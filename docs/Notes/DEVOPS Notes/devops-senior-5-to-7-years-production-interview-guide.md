# DevOps Senior 5 to 7 Years Production Interview Guide

This guide focuses on how to answer DevOps questions with system ownership, reliability, and delivery tradeoff thinking.

---

## What Strong DevOps Answers Should Include

- delivery safety
- environment consistency
- observability
- rollback design
- reliability and operability

---

## 1. CI/CD Is Not Just Automation

Strong answer:

CI/CD is about safe, repeatable delivery with quality gates, traceability, and rollback readiness, not just running build scripts automatically.

### Good themes

- build reproducibility
- test gates
- artifact immutability
- deployment traceability
- rollback path

---

## 2. GitOps Thinking

Explain:

- Git as desired state
- auditability
- drift detection
- change review
- safer cluster operations

### Tradeoff

GitOps improves traceability and consistency, but can slow urgent manual changes unless break-glass procedures are designed clearly.

---

## 3. Rollback Strategy

Strong answers should include:

- what can be rolled back
- how quickly rollback can happen
- whether data or schema changes are reversible
- whether rollback itself is safe

### Senior line

"A rollback plan is incomplete if it only covers application code and ignores config, secrets, schema, or traffic routing."

---

## 4. Observability

Mention:

- logs
- metrics
- traces
- alerts
- SLO-friendly signals

### Strong answer

I want enough visibility to detect failure, localize the boundary, confirm impact, and verify recovery after the fix.

---

## 5. Incident Thinking

Strong incident answers include:

- symptom
- impact
- evidence
- containment
- root cause
- prevention

### Weak answer

- "We restarted the app."

### Better answer

- "We used restart as containment, but also traced the underlying resource or dependency issue and added prevention."

---

## 6. Change Safety

Before a production change:

- identify blast radius
- verify permissions and environment impact
- validate rollback
- confirm observability
- prefer staged rollout

---

## 7. Common Tradeoffs

- speed vs safety
- flexibility vs standardization
- central platform control vs team autonomy
- cost vs redundancy
- simplicity vs feature richness

A strong senior answer explains which side was prioritized and why.
