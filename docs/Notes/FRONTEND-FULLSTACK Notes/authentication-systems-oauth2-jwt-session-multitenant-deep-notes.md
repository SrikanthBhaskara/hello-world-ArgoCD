# Authentication Systems Deep Notes: Multi-Tenant OAuth2, JWT, and Session Security

## Why This Topic Matters
- Authentication is not just login.
- Real systems need identity, session continuity, token validation, tenant isolation, and authorization safety.
- Interviewers at 5 to 7 years expect you to discuss tradeoffs, not only definitions.

## Core Models

### Session-Based Authentication
- Server stores session state.
- Browser holds a session cookie.
- Good for traditional web applications and admin portals.

### Token-Based Authentication
- Client sends token on each request.
- Often used for APIs, SPAs, mobile apps, and microservices.

## Session-Based Security

### How It Works
1. user logs in
2. server creates session
3. browser stores session cookie
4. browser sends cookie on later requests

### Strengths
- server can invalidate session centrally
- easier revocation
- straightforward browser integration

### Risks
- CSRF if cookie-based browser flows are not protected
- session fixation if rotation is poor
- centralized session store scaling concerns

## JWT-Based Authentication

### What JWT Is
- JSON Web Token is a compact token format.
- It typically contains claims such as user id, tenant id, roles, issuer, audience, expiry.
- It is usually signed, not automatically encrypted.

### JWT Strengths
- stateless validation
- good for distributed APIs
- can carry identity and authorization claims

### JWT Risks
- overstuffed tokens
- long expiry windows
- weak verification logic
- no easy revocation unless additional strategy exists

## OAuth2 and OIDC

### OAuth2
- authorization framework
- often used for delegated access and API authorization

### OIDC
- identity layer built on top of OAuth2
- adds standardized user identity information

## Multi-Tenant Authentication

### What Changes in Multi-Tenant Systems
- users belong to different organizations or tenants
- the same identity provider may issue tokens for many tenants
- authorization must be tenant-aware

### Key Design Requirements
- tenant id in token or session context
- strict data isolation
- per-tenant roles or permissions
- issuer and audience validation where relevant
- avoid trusting user-supplied tenant headers blindly

## Example JWT Claims

```json
{
  "sub": "user-123",
  "tenantId": "tenant-a",
  "roles": ["admin"],
  "iss": "https://auth.example.com",
  "aud": "orders-api",
  "exp": 1893456000
}
```

## What to Verify in Tokens
- signature
- issuer
- audience
- expiry
- not-before if used
- tenant context
- scope or role claims

## Session vs JWT

### Session
- simpler for browser apps
- easier revocation
- stronger fit for server-rendered applications

### JWT
- better for distributed API ecosystems
- avoids centralized lookup on every request
- requires careful validation and revocation strategy

## OAuth2 Flows to Know
- authorization code flow with PKCE
- client credentials flow
- refresh token usage

Interview-safe answer:
- For browser-based modern apps I usually prefer authorization code flow with PKCE instead of weaker client-side approaches.

## Multi-Tenant Risks
- tenant data leakage
- trusting token without issuer validation
- mixing global admin with tenant-scoped permissions
- insecure tenant switching

## Good Practices
- include tenant context in identity model
- centralize token validation logic
- keep access tokens short-lived
- rotate signing keys safely
- use refresh tokens carefully
- separate authentication from authorization decisions

## Interview Questions

### When would you choose session-based auth over JWT?
Short answer:
For browser-centric applications where central session control is valuable.

Better answer:
I prefer session-based auth when the application is primarily browser-driven and I want strong central control over revocation and session lifecycle. I prefer JWT-based auth more often for distributed APIs and service ecosystems where stateless identity propagation is more practical.

### What is the hardest part of multi-tenant auth?
Short answer:
Tenant isolation and authorization safety.

Better answer:
The difficult part is making sure identity alone is not mistaken for authorization. In multi-tenant systems I need tenant-aware roles, strict data partitioning, validated token claims, and careful protection against cross-tenant access through bad mapping or untrusted headers.
