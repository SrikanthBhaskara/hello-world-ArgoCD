# Kubernetes 09 – Monitoring & Logging

## 0. Goal of This Note

- Understand Kubernetes observability pillars: metrics, logs, traces
- Use Metrics Server, Resource Requests/Limits
- Set up Prometheus and Grafana
- Understand Kubernetes logging architecture
- Configure a centralized logging stack (EFK/ELK)
- Set up alerting

---

## 1. Observability Pillars

```
┌────────────────────────────────────────────────────────┐
│                    OBSERVABILITY                         │
│                                                          │
│  METRICS          LOGS            TRACES                 │
│  (What's         (What            (Request               │
│  happening?)      happened?)       path through          │
│                                    services)             │
│  Prometheus      Elasticsearch    Jaeger                 │
│  Grafana         Loki             Zipkin                 │
│  Metrics Server  Fluentd          Tempo                  │
└────────────────────────────────────────────────────────┘
```

---

## 2. Metrics Server

**Metrics Server** is the official, lightweight cluster resource usage collector. Required for:
- `kubectl top pods/nodes`
- Horizontal Pod Autoscaler (HPA)

### 2.1 Install

```bash
# With Helm
helm upgrade --install metrics-server metrics-server/metrics-server \
  --namespace kube-system

# Direct manifest
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# minikube
minikube addons enable metrics-server
```

### 2.2 Usage

```bash
# Node resource usage
kubectl top nodes

# Pod resource usage
kubectl top pods
kubectl top pods -A
kubectl top pods -n my-namespace
kubectl top pods --containers          # per-container breakdown
kubectl top pods --sort-by=cpu
kubectl top pods --sort-by=memory
```

---

## 3. Resource Requests and Limits Deep Dive

### 3.1 Setting Resources

```yaml
containers:
- name: app
  resources:
    requests:
      cpu: "250m"          # 0.25 CPU cores (used by scheduler)
      memory: "128Mi"
    limits:
      cpu: "500m"          # throttled if exceeded (NOT killed)
      memory: "256Mi"      # OOMKilled if exceeded
```

### 3.2 Resource Behavior

| | CPU | Memory |
|-|-----|--------|
| **Exceeded request** | Allowed (burstable) | Allowed |
| **Exceeded limit** | Throttled (slowed) | **OOMKilled** |
| **No request set** | Inherits limit | Inherits limit |
| **No limit set** | Can use all node CPU | Can use all node memory |

```bash
# Check if a container is being throttled or OOMKilled
kubectl describe pod my-pod | grep -A5 "Last State"
kubectl get events --field-selector reason=OOMKilling

# Check OOMKilled events
kubectl get events -A | grep OOMKill
```

### 3.3 Vertical Pod Autoscaler (VPA) – Auto Right-sizing

```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: my-app-vpa
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: my-app
  updatePolicy:
    updateMode: Auto         # Auto | Recreate | Initial | Off
  resourcePolicy:
    containerPolicies:
    - containerName: app
      minAllowed:
        cpu: 50m
        memory: 64Mi
      maxAllowed:
        cpu: "2"
        memory: 2Gi
```

```bash
# Check VPA recommendations
kubectl describe vpa my-app-vpa
```

---

## 4. Prometheus Stack

**Prometheus** scrapes metrics from targets and stores them as time series data. **Grafana** visualizes them.

### 4.1 Install kube-prometheus-stack (Recommended)

Includes: Prometheus, Grafana, Alertmanager, Node Exporter, kube-state-metrics.

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm upgrade --install kube-prometheus-stack \
  prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --set grafana.adminPassword=admin \
  --set prometheus.prometheusSpec.retention=30d

# Check all components are running
kubectl get pods -n monitoring
```

### 4.2 Access Grafana

```bash
# Port-forward Grafana
kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80
# Open: http://localhost:3000
# Username: admin / Password: as set above

# Or get the admin password if auto-generated
kubectl get secret -n monitoring kube-prometheus-stack-grafana \
  -o jsonpath="{.data.admin-password}" | base64 -d
```

### 4.3 Access Prometheus

```bash
kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090
# Open: http://localhost:9090
```

### 4.4 PromQL Basics

```
# CPU usage by pod
rate(container_cpu_usage_seconds_total{namespace="default"}[5m])

