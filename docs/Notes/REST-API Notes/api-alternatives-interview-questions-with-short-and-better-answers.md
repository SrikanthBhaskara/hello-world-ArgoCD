# API Alternatives Interview Questions with Short and Better Answers

## 1. When would you choose GraphQL over REST?
Short answer:
When clients need flexible data shapes and REST becomes inefficient.

Better answer:
I choose GraphQL when frontend consumers need different slices of related data and REST endpoints start causing overfetching, underfetching, or endpoint sprawl. I still balance that against added complexity around query governance, resolver performance, and caching.

## 2. When would you choose REST over GraphQL?
Short answer:
When the domain is simpler and operational clarity matters more.

Better answer:
REST is often the better default when resources are straightforward, HTTP semantics and caching are useful, and the team values simple observability and debuggability. It is easier for many teams to operate well at scale.

## 3. What is gRPC best suited for?
Short answer:
Internal service-to-service communication with strong contracts and efficiency needs.

Better answer:
gRPC is strongest in internal systems where typed contracts, efficient serialization, HTTP/2 features, and streaming matter. I use it more often inside microservice ecosystems than for public browser-facing APIs.

## 4. Why is gRPC less common for browser clients?
Short answer:
Because browser support is less direct than plain HTTP JSON APIs.

Better answer:
Browser integration is possible but less straightforward than REST or GraphQL. For many public-facing APIs, JSON over HTTP is simpler for tooling, inspection, debugging, and ecosystem compatibility, even if gRPC is better internally.

## 5. When would you use WebSocket?
Short answer:
When you need bidirectional real-time communication.

Better answer:
I use WebSocket for chat, live collaboration, real-time dashboards, gaming, or other use cases where both client and server need to push data actively over a long-lived connection. It adds state and operational complexity, so I do not use it when polling or SSE would be simpler.

## 6. When is SSE better than WebSocket?
Short answer:
When only the server needs to push updates to the client.

Better answer:
SSE is simpler when the communication is one-way from server to browser, such as notifications, progress updates, or event feeds. It is lighter than full bidirectional WebSocket when the client does not need to send real-time messages back over the same channel.

## 7. How do you compare GraphQL and gRPC?
Short answer:
GraphQL is consumer-flexible; gRPC is contract-strong and efficient.

Better answer:
GraphQL optimizes for client flexibility and UI-driven data composition. gRPC optimizes for strongly typed, efficient service communication. They solve different problems, so I choose based on consumer needs rather than ranking one as universally better.

## 8. What are common GraphQL risks?
Short answer:
Query complexity, N+1 issues, and operational overhead.

Better answer:
GraphQL is powerful, but without limits and good resolver design it can create expensive nested queries, unexpected load, and difficult caching behavior. Strong schema discipline and query governance are important.

## 9. What are common WebSocket challenges?
Short answer:
Connection management, scaling, and state coordination.

Better answer:
WebSocket introduces long-lived connections, connection lifecycle handling, fan-out complexity, and scaling concerns across nodes. You often need shared state or a message broker layer if many instances must broadcast or coordinate events.

## 10. How do you choose between REST, GraphQL, WebSocket, and SSE?
Short answer:
Choose based on data shape flexibility, real-time needs, and operational complexity.

Better answer:
REST is a strong default for standard request-response APIs. GraphQL is useful when consumers need flexible data composition. WebSocket is best for bidirectional real-time interaction. SSE fits one-way live updates. I pick the simplest model that satisfies user and system requirements.
