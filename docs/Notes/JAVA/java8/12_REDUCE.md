# reduce

## What `reduce` does
`reduce` combines stream elements into one final result by repeatedly applying a combining operation.

## Basic example
```java
int sum = nums.stream().reduce(0, Integer::sum);
```

## Meaning of the parts
- Identity: initial value
- Accumulator: how each element combines with the current result
- Optional combiner in parallel or specialized forms

## Common use cases
- Sum values
- Multiply values
- Combine strings
- Merge results into one value
- Compute min or max in custom ways

## Example: string combination
```java
String result = words.stream().reduce("", (a, b) -> a + b);
```

## Example: custom multiplication
```java
int product = nums.stream().reduce(1, (a, b) -> a * b);
```

## Why identity matters
The identity is the starting value and should behave correctly with the accumulator. For sum it is usually `0`. For multiplication it is usually `1`.

## Why associativity matters
For parallel execution, the combining operation should be associative. Otherwise, splitting work across threads can give incorrect or unpredictable results.

## When not to overuse `reduce`
If `collect` is clearer for the job, prefer `collect`. Using `reduce` for everything can make code harder to read, especially when building collections or mutable state.

## Common confusion
Developers sometimes use `reduce` where `collect` is more natural. The difference matters because `reduce` is conceptually for immutable combination into one value, while `collect` is designed for structured mutable accumulation.

## Interview-style answer
The `reduce` operation in Java 8 streams combines all elements into a single result. It is useful for tasks like summing, multiplying, or merging values. The key concepts are the identity value and the accumulator logic, and for parallel behavior it is important that the operation be associative. In practice, `reduce` is best when the result is one combined value rather than a collection or grouped structure.