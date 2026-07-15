# Web Security Deep Notes: XSS and CSRF

## Why This Matters
- Browser-facing applications are exposed to a different threat model than backend-only services.
- Interviewers often expect you to explain not just definitions, but when these attacks happen and how to prevent them in real systems.

## Cross-Site Scripting (XSS)

### What XSS Is
- XSS happens when untrusted input is interpreted as executable content in the browser.
- The attacker injects script or dangerous markup that runs in another user’s browser.

### Common Types

#### Stored XSS
- malicious content is saved in the application and served later to other users
- example: unsafe comment field rendered without sanitization

#### Reflected XSS
- malicious input comes from request parameters and is reflected immediately in the response

#### DOM-Based XSS
- frontend JavaScript reads unsafe input and injects it into the DOM using dangerous APIs

## Unsafe Example

```ts
document.getElementById("message")!.innerHTML = userInput;
```

Problem:
- attacker-controlled HTML or script may execute

## Safer Approach

```ts
document.getElementById("message")!.textContent = userInput;
```

## XSS Prevention
- escape output correctly based on context
- prefer frameworks that auto-escape templates
- avoid `innerHTML` unless content is sanitized
- sanitize rich text with trusted libraries when HTML is truly needed
- use Content Security Policy where practical
- validate input, but do not rely on input validation alone

## Cross-Site Request Forgery (CSRF)

### What CSRF Is
- CSRF happens when a victim’s browser automatically sends authenticated requests to a site without the user intending it.
- This mainly affects cookie-based session authentication because browsers attach cookies automatically.

## Example Scenario
1. user logs in to banking app
2. session cookie is stored in browser
3. user visits malicious page
4. malicious page submits hidden form to banking app
5. browser includes valid session cookie automatically

## Why JWT APIs Often Treat This Differently
- if the API uses bearer tokens stored and sent manually by the client, the browser does not automatically attach them in the same way as cookies
- that changes the CSRF threat model
- but unsafe browser storage or mixed auth approaches can still create risk

## CSRF Prevention
- CSRF tokens
- `SameSite` cookie settings
- avoid unsafe cross-origin form behavior
- verify origin or referer where appropriate
- separate browser-session security from pure API-token security decisions

## XSS vs CSRF

### XSS
- attacker injects script into trusted page context
- primary target is the browser execution context

### CSRF
- attacker tricks a browser into sending an authenticated request
- primary target is unintended state-changing action

## Real Interview Trap
- "If I use JWT, am I safe from CSRF?"

Better answer:
- Not automatically. If JWT is stored and sent through mechanisms that behave like browser-managed credentials, the risk model changes less than people think. The right answer depends on whether auth is cookie-based, storage-based, same-site, cross-site, and how requests are actually sent.

## Practical Defenses
- use framework auto-escaping
- avoid rendering unsanitized user HTML
- use CSP carefully
- use CSRF tokens for session-based browser apps
- set secure cookie flags: `HttpOnly`, `Secure`, `SameSite`
- validate and sanitize untrusted rich content

## Interview Questions

### What is the best defense against XSS?
Short answer:
Context-aware output escaping plus safe rendering patterns.

Better answer:
The strongest practical defense is to avoid injecting untrusted content into executable browser contexts. I rely on framework auto-escaping, safe DOM APIs like `textContent`, careful sanitization for rich text, and layered controls like CSP rather than trusting input validation alone.

### When is CSRF protection required?
Short answer:
Mainly when browser-managed credentials such as cookies are used for authenticated state-changing requests.

Better answer:
CSRF matters when the browser can automatically send credentials to the application, especially in session-based apps. In those cases I use CSRF tokens and secure cookie settings. For stateless bearer-token APIs the threat model is different, but I still evaluate the exact client behavior before claiming it is unnecessary.
