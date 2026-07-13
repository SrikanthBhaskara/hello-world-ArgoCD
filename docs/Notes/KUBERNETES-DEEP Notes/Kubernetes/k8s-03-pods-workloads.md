# Kubernetes 03 – Pods & Workload Resources

## 0. Goal of This Note

- Master Pod configuration and lifecycle
- Understand all workload controllers: Deployment, ReplicaSet, DaemonSet, StatefulSet, Job, CronJob
- Know how to configure health probes, resource limits, and scheduling constraints
- Learn multi-container patterns

---

## 1. Pods

### 1.1 What is a Pod?

A **Pod** is the smallest deployable unit in Kubernetes. It groups one or more containers that:
- Share the same **network namespace** (same IP, ports)
- Share the same **storage volumes**
- Are always co-located on the same node
- Are scheduled and managed together

```
Pod
├── Container 1 (main app)
├── Container 2 (sidecar, e.g., log shipper)
└── Shared Volumes + Network (localhost between containers)
```

> Pods are **ephemeral** – they are not restarted, they are replaced. Never use bare Pods in production; always use a controller (Deployment, etc.).

### 1.2 Basic Pod YAML

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
  namespace: default
  labels:
    app: my-app
    env: prod
spec:
  containers:
  - name: main-app
    image: nginx:1.25
    ports:
    - containerPort: 80
      name: http
      protocol: TCP
    env:
    - name: ENV_VAR
      value: "hello"
    resources:
      requests:
        memory: "64Mi"
        cpu: "250m"
      limits:
        memory: "128Mi"
        cpu: "500m"
```

### 1.3 Pod Lifecycle

```
Pending → Running → Succeeded/Failed
```

| Phase | Meaning |
|-------|---------|
| **Pending** | Pod accepted, waiting to be scheduled or image being pulled |
| **Running** | Pod bound to a node; at least one container running |
| **Succeeded** | All containers exited with code 0 (for Jobs) |
| **Failed** | At least one container exited with non-zero code |
| **Unknown** | Node communication lost |

**Container states:**
- `Waiting` – not running yet (pulling image, waiting for init container)
- `Running` – executing
- `Terminated` – completed or failed

### 1.4 Restart Policies

```yaml
spec:
  restartPolicy: Always       # default – always restart
  restartPolicy: OnFailure    # restart on non-zero exit
  restartPolicy: Never        # never restart (one-shot)
```

### 1.5 Pod Conditions

```bash
kubectl describe pod my-pod
# Look for Conditions section:
# PodScheduled   – node assigned
# Initialized    – all init containers completed
# ContainersReady – all containers are running and ready
# Ready          – pod is ready to serve traffic
```

---

## 2. Health Probes

Health probes tell Kubernetes the state of your containers.

### 2.1 Types of Probes

| Probe | Purpose | Effect if fails |
|-------|---------|----------------|
| **livenessProbe** | Is the container still alive? | Container is killed and restarted |
| **readinessProbe** | Is the container ready to serve traffic? | Pod is removed from Service endpoints |
| **startupProbe** | Has the app finished starting? | livenessProbe is suspended during startup |

### 2.2 Probe Mechanisms

```yaml
# HTTP GET
livenessProbe:
  httpGet:
    path: /health
    port: 8080
    httpHeaders:
    - name: X-Health-Check
      value: "true"
  initialDelaySeconds: 10    # wait before first check
  periodSeconds: 10          # check every 10s
  timeoutSeconds: 5          # fail if no response in 5s
  failureThreshold: 3        # fail after 3 consecutive failures
  successThreshold: 1        # succeed after 1 success (readiness: can be > 1)

# TCP Socket
readinessProbe:
  tcpSocket:
    port: 3306
  initialDelaySeconds: 5
  periodSeconds: 10

# Command Execution
livenessProbe:
  exec:
    command:
    - cat
    - /tmp/healthy
  initialDelaySeconds: 5
  periodSeconds: 10

