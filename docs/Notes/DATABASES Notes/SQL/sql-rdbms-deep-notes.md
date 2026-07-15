# SQL and RDBMS Deep Notes

This note covers relational database fundamentals that interviewers expect across MySQL, PostgreSQL, Oracle-like systems, and general SQL usage.

---

## 1. Why Relational Databases Matter

Relational databases are strong when:

- relationships matter
- transactions matter
- constraints matter
- reporting and querying flexibility matter

Typical strengths:

- ACID transactions
- strong schema control
- joins and aggregation
- mature indexing and query optimization

---

## 2. Core SQL Areas

You should be comfortable with:

- `SELECT`
- `INSERT`
- `UPDATE`
- `DELETE`
- joins
- grouping and aggregation
- subqueries
- common table expressions
- window functions

---

## 3. Join Types

Common joins:

- `INNER JOIN`
- `LEFT JOIN`
- `RIGHT JOIN`
- `FULL OUTER JOIN`
- self join

### Strong interview point

Knowing syntax is not enough. You should explain what rows survive the join and why that matches business intent.

---

## 4. Indexing Fundamentals

Indexes help:

- filtering
- sorting
- joining
- uniqueness

But they cost:

- extra storage
- slower writes
- more maintenance

### Practical rule

Design indexes around real query patterns, not theoretical column importance.

---

## 5. Normalization vs Denormalization

### Normalization

- reduces redundancy
- improves consistency
- avoids update anomalies

### Denormalization

- improves read performance
- reduces join cost
- increases duplication and update complexity

### Real-world answer

Good design often starts normalized and denormalizes selectively when query and scale evidence justify it.

---

## 6. Transactions and Isolation

Common isolation levels:

- read uncommitted
- read committed
- repeatable read
- serializable

### Why this matters

Higher isolation usually improves consistency but can reduce concurrency and increase contention.

### Strong answer

Isolation choice is a tradeoff between correctness guarantees and concurrency cost.

---

## 7. Locks and Deadlocks

### Locks

Used to protect data consistency during concurrent operations.

### Deadlock

Occurs when transactions wait on each other in a cycle.

### Senior answer

Deadlocks are not only database problems. They often reflect transaction ordering, query shape, and application design issues.

---

## 8. Query Optimization Thinking

When a query is slow, check:

- execution plan
- table scan vs index scan
- join order
- row estimates
- sorting and temporary work
- function use on indexed columns
- data skew

---

## 9. Window Functions

Useful for:

- ranking
- running totals
- partition-based analytics
- top-N per group

Example:

```sql
SELECT
    employee_id,
    department_id,
    salary,
    RANK() OVER (PARTITION BY department_id ORDER BY salary DESC) AS salary_rank
FROM employees;
```

---

## 10. Strong SQL Interview Topics

- joins
- indexes
- normalization
- denormalization
- transactions
- isolation
- deadlocks
- execution plans
- pagination strategies
- window functions
