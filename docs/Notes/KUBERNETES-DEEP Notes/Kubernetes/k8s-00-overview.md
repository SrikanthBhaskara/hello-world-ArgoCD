# Kubernetes 00 – Overview & Core Concepts

## 0. Goal of This Note

- Understand why Kubernetes exists and what problems it solves
- Know the full Kubernetes architecture (control plane + worker nodes)
- Understand key Kubernetes objects and their relationships
- Learn essential terminology used throughout all other notes

---

## 1. What is Kubernetes?

### 1.1 The Problem Kubernetes Solves

Before Kubernetes, deploying containerized applications at scale was painful:

| Problem | Without K8s | With K8s |
|---------|------------|---------|
| Container crashes | Manual restart | Auto-restart |
| High traffic | Manual scaling | Auto-scaling (HPA) |
| Config management | Baked into images | ConfigMaps / Secrets |
| Service discovery | Hardcoded IPs | DNS-based discovery |
| Rolling updates | Custom scripts | Built-in rollout |
| Multi-host networking | Complex setup | CNI plugins |
| Storage | Manual mounting | PV/PVC abstraction |

### 1.2 What Kubernetes Is

**Kubernetes** (K8s) is an open-source **container orchestration platform** originally created by Google (based on internal "Borg" system), donated to the CNCF in 2014.

> "Kubernetes" = Greek for "helmsman" or "pilot" – the one who steers the ship.

**What it does:**
- **Schedules** containers across a cluster of machines
- **Heals** failed containers automatically
- **Scales** workloads up/down based on load
- **Manages** configuration, secrets, and storage
- **Exposes** services with built-in load balancing
- **Rolls out** updates with zero downtime

### 1.3 Kubernetes vs Docker

| | Docker | Kubernetes |
|--|--------|-----------|
| **Scope** | Single host | Multi-host cluster |
| **Scheduling** | Manual | Automatic |
| **Self-healing** | Basic restart policies | Full health checks + rescheduling |
| **Scaling** | Manual `docker run` | HPA, cluster autoscaler |
| **Networking** | docker networking | CNI, Services, Ingress |
| **Storage** | Volumes (local) | PV/PVC, StorageClass |

> Docker creates and runs containers. Kubernetes **orchestrates** them at scale.

---

## 2. Kubernetes Architecture

### 2.1 High-Level View

```
┌──────────────────────────────────────────────────────────────┐
│                        CONTROL PLANE                          │
│                                                               │
│   ┌──────────────┐  ┌────────────┐  ┌───────────────────┐   │
│   │  API Server  │  │  Scheduler │  │ Controller Manager│   │
│   │  (kube-      │  │  (kube-    │  │ (kube-controller- │   │
│   │   apiserver) │  │  scheduler)│  │  manager)         │   │
│   └──────┬───────┘  └─────┬──────┘  └─────────┬─────────┘   │
│          │                │                    │              │
│   ┌──────▼────────────────▼────────────────────▼──────────┐  │
│   │                  etcd (cluster state DB)               │  │
│   └───────────────────────────────────────────────────────┘  │
└──────────────────────────┬───────────────────────────────────┘
                           │  (API calls via kubelet)
         ┌─────────────────┼─────────────────┐
         │                 │                 │
┌────────▼───────┐ ┌───────▼────────┐ ┌─────▼──────────┐
│  WORKER NODE 1 │ │  WORKER NODE 2 │ │  WORKER NODE 3 │
│                │ │                │ │                │
│  ┌──────────┐  │ │  ┌──────────┐  │ │  ┌──────────┐  │
│  │ kubelet  │  │ │  │ kubelet  │  │ │  │ kubelet  │  │
│  └──────────┘  │ │  └──────────┘  │ │  └──────────┘  │
│  ┌──────────┐  │ │  ┌──────────┐  │ │  ┌──────────┐  │
│  │kube-proxy│  │ │  │kube-proxy│  │ │  │kube-proxy│  │
│  └──────────┘  │ │  └──────────┘  │ │  └──────────┘  │
│  ┌──────────┐  │ │  ┌──────────┐  │ │  ┌──────────┐  │
│  │Container │  │ │  │Container │  │ │  │Container │  │
│  │ Runtime  │  │ │  │ Runtime  │  │ │  │ Runtime  │  │
│  └──────────┘  │ │  └──────────┘  │ │  └──────────┘  │
│  [Pod][Pod]    │ │  [Pod][Pod]    │ │  [Pod][Pod]    │
└────────────────┘ └────────────────┘ └────────────────┘
```

