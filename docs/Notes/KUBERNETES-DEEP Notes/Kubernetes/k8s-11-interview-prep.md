# Kubernetes 11 – Interview Preparation

## 0. Goal of This Note

- Review 50 most common Kubernetes interview questions with answers
- Understand CKA and CKAD exam domains
- Practice hands-on scenarios
- Know common troubleshooting patterns

---

## 1. Core Concepts (Beginner–Intermediate)

---

**Q1: What is Kubernetes and why do we need it?**

Kubernetes is an open-source container orchestration platform that automates deployment, scaling, and management of containerized applications. We need it because:
- Running containers at scale across many hosts is complex
- Manual container management doesn't scale
- K8s provides self-healing, auto-scaling, service discovery, rolling updates, and declarative configuration out of the box

---

**Q2: What is the difference between a Pod, a Deployment, and a ReplicaSet?**

- **Pod**: Smallest deployable unit; wraps one or more containers sharing network + storage. Pods are ephemeral – no self-healing.
- **ReplicaSet**: Ensures a specified number of Pod replicas run at any time; replaces failed Pods.
- **Deployment**: Manages ReplicaSets; adds rolling updates, rollback history, and pausing/resuming updates.

> In practice you always create a Deployment, never a standalone ReplicaSet.

---

**Q3: What happens when a Pod dies in a standalone Pod vs in a Deployment?**

- **Standalone Pod**: It is NOT restarted. It transitions to `Failed` state and stays dead.
- **Deployment Pod**: The ReplicaSet controller detects the count dropped below desired replicas and creates a new Pod to replace it.

---

**Q4: Explain the Kubernetes control plane components.**

| Component | Role |
|-----------|------|
| **kube-apiserver** | Front door; validates/processes all API requests; single entry point |
| **etcd** | Distributed key-value store; holds all cluster state |
| **kube-scheduler** | Assigns newly created Pods to nodes |
| **kube-controller-manager** | Runs controller loops (ReplicaSet, Deployment, Node, etc.) |
| **cloud-controller-manager** | Interacts with cloud provider APIs (optional) |

---

**Q5: What are worker node components?**

- **kubelet**: Agent on each node; communicates with API server; ensures containers in Pods are running
- **kube-proxy**: Maintains network rules (iptables/IPVS) for Service routing
- **Container Runtime**: containerd, CRI-O, or Docker (runs the actual containers)

---

**Q6: What is etcd and why is it critical?**

etcd is a consistent and highly available key-value store used as Kubernetes' backing store for all cluster data. It stores resource state (Pods, Deployments, Secrets, etc.). If etcd is lost without a backup, you lose the entire cluster state. Always back up etcd before upgrades.

```bash
# Backup etcd
ETCDCTL_API=3 etcdctl snapshot save snapshot.db \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key
```

---

**Q7: What is a Namespace and when should you use multiple namespaces?**

Namespaces are virtual clusters within a physical cluster. Use them to:
- Isolate team workloads (team-a, team-b)
- Separate environments (dev, staging, prod) – though separate clusters are better for prod
- Apply RBAC and resource quotas per team/environment
- Avoid name collisions across teams

---

**Q8: What are Labels and Selectors?**

- **Labels**: Key-value pairs attached to objects for identification: `app=frontend`, `env=prod`
- **Selectors**: Filter objects by their labels. Used by Services, Deployments, and ReplicaSets to find target Pods.

```yaml
selector:
  matchLabels:
    app: frontend
```

---

**Q9: What is the difference between a ConfigMap and a Secret?**

| | ConfigMap | Secret |
|-|-----------|--------|
| **Purpose** | Non-sensitive config | Sensitive data (passwords, tokens) |
| **Storage** | Plaintext | base64-encoded |
| **RBAC** | Less strict | More restrictive recommended |
| **Encrypted at rest** | No (by default) | No (but can be enabled) |

Both can be used as environment variables or mounted as files.

---

**Q10: How do you expose an application externally?**

1. **NodePort**: Expose on a static port on each node (dev/test)
2. **LoadBalancer**: Cloud provisions an external load balancer
3. **Ingress**: HTTP/HTTPS routing rules (host + path based) via an IngressController
4. **port-forward**: Quick local access for debugging (not production)

