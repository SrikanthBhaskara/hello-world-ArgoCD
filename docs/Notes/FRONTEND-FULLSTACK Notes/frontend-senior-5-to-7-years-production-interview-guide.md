# Frontend Senior 5 to 7 Years Production Interview Guide

## What Interviewers Expect
- You should do more than build screens.
- You should explain architecture choices, debugging approach, performance tradeoffs, release safety, and cross-team coordination.
- You should think as a product-facing engineer and a production engineer at the same time.

## Core Expectations

### Architecture Ownership
- choose between CSR, SSR, SSG, and ISR based on user needs
- define state ownership clearly
- reduce frontend-backend coupling through stable contracts
- break large UI areas into maintainable modules

### Production Reliability
- think about telemetry, error tracking, rollout safety, and recovery paths
- understand how feature flags, canaries, and config differences affect the browser experience
- design graceful handling for slow APIs, partial failures, and stale client state

### Performance Thinking
- know how to investigate slow renders, large bundles, and network waterfalls
- use code splitting, caching, and data-fetching strategy intentionally
- reason about browser cost, not just component syntax

### Security Awareness
- explain XSS, CSRF, token storage risks, CSP, and secure auth flows
- understand that frontend security is mostly about reducing exposure and enforcing safe browser behavior

### Collaboration
- work effectively with backend, platform, design, and QA
- negotiate API shape changes
- drive quality without waiting for someone else to define it

## Strong Senior Answers Sound Like This

### On Rendering Strategy
- "I would not treat SSR as automatically better. I would choose based on SEO, personalization, latency, and infrastructure cost."

### On State Management
- "I keep state local by default and only centralize it when multiple independent areas truly need coordinated access."

### On Incidents
- "I start with telemetry and environment differences, then narrow whether the issue is rendering, data shape, timing, auth, caching, or rollout related."

## Topics You Should Be Comfortable With
- React component design
- hooks and side effects
- Next.js rendering models
- browser storage and security tradeoffs
- bundle size and performance analysis
- frontend testing strategy
- observability for UI and API flows
- authentication and session lifecycle
- schema and API contract evolution
- accessibility and UX under failure

## Production Scenarios They May Ask

### Scenario 1
- "Page works locally but fails only in production."

Good answer:
- compare environment config, API base URL, auth flow, feature flags, rendering mode, and stale cached assets
- use production telemetry and browser network traces before guessing

### Scenario 2
- "A release increased bounce rate but not backend errors."

Good answer:
- inspect Core Web Vitals, client errors, broken hydration, bundle regression, slow asset loading, and UX changes that may not show as server failure

### Scenario 3
- "Frontend is making too many API requests."

Good answer:
- inspect effect dependencies, duplicate renders, missing debounce, cache misses, and race conditions
- avoid fixing it only with backend capacity

## Senior Interview Questions

### How do you show seniority as a frontend engineer?
Short answer:
By owning reliability, performance, security, and delivery tradeoffs, not just feature code.

Better answer:
Seniority shows up in the ability to make safe decisions under ambiguity. I should be able to design a frontend architecture, debug production-only issues, work through API contract changes, protect the user experience during partial failure, and help the team deliver changes safely rather than only implementing assigned tasks.

### What changes from 5 years to 7 years?
Short answer:
More ownership, architecture, mentoring, and production judgment.

Better answer:
At 5 years, a strong engineer usually builds independently and debugs well. By 7 years, I’m expected to guide rendering strategy, influence API and contract design, drive rollout safety, mentor others, and speak clearly about business and technical tradeoffs.

## Final Preparation Checklist
- Can you explain SSR vs CSR tradeoffs clearly?
- Can you talk about frontend auth safely?
- Can you describe a real production debugging flow?
- Can you explain bundle and render performance investigation?
- Can you discuss accessibility and error-state design?
- Can you show ownership beyond component implementation?
