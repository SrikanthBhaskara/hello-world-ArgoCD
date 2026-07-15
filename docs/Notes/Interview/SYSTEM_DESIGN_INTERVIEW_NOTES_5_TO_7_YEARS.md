# System Design Interview Notes for 5 to 7 Years Experience

## Purpose
This document covers system design topics that are commonly expected for 5 to 7 years experience roles. It focuses on practical design questions and tradeoffs rather than very large-scale architecture theory alone.

## How to Answer System Design Questions
- Clarify requirements first.
- Separate functional requirements from non-functional requirements.
- Identify bottlenecks and failure points early.
- Explain tradeoffs, not just components.
- Mention observability, reliability, and operational safety.

---

## 1. API Design Questions

### What interviewers expect in API design answers
Interviewers usually expect more than naming endpoints. They want to know how you think about request flow, contracts, versioning, failure handling, backward compatibility, retries, security, and observability. A strong answer explains not only what the API looks like, but why the design is maintainable and safe in production.

### How do you design a clean API
Answer:
I start with clear resource definitions, consistent URLs, correct HTTP methods, structured request and response formats, validation, error handling, authentication, authorization, and versioning strategy. I also think about idempotency, retries, and observability.

Explanation:
A clean API design helps clients use the service predictably. Good API design reduces ambiguity, makes integration easier, and lowers long-term maintenance cost. In interviews, it is useful to mention stable contracts, validation of inputs, meaningful status codes, and how the API will evolve without breaking existing clients.

### What should a good API error response include
Answer:
It should include a stable error code, a human-readable message, and enough context for the client to understand the failure. Internal stack details should not be exposed unnecessarily.

Explanation:
The purpose of a good error response is to make failures actionable for clients and support teams. If error responses are inconsistent, integration becomes harder and debugging takes longer. In practice, a structured error format also helps with dashboards, alerting, and automated client handling.

### Why does idempotency matter
Answer:
It matters because distributed systems often retry requests. If the operation is idempotent, repeated requests do not create duplicate side effects.

Explanation:
Idempotency is especially important when clients, proxies, or internal services retry requests because of timeouts or partial failures. Without idempotency, a retry may create duplicate records, duplicate payments, or repeated background jobs. Mentioning this shows production awareness.

---

## 2. Caching Design Notes

### What caching really solves
Caching reduces latency and offloads repeated work from databases, services, or computation-heavy code paths. It is useful when the same data is requested frequently and recalculating or refetching that data is expensive.

### When should you use caching
Answer:
When repeated reads are expensive and the consistency tradeoff is acceptable. Caching is helpful when the same data is accessed often and the cost of recalculating or refetching is high.

Explanation:
Caching is not automatically a good idea for every system. It adds complexity, so it is most useful when performance bottlenecks are real and when slightly stale data is acceptable or controllable.

### What are the main caching challenges
Answer:
Stale data, invalidation logic, cache size control, consistency with the source of truth, and understanding what should or should not be cached.

Explanation:
In interviews, one of the strongest points you can mention is that cache invalidation is often harder than cache reads. A system with incorrect cache invalidation can return wrong results even if the database is correct. This is why caching must be designed with clear ownership and expiration behavior.

### Common follow-up points
- Cache-aside vs write-through
- TTL selection
- Cache stampede prevention
- Local cache vs distributed cache

### How to explain cache strategy in interviews
- Cache-aside means the application checks cache first and reads from the database on a miss.
- Write-through means updates go to cache and storage together.
- Local cache is faster but only visible to one instance.
- Distributed cache is shared across instances but adds network cost and operational overhead.

---

## 3. Scaling Questions

### What scaling means in interview discussion
Scaling is not only about adding more servers. It is about identifying what is failing under load and choosing the right mechanism to remove that bottleneck. A strong answer includes both technical scale and operational implications.

### Vertical vs horizontal scaling
Answer:
Vertical scaling increases resources on one machine. Horizontal scaling adds more machines or instances. Horizontal scaling is generally better for higher availability and larger traffic growth, but it adds coordination complexity.

Explanation:
Vertical scaling is simpler at first because you do not need service coordination changes. Horizontal scaling is usually more future-proof but may require stateless services, distributed caches, load balancers, and better operational tooling.

