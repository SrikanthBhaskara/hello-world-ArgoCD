# Java 8 Interview Questions Intermediate Level

## Intermediate Questions

### 1. Difference between `map` and `flatMap`?

Solved answer:
`map` transforms each input element into one output value. `flatMap` transforms each input element into a stream or collection of values and then flattens the result into a single stream. `flatMap` is useful for nested lists or tokenizing lines into words.

### 2. Difference between `orElse` and `orElseGet`?

Solved answer:
`orElse` evaluates its fallback value immediately, even if the Optional already contains a value. `orElseGet` evaluates the fallback lazily through a supplier, so it is better when fallback creation is expensive.

### 3. What is the difference between intermediate and terminal operations?

Solved answer:
Intermediate operations return another stream and are lazy, such as `filter`, `map`, and `sorted`. Terminal operations trigger execution and produce a result or side effect, such as `collect`, `count`, or `forEach`.

### 4. When would you use `reduce` instead of `collect`?

Solved answer:
I would use `reduce` when I want to combine stream elements into one final value, such as a sum or concatenated result. I would use `collect` when I need structured results like a list, set, map, or grouping.

### 5. What is the difference between external iteration and internal iteration?

Solved answer:
External iteration means the developer controls the loop manually, such as with a `for` loop. Internal iteration means the library controls traversal, as in a stream pipeline. Java 8 streams use internal iteration.

### 6. How do default methods help interface evolution?

Solved answer:
Default methods let interfaces add behavior without breaking every existing implementation. This is especially useful in large libraries where many classes already implement an interface.

### 7. What are primitive streams and why do they exist?

Solved answer:
Primitive streams such as `IntStream`, `LongStream`, and `DoubleStream` exist to avoid boxing and unboxing overhead and to provide convenient numeric operations like `sum`, `average`, and `range`.

### 8. When would you use `computeIfAbsent`?

Solved answer:
I use `computeIfAbsent` when I want to create and store a value only if the key is missing, such as initializing a list in a map before adding items to it.

### 9. What is the role of `thenCompose` in CompletableFuture?

Solved answer:
`thenCompose` is used when one asynchronous step returns another CompletableFuture and I want to flatten the chain. It avoids nested futures and is useful for dependent async calls.

### 10. Why are streams lazy?

Solved answer:
Streams are lazy so that intermediate operations can be chained and optimized before actual execution. The pipeline usually runs only when a terminal operation is called.

## What interviewers test here
- Concept distinction
- Practical usage
- API understanding
- Ability to explain tradeoffs