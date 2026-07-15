# Frontend Interview Questions with Short and Better Answers

## 1. What is the difference between props and state?
Short answer:
Props come from the parent and state is managed by the component itself.

Better answer:
Props are external inputs passed into a component, while state represents data the component owns and can change over time. I use props to keep components reusable and state to model interactive behavior such as form input, selected items, or loading state.

## 2. What does `useEffect` do?
Short answer:
It runs side effects after render.

Better answer:
`useEffect` is used for work that should happen outside pure rendering, such as data fetching, subscriptions, timers, or cleanup. I try not to use it for simple derived values because that usually belongs in render logic instead.

## 3. Why are keys needed in React lists?
Short answer:
They help React track which items changed.

Better answer:
Keys help React identify list elements across renders so it can update efficiently and preserve correct component identity. Bad keys, like array indexes in unstable lists, can cause UI bugs such as wrong item state being reused.

## 4. What is the difference between CSR and SSR?
Short answer:
CSR renders mostly in the browser, while SSR renders HTML on the server first.

Better answer:
CSR gives a rich SPA-like experience but can delay first meaningful content. SSR improves initial render and SEO because the server returns HTML directly, but it adds server-side cost and complexity. I choose based on user experience, SEO, personalization, and operational tradeoffs.

## 5. How do you handle loading, error, and empty states?
Short answer:
Treat them as first-class UI states, not afterthoughts.

Better answer:
I explicitly model each state so the user always knows what is happening. A mature frontend does not just show the happy path. It should communicate loading clearly, show meaningful recovery guidance on error, and handle empty results without looking broken.

## 6. What causes unnecessary re-renders?
Short answer:
Changing props, state, or unstable references can trigger them.

Better answer:
Re-renders often come from state placed too high, inline object or function creation, broad context usage, or components doing too much work. I investigate before optimizing because not every re-render is a real problem, but I fix unnecessary churn when it affects responsiveness.

## 7. How do you improve frontend performance?
Short answer:
Reduce bundle size, avoid unnecessary work, and optimize rendering paths.

Better answer:
I start by measuring rather than guessing. Typical improvements include route-level code splitting, lazy loading, image optimization, reducing expensive re-renders, avoiding large client bundles, and moving the right work to the server when that improves first-load experience.

## 8. What is optimistic UI?
Short answer:
The UI updates before the server confirms success.

Better answer:
Optimistic UI improves responsiveness by assuming an operation will likely succeed, such as liking a post or moving an item. It works well when the action is reversible and failure handling is designed clearly, because you need a rollback strategy if the server later rejects the change.

## 9. How do you defend against XSS?
Short answer:
Avoid unsafe HTML rendering and use proper escaping and sanitization.

Better answer:
My first rule is to keep untrusted content out of executable browser contexts. I rely on framework auto-escaping, avoid unsafe DOM APIs like `innerHTML` unless sanitized content is required, and use CSP as an additional defense layer rather than the only defense.

## 10. When does CSRF matter?
Short answer:
Mostly when browsers automatically send credentials like cookies.

Better answer:
CSRF matters when browser-managed credentials are automatically attached to state-changing requests, especially in session-based applications. In that case I use CSRF tokens and secure cookie settings. Stateless bearer-token APIs have a different threat model, but I still validate the actual client behavior before claiming the risk is gone.

## 11. How would you store authentication tokens?
Short answer:
It depends on the auth model and threat model.

Better answer:
I do not give a one-size-fits-all answer. Cookie-based session auth can be strong when configured safely with `HttpOnly`, `Secure`, and `SameSite`. Client-accessible storage is simpler in some SPA flows but increases XSS exposure, so storage choice should follow the real architecture and risk model.

## 12. What is hydration?
Short answer:
It is when client-side JavaScript attaches behavior to server-rendered HTML.

Better answer:
Hydration is the process where the browser takes server-rendered markup and turns it into a live interactive application. Hydration mismatches happen when server and client render different output, which can lead to warnings, broken event binding, or inconsistent UI behavior.

## 13. How do you design state management in a large app?
Short answer:
Keep state local by default and promote it only when multiple areas need shared coordination.

Better answer:
I start by identifying ownership and consumers. Local state is usually simplest. I use context for modest shared concerns, and I bring in a dedicated state solution when coordination, caching, or cross-page behavior becomes complex enough that ad hoc sharing would hurt maintainability.

## 14. How do you debug a production-only frontend issue?
Short answer:
Use telemetry, repro narrowing, and environment comparison.

Better answer:
I start with logs, trace ids, feature flags, browser details, and request data from production telemetry. Then I compare config, rendering mode, API payloads, and browser-specific behavior. Production-only issues often come from environment differences, timing, caching, minification, or partial rollout effects.

## 15. What is the difference between GraphQL and REST from a frontend point of view?
Short answer:
GraphQL gives flexible field selection, while REST is simpler and more predictable operationally.

Better answer:
From the frontend perspective, GraphQL reduces overfetching and lets each screen ask for the data shape it needs, which is powerful in UI-heavy products. REST is simpler to cache, reason about, and debug. I choose based on product complexity, consumer flexibility needs, and operational cost.
