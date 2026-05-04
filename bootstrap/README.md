# Bootstrap Resources

These resources are cluster prerequisites for the Bitdefender ArgoCD test deployment.

Apply them only after installing:

```text
External Secrets Operator
cert-manager
```

## 1. Create AWS Credentials Secrets

Do not commit real AWS keys to Git.

For temporary AWS credentials, create the same Secret in all namespaces that need AWS access:

- `external-secrets` for `ClusterSecretStore/aws-ares`
- `argocd` for the ArgoCD ECR Helm repository token
- `mars` for the Kubernetes Docker image pull token

```bash
for namespace in external-secrets argocd mars; do
  sudo kubectl create namespace "$namespace" --dry-run=client -o yaml | sudo kubectl apply -f -
  sudo kubectl create secret generic aws-ares-creds \
    -n "$namespace" \
    --from-literal=access-key="$AWS_ACCESS_KEY_ID" \
    --from-literal=secret-access-key="$AWS_SECRET_ACCESS_KEY" \
    --from-literal=session-token="$AWS_SESSION_TOKEN" \
    --dry-run=client -o yaml | sudo kubectl apply -f -
done
```

## 2. Apply ClusterSecretStore

```bash
sudo kubectl apply -f bootstrap/clustersecretstore-aws-ares.yaml
sudo kubectl get clustersecretstore aws-ares
sudo kubectl describe clustersecretstore aws-ares
```

## 3. Apply default-ca Issuer

```bash
sudo kubectl apply -f bootstrap/default-ca-issuer.yaml
sudo kubectl get clusterissuer default-ca
sudo kubectl get certificate default-ca -n cert-manager
```
