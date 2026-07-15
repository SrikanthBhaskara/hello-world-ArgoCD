# forEach

## What `forEach` does
`forEach` performs an action for each element in a collection or stream.

## Example
```java
names.forEach(System.out::println);
```

## Where it is useful
- Printing
- Logging
- Final side-effect action

## Where to be careful
If you are transforming data, `map` plus `collect` is often clearer than using `forEach` with mutable side effects.

## Example of good usage
```java
List<String> names = Arrays.asList("A", "B", "C");
names.forEach(System.out::println);
```

This is clear because the goal is only side-effect output.

## Example of risky usage
```java
List<String> upper = new ArrayList<>();
names.stream().forEach(name -> upper.add(name.toUpperCase()));
```

This works, but it uses external mutable state. A cleaner approach is:

```java
List<String> upper = names.stream()
	.map(String::toUpperCase)
	.collect(Collectors.toList());
```

## `forEach` on collections vs streams
Collections have `forEach`, and streams also allow `forEach` as a terminal operation. The intent is similar, but stream `forEach` is part of a pipeline.

## Important caution
Using `forEach` to mutate external state inside a stream pipeline is often a bad practice because it mixes declarative and side-effect-heavy styles.

## Interview point
Explain that `forEach` is easy to overuse and should not replace more expressive transformations when those are more appropriate.

## Interview-style answer
`forEach` is useful when you want to perform an action for every element, such as logging or printing. But if the real goal is transformation or result building, then `map`, `filter`, and `collect` usually produce cleaner and safer code than mutating external state inside `forEach`.