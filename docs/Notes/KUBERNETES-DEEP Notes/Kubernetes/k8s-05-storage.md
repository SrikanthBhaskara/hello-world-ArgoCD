# Kubernetes 05 – Storage

## 0. Goal of This Note

- Understand Kubernetes storage concepts and lifecycle
- Use ephemeral volumes for shared scratch space
- Create and manage PersistentVolumes and PersistentVolumeClaims
- Configure StorageClasses for dynamic provisioning
- Understand CSI drivers

---

## 1. Storage Concepts Overview

```
┌────────────────────────────────────────────────────────────┐
│                         POD                                 │
│  Container ──volumeMount──▶ Volume ──PVC──▶ PV ──▶ Storage │
└────────────────────────────────────────────────────────────┘

Ephemeral: emptyDir, configMap, secret, downwardAPI, projected
Persistent: PVC → PV (static or dynamic via StorageClass)
```

**Why storage is hard in Kubernetes:**
- Pods are ephemeral – container filesystem is lost when Pod dies
- Pods move between nodes – local storage doesn't follow them
- Multiple replicas may need shared or independent storage

---

## 2. Ephemeral Volumes

### 2.1 emptyDir

Temporary directory created when Pod starts. **Deleted** when Pod is removed.

```yaml
volumes:
- name: cache
  emptyDir: {}               # defaults to node disk

- name: ramdisk
  emptyDir:
    medium: Memory           # use RAM (tmpfs) – faster but counts toward memory limit
    sizeLimit: 256Mi         # optional size limit
```

**Use cases:**
- Scratch space for algorithms
- Sharing files between containers in a Pod
- Staging data for checksum/sort operations

### 2.2 hostPath

Mounts a file or directory from the **host node** into the Pod.

```yaml
volumes:
- name: host-docker
  hostPath:
    path: /var/run/docker.sock
    type: Socket                 # optional type check

- name: host-logs
  hostPath:
    path: /var/log/app
    type: DirectoryOrCreate      # create directory if it doesn't exist
```

**hostPath types:**
| Type | Behavior |
|------|---------|
| (empty) | No pre-check |
| `Directory` | Must exist as directory |
| `DirectoryOrCreate` | Created if missing |
| `File` | Must exist as file |
| `FileOrCreate` | Created if missing |
| `Socket` | Must exist as Unix socket |
| `CharDevice` | Must exist as char device |
| `BlockDevice` | Must exist as block device |

> **Security warning**: hostPath gives pods access to the host filesystem. Avoid in production unless necessary (DaemonSets for log agents, etc.).

### 2.3 configMap and secret Volumes

Mount ConfigMap/Secret data as files:

```yaml
volumes:
- name: config
  configMap:
    name: app-config
    defaultMode: 0644

- name: tls-certs
  secret:
    secretName: my-tls-secret
    defaultMode: 0400

containers:
- name: app
  volumeMounts:
  - name: config
    mountPath: /etc/app/config
    readOnly: true
  - name: tls-certs
    mountPath: /etc/ssl/certs
    readOnly: true
```

### 2.4 projected Volume

Combines multiple volume sources into one directory:

```yaml
volumes:
- name: all-config
  projected:
    sources:
    - configMap:
        name: app-config
    - secret:
        name: app-secrets
    - serviceAccountToken:
        path: token
        expirationSeconds: 3600
    - downwardAPI:
        items:
        - path: labels
          fieldRef:
            fieldPath: metadata.labels
```

### 2.5 downwardAPI

Exposes Pod metadata as files:

```yaml
volumes:
- name: pod-info
  downwardAPI:
    items:
    - path: "labels"
      fieldRef:
        fieldPath: metadata.labels
    - path: "cpu-limit"
      resourceFieldRef:
        containerName: app
        resource: limits.cpu
```

---

## 3. PersistentVolumes (PV)

A **PersistentVolume** is a piece of storage in the cluster that has been **provisioned by an admin** or **dynamically provisioned** via a StorageClass.

It is a **cluster-level resource** (not namespaced).

### 3.1 PV Spec

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: my-pv
spec:
  capacity:
    storage: 10Gi
  
  accessModes:
  - ReadWriteOnce              # see access modes below
  
  persistentVolumeReclaimPolicy: Retain   # what happens when PVC is deleted
  
  storageClassName: manual     # matches PVC's storageClassName
  
  # Volume source (choose one)
  hostPath:
    path: /data/my-pv
  
  # or NFS
  nfs:
    server: nfs-server.example.com
    path: /exports/data
  
  # or AWS EBS
  awsElasticBlockStore:
    volumeID: vol-12345
    fsType: ext4
