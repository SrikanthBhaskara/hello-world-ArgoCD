# Java 8 Corner Cases and Edge Cases — Theory, Practical, and Programmatic

This file collects the "gotcha" style Java 8 questions that companies use to separate candidates
who memorized syntax from candidates who actually understand behavior at the edges. Each item has
three layers:

- **Theory** — what the JLS / API contract actually says
- **Practical** — where this bites you in real production code
- **Programmatic** — runnable code showing the exact behavior, with output and explanation

Use this file after you are already comfortable with files 01–27 (concepts) and 28–33 (practice).
This file is about the exceptions to the rules, not the rules themselves.

---

## Section A — Streams Edge Cases

### A1. A stream can only be consumed once

**Theory:** A `Stream` is not a data structure — it is a one-time pipeline description. Once a
terminal operation runs, the stream is considered "closed" (`AbstractPipeline` sets a linked flag).
Any further terminal operation throws `IllegalStateException: stream has already been operated
upon or closed`.

**Practical:** Common bug when a stream is stored in a variable/field and reused across two
methods, or when debugging code calls `.count()` first "just to check" and then processes the
same stream.

**Programmatic:**
```java
Stream<Integer> nums = Stream.of(1, 2, 3);
System.out.println(nums.count()); // 3 — terminal op consumes it
System.out.println(nums.count()); // throws IllegalStateException
```
**Fix:** Build a `Supplier<Stream<T>>` and call `.get()` each time you need a fresh stream:
```java
Supplier<Stream<Integer>> supplier = () -> Stream.of(1, 2, 3);
System.out.println(supplier.get().count());
System.out.println(supplier.get().count()); // works, fresh stream
```

---

### A2. Infinite streams need a limit or short-circuit

**Theory:** `Stream.iterate` and `Stream.generate` produce infinite streams. Without a
short-circuiting operation (`limit`, `findFirst`, `anyMatch`, etc.) the pipeline never terminates.

**Practical:** A junior developer writes `Stream.iterate(1, n -> n + 1).forEach(...)` expecting it
to stop — it hangs the thread/process forever. This is a classic "predict the bug" interview
question.

**Programmatic:**
```java
// Hangs forever — no limit, forEach is not short-circuiting
Stream.iterate(1, n -> n + 1).forEach(System.out::println);

// Correct — bounded
Stream.iterate(1, n -> n + 1)
      .limit(5)
      .forEach(System.out::println); // 1 2 3 4 5
```

---

### A3. Stateful lambdas break in parallel streams

**Theory:** The Streams API assumes lambdas passed to `map`/`filter`/`forEach` are stateless and
non-interfering. If a lambda mutates shared external state, results become non-deterministic when
`.parallel()` is used because multiple threads race on that shared state.

**Practical:** Someone "optimizes" a sequential stream to parallel by adding `.parallel()` and the
totals become wrong under load — classic silent bug that will not show up in unit tests on small
data but shows up in production.

**Programmatic:**
```java
List<Integer> data = IntStream.rangeClosed(1, 10_000).boxed().toList();
int[] counter = {0};

data.parallelStream().forEach(x -> counter[0]++); // NOT thread-safe

System.out.println(counter[0]); // often NOT 10000 — race condition
```
**Fix:** Use a reduction/collector instead of external mutable state:
```java
long count = data.parallelStream().count(); // always correct, no shared state
```

---

### A4. `forEach` order is not guaranteed on unordered/parallel streams

**Theory:** `forEach` does not guarantee encounter order even on sequential streams from unordered
sources (e.g., `HashSet`), and never guarantees order on parallel streams. `forEachOrdered` forces
order but forfeits parallel speed-up.

**Programmatic:**
```java
Set<Integer> set = new HashSet<>(List.of(1, 2, 3, 4, 5));
set.stream().forEach(System.out::println);       // order not guaranteed
set.parallelStream().forEachOrdered(System.out::println); // guaranteed order, but slower
```

---

### A5. `Collectors.toMap` throws on duplicate keys

**Theory:** `toMap(keyMapper, valueMapper)` calls `Map.merge` internally without a merge function,
which throws `IllegalStateException: Duplicate key` the second time the same key appears.

