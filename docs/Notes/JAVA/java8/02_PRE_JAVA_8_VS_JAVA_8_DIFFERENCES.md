# Pre-Java 8 vs Java 8 Differences

## Before Java 8
Pre-Java 8 code was often more verbose, especially for collection processing and callback-style behavior. Anonymous inner classes were common, loops were written manually, and interfaces were less flexible.

## With Java 8
Java 8 introduced shorter behavior definitions, declarative collection processing, and better interface evolution support.

## Major differences
- Anonymous inner classes vs lambdas
- Manual loops vs streams
- Null-heavy style vs Optional-based return patterns
- Old date APIs vs `java.time`
- Rigid interfaces vs default/static methods

## Example: anonymous class vs lambda
```java
Runnable a = new Runnable() {
    @Override
    public void run() {
        System.out.println("Hello");
    }
};

Runnable b = () -> System.out.println("Hello");
```

## Example: loop vs stream
```java
List<String> result = new ArrayList<>();
for (String name : names) {
    if (name.startsWith("A")) {
        result.add(name.toUpperCase());
    }
}

List<String> result2 = names.stream()
    .filter(name -> name.startsWith("A"))
    .map(String::toUpperCase)
    .collect(Collectors.toList());
```

## Deeper difference in style
The biggest shift was not only shorter syntax. Java 8 changed many tasks from manual control flow to declarative transformation pipelines. The developer often writes what should happen instead of writing every loop and callback step explicitly.

## Examples of design-level change
- APIs became easier to design around behavior.
- Collection logic became easier to express and compose.
- Interfaces became easier to evolve.
- Null-handling became more explicit in some APIs.

## Interview angle
The difference is not just shorter syntax. Java 8 changed the preferred style for many operations from imperative to declarative.