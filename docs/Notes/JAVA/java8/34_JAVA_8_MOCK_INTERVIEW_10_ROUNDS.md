# Java 8 — 10 Mock Interview Rounds (1 Hour Each)
## Company-Style Tricky Questions with Follow-Up Answers

> **Format per round:** Theory (20 min) → Coding (30 min) → Design/Discussion (10 min)
> Each round targets a different company interview style and difficulty curve.
> Follow-up questions are listed directly after each answer — as real interviewers ask them.

---

## HOW TO USE THIS DOCUMENT

- Treat each round as a standalone 1-hour session
- Cover the Theory section first (spoken answers only)
- Code the problems on paper or IDE without looking at the solution
- Then check the follow-up questions — these are what interviewers ask AFTER your first answer
- Rounds 1–3: Entry/Mid level   |   Rounds 4–7: Senior level   |   Rounds 8–10: Principal / Architect

---

---

# ROUND 1 — Foundations Check (Mid-Level, 1 Hour)
## Style: Amazon Phone Screen

---

### THEORY SECTION — 20 minutes

---

**Q1. What is a lambda expression in Java 8? Why was it introduced?**

**Answer:**
A lambda expression is an anonymous function — it has parameters, a body, and a return type, but no name. It was introduced to enable functional programming style and to reduce boilerplate, especially for single-method interfaces like `Runnable`, `Comparator`, and `ActionListener`.

```java
// Before Java 8
Runnable r = new Runnable() {
    public void run() { System.out.println("Running"); }
};

// Java 8
Runnable r = () -> System.out.println("Running");
```

**Follow-Up 1:** "What is a functional interface? Can it have default methods?"
> Yes. A functional interface has exactly one abstract method. It can have any number of default and static methods. `@FunctionalInterface` annotation is optional but recommended — the compiler enforces the single-abstract-method contract if it is present.

**Follow-Up 2:** "Can a lambda capture a local variable? Under what condition?"
> Yes, but only if the variable is effectively final — its value never changes after assignment. The compiler will reject a lambda that captures a variable that is reassigned later.

**Follow-Up 3 (Tricky):** "What does `this` refer to inside a lambda vs inside an anonymous class?"
> Inside a lambda, `this` refers to the enclosing class instance — the lambda does not introduce a new scope. Inside an anonymous class, `this` refers to the anonymous class instance itself. This is one of the key behavioral differences.

---

**Q2. Explain `Predicate<T>`, `Function<T,R>`, `Consumer<T>`, and `Supplier<T>` — when would you use each?**

**Answer:**
| Interface | Signature | Use When |
|---|---|---|
| `Predicate<T>` | `boolean test(T t)` | Filter / validate data |
| `Function<T,R>` | `R apply(T t)` | Transform / map one type to another |
| `Consumer<T>` | `void accept(T t)` | Side effects — print, save, log |
| `Supplier<T>` | `T get()` | Lazy value generation, factory |

```java
Predicate<String> notBlank = s -> !s.isBlank();
Function<String, Integer> toLen = String::length;
Consumer<String> print = System.out::println;
Supplier<List<String>> newList = ArrayList::new;
```

**Follow-Up 1:** "What is `BiFunction`? Give an example."
> `BiFunction<T,U,R>` takes two arguments and returns a result: `R apply(T t, U u)`. Example: `BiFunction<String, Integer, String> repeat = (s, n) -> s.repeat(n);`

**Follow-Up 2 (Tricky):** "What is the difference between `Function.andThen()` and `Function.compose()`?"
> Both chain two functions. `andThen(g)` runs `f` first then `g`: `g(f(x))`. `compose(g)` runs `g` first then `f`: `f(g(x))`. The execution order is reversed.

---

**Q3. What is the difference between `map()` and `flatMap()` in streams?**

**Answer:**
- `map()` transforms each element one-to-one. The result is still one element per input.
- `flatMap()` transforms each element into a stream and flattens all those streams into one.

```java
// map: List<String> → List<Integer>
List<Integer> lengths = List.of("hello", "world").stream()
    .map(String::length)
    .collect(Collectors.toList());

// flatMap: List<List<Integer>> → List<Integer>
List<List<Integer>> nested = List.of(List.of(1,2), List.of(3,4));
List<Integer> flat = nested.stream()
    .flatMap(Collection::stream)
    .collect(Collectors.toList());
```

**Follow-Up 1 (Tricky):** "If `flatMap` receives a function that returns `null` instead of an empty stream, what happens?"
> A `NullPointerException` is thrown. You should return `Stream.empty()` instead of `null` when there is nothing to emit.

**Follow-Up 2:** "Can `flatMap` change the count of elements? Give an example."
> Yes. A list of 3 sentences flatMapped into words may produce 15 words. The count is not preserved — it depends on what each nested stream contains.

---

### CODING SECTION — 30 minutes

---

**Problem 1 (10 min): Given a list of names, return a sorted list of unique names that start with the letter "A" and have length > 4.**

```java
List<String> names = List.of("Alice", "Anna", "Bob", "Andrew", "Amy", "Albert", "Al");

List<String> result = names.stream()
    .filter(n -> n.startsWith("A"))
    .filter(n -> n.length() > 4)
    .distinct()
    .sorted()
    .collect(Collectors.toList());

// Output: [Albert, Alice, Andrew]
```

**Follow-Up:** "What if the list could contain nulls?"
```java
.filter(Objects::nonNull)
.filter(n -> n.startsWith("A"))
// ... rest of pipeline
```

---

**Problem 2 (10 min): Given a list of integers, compute the sum of squares of all odd numbers using streams.**

```java
List<Integer> nums = List.of(1, 2, 3, 4, 5, 6, 7);

int sumOfSquares = nums.stream()
    .filter(n -> n % 2 != 0)
    .mapToInt(n -> n * n)
    .sum();

// 1 + 9 + 25 + 49 = 84
```

**Follow-Up:** "Why did you use `mapToInt` instead of `map`?"
> `mapToInt` returns an `IntStream`, which has `sum()`, `average()`, `min()`, `max()` as terminal operations — no boxing/unboxing overhead. Using `map` would produce a `Stream<Integer>` requiring `reduce(0, Integer::sum)` instead.

---

**Problem 3 (10 min): Use `Optional` to safely get the first element of a list that is greater than 10, and return "NONE" if not found.**

```java
List<Integer> values = List.of(3, 7, 2, 15, 22);

String result = values.stream()
    .filter(v -> v > 10)
    .findFirst()
    .map(Object::toString)
    .orElse("NONE");

// Output: "15"
```

**Follow-Up (Tricky):** "What is the difference between `orElse("NONE")` and `orElseGet(() -> "NONE")`?"
> `orElse` always evaluates the argument — even if the Optional is present. `orElseGet` only calls the supplier if the Optional is empty. For expensive fallback operations (DB call, object creation), always use `orElseGet`.

---

### DESIGN / DISCUSSION — 10 minutes

**"You have a service that returns a list of user transactions. A user can have multiple transactions. Design a stream pipeline to compute total spend per user, sorted by spend descending."**

**Answer:**
```java
Map<String, Integer> spendByUser = transactions.stream()
    .collect(Collectors.groupingBy(
        Transaction::getUserId,
        Collectors.summingInt(Transaction::getAmount)
    ));

spendByUser.entrySet().stream()
    .sorted(Map.Entry.<String, Integer>comparingByValue().reversed())
    .forEach(e -> System.out.println(e.getKey() + " → " + e.getValue()));
```

**Follow-Up:** "What if you also need only users whose total spend exceeds $500?"
> Add `.filter(e -> e.getValue() > 500)` before the `forEach`.

---

---

# ROUND 2 — Streams Deep Dive (Mid-Level, 1 Hour)
## Style: Google Phone Screen

---

### THEORY SECTION — 20 minutes

---

**Q1. What is stream laziness and why does it matter?**

**Answer:**
Intermediate operations (`filter`, `map`, `sorted`, etc.) do not execute immediately when called — they build up a pipeline descriptor. Execution only begins when a terminal operation (`collect`, `forEach`, `findFirst`, etc.) is invoked.

This matters because:
1. Short-circuit operations can terminate early without processing the whole source
2. Fused pipelines process elements one-at-a-time through all stages rather than stage-by-stage — more cache-friendly
3. No unnecessary computation happens if you stop early (e.g., `findFirst` on a 1-million element stream)

```java
// This does NOT print anything — no terminal operation
Stream<String> s = names.stream().filter(n -> {
    System.out.println("filtering: " + n);
    return n.length() > 3;
});

// This triggers execution
s.findFirst(); // prints only until first match is found
```