**Practical:** Grouping a list of employees by department name assuming department names are
unique — until two departments happen to have the same display string, and the job crashes at
2 a.m. in production.

**Programmatic:**
```java
List<String> words = List.of("apple", "ant", "banana");

// Throws IllegalStateException: Duplicate key a (attempted merging values ant and apple)
Map<Character, String> byFirstLetter = words.stream()
    .collect(Collectors.toMap(w -> w.charAt(0), w -> w));

// Fix: supply a merge function
Map<Character, String> fixed = words.stream()
    .collect(Collectors.toMap(w -> w.charAt(0), w -> w, (a, b) -> a + "," + b));
// {a=apple,ant, b=banana}
```

---

### A6. `Collectors.groupingBy` throws NPE on null keys

**Theory:** `groupingBy` uses `HashMap` internally via `computeIfAbsent`/`merge`-style logic that
does not accept a `null` classifier result cleanly in all JDK versions the way `HashMap.put(null,
...)` does directly — the practical, testable fact is that a `null` key produced by the classifier
function causes a `NullPointerException` inside the collector pipeline.

**Programmatic:**
```java
List<String> data = new ArrayList<>(List.of("a", "b", null));

// Throws NullPointerException
Map<Integer, List<String>> byLength = data.stream()
    .collect(Collectors.groupingBy(s -> s == null ? null : s.length()));
```
**Fix:** Filter nulls first, or map null to a sentinel bucket:
```java
Map<Object, List<String>> safe = data.stream()
    .collect(Collectors.groupingBy(s -> s == null ? "NULL" : s.length()));
```

---

### A7. `IntStream.range` vs `rangeClosed` — off-by-one trap

**Theory:** `range(a, b)` is exclusive of `b`; `rangeClosed(a, b)` is inclusive.

**Programmatic:**
```java
IntStream.range(1, 5).forEach(System.out::print);        // 1234
IntStream.rangeClosed(1, 5).forEach(System.out::print);  // 12345
```
This single-character difference (`range` vs `rangeClosed`) is a favorite "spot the bug" screening
question.

---

### A8. Autoboxing NPE when unboxing a `null` from a stream of wrapper types

**Theory:** `Stream<Integer>` can legally contain `null`. Calling `.mapToInt(Integer::intValue)`
tries to unbox, throwing `NullPointerException`.

**Programmatic:**
```java
List<Integer> list = Arrays.asList(1, 2, null, 4);

int sum = list.stream().mapToInt(Integer::intValue).sum(); // NPE on the null element
```
**Fix:** Filter out nulls before mapping to primitive stream:
```java
int sum = list.stream()
    .filter(Objects::nonNull)
    .mapToInt(Integer::intValue)
    .sum(); // 7
```

---

### A9. `reduce` without identity returns `Optional`, and cannot be used on an empty stream to get a raw value

**Theory:** `reduce(BinaryOperator)` returns `Optional<T>` specifically because there may be no
elements to combine. `reduce(identity, BinaryOperator)` always returns `T` because `identity` is
the fallback.

**Programmatic:**
```java
Optional<Integer> maxNoIdentity = Stream.<Integer>of().reduce(Integer::max);
System.out.println(maxNoIdentity.isPresent()); // false, no NPE

int sumWithIdentity = Stream.<Integer>of().reduce(0, Integer::sum);
System.out.println(sumWithIdentity); // 0
```

---

## Section B — Optional Edge Cases

### B1. `Optional.of(null)` throws immediately; `Optional.ofNullable(null)` does not

**Theory:** `Optional.of` asserts non-null at creation time via `Objects.requireNonNull`.
`Optional.ofNullable` is the null-safe factory.

**Programmatic:**
```java
Optional.of(null);            // throws NullPointerException immediately
Optional.ofNullable(null);    // returns Optional.empty(), no exception
```

---

### B2. `orElse` always evaluates its argument; `orElseGet` only evaluates lazily

**Theory:** `orElse(T other)` evaluates `other` eagerly even when the Optional is present, because
Java evaluates method arguments before the call. `orElseGet(Supplier)` only invokes the supplier
when the value is absent.

