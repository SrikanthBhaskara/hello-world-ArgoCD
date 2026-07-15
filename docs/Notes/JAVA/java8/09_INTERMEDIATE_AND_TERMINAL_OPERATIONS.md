# Intermediate and Terminal Operations

## Intermediate operations
Intermediate operations return another stream and are lazy. They describe work to be done later.

### Common intermediate operations
- filter
- map
- flatMap
- sorted
- distinct
- limit
- skip
- peek

## Terminal operations
Terminal operations end the stream pipeline and trigger execution.

### Common terminal operations
- collect
- forEach
- count
- reduce
- findFirst
- findAny
- anyMatch
- allMatch
- noneMatch
- min
- max

## Why this distinction matters
Understanding laziness explains why code does not execute until a terminal operation is reached. This is one of the most important stream concepts.

## Example
```java
long count = names.stream()
    .filter(name -> name.startsWith("A"))
    .count();
```

The `filter` does not run immediately when written. Execution happens when `count()` is called.

## Short-circuit behavior
Some terminal operations do not need to process the whole stream.

### Examples
- `findFirst()`
- `anyMatch()`
- `noneMatch()`
- `limit()` combined with a terminal step

This matters for efficiency.

## Common mistake
Developers sometimes expect intermediate operations to execute for side effects. That expectation is wrong because without a terminal operation the pipeline is not executed.

## Interview-style answer
Intermediate operations build the stream pipeline and are lazy, while terminal operations trigger actual execution and produce a result or effect. This distinction is important because it explains stream laziness, optimization, and why certain pipelines do nothing until a terminal step is called.