# Kubernetes Learning Materials – Complete Reference Guide

**Created**: April 2026  
**Purpose**: Comprehensive Kubernetes knowledge base from fundamentals to production-grade operations

---

## What's Included

This folder contains a complete Kubernetes learning path with **12 detailed reference files** covering everything from installation to advanced production topics.

---

## File Index

| # | File | Topics |
|---|------|--------|
| 00 | [k8s-00-overview.md](k8s-00-overview.md) | Architecture, components, concepts, terminology |
| 01 | [k8s-01-installation-setup.md](k8s-01-installation-setup.md) | minikube, kubeadm, kind, k3s, kubectl config |
| 02 | [k8s-02-kubectl-commands.md](k8s-02-kubectl-commands.md) | Complete kubectl reference + cheat sheet |
| 03 | [k8s-03-pods-workloads.md](k8s-03-pods-workloads.md) | Pods, Deployments, ReplicaSets, DaemonSets, StatefulSets, Jobs |
| 04 | [k8s-04-services-networking.md](k8s-04-services-networking.md) | Services, Ingress, DNS, NetworkPolicy, CNI |
| 05 | [k8s-05-storage.md](k8s-05-storage.md) | Volumes, PV, PVC, StorageClass, CSI |
| 06 | [k8s-06-config-secrets.md](k8s-06-config-secrets.md) | ConfigMaps, Secrets, environment variables |
| 07 | [k8s-07-rbac-security.md](k8s-07-rbac-security.md) | RBAC, ServiceAccounts, Security Contexts, Pod Security |
| 08 | [k8s-08-helm.md](k8s-08-helm.md) | Helm charts, repositories, templating, lifecycle |
| 09 | [k8s-09-monitoring-logging.md](k8s-09-monitoring-logging.md) | Metrics Server, Prometheus, Grafana, logging stack |
| 10 | [k8s-10-advanced-topics.md](k8s-10-advanced-topics.md) | Operators, CRDs, HPA, VPA, cluster autoscaler, GitOps |
| 11 | [k8s-11-interview-prep.md](k8s-11-interview-prep.md) | 50 interview questions, CKA/CKAD tips |

---

## Learning Paths

### Beginner (New to Kubernetes)
1. [k8s-00-overview.md](k8s-00-overview.md) – Understand what Kubernetes is
2. [k8s-01-installation-setup.md](k8s-01-installation-setup.md) – Set up a local cluster with minikube
3. [k8s-02-kubectl-commands.md](k8s-02-kubectl-commands.md) – Learn to interact with the cluster
4. [k8s-03-pods-workloads.md](k8s-03-pods-workloads.md) – Deploy your first app

### Intermediate (Deploy Real Apps)
5. [k8s-04-services-networking.md](k8s-04-services-networking.md) – Expose and connect services
6. [k8s-05-storage.md](k8s-05-storage.md) – Persist data across restarts
7. [k8s-06-config-secrets.md](k8s-06-config-secrets.md) – Manage configuration and secrets
8. [k8s-08-helm.md](k8s-08-helm.md) – Package and deploy with Helm

### Advanced (Production-Ready)
9. [k8s-07-rbac-security.md](k8s-07-rbac-security.md) – Lock down your cluster
10. [k8s-09-monitoring-logging.md](k8s-09-monitoring-logging.md) – Observe and alert
11. [k8s-10-advanced-topics.md](k8s-10-advanced-topics.md) – Scale and extend Kubernetes

### Interview / Certification Prep
- [k8s-11-interview-prep.md](k8s-11-interview-prep.md) – Questions + CKA/CKAD exam tips

---

## Key Kubernetes Concepts at a Glance

```
Control Plane                     Worker Nodes
┌─────────────────────────┐       ┌────────────────────┐
│  API Server             │──────▶│  kubelet           │
│  etcd                   │       │  kube-proxy        │
│  Scheduler              │       │  Container Runtime │
│  Controller Manager     │       │  Pods              │
└─────────────────────────┘       └────────────────────┘
```

### Core Objects
| Object | Purpose |
|--------|---------|
| **Pod** | Smallest deployable unit; one or more containers |
| **Deployment** | Manages ReplicaSets; rolling updates, rollbacks |
| **Service** | Stable network endpoint for a group of Pods |
| **ConfigMap** | Non-sensitive configuration data |
| **Secret** | Sensitive data (passwords, tokens) |
| **PersistentVolume** | Cluster-level storage resource |
| **Namespace** | Virtual cluster for isolation |
| **Ingress** | HTTP/HTTPS routing rules |

---

## Prerequisites

- Basic Linux command line knowledge
- Understanding of containers and Docker
- Familiarity with YAML syntax

---

## Tools You'll Use

| Tool | Purpose |
|------|---------|
| `kubectl` | CLI to interact with Kubernetes |
| `minikube` | Local single-node cluster |
| `kind` | Kubernetes in Docker |
| `helm` | Package manager for Kubernetes |
| `k9s` | Terminal UI for Kubernetes |
| `kubectx/kubens` | Switch contexts and namespaces fast |