**Practical:** A very common performance/side-effect bug — a "default" that calls a database or
logs a warning runs **every single time**, even when the value is present.

**Programmatic:**
```java
Optional<String> present = Optional.of("value");

present.orElse(sideEffect());   // sideEffect() runs even though present has a value!
present.orElseGet(() -> sideEffect()); // sideEffect() does NOT run

static String sideEffect() {
    System.out.println("computing expensive default...");
    return "default";
}
```

---

### B3. `Optional` is not `Serializable` and should never be a field type

**Theory:** `Optional` was designed as a return type to communicate "may be absent" to callers of
a method — it explicitly does not implement `Serializable`, and Brian Goetz (Java architect) has
stated it was never intended as a general-purpose "maybe" box for fields or method parameters.

**Practical:** Using `Optional<String> name` as an entity field breaks JPA/Hibernate and
serialization frameworks, and adds needless wrapper allocations. Interviewers ask this to check if
you know **API design intent**, not just API mechanics.

**Programmatic (anti-pattern to call out, not to write):**
```java
class User implements Serializable {
    private Optional<String> middleName; // BAD — will break serialization / ORM mapping
}
```
**Correct pattern:** keep the field as a nullable `String`, and only wrap it in `Optional` at the
boundary of a getter if you want callers to reason explicitly about absence.

---

### B4. Nested `Optional<Optional<T>>` from `map` vs `flatMap`

**Theory:** If the mapping function itself returns an `Optional`, `.map()` produces a nested
`Optional<Optional<T>>`. `.flatMap()` flattens it to a single level.

**Programmatic:**
```java
Optional<String> opt = Optional.of("42");

Optional<Optional<Integer>> nested = opt.map(s -> parseSafely(s)); // double-wrapped
Optional<Integer> flat = opt.flatMap(s -> parseSafely(s));         // single level

static Optional<Integer> parseSafely(String s) {
    try { return Optional.of(Integer.parseInt(s)); }
    catch (NumberFormatException e) { return Optional.empty(); }
}
```

---

## Section C — Lambda and Functional Interface Edge Cases

### C1. Lambdas capture effectively final variables — mutating after capture is a compile error

**Theory:** A local variable captured by a lambda must be final or "effectively final" (never
reassigned after initialization). This is enforced at compile time, unlike anonymous inner
classes accessing instance fields.

**Programmatic:**
```java
int counter = 0;
Runnable r = () -> System.out.println(counter); // fine, counter never reassigned
counter++; // compile error: "Variable used in lambda expression should be final or effectively final"
```
**Workaround for true mutable counters:** use an `AtomicInteger` or a single-element array.

---

### C2. `this` inside a lambda refers to the enclosing instance; inside an anonymous class it refers to the anonymous class itself

**Theory:** Lambdas do not create a new scope for `this` — they are lexically transparent.
Anonymous inner classes do create a new `this`.

**Programmatic:**
```java
class Demo {
    int value = 10;

    void run() {
        Runnable lambda = () -> System.out.println(this.value); // 10 — Demo's this
        Runnable anon = new Runnable() {
            int value = 99;
            public void run() {
                System.out.println(this.value); // 99 — anonymous class's own this
            }
        };
        lambda.run();
        anon.run();
    }
}
```

---

### C3. Checked exceptions cannot be thrown from standard functional interfaces

**Theory:** `Function<T,R>.apply`, `Consumer<T>.accept`, etc. do not declare `throws Exception` in
their signature, so a lambda body that calls a method throwing a checked exception will not
compile unless the exception is caught or wrapped.

**Programmatic:**
```java
List<String> paths = List.of("a.txt", "b.txt");

// Does NOT compile: IOException is checked, Function.apply() doesn't declare it
paths.forEach(p -> Files.readAllLines(Paths.get(p)));

// Fix 1: wrap in try/catch inside the lambda
paths.forEach(p -> {
    try {
        Files.readAllLines(Paths.get(p));
    } catch (IOException e) {
        throw new RuntimeException(e);
    }
});

// Fix 2: define a custom throwing functional interface
@FunctionalInterface
interface CheckedConsumer<T> {
    void accept(T t) throws Exception;
}
```

---

### C4. Ambiguous method references when overloads exist

