# API Alternatives Scenarios and Architecture Tradeoffs

## 1. Frontend Needs Different Data Shapes Per Screen

### Better Fit
- GraphQL may be useful

### Why
- different screens can request different fields without many custom REST endpoints

### Tradeoff
- more resolver complexity
- caching and query governance need more discipline

## 2. Internal Services Need Fast Typed Communication

### Better Fit
- gRPC may be useful

### Why
- strong contracts
- efficient payloads
- good streaming support

### Tradeoff
- less friendly for browser-first public clients
- harder human inspection than JSON APIs

## 3. Live Dashboard Needs Continuous Server Updates

### Better Fit
- SSE if updates are one-way
- WebSocket if updates are truly bidirectional

### Tradeoff
- WebSocket adds more connection lifecycle and scaling complexity
- SSE is simpler but only server-to-client

## 4. Public API for Many External Consumers

### Better Fit
- REST often remains the safest default

### Why
- broad tooling support
- easy inspection
- strong HTTP familiarity

### Tradeoff
- can lead to overfetching or too many endpoints if consumer needs vary widely

## 5. Chat or Collaborative Editing

### Better Fit
- WebSocket

### Why
- low-latency bidirectional communication matters

### Tradeoff
- connection scaling, state sharing, and fan-out become operational concerns

## 6. Progress Updates from Long-Running Server Task

### Better Fit
- SSE can be simpler than WebSocket

### Why
- the server mainly needs to push updates

### Tradeoff
- if the client later needs active two-way real-time interaction, SSE may stop being enough

## 7. Browser Compatibility and Simplicity Matter Most

### Better Fit
- REST or SSE, depending on real-time need

### Why
- both are easier to reason about in browser-heavy products than more specialized alternatives

## 8. Interview Question: How do you choose?

### Strong answer
- I do not choose based on trend or preference.
- I start from consumer needs:
  - standard request-response -> REST
  - flexible screen-driven data composition -> GraphQL
  - internal typed service-to-service performance -> gRPC
  - bidirectional real-time -> WebSocket
  - one-way live updates -> SSE
- Then I check operational cost, caching, debugging, scaling, browser support, and team familiarity.
