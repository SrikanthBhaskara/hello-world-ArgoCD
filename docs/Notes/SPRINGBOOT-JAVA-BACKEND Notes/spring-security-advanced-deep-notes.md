# Spring Security Advanced Deep Notes

This note extends the basic Spring Security note with advanced interview topics such as OAuth2, CORS, CSRF, custom filters, and production-safe access control.

---

## 1. Basic vs Advanced Security Topics

Basic topics include:

- authentication vs authorization
- `SecurityFilterChain`
- password encoding
- JWT

Advanced topics include:

- OAuth2 / OIDC
- CORS
- CSRF behavior
- custom authentication filters
- exception handling in security
- production-safe access rollout

---

## 2. CORS

CORS controls whether browsers can call an API from another origin.

### Why it matters

Browser-based frontend applications often fail not because backend logic is wrong, but because cross-origin rules block the request.

### Strong answer

CORS is a browser security policy issue, not a generic server-to-server networking issue.

---

## 3. CSRF

CSRF matters mainly in browser workflows where credentials like cookies are sent automatically.

### Common production rule

- session-based browser apps usually need CSRF protection
- stateless bearer-token APIs often disable CSRF intentionally

### Strong interview point

I do not disable CSRF blindly. I explain why it is or is not needed based on the auth model.

---

## 4. OAuth2 and OIDC

### OAuth2

OAuth2 is an authorization framework.

### OpenID Connect

OIDC adds identity information on top of OAuth2.

### When interviewers ask this

They often want to know whether you understand:

- third-party login
- token validation
- scopes
- identity provider integration

---

## 5. Resource Server vs Client

### Resource server

- protects APIs
- validates access tokens

### OAuth client

- initiates auth flow with identity provider

### Strong answer

In backend APIs, I often discuss resource-server behavior more than browser-login client behavior unless the system explicitly uses social or enterprise login.

---

## 6. Custom Filters

Custom filters are often used when:

- token extraction is custom
- headers need special parsing
- additional auth logic is required

### Caution

Custom filters should be added carefully because security filter ordering mistakes can create subtle access bugs.

---

## 7. Security Exception Handling

Useful concepts:

- `AuthenticationEntryPoint`
- `AccessDeniedHandler`

### Why it matters

- unauthenticated and unauthorized are different
- the API should return predictable security responses

---

## 8. Role and Authority Design

Strong answers include:

- least privilege
- clear permission naming
- business-action protection
- not overloading every user as admin

### Senior point

Security design should minimize blast radius, not just make login succeed.

---

## 9. Production-Safe Security Changes

Before rollout:

- validate access rules in lower environments
- verify actuator/admin routes
- confirm expected roles or scopes
- monitor failed auth spikes
- keep rollback path ready

### Strong answer

Security rollout changes are high risk because they can either expose protected functionality or block valid users. I treat them as controlled production changes, not simple config edits.