**Theory:** A method reference like `String::valueOf` can be ambiguous to the compiler if the
target functional interface's parameter types match more than one overload, or if both a static
and instance version exist with compatible signatures.

**Programmatic:**
```java
// String has both static valueOf(Object) and valueOf(char[]) etc.
Function<Object, String> f = String::valueOf; // resolves, but pick the wrong overload
                                                 // in unclear contexts and you get a compile error:
                                                 // "reference to valueOf is ambiguous"
```
**Practical takeaway:** when a method reference is ambiguous or hard to read, prefer an explicit
lambda for clarity — this is also often the "correct" interview answer versus insisting on always
using `::`.

---

## Section D — Default Methods and Interface Edge Cases

### D1. Diamond problem — two default methods with the same signature must be resolved explicitly

**Theory:** If a class implements two interfaces that each declare a default method with the same
signature, the compiler forces an explicit override — Java will not guess which one to use.

**Programmatic:**
```java
interface A { default String hello() { return "A"; } }
interface B { default String hello() { return "B"; } }

// Compile error unless hello() is overridden explicitly
class C implements A, B {
    @Override
    public String hello() {
        return A.super.hello() + B.super.hello(); // must qualify with InterfaceName.super
    }
}
```

### D2. A class method always wins over a default interface method

**Theory:** "Class wins" rule — if a superclass provides a concrete method with the same
signature as an interface's default method, the class method always takes precedence,
regardless of interface declaration order.

**Programmatic:**
```java
class Parent { String hello() { return "Parent"; } }
interface Greeter { default String hello() { return "Greeter"; } }

class Child extends Parent implements Greeter { }

new Child().hello(); // "Parent" — class method wins, default method is ignored
```

---

## Section E — CompletableFuture Edge Cases

### E1. Exceptions inside `thenApply` are swallowed until you call `get`/`join`/`exceptionally`

**Theory:** `CompletableFuture` captures exceptions into the future's internal state rather than
throwing immediately. Nothing is printed to console and no thread dies — the exception surfaces
only when the future is joined/gotten, wrapped in `CompletionException` (for `join`) or
`ExecutionException` (for `get`).

**Programmatic:**
```java
CompletableFuture<Integer> future = CompletableFuture.supplyAsync(() -> 10 / 0);
// Nothing prints here — no crash, no visible error yet

future.join(); // throws java.util.concurrent.CompletionException: java.lang.ArithmeticException: / by zero
```
**Practical:** A silent failure in production — a background task "completes" but its result is
never consumed, so the `ArithmeticException` is lost forever unless `.exceptionally()` or
`.handle()` is attached.

---

### E2. `thenApply` vs `thenApplyAsync` — which thread runs the callback

**Theory:** `thenApply` runs on whichever thread completed the previous stage (could be the
calling thread if already complete, or the `ForkJoinPool.commonPool()` worker thread). `
thenApplyAsync` (no executor arg) always schedules on `ForkJoinPool.commonPool()`, and the
executor-arg overload runs on the provided `Executor`.

**Practical:** Using the common pool for blocking I/O inside `thenApplyAsync` starves other
parallel-stream and CompletableFuture work across the whole JVM, because they all share the same
default pool.

**Programmatic:**
```java
CompletableFuture.supplyAsync(() -> {
    System.out.println("supply: " + Thread.currentThread().getName());
    return 1;
}).thenApply(x -> {
    System.out.println("thenApply: " + Thread.currentThread().getName()); // may be same thread
    return x + 1;
}).thenApplyAsync(x -> {
    System.out.println("thenApplyAsync: " + Thread.currentThread().getName()); // commonPool thread
    return x + 1;
});
```

---

### E3. `allOf` returns `CompletableFuture<Void>` — you must re-read individual futures for results

**Theory:** `CompletableFuture.allOf(futures...)` only signals completion of all futures; it
discards their individual return values by design.

**Programmatic:**
```java
CompletableFuture<Integer> f1 = CompletableFuture.supplyAsync(() -> 1);
CompletableFuture<Integer> f2 = CompletableFuture.supplyAsync(() -> 2);

CompletableFuture<Void> all = CompletableFuture.allOf(f1, f2);
all.join();

// Must still call f1.join() / f2.join() to get the actual values
int sum = f1.join() + f2.join(); // 3
```

