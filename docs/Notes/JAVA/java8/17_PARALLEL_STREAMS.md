# Parallel Streams

## What they are
Parallel streams process stream operations using multiple threads, typically through Java's common fork-join pool.

## Basic example
```java
long count = numbers.parallelStream()
    .filter(n -> n % 2 == 0)
    .count();
```

## Why they exist
They allow certain data-processing workloads to use multiple CPU cores without developers manually managing thread pools and partitioning logic.

## When they help
- Large datasets
- CPU-heavy independent operations
- Stateless transformations
- Associative reduction logic

## When they can hurt
- Small datasets
- High synchronization overhead
- Shared mutable state
- Order-sensitive logic
- Expensive splitting or combining costs

## Important caution
Parallel streams are not a free performance boost. Whether they help depends on workload characteristics and execution environment.

## Common risks
- Harder debugging
- Less predictable performance
- Hidden thread-pool interactions
- Incorrect results if code has unsafe shared state

## Ordering considerations
Some stream operations care about encounter order. Parallel execution may preserve order when required, but that can reduce performance benefits.

## Interview-style answer
Parallel streams in Java 8 allow stream pipelines to run across multiple threads, usually using the common fork-join pool. They can improve performance for large, CPU-bound, independent workloads, but they are not always beneficial. Small tasks, shared mutable state, ordering requirements, and thread overhead can make them slower or riskier than sequential streams.