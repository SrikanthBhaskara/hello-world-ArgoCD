# GCP Bitdefender Automation Scripts

## Bootstrap a new VM/k3s cluster

Run once after ArgoCD is installed and `kubectl` points to the GCP test cluster:

```bash
./scripts/bootstrap-gcp-prereqs.sh
```

If the cluster requires sudo for kubectl:

```bash
KUBECTL="sudo kubectl" ./scripts/bootstrap-gcp-prereqs.sh
```

The bootstrap script installs/verifies External Secrets Operator and cert-manager, refreshes AWS credentials, applies `ClusterSecretStore/aws-ares`, applies `ClusterIssuer/default-ca`, and applies the ArgoCD root app.

## Refresh expired AWS credentials

Run whenever External Secrets shows `ExpiredTokenException`:

```bash
./scripts/refresh-aws-eso-creds.sh
```

The script runs:

```bash
sl aws session generate --role-name engineer --account-id 776389595347 --profile ava-mars-stage
```

Then it recreates `aws-ares-creds` in:

```text
external-secrets
argocd
mars
```

Finally it forces refresh of the ECR, scanner, bd-updater, Avira, and scanning-service ExternalSecrets when they exist.