# gRPC (requires gRPC health check protocol)
livenessProbe:
  grpc:
    port: 50051
```

### 2.3 Full Example with All Probes

```yaml
containers:
- name: web
  image: my-app:1.0
  ports:
  - containerPort: 8080
  startupProbe:
    httpGet:
      path: /ready
      port: 8080
    failureThreshold: 30      # app has 30 * 10s = 5 min to start
    periodSeconds: 10
  readinessProbe:
    httpGet:
      path: /ready
      port: 8080
    initialDelaySeconds: 5
    periodSeconds: 5
    failureThreshold: 2
  livenessProbe:
    httpGet:
      path: /health
      port: 8080
    initialDelaySeconds: 15
    periodSeconds: 20
    failureThreshold: 3
```

---

## 3. Resource Requests and Limits

```yaml
resources:
  requests:
    memory: "128Mi"       # minimum memory (used for scheduling)
    cpu: "250m"           # 250 millicores = 0.25 CPU
  limits:
    memory: "256Mi"       # maximum memory (OOMKilled if exceeded)
    cpu: "500m"           # max CPU (throttled if exceeded, NOT killed)
```

**CPU units:**
- `1` = 1 CPU core
- `500m` = 0.5 CPU
- `100m` = 0.1 CPU

**Memory units:**
- `Ki` = kibibytes (1024 bytes)
- `Mi` = mebibytes
- `Gi` = gibibytes
- `K`, `M`, `G` = decimal (1000-based)

**QoS Classes (affects eviction priority):**

| Class | Condition |
|-------|-----------|
| **Guaranteed** | requests == limits for all containers |
| **Burstable** | requests < limits, both set |
| **BestEffort** | no requests or limits set |

Eviction order: BestEffort → Burstable → Guaranteed

---

## 4. Environment Variables

```yaml
containers:
- name: app
  image: my-app
  env:
  # Literal value
  - name: ENVIRONMENT
    value: "production"
  
  # From ConfigMap
  - name: DB_HOST
    valueFrom:
      configMapKeyRef:
        name: app-config
        key: database.host
  
  # From Secret
  - name: DB_PASSWORD
    valueFrom:
      secretKeyRef:
        name: app-secrets
        key: db-password
  
  # From Pod fields
  - name: MY_POD_NAME
    valueFrom:
      fieldRef:
        fieldPath: metadata.name
  - name: MY_POD_NAMESPACE
    valueFrom:
      fieldRef:
        fieldPath: metadata.namespace
  - name: MY_POD_IP
    valueFrom:
      fieldRef:
        fieldPath: status.podIP
  
  # From resource fields
  - name: MY_CPU_LIMIT
    valueFrom:
      resourceFieldRef:
        containerName: app
        resource: limits.cpu
  
  # Load all keys from a ConfigMap as env vars
  envFrom:
  - configMapRef:
      name: app-config
  - secretRef:
      name: app-secrets
  - configMapRef:
      name: extra-config
    prefix: EXTRA_              # optional key prefix
```

---

## 5. Init Containers

Run **before** the main containers. Used for:
- Waiting for dependencies (database, service)
- Downloading config files
- Setting up filesystem permissions

```yaml
spec:
  initContainers:
  - name: wait-for-db
    image: busybox
    command: ['sh', '-c', 'until nc -z postgres 5432; do echo waiting; sleep 2; done']
  
  - name: init-config
    image: alpine
    command: ['wget', '-O', '/config/app.conf', 'http://config-server/app.conf']
    volumeMounts:
    - name: config-vol
      mountPath: /config
  
  containers:
  - name: app
    image: my-app
    volumeMounts:
    - name: config-vol
      mountPath: /app/config
  
  volumes:
  - name: config-vol
    emptyDir: {}
