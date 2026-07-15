# Java 8 Interview Questions Easy Level

## Easy Questions

### 1. What are the major features introduced in Java 8?
Expected areas:
- Lambdas
- Streams
- Optional
- Default methods
- Date/time API

Solved answer:
The major features introduced in Java 8 include lambda expressions, functional interfaces, the Streams API, Optional, default and static methods in interfaces, the new date and time API, and CompletableFuture. Together these features made Java less verbose and more expressive.

### 2. What is a lambda expression?

Solved answer:
A lambda expression is a concise way to represent anonymous behavior in Java. It is mainly used with functional interfaces and helps reduce the boilerplate of anonymous inner classes.

### 3. What is a functional interface?

Solved answer:
A functional interface is an interface with exactly one abstract method. It can still have default and static methods. Lambdas work because Java maps them to functional interfaces.

### 4. What is the use of Predicate?

Solved answer:
Predicate is a built-in functional interface used for boolean conditions. It accepts one input and returns `true` or `false`. It is commonly used in filtering and validation logic.

### 5. What is the use of Function?

Solved answer:
Function is used for transformation. It accepts one input type and returns one output type. A common example is using `map` in streams to convert objects into another form.

### 6. What is the difference between Collection and Stream?

Solved answer:
A collection stores data, while a stream processes data. Collections are reusable containers, but streams are usually one-time pipelines used to transform, filter, or aggregate data.

### 7. What is `forEach` used for?

Solved answer:
`forEach` is used to perform an action on each element, such as printing, logging, or final side-effect operations. It should not be overused for transformations where `map` and `collect` are clearer.

### 8. What is Optional?

Solved answer:
Optional is a container that may or may not contain a value. It is used to represent absence more explicitly than returning null, especially in method return types.

### 9. Why is Java 8 date/time API better than Date and Calendar?

Solved answer:
The Java 8 date/time API is better because it is immutable, thread-safe, cleaner to read, and easier to use correctly. Classes like `LocalDate` and `LocalDateTime` are much more intuitive than the old APIs.

### 10. What is a method reference?

Solved answer:
A method reference is a short form of a lambda when an existing method already matches the required functional interface shape. For example, `System.out::println` is a method reference.

## How to answer easy questions
- Keep the definition clear.
- Give one simple example.
- Mention practical usage in one sentence.