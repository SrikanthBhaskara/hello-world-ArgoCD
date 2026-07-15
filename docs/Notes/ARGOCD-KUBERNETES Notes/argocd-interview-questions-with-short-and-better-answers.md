# ArgoCD Interview Questions With Short and Better Answers

## 1. What is ArgoCD?

### Short Answer

ArgoCD is a GitOps continuous delivery tool for Kubernetes.

### Better Answer

ArgoCD is a declarative GitOps controller that watches Git-defined Kubernetes manifests, compares them with live cluster state, and reconciles differences through manual or automated sync.

## 2. What is GitOps?

### Short Answer

GitOps means Git is the source of truth for infrastructure and application deployment state.

### Better Answer

In GitOps, desired deployment state is stored in Git, changes are reviewed through normal version control flow, and a controller like ArgoCD continuously applies and verifies that state in the cluster.

## 3. What problem does ArgoCD solve?

### Short Answer

It reduces manual deployments and drift in Kubernetes environments.

### Better Answer

ArgoCD solves the problem of inconsistent cluster state by making deployments declarative, traceable, and continuously reconciled. It improves rollback, auditability, and environment consistency.

## 4. What is an ArgoCD Application?

### Short Answer

An Application is the ArgoCD resource that defines what to deploy and where to deploy it.

### Better Answer

An ArgoCD `Application` maps a source such as Git or Helm chart to a destination cluster and namespace. It also defines sync behavior, revision, path, and project boundaries.

## 5. What is an AppProject?

### Short Answer

An AppProject is a logical boundary for ArgoCD applications.

### Better Answer

An `AppProject` is used to control which repositories, clusters, namespaces, and resource kinds an application can use. It is important for multi-team separation and security.

## 6. What is ApplicationSet?

### Short Answer

ApplicationSet is used to generate multiple ArgoCD Applications from a template.

### Better Answer

ApplicationSet helps scale ArgoCD by dynamically creating many Applications using generators like list, cluster, git, or matrix. It is useful for multi-cluster and multi-environment patterns.

## 7. What is the difference between sync status and health status?

### Short Answer

Sync status shows whether Git and cluster match. Health status shows whether the application is operational.

### Better Answer

Sync status answers configuration alignment, while health status answers runtime condition. An application can be `Synced` but still `Degraded` if pods are crashing or dependencies are failing.

## 8. What does OutOfSync mean?

### Short Answer

It means the live cluster state differs from the desired state in Git.

### Better Answer

`OutOfSync` means ArgoCD detected a difference between rendered desired manifests and live resources. The cause could be a Git change, manual drift, mutating controllers, or generated fields.

## 9. What is self-heal in ArgoCD?

### Short Answer

Self-heal means ArgoCD can automatically correct drift in live resources.

### Better Answer

With self-heal enabled, ArgoCD re-applies the Git-defined desired state when live resources are manually or externally modified, helping maintain Git as the single source of truth.

## 10. What does prune do?

### Short Answer

Prune removes resources from the cluster that no longer exist in Git.

### Better Answer

Prune allows ArgoCD to delete resources that were removed from the desired configuration. It keeps the cluster clean, but it must be used carefully because accidental Git deletion can remove live resources.

## 11. What is automated sync?

### Short Answer

Automated sync means ArgoCD applies Git changes automatically without manual sync.

### Better Answer

Automated sync allows ArgoCD to continuously reconcile changes from Git. It is commonly combined with prune and self-heal, but production use should be designed with strong review and rollback practices.

## 12. How does ArgoCD work with Helm?

### Short Answer

ArgoCD uses Helm mainly to render manifests and then manages the resulting Kubernetes resources.

### Better Answer

ArgoCD does not behave like a long-lived imperative Helm deployment pipeline. It typically renders the chart using the configured values and then performs declarative reconciliation on the rendered manifests.

## 13. How does ArgoCD work with Kustomize?

### Short Answer

ArgoCD can render Kustomize bases and overlays directly.

