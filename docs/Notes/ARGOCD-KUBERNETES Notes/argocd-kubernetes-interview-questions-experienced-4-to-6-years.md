# ArgoCD / Kubernetes Interview Questions: Experienced (4 to 6 Years)

## Focus Areas

- architecture and deployment tradeoffs
- GitOps operating model
- production troubleshooting
- security and secret flow
- scalability and maintainability
- platform ownership thinking

## Architecture and Deployment Strategy

### 1. How do you decide what should be deployed through Helm, plain manifests, or Kustomize overlays?
Short answer:
I choose based on reuse, environment variation, and maintainability of the deployment model.

Better answer:
Helm is useful when parameterized reusable packaging is important. Plain manifests are fine for simple or highly stable cases. Kustomize is strong when I want layered environment-specific differences without rewriting shared resources. The right choice depends on how much reuse, variation, and review clarity the platform needs.

### 2. What makes a Kubernetes deployment model maintainable over time?
Short answer:
Consistency, clear ownership, predictable overlays, safe secret handling, and strong rollout visibility.

Better answer:
Maintainability comes from reducing accidental complexity. I want a deployment model where shared patterns are reused, environment differences are explicit, images are traceable, secrets are externalized, and operational behavior is easy to reason about during both normal releases and incident response.

### 3. How do you design namespace strategy in a multi-service or multi-environment cluster?
Short answer:
I use namespaces to separate workloads logically by environment, ownership, and operational boundaries.

Better answer:
Namespace design should reduce blast radius and improve clarity. I think about team ownership, secret boundaries, policy scope, monitoring separation, and operational isolation. The goal is not only grouping resources, but making security, debugging, and lifecycle management safer.

## GitOps and ArgoCD Ownership

### 4. What are the biggest benefits of GitOps beyond “deployment from Git”?
Short answer:
Traceability, reviewability, drift reduction, repeatability, and better operational discipline.

Better answer:
GitOps improves not just deployment mechanics but operational quality. It creates a clearer change history, makes environment state auditable, reduces hidden manual drift, and supports safer collaboration. It also helps incident review because the expected state is explicit and versioned.

### 5. What are the main risks or weaknesses in GitOps-based deployment models?
Short answer:
Weak secret patterns, unclear overlay design, hidden manual drift, and false confidence that sync success means runtime success.

Better answer:
GitOps is powerful, but it does not remove operational complexity by itself. Poorly designed overlays, unclear ownership, weak secret integration, or too much indirection can make the system hard to understand. Another risk is assuming a synced application is automatically healthy, which is not always true.

### 6. How do you review an ArgoCD application change before approving it?
Short answer:
I check source path, target namespace, values or overlay differences, secret dependencies, and likely runtime impact.

Better answer:
I review what the application actually points to, what environment-specific values are changing, whether the referenced image and chart artifacts exist, whether secret flows remain valid, and whether the change could affect sync behavior, rollout safety, or runtime connectivity. Approval should be operationally informed, not only syntax-based.

### 7. How do you explain the difference between config drift and source drift?
Short answer:
Config drift is live cluster state diverging from expected state, while source drift is the declared source itself changing or being inconsistent across environments.

Better answer:
Config drift usually means the cluster no longer matches what Git says should be true. Source drift is more about the Git-managed source changing inconsistently or unexpectedly across repos, overlays, or value layers. Both matter, but they require different operational thinking.

## Security and Secrets

### 8. How do you design secret handling in a GitOps-based Kubernetes platform?
Short answer:
I keep secret values out of Git, use an external secret source, and make runtime access controlled and auditable.

Better answer:
The secret design should separate desired configuration from sensitive values. I use a pattern where Git stores references and deployment intent, while the actual credentials live in a dedicated secret-management system and are synchronized or injected into the cluster through controlled workflows with least-privilege access.

### 9. What are common failures in secret delivery flow?
Short answer:
Wrong secret path, missing IAM permission, operator failure, namespace mismatch, or stale generated secrets.

Better answer:
Secret delivery issues often happen at integration boundaries. The application may be correct, but the flow can fail between cloud secret source, secret store definition, operator reconciliation, generated Kubernetes Secret, and pod consumption. I debug that chain step by step rather than restarting workloads blindly.

### 10. Why is image-pull credential flow often a hidden operational risk?
Short answer:
Because deployment can look correct while the workload still fails if registry credentials are stale, missing, or not refreshed properly.

Better answer:
Image access is a dependency many teams assume is stable until it fails in production. Pull-secret generation, token expiry, namespace scope, and workload association all matter. If those break, the cluster may not even start new pods even though manifests and images otherwise seem correct.