**Follow-Up (Tricky):** "Can you reuse a stream after calling a terminal operation?"
> No. A stream is single-use. After a terminal operation, the stream is consumed and any further use throws `IllegalStateException`. You must create a new stream from the source.

**Follow-Up 2 (Tricky):** "Does `sorted()` break laziness?"
> Yes, partially. `sorted()` is a stateful intermediate operation — it must consume the entire stream before it can emit any element in order. It buffers all elements internally. Short-circuit operations after `sorted()` still benefit from laziness, but `sorted()` itself is a full-evaluation barrier.

---

**Q2. What are the short-circuit operations in streams?**

**Answer:**
Short-circuit operations can stop processing early:

| Operation | Short-circuits when... |
|---|---|
| `findFirst()` | first match found |
| `findAny()` | any match found (parallel-friendly) |
| `anyMatch()` | first `true` found |
| `allMatch()` | first `false` found |
| `noneMatch()` | first `true` found |
| `limit(n)` | n elements emitted |

```java
// This stops after finding the first number > 100
OptionalInt first = IntStream.range(1, 1_000_000)
    .filter(n -> n > 100)
    .findFirst();  // stops at 101, does not scan to 1 million
```

**Follow-Up (Tricky):** "`findFirst()` vs `findAny()` — when would you prefer `findAny()`?"
> In parallel streams, `findAny()` is faster because it doesn't have to coordinate which element was "first" across threads. For sequential streams, both return the same result. Use `findAny()` when you only care that something matched, not which specific element.

---

**Q3. Explain `Collectors.groupingBy()` with a downstream collector. What does it produce?**

**Answer:**
`groupingBy(classifier)` groups stream elements by the key returned from the classifier function, producing a `Map<K, List<V>>`. With a downstream collector you can further reduce each group.

```java
// Group employees by department, count each
Map<String, Long> countByDept = employees.stream()
    .collect(Collectors.groupingBy(
        Employee::getDepartment,
        Collectors.counting()
    ));

// Group by department, get average salary
Map<String, Double> avgSalary = employees.stream()
    .collect(Collectors.groupingBy(
        Employee::getDepartment,
        Collectors.averagingDouble(Employee::getSalary)
    ));
```

**Follow-Up (Tricky):** "What if you want a `Map<String, TreeSet<Employee>>` grouped by department, sorted by name?"
```java
Map<String, TreeSet<Employee>> result = employees.stream()
    .collect(Collectors.groupingBy(
        Employee::getDepartment,
        Collectors.toCollection(() -> new TreeSet<>(Comparator.comparing(Employee::getName)))
    ));
```

---

### CODING SECTION — 30 minutes

---

**Problem 1 (12 min): Given a list of sentences, return a frequency map of all words (lowercased), sorted by frequency descending.**

```java
List<String> sentences = List.of(
    "java is great",
    "java streams are powerful",
    "streams are great"
);

Map<String, Long> wordFreq = sentences.stream()
    .flatMap(s -> Arrays.stream(s.split(" ")))
    .map(String::toLowerCase)
    .collect(Collectors.groupingBy(
        Function.identity(),
        Collectors.counting()
    ));

wordFreq.entrySet().stream()
    .sorted(Map.Entry.<String, Long>comparingByValue().reversed())
    .forEach(e -> System.out.println(e.getKey() + ": " + e.getValue()));

// java: 2, streams: 2, are: 2, great: 2, is: 1, powerful: 1
```

**Follow-Up:** "How would you get only the top 3 most frequent words?"
> Add `.limit(3)` after `.sorted(...)` before `.forEach(...)`.

---

**Problem 2 (10 min): Given a list of employees, find the highest-paid employee in each department.**

```java
Map<String, Optional<Employee>> topPaid = employees.stream()
    .collect(Collectors.groupingBy(
        Employee::getDepartment,
        Collectors.maxBy(Comparator.comparingDouble(Employee::getSalary))
    ));

// To unwrap Optional:
Map<String, Employee> result = topPaid.entrySet().stream()
    .filter(e -> e.getValue().isPresent())
    .collect(Collectors.toMap(
        Map.Entry::getKey,
        e -> e.getValue().get()
    ));
```

**Follow-Up (Tricky):** "Why does `maxBy` return `Optional<Employee>` instead of `Employee`?"
> Because the group could be empty. Even though `groupingBy` only creates groups that have at least one element, the downstream collector must be safe in the general case. The `Optional` wrapper signals that a result may or may not be present.

---

**Problem 3 (8 min): Using streams, partition a list of integers into even and odd groups.**

```java
List<Integer> nums = List.of(1, 2, 3, 4, 5, 6, 7, 8);

Map<Boolean, List<Integer>> partitioned = nums.stream()
    .collect(Collectors.partitioningBy(n -> n % 2 == 0));

// partitioned.get(true)  → [2, 4, 6, 8]
// partitioned.get(false) → [1, 3, 5, 7]
```

**Follow-Up:** "What is the difference between `partitioningBy` and `groupingBy`?"
> `partitioningBy` always produces a `Map<Boolean, List<T>>` with exactly two keys (`true` and `false`). `groupingBy` produces a `Map<K, List<T>>` with as many keys as the classifier produces. Use `partitioningBy` when you have a yes/no condition.

---

### DESIGN / DISCUSSION — 10 minutes

**"Design a pipeline that reads a CSV file line by line, parses each line into a `Product` object, filters out products with price < 10, groups them by category, and writes the count per category to a report map."**

**Answer:**
```java
Map<String, Long> report;
try (Stream<String> lines = Files.lines(Paths.get("products.csv"))) {
    report = lines
        .skip(1)  // skip header
        .map(line -> line.split(","))
        .filter(cols -> Double.parseDouble(cols[2]) >= 10.0)
        .collect(Collectors.groupingBy(
            cols -> cols[1],    // category column
            Collectors.counting()
        ));
}
```

**Follow-Up:** "Why wrap with `try-with-resources`?"
> `Files.lines()` returns a stream backed by a file handle. Without closing it, the file descriptor leaks. Wrapping in try-with-resources ensures the stream (and the underlying file) is closed when the block exits, even if an exception occurs.

---

---

# ROUND 3 — Optional and CompletableFuture (Mid-Senior, 1 Hour)
## Style: Microsoft Technical Interview

---

### THEORY SECTION — 20 minutes

---

**Q1. What problem does `Optional` solve? What is the most common misuse?**

**Answer:**
`Optional<T>` was introduced to make the potential absence of a value explicit in an API contract. Instead of returning `null` (which callers may forget to check), returning `Optional<T>` forces the caller to acknowledge the possibility of no value.

**Most common misuses:**
1. Using `optional.get()` without checking `isPresent()` — defeats the purpose, throws `NoSuchElementException`
2. Using `optional.isPresent()` + `optional.get()` instead of `orElse` / `map` / `ifPresent`
3. Using `Optional` as a field in a class — it is not `Serializable`
4. Using `Optional` as a method parameter — caller can still pass `null` `Optional`, which is worse than just `null`

**Follow-Up (Tricky):** "What is the difference between `Optional.of()` and `Optional.ofNullable()`?"
> `Optional.of(value)` throws `NullPointerException` if the value is `null`. Use it only when you know the value is non-null. `Optional.ofNullable(value)` safely wraps `null` as `Optional.empty()`. In practice, `ofNullable` is the safer default when the value could be null.

**Follow-Up 2 (Tricky):** "`orElse(computeDefault())` — is this always safe?"
> No. `orElse` evaluates its argument eagerly regardless of whether the `Optional` is present. If `computeDefault()` has a side effect (DB call, object creation, logging), it executes even when not needed. Use `orElseGet(() -> computeDefault())` for lazy evaluation.

---

**Q2. What is `CompletableFuture`? How does it differ from `Future`?**

**Answer:**
`CompletableFuture<T>` is a promise-like abstraction for async computation. It differs from `Future` in key ways:

| Feature | `Future` | `CompletableFuture` |
|---|---|---|
| Blocking | `get()` blocks | Can chain without blocking |
| Chaining | Not possible | `thenApply`, `thenCompose`, `thenCombine` |
| Exception handling | Try-catch on `get()` | `exceptionally`, `handle` |
| Manual completion | Not possible | `complete(value)`, `completeExceptionally()` |
| Combining | Not possible | `allOf`, `anyOf` |

```java
CompletableFuture<String> future = CompletableFuture
    .supplyAsync(() -> fetchUser(id))          // async
    .thenApply(user -> user.getEmail())        // transform result
    .exceptionally(ex -> "default@email.com"); // fallback
```

**Follow-Up (Tricky):** "What is the difference between `thenApply` and `thenCompose`?"
> `thenApply` takes a `Function<T,U>` — applies a synchronous transform, wraps result in a new `CompletableFuture`. `thenCompose` takes a `Function<T, CompletableFuture<U>>` — used when the transform itself is async. `thenCompose` avoids nested `CompletableFuture<CompletableFuture<T>>`.

