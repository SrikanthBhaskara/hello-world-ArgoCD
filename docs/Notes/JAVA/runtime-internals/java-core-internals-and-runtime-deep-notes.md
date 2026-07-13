# Java Core Internals and Runtime Deep Notes

These notes cover the Java topics that are important even when version-specific features change.

This file is meant to complement the Java 8, 11, 17, 21, and 25 notes. Those notes explain language and platform evolution. This file focuses on evergreen core Java knowledge used in interviews, debugging, and production systems.

## 1. Why These Topics Matter

Many Java notes focus on syntax and new JDK features, but real projects and strong interviews also expect understanding of:

- JVM architecture
- class loading
- heap, stack, and metaspace
- garbage collection basics
- Java Memory Model
- synchronization and concurrency primitives
- thread pools and task execution
- concurrent collections
- serialization and reflection basics
- production debugging mindset

These topics help you explain not just what Java code does, but why it behaves that way at runtime.

## 2. JVM Big Picture

Java source code is compiled into bytecode by `javac`. The JVM loads that bytecode, verifies it, and executes it.

High-level flow:

```text
.java source -> javac -> .class bytecode -> class loader -> JVM runtime -> execution
```

Main responsibilities of the JVM:

- load classes
- verify bytecode safety
- manage memory
- execute bytecode
- optimize execution through JIT compilation
- run garbage collection

Simple interview line:

Java is platform independent at the bytecode level, but the JVM implementation is platform specific for each operating system.

## 3. JDK vs JRE vs JVM

### JVM

The JVM is the runtime engine that executes Java bytecode.

### JRE

The JRE historically meant the JVM plus runtime libraries needed to run Java applications.

### JDK

The JDK includes the compiler and developer tools in addition to the runtime components.

Practical note:

In modern Java discussions, people usually talk in terms of JDK distributions rather than separately installing a JRE.

## 4. JVM Runtime Memory Areas

Important runtime memory areas:

- Heap
- Stack
- Metaspace
- PC register
- Native method stack

### Heap

The heap stores objects and arrays. It is shared across threads.

Example:

```java
User user = new User();
```

The reference may live on the stack, but the object itself is typically allocated on the heap.

### Stack

Each thread has its own stack. The stack stores method frames, local variables, partial results, and return information.

Example:

```java
public int add(int a, int b) {
    int sum = a + b;
    return sum;
}
```

Method arguments and local variables are stored in the stack frame for that call.

### Metaspace

Metaspace stores class metadata. It replaced PermGen in Java 8.

Why it matters:

- old PermGen tuning knowledge does not apply the same way after Java 8
- classloader-heavy applications can still have metadata-related memory problems

### Quick memory comparison

```text
Heap      -> objects
Stack     -> method calls and local variables
Metaspace -> class metadata
```

## 5. Stack vs Heap

### Stack characteristics

- thread-local
- method-call based
- very fast allocation and cleanup
- usually smaller than heap

### Heap characteristics

- shared across threads
- stores most object data
- managed by garbage collector
- larger and more dynamic

Common interview confusion:

Do not say primitives are always on the stack and objects are always on the heap as an absolute rule without context. At beginner level that simplification is common, but production-level reasoning should be more careful.

## 6. Class Loading

The JVM loads classes when they are needed.

Main class loader hierarchy in concept:

- Bootstrap ClassLoader
- Platform ClassLoader
- Application ClassLoader

### Bootstrap ClassLoader

Loads core JDK classes.

### Platform ClassLoader

Loads platform modules and supporting libraries.

### Application ClassLoader

Loads application classes from the classpath or module path.

### Parent delegation

When a class loader receives a request, it usually delegates to its parent first.

Why it matters:

- avoids duplicate core class loading
- improves security and consistency

Production relevance:

Classloader problems often appear in:

- application servers
- plugin systems
- agents and instrumentation
- frameworks doing reflection or dynamic loading

## 7. Class Loading Lifecycle

Simplified phases:

1. Loading
2. Linking
3. Initialization

### Linking includes:

- verification
- preparation
- resolution

Interview-ready summary:

The JVM does not just read a `.class` file and run it. It loads the class, verifies it, prepares memory structures, resolves references, and initializes static state before actual usage.

## 8. Object Creation Flow

When you write:

```java
User user = new User();
```

Conceptually this happens:

1. class is loaded if not already loaded
2. memory is allocated
3. fields get default values
4. constructor runs
5. reference is assigned

Why it matters:

This helps explain initialization order, static blocks, and object lifecycle behavior.

## 9. Garbage Collection Basics

Garbage collection removes objects that are no longer reachable.

Important point:

Java does not free memory immediately when an object becomes unused. Instead, the garbage collector reclaims unreachable objects later.

### Reachability idea

An object becomes eligible for GC when no live references can reach it.

Example:

```java
User user = new User();
user = null;
```

This does not guarantee immediate collection. It only removes one reference.

## 10. Generational GC Idea

Java garbage collection often follows the observation that many objects die young.

Common generational concept:

- young generation
- old generation

Young objects are collected more frequently. Long-lived objects may get promoted.

Why it matters:

This helps explain GC pauses, object churn, and why allocation-heavy code may behave differently under load.

## 11. Common GC Terms

### Minor GC

Usually targets the young generation.

### Major GC or Full GC

Usually heavier and may affect larger memory regions.

### Stop-the-world pause

Application threads pause while the collector performs certain work.

Interview line:

The real question is not whether GC exists, but how often it pauses, how long it pauses, and whether the application's allocation and latency profile match the collector.

## 12. Common Collectors in Modern Discussion

You do not need to memorize every collector deeply, but know the story:

- Serial GC
- Parallel GC
- G1 GC
- ZGC
- Shenandoah

### G1

General-purpose modern collector and common enterprise default for many environments.

### ZGC

Designed for low pause times and very large heaps.

### Shenandoah

Another low-pause collector option.

Important practical point:

Most developers should not tune GC blindly. First understand allocation rate, pause sensitivity, heap size, and real production metrics.

## 13. Common Memory Problems

### Memory leak in Java

In Java, a memory leak usually means objects are still reachable even though the application no longer needs them.

Common causes:

- static caches with no cleanup
- listeners not deregistered
- thread-local misuse
- large collections that keep growing
- classloader leaks in containers

### OutOfMemoryError

Common types:

- Java heap space
- Metaspace
- unable to create new native thread

### StackOverflowError

Often caused by deep or infinite recursion.

Example:

```java
void loop() {
    loop();
}
```

## 14. Java Memory Model

The Java Memory Model explains how threads interact through memory and what visibility guarantees exist.

Why it matters:

Without it, multithreaded programs can behave unexpectedly because one thread may not immediately see another thread's changes.

Key ideas:

- visibility
- ordering
- atomicity
- happens-before relationship

## 15. Visibility Problem

Example:

```java
class FlagHolder {
    boolean running = true;
}
```

One thread changes `running` to `false`, but another thread may continue reading stale cached values unless proper synchronization or `volatile` is used.

This is why thread safety is not only about race conditions. It is also about memory visibility.

## 16. `volatile`

`volatile` ensures visibility of changes across threads and restricts some instruction reordering behavior.

Example:

```java
class FlagHolder {
    volatile boolean running = true;
}
```

Good use cases:

- status flags
- simple publication state

Bad assumption:

`volatile` does not make compound actions atomic.

Example problem:

```java
count++;
```

This is not atomic just because `count` is `volatile`.

## 17. `synchronized`

`synchronized` provides mutual exclusion and visibility guarantees.

Example:

```java
public synchronized void increment() {
    count++;
}
```

What it gives:

- only one thread enters the critical section at a time for that monitor
- memory visibility when entering and leaving synchronized blocks

When it is useful:

- protecting shared mutable state
- simple correctness-first designs

Tradeoff:

Too much coarse-grained synchronization can reduce scalability.

## 18. Atomic Classes

Classes like these help with lock-free or low-lock atomic operations:

- `AtomicInteger`
- `AtomicLong`
- `AtomicReference`

Example:

```java
AtomicInteger counter = new AtomicInteger();
counter.incrementAndGet();
```

Why they matter:

For simple atomic state changes, they can be cleaner than manual locking.

## 19. Happens-Before

The happens-before relationship tells us when one action is guaranteed to be visible to another.

Important examples:

- unlock happens-before later lock on same monitor
- write to a `volatile` variable happens-before later read of that variable
- thread start and join create important ordering guarantees

Interview line:

Happens-before is the core rule that separates correct concurrent Java from code that only appears to work in testing.

## 20. Race Condition

A race condition happens when program correctness depends on timing or interleaving between threads.

Example:

```java
count++;
```

If multiple threads do this unsafely, updates may be lost.

## 21. Deadlock

Deadlock happens when two or more threads wait forever for each other.

Classic idea:

- thread A holds lock 1 and waits for lock 2
- thread B holds lock 2 and waits for lock 1

Avoidance strategies:

- consistent lock ordering
- smaller critical sections
- fewer shared locks

## 22. Thread Lifecycle Basics

A thread goes through conceptual states such as:

- new
- runnable
- running
- blocked or waiting
- terminated

You do not always need exact enum memorization in interviews, but you should understand the lifecycle flow.

## 23. Ways to Execute Work

Common choices:

- extend `Thread`
- implement `Runnable`
- use `Callable`
- use `ExecutorService`
- use `CompletableFuture`
- use virtual threads in modern Java

Practical guidance:

For real applications, prefer executors or higher-level concurrency APIs rather than manually creating raw threads everywhere.

## 24. `Runnable` vs `Callable`

### `Runnable`

- no return value
- cannot throw checked exceptions directly in method signature

### `Callable`

- returns a value
- can throw checked exceptions

Example:

```java
Callable<Integer> task = () -> 42;
```

## 25. `ExecutorService`

`ExecutorService` separates task submission from thread management.

Example:

```java
ExecutorService pool = Executors.newFixedThreadPool(10);
pool.submit(() -> process());
```

Why it matters:

- reuses threads
- limits concurrency
- provides lifecycle control

Common interview issue:

Do not create unbounded pools carelessly or forget shutdown behavior.

## 26. Thread Pools

Why thread pools exist:

- thread creation is expensive
- too many threads can hurt performance
- systems need bounded concurrency

Design questions:

- CPU-bound or IO-bound workload?
- how many tasks run concurrently?
- what happens when the queue fills?
- how is backpressure handled?

## 27. `CompletableFuture`

`CompletableFuture` is a higher-level API for asynchronous composition.

Useful methods:

- `thenApply`
- `thenCompose`
- `thenCombine`
- `exceptionally`
- `handle`

Key concept:

It is not just about running code later. It is about composing dependent async stages cleanly.

## 28. Concurrent Collections

Important examples:

- `ConcurrentHashMap`
- `CopyOnWriteArrayList`
- `BlockingQueue`

### `ConcurrentHashMap`

Useful for shared maps under concurrency.

### `CopyOnWriteArrayList`

Useful when reads are frequent and writes are rare.

### `BlockingQueue`

Useful for producer-consumer designs.

## 29. `ThreadLocal`

`ThreadLocal` stores data per thread.

Example use cases:

- request context
- correlation IDs
- non-thread-safe helper reuse in old designs

Risks:

- memory leaks in thread pools
- hidden coupling
- confusing context propagation

Modern caution:

Before adopting virtual threads or newer context models, audit heavy `ThreadLocal` usage carefully.

## 30. Fork/Join and Parallelism

The Fork/Join framework is designed for divide-and-conquer parallel tasks.

It is also relevant because parallel streams use the common ForkJoinPool by default.

Why this matters:

- parallel streams are not free
- blocking tasks inside common pools can cause surprises

## 31. Immutability and Thread Safety

Immutable objects are easier to reason about under concurrency because they cannot change after construction.

Benefits:

- safer sharing between threads
- fewer synchronization needs
- easier debugging

Examples:

- `String`
- records used as immutable DTO-style models

## 32. `equals()` and `hashCode()` Revisited

These are not only collection topics. They also affect correctness in caching, deduplication, and domain logic.

Contract reminder:

- if two objects are equal, they must have the same hash code
- if hash code is poor, performance may degrade

