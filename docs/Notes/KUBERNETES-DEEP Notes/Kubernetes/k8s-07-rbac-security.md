# Kubernetes 07 – RBAC & Security

## 0. Goal of This Note

- Understand Kubernetes RBAC (Role-Based Access Control)
- Create Roles, ClusterRoles, Bindings and ServiceAccounts
- Configure Security Contexts for Pods and containers
- Apply Pod Security Standards
- Understand network security with NetworkPolicies
- Know image security best practices

---

## 1. Authentication vs Authorization

```
Request → Authentication → Authorization → Admission Control → etcd
           (Who are you?)   (Can you do    (Policy checks)
                            this action?)
```

**Authentication**: Verifying identity
- Client certificates (x509)
- Bearer tokens (ServiceAccount tokens, OIDC)
- Basic auth (deprecated)
- Authentication proxies

**Authorization methods:**
- **RBAC** (Role-Based Access Control) – most common
- ABAC (Attribute-Based Access Control) – legacy
- Node authorization – for kubelets
- Webhook authorization

---

## 2. RBAC Concepts

### 2.1 RBAC Building Blocks

```
Subject (who?)          Role (what can they do?)       Binding (connect them)
────────────────         ─────────────────────────      ────────────────────────
User                     Role (namespaced)               RoleBinding
Group                    ClusterRole (cluster-wide)      ClusterRoleBinding
ServiceAccount
```

**Scope rules:**
| Combination | Scope |
|-------------|-------|
| Role + RoleBinding | Namespace-scoped |
| ClusterRole + ClusterRoleBinding | Cluster-wide |
| ClusterRole + RoleBinding | ClusterRole used within one namespace |

### 2.2 Subjects

```yaml
# Single user
subjects:
- kind: User
  name: alice
  apiGroup: rbac.authorization.k8s.io

# Group
subjects:
- kind: Group
  name: developers
  apiGroup: rbac.authorization.k8s.io

# ServiceAccount
subjects:
- kind: ServiceAccount
  name: my-sa
  namespace: default
```

---

## 3. Roles and ClusterRoles

### 3.1 Role (Namespace-Scoped)

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
  namespace: default
rules:
- apiGroups: [""]             # "" = core API group (pods, services, etc.)
  resources: ["pods"]
  verbs: ["get", "list", "watch"]

- apiGroups: [""]
  resources: ["pods/log"]     # subresources use /
  verbs: ["get"]

- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]

# Specific resource names only
- apiGroups: [""]
  resources: ["configmaps"]
  resourceNames: ["app-config", "feature-flags"]
  verbs: ["get", "list"]
```

**Common verbs:**
| Verb | HTTP method | Meaning |
|------|------------|---------|
| `get` | GET | Read a specific resource |
| `list` | GET (collection) | List resources |
| `watch` | GET (watch) | Watch for changes |
| `create` | POST | Create a resource |
| `update` | PUT | Replace a resource |
| `patch` | PATCH | Partially update |
| `delete` | DELETE | Delete a resource |
| `deletecollection` | DELETE | Delete all |
| `*` | any | All verbs |

**Common apiGroups:**
| apiGroup | Resources |
|----------|-----------|
| `""` (core) | pods, services, configmaps, secrets, pv, pvc, serviceaccounts, nodes, namespaces |
| `apps` | deployments, statefulsets, daemonsets, replicasets |
| `batch` | jobs, cronjobs |
| `networking.k8s.io` | ingresses, networkpolicies |
| `rbac.authorization.k8s.io` | roles, clusterroles, rolebindings |
| `storage.k8s.io` | storageclasses |
| `autoscaling` | horizontalpodautoscalers |
| `*` | all |

### 3.2 ClusterRole (Cluster-Wide)

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: node-reader
rules:
- apiGroups: [""]
  resources: ["nodes"]
  verbs: ["get", "list", "watch"]

- apiGroups: [""]
  resources: ["persistentvolumes"]     # PVs are cluster-scoped
  verbs: ["get", "list"]

- nonResourceURLs: ["/healthz", "/metrics"]  # non-resource URLs
  verbs: ["get"]
```

### 3.3 Built-In ClusterRoles

```bash
kubectl get clusterroles | grep -v system
```

| ClusterRole | Permissions |
|------------|------------|
| `cluster-admin` | Everything – superuser |
| `admin` | Full access within a namespace |
| `edit` | Create/update/delete most resources in namespace |
| `view` | Read-only access in namespace |

---

## 4. Bindings

