# Microservices Deep Notes

These notes are for understanding microservices from both learning and interview perspectives. The goal is not only to know definitions, but to explain where microservices help, where they hurt, and how to operate them safely in production.

## 1. What Microservices Actually Mean

Microservices are an architectural style where a system is broken into smaller services, each owning a specific business capability.

Examples:
- Order service
- Payment service
- Inventory service
- Notification service

Each service usually has:
- Its own codebase or deployable unit
- Its own database or data ownership boundary
- A well-defined API or event contract
- Independent deployment and scaling

Important point:
- Microservices are not just "small services"
- Microservices are about clear ownership, isolation, and independent evolution

## 2. Monolith vs Microservices

### Monolith

In a monolith:
- All business modules are part of one application
- Deployment is usually a single unit
- Simpler local development and debugging
- Easier transactions inside one database

Monolith strengths:
- Faster to build early
- Easier debugging
- Simpler deployment
- Lower operational complexity

Monolith weaknesses:
- Harder to scale selectively
- Large codebase can become tightly coupled
- Release cycles become slower as teams grow

### Microservices

Microservices strengths:
- Independent deployments
- Team ownership by domain
- Independent scaling
- Technology flexibility where justified
- Better fault isolation when designed well

Microservices weaknesses:
- Network failures become part of normal behavior
- Distributed debugging is harder
- Data consistency is more complex
- CI/CD, observability, and platform maturity become mandatory

Interview answer:
- I do not treat microservices as the default. I choose them when domain boundaries, team scale, deployment independence, or scaling patterns justify the extra distributed-system complexity.

## 3. Modular Monolith vs Microservices

A modular monolith is often the better starting point.

Why:
- You still separate modules by domain
- You avoid network overhead between modules
- Refactoring service boundaries is easier before hard separation

When a modular monolith is better:
- Product is early
- Team is small
- Domain boundaries are still evolving
- Operational maturity is low

When microservices become reasonable:
- Different modules need independent release cycles
- Some components need very different scaling
- Teams need strong ownership boundaries
- Domain complexity is large enough to justify separation

## 4. Bounded Context and Service Boundaries

The most important microservices decision is service boundary design.

Good boundaries are usually based on business capability, not technical layers.

Bad split:
- User controller service
- User repository service
- User validation service

Better split:
- Identity service
- Customer profile service
- Billing service

Questions to decide boundaries:
- Which team owns this capability?
- Which data changes together?
- Which rules belong together?
- Which parts need independent scaling?
- Which changes can be released separately?

Warning signs of bad boundaries:
- Too many cross-service calls for one user request
- Shared database tables across services
- Services cannot function without many synchronous dependencies
- Multiple teams changing the same contract frequently

## 5. Database Per Service

One common principle is database per service.

Why:
- Prevent tight coupling at the data layer
- Preserve team autonomy
- Avoid one service breaking another through schema change

This does not always mean one physical database server per service. It means ownership separation.

Acceptable patterns:
- Separate schema with strict ownership
- Separate logical database
- Separate physical database for strong isolation

Bad pattern:
- Service A directly reading Service B database tables for convenience

Why bad:
- Breaks ownership
- Creates hidden coupling
- Makes schema evolution risky

## 6. Communication Patterns

### Synchronous Communication

Common options:
- REST
- gRPC

Use synchronous calls when:
- Caller needs immediate response
- Operation is request-response in nature
- User flow depends on result right now

Risks:
- Higher latency
- Cascading failures
- Runtime coupling

### Asynchronous Communication

Common options:
- Kafka
- RabbitMQ
- SNS/SQS
- EventBridge

Use asynchronous messaging when:
- Workflow can be decoupled
- Event propagation is needed
- Retry and buffering are useful
- High throughput matters

Benefits:
- Better decoupling
- Improved resilience
- Easier fan-out

Tradeoff:
- More complex debugging
- Eventual consistency
- Ordering and duplicate handling concerns

Interview answer:
- I prefer asynchronous communication for domain events and background workflows, and synchronous calls only where a direct response is required by the business flow.

## 7. API Contracts

Microservices survive only when contracts are stable.

Good API contract practices:
- Version carefully
- Keep responses backward compatible where possible
- Validate input clearly
- Return meaningful error codes
- Publish API documentation

Important idea:
- Service contract is not just endpoint shape
- It includes payloads, error behavior, authentication, timeouts, idempotency, and SLAs

Examples of compatibility-safe changes:
- Adding optional field
- Adding new endpoint

Risky changes:
- Renaming existing field
- Changing field type
- Removing response field
- Changing semantics without version strategy

## 8. Data Consistency in Microservices

Strong ACID transactions across services are usually avoided.

Why:
- They do not scale well across distributed services
- They create blocking and tight coupling

