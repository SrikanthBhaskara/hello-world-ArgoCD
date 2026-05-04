# Bitdefender ArgoCD Test

This repository is now scoped only to testing the Bitdefender scanner ArgoCD deployment before promoting the same pattern into `cloudsec-sfcn-cm-ops`.

## How To Deploy To GCP

Push this repository first. The root ArgoCD app reads from the Git repo URL in `argocd/application-root.yaml`, not from your local filesystem.

First, run the Bitdefender Jenkins job with:

```text
build_sib_scanners=true
```

That Jenkins path publishes:

```text
Docker image:
776389595347.dkr.ecr.us-west-2.amazonaws.com/ares/bitdefender:local-vm-setup-gcp

Helm chart:
776389595347.dkr.ecr.us-west-2.amazonaws.com/sib/helmcharts/ares/bitdefender-scanner:0.1.0
```

After that, ArgoCD can deploy the chart. The ESO resources in this repo create the ECR credentials that ArgoCD and Kubernetes need.

Apply the root app:

```powershell
kubectl apply -f .\argocd\application-root.yaml
```

The root app applies `argocd/projects/scanners-dev`, which creates:

- `Namespace/mars`
- ECR token generators for ArgoCD Helm access and Docker image pull access
- `ExternalSecret/bitdefender-ecr-helm-repo` in `argocd`
- `ExternalSecret/ecr-regcred` in `mars`
- `Application/bitdefender-scanner-dev`

So no manual ECR token secret creation is needed for normal testing.

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
- External Secrets Operator installed with the `ECRAuthorizationToken` generator CRD.
- External Secrets Operator must have AWS permission to call ECR `GetAuthorizationToken`.
- `ClusterSecretStore/aws-ares` configured.
- `cert-manager` installed.
- `ClusterIssuer/default-ca` available, or update `certManager.issuerName`.

## Verify

```powershell
kubectl get application bitdefender-scanner-dev -n argocd
kubectl get pods -n mars
kubectl get externalsecret -n mars
kubectl get certificate -n mars
```
