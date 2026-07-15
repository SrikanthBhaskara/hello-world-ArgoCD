# ArgoCD Deep Notes

## 1. What ArgoCD Is

ArgoCD is a GitOps continuous delivery tool for Kubernetes.

Its main idea is simple:
- Git is the desired state
- Kubernetes cluster is the actual state
- ArgoCD continuously compares both
- if there is drift, it shows the difference and can reconcile it

Good interview line:

"ArgoCD is a declarative GitOps controller for Kubernetes that keeps cluster state aligned with version-controlled manifests."

## 2. Why Teams Use ArgoCD

ArgoCD is popular because it gives:
- declarative deployments
- Git-based change history
- easier rollback through Git
- reduced manual `kubectl apply`
- better visibility of drift
- support for Helm, Kustomize, plain YAML, and plugins
- easier promotion across environments

Operational benefits:
- cluster changes are traceable
- unauthorized manual drift is visible
- platform teams can standardize deployment flow
- app teams can own manifests without direct cluster mutation access

## 3. GitOps Core Idea

In GitOps:
- application and environment state are stored in Git
- pull-based deployment is preferred
- reconciliation is continuous
- cluster changes are not supposed to be hand-managed

Traditional push model:
- CI pipeline pushes manifests directly to cluster

GitOps pull model:
- CI updates Git
- ArgoCD detects change
- ArgoCD pulls desired state and applies it

Why this matters:
- credentials can stay inside cluster
- audit trail stays in Git
- environments are reproducible

## 4. ArgoCD Main Components

### API Server

The API server provides:
- UI
- CLI/API access
- authentication handling
- RBAC interaction

### Repository Server

The repo server:
- clones Git repositories
- renders manifests
- handles Helm, Kustomize, and plain YAML generation

### Application Controller

This is the core reconciler.

It:
- watches ArgoCD applications
- compares desired state vs live state
- performs sync operations
- calculates health and sync status

### Redis

Redis is used for caching and improving performance.

## 5. Core ArgoCD Objects

### Application

The `Application` is the most important ArgoCD custom resource.

It typically defines:
- source repo
- revision or branch
- path or chart
- destination cluster
- destination namespace
- sync policy

Basic model:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: sample-app
spec:
  project: default
  source:
    repoURL: https://example.com/repo.git
    targetRevision: main
    path: apps/sample
  destination:
    server: https://kubernetes.default.svc
    namespace: sample
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

### AppProject

`AppProject` provides logical boundaries.

It controls:
- which repos are allowed
- which clusters are allowed
- which namespaces are allowed
- which resource kinds are allowed or denied
- role-based access around applications

This is important for multi-team environments.

### ApplicationSet

`ApplicationSet` is used to generate many Applications from a template.

Common use cases:
- one app per cluster
- one app per tenant
- one app per environment
- one app per directory

Popular generators:
- list
- git
- cluster
- matrix

## 6. Sync Status and Health Status

ArgoCD usually shows two major dimensions:

### Sync Status

This tells whether desired manifests match live cluster state.

Common states:
- `Synced`
- `OutOfSync`
- `Unknown`

### Health Status

This tells whether deployed resources are healthy.

Common states:
- `Healthy`
- `Progressing`
- `Degraded`
- `Missing`
- `Unknown`

Important distinction:
- an application can be `Synced` but still unhealthy
- an application can be `OutOfSync` but currently running fine

Interview line:

"Sync answers whether Git and cluster match. Health answers whether the workload is operational."

## 7. Manual Sync vs Auto Sync

### Manual Sync

In manual mode:
- drift is detected
- humans trigger the sync

Useful when:
- change control is strict
- production requires approval

### Automated Sync

In auto-sync mode ArgoCD can automatically apply changes from Git.

Common flags:
- `prune: true`
- `selfHeal: true`

Meaning:
- `prune` removes resources no longer present in Git
- `selfHeal` reverts live drift even if Git did not change

Good practice:
- be careful with automated prune in shared environments

## 8. Prune, Self-Heal, and Reconciliation

### Prune

If a resource was deleted from Git, ArgoCD can delete it from the cluster during sync.

Risk:
- accidental manifest deletion in Git can delete real workloads

### Self-Heal

If someone changes a live resource manually, ArgoCD can restore Git state.

Benefit:
- prevents long-lived configuration drift

### Reconciliation Loop

ArgoCD periodically reconciles desired and actual state.

The loop is what gives GitOps its consistency model.

## 9. Source Types ArgoCD Supports

ArgoCD can work with:
- plain YAML
- Helm charts
- Kustomize
- Jsonnet
- plugin-based rendering

Why this matters:
- ArgoCD is not tied to only one manifest style
- teams can standardize on one or support several

## 10. ArgoCD with Helm

ArgoCD can deploy Helm charts, but it is important to explain the model correctly.

Interview-ready explanation:

