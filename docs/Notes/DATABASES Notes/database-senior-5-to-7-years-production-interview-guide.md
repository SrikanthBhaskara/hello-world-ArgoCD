# Database Senior 5 to 7 Years Production Interview Guide

This guide helps answer database questions with production thinking instead of only schema definitions.

---

## What Strong Database Answers Should Include

- access-pattern-driven design
- consistency and availability tradeoffs
- query and index behavior
- failure and recovery thinking
- safe schema or data changes

---

## 1. Model for Access Patterns

Strong answer:

I do not start by asking only what the data looks like. I ask how the application reads, writes, filters, aggregates, updates, and scales that data. Good schema design follows access patterns.

---

## 2. SQL vs NoSQL Choice

Strong answer:

I choose relational systems when transactions, constraints, and query flexibility are central. I choose NoSQL only when the workload clearly benefits from document flexibility, partition-oriented scale, or denormalized distributed design.

### Tradeoff

Flexible schema can speed development, but it can shift data-quality enforcement into application code.

---

## 3. Indexing Tradeoffs

Senior answer should include:

- reads become faster
- writes become heavier
- wrong indexes waste storage and hurt maintenance
- query plans matter more than index count

---

## 4. Slow Query Debugging

A strong answer includes:

1. confirm which query is slow
2. review execution plan
3. check index usage
4. check row count and data skew
5. verify lock contention or resource pressure
6. decide whether the fix belongs in query, index, schema, or application access pattern

---

## 5. Transactions and Production Risk

Strong answer:

Transactions protect consistency, but overly broad transactions can create lock contention, deadlocks, and latency spikes. I keep them aligned with business boundaries and as small as safely possible.

---

## 6. Safe Schema Changes

Before a production schema change:

- understand backward compatibility
- avoid breaking old application versions
- consider data migration duration
- consider lock impact
- use staged rollout where possible
- have rollback or mitigation plan

### Good answer line

"I do not treat schema changes as just DDL. I treat them as application-compatibility and production-risk changes."

---

## 7. Replication, Partitioning, and Failover

Strong answers mention:

- read/write path differences
- replica lag
- failover behavior
- partition-key risk
- operational impact during node failure

---

## 8. Search Systems Like Solr

Strong answer:

Search systems are often complementary, not primary sources of truth. I think about indexing lag, schema/analyzer correctness, reindex cost, and consistency between source data and search index.

---

## 9. What Interviewers Want at 5 to 7 Years

They expect:

- database choice justification
- indexing awareness
- production debugging ability
- consistency and performance tradeoff thinking
- safer migration and rollout answers
