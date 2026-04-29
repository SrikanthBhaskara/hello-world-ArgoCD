# Bitdefender ArgoCD Test

This repository is now scoped only to testing the Bitdefender scanner ArgoCD deployment before promoting the same pattern into `cloudsec-sfcn-cm-ops`.

## What To Apply

Apply the root app if you want ArgoCD to manage the Bitdefender child app:

```powershell
kubectl apply -f .\argocd\application-root.yaml
```

Or apply only the Bitdefender child app directly:

```powershell
kubectl apply -f .\argocd\projects\scanners-dev\bitdefender-application.yaml
```

## What It Deploys

The Bitdefender ArgoCD Application pulls this Helm chart:

```text
776389595347.dkr.ecr.us-west-2.amazonaws.com/sib/helmcharts/ares/bitdefender-scanner:0.1.0
```

The Helm chart deploys this Docker image:

```text
776389595347.dkr.ecr.us-west-2.amazonaws.com/ares/bitdefender:local-vm-setup-gcp
```

## Required Cluster Dependencies

- ArgoCD installed in `argocd`.
- ArgoCD configured to read OCI Helm charts from ECR.
- External Secrets Operator installed.
- `ClusterSecretStore/aws-ares` configured.
- `cert-manager` installed.
- `ClusterIssuer/default-ca` available, or update `certManager.issuerName`.

## Verify

```powershell
kubectl get application bitdefender-scanner-dev -n argocd
kubectl get pods -n mars-scanner-dev
kubectl get externalsecret -n mars-scanner-dev
kubectl get certificate -n mars-scanner-dev
```
