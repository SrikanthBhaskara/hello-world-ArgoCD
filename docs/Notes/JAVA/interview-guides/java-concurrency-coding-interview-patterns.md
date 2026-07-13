# Java Concurrency Coding Interview Patterns

## Purpose

This file is a complete concurrency revision note for Java interview preparation.

Use it for:
- multithreading coding rounds
- senior Java backend interviews
- thread-safety design discussions
- async execution and coordination questions
- converting theory into practical Java code

This note includes:
- concurrency fundamentals in interview language
- when to use each Java primitive
- common coding patterns
- sample Java templates
- typical interview questions and stronger answers
- mistakes to avoid

## 1. What Concurrency Usually Means in Interviews

Interviewers are not only testing whether you know APIs like `synchronized` or `ExecutorService`.

They usually want to know whether you can:
- identify shared mutable state
- prevent race conditions
- reason about visibility and ordering
- choose the right abstraction level
- avoid over-locking or unsafe concurrency
- explain tradeoffs between correctness, performance, and simplicity

## 2. What Interviewers Usually Evaluate

### Theory understanding
- race condition
- visibility
- atomicity
- ordering
- deadlock and contention
- blocking vs non-blocking thinking

### Practical Java knowledge
- `synchronized`
- `volatile`
- atomics
- `ReentrantLock`
- `ConcurrentHashMap`
- `BlockingQueue`
- `ExecutorService`
- `CompletableFuture`
- `CountDownLatch`, `Semaphore`, `CyclicBarrier`

### Senior-level signals
- can you reduce shared state instead of adding locks everywhere?
- can you choose between low-level and high-level primitives correctly?
- can you discuss contention, throughput, and safety together?
- can you explain when retry or async behavior becomes harmful?

## 3. First Questions To Ask Before Solving a Concurrency Problem

Before writing code, ask:
- is state shared across threads?
- is the problem coordination or parallel execution?
- is ordering required?
- can state be made immutable?
- do we need blocking semantics?
- what matters most: correctness, latency, throughput, or simplicity?

### Strong interview line
"I first try to classify whether the problem is shared-state synchronization, task orchestration, or message handoff, because the correct Java primitive depends on that."

## 4. Core Concurrency Concepts in Interview Language

### Race condition
A race condition happens when multiple threads access shared state and the final result depends on execution timing.

### Atomicity
An operation is atomic if it happens as one indivisible step from the perspective of other threads.

### Visibility
Visibility means whether one thread can see the latest updates made by another thread.

### Ordering
Even if two lines are written in one order, the runtime may reorder them unless proper synchronization guarantees are used.

### Contention
Contention happens when many threads compete for the same shared resource or lock.

### Deadlock
Deadlock happens when threads wait on each other in a cycle and none can proceed.

## 5. Java Memory Model Simplified

The Java Memory Model defines how threads see memory updates and when those updates become visible safely.

You do not need to give a textbook answer in most interviews.

A strong practical explanation is:
- without coordination, one thread may not see another thread's latest update in time
- instructions may be reordered in ways that break assumptions
- constructs like `volatile`, `synchronized`, locks, and thread lifecycle guarantees establish safe visibility and ordering

### Strong interview line
"I explain the Java Memory Model as the rulebook for safe visibility and ordering between threads."

## 6. When To Use `synchronized`

### Good fit
- small critical sections
- simple shared state protection
- monitor-based locking where simplicity matters

### Why interviewers still like it
It is built into the language, easy to reason about, and often cleaner than over-engineered alternatives.

### Example
```java
public class Counter {
    private int value;

    public synchronized void increment() {
        value++;
    }

    public synchronized int getValue() {
        return value;
    }
}
```

### Better answer
Use `synchronized` when the shared invariant is simple and a monitor lock keeps the design clear. Do not reject it just because other primitives exist.

## 7. When To Use `volatile`

### Good fit
- visibility of simple state flags
- one-writer or simple read-mostly signaling
- not for compound updates like increment

### Example
```java
public class Worker {
    private volatile boolean running = true;

    public void stop() {
        running = false;
    }

    public void run() {
        while (running) {
            // do work
        }
    }
}
```

### Important limitation
`volatile` does not make `count++` thread-safe because increment is read-modify-write, not one atomic step.

## 8. When To Use Atomics

### Good fit
- counters
- compare-and-set logic
- simple lock-free shared state

### Useful types
- `AtomicInteger`
- `AtomicLong`
- `AtomicReference`
- `LongAdder`

