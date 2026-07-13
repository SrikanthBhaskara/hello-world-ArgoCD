# Kubernetes 04 – Services & Networking

## 0. Goal of This Note

- Understand how Kubernetes networking works
- Master all Service types: ClusterIP, NodePort, LoadBalancer, ExternalName
- Configure Ingress and IngressControllers
- Work with DNS in Kubernetes
- Apply NetworkPolicies to control traffic

---

## 1. Kubernetes Networking Model

### 1.1 Fundamental Rules

Kubernetes enforces these networking rules:
1. Every Pod gets its own **unique IP address**
2. Pods on any node can communicate with all Pods on any node **without NAT**
3. Agents on a node (kubelet, proxies) can communicate with all Pods on that node

```
Node 1 (10.0.1.1)          Node 2 (10.0.1.2)
┌────────────────────┐      ┌────────────────────┐
│  Pod A    Pod B    │      │  Pod C    Pod D    │
│ 10.1.0.1 10.1.0.2 │──────│ 10.1.1.1 10.1.1.2 │
└────────────────────┘      └────────────────────┘
Pod A can directly reach Pod D at 10.1.1.2 (no NAT)
```

### 1.2 Pod Networking via CNI

**CNI (Container Network Interface)** plugins implement the networking model:

| CNI Plugin | Features |
|-----------|---------|
| **Flannel** | Simple overlay network, easy setup |
| **Calico** | BGP-based, NetworkPolicy support, high performance |
| **Cilium** | eBPF-based, L7 policies, observability |
| **Weave** | Simple mesh, encryption support |
| **Canal** | Flannel + Calico NetworkPolicy |

### 1.3 The Problem Services Solve

Pods are ephemeral – they get new IPs when recreated. **Services** provide a stable endpoint:

```
Before Service:                After Service:
Client → Pod IP (changes!)     Client → Service IP (stable!)
                                          ↓
                               Service selects Pods by label
                               Distributes traffic across them
```

---

## 2. Services

### 2.1 Service Resource Structure

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
  namespace: default
spec:
  selector:
    app: my-app           # selects Pods with this label
  ports:
  - name: http
    protocol: TCP
    port: 80              # port the service listens on
    targetPort: 8080      # port on the Pod containers
  type: ClusterIP         # service type
```

**Port naming tip:**
```yaml
# Pod's container port can have a name
containers:
- name: app
  ports:
  - containerPort: 8080
    name: http

# Service can reference port by name
spec:
  ports:
  - port: 80
    targetPort: http    # references the named port
```

### 2.2 Service Types

```
ClusterIP     → internal only (default)
NodePort      → exposes on node's IP + fixed port
LoadBalancer  → provisions a cloud load balancer
ExternalName  → DNS alias to external service
```

---

## 3. ClusterIP (Default)

**Internal-only** service. Only reachable from within the cluster.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: backend-svc
spec:
  type: ClusterIP           # optional – default
  selector:
    app: backend
  ports:
  - port: 80
    targetPort: 8080
```

```bash
# ClusterIP address
kubectl get svc backend-svc
# NAME          TYPE        CLUSTER-IP     PORT(S)
# backend-svc   ClusterIP   10.96.45.123   80/TCP

# Access from a pod inside the cluster
curl http://backend-svc           # via DNS
curl http://backend-svc.default   # with namespace
curl http://10.96.45.123          # via ClusterIP directly
```

**DNS resolution:**
```
<service-name>.<namespace>.svc.cluster.local
backend-svc.default.svc.cluster.local
```

---

## 4. NodePort

Exposes the service on a **static port on every node** (30000–32767 range).

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-svc
spec:
  type: NodePort
  selector:
    app: web
  ports:
  - port: 80                  # service port (ClusterIP)
    targetPort: 8080          # pod port
    nodePort: 30080           # node port (optional; auto-assigned if omitted)
```

```
External Client → NodeIP:30080 → Service:80 → Pod:8080
```

```bash
# Access from outside the cluster
curl http://<any-node-ip>:30080

# With minikube
minikube service web-svc --url
```

**Limitation**: NodePort is usually only for dev/testing. Production uses LoadBalancer or Ingress.

---

## 5. LoadBalancer

Provisions an **external load balancer** from the cloud provider (AWS ELB, GCP LB, Azure LB).

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-svc
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: nlb   # AWS NLB (optional)
spec:
  type: LoadBalancer
  selector:
    app: web
  ports:
  - port: 80
    targetPort: 8080
```

```bash
# After creation, EXTERNAL-IP is provisioned by cloud (takes 1-2 min)
kubectl get svc web-svc
# NAME      TYPE           CLUSTER-IP    EXTERNAL-IP      PORT(S)
# web-svc   LoadBalancer   10.96.0.123   203.0.113.10     80:31234/TCP

# Access
curl http://203.0.113.10
```