### How do you identify a scaling bottleneck
Answer:
I check whether the limit is CPU, memory, disk I/O, database throughput, network latency, lock contention, or dependency performance. Scaling should follow actual evidence, not assumptions.

Explanation:
If the database is the real bottleneck, adding app servers may not help. If latency comes from a slow dependency, scaling your own service may still not solve the problem. This is why measurement matters before architectural change.

### What design choices help scaling
- Stateless service design
- Caching
- Asynchronous workloads
- Read/write separation where appropriate
- Connection pooling
- Load balancing

### How to discuss scaling tradeoffs
- Stateless services scale more easily but may require external session or state storage.
- Async processing improves request responsiveness but adds queue and retry complexity.
- Read replicas help read-heavy systems but may introduce replication lag.

---

## 4. Logging and Observability

### Why observability matters
In production systems, failures often cannot be reproduced easily in local environments. Observability helps teams understand what happened, when it happened, and where the failure started.

### What makes logging useful in distributed systems
Answer:
Logs should be structured, correlated, and meaningful. They should include timestamps, request or trace IDs, important state transitions, dependency failures, and business context where needed.

Explanation:
Logs should help reconstruct the path of a request. Unstructured or noisy logs slow down incident response. Interviewers often appreciate answers that distinguish between useful diagnostic logging and excessive log noise.

### What else is needed besides logs
Answer:
Metrics, tracing, health checks, dashboards, alerting, and well-defined operational signals. Logs alone are often not enough for production diagnosis.

Explanation:
Metrics help detect trends, tracing helps follow request flow across services, and alerts help teams respond quickly. Together, these give much stronger production visibility than logs alone.

### Common observability questions
- What would you monitor after a deployment?
- How would you detect a partial failure?
- How would you trace one request across services?

### Good observability examples to mention
- Error rate
- Latency percentile
- Queue depth
- Retry count
- Cache hit rate
- Database slow query count

---

## 5. Queue and Asynchronous Processing

### Why teams use queues
Queues are used when work should not block user-facing requests or when a system needs to absorb burst traffic safely. They are a common way to decouple producers and consumers.

### When would you use a queue
Answer:
When work should be decoupled from a user request, when processing may be slow, when retries are needed, or when throughput smoothing is useful.

Explanation:
Examples include notifications, background file processing, delayed jobs, event handling, and workload buffering. In interviews, it helps to mention that queues improve responsiveness but do not remove the need for failure handling.

### What problems do queues solve
- Background processing
- Retry handling
- Burst smoothing
- Reduced coupling between producers and consumers

### What new complexity do queues introduce
Answer:
Retry behavior, ordering guarantees, duplicate processing, delayed visibility of failures, and more complex observability.

Explanation:
Queues move work out of the request path, but they also create hidden operational states. Jobs may be delayed, retried, duplicated, or dead-lettered. Strong design answers mention how those cases are handled.

---

## 6. Retry Design Questions

### Why retry strategy matters
Retries are often necessary in distributed systems because transient failures happen. However, naive retries can make outages worse if they increase traffic to an already struggling dependency.

### When should retries be used
Answer:
Retries are useful for transient failures such as timeouts or temporary dependency errors. They should be avoided for permanent errors or non-idempotent operations unless carefully controlled.

Explanation:
Retries should be intentional, not automatic for every failure. A safe retry strategy considers the type of error, the business operation, and whether duplicate side effects are acceptable.

### What makes retry logic safe
- Timeouts
- Limits on retry count
- Backoff strategy
- Jitter
- Idempotent operations where possible

### Explanation of backoff and jitter
Backoff increases the delay between retry attempts so the system has time to recover. Jitter randomizes retry timing so many clients do not retry at the exact same moment and overload the dependency again.

### What is retry storm risk
Answer:
If too many clients retry aggressively at once, they can make an overloaded system even worse. Backoff and rate limiting help reduce this risk.

Explanation:
This is a good place to mention that retries should work together with timeouts, circuit breakers, and rate limits. That shows a stronger production mindset.

---

## 7. Rate Limiting Questions

