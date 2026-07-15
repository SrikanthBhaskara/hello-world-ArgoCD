# Distributed Transactions and Saga Pattern Deep Notes

## Why Sagas Exist
- In a microservices system, each service usually owns its own database.
- A business flow like `create order -> reserve inventory -> charge payment -> create shipment` spans multiple services.
- A classical two-phase commit (2PC) tries to make all services commit or rollback together, but it creates tight coupling, coordinator dependency, latency, and lower availability.
- Modern microservices usually prefer eventual consistency with compensating actions instead of global distributed locks.

## Problem with Two-Phase Commit in Microservices
- Every participant must support the protocol.
- The coordinator becomes a critical component and possible bottleneck.
- Long-running transactions hold resources for too long.
- If one service is slow or unavailable, the whole business flow is affected.
- It reduces service autonomy and makes independent deployment harder.

## What a Saga Is
- A saga is a sequence of local transactions.
- Each service performs its own local commit.
- If a later step fails, earlier successful steps are compensated by separate undo-style business actions.
- A compensation is not always a database rollback. It is a business reversal such as `refund payment`, `release inventory`, or `cancel shipment`.

## Orchestration vs Choreography

### Orchestration
- A central saga orchestrator controls the flow.
- It tells each service what to do next.
- Easier to visualize, monitor, retry, and audit.
- Good when the workflow is complex or needs strict control.

Example flow:
1. Order service creates `PENDING` order.
2. Orchestrator calls inventory service to reserve stock.
3. Orchestrator calls payment service to authorize payment.
4. Orchestrator calls shipping service to create shipment.
5. Orchestrator marks order `CONFIRMED`.
6. If payment fails, orchestrator asks inventory service to release stock and marks order `FAILED`.

### Choreography
- No central coordinator.
- Services react to domain events published by other services.
- Lower coupling to a central workflow engine.
- Can become hard to trace when too many services participate.

Example flow:
1. Order service publishes `OrderCreated`.
2. Inventory service consumes it and publishes `InventoryReserved`.
3. Payment service consumes it and publishes `PaymentAuthorized`.
4. Shipping service consumes it and publishes `ShipmentCreated`.
5. Any failure event triggers compensation listeners.

## Local Transaction + Outbox Pattern
- One common problem is: "how do I update my database and publish an event reliably?"
- If a service writes to the DB but crashes before publishing, the system becomes inconsistent.
- The outbox pattern solves this by:
  - writing business data and event data in the same local transaction
  - storing the event in an `outbox` table
  - using a relay/poller/CDC process to publish the event later
- This is one of the most practical patterns for saga reliability.

## Compensation Design Principles
- Compensation must be explicit and business-safe.
- Compensation must be idempotent because retries can happen.
- Compensation should tolerate partial completion.
- Compensation should not assume original state still exists unchanged.

Bad compensation:
- "delete row blindly"

Better compensation:
- "if payment authorization exists and is not already refunded, create refund and mark authorization reversed"

## Data Model Thinking

### State Machine Approach
- Persist workflow state such as:
  - `PENDING`
  - `INVENTORY_RESERVED`
  - `PAYMENT_AUTHORIZED`
  - `COMPLETED`
  - `FAILED`
  - `COMPENSATING`
  - `COMPENSATED`
- This helps retries, observability, and incident recovery.

### Correlation IDs
- Use `orderId`, `paymentId`, and a `sagaId` across all logs, events, and metrics.
- Without correlation IDs, troubleshooting distributed failures is painful.

## Failure Scenarios Interviewers Ask About

### Payment Succeeds but Response Times Out
- Do not retry blindly as a new payment.
- First check payment status using a business idempotency key.
- If payment is already authorized, continue the saga instead of charging again.

### Inventory Reserved but Order Service Crashes
- Recovery process should reload pending saga states from persistent storage.
- The orchestrator or scheduler resumes unfinished work.

### Compensation Fails
- Mark workflow as `COMPENSATION_PENDING`.
- Retry with backoff.
- Alert operations if retries exceed threshold.
- Never silently lose failed compensation.

## Exactly-Once vs Effectively-Once
- In distributed systems, true global exactly-once execution is usually unrealistic.
- What we usually build is effectively-once business behavior:
  - unique business keys
  - idempotent handlers
  - deduplication tables
  - safe retries
- This is the practical answer interviewers often want.

## Example Order Saga

```text
Client -> Order Service -> Order DB
                    -> Outbox event: OrderCreated
Outbox Relay -> Kafka
Kafka -> Inventory Service -> reserve items
Kafka -> Payment Service -> authorize payment
Kafka -> Shipping Service -> create shipment
```

Compensation path:

```text
PaymentFailed -> Inventory Service releases stock
InventoryReleased -> Order Service marks FAILED
PaymentAuthorized but ShippingFailed -> Payment Service refunds or voids authorization
```

## Sample Orchestrator Pseudocode

```java
public void startSaga(CreateOrderCommand command) {
    Order order = orderRepository.save(Order.pending(command.orderId()));
    sagaRepository.save(SagaState.started(order.getId()));

    try {
        inventoryClient.reserve(order.getId(), command.items());
        paymentClient.authorize(order.getId(), command.paymentRequest());
        shippingClient.createShipment(order.getId(), command.address());
        order.markConfirmed();
        sagaRepository.markCompleted(order.getId());
    } catch (PaymentException ex) {
        inventoryClient.release(order.getId());
        order.markFailed("PAYMENT_FAILED");
        sagaRepository.markCompensated(order.getId());
    } catch (ShippingException ex) {
        paymentClient.refund(order.getId());
        inventoryClient.release(order.getId());
        order.markFailed("SHIPPING_FAILED");
        sagaRepository.markCompensated(order.getId());
    }
}
```

## Best Practices
- Keep each local transaction small.
- Prefer asynchronous communication for long-running workflows.
- Use outbox pattern for reliable event publishing.
- Make both forward steps and compensations idempotent.
- Track saga state persistently.
- Emit metrics for started, completed, failed, and compensated flows.
- Add DLQ or retry workflows for poison messages.

## Common Interview Questions

### Why not use 2PC in microservices?
Short answer:
2PC adds coordination cost, reduces availability, and tightly couples independent services.

Better answer:
In microservices we usually optimize for autonomy and availability, so instead of holding a distributed transaction across services, we split the workflow into local transactions and use saga compensation plus idempotent retries to reach eventual consistency.

### What is the hardest part of implementing sagas?
Short answer:
Designing safe compensations and handling retries correctly.

Better answer:
The hard part is not the happy path. It is partial failure handling. You need persistent workflow state, correlation IDs, idempotent compensation, duplicate protection, and strong observability, otherwise a temporary timeout can easily turn into double charges or orphaned reservations.

## What to Say in a 5 to 7 Year Interview
- "I would not start with 2PC unless there is an unusually strict requirement and all participants support it."
- "I prefer saga plus outbox plus idempotent consumers."
- "I treat payment, inventory, and shipment as separate consistency boundaries."
- "I always design compensation around business reversals, not technical rollback assumptions."