Production impact:

Bad `equals()` and `hashCode()` implementations can cause hard-to-debug map and set behavior.

## 33. `HashMap` Internal Story

High-level behavior:

1. compute hash
2. choose bucket
3. compare entries
4. handle collisions
5. resize when threshold exceeded

Modern note:

Under high collision conditions, buckets may transform from linked-list style structures into trees to reduce worst-case lookup cost.

## 34. Generics

Generics give compile-time type safety and reduce casting.

Example:

```java
List<String> names = new ArrayList<>();
```

Why they matter:

- fewer runtime type errors
- clearer API contracts
- better reuse

Important interview terms:

- type erasure
- bounded wildcards
- PECS idea

## 35. PECS

PECS means:

- Producer Extends
- Consumer Super

Example intuition:

- if a structure produces values for you, `? extends`
- if you put values into it, `? super`

This is a common mid-level interview concept.

## 36. Reflection

Reflection allows runtime inspection and invocation of classes, fields, methods, and constructors.

Why it matters:

- widely used by frameworks
- relevant for dependency injection, serialization, proxies, and testing tools

Tradeoffs:

- less compile-time safety
- more runtime overhead
- stronger encapsulation in newer JDKs affects reflective access

## 37. Serialization Basics

Serialization converts an object into a transferable or storable format.

Concepts to know:

- Java native serialization exists
- it is often avoided in modern distributed design
- JSON, protobuf, or Avro are more common for service communication

Why native serialization is often discouraged:

- security concerns
- fragile compatibility
- hidden behavior

## 38. Exception Design

Good exception handling is about clarity, not just catching everything.

Useful principles:

- catch exceptions where you can add meaning
- avoid swallowing exceptions
- preserve root cause when wrapping
- separate validation errors, business errors, and system failures

Bad example:

```java
catch (Exception e) {
    return null;
}
```

## 39. Resource Handling

Prefer `try-with-resources` for closable resources.

Example:

```java
try (BufferedReader reader = Files.newBufferedReader(path)) {
    return reader.readLine();
}
```

Why it matters:

- prevents leaks
- cleaner than manual `finally`

## 40. JIT and Performance Thinking

Java performance is not only about source code shape. The JVM also optimizes execution at runtime.

Important idea:

- hot code paths may be compiled and optimized

Practical caution:

Do not make strong performance assumptions from micro-style code appearance alone. Measure under realistic conditions.

## 41. Common Production Debugging Areas

When a Java service is slow or unstable, check:

- CPU saturation
- heap usage
- GC pauses
- thread states
- blocked or deadlocked threads
- database latency
- HTTP client timeouts
- connection pool exhaustion
- oversized payloads

Interview line:

Performance debugging in Java usually means separating whether the issue is CPU, memory, GC, lock contention, external dependency latency, or configuration.

## 42. Thread Dump and Heap Dump Awareness

You do not need every tool command memorized, but conceptually know:

- thread dump helps inspect thread states, deadlocks, waits, and lock contention
- heap dump helps inspect memory retention and leak suspects

Useful associated tools in discussion:

- JFR
- VisualVM
- JMC
- `jstack`
- `jmap`

## 43. Common Interview Traps

- saying `volatile` solves all concurrency issues
- confusing heap and stack
- saying GC immediately destroys objects
- treating `HashMap` as thread-safe
- using `parallelStream()` as a default optimization
- saying Java has no memory leaks because of GC
- confusing authentication with authorization in API code discussions

## 44. What To Learn Next After This File

After these topics, pair them with:

- version upgrade notes from Java 8 to 25
- Spring Boot and REST API design
- SQL and transaction behavior
- microservices observability
- testing and performance measurement

## 45. Quick Revision Checklist

- JVM overview
- heap vs stack vs metaspace
- class loading
- garbage collection basics
- memory leak vs OOME
- Java Memory Model
- `volatile`
- `synchronized`
- atomics
- race conditions and deadlocks
- thread pools
- `CompletableFuture`
- concurrent collections
- generics and PECS
- reflection
- serialization caution
- exception design
- runtime debugging mindset