**Follow-Up 2:** "What thread executes `thenApply`?"
> If the `CompletableFuture` has already completed by the time `thenApply` is called, the callback runs on the calling thread. If not yet complete, it runs on the thread that completes the future. To guarantee a specific thread pool, use `thenApplyAsync(fn, executor)`.

---

**Q3. What is `thenCombine` vs `thenCompose`?**

**Answer:**
- `thenCombine(other, BiFunction)` — runs two independent futures in parallel and combines their results when both are done
- `thenCompose(Function → CF)` — chains dependent futures sequentially; the second future starts only after the first completes

```java
// thenCombine: parallel, independent
CompletableFuture<String> user = fetchUser(id);
CompletableFuture<String> prefs = fetchPrefs(id);
CompletableFuture<String> result = user.thenCombine(prefs,
    (u, p) -> u + " with prefs: " + p
);

// thenCompose: sequential, dependent
CompletableFuture<Order> order = fetchUser(id)
    .thenCompose(user -> fetchOrder(user.getOrderId()));
```

**Follow-Up:** "What is `CompletableFuture.allOf()`? Does it return the results?"
> `allOf(cf1, cf2, cf3)` returns a `CompletableFuture<Void>` that completes when all given futures complete. It does NOT return the results. You must query each individual future using `.join()` after `allOf().join()` to collect results.

---

### CODING SECTION — 30 minutes

---

**Problem 1 (10 min): Implement a method that takes a list of user IDs and fetches each user asynchronously, returning a `CompletableFuture<List<User>>`.**

```java
public CompletableFuture<List<User>> fetchAllUsers(List<Integer> ids) {
    List<CompletableFuture<User>> futures = ids.stream()
        .map(id -> CompletableFuture.supplyAsync(() -> fetchUser(id)))
        .collect(Collectors.toList());

    return CompletableFuture.allOf(futures.toArray(new CompletableFuture[0]))
        .thenApply(v -> futures.stream()
            .map(CompletableFuture::join)
            .collect(Collectors.toList())
        );
}
```

**Follow-Up (Tricky):** "What happens if one of the `fetchUser` calls fails?"
> `allOf` completes exceptionally if any future fails. The `.thenApply` won't execute. To handle partial failures, use `exceptionally` on each individual future to return a default value before combining them.

```java
.map(id -> CompletableFuture.supplyAsync(() -> fetchUser(id))
    .exceptionally(ex -> User.defaultUser(id)))
```

---

**Problem 2 (10 min): Build an `Optional` chain: given a `userId`, look up the user, get their address, get the city, return it uppercased — or return "UNKNOWN" if anything is missing.**

```java
String city = Optional.ofNullable(userId)
    .map(id -> userRepository.findById(id))     // Optional<User>
    .map(User::getAddress)                       // Optional<Address>
    .map(Address::getCity)                       // Optional<String>
    .map(String::toUpperCase)
    .orElse("UNKNOWN");
```

**Follow-Up (Tricky):** "What if `findById` itself returns an `Optional<User>` — what happens when you call `.map()` on it?"
> You'd get an `Optional<Optional<User>>` — double-wrapped. Use `.flatMap(id -> userRepository.findById(id))` to unwrap the inner `Optional` so you still have `Optional<User>`.

---

**Problem 3 (10 min): Handle a failed `CompletableFuture` gracefully — retry once on failure.**

```java
public CompletableFuture<String> fetchWithRetry(String url) {
    return CompletableFuture.supplyAsync(() -> callRemote(url))
        .exceptionally(ex -> {
            System.out.println("First attempt failed: " + ex.getMessage());
            return callRemote(url);  // retry once synchronously in fallback
        });
}
```

**Follow-Up:** "Is this a true async retry?"
> No. The `exceptionally` callback runs synchronously on the completion thread. For a true async retry you'd use `thenCompose` to chain another `supplyAsync`:

```java
.exceptionallyCompose(ex ->
    CompletableFuture.supplyAsync(() -> callRemote(url))
);
```
> `exceptionallyCompose` was added in Java 12. For Java 8, use `handle` + `thenCompose` pattern.

---

### DESIGN / DISCUSSION — 10 minutes

**"You need to call 3 external APIs — user service, product service, and pricing service — each taking ~300ms. How do you minimize total latency using CompletableFuture?"**

**Answer:**
Call all 3 in parallel using `thenCombine` or `allOf` rather than sequentially:

```java
CompletableFuture<User> userFuture = CompletableFuture.supplyAsync(() -> userService.get(id));
CompletableFuture<Product> productFuture = CompletableFuture.supplyAsync(() -> productService.get(id));
CompletableFuture<Price> priceFuture = CompletableFuture.supplyAsync(() -> pricingService.get(id));

CompletableFuture<Void> all = CompletableFuture.allOf(userFuture, productFuture, priceFuture);
all.join();

User u = userFuture.join();
Product p = productFuture.join();
Price pr = priceFuture.join();
// Total time: ~300ms instead of ~900ms
```

**Follow-Up:** "Which thread pool is used by default in `supplyAsync`?"
> The common `ForkJoinPool` (`ForkJoinPool.commonPool()`). For production services you should pass a dedicated `ExecutorService` to avoid starving other work on the common pool.

---

---

# ROUND 4 — Tricky Lambda and Method Reference (Senior, 1 Hour)
## Style: Amazon SDE-2 Onsite

---

### THEORY SECTION — 20 minutes

---

**Q1. What are the four types of method references? Give an example of each.**

**Answer:**
```java
// 1. Static method reference
Function<String, Integer> parse = Integer::parseInt;

// 2. Instance method reference on a specific instance
String prefix = "Hello";
Predicate<String> startsWith = prefix::startsWith;

// 3. Instance method reference on an arbitrary instance of a type
Function<String, String> upper = String::toUpperCase;
// equates to: s -> s.toUpperCase()

// 4. Constructor reference
Supplier<ArrayList<String>> listFactory = ArrayList::new;
```

**Follow-Up (Tricky):** "Type 2 vs Type 3 — the syntax looks the same (`ClassName::method`). How does the compiler know which is which?"
> For Type 3 (arbitrary instance), the first parameter of the target functional interface is the receiver object. For `String::toUpperCase`, the functional interface `Function<String, String>` takes a `String` as argument — the compiler infers the `String` IS the receiver. For Type 2, an actual object reference is used on the left side (`myInstance::method`), so no first-parameter ambiguity exists.

**Follow-Up 2 (Tricky):** "Can a method reference replace a lambda that throws a checked exception?"
> No, not directly. If the lambda body throws a checked exception, the functional interface must declare that exception in its `throws` clause. Standard functional interfaces like `Function` do not declare checked exceptions. You'd need a custom functional interface or a wrapper that converts checked exceptions to unchecked ones.

---

**Q2. What is variable capture in lambdas? What is "effectively final"?**

**Answer:**
A lambda can access local variables from the enclosing scope only if they are effectively final — the compiler verifies the variable is never reassigned after its initial assignment (whether or not `final` keyword is present).

```java
String prefix = "Hello";  // effectively final — never reassigned
List<String> result = names.stream()
    .filter(n -> n.startsWith(prefix))  // OK
    .collect(Collectors.toList());

// This fails:
int counter = 0;
names.forEach(n -> counter++);  // ERROR: counter is not effectively final
```

**Follow-Up (Tricky):** "Why does Java require captured variables to be effectively final?"
> Lambdas can execute on a different thread than the one that created them. If a local variable could change after capture, the lambda might see stale or inconsistent values. Making captured variables effectively final eliminates this data hazard without requiring synchronization. The captured variable is actually copied into the lambda instance.

**Follow-Up 2 (Tricky):** "Can a lambda modify a field of the enclosing class even if that field is mutable?"
> Yes. Fields are on the heap — they are accessible via the `this` reference (or the enclosing instance reference the lambda captures). The effectively-final restriction applies only to local variables on the stack.

---

**Q3. What is `Comparator.comparing()` and how do you chain multiple comparators?**

**Answer:**
`Comparator.comparing(keyExtractor)` creates a `Comparator` from a key function. You can chain with `thenComparing` for secondary sort keys.

```java
List<Employee> sorted = employees.stream()
    .sorted(
        Comparator.comparing(Employee::getDepartment)
            .thenComparing(Employee::getSalary, Comparator.reverseOrder())
            .thenComparing(Employee::getName)
    )
    .collect(Collectors.toList());
```

