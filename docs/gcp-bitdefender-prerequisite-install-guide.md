# GCP Bitdefender Prerequisite Install Guide

This guide lists the prerequisites that must exist on the GCP VM Kubernetes cluster before deploying Bitdefender through ArgoCD and Helm.

The Bitdefender app itself is managed from:

```text
hello-world-ArgoCD/argocd/application-root.yaml
hello-world-ArgoCD/argocd/projects/scanners-dev/
```

## Prerequisite List

| # | Component | Why It Is Needed |
|---|---|---|
| 1 | ArgoCD | Syncs the Git repo and deploys the Bitdefender ArgoCD Application. |
| 2 | Helm CLI | Installs cluster add-ons such as External Secrets Operator and cert-manager. |
| 3 | External Secrets Operator | Creates Kubernetes Secrets from AWS Secrets Manager and ECR auth tokens. |
| 4 | AWS access for ESO | Allows ESO to call AWS Secrets Manager and ECR. |
| 5 | `ClusterSecretStore/aws-ares` | Tells ESO how to read AWS Secrets Manager. |
| 6 | cert-manager | Creates TLS certificates for the Bitdefender HTTPS endpoint. Temporarily skipped while `certManager.enabled=false` in the test app. |
| 7 | `ClusterIssuer/default-ca` | Issuer used by cert-manager for Bitdefender certificates. Temporarily skipped while `certManager.enabled=false` in the test app. |
| 8 | ECR Docker image | Bitdefender container image. |
| 9 | ECR Helm chart | Bitdefender Helm chart consumed by ArgoCD. |

## Already Completed

The following ECR artifacts were already published by Jenkins:

```text
Docker image:
776389595347.dkr.ecr.us-west-2.amazonaws.com/ares/bitdefender:local-vm-setup-gcp

Helm chart:
776389595347.dkr.ecr.us-west-2.amazonaws.com/sib/helmcharts/ares/bitdefender-scanner:0.1.0
```

## Installation Order

Install in this order:

```text
1. Verify GCP VM cluster access
2. Verify ArgoCD
3. Install Helm CLI if missing
4. Install External Secrets Operator
5. Configure AWS credentials for ESO
6. Create ClusterSecretStore/aws-ares
7. Optional for current test: install cert-manager
8. Optional for current test: create ClusterIssuer/default-ca
9. Apply Bitdefender ArgoCD root app
```

Current temporary test setting:

```yaml
certManager:
  enabled: false
```

Because of this setting, `cert-manager` and `ClusterIssuer/default-ca` can be skipped for the first ArgoCD sync test. Re-enable cert-manager before promoting this pattern to the real `gcp-dev` deployment.

## 1. Verify GCP VM Cluster Access

Run:

```powershell
kubectl config current-context
kubectl get nodes
```

Expected:

```text
kubectl points to the GCP VM/k3s test cluster
kubectl get nodes returns the cluster node
```

If the context is wrong, list contexts:

```powershell
kubectl config get-contexts
```

Switch to the GCP context:

```powershell
kubectl config use-context <gcp-test-context-name>
```

## 2. Verify ArgoCD

Run:

```powershell
kubectl get ns argocd
kubectl get pods -n argocd
kubectl get crd applications.argoproj.io
```

Expected:

```text
argocd namespace exists
ArgoCD pods are Running
Application CRD exists
```

## 3. Install Helm CLI

Check:

```powershell
helm version
```

If Helm is missing, install it on the machine where you run `kubectl`.

On Windows, one simple option is:

```powershell
winget install Helm.Helm
```

After installation, reopen the terminal and verify:

```powershell
helm version
```

## 4. Install External Secrets Operator

External Secrets Operator, or ESO, creates Kubernetes Secrets from external providers.

For Bitdefender, ESO is needed for:

```text
AWS Secrets Manager runtime secrets
ECR token for ArgoCD Helm chart pull
ECR token for Kubernetes Docker image pull
```

Install ESO with Helm:

