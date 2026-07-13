# Java Interview Questions: Beginner (0 to 2 Years)

## Focus Areas

- OOP basics
- Java syntax and JVM basics
- collections
- exceptions
- Java 8 fundamentals
- simple multithreading basics
- code readability and debugging basics

## Core Fundamentals

### 1. What is Java and why is it platform independent?
Short answer:
Java is a programming language that compiles to bytecode, and that bytecode runs on any system with a JVM.

Better answer:
Java is a high-level language designed for portability and large-scale application development. It is called platform independent because the same compiled bytecode can run on different operating systems through their JVM implementations.

### 2. Difference between JDK, JRE, and JVM?
Short answer:
JVM runs bytecode, JRE provides runtime libraries plus JVM, and JDK includes JRE plus development tools.

Better answer:
The JVM is the execution engine. The JRE is what you need to run Java applications. The JDK is what you need to build them because it includes the compiler and other development tools.

### 3. What are class, object, inheritance, polymorphism, abstraction, and encapsulation?
Short answer:
A class is a blueprint, an object is an instance, inheritance supports reuse, polymorphism supports different behavior through one interface, abstraction hides unnecessary detail, and encapsulation protects state.

Better answer:
These are the foundations of object-oriented programming. I explain them with examples: a class defines structure, an object is the actual runtime instance, inheritance helps code reuse, polymorphism supports flexible behavior, abstraction focuses on what matters, and encapsulation protects internal data through controlled access.

### 4. Difference between abstract class and interface?
Short answer:
An abstract class can hold shared code and state, while an interface mainly defines a contract.

Better answer:
I use an abstract class when related classes share behavior or fields. I use an interface when I want different classes to follow the same contract even if they are otherwise unrelated. Interfaces support better flexibility, while abstract classes support shared implementation.

### 5. Difference between method overloading and method overriding?
Short answer:
Overloading means same method name with different parameters. Overriding means a child class changes parent behavior.

Better answer:
Overloading is decided at compile time based on method signatures. Overriding is decided at runtime based on the actual object type. Overloading improves usability, and overriding supports polymorphism.

### 6. What is the difference between `==` and `equals()`?
Short answer:
`==` compares references for objects, while `equals()` compares logical content if implemented properly.

Better answer:
For objects, `==` checks whether both references point to the same object. `equals()` is for logical equality, such as comparing two strings by value. That is why custom classes may need to override `equals()` when business comparison matters.

### 7. Why is `hashCode()` important?
Short answer:
`hashCode()` is used by hash-based collections for efficient storage and lookup.

Better answer:
Collections like `HashMap` and `HashSet` depend on both `hashCode()` and `equals()`. If two objects are equal, they must produce the same hash code. If that contract is broken, map and set behavior becomes unreliable.

## Collections

### 8. Difference between `ArrayList` and `LinkedList`?
Short answer:
`ArrayList` is faster for random access, and `LinkedList` is useful in some insertion or deletion cases.

Better answer:
`ArrayList` is usually the default because indexed access is fast and memory locality is better. `LinkedList` can be useful when frequent insertions or removals happen at known positions, but in many real applications `ArrayList` still performs better overall.

### 9. Difference between `HashMap` and `ConcurrentHashMap`?
Short answer:
`HashMap` is not thread-safe, and `ConcurrentHashMap` is built for concurrent access.

Better answer:
I use `HashMap` for simple single-threaded scenarios. I use `ConcurrentHashMap` when multiple threads need safe shared access and I want better concurrency than locking the entire map.

### 10. Difference between `HashSet` and `TreeSet`?
Short answer:
`HashSet` stores unique elements without order, and `TreeSet` stores unique elements in sorted order.

Better answer:
`HashSet` is generally faster for basic operations. `TreeSet` is useful when sorted traversal or comparator-based ordering is needed. The tradeoff is more overhead for maintaining order.

### 11. What is the difference between `List`, `Set`, and `Map`?
Short answer:
`List` allows duplicates, `Set` stores unique values, and `Map` stores key-value pairs.

Better answer:
I choose them based on the business need. If ordering and duplicates matter, I use a `List`. If uniqueness matters, I use a `Set`. If lookup by key matters, I use a `Map`.

