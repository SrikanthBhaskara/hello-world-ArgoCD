# Method References

## What they are
Method references are shorthand for lambdas when an existing method already matches the required behavior shape.

## Why method references exist
Many lambdas simply call an existing method without adding extra logic. In those cases, method references reduce repetition and improve readability.

### Lambda form
```java
list.forEach(x -> System.out.println(x));
```

### Method reference form
```java
list.forEach(System.out::println);
```

## Types of method references

### 1. Static method reference
```java
Function<String, Integer> parse = Integer::parseInt;
```

### 2. Instance method reference of a specific object
```java
PrintStream out = System.out;
Consumer<String> c = out::println;
```

### 3. Instance method reference of an arbitrary object of a particular type
```java
Function<String, String> upper = String::toUpperCase;
```

### 4. Constructor reference
```java
Supplier<List<String>> s = ArrayList::new;
```

## When to use method references
- When the lambda body only calls one method
- When the method reference is clearer than the lambda
- When it reduces noise without hiding meaning

## When not to use method references
If the lambda contains extra conditions, transformations, or several steps, a method reference is not appropriate.

## Common confusion
Method references are not a different execution model. They are just a more concise form of certain lambdas.

## Interview-style answer
Method references are a shorthand for lambdas when an existing method already matches the required functional interface shape. They improve readability and reduce boilerplate, especially in stream operations and constructor-based suppliers.