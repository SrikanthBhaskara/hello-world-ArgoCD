# Redis Interview Questions with Short and Better Answers

## 1. What is Redis?
Short answer:
Redis is an in-memory data store commonly used for caching, sessions, counters, and fast shared state.

Better answer:
Redis is a high-performance in-memory data store that supports multiple data structures such as strings, hashes, lists, sets, sorted sets, and streams. In real systems I use it for low-latency shared state like cache entries, session data, rate limiting counters, and lightweight coordination.

## 2. Why use Redis instead of only a database?
Short answer:
Because Redis is optimized for very fast in-memory access.

Better answer:
Redis gives low-latency reads and writes for data that is frequently accessed or short-lived. It does not replace the system of record by default, but it reduces database load and improves responsiveness for the right workload.

## 3. What is cache-aside?
Short answer:
Read from cache first, then DB on miss, then populate cache.

Better answer:
Cache-aside is the most common caching pattern. The application checks Redis first, and if the key is missing, reads from the database and writes the result back to Redis. It is simple and practical, but you need an invalidation strategy for updates.

## 4. What are common Redis data structures?
Short answer:
Strings, hashes, lists, sets, sorted sets, and streams.

Better answer:
I choose data structures based on use case. Strings work well for simple values and counters, hashes for grouped fields, lists for ordered sequences, sets for uniqueness, sorted sets for ranking or time-based windows, and streams for event-style records.

## 5. What are Redis eviction policies?
Short answer:
They define what Redis removes when memory is full.

Better answer:
Eviction policy decides how Redis behaves under memory pressure. Examples include LRU and LFU based policies, or `noeviction`. This choice matters because it changes whether the system degrades by dropping less valuable cache entries or by failing writes.

## 6. How do you use Redis for sessions?
Short answer:
Store session state in Redis so multiple app instances can share it.

Better answer:
Redis works well as a shared session store because it is fast and accessible from multiple application nodes. This is useful when scaling web apps horizontally, but session TTL, memory usage, and security controls still need attention.

## 7. How can Redis help with rate limiting?
Short answer:
Use counters or sorted sets with expirations.

Better answer:
Redis is commonly used for distributed rate limiting because it supports fast shared counters and atomic operations. Token bucket or sliding window implementations often use Lua scripts or sorted sets so that concurrent app instances see consistent limit state.

## 8. What is a Redis sorted set good for?
Short answer:
Ranking, leaderboards, and time-window queries.

Better answer:
Sorted sets store members with scores, which makes them useful for leaderboards, delayed work, rate-limiting windows, or time-based event tracking. They are often the right structure when ordering and range queries matter.

## 9. What is the difference between persistence modes in Redis?
Short answer:
RDB uses snapshots and AOF logs writes.

Better answer:
RDB creates periodic snapshots, which is lighter in some workloads but can lose more recent writes. AOF appends write operations for better durability. The right choice depends on recovery expectations, performance tradeoffs, and how critical Redis data really is.

## 10. What is the risk of using Redis as a cache?
Short answer:
Stale data and bad invalidation are common risks.

Better answer:
The biggest risk is not just cache misses. It is incorrect cache behavior: stale entries, inconsistent invalidation, key explosion, hot keys, and over-trusting cached values. A cache must be designed as part of the architecture, not added blindly.

## 11. What is a hot key problem?
Short answer:
One extremely popular key creates a bottleneck.

Better answer:
Hot keys happen when one item is accessed much more heavily than others, concentrating load on one shard or one memory location. Mitigations include replication, local caching, request coalescing, or redesigning the data access pattern.

## 12. When would you use Redis streams?
Short answer:
For lightweight event-style processing or append-only event records.

Better answer:
Redis streams are useful when you need ordered append-only records with consumer group style processing. They can fit operational event pipelines, but for durable large-scale messaging I still compare them against tools like Kafka or RabbitMQ based on delivery and replay requirements.

## 13. Should Redis be used as the primary database?
Short answer:
Only when the use case truly fits and durability expectations are clear.

Better answer:
Redis can be used as a primary data store for some specialized workloads, but that is a bigger architectural choice than simply using it as a cache. I would only do that when data model, durability, persistence mode, failover design, and operational risk all align with the business requirement.
