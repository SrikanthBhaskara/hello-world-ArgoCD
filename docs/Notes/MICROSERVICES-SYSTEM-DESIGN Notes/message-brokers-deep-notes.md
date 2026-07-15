# Message Brokers Deep Notes

These notes cover how message brokers support asynchronous decoupling in backend systems, especially with Kafka, RabbitMQ, and AWS SQS. The goal is to understand not just tool definitions, but delivery semantics, failure modes, ordering, retries, and where each broker fits best.

## 1. Why Message Brokers Exist

Message brokers help systems:
- decouple producers and consumers
- absorb traffic spikes
- support asynchronous workflows
- improve resilience and scalability

Instead of one service waiting synchronously for another, a producer can publish work and let consumers process it separately.

Important point:
- message brokers improve decoupling, but they also increase operational and debugging complexity

## 2. When Asynchronous Messaging Helps

Good use cases:
- notification sending
- audit event pipelines
- order processing stages
- buffering spikes
- fan-out processing

Weak use cases:
- when caller needs immediate consistent response
- when async is used only to hide slow systems

## 3. Core Messaging Concepts

Important concepts:
- producer
- broker
- topic or queue
- consumer
- offset or acknowledgement
- retry
- dead-letter handling

## 4. Kafka at a High Level

Kafka is a distributed event streaming platform.

Strong for:
- high throughput
- event streams
- partitioned scaling
- replayable consumption

Key ideas:
- topics
- partitions
- offsets
- consumer groups

Interview answer:
- I think of Kafka as a durable, scalable event stream platform where ordering is usually per partition, not globally, and where consumer-group behavior is central to scaling and replay.

## 5. Kafka Ordering

Kafka ordering is guaranteed within a partition, not across the whole topic.

Why important:
- if order matters, related events must be keyed carefully

Example:
- order events for the same order ID should often use the same key

## 6. Kafka Consumer Groups

Consumer group behavior:
- each partition is consumed by at most one consumer in the same group at a time
- multiple consumers in a group increase parallelism

Implication:
- max parallelism is limited by partition count

## 7. Kafka Retries and Idempotency

Retries are normal in messaging.

Risks:
- duplicate processing
- out-of-order handling after failures

Need:
- idempotent consumers
- careful retry policy
- dead-letter or quarantine handling where appropriate

## 8. RabbitMQ at a High Level

RabbitMQ is a message broker focused on queue-based delivery patterns.

Strong for:
- task queues
- routing flexibility
- work distribution
- acknowledgement-driven consumption

Common concepts:
- exchanges
- queues
- bindings
- acknowledgements

Interview answer:
- I usually think of RabbitMQ as a strong queue-oriented broker when task distribution, routing flexibility, and acknowledgement-based processing are more important than replayable event streaming semantics.

## 9. RabbitMQ Routing

RabbitMQ can route through exchanges:
- direct
- topic
- fanout
- headers

This gives more explicit message-routing control than simple queue-only mental models.

## 10. AWS SQS at a High Level

SQS is a managed queue service.

Strong for:
- simple decoupled cloud workflows
- managed operational model
- easy integration with AWS systems

Two common types:
- Standard queue
- FIFO queue

Standard queue:
- high scale
- at-least-once delivery
- best-effort ordering

FIFO queue:
- ordered delivery
- deduplication support
- lower throughput characteristics compared with standard-style scaling expectations

## 11. Delivery Semantics

Common delivery semantics:
- at-most-once
- at-least-once
- effectively-once through careful design

Real-world takeaway:
- most systems should assume duplicates can happen
- idempotency is often mandatory

Strong answer:
- I design consumers assuming retries and duplicates are normal. Instead of promising impossible perfect delivery, I focus on idempotent processing, clear retry policy, and safe failure recovery.

## 12. Acknowledgement and Visibility

In queue systems:
- consumer may acknowledge after successful processing
- failure or timeout may cause redelivery

In SQS:
- visibility timeout matters

If visibility timeout is too short:
- duplicate processing can happen before work finishes

If too long:
- failed work may remain invisible too long

## 13. Dead-Letter Queues

DLQ is used for messages that fail repeatedly.

Why important:
- isolates poison messages
- prevents infinite retry loops
- supports later diagnosis

Common mistake:
- having a DLQ but no process to inspect or drain it

## 14. Message Ordering

Ordering is tricky and tool-specific.

Kafka:
- per partition ordering

RabbitMQ:
- queue ordering exists in simpler cases, but concurrency and requeue behavior can affect outcomes

SQS:
- standard queue does not guarantee strict ordering
- FIFO exists for stronger ordering needs

## 15. Backpressure and Throughput

Brokers can absorb spikes, but consumers still need protection.

Need to think about:
- consumer concurrency
- retry storms
- queue lag
- downstream capacity

Without backpressure awareness:
- systems look decoupled but still fail under backlog growth

## 16. Event vs Command Thinking

Important distinction:
- command asks something to be done
- event reports something that happened

Examples:
- command: `ProcessPayment`
- event: `PaymentProcessed`

Mixing these carelessly creates confusing system semantics.

## 17. Example Broker Fit

Choose Kafka when:
- replayable event streams matter
- throughput is high
- stream-style architecture fits

Choose RabbitMQ when:
- queue/task routing flexibility matters
- acknowledgement-based worker processing fits

Choose SQS when:
- you want a managed AWS queue
- simple decoupling is more valuable than operating your own broker platform

## 18. Common Failure Modes

Common issues:
- duplicate delivery
- consumer lag
- poison messages
- replay mistakes
- ordering assumptions
- visibility timeout mismatch
- unbounded retries

Debugging questions:
- is the message still in queue or topic
- did consumer fail before acknowledge or commit
- are retries causing duplicates
- is backlog growing faster than consumption
- is ordering requirement stronger than the chosen broker guarantees

## 19. Observability for Messaging

Watch:
- queue depth or lag
- consumer error rate
- retry count
- DLQ growth
- processing latency
- broker health

Messaging bugs are often hard to diagnose because the producer and consumer are decoupled in time and location.

## 20. What Different Experience Levels Should Know

### 0 to 2 years

Should know:
- why brokers are used
- producer vs consumer
- queue vs topic basics
- asynchronous processing idea

### 2 to 4 years

Should know:
- Kafka partitions and consumer groups
- RabbitMQ queue and exchange basics
- SQS standard vs FIFO
- retries and DLQ basics
- why idempotency matters

### 4 to 7 years

Should know:
- ordering tradeoffs
- consumer scaling patterns
- lag and backlog handling
- delivery semantics realism
- choosing the right broker by workload
- how to design retry, DLQ, and duplicate-safe consumers

If you can explain these with examples and tradeoffs, your messaging discussion will sound much more senior than simply naming broker products.