For production: **Ingress + IngressController** (e.g., nginx-ingress) behind a **LoadBalancer** Service.

---

## 2. Workloads & Controllers

---

**Q11: When would you use a StatefulSet instead of a Deployment?**

Use StatefulSet when your application needs:
- **Stable network identity**: each pod gets a unique, persistent hostname (`mysql-0`, `mysql-1`)
- **Stable persistent storage**: each replica gets its own PVC
- **Ordered deployment/scaling**: pods are created/deleted in order

Examples: MySQL, PostgreSQL, MongoDB, Kafka, ZooKeeper.

---

**Q12: What is a DaemonSet used for?**

A DaemonSet ensures exactly one Pod runs on every node (or a selected subset). Common uses:
- Log collection agents (Fluentd, Filebeat)
- Monitoring agents (Prometheus node-exporter, Datadog agent)
- Network plugins (CNI)
- Storage drivers

---

**Q13: What is the difference between a Job and a CronJob?**

- **Job**: Runs one or more Pods to completion (exit 0). Used for one-time tasks: DB migration, batch processing, data transformation.
- **CronJob**: Creates Jobs on a cron schedule. For recurring tasks: nightly backups, report generation, cleanup jobs.

---

**Q14: What are the three types of health probes?**

| Probe | Fails → | Purpose |
|-------|---------|---------|
| **livenessProbe** | Container restarted | Is the container alive? |
| **readinessProbe** | Pod removed from Service endpoints | Is the container ready for traffic? |
| **startupProbe** | Container restarted | Has the app finished initializing? (disables liveness during startup) |

---

**Q15: What is a rolling update and how do you control it?**

A rolling update gradually replaces old Pods with new ones to achieve zero downtime.

```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxUnavailable: 1     # max pods that can be down at once
    maxSurge: 1           # max extra pods during update
```

Control via: `kubectl rollout pause/resume`, `kubectl rollout undo`, `kubectl rollout status`

---

## 3. Networking

---

**Q16: Explain the four Kubernetes Service types.**

| Type | Access | Use Case |
|------|--------|---------|
| **ClusterIP** | Internal only | Service-to-service communication |
| **NodePort** | Via `nodeIP:nodePort` | Dev/testing external access |
| **LoadBalancer** | Via cloud LB external IP | Production external access |
| **ExternalName** | DNS CNAME alias | Point to external services |

---

**Q17: What is an Ingress? Why is it preferred over a LoadBalancer Service?**

Ingress is an API object that manages HTTP/HTTPS routing into the cluster. An IngressController (e.g., nginx-ingress) implements it.

**Why prefer over LoadBalancer:**
- One LoadBalancer can serve many services (cost savings)
- Host-based and path-based routing
- TLS termination in one place
- Rewrite rules, rate limiting, etc.

---

**Q18: How does in-cluster DNS work?**

CoreDNS runs as a Deployment in `kube-system`. It resolves:
```
my-svc.my-namespace.svc.cluster.local
```

Short forms work too: within the same namespace, `my-svc` resolves correctly.

---

**Q19: What is a NetworkPolicy?**

NetworkPolicy controls which Pods can communicate with which, acting as a Pod-level firewall (L3/L4). By default: all pods can reach all pods. Once you apply a NetworkPolicy to a pod, only traffic matching the policy is allowed.

Requires a CNI plugin that supports it (Calico, Cilium).

---

**Q20: What is the difference between ClusterIP and Headless Service?**

- **ClusterIP**: Has a single stable IP; kube-proxy load-balances across Pods
- **Headless** (`clusterIP: None`): No stable IP; DNS returns A records for each Pod IP directly. Required by StatefulSets for stable Pod DNS names.

---

## 4. Storage

---

**Q21: What is a PersistentVolume (PV) vs a PersistentVolumeClaim (PVC)?**

- **PV**: Cluster-level resource representing actual storage (provisioned by admin or dynamically)
- **PVC**: Namespace-scoped user request for storage; gets bound to a PV that satisfies it

Think of it like: PV = hotel room, PVC = room reservation.

---

