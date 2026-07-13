# Java 11 Notes

## Purpose

This file is a deeper study note for Java 11.

Use it for:

- interview preparation
- revision notes
- understanding what changed from Java 8 to Java 11
- migration planning for teams using Java 8 as a baseline
- understanding the first major post-Java-8 LTS release

## Java 11 in One Line

Java 11 is the first major Long-Term Support release after Java 8 and the bridge from legacy Java to modern Java.

## Why Java 11 Matters

Java 11 is important because it sits between old-world Java and modern Java.

It is where many teams first encountered:

- post-Java-8 release cadence
- module-era platform changes
- removed Java EE and CORBA modules
- standard HTTP client
- many small but high-value library improvements

Even if a team later moves to Java 17 or Java 21, Java 11 is often the first serious modernization step.

## Compared With Java 8

### Newly added

- standard HTTP Client API
- single-file source-code launch
- Flight Recorder
- TLS 1.3
- local variable syntax for lambda parameters with `var`
- `String.isBlank`
- `String.lines`
- `String.repeat`
- `String.strip`, `stripLeading`, `stripTrailing`
- `Files.readString`
- `Files.writeString`
- `Optional.isEmpty`
- `Predicate.not`

Also important features that arrived in the Java 9 to 11 era and matter by Java 11:

- module system
- `jshell`
- collection factory methods like `List.of`, `Set.of`, and `Map.of`
- Stream improvements like `takeWhile`, `dropWhile`, `iterate`, and `ofNullable`
- `Optional` improvements like `ifPresentOrElse`, `or`, and `stream`
- `var` for local variables

### Removed, deprecated, or strongly affected

- Java EE modules removed from the JDK
- CORBA modules removed from the JDK
- deployment stack components removed, including applet-related tooling from the modern JDK era
- Nashorn deprecated for removal
- internal JDK access became more problematic in the module era

### Modified behavior and platform changes

- Java moved to the modern 6-month release cadence
- modular platform boundaries affected old reflective and internal API access
- many common utility tasks became easier with built-in library methods
- the standard library became more competitive with common third-party helpers for basic tasks

## Most Important Platform Features

### Standard HTTP Client

```java
HttpClient client = HttpClient.newHttpClient();
HttpRequest request = HttpRequest.newBuilder()
    .uri(URI.create("https://example.com"))
    .build();
HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
```

Why it matters:

- standard HTTP support in the JDK became much cleaner
- supports HTTP/2
- supports both synchronous and asynchronous calls

Why teams care:

- reduces need for external HTTP client libraries in simpler use cases
- cleaner than older `HttpURLConnection`-style code

### Single-file source-code launch

Why it matters:

- quick experiments and tiny scripts became easier
- lowers friction for demos and simple tools

Example:

```powershell
java Hello.java
```

### Flight Recorder

Why it matters:

- production diagnostics became much more accessible
- useful for performance troubleshooting and runtime analysis

This is especially important for:

- latency issues
- CPU hotspots
- allocation behavior
- lock contention analysis

## Most Important Library Improvements

### String improvements

Important methods:

- `isBlank`
- `lines`
- `repeat`
- `strip`
- `stripLeading`
- `stripTrailing`

Why they matter:

- less hand-written string utility code
- better Unicode-aware trimming with `strip`

### Files improvements

Important methods:

- `Files.readString`
- `Files.writeString`

Why they matter:

- simpler file I/O for common cases

### Optional improvements

Important method:

- `Optional.isEmpty`

Why it matters:

- improves readability over negating `isPresent`

### Predicate helpers

Important method:

- `Predicate.not`

Why it matters:

- can make stream filters cleaner

## Important Carry-Over Features You Must Know by Java 11

Because Java 11 comes after 9 and 10, you should also understand these:

### Module system

Why it matters:

- it changed the platform architecture
- it introduced stronger boundaries around JDK internals

Concepts to know:

- classpath vs module-path
- `module-info.java`
- exported packages
- required modules

### `var`

```java
var list = List.of("a", "b");
```

Why it matters:

- local variable type inference became part of modern Java style

### Collection factory methods

