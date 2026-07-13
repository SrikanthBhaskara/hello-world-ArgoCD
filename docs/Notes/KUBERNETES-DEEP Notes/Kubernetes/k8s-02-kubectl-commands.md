# Kubernetes 02 – kubectl Command Mastery

## 0. Goal of This Note

- Master all essential `kubectl` commands
- Understand output formats and filtering
- Use imperative vs declarative approaches
- Debug efficiently with kubectl
- Know the key shortcuts for exams and daily work

---

## 1. kubectl Basics

### 1.1 Command Structure

```
kubectl [command] [TYPE] [NAME] [flags]
```

| Part | Example | Meaning |
|------|---------|---------|
| command | `get`, `describe`, `apply`, `delete` | Action to perform |
| TYPE | `pods`, `deployments`, `services` | Resource type |
| NAME | `my-pod`, `nginx` | Resource name (optional) |
| flags | `-n my-ns`, `-o yaml` | Modifiers |

```bash
# Resource types can be abbreviated
kubectl get pods            # full
kubectl get po              # short
kubectl get po,svc          # multiple types

# Common abbreviations
po    = pods
svc   = services
deploy = deployments
ds    = daemonsets
sts   = statefulsets
rs    = replicasets
cm    = configmaps
pv    = persistentvolumes
pvc   = persistentvolumeclaims
ns    = namespaces
sa    = serviceaccounts
no    = nodes
ep    = endpoints
ing   = ingresses
netpol = networkpolicies
hpa   = horizontalpodautoscalers
```

---

## 2. Getting Resources

### 2.1 kubectl get

```bash
# Basic listing
kubectl get pods
kubectl get pods -n kube-system          # specific namespace
kubectl get pods -A                      # all namespaces
kubectl get pods --all-namespaces        # same as -A

# With more detail
kubectl get pods -o wide                 # node, IP, etc.

# Specific resource
kubectl get pod my-pod

# Multiple resource types at once
kubectl get pods,services,deployments

# All resources in a namespace
kubectl get all
kubectl get all -n my-namespace

# With labels
kubectl get pods -l app=nginx            # label selector
kubectl get pods -l 'env in (prod,staging)'
kubectl get pods -l app=nginx,env=prod   # multiple labels (AND)
kubectl get pods --selector=app=nginx    # --selector same as -l

# Watch (live updates)
kubectl get pods -w
kubectl get pods --watch

# Sort output
kubectl get pods --sort-by=.metadata.name
kubectl get pods --sort-by=.metadata.creationTimestamp
```

### 2.2 Output Formats

```bash
# Standard table output (default)
kubectl get pods

# Wide – extra columns
kubectl get pods -o wide

# YAML output
kubectl get pod my-pod -o yaml

# JSON output
kubectl get pod my-pod -o json

# Name only
kubectl get pods -o name

# Custom columns
kubectl get pods -o custom-columns=NAME:.metadata.name,STATUS:.status.phase,NODE:.spec.nodeName

# JSONPath – extract specific fields
kubectl get pod my-pod -o jsonpath='{.status.podIP}'
kubectl get pods -o jsonpath='{.items[*].metadata.name}'
kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.phase}{"\n"}{end}'

# Go template
kubectl get pods -o go-template='{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}'
```

### 2.3 kubectl describe

Deep dive into a resource's details, events, and status:

```bash
# Describe a pod (most useful for debugging)
kubectl describe pod my-pod

# Describe other resources
kubectl describe node worker-1
kubectl describe deployment my-app
kubectl describe service my-service
kubectl describe namespace kube-system
kubectl describe pvc my-pvc

# Describe all pods
kubectl describe pods

# Describe pods matching a label
kubectl describe pods -l app=nginx
```

**Describe output sections:**
- **Name, Namespace, Labels, Annotations** – metadata
- **Status, IP, Node** – scheduling info
- **Containers** – image, ports, env, mounts, probes
- **Conditions** – Ready, PodScheduled, Initialized, ContainersReady
- **Events** – most useful for debugging (bottom of output)

---

## 3. Creating and Applying Resources

### 3.1 Imperative vs Declarative

| Approach | Command | Use Case |
|----------|---------|---------|
| **Imperative** | `kubectl run`, `kubectl create` | Quick testing, learning |
| **Declarative** | `kubectl apply -f file.yaml` | Production, version-controlled |

