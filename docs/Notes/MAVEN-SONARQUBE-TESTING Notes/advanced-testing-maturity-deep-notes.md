# Advanced Testing Maturity Deep Notes

## Why This Topic Matters
- Strong engineers do not stop at unit tests.
- Mature systems need contract safety, resilience testing, and performance realism.

## Contract Testing

### What It Solves
- verifies that service consumers and providers agree on request and response contracts

### Pact
- common tool for consumer-driven contract testing

Interview point:
- contract tests reduce integration surprises without needing full end-to-end environments for every change

## Chaos Testing
- intentionally inject failures to validate resilience
- examples:
  - kill instance
  - add latency
  - break dependency

## Resilience Testing
- verify retries, circuit breakers, fallbacks, and degradation behavior
- especially important in microservices

## Performance Tool Comparison

### Locust
- Python-based, code-driven, flexible

### k6
- developer-friendly load testing with JS-based scripts

### JMeter
- mature ecosystem, widely known, more configuration heavy

Interview-safe answer:
- tool choice matters less than realistic scenario design, thresholds, and correlation with observability data

## When To Use What
- Pact: contract boundaries
- chaos testing: failure-mode confidence
- resilience testing: policy correctness under partial outages
- load testing: latency and throughput under concurrency

## Interview Questions

### Why contract tests if integration tests already exist?
Short answer:
Contract tests give faster, more targeted producer-consumer compatibility feedback.

Better answer:
End-to-end tests are valuable but slower and noisier. Contract tests give a focused way to ensure producer and consumer expectations stay aligned, which helps catch breaking API changes early without depending on large shared environments.
