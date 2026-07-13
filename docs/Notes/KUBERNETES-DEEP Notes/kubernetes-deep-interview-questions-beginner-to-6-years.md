# Kubernetes Deep Interview Questions with Answers: Beginner to 6 Years

## Purpose

This file focuses on deeper Kubernetes interview preparation with answers that are useful for real project and troubleshooting rounds.

## Beginner (0 to 2 Years)

### 1. What is Kubernetes?
Short answer:
Kubernetes is a container orchestration platform used to deploy, scale, and manage containerized applications.

Better answer:
Kubernetes provides a control plane that manages workloads declaratively. Instead of manually running containers, we define the desired state and Kubernetes works to keep runtime behavior aligned with that definition.

### 2. What is a Pod?
Short answer:
A Pod is the smallest deployable unit in Kubernetes and usually contains one application container.

Better answer:
A Pod represents one logical workload instance with shared network namespace and storage context for its containers. In most application cases, one main container runs in each Pod.

### 3. Difference between a Pod and a Deployment?
Short answer:
A Pod is a running workload unit, while a Deployment manages replicated Pods and rollout behavior.

Better answer:
Pods are ephemeral and not ideal for direct management in production. Deployments add higher-level lifecycle control such as replica management, rolling updates, and recovery from Pod loss.

### 4. What is a Service?
Short answer:
A Service provides stable networking to a set of Pods selected by labels.

Better answer:
Because Pods can be recreated and their IPs can change, Services give a stable network identity and route traffic to the correct Pod set.

### 5. What are ConfigMaps and Secrets?
Short answer:
They externalize configuration, with Secrets intended for sensitive values.

Better answer:
ConfigMaps hold non-sensitive configuration such as flags or URLs. Secrets are used for credentials, tokens, or certificates. Both help keep configuration outside application images.

## Intermediate (2 to 4 Years)

### 6. Difference between readiness and liveness probes?
Short answer:
Readiness decides whether the Pod receives traffic, while liveness decides whether Kubernetes should restart it.

Better answer:
A readiness probe protects users from traffic reaching an unready app. A liveness probe helps recover from a stuck or broken process. Confusing the two can cause unnecessary restarts or failed routing.

### 7. Difference between Deployment, StatefulSet, and DaemonSet?
Short answer:
Deployment is for stateless replicas, StatefulSet is for stable identity or storage needs, and DaemonSet runs one Pod per node.

Better answer:
These controllers solve different workload patterns. Interviewers want to hear not just definitions, but when each controller is operationally appropriate.

### 8. What are resource requests and limits?
Short answer:
Requests affect scheduling and limits cap maximum resource use.

Better answer:
Requests tell the scheduler what a Pod needs at minimum. Limits help prevent one workload from consuming too much CPU or memory. Misconfigured resources often cause instability.

### 9. How do you debug `CrashLoopBackOff`?
Short answer:
Check `kubectl describe pod`, logs, command, env vars, mounted config, and probe behavior.

Better answer:
I usually start with events and previous logs, then inspect whether the app is crashing on startup, whether configuration is missing, or whether probes are killing a slow-starting process.

### 10. How do you debug `ImagePullBackOff`?
Short answer:
Validate the image path, tag, registry access, and image pull secret or service-account configuration.

Better answer:
An `ImagePullBackOff` often means runtime access failed even though the deployment manifest applied correctly. I inspect the event message carefully to identify auth, tag, or network issues.

### 11. Why do labels and selectors matter so much?
Short answer:
They connect Kubernetes resources to the correct workloads.

Better answer:
Services, Deployments, NetworkPolicies, and many other resources rely on labels and selectors. Bad label design causes routing, ownership, and policy mistakes.

### 12. What is the purpose of a Namespace?
Short answer:
A Namespace separates workloads logically and helps with organization and access control.

Better answer:
Namespaces help isolate teams, applications, and environments. They also support quotas, RBAC boundaries, and blast-radius reduction.

## Experienced (4 to 6 Years)

### 13. How do you troubleshoot a workload layer by layer?
Short answer:
Check manifest correctness, dependencies, scheduling, events, logs, probes, services, ingress, and platform controllers.

Better answer:
I troubleshoot Kubernetes in layers because a failure may come from YAML, runtime config, secrets, certificates, network routing, or platform integrations such as External Secrets or cert-manager.

### 14. What are common production anti-patterns in Kubernetes?
Short answer:
No requests or limits, secrets in images, weak probes, manual cluster hotfixes, and poor observability.

Better answer:
I also watch for over-coupled manifests, unclear ownership, and deployment practices that bypass Git or promotion discipline.

### 15. How do you explain Kubernetes readiness from an operations perspective?
Short answer:
A deployment is ready only when dependencies, startup, health checks, and routing all work.

Better answer:
Applying YAML successfully is not enough. Real readiness means secrets, config, certificates, image pulls, probes, and service connectivity all succeed together.

### 16. What is the difference between a syntactically valid manifest and an operationally safe deployment?
Short answer:
A valid manifest can still produce a failing service.

Better answer:
Operational safety includes correct dependencies, secure secret handling, stable probe design, proper registry access, and application-level health behavior under real runtime conditions.

### 17. How do you explain your Kubernetes experience from this project?
Short answer:
I worked on deployment readiness, runtime troubleshooting, and GitOps-integrated Kubernetes delivery.

Better answer:
My work involved Deployments, Services, Secrets, certificates, service accounts, RBAC, health checks, image pull behavior, namespace resources, and debugging sync, startup, and runtime failures in a GitOps-driven environment.

### 18. How do you think about blast radius in Kubernetes design?
Short answer:
Reduce blast radius through isolation, least privilege, controlled rollouts, and environment discipline.

Better answer:
I prefer namespace separation, clear ownership, small reviewed changes, limited permissions, and rollout strategies that make failures easier to contain and reverse.

## Deep Troubleshooting Scenarios

### 19. Pod is Running but the app is still down. What next?
Short answer:
Check readiness, logs, service selectors, port mappings, config, secrets, and downstream dependencies.

Better answer:
A Running Pod only means the container process exists. It does not prove the app is healthy or reachable. I verify application startup, probe status, service wiring, and dependency readiness.

### 20. Pods are healthy but traffic still fails. What do you inspect?
Short answer:
Inspect the Service, Endpoints, Ingress or load balancer rules, DNS, network policies, and TLS behavior.

Better answer:
If Pods are healthy, the problem is usually in network wiring or edge configuration. I move outward from Pod to Service to Ingress to DNS and certificate layers.

### 21. Secret exists but the app still fails authentication. What do you check?
Short answer:
Check key names, mount or env wiring, secret freshness, application expectations, and whether restart or reload is needed.

Better answer:
I confirm the Secret contains the right keys and values, that the Pod actually consumes the intended Secret, and that the app format matches what the library or framework expects.

## Quick Revision Topics

- probes
- requests and limits
- namespace isolation
- label and selector logic
- pod event debugging
- service and endpoint troubleshooting
- dependency-aware deployment reasoning
