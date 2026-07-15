# Database Real-Time Interview Questions: 0 to 7 Years

This file focuses on practical, real-world database interview questions that commonly come up from beginner to senior levels.

---

## 0 to 2 Years

### 1. What is the difference between `WHERE` and `HAVING`?

Short answer:
`WHERE` filters rows before grouping, and `HAVING` filters groups after aggregation.

Better answer:
I use `WHERE` when filtering raw row data and `HAVING` when filtering aggregated results like `COUNT(*)` or `SUM(amount)`. In interviews, I usually give an example because that makes the difference clearer.

### 2. What is the difference between `INNER JOIN` and `LEFT JOIN`?

Short answer:
`INNER JOIN` returns only matching rows, while `LEFT JOIN` keeps all rows from the left table and includes matches from the right when available.

Better answer:
The real choice depends on business intent. If unmatched left-side rows still matter, I use `LEFT JOIN`. If I only care about matched relationships, `INNER JOIN` is the better fit.

### 3. Why do we create indexes?

Short answer:
Indexes improve query performance for reads.

Better answer:
Indexes help the database find rows faster for filtering, sorting, and joining, but they also add write overhead and storage cost. So I create indexes for important query patterns, not on every column.

### 4. What is normalization?

Short answer:
Normalization reduces redundancy and improves consistency.

Better answer:
Normalization helps avoid duplicate data and update anomalies. In real systems, I still balance normalization with read performance, because some reporting or read-heavy cases may need selective denormalization.

### 5. What is the difference between SQL and NoSQL?

Short answer:
SQL databases are relational, and NoSQL databases support non-relational models like document or wide-column storage.

Better answer:
SQL is usually better when transactions, constraints, and relationships are central. NoSQL is useful when the access pattern, scale model, or schema flexibility makes a relational design less practical.

---

## 2 to 4 Years

### 6. How do you investigate a slow SQL query?

Short answer:
I check the execution plan, indexes, and query pattern first.

Better answer:
I start with evidence, not guesses. I check `EXPLAIN` or `EXPLAIN ANALYZE`, confirm whether indexes are used, review row counts, join order, and filter conditions, and then decide whether the issue is schema, query design, or data distribution.

### 7. What is a transaction and why does it matter?

Short answer:
A transaction ensures a set of operations succeeds fully or fails fully.

Better answer:
Transactions are critical when multiple writes belong to one business action, like debiting one account and crediting another. In production, I also think about transaction size because long transactions increase lock risk and latency.

### 8. What is a deadlock?

Short answer:
A deadlock happens when two or more transactions wait on each other in a cycle.

Better answer:
Deadlocks usually come from transaction ordering and concurrency patterns, not only from the database engine itself. I look at transaction scope, access order, and retry strategy when debugging them.

### 9. When would you choose MongoDB instead of PostgreSQL?

Short answer:
I would choose MongoDB when document-style data and schema flexibility fit the access pattern better.

Better answer:
If the application naturally reads and writes nested document data and does not depend heavily on relational joins or strict transactional patterns, MongoDB can be a better fit. But I still review indexing, document growth, and data-validation strategy carefully.

### 10. What is replication?

Short answer:
Replication keeps copies of data across multiple nodes.

Better answer:
Replication improves availability and sometimes read scale, but it also introduces lag, failover behavior, and consistency questions. So I explain both the benefit and the operational complexity.

### 11. What is partitioning or sharding?

Short answer:
Partitioning splits data across logical or physical segments, and sharding distributes it across nodes.

Better answer:
This improves scale, but the key decision is partition key choice. A bad partition key creates hotspots and uneven load, so I always connect sharding discussions back to access patterns.

---

## 4 to 7 Years

### 12. How do you choose between PostgreSQL, MongoDB, and Cassandra for a new system?

Short answer:
I choose based on access patterns, consistency needs, scale expectations, and operational tradeoffs.

Better answer:
If strong relational integrity and rich querying matter, PostgreSQL is usually the first choice. If the data is naturally document-oriented and the schema needs flexibility, MongoDB can fit better. If the system needs very high distributed write throughput with query-driven denormalized design, Cassandra may be appropriate. I explain the workload first and then justify the database choice from that.

### 13. How do you handle a schema change safely in production?

Short answer:
I treat schema change as a compatibility and rollout problem, not just a DDL change.

Better answer:
I check backward compatibility, application-version overlap, lock impact, migration duration, rollback options, and whether the change should be phased. In production, I avoid risky one-step changes when I can use expand-and-contract style rollout safely.

### 14. What are the tradeoffs of denormalization?

Short answer:
Denormalization improves reads but increases redundancy and update complexity.

Better answer:
I use denormalization when it clearly improves read performance or simplifies key access patterns, but I also account for duplicate data maintenance, consistency risk, and more complex update paths. I usually justify denormalization with actual access evidence.

### 15. How do you debug replication lag or inconsistent reads?

Short answer:
I first confirm whether the read came from a replica, then check lag, write rate, and failover or replication health.

Better answer:
I separate the issue into source write behavior, replication pipeline health, replica pressure, and application read-routing behavior. Then I decide whether the fix belongs in infrastructure tuning, query load reduction, or application consistency expectations.

### 16. What is a strong answer for indexing strategy?

Short answer:
Index design should follow real queries and measured plans.

Better answer:
I avoid saying "add an index" without context. I look at filter columns, sort patterns, join paths, cardinality, and write overhead. I prefer fewer useful indexes over many low-value ones that hurt writes and maintenance.

### 17. How would you explain Solr in a real architecture?

Short answer:
Solr is usually a search system that complements the primary database.

Better answer:
I explain Solr as a search index optimized for relevance, faceting, and text search, while the relational or document database remains the source of truth. I also mention indexing lag, reindex strategy, and source/index consistency because those are real operational concerns.

### 18. What interviewers expect at 5 to 7 years

Short answer:
They expect production thinking, tradeoffs, and debugging maturity.

Better answer:
At this level, they want more than definitions. They expect me to justify database choices, explain how I would diagnose query or replication issues, discuss consistency and scale tradeoffs, and describe how I would roll out data model changes safely in production.
