# Kubernetes 10 – Advanced Topics

## 0. Goal of This Note

- Configure Horizontal Pod Autoscaler (HPA)
- Understand Cluster Autoscaler and VPA
- Create Custom Resource Definitions (CRDs) and Operators
- Implement GitOps with ArgoCD
- Manage multi-cluster setups
- Understand Pod Disruption Budgets and graceful shutdowns

---

## 1. Horizontal Pod Autoscaler (HPA)

**HPA** automatically scales the number of Pod replicas based on CPU, memory, or custom metrics.

### 1.1 Requirements

- Metrics Server must be installed (for CPU/memory)
- Custom metrics: Prometheus Adapter or KEDA

### 1.2 Basic HPA (CPU-based)

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: my-app-hpa
  namespace: default
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: my-app
  minReplicas: 2
  maxReplicas: 20
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70   # target 70% CPU utilization
```

### 1.3 Advanced HPA (Multiple Metrics)

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: my-app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: my-app
  minReplicas: 2
  maxReplicas: 50
  
  metrics:
  # CPU
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 60
  
  # Memory
  - type: Resource
    resource:
      name: memory
      target:
        type: AverageValue
        averageValue: 200Mi
  
  # Custom metric (requires Prometheus Adapter)
  - type: Pods
    pods:
      metric:
        name: http_requests_per_second
      target:
        type: AverageValue
        averageValue: 100
  
  # External metric (e.g., queue length from SQS)
  - type: External
    external:
      metric:
        name: sqs_queue_length
        selector:
          matchLabels:
            queue: my-queue
      target:
        type: AverageValue
        averageValue: "30"
  
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 60    # wait 60s before scaling up again
      policies:
      - type: Pods
        value: 4                         # add at most 4 pods per period
        periodSeconds: 60
    scaleDown:
      stabilizationWindowSeconds: 300   # wait 5 min before scaling down
      policies:
      - type: Percent
        value: 20                        # remove at most 20% per period
        periodSeconds: 60
```

### 1.4 HPA Commands

```bash
# Create imperatively
kubectl autoscale deployment my-app --min=2 --max=20 --cpu-percent=70

# View HPA
kubectl get hpa
kubectl describe hpa my-app-hpa

# Watch HPA in action
kubectl get hpa -w

# Generate load for testing
kubectl run load-gen --image=busybox --restart=Never -- \
  sh -c "while true; do wget -q -O- http://my-svc; done"
```

---

## 2. KEDA (Kubernetes Event-Driven Autoscaling)

**KEDA** enables scaling to/from zero based on external event sources.

```bash
helm repo add kedacore https://kedacore.github.io/charts
helm upgrade --install keda kedacore/keda \
  --namespace kube-system
```

```yaml
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: queue-scaler
spec:
  scaleTargetRef:
    name: my-worker
  minReplicaCount: 0         # scale to zero!
  maxReplicaCount: 100
  triggers:
  - type: rabbitmq
    metadata:
      host: amqp://user:pass@rabbitmq:5672/
      queueName: tasks
      queueLength: "20"      # scale out when queue > 20 messages per replica
  
  - type: prometheus
    metadata:
      serverAddress: http://prometheus:9090
      metricName: http_requests_total
      threshold: "100"
      query: sum(rate(http_requests_total{app="my-app"}[2m]))
```

---

## 3. Cluster Autoscaler

**Cluster Autoscaler** automatically adjusts the **number of nodes** in a cluster by:
- **Scaling up**: when pods can't be scheduled due to insufficient resources
- **Scaling down**: when nodes are underutilized for an extended period

**Cloud-specific setup:**

```yaml
# AWS EKS - via Helm
helm upgrade --install cluster-autoscaler autoscaler/cluster-autoscaler \
  --namespace kube-system \
  --set autoDiscovery.clusterName=my-cluster \
  --set awsRegion=us-east-1 \
  --set rbac.serviceAccount.annotations."eks\.amazonaws\.com/role-arn"=arn:aws:iam::ACCOUNT:role/ClusterAutoscalerRole
```

---

## 4. Pod Disruption Budgets (PDB)

**PDB** limits the number of pods taken down simultaneously during voluntary disruptions (node drain, cluster upgrade).

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: my-app-pdb
spec:
  selector:
    matchLabels:
      app: my-app
  minAvailable: 2              # keep at least 2 pods running at all times
  # or
  maxUnavailable: 1            # allow at most 1 pod to be unavailable at once
  # or
  minAvailable: "75%"          # percentage form
```

```bash
kubectl get pdb
kubectl describe pdb my-app-pdb