```

### 3.2 Access Modes

| Mode | Short | Meaning |
|------|-------|---------|
| `ReadWriteOnce` | RWO | Read-write by one node at a time |
| `ReadOnlyMany` | ROX | Read-only by many nodes |
| `ReadWriteMany` | RWX | Read-write by many nodes |
| `ReadWriteOncePod` | RWOP | Read-write by one Pod (K8s 1.22+) |

> Most block storage (EBS, GCE PD) only supports RWO. NFS and Azure Files support RWX.

### 3.3 Reclaim Policies

| Policy | Behavior when PVC is deleted |
|--------|------------------------------|
| **Retain** | PV stays, admin must manually reclaim (default for manually created PVs) |
| **Delete** | PV and underlying storage deleted (default for dynamically provisioned) |
| **Recycle** | (deprecated) Basic scrub (`rm -rf /data/*`) and made available again |

### 3.4 PV Lifecycle

```
Available → Bound → Released → Available/Deleted
```

- **Available**: PV exists, not yet bound to a PVC
- **Bound**: PV is bound to a specific PVC
- **Released**: PVC was deleted, PV is not yet reclaimed
- **Failed**: Automatic reclamation failed

---

## 4. PersistentVolumeClaims (PVC)

A **PVC** is a user's **request for storage**. It is namespaced.

Kubernetes automatically matches a PVC to an available PV that satisfies its requirements.

### 4.1 PVC Spec

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
  namespace: default
spec:
  accessModes:
  - ReadWriteOnce
  
  resources:
    requests:
      storage: 5Gi             # minimum storage required
  
  storageClassName: standard   # which StorageClass to use
  
  # Optional: select a specific PV
  selector:
    matchLabels:
      release: stable
```

### 4.2 Using PVC in a Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: db-pod
spec:
  containers:
  - name: mysql
    image: mysql:8.0
    volumeMounts:
    - name: mysql-data
      mountPath: /var/lib/mysql
  
  volumes:
  - name: mysql-data
    persistentVolumeClaim:
      claimName: my-pvc         # reference the PVC
      readOnly: false
```

### 4.3 PVC Commands

```bash
# List PVCs
kubectl get pvc
kubectl get pvc -n my-namespace

# Describe a PVC
kubectl describe pvc my-pvc

# List PVs (cluster-level)
kubectl get pv
kubectl describe pv my-pv

# Check binding
kubectl get pv,pvc
```

**Example output:**
```
NAME        STATUS   VOLUME       CAPACITY   ACCESS MODES   STORAGECLASS   AGE
pvc/my-pvc  Bound    pv/my-pv     10Gi       RWO            standard       5m
```

---

## 5. StorageClasses

**StorageClass** defines a type of storage with a provisioner and parameters. Enables **dynamic provisioning** – no need to pre-create PVs.

### 5.1 StorageClass Spec

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-ssd
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"  # set as default
provisioner: kubernetes.io/aws-ebs               # provisioner plugin
parameters:
  type: gp3                   # provider-specific params
  iopsPerGB: "10"
  encrypted: "true"
reclaimPolicy: Delete         # Retain or Delete
allowVolumeExpansion: true    # allow resizing PVCs
volumeBindingMode: WaitForFirstConsumer   # or Immediate
```

### 5.2 Common Provisioners

| Provisioner | Platform |
|------------|---------|
| `kubernetes.io/aws-ebs` | AWS EBS |
| `kubernetes.io/gce-pd` | GCP Persistent Disk |
| `kubernetes.io/azure-disk` | Azure Disk |
| `kubernetes.io/azure-file` | Azure File |
| `kubernetes.io/no-provisioner` | Local (static) |
| `rancher.io/local-path` | Local path (k3s default) |
| `driver.longhorn.io` | Longhorn (distributed) |
| `nfs.csi.k8s.io` | NFS via CSI |

### 5.3 Dynamic Provisioning Flow

```
1. User creates PVC (with storageClassName: fast-ssd)
2. Kubernetes sees PVC is unbound
3. StorageClass provisioner creates volume (e.g., EBS volume)
4. PV is created automatically and bound to PVC
5. Pod can now use the PVC
```

### 5.4 Default StorageClass

```bash
# See which is default (marked with (default))
kubectl get storageclass

# Set a StorageClass as default
kubectl patch storageclass standard -p '{"metadata":{"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

# Remove default annotation
kubectl patch storageclass old-default -p '{"metadata":{"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
```

### 5.5 minikube StorageClasses

```bash
minikube addons enable default-storageclass
kubectl get storageclass
# NAME                 PROVISIONER                RECLAIMPOLICY   VOLUMEBINDINGMODE
# standard (default)   k8s.io/minikube-hostpath   Delete          Immediate
```

---

## 6. Volume Expansion (Resizing)

```yaml
# 1. StorageClass must have allowVolumeExpansion: true
spec:
  allowVolumeExpansion: true

# 2. Edit the PVC to request more storage
kubectl edit pvc my-pvc
# or
kubectl patch pvc my-pvc -p '{"spec":{"resources":{"requests":{"storage":"20Gi"}}}}'

# 3. Watch PVC until resized
kubectl get pvc my-pvc -w
```

> File system expansion may require the Pod to be restarted.

---

## 7. Volume Snapshots

Take point-in-time snapshots of volumes (requires CSI driver support):

```yaml
# VolumeSnapshot
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshot
metadata:
  name: my-snapshot
spec:
  volumeSnapshotClassName: csi-aws-vsc
  source:
    persistentVolumeClaimName: my-pvc

---
# Restore from snapshot
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: restored-pvc
spec:
  accessModes: [ReadWriteOnce]
  storageClassName: fast-ssd
  resources:
    requests:
      storage: 10Gi
  dataSource:
    name: my-snapshot
    kind: VolumeSnapshot
    apiGroup: snapshot.storage.k8s.io
```

---

## 8. CSI (Container Storage Interface)

**CSI** is the standard interface for storage vendors to write plugins without modifying Kubernetes core.

```bash
# List CSI drivers
kubectl get csidrivers

# Check CSI node info
kubectl get csinodes
```

**Popular CSI drivers:**
- `ebs.csi.aws.com` – AWS EBS
- `pd.csi.storage.gke.io` – GCP Persistent Disk
- `disk.csi.azure.com` – Azure Disk
- `file.csi.azure.com` – Azure Files
- `nfs.csi.k8s.io` – NFS
- `driver.longhorn.io` – Rancher Longhorn
- `rook-ceph.rbd.csi.ceph.com` – Ceph (via Rook)

---

## 9. StatefulSet + PVC (volumeClaimTemplates)

Each StatefulSet replica gets its own PVC automatically:

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
spec:
  replicas: 3
  serviceName: postgres
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:15
        volumeMounts:
        - name: data
          mountPath: /var/lib/postgresql/data
  
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: [ReadWriteOnce]
      storageClassName: fast-ssd
      resources:
        requests:
          storage: 20Gi
```

This creates:
- `data-postgres-0` → PVC for postgres-0
- `data-postgres-1` → PVC for postgres-1
- `data-postgres-2` → PVC for postgres-2

**These PVCs are NOT deleted when the StatefulSet is deleted** – data is preserved.

---

## 10. Storage Troubleshooting

```bash
# PVC stuck in Pending state
kubectl describe pvc my-pvc
# Look for: Events section
# Common causes:
# - No PV available that matches
# - StorageClass doesn't exist
# - Provisioner not installed/running

# Check if StorageClass exists
kubectl get storageclass

# Check provisioner pods
kubectl get pods -n kube-system | grep provisioner

# Check PV status
kubectl get pv
kubectl describe pv my-pv

# Pod stuck because of volume
kubectl describe pod my-pod
# Look for: FailedMount, FailedAttachVolume events

# Check if volume is attached to node
kubectl describe node worker-1 | grep -A 10 "Volumes"

# Force delete a stuck PVC (only if Terminating and stuck)
kubectl patch pvc my-pvc -p '{"metadata":{"finalizers":null}}'

# Force delete a stuck PV
kubectl patch pv my-pv -p '{"metadata":{"finalizers":null}}'
```

---

## 11. Storage Summary

| Volume Type | Persists Past Pod | Node-local | Shared Between Pods |
|-------------|------------------|-----------|---------------------|
| `emptyDir` | No | Yes | No (within pod only) |
| `hostPath` | Yes (on same node) | Yes | No |
| `configMap/secret` | N/A | No | Yes (via PVC or inline) |
| `PVC` (RWO) | Yes | No | No (one node at a time) |
| `PVC` (RWX) | Yes | No | Yes (NFS, Azure Files) |
| `PVC` (ROX) | Yes | No | Yes (read-only) |
