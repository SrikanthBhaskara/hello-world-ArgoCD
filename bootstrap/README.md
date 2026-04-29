# Bootstrap Resources

These resources are cluster prerequisites for the Bitdefender ArgoCD test deployment.

Apply them only after installing:

```text
External Secrets Operator
cert-manager
```

## 1. Create AWS Credentials Secret

Do not commit real AWS keys to Git.

For temporary AWS credentials:

```bash
sudo kubectl create secret generic aws-ares-creds \
  -n external-secrets \
  --from-literal=access-key="$AWS_ACCESS_KEY_ID" \
  --from-literal=secret-access-key="$AWS_SECRET_ACCESS_KEY" \
  --from-literal=session-token="$AWS_SESSION_TOKEN" \
  --dry-run=client -o yaml | sudo kubectl apply -f -
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
