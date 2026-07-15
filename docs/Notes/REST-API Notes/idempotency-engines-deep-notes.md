# Idempotency Engines Deep Notes

## Why Idempotency Matters
- Networks are unreliable.
- Clients retry on timeouts.
- Load balancers can retry upstream calls.
- Message consumers may redeliver events.
- Without idempotency, a retry can create duplicate payments, duplicate orders, or duplicate subscriptions.

## Core Idea
- The same logical request should produce the same business outcome even if received multiple times.
- For payments, "same business outcome" usually means "charge at most once".

## Idempotency Is Not Just HTTP Method Semantics
- `GET`, `PUT`, and `DELETE` are defined as idempotent by HTTP semantics.
- Real interview questions usually focus on business idempotency for `POST` operations like:
  - create payment
  - place order
  - issue refund
  - create payout

## Common Design

### Client Sends Idempotency Key
- Client generates a unique key like `payment-<orderId>-<attemptId>`.
- Server stores request fingerprint and result keyed by:
  - `idempotencyKey`
  - `tenantId`
  - API route

### Server Processing Steps
1. Receive request with idempotency key.
2. Check idempotency store.
3. If key exists and request fingerprint matches, return stored response.
4. If key exists but payload differs, reject with conflict.
5. If key does not exist, lock or reserve the key, execute business logic, then store final result.

## Request Fingerprinting
- Store a hash of important business fields.
- This prevents a client from reusing the same key with a different payload.

Example fingerprint inputs:
- customer id
- order id
- amount
- currency
- payment method token

## Data Model Example

```text
idempotency_key
tenant_id
request_hash
status           // IN_PROGRESS, SUCCEEDED, FAILED
response_code
response_body
resource_id      // paymentId or orderId
created_at
expires_at
```

## Database Flow Example

```sql
create table api_idempotency (
    tenant_id varchar(100) not null,
    idempotency_key varchar(200) not null,
    request_hash varchar(128) not null,
    status varchar(30) not null,
    resource_id varchar(100),
    response_code int,
    response_body text,
    created_at timestamp not null,
    expires_at timestamp not null,
    primary key (tenant_id, idempotency_key)
);
```

## Java or Spring Style Flow

```java
public PaymentResponse createPayment(String tenantId, String idempotencyKey, PaymentRequest request) {
    String requestHash = hash(request);

    Optional<IdempotencyRecord> existing = repository.find(tenantId, idempotencyKey);
    if (existing.isPresent()) {
        IdempotencyRecord record = existing.get();
        if (!record.getRequestHash().equals(requestHash)) {
            throw new ConflictException("Same idempotency key used with different payload");
        }
        if (record.isSucceeded()) {
            return deserialize(record.getResponseBody());
        }
        if (record.isInProgress()) {
            throw new TooEarlyException("Request already in progress");
        }
    }

    repository.insertInProgress(tenantId, idempotencyKey, requestHash);

    try {
        Payment payment = paymentService.charge(request);
        PaymentResponse response = PaymentResponse.from(payment);
        repository.markSucceeded(tenantId, idempotencyKey, payment.getId(), 201, serialize(response));
        return response;
    } catch (Exception ex) {
        repository.markFailed(tenantId, idempotencyKey, 500, errorPayload(ex));
        throw ex;
    }
}
```

## Handling Concurrency
- Two identical requests may arrive at the same time.
- Use one of these:
  - DB unique constraint plus insert-first approach
  - Redis `SETNX` lock with TTL
  - row-level lock for existing key
- Never use "check then insert" without atomic protection.

## Payment API Example

### Old risky behavior
- Request times out after payment provider receives it.
- Client retries.
- Server sends second charge request.
- Customer is charged twice.

### Better idempotent behavior
- Server stores `idempotencyKey=payment-order-123`.
- First request creates payment and stores `paymentId=p-456`.
- Retry with same key returns the original success response referencing `p-456`.

## In-Progress State
- If a request is still running, the duplicate request should not execute again.
- Options:
  - return `409 Conflict`
  - return `202 Accepted`
  - return a retriable "processing" response
- The choice depends on API contract and client behavior.

## Expiration Strategy
- Idempotency records usually do not stay forever.
- Keep them long enough for realistic retries and settlement checks.
- Payments often use longer retention than ordinary creates.
- Consider audit and compliance requirements before cleanup.

## Idempotency Across Async Systems
- If a synchronous API publishes events, downstream consumers must also be idempotent.
- API idempotency alone is not enough.
- Use:
  - event id
  - dedupe table
  - upsert semantics
  - consumer-side processed-message store

## Exactly Once: Interview-Friendly Reality
- True exactly-once across external systems is very hard.
- Practical systems aim for:
  - at-most-once charge initiation from API layer
  - at-least-once delivery in messaging
  - idempotent consumers
  - deduplicated business effect
- The right phrase is often "effectively once at business level".

## Failure Cases to Discuss

### Request succeeds but response is lost
- Client retries with same key.
- Server returns original result from idempotency store.

### Same key reused with different amount
- Reject because the request fingerprint changed.

### Server crashes after external charge but before response storage
- Reconciliation job should look up provider transaction by business reference.
- Finalize local idempotency record during recovery.

## Best Practices
- Make idempotency mandatory for risky write APIs.
- Scope keys by tenant and route.
- Validate request fingerprint.
- Persist response or resource reference.
- Use atomic insert or lock behavior.
- Add cleanup policy and reconciliation jobs.
- Log idempotency key in every request trace.

## Interview Questions

### How do you make a payment API safe against retries?
Short answer:
Use an idempotency key, store request hash and final result, and return the stored result for retries.

Better answer:
I would make the client send an idempotency key, enforce a unique constraint per tenant and API, store a request fingerprint, reserve the key before calling the payment provider, and persist the final outcome so that any retry returns the original payment result instead of initiating a second charge.

### Is idempotency enough for exactly-once?
Short answer:
Not globally, but it gives effectively-once behavior at business level.

Better answer:
Across distributed systems, exactly-once is usually a marketing phrase unless you define the boundary carefully. My goal is effectively-once business execution by combining API idempotency, safe persistence, reconciliation, and idempotent downstream consumers.
