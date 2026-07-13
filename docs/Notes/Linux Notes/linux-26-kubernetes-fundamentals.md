# Linux 26 – Kubernetes Fundamentals & Container Orchestration

## 0. Goal of This Note

- Understand Kubernetes architecture and components
- Master kubectl command-line tool
- Deploy and manage applications in Kubernetes
- Work with Pods, Deployments, Services, ConfigMaps, and Secrets
- Implement basic troubleshooting and monitoring
- Understand namespaces and resource management

---

## 1. Kubernetes Overview

### 1.1 What is Kubernetes?

**Kubernetes** (K8s) is an open-source container orchestration platform that automates deployment, scaling, and management of containerized applications.

**Key features:**
- **Automated deployment and rollback**
- **Service discovery and load balancing**
- **Storage orchestration**
- **Self-healing** (restart failed containers)
- **Horizontal scaling**
- **Secret and configuration management**

**Use cases:**
- Microservices architecture
- CI/CD pipelines
- Multi-cloud deployments
- Auto-scaling applications
- High-availability systems

### 1.2 Kubernetes Architecture

```
┌─────────────────────────────────────────────────────────┐
│                   CONTROL PLANE                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │  API Server  │  │  Scheduler   │  │  Controller  │  │
│  │              │  │              │  │   Manager    │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
│  ┌──────────────────────────────────────────────────┐  │
│  │              etcd (key-value store)               │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
┌───────▼────────┐  ┌───────▼────────┐  ┌───────▼────────┐
│   WORKER NODE  │  │   WORKER NODE  │  │   WORKER NODE  │
│ ┌────────────┐ │  │ ┌────────────┐ │  │ ┌────────────┐ │
│ │  kubelet   │ │  │ │  kubelet   │ │  │ │  kubelet   │ │
│ └────────────┘ │  │ └────────────┘ │  │ └────────────┘ │
│ ┌────────────┐ │  │ ┌────────────┐ │  │ ┌────────────┐ │
│ │ kube-proxy │ │  │ │ kube-proxy │ │  │ │ kube-proxy │ │
│ └────────────┘ │  │ └────────────┘ │  │ └────────────┘ │
│ ┌────────────┐ │  │ ┌────────────┐ │  │ ┌────────────┐ │
│ │Container   │ │  │ │Container   │ │  │ │Container   │ │
│ │Runtime     │ │  │ │Runtime     │ │  │ │Runtime     │ │
│ └────────────┘ │  │ └────────────┘ │  │ └────────────┘ │
│  PODs          │  │  PODs          │  │  PODs          │
└────────────────┘  └────────────────┘  └────────────────┘
```

**Control Plane Components:**
- **API Server**: Central management interface, exposes Kubernetes API
- **etcd**: Distributed key-value store for cluster data
- **Scheduler**: Assigns Pods to nodes
- **Controller Manager**: Runs controller processes (ReplicaSet, Deployment, etc.)
- **Cloud Controller Manager**: Interacts with cloud providers (optional)

**Worker Node Components:**
- **kubelet**: Agent that ensures containers are running in Pods
- **kube-proxy**: Network proxy for service discovery
- **Container Runtime**: Docker, containerd, CRI-O

---

## 2. Kubernetes Installation

### 2.1 Minikube (Local Development)

**Minikube** runs a single-node Kubernetes cluster locally.

```bash
# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Verify kubectl
kubectl version --client

# Install minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Start minikube
minikube start

# Check status
minikube status

# Access dashboard
minikube dashboard

# Stop minikube
minikube stop

# Delete cluster
minikube delete
```

### 2.2 kubeadm (Production Cluster)

**On all nodes (master + workers):**
```bash
# Disable swap
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

# Install container runtime (containerd)
sudo apt update
sudo apt install -y containerd

# Configure containerd
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd

# Install kubeadm, kubelet, kubectl
sudo apt install -y apt-transport-https ca-certificates curl
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt update
sudo apt install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# Enable kubelet
sudo systemctl enable kubelet
```