### 2.2 Control Plane Components

#### kube-apiserver
- The **front door** of Kubernetes – all communication goes through it
- Exposes the Kubernetes REST API
- Validates and processes API requests
- Reads/writes cluster state to etcd
- Scales horizontally for HA

#### etcd
- **Distributed key-value store** – the cluster's source of truth
- Stores all cluster state (Pods, Deployments, Secrets, etc.)
- Uses the Raft consensus algorithm for strong consistency
- **Critical**: losing etcd without backup = losing the cluster

#### kube-scheduler
- Watches for newly created Pods with no assigned node
- Selects the best node based on:
  - Resource requirements (CPU, memory)
  - Node affinity/anti-affinity rules
  - Taints and tolerations
  - Pod topology spread constraints

#### kube-controller-manager
- Runs multiple **controller loops** in one process:
  - **Node Controller**: monitors node health
  - **ReplicaSet Controller**: maintains desired Pod count
  - **Deployment Controller**: manages rolling updates
  - **Service Account Controller**: creates default ServiceAccounts
  - **Namespace Controller**: handles namespace lifecycle

#### cloud-controller-manager (optional)
- Integrates with cloud provider APIs (AWS, GCP, Azure)
- Manages cloud-specific resources: LoadBalancers, Routes, Volumes

### 2.3 Worker Node Components

#### kubelet
- Agent running on every node
- Receives PodSpecs from the API server
- Ensures containers described in PodSpecs are running and healthy
- Reports node and Pod status back to the API server

#### kube-proxy
- Runs on every node as a DaemonSet
- Maintains network rules (iptables or IPVS) for Service routing
- Implements the Service ClusterIP concept via NAT rules
- Handles load balancing across Pod endpoints

#### Container Runtime
- The software that runs containers
- Kubernetes supports any **CRI** (Container Runtime Interface) compatible runtime:
  - **containerd** (default in most modern distros)
  - **CRI-O** (lightweight, especially for OpenShift)
  - **Docker** (via dockershim – deprecated in K8s 1.24+)

---

## 3. Kubernetes Objects Model

### 3.1 Object Basics

Every Kubernetes object has the same structure:

```yaml
apiVersion: apps/v1          # which API group & version
kind: Deployment             # type of object
metadata:                    # identity and labels
  name: my-app
  namespace: default
  labels:
    app: my-app
    version: "1.0"
  annotations:
    deploy-tool: helm
spec:                        # desired state (varies by kind)
  replicas: 3
  ...
status:                      # current state (filled by K8s, read-only)
  availableReplicas: 3
  ...
```

**Key rule**: You declare `spec` (desired state). Kubernetes continuously works to make `status` match `spec`. This is **declarative** management.

### 3.2 Object Hierarchy

```
Namespace
 └── Deployment
      └── ReplicaSet
           └── Pod
                └── Container(s)

Namespace
 └── Service  ──────────────▶ selects Pods via labels
 └── Ingress  ──────────────▶ routes to Services
 └── ConfigMap / Secret ────▶ mounted into Pods
 └── PersistentVolumeClaim ▶ binds to PersistentVolume
```

### 3.3 Core Object Reference

