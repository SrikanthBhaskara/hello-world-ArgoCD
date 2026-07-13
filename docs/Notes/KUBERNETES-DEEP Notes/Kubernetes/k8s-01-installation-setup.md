# Kubernetes 01 – Installation & Setup

## 0. Goal of This Note

- Install and configure `kubectl`
- Set up a local Kubernetes cluster (minikube, kind)
- Understand kubeadm for production clusters
- Manage kubeconfig and multiple contexts

---

## 1. Installing kubectl

`kubectl` is the Kubernetes command-line tool. Install it first regardless of which cluster type you use.

### 1.1 Linux

```bash
# Download latest stable release
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Install
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Verify
kubectl version --client
```

### 1.2 macOS

```bash
# With Homebrew
brew install kubectl

# Verify
kubectl version --client
```

### 1.3 Windows

```powershell
# With Chocolatey
choco install kubernetes-cli

# With winget
winget install Kubernetes.kubectl

# Verify
kubectl version --client
```

### 1.4 Enable Shell Autocompletion

```bash
# Bash
echo 'source <(kubectl completion bash)' >> ~/.bashrc
source ~/.bashrc

# Zsh
echo 'source <(kubectl completion zsh)' >> ~/.zshrc
source ~/.zshrc

# Create alias with completion
echo 'alias k=kubectl' >> ~/.bashrc
echo 'complete -o default -F __start_kubectl k' >> ~/.bashrc
```

---

## 2. minikube (Local Development)

**Best for**: Learning Kubernetes, local development and testing.

### 2.1 Install minikube

```bash
# Linux
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# macOS
brew install minikube

# Windows
winget install Kubernetes.minikube
# or with Chocolatey
choco install minikube
```

### 2.2 Prerequisites

minikube needs a driver to create the VM or container:

| Driver | OS | Notes |
|--------|----|-------|
| `docker` | All | Recommended – no VM overhead |
| `virtualbox` | All | Requires VirtualBox installed |
| `hyperv` | Windows | Built-in, requires Hyper-V enabled |
| `podman` | Linux/macOS | Rootless option |
| `kvm2` | Linux | Hardware virtualization |

```bash
# Check available drivers
minikube start --help | grep driver

# Use Docker driver (recommended)
minikube start --driver=docker
```

### 2.3 Basic minikube Usage

```bash
# Start cluster (default: 2 CPUs, 2GB RAM)
minikube start

# Start with more resources
minikube start --cpus=4 --memory=4096 --disk-size=20g

# Start specific Kubernetes version
minikube start --kubernetes-version=v1.28.0

# Check status
minikube status

# Open Kubernetes dashboard
minikube dashboard

# Pause cluster (saves resources)
minikube pause

# Unpause
minikube unpause

# Stop cluster
minikube stop

# Delete cluster
minikube delete

# Delete all clusters
minikube delete --all
```

### 2.4 minikube Add-ons

```bash
# List available add-ons
minikube addons list

# Enable ingress (nginx ingress controller)
minikube addons enable ingress

# Enable metrics-server
minikube addons enable metrics-server

# Enable dashboard
minikube addons enable dashboard

# Enable registry (local Docker registry)
minikube addons enable registry

# Access a service via minikube
minikube service myservice --url

# Get minikube IP
minikube ip
```

### 2.5 Multi-Node minikube

```bash
# Start a 3-node cluster
minikube start --nodes=3

# List nodes
kubectl get nodes

# Add a node to existing cluster
minikube node add

# Delete a node
minikube node delete minikube-m03
```

---

## 3. kind (Kubernetes in Docker)

**Best for**: CI/CD pipelines, testing multi-node setups locally.

### 3.1 Install kind

```bash
# Linux/macOS
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.22.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# macOS with Homebrew
brew install kind

# Windows
winget install Kubernetes.kind
```

### 3.2 Basic kind Usage

```bash
# Create a cluster
kind create cluster

# Create with a name
kind create cluster --name my-cluster

# List clusters
kind get clusters

# Delete cluster
kind delete cluster --name my-cluster

# Get kubeconfig for a cluster
kind get kubeconfig --name my-cluster
```

### 3.3 kind Multi-Node Config

```yaml
# kind-config.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
- role: worker
- role: worker
```

```bash
# Create cluster from config
kind create cluster --config kind-config.yaml

# Load local Docker image into kind
kind load docker-image my-image:latest
```

### 3.4 kind with Ingress

```yaml
# kind-ingress-config.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
```

---

## 4. k3s (Lightweight Production)

**Best for**: Edge computing, IoT, resource-constrained environments, simple production.

```bash
# Install k3s (single command!)
curl -sfL https://get.k3s.io | sh -

# With specific options
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable traefik" sh -

# Check status
sudo systemctl status k3s

# Use kubectl (k3s ships its own)
sudo k3s kubectl get nodes

# Or use your own kubectl (copy kubeconfig)
sudo cat /etc/rancher/k3s/k3s.yaml > ~/.kube/config
kubectl get nodes

# Install k3s agent (worker node)
curl -sfL https://get.k3s.io | K3S_URL=https://<master-ip>:6443 K3S_TOKEN=<token> sh -

# Get node token (on master)
sudo cat /var/lib/rancher/k3s/server/node-token

# Uninstall k3s
/usr/local/bin/k3s-uninstall.sh
```

---

## 5. kubeadm (Production Cluster)

**Best for**: Self-managed production clusters on bare metal or VMs.

### 5.1 System Requirements

