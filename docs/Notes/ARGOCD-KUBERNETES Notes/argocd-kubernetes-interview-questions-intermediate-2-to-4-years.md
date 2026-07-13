# ArgoCD / Kubernetes Interview Questions: Intermediate (2 to 4 Years)

## Focus Areas

- Kubernetes resource behavior
- deployment troubleshooting
- config and secret flow
- GitOps reasoning
- service exposure and traffic flow
- day-2 operational awareness

## Kubernetes Core Behavior

### 1. What is the difference between a Pod, Deployment, and ReplicaSet?
Short answer:
A Pod is the runtime unit, a Deployment manages rollout and desired state, and a ReplicaSet maintains the requested number of pod replicas.

Better answer:
Pods are the actual running units. ReplicaSets enforce replica count, but in practice Deployments are what we usually manage directly because they own rollout behavior and create ReplicaSets behind the scenes. That distinction matters in troubleshooting because the visible failure may be at pod level while the real control logic is at Deployment level.

### 2. What is the difference between Deployment and StatefulSet?
Short answer:
Deployment is mainly for stateless workloads, while StatefulSet is for workloads needing stable identity or persistent per-pod storage.

Better answer:
If replicas are interchangeable, Deployment is usually the right choice. If each pod needs stable network identity, ordered lifecycle, or dedicated persistent storage, StatefulSet is stronger. The design choice depends on workload semantics, not just preference.

### 3. What happens during a rolling update in Kubernetes?
Short answer:
Kubernetes gradually replaces old pods with new ones based on rollout strategy settings.

Better answer:
A rolling update avoids replacing everything at once. New pods are created progressively, readiness is checked, and old pods are removed in steps according to strategy settings like max unavailable and max surge. This reduces release risk, but only if probes and startup assumptions are configured correctly.

### 4. What is the purpose of readiness and liveness probes?
Short answer:
Readiness decides whether a pod should receive traffic, and liveness decides whether the container should be restarted.

Better answer:
Readiness protects traffic flow by keeping an unhealthy or not-yet-ready pod out of service endpoints. Liveness is more about recovery when the application is stuck or broken. Misconfigured probes can create instability, so they need to match real application startup and health behavior.

## Services, Networking, and Exposure

### 5. What is the difference between ClusterIP, NodePort, and LoadBalancer services?
Short answer:
ClusterIP is internal-only, NodePort exposes through node ports, and LoadBalancer exposes through an external load-balancing mechanism.

Better answer:
ClusterIP is the default for internal service-to-service communication. NodePort is a simpler exposure model but usually not the final production entry point. LoadBalancer is more natural when cloud or infrastructure integration provides external traffic routing. The choice depends on access pattern and environment design.

### 6. Why might a service exist but still not route traffic to pods?
Short answer:
Common reasons are wrong selectors, missing endpoints, unhealthy pods, wrong ports, or namespace mismatch.

Better answer:
I troubleshoot this layer by layer: confirm pods are healthy, confirm labels match selectors, confirm endpoints are populated, confirm target and service ports align, and confirm the app is actually listening where expected. Many reachability issues are simple wiring mismatches rather than deeper cluster failures.

### 7. What is an Ingress and when would you use it?
Short answer:
Ingress manages external HTTP or HTTPS routing to services inside the cluster.

Better answer:
Ingress is useful when multiple services need controlled external routing, host or path-based rules, and TLS handling. It acts as an entry-point routing layer rather than replacing services internally.

## Config, Secrets, and Runtime Wiring

### 8. Difference between ConfigMap and Secret in real usage?
Short answer:
ConfigMap stores non-sensitive configuration and Secret stores sensitive values or credentials.

Better answer:
Both externalize application configuration from images, but they should be treated differently operationally. ConfigMaps are appropriate for normal app settings, while Secrets should be sourced, stored, and accessed more carefully because they hold credentials or sensitive data.

### 9. Why is external secret flow important in GitOps-based systems?
Short answer:
Because Git should store deployment intent, not raw secret values.

Better answer:
GitOps works best when configuration is version-controlled but sensitive values are still protected. External secret flow keeps actual credentials outside Git while allowing the cluster to reconcile secret references into runtime secrets safely and audibly.

### 10. What is an image pull secret and when do you need it?
Short answer:
An image pull secret lets Kubernetes authenticate to a private image registry.

Better answer:
It is needed when images are not publicly accessible. If the secret is missing, expired, or miswired, workloads can fail with pull-related errors even if the deployment manifest itself looks correct.

## GitOps and ArgoCD

### 11. What is GitOps in practical terms?
Short answer:
GitOps means the desired deployment state is stored in Git and automation reconciles the cluster to match it.

