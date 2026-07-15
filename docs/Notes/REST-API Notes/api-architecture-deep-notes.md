# API Architecture Deep Notes

These notes cover secure, versioned, and idiomatic API design across REST, GraphQL, and gRPC. The goal is not just to know the technologies, but to understand when to use them, how to evolve them safely, and how to avoid designs that create long-term operational pain.

## 1. What API Architecture Really Means

API architecture is the design of how systems expose capabilities to clients and to other services.

A strong API architecture answers:
- what style should the API use
- how clients authenticate and authorize
- how the API evolves without breaking consumers
- how errors, pagination, idempotency, and observability are handled
- how latency, security, and consistency concerns are managed

Good API design is not only about endpoints working today. It is about making the interface predictable, safe, and maintainable over time.

## 2. Common API Styles

The most common styles in backend systems are:
- REST
- GraphQL
- gRPC

Each has a different strength profile.

## 3. REST API Design

REST is the most common HTTP API style for external and internal business services.

Strong REST principles:
- model resources, not actions
- use HTTP verbs correctly
- use meaningful status codes
- make URLs predictable
- support pagination, filtering, and sorting where needed
- keep request and response contracts stable

Good examples:
- `GET /orders/123`
- `POST /orders`
- `PATCH /orders/123`

Less idiomatic examples:
- `POST /createOrder`
- `GET /getAllOrders`

Interview answer:
- A well-designed REST API is resource-oriented, predictable, and explicit about HTTP semantics. Good REST is not only about using JSON over HTTP, but about making contracts stable and behavior easy for clients to understand.

## 4. REST Versioning

API versioning is needed when behavior or contract shape must evolve without breaking existing consumers.

Common approaches:
- URI versioning: `/v1/orders`
- header versioning
- media type versioning

For most business systems, URI versioning is easiest to communicate and support operationally.

When to version:
- breaking field changes
- major response structure changes
- semantics change in a way that old clients would misbehave

When not to version:
- adding optional fields
- adding non-breaking endpoints

Best practice:
- prefer backward-compatible evolution first
- version only when necessary
- document deprecation clearly

## 5. REST Security

Common security controls:
- HTTPS everywhere
- authentication
- authorization
- input validation
- rate limiting
- auditability

Authentication options:
- session-based
- API keys
- OAuth2/OIDC
- JWT-based flows

Authorization questions:
- who is the caller
- what may they do
- what data may they see

Security mistakes to avoid:
- exposing internal errors directly
- trusting client-provided identity blindly
- missing validation on path/query/body values
- weak rate limits on expensive endpoints
- inconsistent authorization across similar endpoints

## 6. GraphQL Architecture

GraphQL lets clients request exactly the fields they need through a schema-driven query model.

Strengths:
- flexible client data fetching
- fewer over-fetching and under-fetching issues
- strong schema-driven contract

Weaknesses:
- query complexity can become dangerous
- caching is often less straightforward than REST
- resolver design can create hidden N+1 query problems
- authorization must still be enforced carefully at field or resolver level

Good use cases:
- frontend-heavy products with variable data needs
- multiple clients that need different slices of the same model

Risky use cases:
- simple CRUD systems that do not need GraphQL complexity
- teams without strong schema governance

Interview answer:
- GraphQL is powerful when clients need flexible data selection, but I only choose it when the flexibility is worth the added complexity around query cost, authorization, and resolver performance.

## 7. GraphQL Security and Governance

Important protections:
- query depth limits
- query complexity limits
- resolver-level authorization
- persisted queries where appropriate
- rate limiting

N+1 problem example:
- one query asks for 100 orders
- each order triggers a separate customer lookup
- total query count explodes

Common solution:
- batch loading
- careful resolver design

## 8. gRPC Architecture

gRPC is a high-performance RPC framework built around Protocol Buffers.

Strengths:
- efficient binary protocol
- strongly typed contracts
- excellent internal service-to-service communication
- streaming support

Weaknesses:
- not as browser-friendly as REST
- debugging by humans is less intuitive than JSON APIs
- not always the right default for public APIs

