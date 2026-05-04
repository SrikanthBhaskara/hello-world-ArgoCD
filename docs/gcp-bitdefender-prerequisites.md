# GCP Bitdefender ArgoCD Prerequisites

This document explains the cluster dependencies required before the Bitdefender scanner can be deployed through ArgoCD and Helm.

The Bitdefender ArgoCD test app is here:

```text
argocd/projects/scanners-dev/bitdefender-application.yaml
```

It deploys:

```text
Helm chart:
776389595347.dkr.ecr.us-west-2.amazonaws.com/sib/helmcharts/ares/bitdefender-scanner:0.1.0

Docker image:
776389595347.dkr.ecr.us-west-2.amazonaws.com/ares/bitdefender:local-vm-setup-gcp
```

## Simple Overview

ArgoCD and Helm can deploy Bitdefender, but they should not store sensitive values directly in Git.

Bitdefender needs sensitive values at runtime:

```text
keystore password
Bitdefender licence serial
AWS credentials
ECR Docker image pull token
ECR Helm chart pull token
```

These values should not be committed into YAML files. That is why the deployment needs External Secrets Operator.

The high-level flow is:

```text
AWS Secrets Manager / AWS ECR
        |
        v
External Secrets Operator
        |
        v
Kubernetes Secret
        |
        v
ArgoCD / Bitdefender pod
```

The full deployment flow is:

```text
ArgoCD deploys the application.
Helm renders the Kubernetes resources.
External Secrets Operator creates required Kubernetes Secrets.
cert-manager creates the TLS certificate.
Kubernetes starts the Bitdefender pod.
```

## What Is ESO?

ESO means External Secrets Operator.

It is a Kubernetes controller that reads secrets from an external secret provider and creates normal Kubernetes `Secret` objects.

In this deployment, the external providers are:

```text
AWS Secrets Manager
AWS ECR
```

ESO lets us manage secret references in Git without putting the secret values in Git.

Without ESO, we would need to manually run commands like:

```powershell
kubectl create secret generic ...
kubectl create secret docker-registry ...
```

That would not be proper GitOps because someone would need to manually create or refresh secrets outside ArgoCD.

With ESO, the Git repo stores only references and templates. ESO creates the real Kubernetes Secrets inside the cluster.

## Why Each Dependency Is Needed

| Dependency | Why It Is Needed |
|---|---|
| ArgoCD | Watches the Git repo and applies the Bitdefender Application. |
| Helm | Packages the Bitdefender Kubernetes resources as a reusable chart. |
| External Secrets Operator | Creates Kubernetes Secrets from AWS Secrets Manager and AWS ECR tokens. |
| cert-manager | Creates the TLS certificate used by Bitdefender HTTPS on port `8443`. |
| `ClusterIssuer/default-ca` | Tells cert-manager which issuer/CA to use when creating the Bitdefender certificate. |
| AWS access for ESO | Allows ESO to read AWS Secrets Manager and generate ECR auth tokens. |

## What ArgoCD Manages For Bitdefender

The `hello-world-ArgoCD` test repo now manages the Bitdefender-specific pieces:

```text
Namespace: mars
ArgoCD ECR Helm repository secret
Docker image pull secret: ecr-regcred
Bitdefender ArgoCD Application
Bitdefender Helm release
```

The Jenkins flag controls only the build/publish side:

```text
build_sib_scanners=true
```

When that flag is enabled, Jenkins publishes the Bitdefender Docker image and Helm chart to ECR.

ArgoCD then consumes those ECR artifacts. The ESO manifests in this repo create the credentials ArgoCD and Kubernetes need to pull from ECR.

The platform team or cluster bootstrap still needs to provide the shared cluster services:

```text
ArgoCD
External Secrets Operator
cert-manager
ClusterIssuer/default-ca or equivalent
AWS identity/permissions for ESO
```

## Required Components

Before applying the ArgoCD app, the GCP cluster must have:

- ArgoCD
- External Secrets Operator
- cert-manager
- `ClusterIssuer/default-ca`
- AWS access for External Secrets Operator

These are cluster-level prerequisites. The Bitdefender app should not create or own them because they are shared platform services.

## 1. External Secrets Operator

External Secrets Operator, usually called ESO, is a Kubernetes controller that reads secrets from an external provider and creates Kubernetes `Secret` objects.

For this Bitdefender deployment, ESO is needed for two jobs:

1. Read Bitdefender runtime secrets from AWS Secrets Manager.
2. Generate ECR login tokens for ArgoCD Helm access and Kubernetes image pull access.

### Why Bitdefender Needs ESO

The Bitdefender container needs sensitive values such as:

```text
keystore password
Bitdefender licence serial
AWS access key id
AWS secret access key
```