**Follow-Up (Tricky):** "What is `Comparator.naturalOrder()` vs `Comparator.reverseOrder()`? What if the elements are not `Comparable`?"
> `naturalOrder()` uses the element's own `compareTo()` — requires the element to implement `Comparable`. `reverseOrder()` reverses it. If the elements do not implement `Comparable`, you get a `ClassCastException` at runtime. You must provide an explicit `Comparator` via `comparing(keyExtractor, comparator)`.

---

### CODING SECTION — 30 minutes

---

**Problem 1 (12 min): Write a generic method using `Function<T,R>` chaining that: (a) parses a CSV row string into a `String[]`, (b) converts column 2 to `Integer`, (c) doubles it.**

```java
Function<String, String[]> parse = line -> line.split(",");
Function<String[], Integer> toInt = cols -> Integer.parseInt(cols[1].trim());
Function<Integer, Integer> doubled = n -> n * 2;

Function<String, Integer> pipeline = parse.andThen(toInt).andThen(doubled);

String row = "Alice,42,Engineering";
int result = pipeline.apply(row);  // 84
```

**Follow-Up:** "What happens if column 2 is not a number?"
> `NumberFormatException` is thrown unchecked. To make it safe, wrap with a try-catch inside the function or use a custom exception-safe function interface.

---

**Problem 2 (10 min): Implement a memoize utility using `HashMap.computeIfAbsent` that caches the result of a `Function<Integer, Integer>`.**

```java
public static <T, R> Function<T, R> memoize(Function<T, R> fn) {
    Map<T, R> cache = new HashMap<>();
    return key -> cache.computeIfAbsent(key, fn);
}

// Usage:
Function<Integer, Integer> slowSquare = n -> {
    // simulate slow computation
    return n * n;
};

Function<Integer, Integer> cachedSquare = memoize(slowSquare);
cachedSquare.apply(5);  // computed
cachedSquare.apply(5);  // from cache
```

**Follow-Up (Tricky):** "Is this thread-safe?"
> No. `HashMap` is not thread-safe. For a thread-safe version, use `ConcurrentHashMap`. `ConcurrentHashMap.computeIfAbsent` is atomic per key, which prevents duplicate computation for the same key under concurrent access.

---

**Problem 3 (8 min): Use `Predicate.and()`, `Predicate.or()`, `Predicate.negate()` to filter employees who are in Engineering OR earn more than 80k AND are NOT junior level.**

```java
Predicate<Employee> isEngineering = e -> "Engineering".equals(e.getDept());
Predicate<Employee> highEarner = e -> e.getSalary() > 80_000;
Predicate<Employee> isJunior = e -> "Junior".equals(e.getLevel());

Predicate<Employee> criteria = isEngineering
    .or(highEarner)
    .and(isJunior.negate());

List<Employee> filtered = employees.stream()
    .filter(criteria)
    .collect(Collectors.toList());
```

**Follow-Up:** "Does Java short-circuit `Predicate.and()` and `Predicate.or()`?"
> Yes. Just like `&&` and `||`, `and()` short-circuits if the left side is `false`, and `or()` short-circuits if the left side is `true`. The right-side predicate is not evaluated in those cases.

---

### DESIGN / DISCUSSION — 10 minutes

**"How would you use lambdas and method references to implement a simple event-dispatch system where handlers are registered for event types and dispatched by type?"**

**Answer:**
```java
Map<Class<?>, List<Consumer<Object>>> handlers = new HashMap<>();

public <T> void on(Class<T> type, Consumer<T> handler) {
    handlers.computeIfAbsent(type, k -> new ArrayList<>())
        .add(event -> handler.accept(type.cast(event)));
}

public void dispatch(Object event) {
    handlers.getOrDefault(event.getClass(), Collections.emptyList())
        .forEach(h -> h.accept(event));
}

// Register
on(LoginEvent.class, e -> System.out.println("Login: " + e.getUser()));

// Dispatch
dispatch(new LoginEvent("alice"));
```

---

---

# ROUND 5 — Date/Time API and Collectors (Senior, 1 Hour)
## Style: Netflix / Stripe Engineering

---

### THEORY SECTION — 20 minutes

---

**Q1. What are the problems with `java.util.Date` and `java.util.Calendar`? How does Java 8 fix them?**

**Answer:**
Problems with old API:
- `Date` is mutable — thread-unsafe, no defensive copy needed by contract
- Month in `Calendar` is 0-based (January = 0) — constant source of off-by-one bugs
- No clear separation between date, time, and timezone concepts
- No built-in formatting that's easy to use and thread-safe (`SimpleDateFormat` is not thread-safe)
- No concept of duration or period computation

Java 8 fixes:
- All new types (`LocalDate`, `LocalTime`, `LocalDateTime`, `ZonedDateTime`) are immutable and thread-safe
- Months are 1-based (`Month.JANUARY == 1`)
- Clear separation: `LocalDate` (date only), `LocalTime` (time only), `ZonedDateTime` (date + time + zone)
- `DateTimeFormatter` is immutable and thread-safe
- `Period` for date-based amounts, `Duration` for time-based amounts

**Follow-Up (Tricky):** "What is the difference between `Period` and `Duration`?"
> `Period` represents a date-based amount: years, months, days (e.g., `Period.of(1, 2, 3)` = 1 year, 2 months, 3 days). `Duration` represents a time-based amount in seconds and nanoseconds (e.g., `Duration.ofHours(5)`). You use `Period.between(date1, date2)` for calendar distance and `Duration.between(time1, time2)` for elapsed time in hours/minutes/seconds.

**Follow-Up 2:** "Is `LocalDateTime` timezone-aware?"
> No. `LocalDateTime` has no timezone. It represents date and time as seen on a wall clock — the same `LocalDateTime` can mean different instants depending on the timezone. Use `ZonedDateTime` or `OffsetDateTime` when timezone context is needed.

---

**Q2. What does `Collectors.toUnmodifiableList()` do vs `Collectors.toList()`?**

**Answer:**
- `toList()` returns a mutable list (typically `ArrayList`)
- `toUnmodifiableList()` (Java 10+) returns an unmodifiable list

For Java 8:
```java
// Equivalent to toUnmodifiableList() in Java 8:
.collect(Collectors.collectingAndThen(
    Collectors.toList(),
    Collections::unmodifiableList
))
```

`collectingAndThen` is a powerful pattern: it applies a finisher function to the result of another collector, useful for wrapping, sorting, or converting after collection.

**Follow-Up (Tricky):** "Can you create a `Collector` that collects to a `TreeMap` sorted by key?"
```java
.collect(Collectors.toMap(
    KeyExtractor::get,
    ValueExtractor::get,
    (v1, v2) -> v1,  // merge function for duplicate keys
    TreeMap::new     // map factory
))
```

---

### CODING SECTION — 30 minutes

---

**Problem 1 (12 min): Given a list of `LocalDate` order dates, group them by month-year and count orders per month.**

```java
List<LocalDate> dates = List.of(
    LocalDate.of(2024, 1, 5),
    LocalDate.of(2024, 1, 20),
    LocalDate.of(2024, 2, 10),
    LocalDate.of(2024, 3, 1)
);

Map<YearMonth, Long> byMonth = dates.stream()
    .collect(Collectors.groupingBy(
        d -> YearMonth.from(d),
        Collectors.counting()
    ));

// {2024-01=2, 2024-02=1, 2024-03=1}
```

**Follow-Up:** "How do you get orders in the last 30 days relative to today?"
```java
LocalDate cutoff = LocalDate.now().minusDays(30);
dates.stream()
    .filter(d -> d.isAfter(cutoff))
    .collect(Collectors.toList());
```

---

**Problem 2 (10 min): Build a custom `Collector` that joins strings with a separator only if there are more than one element.**

```java
// Using built-in for simplicity — but explain how custom works
Collector<String, ?, String> joinIfMultiple = Collectors.collectingAndThen(
    Collectors.toList(),
    list -> list.size() > 1 ? String.join(", ", list) : list.isEmpty() ? "" : list.get(0)
);

String result = List.of("Alice", "Bob", "Charlie").stream()
    .collect(joinIfMultiple);  // "Alice, Bob, Charlie"

String single = List.of("Alice").stream()
    .collect(joinIfMultiple);  // "Alice" (no separator added)
```

**Follow-Up:** "What are the four components of a custom `Collector`?"
> `supplier()` (creates mutable result container), `accumulator()` (adds element to container), `combiner()` (merges two containers in parallel), `finisher()` (converts container to final result). Optional `characteristics()` marks the collector as `UNORDERED`, `IDENTITY_FINISH`, or `CONCURRENT`.

---

**Problem 3 (8 min): Compute the number of days between two dates and check if a date falls on a weekend.**

