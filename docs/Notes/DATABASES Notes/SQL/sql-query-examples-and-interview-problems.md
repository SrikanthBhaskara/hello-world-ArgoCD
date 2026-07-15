# SQL Query Examples and Interview Problems

This note focuses on query-writing patterns that commonly appear in interviews.

---

## 1. Find the Second Highest Salary

```sql
SELECT MAX(salary) AS second_highest_salary
FROM employees
WHERE salary < (SELECT MAX(salary) FROM employees);
```

### What interviewers check

- subquery understanding
- aggregate usage
- edge case awareness

---

## 2. Top N Salaries Per Department

```sql
SELECT employee_id, department_id, salary
FROM (
    SELECT
        employee_id,
        department_id,
        salary,
        DENSE_RANK() OVER (
            PARTITION BY department_id
            ORDER BY salary DESC
        ) AS rnk
    FROM employees
) t
WHERE rnk <= 3;
```

### Key concept

Window functions are usually cleaner than self-joins for ranking problems.

---

## 3. Find Duplicate Emails

```sql
SELECT email, COUNT(*) AS duplicate_count
FROM users
GROUP BY email
HAVING COUNT(*) > 1;
```

---

## 4. Running Total

```sql
SELECT
    order_id,
    customer_id,
    amount,
    SUM(amount) OVER (
        PARTITION BY customer_id
        ORDER BY order_id
    ) AS running_total
FROM orders;
```

---

## 5. Delete Duplicate Rows but Keep One

```sql
DELETE FROM users
WHERE id NOT IN (
    SELECT MIN(id)
    FROM users
    GROUP BY email
);
```

### Caution

In production, large deletes should be reviewed carefully for lock impact, batching, and rollback safety.

---

## 6. Find Records Present in One Table but Not Another

```sql
SELECT o.order_id
FROM orders o
LEFT JOIN shipments s
    ON o.order_id = s.order_id
WHERE s.order_id IS NULL;
```

---

## 7. Query Performance Review Checklist

When a SQL query is slow, check:

- execution plan
- full scan vs index scan
- join order
- missing indexes
- sort or temp work
- large `IN` filters
- functions on indexed columns
- row count and cardinality

---

## 8. Common SQL Interview Problem Types

- joins
- duplicates
- second highest value
- top N per group
- gaps and islands
- running totals
- ranking
- delete/update with conditions
- group by with filters
- pagination
