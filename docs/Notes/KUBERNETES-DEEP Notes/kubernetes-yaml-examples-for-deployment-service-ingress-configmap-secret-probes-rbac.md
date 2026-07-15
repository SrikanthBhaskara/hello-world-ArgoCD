# Kubernetes YAML Examples for Deployment, Service, Ingress, ConfigMap, Secret, Probes, and RBAC

## 1. Basic Deployment

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
          image: my-registry.example.com/team/app-service:1.2.0
          ports:
            - containerPort: 8080
```

Use this when:
- you want a stateless replicated application workload

## 2. ClusterIP Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: app-service
  namespace: app-dev
spec:
  selector:
    app: app-service
  ports:
    - port: 80
      targetPort: 8080
  type: ClusterIP
```

Use this when:
- service should be reachable only inside the cluster

## 3. LoadBalancer Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: app-public
  namespace: app-dev
spec:
  selector:
    app: app-service
  ports:
    - port: 80
      targetPort: 8080
  type: LoadBalancer
```

Use this when:
- cloud load balancer integration should expose the service externally

## 4. Ingress Example

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress
  namespace: app-dev
spec:
  rules:
    - host: app.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: app-service
                port:
                  number: 80
```

Use this when:
- HTTP or HTTPS traffic needs path-based or host-based routing

## 5. ConfigMap Example

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  namespace: app-dev
data:
  LOG_LEVEL: INFO
  FEATURE_FLAG_X: "true"
```

## 6. Deployment Using ConfigMap Values

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
          image: my-registry.example.com/team/app-service:1.2.0
          env:
            - name: LOG_LEVEL
              valueFrom:
                configMapKeyRef:
                  name: app-config
                  key: LOG_LEVEL
```

## 7. Secret Example

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
  namespace: app-dev
type: Opaque
stringData:
  DB_PASSWORD: change-me
  API_TOKEN: sample-token
```

## 8. Deployment Using Secret Values

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
          image: my-registry.example.com/team/app-service:1.2.0
          env:
            - name: DB_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: app-secret
                  key: DB_PASSWORD
```

## 9. Readiness and Liveness Probe Example

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
          image: my-registry.example.com/team/app-service:1.2.0
          ports:
            - containerPort: 8080
          readinessProbe:
            httpGet:
              path: /actuator/health/readiness
              port: 8080
            initialDelaySeconds: 10
            periodSeconds: 5
          livenessProbe:
            httpGet:
              path: /actuator/health/liveness
              port: 8080
            initialDelaySeconds: 30
            periodSeconds: 10
```

Important point:
- readiness protects traffic
- liveness protects restart behavior

## 10. Resource Requests and Limits Example

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
          image: my-registry.example.com/team/app-service:1.2.0
          resources:
            requests:
              cpu: "250m"
              memory: "256Mi"
            limits:
              cpu: "500m"
              memory: "512Mi"
```

## 11. ServiceAccount Example

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: app-runtime
  namespace: app-dev
```

## 12. Role Example

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: app-reader
  namespace: app-dev
rules:
  - apiGroups: [""]
    resources: ["configmaps", "secrets"]
    verbs: ["get", "list"]
```

## 13. RoleBinding Example

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: app-reader-binding
  namespace: app-dev
subjects:
  - kind: ServiceAccount
    name: app-runtime
    namespace: app-dev
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: app-reader
```

## 14. Deployment Using ServiceAccount

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
          image: my-registry.example.com/team/app-service:1.2.0
```

## 15. Namespace Example

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: app-dev
```

## 16. Strong Interview Statements

- "A manifest can be valid but still unsafe operationally."
- "Service routing depends on labels, selectors, target ports, and readiness all being correct together."
- "Secrets and ConfigMaps externalize runtime data from the image."
- "RBAC should be as narrow as possible for workload identity."
- "Readiness and liveness solve different operational problems."
