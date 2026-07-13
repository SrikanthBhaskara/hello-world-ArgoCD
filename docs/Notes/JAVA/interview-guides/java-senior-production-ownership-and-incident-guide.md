# Java Senior Production Ownership and Incident Guide

## Purpose

This file is for 5 to 7 year engineers who need stronger senior-level answers around production ownership.

Use it for:
- incident management rounds
- debugging and RCA discussions
- observability and reliability interviews
- senior ownership storytelling

## What Is Usually Missing in Mid-Level Answers

Mid-level answers often stop at the fix.

Senior answers should include:
- impact assessment
- investigation structure
- tradeoffs during mitigation
- root cause clarity
- prevention plan
- ownership after recovery

## Senior Incident Flow

1. understand customer or business impact
2. narrow blast radius
3. identify whether issue is app, dependency, data, infra, or config
4. stabilize safely
5. gather evidence before making risky changes
6. restore service
7. write root cause and prevention actions

## Areas Senior Engineers Must Speak About Clearly

### Observability
You should be comfortable explaining:
- metrics
- logs
- traces
- correlation IDs
- alert quality
- dashboards vs symptoms

### Reliability
You should discuss:
- retries and when not to retry
- timeouts
- circuit breaking
- graceful degradation
- bulkheads or isolation
- rollout safety

### Incident Ownership
You should explain:
- communication during incident
- decision-making under uncertainty
- tradeoff between fast rollback and deeper diagnosis
- postmortem quality

## Common Senior Production Scenarios

### Memory Growth Without Crash
What to cover:
- heap vs non-heap vs thread growth
- GC behavior
- retained object patterns
- load and cache behavior
- heap dump use
- whether the growth is leak or expected pressure

### Latency Spikes After Release
What to cover:
- release comparison
- dependency calls
- thread pool pressure
- DB query change
- connection pools
- rollback decision
- canary or feature flag strategy

### Kubernetes Pods Restarting Frequently
What to cover:
- probes
- resource requests and limits
- startup time
- dependency health
- config drift
- OOM vs crash loop vs external failure

### Duplicate Orders or Payments
What to cover:
- retry behavior
- idempotency keys
- eventual-consistency path
- consumer replay
- database uniqueness rules

## Senior RCA Structure

A good root cause explanation should include:
- what happened
- why it happened
- why existing controls did not stop it
- what fixed it immediately
- what will prevent recurrence

## Good Preventive Actions

- alert tuning
- dashboard improvements
- stricter validation
- load test coverage
- timeout or retry changes
- resource tuning based on data
- better rollout or canary safety
- stronger idempotency controls

## Strong Senior Phrases

- "I would separate symptom from root cause before deciding whether rollback or mitigation is safer."
- "The fix is not complete until we reduce the chance of recurrence."
- "I would verify whether this is a single-request issue, a load-shaped issue, or a dependency-wide issue."
- "During incidents, preserving evidence matters almost as much as restoring service."
- "A senior response includes recovery, learning, and prevention."

## Observability Questions You Should Answer Well

- What metrics would you add to this service?
- How would you trace a slow request across services?
- What makes an alert noisy vs useful?
- How do you know whether the DB is the bottleneck or the app layer is?
- What logs should be structured and why?

## Reliability Questions You Should Answer Well

- When is retry harmful?
- When should timeout be strict vs relaxed?
- How do you degrade gracefully when a dependency fails?
- How do you design safe rollout and rollback paths?
- How do you reduce blast radius in production?

## Practice Prompts

1. Explain one production incident in senior-level format.
2. Explain how you would debug rising latency after a release.
3. Explain your observability baseline for a new service.
4. Explain one case where retry made a system worse.

## Pair This With

- [5 to 7 years mock interview rounds with ideal answers](../../5-to-7-years-mock-interview-rounds-with-ideal-answers.md)
- [Java core internals interview questions](../runtime-internals/java-core-internals-interview-questions.md)
- [Java concurrency coding interview patterns](./java-concurrency-coding-interview-patterns.md)