```java
LocalDate start = LocalDate.of(2024, 3, 1);
LocalDate end = LocalDate.of(2024, 3, 31);

long days = ChronoUnit.DAYS.between(start, end);  // 30

boolean isWeekend = end.getDayOfWeek() == DayOfWeek.SATURDAY
    || end.getDayOfWeek() == DayOfWeek.SUNDAY;
```

**Follow-Up:** "How do you add 2 business days to a date (skip weekends)?"
```java
public LocalDate addBusinessDays(LocalDate date, int daysToAdd) {
    LocalDate result = date;
    int added = 0;
    while (added < daysToAdd) {
        result = result.plusDays(1);
        if (result.getDayOfWeek() != DayOfWeek.SATURDAY
            && result.getDayOfWeek() != DayOfWeek.SUNDAY) {
            added++;
        }
    }
    return result;
}
```

---

### DESIGN / DISCUSSION — 10 minutes

**"A report requires generating `LocalDateTime` timestamps for every midnight in a given month. How would you produce this list?"**

```java
LocalDate start = LocalDate.of(2024, 3, 1);
LocalDate end = start.withDayOfMonth(start.lengthOfMonth());

List<LocalDateTime> midnights = start.datesUntil(end.plusDays(1))
    .map(LocalDate::atStartOfDay)
    .collect(Collectors.toList());
// Java 9+ datesUntil

// Java 8 equivalent:
List<LocalDateTime> midnights = IntStream.rangeClosed(1, start.lengthOfMonth())
    .mapToObj(day -> LocalDate.of(2024, 3, day).atStartOfDay())
    .collect(Collectors.toList());
```

---

---

# ROUND 6 — Parallel Streams and Performance (Senior, 1 Hour)
## Style: LinkedIn / Uber Engineering

---

### THEORY SECTION — 20 minutes

---

**Q1. When should you use parallel streams? When should you avoid them?**

**Answer:**
**Use when:**
- Large dataset (rule of thumb: > 10,000 elements for simple operations)
- Computationally expensive per-element work (CPU-bound)
- Stateless, non-interfering operations
- Order of results does not matter (or you use `forEachOrdered`)

**Avoid when:**
- Small dataset — thread creation and merge overhead costs more than the work
- I/O-bound work — `ForkJoinPool` is not designed for blocking I/O; use `CompletableFuture` with a separate thread pool instead
- Operations that modify shared state — race conditions, corrupted results
- Ordered pipelines with `limit` or `findFirst` — `ORDERED` characteristic forces expensive coordination in parallel

```java
// BAD — shared mutable state
List<Integer> shared = new ArrayList<>();
nums.parallelStream().forEach(n -> shared.add(n));  // data corruption

// GOOD — use collect
List<Integer> result = nums.parallelStream()
    .filter(n -> n > 0)
    .collect(Collectors.toList());  // thread-safe
```

**Follow-Up (Tricky):** "Can the order of results from a parallel stream be guaranteed?"
> The encounter order is preserved only if the source has a defined order (e.g., `List`) AND no unordered operations are applied. For `collect(toList())`, the result list matches the source order even for parallel streams. But `forEach` with parallel streams is unordered — use `forEachOrdered` if you need ordering (at a performance cost).

---

**Q2. What thread pool does `parallelStream()` use? What is the risk?**

**Answer:**
By default, parallel streams use the `ForkJoinPool.commonPool()`, which is a shared JVM-wide thread pool. The number of threads defaults to `Runtime.getRuntime().availableProcessors() - 1`.

**Risk:** If multiple parts of your application (or multiple parallel stream operations) use the common pool simultaneously, they compete for the same threads. A long-running parallel stream can starve other tasks including critical infrastructure tasks running in the same pool.

**Solution:** Run the parallel stream inside a custom `ForkJoinPool`:
```java
ForkJoinPool customPool = new ForkJoinPool(4);
customPool.submit(() ->
    list.parallelStream()
        .filter(condition)
        .collect(Collectors.toList())
).get();
```

**Follow-Up:** "Is using a custom `ForkJoinPool` with parallel streams officially supported?"
> It works due to how `ForkJoinPool.submit` sets the current thread's pool context, but it is not officially documented behavior. For production, consider using `CompletableFuture.supplyAsync` with an explicit `ExecutorService` for more reliable control.

---

### CODING SECTION — 30 minutes

---

**Problem 1 (15 min): Compute the sum of prime numbers in range 1 to 100,000 using parallel stream. Show the sequential version for comparison.**

```java
public static boolean isPrime(int n) {
    if (n < 2) return false;
    for (int i = 2; i * i <= n; i++) {
        if (n % i == 0) return false;
    }
    return true;
}

// Sequential
long seqSum = IntStream.rangeClosed(1, 100_000)
    .filter(Main::isPrime)
    .asLongStream()
    .sum();

// Parallel
long parSum = IntStream.rangeClosed(1, 100_000)
    .parallel()
    .filter(Main::isPrime)
    .asLongStream()
    .sum();
```

**Follow-Up:** "Why use `asLongStream()` before `sum()`?"
> The sum of all primes up to 100,000 exceeds `Integer.MAX_VALUE`. Converting to `LongStream` prevents integer overflow.

---

**Problem 2 (15 min): Explain and demonstrate why this parallel reduce is WRONG:**

```java
// WRONG — order-dependent initial value causes incorrect results in parallel
List<Integer> nums = List.of(1, 2, 3, 4, 5);
int wrong = nums.parallelStream().reduce(10, Integer::sum);
// May produce: 10+10+10+... depending on partition count
```

**Fix:**
```java
// CORRECT — use 0 as identity (neutral element for +)
int correct = nums.parallelStream().reduce(0, Integer::sum);
// Result: 15

// OR use the 3-arg reduce:
int correct2 = nums.parallelStream()
    .reduce(0, Integer::sum, Integer::sum);
// 0 is identity, Integer::sum is accumulator, Integer::sum is combiner
```

**Follow-Up (Tricky):** "Why does the wrong version produce unpredictable results?"
> In parallel `reduce`, the identity value is applied to EACH partition (thread). With `reduce(10, sum)` on 4 threads, each thread starts with 10. After combining: 10 + (10+1+2) + (10+3+4) = 10+13+17+... ≠ 10+15. The identity must be neutral (0 for sum, 1 for product) for parallel correctness.

---

### DESIGN / DISCUSSION — 10 minutes

**"A batch job needs to process 1 million records, each requiring a 50ms database lookup. How would you design this with Java 8 concurrency features?"**

**Answer:**
Parallel streams are wrong here (I/O-bound, common pool starvation risk).

Use `CompletableFuture` with a dedicated thread pool:
```java
ExecutorService pool = Executors.newFixedThreadPool(50);

List<CompletableFuture<ProcessedRecord>> futures = records.stream()
    .map(r -> CompletableFuture.supplyAsync(() -> process(r), pool))
    .collect(Collectors.toList());

List<ProcessedRecord> results = CompletableFuture.allOf(
    futures.toArray(new CompletableFuture[0])
).thenApply(v -> futures.stream()
    .map(CompletableFuture::join)
    .collect(Collectors.toList())
).join();

pool.shutdown();
```

**Follow-Up:** "How do you choose the thread pool size?"
> For I/O-bound: `threadPoolSize = N_CPU * (1 + wait_time / compute_time)`. With 50ms wait and 1ms compute per record, ratio ≈ 50, so `threadPoolSize ≈ N_CPU * 51`. Cap based on DB connection pool size to avoid overwhelming the DB.

---

---

# ROUND 7 — Advanced Tricky Company Questions (Senior+, 1 Hour)
## Style: Google SDE-3 / Facebook E5 Onsite

---

### THEORY SECTION — 20 minutes

---

**Q1 (TRICKY). What is the difference between `Stream.iterate()` and `Stream.generate()`?**

**Answer:**
- `Stream.iterate(seed, UnaryOperator)` — produces an infinite sequential ordered stream by repeatedly applying a function to the previous element. Each element depends on the prior one.
- `Stream.generate(Supplier)` — produces an infinite sequential unordered stream by calling the supplier repeatedly. Elements are independent.

```java
// iterate: 0, 2, 4, 6, 8, ...
Stream.iterate(0, n -> n + 2).limit(5).forEach(System.out::println);

// generate: random UUIDs
Stream.generate(UUID::randomUUID).limit(3).forEach(System.out::println);

// Java 9+ iterate with predicate (takeWhile equivalent)
Stream.iterate(0, n -> n < 100, n -> n + 2);
```

**Follow-Up (Tricky):** "Are these streams lazy?"
> Yes. `iterate` and `generate` are lazy sources — elements are computed on demand. Without `limit()` or another short-circuit operation, they run forever.

