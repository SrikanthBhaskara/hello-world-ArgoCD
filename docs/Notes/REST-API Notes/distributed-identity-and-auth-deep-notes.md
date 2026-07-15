# Distributed Identity and Authentication Deep Notes

These notes cover secure identity and authorization in distributed systems, especially machine-to-machine and user authentication with OAuth2, OIDC, JWT verification, and RBAC. The goal is to understand not just token names, but trust boundaries, verification, propagation, and authorization safety.

## 1. Why Distributed Identity Is Hard

In distributed systems, identity crosses:
- clients
- API gateways
- backend services
- message-driven workflows

The system must answer:
- who is the caller
- how do we trust that identity
- what are they allowed to do
- how is that trust propagated safely

## 2. Authentication vs Authorization

Authentication:
- proves identity

Authorization:
- decides access

Strong interview line:
- authentication answers "who are you?" and authorization answers "what are you allowed to do?"

## 3. User Authentication vs Machine-to-Machine Authentication

### User Authentication

Caller is an end user.

Common tools:
- OAuth2
- OIDC
- JWT access tokens

### Machine-to-Machine Authentication

Caller is another service or workload.

Common tools:
- OAuth2 client credentials flow
- mTLS in some environments
- workload identity and short-lived tokens

Important:
- user tokens and service identity tokens solve different trust problems

## 4. OAuth2 at a Practical Level

OAuth2 is an authorization framework.

It defines flows for obtaining access tokens.

Common practical flows:
- authorization code flow
- client credentials flow

Use authorization code flow when:
- a user is involved

Use client credentials flow when:
- one service calls another without end-user login interaction

## 5. OIDC

OIDC builds on OAuth2 and adds identity information.

Why it matters:
- OAuth2 alone is about access delegation
- OIDC adds standardized identity semantics

This is common for:
- user login
- SSO
- identity claims

## 6. JWT Basics

JWT is a token format, not an authentication strategy by itself.

Typical JWT contains:
- subject
- issuer
- audience
- expiry
- roles or scopes

Important:
- JWT is signed, not automatically encrypted
- never assume token contents are secret

## 7. JWT Verification

A service receiving a JWT should usually verify:
- signature
- issuer
- audience
- expiry
- not-before if used

Common mistakes:
- checking presence but not signature
- ignoring audience
- trusting expired tokens
- trusting roles without issuer validation

Strong answer:
- JWT verification is not just parsing the token. I verify signature, issuer, audience, and time-based claims before trusting the caller identity or permissions.

## 8. Token Propagation

In distributed systems, identity may pass through:
- gateway
- edge service
- downstream services

Questions to answer:
- should the original user token be propagated
- should an internal service token be exchanged instead
- what claims should downstream services trust

Risk:
- uncontrolled token propagation can increase blast radius and leak privilege

## 9. Machine-to-Machine Authentication

For service-to-service calls, common patterns include:
- OAuth2 client credentials flow
- workload identity
- signed internal tokens
- mTLS for transport trust

Good design goals:
- short-lived credentials
- least privilege
- auditable identity

## 10. Role-Based Access Control

RBAC means access is granted based on roles assigned to identities.

Examples:
- `ADMIN`
- `SUPPORT`
- `READ_ONLY`

Why useful:
- simpler authorization model
- clearer governance

But remember:
- role checks alone may be too coarse for all systems

Sometimes you also need:
- permission-based checks
- tenant-aware checks
- object-level authorization

## 11. Scopes vs Roles

Scopes often represent:
- what an access token may do

Roles often represent:
- what a user or service is allowed to act as in the business domain

In real systems these can overlap, but they should not be confused blindly.

## 12. Authorization at Multiple Layers

Authorization may happen at:
- API gateway
- endpoint layer
- service method layer
- data ownership layer

Best practice:
- do not rely on only one layer if deeper business checks matter

Example:
- gateway may verify token
- service still enforces whether user may access order `123`

## 13. Token Expiry and Refresh

Tokens should expire.

Why:
- limits blast radius
- reduces risk of long-lived compromise

If tokens are very short-lived:
- clients may need refresh flow

If tokens are too long-lived:
- privilege persists too long after compromise

## 14. Common Security Risks

Bad patterns:
- hardcoded shared secrets
- trusting unsigned tokens
- not checking audience
- broad roles with too much power
- forwarding identity headers from untrusted callers
- logging sensitive token contents

## 15. API Gateway and Identity

The gateway often helps with:
- token verification
- auth policy enforcement
- rate limiting by identity
- claim forwarding

But:
- services must still know what trust assumptions they rely on
- a service should not trust arbitrary headers unless the gateway boundary is explicit and protected

## 16. OAuth2 Client Credentials Example

Typical machine-to-machine flow:
1. service authenticates with client credentials
2. auth server issues access token
3. service calls downstream API with bearer token
4. downstream verifies token and scope

Use when:
- service acts as itself, not as a user

## 17. User Login with OIDC Example

Typical flow:
1. user authenticates with identity provider
2. client receives authorization result
3. access token and identity information are issued
4. API validates access token

Use when:
- user identity and login experience matter

## 18. Observability and Audit

Distributed identity needs:
- traceability of who called what
- rejection reason visibility
- secure audit logging

Log carefully:
- token metadata or subject where appropriate
- never dump full sensitive token values casually

## 19. What Different Experience Levels Should Know

### 0 to 2 years

Should know:
- authentication vs authorization
- what JWT is
- what RBAC is
- why HTTPS and token validation matter

### 2 to 4 years

Should know:
- OAuth2 vs OIDC
- user vs machine authentication difference
- JWT verification basics
- role and scope checks

### 4 to 7 years

Should know:
- client credentials flow and service identity design
- trust boundaries across gateway and services
- safe token propagation decisions
- least privilege and role-model limitations
- how to explain verification, expiry, audience, and issuer checks clearly

If you can explain these with real trust-boundary reasoning, your distributed identity answers will sound much more secure and architecture-aware.
