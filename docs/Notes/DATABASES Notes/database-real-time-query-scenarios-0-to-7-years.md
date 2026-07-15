# Database Real-Time Query and Scenario Questions: 0 to 7 Years

This file covers practical query-writing and debugging scenarios that are commonly asked in live database interviews.

---

## SQL Real-Time Query Questions

### 1. Find duplicate records by email

```sql
SELECT email, COUNT(*) AS duplicate_count
FROM users
GROUP BY email
HAVING COUNT(*) > 1;
```

### 2. Get the latest order for each customer

```sql
SELECT *
FROM (
    SELECT
        order_id,
        customer_id,
        created_at,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY created_at DESC
        ) AS rn
    FROM orders
) t
WHERE rn = 1;
```

### 3. Find employees earning more than department average

```sql
SELECT e.employee_id, e.department_id, e.salary
FROM employees e
JOIN (
    SELECT department_id, AVG(salary) AS avg_salary
    FROM employees
    GROUP BY department_id
) d
ON e.department_id = d.department_id
WHERE e.salary > d.avg_salary;
```

### 4. Find customers with no orders

```sql
SELECT c.customer_id
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.customer_id IS NULL;
```

### 5. Running total by customer

```sql
SELECT
    order_id,
    customer_id,
    amount,
    SUM(amount) OVER (
        PARTITION BY customer_id
        ORDER BY created_at
    ) AS running_total
FROM orders;
```

---

## MongoDB Real-Time Questions

### 6. Count successful orders by customer

```javascript
db.orders.aggregate([
  { $match: { status: "SUCCESS" } },
  {
    $group: {
      _id: "$customerId",
      totalOrders: { $sum: 1 },
      totalAmount: { $sum: "$amount" }
    }
  },
  { $sort: { totalAmount: -1 } }
])
```

### 7. Find documents where nested city is Hyderabad

```javascript
db.users.find({ "address.city": "Hyderabad" })
```

### 8. Explain embedding vs referencing with a real example

Good answer:
If order items are always read with the order, embedding can simplify reads. If the related data is large, shared, or updated independently, referencing is safer and more maintainable.

---

## Cassandra Real-Time Questions

### 9. Why is this query bad in Cassandra?

```sql
SELECT *
FROM orders_by_customer
WHERE status = 'FAILED'
ALLOW FILTERING;
```

Better answer:
This suggests the table was not designed for that query path. In Cassandra, I model tables around known access patterns, so if I need frequent lookup by status I usually create a dedicated table or design that supports it directly.

### 10. What is a hot partition?

Short answer:
A hot partition is a partition that receives too much traffic compared to others.

Better answer:
It happens when partition key design concentrates too much read or write load on one partition or node. This hurts latency and cluster balance, so partition-key choice is one of the most important Cassandra design decisions.

---

## Solr Real-Time Questions

### 11. Search by brand with faceting

```text
q=laptop&fq=brand:Dell&facet=true&facet.field=category
```

### 12. Why can search results be stale even when the source database is updated?

Better answer:
Because Solr is usually an index layered on top of the source system. If indexing is asynchronous, there can be lag between source-of-truth updates and searchable index visibility.

---

## Production Debugging Scenarios

### 13. Query became slow after data growth. What do you check?

Strong answer:
I check whether the old plan still makes sense with current data size. I review index usage, row estimates, statistics, join order, partition pruning behavior, and whether the access pattern changed.

### 14. CPU is high on the database server. What next?

Strong answer:
I correlate CPU with active queries, lock waits, execution plans, batch jobs, index maintenance, or replication work. I avoid assuming hardware shortage before confirming workload shape.

### 15. Application sees stale data after a write. What are likely causes?

Strong answer:
I check whether reads are routed to replicas, whether eventual consistency is involved, whether cache invalidation is delayed, and whether there is asynchronous indexing or message-driven propagation in the architecture.

### 16. Index was added but performance did not improve. Why?

Strong answer:
Possible reasons include low selectivity, wrong column order, function use on the column, optimizer choosing another path, stale statistics, or the query being bottlenecked elsewhere.

---

## What Interviewers Like in Live Query Rounds

- clear reasoning before writing query
- correct join choice
- awareness of duplicates and null handling
- ability to improve query, not just write the first version
- explanation of performance impact
- acknowledgment of production safety for update/delete operations