### 12. What is fail-fast behavior in collections?
Short answer:
It means an iterator throws `ConcurrentModificationException` when the collection is modified unsafely during iteration.

Better answer:
Fail-fast behavior helps catch accidental structural changes while iterating. It is a safety mechanism, and the usual fix is to use the iterator's own remove method or change the logic so modification is done separately.

## Exceptions

### 13. Difference between checked and unchecked exceptions?
Short answer:
Checked exceptions must be handled or declared, and unchecked exceptions extend `RuntimeException`.

Better answer:
Checked exceptions represent conditions the caller is expected to consider, while unchecked exceptions often indicate programming mistakes or invalid assumptions. Good code uses exceptions intentionally instead of treating every error the same way.

### 14. What is `try-catch-finally` and when does `finally` run?
Short answer:
`try` contains risky code, `catch` handles exceptions, and `finally` is usually used for cleanup.

Better answer:
`finally` typically runs whether an exception occurs or not, except in rare cases like forced JVM termination. Today, for closable resources, `try-with-resources` is often cleaner than a manual `finally` block.

### 15. Difference between `throw` and `throws`?
Short answer:
`throw` actually raises an exception, and `throws` declares possible exception propagation.

Better answer:
I think of `throw` as the action and `throws` as the method contract. `throw` happens inside code logic, while `throws` appears in the method signature.

## Strings and Immutability

### 16. Why is `String` immutable?
Short answer:
It is immutable for safety, sharing, pooling, and predictable behavior.

Better answer:
Immutability makes strings safe to share across threads and APIs. It also supports string pooling and stable hashing, which is important because strings are used heavily as keys and identifiers.

### 17. Difference between `StringBuilder` and `StringBuffer`?
Short answer:
`StringBuilder` is faster and not synchronized, while `StringBuffer` is synchronized and thread-safe.

Better answer:
In most code, `StringBuilder` is preferred because many string-building operations are local to one thread. `StringBuffer` is useful only when the same mutable string object is shared across threads.

## Java 8 Questions

### 18. What is a lambda expression?
Short answer:
A lambda is a compact way to pass behavior as code for a functional interface.

Better answer:
Lambdas reduce boilerplate compared to anonymous classes and make stream operations, sorting, filtering, and callback logic easier to read.

### 19. What is a functional interface?
Short answer:
A functional interface has exactly one abstract method.

Better answer:
Functional interfaces are the target types for lambdas and method references. Common examples include `Predicate`, `Function`, `Consumer`, `Supplier`, and `Runnable`.

### 20. Difference between lambda and anonymous class?
Short answer:
A lambda is shorter and meant for functional interfaces, while an anonymous class creates a full unnamed class implementation.

Better answer:
I use a lambda when I only need simple behavior for a single abstract method. I use an anonymous class when I need more structure, extra fields, or multiple method implementations.

### 21. What is Stream API?
Short answer:
It is a declarative way to process data using operations like filter, map, and collect.

Better answer:
A stream is a processing pipeline, not the collection itself. It helps express transformation logic more clearly by focusing on what to do instead of manual loop mechanics.

### 22. Difference between `map()` and `flatMap()`?
Short answer:
`map()` transforms one element to one result, and `flatMap()` flattens nested results into one stream.

Better answer:
If one input becomes one output, I use `map()`. If one input can produce multiple outputs, such as a list of roles from a user, I use `flatMap()` to flatten the nested structure.

### 23. Difference between intermediate and terminal operations in streams?
Short answer:
Intermediate operations build the pipeline, and terminal operations execute it.

Better answer:
Operations like `filter()` and `map()` are intermediate. Operations like `collect()` and `count()` are terminal. Streams are lazy, so the pipeline is evaluated only when a terminal operation is called.

### 24. What is `Optional` and why is it used?
Short answer:
`Optional` is a container that may or may not hold a value.

Better answer:
It makes missing values explicit and encourages callers to handle absence intentionally instead of assuming everything is non-null. I mostly use it in return types, not everywhere.

### 25. Difference between `orElse()` and `orElseGet()`?
Short answer:
`orElse()` takes a direct fallback value, while `orElseGet()` computes it lazily.