---

## Section F — Collection and Comparator Edge Cases

### F1. `ConcurrentModificationException` from modifying a collection during `forEach`

**Theory:** Both classic for-each and the Streams API `forEach` on most `Collection` sources
iterate using the collection's own iterator/spliterator, which fails fast if the backing
collection's modification count changes mid-iteration.

**Programmatic:**
```java
List<Integer> list = new ArrayList<>(List.of(1, 2, 3, 4));

list.forEach(n -> {
    if (n == 2) list.remove(Integer.valueOf(2)); // ConcurrentModificationException
});
```
**Fix:** use `removeIf`, or collect a separate list and remove after iterating:
```java
list.removeIf(n -> n == 2); // safe, purpose-built for this
```

---

### F2. Sorting with `Comparator` throws `NullPointerException` on null elements unless handled explicitly

**Theory:** `Comparator.naturalOrder()` and most user comparators call `.compareTo()` directly,
which throws NPE on a `null` element. Java 8 added `Comparator.nullsFirst`/`nullsLast` exactly to
solve this.

**Programmatic:**
```java
List<String> names = new ArrayList<>(Arrays.asList("Bob", null, "Alice"));

names.sort(Comparator.naturalOrder()); // throws NullPointerException

names.sort(Comparator.nullsFirst(Comparator.naturalOrder())); // [null, Alice, Bob]
```

---

### F3. `List.of(...)` (Java 9+ note) and `Arrays.asList(...)` produce fixed-size/immutable-ish lists — `add`/`remove` throw `UnsupportedOperationException`

**Theory:** `Arrays.asList` returns a fixed-size list backed by the array — `set` works but
`add`/`remove` throw `UnsupportedOperationException`. This is a Java 8-era trap that still shows
up constantly because `Arrays.asList` is used everywhere.

**Programmatic:**
```java
List<Integer> list = Arrays.asList(1, 2, 3);
list.set(0, 99);      // OK — [99, 2, 3]
list.add(4);           // throws UnsupportedOperationException
```
**Fix:** wrap in a real mutable list: `new ArrayList<>(Arrays.asList(1, 2, 3))`.

---

### F4. `Map.merge` and `computeIfAbsent` corner behavior with `null` return values

**Theory:** If the remapping function passed to `merge` returns `null`, the key is **removed**
from the map rather than mapped to `null`. Same idea applies to `compute`.

**Programmatic:**
```java
Map<String, Integer> map = new HashMap<>(Map.of("a", 1));

map.merge("a", 1, (oldV, newV) -> null); // returning null removes the "a" entry entirely
System.out.println(map.containsKey("a")); // false
```

---

## Section G — Date/Time API Edge Cases

### G1. `LocalDate.plusMonths` clamps to the last valid day instead of overflowing

**Theory:** Java 8's date/time API defines "smart" arithmetic — adding months to Jan 31 does not
overflow into March; it clamps to the last valid day of the resulting month.

**Programmatic:**
```java
LocalDate jan31 = LocalDate.of(2024, 1, 31);
LocalDate result = jan31.plusMonths(1);
System.out.println(result); // 2024-02-29 (leap year clamp), NOT 2024-03-02
```

### G2. All `java.time` types are immutable — reassignment is required, not mutation

**Theory:** Every operation (`plusDays`, `withYear`, etc.) returns a **new** instance. Forgetting
to capture the return value is a silent no-op bug, very similar to the classic `String` immutable
trap.

**Programmatic:**
```java
LocalDate date = LocalDate.of(2024, 1, 1);
date.plusDays(5);              // return value discarded — date is still 2024-01-01!
System.out.println(date);      // 2024-01-01 — NOT 2024-01-06

date = date.plusDays(5);       // correct — reassign
System.out.println(date);      // 2024-01-06
```

---

## Section H — Quick-Fire Theory Corner-Case Q&A (Spoken Answers)

**Q1: What happens if you call a stream's terminal operation twice?**
> "It throws `IllegalStateException` because a stream can only be traversed once. If I need to
> reuse the same source, I keep a `Supplier<Stream<T>>` and call `.get()` each time, or rebuild the
> stream from the original collection."

