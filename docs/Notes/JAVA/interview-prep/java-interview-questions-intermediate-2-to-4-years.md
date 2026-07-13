# Java Interview Questions: Intermediate (2 to 4 Years)

## Focus Areas

- Java 8 to Java 17 modernization
- API design choices
- collections internals
- exceptions and transactions
- multithreading and async basics
- clean code and maintainability
- migration and framework-aware reasoning

## Collections and Internals

### 1. How does `HashMap` work internally?
Short answer:
`HashMap` uses hashing to place keys into buckets, handles collisions inside buckets, and resizes when the load threshold is crossed.

Better answer:
When a key is inserted, `HashMap` computes the hash, maps it to a bucket index, and stores the entry there. If multiple keys land in the same bucket, it handles collisions by comparing keys. As the map grows, it resizes and redistributes entries. In modern Java, very high-collision buckets can become tree-based to improve worst-case lookup behavior.

### 2. Difference between `HashMap`, `LinkedHashMap`, and `TreeMap`?
Short answer:
`HashMap` is unordered, `LinkedHashMap` preserves insertion order, and `TreeMap` keeps keys sorted.

Better answer:
I choose based on behavior, not habit. `HashMap` is the general-purpose option for fast lookup. `LinkedHashMap` is useful when predictable iteration order matters. `TreeMap` is useful when sorted-key traversal or range-style access is needed, though it has more overhead than hash-based maps.

### 3. When would you choose `ConcurrentHashMap`?
Short answer:
I use it when multiple threads need shared map access safely without synchronizing the entire map.

Better answer:
`ConcurrentHashMap` is a strong choice when many threads read and write shared data and I want better concurrency than a single synchronized block around a `HashMap`. It fits caches, registries, and shared coordination data, but I still think carefully about whether the shared mutable state itself is necessary.

### 4. Difference between `Comparable` and `Comparator`?
Short answer:
`Comparable` defines natural ordering inside the class, while `Comparator` defines external custom ordering.

Better answer:
I use `Comparable` when the object has one clear natural order, like sorting by ID or name as a default rule. I use `Comparator` when sorting may vary by use case, such as salary, department, or descending timestamp. `Comparator` is usually more flexible in real systems.

## Java 8 to Java 11 to Java 17 Progression

### 5. What changed significantly from Java 8 to Java 11?
Short answer:
Important changes include the standard HTTP client, Java EE module removal, module-era impact, and useful `String` and `Files` APIs.

Better answer:
Java 11 is the first practical post-Java-8 LTS for many teams. Beyond language syntax, it changed real migration behavior through bundled Java EE removals, stronger module-era expectations, and standard APIs like `HttpClient`, `Files.readString`, `String.isBlank`, and `Optional.isEmpty`. So the shift was as much about platform cleanup as new APIs.

### 6. What changed significantly from Java 11 to Java 17?
Short answer:
Java 17 brought records, sealed classes, switch expressions, text blocks, and stronger JDK encapsulation.

Better answer:
Java 17 made modern Java modeling much more practical. Records improved data-carrier code, sealed classes improved controlled hierarchies, text blocks improved multi-line string readability, and switch expressions improved branching clarity. It also continued the stricter platform direction, which matters for reflection-heavy or internal-API-dependent code.

### 7. Why do Java 8 or Java 11 applications fail after JDK upgrades even when business logic looks simple?
Short answer:
Because upgrade failures often come from dependencies, removed modules, reflective access, or runtime assumptions rather than business code.

Better answer:
The core business flow may still be valid, but the surrounding runtime environment changes. Older apps may depend on internal JDK APIs, removed bundled modules like JAXB, outdated libraries, old startup flags, or reflection that no longer works cleanly under newer encapsulation rules. That is why migration must audit the platform, not only the source code.

## Java 17 Design Questions

### 8. What is a record and when should you use it?
Short answer:
A record is a compact way to define an immutable data carrier with generated boilerplate like constructor, accessors, `equals`, `hashCode`, and `toString`.

Better answer:
I use records when the main purpose of the type is to carry data clearly and immutably, such as DTOs, API responses, or command-style request objects. Records reduce boilerplate and make intent obvious, but I use them where data semantics are the real goal rather than heavy mutation or framework-specific lifecycle behavior.

### 9. When should you avoid records?
Short answer:
Avoid them for mutable entities, JPA-heavy models, proxy-driven frameworks, or identity-rich objects with behavior-heavy semantics.

Better answer:
Records are great for transparent data holders, but they are not a universal replacement for classes. I avoid them when an object has complex lifecycle rules, mutability, framework proxy behavior, or business identity that should not be expressed as plain structural data equality.

