# Full-Stack Senior 5 to 7 Years Production Interview Guide

## What Senior Full-Stack Means
- You are expected to reason across UI, API, backend, database, security, and deployment.
- Interviewers want someone who can make safe tradeoffs across the whole request path, not only within one layer.

## Core Expectations

### End-to-End Design
- understand browser behavior, frontend rendering, API design, backend service logic, persistence, and observability together
- explain how a user interaction becomes a persisted business outcome

### Contract Ownership
- design API and schema evolution safely
- avoid tight coupling between UI models and storage details
- manage backward compatibility during rollout

### Production Thinking
- reason about performance from browser to DB
- troubleshoot using logs, metrics, traces, and client telemetry
- plan safe release, rollback, and feature-flag usage

### Security Awareness
- defend both browser-facing and service-side surfaces
- explain token handling, CSRF, XSS, input validation, auth boundaries, and secret usage

## Full-Stack Interview Themes

### Frontend
- rendering strategy
- state ownership
- performance and UX under failure

### Backend
- API design
- concurrency and retries
- idempotency and consistency

### Database
- query behavior
- schema changes
- indexing and scaling

### Platform
- deployment flow
- observability
- rollback and incident handling

## Example Senior Question

### How would you design a file upload feature end to end?
Good answer:
- use direct object-storage upload when possible
- keep metadata in backend
- validate auth and authorization before issuing upload permission
- support retries or chunking for large files
- add async scanning or processing
- emit telemetry for success, error, latency, and post-processing status

### How would you diagnose a slow user journey?
Good answer:
- start from user symptom
- inspect browser timing, API latency, backend traces, DB queries, and dependency calls
- identify whether the issue is client rendering, network behavior, API design, or persistence
- do not stop at one layer just because it is familiar

## What Senior-Level Answers Should Show
- tradeoff clarity
- production realism
- safe rollout thinking
- user-impact awareness
- coordination across teams

## Preparation Checklist
- Can you explain a request end to end?
- Can you discuss frontend and backend failures in one answer?
- Can you explain schema change rollout safely?
- Can you describe observability from browser to service?
- Can you talk about product impact, not only technical detail?