## Runtime Troubleshooting and Incidents

### 11. How do you lead troubleshooting when a deployment is successful in GitOps but the application is down?
Short answer:
I separate reconciliation success from runtime health and then investigate the runtime dependency chain.

Better answer:
Once I know the GitOps tool successfully applied the objects, I switch mindset from sync status to application health. I validate pod state, logs, probes, config, secrets, service endpoints, and ingress path. The key is not to stop at “Argo says synced” because runtime failures often happen after that stage.

### 12. How do you approach a repeated `CrashLoopBackOff` issue across environments?
Short answer:
I look for shared startup assumptions, configuration gaps, probe mismatches, and dependency differences rather than treating each crash as isolated.

Better answer:
If the same pattern appears repeatedly, I ask whether the deployment model itself is too fragile. I compare environment values, startup dependencies, probes, resource limits, and external service assumptions. Then I try to turn the fix into a structural improvement, not just a one-time restart.

### 13. What is your troubleshooting order for a service that is deployed but unreachable?
Short answer:
Pod health, container port, service selectors, service endpoints, ingress or load balancer path, and then network restrictions.

Better answer:
I move layer by layer from inside out. First I confirm the application is healthy in the pod. Then I verify service wiring, endpoint population, ingress rules, and external routing assumptions. That sequence prevents wasted time on outer layers when the inner layer is already failing.

### 14. How do you differentiate platform issue vs application issue?
Short answer:
I check whether the failure comes from deployment wiring, secret or runtime injection, traffic path, or actual application logic and startup behavior.

Better answer:
I try to isolate whether the platform delivered the environment the application expected. If the app is failing because its dependency chain is broken, it may still appear as an application crash even though the true root cause is platform or configuration flow. That distinction matters for ownership and long-term prevention.

## Scalability and Platform Thinking

### 15. What makes a Kubernetes platform change risky at scale?
Short answer:
Shared patterns, common charts, shared secret flow, and common controllers can create broad blast radius if changed carelessly.

Better answer:
At scale, even a small shared change can affect many services at once. That is why common overlays, base charts, secret generators, and ingress patterns need careful rollout, validation, and visibility. Senior platform thinking always includes blast-radius awareness.

### 16. How do you think about resource requests and limits from a platform perspective?
Short answer:
They must balance application needs, cluster efficiency, and runtime safety.

Better answer:
Requests and limits are not just YAML values. They affect scheduling, stability, throttling, memory safety, and cost. I use actual usage patterns, startup characteristics, and failure history to guide them rather than copying defaults blindly.

### 17. How do you make deployments safer across many services?
Short answer:
I use shared patterns carefully, validate environment-specific overrides, and enforce strong observability and rollout checks.

Better answer:
Safer large-scale deployment depends on consistency plus controlled flexibility. I want version traceability, explicit value ownership, safe health checks, secret flow confidence, and enough monitoring to know quickly when a shared change has introduced cross-service risk.

## Senior Ownership and Review Thinking

### 18. What do you expect a senior engineer to catch in a Kubernetes or ArgoCD review?
Short answer:
Not just syntax errors, but operational risk, rollout risk, secret risk, and maintainability issues.

Better answer:
Senior review should ask whether the manifest will behave safely in production, whether dependencies are satisfied, whether the secret and image paths are valid, whether the rollout could fail under load, and whether the design is maintainable for the next team member.

### 19. How do you explain your Kubernetes and GitOps ownership in interviews?
Short answer:
I explain ownership through deployment flow, environment modeling, secret flow, runtime validation, and troubleshooting impact.

Better answer:
Instead of saying I only updated YAML, I explain how I worked across image publishing, manifest updates, environment-specific values, ArgoCD application wiring, secret resolution, pod startup validation, and production-style debugging. That shows ownership across the full deployment lifecycle.

### 20. What distinguishes a mid-level Kubernetes engineer from a senior one?
Short answer:
A senior engineer reasons in terms of system behavior, blast radius, recovery, and platform design, not only manifest syntax.

Better answer:
A mid-level engineer may know how to deploy and debug resources. A senior engineer also anticipates rollout risk, designs safer deployment patterns, improves operational visibility, reduces repeat incidents, and makes platform decisions that help many services rather than only one workload.

## What To Revise Before Interview

- Helm vs manifest vs overlay tradeoffs
- GitOps benefits and pitfalls
- secret and image pull flow
- runtime troubleshooting order
- blast-radius and platform review thinking
- ownership framing for deployment work
