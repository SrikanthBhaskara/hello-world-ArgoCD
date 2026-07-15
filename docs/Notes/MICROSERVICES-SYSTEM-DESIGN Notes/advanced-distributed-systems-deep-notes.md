# Advanced Distributed Systems Deep Notes

## Why This Topic Matters
- At 5 to 7 years, interviewers often want architecture thinking beyond CRUD microservices.
- They expect familiarity with event-driven consistency, change propagation, and system evolution patterns.

## CQRS

### What It Is
- Command Query Responsibility Segregation separates write model from read model

### Why Use It
- optimize reads and writes differently
- scale query side independently
- support complex reporting

### Risks
- more moving parts
- eventual consistency
- operational complexity

## Event Sourcing

### What It Is
- persist state changes as a sequence of events rather than only current row state

### Strengths
- strong audit history
- replayability
- temporal debugging

### Risks
- migration complexity
- event schema evolution
- replay cost

## CDC

### What It Is
- Change Data Capture publishes database changes to other systems

### Common Tool
- Debezium

### Use Cases
- syncing search index
- analytics pipelines
- event propagation from legacy DB-centric systems

## Outbox and Inbox

### Outbox
- write domain data and event record together locally
- publish from outbox later

### Inbox
- store processed message identity on consumer side to prevent duplicate effects

## Saga Orchestration Tools
- Temporal
- Camunda
- Orkes or Conductor style workflow engines

Interview point:
- workflow engines help with state, retries, and visibility, but they should not become an excuse to skip domain design.

## When To Use Advanced Patterns
- not on day one for every project
- use when consistency boundaries, auditability, scale, or integration complexity genuinely require them

## Interview Questions

### CQRS vs simple CRUD?
Short answer:
CQRS separates read and write models when their needs differ significantly.

Better answer:
I use CRUD by default for simpler systems. I move to CQRS when read patterns, scaling needs, or reporting needs diverge enough that one model becomes awkward or inefficient for both reads and writes.

### Why use Debezium or CDC?
Short answer:
To publish data changes safely without hand-writing fragile sync logic.

Better answer:
CDC is useful when a system of record already exists and multiple downstream systems need consistent updates. Rather than sprinkling sync code across services, Debezium can capture DB changes and turn them into a reliable event stream.
