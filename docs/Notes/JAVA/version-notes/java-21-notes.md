# Java 21 Notes

## Purpose

This file is a deeper study note for Java 21.

Use it for:

- interview preparation
- revision notes
- understanding what changed from Java 17 to Java 21
- migration planning for concurrency-heavy services
- learning the most important modern Java concurrency ideas

## Java 21 in One Line

Java 21 is the LTS where virtual threads made modern Java concurrency much simpler and more accessible.

## Release Identity

Java 21 is especially important because it combines:

- mature pattern matching
- better data destructuring
- a major concurrency shift through virtual threads

This is one of the most important Java releases since Java 8.

## Compared With Java 17

### Newly added

- virtual threads
- record patterns
- pattern matching for `switch`
- sequenced collections
- generational ZGC
- Key Encapsulation Mechanism API

Preview features in Java 21 that matter conceptually:

- structured concurrency
- scoped values
- string templates
- unnamed patterns and variables
- unnamed classes and instance main methods

### Removed, deprecated, or newly restricted

- dynamic loading of agents was prepared to be disallowed in the future
- older concurrency assumptions based only on expensive platform threads became less compelling, even though not removed

### Modified behavior and platform changes

- thread-per-request style becomes practical again for many I/O-heavy applications
- branching logic becomes cleaner with switch pattern matching
- destructuring-style matching becomes easier with record patterns
- ordered collections gain more explicit first, last, and reverse operations

## Most Important New Features

### Virtual threads

Old style:

```java
ExecutorService executor = Executors.newFixedThreadPool(100);
```

Java 21:

```java
try (var executor = java.util.concurrent.Executors.newVirtualThreadPerTaskExecutor()) {
    executor.submit(() -> callService());
}
```

Why it matters:

- much cheaper than platform threads
- excellent for I/O-heavy work
- simplifies concurrency design
- lets many blocking tasks scale better

What it changes conceptually:

- developers no longer need to think only in terms of "few expensive threads"
- traditional blocking code becomes viable at much larger concurrency levels

What it does not mean:

- CPU-bound code does not automatically become faster
- poor locking design is still poor locking design
- excessive shared-state problems do not disappear

What to learn deeply:

- platform thread vs virtual thread
- thread-per-task model
- scheduler behavior at a conceptual level
- blocking vs pinning

Pinning matters because:

- some operations can stop a virtual thread from unmounting efficiently
- synchronization choices can affect scalability

### Record patterns

Old style:

```java
if (obj instanceof Point p) {
    int x = p.x();
    int y = p.y();
    System.out.println(x + "," + y);
}
```

Java 21:

```java
if (obj instanceof Point(int x, int y)) {
    System.out.println(x + "," + y);
}
```

Why it matters:

- easier destructuring of data
- cleaner nested matching
- pairs well with records and sealed hierarchies

### Pattern matching for `switch`

Old style:

```java
if (value instanceof Integer i) {
    return "Integer: " + i;
} else if (value instanceof String s) {
    return "String: " + s;
}
return "Other";
```

Java 21:

```java
return switch (value) {
    case Integer i -> "Integer: " + i;
    case String s -> "String: " + s;
    case null -> "null";
    default -> "Other";
};
```

Why it matters:

- cleaner type-based branching
- less noisy than long `if-else` chains
- stronger match between code and domain modeling

This becomes especially strong with sealed classes:

- fewer impossible states
- more exhaustive branching style

### Sequenced collections

Why it matters:

- clearer ordered collection handling
- supports first, last, and reversed views more directly

Why you should care:

- Java had ordered collections before, but this makes order-aware APIs more explicit and uniform

## Most Important Conceptual Additions

### Structured concurrency

In Java 21 it was still preview, but conceptually important.

Why it matters:

- groups related concurrent tasks together
- makes cancellation and failure handling cleaner
- reflects the idea that child tasks belong to one operation scope

Why interviewers care:

- it shows you understand where Java concurrency is going beyond raw executors

### Scoped values

Also preview in Java 21, but important for understanding Java 25.

Why it matters:

- modern context propagation direction
- alternative to thread-local-heavy design in structured concurrent code

Why it is important even before Java 25:

- many teams exploring virtual threads also need cleaner context-sharing patterns

## Modified or Important Runtime Changes

### Concurrency model shift

Before Java 21:

- developers often chose between platform threads or reactive complexity

Java 21:

- virtual threads create a third path
- blocking style can remain readable and still scale much better

This is one of the biggest practical mindset changes in Java in years.

### Generational ZGC

Why it matters:

- improves a major low-latency garbage collector option
- relevant for high-scale services that care about pause behavior

## What To Learn Deeply

- virtual threads
- record patterns
- switch pattern matching
- sequenced collections
- structured concurrency concept
- scoped values concept
- pinning and synchronization caveats

## Interview Questions To Expect