```powershell
helm repo add external-secrets https://charts.external-secrets.io
helm repo update

helm upgrade --install external-secrets external-secrets/external-secrets `
  -n external-secrets `
  --create-namespace `
  --set installCRDs=true
```

Verify:

```powershell
kubectl get pods -n external-secrets
kubectl get crd externalsecrets.external-secrets.io
kubectl get crd clustersecretstores.external-secrets.io
kubectl get crd ecrauthorizationtokens.generators.external-secrets.io
```

Expected pods:

```text
external-secrets
external-secrets-webhook
external-secrets-cert-controller
```

## 5. Configure AWS Access For ESO

ESO needs AWS permissions for:

```text
secretsmanager:GetSecretValue
secretsmanager:DescribeSecret
ecr:GetAuthorizationToken
```

For dev testing on the GCP VM cluster, the simplest bootstrap is to create an AWS credentials Secret in each namespace that needs AWS access.

Create the Secret in:

```text
external-secrets
argocd
mars
```

`external-secrets/aws-ares-creds` is used by `ClusterSecretStore/aws-ares`.

`argocd/aws-ares-creds` is used by the ArgoCD ECR Helm repository token generator.

`mars/aws-ares-creds` is used by the Kubernetes Docker image pull token generator.

Create the Secrets:

```powershell
foreach ($namespace in @("external-secrets", "argocd", "mars")) {
  kubectl create namespace $namespace --dry-run=client -o yaml | kubectl apply -f -
  kubectl create secret generic aws-ares-creds `
    -n $namespace `
    --from-literal=access-key=<AWS_ACCESS_KEY_ID> `
    --from-literal=secret-access-key=<AWS_SECRET_ACCESS_KEY> `
    --from-literal=session-token=<AWS_SESSION_TOKEN> `
    --dry-run=client -o yaml | kubectl apply -f -
}
```

Do not commit real AWS keys to Git.

The ECR token generator manifests reference this Secret in their own namespaces:

```text
argocd/aws-ares-creds
mars/aws-ares-creds
```

This lets ESO generate:

```text
argocd/bitdefender-ecr-helm-repo
mars/ecr-regcred
```

## 6. Create ClusterSecretStore/aws-ares

This repo includes this file:

```text
bootstrap/clustersecretstore-aws-ares.yaml
```

For long-lived access key credentials:

```yaml
apiVersion: external-secrets.io/v1
kind: ClusterSecretStore
metadata:
  name: aws-ares
spec:
  provider:
    aws:
      service: SecretsManager
      region: us-west-2
      auth:
        secretRef:
          accessKeyIDSecretRef:
            name: aws-ares-creds
            namespace: external-secrets
            key: access-key
          secretAccessKeySecretRef:
            name: aws-ares-creds
            namespace: external-secrets
            key: secret-access-key
```

For temporary AWS session credentials, use:

```yaml
apiVersion: external-secrets.io/v1
kind: ClusterSecretStore
metadata:
  name: aws-ares
spec:
  provider:
    aws:
      service: SecretsManager
      region: us-west-2
      auth:
        secretRef:
          accessKeyIDSecretRef:
            name: aws-ares-creds
            namespace: external-secrets
            key: access-key
          secretAccessKeySecretRef:
            name: aws-ares-creds
            namespace: external-secrets
            key: secret-access-key
          sessionTokenSecretRef:
            name: aws-ares-creds
            namespace: external-secrets
            key: session-token
```

Before applying it, create the AWS credentials Secrets as shown in Step 5.

Apply:

```powershell
kubectl apply -f .\bootstrap\clustersecretstore-aws-ares.yaml
```

Verify:

```powershell
kubectl get clustersecretstore aws-ares
kubectl describe clustersecretstore aws-ares
```

Expected:

```text
Ready=True
```

## 7. Install cert-manager

cert-manager creates the TLS certificate used by Bitdefender HTTPS on port `8443`.

Install with Helm:

```powershell
helm repo add jetstack https://charts.jetstack.io
helm repo update

helm upgrade --install cert-manager jetstack/cert-manager `
  -n cert-manager `
  --create-namespace `
  --set crds.enabled=true
```

Verify:

```powershell
kubectl get pods -n cert-manager
kubectl get crd certificates.cert-manager.io
kubectl get crd clusterissuers.cert-manager.io
```

Expected pods:

```text
cert-manager
cert-manager-cainjector
cert-manager-webhook
```

## 8. Create ClusterIssuer/default-ca

For dev testing, create a self-signed issuer chain.

This repo includes this file:

```text
bootstrap/default-ca-issuer.yaml
```

Content:

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: selfsigned-bootstrap
spec:
  selfSigned: {}
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: default-ca
  namespace: cert-manager
spec:
  isCA: true
  commonName: default-ca
  secretName: default-ca
  duration: 8760h
  renewBefore: 720h
  privateKey:
    algorithm: RSA
    size: 2048
  issuerRef:
    name: selfsigned-bootstrap
    kind: ClusterIssuer
---
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: default-ca
spec:
  ca:
    secretName: default-ca
```

Apply:

```powershell
kubectl apply -f .\bootstrap\default-ca-issuer.yaml
```

Verify:

```powershell
kubectl get clusterissuer
kubectl get clusterissuer default-ca
kubectl get certificate default-ca -n cert-manager
```

Expected:

```text
ClusterIssuer/default-ca exists
Certificate/default-ca Ready=True
```

## 9. Apply Bitdefender ArgoCD Root App

Before this step, push `hello-world-ArgoCD` changes to GitHub `main`.

Then apply:

```powershell
cd C:\dev\hello-world-ArgoCD
kubectl apply -f .\argocd\application-root.yaml
```

Verify:

```powershell
kubectl get application -n argocd
kubectl get application bitdefender-scanner-dev -n argocd
kubectl describe application bitdefender-scanner-dev -n argocd
```

Verify ESO-created secrets:

```powershell
kubectl get externalsecret -A
kubectl get secret bitdefender-ecr-helm-repo -n argocd
kubectl get secret ecr-regcred -n mars
kubectl get secret bitdefender-secrets -n mars
```

Verify pod:

```powershell
kubectl get pods -n mars
kubectl describe pod -n mars -l app.kubernetes.io/name=bitdefender-scanner
kubectl logs -n mars deployment/bitdefender --tail=100
```

## Common Failures

| Symptom | Cause | Fix |
|---|---|---|
| `no matches for kind ExternalSecret` | ESO CRDs missing | Install ESO with `--set installCRDs=true`. |
| `no matches for kind ECRAuthorizationToken` | ESO generator CRD missing | Upgrade/install ESO version that includes generator CRDs. |
| `ClusterSecretStore aws-ares not found` | Secret store missing | Apply `clustersecretstore-aws-ares.yaml`. |
| `ExternalSecret not synced` | AWS permission or secret path issue | Check `kubectl describe externalsecret ...`. |
| ArgoCD cannot pull Helm chart | ECR Helm repo secret not created or token invalid | Check `bitdefender-ecr-helm-repo` in `argocd`. |
| Pod `ImagePullBackOff` | `ecr-regcred` missing/invalid | Check `ecr-regcred` in `mars`. |
| Certificate not ready | cert-manager or issuer issue | Check `kubectl describe certificate -n mars`. |

## Quick Full Verification

```powershell
kubectl get ns argocd
kubectl get pods -n argocd

kubectl get pods -n external-secrets
kubectl get crd externalsecrets.external-secrets.io
kubectl get crd ecrauthorizationtokens.generators.external-secrets.io
kubectl get clustersecretstore aws-ares

kubectl get pods -n cert-manager
kubectl get clusterissuer default-ca

kubectl get application bitdefender-scanner-dev -n argocd
kubectl get externalsecret -A
kubectl get pods -n mars
```
