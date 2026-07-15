# Docker Senior 5 to 7 Years Production Interview Guide

This guide helps you answer Docker questions with engineering and production depth.

---

## What Strong Docker Answers Should Include

- image design choices
- runtime failure modes
- security and supply chain awareness
- operational debugging
- container vs host tradeoffs

---

## 1. Images vs Containers

Do not stop at the definition.

Explain:

- images are immutable build artifacts
- containers are running instances
- image quality affects startup speed, security, and reproducibility

---

## 2. Dockerfile Best Practices

Strong answer should mention:

- small base images where practical
- multi-stage builds
- explicit versioning
- non-root runtime where possible
- avoiding secrets in image layers

### Tradeoff

Very small images reduce attack surface, but can make runtime debugging harder if you remove too many utilities.

---

## 3. Image Tags and Deployment Safety

Strong answer:

Using mutable tags like `latest` increases release ambiguity. Immutable version tags are safer for rollback and incident analysis.

---

## 4. Volumes and Data Safety

Interviewers may expect:

- difference between container filesystem and persistent storage
- why data should not live only in ephemeral container layers
- backup and migration implications

---

## 5. Container Debugging

If a container fails:

- check `docker ps -a`
- inspect logs
- inspect environment/config
- verify network reachability
- verify mounted volumes
- verify entrypoint/command behavior

### Senior answer pattern

Differentiate whether the problem is image build, runtime config, dependency access, filesystem, or resource behavior.

---

## 6. Resource Controls

Strong answers mention:

- CPU and memory limits
- noisy-neighbor risk
- OOM behavior
- observability before changing limits

---

## 7. Security Thinking

Explain:

- non-root containers
- image scanning
- base image trust
- secret handling
- least privilege

### Strong line

"Containerization improves packaging consistency, but it does not automatically make an application secure."

---

## 8. Production-Safe Docker Changes

Before release:

- verify image immutability
- scan image
- confirm entrypoint and health behavior
- validate runtime config and secrets
- keep rollback tag ready
