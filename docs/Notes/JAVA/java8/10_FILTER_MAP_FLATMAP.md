# filter, map, flatMap

## filter
`filter` keeps only those elements that satisfy a condition.

```java
List<Integer> evens = nums.stream()
    .filter(n -> n % 2 == 0)
    .collect(Collectors.toList());
```

### Use cases
- Remove invalid data
- Keep matching records
- Apply business conditions

## map
`map` transforms each element into another value.

```java
List<Integer> lengths = words.stream()
    .map(String::length)
    .collect(Collectors.toList());
```

### Use cases
- Convert objects to fields
- Transform text
- Change one type into another

## flatMap
`flatMap` transforms each element into a stream of elements and then flattens the result into one combined stream.

```java
List<String> tokens = lines.stream()
    .flatMap(line -> Arrays.stream(line.split(" ")))
    .collect(Collectors.toList());
```

### Use cases
- Flatten nested lists
- Split lines into words
- Flatten optional or nested stream results

## The real difference between map and flatMap
- `map`: one input becomes one output
- `flatMap`: one input may become zero, one, or many outputs

## Example with nested lists
```java
List<List<Integer>> data = Arrays.asList(
    Arrays.asList(1, 2),
    Arrays.asList(3, 4)
);

List<Integer> flat = data.stream()
    .flatMap(List::stream)
    .collect(Collectors.toList());
```

Without `flatMap`, the result would still be nested.

## Common confusion
Many developers understand `map` quickly but struggle with `flatMap`. The easiest explanation is that `flatMap` is used when each element produces a collection or stream and you want one flat result.

## Interview-style answer
In Java 8 streams, `filter` is used to keep matching elements, `map` is used to transform each element into another value, and `flatMap` is used when each element expands into multiple values and those nested results need to be flattened into one stream. `flatMap` is especially useful for nested collections and tokenization-like problems.