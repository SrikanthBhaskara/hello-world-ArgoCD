# Browser Internals, Web Platform Security, and Caching Deep Notes

## Why This Topic Matters
- Full-stack engineers are often expected to understand what the browser is doing, not just framework syntax.
- This topic helps explain performance issues, XSS and CORS confusion, and frontend behavior under real network conditions.

## Rendering Pipeline Basics
- browser parses HTML into DOM
- parses CSS into CSSOM
- combines them into render tree
- performs layout
- paints pixels
- may composite layers

Interview point:
- DOM changes can trigger layout and paint cost, which is why heavy UI churn and repeated synchronous measurement can hurt performance.

## Event Loop
- JavaScript runs on a single main thread in most browser cases
- work is processed through call stack, task queue, and microtask queue

### Macro Tasks
- timers
- IO callbacks
- user events

### Micro Tasks
- promise callbacks
- mutation observer callbacks

Why it matters:
- promise-heavy code can starve normal task handling if not managed carefully

## DOM vs Virtual DOM

### DOM
- real browser representation

### Virtual DOM
- in-memory representation used by frameworks like React to compute updates

Interview-safe answer:
- The virtual DOM is an optimization strategy for describing UI updates, not a magic performance guarantee. Poor component structure can still create inefficient work.

## Browser Storage

### Cookies
- sent automatically with matching requests
- useful for sessions
- security-sensitive

### localStorage
- persistent client storage
- synchronous API
- not ideal for sensitive tokens

### sessionStorage
- scoped to tab session

## CORS

### What It Is
- Cross-Origin Resource Sharing controls whether the browser allows frontend code from one origin to access responses from another origin.

### Important Point
- CORS is a browser enforcement model, not a backend authentication system.

### Common Confusion
- if Postman works but browser fails, CORS may be the issue

## CSP

### What It Is
- Content Security Policy restricts what scripts, styles, and resources can execute or load
- useful for reducing XSS blast radius

### Practical Use
- restrict script sources
- avoid unsafe inline execution where possible

## Browser Caching

### Types
- memory cache
- disk cache
- CDN cache
- service worker cache

### Common Headers
- `Cache-Control`
- `ETag`
- `Last-Modified`

Interview point:
- caching strategy should differ for static assets, APIs, and user-specific data

## Common Security Topics

### XSS
- untrusted input executed in browser

### CSRF
- browser sends authenticated request automatically without user intent

### Clickjacking
- attacker frames your page and tricks user interaction
- mitigate with frame restrictions

## Interview Questions

### Why does CORS exist?
Short answer:
To control cross-origin browser access to responses.

Better answer:
Browsers enforce same-origin restrictions to reduce abuse across sites. CORS gives servers a controlled way to say which origins, methods, and headers are allowed for browser-based cross-origin access.

### Why is localStorage risky for sensitive auth tokens?
Short answer:
Because script access makes token theft easier if XSS exists.

Better answer:
Anything readable by frontend JavaScript becomes easier to steal if the page is compromised by XSS. That is why auth storage decisions must consider both convenience and the actual browser threat model.
