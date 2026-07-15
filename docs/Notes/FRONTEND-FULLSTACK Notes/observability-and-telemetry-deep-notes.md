# Observability and Telemetry Deep Notes

## Why Observability Matters
- Monitoring tells you whether something is wrong.
- Observability helps you understand why it is wrong.
- Mature teams do not stop at dashboards. They use metrics, logs, and traces together.

## The Three Pillars
- metrics
- logs
- traces

## Metrics
- numeric measurements over time
- examples:
  - CPU
  - memory
  - request rate
  - error rate
  - p95 latency
  - queue depth

## Logs
- event records from applications and systems
- good logs are structured, searchable, and correlated

### Structured Logging
- prefer key-value or JSON style logs
- include:
  - timestamp
  - service name
  - environment
  - trace id
  - request id
  - tenant id where appropriate

Example:

```json
{
  "level": "ERROR",
  "service": "orders-api",
  "traceId": "abc-123",
  "tenantId": "tenant-a",
  "message": "payment provider timeout"
}
```

## Traces
- traces show the path of a request across services
- useful in microservices, async systems, and distributed APIs

## Distributed Tracing
- helps answer:
  - which service is slow?
  - where did the failure start?
  - how much time was spent in DB vs external API?

## Prometheus

### What It Does
- scrapes metrics from targets
- stores time-series data
- supports alerting through rules and integrations

### Good Fit
- infrastructure and application metrics
- Kubernetes monitoring
- SLI and SLO tracking

## Grafana

### What It Does
- visualizes metrics and dashboards
- can connect to Prometheus and other data sources
- useful for operational dashboards and alert exploration

## Datadog

### What It Does
- commercial observability platform
- supports metrics, logs, traces, dashboards, alerts
- often chosen when teams want a more integrated managed platform

## OpenTelemetry

### What It Is
- open standard for telemetry collection
- supports instrumentation for traces, metrics, and logs
- helps reduce vendor lock-in at instrumentation layer

### Why It Matters
- instrument once
- export to multiple backends
- unify telemetry approach across services

## Observability Design Principles
- instrument business-critical flows first
- define service-level indicators clearly
- correlate logs, metrics, and traces using IDs
- alert on symptoms users feel, not only raw infrastructure values

## Good Alerts
- high error rate
- high p95 latency
- queue lag threshold breach
- dependency timeout spike

## Bad Alerts
- too noisy
- no owner
- infrastructure-only alerts without user impact context

## Example Production Flow
1. Grafana shows p95 latency spike
2. Prometheus shows downstream dependency error rise
3. traces show delay concentrated in payment call
4. structured logs confirm timeout exceptions with same trace ids
5. team isolates the dependency bottleneck quickly

## What 5 to 7 Year Engineers Should Say
- "I care about golden signals: latency, traffic, errors, saturation."
- "I want correlation ids across logs and traces."
- "I design alerts around customer-impacting symptoms and critical dependencies."
- "I use observability during rollout, incident response, and capacity planning."

## Interview Questions

### What is the difference between monitoring and observability?
Short answer:
Monitoring shows known signals; observability helps explain unknown failures.

Better answer:
Monitoring is about tracking expected health indicators and thresholds. Observability goes further by giving enough telemetry to investigate new or unexpected failure modes, especially in distributed systems where the cause is not obvious from one metric alone.

### Why is OpenTelemetry important?
Short answer:
It standardizes instrumentation across services and tools.

Better answer:
OpenTelemetry gives a vendor-neutral way to instrument applications for traces, metrics, and logs. That matters because it keeps telemetry collection consistent across services and makes it easier to export data to different observability backends without rewriting application instrumentation each time.