**Locally (minikube)**: use `minikube tunnel` to simulate external IP assignment.

---

## 6. ExternalName

Maps a service to an **external DNS name**. No proxy, just DNS CNAME.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: external-db
spec:
  type: ExternalName
  externalName: prod-db.mycompany.com   # DNS name

# Now pods can use: external-db.default.svc.cluster.local
# which resolves to: prod-db.mycompany.com
```

---

## 7. Headless Services

A service with `clusterIP: None`. No load balancing – DNS returns Pod IPs directly. Required by StatefulSets.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: mysql-headless
spec:
  clusterIP: None             # headless
  selector:
    app: mysql
  ports:
  - port: 3306

# DNS returns A records for each pod directly
# mysql-0.mysql-headless.default.svc.cluster.local → 10.1.0.5
# mysql-1.mysql-headless.default.svc.cluster.local → 10.1.0.6
```

---

## 8. Endpoints

Services select Pods, and Kubernetes creates **Endpoints** objects to track Pod IPs:

```bash
kubectl get endpoints
kubectl get ep my-service
kubectl describe endpoints my-service
```

**Manual Endpoint** (service without selector – point to external resource):
```yaml
apiVersion: v1
kind: Service
metadata:
  name: external-api
spec:
  ports:
  - port: 443
  # no selector

---
apiVersion: v1
kind: Endpoints
metadata:
  name: external-api      # must match service name
subsets:
- addresses:
  - ip: 192.168.1.100
  - ip: 192.168.1.101
  ports:
  - port: 443
```

---

## 9. Ingress

**Ingress** manages external HTTP/HTTPS access to services. It provides:
- Host-based routing (virtual hosting)
- Path-based routing
- TLS termination
- Name-based virtual hosting

