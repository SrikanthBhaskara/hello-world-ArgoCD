# Distributed Rate Limiting Algorithms Deep Notes

## Why Rate Limiting Matters
- Protects services from abuse and traffic spikes.
- Preserves fair usage across clients.
- Prevents expensive downstream overload.
- Gives predictable capacity behavior during incidents.

## Common Interview Question
- "How would you implement a distributed rate limiter for APIs across many app instances?"

The expected answer usually includes:
- algorithm choice
- shared state store like Redis
- atomic update logic
- latency and accuracy tradeoffs
- per-user, per-tenant, or per-route limits

## Core Algorithms

### Fixed Window Counter
- Example: 100 requests per minute.
- Count requests in the current minute bucket.
- Simple and fast.

Problem:
- Boundary burst issue.
- A client can send 100 requests at `12:00:59` and another 100 at `12:01:01`.

### Sliding Window Log
- Store timestamp of each request.
- Remove timestamps older than the window.
- Current size of log is the request count.

Pros:
- Very accurate.

Cons:
- More memory heavy.
- More expensive at large scale.

### Sliding Window Counter
- Hybrid approach that approximates sliding behavior using neighboring buckets.
- Better balance between accuracy and storage.

### Token Bucket
- Tokens are added at a fixed refill rate.
- Each request consumes a token.
- If bucket is empty, reject or queue.

Pros:
- Supports controlled bursts.
- Very common for APIs.

### Leaky Bucket
- Requests enter a bucket and leave at a constant rate.
- Smooths traffic.

Pros:
- Good for shaping outgoing traffic.

## When to Choose What
- Fixed window: simplest internal admin tools.
- Token bucket: most public APIs and gateway-level controls.
- Sliding window log: when fairness accuracy matters more than storage cost.
- Leaky bucket: traffic shaping and smoothing.

## Redis-Based Distributed Design

### Why Redis
- Fast in-memory store.
- Atomic operations with Lua scripts.
- TTL support for cleanup.
- Shared across many app instances.

### Token Bucket with Redis
- Key example: `rl:tenant123:/payments`
- Store:
  - current tokens
  - last refill timestamp
- Each request:
  - compute elapsed time
  - refill tokens based on rate
  - if tokens >= 1, decrement and allow
  - else reject with `429 Too Many Requests`

### Lua Script Idea
- Use a Lua script so refill and consume happen atomically.
- This prevents race conditions between concurrent nodes.

## Sliding Window Log with Redis Sorted Set
- Key example: `rl:ip:10.1.2.3`
- Store timestamps in a sorted set.

Flow:
1. Remove entries older than current window.
2. Count remaining entries.
3. If count >= limit, reject.
4. Else insert current timestamp and allow.

Redis commands conceptually:
- `ZREMRANGEBYSCORE`
- `ZCARD`
- `ZADD`
- `EXPIRE`

## Example: 100 Requests per Minute

### Token Bucket
- capacity = 100
- refill rate = 100 tokens per 60 seconds
- burst up to 100 allowed if bucket was full

### Sliding Window Log
- keep all request timestamps in last 60 seconds
- reject when count reaches 100

## Multi-Dimensional Limits
- per IP
- per user
- per tenant
- per API key
- per route
- per region

Good systems often apply more than one:
- coarse global limit
- tenant limit
- sensitive endpoint limit

## Headers and Client Contract
- Return:
  - `429 Too Many Requests`
  - `Retry-After`
  - optionally `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset`

## Distributed Tradeoffs

### Strong Accuracy vs Cost
- Sliding log is more accurate but heavier.
- Token bucket is more efficient and operationally friendlier.

### Single Redis vs Cluster
- Single Redis is simpler but a bottleneck at scale.
- Redis Cluster scales better but increases topology complexity.

### Fail-Open vs Fail-Closed
- Fail-open:
  - allow traffic if rate limiter store is unavailable
  - protects customer experience, risks overload
- Fail-closed:
  - block traffic if limiter store is unavailable
  - protects backend, risks false rejections
- Critical payment or auth APIs may choose differently from general APIs.

## API Gateway Integration
- Can be applied in:
  - Kong
  - Apache APISIX
  - NGINX
  - AWS API Gateway
  - application layer
- Edge-level limiting reduces waste before requests hit business services.

## Hot Key Problem
- Very popular tenants can create Redis hot keys.
- Mitigations:
  - partition by smaller dimensions
  - use local pre-check plus global limiter
  - shard counters
  - separate extremely hot tenants

## Sample Java Service Pseudocode

```java
public boolean allowRequest(String key) {
    RateLimitResult result = redisScriptExecutor.executeTokenBucket(
        key,
        100,
        10.0
    );
    return result.allowed();
}
```

## Interview Questions

### Token bucket vs sliding window?
Short answer:
Token bucket is efficient and allows bursts; sliding window is more accurate but heavier.

Better answer:
If I need practical API protection at scale, I usually start with token bucket because it is simple, fast, and burst-friendly. If fairness precision matters a lot, I would consider sliding window, often with Redis sorted sets, while accepting the higher memory and operational cost.

### How do you scale a distributed rate limiter?
Short answer:
Use shared Redis state, atomic Lua scripts, and define limits by client identity.

Better answer:
I would push rate limiting to the edge, keep shared counters in Redis, perform atomic refill-and-consume logic through Lua, return proper rate-limit headers, and think carefully about hot keys, fail-open versus fail-closed behavior, and whether I need strict accuracy or a cheaper approximation.