```

**Init container rules:**
- Run sequentially, in order
- Each must complete successfully before the next starts
- If one fails, kubelet restarts the pod (based on `restartPolicy`)
- Do not support `livenessProbe`, `readinessProbe`, `startupProbe`

---

## 6. Multi-Container Patterns

### 6.1 Sidecar Pattern

A helper container runs alongside the main container. Common uses: log agents, proxies, metric exporters.

```yaml
spec:
  containers:
  - name: app
    image: my-web-app
    volumeMounts:
    - name: log-vol
      mountPath: /var/log/app
  
  - name: log-shipper
    image: fluentd:latest
    volumeMounts:
    - name: log-vol
      mountPath: /var/log/app
      readOnly: true
  
  volumes:
  - name: log-vol
    emptyDir: {}
```

### 6.2 Ambassador Pattern

Proxy container that handles outbound connections on behalf of the main container.

```yaml
containers:
- name: app
  image: my-app
  # app connects to localhost:5432
  env:
  - name: DB_HOST
    value: "localhost"

- name: db-proxy
  image: envoy:latest
  # forwards localhost:5432 to real DB
```

### 6.3 Adapter Pattern

Transform the main container's output (e.g., convert metrics format).

---

## 7. Volumes in Pods

```yaml
spec:
  containers:
  - name: app
    image: nginx
    volumeMounts:
    - name: cache
      mountPath: /cache
    - name: config
      mountPath: /etc/nginx/conf.d
      readOnly: true
    - name: secrets
      mountPath: /etc/secrets
      readOnly: true
  
  volumes:
  # Temporary storage, deleted with pod
  - name: cache
    emptyDir: {}
  
  # Host node directory
  - name: host-logs
    hostPath:
      path: /var/log
      type: Directory             # Directory | File | DirectoryOrCreate | FileOrCreate
  
  # From ConfigMap
  - name: config
    configMap:
      name: nginx-config
      items:                       # optional: mount specific keys
      - key: nginx.conf
        path: default.conf
  
  # From Secret
  - name: secrets
    secret:
      secretName: my-secret
      defaultMode: 0400            # file permissions
```

---

## 8. Scheduling – Node Affinity, Taints, Tolerations

### 8.1 nodeSelector (Simple)

```yaml
spec:
  nodeSelector:
    disktype: ssd
    zone: us-east-1a
```

### 8.2 Node Affinity (Advanced)

```yaml
spec:
  affinity:
    nodeAffinity:
      # MUST match (hard rule)
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: disktype
            operator: In
            values: [ssd, nvme]
      
      # PREFER to match (soft rule)
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100               # higher = stronger preference
        preference:
          matchExpressions:
          - key: zone
            operator: In
            values: [us-east-1a]
```

### 8.3 Pod Affinity / Anti-Affinity

Run Pods **near** or **away from** other Pods:

```yaml
affinity:
  # Co-locate with pods that have app=cache
  podAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
    - labelSelector:
        matchLabels:
          app: cache
      topologyKey: kubernetes.io/hostname

  # Spread across different nodes (no two app=web pods on same node)
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 100
      podAffinityTerm:
        labelSelector:
          matchLabels:
            app: web
        topologyKey: kubernetes.io/hostname
```

### 8.4 Taints and Tolerations

**Taints** repel Pods from nodes. **Tolerations** allow Pods to be scheduled on tainted nodes.

```bash
# Add taint to node
kubectl taint nodes node1 gpu=true:NoSchedule
kubectl taint nodes node1 maintenance=true:NoExecute    # evicts existing pods too
```

```yaml
# Pod with toleration
spec:
  tolerations:
  - key: "gpu"
    operator: "Equal"
    value: "true"
    effect: "NoSchedule"
  
  - key: "node.kubernetes.io/not-ready"
    operator: "Exists"
    effect: "NoExecute"
    tolerationSeconds: 300         # evict after 300s
```

### 8.5 Topology Spread Constraints

Spread Pods evenly across zones/nodes:

```yaml
spec:
  topologySpreadConstraints:
  - maxSkew: 1                             # max difference in count between zones
    topologyKey: topology.kubernetes.io/zone
    whenUnsatisfiable: DoNotSchedule      # or ScheduleAnyway
    labelSelector:
      matchLabels:
        app: web
