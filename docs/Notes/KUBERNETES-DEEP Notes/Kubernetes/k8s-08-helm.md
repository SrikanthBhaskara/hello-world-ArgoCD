# Kubernetes 08 – Helm Package Manager

## 0. Goal of This Note

- Understand what Helm is and why it's used
- Install and configure Helm
- Work with Helm repositories, charts, releases, and rollbacks
- Write custom Helm charts with Go templating
- Use Helm in CI/CD pipelines

---

## 1. What is Helm?

**Helm** is the **package manager for Kubernetes**. It:
- Packages Kubernetes manifests into **charts** (like npm packages, apt packages)
- Manages the full lifecycle (install, upgrade, rollback, uninstall)
- Supports **templating** via Go templates + values
- Tracks **release history**

```
Without Helm:                  With Helm:
kubectl apply -f deploy.yaml   helm install my-release my-chart
kubectl apply -f service.yaml  helm upgrade my-release my-chart --set replicas=5
kubectl apply -f ingress.yaml  helm rollback my-release 1
kubectl apply -f cm.yaml       helm uninstall my-release
kubectl apply -f secret.yaml
```

### Key Terms

| Term | Meaning |
|------|---------|
| **Chart** | Package containing K8s manifests + metadata + values |
| **Release** | A running instance of a chart (installed in the cluster) |
| **Revision** | Version number of a release (1, 2, 3...) |
| **Repository** | Collection of charts (like a package registry) |
| **Values** | Configuration parameters that customize a chart |

---

## 2. Installing Helm

```bash
# Linux/macOS (script)
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# macOS (Homebrew)
brew install helm

# Windows (Chocolatey)
choco install kubernetes-helm

# Windows (winget)
winget install Helm.Helm

# Verify
helm version
```

---

## 3. Helm Repositories

```bash
# Add popular repositories
helm repo add stable https://charts.helm.sh/stable
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add cert-manager https://charts.jetstack.io
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts

# List configured repos
helm repo list

# Update all repos (fetch latest chart metadata)
helm repo update

# Remove a repo
helm repo remove stable

# Search for charts
helm search repo nginx
helm search repo bitnami/nginx
helm search repo nginx --versions           # show all available versions
helm search hub wordpress                   # search Artifact Hub
```

---

## 4. Working with Charts

### 4.1 Inspect a Chart

```bash
# Show chart info
helm show chart bitnami/nginx
helm show values bitnami/nginx              # show all default values
helm show readme bitnami/nginx
helm show all bitnami/nginx                 # everything

# Download chart locally (without installing)
helm pull bitnami/nginx
helm pull bitnami/nginx --version 15.0.0   # specific version
helm pull bitnami/nginx --untar            # extract it
```

### 4.2 Install a Chart

```bash
# Basic install (auto-generates release name)
helm install release-name chart-name

# Install from a repo
helm install my-nginx bitnami/nginx

# Install specific version
helm install my-nginx bitnami/nginx --version 15.0.0

# Install into a specific namespace (creates namespace if --create-namespace)
helm install my-nginx bitnami/nginx \
  --namespace web \
  --create-namespace

# Override values inline
helm install my-nginx bitnami/nginx \
  --set service.type=NodePort \
  --set replicaCount=3

# Override with a values file
helm install my-nginx bitnami/nginx -f my-values.yaml

# Multiple values files (later files override earlier ones)
helm install my-nginx bitnami/nginx \
  -f defaults.yaml \
  -f production.yaml

# Dry run (don't install, just render templates)
helm install my-nginx bitnami/nginx --dry-run

# Debug (dry run with template rendering output)
helm install my-nginx bitnami/nginx --dry-run --debug

# Wait for all Pods to be ready
helm install my-nginx bitnami/nginx --wait --timeout 5m

# Generate manifests without installing
helm template my-nginx bitnami/nginx
helm template my-nginx bitnami/nginx -f my-values.yaml > rendered.yaml
```

### 4.3 List and Status

```bash
# List all releases
helm list
helm list -A                               # all namespaces
helm list -n web                           # specific namespace
helm list --all                            # include failed/uninstalled
helm list --filter nginx                   # filter by name

# Get release status
helm status my-nginx
helm status my-nginx -n web

# Get revision history
helm history my-nginx

# Get the rendered manifests of a deployed release
helm get manifest my-nginx

# Get user-supplied values
helm get values my-nginx
helm get values my-nginx --all             # all values (including defaults)

# Get all info
helm get all my-nginx
```

### 4.4 Upgrade a Release