**Follow-Up 2 (Tricky):** "Can `generate` be used in a parallel stream?"
> Technically yes, but the supplier must be thread-safe if it has state. `Stream.generate(() -> new Random().nextInt())` is safe (new instance per call). `Stream.generate(random::nextInt)` with a shared `Random` is NOT safe — use `ThreadLocalRandom.current()::nextInt` instead.

---

**Q2 (TRICKY). What is the difference between `map(Optional::of)` and `flatMap`when chaining Optionals?**

**Answer:**
```java
Optional<String> opt = Optional.of("hello");

// map wraps the result — produces Optional<Optional<Integer>>
Optional<Optional<Integer>> wrong = opt.map(s -> Optional.of(s.length()));

// flatMap unwraps — produces Optional<Integer>
Optional<Integer> correct = opt.flatMap(s -> Optional.of(s.length()));
```

The rule: if the mapping function itself returns an `Optional`, use `flatMap`. If it returns a plain value, use `map`.

**Follow-Up (Tricky):** "What does `Optional.flatMap` with a method that could return `Optional.empty()` do?"
> If the input `Optional` is present AND the mapper returns `Optional.empty()`, the result is `Optional.empty()`. The empty value propagates correctly — this is exactly the desired behavior for chained nullable lookups.

---

**Q3 (TRICKY). What happens when you call `stream.sorted().findFirst()` on a parallel stream?**

**Answer:**
`sorted()` on an ordered parallel stream forces a full evaluation (buffering all elements) to determine the global order, then `findFirst()` returns the first element in that order. The sorting is done correctly but the `ORDERED` constraint kills most of the parallel speedup — all threads must synchronize to merge-sort their partitions.

If you don't need the absolute first in sorted order, use `findAny()` which allows parallel threads to return any match without full coordination.

**Follow-Up (Tricky):** "`unordered()` hint — what does it do?"
> Calling `.unordered()` on a stream relaxes the ordering constraint. This allows the parallel runtime to skip ordering-preserving merges, potentially improving performance. It does NOT randomize — it just signals "I don't care about encounter order," enabling more efficient parallel execution.

---

### CODING SECTION — 30 minutes

---

**Problem 1 (15 min) TRICKY: Given a flat list of `Department` objects each containing a list of `Employee` objects, build a `Map<String, List<String>>` — department name → sorted list of employee names. Handle the case where a department may appear more than once in the input list.**

```java
// Model
record Department(String name, List<Employee> employees) {}
record Employee(String name, double salary) {}

List<Department> departments = List.of(
    new Department("Eng", List.of(new Employee("Zara", 90000), new Employee("Alice", 80000))),
    new Department("Eng", List.of(new Employee("Bob", 75000))),  // duplicate dept
    new Department("HR", List.of(new Employee("Charlie", 60000)))
);

Map<String, List<String>> result = departments.stream()
    .collect(Collectors.toMap(
        Department::name,
        d -> d.employees().stream()
            .map(Employee::name)
            .sorted()
            .collect(Collectors.toList()),
        (existing, incoming) -> {  // merge function for duplicate keys
            List<String> merged = new ArrayList<>(existing);
            merged.addAll(incoming);
            Collections.sort(merged);
            return merged;
        }
    ));

// {Eng=[Alice, Bob, Zara], HR=[Charlie]}
```

**Follow-Up:** "Why does `Collectors.toMap` throw an exception on duplicate keys by default?"
> The default merge function for `toMap` throws `IllegalStateException` on duplicate keys. You must supply a merge function (3rd argument) to define how to combine values when the same key appears more than once.

---

**Problem 2 (15 min) TRICKY: Using `reduce`, write a method that finds the second-largest element in a stream without sorting.**

```java
public static OptionalInt secondLargest(IntStream stream) {
    int[] top2 = stream.collect(
        () -> new int[]{Integer.MIN_VALUE, Integer.MIN_VALUE},
        (arr, val) -> {
            if (val > arr[0]) {
                arr[1] = arr[0];
                arr[0] = val;
            } else if (val > arr[1] && val != arr[0]) {
                arr[1] = val;
            }
        },
        (arr1, arr2) -> {
            // Combine: take top 2 from both arrays
            int[] combined = {
                Math.max(arr1[0], arr2[0]),
                0
            };
            combined[1] = Arrays.stream(new int[]{arr1[0], arr1[1], arr2[0], arr2[1]})
                .filter(v -> v != combined[0])
                .max()
                .orElse(Integer.MIN_VALUE);
        }
    );
    return top2[1] == Integer.MIN_VALUE ? OptionalInt.empty() : OptionalInt.of(top2[1]);
}
```

**Follow-Up:** "Could you also use a `TreeSet` approach?"
```java
OptionalInt second = nums.stream()
    .collect(Collectors.collectingAndThen(
        Collectors.toCollection(() -> new TreeSet<>(Comparator.reverseOrder())),
        set -> set.size() > 1 ? OptionalInt.of(set.stream().skip(1).findFirst().get()) : OptionalInt.empty()
    ));
```
> The `TreeSet` approach is cleaner and easier to understand — prefer it in interviews unless raw performance matters.

---

### DESIGN / DISCUSSION — 10 minutes

**"Describe a real scenario where a stream chain that looks correct can produce wrong results in a multi-threaded environment."**

**Answer:**
```java
// WRONG — shared mutable accumulator
Map<String, Integer> counts = new HashMap<>();
users.parallelStream()
    .forEach(u -> counts.merge(u.getCountry(), 1, Integer::sum));
// HashMap is not thread-safe — race conditions cause lost updates
```

**Fix:**
```java
// CORRECT — use groupingBy which handles concurrency internally
Map<String, Long> counts = users.parallelStream()
    .collect(Collectors.groupingByConcurrent(
        User::getCountry,
        Collectors.counting()
    ));
```

`groupingByConcurrent` uses a `ConcurrentHashMap` and is concurrent-safe. It is also slightly more efficient because it doesn't need to merge partial maps from each thread.

---

---

# ROUND 8 — Design-Heavy Java 8 (Principal Level, 1 Hour)
## Style: Apple / Airbnb Staff Engineer

---

### THEORY SECTION — 20 minutes

---

**Q1. How do default methods in interfaces affect the evolution of APIs? What is the diamond problem?**

**Answer:**
Default methods allow interface authors to add new methods without breaking all existing implementations. This was critical for evolving `Collection` and `Iterable` in Java 8 to add `forEach`, `stream()`, etc.

**Diamond problem:** When a class implements two interfaces that both define a default method with the same signature:
```java
interface A { default void greet() { System.out.println("A"); } }
interface B { default void greet() { System.out.println("B"); } }

class C implements A, B {
    @Override
    public void greet() {
        A.super.greet();  // must explicitly resolve
    }
}
```

The compiler forces the implementing class to override and explicitly call the desired parent using `InterfaceName.super.method()`.

**Follow-Up (Tricky):** "If a class inherits a method from a superclass and an interface provides a default method with the same name, which wins?"
> The class method always wins over the interface default method. Class implementation takes priority. This preserves backward compatibility — adding a default method to an interface cannot override a class method.

---

**Q2. Describe how Java 8 streams implement the "pipeline" pattern internally.**

**Answer:**
Streams use a linked chain of `ReferencePipeline` stages. Each intermediate operation wraps the previous stage. When a terminal operation is invoked:

1. The terminal operation creates a `Sink` chain, working backward from output to input
2. Each stage's `Sink.accept()` method applies its operation and calls downstream `.accept()`
3. The source spliterator pushes elements through the chain
4. Short-circuit operations throw `BreakException` internally to stop the source

The key design insight: elements flow one-by-one through all stages (loop fusion), not stage-by-stage over the entire dataset. This is why streams can be more cache-friendly than multiple `for` loops on large datasets.

**Follow-Up:** "What is a `Spliterator`?"
> A `Spliterator` is an iterator designed for parallel traversal. It can be split into two halves via `trySplit()`, enabling each half to be processed by a different thread. Standard collections (`ArrayList`, arrays) have efficient `Spliterator` implementations. User-defined spliterators can describe `ORDERED`, `SIZED`, `DISTINCT`, `SORTED` characteristics that the stream engine uses for optimization.

---

### CODING SECTION — 30 minutes

---

**Problem 1 (20 min): Design a `Pipeline<T>` class using `Function` composition that allows adding stages and executing them.**

```java
public class Pipeline<T> {
    private final Function<T, T> stages;

    private Pipeline(Function<T, T> stages) {
        this.stages = stages;
    }

    public static <T> Pipeline<T> of(Function<T, T> stage) {
        return new Pipeline<>(stage);
    }

    public Pipeline<T> addStage(Function<T, T> nextStage) {
        return new Pipeline<>(stages.andThen(nextStage));
    }

    public T execute(T input) {
        return stages.apply(input);
    }
}

// Usage:
Pipeline<String> pipeline = Pipeline.<String>of(String::trim)
    .addStage(String::toLowerCase)
    .addStage(s -> s.replace(" ", "_"));

String result = pipeline.execute("  Hello World  ");
// "hello_world"
```