| Kind | apiVersion | Purpose |
|------|-----------|---------|
| **Pod** | `v1` | Smallest deployable unit; wraps one or more containers |
| **ReplicaSet** | `apps/v1` | Ensures N identical Pod replicas run at all times |
| **Deployment** | `apps/v1` | Manages ReplicaSets; adds rolling update + rollback |
| **StatefulSet** | `apps/v1` | Like Deployment but for stateful apps (stable identity, ordered updates) |
| **DaemonSet** | `apps/v1` | Runs one Pod per node (log agents, monitoring agents) |
| **Job** | `batch/v1` | Runs Pods to completion (one-time tasks) |
| **CronJob** | `batch/v1` | Schedules Jobs on a cron schedule |
| **Service** | `v1` | Stable DNS name + IP + load balancing for a set of Pods |
| **Ingress** | `networking.k8s.io/v1` | HTTP/HTTPS routing rules to Services |
| **ConfigMap** | `v1` | Non-sensitive config data injected into Pods |
| **Secret** | `v1` | Sensitive config data (base64-encoded, not encrypted by default) |
| **Namespace** | `v1` | Virtual cluster for isolation and resource quotas |
| **PersistentVolume** | `v1` | Cluster-level storage resource |
| **PersistentVolumeClaim** | `v1` | User's request for storage |
| **StorageClass** | `storage.k8s.io/v1` | Template for dynamic volume provisioning |
| **ServiceAccount** | `v1` | Identity for processes running in Pods |
| **Role / ClusterRole** | `rbac.authorization.k8s.io/v1` | Set of API permissions |
| **RoleBinding / ClusterRoleBinding** | `rbac.authorization.k8s.io/v1` | Binds a role to a user/group/SA |
| **HorizontalPodAutoscaler** | `autoscaling/v2` | Auto-scales Deployment based on CPU/memory/custom metrics |
| **NetworkPolicy** | `networking.k8s.io/v1` | Firewall rules between Pods |

---

## 4. Labels, Selectors & Annotations

### 4.1 Labels

Key-value pairs attached to objects. Used for identification and selection.

```yaml
metadata:
  labels:
    app: frontend
    env: production
    version: "2.1"
    tier: web
```

**Label rules:**
- Key: `[prefix/]name` — prefix is optional, max 253 chars; name max 63 chars
- Value: max 63 chars, must start/end with alphanumeric

### 4.2 Selectors

Used by controllers and Services to find target Pods:

```yaml
# Equality-based
selector:
  matchLabels:
    app: frontend
    env: production

# Set-based
selector:
  matchExpressions:
  - key: app
    operator: In
    values: [frontend, backend]
  - key: env
    operator: NotIn
    values: [dev]
  - key: critical
    operator: Exists
```

### 4.3 Annotations

Non-identifying metadata. Used for tooling, documentation, config:

```yaml
metadata:
  annotations:
    kubernetes.io/description: "Main web frontend"
    prometheus.io/scrape: "true"
    prometheus.io/port: "8080"
    deployment.kubernetes.io/revision: "3"
```

---

## 5. Namespaces

### 5.1 What are Namespaces?

Virtual clusters within a physical cluster. Used to:
- Isolate teams/environments (dev, staging, prod)
- Apply resource quotas and LimitRanges
- Scope RBAC policies

### 5.2 Default Namespaces

| Namespace | Purpose |
|-----------|---------|
| `default` | Where resources go if no namespace specified |
| `kube-system` | Kubernetes system components (API server, dns, proxy) |
| `kube-public` | Publicly readable (cluster info) |
| `kube-node-lease` | Node heartbeat lease objects |

### 5.3 Working with Namespaces

```bash
# List namespaces
kubectl get namespaces

# Create namespace
kubectl create namespace my-team

# Or via YAML
kubectl apply -f - <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: my-team
  labels:
    env: staging
EOF

# Set default namespace for current context
kubectl config set-context --current --namespace=my-team

# Resources in all namespaces
kubectl get pods -A
kubectl get pods --all-namespaces
```