### Better Answer

ArgoCD integrates well with Kustomize for environment overlays, patching, label injection, and image updates. This is useful when teams want pure manifest layering without Helm templating.

## 14. Why is ArgoCD considered pull-based delivery?

### Short Answer

Because the controller inside or near the cluster pulls the desired state from Git.

### Better Answer

Unlike push-based pipelines that directly apply manifests from CI, ArgoCD continuously observes Git and reconciles state from the cluster side. This reduces credential spread and improves deployment traceability.

## 15. How do you rollback with ArgoCD?

### Short Answer

Usually by reverting the Git change and syncing the previous desired state.

### Better Answer

The most reliable rollback pattern is a Git revert followed by sync, because it preserves auditability, aligns with GitOps principles, and avoids creating configuration truth outside version control.

## 16. What are ArgoCD hooks?

### Short Answer

Hooks are lifecycle-triggered resources used before, during, or after sync.

### Better Answer

Hooks allow teams to run jobs or actions in phases like `PreSync`, `Sync`, `PostSync`, or `SyncFail`. They are often used for migrations, smoke checks, and notifications.

## 17. What are sync waves?

### Short Answer

Sync waves control the order in which resources are applied.

### Better Answer

Sync waves help coordinate dependencies between resources, such as ensuring namespaces, CRDs, secrets, or service accounts exist before workloads start. This reduces race conditions during rollout.

## 18. What is drift detection?

### Short Answer

Drift detection means identifying when live cluster state differs from Git-defined desired state.

### Better Answer

Drift detection is one of ArgoCD's biggest operational strengths. It helps identify manual edits, unexpected controller mutation, or missed deployment steps, making environments easier to trust and debug.

## 19. How do you troubleshoot an ArgoCD deployment issue?

### Short Answer

Check sync status, health status, diffs, controller logs, and Kubernetes events.

### Better Answer

I first separate GitOps failure from workload failure. If sync is failing, I inspect rendering, permissions, ordering, and diff. If sync is successful but health is degraded, I move into pod, event, probe, secret, and service debugging on the Kubernetes side.

## 20. What security concerns matter in ArgoCD?

### Short Answer

RBAC, repo credentials, cluster credentials, project restrictions, and secret handling.

### Better Answer

ArgoCD should be designed with least privilege, strong SSO and RBAC, restricted project scope, secure secret integrations, and careful separation between development and production access.

## 21. What is a good repo structure for ArgoCD?

### Short Answer

Use clear separation by app and environment, with explicit ownership and promotion flow.

### Better Answer

I prefer structures that make environment differences obvious and reviewable. Good repo design reduces accidental blast radius, improves promotion clarity, and makes troubleshooting much easier.

## 22. What are the main components of ArgoCD?

### Short Answer

API server, repo server, application controller, and Redis.

### Better Answer

The API server provides UI and API access, the repo server renders source content, the application controller performs reconciliation, and Redis is used for caching and efficiency.

## 23. How is ArgoCD different from Jenkins?

### Short Answer

Jenkins is commonly used for CI and orchestration, while ArgoCD focuses on GitOps deployment and reconciliation.

### Better Answer

I usually explain them as complementary. Jenkins or another CI tool builds, tests, scans, and updates deployment config in Git, while ArgoCD handles cluster-side deployment reconciliation from Git.

## 24. Why do teams use ApplicationSet instead of creating Applications manually?

### Short Answer

Because it scales better and reduces repetitive configuration.

### Better Answer

When many similar applications or clusters exist, ApplicationSet standardizes generation and lowers maintenance effort. It is especially valuable for multi-cluster and multi-tenant GitOps setups.

## 25. What should a strong senior answer include for ArgoCD?

### Short Answer

Architecture, security, repo design, troubleshooting, and tradeoffs.

### Better Answer

A strong senior answer should go beyond feature definitions and include promotion strategy, project boundaries, blast-radius control, drift ownership, RBAC, secret handling, and operational debugging discipline.
