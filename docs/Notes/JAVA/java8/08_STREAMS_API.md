# Streams API

## What a stream is
A stream is a sequence of elements that supports aggregate operations. It is not a data structure and does not store elements itself. Instead, it describes a pipeline for processing data from a source.

## Why streams matter
Streams changed Java collection processing from an imperative style to a more declarative one.

### Benefits
- Cleaner data transformation logic
- Reduced loop boilerplate
- Easier chaining of operations
- Better separation between what to do and how iteration happens
- Support for parallel execution in suitable cases

## Stream pipeline structure
1. Source
2. Intermediate operations
3. Terminal operation

### Example
```java
List<String> result = names.stream()
    .filter(name -> name.length() > 3)
    .map(String::toUpperCase)
    .collect(Collectors.toList());
```

In this example:
- `names` is the source
- `filter` and `map` are intermediate operations
- `collect` is the terminal operation

## Stream source examples
- Collection source
- Array source
- `Stream.of(...)`
- Numeric stream factories like `IntStream.range(...)`
- File or buffered reader sources in practical use

## Important properties
- Streams do not store data.
- Streams are usually consumed once.
- Intermediate operations are lazy.
- Streams can be sequential or parallel.

## Why laziness matters
Intermediate operations do nothing until a terminal operation is called. This allows Java to optimize execution and avoid unnecessary work.

## Streams are not always better than loops
Streams are very useful for transformation-heavy collection logic, but a simple loop may still be clearer for highly stateful or side-effect-heavy code.

## Common use cases
- Filtering lists
- Converting one collection to another
- Grouping by fields
- Counting and aggregation
- Matching conditions
- Finding min, max, or first values

## Stream processing style
Streams encourage a style where you describe the processing pipeline instead of manually controlling iteration.

## Interview-style answer
The Streams API in Java 8 provides a declarative way to process data from collections and other sources. A stream is not a storage structure but a pipeline of operations such as filtering, mapping, grouping, and reduction. Its practical value is cleaner data-processing code, lazy execution, and easier composition of collection logic.