- OS: Ubuntu 20.04+, Debian 11+, CentOS 7+, RHEL 8+
- RAM: 2 GB minimum per node
- CPU: 2+ cores on master, 1+ on workers
- Swap disabled
- Unique hostname, MAC, product_uuid per node
- Ports open (see below)

**Required ports:**

| Component | Port | Protocol |
|-----------|------|---------|
| API Server | 6443 | TCP |
| etcd | 2379-2380 | TCP |
| Scheduler | 10251 | TCP |
| Controller Manager | 10252 | TCP |
| kubelet API | 10250 | TCP |
| NodePort range | 30000-32767 | TCP |

### 5.2 Install on All Nodes

```bash
# 1. Disable swap (required by kubelet)
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# 2. Enable networking modules
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# 3. Set sysctl params for networking
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system

# 4. Install containerd
sudo apt update
sudo apt install -y containerd
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
# Set SystemdCgroup = true
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd

# 5. Install kubeadm, kubelet, kubectl
sudo apt install -y apt-transport-https ca-certificates curl gpg
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt update
sudo apt install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
sudo systemctl enable kubelet
```

### 5.3 Initialize the Master Node

```bash
# Initialize control plane
sudo kubeadm init \
  --pod-network-cidr=10.244.0.0/16 \
  --apiserver-advertise-address=<master-ip>

# Set up kubeconfig for regular user
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install Pod network (CNI) – Flannel example
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

# Alternative CNI – Calico
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/calico.yaml

# Verify control plane is ready
kubectl get nodes
kubectl get pods -n kube-system
```

### 5.4 Join Worker Nodes

```bash
# On master – generate join command
kubeadm token create --print-join-command

# On each worker – run the join command (output from above)
sudo kubeadm join <master-ip>:6443 \
  --token <token> \
  --discovery-token-ca-cert-hash sha256:<hash>

# Verify from master
kubectl get nodes
```

### 5.5 Tear Down / Reset

```bash
# On a node (drain first from master)
kubectl drain <node-name> --delete-emptydir-data --force --ignore-daemonsets
kubectl delete node <node-name>

# On the node itself
sudo kubeadm reset
sudo iptables -F && sudo iptables -t nat -F && sudo iptables -t mangle -F && sudo iptables -X
sudo ipvsadm -C   # if using IPVS
rm -rf ~/.kube
```

---

## 6. kubectl Configuration (kubeconfig)

### 6.1 kubeconfig Structure

```yaml
# ~/.kube/config
apiVersion: v1
kind: Config
current-context: my-cluster          # active context

clusters:
- name: my-cluster
  cluster:
    server: https://192.168.1.100:6443
    certificate-authority-data: <base64>

users:
- name: admin
  user:
    client-certificate-data: <base64>
    client-key-data: <base64>

contexts:
- name: my-cluster
  context:
    cluster: my-cluster
    user: admin
    namespace: default                # optional default namespace
```

### 6.2 Managing Contexts

```bash
# View full config
kubectl config view
kubectl config view --minify             # only active context

# List all contexts
kubectl config get-contexts

# Get current context
kubectl config current-context

# Switch context
kubectl config use-context my-cluster

# Create/update a context
kubectl config set-context staging \
  --cluster=my-cluster \
  --user=admin \
  --namespace=staging

# Delete a context
kubectl config delete-context old-cluster

# Rename a context
kubectl config rename-context old-name new-name

# Set default namespace for current context
kubectl config set-context --current --namespace=my-namespace
```

### 6.3 Multiple kubeconfig Files

```bash
# Merge multiple config files
export KUBECONFIG=~/.kube/config:~/.kube/cluster2-config
kubectl config view --merge --flatten > ~/.kube/merged-config

# Use a specific kubeconfig file
kubectl --kubeconfig=/path/to/other/config get pods

# Set env var
export KUBECONFIG=/path/to/config
```

### 6.4 kubectx / kubens (Productivity Tools)

```bash
# Install kubectx + kubens
brew install kubectx                    # macOS
sudo apt install kubectx               # Ubuntu (may need snap)
# or via krew: kubectl krew install ctx ns

# kubectx – switch contexts fast
kubectx                                 # list all contexts
kubectx my-cluster                     # switch to context
kubectx -                              # switch to previous

# kubens – switch namespaces fast
kubens                                  # list all namespaces
kubens kube-system                     # switch to namespace
kubens -                               # switch to previous
```

---

## 7. Useful Cluster Setup Verification

```bash
# Check all nodes are Ready
kubectl get nodes -o wide

# Check system Pods are running
kubectl get pods -n kube-system

# Check cluster info
kubectl cluster-info

# Check component status (deprecated in newer versions but still works)
kubectl get componentstatuses

# Check API server is reachable
kubectl version

# Test deploying a simple app
kubectl create deployment test-nginx --image=nginx
kubectl get pods
kubectl expose deployment test-nginx --port=80 --type=NodePort
kubectl get services
minikube service test-nginx              # open in browser (minikube only)

# Clean up test
kubectl delete deployment test-nginx
kubectl delete service test-nginx
```

---

## 8. k9s – Terminal UI for Kubernetes

**k9s** is a terminal-based UI to interact with Kubernetes clusters visually.

```bash
# Install
brew install k9s                        # macOS
# Linux – download from https://github.com/derailed/k9s/releases

# Launch
k9s

# Key shortcuts inside k9s
# :pods         → navigate to pods
# :deployments  → navigate to deployments
# /             → filter/search
# d             → describe selected resource
# l             → view logs
# s             → shell into container
# ctrl+d        → delete resource
# ?             → help/keybindings
# q             → quit / go back
```
