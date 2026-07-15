# Database Interview Questions with Short and Better Answers

## 1. What is the difference between SQL and NoSQL?

Short answer:
SQL databases are relational and usually use structured schemas, while NoSQL databases support non-relational models like documents, key-value, wide-column, or graph.

Better answer:
SQL systems are strong when relationships, transactions, and structured querying are central. NoSQL systems are useful when scale patterns, flexible schema, denormalized reads, or distributed write behavior matter more. The choice should come from access patterns and operational needs, not trends.

## 2. What is normalization?

Short answer:
Normalization organizes data to reduce redundancy and improve consistency.

Better answer:
Normalization helps avoid update anomalies by separating repeated information into related tables. In practice, strong systems balance normalization with performance needs, because some read-heavy cases may justify selective denormalization.

## 3. What is an index?

Short answer:
An index improves query speed by helping the database find rows faster.

Better answer:
Indexes reduce read cost for matching, sorting, and filtering patterns, but they add write overhead and storage cost. Good index design depends on real queries, selectivity, and execution plans rather than adding indexes blindly.

## 4. What is the difference between primary key and unique key?

Short answer:
A primary key uniquely identifies each row, while a unique key also enforces uniqueness but is not necessarily the main row identifier.

Better answer:
A table has one primary key used as its main identity. Unique constraints can enforce business uniqueness for fields like email or username. Good schema design treats identity and business uniqueness as separate concerns when needed.

## 5. What is a transaction?

Short answer:
A transaction is a unit of work that should complete fully or not at all.

Better answer:
Transactions protect consistency across multiple related operations. In production, the real skill is choosing the right transaction boundary and avoiding overly large transactions that increase lock time and contention.

## 6. What is ACID?

Short answer:
ACID stands for Atomicity, Consistency, Isolation, and Durability.

Better answer:
ACID describes guarantees expected from transactional systems. In interviews, it helps to connect ACID to real behavior such as rollback on failure, isolation tradeoffs under concurrency, and durability after commit even during crashes.

## 7. What is the difference between `INNER JOIN` and `LEFT JOIN`?

Short answer:
`INNER JOIN` returns matching rows from both sides, while `LEFT JOIN` keeps all rows from the left side and includes matches from the right when available.

Better answer:
Join choice reflects business intent. If unmatched left-side records must still appear, `LEFT JOIN` is appropriate. If only fully matched relationships matter, `INNER JOIN` fits better.

## 8. What is denormalization?

Short answer:
Denormalization means intentionally storing some repeated data to improve read performance or simplify queries.

Better answer:
Denormalization is a tradeoff. It can reduce expensive joins and improve read speed, but it increases update complexity and consistency risk. Strong answers explain when that tradeoff is acceptable.

## 9. When would you choose MongoDB?

Short answer:
MongoDB is useful when document-style data and schema flexibility are valuable.

Better answer:
I choose MongoDB when the data is naturally document-oriented, nested structures are common, and fast iteration on schema is helpful. I still evaluate indexing strategy, document growth, query shape, and whether transactions or joins are central requirements.

## 10. When would you choose Cassandra?

Short answer:
Cassandra is useful for very high write throughput, horizontal scale, and predictable partition-based access patterns.

Better answer:
Cassandra works best when data access is modeled around partition keys and denormalized query-driven tables. It is strong for distributed scale and availability, but poor query modeling can lead to hot partitions or inefficient access.

## 11. What is eventual consistency?

Short answer:
Eventual consistency means replicas may not be immediately identical, but they converge over time.

Better answer:
This model can improve availability and scale in distributed systems, but applications must tolerate short periods of stale reads or delayed visibility. Senior answers explain how business logic handles that.

## 12. What is sharding or partitioning?

Short answer:
Sharding or partitioning splits data across multiple nodes or logical sections.

Better answer:
Partitioning improves scale and manageability, but key selection is critical. A bad partition key creates hotspots, uneven storage, and poor performance under load.

## 13. What is replication?

Short answer:
Replication means keeping copies of data on multiple nodes for availability and resilience.

Better answer:
Replication improves failover and read scaling, but it adds synchronization, lag, and consistency considerations. Strong answers explain how the application handles replication delay or failover behavior.

## 14. What is Solr used for?

Short answer:
Solr is used for indexing and searching large amounts of text-rich data.

Better answer:
Solr is strong when full-text search, relevance, filtering, faceting, analyzers, and fast search response are important. It complements transactional databases rather than replacing them in most systems.

## 15. How do you investigate a slow database query?

Short answer:
I check the query plan, indexes, filter conditions, data volume, and whether the access pattern matches the schema design.

Better answer:
I start with evidence: execution plan, actual runtime, row estimates, index usage, locks, and resource behavior. Then I decide whether the issue is query shape, missing indexes, stale statistics, poor partitioning, or application-level overfetching.
