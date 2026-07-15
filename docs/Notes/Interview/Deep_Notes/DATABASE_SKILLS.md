# Database Skills

## Why Database Skills Matter
Even when a role is not database-heavy, interviewers want to know whether you understand how data is stored, queried, updated, and protected. Many performance and reliability issues come from weak database decisions.

## Core Database Areas to Understand
- Data modeling
- SQL fundamentals
- Query behavior
- Indexing
- Transactions
- Locking and concurrency
- Performance issues
- Data consistency

## Data Modeling

### What it means
Data modeling is the process of deciding how information should be represented in tables or collections and how different entities relate to each other.

### What good modeling considers
- What entities exist
- What relationships exist
- Which fields are required
- Which queries will be most common
- How the model will evolve over time

## SQL Fundamentals

### What interviewers expect
You should understand selects, joins, filtering, aggregation, grouping, ordering, updates, and deletes. You should also know how poor query shape can affect performance.

### Common joins
- Inner join
- Left join
- Right join
- Full join

You do not need to memorize formal definitions only. You should understand when each join changes the result set.

## Query Behavior

### Why query behavior matters
Two queries can return the same logical data but have very different performance cost. The way a query filters, joins, and sorts data determines how much work the database must do.

### What to think about
- How many rows are scanned
- Whether indexes can be used
- Whether joins are selective or expensive
- Whether sorting or grouping creates heavy work

## Indexing in Depth

### What an index does
An index helps the database find rows more efficiently, similar to how an index in a book helps you find a topic without reading every page.

### Benefits
- Faster lookup
- Faster filtering
- Faster join support in many cases

### Costs
- More storage
- Slower inserts, updates, and deletes
- More maintenance overhead

### Practical rule
Indexes should follow real query patterns. Adding indexes blindly is not good database design.

## Transactions

### What they are
Transactions group multiple operations so they succeed or fail as one unit.

### Why they matter
They protect consistency when partial updates would leave the system in a broken state.

### Practical example
If one operation deducts money and another operation records the transfer, both should succeed together or fail together.

## Locking and Concurrency

### What can go wrong
When many operations happen at the same time, they can block each other, overwrite each other, or read inconsistent state if not handled correctly.

### Common issues
- Lock contention
- Deadlocks
- Lost updates
- Long-running transactions blocking others

## Performance Issues in Real Systems

### Common causes
- Slow queries
- Missing indexes
- Large table scans
- N+1 query behavior
- Too much data fetched
- Poor pagination strategy
- Connection pool exhaustion

### N+1 query problem
This happens when one query loads a list of items and then additional queries are executed for each item. It often works functionally but performs badly at scale.

## Data Consistency

### What it means
Consistency means data remains correct and logically valid across operations and services.

### Common threats to consistency
- Partial updates
- Retry duplication
- Race conditions
- Weak transaction boundaries
- Bad synchronization between systems

## What Good Database Thinking Looks Like
Good database thinking starts with access patterns. Before choosing a schema or optimization, understand how the data will be read and written.

### Questions to ask
- What are the most frequent queries?
- Is the workload read-heavy or write-heavy?
- Do we need strong consistency?
- What relationships matter?
- How large can the data grow?
- What are the failure and concurrency risks?

## Important Concepts

### Normalization
Normalization reduces duplication and improves consistency. It is useful when correctness and clean relationships matter.

### Denormalization
Denormalization may improve read performance, but it increases duplication and makes updates harder to keep consistent.

### Indexing
Indexes improve read performance but increase write cost and storage usage. Indexes should follow query patterns.

### Transactions
Transactions protect correctness when multiple changes must succeed or fail together.

## How to Speak About Database Skills in Interviews

### Sample interview answer
I look at databases from a practical system perspective. I try to understand data shape, read and write patterns, query cost, concurrency risk, and how indexes or transactions affect behavior. I pay attention to consistency and performance because many real production problems come from database decisions that look fine at small scale but fail under real workload.

## SQL Examples and Solved Problems

### Example 1: Find the Second Highest Salary

Table:
- `employees(id, name, salary)`

```sql
SELECT MAX(salary) AS second_highest_salary
FROM employees
WHERE salary < (SELECT MAX(salary) FROM employees);
```

Why it matters:
This tests aggregation and subquery understanding.

### Example 2: Count Employees by Department

Table:
- `employees(id, name, department_id)`

```sql
SELECT department_id, COUNT(*) AS employee_count
FROM employees
GROUP BY department_id;
```

Why it matters:
This checks grouping and aggregation basics.

### Example 3: Employees and Department Names

