# Kubernetes Interview Questions With Short and Better Answers

## 1. What is Kubernetes?

### Short Answer

Kubernetes is a container orchestration platform used to deploy, scale, and manage containerized applications.

### Better Answer

Kubernetes is a declarative platform that manages containerized workloads through a control plane. Instead of manually starting and managing containers, we define the desired state and Kubernetes continuously works to keep the runtime aligned with that state.

## 2. What problem does Kubernetes solve?

### Short Answer

It solves deployment, scaling, recovery, and service management challenges for containers.

### Better Answer

Kubernetes helps teams run containers reliably at scale. It handles replica management, rollout control, service discovery, self-healing, and configuration patterns so application delivery becomes more standardized and repeatable.

## 3. What is a Pod?

### Short Answer

A Pod is the smallest deployable unit in Kubernetes.

### Better Answer

A Pod represents one workload instance with shared network namespace and storage context for its containers. In most application cases, a Pod runs one main application container plus any tightly coupled helper containers if needed.

## 4. What is the difference between a Pod and a Deployment?

### Short Answer

A Pod is a running workload unit, while a Deployment manages replicated Pods and rollout behavior.

### Better Answer

Pods are ephemeral and not ideal for direct production management. A Deployment adds higher-level lifecycle control such as replica management, rolling updates, and recovery when Pods are lost or replaced.

## 5. What is a Service in Kubernetes?

### Short Answer

A Service provides stable networking to a set of Pods selected by labels.

### Better Answer

Because Pod IPs can change when Pods restart or reschedule, a Service gives a stable network identity and routes traffic to the correct Pod group through label selectors.

## 6. What is the difference between ClusterIP, NodePort, and LoadBalancer?

### Short Answer

ClusterIP is internal-only, NodePort exposes through the node, and LoadBalancer exposes through an external load balancer integration.

### Better Answer

I use ClusterIP for internal service-to-service communication, NodePort mostly as a simpler exposure method or for specific use cases, and LoadBalancer when the platform should provision external access through cloud load-balancer integration.

## 7. What is an Ingress?

### Short Answer

Ingress is a Kubernetes resource used to define HTTP or HTTPS routing into services.

### Better Answer

Ingress provides higher-level external routing rules like host-based or path-based routing. In practice it works with an ingress controller that implements the actual traffic-handling behavior.

## 8. What are ConfigMaps and Secrets?

### Short Answer

ConfigMaps store non-sensitive configuration, and Secrets store sensitive values.

### Better Answer

Both externalize runtime configuration from the container image. ConfigMaps are for non-sensitive values like flags or endpoints, while Secrets are for tokens, passwords, and certificates that need tighter handling.

## 9. What is a Namespace?

### Short Answer

A Namespace logically separates workloads inside a Kubernetes cluster.

### Better Answer

Namespaces are useful for team, application, or environment separation. They help with access control, quotas, organization, and reducing operational blast radius.

## 10. What are labels and selectors?

### Short Answer

Labels are key-value metadata, and selectors use those labels to target resources.

### Better Answer

Labels and selectors are one of the most important Kubernetes design concepts because Services, Deployments, policies, and many controllers rely on them to connect the right resources together.

## 11. What is the difference between readiness and liveness probes?

### Short Answer

Readiness controls traffic routing, while liveness controls restart behavior.

### Better Answer

Readiness tells Kubernetes whether the application is prepared to receive traffic. Liveness tells Kubernetes whether the process is unhealthy enough to restart. Mixing them up can cause unstable rollouts or unnecessary restarts.

## 12. What are resource requests and limits?

### Short Answer

Requests affect scheduling and limits cap maximum resource usage.

### Better Answer

Requests tell the scheduler what CPU and memory the Pod needs at minimum, while limits prevent a workload from consuming too much. Misconfigured values often cause scheduling problems, throttling, or memory-related instability.

## 13. What is a StatefulSet?

### Short Answer

