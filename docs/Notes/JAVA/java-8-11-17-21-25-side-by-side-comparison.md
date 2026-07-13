# Java 8, 11, 17, 21, 25: Side-by-Side Comparison

## Why This Note Exists

This note helps you compare the most important Java LTS versions side by side.

Use it when:

- you want a fast comparison across major Java versions
- you want to prepare for migration interviews
- you want to understand what changed in code style, APIs, and runtime behavior

## Quick Positioning

| Version | Main Identity |
|---|---|
| Java 8 | functional-style Java becomes mainstream |
| Java 11 | first major post-8 LTS modernization bridge |
| Java 17 | modern language modeling becomes standard for enterprise Java |
| Java 21 | major concurrency modernization release |
| Java 25 | latest LTS that continues modern language and runtime maturity |

## Feature Comparison Table

| Area | Java 8 | Java 11 | Java 17 | Java 21 | Java 25 |
|---|---|---|---|---|---|
| LTS | yes | yes | yes | yes | yes |
| Big identity | lambdas and streams | first post-8 LTS bridge | modern enterprise baseline | modern concurrency baseline | latest LTS maturity layer |
| Core coding style | loops plus streams transition | same plus cleaner APIs | records, sealed types, switch expressions | virtual-thread era begins | more mature modern Java direction |
| HTTP client | old `HttpURLConnection` mostly | standard `HttpClient` available | same | same | same |
| Data carrier style | classic POJOs | classic POJOs | records become standard | records mainstream | records still mainstream |
| Hierarchy modeling | classic inheritance/interfaces | same | sealed classes standard | stronger pattern matching around models | same direction, more mature |
| String handling | baseline | better String APIs | text blocks already available by this era | same | same |
| Concurrency story | thread pools and `CompletableFuture` | same baseline | same baseline with better language support around modeling | virtual threads standard | virtual threads plus scoped-values direction |
| Pattern matching | no | no | `instanceof` pattern matching standard | switch pattern matching standard | further language polish direction |
| Module system | not present | present and important | present and stricter | present | present |
| Java EE bundled modules | still bundled era mindset | removed from JDK | already removed era | same | same |
| GC story | pre-modern baseline | bridge era improvements | more modern collector landscape | generational ZGC | continued runtime maturity |

## What Changed Most From Version to Version

### Java 8 to Java 11

Biggest practical changes:

- standard HTTP client
- useful String and Files APIs
- Java EE and CORBA modules removed from the JDK
- stronger module-era reality

### Java 11 to Java 17

Biggest practical changes:

- records
- sealed classes
- switch expressions
- text blocks
- stronger encapsulation of JDK internals

### Java 17 to Java 21

Biggest practical changes:

- virtual threads
- record patterns
- switch pattern matching
- sequenced collections
- generational ZGC

### Java 21 to Java 25

Biggest practical changes:

- latest LTS maturity
- scoped-values direction
- module import declarations
- compact source files direction
- flexible constructor bodies direction
- continued runtime and GC improvements

## Code Structure Shift

### Java 8 style

```java
List<String> names = new ArrayList<>();
for (User user : users) {
    if (user.isActive()) {
        names.add(user.getName());
    }
}
```

### Java 11 style

Mostly same structure, but older helper code starts getting replaced by standard JDK utilities such as:

- `HttpClient`
- `Files.readString`
- `String.isBlank`

### Java 17 style

```java
record UserDto(String id, String name) {}
```

and

```java
return switch (status) {
    case ACTIVE -> "enabled";
    case DISABLED -> "disabled";
};
```

### Java 21 style

```java
try (var executor = Executors.newVirtualThreadPerTaskExecutor()) {
    executor.submit(() -> process());
}
```

### Java 25 style

Still modern Java, but with more maturity around:

- latest language cleanup direction
- modern concurrency direction
- runtime and GC improvements

## Migration Focus

| Upgrade path | Main risks |
|---|---|
| Java 8 to 11 | removed Java EE modules, dependency compatibility, old runtime assumptions |
| Java 11 to 17 | internal API access, framework compatibility, newer syntax adoption choices |
| Java 17 to 21 | concurrency model changes, testing virtual-thread behavior, library readiness |
| Java 21 to 25 | deciding which latest features matter vs what should stay optional |

## Best Study Order

| Step | Focus |
|---|---|
| 1 | Java 8 streams, `Optional`, `java.time`, `CompletableFuture` |
| 2 | Java 11 modules at a practical level, HTTP client, `String` and `Files` improvements |
| 3 | Java 17 switch expressions, text blocks, records, sealed classes |
| 4 | Java 21 virtual threads, record patterns, switch pattern matching |
| 5 | Java 25 scoped values, module import declarations, compact source files, flexible constructor bodies |

## Fast Summary

| Version | What You Should Remember First |
|---|---|
| Java 8 | functional Java starts here |
| Java 11 | first real modernization bridge from Java 8 |
| Java 17 | modern language modeling becomes practical |
| Java 21 | concurrency gets dramatically simpler |
| Java 25 | latest LTS standardizes newer ideas |

## Related Notes

- [Java 8 Notes](./version-notes/java-8-notes.md)
- [Java 11 Notes](./version-notes/java-11-notes.md)
- [Java 17 Notes](./version-notes/java-17-notes.md)
- [Java 21 Notes](./version-notes/java-21-notes.md)
- [Java 25 Notes](./version-notes/java-25-notes.md)
- [Java 8, 11, 17, 21, 25: Complete Learning Notes](./learning-guides/java-8-11-17-21-25-complete-learning-notes.md)
