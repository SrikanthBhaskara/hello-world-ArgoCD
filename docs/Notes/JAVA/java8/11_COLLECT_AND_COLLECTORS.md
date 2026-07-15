# collect and Collectors

## Why `collect` matters
Most practical stream pipelines end by collecting results into a list, set, map, grouped structure, or summary value. That makes `collect` one of the most important terminal operations in Java 8.

## What `Collectors` provides
`Collectors` is a utility class that provides common collection strategies for stream results.

## Common collectors
- toList
- toSet
- joining
- groupingBy
- partitioningBy
- counting
- averagingInt
- mapping
- summarizingInt
- toMap

## Example: toList
```java
List<String> list = names.stream()
    .map(String::toUpperCase)
    .collect(Collectors.toList());
```

## Example: toSet
```java
Set<String> set = names.stream().collect(Collectors.toSet());
```

## Example: groupingBy
```java
Map<String, List<Employee>> byDept = employees.stream()
    .collect(Collectors.groupingBy(Employee::getDepartment));
```

## Example: joining
```java
String joined = names.stream().collect(Collectors.joining(", "));
```

## Example: partitioningBy
```java
Map<Boolean, List<Integer>> partitions = nums.stream()
    .collect(Collectors.partitioningBy(n -> n % 2 == 0));
```

## Example: counting
```java
long count = names.stream().collect(Collectors.counting());
```

## Why `collect` is often better than manual accumulation
Without `collect`, developers may use loops and mutable containers manually. `collect` keeps the accumulation logic aligned with the pipeline style and is easier to reason about.

## `collect` vs `reduce`
`collect` is better suited for building collections and grouped results. `reduce` is better for combining stream elements into one value.

## Common interview point
If asked why `collect` exists when `reduce` also exists, explain that `collect` is specialized for mutable reduction and structured result building.

## Interview-style answer
`collect` is a terminal stream operation used to gather results into collections, grouped maps, joined strings, or summary objects. The `Collectors` utility class provides ready-made strategies like `toList`, `groupingBy`, `joining`, and `partitioningBy`. In real code, `collect` is one of the most common stream endpoints because most pipelines need a structured final result.