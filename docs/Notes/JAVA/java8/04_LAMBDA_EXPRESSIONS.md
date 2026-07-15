# Lambda Expressions

## What a lambda is
A lambda expression is a compact way to represent behavior without creating a named class or writing a full anonymous inner class. In practical terms, it lets you pass code as data when a method expects a functional interface.

## Why lambdas were introduced
Before Java 8, small behavior blocks required anonymous inner classes. That made code verbose and harder to read, especially when the logic itself was simple.

### Before Java 8
```java
Comparator<String> comp = new Comparator<String>() {
    @Override
    public int compare(String a, String b) {
        return a.length() - b.length();
    }
};
```

### With Java 8
```java
Comparator<String> comp = (a, b) -> a.length() - b.length();
```

The behavior is the same, but the Java 8 version is shorter and clearer.

## Lambda syntax

### Expression form
```java
(parameters) -> expression
```

### Block form
```java
(parameters) -> {
    statements;
}
```

### Examples
```java
() -> System.out.println("Hello")
(x) -> x * x
(a, b) -> a + b
name -> name.toUpperCase()
```

## Parts of a lambda
- Parameter list
- Arrow token `->`
- Body

The body can be a single expression or a full block with multiple statements.

## Where lambdas are used
- Sorting and comparison
- Stream pipelines
- Event handlers
- Thread tasks
- Callback-based APIs
- Functional interface implementations

## Lambda with Runnable
```java
Runnable task = () -> System.out.println("Running task");
new Thread(task).start();
```

## Lambda with Comparator
```java
List<String> names = Arrays.asList("Anu", "Rohit", "Vijay");
names.sort((a, b) -> a.length() - b.length());
```

## Lambda with Stream filter
```java
List<String> result = names.stream()
    .filter(name -> name.startsWith("A"))
    .collect(Collectors.toList());
```

## Type inference in lambdas
Java usually infers the parameter types from context.

### Explicit types
```java
Comparator<String> comp = (String a, String b) -> a.compareTo(b);
```

### Inferred types
```java
Comparator<String> comp = (a, b) -> a.compareTo(b);
```

In most cases, the inferred version is preferred because it is shorter and still readable.

## Rules and restrictions

### 1. Lambdas need a target type
A lambda cannot exist by itself. It must be assigned where Java knows which functional interface type is expected.

### 2. Captured local variables must be effectively final
If a local variable is used inside a lambda, it cannot be changed afterward.

```java
int base = 10;
Function<Integer, Integer> fn = x -> x + base;
```

This works because `base` is not modified.

### 3. `this` behaves differently from anonymous inner classes
Inside a lambda, `this` refers to the enclosing class instance, not to a new anonymous object.

That is an important difference from anonymous inner classes.

## Lambda vs anonymous inner class

### Similarity
Both can provide implementation for a single-method contract.

### Differences
- Lambdas are shorter.
- Lambdas do not create a separate `this` context the way anonymous classes do.
- Lambdas work more naturally with functional-style APIs.

## Why lambdas matter in real code
- They make APIs that accept behavior easier to use.
- They improve readability in data-processing code.
- They encourage a more declarative style, especially with streams.

## When not to use lambdas
Do not force lambdas when the logic is long or unclear. If the body becomes too complex, a named method is often more readable.

### Example of overuse
If a lambda contains many lines, nested conditions, and side effects, it can reduce clarity instead of improving it.

## Common interview questions

### Why are lambdas better than anonymous inner classes?
They reduce verbosity and make behavior-passing much more readable, especially for simple single-method contracts.

### Are lambdas objects?
They are used as instances of functional interface target types, but they are not written as explicit class definitions by the developer.

### Can a lambda replace every anonymous inner class?
No. Lambdas are best for functional interfaces. If multiple abstract methods are involved, lambdas cannot be used.

## Interview-style answer
Lambda expressions in Java 8 are a concise way to represent behavior inline. They are mainly used with functional interfaces and help reduce the boilerplate of anonymous inner classes. Their biggest practical value is in stream processing, callbacks, sorting, and APIs that accept small units of behavior. They also support a more declarative coding style, though they should not be overused when the logic becomes too complex.