### 10. What problem do sealed classes solve?
Short answer:
Sealed classes let you control which types are allowed to extend or implement a hierarchy.

Better answer:
They help model closed domains more safely. Instead of leaving inheritance open by default, I can explicitly define the permitted subtypes. That improves maintainability, reasoning, and pattern matching support because the hierarchy becomes intentional rather than accidental.

### 11. Difference between normal `switch` and switch expression?
Short answer:
A switch expression returns a value and is often cleaner and safer than traditional switch statements.

Better answer:
Traditional `switch` is statement-oriented and often relies on `break`, which is easy to misuse. Switch expressions are value-oriented, reduce fall-through mistakes, and improve readability for mapping logic. They make branching look more like an expression than a control-flow trap.

### 12. Why are text blocks useful in real projects?
Short answer:
They make multi-line strings like SQL, JSON, and XML much easier to read and maintain.

Better answer:
Text blocks reduce noisy escaping and string concatenation. In real code, that improves readability for SQL queries, JSON templates, XML payloads, and documentation-like output. They do not change architecture, but they make everyday maintenance significantly cleaner.

### 13. What does stronger encapsulation of JDK internals mean?
Short answer:
It means newer JDKs are stricter about access to internal JDK classes and unsupported reflective behavior.

Better answer:
Older code often accessed internal JDK APIs directly or indirectly through libraries. Newer Java versions increasingly enforce module boundaries and internal encapsulation, so unsupported reflective access can fail or require special handling. That matters a lot during upgrades because code that used to “just work” may no longer be legal or safe.

## Streams and Functional Design

### 14. When should you avoid using streams?
Short answer:
Avoid them when the logic becomes mutation-heavy, deeply branched, or less readable than a loop.

Better answer:
Streams are great for declarative data transformations, but not every loop becomes better as a stream. If the logic involves complex branching, side effects, debugging-heavy flow, or state mutation, a loop is often clearer. I optimize for readability and correctness first, not “stream usage”.

### 15. Difference between `thenApply()` and `thenCompose()` in `CompletableFuture`?
Short answer:
`thenApply()` transforms a result, while `thenCompose()` flattens nested async stages.

Better answer:
If I already have a value and want to transform it, I use `thenApply()`. If my next step itself returns another `CompletableFuture`, I use `thenCompose()` to avoid ending up with `CompletableFuture<CompletableFuture<T>>`. It is similar to `map` versus `flatMap` thinking.

### 16. Why are side effects inside streams risky?
Short answer:
They make stream pipelines harder to reason about, test, and parallelize safely.

Better answer:
Streams work best when each step is transformation-oriented. Side effects such as mutating shared state or depending on external changes make the code less predictable and more fragile. They are especially risky if someone later switches to parallel execution or assumes the pipeline is purely functional.

### 17. When are parallel streams useful and when are they risky?
Short answer:
They can help with CPU-friendly, independent operations on large enough datasets, but they are risky for blocking, small, or side-effect-heavy work.

Better answer:
Parallel streams are not a default optimization. They may help for computation-heavy independent work, but they use the common pool and can behave badly if the tasks block, mutate shared state, or have poor workload partitioning. I use them only after understanding the workload and measuring impact.

## Exceptions, Transactions, and APIs

### 18. How do you design a clean exception strategy in a service layer?
Short answer:
I separate validation, business, and infrastructure failures and avoid swallowing errors.

Better answer:
Good exception strategy means preserving meaning. Validation errors should clearly tell the caller what input is wrong. Business-rule violations should be distinguishable from technical failures. Infrastructure exceptions may need wrapping with domain context, but I preserve root cause so debugging stays possible. I also avoid throwing generic exceptions everywhere because they weaken API clarity.

### 19. How do checked vs unchecked exceptions affect API design?
Short answer:
Checked exceptions force callers to consider certain failures, while unchecked exceptions keep APIs lighter but require disciplined design.

Better answer:
Checked exceptions can make failure handling explicit, but overusing them can clutter APIs. Unchecked exceptions keep signatures cleaner and are often preferred for programming errors or many framework-level flows. The key is consistency: callers should be able to understand which failures are part of normal contract handling and which represent unexpected problems.

### 20. What makes a public API in Java easy to maintain?
Short answer:
Clear naming, stable contracts, immutability where useful, predictable null handling, and thoughtful exception behavior.