# Memory usage by pod
container_memory_working_set_bytes{namespace="default"}

# HTTP request rate
rate(http_requests_total[5m])

# Error rate
rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m])

# Pod restarts
increase(kube_pod_container_status_restarts_total[1h])

# Node is not Ready
kube_node_status_condition{condition="Ready",status="true"} == 0
```

### 4.5 Instrument Your App

```yaml
# Annotate pods for Prometheus scraping
metadata:
  annotations:
    prometheus.io/scrape: "true"
    prometheus.io/port: "8080"
    prometheus.io/path: "/metrics"

# Or use PodMonitor/ServiceMonitor (preferred in kube-prometheus-stack)
```

```yaml
# ServiceMonitor (tells Prometheus to scrape this service)
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: my-app-monitor
  namespace: monitoring
  labels:
    release: kube-prometheus-stack    # must match Prometheus selector
spec:
  selector:
    matchLabels:
      app: my-app
  namespaceSelector:
    matchNames:
    - default
  endpoints:
  - port: http-metrics
    path: /metrics
    interval: 30s
```

---

## 5. Alertmanager

```yaml
# PrometheusRule – define alert rules
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: my-alerts
  namespace: monitoring
  labels:
    release: kube-prometheus-stack
spec:
  groups:
  - name: pod-alerts
    interval: 30s
    rules:
    
    - alert: PodCrashLooping
      expr: increase(kube_pod_container_status_restarts_total[15m]) > 3
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "Pod {{ $labels.pod }} is crash-looping"
        description: "Pod {{ $labels.pod }} has restarted more than 3 times in 15 minutes"
    
    - alert: HighMemoryUsage
      expr: |
        container_memory_working_set_bytes / container_spec_memory_limit_bytes > 0.9
      for: 10m
      labels:
        severity: critical
      annotations:
        summary: "Container {{ $labels.container }} memory near limit"
    
    - alert: NodeNotReady
      expr: kube_node_status_condition{condition="Ready",status="true"} == 0
      for: 2m
      labels:
        severity: critical
      annotations:
        summary: "Node {{ $labels.node }} is not ready"
```

### 5.1 Alertmanager Config (Slack notifications)

```yaml
# In kube-prometheus-stack values
alertmanager:
  config:
    global:
      resolve_timeout: 5m
    route:
      group_by: ['alertname', 'namespace']
      group_wait: 30s
      group_interval: 5m
      repeat_interval: 4h
      receiver: slack-notifications
    receivers:
    - name: slack-notifications
      slack_configs:
      - api_url: https://hooks.slack.com/services/xxx/yyy/zzz
        channel: '#alerts'
        title: '{{ .GroupLabels.alertname }}'
        text: '{{ range .Alerts }}{{ .Annotations.summary }}\n{{ end }}'
```

---

## 6. Kubernetes Logging Architecture

### 6.1 How Kubernetes Handles Logs

```
Container stdout/stderr
        ↓
Container Runtime (containerd/docker)
        ↓
Log files on node: /var/log/pods/<namespace>_<pod>_<uid>/<container>/0.log
        ↓
kubelet rotates logs (10MB default, 5 files)
        ↓
kubectl logs reads from here
```

**Problems with this model:**
- Logs are lost when a pod is evicted/deleted
- Logs spread across many nodes
- No central search/query

### 6.2 Logging Patterns

**Application-level logging**: containers write to stdout/stderr (recommended)

**Node-level logging agent** (DaemonSet):
```
Each node → Fluentd/Fluent Bit DaemonSet → Elasticsearch/Loki
```

**Sidecar logging**:
```
App container → shared volume → Sidecar (logs to stdout) → Node agent → Backend
```

---

## 7. EFK Stack (Elasticsearch + Fluentd + Kibana)

### 7.1 Install with Helm

```bash
# Install Elasticsearch
helm repo add elastic https://helm.elastic.co
helm upgrade --install elasticsearch elastic/elasticsearch \
  --namespace logging --create-namespace \
  --set replicas=1 \
  --set minimumMasterNodes=1 \
  --set resources.requests.memory=512Mi

