# Kubernetes Study Index

Use this index to navigate all Kubernetes notes. Follow the sequence for structured learning, or jump to any topic directly.

---

## Foundations (Start Here)

- **00** – [Overview & Core Concepts](k8s-00-overview.md)
  - What is Kubernetes, why it exists, architecture, components, key terminology
- **01** – [Installation & Setup](k8s-01-installation-setup.md)
  - minikube, kubeadm, kind, k3s, kubectl installation and config
- **02** – [kubectl Command Mastery](k8s-02-kubectl-commands.md)
  - Full kubectl reference, output formats, debugging commands, cheat sheet

---

## Core Workloads

- **03** – [Pods & Workload Resources](k8s-03-pods-workloads.md)
  - Pods, init containers, multi-container patterns
  - Deployments, ReplicaSets, rolling updates, rollbacks
  - DaemonSets, StatefulSets, Jobs, CronJobs

---

## Networking & Storage

- **04** – [Services & Networking](k8s-04-services-networking.md)
  - ClusterIP, NodePort, LoadBalancer, ExternalName
  - Ingress, IngressController, TLS termination
  - DNS, NetworkPolicy, CNI plugins
- **05** – [Storage](k8s-05-storage.md)
  - Volumes (emptyDir, hostPath, configMap, secret)
  - PersistentVolumes, PersistentVolumeClaims
  - StorageClasses, dynamic provisioning, CSI drivers

---

## Configuration & Security

- **06** – [ConfigMaps & Secrets](k8s-06-config-secrets.md)
  - ConfigMaps: file-based and env-based configuration
  - Secrets: opaque, TLS, docker-registry types
  - Mounting configs as volumes vs environment variables
- **07** – [RBAC & Security](k8s-07-rbac-security.md)
  - Roles, ClusterRoles, RoleBindings
  - ServiceAccounts, token projection
  - Security Contexts, Pod Security Standards
  - Network policies, image security

---

## Operations

- **08** – [Helm Package Manager](k8s-08-helm.md)
  - Charts, repositories, values, templates
  - Install, upgrade, rollback, uninstall
  - Writing custom Helm charts
- **09** – [Monitoring & Logging](k8s-09-monitoring-logging.md)
  - Metrics Server, resource requests/limits
  - Prometheus + Grafana stack
  - Kubernetes logging architecture, ELK/EFK stack
  - Alerting and dashboards

---

## Advanced Topics

- **10** – [Advanced Topics](k8s-10-advanced-topics.md)
  - Horizontal Pod Autoscaler (HPA), Vertical Pod Autoscaler (VPA)
  - Cluster autoscaler
  - Custom Resource Definitions (CRDs), Operators
  - GitOps with ArgoCD / Flux
  - Multi-cluster management

---

## Reference & Exam Prep

- **11** – [Interview Preparation](k8s-11-interview-prep.md)
  - 50 common Kubernetes interview questions with answers
  - CKA and CKAD exam tips and domains
  - Hands-on scenario practice

---

## Quick Reference

### Essential kubectl Commands
```bash
kubectl get pods -A                        # all pods, all namespaces
kubectl describe pod <name>                # detailed pod info
kubectl logs <pod> -f                      # follow logs
kubectl exec -it <pod> -- /bin/sh         # shell into pod
kubectl apply -f manifest.yaml            # apply config
kubectl delete -f manifest.yaml           # delete from config
kubectl rollout status deployment/<name>  # check rollout
kubectl rollout undo deployment/<name>    # rollback
```

### YAML Skeleton
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
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-app
        image: nginx:1.25
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"
```

### Key API Versions
| Resource | apiVersion |
|----------|-----------|
| Pod, Deployment, ReplicaSet, DaemonSet, StatefulSet | `apps/v1` |
| Service, ConfigMap, Secret, PV, PVC, Namespace | `v1` |
| Ingress | `networking.k8s.io/v1` |
| NetworkPolicy | `networking.k8s.io/v1` |
| HorizontalPodAutoscaler | `autoscaling/v2` |
| CronJob | `batch/v1` |
| Role, RoleBinding | `rbac.authorization.k8s.io/v1` |
| CRD | `apiextensions.k8s.io/v1` |