**On master node only:**
```bash
# Initialize cluster
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

# Set up kubectl for current user
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install Pod network (Flannel)
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

# Get join command for workers
kubeadm token create --print-join-command
```

**On worker nodes:**
```bash
# Run the join command from master
sudo kubeadm join <master-ip>:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>
```

### 2.3 kubectl Configuration

```bash
# Check kubectl config
kubectl config view

# Get current context
kubectl config current-context

# List contexts
kubectl config get-contexts

# Switch context
kubectl config use-context minikube

# Set namespace
kubectl config set-context --current --namespace=mynamespace
```

---

## 3. kubectl Core Commands

### 3.1 Basic Commands

```bash
# Cluster info
kubectl cluster-info
kubectl get nodes
kubectl get componentstatuses

# Version
kubectl version
kubectl version --short

# Help
kubectl --help
kubectl get --help
kubectl create --help
```

### 3.2 Working with Resources

**Get resources:**
```bash
# List pods
kubectl get pods
kubectl get pods -o wide                    # more details
kubectl get pods -A                         # all namespaces
kubectl get pods -n kube-system             # specific namespace

# List all resources
kubectl get all
kubectl get all -A

# List specific resources
kubectl get deployments
kubectl get services
kubectl get nodes
kubectl get namespaces
kubectl get configmaps
kubectl get secrets
kubectl get persistentvolumes
kubectl get persistentvolumeclaims

# Watch resources
kubectl get pods --watch
kubectl get pods -w

# Output formats
kubectl get pods -o yaml
kubectl get pods -o json
kubectl get pods -o wide
kubectl get pods -o name
```

**Describe resources:**
```bash
# Detailed information
kubectl describe pod mypod
kubectl describe deployment mydeployment
kubectl describe service myservice
kubectl describe node node1

# Get YAML definition
kubectl get pod mypod -o yaml
kubectl get deployment mydeployment -o yaml
```

**Create resources:**
```bash
# From YAML file
kubectl apply -f pod.yaml
kubectl apply -f deployment.yaml
kubectl create -f service.yaml

# From directory
kubectl apply -f ./manifests/

# From URL
kubectl apply -f https://example.com/manifest.yaml

# Create from command line
kubectl run nginx --image=nginx
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=NodePort
```

**Delete resources:**
```bash
# Delete specific resource
kubectl delete pod mypod
kubectl delete deployment mydeployment
kubectl delete service myservice

# Delete from file
kubectl delete -f pod.yaml

# Delete all pods
kubectl delete pods --all

# Delete all resources
kubectl delete all --all

# Force delete (immediate)
kubectl delete pod mypod --force --grace-period=0
```

**Edit resources:**
```bash
# Edit in default editor
kubectl edit pod mypod
kubectl edit deployment mydeployment

# Replace resource
kubectl replace -f pod.yaml
kubectl replace --force -f pod.yaml        # delete and recreate
```

### 3.3 Logs and Debugging

```bash
# View logs
kubectl logs mypod
kubectl logs mypod -c container-name        # specific container
kubectl logs mypod -f                       # follow logs
kubectl logs mypod --tail=100               # last 100 lines
kubectl logs mypod --since=1h               # last hour
kubectl logs mypod --previous               # previous instance (after crash)

# Logs from deployment
kubectl logs deployment/mydeployment

# Execute commands in container
kubectl exec mypod -- ls /
kubectl exec mypod -- env
kubectl exec -it mypod -- /bin/bash         # interactive shell
kubectl exec -it mypod -c container-name -- /bin/sh

# Copy files
kubectl cp mypod:/path/to/file /local/path
kubectl cp /local/file mypod:/path/to/file

# Port forwarding
kubectl port-forward mypod 8080:80
kubectl port-forward service/myservice 8080:80

# Top (resource usage)
kubectl top nodes
kubectl top pods
kubectl top pod mypod

# Events
kubectl get events
kubectl get events --sort-by='.lastTimestamp'
kubectl get events --field-selector involvedObject.name=mypod
```

---

## 4. Kubernetes Objects

### 4.1 Pods

**Pod** is the smallest deployable unit (one or more containers).

