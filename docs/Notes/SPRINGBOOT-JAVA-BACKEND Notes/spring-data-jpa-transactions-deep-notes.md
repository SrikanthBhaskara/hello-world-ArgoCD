# Spring Data JPA and Transactions Deep Notes

This note focuses on persistence patterns, transaction boundaries, and performance-aware backend design.

---

## 1. Spring Data JPA Basics

Spring Data JPA reduces repository boilerplate.

Example:

```java
public interface ProductRepository extends JpaRepository<Product, Long> {
    Optional<Product> findBySku(String sku);
}
```

### Benefits

- CRUD support
- paging and sorting
- query derivation
- integration with JPA/Hibernate

---

## 2. Transaction Boundaries

Use `@Transactional` around business actions, not around every random method.

Example:

```java
@Transactional
public void placeOrder(CreateOrderRequest request) {
    // persist order
    // update stock
}
```

### Why this matters

- protects data consistency
- keeps related changes atomic
- but large transactions increase lock and latency risk

---

## 3. Common JPA Problems

Interviewers often ask about:

- N+1 query issue
- lazy loading surprises
- overfetching
- missing indexes
- mapping entities directly to API responses

### Strong answer

When JPA is slow, I check actual SQL, query count, fetch strategy, row volume, and transaction scope before changing code blindly.

---

## 4. Pagination and Query Efficiency

Use pagination for list endpoints with large data volume.

Example:

```java
Page<Order> findByStatus(String status, Pageable pageable);
```

### Senior point

Without pagination, list endpoints can become memory-heavy, slow, and operationally unsafe under real data growth.

---

## 5. Safe Schema and Persistence Changes

Production-safe thinking should include:

- migration compatibility
- rollout sequencing
- data backfill strategy
- lock impact
- rollback path
