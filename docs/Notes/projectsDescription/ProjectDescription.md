# Enterprise Cloud Security Scanner Platform / Scanner-in-a-Box

## Resume Project Points

- Worked on an enterprise cloud security scanner platform involving Avira, Bitdefender, CDR, ThreatGrid, and scanning-service gateway components using Java 17, Spring Boot, Docker, Kubernetes, Jenkins, AWS ECR, Terraform/Terragrunt, ArgoCD, Helm, and GitOps.

- Built and improved CI/CD and deployment automation for scanner services, including Jenkins pipeline stages, Maven build/test flow, SonarQube scan, Docker image publishing, ECR integration, Terraform-based Kubernetes deployment, secrets validation, health checks, and dev/stage release gates.

- Contributed to Scanner-in-a-Box / SSE-in-a-Box GitOps deployment by configuring ArgoCD Applications, Helm chart references, Kustomize overlays, ExternalSecrets, AWS Secrets Manager mappings, image pull secrets, and GCP-dev/SIB deployment readiness.

## Complete Project Description

The Enterprise Cloud Security Scanner Platform is a cloud-native security scanning system used to scan files and URLs through multiple scanner engines and supporting services. The platform includes Avira scanner, Bitdefender scanner, CDR scanner, ThreatGrid services, scanner updater services, scanning-service gateway, shared scanner REST framework components, and deployment automation.

The scanner services are built using Java and Spring Boot, packaged as Docker images, published to AWS ECR, and deployed on Kubernetes. The platform uses Jenkins for CI/CD, Maven for build and test execution, SonarQube for code quality checks, Terraform/Terragrunt for Kubernetes and cloud infrastructure resources, and ArgoCD/Helm/Kustomize for GitOps-based deployment.

The project also included Scanner-in-a-Box / SSE-in-a-Box deployment work for GCP-dev environments. In this model, scanner services are deployed declaratively using ArgoCD Applications, Helm OCI charts, Kustomize overlays, External Secrets Operator, Kubernetes Secrets, image pull secrets, and environment-specific Helm values.

## My Responsibilities

- Developed and maintained backend scanner services and platform deployment flows using Java 17, Spring Boot, Maven, Docker, and Kubernetes.

- Worked on Jenkins CI/CD pipelines for build, test, SonarQube analysis, quality gate handling, Docker image creation, ECR publishing, image tag validation, and dev/stage deployment gates.

- Created and updated Terraform/Terragrunt Kubernetes resources including Deployments, Services, Secrets, certificates, service accounts, RBAC, pod disruption budgets, monitor deployments, and network policies.

- Integrated AWS Secrets Manager and External Secrets Operator for secure runtime configuration without storing secret values in Git.

- Configured Scanner-in-a-Box GitOps deployment resources such as ArgoCD Applications, Helm chart references, Kustomize overlays, ExternalSecrets, image pull secrets, namespace resources, and GCP-dev/SIB environment values.

- Troubleshot deployment issues related to ECR authentication, image pull errors, ArgoCD sync failures, ExternalSecret readiness, pod startup failures, health checks, Kubernetes readiness/liveness probes, and registry credential refresh.

- Improved local development setup using Docker, Docker Compose, local Dockerfiles, run scripts, environment overrides, health-check configuration, and troubleshooting documentation.

- Added and validated automated testing flows using JUnit, Mockito, Cucumber, endpoint contract tests, integration tests, and tag-based test execution for scanner services.

## Key Modules / Areas Worked On

- Avira scanner and updater deployment readiness
- Bitdefender scanner and updater deployment readiness
- CDR scanner CI/CD, Docker, Terraform, and Kubernetes deployment readiness
- ThreatGrid services and uploader GitOps deployment
- Scanning-service gateway deployment planning
- Scanner REST framework and shared scanner platform components
- Scanner-in-a-Box / SSE-in-a-Box GCP-dev GitOps overlays
- Jenkins pipeline, AWS ECR image publishing, and Helm OCI chart deployment flow
- AWS Secrets Manager, ExternalSecrets, Kubernetes Secrets, certificates, and image pull secrets

## Technical Stack

Java 17, Spring Boot, Maven, REST APIs, Docker, Kubernetes, Jenkins, AWS ECR, AWS Secrets Manager, Terraform, Terragrunt, ArgoCD, Helm, Kustomize, External Secrets Operator, SonarQube, JUnit, Mockito, Cucumber, Git, YAML, CI/CD, GitOps.

## Interview Explanation

I worked on a cloud security scanner platform where multiple scanner engines such as Avira, Bitdefender, CDR, and ThreatGrid services are deployed as cloud-native services. My work covered both backend service readiness and platform deployment automation.

On the CI/CD side, I worked on Jenkins pipelines that build Java/Spring Boot services, run tests and SonarQube checks, build Docker images, publish images to AWS ECR, validate image tags, and trigger dev/stage deployments. On the infrastructure side, I worked with Terraform, Terragrunt, Kubernetes, service accounts, RBAC, network policies, certificates, pod health checks, and monitor deployments.

For Scanner-in-a-Box, I worked on the GitOps deployment model where scanner services are deployed to GCP-dev/SIB environments through ArgoCD, Helm OCI charts, Kustomize overlays, and External Secrets Operator. I configured ArgoCD Applications, Helm values, AWS Secrets Manager references, ExternalSecrets, and image pull settings, and also debugged ArgoCD sync and Kubernetes runtime issues.

## Short Resume Format

Project: Enterprise Cloud Security Scanner Platform / Scanner-in-a-Box

Project Description:
Worked on a cloud-native security scanner platform used for file and URL scanning through multiple scanner engines such as Avira, Bitdefender, CDR, ThreatGrid, and scanning-service gateway. The CDR scanner integrates with a third-party Content Disarm and Reconstruction API for secure file sanitization. The platform is deployed on Kubernetes using Jenkins CI/CD, Docker, AWS ECR, Terraform/Terragrunt, ArgoCD, Helm, Kustomize, and GitOps practices.

My Responsibilities:
- Developed and maintained Java/Spring Boot scanner services and deployment flows.
- Worked on CDR scanner integration with a third-party sanitization API, including API endpoint configuration, tenant/API credential handling, AWS Secrets Manager mapping, runtime environment variables, and deployment validation.
- Built and improved Jenkins CI/CD pipelines for build, test, SonarQube scan, Docker image publishing, ECR integration, and dev/stage deployments.
- Created and updated Kubernetes/Terraform resources such as deployments, services, secrets, certificates, RBAC, PDBs, monitor deployments, and network policies.
- Configured Scanner-in-a-Box GitOps deployment using ArgoCD Applications, Helm charts, Kustomize overlays, ExternalSecrets, AWS Secrets Manager, and image pull secrets.
- Troubleshot ECR authentication, ArgoCD sync failures, ExternalSecret readiness, pod startup issues, and Kubernetes health-check failures.