**Q22: What are the three PV access modes?**

| Mode | Meaning |
|------|---------|
| **ReadWriteOnce (RWO)** | Mount read-write by one node |
| **ReadOnlyMany (ROX)** | Mount read-only by many nodes |
| **ReadWriteMany (RWX)** | Mount read-write by many nodes |

Most block volumes (EBS, GCE PD) only support RWO. NFS and Azure Files support RWX.

---

**Q23: What is a StorageClass?**

StorageClass is a Kubernetes resource that defines a type of storage and its provisioner. It enables **dynamic provisioning** – PVs are automatically created when a PVC requests a StorageClass. Each cloud provider has its own provisioner.

---

**Q24: What happens to the PVC when a StatefulSet is deleted?**

The PVCs created by `volumeClaimTemplates` are NOT deleted when the StatefulSet is deleted. This is intentional to protect data. You must manually delete the PVCs.

---

**Q25: What is the difference between emptyDir and hostPath?**

- **emptyDir**: Temporary directory created with the Pod; deleted when Pod is removed. Good for scratch space or sharing data between containers in a Pod.
- **hostPath**: Mounts a path from the host node. Data persists on that node even if Pod is deleted. Security risk in production.

---

## 5. RBAC & Security

---

**Q26: How does RBAC work in Kubernetes?**

RBAC uses four objects:
1. **Role/ClusterRole**: Defines permissions (which verbs on which resources)
2. **RoleBinding/ClusterRoleBinding**: Binds a Role to subjects (Users, Groups, ServiceAccounts)

Role = namespaced, ClusterRole = cluster-wide.

---

**Q27: What is a ServiceAccount and why is it used?**

A ServiceAccount provides an identity for Pods to authenticate to the Kubernetes API. When a Pod calls the API (e.g., an Operator listing Pods), it uses its ServiceAccount's token. Every namespace has a `default` SA. Best practice: create a dedicated SA with minimal permissions per workload.

---

**Q28: What is the principle of least privilege in Kubernetes?**

Only grant permissions that are strictly necessary:
- Use Roles (not ClusterRoles) when namespace-scoped access is sufficient
- Don't bind `cluster-admin` to application ServiceAccounts
- Set `automountServiceAccountToken: false` when the Pod doesn't need API access
- Drop all capabilities and add back only what's needed
- Use ReadOnly filesystem where possible

---

**Q29: What is a Security Context?**

Security Context defines privilege and access control settings at the Pod or container level:
```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  readOnlyRootFilesystem: true
  allowPrivilegeEscalation: false
  capabilities:
    drop: [ALL]
```

---

**Q30: What are Pod Security Standards?**

Three levels: **Privileged** (no restrictions), **Baseline** (prevents known escalations), **Restricted** (best practices). Applied to namespaces via labels:
```
pod-security.kubernetes.io/enforce: restricted
```

---

## 6. Scheduling

---

**Q31: How does the Kubernetes scheduler decide where to place a Pod?**

Two stages:
1. **Filtering**: Finds feasible nodes (enough CPU/memory, node selectors match, taints tolerated)
2. **Scoring**: Ranks feasible nodes by criteria (balanced resource usage, pod anti-affinity spread, etc.)

The highest-scoring node gets the Pod.

---

**Q32: What are Taints and Tolerations?**

- **Taint**: Applied to a node; repels Pods (`kubectl taint nodes node1 key=value:NoSchedule`)
- **Toleration**: Applied to a Pod; allows it to be scheduled on tainted nodes