**Follow-Up:** "How would you make this support different input and output types (heterogeneous pipeline)?"
> Use a more complex generic model with a mutable stage list and type erasure, or use a builder pattern that chains `Function<A,B>` → `Function<B,C>` by composition. This gets complex — in practice Akka Streams, Spring Integration, or `java.util.stream` itself solves this problem.

---

**Problem 2 (10 min): Use `CompletableFuture` to implement a timeout — if the async operation does not complete in 2 seconds, return a default value.**

```java
// Java 9+: orTimeout and completeOnTimeout
CompletableFuture<String> result = CompletableFuture
    .supplyAsync(() -> slowOperation())
    .completeOnTimeout("DEFAULT", 2, TimeUnit.SECONDS);

// Java 8 equivalent using ScheduledExecutorService:
CompletableFuture<String> future = CompletableFuture.supplyAsync(() -> slowOperation());

ScheduledExecutorService scheduler = Executors.newSingleThreadScheduledExecutor();
scheduler.schedule(() -> future.complete("DEFAULT"), 2, TimeUnit.SECONDS);

String value = future.join();  // either real result or "DEFAULT" after 2s
```

**Follow-Up:** "What is the difference between `complete("DEFAULT")` as a timeout and `completeExceptionally(new TimeoutException())`?"
> `complete` provides a fallback value — the future succeeds with the default. `completeExceptionally` marks the future as failed with an exception, which is propagated via `exceptionally` or throws in `get()`. Choose based on whether timeout is an acceptable result or an error condition.

---

### DESIGN / DISCUSSION — 10 minutes

**"Design a functional builder pattern for a `QuerySpec` object with optional filters using Java 8 features."**

```java
public class QuerySpec {
    private final String table;
    private final List<Predicate<Row>> filters;
    private final Function<Row, Row> transformer;
    private final int limit;

    private QuerySpec(Builder b) {
        this.table = b.table;
        this.filters = b.filters;
        this.transformer = b.transformer;
        this.limit = b.limit;
    }

    public static class Builder {
        private String table;
        private final List<Predicate<Row>> filters = new ArrayList<>();
        private Function<Row, Row> transformer = Function.identity();
        private int limit = Integer.MAX_VALUE;

        public Builder from(String table) { this.table = table; return this; }
        public Builder where(Predicate<Row> filter) { filters.add(filter); return this; }
        public Builder transform(Function<Row, Row> fn) { transformer = fn; return this; }
        public Builder limit(int n) { limit = n; return this; }
        public QuerySpec build() { return new QuerySpec(this); }
    }
}

// Usage:
QuerySpec spec = new QuerySpec.Builder()
    .from("orders")
    .where(row -> row.get("status").equals("ACTIVE"))
    .where(row -> Integer.parseInt(row.get("amount")) > 100)
    .transform(row -> row.withField("amount", row.get("amount") + "_USD"))
    .limit(50)
    .build();
```

---

---

# ROUND 9 — Tricky Edge Cases (Senior/Staff, 1 Hour)
## Style: Palantir / Two Sigma Engineering

---

### THEORY SECTION — 20 minutes

---

**Q1 (TRICKY). What is the difference between `Stream.of(null)` and `Stream.ofNullable(null)` (Java 9+)?**

**Answer:**
- `Stream.of(null)` creates a stream with one element: `null`. Downstream operations that don't handle null may throw NPE.
- `Stream.ofNullable(null)` (Java 9+) creates an empty stream if the argument is null. Safe for null-check-free pipelines.

```java
// Java 8 equivalent of Stream.ofNullable:
Stream<String> safe = value == null ? Stream.empty() : Stream.of(value);
```

**Follow-Up (Tricky):** "`Arrays.stream(null)` vs `Stream.of(null)` — what is the difference?"
> `Arrays.stream(null)` throws `NullPointerException` — a null array is not valid. `Stream.of(null)` works because the varargs overload accepts a single null element; the stream contains one `null` element.

---

**Q2 (TRICKY). Can two threads safely call `stream()` on the same `List` simultaneously?**

**Answer:**
Yes, if the `List` is not modified during the stream operations. `ArrayList.stream()` creates a new `Spliterator` backed by the array snapshot at creation time. If another thread MODIFIES the list during traversal, you may see `ConcurrentModificationException` or inconsistent results — the same as iterating with a regular `for-each` on a non-concurrent list.

**Follow-Up (Tricky):** "What about reading the same `List` from two threads simultaneously — is that safe?"
> Yes. Concurrent reads on `ArrayList` (or any `List` without writes) are safe. Java Memory Model guarantees visibility of writes that happened-before the reads (e.g., if the list was populated before threads were spawned). Parallel streams do this internally — they read from the same source concurrently.

---

**Q3 (TRICKY). What happens if you call `collect(Collectors.toList())` and then modify the returned list? What if you use `toUnmodifiableList()`?**

**Answer:**
- `toList()` returns a mutable list (usually `ArrayList`). Modifying it is safe and won't affect the source.
- `toUnmodifiableList()` (Java 10) returns a list that throws `UnsupportedOperationException` on `add/remove/set`.
- In Java 16+, `Stream.toList()` returns an unmodifiable list by default.

**Follow-Up (Tricky):** "If you sort the list returned by `collect(toList())`, does it affect the original source list?"
> No. The collected list is a new object. Sorting it does not modify the original collection from which the stream was created.

---

### CODING SECTION — 30 minutes

---

**Problem 1 (15 min) TRICKY: Implement `zip` for two streams — combine elements pairwise into a `Pair<A,B>` list.**

Java 8 has no built-in `zip`. Implement it:

```java
public static <A, B> List<Pair<A, B>> zip(List<A> listA, List<B> listB) {
    int size = Math.min(listA.size(), listB.size());
    return IntStream.range(0, size)
        .mapToObj(i -> new Pair<>(listA.get(i), listB.get(i)))
        .collect(Collectors.toList());
}

// Simple Pair class:
record Pair<A, B>(A first, B second) {}

// Usage:
List<String> names = List.of("Alice", "Bob", "Charlie");
List<Integer> scores = List.of(90, 85, 78);
List<Pair<String, Integer>> zipped = zip(names, scores);
// [(Alice, 90), (Bob, 85), (Charlie, 78)]
```

**Follow-Up:** "What if one list is infinite (from `Stream.iterate`)?"
> This approach requires materialized lists. For infinite streams, you'd need a `Spliterator`-based approach or a library like Guava's `Streams.zip` which works on stream sources and stops at the shorter one.

---

**Problem 2 (15 min) TRICKY: Given a stream of events with timestamps, detect "bursts" — sequences of 3 or more events within a 5-second window. Return the count of such bursts.**

```java
// Simplified: detect runs where consecutive gaps < 5000ms
List<Long> timestamps = List.of(100L, 200L, 300L, 1000L, 6500L, 7000L, 7400L, 7900L);

// Step 1: compute gaps
// Step 2: find runs of gaps all < 5000
// Streams don't handle state well here — use plain iteration for clarity

int burstCount = 0;
int run = 1;
for (int i = 1; i < timestamps.size(); i++) {
    if (timestamps.get(i) - timestamps.get(i - 1) < 5000) {
        run++;
        if (run == 3) burstCount++;  // count when burst first detected
    } else {
        run = 1;
    }
}
// burstCount = 1 (the 6500-7900 window has 4 events within 5 seconds)
```

**Follow-Up:** "Why did you NOT use streams for this?"
> This problem requires stateful processing — each element's decision depends on the prior element's value and an accumulated run count. Streams are designed for stateless element-wise operations. Forcing stateful logic into streams via mutable captured variables is an anti-pattern. For sliding window / stateful stream processing, use a plain loop, or a framework like Flink/Kafka Streams.

---

### DESIGN / DISCUSSION — 10 minutes

**"A colleague writes this and says it is faster. Is it? Why or why not?"**
```java
list.parallelStream()
    .map(item -> expensiveLookup(item))
    .collect(Collectors.toList());
```

**Answer:**
It may or may not be faster depending on:
1. `expensiveLookup` CPU-bound? → Parallel streams likely faster
2. `expensiveLookup` makes network/DB calls? → Parallel streams use ForkJoinPool (not designed for blocking) — CompletableFuture with dedicated pool is better
3. List size < 1000? → Thread overhead likely makes it slower
4. `expensiveLookup` has shared state? → Race condition, incorrect results

The answer must always be: **measure before assuming parallelism is faster**. Use JMH for benchmarking, not manual timing.

