# Common Mistakes in Java 8

## Frequent mistakes
- Using streams where a loop is clearer
- Using side effects heavily inside stream pipelines
- Misusing Optional everywhere
- Assuming parallel streams always improve performance
- Forgetting stream laziness
- Writing overly complex chained stream code
- Confusing `map` and `flatMap`
- Ignoring `orElse` vs `orElseGet` evaluation cost

## Why interviewers ask about mistakes
They want to know whether you can use Java 8 features responsibly rather than mechanically.

## Good speaking point
Java 8 features improve expressiveness, but they should still be used only when they improve clarity, safety, or maintainability.

## Example of bad stream overuse
If a simple loop is more readable than a long chain of stream operations with nested lambdas, the loop is often the better engineering choice.

## Example of Optional misuse
```java
class User {
	private Optional<String> name;
}
```

This is often not a good design because Optional is usually more useful in return types than as fields.

## Example of side-effect-heavy stream misuse
```java
List<String> result = new ArrayList<>();
names.stream().forEach(name -> result.add(name.toUpperCase()));
```

This is usually less clear than using `map` and `collect`.