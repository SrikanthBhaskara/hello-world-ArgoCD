# Docker Compose, Registry, and Kubernetes Deployment Examples

## 1. Local Docker Compose Architecture

Docker Compose is commonly used for:
- local multi-container development
- quick integration setup
- simple service composition

Example use cases:
- app plus database
- app plus Redis
- app plus mock dependency

Good interview line:

"I use Docker Compose mainly for local or lightweight multi-service workflows, while orchestration platforms like Kubernetes handle larger production concerns."

## 2. Simple Docker Compose Example

```yaml
version: "3.9"

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "8080:8080"
    environment:
      SPRING_PROFILES_ACTIVE: local
    depends_on:
      - postgres

  postgres:
    image: postgres:16
    environment:
      POSTGRES_DB: appdb
      POSTGRES_USER: appuser
      POSTGRES_PASSWORD: apppass
    ports:
      - "5432:5432"
    volumes:
      - postgres-data:/var/lib/postgresql/data

volumes:
  postgres-data:
```

Use this when:
- you need a simple local app plus database setup

## 3. Why Compose Helps in Development

Compose helps because:
- local dependencies start consistently
- team setup becomes easier
- one command can start the whole stack

Common commands:

```bash
docker compose up -d
docker compose logs -f
docker compose down
```

## 4. Docker Registry Flow

A registry stores built images for later deployment.

Typical flow:
1. code is built
2. image is created
3. image is tagged
4. image is pushed to registry
5. runtime platform pulls that exact image

Important principle:
- registry is the artifact distribution layer

## 5. Example Registry Tagging Flow

```bash
docker build -t my-app:local .
docker tag my-app:local my-registry.example.com/team/my-app:1.4.2
docker push my-registry.example.com/team/my-app:1.4.2
```

Better tagging patterns:
- semantic version
- build number
- commit SHA

Avoid relying only on:
- `latest`

## 6. Strong Registry Practices

- use traceable tags
- keep image provenance clear
- avoid mutable release ambiguity
- scan images in CI where possible
- clean up unused images by policy

## 7. Kubernetes Deployment Example Using a Registry Image

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
  namespace: app-dev
spec:
  replicas: 2
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
        - name: my-app
          image: my-registry.example.com/team/my-app:1.4.2
          ports:
            - containerPort: 8080
          env:
            - name: SPRING_PROFILES_ACTIVE
              value: dev
```

## 8. Kubernetes Service Example

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-app
  namespace: app-dev
spec:
  selector:
    app: my-app
  ports:
    - port: 80
      targetPort: 8080
  type: ClusterIP
```

Use this when:
- traffic should stay internal inside the cluster

## 9. Kubernetes Ingress Example

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-app
  namespace: app-dev
spec:
  rules:
    - host: my-app.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: my-app
                port:
                  number: 80
```

Use this when:
- the application should be reachable from outside the cluster

## 10. ConfigMap Example

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-app-config
  namespace: app-dev
data:
  LOG_LEVEL: INFO
  FEATURE_X_ENABLED: "true"
```

## 11. Deployment Using ConfigMap Values

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
  namespace: app-dev
spec:
  replicas: 2
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
        - name: my-app
          image: my-registry.example.com/team/my-app:1.4.2
          env:
            - name: LOG_LEVEL
              valueFrom:
                configMapKeyRef:
                  name: my-app-config
                  key: LOG_LEVEL
```

## 12. Secret Example

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: my-app-secret
  namespace: app-dev
type: Opaque
stringData:
  DB_PASSWORD: change-me
```

## 13. Deployment Using Secret Values

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
  namespace: app-dev
spec:
  replicas: 2
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
        - name: my-app
          image: my-registry.example.com/team/my-app:1.4.2
          env:
            - name: DB_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: my-app-secret
                  key: DB_PASSWORD
```

## 14. Example Flow From Docker Compose to Kubernetes

Local development flow:
- use Docker Compose for app and local dependencies

Delivery flow:
- build image in CI
- push image to registry
- deploy same image to Kubernetes

This gives:
- fast local setup
- consistent deployable artifact
- clearer separation between development and production orchestration

## 15. Strong Interview Statements

- "Docker Compose is good for local multi-service workflows, not as a replacement for full production orchestration."
- "The registry is the artifact distribution layer between CI and runtime."
- "Kubernetes should deploy the same image built in CI rather than rebuilding per environment."
- "Configuration and secrets should come from the runtime environment, not from image rebuilds."
