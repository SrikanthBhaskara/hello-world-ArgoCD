# API Alternatives Deep Notes: GraphQL, gRPC, WebSocket, and SSE

## Why This Topic Matters
- REST is common, but senior engineers are often expected to compare it with other API styles.
- The right protocol depends on consumer needs, latency, streaming behavior, and contract complexity.

## GraphQL

### What It Is
- client asks for exactly the fields it needs
- schema-driven query language

### Strengths
- flexible frontend consumption
- reduces overfetching or underfetching
- strong typed schema

### Risks
- query complexity
- caching is less straightforward than simple REST GET
- poor resolver design can create N+1 problems

## gRPC

### What It Is
- RPC framework often using Protocol Buffers over HTTP/2
- strong typing and efficient serialization

### Strengths
- good for service-to-service communication
- high performance
- supports streaming

### Risks
- browser compatibility is less direct than REST
- not always ideal for public APIs

## WebSocket

### What It Is
- long-lived duplex connection
- client and server can both send messages

### Best Fit
- chat
- live dashboards
- collaborative editing
- gaming

## SSE

### What It Is
- server pushes updates to client over one-way stream
- simpler than WebSocket for server-to-client event delivery

### Best Fit
- notifications
- live feed updates
- progress streaming

## How To Choose

### REST
- simple CRUD
- good caching
- broad ecosystem support

### GraphQL
- frontend flexibility matters
- many consumers need different data shapes

### gRPC
- internal low-latency typed service communication

### WebSocket
- true bidirectional real-time communication

### SSE
- one-way server updates with simpler model

## Interview Questions

### GraphQL vs REST?
Short answer:
GraphQL offers flexible querying; REST is simpler and easier to cache and reason about.

Better answer:
I choose GraphQL when consumers need variable shapes and many related objects efficiently, especially in frontend-heavy applications. I choose REST when the domain is simpler, caching matters, and operational clarity is more valuable than query flexibility.

### gRPC vs REST?
Short answer:
gRPC is usually better for internal typed service-to-service communication.

Better answer:
I prefer gRPC for internal microservice calls where performance, strict contracts, and streaming matter. I still often expose REST or another browser-friendly interface externally because tooling, debuggability, and client compatibility are simpler for public consumers.