Instead, systems usually use:
- Eventual consistency
- Sagas
- Compensating actions
- Idempotent consumers
- Retries with controls

### Saga Pattern

Saga coordinates a multi-step business process across services.

Example:
1. Order service creates order in PENDING state
2. Payment service charges payment
3. Inventory service reserves stock
4. Shipping service prepares shipment
5. Order becomes CONFIRMED

If inventory reservation fails:
- Payment may need refund
- Order may move to FAILED

Two common saga styles:
- Choreography: services react to events
- Orchestration: central coordinator controls the flow

### Outbox Pattern

Problem:
- Database update succeeds but event publish fails

Solution:
- Write business data and outbox event in same local transaction
- Background process publishes outbox records to broker

This avoids losing events after database commit.

## 9. Idempotency

In distributed systems, retries are normal. So operations must often be idempotent.

Idempotent means:
- Repeating the same request does not produce unintended duplicate effects

Examples:
- Payment request with idempotency key
- Order creation using client request ID
- Consumer tracking processed event IDs

Without idempotency:
- Duplicate orders
- Duplicate charges
- Duplicate emails

## 10. Resilience Patterns

Failures in microservices are expected, not exceptional.

Important patterns:
- Timeout
- Retry
- Circuit breaker
- Bulkhead
- Fallback
- Rate limiting

### Timeout

Always define client-side timeouts.

Without timeout:
- Threads get stuck
- Request queues grow
- System becomes slow before it fully fails

### Retry

Use retries only for transient failures.

Good retry cases:
- Temporary network issue
- Short downstream overload

Bad retry cases:
- Validation failures
- Authentication failures
- Permanent business rule failures

Retry best practices:
- Use exponential backoff
- Add jitter
- Limit retry count
- Make operation idempotent

### Circuit Breaker

If downstream service is failing repeatedly:
- Stop sending full traffic immediately
- Fail fast for a short period
- Probe recovery later

Why:
- Protect calling service
- Prevent resource exhaustion
- Reduce cascading failures

## 11. Observability

In microservices, logs alone are not enough.

You need:
- Metrics
- Logs
- Distributed tracing
- Correlation IDs
- Dashboards
- Alerting

### Metrics

Track:
- Request rate
- Error rate
- Latency percentiles
- JVM and container memory
- Queue lag
- Retry count
- Circuit breaker open state

### Logs

Logs should be:
- Structured
- Searchable
- Correlated by trace or request ID

### Tracing

Tracing shows request flow across services.

Example flow:
- API gateway
- Order service
- Payment service
- Inventory service

Tracing helps answer:
- Which service introduced latency?
- Where did the request fail?
- Which downstream dependency is unstable?

Interview answer:
- In distributed systems, I rely on correlation IDs and tracing because production issues usually cross service boundaries, and logs from one service alone rarely tell the full story.

## 12. API Gateway

API gateway acts as the entry point for clients.

Common responsibilities:
- Routing
- Authentication
- Rate limiting
- TLS termination
- Request/response transformation
- Aggregation in some cases

Benefits:
- Simplifies client interaction
- Centralizes cross-cutting policies

Risk:
- Gateway can become a bottleneck or a monolith if overloaded with business logic

Rule:
- Keep business orchestration out of the gateway unless there is a strong reason

## 13. Service Discovery and Configuration

In dynamic environments, service addresses change.

Solutions:
- Kubernetes service discovery
- Eureka
- Consul
- DNS-based discovery

Configuration concerns:
- Externalized configuration
- Environment-specific overrides
- Secret management
- Feature flags

Do not:
- Hardcode downstream URLs in code
- Bake secrets directly into images

## 14. Security in Microservices

Common security concerns:
- Authentication
- Authorization
- Service-to-service trust
- Secret management
- Token propagation
- Encryption in transit

Typical patterns:
- OAuth2 or OIDC for users
- JWT token propagation
- mTLS in internal service mesh environments
- IAM roles or workload identity for cloud service access

Important point:
- Authentication tells who the caller is
- Authorization tells what the caller can do

Production concern:
- Avoid trusting only headers from upstream unless they are added by a trusted gateway or proxy

## 15. Deployment and Release Patterns

Microservices need safe release strategies.

Common patterns:
- Rolling deployment
- Blue-green deployment
- Canary deployment
- Feature flags

Why feature flags matter:
- Deploy code separately from release exposure
- Reduce rollback scope
- Validate behavior gradually

Good production practice:
- Roll out one service gradually
- Watch latency, error rate, and downstream impact
- Keep rollback path ready

## 16. Scaling

Microservices support selective scaling, but only if the boundary is correct.

Examples:
- Search service may need high CPU scaling
- Notification service may need asynchronous worker scaling
- Reporting service may need batch-oriented scaling

