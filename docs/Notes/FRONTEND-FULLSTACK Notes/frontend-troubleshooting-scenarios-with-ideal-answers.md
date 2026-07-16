# Frontend Troubleshooting Scenarios with Ideal Answers

## 1. Hydration Mismatch in Production

### Scenario
- The page loads HTML from the server, but the browser console shows hydration mismatch warnings.

### Ideal Answer
- I would compare what the server rendered versus what the client renders on first load.
- Common causes include time-dependent values, random values, browser-only APIs used during server render, auth-dependent UI differences, and locale differences.
- I would isolate the component causing the mismatch, move browser-only logic behind client-only boundaries if needed, and make the initial render deterministic.

## 2. CORS Fails Only in the Browser

### Scenario
- API calls work in Postman but fail from the UI.

### Ideal Answer
- That points to browser enforcement, not necessarily backend unavailability.
- I would inspect the request origin, preflight behavior, allowed headers, allowed methods, and credential configuration.
- I would verify whether the frontend is sending cookies or auth headers and whether the backend CORS policy matches that exact browser flow.

## 3. Auth Redirect Loop

### Scenario
- Users keep getting redirected between login and dashboard.

### Ideal Answer
- I would inspect token or session validity, cookie scope, clock skew, route guards, and whether the frontend incorrectly treats a temporary loading state as unauthenticated.
- Redirect loops often come from auth state being checked too early or from session cookies not being sent in the expected environment.

## 4. Stale Asset Cache After Deployment

### Scenario
- Users still see old JS or broken UI after a release.

### Ideal Answer
- I would check cache-control strategy, hashed asset filenames, CDN invalidation behavior, and service worker interaction if one exists.
- The goal is to ensure HTML references the new asset version and that long-lived static caching is safe only for fingerprinted files.

## 5. Page Feels Slow but Backend Looks Fine

### Scenario
- Users say the page is slow, but server latency looks healthy.

### Ideal Answer
- I would shift focus to frontend rendering cost, bundle size, image loading, layout thrash, large tables, and client-side data transformations.
- I would use browser performance profiling, network waterfall inspection, and Core Web Vitals rather than assuming the backend is the bottleneck.

## 6. Duplicate API Calls

### Scenario
- One screen seems to hit the same endpoint multiple times.

### Ideal Answer
- I would inspect effect dependencies, route transitions, duplicate mounts, dev-only strict-mode behavior versus production behavior, and missing client cache or dedupe.
- I would make sure the fix preserves correctness rather than just hiding the symptom.

## 7. Search Results Arrive Out of Order

### Scenario
- Fast typing causes older responses to overwrite newer search results.

### Ideal Answer
- This is a race condition. I would debounce input, cancel stale requests when possible, or ignore responses that do not match the latest active query.
- The real fix is request coordination, not only UI repaint logic.

## 8. Memory Leak from Event Listeners

### Scenario
- Long sessions make the page slower over time.

### Ideal Answer
- I would inspect effects that attach listeners, timers, intervals, sockets, or observers without cleanup.
- In React, this usually means checking `useEffect` cleanup behavior and component mount/unmount boundaries carefully.

## 9. Feature Flag Works for Some Users but Not Others

### Scenario
- One group sees a new UI, another group sees broken behavior.

### Ideal Answer
- I would verify how the flag is evaluated, cached, and propagated.
- I would also check whether the frontend assumes backend support that is not enabled consistently across environments or user segments.

## 10. Large List Freezes the Browser

### Scenario
- Rendering a big dataset makes scrolling and interaction laggy.

### Ideal Answer
- I would reduce work by paginating, virtualizing, or chunking rendering, and by avoiding expensive per-item computation during every render.
- Rendering strategy matters more than micro-optimizing one component in isolation.