Tables:
- `employees(id, name, department_id)`
- `departments(id, department_name)`

```sql
SELECT e.name, d.department_name
FROM employees e
JOIN departments d ON e.department_id = d.id;
```

Why it matters:
This is a basic join problem and appears often in interviews.

### Example 4: Departments With No Employees

```sql
SELECT d.department_name
FROM departments d
LEFT JOIN employees e ON d.id = e.department_id
WHERE e.id IS NULL;
```

Why it matters:
This checks left join reasoning and null filtering.

### Example 5: Top 3 Highest Paid Employees

```sql
SELECT name, salary
FROM employees
ORDER BY salary DESC
LIMIT 3;
```

Why it matters:
This tests sorting and limiting results.

### Example 6: Duplicate Emails

Table:
- `users(id, email)`

```sql
SELECT email, COUNT(*) AS duplicate_count
FROM users
GROUP BY email
HAVING COUNT(*) > 1;
```

Why it matters:
This is a classic grouping and filtering example.

### Example 7: Running Total by Date

Table:
- `daily_sales(sale_date, amount)`

```sql
SELECT sale_date,
	   amount,
	   SUM(amount) OVER (ORDER BY sale_date) AS running_total
FROM daily_sales;
```

Why it matters:
This introduces window functions, which are strong SQL interview signals.

### Example 8: Transactions Above Department Average

Table:
- `employees(id, name, department_id, salary)`

```sql
SELECT e.name, e.salary, e.department_id
FROM employees e
WHERE e.salary > (
	SELECT AVG(e2.salary)
	FROM employees e2
	WHERE e2.department_id = e.department_id
);
```

Why it matters:
This checks correlated subquery understanding.

### Example 9: Update Inactive Users

Table:
- `users(id, last_login, status)`

```sql
UPDATE users
SET status = 'inactive'
WHERE last_login < CURRENT_DATE - INTERVAL '90 days';
```

Why it matters:
This shows practical update logic and operational caution around bulk updates.

### Example 10: Delete Duplicate Rows but Keep One

Table:
- `users(id, email)`

```sql
DELETE FROM users
WHERE id NOT IN (
	SELECT MIN(id)
	FROM users
	GROUP BY email
);
```

Why it matters:
This shows deduplication logic, though in real systems you would validate carefully before deletion.

### How to Explain SQL Answers in Interviews
- State what the query is trying to return.
- Explain why a join, group by, subquery, or window function is needed.
- Mention correctness first, then performance.
- If relevant, mention indexing considerations.

## Common Interview Questions

### When would you denormalize data
When read performance matters significantly and the added duplication can be managed safely.

### How do you investigate a slow query
Check the query pattern, indexes, execution plan, row volume, join behavior, whether too much data is being fetched, and whether the access pattern itself should change.

### Why can too many indexes be a problem
They improve reads but make inserts, updates, and deletes more expensive.

### How do you think about transactions in service design
Use them where correctness requires atomic updates, but keep them as short as possible to avoid unnecessary locking and concurrency issues.

## Quick Revision Checklist
- Can I explain data modeling in practical terms?
- Can I explain normalization and denormalization clearly?
- Can I explain indexing without oversimplifying it?
- Can I discuss slow query investigation?
- Can I explain what causes lock contention?
- Can I connect database choices to application behavior?

## Interview Style Q&A

### Q1. How do you choose between normalization and denormalization?
I prefer normalization when consistency and clean relationships matter most. I consider denormalization when read performance is a major concern and the duplication can be managed safely.

### Q2. How do you investigate a slow database query?
I look at the query shape, execution plan, row scan volume, join behavior, filtering selectivity, and whether indexes support the access pattern. I also check whether the application is asking for more data than necessary.

### Q3. Why is indexing not always a complete solution?
Because indexes help reads, but they also increase write cost and storage use. If the access pattern or schema is poor, adding indexes alone may not solve the real issue.

### Q4. What is the N+1 query problem?
It happens when one query loads a list of items and then additional queries are triggered for each item. It often works correctly but performs badly as data size grows.

### Q5. Why do transactions matter?
Transactions matter when multiple changes must either succeed together or fail together. Without proper transaction boundaries, partial updates can leave the system in an inconsistent state.

### Q6. What is the difference between `WHERE` and `HAVING`?
`WHERE` filters rows before grouping. `HAVING` filters groups after aggregation. That is why aggregate conditions like `COUNT(*) > 1` belong in `HAVING`.

### Q7. When would you use a window function?
I use a window function when I need row-level output together with aggregate context, such as ranking, running totals, or comparing each row against a group average.