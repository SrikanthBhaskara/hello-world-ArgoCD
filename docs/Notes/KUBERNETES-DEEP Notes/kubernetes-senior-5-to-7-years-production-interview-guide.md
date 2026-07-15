# Kubernetes Senior 5 to 7 Years Production Interview Guide

This guide helps you answer Kubernetes questions with production thinking instead of only cluster definitions.

---

## What Strong Kubernetes Answers Should Include

- workload behavior under failure
- rollout safety
- debugging flow
- scheduling and resource tradeoffs
- security and multi-team implications

---

## 1. Pods, Deployments, and Services

Do not stop at resource definitions.

Explain:

- Pod lifecycle and replacement behavior
- why Deployments manage stateless rollouts well
- how Services decouple clients from Pod churn
- what happens during rollout, restart, or failure

---

## 2. Readiness vs Liveness Probes

Strong answer:

Readiness controls traffic eligibility. Liveness controls restart behavior when the container is unhealthy.

### Production angle

An incorrect readiness probe causes bad traffic routing. An incorrect liveness probe can create restart loops and amplify incidents.

### Safe rollout note

Tune probes gradually and validate with rollout status and metrics.

---

## 3. Requests and Limits

Interviewers expect:

- scheduling implications
- throttling risk
- OOMKill behavior
- cluster efficiency tradeoff

### Strong answer

Requests affect scheduling guarantees. Limits cap usage, but overly tight limits can create CPU throttling or OOM problems.

---

## 4. ConfigMaps and Secrets

Go beyond "ConfigMap is for config and Secret is for secrets."

Explain:

- config separation from image
- update behavior
- secret access scope
- operational and security risks

---

## 5. Common Debugging Flow

If a workload is failing:

1. `kubectl get pods`
2. `kubectl describe pod`
3. `kubectl logs`
4. check events
5. verify config, secret, image, probe, and resource behavior

### Senior answer pattern

Start from observed symptom, then narrow to scheduling, image, application, network, dependency, or configuration failure.

---

## 6. Networking and Ingress

Strong answer should include:

- Service type choice
- ingress controller dependency
- DNS and certificate behavior
- east-west vs north-south traffic

### Tradeoff

More ingress flexibility often adds controller, annotation, and routing complexity.

---

## 7. RBAC and Security

Strong answer:

RBAC is not just about making commands work. It is about preventing excessive blast radius across teams and workloads.

Mention:

- least privilege
- namespace isolation
- service account scope
- sensitive admin verbs

---

## 8. Production-Safe Kubernetes Changes

Before rollout:

- confirm backward compatibility
- check probe behavior
- check resource settings
- check secret/config dependencies
- confirm rollback path

### Good answer line

"I verify not only whether the manifest is valid, but whether the rollout can fail safely under real traffic."
