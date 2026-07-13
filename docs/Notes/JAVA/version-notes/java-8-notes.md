# Java 8 Notes

## Purpose

This file is a deeper study note for Java 8.

Use it for:

- interview preparation
- revision notes
- understanding what changed from Java 7 to Java 8
- migration planning for older codebases
- building a base before studying Java 17, 21, and 25

## Java 8 in One Line

Java 8 introduced functional-style programming into mainstream Java and changed how everyday Java code is written.

## Release Identity

If Java 7 feels like classic object-oriented Java with collections, loops, and callback-heavy code, Java 8 is where Java becomes much more expressive through:

- lambdas
- streams
- functional interfaces
- `Optional`
- `java.time`
- `CompletableFuture`

This is why Java 8 is still treated as the baseline in many interviews and real projects.

## Compared With Java 7

### Newly added

- lambda expressions
- method references
- functional interfaces
- Stream API
- `Optional`
- `java.time` date and time API
- `CompletableFuture`
- default methods in interfaces
- static methods in interfaces
- Base64 API
- repeating annotations
- type annotations
- Nashorn JavaScript engine
- parallel array sorting support

### Removed, replaced, or effectively retired

- PermGen was removed in HotSpot and replaced by Metaspace
- old date and time classes like `Date` and `Calendar` were not removed, but `java.time` became the preferred modern API
- repetitive anonymous-class callback style was not removed, but lambdas became the cleaner default in many cases
- old collection-processing loops were not removed, but stream pipelines became the preferred style where they improve clarity

### Modified behavior and platform changes

- interfaces can now contain behavior through default and static methods
- collection processing can now be written declaratively with streams
- concurrency code can now be written with richer async composition using `CompletableFuture`
- memory tuning changed because of Metaspace replacing PermGen
- APIs across the JDK were updated to accept functional interfaces

## Most Important New Language Features

### Lambda expressions

```java
Runnable r = () -> System.out.println("Hello");
```

Why it matters:

- less boilerplate than anonymous classes
- enables functional APIs
- works naturally with streams and callbacks

What to understand deeply:

- lambdas are not just shorter syntax; they work because of target typing and functional interfaces
- a lambda can only target an interface with one abstract method
- lambdas capture effectively final local variables

Common mistake:

- treating lambdas as if they are identical to anonymous classes in every detail

Important difference:

- `this` inside a lambda refers to the enclosing instance
- `this` inside an anonymous class refers to the anonymous class instance

### Method references

```java
names.forEach(System.out::println);
```

Forms to know:

- static method reference: `Integer::sum`
- bound instance method reference: `printer::print`
- unbound instance method reference: `String::trim`
- constructor reference: `ArrayList::new`

Why it matters:

- cleaner syntax when a lambda only calls an existing method

### Functional interfaces

Examples:

- `Predicate<T>`
- `Function<T, R>`
- `Consumer<T>`
- `Supplier<T>`
- `UnaryOperator<T>`
- `BinaryOperator<T>`

Why they matter:

- they are the backbone of streams, lambdas, and modern API design

Interview point:

- a functional interface may contain many default or static methods, but only one abstract method

### Default methods

```java
interface Printer {
    default void print() {
        System.out.println("default print");
    }
}
```

Why it matters:

- allows interface evolution without breaking older implementations

Conflict rule to remember:

- if two interfaces provide the same default method, the implementing class must resolve the conflict

### Static methods in interfaces

Why they matter:

- related utility methods can live close to the interface contract

## Most Important New APIs

### Stream API

```java
List<String> result = users.stream()
    .filter(User::isActive)
    .map(User::getName)
    .sorted()
    .collect(java.util.stream.Collectors.toList());
```

Core concepts:

- a stream is not a data structure
- a stream is a pipeline over data
- streams are lazy until a terminal operation runs
- intermediate operations build a pipeline
- terminal operations trigger execution

Key operations:

- `map`
- `flatMap`
- `filter`
- `distinct`
- `sorted`
- `limit`
- `skip`
- `reduce`
- `collect`
- `findFirst`
- `findAny`
- `anyMatch`
- `allMatch`
- `noneMatch`

Collectors you should know:

- `toList`
- `toSet`
- `joining`
- `groupingBy`
- `partitioningBy`
- `mapping`
- `counting`
- `summarizingInt`

What to learn deeply:

- difference between `map` and `flatMap`
- side effects in streams are dangerous
- parallel streams are not automatically faster
- stream readability matters more than writing everything in one long chain

Common mistakes:

- mutating shared state inside streams
- using streams for code that is clearer as a loop
- assuming parallel streams always help

### `Optional`

```java
Optional<User> user = findUser(id);
user.ifPresent(System.out::println);
```

Why it matters:

- represents absence more clearly than raw `null`
- encourages callers to think about missing values explicitly

What to use it for:

- return types where a value may be absent

What not to do:

- avoid using `Optional` as a field everywhere
- avoid using `Optional` for parameters in most cases
- avoid calling `get()` carelessly