---

## 6. The Control Loop (Reconciliation)

Kubernetes is built on a **control loop** pattern:

```
         ┌──────────────────────────────────────┐
         │                                      │
         ▼                                      │
  [Desired State]  ──▶  [Observe Current]  ──▶  [Diff]  ──▶  [Act]
  (spec in etcd)        (status from nodes)    (!=?)         (API calls)
         ▲                                                         │
         └─────────────────────────────────────────────────────────┘
```

Example: Deployment with `replicas: 3`
1. Controller reads desired state: 3 replicas
2. Controller observes current state: 2 Pods running
3. Diff: need 1 more Pod
4. Controller creates a new Pod via API server
5. Scheduler assigns Pod to a node
6. kubelet pulls image and starts container

This loop runs **continuously** — Kubernetes is always self-correcting.

---

## 7. Kubernetes API Groups & Versions

Resources are organized in API groups:

| API Group | Resources |
|-----------|-----------|
| `""` (core) | Pod, Service, ConfigMap, Secret, PV, PVC, Namespace |
| `apps` | Deployment, ReplicaSet, StatefulSet, DaemonSet |
| `batch` | Job, CronJob |
| `networking.k8s.io` | Ingress, NetworkPolicy, IngressClass |
| `storage.k8s.io` | StorageClass, VolumeAttachment |
| `rbac.authorization.k8s.io` | Role, ClusterRole, RoleBinding, ClusterRoleBinding |
| `autoscaling` | HorizontalPodAutoscaler |
| `apiextensions.k8s.io` | CustomResourceDefinition |
| `policy` | PodDisruptionBudget |

```bash
# List all available API resources and their versions
kubectl api-resources
kubectl api-resources --namespaced=true

# List supported API versions
kubectl api-versions
```

---

## 8. How Kubernetes Runs a Container (End-to-End)

```
1. User:         kubectl apply -f deployment.yaml
2. API Server:   Validates YAML, writes to etcd
3. Controller:   Deployment controller creates ReplicaSet
                 ReplicaSet controller creates Pod objects
4. Scheduler:    Finds best node for each Pod → writes nodeName to Pod
5. kubelet:      Sees Pod assigned to its node
                 Pulls container image via container runtime
                 Starts containers, sets up volumes & networking
6. kube-proxy:   Updates iptables rules for Service routing
7. Status:       kubelet reports Pod status → API server → etcd
```

---

## 9. Key Terminology Glossary

| Term | Meaning |
|------|---------|
| **Cluster** | Set of machines (nodes) running Kubernetes |
| **Node** | A single machine in the cluster (physical or VM) |
| **Pod** | Group of one or more containers sharing network and storage |
| **Container** | A running instance of a Docker/OCI image |
| **Image** | Immutable, layered filesystem for a container |
| **Registry** | Storage for container images (Docker Hub, ECR, GCR) |
| **Manifest** | YAML/JSON file describing a Kubernetes object |
| **Workload** | Application running in K8s (Deployment, StatefulSet, etc.) |
| **Rolling Update** | Gradually replacing old Pods with new ones |
| **Rollback** | Reverting to a previous Deployment revision |
| **Taint** | Mark on a node that repels Pods (unless they tolerate it) |
| **Toleration** | Pod's permission to be scheduled on a tainted node |
| **Affinity** | Rules that attract Pods to certain nodes |
| **Probe** | Health check: liveness, readiness, or startup |
| **Resource Request** | Minimum CPU/memory a Pod needs (used for scheduling) |
| **Resource Limit** | Maximum CPU/memory a Pod can use |
| **QoS Class** | Guaranteed, Burstable, or BestEffort (based on requests/limits) |
| **Context** | Named kubectl connection config (cluster + user + namespace) |
| **Kubeconfig** | `~/.kube/config` file storing contexts and credentials |