> Ingress requires an **Ingress Controller** to be installed (it doesn't work by itself).

### 9.1 Ingress Controllers

| Controller | Notes |
|-----------|-------|
| **ingress-nginx** | Most popular, maintained by Kubernetes community |
| **Traefik** | Auto-discovers services, built-in Let's Encrypt |
| **HAProxy** | High performance |
| **AWS ALB Ingress** | Uses AWS Application Load Balancer |
| **GCE Ingress** | Google Cloud's native LB |

```bash
# Install ingress-nginx via Helm
helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace

# Enable in minikube
minikube addons enable ingress

# Verify
kubectl get pods -n ingress-nginx
```

### 9.2 Basic Ingress

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /    # nginx-specific
spec:
  ingressClassName: nginx              # specify controller
  rules:
  - host: myapp.example.com
    http:
      paths:
      - path: /
        pathType: Prefix               # Prefix | Exact | ImplementationSpecific
        backend:
          service:
            name: frontend-svc
            port:
              number: 80
```

### 9.3 Path-Based Routing

```yaml
spec:
  rules:
  - host: api.example.com
    http:
      paths:
      - path: /v1
        pathType: Prefix
        backend:
          service:
            name: api-v1-svc
            port:
              number: 80
      
      - path: /v2
        pathType: Prefix
        backend:
          service:
            name: api-v2-svc
            port:
              number: 80
```

### 9.4 Host-Based Routing

```yaml
spec:
  rules:
  - host: app.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app-svc
            port:
              number: 80
  
  - host: admin.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: admin-svc
            port:
              number: 80
```

### 9.5 TLS / HTTPS

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: tls-ingress
spec:
  tls:
  - hosts:
    - myapp.example.com
    secretName: myapp-tls-secret     # TLS cert stored as Secret
  rules:
  - host: myapp.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app-svc
            port:
              number: 80
```

```bash
# Create TLS secret from cert files
kubectl create secret tls myapp-tls-secret \
  --cert=tls.crt \
  --key=tls.key
```

### 9.6 Default Backend

```yaml
spec:
  defaultBackend:                    # fallback if no rule matches
    service:
      name: default-404-svc
      port:
        number: 80
  rules: [...]
```

---

## 10. DNS in Kubernetes

Kubernetes runs **CoreDNS** (deployed as a Deployment in `kube-system`) for cluster-internal DNS.

### 10.1 DNS Records

**Services:**
```
<service-name>.<namespace>.svc.cluster.local
my-svc.default.svc.cluster.local

# Short forms (from within same namespace)
my-svc                               ← works within same namespace
my-svc.other-namespace               ← cross-namespace (shorter form)
```

**Pods:**
```
<pod-ip-dashes>.<namespace>.pod.cluster.local
10-1-0-5.default.pod.cluster.local
```

**StatefulSet Pods:**
```
<pod-name>.<service-name>.<namespace>.svc.cluster.local
mysql-0.mysql-headless.default.svc.cluster.local
```

### 10.2 DNS Policy in Pods

```yaml
spec:
  dnsPolicy: ClusterFirst           # default – use cluster DNS, fallback upstream
  # dnsPolicy: Default             – use node's DNS
  # dnsPolicy: None                – fully custom (use dnsConfig)
  # dnsPolicy: ClusterFirstWithHostNet – for pods with hostNetwork: true
  
  dnsConfig:
    nameservers:
    - 8.8.8.8
    searches:
    - my-ns.svc.cluster.local
    - svc.cluster.local
    options:
    - name: ndots
      value: "5"
```

```bash
# Debug DNS from within a pod
kubectl run dns-test --image=busybox --rm -it --restart=Never -- nslookup my-svc
kubectl run dns-test --image=busybox --rm -it --restart=Never -- nslookup my-svc.default.svc.cluster.local
```

---

## 11. NetworkPolicy

Controls **which Pods can communicate with which** at the network (L3/L4) level. Think of it as a **firewall for Pods**.

> NetworkPolicy requires a CNI plugin that supports it (Calico, Cilium, Weave, Canal). Flannel alone does NOT support NetworkPolicy.

### 11.1 Default Behavior

- Without NetworkPolicy: all Pods can talk to all Pods (open by default)
- With NetworkPolicy: traffic matching the policy is allowed; everything else is denied

### 11.2 Deny All (Default Deny)

```yaml
# Deny all ingress to pods in this namespace
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
  namespace: production
spec:
  podSelector: {}             # applies to ALL pods in namespace
  policyTypes:
  - Ingress                   # block all incoming traffic

---
# Deny all egress too
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
  namespace: production
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
```

### 11.3 Allow Specific Traffic

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-to-backend
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: backend             # this policy applies to backend pods
  
  policyTypes:
  - Ingress
  - Egress
  
  ingress:
  # Allow from pods labeled app=frontend in same namespace
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 8080
  
  # Allow from any pod in namespace "monitoring"
  - from:
    - namespaceSelector:
        matchLabels:
          name: monitoring
    ports:
    - protocol: TCP
      port: 9090
  
  egress:
  # Allow backend to reach database
  - to:
    - podSelector:
        matchLabels:
          app: postgres
    ports:
    - protocol: TCP
      port: 5432
  
  # Allow DNS (always needed!)
  - to:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: kube-system
    ports:
    - protocol: UDP
      port: 53
    - protocol: TCP
      port: 53
```

### 11.4 Combined Pod + Namespace Selector

```yaml
# AND logic: pod must be in the namespace AND match pod selector
- from:
  - namespaceSelector:
      matchLabels:
        env: production
    podSelector:
      matchLabels:
        app: frontend
```

```yaml
# OR logic: separate list items
- from:
  - namespaceSelector:
      matchLabels:
        env: production
  - podSelector:
      matchLabels:
        app: frontend
```

### 11.5 Allow All Traffic

```yaml
# Allow all ingress
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  ingress:
  - {}                    # empty rule = allow all

# Allow all egress
  egress:
  - {}
```

---

## 12. Service Mesh (Brief Overview)

For **advanced traffic management** beyond what Kubernetes provides natively:

| Feature | Kubernetes Native | Service Mesh (Istio/Linkerd) |
|---------|-----------------|------------------------------|
| Load balancing | Round-robin | Weighted, circuit breaking |
| TLS | Manual secrets | mTLS automatically |
| Traffic shaping | No | Canary, A/B testing |
| Observability | Basic | Distributed tracing, metrics |
| Retries | No | Configurable |

**Popular Service Meshes:**
- **Istio** – most feature-rich, complex
- **Linkerd** – lightweight, easier to operate
- **Consul Connect** – HashiCorp's service mesh

---

## 13. Common Networking Debugging

```bash
# Test DNS resolution
kubectl run test --image=busybox --rm -it --restart=Never -- nslookup my-svc

# Test connectivity between pods
kubectl exec pod-a -- curl http://my-svc:80
kubectl exec pod-a -- nc -zv my-svc 80

# Check endpoints (are pods selected?)
kubectl get endpoints my-svc
kubectl describe endpoints my-svc

# Check if service is reachable from a node
kubectl get svc my-svc                   # get ClusterIP
# from a node: curl http://<cluster-ip>

# Check CNI/kube-proxy
kubectl get pods -n kube-system | grep -E 'kube-proxy|flannel|calico|cilium'

# Check NetworkPolicy is not blocking
kubectl get networkpolicies -A
kubectl describe networkpolicy my-policy

# Sniff traffic in a pod (if tcpdump available)
kubectl exec my-pod -- tcpdump -i any -n port 80

# Run netshoot for advanced debugging
kubectl run netshoot --image=nicolaka/netshoot --rm -it --restart=Never -- bash
```
