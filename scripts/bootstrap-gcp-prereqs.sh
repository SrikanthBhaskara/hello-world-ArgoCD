#!/usr/bin/env bash
set -euo pipefail

# Bootstrap a GCP VM/k3s cluster for the Bitdefender ArgoCD test deployment.
#
# Optional environment overrides:
#   KUBECTL="sudo kubectl"
#   INSTALL_OPERATORS=true
#   AWS_PROFILE_NAME=ava-mars-stage
#   AWS_ACCOUNT_ID=776389595347
#   AWS_ROLE_NAME=engineer

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
KUBECTL_CMD="${KUBECTL:-kubectl}"
INSTALL_OPERATORS="${INSTALL_OPERATORS:-true}"

k() {
  ${KUBECTL_CMD} "$@"
}

log() {
  printf '\n==> %s\n' "$*"
}

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

install_external_secrets_operator() {
  if k get crd externalsecrets.external-secrets.io >/dev/null 2>&1; then
    log "External Secrets Operator CRDs already installed"
    return
  fi

  if [[ "$INSTALL_OPERATORS" != "true" ]]; then
    echo "External Secrets Operator is missing. Re-run with INSTALL_OPERATORS=true or install it manually." >&2
    exit 1
  fi

  require_cmd helm
  log "Installing External Secrets Operator"
  helm repo add external-secrets https://charts.external-secrets.io >/dev/null
  helm repo update external-secrets >/dev/null
  helm upgrade --install external-secrets external-secrets/external-secrets \
    --namespace external-secrets \
    --create-namespace \
    --set installCRDs=true
  k rollout status deployment/external-secrets -n external-secrets --timeout=180s
}

install_cert_manager() {
  if k get crd certificates.cert-manager.io >/dev/null 2>&1; then
    log "cert-manager CRDs already installed"
    return
  fi

  if [[ "$INSTALL_OPERATORS" != "true" ]]; then
    echo "cert-manager is missing. Re-run with INSTALL_OPERATORS=true or install it manually." >&2
    exit 1
  fi

  require_cmd helm
  log "Installing cert-manager"
  helm repo add jetstack https://charts.jetstack.io >/dev/null
  helm repo update jetstack >/dev/null
  helm upgrade --install cert-manager jetstack/cert-manager \
    --namespace cert-manager \
    --create-namespace \
    --set crds.enabled=true || \
  helm upgrade --install cert-manager jetstack/cert-manager \
    --namespace cert-manager \
    --create-namespace \
    --set installCRDs=true
  k rollout status deployment/cert-manager -n cert-manager --timeout=180s
  k rollout status deployment/cert-manager-webhook -n cert-manager --timeout=180s
  k rollout status deployment/cert-manager-cainjector -n cert-manager --timeout=180s
}

require_cmd kubectl
require_cmd aws

log "Using Kubernetes context"
k config current-context
k get nodes

log "Ensuring namespaces"
for namespace in external-secrets argocd mars cert-manager; do
  k create namespace "$namespace" --dry-run=client -o yaml | k apply -f -
done

install_external_secrets_operator
install_cert_manager

log "Refreshing AWS credentials for ESO and ECR generators"
bash "${SCRIPT_DIR}/refresh-aws-eso-creds.sh"

log "Applying ClusterSecretStore/aws-ares"
k apply -f "${REPO_ROOT}/bootstrap/clustersecretstore-aws-ares.yaml"
k get clustersecretstore aws-ares

log "Applying default-ca ClusterIssuer"
k apply -f "${REPO_ROOT}/bootstrap/default-ca-issuer.yaml"
k get clusterissuer default-ca

log "Applying ArgoCD root app"
if k get crd applications.argoproj.io >/dev/null 2>&1; then
  k apply -f "${REPO_ROOT}/argocd/application-root.yaml"
  k annotate application bitdefender-scanner-root -n argocd argocd.argoproj.io/refresh=hard --overwrite || true
else
  echo "ArgoCD Application CRD is not installed; install ArgoCD first, then apply argocd/application-root.yaml." >&2
fi

log "Bootstrap status"
k get pods -n external-secrets || true
k get pods -n cert-manager || true
k get externalsecret -A || true
k get application -n argocd || true
