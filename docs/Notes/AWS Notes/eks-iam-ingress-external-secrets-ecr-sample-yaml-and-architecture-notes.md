# EKS IAM, Ingress, External Secrets, and ECR Sample YAML and Architecture Notes

## 1. EKS Workload Identity Pattern

Goal:
- avoid static AWS keys in pods
- give each workload only the AWS permissions it needs

High-level flow:
1. Kubernetes workload uses a service account.
2. That service account is associated with an AWS IAM role.
3. The workload receives temporary AWS credentials through that identity path.
4. The workload calls AWS services like Secrets Manager or S3 with least privilege.

Good interview line:

"For EKS, I prefer workload-level identity instead of sharing broad AWS permissions across all pods on a node."

## 2. Example Service Account for AWS Identity Mapping

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: app-runtime
  namespace: app-dev
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::123456789012:role/app-dev-secrets-role
```

Use this when:
- one workload needs AWS API access
- you want pod-level permission boundaries

## 3. Example Deployment Using the Service Account

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-service
  namespace: app-dev
spec:
  replicas: 2
  selector:
    matchLabels:
      app: app-service
  template:
    metadata:
      labels:
        app: app-service
    spec:
      serviceAccountName: app-runtime
      containers:
        - name: app-service
          image: 123456789012.dkr.ecr.us-east-1.amazonaws.com/app-service:1.2.0
          ports:
            - containerPort: 8080
```

## 4. Example IAM Policy for Secrets Read Access

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ],
      "Resource": "arn:aws:secretsmanager:us-east-1:123456789012:secret:app/dev/*"
    }
  ]
}
```

Good design point:
- scope to exact secret path or resource pattern
- avoid broad `*` access unless absolutely necessary

## 5. External Secrets High-Level Architecture

Typical flow:
1. Secret is stored in AWS Secrets Manager.
2. EKS workload identity gives the secret controller permission to read it.
3. External Secrets controller reads the upstream secret.
4. Controller creates or refreshes a Kubernetes `Secret`.
5. Application consumes the Kubernetes `Secret`.

Why teams use this:
- Git does not contain plaintext secret values
- runtime secret delivery stays automated
- secret source stays centralized in AWS

## 6. SecretStore Example

```yaml
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: aws-secrets
  namespace: app-dev
spec:
  provider:
    aws:
      service: SecretsManager
      region: us-east-1
      auth:
        jwt:
          serviceAccountRef:
            name: external-secrets-sa
```

## 7. ExternalSecret Example

```yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: app-runtime-secret
  namespace: app-dev
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: aws-secrets
    kind: SecretStore
  target:
    name: app-runtime-secret
    creationPolicy: Owner
  data:
    - secretKey: DB_PASSWORD
      remoteRef:
        key: app/dev/database
        property: password
    - secretKey: API_TOKEN
      remoteRef:
        key: app/dev/integration
        property: token
```

## 8. Deployment Consuming the Synced Secret

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-service
  namespace: app-dev
spec:
  replicas: 2
  selector:
    matchLabels:
      app: app-service
  template:
    metadata:
      labels:
        app: app-service
    spec:
      containers:
        - name: app-service
          image: 123456789012.dkr.ecr.us-east-1.amazonaws.com/app-service:1.2.0
          env:
            - name: DB_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: app-runtime-secret
                  key: DB_PASSWORD
            - name: API_TOKEN
              valueFrom:
                secretKeyRef:
                  name: app-runtime-secret
                  key: API_TOKEN
```

## 9. ECR Image Flow

Typical flow:
1. CI builds image.
2. CI tags image.
3. CI pushes image to ECR.
4. Manifest is updated with image tag.
5. EKS deployment pulls image from ECR.

Important checks:
- image exists
- tag is correct
- region is correct
- workload references correct registry path

## 10. Example EKS Deployment Using an ECR Image

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: payments
  namespace: payments
spec:
  replicas: 3
  selector:
    matchLabels:
      app: payments
  template:
    metadata:
      labels:
        app: payments
    spec:
      containers:
        - name: payments
          image: 123456789012.dkr.ecr.us-east-1.amazonaws.com/payments:2.3.1
          ports:
            - containerPort: 8080
```

## 11. Internal Service Example

```yaml
apiVersion: v1
kind: Service
metadata:
  name: payments
  namespace: payments
spec:
  selector:
    app: payments
  ports:
    - port: 80
      targetPort: 8080
  type: ClusterIP
```

Use this when:
- service should stay internal to the cluster

## 12. Ingress Example for ALB-Style Exposure

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: payments-ingress
  namespace: payments
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
spec:
  rules:
    - host: payments.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: payments
                port:
                  number: 80
```

Important explanation:
- ingress defines routing intent
- AWS-side controller provisions and manages the actual load balancer behavior

## 13. Internal Ingress Example

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: internal-api-ingress
  namespace: internal-api
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internal
spec:
  rules:
    - host: internal-api.example.local
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: internal-api
                port:
                  number: 80
```

Use this when:
- traffic should remain private inside the organization network path

## 14. NLB-Style Service Example

```yaml
apiVersion: v1
kind: Service
metadata:
  name: tcp-service
  namespace: platform
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
spec:
  type: LoadBalancer
  selector:
    app: tcp-service
  ports:
    - port: 443
      targetPort: 8443
```

Use this when:
- transport-level load balancing is needed instead of ALB-style Layer 7 routing

## 15. Architecture Thinking for EKS + IAM + Secrets + Ingress

A clean platform flow often looks like this:

1. Application image is stored in ECR.
2. Kubernetes deployment references that image.
3. Workload or secret controller gets AWS access through scoped identity.
4. Secrets are read from Secrets Manager through External Secrets.
5. Application consumes Kubernetes secrets at runtime.
6. Traffic enters through ALB or NLB depending on protocol needs.
7. Logs and metrics are collected through the observability stack.

## 16. Strong Interview Statements

- "I prefer workload-level AWS identity instead of node-wide broad credentials."
- "Secrets should stay in a secure upstream store, not in Git."
- "Ingress design must be explained together with AWS load balancer behavior."
- "ECR is not just image storage, it is part of the delivery chain, so tagging and pull reliability matter."
- "The safest design is the one that keeps permissions narrow and platform behavior observable."