### Example
```java
public class AtomicCounter {
    private final AtomicInteger counter = new AtomicInteger();

    public int incrementAndGet() {
        return counter.incrementAndGet();
    }
}
```

### `AtomicInteger` vs `LongAdder`
- `AtomicInteger` is simple and exact for many cases
- `LongAdder` is often better under high write contention for counters

## 9. When To Use `ReentrantLock`

### Good fit
- explicit lock control
- try-lock behavior
- interruptible locking
- more advanced coordination than simple monitor use

### Example
```java
public class Wallet {
    private final ReentrantLock lock = new ReentrantLock();
    private int balance;

    public void deposit(int amount) {
        lock.lock();
        try {
            balance += amount;
        } finally {
            lock.unlock();
        }
    }
}
```

### Interview note
Use it when its features are needed, not by default. `synchronized` is often enough for simpler code.

## 10. Concurrent Collections

### `ConcurrentHashMap`
Use for shared key-value access with concurrent reads and writes.

### Example
```java
public class VisitCounter {
    private final ConcurrentHashMap<String, AtomicInteger> counts = new ConcurrentHashMap<>();

    public void record(String key) {
        counts.computeIfAbsent(key, k -> new AtomicInteger()).incrementAndGet();
    }
}
```

### Good interview line
"I prefer `ConcurrentHashMap` over synchronizing a plain `HashMap` when multiple threads need shared access and per-key updates are common."

### Other useful collections
- `CopyOnWriteArrayList` for read-heavy, write-light scenarios
- `ConcurrentLinkedQueue` for lock-free queueing
- `BlockingQueue` for producer-consumer flow

## 11. Producer-Consumer Pattern

### Problem shape
Some threads produce tasks and others consume them.

### Best Java tool
`BlockingQueue`

### Example
```java
import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.BlockingQueue;

public class ProducerConsumerExample {
    private final BlockingQueue<Integer> queue = new ArrayBlockingQueue<>(10);

    public void produce(int value) throws InterruptedException {
        queue.put(value);
    }

    public int consume() throws InterruptedException {
        return queue.take();
    }
}
```

### Why this is good
- safe handoff
- natural blocking semantics
- clearer than manual `wait/notify` in many interviews

## 12. Executor Pattern

### Problem shape
You need task execution, pooling, and lifecycle control.

### Best Java tool
`ExecutorService`

### Example
```java
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class ExecutorExample {
    private final ExecutorService executor = Executors.newFixedThreadPool(4);

    public void submitTask(Runnable task) {
        executor.submit(task);
    }
}
```

### Strong interview line
"If the problem is task execution rather than direct shared-state coordination, I prefer executors over creating raw threads manually."

## 13. CompletableFuture Pattern

### Problem shape
You need async composition and possibly parallel calls.

### Example
```java
import java.util.concurrent.CompletableFuture;

public class AsyncCompositionExample {
    public CompletableFuture<String> fetchCombined() {
        CompletableFuture<String> user = CompletableFuture.supplyAsync(() -> "user");
        CompletableFuture<String> profile = CompletableFuture.supplyAsync(() -> "profile");

        return user.thenCombine(profile, (u, p) -> u + "-" + p);
    }
}
```

### Good interview points
- use for async orchestration
- discuss exception handling with `handle`, `exceptionally`, or `whenComplete`
- avoid turning it into unreadable callback chains

## 14. Ordered Execution Pattern

### Problem shape
Tasks must run in a known order even across threads.

### Example using `CountDownLatch`
```java
import java.util.concurrent.CountDownLatch;

public class OrderedPrinter {
    private final CountDownLatch firstDone = new CountDownLatch(1);
    private final CountDownLatch secondDone = new CountDownLatch(1);

    public void first(Runnable printFirst) {
        printFirst.run();
        firstDone.countDown();
    }

    public void second(Runnable printSecond) throws InterruptedException {
        firstDone.await();
        printSecond.run();
        secondDone.countDown();
    }

    public void third(Runnable printThird) throws InterruptedException {
        secondDone.await();
        printThird.run();
    }
}
```

## 15. Coordination Primitives Summary

### `CountDownLatch`
Use for one-time waiting until one or more tasks complete.

### `CyclicBarrier`
Use when multiple threads must meet repeatedly at the same phase.

### `Semaphore`
Use to limit concurrency, such as allowing only N simultaneous accesses.

### `Phaser`
Useful for more flexible phase coordination.