### 4.1 RoleBinding

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: alice-pod-reader
  namespace: default
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role                         # or ClusterRole
  name: pod-reader
subjects:
- kind: User
  name: alice
  apiGroup: rbac.authorization.k8s.io
```

### 4.2 ClusterRoleBinding

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: cluster-admin-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: User
  name: admin@example.com
  apiGroup: rbac.authorization.k8s.io
```

### 4.3 Creating RBAC Imperatively

```bash
# Create Role
kubectl create role pod-reader \
  --verb=get,list,watch \
  --resource=pods \
  -n default

# Create ClusterRole
kubectl create clusterrole node-reader \
  --verb=get,list,watch \
  --resource=nodes

# Create RoleBinding
kubectl create rolebinding alice-pod-reader \
  --role=pod-reader \
  --user=alice \
  -n default

# ClusterRoleBinding (uses ClusterRole, binds to user cluster-wide)
kubectl create clusterrolebinding alice-admin \
  --clusterrole=admin \
  --user=alice

# Bind ClusterRole to namespace (reuse ClusterRole in a specific namespace)
kubectl create rolebinding alice-view-prod \
  --clusterrole=view \
  --user=alice \
  --namespace=production
```

---

## 5. ServiceAccounts

### 5.1 What is a ServiceAccount?

A **ServiceAccount** provides an **identity for processes in a Pod** to interact with the Kubernetes API. Used for:
- Pods that need to call the K8s API
- Applications that interact with other services using K8s-issued tokens

Every namespace has a `default` ServiceAccount. Each Pod automatically gets a token from its ServiceAccount.

### 5.2 Default ServiceAccount

```yaml
# Pods use default SA if none specified
spec:
  serviceAccountName: default    # implicit

# Disable automounting (security best practice when not needed)
spec:
  automountServiceAccountToken: false
```

### 5.3 Creating and Using a ServiceAccount

```yaml
# 1. Create a ServiceAccount
apiVersion: v1
kind: ServiceAccount
metadata:
  name: app-sa
  namespace: default

---
# 2. Create a Role
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
  namespace: default
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch"]

---
# 3. Bind SA to Role
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: app-sa-pod-reader
  namespace: default
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: pod-reader
subjects:
- kind: ServiceAccount
  name: app-sa
  namespace: default

---
# 4. Use SA in a Pod
apiVersion: v1
kind: Pod
metadata:
  name: my-app
spec:
  serviceAccountName: app-sa
  containers:
  - name: app
    image: my-app
```

### 5.4 Token Projection (secure, short-lived tokens)

```yaml
volumes:
- name: token-vol
  projected:
    sources:
    - serviceAccountToken:
        path: token
        expirationSeconds: 3600
        audience: my-service

containers:
- volumeMounts:
  - name: token-vol
    mountPath: /var/run/secrets/custom
```

---

## 6. Checking Permissions

```bash
# Can I do something?
kubectl auth can-i create pods
kubectl auth can-i create pods --namespace production
kubectl auth can-i delete nodes
kubectl auth can-i '*' '*'            # check all permissions (admin check)

# Can another user/SA do something? (as admin)
kubectl auth can-i list pods --as alice
kubectl auth can-i list pods --as=system:serviceaccount:default:my-sa

# Who I am
kubectl auth whoami

# Get all permissions in a namespace (verbose)
kubectl auth can-i --list
kubectl auth can-i --list --namespace=production

# Check what a role can do
kubectl describe role pod-reader
kubectl describe clusterrole admin
```

---

## 7. Security Contexts

Security contexts set **privilege and access control settings** for Pods/containers.

### 7.1 Pod-Level Security Context

```yaml
spec:
  securityContext:
    runAsUser: 1000              # run all containers as user 1000
    runAsGroup: 3000             # run all containers with group 3000
    fsGroup: 2000                # volume ownership (mounted volumes owned by this group)
    runAsNonRoot: true           # reject if image runs as root
    supplementalGroups: [4000]
    sysctls:                     # kernel parameters
    - name: net.ipv4.tcp_keepalive_time
      value: "300"
```

### 7.2 Container-Level Security Context

```yaml
containers:
- name: app
  image: nginx
  securityContext:
    runAsUser: 1000
    runAsNonRoot: true
    readOnlyRootFilesystem: true     # make root FS read-only
    allowPrivilegeEscalation: false  # prevent sudo, setuid
    privileged: false                # no host-level access
    capabilities:
      drop:
      - ALL                          # drop all capabilities
      add:
      - NET_BIND_SERVICE             # add back specific ones
    seccompProfile:
      type: RuntimeDefault           # use container runtime's default seccomp
```

