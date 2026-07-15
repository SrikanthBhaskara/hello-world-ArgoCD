# Frontend and Full-Stack Mock Interview Rounds

## Round 1: React Basics

### Question
What is the difference between props and state, and when would you lift state up?

### Ideal Answer
Props are values passed into a component from its parent, while state is data the component owns and updates itself. I lift state up when multiple sibling components need to read or update the same value so there is one clear source of truth instead of duplicated local state.

## Round 2: Rendering Strategy

### Question
How do you choose between CSR, SSR, and SSG?

### Ideal Answer
I choose based on SEO, personalization, freshness, and performance goals. CSR is fine for authenticated dashboards where interactivity matters most. SSR is useful when first-page render and SEO matter. SSG is ideal for stable content where fast delivery is important and data does not change every request.

## Round 3: Debugging

### Question
Users report that a page works locally but fails in production only after deployment. How do you investigate?

### Ideal Answer
I compare environment-specific differences first: config, API base URL, feature flags, caching, rendering mode, and browser behavior. Then I use production telemetry, request ids, console logs, network traces, and rollout history. Production-only issues are often caused by environment mismatch, timing, build optimization, or stale assets rather than the core component logic itself.

## Round 4: Security

### Question
How would you explain XSS and CSRF to an interviewer?

### Ideal Answer
XSS is when untrusted content gets executed in the browser as script, usually because unsafe content was rendered without proper escaping or sanitization. CSRF is when a browser is tricked into sending an authenticated request unintentionally, usually in cookie-based flows. I defend them differently: XSS with safe rendering and sanitization, and CSRF with tokens and secure cookie behavior.

## Round 5: Full-Stack Contract Change

### Question
Backend changed `fullName` into `firstName` and `lastName`. How do you roll this out safely?

### Ideal Answer
I avoid a one-shot breaking release. I prefer an expand-and-contract strategy: add new fields and backend support first, keep old and new formats temporarily, update the frontend, backfill data if needed, then remove the old contract only after consumers are migrated.

## Round 6: Performance

### Question
What would you do if a React page feels slow?

### Ideal Answer
I would measure before guessing. I would inspect render frequency, large lists, expensive computations, bundle size, network waterfalls, and asset loading. Typical fixes include code splitting, reducing unnecessary re-renders, lazy loading, pagination or virtualization, and moving the right work server-side.

## Round 7: Testing

### Question
What is your frontend testing strategy?

### Ideal Answer
I use a layered approach. Unit and component tests validate behavior in isolation, integration-style tests cover component interaction and API mocking, and end-to-end tests cover a few critical business journeys like login, checkout, or file upload. I do not try to force one test type to do everything.

## Round 8: Auth Design

### Question
How would you design authentication for a multi-tenant frontend application?

### Ideal Answer
I would make tenant context explicit in the identity model, not only in the UI. On the frontend I would keep auth handling consistent, validate session or token lifecycle carefully, and make sure cross-tenant switching is deliberate and safe. On the backend I would rely on validated tenant-aware identity and authorization rather than trusting client-sent tenant hints blindly.

## Round 9: Real-Time Data

### Question
When would you use WebSocket instead of polling?

### Ideal Answer
I use WebSocket when the interaction is truly real time and bidirectional, such as chat or collaborative editing. For one-way updates or simpler scenarios, SSE or controlled polling may be operationally simpler and completely sufficient.

## Round 10: Senior Ownership

### Question
What changes in expectations when moving from frontend developer to senior full-stack engineer?

### Ideal Answer
The expectation shifts from implementing screens well to owning delivery outcomes. That includes frontend architecture, API contract thinking, debugging production issues, security awareness, performance budgets, release safety, and helping the team make good tradeoffs rather than only coding assigned tasks.