Better answer:
Maintainable APIs are easy to read, hard to misuse, and stable over time. That usually means strong names, minimal surprise, clear null and exception policies, backward-compatible changes where possible, and types that communicate intent well. I also prefer reducing unnecessary overloads and keeping contracts explicit rather than clever.

## Concurrency and Async

### 21. Difference between `ExecutorService` and `CompletableFuture`?
Short answer:
`ExecutorService` manages task execution resources, while `CompletableFuture` is a higher-level abstraction for async composition.

Better answer:
`ExecutorService` answers “where and how are tasks executed?” `CompletableFuture` answers “how do I model async flow and combine results?” In real systems, they often work together: the executor provides execution control, and the future API provides composition and error handling.

### 22. When would you use explicit thread pools instead of default async behavior?
Short answer:
I use explicit pools when I need control over concurrency, queueing, isolation, or workload type.

Better answer:
Default async behavior can be fine for simple cases, but production systems often need bounded concurrency, separate execution domains, or protection from blocking tasks affecting unrelated work. Explicit pools let me tune size, queueing, rejection handling, and workload isolation more intentionally.

### 23. What are common problems with thread-local-heavy code?
Short answer:
It can create hidden coupling, context propagation issues, and memory or cleanup problems in pooled-thread environments.

Better answer:
`ThreadLocal` can look convenient, but it often hides important data flow and becomes risky in thread pools if cleanup is inconsistent. It also complicates migration toward newer concurrency models because context tied too strongly to thread identity becomes harder to reason about and test.

## Real-World Code Structure Questions

### 24. Convert POJO-style DTO code to record style.
Short answer:
```java
record UserDto(String id, String name) {}
```

Better answer:
This is a good fit because the object is only carrying immutable data. Records reduce boilerplate and express that the type is a transparent data holder rather than a lifecycle-heavy object.

### 25. Replace if-cast style with pattern matching for `instanceof`.
Short answer:
```java
if (obj instanceof String s) {
    return s.toUpperCase();
}
```

Better answer:
Pattern matching removes the noisy separate cast and makes the condition and usable typed variable part of one readable step. It improves clarity without changing the business logic.

### 26. Replace `HttpURLConnection`-style logic with `HttpClient`.
Short answer:
Use the JDK `HttpClient` API with `HttpRequest` and `HttpResponse`.

Better answer:
```java
HttpClient client = HttpClient.newHttpClient();
HttpRequest request = HttpRequest.newBuilder()
        .uri(URI.create("https://example.com/api"))
        .GET()
        .build();
HttpResponse<String> response =
        client.send(request, HttpResponse.BodyHandlers.ofString());
```
This is cleaner, more modern, and easier to extend with timeouts, async flows, and better request construction than older low-level connection handling.

## Scenario Questions

### 27. Your Java 8 app uses JAXB and breaks on Java 11. What do you check first?
Short answer:
I first check whether the app depended on JAXB being bundled in the JDK and whether replacement dependencies were added explicitly.

Better answer:
Java 11 removed several Java EE-era modules from the JDK, including JAXB. So my first check is whether the build or runtime assumed those classes were still available by default. Then I verify dependency declarations, library compatibility, and whether any reflective or framework-level integration also needs updates.

### 28. Your team wants to adopt records. Where would you start safely?
Short answer:
I would start with DTOs, request or response models, and other obvious immutable data carriers.

Better answer:
I do not begin with entity or framework-sensitive models. The safest entry point is plain immutable data-transfer shapes where records add clarity without affecting persistence proxies, identity semantics, or lifecycle behavior. That gives fast wins with low migration risk.

### 29. A stream pipeline became unreadable. What would you refactor?
Short answer:
I would break the pipeline into named steps or replace it with a loop if the control flow is clearer that way.

Better answer:
I treat readability as the primary signal. If a stream contains too much branching, nested mapping, or hidden side effects, I either extract meaningful helper methods or move back to imperative code. Good refactoring keeps the intent obvious instead of preserving streams for style alone.

### 30. A service uses too many helper utilities for string or file operations. Which JDK features can replace them?
Short answer:
Useful replacements include `String.isBlank`, `strip`, `lines`, `repeat`, `Files.readString`, and `Files.writeString`.

Better answer:
One benefit of newer JDKs is that many small utility methods no longer need custom wrappers or third-party helpers. Modern `String`, `Files`, `Optional`, and HTTP APIs often reduce internal utility clutter and make the codebase simpler and easier to maintain.

## What to Revise Before Interview

- `HashMap` internals
- Java 8 to 17 changes
- records and sealed classes
- switch expressions
- `CompletableFuture`
- migration issues from older JDKs
- API design and readability tradeoffs