**Simple Pod YAML:**
```yaml
# pod-nginx.yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: nginx
spec:
  containers:
  - name: nginx
    image: nginx:1.21
    ports:
    - containerPort: 80
```

```bash
# Create pod
kubectl apply -f pod-nginx.yaml

# Get pods
kubectl get pods

# Describe pod
kubectl describe pod nginx-pod

# Logs
kubectl logs nginx-pod

# Shell access
kubectl exec -it nginx-pod -- /bin/bash

# Delete pod
kubectl delete pod nginx-pod
```

**Multi-container Pod:**
```yaml
# pod-multi.yaml
apiVersion: v1
kind: Pod
metadata:
  name: multi-container-pod
spec:
  containers:
  - name: nginx
    image: nginx:1.21
    ports:
    - containerPort: 80
  - name: sidecar
    image: busybox
    command: ['sh', '-c', 'while true; do echo $(date) >> /var/log/app.log; sleep 5; done']
    volumeMounts:
    - name: logs
      mountPath: /var/log
  volumes:
  - name: logs
    emptyDir: {}
```

### 4.2 Deployments

**Deployment** manages ReplicaSets and provides declarative updates.

```yaml
# deployment-nginx.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - containerPort: 80
```

```bash
# Create deployment
kubectl apply -f deployment-nginx.yaml

# Get deployments
kubectl get deployments
kubectl get deploy

# Get ReplicaSets
kubectl get replicasets
kubectl get rs

# Get pods from deployment
kubectl get pods -l app=nginx

# Scale deployment
kubectl scale deployment nginx-deployment --replicas=5

# Update image (rolling update)
kubectl set image deployment/nginx-deployment nginx=nginx:1.22

# Check rollout status
kubectl rollout status deployment/nginx-deployment

# Rollout history
kubectl rollout history deployment/nginx-deployment

# Rollback to previous version
kubectl rollout undo deployment/nginx-deployment

# Rollback to specific revision
kubectl rollout undo deployment/nginx-deployment --to-revision=2

# Pause/Resume rollout
kubectl rollout pause deployment/nginx-deployment
kubectl rollout resume deployment/nginx-deployment

# Restart deployment
kubectl rollout restart deployment/nginx-deployment
```

**Deployment strategies:**
```yaml
spec:
  strategy:
    type: RollingUpdate              # or Recreate
    rollingUpdate:
      maxSurge: 1                    # max new pods during update
      maxUnavailable: 1              # max unavailable during update
```

### 4.3 Services

**Service** provides stable network endpoint for Pods.

**ClusterIP Service (internal):**
```yaml
# service-nginx-clusterip.yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  type: ClusterIP                    # default type
  selector:
    app: nginx
  ports:
  - port: 80                         # service port
    targetPort: 80                   # container port
```

**NodePort Service (external access):**
```yaml
# service-nginx-nodeport.yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-nodeport
spec:
  type: NodePort
  selector:
    app: nginx
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080                  # 30000-32767 range
```

**LoadBalancer Service (cloud):**
```yaml
# service-nginx-lb.yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-loadbalancer
spec:
  type: LoadBalancer
  selector:
    app: nginx
  ports:
  - port: 80
    targetPort: 80
```

```bash
# Create service
kubectl apply -f service-nginx.yaml

# Get services
kubectl get services
kubectl get svc

# Describe service
kubectl describe service nginx-service

# Get service endpoints
kubectl get endpoints nginx-service

# Access service (from within cluster)
kubectl run test --rm -it --image=busybox -- wget -O- http://nginx-service

# Access NodePort service
# http://<node-ip>:30080

# Expose deployment as service
kubectl expose deployment nginx-deployment --port=80 --type=NodePort
```

### 4.4 ConfigMaps

**ConfigMap** stores configuration data as key-value pairs.

```yaml
# configmap-app.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  database_url: "mysql://db.example.com:3306"
  log_level: "info"
  app.properties: |
    property1=value1
    property2=value2
```