Better answer:
`orElseGet()` is better when the fallback value is expensive to create because it runs only if the optional is empty.

### 26. Why is `java.time` better than old `Date` and `Calendar`?
Short answer:
`java.time` is cleaner, immutable, and easier to use correctly.

Better answer:
The old APIs were confusing and mutable. `java.time` introduced clear types like `LocalDate`, `LocalDateTime`, and `ZonedDateTime`, which makes date-time logic safer and more readable.

### 27. What is `CompletableFuture` in simple terms?
Short answer:
It is a way to handle asynchronous work and future results more flexibly.

Better answer:
`CompletableFuture` is useful when tasks run independently or when we want to chain async steps together without blocking the main flow unnecessarily.

## Basic Multithreading

### 28. Difference between process and thread?
Short answer:
A process is an independent running program, and a thread is a smaller execution unit inside a process.

Better answer:
Processes usually have separate memory spaces, while threads share memory inside the same process. Threads are lighter, but shared state means synchronization becomes important.

### 29. What are ways to create a thread in Java?
Short answer:
You can extend `Thread`, implement `Runnable`, implement `Callable`, or use executors.

Better answer:
In modern code, I prefer executors because they separate task submission from thread management. They are more flexible and maintainable than manually creating threads everywhere.

### 30. What is synchronization?
Short answer:
Synchronization controls shared access so multiple threads do not corrupt data.

Better answer:
When multiple threads update shared state, race conditions can happen. Synchronization protects correctness, though too much locking can affect performance, so balance matters.

### 31. Difference between `sleep()` and `wait()`?
Short answer:
`sleep()` pauses a thread for time, while `wait()` releases the monitor and waits for notification.

Better answer:
`sleep()` belongs to `Thread` and does not release locks. `wait()` belongs to `Object`, must be used in synchronized context, and is meant for thread coordination.

## Simple Code-Structure Questions

### 32. Convert this old loop to stream style.
```java
List<String> names = new ArrayList<>();
for (User user : users) {
    if (user.isActive()) {
        names.add(user.getName());
    }
}
```
Short answer:
```java
List<String> names = users.stream()
    .filter(User::isActive)
    .map(User::getName)
    .toList();
```

Better answer:
This is clearer because it expresses the intent as a pipeline: filter active users, map to names, then collect the result.

### 33. Convert anonymous class to lambda.
```java
Runnable r = new Runnable() {
    @Override
    public void run() {
        System.out.println("Hello");
    }
};
```
Short answer:
```java
Runnable r = () -> System.out.println("Hello");
```

Better answer:
This works because `Runnable` is a functional interface. The lambda removes unnecessary boilerplate and makes the behavior easier to read.

## Beginner Practical Round

### 34. Write code to count word frequency in a list.
Short answer:
Use a `Map<String, Integer>` and increment the count while iterating.

Better answer:
That is the clearest beginner answer. If the interviewer wants Java 8 style, I can also mention `Collectors.groupingBy` with `counting()`.

### 35. Write code to remove duplicates from a list.
Short answer:
Convert the list to a set or use `stream().distinct()`.

Better answer:
If order matters, I use `LinkedHashSet` or `distinct()`. I mention order because interviewers often want to see whether I think about behavior, not only syntax.

### 36. Write code to sort employees by salary.
Short answer:
Use `employees.sort(Comparator.comparing(Employee::getSalary));`

Better answer:
I prefer `Comparator.comparing` because it is readable and easy to extend with `reversed()` or secondary comparison logic.

### 37. Reverse a string and check palindrome.
Short answer:
Reverse the string using `StringBuilder` and compare with the original.

Better answer:
For a beginner interview, this answer is simple and readable. If needed, I can also explain a two-pointer approach as an alternative.

### 38. Find second highest number in an array.
Short answer:
Track the highest and second highest values in one pass.

Better answer:
I prefer the one-pass solution because it is efficient and easy to explain. I also mention edge cases like duplicates, negative numbers, and arrays with too few distinct values.

## What to Revise Before Interview

- collections
- OOP basics
- `equals()` and `hashCode()`
- streams
- `Optional`
- `java.time`
- basic threading
- explain code choices, not only definitions