Important methods:

- `of`
- `ofNullable`
- `empty`
- `map`
- `flatMap`
- `filter`
- `orElse`
- `orElseGet`
- `orElseThrow`
- `ifPresent`

Interview point:

- `orElse` evaluates eagerly
- `orElseGet` evaluates lazily

### `java.time`

```java
LocalDate today = LocalDate.now();
LocalDate nextWeek = today.plusDays(7);
```

Important types:

- `LocalDate`
- `LocalTime`
- `LocalDateTime`
- `Instant`
- `ZonedDateTime`
- `Duration`
- `Period`

Why it matters:

- immutable
- easier to read
- much safer than old date/time APIs
- better timezone handling

Old API problem:

- `Date` and `Calendar` are awkward, mutable, and error-prone

New API advantage:

- more domain-specific types
- easier formatting and arithmetic

### `CompletableFuture`

```java
CompletableFuture.supplyAsync(() -> loadUser())
    .thenApply(User::getName)
    .thenAccept(System.out::println);
```

Why it matters:

- easier async composition
- better than deeply nested callbacks
- supports chaining and combining async computations

Important methods:

- `supplyAsync`
- `runAsync`
- `thenApply`
- `thenCompose`
- `thenCombine`
- `thenAccept`
- `exceptionally`
- `handle`
- `allOf`
- `anyOf`

Key difference:

- `thenApply` maps a value
- `thenCompose` flattens nested futures

Common mistakes:

- ignoring exception handling
- blocking with `get()` too early
- using the common pool carelessly in server code

## Old Style vs Java 8 Style

### Old loop vs stream

Old:

```java
List<String> names = new ArrayList<>();
for (User user : users) {
    if (user.isActive()) {
        names.add(user.getName());
    }
}
Collections.sort(names);
```

Java 8:

```java
List<String> names = users.stream()
    .filter(User::isActive)
    .map(User::getName)
    .sorted()
    .collect(java.util.stream.Collectors.toList());
```

When stream style is better:

- simple pipeline transformations
- expressive filtering and mapping

When loop style is still better:

- complex branching
- mutation-heavy logic
- cases where readability is better with explicit control flow

### Anonymous class vs lambda

Old:

```java
button.setOnAction(new EventHandler<ActionEvent>() {
    @Override
    public void handle(ActionEvent event) {
        System.out.println("Clicked");
    }
});
```

Java 8:

```java
button.setOnAction(event -> System.out.println("Clicked"));
```

### Old date API vs `java.time`

Old:

```java
Date now = new Date();
```

Java 8:

```java
Instant now = Instant.now();
LocalDate today = LocalDate.now();
```

### Callback style vs `CompletableFuture`

Old idea:

- nested callbacks and manual thread handling

Java 8:

- chain async steps declaratively with `CompletableFuture`

## Modified or Important Runtime Changes

### PermGen to Metaspace

Before Java 8:

- class metadata lived in PermGen

In Java 8:

- class metadata moved to Metaspace
- JVM tuning flags changed

Why it matters:

- old JVM flags may stop working as expected
- memory behavior differs from Java 7
- classloader-heavy applications may behave differently

### HashMap collision handling improvements

Why it matters:

- collision-heavy maps became more robust
- implementation details changed for better worst-case performance

## What To Learn Deeply

- lambda expressions
- functional interfaces
- streams
- collectors
- `Optional`
- `java.time`
- `CompletableFuture`
- default methods
- Metaspace vs PermGen

## Interview Questions To Expect

- What is a functional interface?
- Difference between lambda and anonymous class?
- Difference between `map` and `flatMap`?
- Difference between `findAny` and `findFirst`?
- When should `Optional` be used?
- Why was `java.time` introduced?
- What changed from PermGen to Metaspace?
- What is the difference between `thenApply` and `thenCompose`?
- Why are streams lazy?

## Migration Notes

If you move from Java 7 to Java 8:

- refactor repetitive loops into streams where it improves readability
- replace old date/time logic with `java.time`
- use lambdas where anonymous classes are noisy
- review JVM tuning if you relied on PermGen settings
- add tests around concurrency if you adopt `CompletableFuture`

## Common Pitfalls

- using streams when loops are clearer
- abusing parallel streams
- overusing `Optional`
- ignoring `CompletableFuture` exception paths
- confusing lambdas with anonymous-class behavior

## Practice Topics

- write a pipeline using `filter`, `map`, and `collect`
- group values with `Collectors.groupingBy`
- compare `orElse` vs `orElseGet`
- convert old `Date` code to `java.time`
- compose two async calls using `CompletableFuture`

## Deeper Stream Notes

### Streams are declarative, not magical

A stream pipeline describes what should happen to data, not how the loop should be written.

This gives you:

- better readability for transformation-heavy logic
- easier composition of operations
- cleaner separation between source, transformation, and terminal step

It does not give you:

- automatic performance improvement
- better readability in every case
- free parallelism

### Intermediate vs terminal operations

Intermediate operations:

- return another stream
- are lazy
- build the pipeline

Examples:

- `map`
- `filter`
- `flatMap`
- `sorted`
- `distinct`

Terminal operations:

- trigger execution
- produce a result or side effect

Examples:

- `collect`
- `forEach`
- `count`
- `reduce`
- `findFirst`

### Stateless vs stateful operations

Stateless operations:

- do not depend on previous elements
- are easier to optimize

Examples:

- `map`
- `filter`

Stateful operations:

- need more context
- may require buffering or ordering awareness

Examples:

- `sorted`
- `distinct`
- `limit` on ordered streams

### Ordered vs unordered streams

Why this matters:

- encounter order can affect performance and semantics
- `findFirst` respects order more strictly than `findAny`
- parallel streams may behave differently depending on ordering constraints

### Primitive streams

Know these:

- `IntStream`
- `LongStream`
- `DoubleStream`

Why they matter:

- avoid boxing overhead
- provide numeric helpers like `sum`, `average`, and `range`

### Parallel streams

Parallel streams are useful only when:

- the data set is large enough
- operations are CPU-heavy and mostly independent
- there is low contention and minimal side effects

Parallel streams are risky when:

- operations block on I/O
- shared mutable state is involved
- ordering matters heavily
- work is too small to amortize parallel overhead

Interview-quality takeaway:

- parallel streams are a tool, not a default optimization

## Deeper `CompletableFuture` Notes

### Mental model

`CompletableFuture` is both:

- a future result
- a pipeline stage

This is why it can represent async work and also chain more async work.

### `thenApply` vs `thenCompose`

Use `thenApply` when:

- the next step returns a normal value

Use `thenCompose` when:

- the next step already returns another `CompletableFuture`

Bad shape:

- `CompletableFuture<CompletableFuture<T>>`

Good shape:

- `CompletableFuture<T>`

### Exception handling

Methods to know:

- `exceptionally`
- `handle`
- `whenComplete`

Difference in intent:

- `exceptionally` recovers from failure
- `handle` transforms both success and failure
- `whenComplete` observes completion but is not mainly for transformation

### Common pool caution

By default, many async methods use the common fork-join pool.

Why this matters:

- behavior may not be ideal for server workloads
- blocking work in the common pool can create issues

Real-world lesson:

- production systems often prefer explicit executors

## Design Guidance

### When not to use streams

Avoid streams when:

- you have complex nested branching
- mutation is the main operation
- a basic loop is clearer

### When not to use `Optional`

Avoid `Optional` when:

- it is used as a field everywhere without clear value
- serialization or framework usage becomes awkward
- it makes a simple API harder to read

### When not to use `CompletableFuture`

Avoid forcing it when:

- your work is fully synchronous
- the async chain becomes harder to understand than the problem itself
- error-handling becomes scattered and confusing

## Real-World Java 8 Impact

Java 8 changed enterprise codebases in several practical ways:

- callback-heavy code became cleaner with lambdas
- utility-heavy collection logic moved into stream pipelines
- time handling improved dramatically through `java.time`
- async workflows became composable with `CompletableFuture`
- interfaces could evolve more safely through default methods

## Upgrade Checklist: Java 7 to Java 8

- identify repetitive loops that can become readable stream pipelines
- replace old date/time code first, because that yields high value
- review anonymous classes that are really functional-interface use cases
- audit JVM flags related to PermGen
- decide where async composition with `CompletableFuture` is actually useful
- add tests before refactoring collection-heavy code into streams

## Old Code Structure vs New Code Structure

### Event-handling structure

Old structure:

```java
button.setOnAction(new EventHandler<ActionEvent>() {
    @Override
    public void handle(ActionEvent event) {
        System.out.println("Clicked");
    }
});
```

Java 8 structure:

```java
button.setOnAction(event -> System.out.println("Clicked"));
```

### Collection-processing structure

Old structure:

```java
Map<String, Integer> counts = new HashMap<>();
for (String word : words) {
    Integer current = counts.get(word);
    counts.put(word, current == null ? 1 : current + 1);
}
```

Java 8 structure:

```java
Map<String, Long> counts = words.stream()
    .collect(java.util.stream.Collectors.groupingBy(
        w -> w,
        java.util.stream.Collectors.counting()
    ));
```

### Date-handling structure

Old structure:

```java
Date now = new Date();
Calendar calendar = Calendar.getInstance();
calendar.add(Calendar.DAY_OF_MONTH, 7);
Date nextWeek = calendar.getTime();
```

Java 8 structure:

```java
Instant now = Instant.now();
LocalDate nextWeek = LocalDate.now().plusDays(7);
```

## Short Summary

Java 8 is mainly about:

- functional programming support
- better collection processing
- better date/time APIs
- better async composition

## Official References

- Java 8 "What's New": https://www.oracle.com/java/technologies/javase/8-whats-new.html
- Java 8 language enhancements: https://docs.oracle.com/javase/8/docs/technotes/guides/language/enhancements.html
