# Java 8 to Java 25: Key Changes and Learning Notes

## Purpose

This note is a practical study guide for moving from Java 8 to Java 25.

It focuses on:

- major language changes
- important library and platform additions
- JVM and tooling changes that affect production systems
- features you should learn first
- migration risks when moving old Java 8 code to newer JDKs

This is not a list of every single JEP or patch-level change. It is a high-signal guide to the most important developer-facing changes from Java 8 through Java 25.

## Big Picture

Java changed a lot after Java 8:

- Java moved to a 6-month release cadence.
- LTS releases became the main upgrade targets for most teams.
- The language became more expressive with `var`, switch expressions, text blocks, records, sealed classes, and pattern matching.
- Concurrency changed dramatically with virtual threads and structured concurrency.
- The platform became stricter with module boundaries and stronger encapsulation of JDK internals.
- Several old technologies were removed or deprecated, including Java EE/CORBA modules, Nashorn, CMS, Security Manager, and 32-bit x86 support.

## LTS Milestones

These are the versions most teams usually target:

- Java 8: old baseline in many legacy systems
- Java 11: first major post-8 LTS
- Java 17: modern enterprise baseline
- Java 21: current widely adopted modern LTS
- Java 25: latest LTS, GA on 2025-09-16

## Java 8 Baseline

Before learning 9 to 25, make sure these Java 8 features are solid:

- lambda expressions
- method references
- functional interfaces
- Stream API
- `Optional`
- `java.time`
- default and static methods in interfaces
- `CompletableFuture`
- parallel streams

If Java 8 is your real baseline, these are the concepts you compare everything else against.

## Version-by-Version Changes

### Java 9

This was the biggest structural release after Java 8.

Key changes:

- Java Platform Module System, also called JPMS or Project Jigsaw
- `jshell` REPL
- collection factory methods like `List.of`, `Set.of`, `Map.of`
- Stream improvements such as `takeWhile`, `dropWhile`, `iterate`, and `ofNullable`
- `Optional` improvements like `ifPresentOrElse`, `or`, and `stream`
- Process API updates
- multi-release JARs
- G1 became the default garbage collector
- private methods in interfaces
- stronger encapsulation of internal JDK APIs started here

Why it matters:

- Modules changed packaging, visibility, startup layout, and runtime image creation.
- Many legacy apps still feel Java 9 pain because they depended on internal JDK classes.

What to learn:

- difference between classpath and module-path
- `module-info.java`
- exported packages vs required modules
- when not to modularize immediately

### Java 10

Key changes:

- local variable type inference with `var`
- Application Class-Data Sharing
- parallel full GC for G1
- time-based release versioning

Why it matters:

- `var` became part of everyday Java coding style.

What to learn:

- where `var` improves readability
- where explicit types are still better

### Java 11

First major post-Java-8 LTS.

Key changes:

- standard HTTP Client API
- launch single-file source-code programs
- Flight Recorder
- ZGC introduced as experimental
- TLS 1.3
- lambda parameter `var`
- Java EE and CORBA modules removed from the JDK
- Nashorn deprecated

Common library additions people use a lot:

- `String.isBlank`
- `String.lines`
- `String.repeat`
- `String.strip`, `stripLeading`, `stripTrailing`
- `Files.readString` and `Files.writeString`
- `Predicate.not`
- `Optional.isEmpty`

Why it matters:

- Java 11 is the first realistic migration target for many Java 8 systems.
- Removal of bundled Java EE/CORBA modules breaks older builds that expected JAXB, JAX-WS, and related APIs inside the JDK.

What to learn:

- HTTP client basics
- module removals and replacement dependencies
- new String and Files APIs

### Java 12

Key changes:

- switch expressions as preview
- Shenandoah GC as experimental
- JVM Constants API

Why it matters:

- started the language modernization path that later became standard.

What to learn:

- preview feature lifecycle in Java

### Java 13

Key changes:

- switch expressions second preview
- text blocks first preview
- dynamic CDS archives
- ZGC uncommit unused memory
- legacy socket API reimplemented

Why it matters:

- text blocks started here and became very important later.

What to learn:

- why text blocks reduce noisy string concatenation

### Java 14

Key changes:

- switch expressions became standard
- records first preview
- pattern matching for `instanceof` first preview
- text blocks second preview
- helpful NullPointerExceptions
- `jpackage` incubator
- CMS garbage collector removed
- Pack200 removed
- ZGC on macOS and Windows