A StatefulSet is used for workloads that need stable identity or persistent storage behavior.

### Better Answer

StatefulSet is useful for workloads like databases or clustered systems where each replica needs a predictable identity, stable storage association, or ordered startup and shutdown behavior.

## 14. What is a DaemonSet?

### Short Answer

A DaemonSet runs one Pod per node or per eligible node set.

### Better Answer

DaemonSets are commonly used for node-level agents such as logging, monitoring, or security components because they ensure coverage across the cluster rather than application-style replication.

## 15. What is a Job or CronJob?

### Short Answer

A Job runs one-time tasks, and a CronJob runs scheduled tasks.

### Better Answer

I use Jobs for batch or one-time work such as migrations or exports, and CronJobs for scheduled automation. They solve different problems than always-on services and Deployments.

## 16. How do you debug `CrashLoopBackOff`?

### Short Answer

Check `kubectl describe`, logs, startup command, env vars, mounts, and probe behavior.

### Better Answer

I usually start with events and logs, then verify whether the application crashes on startup, whether configuration or secrets are missing, or whether probes are killing a slow-starting service before it becomes ready.

## 17. How do you debug `ImagePullBackOff`?

### Short Answer

Check the image name, tag, registry access, and pull secret or service-account configuration.

### Better Answer

I focus on the event message first because it usually points toward auth, tag, or registry problems. Then I confirm the image exists, the reference is correct, and the runtime path has access to pull it.

## 18. How do you troubleshoot a Service that is not routing traffic?

### Short Answer

Check selectors, endpoints, target ports, Pod readiness, and whether the Service points to the right Pods.

### Better Answer

If a Service is not routing traffic, I inspect the full chain from Service selector to Pod labels to endpoint creation and actual application port binding. The issue is often a mismatch in one of those layers.

## 19. How do you troubleshoot an Ingress problem?

### Short Answer

Check ingress rules, controller health, backend service wiring, DNS, and TLS behavior.

### Better Answer

I move layer by layer: ingress object, ingress controller, service backend, endpoint health, DNS resolution, and certificate or TLS configuration. Healthy Pods alone do not prove the ingress path works.

## 20. What is RBAC in Kubernetes?

### Short Answer

RBAC controls who can perform which actions on which resources.

### Better Answer

RBAC is a key security control in Kubernetes. It defines access through roles and bindings so teams and workloads only get the permissions they actually need.

## 21. Why are service accounts important?

### Short Answer

Service accounts provide identity for workloads running inside the cluster.

### Better Answer

Service accounts matter because Pods often need identity for Kubernetes API access or external cloud integration. Good service-account design helps implement least privilege at the workload level.

## 22. What is the difference between a valid manifest and a safe deployment?

### Short Answer

A valid manifest may still produce a broken or unsafe runtime behavior.

### Better Answer

Syntactic correctness only means Kubernetes accepts the YAML. Operational safety depends on secrets, probes, image access, networking, resource sizing, dependencies, and whether the application is actually healthy in runtime.

## 23. How do you think about blast radius in Kubernetes?

### Short Answer

Reduce blast radius through isolation, least privilege, controlled rollouts, and clear ownership.

### Better Answer

I try to reduce blast radius through namespaces, RBAC, small changes, progressive rollout patterns, and avoiding overly broad permissions or shared resources where they are not necessary.

## 24. What are common Kubernetes anti-patterns?

### Short Answer

No requests or limits, weak probes, secrets in images, manual hotfixes, and poor observability.

### Better Answer

I also watch for bad label design, unclear ownership, direct Pod management in production, environment drift, and deployments that ignore dependency readiness and rollback planning.

## 25. What should a strong senior Kubernetes answer include?

### Short Answer

Tradeoffs, troubleshooting, runtime safety, security, and rollout thinking.

### Better Answer

A stronger answer should go beyond definitions and explain how manifests behave in real environments, how failures are diagnosed, how permissions and blast radius are controlled, and how the platform stays observable and recoverable in production.
