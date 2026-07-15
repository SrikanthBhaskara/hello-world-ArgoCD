# Security and Compliance Deep Notes

## Security Mindset for 5 to 7 Years Experience
- Interviewers usually expect more than "use HTTPS".
- They want to hear how you reduce blast radius, secure pipelines, protect secrets, and make systems auditable.

## Encryption in Transit
- Use TLS for all external and internal sensitive traffic.
- Prefer modern TLS configuration and strong cipher suites from platform defaults.
- Terminate TLS carefully:
  - edge load balancer
  - ingress controller
  - service mesh, if used
- For high-trust environments, consider mutual TLS for service-to-service communication.

## Encryption at Rest
- Encrypt:
  - databases
  - object storage
  - block volumes
  - backups
  - secret stores
- Use cloud-managed KMS where possible.
- Rotate keys according to policy and automate access control around them.

## Secrets Management
- Never keep secrets in source control.
- Use:
  - AWS Secrets Manager
  - AWS Parameter Store
  - HashiCorp Vault
  - Kubernetes External Secrets integration
- Rotate secrets and scope access by least privilege.

## CI/CD Pipeline Security

### Risks
- hardcoded credentials
- overly broad runner permissions
- dependency poisoning
- unsigned artifacts
- unreviewed production deployment triggers

### Good Controls
- short-lived credentials
- OIDC-based federation for CI runners
- branch protection and mandatory reviews
- artifact repository scanning
- secret scanning
- SBOM generation
- signed container images and provenance where possible

## Secure Build and Release Flow
1. developer pushes code
2. PR checks run tests, static analysis, SCA, secret scan
3. artifact is built once
4. artifact is signed and stored
5. deployment uses the verified artifact, not a rebuilt one
6. audit trail captures who approved and what was deployed

## OWASP-Oriented Application Security
- Treat the common web risks seriously:
  - injection
  - broken authentication
  - broken access control
  - security misconfiguration
  - vulnerable dependencies
  - insecure deserialization
  - SSRF-style trust issues
- The exact published categories can evolve, so in interviews focus on the control mindset:
  - input validation
  - output encoding
  - parameterized queries
  - least privilege
  - dependency hygiene
  - secure defaults

## IAM and Least Privilege
- Give users, services, runners, and pods only the permissions they need.
- Prefer role assumption over long-lived access keys.
- Separate read, write, deploy, and admin privileges.

## API and Service Security
- OAuth2 or OIDC for delegated auth
- JWT validation with issuer, audience, expiry, and signature checks
- RBAC or ABAC for authorization
- rate limiting and WAF for abuse protection
- audit logging for sensitive actions

## Data Privacy and Compliance

### GDPR-Type Thinking
- know what personal data you collect
- define retention period
- support deletion or anonymization workflows where required
- minimize unnecessary data storage
- secure cross-border data handling based on policy

### HIPAA-Type Thinking
- protect health-related data carefully
- enforce access auditing
- encrypt at rest and in transit
- restrict data exposure and logging

Interview-safe note:
- Do not claim compliance by using one tool. Compliance is process, control, evidence, and auditability.

## Logging and Sensitive Data
- Never log secrets, tokens, or full payment details.
- Mask PII where possible.
- Restrict who can access application logs and traces.

## Vulnerability Management
- dependency scanning
- base image scanning
- OS package patching
- container runtime hardening
- regular remediation SLAs

## Kubernetes Security Examples
- run containers as non-root where possible
- use read-only root filesystem when suitable
- restrict hostPath and privileged mode
- use network policies
- scope service accounts
- avoid secret values in plain manifests

## Incident Response Basics
- detect suspicious behavior
- contain blast radius
- rotate exposed credentials
- identify timeline and root cause
- patch and add preventive control
- preserve audit trail

## Interview Questions

### How do you secure a CI/CD pipeline?
Short answer:
Use least privilege, short-lived credentials, scanning, artifact integrity, and gated deployments.

Better answer:
I secure the pipeline end to end: protect the source branch, use ephemeral credentials through federation, scan code and dependencies, prevent secrets from entering the repo, sign and track build artifacts, and make production deployment auditable and approval-driven for high-risk changes.

### What is the difference between security and compliance?
Short answer:
Security reduces risk; compliance proves required controls exist and are followed.

Better answer:
Security is the ongoing engineering discipline of preventing, detecting, and responding to threats. Compliance adds documented controls, evidence, retention, reviews, and auditability against a required framework such as privacy or healthcare standards.