Why it matters:

- modern Java syntax really started to feel different from Java 8 here.

What to learn:

- switch expressions with `yield`
- how helpful NPEs improve debugging

### Java 15

Key changes:

- text blocks became standard
- records second preview
- sealed classes first preview
- pattern matching for `instanceof` second preview
- hidden classes
- Nashorn removed
- biased locking disabled and deprecated
- ZGC became production-ready
- Shenandoah became production-ready

Why it matters:

- text blocks are now normal modern Java.
- sealed classes and records were clearly on the way to becoming mainstream.

What to learn:

- text blocks for SQL, JSON, XML, and templates
- hidden classes only at a conceptual level unless you build frameworks

### Java 16

Key changes:

- records became standard
- pattern matching for `instanceof` became standard
- sealed classes second preview
- strong encapsulation of JDK internals by default
- Unix-domain socket channels
- `jpackage` became standard
- Elastic Metaspace

Why it matters:

- records and `instanceof` pattern matching are core modern Java features.
- many older applications using internal JDK APIs started failing harder here.

What to learn:

- when a record is a good fit
- limitations of records
- how pattern matching removes manual casts

### Java 17

LTS release.

Key changes:

- sealed classes became standard
- pattern matching for `switch` first preview
- enhanced pseudo-random number generators
- macOS/AArch64 support
- strong encapsulation of JDK internals
- Security Manager deprecated for removal
- Applet API deprecated for removal
- RMI Activation removed
- Foreign Function and Memory API incubator
- Vector API second incubator

Why it matters:

- Java 17 became the main enterprise upgrade target after Java 11.
- `records + sealed classes + pattern matching` started forming a more expressive domain-modeling style.

What to learn:

- sealed hierarchies
- exhaustive switch thinking
- migration impact of internal API encapsulation

### Java 18

Key changes:

- UTF-8 became the default charset
- simple web server
- code snippets in Java API docs
- core reflection reimplemented with method handles
- pattern matching for `switch` second preview
- finalization deprecated for removal
- Foreign Function and Memory API second incubator

Why it matters:

- UTF-8 by default can change behavior in legacy systems that relied on platform default encodings.
- finalization deprecation is important for old cleanup patterns.

What to learn:

- why `finalize()` should be avoided
- charset assumptions in older applications

### Java 19

Key changes:

- virtual threads first preview
- structured concurrency incubator
- record patterns first preview
- pattern matching for `switch` third preview
- Foreign Function and Memory API preview
- Linux/RISC-V port

Why it matters:

- Project Loom became real for application developers.

What to learn:

- difference between platform threads and virtual threads
- why blocking code can become scalable again

### Java 20

Key changes:

- scoped values incubator
- record patterns second preview
- pattern matching for `switch` fourth preview
- virtual threads second preview
- structured concurrency second incubator
- Foreign Function and Memory API second preview

Why it matters:

- Java kept refining the Loom and Amber feature set before making it final.

What to learn:

- relationship between virtual threads, structured concurrency, and scoped values

### Java 21

LTS release.

Key changes:

- virtual threads became standard
- record patterns became standard
- pattern matching for `switch` became standard
- sequenced collections
- generational ZGC
- structured concurrency preview
- scoped values preview
- string templates preview
- unnamed patterns and variables preview
- unnamed classes and instance main methods preview
- Foreign Function and Memory API third preview
- Key Encapsulation Mechanism API
- prepare to disallow dynamic loading of agents

Why it matters:

- Java 21 is one of the most important releases since Java 8.
- virtual threads changed the concurrency conversation for server-side Java.

What to learn first in Java 21:

- virtual threads
- record patterns
- pattern matching in switch
- sequenced collections

### Java 22

Key changes:

- Foreign Function and Memory API became standard
- unnamed variables and patterns became standard
- class-file API preview
- launch multi-file source-code programs
- string templates second preview
- statements before `super(...)` preview
- stream gatherers preview
- implicitly declared classes and instance main methods second preview
- structured concurrency second preview
- scoped values second preview

Why it matters:

- FFM became production-grade, giving Java a modern alternative to JNI for many use cases.

What to learn:

- when to use FFM instead of JNI
- stream gatherers conceptually

### Java 23

Key changes:

- primitive types in patterns, `instanceof`, and `switch` first preview
- class-file API second preview
- Markdown documentation comments
- stream gatherers second preview
- module import declarations preview
- implicitly declared classes and instance main methods third preview
- flexible constructor bodies second preview
- scoped values third preview
- structured concurrency third preview
- ZGC generational mode by default
- deprecation of `sun.misc.Unsafe` memory-access methods for removal