```

---

## 9. Deployments

### 9.1 What is a Deployment?

A **Deployment** manages a **ReplicaSet**, which manages **Pods**. It adds:
- Rolling updates
- Rollback capability
- Revision history

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
  namespace: default
  labels:
    app: my-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-app                  # must match pod template labels
  
  strategy:
    type: RollingUpdate            # or Recreate
    rollingUpdate:
      maxUnavailable: 1            # max pods unavailable during update
      maxSurge: 1                  # max extra pods during update
  
  revisionHistoryLimit: 10         # how many old ReplicaSets to keep
  
  template:
    metadata:
      labels:
        app: my-app                # must match selector.matchLabels
    spec:
      containers:
      - name: my-app
        image: nginx:1.25
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "100m"
          limits:
            memory: "128Mi"
            cpu: "200m"
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 10
```

### 9.2 Update Strategies

**RollingUpdate** (default):
```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxUnavailable: 25%   # can be absolute number or percentage
    maxSurge: 25%
```
- New pods come up before old ones are taken down
- Zero downtime (with proper readiness probes)

**Recreate**:
```yaml
strategy:
  type: Recreate
```
- All old pods are killed before new ones start
- Causes downtime but ensures no two versions run simultaneously

### 9.3 Managing Deployments

```bash
# Create
kubectl apply -f deployment.yaml

# Scale
kubectl scale deployment my-app --replicas=5

# Update image (triggers rolling update)
kubectl set image deployment/my-app my-app=nginx:1.26
# or add --record (deprecated but used in exams)
kubectl set image deployment/my-app my-app=nginx:1.26 --record

# Check rollout
kubectl rollout status deployment/my-app

# History
kubectl rollout history deployment/my-app

# Rollback
kubectl rollout undo deployment/my-app
kubectl rollout undo deployment/my-app --to-revision=2

# Pause / Resume
kubectl rollout pause deployment/my-app
kubectl rollout resume deployment/my-app

# Restart all pods
kubectl rollout restart deployment/my-app
```

---

## 10. DaemonSets

Ensures **exactly one Pod** runs on every node (or every node matching a selector). Use cases:
- Log collectors (Fluentd, Filebeat)
- Monitoring agents (Prometheus node-exporter)
- Network plugins (CNI, kube-proxy itself)
- Storage drivers

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: log-agent
  namespace: monitoring
spec:
  selector:
    matchLabels:
      name: log-agent
  updateStrategy:
    type: RollingUpdate       # or OnDelete
    rollingUpdate:
      maxUnavailable: 1
  template:
    metadata:
      labels:
        name: log-agent
    spec:
      tolerations:
      # Run on master nodes too
      - key: node-role.kubernetes.io/control-plane
        operator: Exists
        effect: NoSchedule
      containers:
      - name: log-agent
        image: fluentd:latest
        volumeMounts:
        - name: varlog
          mountPath: /var/log
      volumes:
      - name: varlog
        hostPath:
          path: /var/log
```

---

## 11. StatefulSets

For **stateful applications** that need:
- Stable, unique network identity (pod-0, pod-1, pod-2)
- Stable, persistent storage per replica
- Ordered, graceful deployment and scaling
- Ordered rolling updates

**Examples**: databases (MySQL, PostgreSQL, MongoDB), message queues (Kafka, RabbitMQ), ZooKeeper.

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql
spec:
  serviceName: mysql-headless     # REQUIRED – must match headless service name
  replicas: 3
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - name: mysql
        image: mysql:8.0
        ports:
        - containerPort: 3306
        env:
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-secret
              key: password
        volumeMounts:
        - name: data
          mountPath: /var/lib/mysql
  
  volumeClaimTemplates:           # creates a PVC for each pod
  - metadata:
      name: data
    spec:
      accessModes: [ReadWriteOnce]
      storageClassName: standard
      resources:
        requests:
          storage: 10Gi

---
# Headless Service (required for stable DNS)
apiVersion: v1
kind: Service
metadata:
  name: mysql-headless
spec:
  clusterIP: None              # headless – no cluster IP
  selector:
    app: mysql
  ports:
  - port: 3306
```

