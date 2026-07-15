# Spring Async, Scheduling, and Events Deep Notes

This note focuses on asynchronous execution, scheduled jobs, and Spring application events.

---

## 1. `@Async`

`@Async` is used to run a method asynchronously.

Common use cases:

- notifications
- email sending
- lightweight background work

### Strong point

`@Async` is useful for simple async behavior, but it is not a replacement for durable queues when reliability, retry, or cross-service decoupling is required.

---

## 2. Thread Pool Awareness

Asynchronous work still needs controlled executors.

Strong answers should mention:

- thread pool sizing
- queue behavior
- backpressure risk
- visibility into async failures

---

## 3. `@Scheduled`

`@Scheduled` is used for periodic tasks.

Common uses:

- cleanup
- sync jobs
- report generation
- cache refresh

Example:

```java
@Scheduled(fixedDelay = 60000)
public void refreshCache() {
}
```

### Production concerns

- overlapping runs
- long-running jobs
- retries
- distributed duplicate execution

---

## 4. Events in Spring

Spring supports application events for decoupled communication inside the application.

Useful pieces:

- `ApplicationEventPublisher`
- `@EventListener`

### Example idea

- order created
- publish event
- listener sends email or audit record

---

## 5. When Events Fit Well

Events are useful when:

- the secondary action is not part of the immediate response
- you want looser coupling
- internal workflow separation improves clarity

### Tradeoff

More decoupling can make debugging harder if event flow is not observable.

---

## 6. Async vs Queue-Based Design

### `@Async`

- simple
- local to application process
- weaker durability

### Queue-based design

- stronger reliability
- better retry patterns
- better cross-service decoupling
- more operational complexity

### Strong answer

If the work must survive process restarts or needs controlled retry semantics, I usually prefer a message-based design over only using in-memory async execution.

---

## 7. Senior Production Concerns

Strong answers should mention:

- failure visibility
- retry behavior
- duplicate execution risk
- idempotency
- resource impact

### Strong interview line

Async and scheduled work are easy to add, but the real challenge is making them observable, safe, and reliable under production failure conditions.