### 7.3 Recommended Secure Container Config

```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 10000
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: true
  capabilities:
    drop:
    - ALL
  seccompProfile:
    type: RuntimeDefault
```

---

## 8. Pod Security Standards (PSS)

Kubernetes defines three security policy **levels** applied at the namespace level:

| Level | Restriction | Description |
|-------|------------|-------------|
| **Privileged** | None | No restrictions |
| **Baseline** | Minimal | Prevents known privilege escalations |
| **Restricted** | Strict | Best practices for security-hardened workloads |

### 8.1 Applying PSS to a Namespace

```yaml
# Label the namespace with the policy
apiVersion: v1
kind: Namespace
metadata:
  name: production
  labels:
    # enforce: reject violating pods
    # audit: log violations
    # warn: warn about violations (in API response)
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/enforce-version: latest
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/warn: restricted
```

```bash
# Apply via kubectl
kubectl label namespace production \
  pod-security.kubernetes.io/enforce=restricted \
  --overwrite
```

### 8.2 What Restricted Policy Requires

- `runAsNonRoot: true`
- `allowPrivilegeEscalation: false`
- `seccompProfile.type: RuntimeDefault` or `Localhost`
- `capabilities.drop: [ALL]`
- No `hostPath`, `hostNetwork`, `hostPID`, `hostIPC`
- No privileged containers

---

## 9. Admission Controllers

Admission controllers validate/mutate API requests **before** objects are persisted:

| Controller | Purpose |
|-----------|---------|
| `NamespaceLifecycle` | Prevent creation in terminating namespaces |
| `ResourceQuota` | Enforce resource quotas |
| `LimitRanger` | Set default resource limits |
| `ServiceAccount` | Auto-inject ServiceAccount |
| `PodSecurity` | Enforce Pod Security Standards |
| `MutatingWebhook` | Call external webhook to modify objects |
| `ValidatingWebhook` | Call external webhook to validate objects |

---

## 10. ResourceQuota and LimitRange

### 10.1 ResourceQuota

Limits total resource consumption in a namespace:

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: ns-quota
  namespace: production
spec:
  hard:
    # Compute
    requests.cpu: "10"
    requests.memory: 20Gi
    limits.cpu: "20"
    limits.memory: 40Gi
    
    # Object counts
    pods: "50"
    services: "20"
    persistentvolumeclaims: "10"
    secrets: "50"
    configmaps: "50"
    
    # LoadBalancers (expensive cloud resources)
    services.loadbalancers: "2"
    services.nodeports: "5"
```

### 10.2 LimitRange

Sets **default** and **max/min** resource limits for containers:

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: default-limits
  namespace: default
spec:
  limits:
  - type: Container
    default:
      cpu: 200m
      memory: 128Mi
    defaultRequest:
      cpu: 100m
      memory: 64Mi
    max:
      cpu: "2"
      memory: 2Gi
    min:
      cpu: 50m
      memory: 32Mi
  
  - type: PersistentVolumeClaim
    max:
      storage: 20Gi
    min:
      storage: 1Gi
```

---

## 11. Security Best Practices

```bash
# Check current RBAC setup
kubectl get roles,rolebindings -A
kubectl get clusterroles,clusterrolebindings

# Find overly permissive bindings
kubectl get clusterrolebindings -o json | jq '.items[] | select(.roleRef.name=="cluster-admin") | .metadata.name'

# Check who can do what (requires rakkess tool)
# kubectl krew install access-matrix
kubectl access-matrix --namespace=default
```

**Security checklist:**
- [ ] Use RBAC with least-privilege principle
- [ ] Avoid `cluster-admin` for workloads
- [ ] Disable `automountServiceAccountToken` when not needed
- [ ] Set `readOnlyRootFilesystem: true`
- [ ] Set `allowPrivilegeEscalation: false`
- [ ] Drop all capabilities; add only needed ones
- [ ] Set `runAsNonRoot: true`
- [ ] Use Network Policies to restrict pod-to-pod traffic
- [ ] Scan container images for vulnerabilities (Trivy, Snyk)
- [ ] Enable Audit logging
- [ ] Encrypt etcd (includes Secrets at rest)
- [ ] Apply Pod Security Standards (restricted on production namespaces)
- [ ] Use namespaces to isolate teams and environments
- [ ] Set ResourceQuotas to prevent resource exhaustion