**Q2: Why does `Optional.of(null)` throw immediately instead of just creating an empty Optional?**
> "Because `Optional.of` is meant for callers who are certain a value is present — throwing at
> creation time makes the bug visible immediately at the source, rather than silently becoming an
> empty Optional and failing somewhere far downstream, which would be harder to debug."

**Q3: Why should you never use `Optional` as a class field or method parameter?**
> "`Optional` doesn't implement `Serializable`, adds allocation overhead, and was designed as a
> return type only — to tell the caller of a method that a result may be absent. Using it as a
> field breaks with ORMs like Hibernate and adds no real value over a nullable field with clear
> null-handling contracts."

**Q4: If two interfaces provide default methods with the same signature and a class implements
both without overriding, what happens?**
> "It's a compile-time error. Java will not pick one arbitrarily — the implementing class must
> override the method and can call a specific interface's version explicitly using
> `InterfaceName.super.methodName()`."

**Q5: Does `CompletableFuture` propagate exceptions like a normal method call?**
> "No — exceptions inside async stages are captured into the future's internal completion state.
> They only surface when you call `join()`/`get()` (wrapped in `CompletionException` or
> `ExecutionException`), or when you attach `.exceptionally()`/`.handle()`. If nothing ever reads
> the future's result, the exception is silently lost."

**Q6: What's wrong with `list.forEach(x -> list.remove(x))`?**
> "It throws `ConcurrentModificationException` because the fail-fast iterator backing `forEach`
> detects the list was structurally modified during iteration. The correct fix is
> `list.removeIf(condition)`, which is specifically designed for safe conditional removal."

**Q7: Why does sorting a list with nulls using `Comparator.naturalOrder()` fail?**
> "Because `naturalOrder()` calls `compareTo()` on the elements directly, and you can't call an
> instance method on `null`. Java 8 added `Comparator.nullsFirst()` / `nullsLast()` specifically
> to wrap another comparator and define where nulls should sort."

---

## Section I — Practical "Debug This Production Incident" Style Prompts

These are the format some companies use in on-site rounds: they give you a broken snippet and ask
you to find the bug **without running it**.

**Incident 1:** A nightly batch job silently produces wrong totals only when run on a multi-core
box, but is correct in the single-threaded dev environment.
> **Root cause to find:** external mutable state accumulated inside a `.parallelStream().forEach()`
> lambda (see Section A3). **Fix:** use a proper reduction/collector.

**Incident 2:** A REST endpoint that returns "default" values even for records that clearly exist
in the database, and profiling shows a mysterious extra DB call on every single request.
> **Root cause to find:** `Optional.orElse(fetchDefaultFromDb())` eagerly evaluating the fallback
> every time (see Section B2). **Fix:** switch to `orElseGet(() -> fetchDefaultFromDb())`.

**Incident 3:** A background task queue reports "0 failures" in monitoring, yet business data is
missing after an async pipeline step throws an exception internally.
> **Root cause to find:** `CompletableFuture` exception swallowed because nothing calls
> `.exceptionally()`/`.handle()` or checks `.join()` (see Section E1). **Fix:** add
> `.exceptionally(...)` and log/alert on it, or ensure the future is always joined and inspected.

**Incident 4:** A report generator throws `IllegalStateException: Duplicate key` in production
only once a month.
> **Root cause to find:** `Collectors.toMap` without a merge function, triggered only when two
> input rows share a key (rare data collision) (see Section A5). **Fix:** provide a merge function
> or switch to `groupingBy` if multiple values per key are actually valid.

---

## How to Use This File in an Interview

1. When asked "any tricky Java 8 gotchas you know?", pick 2–3 from this file that fit the role
   (e.g., CompletableFuture edge cases for backend/async-heavy roles, Stream/Optional edge cases
   for general backend roles).
2. Always answer in three parts out loud: **what happens → why it happens (spec/API reason) →
   how you'd prevent or fix it**. This structure is exactly what senior interviewers are scoring
   for.
3. If asked to write code live, prefer the "Incident" style prompts in Section I — they simulate
   what a real interviewer debugging round looks like.