Those values should not be stored in Git. Instead, the Helm chart creates an `ExternalSecret`, and ESO creates the real Kubernetes Secret inside the namespace.

The Bitdefender Helm chart expects this Secret:

```text
bitdefender-secrets
```

The ArgoCD test manifests also use ESO to create:

```text
argocd/bitdefender-ecr-helm-repo
mars/ecr-regcred
```

### ESO Resources Used

The Bitdefender flow uses these ESO custom resources:

```text
ExternalSecret
ClusterSecretStore
ECRAuthorizationToken
```

`ExternalSecret` says what Kubernetes Secret should be created.

`ClusterSecretStore` tells ESO how to connect to AWS Secrets Manager.

`ECRAuthorizationToken` asks AWS ECR for a short-lived registry token.

### Verify ESO Is Installed

Run:

```powershell
kubectl get crd externalsecrets.external-secrets.io
kubectl get crd clustersecretstores.external-secrets.io
kubectl get crd ecrauthorizationtokens.generators.external-secrets.io
kubectl get pods -A | findstr external-secrets
```

Expected:

```text
CRDs exist
external-secrets controller pod is Running
```

If `ecrauthorizationtokens.generators.external-secrets.io` is missing, the current GitOps ECR token generation will not work.

### Verify ClusterSecretStore

Run:

```powershell
kubectl get clustersecretstore
kubectl get clustersecretstore aws-ares -o yaml
```

Expected:

```text
aws-ares exists
status condition is Ready=True
provider is AWS Secrets Manager
region is us-west-2 or the expected AWS region
```

If `aws-ares` does not exist, Bitdefender runtime secrets cannot be populated.

## 2. cert-manager

cert-manager is a Kubernetes controller that creates and renews TLS certificates.

For Bitdefender, the scanner exposes HTTPS on port `8443`. The pod needs a TLS certificate mounted into the container so the service can start correctly.

### Why Bitdefender Needs cert-manager

The Helm chart creates a cert-manager `Certificate` resource. cert-manager then creates the Kubernetes TLS Secret used by the Bitdefender deployment.

The Bitdefender startup scripts expect mounted cert files similar to the local VM deployment:

```text
/tmp/certs/tls.crt
/tmp/certs/tls.key
```

Without cert-manager and a working issuer, the `Certificate` will not become ready and the pod may fail or remain unhealthy.

### Verify cert-manager Is Installed

Run:

```powershell
kubectl get crd certificates.cert-manager.io
kubectl get pods -A | findstr cert-manager
```

Expected:

```text
certificates.cert-manager.io exists
cert-manager pods are Running
```

Typical pods:

```text
cert-manager
cert-manager-cainjector
cert-manager-webhook
```

## 3. ClusterIssuer/default-ca

A `ClusterIssuer` is a cert-manager resource that tells cert-manager how to issue certificates.

The Bitdefender ArgoCD test app currently uses:

```yaml
certManager:
  enabled: true
  issuerName: default-ca
```

That means the GCP cluster must already have:

```text
ClusterIssuer/default-ca
```

### Why Bitdefender Needs default-ca

The Helm chart creates a `Certificate` that references `default-ca`. cert-manager uses that issuer to create the scanner TLS certificate.

If `default-ca` is not present, the `Certificate` will be created, but it will not become ready.

### Verify ClusterIssuer

Run:

```powershell
kubectl get clusterissuer
kubectl get clusterissuer default-ca -o yaml
```

Expected:

```text
default-ca exists
Ready=True
```

If the cluster uses a different issuer name, update this value in:

```text
argocd/projects/scanners-dev/bitdefender-application.yaml
```

Example:

```yaml
certManager:
  enabled: true
  issuerName: <actual-cluster-issuer-name>
```

## 4. AWS Access For ESO

ESO needs AWS permissions because this GCP cluster still reads scanner secrets and ECR tokens from AWS.

There are two types of AWS access required.

## AWS Secrets Manager Access

Bitdefender runtime secrets are expected under paths like:

```text
gcp-scanner-test/sib/ares/bitdefender/keystore-password
gcp-scanner-test/sib/ares/bitdefender/licence-serial
gcp-scanner-test/sib/ares/bitdefender/aws-credentials
```

ESO must be allowed to call AWS Secrets Manager APIs for these paths.

Required AWS permissions usually include:

```text
secretsmanager:GetSecretValue
secretsmanager:DescribeSecret
```

If Secrets Manager access is broken, the Bitdefender `ExternalSecret` will not create `bitdefender-secrets`.

Verify after sync:

```powershell
kubectl get externalsecret -n mars
kubectl describe externalsecret bitdefender-secrets -n mars
kubectl get secret bitdefender-secrets -n mars
```

