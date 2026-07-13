# Scenario-Based Mock Interview Rounds

Use these rounds for speaking practice. Try to answer each question in 60 to 120 seconds before reading the ideal answer.

## Round 1: Java and Spring Boot

### 1. Your Spring Boot service is getting slow after a new release. How would you troubleshoot?
Ideal answer:
I would first confirm whether the slowdown is real and identify where it appears, such as one API, all APIs, startup time, or database interaction. Then I would check application logs, metrics, thread usage, database query timings, and recent config changes. I would compare the current release with the previous stable version and isolate whether the issue is in business logic, external API calls, or infrastructure.

### 2. What is the difference between `HashMap` and `ConcurrentHashMap`, and when would you choose each?
Ideal answer:
`HashMap` is not thread-safe and is suitable for single-threaded or externally synchronized use. `ConcurrentHashMap` is designed for concurrent access and performs better than synchronizing the whole map in multi-threaded scenarios. I would choose `HashMap` for simple local data handling and `ConcurrentHashMap` when multiple threads need shared access with good concurrency.

### 3. Why would you use `Optional`, and where would you avoid it?
Ideal answer:
`Optional` makes absence explicit and helps reduce accidental `NullPointerException` usage in method return values. It is useful when a value may or may not be present and the caller should handle that intentionally. I usually avoid using it for entity fields or DTO fields because that can make code noisy and awkward for serialization or persistence layers.

## Round 2: Docker and Kubernetes

### 4. A pod is in `CrashLoopBackOff`. What would you do?
Ideal answer:
I would inspect the pod events and container logs using `kubectl describe pod` and `kubectl logs`. Then I would check whether the container command is failing, whether required environment variables or secrets are missing, whether the image contains the expected artifact, and whether readiness or liveness settings are too aggressive.

### 5. The deployment is successful but the application is not reachable. What checks would you do?
Ideal answer:
I would validate the path layer by layer: pod status, container port, service selector, service endpoints, ingress or load balancer configuration, namespace correctness, and any network policy restrictions. I also check whether the application is actually listening on the expected port.

### 6. Why is it risky to keep secrets in Git?
Ideal answer:
Keeping secrets in Git increases long-term exposure because repositories are copied, cloned, backed up, and sometimes shared more widely than intended. A better pattern is storing sensitive values in a secret manager and using controlled runtime injection.

## Round 3: GitOps, ArgoCD, Helm, External Secrets

### 7. An ArgoCD application is out of sync. How do you explain that?
Ideal answer:
It means the live cluster state differs from the desired state stored in Git or from the rendered manifest source. That can happen because new Git changes are pending sync, someone changed resources manually in the cluster, or a sync operation failed partially.

### 8. How does Helm help in Kubernetes deployments?
Ideal answer:
Helm helps package Kubernetes manifests into reusable charts with parameterized values. Instead of copying static YAML for each environment, we can keep one chart and pass different values for image tags, resources, and environment-specific settings.

### 9. How would you troubleshoot if External Secrets are not creating Kubernetes secrets?
Ideal answer:
I would check whether the `ExternalSecret` resource is healthy, whether the referenced `SecretStore` or `ClusterSecretStore` is reachable, whether IAM or cloud permissions are correct, whether the external key path exists, and whether the operator logs show reconciliation errors.

## Round 4: Jenkins, Terraform, AWS

### 10. A Jenkins build passes unit tests but the deployment later fails because the image is missing. What do you check?
Ideal answer:
I would verify whether the Docker build stage actually ran, whether the image was tagged correctly, whether the push to ECR succeeded, and whether the downstream deployment references the same image tag. This kind of issue is often a mismatch between build output and deployment input.

### 11. What is the use of Terraform and Terragrunt in a project like yours?
Ideal answer:
Terraform helps define infrastructure and environment resources declaratively, while Terragrunt helps organize shared configuration, reduce duplication, and manage multiple environments more cleanly. In a project like ours, that is useful for Kubernetes-related resources and reusable environment structures.

### 12. How do you secure deployment credentials in AWS-integrated pipelines?
Ideal answer:
The key principle is to avoid hardcoding credentials. I prefer role-based access, secret managers, short-lived tokens where possible, and least-privilege permissions. In pipeline and Kubernetes flows, I also separate secret references from actual secret values and use audit-friendly mechanisms like AWS Secrets Manager.

## Round 5: Project and Ownership

### 13. Explain a recent issue you solved end to end.
Ideal answer:
One strong example is a deployment issue where everything looked correct in source control, but the application still failed after rollout. I traced it through image availability, secret injection, ArgoCD sync status, pod events, and container logs. The issue turned out to be configuration and runtime dependency related rather than code logic.

### 14. What part of the project did you personally own?
Ideal answer:
I owned work across multiple layers rather than a single narrow module. That included backend service readiness, Jenkins build and quality flow, Docker packaging, ECR publishing, Kubernetes deployment updates, GitOps manifest changes, and post-deployment validation.

### 15. If you join our team, what will you ramp up on first?
Ideal answer:
I would first understand the architecture, deployment path, operational pain points, and ownership boundaries. Then I would study one service deeply from code to release path to runtime behavior so I can contribute quickly and safely.
