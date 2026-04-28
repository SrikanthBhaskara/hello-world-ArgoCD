# Scanner Helm test applications

This folder is only for testing the Bitdefender scanner ArgoCD Application and Helm chart flow before the same setup is promoted into `cloudsec-sfcn-cm-ops/apps/overlays/sib/gcp-dev`.

The root app in this repo points to `argocd/projects`. That kustomization includes this folder, so applying `argocd/application-root.yaml` creates this child app:

- `bitdefender-scanner-dev`

The app deploys into `mars-scanner-dev` so testing is isolated from the real `mars` namespace used by the planned `gcp-dev` deployment.

Before syncing this app, confirm these dependencies exist in the test GCP cluster:

- ArgoCD can authenticate to the ECR OCI Helm repository.
- The scanner Helm chart exists at the configured OCI path and version.
- `cert-manager` is installed.
- A cluster issuer named `default-ca` exists, or change `certManager.issuerName`.
- External Secrets Operator is installed.
- A `ClusterSecretStore` named `aws-ares` exists and can read AWS Secrets Manager.
- AWS Secrets Manager has test secrets under the `gcp-scanner-test/sib/ares/bitdefender/...` paths used in this file.

Promotion rule:

- Keep testing changes here first.
- After the Helm rendering, ExternalSecret resolution, and scanner connectivity are verified, copy the final values into the `cloudsec-sfcn-cm-ops` `gcp-dev/scanners` applications.
