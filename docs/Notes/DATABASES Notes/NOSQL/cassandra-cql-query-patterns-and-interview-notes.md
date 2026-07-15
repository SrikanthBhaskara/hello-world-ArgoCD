# Cassandra CQL Query Patterns and Interview Notes

This note focuses on Cassandra interview patterns, especially around data modeling and query-driven design.

---

## 1. Table Designed for Query Pattern

```sql
CREATE TABLE orders_by_customer (
    customer_id text,
    order_time timestamp,
    order_id uuid,
    amount decimal,
    status text,
    PRIMARY KEY (customer_id, order_time, order_id)
) WITH CLUSTERING ORDER BY (order_time DESC, order_id ASC);
```

### Why this matters

This design assumes queries are usually by `customer_id` and recent order history.

---

## 2. Read by Partition Key

```sql
SELECT *
FROM orders_by_customer
WHERE customer_id = 'CUST123'
LIMIT 20;
```

### Interview point

Efficient Cassandra reads depend on correct partition-key-driven access.

---

## 3. Range Read Within Partition

```sql
SELECT *
FROM orders_by_customer
WHERE customer_id = 'CUST123'
  AND order_time >= '2026-01-01'
  AND order_time < '2026-02-01';
```

---

## 4. Why `ALLOW FILTERING` Is Risky

```sql
SELECT *
FROM orders_by_customer
WHERE status = 'FAILED'
ALLOW FILTERING;
```

### Why interviewers care

`ALLOW FILTERING` often signals a poor query-model match and can cause inefficient scans.

---

## 5. Common Cassandra Interview Themes

- design for query patterns
- partition key choice
- clustering columns
- hot partitions
- tombstones
- compaction
- consistency levels
- replication factor
