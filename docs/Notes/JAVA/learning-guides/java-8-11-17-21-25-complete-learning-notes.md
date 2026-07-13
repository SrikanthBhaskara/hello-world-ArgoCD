# Java 8, 11, 17, 21, 25: Complete Learning Notes

## Purpose

This note focuses on the most important Java LTS releases:

- Java 8
- Java 11
- Java 17
- Java 21
- Java 25

Use it for:

- interview preparation
- project upgrade understanding
- learning modern Java in LTS steps
- understanding how old Java code evolves into modern Java code

## Why These Versions Matter

- Java 8 is the legacy baseline for many systems.
- Java 11 is the first major modernization bridge after Java 8.
- Java 17 is the modern enterprise language baseline for many teams.
- Java 21 is the major concurrency milestone release.
- Java 25 is the latest LTS and standardizes more modern platform directions.

## Quick Comparison

| Version | Released | Why It Matters | Most Important Additions |
|---|---|---|---|
| Java 8 | 2014-03-18 | functional baseline | lambdas, streams, `Optional`, `java.time`, `CompletableFuture` |
| Java 11 | 2018-09-25 | first post-8 LTS | HTTP client, module-era migration reality, `String`/`Files` improvements |
| Java 17 | 2021-09-14 | major modern language LTS | records, sealed classes, pattern matching for `instanceof`, text blocks |
| Java 21 | 2023-09-19 | concurrency milestone LTS | virtual threads, record patterns, pattern matching for `switch`, sequenced collections |
| Java 25 | 2025-09-16 | latest LTS | scoped values, module import declarations, compact source files, flexible constructor bodies |

## Quick Revision Sheet

### One-line memory map

- Java 8: functional Java starts here
- Java 11: Java enters the post-8 platform era
- Java 17: modern modeling and cleaner syntax become mainstream
- Java 21: modern concurrency becomes practical with virtual threads
- Java 25: latest LTS polish and newer ergonomics become standard

### Best real-world upgrade path

1. Java 8 -> Java 11
2. Java 11 -> Java 17
3. Java 17 -> Java 21
4. Java 21 -> Java 25

### Biggest migration risks

- internal JDK APIs are strongly encapsulated
- Java EE and CORBA pieces are no longer bundled
- Nashorn is removed
- Security Manager is deprecated and later disabled
- default charset becomes UTF-8 in newer Java
- old reflective and agent-loading assumptions may break

## Java 8

### Quick memory line

Java 8 is the foundation release for lambdas, streams, modern date/time, and async basics.

### Most important features

- lambda expressions
- method references
- functional interfaces
- Stream API
- `Optional`
- `java.time`
- `CompletableFuture`
- default methods in interfaces

### Why it matters

- collection processing becomes more declarative
- async composition becomes much cleaner
- Java gains a modern date/time API

### Old code structure vs new code structure

Old style:

```java
List<String> names = new ArrayList<>();
for (User user : users) {
    if (user.isActive()) {
        names.add(user.getName());
    }
}
Collections.sort(names);
```

Java 8 style:

```java
List<String> names = users.stream()
    .filter(User::isActive)
    .map(User::getName)
    .sorted()
    .collect(java.util.stream.Collectors.toList());
```

### What to learn deeply

- streams
- `map` vs `flatMap`
- `Optional`
- `CompletableFuture`
- `java.time`

## Java 11

### Quick memory line

Java 11 is the bridge from legacy Java 8 systems into the modern platform world.

### Most important features

- standard HTTP client
- single-file source launch
- module-era platform impact
- `String.isBlank`, `lines`, `repeat`, `strip`
- `Files.readString`, `Files.writeString`
- `Optional.isEmpty`
- collection factory methods and Java 9 to 11 carry-over improvements

### Why it matters

- first realistic post-Java-8 LTS target
- many teams first hit Java EE removal and encapsulation issues here
- standard library became much nicer for common tasks

### Old code structure vs new code structure

Old style:

```java
URL url = new URL("https://example.com");
HttpURLConnection conn = (HttpURLConnection) url.openConnection();
conn.setRequestMethod("GET");
```

Java 11 style:

```java
HttpClient client = HttpClient.newHttpClient();
HttpRequest request = HttpRequest.newBuilder()
    .uri(URI.create("https://example.com"))
    .build();
HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
```

### What to learn deeply

- HTTP client
- Java EE module removal impact
- classpath vs module-path at a practical level
- `String` and `Files` quality-of-life APIs

## Java 17

### Quick memory line

Java 17 is the LTS where modern Java syntax and modeling become stable enough for broad enterprise use.

### Most important features

- switch expressions
- text blocks
- records
- sealed classes
- pattern matching for `instanceof`
- helpful NullPointerExceptions
- stronger encapsulation

### Why it matters

- language becomes more expressive with less boilerplate
- many teams adopt records and sealed classes as new modeling defaults
- platform boundaries become stricter and safer

### Old code structure vs new code structure

Old style:

```java
final class Employee {
    private final String id;
    private final String name;

    Employee(String id, String name) {
        this.id = id;
        this.name = name;
    }

    String id() { return id; }
    String name() { return name; }
}
```

Java 17 style:

```java
record Employee(String id, String name) {}
```

Old branching style:

```java
if (obj instanceof String) {
    String s = (String) obj;
    return s.toUpperCase();
}
return "other";
```

Java 17 style:

```java
if (obj instanceof String s) {
    return s.toUpperCase();
}
return "other";
```

### What to learn deeply

- records
- sealed classes
- switch expressions
- text blocks
- stronger encapsulation and migration pain points

## Java 21

### Quick memory line

Java 21 is the LTS where concurrency becomes much simpler because virtual threads are standard.

### Most important features

- virtual threads
- record patterns
- pattern matching for `switch`
- sequenced collections
- generational ZGC

### Why it matters

- thread-per-task becomes practical again for many I/O-heavy services
- branching on type hierarchies becomes cleaner
- record-based modeling integrates nicely with pattern matching

### Old code structure vs new code structure

Old style:

```java
ExecutorService executor = Executors.newFixedThreadPool(100);
for (String url : urls) {
    executor.submit(() -> fetch(url));
}
```

Java 21 style:

```java
try (var executor = java.util.concurrent.Executors.newVirtualThreadPerTaskExecutor()) {
    for (String url : urls) {
        executor.submit(() -> fetch(url));
    }
}
```

Old branching style:

```java
if (value instanceof Integer i) {
    return "Integer: " + i;
} else if (value instanceof String s) {
    return "String: " + s;
}
return "Other";
```

Java 21 style:

```java
return switch (value) {
    case Integer i -> "Integer: " + i;
    case String s -> "String: " + s;
    case null -> "null";
    default -> "Other";
};
```

### What to learn deeply

- virtual threads
- pinning
- record patterns
- switch pattern matching
- structured concurrency and scoped values concepts

## Java 25

### Quick memory line

Java 25 is the latest LTS and standardizes several features that were still evolving after Java 21.

### Most important features

- scoped values
- module import declarations
- compact source files and instance main methods
- flexible constructor bodies
- compact object headers
- generational Shenandoah

### Why it matters

- newer platform ideas become standard rather than preview-only
- context handling improves in modern concurrent systems
- runtime and footprint improvements become an important part of the release story

### Old code structure vs new code structure

Older direction:

```java
public class HelloWorld {
    public static void main(String[] args) {
        System.out.println("Hello");
    }
}
```

Java 25 direction:

- compact source files and instance main methods reduce boilerplate for small programs

Older context style:

- `ThreadLocal`-heavy context propagation

Java 25 direction:

- scoped values provide a cleaner execution-scope-oriented model

### What to learn deeply

- scoped values
- standard vs preview discipline
- why teams may choose Java 21 or Java 25
- runtime and operations benefits

## Best Way to Compare These Five Versions

### Java 8

Think:

- functional programming baseline

### Java 11

Think:

- platform modernization bridge

### Java 17

Think:

- modern language expressiveness

### Java 21

Think:

- concurrency revolution

### Java 25

Think:

- latest LTS maturity and runtime polish

## What To Learn First

1. Java 8 streams, `Optional`, `java.time`, `CompletableFuture`
2. Java 11 HTTP client, modules at a practical level, `String` and `Files` improvements
3. Java 17 records, sealed classes, text blocks, switch expressions
4. Java 21 virtual threads, record patterns, switch pattern matching
5. Java 25 scoped values, module import declarations, flexible constructor bodies

## Best Upgrade Path for Real Projects

### Java 8 to Java 11

Main work:

- dependency upgrades
- Java EE and CORBA replacement dependencies
- module-era access cleanup

### Java 11 to Java 17

Main work:

- stricter encapsulation handling
- reflection-heavy framework validation
- modern language adoption where useful

### Java 17 to Java 21

Main work:

- concurrency model evaluation
- framework compatibility for virtual threads
- observability updates

### Java 21 to Java 25

Main work:

- ecosystem readiness checks
- deciding whether Java 25-only features add real value
- performance and footprint validation

## Important Migration Risks

- strong encapsulation of JDK internals
- removed Java EE/CORBA modules
- Nashorn removal
- Security Manager decline and permanent disablement
- finalization deprecation path
- default charset becoming UTF-8
- dynamic agent loading restrictions
- old 32-bit platform assumptions

## Interview Cheat View

If someone asks what changed from Java 8 to modern Java, the shortest strong answer is:

- Java 8 introduced lambdas, streams, `Optional`, `java.time`, and `CompletableFuture`.
- Java 11 became the bridge release with the HTTP client and the first big platform migration pain around bundled modules and encapsulation.
- Java 17 made the language much more expressive with records, sealed classes, text blocks, switch expressions, and pattern matching for `instanceof`.
- Java 21 made concurrency much simpler with virtual threads and improved branching with record patterns and switch pattern matching.
- Java 25 is the latest LTS and continues that direction with scoped values and newer language ergonomics becoming standard.

## Final Summary

If you want to master the most important LTS path, these are the versions to know:

- Java 8 for the functional foundation
- Java 11 for the first modernization bridge
- Java 17 for modern object and language design
- Java 21 for modern concurrency
- Java 25 for the latest LTS direction

## Official References

- Java 8 "What's New": https://www.oracle.com/java/technologies/javase/8-whats-new.html
- JDK 11: https://openjdk.org/projects/jdk/11/
- JDK 17: https://openjdk.org/projects/jdk/17/
- JDK 21: https://openjdk.org/projects/jdk/21/
- JDK 25: https://openjdk.org/projects/jdk/25/
- Java language changes summary through Java 25: https://docs.oracle.com/en/java/javase/25/language/java-language-changes-summary.html