# Test: draining a node respects PDBs
kubectl drain worker-1 --ignore-daemonsets --delete-emptydir-data
# Will block if drain would violate a PDB
```

---

## 5. Custom Resource Definitions (CRDs)

**CRDs** let you extend Kubernetes with your own resource types.

### 5.1 Creating a CRD

```yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: databases.mycompany.io       # <plural>.<group>
spec:
  group: mycompany.io
  names:
    kind: Database                   # singular CamelCase
    singular: database
    plural: databases
    shortNames:
    - db
  scope: Namespaced                  # Namespaced or Cluster
  versions:
  - name: v1
    served: true
    storage: true
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
            properties:
              engine:
                type: string
                enum: [mysql, postgres, mongodb]
              version:
                type: string
              replicas:
                type: integer
                minimum: 1
                maximum: 10
            required: [engine, version]
          status:
            type: object
            properties:
              phase:
                type: string
    subresources:
      status: {}                     # enable status subresource
    additionalPrinterColumns:
    - name: Engine
      type: string
      jsonPath: .spec.engine
    - name: Ready
      type: string
      jsonPath: .status.phase
```

### 5.2 Creating a Custom Resource

```yaml
apiVersion: mycompany.io/v1
kind: Database
metadata:
  name: my-postgres
  namespace: default
spec:
  engine: postgres
  version: "15.0"
  replicas: 3
```

```bash
# After applying the CRD
kubectl get databases
kubectl get db                        # short name
kubectl describe database my-postgres
kubectl delete database my-postgres
```

---

## 6. Kubernetes Operators

An **Operator** is a controller that manages complex applications using CRDs. It encodes operational knowledge (Day 2 operations) into code.

**Examples of popular Operators:**
| Operator | Purpose |
|----------|---------|
| Prometheus Operator | Manages Prometheus and Alertmanager |
| Cert-Manager | Manages TLS certificates |
| Strimzi | Manages Apache Kafka |
| CloudNativePG | Manages PostgreSQL |
| Redis Operator | Manages Redis Cluster |
| Istio Operator | Manages Istio service mesh |

### 6.1 Operator Pattern

```
User creates:    Database CR (custom resource)
Operator sees:   New Database CR
Operator does:
  - Creates StatefulSet with DB containers
  - Creates Services for access
  - Creates PVCs for storage
  - Configures replication
  - Handles backups/restores
  - Handles upgrades
```

### 6.2 Building an Operator with Operator SDK

```bash
# Install operator-sdk
brew install operator-sdk

# Create operator project
operator-sdk init --domain mycompany.io --repo github.com/me/my-operator

# Generate API (creates CRD + controller skeleton)
operator-sdk create api --group mygroup --version v1 --kind MyApp --resource --controller

# Build and deploy
make docker-build docker-push IMG=myregistry/my-operator:v1.0.0
make deploy IMG=myregistry/my-operator:v1.0.0
```

---

## 7. GitOps with ArgoCD

**GitOps** = Git as the single source of truth for cluster state. ArgoCD continuously syncs your cluster to match the Git repository.

### 7.1 Install ArgoCD

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm upgrade --install argocd argo/argo-cd \
  --namespace argocd --create-namespace \
  --set server.service.type=LoadBalancer

# Get initial admin password
kubectl get secret -n argocd argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d

# Port-forward if no LoadBalancer
kubectl port-forward -n argocd svc/argocd-server 8080:443
# Open https://localhost:8080
# Login: admin / <password above>
```

### 7.2 ArgoCD Application

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-app
  namespace: argocd
spec:
  project: default
  
  source:
    repoURL: https://github.com/myorg/k8s-manifests.git
    targetRevision: HEAD
    path: apps/my-app                 # directory in repo
  
  destination:
    server: https://kubernetes.default.svc
    namespace: production
  
  syncPolicy:
    automated:
      prune: true                     # delete resources removed from Git
      selfHeal: true                  # revert manual cluster changes
    syncOptions:
    - CreateNamespace=true
    retry:
      limit: 5
      backoff:
        duration: 5s
        factor: 2
        maxDuration: 3m
```

### 7.3 Helm-based Application

```yaml
spec:
  source:
    repoURL: https://charts.bitnami.com/bitnami
    chart: nginx
    targetRevision: 15.x.x
    helm:
      releaseName: my-nginx
      values: |
        replicaCount: 3
        service:
          type: ClusterIP
```

### 7.4 App of Apps Pattern

```yaml
# root-app.yaml – deploys all other applications
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: root
  namespace: argocd
spec:
  source:
    path: apps                      # directory containing other Application YAMLs
  ...
```

---

## 8. Flux (Alternative GitOps Tool)

```bash
# Install Flux
brew install fluxcd/tap/flux

