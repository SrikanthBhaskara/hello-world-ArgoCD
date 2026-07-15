# API Gateway and Traffic Management Deep Notes

These notes focus on API gateway responsibilities, traffic control, edge security, and request governance. The goal is not just to name products like Kong, Apache APISIX, or AWS API Gateway, but to understand what problems gateways solve and what risks they introduce.

## 1. What an API Gateway Is

An API gateway is the controlled entry point for API traffic.

It commonly handles:
- request routing
- authentication handoff or verification
- rate limiting
- throttling
- request and response policy enforcement
- payload validation
- observability and tracing

Important point:
- a gateway should centralize cross-cutting traffic concerns
- it should not become a giant business-logic monolith

## 2. Why Teams Use API Gateways

Gateways are valuable when:
- many clients call many services
- edge security must be standardized
- traffic policies must be consistent
- public-facing APIs need strong governance

Typical benefits:
- single controlled entry point
- reduced repeated policy logic in every service
- easier rollout of edge protections
- better request visibility

## 3. Common Products

Common gateway choices:
- Kong
- Apache APISIX
- AWS API Gateway
- Spring Cloud Gateway

### Kong

Kong is widely used for:
- plugin-based policy management
- authentication policies
- rate limiting
- request transformation

### Apache APISIX

APISIX is strong for:
- dynamic routing
- plugin-driven traffic control
- high-performance gateway use cases

### AWS API Gateway

AWS API Gateway is useful when:
- the system already fits AWS-managed platform patterns
- serverless or managed API exposure is preferred
- IAM and AWS-native integrations matter

Interview answer:
- I choose gateway technology based on operating model, cloud fit, plugin needs, and traffic scale. The gateway product matters, but the architecture decisions around routing, security, and policy ownership matter more.

## 4. Core Gateway Responsibilities

A mature gateway often provides:
- route mapping
- authentication integration
- authorization context propagation
- request validation
- response normalization
- rate limiting
- auditability
- edge observability

It may also provide:
- header transformation
- canary or weighted routing
- circuit-breaking support at the edge

## 5. Routing at the Edge

Routing rules can use:
- path
- host
- method
- headers
- version prefix

Examples:
- `/v1/orders` to one service
- `/v2/orders` to another service version
- internal admin routes to a stricter policy path

Important:
- route ownership should be explicit
- versioning and routing policies should not become chaotic

## 6. Rate Limiting vs Throttling

These terms are related but not identical.

### Rate Limiting

Rate limiting controls how many requests are allowed over time.

Example:
- 100 requests per minute per API key

### Throttling

Throttling slows, rejects, or constrains traffic when usage exceeds a safe boundary.

Example:
- returning `429 Too Many Requests`
- limiting burst behavior

Simple explanation:
- rate limiting defines allowed traffic policy
- throttling is how excess traffic is controlled

## 7. Token Bucket

Token Bucket allows bursts while enforcing average rate over time.

How it works:
- tokens refill at a fixed rate
- each request consumes a token
- if tokens exist, request passes
- if not, request is rejected or delayed

Why useful:
- handles short bursts better
- keeps long-term traffic within policy

Good use cases:
- public APIs
- client-level rate policies
- burst-tolerant traffic control

## 8. Leaky Bucket

Leaky Bucket smooths output to a more constant rate.

How it works:
- requests enter a bucket or queue
- requests are processed at a fixed outflow rate
- excess beyond capacity is dropped or rejected

Why useful:
- protects downstream systems from burst spikes
- creates steadier flow

Difference from Token Bucket:
- Token Bucket allows short bursts more naturally
- Leaky Bucket emphasizes steady output

## 9. Choosing a Rate Limiting Strategy

Use Token Bucket when:
- burst tolerance matters
- short-lived spikes are acceptable

Use Leaky Bucket when:
- downstream smoothing matters more
- you want steadier outgoing flow

Also common:
- fixed window
- sliding window

Interview answer:
- I choose rate limiting based on whether the system needs burst tolerance or steady downstream protection. Token Bucket is usually better for client experience under bursts, while Leaky Bucket is often better for smoothing traffic.

## 10. Where to Apply Rate Limiting

Possible scopes:
- per IP
- per user
- per API key
- per tenant
- per route
- per service

Important design question:
- what identity is the limit keyed on

Bad design:
- global limit only, with no tenant awareness

## 11. Payload Validation at the Gateway

Gateways may validate:
- request size
- required headers
- content type
- schema shape in some architectures
- basic field presence or format

Why useful:
- reject obviously bad traffic early
- reduce waste on backend services

But be careful:
- deep business validation usually belongs in the service
- gateway validation should stay at the traffic policy and contract hygiene layer

## 12. Request Size and Abuse Protection

Gateways should often enforce:
- payload size limits
- header size limits
- timeout limits
- malformed-request rejection

Why:
- prevent abuse
- reduce accidental overload
- protect upstream services

## 13. Authentication at the Gateway

A gateway may:
- verify JWTs
- integrate with OAuth2/OIDC
- validate API keys
- forward trusted identity headers internally

Important:
- internal services must trust the identity propagation model carefully
- do not trust arbitrary caller headers without a trusted gateway or proxy boundary

## 14. Gateway and Observability

A good gateway should emit:
- request counts
- latency
- status codes
- rejected request reasons
- rate limit hits
- route-level traffic distribution

Why important:
- edge failures often appear before application failures
- gateway telemetry helps explain whether the problem is traffic policy, auth failure, backend latency, or abuse

## 15. Common Gateway Risks

Bad patterns:
- too much business logic in gateway plugins
- unclear route ownership
- weak rate-limit design
- inconsistent auth handling across routes
- forwarding unsafe headers
- not testing rollback of traffic policy changes

## 16. Product-Oriented Notes

### Kong

Good for:
- plugin-rich policy handling
- auth and rate limiting integration
- enterprise API governance

### Apache APISIX

Good for:
- dynamic routing and plugin-driven traffic management
- high-performance gateway scenarios

### AWS API Gateway

Good for:
- managed AWS-native API exposure
- Lambda and AWS integrations
- reducing self-managed gateway overhead

Strong answer:
- I think of Kong and APISIX as flexible gateway platforms, while AWS API Gateway is a managed cloud service choice. The right answer depends on whether the team values plugin flexibility, managed operations, or cloud-native integration most.

## 17. What Different Experience Levels Should Know

### 0 to 2 years

Should know:
- what an API gateway is
- why rate limiting matters
- basic routing and validation purpose

### 2 to 4 years

Should know:
- rate limiting algorithms
- throttling behavior
- payload validation boundaries
- auth integration basics

### 4 to 7 years

Should know:
- choosing gateway products intentionally
- traffic policy design by tenant/client/route
- safe identity propagation
- how gateway changes affect resilience and blast radius
- when not to push more logic into the gateway

If you can explain these with examples and tradeoffs, your gateway discussion will sound much more senior and architecture-ready.
