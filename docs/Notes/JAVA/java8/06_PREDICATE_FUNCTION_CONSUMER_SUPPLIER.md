# Predicate, Function, Consumer, Supplier

## Why these interfaces matter
These are the most commonly used built-in functional interfaces in Java 8. They represent very common behavior shapes, so developers do not have to create custom interfaces for every small operation.

## Predicate<T>

### What it represents
A `Predicate<T>` takes one input and returns `true` or `false`.

```java
Predicate<Integer> isEven = n -> n % 2 == 0;
```

### Typical uses
- Filtering values
- Validation rules
- Business conditions
- Match checks

### Example with streams
```java
List<Integer> evens = numbers.stream()
	.filter(n -> n % 2 == 0)
	.collect(Collectors.toList());
```

### Useful methods
- `and`
- `or`
- `negate`

### Example
```java
Predicate<String> notEmpty = s -> s != null && !s.isEmpty();
Predicate<String> shortText = s -> s.length() < 10;
Predicate<String> valid = notEmpty.and(shortText);
```

## Function<T, R>

### What it represents
A `Function<T, R>` takes an input of type `T` and returns a value of type `R`.

```java
Function<String, Integer> len = s -> s.length();
```

### Typical uses
- Mapping values
- Converting data types
- Extracting fields
- Transforming objects

### Example with streams
```java
List<Integer> lengths = words.stream()
	.map(String::length)
	.collect(Collectors.toList());
```

### Useful methods
- `andThen`
- `compose`

### Example
```java
Function<String, String> trim = String::trim;
Function<String, Integer> length = String::length;
Function<String, Integer> trimThenLength = trim.andThen(length);
```

## Consumer<T>

### What it represents
A `Consumer<T>` accepts one input and returns nothing.

```java
Consumer<String> print = System.out::println;
```

### Typical uses
- Logging
- Printing
- Updating state
- Performing final side-effect actions

### Example
```java
names.forEach(System.out::println);
```

### Important note
Consumers are about side effects, so they should be used carefully in stream-heavy code where pure transformations are often cleaner.

## Supplier<T>

### What it represents
A `Supplier<T>` provides a value without taking input.

```java
Supplier<Double> random = Math::random;
```

### Typical uses
- Lazy object creation
- Default value generation
- Deferred computation
- Factory-style behavior

### Example
```java
Supplier<List<String>> listFactory = ArrayList::new;
```

## Comparison summary
- Predicate checks
- Function transforms
- Consumer uses
- Supplier provides

## When to use built-in interfaces vs custom interfaces
Use built-in interfaces when the behavior fits naturally. Use custom functional interfaces when the method meaning is domain-specific and naming improves readability.

## Interview-style answer
Predicate, Function, Consumer, and Supplier are important built-in functional interfaces in Java 8. Predicate is used for boolean conditions, Function for transformation, Consumer for side-effect operations, and Supplier for value generation without input. They are heavily used in stream processing and modern Java APIs because they avoid the need for many tiny custom interfaces.