```bash
# Upgrade to newer chart version
helm upgrade my-nginx bitnami/nginx

# Upgrade to specific version
helm upgrade my-nginx bitnami/nginx --version 16.0.0

# Upgrade with changed values
helm upgrade my-nginx bitnami/nginx \
  --set replicaCount=5 \
  --reuse-values                           # keep existing values, only change what's set

# Upgrade or install if not exists
helm upgrade --install my-nginx bitnami/nginx -f values.yaml

# Wait for readiness
helm upgrade my-nginx bitnami/nginx --wait

# Atomic: rollback if upgrade fails
helm upgrade my-nginx bitnami/nginx --atomic --timeout 5m
```

### 4.5 Rollback

```bash
# View history first
helm history my-nginx

# Rollback to previous revision
helm rollback my-nginx

# Rollback to specific revision
helm rollback my-nginx 2

# Dry run rollback
helm rollback my-nginx --dry-run
```

### 4.6 Uninstall

```bash
# Uninstall a release
helm uninstall my-nginx

# Keep history (can rollback later)
helm uninstall my-nginx --keep-history

# Uninstall from specific namespace
helm uninstall my-nginx -n web
```

---

## 5. Creating a Custom Chart

### 5.1 Chart Structure

```bash
# Scaffold a new chart
helm create my-chart

# Structure:
my-chart/
├── Chart.yaml          # chart metadata
├── values.yaml         # default configuration values
├── charts/             # chart dependencies
├── templates/          # Kubernetes manifest templates
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   ├── serviceaccount.yaml
│   ├── hpa.yaml
│   ├── _helpers.tpl    # template helpers (partials)
│   ├── NOTES.txt       # displayed after install
│   └── tests/
│       └── test-connection.yaml
└── .helmignore         # files to ignore when packaging
```

### 5.2 Chart.yaml

```yaml
apiVersion: v2                    # Helm 3 uses v2
name: my-chart
description: A sample Helm chart for Kubernetes
type: application                 # application or library

version: 1.0.0                    # chart version (semver)
appVersion: "2.3.0"               # app version (informational)

keywords:
- nginx
- web-server

maintainers:
- name: Your Name
  email: your@email.com

dependencies:
- name: postgresql
  version: "12.x.x"
  repository: https://charts.bitnami.com/bitnami
  condition: postgresql.enabled
```

### 5.3 values.yaml

```yaml
# values.yaml – default values
replicaCount: 1

image:
  repository: nginx
  tag: "1.25"
  pullPolicy: IfNotPresent

service:
  type: ClusterIP
  port: 80

ingress:
  enabled: false
  className: nginx
  hosts:
  - host: myapp.example.com
    paths:
    - path: /
      pathType: Prefix

resources:
  limits:
    cpu: 200m
    memory: 128Mi
  requests:
    cpu: 100m
    memory: 64Mi

autoscaling:
  enabled: false
  minReplicas: 1
  maxReplicas: 10
  targetCPUUtilizationPercentage: 80
```

### 5.4 Go Templating in Templates

```yaml
# templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "my-chart.fullname" . }}    # call helper
  namespace: {{ .Release.Namespace }}
  labels:
    {{- include "my-chart.labels" . | nindent 4 }}  # indent 4 spaces
spec:
  {{- if not .Values.autoscaling.enabled }}
  replicas: {{ .Values.replicaCount }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "my-chart.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "my-chart.selectorLabels" . | nindent 8 }}
    spec:
      containers:
      - name: {{ .Chart.Name }}
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
        imagePullPolicy: {{ .Values.image.pullPolicy }}
        ports:
        - name: http
          containerPort: 80
        {{- with .Values.resources }}
        resources:
          {{- toYaml . | nindent 10 }}
        {{- end }}
```

### 5.5 Template Variables Reference

| Variable | Meaning |
|----------|---------|
| `.Values.xxx` | Values from values.yaml |
| `.Release.Name` | Release name (e.g., my-nginx) |
| `.Release.Namespace` | Namespace of the release |
| `.Release.IsInstall` | True on first install |
| `.Release.IsUpgrade` | True on upgrade |
| `.Chart.Name` | Chart name |
| `.Chart.Version` | Chart version |
| `.Chart.AppVersion` | App version |
| `.Files.Get "file"` | Contents of a file in the chart |
| `.Capabilities.KubeVersion` | Kubernetes version |

### 5.6 Template Functions

```yaml
# String functions
{{ .Values.name | upper }}
{{ .Values.name | lower }}
{{ .Values.name | title }}
{{ .Values.name | quote }}
{{ .Values.name | trunc 63 | trimSuffix "-" }}

# Defaults
{{ .Values.timeout | default 30 }}
{{ .Values.image.tag | default .Chart.AppVersion }}

# Type checking
{{- if .Values.ingress.enabled }}
{{- end }}

{{- if eq .Values.service.type "NodePort" }}
{{- end }}

{{- if and .Values.ingress.enabled .Values.ingress.tls }}
{{- end }}

# Iteration
{{- range .Values.ingress.hosts }}
- host: {{ .host | quote }}
{{- end }}

# YAML conversion
{{- toYaml .Values.resources | nindent 10 }}

# Indent
{{- include "my-chart.labels" . | nindent 4 }}
```