```bash
# Create from file
kubectl create configmap app-config --from-file=config.txt

# Create from literal
kubectl create configmap app-config --from-literal=key1=value1 --from-literal=key2=value2

# Create from YAML
kubectl apply -f configmap-app.yaml

# Get ConfigMaps
kubectl get configmaps
kubectl get cm

# Describe ConfigMap
kubectl describe configmap app-config

# View data
kubectl get configmap app-config -o yaml
```

**Use ConfigMap in Pod:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
spec:
  containers:
  - name: app
    image: myapp:1.0
    env:
    - name: DATABASE_URL
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: database_url
    volumeMounts:
    - name: config-volume
      mountPath: /etc/config
  volumes:
  - name: config-volume
    configMap:
      name: app-config
```

### 4.5 Secrets

**Secret** stores sensitive data (passwords, tokens, keys).

```bash
# Create secret from literal
kubectl create secret generic db-secret \
  --from-literal=username=admin \
  --from-literal=password=SecurePass123!

# Create secret from file
kubectl create secret generic ssh-key --from-file=ssh-privatekey=~/.ssh/id_rsa

# Create TLS secret
kubectl create secret tls tls-secret \
  --cert=path/to/cert.pem \
  --key=path/to/key.pem

# Get secrets
kubectl get secrets

# Describe secret
kubectl describe secret db-secret

# View secret (base64 encoded)
kubectl get secret db-secret -o yaml

# Decode secret
kubectl get secret db-secret -o jsonpath='{.data.password}' | base64 --decode
```

**Secret YAML:**
```yaml
# secret-db.yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-secret
type: Opaque
data:
  username: YWRtaW4=                 # base64 encoded "admin"
  password: U2VjdXJlUGFzczEyMyE=     # base64 encoded "SecurePass123!"
```

**Use Secret in Pod:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
spec:
  containers:
  - name: app
    image: myapp:1.0
    env:
    - name: DB_USERNAME
      valueFrom:
        secretKeyRef:
          name: db-secret
          key: username
    - name: DB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: db-secret
          key: password
```

---

## 5. Namespaces

**Namespace** provides virtual clusters within a physical cluster.

```bash
# List namespaces
kubectl get namespaces
kubectl get ns

# Create namespace
kubectl create namespace dev
kubectl create namespace prod

# Create from YAML
kubectl apply -f - <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: staging
EOF

# Delete namespace
kubectl delete namespace dev

# Set default namespace
kubectl config set-context --current --namespace=dev

# Get resources in namespace
kubectl get pods -n dev
kubectl get all -n dev

# Get resources in all namespaces
kubectl get pods -A
kubectl get pods --all-namespaces
```

**Create resources in namespace:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mypod
  namespace: dev              # specify namespace
spec:
  containers:
  - name: nginx
    image: nginx
```

```bash
# Or specify namespace in command
kubectl apply -f pod.yaml -n dev
kubectl run nginx --image=nginx -n dev
```

---

## 6. Resource Management

### 6.1 Resource Requests and Limits

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: resource-demo
spec:
  containers:
  - name: app
    image: nginx
    resources:
      requests:                      # minimum guaranteed
        memory: "64Mi"
        cpu: "250m"                  # 0.25 CPU
      limits:                        # maximum allowed
        memory: "128Mi"
        cpu: "500m"                  # 0.5 CPU
```

**CPU units:**
- 1 CPU = 1000m (millicores)
- 100m = 0.1 CPU
- 500m = 0.5 CPU

**Memory units:**
- Ki (Kibibyte) = 1024 bytes
- Mi (Mebibyte) = 1024 Ki
- Gi (Gibibyte) = 1024 Mi

### 6.2 Labels and Selectors

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mypod
  labels:
    app: nginx
    env: production
    tier: frontend
spec:
  containers:
  - name: nginx
    image: nginx
```

```bash
# Filter by label
kubectl get pods -l app=nginx
kubectl get pods -l env=production
kubectl get pods -l 'env in (dev,staging)'
kubectl get pods -l app=nginx,env=production

# Add label
kubectl label pod mypod version=v1

# Update label
kubectl label pod mypod env=staging --overwrite

# Remove label
kubectl label pod mypod env-