### 3.2 kubectl apply (Declarative – Recommended)

```bash
# Apply a single file
kubectl apply -f deployment.yaml

# Apply multiple files
kubectl apply -f deployment.yaml -f service.yaml

# Apply all files in a directory
kubectl apply -f ./k8s/

# Apply from URL
kubectl apply -f https://raw.githubusercontent.com/example/repo/main/manifest.yaml

# Dry run – see what would happen
kubectl apply -f deployment.yaml --dry-run=client

# Server-side dry run
kubectl apply -f deployment.yaml --dry-run=server

# Diff – see what would change in the cluster
kubectl diff -f deployment.yaml
```

### 3.3 kubectl create (Imperative)

```bash
# Create a namespace
kubectl create namespace my-ns

# Create a deployment
kubectl create deployment nginx --image=nginx
kubectl create deployment nginx --image=nginx --replicas=3 -n my-ns

# Create a service
kubectl expose deployment nginx --port=80 --target-port=80 --type=ClusterIP
kubectl expose deployment nginx --port=80 --type=NodePort

# Create a Pod (rarely used directly)
kubectl run my-pod --image=nginx
kubectl run my-pod --image=nginx --port=80
kubectl run my-pod --image=nginx --env="MY_VAR=hello"
kubectl run my-pod --image=busybox --command -- sleep 3600

# Create a ConfigMap
kubectl create configmap my-config --from-literal=key=value
kubectl create configmap my-config --from-file=config.properties
kubectl create configmap my-config --from-env-file=.env

# Create a Secret
kubectl create secret generic my-secret --from-literal=password=secret123
kubectl create secret generic my-secret --from-file=ssh-key=~/.ssh/id_rsa
kubectl create secret tls my-tls --cert=tls.crt --key=tls.key

# Create a ServiceAccount
kubectl create serviceaccount my-sa

# Create a Role
kubectl create role pod-reader --verb=get,list,watch --resource=pods

# Create a RoleBinding
kubectl create rolebinding pod-reader-binding \
  --role=pod-reader \
  --serviceaccount=default:my-sa

# Generate YAML without creating (for templates)
kubectl create deployment nginx --image=nginx --dry-run=client -o yaml > deployment.yaml
kubectl run my-pod --image=nginx --dry-run=client -o yaml > pod.yaml
```

---

## 4. Editing and Patching

### 4.1 kubectl edit

Opens resource YAML in your default editor (`$EDITOR`):

```bash
kubectl edit deployment my-app
kubectl edit service my-service
kubectl edit configmap my-config

# Change editor
EDITOR=nano kubectl edit deployment my-app
```

### 4.2 kubectl patch

Apply partial changes without editing the full YAML:

```bash
# Strategic merge patch
kubectl patch deployment my-app -p '{"spec":{"replicas":5}}'

# JSON merge patch
kubectl patch deployment my-app --type=merge -p '{"spec":{"replicas":5}}'

# JSON patch
kubectl patch deployment my-app --type=json \
  -p='[{"op":"replace","path":"/spec/replicas","value":5}]'

# Patch a node (mark unschedulable)
kubectl patch node worker-1 -p '{"spec":{"unschedulable":true}}'
```

### 4.3 kubectl set

Convenience commands for common updates:

```bash
# Update container image
kubectl set image deployment/my-app my-container=nginx:1.25
kubectl set image deployment/my-app *=nginx:1.25      # all containers

# Set environment variable
kubectl set env deployment/my-app MY_VAR=hello
kubectl set env deployment/my-app MY_VAR-            # remove env var

# Set resource requests/limits
kubectl set resources deployment my-app \
  --requests=cpu=100m,memory=64Mi \
  --limits=cpu=200m,memory=128Mi

# Set service account
kubectl set serviceaccount deployment my-app my-sa
```

---

## 5. Deleting Resources

```bash
# Delete specific resource
kubectl delete pod my-pod
kubectl delete deployment my-app
kubectl delete service my-svc
kubectl delete namespace my-ns          # deletes everything in it!

# Delete from file
kubectl delete -f deployment.yaml

# Delete with label selector
kubectl delete pods -l app=nginx
kubectl delete pods -l env=test

# Delete all resources of a type in a namespace
kubectl delete pods --all
kubectl delete pods --all -n my-ns

# Delete all (most things – not PVs, namespaces, etc.)
kubectl delete all --all
kubectl delete all --all -n my-ns

# Force delete (skip graceful termination)
kubectl delete pod stuck-pod --force --grace-period=0

# With timeout (wait for deletion)
kubectl delete pod my-pod --timeout=60s
```