- What are virtual threads?
- How are virtual threads different from platform threads?
- Are virtual threads always better?
- When should you not expect benefits from virtual threads?
- What are record patterns?
- Why is switch pattern matching useful?
- How do virtual threads compare to reactive programming?
- When would you choose Java 21 over Java 17?

## Migration Notes

If you move from Java 17 to Java 21:

- re-evaluate executor and threading design
- test framework compatibility with virtual threads
- check observability and tracing behavior under many lightweight threads
- revisit thread-local-heavy logic
- adopt switch pattern matching where it improves clarity

## Common Pitfalls

- assuming virtual threads are a magic performance fix
- forgetting that blocking external resources can still be bottlenecks
- ignoring thread-local and synchronization implications
- using advanced matching where simpler code is clearer

## Practice Topics

- rewrite a fixed thread pool example using virtual threads
- model a sealed hierarchy and branch on it with switch pattern matching
- destructure nested record data with record patterns
- compare a `ThreadLocal` idea to a scoped-values concept

## Deeper Virtual Thread Notes

### The important mindset shift

Before virtual threads, a common idea was:

- threads are expensive, so use fewer of them and multiplex work aggressively

With virtual threads, the idea becomes:

- threads are cheap enough that request-per-task style becomes practical again for many workloads

This is why Java 21 feels important in day-to-day backend design.

### Carrier threads and mounting conceptually

At a high level:

- virtual threads are scheduled onto platform threads
- the platform threads underneath are often called carrier threads

Why this matters:

- you still need real OS threads underneath
- virtual threads improve scalability by reducing the cost of representing blocked tasks

### Parking vs pinning

Parking is good:

- the virtual thread can yield efficiently while waiting

Pinning is a risk:

- the virtual thread cannot unmount as efficiently from the carrier thread

Why teams should care:

- some synchronization or native interactions can reduce the scalability advantage

### Virtual threads are best for I/O-heavy workloads

Good fit:

- REST calls
- database calls
- message-processing services
- request-per-task server logic

Less impressive fit:

- pure CPU-bound tasks
- tightly synchronized shared-state code

## Structured Concurrency and Scoped Values Together

These two ideas are related in practice.

Structured concurrency is about:

- grouping child tasks under one parent operation
- clearer cancellation and failure handling

Scoped values are about:

- propagating contextual data safely within that scoped execution model

Why this matters:

- Loom is not only about cheaper threads
- it is also about cleaner structure around concurrent work

## Deeper Notes on Pattern Matching

### Record patterns are more than syntax sugar

They matter because:

- they reduce repeated extraction code
- they let code express structure directly
- they align well with immutable, record-based modeling

### Switch pattern matching changes branching style

Before:

- type branching was often noisy, imperative, and repetitive

Now:

- branching can directly reflect domain structure

This becomes especially powerful with sealed hierarchies because the set of possible cases is more controlled.

## Real-World Adoption Checklist: Java 17 to Java 21

- validate framework support for virtual threads
- inspect thread-local usage patterns
- review connection pools and blocking-resource limits
- check monitoring and tracing behavior with many lightweight threads
- update coding guidelines for when to use virtual threads
- adopt pattern matching where it clarifies domain branching

## When Not to Reach for Virtual Threads

Avoid assuming they are the answer when:

- the workload is CPU-bound
- the bottleneck is database throughput, not thread count
- synchronization design is poor
- you have not measured before and after behavior

## Advanced Interview Angles

- Why are virtual threads a concurrency model shift, not just a performance tweak?
- What is pinning, and why can it matter?
- How do virtual threads compare with reactive programming conceptually?
- Why do record patterns and switch pattern matching fit well with sealed classes?

## Old Code Structure vs New Code Structure

### Request-processing structure

Old structure:

```java
ExecutorService executor = Executors.newFixedThreadPool(100);
for (Request request : requests) {
    executor.submit(() -> handle(request));
}
```

Java 21 structure:

```java
try (var executor = java.util.concurrent.Executors.newVirtualThreadPerTaskExecutor()) {
    for (Request request : requests) {
        executor.submit(() -> handle(request));
    }
}
```

### Type-branching structure

Old structure:

```java
if (value instanceof Integer i) {
    return "int " + i;
} else if (value instanceof String s) {
    return "string " + s;
}
return "other";
```

Java 21 structure:

```java
return switch (value) {
    case Integer i -> "int " + i;
    case String s -> "string " + s;
    case null -> "null";
    default -> "other";
};
```

### Record extraction structure

Old structure:

```java
if (obj instanceof Point p) {
    int x = p.x();
    int y = p.y();
    return x + "," + y;
}
```

Java 21 structure:

```java
if (obj instanceof Point(int x, int y)) {
    return x + "," + y;
}
```

## Short Summary

Java 21 is mainly about:

- modern concurrency
- better pattern matching
- better data destructuring
- cleaner ordered collection handling

## Official References

- JDK 21: https://openjdk.org/projects/jdk/21/
- Java language changes summary: https://docs.oracle.com/en/java/javase/25/language/java-language-changes-summary.html
