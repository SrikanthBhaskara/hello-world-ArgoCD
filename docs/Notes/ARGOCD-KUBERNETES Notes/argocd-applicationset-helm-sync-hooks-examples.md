# ArgoCD ApplicationSet, Helm, and Sync-Hooks Examples

## 1. Basic ArgoCD Application

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: payments-dev
  namespace: argocd
spec:
  project: payments
  source:
    repoURL: https://github.com/example/platform-config.git
    targetRevision: main
    path: apps/payments/dev
  destination:
    server: https://kubernetes.default.svc
    namespace: payments-dev
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

Use this when:
- one application maps directly to one repo path and one namespace

## 2. Helm-Based ArgoCD Application

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: inventory-helm
  namespace: argocd
spec:
  project: retail
  source:
    repoURL: https://github.com/example/helm-config.git
    targetRevision: main
    path: charts/inventory
    helm:
      valueFiles:
        - values.yaml
        - values-dev.yaml
      parameters:
        - name: image.tag
          value: "1.4.2"
  destination:
    server: https://kubernetes.default.svc
    namespace: inventory
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

Why this is useful:
- chart stays reusable
- environment values stay explicit
- ArgoCD still reconciles rendered manifests declaratively

## 3. Kustomize-Based Application

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: orders-kustomize
  namespace: argocd
spec:
  project: commerce
  source:
    repoURL: https://github.com/example/gitops-config.git
    targetRevision: main
    path: apps/orders/overlays/prod
  destination:
    server: https://kubernetes.default.svc
    namespace: orders
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

## 4. AppProject Example

```yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: payments
  namespace: argocd
spec:
  sourceRepos:
    - https://github.com/example/platform-config.git
  destinations:
    - namespace: payments-*
      server: https://kubernetes.default.svc
  clusterResourceWhitelist:
    - group: "*"
      kind: "*"
  namespaceResourceWhitelist:
    - group: "*"
      kind: "*"
```

Why this matters:
- limits where apps can deploy
- reduces accidental cross-team access

## 5. ApplicationSet With List Generator

```yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: sample-multi-env
  namespace: argocd
spec:
  generators:
    - list:
        elements:
          - env: dev
            namespace: app-dev
            path: apps/sample/dev
          - env: qa
            namespace: app-qa
            path: apps/sample/qa
          - env: prod
            namespace: app-prod
            path: apps/sample/prod
  template:
    metadata:
      name: "sample-{{env}}"
    spec:
      project: default
      source:
        repoURL: https://github.com/example/gitops-config.git
        targetRevision: main
        path: "{{path}}"
      destination:
        server: https://kubernetes.default.svc
        namespace: "{{namespace}}"
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
```

Use this when:
- you want a simple one-template-per-environment model

## 6. ApplicationSet With Git Directory Generator

```yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: tenant-apps
  namespace: argocd
spec:
  generators:
    - git:
        repoURL: https://github.com/example/gitops-config.git
        revision: main
        directories:
          - path: tenants/*
  template:
    metadata:
      name: "{{path.basename}}"
    spec:
      project: tenants
      source:
        repoURL: https://github.com/example/gitops-config.git
        targetRevision: main
        path: "{{path}}"
      destination:
        server: https://kubernetes.default.svc
        namespace: "{{path.basename}}"
```

Use this when:
- folder structure itself drives app generation

## 7. ApplicationSet With Cluster Generator

```yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: platform-agents
  namespace: argocd
spec:
  generators:
    - clusters: {}
  template:
    metadata:
      name: "agent-{{name}}"
    spec:
      project: platform
      source:
        repoURL: https://github.com/example/platform-config.git
        targetRevision: main
        path: agents/base
      destination:
        server: "{{server}}"
        namespace: agents
```

Use this when:
- the same component must exist across many registered clusters

## 8. PreSync Hook Example for DB Migration

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: payments-migration
  annotations:
    argocd.argoproj.io/hook: PreSync
    argocd.argoproj.io/hook-delete-policy: HookSucceeded
spec:
  template:
    spec:
      restartPolicy: Never
      containers:
        - name: migrate
          image: example/payments:1.4.2
          command: ["sh", "-c", "python manage.py migrate"]
```

What this does:
- runs migration before normal sync continues

## 9. PostSync Hook Example for Smoke Check

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: payments-smoke-test
  annotations:
    argocd.argoproj.io/hook: PostSync
    argocd.argoproj.io/hook-delete-policy: HookSucceeded
spec:
  template:
    spec:
      restartPolicy: Never
      containers:
        - name: smoke
          image: curlimages/curl:8.5.0
          command:
            - sh
            - -c
            - "curl -f http://payments.payments.svc.cluster.local:8080/actuator/health"
```

What this does:
- validates application health after deployment

## 10. SyncFail Hook Example

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: notify-sync-failure
  annotations:
    argocd.argoproj.io/hook: SyncFail
    argocd.argoproj.io/hook-delete-policy: HookSucceeded
spec:
  template:
    spec:
      restartPolicy: Never
      containers:
        - name: notify
          image: curlimages/curl:8.5.0
          command:
            - sh
            - -c
            - "echo deployment failed"
```

Use this when:
- you want alerting or cleanup on failed sync

## 11. Sync Wave Example

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: reports
  annotations:
    argocd.argoproj.io/sync-wave: "-1"
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: reports-config
  namespace: reports
  annotations:
    argocd.argoproj.io/sync-wave: "0"
data:
  LOG_LEVEL: INFO
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: reports-service
  namespace: reports
  annotations:
    argocd.argoproj.io/sync-wave: "1"
spec:
  replicas: 2
  selector:
    matchLabels:
      app: reports-service
  template:
    metadata:
      labels:
        app: reports-service
    spec:
      containers:
        - name: reports-service
          image: example/reports:2.0.0
```

Why this helps:
- namespace first
- config next
- workload last

## 12. Ignore Differences Example

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: autoscaled-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/example/gitops-config.git
    targetRevision: main
    path: apps/autoscaled
  destination:
    server: https://kubernetes.default.svc
    namespace: autoscaled
  ignoreDifferences:
    - group: apps
      kind: Deployment
      jsonPointers:
        - /spec/replicas
```

Use this carefully:
- useful when another controller such as HPA mutates replicas
- should not be used to hide meaningful drift

## 13. Multiple Helm Value Files Pattern

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: checkout-prod
  namespace: argocd
spec:
  project: commerce
  source:
    repoURL: https://github.com/example/helm-config.git
    targetRevision: main
    path: charts/checkout
    helm:
      valueFiles:
        - values.yaml
        - environments/prod.yaml
        - environments/prod-secrets-reference.yaml
  destination:
    server: https://kubernetes.default.svc
    namespace: checkout
```

## 14. Strong Interview Explanation for These Examples

When explaining these YAML files in interviews, say:

- "Application defines deployment intent for one workload."
- "AppProject adds governance boundaries."
- "ApplicationSet reduces repetition at scale."
- "Helm gives reusable templating, while ArgoCD provides declarative reconciliation."
- "Hooks and sync waves help enforce ordering and release safety."
- "Ignore differences should be used intentionally, not as a blanket way to hide drift."