Better answer:
In practical terms, Git becomes the reviewable and versioned source of deployment truth. Tools like ArgoCD detect drift between Git and the cluster and apply changes to bring the live environment back in line. This reduces manual changes and improves traceability.

### 12. What does it mean when an ArgoCD application is OutOfSync?
Short answer:
It means the live cluster state differs from the desired state in Git or the rendered source.

Better answer:
That drift can come from new Git changes waiting to sync, manual cluster changes, rendering differences, or failed earlier sync attempts. The correct next step is to inspect diff and sync history instead of assuming it is only cosmetic.

### 13. What is the difference between sync failure and health failure in ArgoCD?
Short answer:
Sync failure means ArgoCD could not apply or reconcile the desired state, while health failure means the resource exists but is not healthy at runtime.

Better answer:
This is an important distinction. Sync is about reconciliation of manifests; health is about the actual runtime condition afterward. A deployment can sync successfully and still fail health because the pod crashes, probes fail, or dependencies are missing.

### 14. Why is Git the source of truth useful operationally?
Short answer:
Because it gives history, reviewability, rollback clarity, and reduced manual drift.

Better answer:
If the cluster changes only through reviewed source, teams can see exactly what changed and why. This improves incident analysis and reduces the hidden risk of ad-hoc manual fixes that later get forgotten or overwritten.

## Troubleshooting Scenarios

### 15. A pod is in `ImagePullBackOff`. What do you check?
Short answer:
I check image name and tag, registry access, image pull secret, and whether the image actually exists.

Better answer:
I verify the deployment references the correct registry path and tag, confirm credentials are valid, confirm the pull secret is present in the right namespace or service account path, and check whether the image was actually published successfully upstream.

### 16. A pod is in `CrashLoopBackOff`. What do you check?
Short answer:
I check events, logs, startup command, environment variables, secrets, and probe behavior.

Better answer:
`CrashLoopBackOff` is a symptom, not a root cause. I want to know whether the container is failing due to app startup logic, missing configuration, dependency reachability, bad commands, or probe settings that restart a slow-starting app prematurely.

### 17. An ArgoCD app synced successfully but the service is still not working. What next?
Short answer:
I move from GitOps status to runtime debugging: pod health, logs, probes, secrets, networking, and service exposure.

Better answer:
ArgoCD success only proves the desired objects were applied. It does not prove the application is healthy. After sync success, I switch to normal Kubernetes runtime troubleshooting and validate the dependency chain from config and secret flow to pod startup and traffic reachability.

### 18. External Secrets are not creating Kubernetes Secrets. What do you check?
Short answer:
I check the ExternalSecret resource, the store reference, cloud permissions, key path, and operator logs.

Better answer:
I want to verify whether the problem is in the secret source, the secret store definition, IAM or auth permissions, namespace placement, or the operator reconciliation itself. This issue is often integration-flow related rather than application-code related.

## Design and Ownership Thinking

### 19. How do you make Kubernetes deployments safer across environments?
Short answer:
I use environment-specific values carefully, strong validation, reviewed Git changes, health checks, and rollout discipline.

Better answer:
Safer deployments come from consistency plus controlled differences. I want shared chart or manifest patterns, clear environment overlays, externalized secrets, probe correctness, image traceability, and enough validation to catch wrong values before the workload fails at runtime.

### 20. Why are labels and selectors more important than they look?
Short answer:
Because a lot of Kubernetes resource relationships depend on them, including service-to-pod routing and controller ownership.

Better answer:
Labels and selectors are a core coordination mechanism in Kubernetes. If they are wrong, resources can exist but not behave correctly together. Many seemingly mysterious runtime issues come down to selector mismatch rather than infrastructure failure.

### 21. What would you look for when reviewing a Kubernetes manifest in code review?
Short answer:
I check image versioning, labels, selectors, probes, resources, secret references, ports, and namespace correctness.

Better answer:
I review both correctness and operability. That includes whether rollout behavior is safe, whether probes match the application, whether configuration and secrets are externalized properly, whether resource requests and limits are reasonable, and whether the manifest is maintainable for future changes.

### 22. How do you explain Kubernetes experience from a deployment-focused project?
Short answer:
I explain ownership in terms of deployment flow, secret flow, runtime validation, and troubleshooting rather than only YAML editing.

Better answer:
Strong Kubernetes experience is not just writing manifests. It includes understanding how images, configuration, secrets, health checks, service routing, GitOps sync, and runtime diagnostics all connect. I explain my work through that full deployment and operations chain.

## What To Revise Before Interview

- pod, deployment, service behavior
- probes and rollout strategy
- service exposure flow
- ConfigMap vs Secret
- GitOps and ArgoCD sync reasoning
- runtime troubleshooting sequence