---

## 6. Logs

```bash
# Pod logs
kubectl logs my-pod

# Follow/stream logs
kubectl logs my-pod -f
kubectl logs my-pod --follow

# Last N lines
kubectl logs my-pod --tail=100

# Logs since duration
kubectl logs my-pod --since=1h
kubectl logs my-pod --since=30m
kubectl logs my-pod --since-time="2026-01-01T10:00:00Z"

# Specific container in multi-container pod
kubectl logs my-pod -c my-container

# All containers in a pod
kubectl logs my-pod --all-containers=true

# Previous container (useful if it crashed)
kubectl logs my-pod --previous
kubectl logs my-pod -p

# From a Deployment (picks one pod)
kubectl logs deployment/my-app

# Label selector
kubectl logs -l app=nginx
kubectl logs -l app=nginx -f            # follow all matching pods
```

---

## 7. Executing Commands in Pods

```bash
# Single command
kubectl exec my-pod -- ls /app
kubectl exec my-pod -- cat /etc/config/app.conf
kubectl exec my-pod -- env

# Interactive shell
kubectl exec -it my-pod -- /bin/bash
kubectl exec -it my-pod -- /bin/sh      # for alpine/minimal images

# Specific container in multi-container pod
kubectl exec -it my-pod -c sidecar -- /bin/sh

# Run a command as specific user
kubectl exec my-pod -- sh -c "id"
```

---

## 8. Port Forwarding & Proxying

```bash
# Forward local port to pod port
kubectl port-forward pod/my-pod 8080:80
# Now: curl localhost:8080

# Forward to service
kubectl port-forward service/my-svc 8080:80

# Forward to deployment (picks a pod)
kubectl port-forward deployment/my-app 8080:80

# Bind to all interfaces (default is 127.0.0.1)
kubectl port-forward pod/my-pod 8080:80 --address 0.0.0.0

# Background port-forward
kubectl port-forward pod/my-pod 8080:80 &

# Kubernetes API proxy (exposes API at localhost:8001)
kubectl proxy

# Access API via proxy
curl http://localhost:8001/api/v1/namespaces/default/pods
```

---

## 9. Scaling and Rollouts

### 9.1 Scaling

```bash
# Scale a deployment
kubectl scale deployment my-app --replicas=5
kubectl scale deployment my-app --replicas=0      # stop all pods

# Scale multiple
kubectl scale deployments/frontend deployments/backend --replicas=3

# Conditional scale (only if current count matches)
kubectl scale deployment my-app --replicas=5 --current-replicas=3
```

### 9.2 Rolling Updates

```bash
# Update image (triggers rolling update)
kubectl set image deployment/my-app container-name=nginx:1.25

# Check rollout status
kubectl rollout status deployment/my-app

# Check rollout history
kubectl rollout history deployment/my-app

# Check specific revision
kubectl rollout history deployment/my-app --revision=3

# Pause a rollout
kubectl rollout pause deployment/my-app

# Resume
kubectl rollout resume deployment/my-app

# Undo last rollout (rollback to previous version)
kubectl rollout undo deployment/my-app

# Rollback to specific revision
kubectl rollout undo deployment/my-app --to-revision=2

# Restart all pods in a deployment (rolling restart)
kubectl rollout restart deployment/my-app
```

---

## 10. Node Management

```bash
# List nodes
kubectl get nodes
kubectl get nodes -o wide

# Describe a node
kubectl describe node worker-1

# Mark node as unschedulable (no new pods)
kubectl cordon worker-1

# Mark node as schedulable again
kubectl uncordon worker-1

# Safely evict all pods from a node (before maintenance)
kubectl drain worker-1 \
  --ignore-daemonsets \
  --delete-emptydir-data \
  --force

# Add label to node
kubectl label node worker-1 disktype=ssd
kubectl label node worker-1 zone=us-east-1a

# Remove label from node
kubectl label node worker-1 disktype-

# Add taint to node
kubectl taint nodes worker-1 key=value:NoSchedule
kubectl taint nodes worker-1 key=value:NoExecute

# Remove taint
kubectl taint nodes worker-1 key=value:NoSchedule-
```

---

## 11. Copying Files

