# Optional

## What Optional is
`Optional` is a container object that may hold a non-null value or may be empty. It is used to represent absence explicitly instead of silently returning `null`.

## Why it was introduced
The main goal was to make null-related absence more visible and force callers to think about missing values more deliberately.

## Basic example
```java
Optional<String> name = Optional.ofNullable(input);
String result = name.map(String::trim).orElse("default");
```

## Common factory methods
- `Optional.of(value)`
- `Optional.ofNullable(value)`
- `Optional.empty()`

## Common access and transformation methods
- `isPresent()`
- `ifPresent(...)`
- `orElse(...)`
- `orElseGet(...)`
- `orElseThrow(...)`
- `map(...)`
- `flatMap(...)`
- `filter(...)`

## Best use cases
- Method return types where absence is meaningful
- Fluent transformation pipelines
- Safer handling of lookup results

## Example with lookup logic
```java
Optional<User> user = findUserById(id);
String city = user
	.map(User::getAddress)
	.map(Address::getCity)
	.orElse("Unknown");
```

## `orElse` vs `orElseGet`

### `orElse`
The fallback value is evaluated immediately.

### `orElseGet`
The fallback supplier runs only if the Optional is empty.

### Why the difference matters
If the fallback is expensive, `orElseGet` is safer and more efficient.

## Common misuse
- Using Optional for every field in domain classes
- Using Optional as a method parameter unnecessarily
- Using `get()` carelessly without checking presence

## Important caution
`Optional` does not eliminate all null problems automatically. It improves API clarity when used thoughtfully.

## Interview-style answer
Optional in Java 8 is a container used to represent the presence or absence of a value more explicitly than returning null. It is most useful in method return types and transformation chains. Its real value is API clarity, but it should not be overused for fields or parameters where it makes code more awkward instead of clearer.