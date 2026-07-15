# Database Performance, Scale, and Reliability Deep Notes

## Why This Topic Matters
- Senior interviewers want to know whether you can keep data systems healthy in production.
- That includes query performance, replication, partitioning, connection management, and safe schema change strategy.

## Execution Plans
- explain how the database will access data
- reveal scans, index use, join order, sort cost

Interview point:
- do not optimize queries blindly without checking the execution plan first

## Slow Query Analysis
- identify high-latency queries
- compare logical design with actual access patterns
- check missing indexes, large scans, bad joins, and skewed data

## Partitioning
- split large tables into manageable pieces
- useful for time-based or tenant-based data separation

## Replication
- primary and replica model
- useful for read scaling and recovery
- introduces consistency lag considerations

## Sharding
- split data across multiple independent databases
- stronger scale move than partitioning
- much higher operational complexity

## Connection Pooling
- prevents excessive connection overhead
- must be tuned to DB capacity, not only app desire

## Migration Rollback Strategy
- destructive schema rollback is often unsafe
- prefer forward-fix mindset with additive migrations and staged cleanup

## Interview Questions

### Partitioning vs sharding?
Short answer:
Partitioning splits data inside one logical database; sharding splits across multiple independent data stores.

Better answer:
Partitioning is usually my earlier scale step because operational overhead is lower. Sharding is a bigger architectural decision used when one database instance or cluster cannot meet scale, isolation, or growth requirements anymore.

### Why is connection pooling important?
Short answer:
Because DB connections are expensive and limited.

Better answer:
Without proper pooling, applications can overwhelm the database with connection churn or excessive concurrency. A good pool protects both performance and stability, and I tune it based on actual DB capacity rather than guesswork.
