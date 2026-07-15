# Cassandra Deep Notes

Cassandra is a distributed wide-column database designed for high availability, high write throughput, and horizontal scale.

---

## 1. When Cassandra Fits Well

Cassandra is strong when:

- write throughput is high
- horizontal scale is important
- multi-node availability matters
- access patterns can be modeled around partition keys

---

## 2. Query-Driven Data Modeling

In Cassandra, schema is typically designed from query patterns backward.

That means:

- model for reads you need
- denormalize intentionally
- avoid expecting flexible ad hoc relational querying

### Strong interview point

In Cassandra, poor data modeling causes pain much faster than in many relational systems.

---

## 3. Partition Key and Clustering Columns

### Partition key

- determines where data lives
- critical for scale and hotspot avoidance

### Clustering columns

- define ordering within a partition

### Production risk

A bad partition key can create hot partitions and uneven node pressure.

---

## 4. Replication and Consistency

Cassandra supports tunable consistency.

Common ideas:

- replication factor
- consistency levels
- eventual consistency behavior

### Tradeoff

Higher consistency improves correctness visibility, but can increase latency and reduce availability under failure conditions.

---

## 5. Write Path Strength

Cassandra is often chosen because writes are efficient and scalable.

But good answers also mention:

- compaction
- repair
- tombstones
- read amplification risks

---

## 6. Tombstones

Deletes in Cassandra create tombstones rather than immediate physical removal.

Why this matters:

- too many tombstones can hurt reads
- wide scans over tombstone-heavy data can become expensive

---

## 7. Operational Concerns

Senior answers should mention:

- repairs
- node replacement
- compaction impact
- hotspot detection
- consistency expectations

---

## 8. When Not to Choose Cassandra

Avoid Cassandra when:

- ad hoc relational querying is required
- joins are important
- query shape is not well known
- the team expects SQL-style flexibility without modeling tradeoffs
