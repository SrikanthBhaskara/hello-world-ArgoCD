# Caching Strategies Deep Notes

These notes cover practical caching strategies for backend and microservice systems, especially with Redis and Memcached. The main goal is to understand not only how caches improve performance, but also how they can introduce correctness problems if designed poorly.

## 1. Why Caching Exists

Caching is used to:
- reduce database load
- reduce latency
- smooth repeated read traffic
- avoid recomputing expensive results

Caching helps when:
- reads are much more frequent than writes
- some data can tolerate staleness
- the source system is expensive or slow

Important point:
- cache is a performance optimization, not the source of truth

## 2. Common Cache Locations

Caching can happen at:
- client side
- CDN
- API gateway
- application in-memory cache
- distributed cache
- database result cache

These notes focus on distributed application caching.

## 3. Redis vs Memcached

### Redis

Redis supports:
- strings
- hashes
- lists
- sets
- sorted sets
- TTL
- pub/sub
- persistence options

Good for:
- richer cache use cases
- counters
- rate limiting
- session-like or coordination patterns

### Memcached

Memcached is simpler:
- key-value cache
- memory-focused
- lightweight

Good for:
- straightforward distributed object caching

Simple comparison:
- choose Redis when you need richer data structures or operational features
- choose Memcached when simple, fast, distributed caching is enough

## 4. Cache Patterns

Common patterns:
- cache-aside
- read-through
- write-through
- write-behind

### Cache-Aside

Most common application pattern.

Flow:
1. application checks cache
2. on miss, reads database
3. stores result in cache
4. returns response

Why common:
- simple
- application stays in control

Risk:
- invalidation complexity

### Write-Through

Writes go through cache and source store together.

Benefit:
- cache stays warm

Tradeoff:
- write path is more coupled

### Write-Behind

Write goes to cache first, source update happens later.

Benefit:
- fast writes

Risk:
- higher consistency complexity

## 5. TTL and Expiration

TTL means time to live.

Why used:
- prevent stale data from lasting forever
- reduce invalidation complexity in some cases

Tradeoff:
- long TTL can return stale data longer
- short TTL reduces cache benefit

Strong answer:
- TTL should reflect business tolerance for staleness. It is not just a technical knob. I choose it based on how harmful old data is versus how valuable cache hit rate is.

## 6. Cache Invalidation

This is one of the most important caching topics.

Why hard:
- data changes in source of truth
- cache may still contain old value
- multiple services may read and write related data

Common invalidation approaches:
- TTL-based expiry
- delete key on update
- event-driven invalidation
- versioned cache keys

Interview answer:
- Cache invalidation is hard because the system must know when cached data is no longer trustworthy. I prefer explicit ownership and simple invalidation rules over clever cache behavior that becomes impossible to reason about.

## 7. Cache Key Design

Good key design matters.

Examples:
- `user:123`
- `product:567:inventory`
- `search:query:page:sort`

Need:
- stable naming
- collision avoidance
- tenant or environment separation where needed

Bad key design can cause:
- overwrites
- hard debugging
- stale data mix-ups

## 8. Staleness and Correctness

Not all data should be cached equally.

Good cache candidates:
- product catalog
- read-heavy metadata
- expensive but slowly changing reference data

Risky cache candidates:
- highly volatile financial balances
- security-sensitive authorization decisions unless designed very carefully
- data requiring strict real-time consistency

## 9. Cache Stampede and Hot Keys

### Cache Stampede

Many requests miss the same key at once and all hit the database.

Possible mitigations:
- request coalescing
- locking around regeneration
- staggered expiration
- background refresh

### Hot Keys

One key gets huge traffic concentration.

Possible mitigations:
- key sharding strategies
- local caching layers
- pre-warming
- rate control

## 10. Distributed Cache in Microservices

In microservices, caches add:
- performance benefit
- cross-instance consistency questions
- invalidation ownership complexity

Questions to answer:
- who owns the cached value
- who invalidates it
- what TTL is safe
- what happens on stale read

## 11. Redis Operational Considerations

Think about:
- memory limits
- eviction policy
- persistence choice if relevant
- high availability
- network latency

Common eviction examples:
- LRU-style behavior
- TTL-driven expiry

Operational point:
- a cache under memory pressure can behave very differently than expected if eviction strategy is poorly understood

## 12. Sessions, Counters, and Rate Limiting

Redis is often used for more than plain cache:
- distributed counters
- sliding-window rate limiting
- session-like token state
- lock coordination

This is useful, but remember:
- these patterns carry correctness risk if assumptions are weak

## 13. Example Cache-Aside Flow

```text
Request -> App -> Redis
           miss -> DB -> Redis set -> Response
           hit  -> Response
```

## 14. Example Redis Cache-Aside Pseudocode

```java
String key = "user:" + userId;
User cached = redis.get(key);

if (cached != null) {
    return cached;
}

User fromDb = repository.findById(userId);
redis.setex(key, 300, fromDb);
return fromDb;
```

## 15. Common Caching Mistakes

Bad patterns:
- caching everything blindly
- unclear invalidation ownership
- no TTL and no invalidation
- caching highly volatile data without a consistency plan
- ignoring serialization or payload size cost
- using cache as hidden shared state

## 16. What Different Experience Levels Should Know

### 0 to 2 years

Should know:
- why caching is used
- basic Redis vs Memcached difference
- what TTL means
- cache hit vs miss

### 2 to 4 years

Should know:
- cache-aside pattern
- invalidation basics
- hot key and stampede concepts
- when caching should or should not be used

### 4 to 7 years

Should know:
- cache ownership and correctness tradeoffs
- distributed cache design
- key design and invalidation strategy
- operational impact of memory and eviction
- how stale data risk changes architecture decisions

If you can explain these with practical tradeoffs, your caching discussion will sound much stronger than just saying "we used Redis for performance."