"ArgoCD uses Helm mainly as a manifest templating engine. It renders manifests and then manages the resulting Kubernetes resources declaratively."

Key implications:
- Git can store chart values
- ArgoCD renders manifests before apply
- live state is compared against rendered output

Common Helm concerns in ArgoCD:
- value file overrides
- environment-specific values
- chart version control
- secret handling

## 11. ArgoCD with Kustomize

Kustomize is often used for:
- overlays per environment
- patching
- image tag replacement
- namespace or label injection

Why teams like it:
- no templating language required
- strong fit for pure manifest layering

Common pattern:
- `base/`
- `overlays/dev`
- `overlays/qa`
- `overlays/prod`

## 12. Multi-Environment Promotion

A common GitOps pattern is:
- dev changes merge first
- validation happens
- promotion updates test or stage
- promotion then updates prod

Promotion styles:
- branch-per-environment
- directory-per-environment
- separate repo per environment

Good interview answer:

"I prefer environment separation that makes promotion explicit and reviewable. Directory-based or repo-based promotion usually makes audit and rollback easier."

## 13. Multi-Cluster Deployment

ArgoCD can manage:
- one cluster
- many clusters
- many apps across many clusters

This is usually done by:
- registering target clusters with ArgoCD
- using destination server references
- generating apps through ApplicationSet

Challenges:
- RBAC boundaries
- naming conventions
- tenant isolation
- cluster-specific overrides

## 14. Sync Waves and Ordering

Some resources must be applied in order.

Examples:
- namespace before deployment
- CRD before custom resource
- secret provider objects before app
- service account or role bindings before workloads

ArgoCD supports sync ordering concepts like:
- sync phases
- sync waves
- hooks

This helps avoid race conditions during rollout.

## 15. Hooks

Hooks are resources annotated for lifecycle actions.

Common phases:
- PreSync
- Sync
- PostSync
- SyncFail

Use cases:
- database migration
- smoke checks
- notification jobs
- cleanup jobs

Risk:
- hook failure can block application sync
- badly designed hooks can make rollouts fragile

## 16. Drift Detection

Drift means live cluster state differs from Git desired state.

Common reasons:
- manual `kubectl edit`
- operator mutation
- defaulted fields
- external controllers changing objects
- config generated outside Git

ArgoCD shows diffs, but not every diff is equally important.

Mature engineering practice:
- understand noisy diffs
- suppress only safe differences
- do not blindly ignore important drift

## 17. Common Causes of OutOfSync

- manifest changed in Git but not yet synced
- live manual change in cluster
- mutating webhook changed fields
- HPA changed replica count
- generated fields differ
- Helm rendering inputs changed
- resources created manually outside ArgoCD

Interview line:

"OutOfSync does not always mean failure. Sometimes it is expected mutation, but we should understand and intentionally manage those differences."

## 18. ArgoCD Troubleshooting Flow

When an app is not working, a solid troubleshooting path is:

1. Check app sync status and health status.
2. Inspect resource tree in ArgoCD.
3. Read sync history and error messages.
4. Check controller logs if reconciliation is failing.
5. Check rendered manifests.
6. Compare live manifest and desired manifest.
7. Inspect Kubernetes events, pod logs, rollout status, probes, and dependencies.

Good interview answer:

"I first separate GitOps failure from workload failure. If sync is failing, I inspect rendering, permissions, ordering, and diff. If sync is fine but health is degraded, I move into Kubernetes-level debugging."

## 19. Common Real-World Failure Scenarios

### Wrong Repo Path

Symptoms:
- application fails to render
- manifest generation errors

### Wrong Branch or Revision

Symptoms:
- stale release
- expected change not visible

### Helm Values Mismatch

Symptoms:
- wrong image
- wrong environment configuration
- template render failure

### Missing Namespace or Permission

Symptoms:
- forbidden errors
- resource create failures

### CRD Timing Issues

Symptoms:
- custom resources fail before CRD exists

### Secret Dependency Problems

Symptoms:
- pods crash because mounted secret or env secret missing

### Image Pull Problems

Symptoms:
- sync succeeds but pods fail in runtime

### Health Check Misconfiguration

Symptoms:
- resources are deployed but remain degraded or progressing

## 20. ArgoCD and Security

Key security topics:
- SSO integration
- RBAC
- project-level restrictions
- least privilege
- repository credential protection
- cluster credential protection

Best practices:
- avoid overly broad admin access
- restrict projects to known repos and destinations
- separate dev and prod access
- protect secrets used by repo access or cluster registration

## 21. ArgoCD RBAC

RBAC should answer:
- who can view apps
- who can sync apps
- who can override or delete apps
- who can manage projects

In mature teams:
- platform admins manage ArgoCD platform
- app teams manage only their applications
- production permissions are narrower than non-production

## 22. ArgoCD and Secrets

A common interview topic is secret handling.

Important rule:
- avoid storing plaintext secrets directly in Git

Common approaches:
- external secret operators
- sealed secrets
- secret managers integrated through controllers