### Why rate limiting is important in system design
Rate limiting protects systems from overload, abuse, and accidental traffic spikes. It also helps create fairness between consumers and prevents one client from exhausting shared resources.

### Why use rate limiting
Answer:
Rate limiting protects services from abuse, overload, and accidental traffic spikes. It helps maintain fairness and system stability.

Explanation:
This is relevant in public APIs, authentication flows, file uploads, notification systems, and any endpoint vulnerable to burst traffic. Mentioning business protection as well as technical protection strengthens the answer.

### Common rate limiting approaches
- Token bucket
- Leaky bucket
- Fixed window
- Sliding window

### What tradeoffs matter
Answer:
Precision, implementation simplicity, memory cost, fairness, and whether the limiter must work across multiple instances.

Explanation:
Fixed windows are simpler but can be bursty at boundaries. Sliding windows are more accurate but more complex. Distributed rate limiting adds coordination and state-sharing requirements.

---

## 8. Database Design Questions

### What database design discussion should include
Interviewers usually expect more than choosing SQL or NoSQL. They want to hear how you think about schema shape, read/write patterns, indexing, consistency, query cost, and operational concerns.

### How do you choose SQL vs NoSQL
Answer:
I choose SQL when relationships, transactions, and structured consistency are important. I choose NoSQL when schema flexibility, very high scale, or semi-structured data matters more than relational operations.

Explanation:
The right answer depends on access patterns and business requirements. Choosing based on hype instead of workload is a weak design signal.

### What is normalization and when is denormalization useful
Answer:
Normalization reduces redundancy and improves consistency. Denormalization may be useful for read-heavy systems where query performance matters more than perfectly normalized structure.

Explanation:
Normalization is helpful for correctness and maintainability, but denormalization can improve read performance when joins become expensive or when certain views are requested frequently.

### What common database issues come up in design interviews
- Missing indexes
- N+1 queries
- Slow joins
- Connection pool exhaustion
- Hot rows or lock contention
- Read/write imbalance

### How to explain indexing in design rounds
Indexes improve read performance, but they increase write overhead and storage usage. Good answers mention that indexing should follow query patterns, not be added blindly.

---

## 9. Common System Design Scenarios

### What interviewers want in scenario answers
They want structure. Start with requirements, expected scale, important data model, critical workflows, bottlenecks, failure handling, and monitoring. You do not need the perfect architecture diagram, but you do need disciplined reasoning.

### Design a notification system
Things to discuss:
- API entry point
- Queue for async delivery
- Retry strategy
- Delivery status tracking
- Rate limiting
- Logging and observability

Explanation:
A notification system is a good example for discussing async processing, retries, user preferences, delivery guarantees, throttling, and operational visibility.

### Design a file-processing system
Things to discuss:
- Upload flow
- Storage choice
- Background processing queue
- Progress tracking
- Failure handling
- Retry and idempotency

Explanation:
This scenario is useful for showing how you think about long-running workflows, batch safety, retryable operations, and how users observe progress.

### Design a simple URL shortener or content service
Things to discuss:
- API structure
- Unique key generation
- Read-heavy traffic optimization
- Caching
- Database schema
- Metrics and abuse protection

Explanation:
This kind of scenario helps demonstrate API design, read-heavy scaling, storage tradeoffs, key generation strategy, and protection against misuse.

---

## 10. Good Answer Style for 5 to 7 Years

### Weak style
- Only naming components
- No tradeoff discussion
- No failure handling
- No observability discussion

### Strong style
- Clarify requirements first
- Identify traffic and reliability expectations
- Choose components with reasons
- Explain tradeoffs
- Cover failure handling, scaling, and monitoring

---

## 11. Quick Revision Checklist
- API design and versioning
- Idempotency
- Caching strategy and invalidation
- Scaling bottlenecks
- Queue and async design
- Retry safety and backoff
- Rate limiting models
- SQL vs NoSQL choice
- Logging, metrics, tracing
- Reliability and rollback thinking

## Final Note
For 5 to 7 years experience, system design rounds usually test whether you can think clearly about architecture tradeoffs, production risks, and operational behavior. You do not need extreme-scale answers for every question, but you do need structured reasoning, practical design choices, and awareness of failure modes.