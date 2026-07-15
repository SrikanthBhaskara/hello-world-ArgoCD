# Functional Interfaces

## Definition
A functional interface is an interface that contains exactly one abstract method. It may also contain default methods, static methods, and methods inherited from `Object`.

## Why functional interfaces matter
They are the foundation that makes lambda expressions and method references possible. A lambda needs a target type, and a functional interface provides that target type.

## Simple example
```java
@FunctionalInterface
interface Printer {
    void print(String value);
}
```

Now this works:

```java
Printer printer = text -> System.out.println(text);
printer.print("Hello");
```

## Why the one-abstract-method rule matters
If an interface had multiple abstract methods, Java would not know which method the lambda was supposed to implement.

## `@FunctionalInterface`

### What it does
The annotation is optional, but it tells the compiler to enforce the functional-interface rule.

### Why it helps
If someone later adds another abstract method by mistake, the compiler will reject it.

## What is allowed inside a functional interface
- One abstract method
- Any number of default methods
- Any number of static methods
- Methods from `Object`

## Example with default and static methods
```java
@FunctionalInterface
interface Converter {
    int convert(String value);

    default void info() {
        System.out.println("Converter interface");
    }

    static boolean isEmpty(String text) {
        return text == null || text.isEmpty();
    }
}
```

## Built-in functional interfaces
- Runnable
- Comparator<T>
- Callable<T>
- Predicate<T>
- Function<T, R>
- Consumer<T>
- Supplier<T>

## Functional interfaces in real APIs
Functional interfaces are used whenever an API accepts behavior.

### Common cases
- Sorting rules
- Filtering conditions
- Transformation logic
- Deferred value creation
- Callback actions

## Why this feature improved Java design
Before Java 8, accepting behavior in APIs usually meant anonymous classes, which were verbose. Functional interfaces made these APIs much easier to use and helped library design become more expressive.

## Common interview questions

### Can a functional interface have multiple methods?
It can have many methods, but only one abstract method.

### Does overriding `toString()` or `equals()` break the rule?
No. Methods from `Object` do not count as additional abstract methods for this purpose.

### Why are functional interfaces important for lambdas?
Because a lambda needs a known method shape. The functional interface defines that shape.

## Interview-style answer
Functional interfaces are interfaces with exactly one abstract method, and they are essential in Java 8 because lambdas and method references need them as target types. They make APIs that accept behavior much cleaner and reduce the verbosity that existed before Java 8 with anonymous inner classes.