---

---

# ROUND 10 — Full Gauntlet (Principal Level, 1 Hour)
## Style: Comprehensive FAANG Final Round

---

### THEORY SECTION — 20 minutes

---

**Q1 (COMPREHENSIVE). Walk me through everything that happens when you call:**
```java
employees.stream()
    .filter(e -> e.getSalary() > 50000)
    .map(Employee::getName)
    .sorted()
    .limit(5)
    .collect(Collectors.toList());
```

**Answer:**
1. `employees.stream()` — creates a `ReferencePipeline.Head` over the list's `Spliterator`
2. `.filter(...)` — adds a `StatelessOp` stage; no execution yet
3. `.map(...)` — adds another `StatelessOp` stage; no execution yet
4. `.sorted()` — adds a `StatefulOp` stage (will buffer and sort)
5. `.limit(5)` — adds a short-circuit `StatefulOp`
6. `.collect(toList())` — terminal operation triggers evaluation
   - A `Sink` chain is built backward: `List accumulator ← limit sink ← sort sink ← map sink ← filter sink`
   - Source spliterator pushes each `Employee` through: filter → map → buffered by sort
   - After source is exhausted, sort emits elements in order through limit → collect
   - After 5 elements are emitted, limit's short-circuit flag stops the sort from emitting more
7. Returns an unordered (in terms of original list), alphabetically sorted list of 5 highest-earner names

**Follow-Up:** "If you remove `sorted()`, does `limit(5)` still stop early?"
> Yes. Without `sorted()`, the pipeline is fully lazy from source to limit. `limit(5)` short-circuits after 5 elements pass the filter — the source spliterator stops being iterated after that.

---

**Q2 (TRICKY FINAL). What are all the ways a `Stream` can be created in Java 8?**

**Answer:**
```java
// 1. From collection
list.stream();
list.parallelStream();

// 2. From array
Arrays.stream(arr);
Arrays.stream(arr, startIndex, endIndex);

// 3. Stream.of
Stream.of("a", "b", "c");
Stream.of(singleValue);

// 4. Stream.empty
Stream.empty();

// 5. Stream.iterate
Stream.iterate(0, n -> n + 1);

// 6. Stream.generate
Stream.generate(Math::random);

// 7. IntStream / LongStream / DoubleStream ranges
IntStream.range(0, 10);
IntStream.rangeClosed(1, 10);
LongStream.range(0L, 1_000_000L);

// 8. Stream.concat
Stream.concat(stream1, stream2);

// 9. Files.lines
Files.lines(Path.of("file.txt"));

// 10. BufferedReader.lines
new BufferedReader(reader).lines();

// 11. Pattern.splitAsStream
Pattern.compile(",").splitAsStream("a,b,c");

// 12. IntStream.chars() / codePoints()
"hello".chars();  // IntStream of char values
```

---

### CODING SECTION — 30 minutes

---

**GRAND FINALE PROBLEM (30 min): Full pipeline design**

**Prompt:** Given a log file where each line is: `TIMESTAMP|USER_ID|ACTION|STATUS` — write a complete Java 8 stream solution that:
1. Parses each line into a `LogEntry` record
2. Filters only `FAILED` status entries
3. Groups by `USER_ID`
4. For each user, counts failures and gets the most recent failure timestamp
5. Returns users with more than 3 failures, sorted by failure count descending
6. Output: `List<UserFailureSummary>`

```java
record LogEntry(String timestamp, String userId, String action, String status) {
    static LogEntry parse(String line) {
        String[] parts = line.split("\\|");
        return new LogEntry(parts[0], parts[1], parts[2], parts[3]);
    }
}

record UserFailureSummary(String userId, long failureCount, String lastFailureTime) {}

public List<UserFailureSummary> analyzeFailures(List<String> lines) {
    return lines.stream()
        .map(LogEntry::parse)
        .filter(e -> "FAILED".equals(e.status()))
        .collect(Collectors.groupingBy(LogEntry::userId))
        .entrySet().stream()
        .filter(entry -> entry.getValue().size() > 3)
        .map(entry -> {
            List<LogEntry> failures = entry.getValue();
            long count = failures.size();
            String lastTime = failures.stream()
                .map(LogEntry::timestamp)
                .max(Comparator.naturalOrder())
                .orElse("UNKNOWN");
            return new UserFailureSummary(entry.getKey(), count, lastTime);
        })
        .sorted(Comparator.comparingLong(UserFailureSummary::failureCount).reversed())
        .collect(Collectors.toList());
}
```

**Follow-Up 1:** "What if the log file is very large (10 GB)? How would you change this?"
> Use `Files.lines(path)` which lazily streams lines — avoids loading the whole file into memory. Also consider using `groupingByConcurrent` with `parallelStream()` for better throughput, but measure first.

**Follow-Up 2:** "How would you add a time-range filter to only look at failures in the last 24 hours?"
```java
.filter(e -> "FAILED".equals(e.status()))
.filter(e -> isWithinLast24Hours(e.timestamp()))
```

**Follow-Up 3 (Design):** "How would you make this code testable?"
> Inject the `UserRepository` or parsing logic as functional parameters. Pass `Function<String, LogEntry>` as a parser argument, and `Predicate<String>` as the status filter. This allows test cases to inject controlled behavior without mocking file I/O.

---

### FINAL DESIGN DISCUSSION — 10 minutes

**"Reflect: In a production Java 8 codebase, what are the top 3 mistakes you have seen with streams and lambdas in code reviews? How do you fix them?"**

**Answer:**

**Mistake 1: Calling `.get()` on Optional without checking**
```java
// Wrong
String name = optional.get();  // throws if empty

// Fix
String name = optional.orElseThrow(() -> new IllegalStateException("Name not found"));
```

**Mistake 2: Using parallel streams for I/O operations**
```java
// Wrong — blocks ForkJoinPool threads on I/O
results = items.parallelStream().map(item -> httpClient.get(item.url())).collect(...);

// Fix — use CompletableFuture with dedicated executor
ExecutorService exec = Executors.newFixedThreadPool(20);
results = CompletableFuture.allOf(items.stream()
    .map(item -> CompletableFuture.supplyAsync(() -> httpClient.get(item.url()), exec))
    ...
```

**Mistake 3: Collecting to a list and then streaming again unnecessarily**
```java
// Wrong — materializes intermediate list
List<String> filtered = list.stream().filter(cond).collect(toList());
List<String> mapped = filtered.stream().map(fn).collect(toList());

// Fix — compose into one pipeline
List<String> result = list.stream().filter(cond).map(fn).collect(toList());
```

---

---

## QUICK REFERENCE: TRICKY QUESTIONS BY COMPANY STYLE

| Company Style | Favorite Java 8 Traps |
|---|---|
| **Amazon** | `orElse` vs `orElseGet` eager evaluation; lambda variable capture |
| **Google** | Stream laziness; `sorted()` as evaluation barrier; `findAny` vs `findFirst` |
| **Microsoft** | `CompletableFuture` thread model; `thenApply` vs `thenCompose` |
| **Facebook/Meta** | `reduce` identity in parallel; `groupingBy` merge function |
| **Apple** | Default method resolution order; interface evolution |
| **Netflix/Stripe** | `Collectors.toMap` duplicate key exception; custom collectors |
| **Uber/LinkedIn** | Parallel stream common pool starvation; I/O in parallel streams |
| **Palantir** | Stateful stream operations — when NOT to use streams |
| **Two Sigma** | `Stream.iterate` vs `Stream.generate`; thread-safety of stream sources |

---

## TIMING GUIDE FOR SELF-PRACTICE

| Round | Focus | Level | Time |
|---|---|---|---|
| 1 | Lambda, Predicate, flatMap basics | Mid | 60 min |
| 2 | Streams deep — laziness, grouping, partitioning | Mid | 60 min |
| 3 | Optional, CompletableFuture | Mid-Senior | 60 min |
| 4 | Lambda tricky, method references, Comparator | Senior | 60 min |
| 5 | Date/Time API, Collectors advanced | Senior | 60 min |
| 6 | Parallel streams, performance | Senior | 60 min |
| 7 | FAANG-style tricky theory + hard coding | Senior+ | 60 min |
| 8 | Design-heavy, API evolution, Spliterator | Principal | 60 min |
| 9 | Edge cases — null, concurrency, stateful anti-patterns | Staff | 60 min |
| 10 | Grand gauntlet — full pipeline + production thinking | Principal | 60 min |

---

*File: `34_JAVA_8_MOCK_INTERVIEW_10_ROUNDS.md` — Part of java8 interview prep series*
*See files 30, 31, 32 for solved Q&A by difficulty, file 33 for coding problems with solutions*
