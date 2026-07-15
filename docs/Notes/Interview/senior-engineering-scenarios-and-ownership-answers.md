# Senior Engineering Scenarios and Ownership Answers

## 1. A risky release is scheduled, but test confidence is weak

### Good answer
I would not rely on optimism. I would clarify what is uncertain, reduce the blast radius with feature flags or canary rollout if possible, verify observability is ready, and align with stakeholders on the actual risk. If the unknowns are too large for the business value, I would recommend delaying rather than pretending the risk is acceptable.

## 2. Two teams disagree on API ownership

### Good answer
I would first separate the technical and organizational concerns. Then I would clarify domain boundaries, operational ownership, change frequency, and who carries incident responsibility. My goal would be a decision that reduces future ambiguity, not just ends the current debate quickly.

## 3. A junior engineer made a mistake that caused an incident

### Good answer
I would focus on system learning, not blame. I would help stabilize the incident, understand how the unsafe path was possible, and improve reviews, guardrails, tests, rollout safety, or documentation. A senior engineer should reduce the chance that the same class of mistake can happen again.

## 4. Estimation is requested for a fuzzy feature

### Good answer
I would avoid false precision. I would split the work into known implementation, technical discovery, external dependency risk, and rollout risk. Then I would give a range with assumptions and call out what could change the estimate.

## 5. A production issue has no clear owner during an outage

### Good answer
I would help establish temporary incident roles quickly: someone driving coordination, someone investigating logs and metrics, someone handling stakeholder communication, and someone tracking timeline and actions. Clear coordination often matters as much as technical skill during the first phase of an incident.

## 6. A code review has design issues but the author is defensive

### Good answer
I would keep the conversation around behavior, maintainability, and operational risk instead of style preference. If needed I would move from comment ping-pong into a direct discussion so the goal becomes shared understanding instead of point scoring.

## 7. Stakeholders want a shortcut that weakens security

### Good answer
I would explain the business impact of the security tradeoff in simple terms and propose safer alternatives if possible. I do not treat security as a slogan, but I also do not quietly approve risky shortcuts without making the decision explicit.

## 8. Legacy code is hard to change, but the business needs speed

### Good answer
I would not recommend a full rewrite by reflex. I would identify high-friction areas, add seams around the most risky parts, improve tests where change is frequent, and modernize in steps so we deliver value while reducing long-term maintenance cost.

## 9. A feature is complete technically, but operational readiness is poor

### Good answer
I would treat that as incomplete work. Production readiness includes metrics, logging, alerts, rollback strategy, runbook clarity, and safe rollout planning. Shipping without that may only move the cost from development time into incident time.

## 10. How do you show seniority in interviews without sounding abstract?

### Good answer
I answer with context, tradeoffs, and concrete actions. Instead of saying "I focus on reliability," I explain how I would reduce blast radius, what telemetry I need, how I would roll out safely, and how I would lead communication if something fails.
