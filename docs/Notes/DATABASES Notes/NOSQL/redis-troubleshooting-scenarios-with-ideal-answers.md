# Redis Troubleshooting Scenarios with Ideal Answers

## 1. Cache Hit Ratio Suddenly Drops

### Scenario
- Application latency increases and the database load spikes.

### Ideal Answer
- I would check whether keys are expiring too aggressively, whether deployment changed key naming, and whether invalidation logic is over-clearing the cache.
- I would also confirm that the application is reading the same keys it writes and that serialization format changes did not silently invalidate old cache data.

## 2. Redis Memory Is Full

### Scenario
- Redis starts rejecting writes or evicting data unexpectedly.

### Ideal Answer
- I would inspect `maxmemory`, eviction policy, TTL usage, and key distribution.
- Then I would identify whether the issue is a genuine growth pattern, missing expirations, a hot cache with too many distinct keys, or misuse of Redis for long-lived data that should not be in-memory.

## 3. Hot Key Causes Uneven Load

### Scenario
- One Redis key is hit far more than others and becomes a bottleneck.

### Ideal Answer
- I would confirm the access pattern, then consider local caching, request coalescing, replicas for reads if appropriate, or redesigning how that data is distributed.
- The right fix is not always "bigger Redis"; sometimes the access pattern itself is the architectural problem.

## 4. Stale Data After Update

### Scenario
- Users still see old values even after successful updates.

### Ideal Answer
- I would inspect cache invalidation order, TTL length, write path consistency, and whether multiple services update the same business object without shared cache discipline.
- I would confirm whether the system uses cache-aside, write-through, or another pattern, because the debugging path depends on that design.

## 5. Rate Limiter Behaves Inconsistently Across Nodes

### Scenario
- Some requests are blocked too early and others are not blocked at all.

### Ideal Answer
- I would check whether the implementation is truly atomic, especially if multiple operations are performed separately instead of inside one Lua script or transaction-like server-side unit.
- In distributed rate limiting, consistency depends on key design and atomic update logic, not only the algorithm name.

## 6. Redis Replication Lag

### Scenario
- Reads from replicas return older data than expected.

### Ideal Answer
- I would verify whether the application assumes read-after-write consistency from replicas. If that guarantee matters, I would route those reads to primary or redesign the flow.
- Replica lag is a design concern as much as an operational one.

## 7. Lock Stays Around Too Long

### Scenario
- A distributed lock prevents work long after the original worker died.

### Ideal Answer
- I would check whether the lock has a TTL and whether renewal or release logic is correct.
- If the business depends heavily on locking, I would revisit whether the workflow should instead use idempotency, queue ownership, or another safer coordination pattern.

## 8. CPU Spikes During Large Key Scans

### Scenario
- Redis becomes slow when diagnostics or cleanup jobs run.

### Ideal Answer
- I would check whether expensive commands like broad scans or large key operations are running in production.
- For inspection and maintenance I would use safer incremental approaches and avoid commands that block or heavily burden the instance in peak traffic.