```bash
# Copy FROM pod to local
kubectl cp my-pod:/var/log/app.log ./app.log
kubectl cp my-pod:/etc/config/ ./config/

# Copy TO pod from local
kubectl cp ./app.jar my-pod:/app/app.jar

# Specific container
kubectl cp my-pod:/var/log/app.log ./app.log -c my-container
```

---

## 12. Debugging Commands

```bash
# Run a temporary debug pod (deleted after exit)
kubectl run debug --image=busybox --rm -it --restart=Never -- sh
kubectl run debug --image=nicolaka/netshoot --rm -it --restart=Never -- bash

# Debug a specific pod (copy it with overrides)
kubectl debug my-pod -it --image=busybox --copy-to=debug-pod

# Get events for a namespace (sorted by time)
kubectl get events --sort-by=.lastTimestamp
kubectl get events --sort-by=.lastTimestamp -n my-ns

# Get events for a specific resource
kubectl get events --field-selector involvedObject.name=my-pod

# Check resource usage (requires metrics-server)
kubectl top nodes
kubectl top pods
kubectl top pods -n my-ns
kubectl top pods --containers

# Check API request verbosity
kubectl get pods -v=6                  # show API requests
kubectl get pods -v=8                  # show request/response headers
kubectl get pods -v=9                  # show full body

# Check what you can do (authorization)
kubectl auth can-i create pods
kubectl auth can-i delete deployments --namespace=production
kubectl auth can-i '*' '*'             # check all permissions
kubectl auth whoami
```

---

## 13. Labels and Annotations Management

```bash
# Add label to pod
kubectl label pod my-pod env=production
kubectl label pod my-pod version=v2 --overwrite

# Remove label from pod
kubectl label pod my-pod env-

# Add label to all pods matching a selector
kubectl label pods -l app=nginx tier=web

# Add annotation
kubectl annotate pod my-pod description="My web pod"
kubectl annotate pod my-pod description="Updated" --overwrite

# Remove annotation
kubectl annotate pod my-pod description-
```

---

## 14. Resource Quotas and Limits

```bash
# Check resource quotas in a namespace
kubectl get resourcequota
kubectl describe resourcequota -n my-ns

# Check limit ranges
kubectl get limitrange
kubectl describe limitrange -n my-ns
```

---

## 15. Quick Reference Cheat Sheet

### Most Used Daily Commands
```bash
# Inspect
kgp                                    # alias: kubectl get pods
kubectl get pods -A                    # all pods
kubectl describe pod <name>            # details + events
kubectl logs <pod> -f                  # follow logs
kubectl top pods                       # resource usage

# Deploy
kubectl apply -f manifest.yaml         # apply/update
kubectl delete -f manifest.yaml        # delete

# Debug
kubectl exec -it <pod> -- /bin/sh     # shell in
kubectl port-forward svc/<svc> 8080:80
kubectl get events --sort-by=.lastTimestamp

# Rollout
kubectl rollout status deploy/<name>
kubectl rollout undo deploy/<name>
kubectl rollout restart deploy/<name>
```

### Useful Aliases
```bash
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get svc'
alias kgd='kubectl get deployment'
alias kgn='kubectl get nodes'
alias kga='kubectl get all'
alias kdp='kubectl describe pod'
alias klf='kubectl logs -f'
alias kx='kubectl exec -it'
alias kaf='kubectl apply -f'
alias kdf='kubectl delete -f'
```

### Generate YAML Templates (Exam Tip)
```bash
# Generate pod YAML
kubectl run nginx --image=nginx --dry-run=client -o yaml > pod.yaml

# Generate deployment YAML
kubectl create deployment nginx --image=nginx --replicas=3 --dry-run=client -o yaml > deploy.yaml

# Generate service YAML
kubectl expose deployment nginx --port=80 --dry-run=client -o yaml > service.yaml

# Generate job YAML
kubectl create job myjob --image=busybox --dry-run=client -o yaml -- echo hello > job.yaml

# Generate cronjob YAML
kubectl create cronjob mycron --image=busybox --schedule="* * * * *" --dry-run=client -o yaml > cron.yaml

# Generate configmap YAML
kubectl create configmap myconfig --from-literal=key=value --dry-run=client -o yaml > cm.yaml

# Generate secret YAML
kubectl create secret generic mysecret --from-literal=pass=s3cr3t --dry-run=client -o yaml > secret.yaml
```