## 16. Read-Mostly Data Pattern

### Good options
- immutable objects
- `ConcurrentHashMap`
- `CopyOnWriteArrayList` when writes are rare

### Strong interview line
"Often the best concurrency optimization is reducing mutation instead of adding more locks."

## 17. Thread-Safe Singleton

### Example
```java
public class Singleton {
    private static volatile Singleton instance;

    private Singleton() {
    }

    public static Singleton getInstance() {
        if (instance == null) {
            synchronized (Singleton.class) {
                if (instance == null) {
                    instance = new Singleton();
                }
            }
        }
        return instance;
    }
}
```

### Interview explanation
This is double-checked locking, and `volatile` is needed so partially initialized state is not observed incorrectly.

## 18. Rate Limiter With Concurrency Discussion

A concurrency interview may ask for a thread-safe rate limiter.

### What to discuss
- per-client shared state
- atomic update rules
- concurrent map storage
- time-window logic
- in-memory vs distributed implementation

### Better answer line
"I would keep the policy pluggable and then address thread safety around the shared state separately, because policy logic and synchronization concerns should not be mixed blindly."

## 19. Thread Pool Design Tradeoff Questions

Be ready for:
- fixed thread pool vs cached pool
- bounded queue vs unbounded queue
- CPU-bound vs IO-bound pool sizing
- rejection policy
- task backpressure

### Strong answer line
"Pool size depends on whether the workload is CPU-bound or waiting-heavy. I would avoid one default pool for every workload type."

## 20. Common Concurrency Interview Questions and Better Answers

### Question
When do you choose `synchronized` vs atomics?

### Better answer
I use atomics for simple independent state like counters or compare-and-set flows. If the logic protects a richer invariant across multiple fields or steps, `synchronized` or a lock is usually clearer.

### Question
When do you choose `ConcurrentHashMap`?

### Better answer
When multiple threads need shared key-value access and I want safe concurrent operations without serializing the entire map behind one external lock.

### Question
When is retry harmful in concurrent or async systems?

### Better answer
Retry is harmful when the failure is not transient, when the action is not idempotent, or when retry storms amplify dependency pressure.

### Question
Why not always use virtual threads?

### Better answer
Virtual threads help mainly for high-concurrency blocking workloads. They do not solve CPU saturation, poor synchronization, or database bottlenecks automatically.

## 21. Deadlock Awareness

### Causes to mention
- inconsistent lock ordering
- nested locking without discipline
- holding one lock while waiting for another resource

### Prevention
- keep lock ordering consistent
- reduce lock scope
- avoid blocking calls while holding locks when possible
- prefer higher-level concurrency abstractions where suitable

## 22. Mistakes That Hurt Concurrency Answers

- using `HashMap` with concurrent mutation
- using `volatile` where atomicity is required
- overusing low-level primitives when executors or queues are cleaner
- forgetting to shut down executors
- ignoring backpressure
- assuming thread safety automatically means good performance
- writing manual `wait/notify` without a good reason

## 23. Strong Senior-Level Phrases

- "I first ask whether shared mutable state can be reduced before choosing locks."
- "For simple counters atomics are enough, but they do not solve every coordination problem."
- "If the problem is really task orchestration, executors and futures are a better abstraction than raw threads."
- "Thread safety, ordering, and throughput are separate requirements, so I evaluate them independently."
- "I prefer a design that is safe and explainable under load, not only theoretically concurrent."

## 24. Practice Problems

Practice these aloud and in code:
1. thread-safe counter
2. producer-consumer queue
3. print in order across threads
4. thread-safe singleton
5. bounded task executor concept
6. concurrent rate limiter
7. async composition with `CompletableFuture`
8. cache with concurrent access

## 25. What To Pair This With

- [Java multithreading and concurrency interview guide](./java-multithreading-concurrency-interview-guide.md)
- [Java core internals interview questions](../runtime-internals/java-core-internals-interview-questions.md)
- [Java low-level design interview guide](./java-low-level-design-interview-guide.md)
- [Java senior production ownership and incident guide](./java-senior-production-ownership-and-incident-guide.md)

## 26. Final Revision Advice

A weak concurrency answer lists APIs.

A strong concurrency answer:
- identifies the shared-state problem clearly
- chooses the right abstraction level
- explains visibility, atomicity, or ordering only as needed
- writes code that is safe and readable
- mentions throughput, contention, or backpressure where relevant

That is what makes the answer feel senior and practical instead of theoretical.
