# ArgoCD / Kubernetes Interview Questions: Beginner (0 to 2 Years)

## Focus Areas

- Kubernetes fundamentals
- basic manifests
- `kubectl` basics
- pods, deployments, services
- namespaces and config basics
- GitOps basics

## Kubernetes Fundamentals

### 1. What is Kubernetes and why is it used?
Short answer:
Kubernetes is a container orchestration platform used to deploy, manage, and scale containerized applications.

Better answer:
Kubernetes helps teams run applications consistently by managing containers, networking, health checks, rollout behavior, and scaling. It becomes especially useful when multiple services need standardized deployment and recovery patterns.

### 2. What is a Pod?
Short answer:
A pod is the smallest deployable unit in Kubernetes and usually contains one or more closely related containers.

Better answer:
A pod represents a running instance of an application in Kubernetes. Containers inside a pod share networking and volumes, so they are treated as a unit. In many cases, one main application container runs per pod.

### 3. Difference between Pod and Deployment?
Short answer:
A pod is the runtime unit, while a deployment manages replicated pods and rollout behavior.

Better answer:
A deployment maintains the desired number of replicas, supports rolling updates, and recreates pods when needed. That is why we usually deploy stateless applications through deployments instead of raw pods.

### 4. Difference between Deployment and StatefulSet?
Short answer:
Deployment is mainly for stateless apps, while StatefulSet is for stateful apps needing stable identity or storage.

Better answer:
A deployment works when replicas are interchangeable. A StatefulSet is used when each pod needs a stable network identity, ordered startup or shutdown, or persistent storage tied to that specific pod.

### 5. What is a Service in Kubernetes?
Short answer:
A service provides stable network access to a set of pods.

Better answer:
Because pods can be recreated and their IPs can change, a service gives a stable endpoint for access. Common service types include `ClusterIP`, `NodePort`, and `LoadBalancer`.

### 6. What is a Namespace?
Short answer:
A namespace is a logical boundary used to organize and isolate resources in a cluster.

Better answer:
Namespaces help separate teams, applications, or environments inside the same cluster. They improve organization and can be combined with access control and quotas.

### 7. What is the use of labels and selectors?
Short answer:
Labels are key-value tags, and selectors use those labels to match resources.

Better answer:
Labels are fundamental in Kubernetes because services and controllers use them to find the correct resources. If selectors are wrong, traffic may not reach the intended pods even though resources exist.

## Config and Secrets

### 8. Difference between ConfigMap and Secret?
Short answer:
`ConfigMap` stores non-sensitive config, and `Secret` stores sensitive data.

Better answer:
Both externalize configuration from the container image, but they should be used according to sensitivity. In stronger setups, secret values come from systems like AWS Secrets Manager and are injected through operators or runtime integration.

### 9. Why should secrets not be hardcoded in YAML?
Short answer:
Hardcoded secrets are risky because they can leak through Git history, sharing, or logs.

Better answer:
Hardcoding secrets makes rotation difficult and increases exposure. A stronger approach is to keep only secret references in Git and fetch actual values from a secure secret manager.

### 10. What is an image pull secret?
Short answer:
It allows Kubernetes to authenticate to a private container registry.

Better answer:
When images are stored in a private registry, the cluster needs credentials to pull them. If the pull secret is missing or wrong, pods may fail with image pull errors.

## `kubectl` Basics

### 11. Which commands do you use most often for troubleshooting?
Short answer:
`kubectl get`, `describe`, `logs`, `exec`, `apply`, and `delete`.

Better answer:
I usually start with `get` for status, then `describe` for deeper detail and events, and `logs` for application output. `exec` is useful when I need to inspect behavior from inside the running container.

### 12. How do you see pod logs?
Short answer:
Use `kubectl logs <pod-name>`.

Better answer:
If a pod has multiple containers, I specify the container name. For restart cases, I also check previous logs because the current container may not show the original failure.

### 13. How do you check why a pod is not starting?
Short answer:
Check pod events, logs, image details, and required config or secrets.

Better answer:
I first classify the problem: scheduling issue, image pull issue, startup crash, probe failure, or dependency issue. Then I use `kubectl describe` and `kubectl logs` to gather evidence and verify related configuration.