### 5.7 _helpers.tpl

```
{{/*
Expand the name of the chart.
*/}}
{{- define "my-chart.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "my-chart.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "my-chart.labels" -}}
helm.sh/chart: {{ include "my-chart.chart" . }}
{{ include "my-chart.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "my-chart.selectorLabels" -}}
app.kubernetes.io/name: {{ include "my-chart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
```

---

## 6. Chart Dependencies

```yaml
# Chart.yaml
dependencies:
- name: postgresql
  version: "12.x.x"
  repository: https://charts.bitnami.com/bitnami
  condition: postgresql.enabled       # only include if this value is true
  alias: db                           # access as db in values

- name: redis
  version: "17.x.x"
  repository: https://charts.bitnami.com/bitnami
  tags:
  - cache
```

```bash
# Download dependencies
helm dependency update my-chart

# List dependencies
helm dependency list my-chart

# Build (package deps)
helm dependency build my-chart
```

```yaml
# values.yaml – configure dependency
postgresql:
  enabled: true
  auth:
    password: mysecretpassword
  primary:
    persistence:
      size: 8Gi
```

---

## 7. Packaging and Distributing

```bash
# Validate chart syntax
helm lint my-chart

# Package chart into a .tgz archive
helm package my-chart
# produces: my-chart-1.0.0.tgz

# Install from local package
helm install my-release ./my-chart-1.0.0.tgz

# Push to OCI registry (Helm 3.8+)
helm push my-chart-1.0.0.tgz oci://registry.example.com/charts

# Install from OCI
helm install my-release oci://registry.example.com/charts/my-chart --version 1.0.0

# Set up a chart repository with GitHub Pages or ChartMuseum
helm repo index .                     # generate index.yaml from tgz files
```

---

## 8. Helm in CI/CD

```bash
# Typical CI/CD pipeline steps:

# 1. Lint
helm lint ./my-chart

# 2. Render and validate (dry-run with server validation)
helm upgrade --install my-release ./my-chart \
  --namespace production \
  -f values-production.yaml \
  --dry-run

# 3. Deploy
helm upgrade --install my-release ./my-chart \
  --namespace production \
  -f values-production.yaml \
  --wait \
  --atomic \
  --timeout 10m

# 4. Verify
helm status my-release -n production
kubectl rollout status deployment/my-release-my-chart -n production

# Rollback on failure
helm rollback my-release -n production
```

**Helm with ArgoCD (GitOps):**
```yaml
# ArgoCD Application using Helm
apiVersion: argoproj.io/v1alpha1
kind: Application
spec:
  source:
    repoURL: https://charts.bitnami.com/bitnami
    chart: nginx
    targetRevision: 15.0.0
    helm:
      releaseName: my-nginx
      values: |
        replicaCount: 3
        service:
          type: ClusterIP
```

---

## 9. Common Helm Charts

```bash
# ingress-nginx
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx --create-namespace

# cert-manager (auto TLS with Let's Encrypt)
helm upgrade --install cert-manager cert-manager/cert-manager \
  --namespace cert-manager --create-namespace \
  --set installCRDs=true

# Prometheus + Grafana stack
helm upgrade --install kube-prometheus-stack \
  prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace

# Loki (log aggregation)
helm upgrade --install loki grafana/loki-stack \
  --namespace monitoring

# ArgoCD
helm upgrade --install argocd argo/argo-cd \
  --namespace argocd --create-namespace

# Longhorn (distributed storage)
helm upgrade --install longhorn longhorn/longhorn \
  --namespace longhorn-system --create-namespace
```

---

## 10. Helm Cheat Sheet

```bash
# Search
helm search repo <term>
helm search hub <term>

# Info
helm show chart <chart>
helm show values <chart>

# Install/Upgrade
helm install <release> <chart> [flags]
helm upgrade --install <release> <chart> -f values.yaml [flags]

# Status
helm list [-A] [-n namespace]
helm status <release>
helm history <release>
helm get values <release>
helm get manifest <release>

# Rollback
helm rollback <release> [revision]

# Uninstall
helm uninstall <release>

# Develop
helm create <name>
helm lint <chart>
helm template <release> <chart>
helm package <chart>

# Repos
helm repo add <name> <url>
helm repo update
helm repo list
```
