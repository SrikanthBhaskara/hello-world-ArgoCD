# Jenkins / Terraform / Terragrunt Interview Questions with Answers: Beginner to 6 Years

## Purpose

This file prepares you for interview rounds covering Jenkins, Terraform, and Terragrunt using both general knowledge and project-style delivery answers.

## Beginner (0 to 2 Years)

### 1. What is Jenkins?
Short answer:
Jenkins is a CI/CD automation server used to build, test, and deploy applications.

Better answer:
Jenkins automates repetitive delivery steps such as code checkout, build, test execution, quality checks, packaging, artifact publishing, and deployment triggers. It helps standardize CI/CD flow across teams.

### 2. What is a Jenkins pipeline?
Short answer:
A Jenkins pipeline is a scripted or declarative workflow that defines CI/CD stages.

Better answer:
A pipeline expresses the delivery flow as code, so the same build and deployment logic can be version-controlled, reviewed, and reused.

### 3. What is Terraform?
Short answer:
Terraform is an Infrastructure as Code tool used to define and provision infrastructure declaratively.

Better answer:
Terraform lets teams describe cloud or platform resources in code and apply them in a repeatable way. It is widely used for infrastructure provisioning, shared modules, and environment consistency.

### 4. What is Terragrunt?
Short answer:
Terragrunt is a wrapper around Terraform that helps manage shared configuration, remote state, and reusable infrastructure patterns.

Better answer:
Terragrunt reduces duplication across many Terraform modules and environments by centralizing backend config, shared variables, and reusable patterns.

### 5. Why use Infrastructure as Code instead of manual setup?
Short answer:
IaC is version-controlled, repeatable, reviewable, and auditable.

Better answer:
Manual infrastructure changes create drift and hidden knowledge. IaC improves consistency, enables peer review, and makes environment recreation easier.

## Intermediate (2 to 4 Years)

### 6. What typical stages do you expect in a Jenkins pipeline?
Short answer:
Checkout, build, unit tests, quality checks, package or image build, publish artifact, and deploy or trigger deployment.

Better answer:
The exact stages vary by team, but I expect clear validation, packaging, and traceability steps before anything reaches an environment.

### 7. What is the difference between declarative and scripted Jenkins pipeline?
Short answer:
Declarative pipelines are more structured, while scripted pipelines are more flexible.

Better answer:
Declarative syntax is easier to standardize and maintain for most teams. Scripted pipelines are useful when the flow needs advanced logic, but they can become harder to read if overused.

### 8. How does Jenkins fit with Docker and Kubernetes?
Short answer:
Jenkins can build artifacts, create Docker images, push them to a registry, and trigger Kubernetes or GitOps-based deployment flow.

Better answer:
In many setups, Jenkins handles CI and artifact creation, while Kubernetes or GitOps tools handle runtime reconciliation. That separation keeps delivery cleaner.

### 9. What is Terraform state and why is it important?
Short answer:
Terraform state tracks the real-world resources Terraform manages.

Better answer:
State is critical because Terraform uses it to understand what already exists and what must change. Because state may include sensitive values, it should be protected and stored carefully.

### 10. Why is remote state important?
Short answer:
Remote state supports collaboration, locking, and consistency across team members and CI systems.

Better answer:
Without remote state, different operators or pipelines may act on stale information and create conflicting changes.

### 11. What Terraform commands should you know well?
Short answer:
`init`, `plan`, `apply`, `destroy`, `fmt`, and `validate`.

Better answer:
I also expect people to understand when to use `plan` carefully, how to read its blast radius, and why `validate` and formatting should be part of CI.

### 12. What problem does Terragrunt solve in real projects?
Short answer:
It reduces repeated Terraform code and helps organize many environments consistently.

Better answer:
Terragrunt is especially useful when the same infrastructure patterns must be applied across multiple accounts, regions, or environments with small differences.

### 13. How do you handle secrets in Jenkins and Terraform flows?
Short answer:
Secrets should come from secure secret stores or credential systems, not from source code.

Better answer:
I avoid hardcoding credentials in pipeline files or Terraform variables. I prefer secret managers, CI credential stores, and least-privilege access tied to the environment.

## Experienced (4 to 6 Years)

### 14. How do you design a reliable Jenkins pipeline for enterprise delivery?
Short answer:
Use clear stages, fail-fast validation, secure credentials, traceable artifacts, and controlled deployment gates.

Better answer:
A reliable pipeline should produce reproducible outputs, surface errors early, enforce quality standards, and preserve enough logs and metadata to support audit and troubleshooting.

### 15. How do Terraform and Terragrunt fit together in a platform team?
Short answer:
Terraform defines resources, and Terragrunt helps organize and reuse those Terraform modules at scale.

Better answer:
Terraform is the provisioning engine. Terragrunt adds structure for many environments by reducing duplication and standardizing backend and variable patterns.

### 16. How do you explain your Jenkins experience from this project?
Short answer:
I worked on Jenkins-driven build and deployment automation for Java and scanner services.

Better answer:
My work included build stages, Maven test execution, SonarQube checks, Docker image creation, registry publishing, tag validation, and deployment gating for downstream environments.

### 17. How do you explain your Terraform and Terragrunt experience from this project?
Short answer:
I worked on environment-specific infrastructure and deployment resources managed through Terraform and Terragrunt.

Better answer:
That included reusable configuration for Kubernetes-related resources, secrets integration, certificates, RBAC, services, and deployment-ready platform components with consistent environment handling.

### 18. What are common failures in Jenkins pipelines?
Short answer:
Flaky tests, dependency resolution issues, bad credentials, registry failures, and hidden environment assumptions.

Better answer:
Pipeline failures often reveal deeper design problems such as poor artifact traceability, fragile scripts, or unclear ownership of release steps.

### 19. What are common failures in Terraform and Terragrunt workflows?
Short answer:
State locking problems, infrastructure drift, dependency ordering issues, bad variable config, and permission failures.

Better answer:
I also watch for dangerous replacements, wrong backend setup, and module assumptions that work in one environment but not another.

### 20. How do you review Infrastructure as Code changes safely?
Short answer:
Review correctness, blast radius, secret handling, idempotence, dependencies, and rollback impact.

Better answer:
I pay close attention to anything that deletes or replaces existing resources, changes network exposure, or alters shared modules used by multiple environments.

### 21. How do Jenkins and GitOps coexist?
Short answer:
Jenkins can build and publish validated artifacts, while GitOps controllers reconcile deployment state from Git.

Better answer:
That separation works well because Jenkins focuses on CI and artifact readiness, and GitOps focuses on runtime convergence and drift control.

### 22. In this project, how would you explain the full delivery chain?
Short answer:
Code changes trigger CI, the application is built and validated, the image or artifact is published, and deployment state is promoted through controlled environment definitions.

Better answer:
A strong end-to-end explanation is: source change enters Jenkins, Maven and tests validate it, SonarQube checks quality, Docker packages the service, the image is pushed to a registry such as ECR, infrastructure or deployment definitions are managed through Terraform or Terragrunt and GitOps-aware repositories, and the runtime platform applies the desired state in Kubernetes.

## Quick Revision Topics

- Jenkins pipeline stages
- declarative vs scripted pipeline
- Terraform state and remote state
- Terragrunt reuse patterns
- CI secrets handling
- IaC blast radius review
