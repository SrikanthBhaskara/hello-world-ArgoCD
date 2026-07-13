# Java Core Internals Interview Questions

These questions focus on evergreen Java topics that sit beyond version-specific features. Use the `Short answer` for fast response and the `Better answer` when the interviewer wants more depth.

## JVM and Memory

### 1. What happens when you run a Java program?
Short answer:
Java source is compiled into bytecode, the JVM loads the classes, verifies the bytecode, and executes it.

Better answer:
The flow is source to bytecode through `javac`, then class loading, verification, linking, initialization, and execution inside the JVM. At runtime the JVM also manages memory, performs JIT optimizations, and runs garbage collection.

### 2. What is the difference between heap, stack, and metaspace?
Short answer:
Heap stores objects, stack stores method frames and local variables, and metaspace stores class metadata.

Better answer:
The heap is shared across threads and is where most objects live. Each thread has its own stack for method calls and locals. Metaspace stores class metadata and replaced PermGen in Java 8. This difference matters when debugging `OutOfMemoryError`, stack overflow, and classloader-heavy applications.

### 3. What is Metaspace and why did it replace PermGen?
Short answer:
Metaspace stores class metadata and replaced PermGen to improve metadata memory management.

Better answer:
PermGen was a fixed memory area that often caused tuning and class metadata issues. Java 8 replaced it with Metaspace, which is managed differently and uses native memory for class metadata. That changed old JVM tuning assumptions.

### 4. What is a memory leak in Java if garbage collection exists?
Short answer:
A memory leak in Java means objects are still reachable even though the application no longer needs them.

Better answer:
Garbage collection only removes unreachable objects. If code keeps references accidentally, such as through static caches, thread locals, listeners, or growing collections, those objects stay live and memory keeps growing. So GC does not eliminate memory leaks; it only eliminates unreachable garbage.

### 5. Why does `user = null` not guarantee immediate garbage collection?
Short answer:
Because removing a reference only makes the object eligible for collection; it does not force immediate GC.

Better answer:
The garbage collector runs when the JVM decides it is appropriate. Setting a reference to `null` may help make an object unreachable, but collection timing depends on runtime behavior and collector decisions.

## Class Loading

### 6. What is class loading in Java?
Short answer:
Class loading is the process where the JVM loads class definitions into memory before use.

Better answer:
The JVM loads classes when needed, verifies them, links them, and initializes them. This is more than just reading a `.class` file. It is part of the runtime safety and execution model of Java.

### 7. What is parent delegation in class loading?
Short answer:
It means a class loader usually asks its parent to load a class first.

Better answer:
Parent delegation helps avoid duplicate loading of core classes and improves security and consistency. It is especially important when explaining how application, platform, and bootstrap class loaders interact.

### 8. Where do classloader issues appear in real projects?
Short answer:
They often appear in containers, plugin systems, agents, and reflection-heavy frameworks.

Better answer:
Classloader issues show up when classes are loaded in isolated contexts, such as application servers, plugin architectures, instrumentation agents, or redeployable environments. They can lead to class conflicts, leaks, or confusing runtime behavior.

## Garbage Collection

### 9. What is garbage collection?
Short answer:
Garbage collection reclaims memory from objects that are no longer reachable.

Better answer:
Garbage collection is the JVM mechanism for reclaiming heap memory from unreachable objects. The important engineering question is not just that GC exists, but how pause times, allocation rate, and heap behavior affect the application.

### 10. What is the difference between minor GC and full GC?
Short answer:
Minor GC usually targets young objects, while full GC is heavier and can involve larger memory regions.

Better answer:
Minor GC is generally more frequent and focuses on short-lived objects. Full GC is usually more expensive and can have higher pause impact. Exact implementation details vary by collector, but this distinction is useful in production troubleshooting.

### 11. Why do Java applications still have performance problems if GC is automatic?
Short answer:
Because automatic memory management does not remove pause, allocation, retention, or tuning problems.

Better answer:
GC helps developers avoid manual memory free calls, but it does not eliminate object churn, leak-like retention, large heap pressure, or pause sensitivity. Allocation-heavy code and poor memory behavior can still affect latency and throughput.