Good answer:

"ArgoCD should manage secret references declaratively, but the actual secret value path should be handled through a secure secret-management workflow."

## 23. Webhooks vs Polling

ArgoCD can discover changes by:
- polling repositories
- using webhooks

Webhooks improve responsiveness and reduce unnecessary checks.

However:
- polling still provides fallback consistency

## 24. Rollback Strategy

In GitOps, rollback often means:
- revert Git commit
- sync previous known good state

This is powerful because:
- rollback is versioned
- rollback is reviewable
- rollback follows the same delivery path as rollout

Good interview line:

"In ArgoCD, the safest rollback is usually a Git revert and resync, because it preserves declarative truth and audit history."

## 25. ArgoCD vs CI/CD Pipelines

ArgoCD is not a full replacement for CI.

Typical split:
- CI builds image
- CI runs tests and scans
- CI updates manifest or chart values in Git
- ArgoCD deploys to cluster

Interview line:

"I see CI as build-and-validate, and ArgoCD as deploy-and-reconcile."

## 26. ArgoCD vs Jenkins or Script-Based Deployments

Script-based deployment often means:
- imperative steps
- cluster credentials in pipeline
- weaker drift detection

ArgoCD improves:
- declarative state
- repeatability
- visibility
- reconciliation

Tradeoff:
- ArgoCD adds platform concepts teams must learn
- bad repo structure can still create complexity

## 27. ArgoCD Repo Design Best Practices

Useful patterns:
- separate app code and deployment config when needed
- keep environment overlays explicit
- use clear naming
- keep values and manifests reviewable
- do not mix too many unrelated systems in one path

Avoid:
- giant monolithic manifest folders without ownership boundaries
- unclear environment inheritance
- hidden production changes

## 28. ApplicationSet Deep Value

ApplicationSet becomes very valuable when you have scale.

Examples:
- onboarding same app to many clusters
- generating per-customer apps
- generating per-environment apps from folders

Key benefit:
- one template controls many applications consistently

Risk:
- bad generator design can create large blast radius

## 29. Observability for ArgoCD

Important operational areas:
- sync failures
- reconciliation lag
- app health trends
- controller errors
- repository render failures
- failed hooks

Even if dashboards differ by company, good monitoring questions are:
- which apps are degraded
- which apps are persistently out of sync
- what changed recently
- is the controller healthy

## 30. How ArgoCD Fits with Kubernetes Troubleshooting

ArgoCD can tell you:
- what should be deployed
- whether it matches
- whether Kubernetes objects look healthy

But application debugging still needs Kubernetes knowledge:
- `kubectl get`
- `kubectl describe`
- `kubectl logs`
- events
- probes
- image pull status
- service and ingress connectivity

## 31. Common Interview Questions and Better Answers

### What is ArgoCD?

Better answer:

"ArgoCD is a Kubernetes-native GitOps delivery controller. It watches a Git-defined desired state, compares it with live cluster state, and reconciles differences either manually or automatically."

### What is the difference between sync and health?

Better answer:

"Sync tells whether the cluster matches Git. Health tells whether the deployed resources are operational. An application can be synced but unhealthy if pods are crashing."

### Why use ArgoCD with Helm?

Better answer:

"Helm gives reusable templating and environment values, while ArgoCD gives GitOps reconciliation, visibility, and lifecycle management of the rendered Kubernetes resources."

### What is self-heal?

Better answer:

"Self-heal means ArgoCD can correct live drift by reapplying the Git-defined desired state even when the drift was caused manually in the cluster."

### How do you troubleshoot an OutOfSync app?

Better answer:

"I first inspect the diff and sync history, then check whether the difference comes from Git changes, manual drift, controller mutation, or generated fields. After that I decide whether it needs sync, ignore rules, or workload-level debugging."

## 32. Strong Practical Tradeoff Statements

- "I prefer Git to remain the single source of truth and avoid manual cluster edits except during emergency debugging."
- "Auto-sync with prune is powerful, but I enable it carefully in production because deletion risk is real."
- "ApplicationSet improves scale, but poor generator design can widen blast radius quickly."
- "If a resource is consistently mutated by another controller, I evaluate diff customization instead of accepting noisy drift forever."

## 33. What Senior Candidates Should Emphasize

If the interview is for 4 to 7 years experience, talk not only about features but also about:
- repo structure
- promotion model
- operational guardrails
- RBAC boundaries
- production rollback
- drift ownership
- troubleshooting discipline
- secret-management integration

## 34. Final Revision Checklist

Before an interview, make sure you can explain:
- what GitOps means
- ArgoCD components
- Application vs AppProject vs ApplicationSet
- sync status vs health status
- auto sync, prune, self-heal
- Helm and Kustomize integration
- sync waves and hooks
- rollback through Git
- common failure scenarios
- security and RBAC concerns
- how to troubleshoot degraded or out-of-sync apps
