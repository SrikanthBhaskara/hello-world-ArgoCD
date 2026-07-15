# Primitive Streams

## Why they exist
Using boxed types like `Integer` can introduce boxing and unboxing overhead. Java 8 provides primitive streams for better performance and cleaner numeric operations.

## Types
- IntStream
- LongStream
- DoubleStream

## Example
```java
int sum = IntStream.rangeClosed(1, 5).sum();
```

## More examples

### Average of values
```java
OptionalDouble avg = IntStream.of(10, 20, 30).average();
```

### Maximum value
```java
OptionalInt max = IntStream.of(3, 8, 2, 9).max();
```

### Mapping and summing
```java
int total = IntStream.rangeClosed(1, 5)
	.map(n -> n * 2)
	.sum();
```

## Benefits
- Less boxing overhead
- Numeric convenience methods
- Clearer intent for numeric pipelines

## Why boxing matters
Using boxed numbers like `Integer` can introduce conversion overhead and more object allocation. Primitive streams help avoid that.

## Common methods
- `sum()`
- `average()`
- `max()`
- `min()`
- `range()`
- `rangeClosed()`

## Interview point
Primitive streams are especially useful in performance-sensitive numeric processing.

## Interview-style answer
Primitive streams like `IntStream`, `LongStream`, and `DoubleStream` exist to avoid boxing overhead and to provide convenient numeric operations such as `sum`, `average`, and `range`. They are useful when numeric processing is common and performance or readability matters.