### 14. What does `CrashLoopBackOff` usually mean?
Short answer:
It means the container starts, fails, and Kubernetes keeps retrying with backoff.

Better answer:
`CrashLoopBackOff` is a symptom, not the root cause. The actual problem may be application startup failure, missing environment variables, bad commands, or failing probes.

### 15. What does `ImagePullBackOff` usually mean?
Short answer:
It means Kubernetes cannot pull the container image.

Better answer:
Common reasons are wrong image name or tag, missing registry credentials, expired pull secret, or network access problems to the registry.

## ArgoCD Basics

### 16. What is ArgoCD?
Short answer:
ArgoCD is a GitOps tool that deploys Kubernetes applications by syncing cluster state with Git-managed manifests.

Better answer:
ArgoCD continuously compares the desired state from Git with the live cluster state and applies changes to bring them in sync. This makes deployments more traceable and less dependent on manual cluster updates.

### 17. What is GitOps in simple terms?
Short answer:
GitOps means Git is the source of truth for deployment configuration.

Better answer:
In GitOps, deployment definitions are version-controlled in Git and automation reconciles the live environment to match them. This improves reviewability, rollback visibility, and consistency across environments.

### 18. What is an ArgoCD Application?
Short answer:
It is a resource that tells ArgoCD what to deploy and from where.

Better answer:
It defines the source location, target cluster or namespace, and sync behavior. In practice it acts like the deployment contract between Git and the cluster.

### 19. Why is Git the source of truth in GitOps?
Short answer:
Because Git keeps deployment intent versioned, reviewable, and reproducible.

Better answer:
When Git is the source of truth, we can see who changed what, review changes before release, and recover known-good states more reliably. It also reduces hidden manual drift in clusters.

### 20. Difference between manual deployment and GitOps deployment?
Short answer:
Manual deployment relies on direct human action, while GitOps deployment applies version-controlled desired state.

Better answer:
Manual deployment may work for quick changes, but it is harder to audit and repeat. GitOps is stronger for teams because the deployment process is declarative, reviewable, and consistent.

## Beginner Scenarios

### 21. Pod is not running. What do you check first?
Short answer:
I check pod status, events, logs, image reference, and required config or secrets.

Better answer:
My first goal is to classify the failure: scheduling, image pull, startup crash, probe failure, or dependency issue. `kubectl describe` and `kubectl logs` usually give the fastest signal.

### 22. Service is deployed but app is not reachable. What do you check?
Short answer:
I check pod health, service selectors, endpoints, ports, namespace, and ingress or load balancer config.

Better answer:
I troubleshoot layer by layer. First I confirm the app is healthy inside the pod. Then I verify the service is selecting the correct pods and exposing the right port. After that I check ingress, load balancer, DNS, or network restrictions.

### 23. Secret is missing. Where do you look?
Short answer:
I check the secret resource, External Secret status, operator logs, namespace, and external source path.

Better answer:
I first confirm whether the secret should be created manually or through an operator. Then I inspect the store reference, key path, namespace, and reconciliation errors. Many secret issues are flow configuration problems rather than code issues.

### 24. ArgoCD app shows out of sync. What does that mean?
Short answer:
It means live cluster state does not match the desired state in Git or the rendered source.

Better answer:
This may happen because new Git changes are waiting to sync, manual changes were made in the cluster, or the previous sync failed. I inspect the diff and sync history before deciding the next action.

### 25. Deployment applied successfully but no pods are healthy. What basic checks do you perform?
Short answer:
I check pod events, logs, probes, environment variables, secrets, image pull behavior, and resource limits.

Better answer:
A successful apply only means the manifest was accepted, not that the application is healthy. I verify whether the correct image was deployed, whether secrets and config are available, whether the container starts correctly, and whether probes fit the startup behavior.

## What to Revise Before Interview

- pod, deployment, service
- namespace, labels, selectors
- ConfigMap vs Secret
- `kubectl get`, `describe`, `logs`
- ArgoCD basics and GitOps idea
- explain root-cause thinking, not only commands