Expected:

```text
ExternalSecret status shows SecretSynced=True
Kubernetes Secret bitdefender-secrets exists
```

## AWS ECR Token Access

ArgoCD and Kubernetes both need ECR credentials:

1. ArgoCD needs ECR auth to pull the OCI Helm chart.
2. Kubernetes needs ECR auth to pull the Bitdefender Docker image.

The test manifests generate both through ESO:

```text
argocd-ecr-helm-repo-externalsecret.yaml
image-pull-secret-externalsecret.yaml
```

These use:

```text
ECRAuthorizationToken
```

ESO must be allowed to call:

```text
ecr:GetAuthorizationToken
```

If ECR token access is broken:

- ArgoCD may not pull the Helm chart.
- Kubernetes may show `ImagePullBackOff` or `ErrImagePull`.

Verify after applying the root app:

```powershell
kubectl get externalsecret bitdefender-ecr-helm-repo -n argocd
kubectl describe externalsecret bitdefender-ecr-helm-repo -n argocd
kubectl get secret bitdefender-ecr-helm-repo -n argocd

kubectl get externalsecret ecr-regcred -n mars
kubectl describe externalsecret ecr-regcred -n mars
kubectl get secret ecr-regcred -n mars
```

Expected:

```text
argocd/bitdefender-ecr-helm-repo exists
mars/ecr-regcred exists
ExternalSecret status shows SecretSynced=True
```

## 5. How To Verify Everything Before Deploy

Use these commands from a terminal connected to the correct GCP test cluster.

```powershell
kubectl config current-context
kubectl get nodes
```

Check ESO:

```powershell
kubectl get crd externalsecrets.external-secrets.io
kubectl get crd clustersecretstores.external-secrets.io
kubectl get crd ecrauthorizationtokens.generators.external-secrets.io
kubectl get pods -A | findstr external-secrets
kubectl get clustersecretstore aws-ares
```

Check cert-manager:

```powershell
kubectl get crd certificates.cert-manager.io
kubectl get pods -A | findstr cert-manager
kubectl get clusterissuer default-ca
```

Check ArgoCD:

```powershell
kubectl get ns argocd
kubectl get pods -n argocd
kubectl get crd applications.argoproj.io
```

## 6. Deploy Bitdefender After Prerequisites Are Ready

Push the `hello-world-ArgoCD` repo changes first.

Then apply the root app:

```powershell
cd C:\dev\hello-world-ArgoCD
kubectl apply -f .\argocd\application-root.yaml
```

Check ArgoCD app:

```powershell
kubectl get application bitdefender-scanner-dev -n argocd
kubectl describe application bitdefender-scanner-dev -n argocd
```

Check generated secrets:

```powershell
kubectl get secret bitdefender-ecr-helm-repo -n argocd
kubectl get secret ecr-regcred -n mars
kubectl get secret bitdefender-secrets -n mars
```

Check pod:

```powershell
kubectl get pods -n mars
kubectl describe pod -n mars -l app.kubernetes.io/name=bitdefender-scanner
kubectl logs -n mars deployment/bitdefender --tail=100
```

## 7. Common Failure Mapping

| Symptom | Likely Missing Piece | What To Check |
|---|---|---|
| `no matches for kind ExternalSecret` | ESO CRDs missing or wrong API version | `kubectl get crd externalsecrets.external-secrets.io` |
| `no matches for kind ECRAuthorizationToken` | ESO generator CRD missing | `kubectl get crd ecrauthorizationtokens.generators.external-secrets.io` |
| `ClusterSecretStore aws-ares not found` | AWS secret store missing | `kubectl get clustersecretstore aws-ares` |
| `ExternalSecret not synced` | ESO AWS access or AWS secret path issue | `kubectl describe externalsecret ...` |
| ArgoCD cannot pull chart | ECR Helm repo secret missing or bad token | `kubectl get secret bitdefender-ecr-helm-repo -n argocd` |
| Pod `ImagePullBackOff` | Docker pull secret missing or expired | `kubectl get secret ecr-regcred -n mars` |
| Certificate not ready | cert-manager or issuer issue | `kubectl describe certificate -n mars` |
| `issuer default-ca not found` | Wrong issuer name | `kubectl get clusterissuer` |

## 8. What Is Still Bootstrap

ArgoCD and Helm can manage the Bitdefender application, but the platform still needs these installed first:

```text
ArgoCD
External Secrets Operator
cert-manager
ClusterIssuer/default-ca or equivalent
AWS identity/permissions for ESO
```

After those are present, the Bitdefender-specific deployment can be GitOps-managed through ArgoCD.