**DNS for StatefulSet pods:**
```
mysql-0.mysql-headless.default.svc.cluster.local
mysql-1.mysql-headless.default.svc.cluster.local
mysql-2.mysql-headless.default.svc.cluster.local
```

**Ordered behavior:**
- Created in order: 0 → 1 → 2
- Deleted in reverse: 2 → 1 → 0
- Each must be Running+Ready before next starts

---

## 12. Jobs

Run a task to **completion** (not continuously). Pod runs until it exits successfully.

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: db-migration
spec:
  completions: 1              # total successful completions needed
  parallelism: 1              # run N pods in parallel
  backoffLimit: 4             # retry on failure (max attempts)
  activeDeadlineSeconds: 300  # kill if not done in 5 min
  ttlSecondsAfterFinished: 60 # auto-delete 60s after completion
  
  template:
    spec:
      restartPolicy: Never    # REQUIRED for Jobs: Never or OnFailure
      containers:
      - name: migration
        image: my-app:latest
        command: ["python", "manage.py", "migrate"]
        env:
        - name: DB_HOST
          value: postgres

# Parallel job – run 5 completions, 2 at a time
spec:
  completions: 5
  parallelism: 2
```

```bash
# Check job status
kubectl get jobs
kubectl describe job db-migration

# See pods created by job
kubectl get pods -l job-name=db-migration

# Get logs
kubectl logs -l job-name=db-migration
```

---

## 13. CronJobs

Schedules **Jobs** on a cron schedule.

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: nightly-backup
spec:
  schedule: "0 2 * * *"         # 2 AM every day (cron syntax)
  concurrencyPolicy: Forbid     # Allow | Forbid | Replace
  successfulJobsHistoryLimit: 3
  failedJobsHistoryLimit: 1
  startingDeadlineSeconds: 60   # fail if can't start within 60s of schedule
  suspend: false                # set true to pause scheduling
  
  jobTemplate:
    spec:
      template:
        spec:
          restartPolicy: OnFailure
          containers:
          - name: backup
            image: backup-tool:latest
            command: ["/scripts/backup.sh"]
            env:
            - name: BACKUP_TARGET
              value: "s3://my-bucket/backups"
```

**Cron syntax:**
```
 ┌───── minute (0-59)
 │ ┌───── hour (0-23)
 │ │ ┌───── day of month (1-31)
 │ │ │ ┌───── month (1-12)
 │ │ │ │ ┌───── day of week (0-6, 0=Sunday)
 │ │ │ │ │
 * * * * *

Examples:
"*/5 * * * *"    every 5 minutes
"0 * * * *"      every hour
"0 0 * * *"      midnight every day
"0 0 * * 0"      midnight every Sunday
"0 9-17 * * 1-5" every hour 9-17 on weekdays
```

```bash
# Manually trigger a CronJob
kubectl create job --from=cronjob/nightly-backup manual-backup-$(date +%s)

# Check CronJob
kubectl get cronjobs
kubectl describe cronjob nightly-backup
```

---

## 14. Workload Summary

| Controller | Use Case | Scaling | Identity | Storage |
|-----------|---------|---------|---------|---------|
| **Deployment** | Stateless apps (web, API) | Horizontal | Random | Shared |
| **StatefulSet** | Stateful apps (DBs, queues) | Horizontal | Stable | Per-replica PVC |
| **DaemonSet** | One per node (log agents) | Node-based | Stable | hostPath |
| **Job** | One-time tasks | Parallel N | Temporary | Shared |
| **CronJob** | Scheduled tasks | Per run | Temporary | Shared |
