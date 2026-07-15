# Reliability Engineering Deep Notes

## Reliability Mindset
- Reliability is the ability of a system to keep delivering acceptable service under normal load, failures, and sudden spikes.
- A 5 to 7 year engineer is usually expected to talk about prevention, detection, mitigation, and recovery, not just feature delivery.

## Core Goals
- high availability
- graceful degradation
- predictable latency
- controlled failure domains
- fast recovery
- measurable service health

## Reliability Building Blocks

### Auto-Scaling
- Horizontal scaling adds more instances when load rises.
- Common metrics:
  - CPU
  - memory
  - request rate
  - queue depth
  - custom business metrics like active jobs

Interview point:
- CPU-only scaling is often not enough for IO-heavy services.

### Load Shedding
- Reject low-priority work when the system is saturated.
- Protect critical paths first.

### Rate Limiting
- Prevents bad clients or sudden bursts from exhausting shared resources.
- Works best at the edge before the request reaches expensive downstream systems.

### Circuit Breakers
- Stop repeated calls to a failing dependency.
- States:
  - closed
  - open
  - half-open
- Prevents thread pool exhaustion and cascading latency.

### Bulkheads
- Isolate resources so one failing dependency does not consume all threads or connections.

### Timeouts
- Every network call needs connect and read timeouts.
- Missing timeouts are a classic production incident cause.

### Retries with Backoff
- Retry only transient failures.
- Use exponential backoff with jitter.
- Do not retry unsafe non-idempotent operations blindly.

## Graceful Degradation
- Keep the most important user journey alive even if secondary features fail.

Examples:
- return cached product catalog if recommendation service is down
- accept order but defer invoice PDF generation
- disable analytics, keep checkout available

## Reliability During Traffic Spikes

### Good Strategy
1. absorb burst with queue or buffer
2. rate limit at edge
3. auto-scale stateless layers
4. protect dependencies with circuit breakers
5. degrade optional features
6. monitor saturation and error budget burn

### Bad Strategy
- keep retrying every failing dependency
- let unlimited work pile up
- scale app pods without checking DB, cache, or queue bottlenecks

## Observability and SRE Signals

### Golden Signals
- latency
- traffic
- errors
- saturation

### Additional Useful Signals
- queue lag
- retry rate
- circuit breaker open count
- dependency latency
- pod restart count
- p95 and p99 latency

## SLI, SLO, SLA
- SLI: actual measurement, like successful request ratio.
- SLO: target, like 99.9 percent availability.
- SLA: external contractual promise, often tied to penalties.

## Error Budgets
- If the service has a 99.9 percent monthly availability goal, the remaining 0.1 percent is the error budget.
- Teams can use error budget burn to decide whether to slow feature releases and focus on stability.

## Reliability Patterns for Microservices
- health checks and readiness probes
- liveness checks used carefully
- async decoupling with queues
- idempotent consumers
- fallback responses
- cached reads for non-critical features
- blue-green or canary deployments
- fast rollback strategy

## Production Incident Example

Scenario:
- traffic spikes 5x after a campaign
- app pods scale out
- database connection pool saturates
- retries increase
- latency explodes

Good answer:
- identify the true bottleneck first
- rate limit non-critical endpoints
- reduce retry storm
- enforce DB connection caps
- enable caching or read replicas if applicable
- scale app only if downstream can handle it
- after incident, add queue-based buffering and better autoscaling signals

## Kubernetes Reliability Thinking
- readiness probe should fail before the service is truly broken for users
- HPA should consider meaningful metrics
- pod disruption budgets protect rolling updates
- resource requests and limits must be realistic
- cluster autoscaler helps only if workloads are schedulable and dependencies can scale

## CI/CD and Reliability
- use small deployments
- health-check before full rollout
- automate rollback conditions
- track change failure rate
- canary high-risk changes

## Reliability Interview Questions

### How do you handle sudden traffic spikes?
Short answer:
Use auto-scaling, rate limiting, circuit breakers, and graceful degradation.

Better answer:
I would protect the system in layers: rate limit at the edge, scale stateless services on meaningful metrics, stop dependency cascades with timeouts and circuit breakers, shed low-priority traffic, and degrade optional features so the most critical workflow stays available.

### Why is auto-scaling alone not enough?
Short answer:
Because the bottleneck may be the database, cache, queue, or third-party dependency.

Better answer:
Scaling app instances without understanding downstream capacity often makes incidents worse by increasing concurrency against the real bottleneck. Reliable systems scale end to end and apply protection patterns like queues, backpressure, circuit breakers, and connection limits.
