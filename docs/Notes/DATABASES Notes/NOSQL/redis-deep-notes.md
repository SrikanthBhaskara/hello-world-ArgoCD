# Redis Deep Notes

## Why Redis Matters
- Redis is not just a cache.
- In interviews it often appears in caching, session storage, rate limiting, locks, queues, and leaderboards.

## Common Redis Uses
- cache
- session store
- pub or sub
- distributed lock support
- rate limiting counters
- short-lived state

## Data Structures To Know
- strings
- hashes
- lists
- sets
- sorted sets
- streams

## Caching Patterns

### Cache Aside
- app checks Redis first
- on miss, read DB and populate cache

### Write Through
- write to cache and backing store together

### Write Behind
- write to cache first and persist later
- faster writes but more operational risk

## Cache Risks
- stale data
- thundering herd on misses
- key explosion
- inconsistent invalidation

## Eviction Policies
- `noeviction`
- `allkeys-lru`
- `volatile-lru`
- `allkeys-lfu`

Interview point:
- eviction policy must match workload. Blindly accepting the default is weak engineering.

## Sessions in Redis
- useful for centralized session access across many app instances
- common in web apps and gateway layers

## Rate Limiting
- token bucket or sliding window counters
- often implemented with Lua scripts for atomicity

## Distributed Locks
- use carefully
- require timeout and failure thinking
- lock misuse can create false safety

Interview-safe answer:
- I use distributed locks only when I truly need cross-node coordination and the business operation cannot tolerate concurrent execution.

## Pub or Sub
- lightweight event distribution
- useful for notifications or cache invalidation
- not the same as durable message broker guarantees

## Persistence
- RDB snapshots
- AOF append-only file
- choose based on durability vs performance needs

## Redis Questions

### Why use Redis instead of only DB cache tables?
Short answer:
Because Redis is optimized for fast in-memory access and short-lived shared state.

Better answer:
Redis is useful when low-latency access, high read throughput, and shared cross-instance state matter. I still use it carefully because cache invalidation, key design, and memory pressure are architectural concerns, not afterthoughts.