Good use cases:
- internal microservice communication
- low-latency service-to-service calls
- streaming and strongly typed internal platforms

Interview answer:
- I usually think of gRPC as a strong internal communication choice when performance, strong contracts, and efficient service-to-service interaction matter more than public-web simplicity.

## 9. gRPC Versioning

Versioning in gRPC usually happens through schema evolution discipline.

Safe changes:
- adding new optional fields
- adding new services or methods

Risky changes:
- changing field numbers
- reusing removed field numbers
- changing semantics without coordination

Important rule:
- field numbers are part of the contract

## 10. Choosing Between REST, GraphQL, and gRPC

Simple decision guidance:

Use REST when:
- API is public or broadly consumed
- HTTP semantics matter
- simplicity and debuggability are important

Use GraphQL when:
- clients need flexible field selection
- data aggregation patterns vary heavily
- schema governance is strong

Use gRPC when:
- services communicate internally
- low latency matters
- strong contracts and streaming are valuable

Strong answer:
- I choose API style based on client needs, operational complexity, and evolution pressure. I do not choose GraphQL or gRPC just because they are modern. REST often remains the best default unless the use case clearly benefits from a different model.

## 11. Idempotency and Safe Retries

Distributed systems retry. APIs must handle that safely.

Important ideas:
- `GET`, `PUT`, and `DELETE` should usually be idempotent by semantics
- `POST` often needs explicit idempotency design for critical operations

Example:
- payment creation should often use an idempotency key

Without idempotency:
- duplicate charges
- duplicate orders
- duplicate side effects

## 12. Pagination, Filtering, and Sorting

Large collections should not return unlimited data.

Need:
- pagination
- filtering
- sorting

Typical patterns:
- page/size
- cursor pagination for larger or more dynamic datasets

Cursor pagination is often better for:
- large datasets
- real-time changing datasets

## 13. Error Handling and Status Design

Strong APIs define:
- correct HTTP or RPC-level status
- structured error body
- stable error codes
- safe messages

Do not:
- return `200 OK` for every error
- leak stack traces
- force clients to parse human-only messages

Good error structure usually includes:
- machine-readable code
- human-readable message
- correlation/request identifier

## 14. API Security Beyond Authentication

Also think about:
- mass assignment risk
- object-level authorization
- rate limiting
- replay protection
- schema abuse in GraphQL
- service-to-service trust in internal APIs

For internal APIs:
- mTLS may matter
- workload identity or IAM-based auth may matter

## 15. Observability for APIs

A production-grade API should expose:
- request rate
- error rate
- latency
- status code distribution
- dependency latency
- trace and request IDs

For APIs, observability is not optional because correctness problems often appear as:
- latency spikes
- partial failures
- timeout cascades
- unexpected client error patterns

## 16. Backward Compatibility Thinking

Strong API teams:
- prefer additive changes
- avoid renaming or deleting fields casually
- publish deprecation timelines
- communicate breaking changes clearly

For GraphQL:
- deprecate fields before removal

For gRPC:
- preserve field numbers and schema compatibility

## 17. Common Anti-Patterns

Bad patterns:
- verbs everywhere in REST URLs
- no versioning strategy at all
- weak authorization on nested resources
- exposing internal entity structure directly
- no idempotency for retry-prone operations
- choosing GraphQL or gRPC without clear need
- unstable error contracts

## 18. What Different Experience Levels Should Know

### 0 to 2 years

Should know:
- what REST is
- basic HTTP methods and status codes
- why versioning exists
- why authentication and validation matter

### 2 to 4 years

Should know:
- REST resource design
- idempotency basics
- pagination and filtering
- difference between REST, GraphQL, and gRPC
- basic security and error contract design

### 4 to 7 years

Should know:
- API evolution and backward compatibility
- choosing between API styles intentionally
- contract safety under retries and distributed failure
- operational tradeoffs of GraphQL and gRPC
- secure multi-client API design

If you can explain these clearly with examples and tradeoffs, your API architecture discussion will sound much more senior.