# Bootstrap with GitHub
flux bootstrap github \
  --owner=myorg \
  --repository=fleet-infra \
  --branch=main \
  --path=clusters/production \
  --personal
```

```yaml
# GitRepository source
apiVersion: source.toolkit.fluxcd.io/v1
kind: GitRepository
metadata:
  name: my-app
  namespace: flux-system
spec:
  interval: 1m
  url: https://github.com/myorg/my-app
  ref:
    branch: main

---
# Kustomization (deploy from Git)
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: my-app
  namespace: flux-system
spec:
  interval: 10m
  path: ./k8s/prod
  prune: true
  sourceRef:
    kind: GitRepository
    name: my-app
```

---

## 9. Multi-Cluster Management

### 9.1 kubefed (Federation)

```bash
# Install kubefedctl
helm install kubefed kubefed-charts/kubefed \
  --namespace kube-federation-system \
  --create-namespace
```

### 9.2 ArgoCD Multi-Cluster

```bash
# Add a cluster to ArgoCD
argocd cluster add my-other-context

# Target specific cluster in Application
spec:
  destination:
    server: https://other-cluster-api:6443
    namespace: production
```

### 9.3 Cluster API (CAPI)

Declaratively manage cluster lifecycle (create, upgrade, delete clusters):

```bash
# Install clusterctl
curl -L https://github.com/kubernetes-sigs/cluster-api/releases/download/v1.6.0/clusterctl-linux-amd64 -o clusterctl
sudo install clusterctl /usr/local/bin/

# Initialize with AWS provider
clusterctl init --infrastructure aws

# Generate cluster config
clusterctl generate cluster my-cluster \
  --kubernetes-version v1.29.0 \
  --control-plane-machine-count 3 \
  --worker-machine-count 3 > my-cluster.yaml

kubectl apply -f my-cluster.yaml
```

---

## 10. Graceful Shutdown and Lifecycle Hooks

### 10.1 Lifecycle Hooks

```yaml
containers:
- name: app
  image: my-app
  lifecycle:
    postStart:
      exec:
        command: ["/bin/sh", "-c", "echo started > /tmp/status"]
    preStop:
      exec:
        command: ["/bin/sh", "-c", "sleep 5 && kill -SIGTERM 1"]
      # or HTTP:
      httpGet:
        path: /shutdown
        port: 8080
```

### 10.2 Graceful Shutdown Config

```yaml
spec:
  terminationGracePeriodSeconds: 60   # time to gracefully shut down (default: 30)
  containers:
  - name: app
    lifecycle:
      preStop:
        exec:
          # Give time for load balancer to stop sending traffic
          command: ["sleep", "5"]
```

**Shutdown sequence:**
1. Pod gets `SIGTERM` signal
2. `preStop` hook runs
3. Container has `terminationGracePeriodSeconds` to shut down
4. If still running: `SIGKILL`

### 10.3 Connection Draining

```yaml
spec:
  terminationGracePeriodSeconds: 75    # longer than load balancer drain time

containers:
- lifecycle:
    preStop:
      exec:
        command:
        - /bin/sh
        - -c
        - |
          sleep 10                     # wait for LB to stop sending traffic
          /app/graceful-shutdown.sh    # drain connections
```

---

## 11. Kustomize

**Kustomize** is a built-in Kubernetes tool for customizing YAML manifests without templating.

```
base/
  deployment.yaml
  service.yaml
  kustomization.yaml

overlays/
  development/
    kustomization.yaml
    replica-patch.yaml
  production/
    kustomization.yaml
    replica-patch.yaml
    resource-patch.yaml
```

```yaml
# base/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- deployment.yaml
- service.yaml

# overlays/production/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
bases:
- ../../base
namePrefix: prod-
namespace: production
commonLabels:
  env: production
patchesStrategicMerge:
- replica-patch.yaml
images:
- name: my-app
  newTag: "1.5.0"
```

```yaml
# overlays/production/replica-patch.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 10
```

```bash
# Build and review (don't apply)
kubectl kustomize overlays/production

# Apply directly
kubectl apply -k overlays/production

# Use with ArgoCD
spec:
  source:
    path: overlays/production
```

---

## 12. Service Accounts & IRSA (AWS)

**IRSA** (IAM Roles for Service Accounts) lets Pods assume AWS IAM roles without credentials:

```yaml
# Annotate ServiceAccount with IAM role ARN
apiVersion: v1
kind: ServiceAccount
metadata:
  name: s3-access-sa
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::123456789:role/S3AccessRole

# Use in Pod
spec:
  serviceAccountName: s3-access-sa
  containers:
  - name: app
    image: my-app
    # App can now call AWS APIs using the IAM role
    # AWS SDKs automatically pick up the injected token
```
