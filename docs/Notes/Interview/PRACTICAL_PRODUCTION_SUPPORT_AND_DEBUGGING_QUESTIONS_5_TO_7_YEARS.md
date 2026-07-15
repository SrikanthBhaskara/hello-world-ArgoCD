# Practical Production Support and Debugging Questions for 5 to 7 Years Experience

## Purpose
This document focuses on interview questions related to production support, incident handling, debugging, RCA, and sustaining engineering. It is especially useful if your experience includes live issue investigation and production-safe bug fixing.

## 1. Incident Triage Questions

### 1. What do you do first when a production issue is reported?
Answer:
I first understand impact: who is affected, what is failing, when it started, and whether the issue is ongoing. Then I collect logs, metrics, recent deployment history, and environment changes to narrow the problem before deciding on action.

### 2. How do you prioritize multiple production issues?
Answer:
I prioritize by customer impact, severity, blast radius, business criticality, and whether the issue is actively growing. A widespread user-facing outage is addressed before a lower-impact defect.

### 3. When would you choose rollback over forward fix?
Answer:
I prefer rollback when the issue clearly started with a recent change, the rollback path is safe, and the business impact is high. If rollback is risky or the fix is small and well understood, a forward fix may be better.

## 2. Debugging Questions

### 1. How do you investigate a problem that happens intermittently?
Answer:
I look for timing patterns, race conditions, retries, dependency variability, cache behavior, and environment-specific triggers. Intermittent issues usually need correlation across timestamps, request IDs, and common conditions.

### 2. How do you debug an issue that cannot be reproduced locally?
Answer:
I compare environments, data patterns, load, configuration, permissions, security settings, and external dependencies. I also add focused diagnostics if needed and avoid making unsupported assumptions.

### 3. What information do you want in logs during a production investigation?
Answer:
I want timestamps, request or correlation IDs, error messages, important inputs, dependency failures, state transitions, and enough context to follow the request flow without exposing sensitive data.

## 3. Root Cause Analysis Questions

### 1. What is your RCA process?
Answer:
I start from the visible symptom, trace backward to find where behavior first diverges from expectation, validate the suspected cause with evidence, identify affected scope, and document the reason, fix, and prevention ideas.

### 2. How do you avoid treating symptoms instead of root cause?
Answer:
I avoid stopping at the first visible failure. I keep tracing upstream until I identify why the failure happened. A downstream crash may be only the result of earlier invalid state, stale data, or unexpected input.

### 3. What do you include in an RCA note?
Answer:
I include the issue summary, impact, timeline, root cause, contributing factors, fix summary, validation scope, rollback considerations, and prevention or follow-up actions.

## 4. Production Safety Questions

### 1. How do you make sure a production fix is safe?
Answer:
I validate the root cause first, keep the fix as small as possible, review neighboring flows, consider rollback options, and think about what monitoring or verification is needed after deployment.

### 2. How do you reduce regression risk?
Answer:
I check related code paths, edge cases, compatibility expectations, and operational assumptions. I avoid unrelated cleanup during critical fixes and focus on the minimum effective change.

### 3. How do you think about monitoring after a fix?
Answer:
I identify the signals that would prove success or failure, such as error-rate reduction, latency improvement, log patterns, or alert quieting. Good post-fix monitoring helps confirm whether the fix actually worked in production.

## 5. Practical Scenario Questions

### 1. A deployment succeeded technically, but users report problems. What do you do?
Answer:
I do not assume deployment success means functional success. I validate behavior through logs, metrics, user reports, dependency responses, and key flows. If the impact is high, I assess rollback readiness while narrowing the root cause.

### 2. A service is healthy, but one workflow is broken. How do you investigate?
Answer:
I isolate the affected workflow, compare it with working paths, inspect input differences, check dependency usage, and identify where that workflow diverges from normal behavior.

### 3. A hardware or monitoring alert does not match the real system state. What do you check?
Answer:
I verify whether the source data is wrong, stale, partially updated, or interpreted incorrectly by the monitoring layer. I check the collection path, mapping logic, and any cleanup or refresh behavior involved in status reporting.

### 4. A configuration fix works temporarily but the issue returns. What does that suggest?
Answer:
It suggests the true problem may be deeper than configuration alone. The config may only mask the behavior, while the underlying issue could still exist in code, process, timing, or state management.

## 6. Communication Questions

### 1. How do you communicate during an active production issue?
Answer:
I communicate clearly and factually: current impact, what is known, what is being checked, what actions are underway, and what the next update point will be. I avoid speculation when evidence is incomplete.

### 2. How do you explain technical issues to non-technical stakeholders?
Answer:
I explain the impact, why it happened at a high level, what action is being taken, and whether users need to do anything. I avoid deep internal implementation details unless they are necessary.

## 7. Quick Revision Topics
- Incident triage
- RCA process
- Logs, metrics, and correlation IDs
- Rollback vs forward fix
- Regression risk
- Post-fix monitoring
- Intermittent issue debugging
- Configuration vs code problems
- Communication during incidents

## Final Note
At 5 to 7 years of experience, interviewers often want to see whether you can operate calmly and effectively in real production situations. Strong answers show structure, evidence-based debugging, safety awareness, and clear communication.