Why it matters:

- language work continued toward simpler beginner syntax and stronger pattern matching.
- documentation comments became friendlier with Markdown.

What to learn:

- Markdown doc comments
- direction of primitive pattern matching

### Java 24

Key changes:

- class-file API became standard
- stream gatherers became standard
- Ahead-of-Time class loading and linking
- compact object headers experimental
- generational Shenandoah experimental
- module import declarations second preview
- primitive types in patterns second preview
- flexible constructor bodies third preview
- simple source files and instance main methods fourth preview
- structured concurrency fourth preview
- scoped values fourth preview
- synchronize virtual threads without pinning
- Security Manager permanently disabled
- Windows 32-bit x86 port removed

Why it matters:

- this release improved runtime startup and continued Loom and language polishing.
- permanent Security Manager disablement matters for very old enterprise security models.

What to learn:

- pinning in virtual threads
- why AOT class loading/linking helps startup

### Java 25

Latest LTS release. GA date: 2025-09-16.

Key changes:

- scoped values became standard
- Key Derivation Function API became standard
- module import declarations became standard
- compact source files and instance main methods became standard
- flexible constructor bodies became standard
- compact object headers became standard
- generational Shenandoah became standard
- structured concurrency fifth preview
- primitive types in patterns, `instanceof`, and `switch` third preview
- Stable Values preview
- PEM encodings of cryptographic objects preview
- JFR CPU-time profiling experimental
- JFR method timing and tracing
- JFR cooperative sampling
- Ahead-of-Time command-line ergonomics
- Ahead-of-Time method profiling
- 32-bit x86 port removed

Why it matters:

- Java 25 is now the latest LTS landing point.
- It finalizes several features that were previewed across Java 22 to 24.

What to learn first:

- scoped values
- finalized compact source files / instance main methods
- finalized module import declarations
- finalized flexible constructor bodies

## Language Feature Evolution You Should Remember

This is the easiest memory map from Java 8 to Java 25:

- Java 8: lambdas, streams, `Optional`, `java.time`
- Java 9: modules
- Java 10: `var`
- Java 14: switch expressions standard
- Java 15: text blocks standard
- Java 16: records and pattern matching for `instanceof`
- Java 17: sealed classes
- Java 21: record patterns, pattern matching for `switch`, virtual threads
- Java 22: unnamed variables and patterns, FFM standard
- Java 25: module imports, compact source files / instance main methods, flexible constructor bodies

## Most Important API and Platform Shifts

### 1. Modules

Understand this well, even if your team does not fully adopt JPMS.

Why:

- many migration issues come from stronger encapsulation
- internal JDK packages are no longer safe to depend on

### 2. HTTP Client

Use `java.net.http.HttpClient` instead of old low-level HTTP styles for many cases.

### 3. Records and Sealed Classes

These are central to modern domain modeling.

Use them when:

- your type is mostly immutable data
- you want clearer modeling of fixed hierarchies

### 4. Pattern Matching

This reduces noisy casts and `instanceof` checks.

It becomes especially useful with:

- records
- sealed hierarchies
- switch expressions

### 5. Virtual Threads

This is one of the biggest practical changes in modern Java.

Use them for:

- request-per-thread servers
- I/O-heavy applications
- simpler concurrency code

Be careful with:

- thread-local-heavy designs
- pinning scenarios
- CPU-bound work, where virtual threads do not create magical speedups

### 6. FFM API

The Foreign Function and Memory API is the modern path for native interop and off-heap memory work.

This matters most if you:

- integrate with C libraries
- used JNI
- need high-performance native interop

## Production Migration Risks from Java 8

If you move a Java 8 application forward, watch these carefully:

- internal JDK APIs are strongly encapsulated
- JAXB, JAX-WS, CORBA, and other Java EE pieces are no longer bundled in newer JDKs
- Nashorn is removed
- CMS is removed
- Security Manager is deprecated, then permanently disabled
- finalization is deprecated for removal
- default charset became UTF-8 in Java 18
- dynamic agent loading is being restricted
- 32-bit Windows and then broader 32-bit x86 support were removed

## Best Learning Order

If you already know Java 8 well, study in this order:

1. Java 9 modules at a practical level
2. Java 10 `var`
3. Java 11 HTTP client and key API additions
4. Java 14 and 15 switch expressions and text blocks
5. Java 16 and 17 records, pattern matching for `instanceof`, sealed classes
6. Java 21 virtual threads, record patterns, and switch pattern matching
7. Java 22 FFM and unnamed variables
8. Java 23 to 25 preview-to-standard evolution for scoped values, module imports, compact source files, and flexible constructors

## What Matters Most for Interviews

Usually high-value topics are:

- lambdas and streams
- `Optional`
- immutable design
- records vs classes
- sealed classes
- switch expressions
- pattern matching
- virtual threads
- differences between Java 8, 11, 17, 21, and 25
- module system basics

## What Matters Most for Real Projects

Usually high-value topics are:

- migration from Java 8 to 17 or 21
- dependency compatibility
- removed JDK modules
- internal API breakage
- GC choices
- observability with JFR
- concurrency design with virtual threads
- startup and packaging choices

## Must-Practice Code Examples

### `var`

```java
var users = List.of("A", "B", "C");
for (var user : users) {
    System.out.println(user);
}
```

### Switch expression

```java
String label = switch (status) {
    case 200, 201 -> "success";
    case 400 -> "bad request";
    default -> "other";
};
```

### Text block

```java
String json = """
    {
      "name": "ARES",
      "enabled": true
    }
    """;
```

### Record

```java
record User(String id, String name) {}
```

### Pattern matching for `instanceof`

```java
if (obj instanceof String s) {
    System.out.println(s.toUpperCase());
}
```

### Sealed class hierarchy

```java
sealed interface Result permits Success, Failure {}

record Success(String value) implements Result {}
record Failure(String error) implements Result {}
```

### Virtual threads

```java
try (var executor = java.util.concurrent.Executors.newVirtualThreadPerTaskExecutor()) {
    executor.submit(() -> fetchData());
}
```

## Recommended Upgrade Mindset

For most teams, the cleanest learning path is not:

- Java 8 -> every release in production

It is:

- understand 9 to 25 conceptually
- upgrade production in LTS steps
- usually target 17, 21, or 25 depending on ecosystem readiness

## Suggested Study Roadmap by Days

### Days 1 to 2

- Java 9 modules
- Java 10 `var`
- Java 11 HTTP client and String APIs

### Days 3 to 4

- switch expressions
- text blocks
- helpful NPEs

### Days 5 to 6

- records
- sealed classes
- pattern matching with `instanceof`
- pattern matching with `switch`

### Days 7 to 8

- virtual threads
- structured concurrency concepts
- scoped values concepts

### Days 9 to 10

- FFM API overview
- JFR overview
- migration pitfalls from Java 8
- Java 21 to 25 latest changes

## Short Summary

If you remember only one line:

Java after 8 became more expressive, more modular, more concurrent, and more strict about old unsupported internals.

The highest-value modern Java topics are:

- records
- sealed classes
- pattern matching
- text blocks
- virtual threads
- HTTP client
- modules
- migration changes around encapsulation and removed old platform features

## Official References

- Java 8 "What's New": https://www.oracle.com/java/technologies/javase/8-whats-new.html
- Java language changes summary through Java 25: https://docs.oracle.com/en/java/javase/25/language/java-language-changes-summary.html
- OpenJDK JDK release index: https://openjdk.org/projects/jdk/
- JDK 9: https://openjdk.org/projects/jdk9
- JDK 10: https://openjdk.org/projects/jdk/10/
- JDK 11: https://openjdk.org/projects/jdk/11/
- JDK 12: https://openjdk.org/projects/jdk/12/
- JDK 13: https://openjdk.org/projects/jdk/13/
- JDK 14: https://openjdk.org/projects/jdk/14
- JDK 15: https://openjdk.org/projects/jdk/15/
- JDK 16: https://openjdk.org/projects/jdk/16/
- JDK 17: https://openjdk.org/projects/jdk/17/
- JDK 18: https://openjdk.org/projects/jdk/18/
- JDK 19: https://openjdk.org/projects/jdk/19/
- JDK 20: https://openjdk.org/projects/jdk/20/
- JDK 21: https://openjdk.org/projects/jdk/21/
- JDK 22: https://openjdk.org/projects/jdk/22
- JDK 23: https://openjdk.org/projects/jdk/23/
- JDK 24: https://openjdk.org/projects/jdk/24/
- JDK 25: https://openjdk.org/projects/jdk/25/