### 12. What is the difference between G1 and low-pause collectors like ZGC conceptually?
Short answer:
G1 is a general-purpose modern collector, while ZGC focuses more strongly on low pause times for large heaps and latency-sensitive workloads.

Better answer:
G1 is a common enterprise default because it balances throughput and pause goals reasonably well. ZGC and similar low-pause collectors are more attractive when very large heaps or tighter latency requirements matter. The right choice depends on workload, not hype.

## Java Memory Model and Concurrency

### 13. What is the Java Memory Model?
Short answer:
It defines how threads interact through memory and what visibility and ordering guarantees exist.

Better answer:
The Java Memory Model explains when writes by one thread become visible to another, how instruction reordering is controlled, and what constructs such as `volatile`, `synchronized`, and thread start or join guarantee. It is foundational for correct concurrent code.

### 14. What problem does `volatile` solve?
Short answer:
`volatile` solves visibility problems for shared variables across threads.

Better answer:
`volatile` ensures that writes by one thread are visible to other threads reading the same variable and restricts some reordering behavior. It is useful for flags and simple state publication, but it does not make compound operations like `count++` atomic.

### 15. What does `synchronized` provide?
Short answer:
It provides mutual exclusion and visibility guarantees.

Better answer:
`synchronized` ensures only one thread at a time can enter a protected critical section for a given monitor, and it also establishes memory visibility when threads enter and exit synchronized code. It is a correctness-first tool for shared mutable state.

### 16. Why is `count++` not thread-safe?
Short answer:
Because it is a read-modify-write sequence, not a single atomic action.

Better answer:
`count++` involves reading the current value, computing the new value, and writing it back. If multiple threads do that simultaneously without coordination, updates can be lost. That is why atomics or locking are needed.

### 17. What is a race condition?
Short answer:
A race condition happens when correctness depends on the timing of concurrent execution.

Better answer:
If multiple threads access shared state and at least one thread modifies it without proper coordination, the final result may vary based on interleaving. Race conditions are dangerous because the code can appear to work until real concurrency or load exposes it.

### 18. What is deadlock?
Short answer:
Deadlock is when threads wait forever on each other and none can continue.

Better answer:
Deadlock usually happens when multiple locks are acquired in inconsistent order, such as thread A waiting for a lock held by thread B while thread B waits for a lock held by thread A. Avoiding it requires disciplined lock ordering and smaller shared critical sections.

### 19. What are atomic classes and when would you use them?
Short answer:
Atomic classes provide thread-safe atomic operations for simple shared values.

Better answer:
Classes like `AtomicInteger` and `AtomicReference` are useful when you need simple lock-free or low-lock state updates such as counters, flags, or compare-and-set patterns. They are not a full replacement for all synchronization.

### 20. What is happens-before?
Short answer:
It is the rule that tells us when one action is guaranteed to be visible to another action in concurrent Java.

Better answer:
Happens-before is the core correctness model for concurrency visibility and ordering in Java. For example, a write to a `volatile` variable happens-before a later read of that same variable, and unlocking a monitor happens-before a later lock of that monitor.

## Executors and Async

### 21. Why use `ExecutorService` instead of creating threads manually?
Short answer:
Because it separates task submission from thread management and supports reuse and control.

Better answer:
`ExecutorService` lets us manage concurrency in a structured way. It reuses threads, allows bounded execution models, supports shutdown control, and generally leads to cleaner and more scalable code than manually creating raw threads everywhere.

### 22. What should you think about when choosing thread-pool size?
Short answer:
Think about workload type, concurrency limits, queue behavior, and downstream bottlenecks.

Better answer:
For CPU-bound tasks, too many threads can create overhead without benefit. For IO-bound tasks, more concurrency may help, but only within system and dependency limits. Good thread-pool design also considers rejection policy, queue growth, and backpressure.

### 23. What is the difference between `Runnable` and `Callable`?
Short answer:
`Runnable` does not return a value, while `Callable` returns a value and can throw checked exceptions.

Better answer:
I use `Runnable` for fire-and-forget work and `Callable` when I need a result or checked-exception-aware task submission. This becomes especially relevant with futures and executor-based workflows.