# Install Kibana
helm upgrade --install kibana elastic/kibana \
  --namespace logging \
  --set elasticsearchHosts="http://elasticsearch-master:9200"

# Install Fluentd (or Fluent Bit – lighter)
helm repo add fluent https://fluent.github.io/helm-charts
helm upgrade --install fluentd fluent/fluentd \
  --namespace logging

# Access Kibana
kubectl port-forward -n logging svc/kibana-kibana 5601:5601
```

### 7.2 Fluent Bit (Lightweight Alternative)

```bash
helm upgrade --install fluent-bit fluent/fluent-bit \
  --namespace logging \
  --set backend.type=es \
  --set backend.es.host=elasticsearch-master
```

---

## 8. Loki + Grafana (Log Aggregation)

**Loki** is a newer, more Kubernetes-native log aggregation system that works seamlessly with Grafana.

```bash
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Install Loki Stack (Loki + Promtail + Grafana)
helm upgrade --install loki grafana/loki-stack \
  --namespace monitoring \
  --set grafana.enabled=false \      # use existing Grafana
  --set promtail.enabled=true \
  --set loki.persistence.enabled=true \
  --set loki.persistence.size=10Gi
```

**In Grafana:**
1. Add data source: Loki → `http://loki:3100`
2. Go to Explore → select Loki
3. Query with LogQL:

```
# All logs from a namespace
{namespace="default"}

# Logs from a specific pod
{pod="my-app-xyz"}

# Filter for errors
{namespace="default"} |= "ERROR"

# Rate of error lines
rate({namespace="default"} |= "ERROR" [5m])

# Parse JSON logs
{pod="my-app-xyz"} | json | level="error"
```

---

## 9. Distributed Tracing

For microservices, tracing shows request flow across services.

### 9.1 Jaeger

```bash
helm repo add jaegertracing https://jaegertracing.github.io/helm-charts

helm upgrade --install jaeger jaegertracing/jaeger \
  --namespace monitoring \
  --set provisionDataStore.cassandra=false \
  --set allInOne.enabled=true \
  --set storage.type=memory

kubectl port-forward -n monitoring svc/jaeger-query 16686:16686
```

### 9.2 OpenTelemetry

Modern standard for generating, collecting, and exporting telemetry data:

```bash
# Install OpenTelemetry Operator
helm upgrade --install opentelemetry-operator open-telemetry/opentelemetry-operator \
  --namespace monitoring
```

---

## 10. Key Dashboards in Grafana

After installing kube-prometheus-stack, useful built-in dashboards:

| Dashboard ID | Includes |
|-------------|---------|
| **Kubernetes / Cluster** | Node CPU, memory, pod count |
| **Kubernetes / Nodes** | Per-node resources |
| **Kubernetes / Pods** | Per-pod CPU, memory, restarts |
| **Kubernetes / Workloads** | Deployment status |
| **Node Exporter Full** | Detailed host metrics |

```bash
# Import community dashboards
# Go to Grafana → + → Import → enter dashboard ID from grafana.com/dashboards
# Popular IDs:
# 315  - Kubernetes cluster monitoring
# 6417 - Kubernetes Pods
# 1860 - Node Exporter Full
# 13770 - Kubernetes All-in-one
```

---

## 11. Monitoring Best Practices

**The Four Golden Signals** (Google SRE):
1. **Latency** – time to serve requests
2. **Traffic** – requests per second
3. **Errors** – rate of failed requests
4. **Saturation** – how "full" the system is (CPU, memory)

**Process:**
```
1. Set resource requests/limits on all containers
2. Enable Metrics Server for HPA
3. Deploy kube-prometheus-stack
4. Create ServiceMonitors for your apps
5. Set up alerts for:
   - Pod CrashLooping
   - High memory/CPU usage (>80%)
   - Nodes not ready
   - PVCs nearing capacity
   - Failed Jobs
6. Deploy Loki for log aggregation
7. Create Grafana dashboards for each service
```

```bash
# Quick health check commands
kubectl get pods -A | grep -v Running | grep -v Completed
kubectl get events -A --sort-by=.lastTimestamp | tail -20
kubectl top nodes
kubectl top pods -A --sort-by=memory | head -20
```