```java
List<String> names = List.of("A", "B", "C");
```

Why they matter:

- concise immutable collection creation

### Stream and Optional enhancements

Why they matter:

- smoother collection pipelines
- easier optional handling

## Old Style vs Java 11 Style

### Old HTTP style vs Java 11 HTTP Client

Old:

- `HttpURLConnection`
- verbose setup
- less pleasant API

Java 11:

- `HttpClient`
- modern builder style
- easier sync and async handling

### Old string helpers vs Java 11 String methods

Old:

- custom utility methods
- manual blank checks
- manual repeat logic

Java 11:

- built-in methods like `isBlank`, `repeat`, and `lines`

### Old file reading helpers vs `Files.readString`

Old:

- boilerplate readers and buffers for simple file reads

Java 11:

- one-line common-case file reading and writing

## Big Migration Topic: Java EE and CORBA Removal

This is one of the biggest reasons Java 8 to 11 upgrades hurt.

Before Java 11:

- some applications assumed APIs like JAXB were available inside the JDK

In Java 11:

- those modules are no longer bundled in the JDK

What this means in practice:

- code may fail to compile
- runtime may fail because expected classes are missing
- build files often need explicit replacement dependencies

## Big Migration Topic: Module-Era Encapsulation

Even if you do not modularize your application, Java 11 still lives in the post-Java-9 platform world.

Why this matters:

- libraries that depended on internal JDK classes may fail
- reflective access behavior is more constrained

This is a major reason Java 8 to 11 migration is not just a syntax upgrade.

## Real-World Migration Checklist: Java 8 to Java 11

- upgrade the build toolchain
- identify use of JAXB, JAX-WS, and related Java EE modules
- replace removed JDK-provided APIs with explicit dependencies where needed
- search for internal API usage such as `sun.*`
- test reflective frameworks carefully
- modernize basic file, string, and HTTP code where it helps
- validate startup flags and old JVM assumptions

## When Java 11 Is the Right Target

Choose Java 11 when:

- the organization wants a conservative first upgrade from Java 8
- library support is strong for 11
- the team wants a stable LTS before moving farther

Choose a newer LTS instead when:

- the team specifically wants records, sealed classes, or virtual threads
- the ecosystem is already ready for 17 or 21

## Advanced Interview Angles

- Why is Java 11 considered a bridge release between Java 8 and modern Java?
- What made Java 8 to 11 migrations painful for many teams?
- Why is the Java 11 HTTP Client important?
- What changed with Java EE module availability?
- How is `strip` different in intent from older trimming approaches?

## Practice Topics

- replace `HttpURLConnection`-style code with `HttpClient`
- rewrite file reads using `Files.readString`
- identify where `List.of` and `Map.of` improve old code
- explain why JAXB-related code might break on Java 11
- compare Java 8 and Java 11 migration risks

## Old Code Structure vs New Code Structure

### HTTP structure

Old structure:

```java
URL url = new URL("https://example.com");
HttpURLConnection conn = (HttpURLConnection) url.openConnection();
conn.setRequestMethod("GET");
```

Java 11 structure:

```java
HttpClient client = HttpClient.newHttpClient();
HttpRequest request = HttpRequest.newBuilder()
    .uri(URI.create("https://example.com"))
    .build();
HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
```

### Immutable collection structure

Old structure:

```java
List<String> names = new ArrayList<>();
names.add("A");
names.add("B");
names = Collections.unmodifiableList(names);
```

Java 11 structure:

```java
List<String> names = List.of("A", "B");
```

### File I/O structure

Old structure:

```java
String content = new String(Files.readAllBytes(path), StandardCharsets.UTF_8);
```

Java 11 structure:

```java
String content = Files.readString(path);
```

## Short Summary

Java 11 is mainly about:

- first post-Java-8 LTS modernization
- HTTP client and library quality-of-life improvements
- module-era migration realities
- removal of bundled Java EE and CORBA pieces

## Official References

- JDK 11: https://openjdk.org/projects/jdk/11/
- Java language changes summary: https://docs.oracle.com/en/java/javase/25/language/java-language-changes-summary.html
