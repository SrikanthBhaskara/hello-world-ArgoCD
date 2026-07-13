# Kubernetes 06 – ConfigMaps & Secrets

## 0. Goal of This Note

- Understand the difference between ConfigMaps and Secrets
- Create and manage configuration from multiple sources
- Inject config via environment variables and volumes
- Handle Secrets safely (rotation, encryption at rest)

---

## 1. ConfigMaps

### 1.1 What is a ConfigMap?

A **ConfigMap** stores **non-sensitive configuration data** as key-value pairs. It decouples configuration from container images.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  namespace: default
data:
  # Simple key-value pairs
  APP_ENV: "production"
  LOG_LEVEL: "info"
  MAX_CONNECTIONS: "100"
  
  # Multi-line config file
  nginx.conf: |
    server {
      listen 80;
      root /usr/share/nginx/html;
    }
  
  # Properties file
  database.properties: |
    db.host=postgres
    db.port=5432
    db.name=myapp
```

### 1.2 Creating ConfigMaps

```bash
# From literals
kubectl create configmap app-config \
  --from-literal=APP_ENV=production \
  --from-literal=LOG_LEVEL=info

# From a file (key = filename, value = file content)
kubectl create configmap nginx-config --from-file=nginx.conf

# From a file with custom key name
kubectl create configmap nginx-config --from-file=config=nginx.conf

# From a directory (creates one key per file)
kubectl create configmap app-config --from-file=./config-dir/

# From an .env file (each KEY=VALUE becomes a separate key)
kubectl create configmap app-config --from-env-file=.env

# Dry run to review
kubectl create configmap app-config --from-literal=key=val \
  --dry-run=client -o yaml
```

### 1.3 Using ConfigMap as Environment Variables

```yaml
containers:
- name: app
  image: my-app
  
  # Load specific keys
  env:
  - name: APP_ENV
    valueFrom:
      configMapKeyRef:
        name: app-config
        key: APP_ENV
        optional: false        # pod fails to start if key missing (default: false)
  
  - name: LOG_LEVEL
    valueFrom:
      configMapKeyRef:
        name: app-config
        key: LOG_LEVEL
  
  # Load ALL keys from ConfigMap as env vars
  envFrom:
  - configMapRef:
      name: app-config
      optional: true           # don't fail if configmap missing
  
  # Multiple ConfigMaps
  envFrom:
  - configMapRef:
      name: app-config
  - configMapRef:
      name: feature-flags
    prefix: FEATURE_           # prefix keys to avoid conflicts
```

### 1.4 Using ConfigMap as Volume (Files)

```yaml
volumes:
- name: config-vol
  configMap:
    name: app-config
    
    # Mount only specific keys
    items:
    - key: nginx.conf
      path: nginx.conf           # filename in the mounted directory
      mode: 0644
    
    defaultMode: 0644

containers:
- name: nginx
  volumeMounts:
  - name: config-vol
    mountPath: /etc/nginx/conf.d  # entire configmap as directory
    readOnly: true
  
  # Mount a single key as a file
  - name: config-vol
    mountPath: /etc/nginx/nginx.conf
    subPath: nginx.conf          # mount only this key
    readOnly: true
```

> **Important**: Using `subPath` means the file is NOT automatically updated when the ConfigMap changes. Without `subPath`, files update automatically (with ~1 min delay).

---

## 2. Secrets

### 2.1 What is a Secret?

A **Secret** stores **sensitive data** such as passwords, API tokens, SSH keys, TLS certificates. Like ConfigMaps, but:
- Data is **base64-encoded** (not encrypted by default!)
- Access is restricted via RBAC
- Can be encrypted at rest with `EncryptionConfiguration`
- Kubernetes tries to not write Secret data to disk (uses tmpfs)

> **Base64 encoding ≠ encryption**. Anyone with read access to the Secret can decode it with `base64 -d`.

### 2.2 Secret Types

| Type | When to use |
|------|------------|
| `Opaque` | Default; arbitrary user-defined data |
| `kubernetes.io/service-account-token` | SA token (auto-created) |
| `kubernetes.io/dockerconfigjson` | Docker registry credentials |
| `kubernetes.io/tls` | TLS certificate + key |
| `kubernetes.io/ssh-auth` | SSH private key |
| `kubernetes.io/basic-auth` | Username + password |
| `bootstrap.kubernetes.io/token` | Bootstrap tokens |

### 2.3 Creating Secrets

```bash
# Generic (Opaque) secret
kubectl create secret generic db-secret \
  --from-literal=username=admin \
  --from-literal=password=s3cr3t!

# From files
kubectl create secret generic app-secret \
  --from-file=api-key.txt \
  --from-file=ssh-key=~/.ssh/id_rsa

# TLS secret
kubectl create secret tls my-tls-secret \
  --cert=tls.crt \
  --key=tls.key

# Docker registry secret
kubectl create secret docker-registry registry-creds \
  --docker-server=docker.io \
  --docker-username=myuser \
  --docker-password=mypassword \
  --docker-email=user@example.com
```

### 2.4 Secret YAML (with base64 encoding)

```bash
# Encode values
echo -n "admin" | base64        # YWRtaW4=
echo -n "s3cr3t!" | base64     # czNjcjN0IQ==

# Decode
echo "YWRtaW4=" | base64 -d    # admin
```

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-secret
type: Opaque
data:
  username: YWRtaW4=           # base64("admin")
  password: czNjcjN0IQ==       # base64("s3cr3t!")

# Alternatively – plaintext with stringData (auto-encoded)
apiVersion: v1
kind: Secret
metadata:
  name: db-secret
type: Opaque
stringData:                    # plaintext; converted to base64 on apply
  username: admin
  password: s3cr3t!
```