Effects: `NoSchedule` (won't schedule), `PreferNoSchedule` (avoid if possible), `NoExecute` (evict existing pods too)

---

**Q33: What is Node Affinity vs Pod Affinity?**

- **Node Affinity**: Rules that attract Pods to certain nodes (based on node labels)
- **Pod Affinity**: Place Pods near other specific Pods (same topology zone)
- **Pod Anti-Affinity**: Spread Pods away from other Pods (different nodes for HA)

`requiredDuringScheduling` = hard rule; `preferredDuringScheduling` = soft preference.

---

**Q34: What is the difference between nodeSelector and node affinity?**

- **nodeSelector**: Simple key=value match; hard rule only
- **nodeAffinity**: Supports `In`, `NotIn`, `Exists`, `DoesNotExist`, `Gt`, `Lt` operators; supports soft preferences

---

## 7. Auto-Scaling

---

**Q35: What is HPA and how does it work?**

**Horizontal Pod Autoscaler** scales the number of Pod replicas based on observed metrics (CPU, memory, custom). It:
1. Periodically queries Metrics Server (every 15s)
2. Calculates desired replicas = `currentReplicas × (currentMetric / targetMetric)`
3. Updates the Deployment's replica count

---

**Q36: What is the difference between HPA and VPA?**

| | HPA | VPA |
|-|-----|-----|
| **Scales** | Pod count (horizontal) | CPU/memory requests (vertical) |
| **Use when** | Load varies; app is stateless | Right-sizing resources for stable load |
| **Can together?** | Not recommended with CPU metric | Use HPA for replicas, VPA for sizing |

---

**Q37: What is Cluster Autoscaler?**

Cluster Autoscaler adjusts the number of **nodes** in a cluster:
- **Scales up**: when Pods are unschedulable due to lacking resources
- **Scales down**: when nodes are underutilized (less than 50% for 10 minutes by default)

---

## 8. Helm

---

**Q38: What is Helm and what problem does it solve?**

Helm is the Kubernetes package manager. It solves:
- Managing complex apps with many related K8s objects
- Templating (different values per environment)
- Versioning and rollbacks of releases
- Sharing applications via chart repositories

---

**Q39: What is the difference between `helm install` and `helm upgrade --install`?**

- `helm install`: Creates a new release; fails if the release already exists
- `helm upgrade --install`: Creates if it doesn't exist; upgrades if it does. Idempotent. Preferred in CI/CD.

---

**Q40: How do you override Helm values?**

```bash
# At install time
helm install my-app chart/ --set replicas=3 --set image.tag=v2
helm install my-app chart/ -f production-values.yaml

# Multiple files (later overrides earlier)
helm install my-app chart/ -f base.yaml -f prod.yaml
```

---

## 9. Operations & Troubleshooting

---

**Q41: A Pod is stuck in Pending state. How do you debug it?**

```bash
kubectl describe pod <pod-name>
# Look at Events section at the bottom:
```

Common causes:
| Event Message | Cause |
|---------------|-------|
| `0/3 nodes are available: insufficient cpu` | Not enough CPU resources on nodes |
| `0/3 nodes are available: node(s) had taint` | Pod doesn't tolerate node taints |
| `0/3 nodes are available: pod has unbound PVC` | PVC isn't bound to a PV |
| `ImagePullBackOff` | Wrong image name, tag, or missing registry credentials |

---

**Q42: A Pod is in CrashLoopBackOff. How do you debug it?**

```bash
# Check current logs
kubectl logs <pod-name>

# Check logs from previous container (the one that crashed)
kubectl logs <pod-name> --previous

# Check events
kubectl describe pod <pod-name>

# Check exit code
kubectl get pod <pod-name> -o jsonpath='{.status.containerStatuses[0].lastState.terminated.exitCode}'
```

Common causes: app crashes on startup, missing env/config, wrong command, missing dependencies.

---

**Q43: How do you perform a zero-downtime deployment?**

1. Use a **Deployment** (not standalone Pods)
2. Set `strategy.type: RollingUpdate`
3. Configure `maxUnavailable: 0` and `maxSurge: 1`
4. Add a **readinessProbe** – new pods won't receive traffic until ready
5. Add a **preStop** hook with sleep to allow load balancer drain
6. Set appropriate `terminationGracePeriodSeconds`

---

**Q44: How do you roll back a Deployment?**

```bash
# Check history
kubectl rollout history deployment/my-app

# Rollback to previous version
kubectl rollout undo deployment/my-app

# Rollback to specific revision
kubectl rollout undo deployment/my-app --to-revision=3
```

---

**Q45: How do you safely remove a node from the cluster for maintenance?**

```bash
# 1. Mark unschedulable (no new pods)
kubectl cordon worker-1

# 2. Evict all pods (respects PDBs)
kubectl drain worker-1 \
  --ignore-daemonsets \
  --delete-emptydir-data

# 3. Perform maintenance

# 4. Re-enable scheduling
kubectl uncordon worker-1
```

---

**Q46: How do you debug network connectivity between two Pods?**

```bash
# 1. Check if service endpoints are populated
kubectl get endpoints my-svc

# 2. DNS test from a pod
kubectl exec pod-a -- nslookup my-svc

# 3. Connectivity test
kubectl exec pod-a -- curl http://my-svc:80

# 4. Check NetworkPolicies
kubectl get networkpolicies -A

# 5. Use netshoot for advanced debugging
kubectl run test --image=nicolaka/netshoot --rm -it --restart=Never -- bash
```

---

**Q47: How do you check resource usage in the cluster?**

```bash
kubectl top nodes                         # node CPU/memory
kubectl top pods -A                       # all pod CPU/memory
kubectl top pods --sort-by=memory         # sort by memory
kubectl describe node worker-1 | grep -A 10 "Allocated"  # node allocation
```

---

## 10. CKA / CKAD Exam Tips

---

**Q48: What are the CKA exam domains?**

| Domain | Weight |
|--------|--------|
| Cluster Architecture, Installation & Configuration | 25% |
| Workloads & Scheduling | 15% |
| Services & Networking | 20% |
| Storage | 10% |
| Troubleshooting | 30% |

---

**Q49: What are the CKAD exam domains?**

| Domain | Weight |
|--------|--------|
| Application Design and Build | 20% |
| Application Deployment | 20% |
| Application Observability and Maintenance | 15% |
| Application Environment, Configuration and Security | 25% |
| Services & Networking | 20% |

---

**Q50: Top exam tips for CKA/CKAD?**

1. **Set up aliases**: `alias k=kubectl && complete -o default -F __start_kubectl k`
2. **Use `--dry-run=client -o yaml`** to generate YAML quickly
3. **Use kubectl documentation** (`kubectl explain <resource>`)
4. **Know the exam docs** at kubernetes.io/docs – it's open-book
5. **Practice with`tmux`** for multiple terminals
6. **Be fast with `kubectl edit`** and imperative commands
7. **Time management**: skip hard questions, come back later
8. **Verify your work** after each task with `kubectl get` and `kubectl describe`

**Most useful commands in the exam:**
```bash
kubectl run nginx --image=nginx --dry-run=client -o yaml > pod.yaml
kubectl create deployment web --image=nginx --replicas=3 --dry-run=client -o yaml > deploy.yaml
kubectl expose deployment web --port=80 --type=NodePort --dry-run=client -o yaml > svc.yaml
kubectl explain pod.spec.containers.securityContext
kubectl get events --sort-by=.lastTimestamp
kubectl rollout status deployment/web
kubectl auth can-i create pods
```

---

## 11. Architecture Scenario Questions

**Scenario: Design the storage architecture for a stateful database cluster in Kubernetes.**

- Use StatefulSet with `volumeClaimTemplates` (each pod gets its own PVC)
- Use a StorageClass with `allowVolumeExpansion: true` and RWO access mode
- Set `reclaimPolicy: Retain` to prevent data loss on PVC deletion
- Use a headless Service for stable DNS per pod
- Use Pod Disruption Budget to ensure at least (majority) nodes stay up
- Regular backups via CronJob or volume snapshots

**Scenario: A production service is seeing intermittent 503 errors during deployments.**

Likely cause: Pods are receiving traffic before they're ready.

Fix:
1. Add `readinessProbe` to remove Pods from endpoints until ready
2. Add `preStop` hook with `sleep 5` to let load balancer drain
3. Increase `terminationGracePeriodSeconds` if app needs more time to shut down
4. Set `maxUnavailable: 0` in rolling update strategy

**Scenario: The cluster is running out of resources. Some non-critical jobs are starving critical services.**

Solutions:
1. Add `ResourceQuotas` per namespace to cap resource usage
2. Set proper `requests` and `limits` on all containers
3. Use Priority Classes – assign higher priority to critical services
4. Use LimitRange to set defaults
5. Scale up node pool or enable Cluster Autoscaler