Important:
- Scaling one overloaded service is better than scaling the whole monolith
- But network chatter can erase that benefit if the design is poor

Scaling decisions should consider:
- CPU
- Memory
- I/O wait
- DB connection limits
- Queue lag
- External dependency throughput

## 17. Caching in Microservices

Common cache locations:
- Client cache
- CDN
- API gateway cache
- Service local cache
- Distributed cache like Redis

Use cache when:
- Data is frequently read
- Staleness is acceptable for some period
- Expensive computation or repeated reads exist

Risks:
- Stale data
- Cache invalidation complexity
- Hidden production bugs due to inconsistent refresh

Interview answer:
- I treat cache as a performance optimization, not a source of truth. I define ownership, TTL strategy, and invalidation behavior before introducing it.

## 18. Testing Strategy

Microservices require layered testing.

Useful levels:
- Unit tests
- Component tests
- Contract tests
- Integration tests
- End-to-end tests
- Chaos or resilience testing

### Contract Testing

Contract testing validates that producer and consumer agree on API shape and behavior.

Why important:
- Prevents integration breakage
- Reduces fear of independent deployment

### End-to-End Testing

Needed, but should not be the only safety net.

Why not enough:
- Slow
- Brittle
- Hard to debug

## 19. Common Anti-Patterns

### Distributed Monolith

Looks like microservices on paper, but:
- Services cannot deploy independently
- Every request depends on many synchronous calls
- One change forces coordinated releases

### Shared Database

Multiple services directly updating same tables.

Why harmful:
- Destroys ownership
- Causes schema coupling
- Makes incidents harder to isolate

### Chatty Communication

One request triggers many internal calls just to build a response.

Problems:
- High latency
- More failure points
- More operational cost

### Nanoservices

Services become too small and meaningless.

Problem:
- Operational overhead becomes higher than business value

### Overusing Synchronous Calls

If every workflow needs immediate downstream responses, the system becomes fragile.

## 20. Real Production Troubleshooting Thinking

When one service is failing, do not guess based only on application code.

Check:
1. Is the issue in this service or downstream?
2. Is latency increasing or error rate increasing?
3. Are retries making the situation worse?
4. Did a deployment happen recently?
5. Is the database or message broker under pressure?
6. Are connection pools exhausted?
7. Is there queue lag or consumer backlog?
8. Is a circuit breaker opening?
9. Is there a config or secret mismatch?
10. Is one noisy dependency affecting all requests?

Strong interview answer:
- I start with scope, recent change correlation, golden signals, and dependency health before jumping into code assumptions. In distributed systems, the first visible failure is often not the root cause.

## 21. Sample Architecture Flow

Example e-commerce flow:

1. Client sends order request through API gateway
2. Order service validates and creates order
3. Order service writes order and outbox event
4. Event broker publishes `OrderCreated`
5. Payment service consumes event and processes payment
6. Inventory service reserves stock
7. Notification service sends confirmation
8. Order service updates final status after workflow completion

Good design traits:
- Each service owns its own data
- Event flow is traceable
- Failures are retried safely
- Compensation exists for partial failure
- Monitoring exists across the full request path

## 22. Interview Tradeoff Statements

These help you sound practical:

- Microservices improve autonomy, but only if service boundaries are stable and operational maturity is strong.
- A modular monolith is often the right first step before service extraction.
- Independent deployability matters more than service count.
- Eventual consistency is normal in distributed systems, but it must be designed deliberately.
- Retries without idempotency are dangerous.
- Shared databases make teams faster in the short term and slower in the long term.
- Distributed tracing is not optional once request flow crosses multiple services.

## 23. What 5 to 7 Years Interviewers Expect

At this level, interviewers usually expect more than definitions.

They expect you to explain:
- How you choose service boundaries
- How you avoid distributed monoliths
- How you handle partial failures
- How you manage consistency without distributed transactions
- How you design observability
- How you roll out changes safely
- How you investigate incidents
- What tradeoffs led you to choose synchronous or asynchronous communication

Strong answer style:
- Start with the business requirement
- Explain the tradeoff
- Mention failure handling
- Mention operational impact
- Mention how you would validate it in production

## 24. Final Revision Checklist

Before interviews, make sure you can explain:
- monolith vs modular monolith vs microservices
- bounded context and domain ownership
- database per service
- sync vs async communication
- saga and outbox patterns
- idempotency
- retries, timeout, circuit breaker, bulkhead
- tracing, metrics, structured logs
- API gateway and service discovery
- security in service-to-service communication
- deployment safety and rollback
- common anti-patterns
- real production troubleshooting approach

If you can explain these with examples and tradeoffs, your microservices discussion will sound much more senior and production-ready.