### 2.5 Docker Registry Secret

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: registry-creds
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: <base64-of-docker-config-json>

# Use in Pod
spec:
  imagePullSecrets:
  - name: registry-creds
  containers:
  - name: app
    image: myregistry.com/my-app:latest
```

### 2.6 Using Secrets as Environment Variables

```yaml
containers:
- name: app
  env:
  # Specific key
  - name: DB_USERNAME
    valueFrom:
      secretKeyRef:
        name: db-secret
        key: username
        optional: false
  
  - name: DB_PASSWORD
    valueFrom:
      secretKeyRef:
        name: db-secret
        key: password
  
  # All keys from a Secret
  envFrom:
  - secretRef:
      name: db-secret
```

### 2.7 Using Secrets as Volumes

```yaml
volumes:
- name: secret-vol
  secret:
    secretName: db-secret
    defaultMode: 0400          # important: restrict permissions!
    
    # Mount specific keys
    items:
    - key: username
      path: db-username
    - key: password
      path: db-password

containers:
- name: app
  volumeMounts:
  - name: secret-vol
    mountPath: /etc/secrets
    readOnly: true
```

Files are mounted as:
```
/etc/secrets/db-username  → contains "admin"
/etc/secrets/db-password  → contains "s3cr3t!"
```

---

## 3. ConfigMap vs Secret Comparison

| | ConfigMap | Secret |
|-|-----------|--------|
| **Sensitive data** | No | Yes |
| **Storage format** | Plaintext | Base64 encoded |
| **Encrypted at rest** | No (by default) | No (by default, but can be) |
| **RBAC restriction** | Recommended | Required |
| **Max size** | 1 MiB | 1 MiB |
| **Use for** | App settings, config files | Passwords, tokens, certs |

---

## 4. Managing ConfigMaps and Secrets

```bash
# View ConfigMap
kubectl get configmap app-config
kubectl describe configmap app-config
kubectl get configmap app-config -o yaml

# View Secret (data will be base64 encoded)
kubectl get secret db-secret
kubectl describe secret db-secret    # shows keys but NOT values
kubectl get secret db-secret -o yaml

# Decode a secret value
kubectl get secret db-secret -o jsonpath='{.data.password}' | base64 -d

# All secrets in namespace
kubectl get secrets

# Edit ConfigMap
kubectl edit configmap app-config

# Update a ConfigMap from a file
kubectl create configmap nginx-config --from-file=nginx.conf --dry-run=client -o yaml | kubectl apply -f -

# Delete
kubectl delete configmap app-config
kubectl delete secret db-secret
```

---

## 5. Configuration Best Practices

### 5.1 Environment-Specific Config

Structure per environment:
```
configs/
  base/
    configmap.yaml
    secret.yaml
  overlays/
    development/
      kustomization.yaml
    production/
      kustomization.yaml
```

### 5.2 External Secret Management

For production, use external secret managers instead of plain Kubernetes Secrets:

| Tool | Description |
|------|------------|
| **External Secrets Operator** | Syncs secrets from AWS SM, GCP SM, HashiCorp Vault, Azure KV |
| **Sealed Secrets** | Encrypts secrets; safe to store in Git |
| **HashiCorp Vault Agent** | Injects secrets via sidecar or init container |
| **CSI Secret Store** | Mounts secrets from external stores as volumes |

**External Secrets Operator example:**
```yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: db-credentials
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: aws-secret-manager
    kind: ClusterSecretStore
  target:
    name: db-secret         # name of Kubernetes Secret to create
    creationPolicy: Owner
  data:
  - secretKey: password     # K8s secret key
    remoteRef:
      key: prod/database    # AWS SM secret path
      property: password    # JSON property
```

### 5.3 Enabling Encryption at Rest

Edit the API server configuration:

```yaml
# /etc/kubernetes/encryption-config.yaml
apiVersion: apiserver.config.k8s.io/v1
kind: EncryptionConfiguration
resources:
- resources:
  - secrets
  providers:
  - aescbc:
      keys:
      - name: key1
        secret: <base64-encoded-32-byte-key>
  - identity: {}
```

```bash
# Add to kube-apiserver:
--encryption-provider-config=/etc/kubernetes/encryption-config.yaml
```

### 5.4 Secret Security Checklist

- [ ] Enable RBAC – only pods/users that need secrets can read them
- [ ] Use `readOnly: true` when mounting as volume
- [ ] Set file permissions `0400` for secret volume mounts
- [ ] Enable encryption at rest for etcd
- [ ] Consider external secret managers (External Secrets Operator, Vault)
- [ ] Rotate secrets regularly
- [ ] Never commit secrets to Git (even base64 encoded)
- [ ] Use audit logging to detect unauthorized access
- [ ] Set `automountServiceAccountToken: false` when not needed

---

## 6. Immutable ConfigMaps and Secrets

Mark as immutable to prevent accidental changes (also improves performance):

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-config
immutable: true             # cannot be modified after creation
data:
  key: value

---
apiVersion: v1
kind: Secret
metadata:
  name: my-secret
immutable: true
data:
  key: dmFsdWU=
```

Once immutable, to change: delete and recreate.

---

## 7. Watching for Config Changes

Pods do NOT automatically pick up ConfigMap/Secret changes when using `env`/`envFrom`. They need a restart.

**Auto-reload options:**
1. Mount as volume (files update after ~1 min, without `subPath`)
2. Use a tool like **Reloader** (watches for changes and rolling-restarts)
3. Use **Kustomize** config hash to force pod recreation on config change

```yaml
# Reloader annotation example
metadata:
  annotations:
    reloader.stakater.com/auto: "true"
```