# Show labels
kubectl get pods --show-labels
```

---

## 7. Troubleshooting

### 7.1 Common Issues

**Pod stuck in Pending:**
```bash
kubectl describe pod mypod
# Check:
# - Insufficient resources
# - Node selector not matching
# - PersistentVolumeClaim not bound
```

**Pod in CrashLoopBackOff:**
```bash
kubectl logs mypod
kubectl logs mypod --previous
kubectl describe pod mypod
# Check:
# - Application errors
# - Missing configuration
# - Failed liveness/readiness probes
```

**ImagePullBackOff:**
```bash
kubectl describe pod mypod
# Check:
# - Image name typo
# - Private registry auth
# - Network issues
```

**Service not accessible:**
```bash
kubectl get endpoints myservice
kubectl describe service myservice
# Check:
# - Selector matches pod labels
# - Pod is running
# - Port configuration
```

### 7.2 Debugging Commands

```bash
# Get events
kubectl get events --sort-by='.lastTimestamp'

# Check node status
kubectl get nodes
kubectl describe node node1

# Check resource usage
kubectl top nodes
kubectl top pods

# Run debug pod
kubectl run debug --rm -it --image=busybox -- /bin/sh

# Test DNS
kubectl run test --rm -it --image=busybox -- nslookup kubernetes.default

# Check cluster components
kubectl get componentstatuses
kubectl get pods -n kube-system
```

---

## 8. Best Practices

### 8.1 Security Best Practices

```yaml
✓ Use specific image tags (not :latest)
✓ Run containers as non-root
✓ Use read-only root filesystem when possible
✓ Set resource limits
✓ Use NetworkPolicies
✓ Use RBAC for access control
✓ Scan images for vulnerabilities
✓ Use Secrets (not ConfigMaps) for sensitive data
✓ Enable Pod Security Policies
✓ Regularly update Kubernetes
```

**Example secure Pod:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secure-pod
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
  containers:
  - name: app
    image: myapp:1.2.3                # specific version
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      capabilities:
        drop:
        - ALL
    resources:
      limits:
        memory: "128Mi"
        cpu: "500m"
```

### 8.2 Deployment Best Practices

```yaml
✓ Use Deployments (not bare Pods)
✓ Set replica count ≥ 2 for high availability
✓ Define liveness and readiness probes
✓ Use rolling updates
✓ Set appropriate resource requests/limits
✓ Use labels consistently
✓ Version your manifests in Git
✓ Use namespaces for isolation
✓ Implement monitoring and logging
✓ Test in staging before production
```

---

## 9. Practice Exercises

1. **Basic Deployment:**
   - Create deployment with nginx (3 replicas)
   - Expose as NodePort service
   - Scale to 5 replicas
   - Update nginx version
   - Rollback update

2. **ConfigMaps and Secrets:**
   - Create ConfigMap with application config
   - Create Secret with database credentials
   - Deploy app using both
   - Verify environment variables

3. **Troubleshooting:**
   - Deploy intentionally broken app
   - Diagnose using logs and describe
   - Fix the issue
   - Verify working

4. **Multi-tier Application:**
   - Deploy frontend (nginx)
   - Deploy backend (API)
   - Deploy database (MySQL)
   - Create services for each tier
   - Verify communication

5. **Namespaces:**
   - Create dev, staging, prod namespaces
   - Deploy same app to each
   - Use different resource limits
   - Switch between namespaces

---

## 10. Quick Reference

**Essential kubectl commands:**
```bash
kubectl get pods                     # list pods
kubectl describe pod <name>          # pod details
kubectl logs <pod>                   # view logs
kubectl exec -it <pod> -- /bin/bash  # shell access
kubectl apply -f <file>              # create/update
kubectl delete -f <file>             # delete
kubectl get all                      # all resources
kubectl get events                   # cluster events
kubectl top nodes                    # resource usage
```

**Common shortcuts:**
```bash
po  = pods
deploy = deployments
svc = services
ns  = namespaces
cm  = configmaps
pv  = persistentvolumes
pvc = persistentvolumeclaims
```

---

Next: **Linux 27 – Ansible Automation** for configuration management and infrastructure as code.
