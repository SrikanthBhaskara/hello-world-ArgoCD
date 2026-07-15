# ArgoCD Senior 5 to 7 Years Production Interview Guide

This guide helps you answer ArgoCD and GitOps questions with production safety and multi-environment thinking.

---

## What Strong ArgoCD Answers Should Include

- desired state and drift thinking
- deployment safety
- rollback and sync behavior
- repo structure and change review
- failure isolation across apps and environments

---

## 1. GitOps in Real Systems

Strong answer:

GitOps is not only syncing YAML from Git. It is a controlled operating model where desired state is versioned, reviewed, auditable, and continuously reconciled.

---

## 2. Sync and Drift

Explain:

- why drift matters
- when auto-sync is useful
- when manual sync is safer
- how pruning or self-heal can become risky if misused

---

## 3. ApplicationSet and Multi-Environment Scale

Senior answers should include:

- consistency across clusters or apps
- generation risk if template mistakes affect many targets
- review discipline before mass rollout

---

## 4. Hooks, Waves, and Ordering

Strong answer:

Hooks and sync waves help sequence dependencies, but they also add release complexity, so I use them deliberately and test ordering behavior before production rollout.

---

## 5. Debugging ArgoCD Incidents

Typical checks:

- app health vs sync status
- controller logs
- repo revision
- generated manifests
- cluster events
- RBAC or secret dependency failures

---

## 6. Safe Production Changes

Before changing GitOps behavior:

- confirm affected apps and clusters
- validate generated manifests
- check prune/self-heal implications
- control blast radius
- keep rollback commit ready