### 24. What is the main value of `CompletableFuture`?
Short answer:
It helps compose asynchronous stages more cleanly.

Better answer:
`CompletableFuture` is valuable not just because it runs code asynchronously, but because it supports composition, combination, and centralized error handling for async workflows. It reduces callback-style nesting and makes dependent async logic easier to express.

### 25. Why can parallel streams be risky?
Short answer:
Because they use shared pool behavior and may not fit blocking or side-effect-heavy workloads.

Better answer:
Parallel streams can help in some CPU-oriented parallel operations, but they are not a default optimization. They use the common ForkJoinPool, so blocking tasks, poor partitioning, shared-state side effects, or small workloads can make them slower or harder to reason about.

## Collections, Generics, Reflection

### 26. How does `HashMap` work internally?
Short answer:
It computes a hash, chooses a bucket, handles collisions, and resizes when thresholds are crossed.

Better answer:
`HashMap` uses hashing to locate candidate buckets quickly, then compares keys within the bucket. Under heavy collision scenarios, bucket structures can move toward trees to improve worst-case lookup behavior. Good `hashCode()` and `equals()` implementations are essential for correctness and performance.

### 27. What is PECS in generics?
Short answer:
PECS means Producer Extends, Consumer Super.

Better answer:
If a structure produces values for you, `? extends` is usually appropriate. If you want to put values into it, `? super` is usually appropriate. This helps design flexible and type-safe generic APIs.

### 28. What is type erasure?
Short answer:
Type erasure means generic type information is mostly removed at runtime.

Better answer:
Java generics provide compile-time safety, but at runtime many generic type details are erased. This is why `List<String>` and `List<Integer>` are not fully distinct runtime types in the way some developers expect, and it explains some reflection and overloading limitations.

### 29. Why is reflection powerful but risky?
Short answer:
Reflection allows runtime inspection and invocation, but it reduces compile-time safety and can be slower or harder to maintain.

Better answer:
Reflection is heavily used by frameworks for dependency injection, proxies, serialization, and test tooling. But it comes with tradeoffs: less explicit code paths, more runtime errors, potential performance overhead, and stronger restrictions under newer JDK encapsulation rules.

### 30. Why is native Java serialization often discouraged?
Short answer:
Because it has security, compatibility, and maintainability risks.

Better answer:
Native serialization can be brittle across versions, hard to reason about, and risky from a security perspective. In distributed systems, explicit formats such as JSON, protobuf, or Avro are often safer and clearer.

## Production and Debugging

### 31. How do you start debugging a slow Java service?
Short answer:
First determine whether the issue is CPU, memory, GC, locks, or external dependency latency.

Better answer:
I avoid guessing at source code first. I look at CPU usage, heap behavior, GC pause patterns, thread states, external call latency, connection pool health, and recent config or deployment changes. The goal is to isolate whether the bottleneck is internal compute, memory pressure, lock contention, or dependency slowdown.

### 32. What is a thread dump used for?
Short answer:
A thread dump helps inspect running threads, blocked states, waits, and deadlocks.

Better answer:
Thread dumps are especially useful when an application appears stuck, slow, or deadlocked. They help identify threads waiting on locks, blocked pools, repeated stack traces, and contention hotspots.

### 33. What is a heap dump used for?
Short answer:
A heap dump helps inspect retained objects and memory growth suspects.

Better answer:
A heap dump is useful when diagnosing suspected leaks, unexpected memory growth, or very high heap usage. It helps identify which object graphs are retaining memory and whether caches, thread locals, or collections are the cause.

### 34. Why is strong Java knowledge more than syntax knowledge?
Short answer:
Because real systems fail at runtime, under concurrency, under load, and across environments.

Better answer:
Syntax helps write code, but runtime understanding helps explain behavior. Strong Java engineers understand memory, concurrency, GC, collections behavior, dependency interactions, and debugging workflows. That is what makes them reliable in production systems.

## Quick Revision

- JVM lifecycle
- heap, stack, metaspace
- class loading
- garbage collection
- Java Memory Model
- `volatile`
- `synchronized`
- atomics
- thread pools
- `CompletableFuture`
- `HashMap`
- generics and PECS
- reflection
- serialization cautions
- thread dump and heap dump usage
