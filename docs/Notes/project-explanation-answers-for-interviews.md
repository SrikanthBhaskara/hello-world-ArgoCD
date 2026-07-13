# Project Explanation Answers For Interviews

These answers are aligned to the scanner platform and GitOps work in this repository.

## 1. Explain your current project.

Short answer:
I worked on a cloud-native security scanner platform where multiple scanner engines and related services were built and deployed using Java, Spring Boot, Docker, Kubernetes, Jenkins, AWS ECR, Terraform, ArgoCD, Helm, and GitOps.

Better answer:
I worked on an enterprise cloud security scanner platform used to scan files and URLs through multiple scanner engines such as Avira, Bitdefender, CDR, and ThreatGrid-related services. My work covered both backend service readiness and the platform delivery side, including Jenkins CI/CD, Docker image publishing to AWS ECR, Kubernetes deployment resources, Terraform and Terragrunt changes, and ArgoCD plus Helm based GitOps deployment flows.

## 2. What was your role in the project?

Short answer:
My role was a mix of backend development, CI/CD work, deployment automation, and production-style troubleshooting.

Better answer:
I worked on Java and Spring Boot service changes, Maven build and test flow, Jenkins pipeline improvements, containerization, Kubernetes deployment readiness, secret integration, and GitOps-based environment deployments. I also handled troubleshooting when issues occurred after deployment, such as secret mapping problems, ECR authentication failures, or pod health-check issues.

## 3. Which technologies did you use?

Short answer:
I used Java 17, Spring Boot, Maven, Docker, Kubernetes, Jenkins, AWS ECR, AWS Secrets Manager, Terraform, Terragrunt, ArgoCD, Helm, Kustomize, External Secrets, JUnit, Mockito, and SonarQube.

Better answer:
The main stack included Java 17 and Spring Boot for service development, Maven for build and testing, Docker for packaging, Jenkins for CI/CD, AWS ECR for image and chart storage, Kubernetes for runtime orchestration, Terraform and Terragrunt for infrastructure and deployment resources, and ArgoCD, Helm, Kustomize, and External Secrets for GitOps-based deployment.

## 4. How does your CI/CD flow work?

Short answer:
The pipeline builds the Java application, runs tests and quality checks, creates a Docker image, pushes it to ECR, and then deployment configuration is applied through Terraform or GitOps-based ArgoCD flows.

Better answer:
The CI/CD flow starts with source checkout and Maven build. Then tests and SonarQube analysis run, and quality gates are validated. After that the Docker image is built and published to AWS ECR. For deployment, environment-specific configuration is managed either through Terraform and Terragrunt resources or through GitOps paths where ArgoCD reads the desired state from Git and syncs the Kubernetes objects and Helm chart references.

## 5. How does GitOps fit into your project?

Short answer:
GitOps is used to keep deployment state in Git, and ArgoCD syncs the cluster to match that desired state.

Better answer:
In our GitOps model, deployment configuration such as ArgoCD Applications, Helm chart references, Kustomize overlays, values files, and ExternalSecret definitions are stored in Git. ArgoCD monitors those manifests and syncs the cluster state accordingly. That gives version control, reviewability, traceability, and repeatable deployments instead of relying on manual cluster changes.

## 6. How were secrets managed?

Short answer:
Secrets were not hardcoded in Git. We used AWS Secrets Manager and External Secrets Operator to pull values securely into Kubernetes.

Better answer:
We avoided storing secret values in source control. Secret references were maintained declaratively, while the actual sensitive values were stored in AWS Secrets Manager. External Secrets Operator read those values and created Kubernetes Secrets at runtime. This kept secrets centralized, auditable, and environment-specific while still fitting into the GitOps deployment model.

## 7. What kind of issues did you troubleshoot?

Short answer:
I handled image pull issues, ArgoCD sync failures, External Secret readiness issues, pod startup failures, and readiness or liveness probe problems.

Better answer:
A lot of real work was around deployment troubleshooting. Examples included ECR authentication issues that caused image pull errors, ArgoCD applications staying out of sync, External Secrets not getting resolved correctly, pods failing during startup because of missing runtime configuration, and readiness or liveness probes failing due to incorrect startup assumptions.

## 8. How do you explain your project in two minutes?

Short answer:
I worked on a cloud-native scanner platform where backend services were built in Java and Spring Boot, packaged with Docker, deployed on Kubernetes, and released through Jenkins, AWS ECR, Terraform, and ArgoCD-based GitOps workflows.

Better answer:
I worked on a cloud-native security scanner platform that used multiple scanner engines to process files and URLs. My contribution covered both application and platform layers. On the backend side, I worked with Java and Spring Boot services. On the delivery side, I worked on Maven build and test flow, Jenkins pipelines, Docker image creation, AWS ECR publishing, Kubernetes deployment resources, Terraform and Terragrunt changes, and ArgoCD plus Helm GitOps deployment.

## 9. What was the business value of your work?

Short answer:
My work improved deployment reliability, repeatability, and secure configuration management for scanner services.

Better answer:
The value was not only feature delivery. A big part of the impact was making deployments more reliable and less manual. By improving pipeline quality checks, container publishing, secret handling, GitOps configuration, and runtime troubleshooting, the platform became easier to release, easier to debug, and safer to operate across environments.

## 10. Why did you use Kubernetes and ArgoCD?

Short answer:
Kubernetes helped manage containerized services consistently, and ArgoCD helped automate declarative deployments from Git.

Better answer:
Kubernetes gave us a consistent way to run multiple services with health checks, scaling controls, networking, and resource isolation. ArgoCD fit well because our deployment model relied on declarative configuration and reviewable changes in Git. Together they reduced manual deployment drift and made environment rollouts more predictable.

## 11. Explain one production-style issue you solved.

Short answer:
One common issue was a pod failing after deployment because secret values were not available or image access was misconfigured.

Better answer:
My approach was to validate whether the image existed and was accessible, check whether External Secrets had created the expected Kubernetes Secret, inspect deployment events and pod logs, verify environment variables and mount references, and then correct the configuration source rather than only restarting pods.

## 12. Best structure to answer any project question

Use this structure:
1. What the system does.
2. What technologies are involved.
3. What exactly you owned.
4. One challenge you solved.
5. The business or operational impact.
