# Java 8+ Features - Complete Interview Guide

> **For 5+ Year Experienced Backend Developers**
> 
> Complete guide covering Lambda Expressions, Stream API, Functional Interfaces, Optional, Method References, Default Methods, Date/Time API, and more with real-world examples, interview questions, traps, and coding problems.

---

## Table of Contents

1. [Lambda Expressions](#1-lambda-expressions)
2. [Functional Interfaces](#2-functional-interfaces)
3. [Method References](#3-method-references)
4. [Stream API](#4-stream-api)
5. [Optional](#5-optional)
6. [Default & Static Methods in Interfaces](#6-default--static-methods-in-interfaces)
7. [Date and Time API](#7-date-and-time-api)
8. [CompletableFuture](#8-completablefuture)
9. [Java 9+ Features](#9-java-9-features)
10. [Java 10-17 Features](#10-java-10-17-features)
11. [Interview Questions](#11-interview-questions)
12. [Interview Traps & Edge Cases](#12-interview-traps--edge-cases)
13. [Coding Problems](#13-coding-problems)

---

# 1. LAMBDA EXPRESSIONS

## 1.1 Introduction to Lambdas

**Lambda expression** = Anonymous function: short block of code that takes parameters and returns a value.

**Syntax:**
```java
(parameters) -> expression
(parameters) -> { statements; }
```

```java
import java.util.*;

public class LambdaBasics {
    
    // Before Java 8: Anonymous inner class
    public void beforeJava8() {
        Runnable runnable = new Runnable() {
            @Override
            public void run() {
                System.out.println("Running");
            }
        };
        new Thread(runnable).start();
    }
    
    // Java 8: Lambda expression
    public void withJava8() {
        Runnable runnable = () -> System.out.println("Running");
        new Thread(runnable).start();
        
        // Or inline
        new Thread(() -> System.out.println("Running")).start();
    }
    
    // Lambda with parameters
    public void lambdaWithParameters() {
        // No parameters
        Runnable r1 = () -> System.out.println("No params");
        
        // Single parameter (parentheses optional)
        Comparator<String> c1 = (s) -> s.length();
        Comparator<String> c2 = s -> s.length();  // Same
        
        // Multiple parameters
        Comparator<String> c3 = (s1, s2) -> s1.compareTo(s2);
        
        // Multiple statements (braces required)
        Comparator<String> c4 = (s1, s2) -> {
            System.out.println("Comparing: " + s1 + " and " + s2);
            return s1.compareTo(s2);
        };
        
        // With explicit return
        Comparator<Integer> c5 = (a, b) -> {
            return Integer.compare(a, b);
        };
    }
    
    // Lambda with type declarations
    public void lambdaWithTypes() {
        // Type inference (compiler infers types)
        Comparator<String> c1 = (s1, s2) -> s1.compareTo(s2);
        
        // Explicit types
        Comparator<String> c2 = (String s1, String s2) -> s1.compareTo(s2);
    }
    
    // Common use cases
    public void commonUseCases() {
        List<String> names = Arrays.asList("John", "Jane", "Bob", "Alice");
        
        // Sorting
        names.sort((s1, s2) -> s1.compareTo(s2));
        names.sort(String::compareTo);  // Method reference
        
        // Filtering
        names.removeIf(name -> name.startsWith("J"));
        
        // forEach
        names.forEach(name -> System.out.println(name));
        names.forEach(System.out::println);  // Method reference
        
        // Mapping
        List<Integer> lengths = new ArrayList<>();
        names.forEach(name -> lengths.add(name.length()));
    }
}
```

## 1.2 Lambda Scope and Variable Capture

```java
public class LambdaScope {
    
    private int instanceVar = 10;
    private static int staticVar = 20;
    
    public void demonstrateScope() {
        int localVar = 30;
        final int finalVar = 40;
        
        Runnable r = () -> {
            // Can access instance variables
            System.out.println("Instance: " + instanceVar);
            instanceVar++;  // Can modify
            
            // Can access static variables
            System.out.println("Static: " + staticVar);
            staticVar++;  // Can modify
            
            // Can access local variables (must be final or effectively final)
            System.out.println("Local: " + localVar);
            // localVar++;  // ERROR: Cannot modify
            
            System.out.println("Final: " + finalVar);
        };
        
        // localVar = 50;  // ERROR: Makes localVar not effectively final
        
        r.run();
    }
    
    // Effectively final
    public void effectivelyFinal() {
        int count = 0;  // Effectively final (not modified after initialization)
        
        Runnable r = () -> {
            System.out.println(count);  // OK
        };
        
        // count++;  // Would make it not effectively final
    }
    
    // Variable capture from enclosing scope
    public void variableCapture() {
        String prefix = "Hello, ";
        
        List<String> names = Arrays.asList("Alice", "Bob", "Charlie");
        names.forEach(name -> System.out.println(prefix + name));
        // Lambda captures 'prefix' from enclosing scope
    }
    
    // this reference in lambda
    public void thisReference() {
        // Lambda uses enclosing class's 'this'
        Runnable r = () -> {
            System.out.println(this.instanceVar);  // Refers to LambdaScope.this
        };
        
        // Compare with anonymous class
        Runnable r2 = new Runnable() {
            @Override
            public void run() {
                // System.out.println(this.instanceVar);  // ERROR: Runnable has no instanceVar
                System.out.println(LambdaScope.this.instanceVar);  // Must qualify
            }
        };
    }
}
```

---

# 2. FUNCTIONAL INTERFACES

## 2.1 Built-in Functional Interfaces

```java
import java.util.function.*;
import java.util.*;

public class FunctionalInterfacesDemo {
    
    // Function<T, R> - takes T, returns R
    public void demonstrateFunction() {
        Function<String, Integer> stringLength = s -> s.length();
        System.out.println(stringLength.apply("Hello"));  // 5
        
        Function<Integer, Integer> square = x -> x * x;
        System.out.println(square.apply(5));  // 25
        
        // Chaining functions
        Function<String, String> toUpper = s -> s.toUpperCase();
        Function<String, Integer> upperLength = toUpper.andThen(stringLength);
        System.out.println(upperLength.apply("hello"));  // 5
        
        Function<String, Integer> lengthUpper = stringLength.compose(toUpper);
        System.out.println(lengthUpper.apply("hello"));  // 5
    }
    
    // Predicate<T> - takes T, returns boolean
    public void demonstratePredicate() {
        Predicate<String> isEmpty = s -> s.isEmpty();
        System.out.println(isEmpty.test(""));  // true
        System.out.println(isEmpty.test("Hello"));  // false
        
        Predicate<Integer> isEven = n -> n % 2 == 0;
        Predicate<Integer> isPositive = n -> n > 0;
        
        // Combining predicates
        Predicate<Integer> isEvenAndPositive = isEven.and(isPositive);
        System.out.println(isEvenAndPositive.test(4));  // true
        System.out.println(isEvenAndPositive.test(-4));  // false
        
        Predicate<Integer> isEvenOrPositive = isEven.or(isPositive);
        System.out.println(isEvenOrPositive.test(3));  // true
        
        Predicate<Integer> isOdd = isEven.negate();
        System.out.println(isOdd.test(3));  // true
    }
    
    // Consumer<T> - takes T, returns nothing
    public void demonstrateConsumer() {
        Consumer<String> printUpperCase = s -> System.out.println(s.toUpperCase());
        printUpperCase.accept("hello");  // HELLO
        
        List<String> names = Arrays.asList("Alice", "Bob", "Charlie");
        names.forEach(printUpperCase);
        
        // Chaining consumers
        Consumer<String> print = System.out::println;
        Consumer<String> printLength = s -> System.out.println("Length: " + s.length());
        Consumer<String> printBoth = print.andThen(printLength);
        printBoth.accept("Hello");
    }
    
    // Supplier<T> - takes nothing, returns T
    public void demonstrateSupplier() {
        Supplier<Double> randomValue = () -> Math.random();
        System.out.println(randomValue.get());
        
        Supplier<String> greeting = () -> "Hello World";
        System.out.println(greeting.get());
        
        // Lazy evaluation
        Supplier<List<String>> expensiveList = () -> {
            System.out.println("Creating expensive list...");
            return Arrays.asList("A", "B", "C");
        };
        // List not created yet
        System.out.println("Before get()");
        List<String> list = expensiveList.get();  // Created here
        System.out.println(list);
    }
    
    // BiFunction<T, U, R> - takes T and U, returns R
    public void demonstrateBiFunction() {
        BiFunction<Integer, Integer, Integer> add = (a, b) -> a + b;
        System.out.println(add.apply(5, 3));  // 8
        
        BiFunction<String, String, String> concat = (s1, s2) -> s1 + s2;
        System.out.println(concat.apply("Hello", "World"));  // HelloWorld
        
        // With chaining
        BiFunction<String, String, Integer> concatLength = 
            concat.andThen(s -> s.length());
        System.out.println(concatLength.apply("Hello", "World"));  // 10
    }
    
    // BiPredicate<T, U> - takes T and U, returns boolean
    public void demonstrateBiPredicate() {
        BiPredicate<String, Integer> isLengthEqual = (s, len) -> s.length() == len;
        System.out.println(isLengthEqual.test("Hello", 5));  // true
        System.out.println(isLengthEqual.test("Hello", 3));  // false
    }
    
    // BiConsumer<T, U> - takes T and U, returns nothing
    public void demonstrateBiConsumer() {
        BiConsumer<String, Integer> printWithIndex = (s, i) -> 
            System.out.println(i + ": " + s);
        
        List<String> names = Arrays.asList("Alice", "Bob", "Charlie");
        for (int i = 0; i < names.size(); i++) {
            printWithIndex.accept(names.get(i), i);
        }
        
        // Map forEach
        Map<String, Integer> map = new HashMap<>();
        map.put("Alice", 25);
        map.put("Bob", 30);
        map.forEach((name, age) -> System.out.println(name + " is " + age));
    }
    
    // UnaryOperator<T> - Function<T, T>
    public void demonstrateUnaryOperator() {
        UnaryOperator<Integer> square = x -> x * x;
        System.out.println(square.apply(5));  // 25
        
        UnaryOperator<String> toUpper = s -> s.toUpperCase();
        List<String> names = Arrays.asList("alice", "bob");
        names.replaceAll(toUpper);  // [ALICE, BOB]
    }
    
    // BinaryOperator<T> - BiFunction<T, T, T>
    public void demonstrateBinaryOperator() {
        BinaryOperator<Integer> add = (a, b) -> a + b;
        System.out.println(add.apply(5, 3));  // 8
        
        BinaryOperator<String> concat = (s1, s2) -> s1 + s2;
        System.out.println(concat.apply("Hello", "World"));  // HelloWorld
        
        // Used in reduce
        List<Integer> numbers = Arrays.asList(1, 2, 3, 4, 5);
        int sum = numbers.stream().reduce(0, (a, b) -> a + b);
        System.out.println(sum);  // 15
    }
}
```

## 2.2 Custom Functional Interfaces

```java
public class CustomFunctionalInterfaces {
    
    // Custom functional interface
    @FunctionalInterface
    interface Calculator {
        int calculate(int a, int b);
        
        // Can have default methods
        default int add(int a, int b) {
            return a + b;
        }
        
        // Can have static methods
        static int multiply(int a, int b) {
            return a * b;
        }
    }
    
    // Usage
    public void useCustomInterface() {
        Calculator addition = (a, b) -> a + b;
        Calculator subtraction = (a, b) -> a - b;
        Calculator multiplication = (a, b) -> a * b;
        Calculator division = (a, b) -> a / b;
        
        System.out.println(addition.calculate(10, 5));  // 15
        System.out.println(subtraction.calculate(10, 5));  // 5
        System.out.println(multiplication.calculate(10, 5));  // 50
        System.out.println(division.calculate(10, 5));  // 2
    }
    
    // Generic functional interface
    @FunctionalInterface
    interface Transformer<T, R> {
        R transform(T input);
    }
    
    public void useGenericInterface() {
        Transformer<String, Integer> stringLength = s -> s.length();
        Transformer<Integer, String> intToString = i -> String.valueOf(i);
        
        System.out.println(stringLength.transform("Hello"));  // 5
        System.out.println(intToString.transform(42));  // "42"
    }
    
    // Functional interface with exceptions
    @FunctionalInterface
    interface ThrowingFunction<T, R> {
        R apply(T t) throws Exception;
    }
    
    public void useThrowingFunction() {
        ThrowingFunction<String, Integer> parse = s -> Integer.parseInt(s);
        
        try {
            System.out.println(parse.apply("123"));  // 123
            System.out.println(parse.apply("abc"));  // NumberFormatException
        } catch (Exception e) {
            System.out.println("Error: " + e.getMessage());
        }
    }
}
```

## 2.3 Real-World Example: Validation Framework

```java
import java.util.*;
import java.util.function.*;

public class ValidationFramework {
    
    // Validator functional interface
    @FunctionalInterface
    interface Validator<T> {
        ValidationResult validate(T value);
        
        default Validator<T> and(Validator<T> other) {
            return value -> {
                ValidationResult result = this.validate(value);
                return result.isValid() ? other.validate(value) : result;
            };
        }
    }
    
    // Validation result
    static class ValidationResult {
        private boolean valid;
        private String errorMessage;
        
        private ValidationResult(boolean valid, String errorMessage) {
            this.valid = valid;
            this.errorMessage = errorMessage;
        }
        
        public static ValidationResult valid() {
            return new ValidationResult(true, null);
        }
        
        public static ValidationResult invalid(String message) {
            return new ValidationResult(false, message);
        }
        
        public boolean isValid() {
            return valid;
        }
        
        public String getErrorMessage() {
            return errorMessage;
        }
    }
    
    // User entity
    static class User {
        private String username;
        private String email;
        private int age;
        
        public User(String username, String email, int age) {
            this.username = username;
            this.email = email;
            this.age = age;
        }
        
        public String getUsername() { return username; }
        public String getEmail() { return email; }
        public int getAge() { return age; }
    }
    
    // Validators
    static class UserValidators {
        
        public static Validator<User> usernameNotEmpty() {
            return user -> {
                if (user.getUsername() == null || user.getUsername().isEmpty()) {
                    return ValidationResult.invalid("Username cannot be empty");
                }
                return ValidationResult.valid();
            };
        }
        
        public static Validator<User> usernameLength(int min, int max) {
            return user -> {
                int length = user.getUsername().length();
                if (length < min || length > max) {
                    return ValidationResult.invalid(
                        String.format("Username must be between %d and %d characters", min, max)
                    );
                }
                return ValidationResult.valid();
            };
        }
        
        public static Validator<User> emailValid() {
            return user -> {
                String email = user.getEmail();
                if (email == null || !email.matches("^[A-Za-z0-9+_.-]+@(.+)$")) {
                    return ValidationResult.invalid("Invalid email format");
                }
                return ValidationResult.valid();
            };
        }
        
        public static Validator<User> ageRange(int min, int max) {
            return user -> {
                int age = user.getAge();
                if (age < min || age > max) {
                    return ValidationResult.invalid(
                        String.format("Age must be between %d and %d", min, max)
                    );
                }
                return ValidationResult.valid();
            };
        }
    }
    
    // Usage
    public static void main(String[] args) {
        // Compose validators
        Validator<User> userValidator = 
            UserValidators.usernameNotEmpty()
                .and(UserValidators.usernameLength(3, 20))
                .and(UserValidators.emailValid())
                .and(UserValidators.ageRange(18, 100));
        
        // Valid user
        User validUser = new User("john_doe", "john@example.com", 25);
        ValidationResult result1 = userValidator.validate(validUser);
        System.out.println("Valid user: " + result1.isValid());
        
        // Invalid username
        User invalidUser1 = new User("jo", "john@example.com", 25);
        ValidationResult result2 = userValidator.validate(invalidUser1);
        System.out.println("Invalid username: " + result2.isValid() + 
                         " - " + result2.getErrorMessage());
        
        // Invalid email
        User invalidUser2 = new User("john_doe", "invalid-email", 25);
        ValidationResult result3 = userValidator.validate(invalidUser2);
        System.out.println("Invalid email: " + result3.isValid() + 
                         " - " + result3.getErrorMessage());
        
        // Invalid age
        User invalidUser3 = new User("john_doe", "john@example.com", 150);
        ValidationResult result4 = userValidator.validate(invalidUser3);
        System.out.println("Invalid age: " + result4.isValid() + 
                         " - " + result4.getErrorMessage());
    }
}
```

---

# 3. METHOD REFERENCES

## 3.1 Types of Method References

```java
import java.util.*;
import java.util.function.*;

public class MethodReferencesDemo {
    
    // 1. Static method reference: ClassName::staticMethod
    public void staticMethodReference() {
        // Lambda
        Function<String, Integer> lambda = s -> Integer.parseInt(s);
        
        // Method reference
        Function<String, Integer> methodRef = Integer::parseInt;
        
        System.out.println(methodRef.apply("123"));  // 123
        
        // Examples
        List<String> numbers = Arrays.asList("1", "2", "3");
        numbers.stream()
               .map(Integer::parseInt)  // Static method reference
               .forEach(System.out::println);
    }
    
    // 2. Instance method reference: object::instanceMethod
    public void instanceMethodReference() {
        String prefix = "Hello, ";
        
        // Lambda
        Function<String, String> lambda = s -> prefix.concat(s);
        
        // Method reference
        Function<String, String> methodRef = prefix::concat;
        
        System.out.println(methodRef.apply("World"));  // Hello, World
        
        // Examples
        List<String> names = Arrays.asList("Alice", "Bob", "Charlie");
        names.forEach(System.out::println);  // Instance method of System.out
    }
    
    // 3. Instance method of arbitrary object: ClassName::instanceMethod
    public void arbitraryObjectMethodReference() {
        // Lambda
        Comparator<String> lambda = (s1, s2) -> s1.compareToIgnoreCase(s2);
        
        // Method reference
        Comparator<String> methodRef = String::compareToIgnoreCase;
        
        List<String> names = Arrays.asList("Charlie", "alice", "Bob");
        names.sort(String::compareToIgnoreCase);
        System.out.println(names);  // [alice, Bob, Charlie]
        
        // More examples
        List<String> strings = Arrays.asList("a", "b", "c");
        strings.stream()
               .map(String::toUpperCase)  // Each string's toUpperCase()
               .forEach(System.out::println);
    }
    
    // 4. Constructor reference: ClassName::new
    public void constructorReference() {
        // Lambda
        Supplier<List<String>> lambda = () -> new ArrayList<>();
        
        // Constructor reference
        Supplier<List<String>> methodRef = ArrayList::new;
        
        List<String> list = methodRef.get();
        list.add("Item");
        
        // With parameters
        Function<String, Integer> intConstructor = Integer::new;
        Integer num = intConstructor.apply("123");
        System.out.println(num);  // 123
        
        // Array constructor
        IntFunction<int[]> arrayCreator = int[]::new;
        int[] array = arrayCreator.apply(10);  // Creates array of size 10
    }
    
    // Practical examples
    public void practicalExamples() {
        List<String> names = Arrays.asList("Alice", "Bob", "Charlie", "David");
        
        // Static method reference
        names.stream()
             .map(String::valueOf)  // String.valueOf(name)
             .forEach(System.out::println);
        
        // Instance method reference (specific object)
        PrintStream out = System.out;
        names.forEach(out::println);
        
        // Instance method reference (arbitrary object)
        List<Integer> lengths = names.stream()
                                     .map(String::length)  // name.length()
                                     .collect(java.util.stream.Collectors.toList());
        
        // Constructor reference
        List<String> copy = names.stream()
                                 .collect(java.util.stream.Collectors.toCollection(ArrayList::new));
    }
}
```

## 3.2 Custom Class with Method References

```java
import java.util.*;
import java.util.function.*;

public class CustomMethodReferences {
    
    static class Person {
        private String name;
        private int age;
        
        public Person(String name, int age) {
            this.name = name;
            this.age = age;
        }
        
        public String getName() { return name; }
        public int getAge() { return age; }
        
        public void printInfo() {
            System.out.println(name + " is " + age + " years old");
        }
        
        public static Person createPerson(String name, int age) {
            return new Person(name, age);
        }
        
        public static int compareByAge(Person p1, Person p2) {
            return Integer.compare(p1.age, p2.age);
        }
        
        @Override
        public String toString() {
            return name + "(" + age + ")";
        }
    }
    
    public static void main(String[] args) {
        List<Person> people = Arrays.asList(
            new Person("Alice", 30),
            new Person("Bob", 25),
            new Person("Charlie", 35)
        );
        
        // Instance method reference - forEach
        people.forEach(Person::printInfo);
        
        // Instance method reference - sorting
        people.sort(Comparator.comparing(Person::getAge));
        System.out.println(people);  // Sorted by age
        
        // Static method reference - comparison
        people.sort(Person::compareByAge);
        System.out.println(people);
        
        // Constructor reference
        BiFunction<String, Integer, Person> personFactory = Person::new;
        Person person = personFactory.apply("David", 28);
        person.printInfo();
        
        // Static method reference - factory
        BiFunction<String, Integer, Person> staticFactory = Person::createPerson;
        Person person2 = staticFactory.apply("Eve", 32);
        person2.printInfo();
    }
}
```

---

# 4. STREAM API

## 4.1 Creating Streams

```java
import java.util.*;
import java.util.stream.*;

public class StreamCreation {
    
    public void createStreamsFromCollections() {
        // From List
        List<String> list = Arrays.asList("A", "B", "C");
        Stream<String> stream1 = list.stream();
        
        // From Set
        Set<Integer> set = new HashSet<>(Arrays.asList(1, 2, 3));
        Stream<Integer> stream2 = set.stream();
        
        // From Map
        Map<String, Integer> map = new HashMap<>();
        map.put("A", 1);
        map.put("B", 2);
        
        Stream<Map.Entry<String, Integer>> stream3 = map.entrySet().stream();
        Stream<String> keyStream = map.keySet().stream();
        Stream<Integer> valueStream = map.values().stream();
    }
    
    public void createStreamsFromArrays() {
        // From array
        String[] array = {"A", "B", "C"};
        Stream<String> stream1 = Arrays.stream(array);
        Stream<String> stream2 = Stream.of(array);
        
        // Primitive streams
        int[] numbers = {1, 2, 3, 4, 5};
        IntStream intStream = Arrays.stream(numbers);
        
        // Stream.of with varargs
        Stream<String> stream3 = Stream.of("A", "B", "C");
        Stream<Integer> stream4 = Stream.of(1, 2, 3);
    }
    
    public void createStreamsWithBuilders() {
        // Stream.builder
        Stream<String> stream = Stream.<String>builder()
            .add("A")
            .add("B")
            .add("C")
            .build();
        
        // Empty stream
        Stream<String> emptyStream = Stream.empty();
    }
    
    public void createInfiniteStreams() {
        // Stream.generate - infinite stream
        Stream<Double> randomNumbers = Stream.generate(Math::random);
        randomNumbers.limit(5).forEach(System.out::println);
        
        Stream<String> constantStream = Stream.generate(() -> "Hello");
        constantStream.limit(3).forEach(System.out::println);
        
        // Stream.iterate - infinite stream with seed
        Stream<Integer> evenNumbers = Stream.iterate(0, n -> n + 2);
        evenNumbers.limit(10).forEach(System.out::println);  // 0, 2, 4, ..., 18
        
        // Java 9+: iterate with predicate
        Stream<Integer> numbers = Stream.iterate(1, n -> n <= 10, n -> n + 1);
        numbers.forEach(System.out::println);  // 1 to 10
    }
    
    public void createStreamsFromOtherSources() {
        // From String
        String text = "Hello";
        IntStream charStream = text.chars();  // Stream of char codes
        charStream.forEach(c -> System.out.print((char) c + " "));
        
        // From lines
        Stream<String> lines = "Line1\nLine2\nLine3".lines();  // Java 11+
        
        // From Optional
        Optional<String> optional = Optional.of("Hello");
        Stream<String> optionalStream = optional.stream();  // Java 9+
    }
}
```

## 4.2 Intermediate Operations

```java
import java.util.*;
import java.util.stream.*;

public class IntermediateOperations {
    
    // filter - select elements
    public void demonstrateFilter() {
        List<Integer> numbers = Arrays.asList(1, 2, 3, 4, 5, 6, 7, 8, 9, 10);
        
        // Even numbers
        List<Integer> evenNumbers = numbers.stream()
            .filter(n -> n % 2 == 0)
            .collect(Collectors.toList());
        System.out.println(evenNumbers);  // [2, 4, 6, 8, 10]
        
        // Multiple filters
        List<Integer> result = numbers.stream()
            .filter(n -> n > 3)            // Greater than 3
            .filter(n -> n % 2 == 0)       // Even
            .collect(Collectors.toList());
        System.out.println(result);  // [4, 6, 8, 10]
    }
    
    // map - transform elements
    public void demonstrateMap() {
        List<String> names = Arrays.asList("Alice", "Bob", "Charlie");
        
        // To uppercase
        List<String> upperNames = names.stream()
            .map(String::toUpperCase)
            .collect(Collectors.toList());
        System.out.println(upperNames);  // [ALICE, BOB, CHARLIE]
        
        // To lengths
        List<Integer> lengths = names.stream()
            .map(String::length)
            .collect(Collectors.toList());
        System.out.println(lengths);  // [5, 3, 7]
        
        // Complex transformation
        List<String> prefixed = names.stream()
            .map(name -> "Mr. " + name)
            .collect(Collectors.toList());
        System.out.println(prefixed);  // [Mr. Alice, Mr. Bob, Mr. Charlie]
    }
    
    // flatMap - flatten nested structures
    public void demonstrateFlatMap() {
        List<List<Integer>> nestedList = Arrays.asList(
            Arrays.asList(1, 2, 3),
            Arrays.asList(4, 5, 6),
            Arrays.asList(7, 8, 9)
        );
        
        // Flatten to single list
        List<Integer> flatList = nestedList.stream()
            .flatMap(List::stream)
            .collect(Collectors.toList());
        System.out.println(flatList);  // [1, 2, 3, 4, 5, 6, 7, 8, 9]
        
        // Split strings and flatten
        List<String> sentences = Arrays.asList("Hello World", "Java Streams");
        List<String> words = sentences.stream()
            .flatMap(sentence -> Arrays.stream(sentence.split(" ")))
            .collect(Collectors.toList());
        System.out.println(words);  // [Hello, World, Java, Streams]
    }
    
    // distinct - remove duplicates
    public void demonstrateDistinct() {
        List<Integer> numbers = Arrays.asList(1, 2, 2, 3, 3, 3, 4, 5, 5);
        
        List<Integer> distinct = numbers.stream()
            .distinct()
            .collect(Collectors.toList());
        System.out.println(distinct);  // [1, 2, 3, 4, 5]
    }
    
    // sorted - sort elements
    public void demonstrateSorted() {
        List<Integer> numbers = Arrays.asList(5, 2, 8, 1, 9, 3);
        
        // Natural order
        List<Integer> sorted = numbers.stream()
            .sorted()
            .collect(Collectors.toList());
        System.out.println(sorted);  // [1, 2, 3, 5, 8, 9]
        
        // Custom comparator
        List<Integer> reverseSorted = numbers.stream()
            .sorted(Comparator.reverseOrder())
            .collect(Collectors.toList());
        System.out.println(reverseSorted);  // [9, 8, 5, 3, 2, 1]
        
        // Sorting objects
        List<String> names = Arrays.asList("Charlie", "Alice", "Bob");
        List<String> sortedNames = names.stream()
            .sorted(Comparator.comparing(String::length))
            .collect(Collectors.toList());
        System.out.println(sortedNames);  // [Bob, Alice, Charlie]
    }
    
    // peek - perform action without modifying stream
    public void demonstratePeek() {
        List<Integer> numbers = Arrays.asList(1, 2, 3, 4, 5);
        
        List<Integer> result = numbers.stream()
            .peek(n -> System.out.println("Before filter: " + n))
            .filter(n -> n % 2 == 0)
            .peek(n -> System.out.println("After filter: " + n))
            .map(n -> n * 2)
            .peek(n -> System.out.println("After map: " + n))
            .collect(Collectors.toList());
        
        System.out.println("Result: " + result);
    }
    
    // limit and skip
    public void demonstrateLimitSkip() {
        List<Integer> numbers = Arrays.asList(1, 2, 3, 4, 5, 6, 7, 8, 9, 10);
        
        // First 5 elements
        List<Integer> first5 = numbers.stream()
            .limit(5)
            .collect(Collectors.toList());
        System.out.println(first5);  // [1, 2, 3, 4, 5]
        
        // Skip first 5 elements
        List<Integer> after5 = numbers.stream()
            .skip(5)
            .collect(Collectors.toList());
        System.out.println(after5);  // [6, 7, 8, 9, 10]
        
        // Pagination: skip first 5, take next 3
        List<Integer> page = numbers.stream()
            .skip(5)
            .limit(3)
            .collect(Collectors.toList());
        System.out.println(page);  // [6, 7, 8]
    }
    
    // takeWhile and dropWhile (Java 9+)
    public void demonstrateTakeDropWhile() {
        List<Integer> numbers = Arrays.asList(1, 2, 3, 4, 5, 1, 2, 3);
        
        // takeWhile - take elements while condition is true
        List<Integer> taken = numbers.stream()
            .takeWhile(n -> n < 4)
            .collect(Collectors.toList());
        System.out.println(taken);  // [1, 2, 3]
        
        // dropWhile - drop elements while condition is true
        List<Integer> dropped = numbers.stream()
            .dropWhile(n -> n < 4)
            .collect(Collectors.toList());
        System.out.println(dropped);  // [4, 5, 1, 2, 3]
    }
}
```

---

**Part 1 Complete!** ✅

Covered:
- Lambda Expressions (syntax, scope, variable capture) ✅
- Functional Interfaces (Predicate, Function, Consumer, Supplier, etc.) ✅
- Method References (all 4 types) ✅
- Stream API Creation & Intermediate Operations ✅
- Real-World Example (Validation Framework) ✅

## 4.3 Terminal Operations

```java
import java.util.*;
import java.util.stream.*;

public class TerminalOperations {
    
    // collect - collect stream elements into collection
    public void demonstrateCollect() {
        List<String> names = Arrays.asList("Alice", "Bob", "Charlie", "Alice");
        
        // To List
        List<String> list = names.stream()
            .collect(Collectors.toList());
        
        // To Set (removes duplicates)
        Set<String> set = names.stream()
            .collect(Collectors.toSet());
        System.out.println(set);  // [Alice, Bob, Charlie]
        
        // To specific collection
        LinkedList<String> linkedList = names.stream()
            .collect(Collectors.toCollection(LinkedList::new));
        
        // To Map
        Map<String, Integer> nameLength = names.stream()
            .distinct()
            .collect(Collectors.toMap(
                name -> name,           // Key
                String::length          // Value
            ));
        System.out.println(nameLength);  // {Alice=5, Bob=3, Charlie=7}
        
        // Joining strings
        String joined = names.stream()
            .collect(Collectors.joining(", "));
        System.out.println(joined);  // Alice, Bob, Charlie, Alice
        
        String csv = names.stream()
            .collect(Collectors.joining(", ", "[", "]"));
        System.out.println(csv);  // [Alice, Bob, Charlie, Alice]
    }
    
    // reduce - combine elements to single result
    public void demonstrateReduce() {
        List<Integer> numbers = Arrays.asList(1, 2, 3, 4, 5);
        
        // Sum with identity
        int sum = numbers.stream()
            .reduce(0, (a, b) -> a + b);
        System.out.println(sum);  // 15
        
        // Product
        int product = numbers.stream()
            .reduce(1, (a, b) -> a * b);
        System.out.println(product);  // 120
        
        // Max value (returns Optional)
        Optional<Integer> max = numbers.stream()
            .reduce((a, b) -> a > b ? a : b);
        max.ifPresent(System.out::println);  // 5
        
        // Using Integer::max
        Optional<Integer> max2 = numbers.stream()
            .reduce(Integer::max);
        System.out.println(max2.get());  // 5
        
        // String concatenation
        List<String> words = Arrays.asList("Java", "Streams", "Are", "Powerful");
        String sentence = words.stream()
            .reduce("", (s1, s2) -> s1 + " " + s2);
        System.out.println(sentence.trim());  // Java Streams Are Powerful
    }
    
    // forEach - perform action on each element
    public void demonstrateForEach() {
        List<String> names = Arrays.asList("Alice", "Bob", "Charlie");
        
        // Simple forEach
        names.stream()
            .forEach(System.out::println);
        
        // With side effects (not recommended in streams)
        List<String> result = new ArrayList<>();
        names.stream()
            .forEach(name -> result.add(name.toUpperCase()));
        System.out.println(result);
        
        // forEachOrdered - maintains order in parallel streams
        names.parallelStream()
            .forEachOrdered(System.out::println);
    }
    
    // count, min, max
    public void demonstrateCountMinMax() {
        List<Integer> numbers = Arrays.asList(1, 2, 3, 4, 5);
        
        // Count
        long count = numbers.stream()
            .filter(n -> n > 2)
            .count();
        System.out.println(count);  // 3
        
        // Min
        Optional<Integer> min = numbers.stream()
            .min(Integer::compareTo);
        System.out.println(min.get());  // 1
        
        // Max
        Optional<Integer> max = numbers.stream()
            .max(Integer::compareTo);
        System.out.println(max.get());  // 5
        
        // With custom comparator
        List<String> names = Arrays.asList("Alice", "Bob", "Charlie");
        Optional<String> longest = names.stream()
            .max(Comparator.comparing(String::length));
        System.out.println(longest.get());  // Charlie
    }
    
    // anyMatch, allMatch, noneMatch
    public void demonstrateMatching() {
        List<Integer> numbers = Arrays.asList(1, 2, 3, 4, 5);
        
        // anyMatch - at least one element matches
        boolean hasEven = numbers.stream()
            .anyMatch(n -> n % 2 == 0);
        System.out.println(hasEven);  // true
        
        // allMatch - all elements match
        boolean allPositive = numbers.stream()
            .allMatch(n -> n > 0);
        System.out.println(allPositive);  // true
        
        // noneMatch - no elements match
        boolean noNegative = numbers.stream()
            .noneMatch(n -> n < 0);
        System.out.println(noNegative);  // true
    }
    
    // findFirst, findAny
    public void demonstrateFind() {
        List<String> names = Arrays.asList("Alice", "Bob", "Charlie", "David");
        
        // findFirst - first element
        Optional<String> first = names.stream()
            .filter(name -> name.startsWith("C"))
            .findFirst();
        System.out.println(first.get());  // Charlie
        
        // findAny - any element (useful for parallel streams)
        Optional<String> any = names.parallelStream()
            .filter(name -> name.length() > 3)
            .findAny();
        System.out.println(any.get());  // Any of: Alice, Charlie, David
    }
    
    // toArray
    public void demonstrateToArray() {
        List<String> names = Arrays.asList("Alice", "Bob", "Charlie");
        
        // To Object array
        Object[] array1 = names.stream().toArray();
        
        // To specific type array
        String[] array2 = names.stream().toArray(String[]::new);
        System.out.println(Arrays.toString(array2));  // [Alice, Bob, Charlie]
    }
}
```

## 4.4 Advanced Collectors

```java
import java.util.*;
import java.util.stream.*;

public class AdvancedCollectors {
    
    static class Employee {
        private String name;
        private String department;
        private int salary;
        
        public Employee(String name, String department, int salary) {
            this.name = name;
            this.department = department;
            this.salary = salary;
        }
        
        public String getName() { return name; }
        public String getDepartment() { return department; }
        public int getSalary() { return salary; }
        
        @Override
        public String toString() {
            return name + "(" + department + ", $" + salary + ")";
        }
    }
    
    public void demonstrateGroupingBy() {
        List<Employee> employees = Arrays.asList(
            new Employee("Alice", "IT", 80000),
            new Employee("Bob", "HR", 60000),
            new Employee("Charlie", "IT", 90000),
            new Employee("David", "HR", 65000),
            new Employee("Eve", "IT", 85000)
        );
        
        // Group by department
        Map<String, List<Employee>> byDept = employees.stream()
            .collect(Collectors.groupingBy(Employee::getDepartment));
        System.out.println(byDept);
        
        // Group by and count
        Map<String, Long> countByDept = employees.stream()
            .collect(Collectors.groupingBy(
                Employee::getDepartment,
                Collectors.counting()
            ));
        System.out.println(countByDept);  // {IT=3, HR=2}
        
        // Group by and average salary
        Map<String, Double> avgSalaryByDept = employees.stream()
            .collect(Collectors.groupingBy(
                Employee::getDepartment,
                Collectors.averagingInt(Employee::getSalary)
            ));
        System.out.println(avgSalaryByDept);  // {IT=85000.0, HR=62500.0}
        
        // Group by and sum salary
        Map<String, Integer> totalSalaryByDept = employees.stream()
            .collect(Collectors.groupingBy(
                Employee::getDepartment,
                Collectors.summingInt(Employee::getSalary)
            ));
        System.out.println(totalSalaryByDept);  // {IT=255000, HR=125000}
    }
    
    public void demonstratePartitioningBy() {
        List<Employee> employees = Arrays.asList(
            new Employee("Alice", "IT", 80000),
            new Employee("Bob", "HR", 60000),
            new Employee("Charlie", "IT", 90000),
            new Employee("David", "HR", 65000)
        );
        
        // Partition by salary > 70000
        Map<Boolean, List<Employee>> partitioned = employees.stream()
            .collect(Collectors.partitioningBy(e -> e.getSalary() > 70000));
        
        System.out.println("High earners: " + partitioned.get(true));
        System.out.println("Low earners: " + partitioned.get(false));
    }
    
    public void demonstrateSummarizingStatistics() {
        List<Integer> numbers = Arrays.asList(1, 2, 3, 4, 5, 6, 7, 8, 9, 10);
        
        IntSummaryStatistics stats = numbers.stream()
            .collect(Collectors.summarizingInt(Integer::intValue));
        
        System.out.println("Count: " + stats.getCount());      // 10
        System.out.println("Sum: " + stats.getSum());          // 55
        System.out.println("Min: " + stats.getMin());          // 1
        System.out.println("Max: " + stats.getMax());          // 10
        System.out.println("Average: " + stats.getAverage());  // 5.5
    }
    
    public void demonstrateMapping() {
        List<Employee> employees = Arrays.asList(
            new Employee("Alice", "IT", 80000),
            new Employee("Bob", "HR", 60000),
            new Employee("Charlie", "IT", 90000)
        );
        
        // Group by department, collect names
        Map<String, List<String>> namesByDept = employees.stream()
            .collect(Collectors.groupingBy(
                Employee::getDepartment,
                Collectors.mapping(Employee::getName, Collectors.toList())
            ));
        System.out.println(namesByDept);  // {IT=[Alice, Charlie], HR=[Bob]}
    }
}
```

## 4.5 Parallel Streams

```java
import java.util.*;
import java.util.stream.*;

public class ParallelStreamsDemo {
    
    public void createParallelStreams() {
        List<Integer> numbers = Arrays.asList(1, 2, 3, 4, 5);
        
        // From sequential stream
        numbers.stream().parallel()
            .forEach(System.out::println);
        
        // Direct parallel stream
        numbers.parallelStream()
            .forEach(System.out::println);
        
        // Convert back to sequential
        numbers.parallelStream()
            .sequential()
            .forEach(System.out::println);
    }
    
    public void performanceComparison() {
        List<Integer> numbers = IntStream.rangeClosed(1, 10_000_000)
            .boxed()
            .collect(Collectors.toList());
        
        // Sequential
        long start = System.currentTimeMillis();
        long sum1 = numbers.stream()
            .mapToLong(Integer::longValue)
            .sum();
        long sequential = System.currentTimeMillis() - start;
        System.out.println("Sequential: " + sequential + "ms, Sum: " + sum1);
        
        // Parallel
        start = System.currentTimeMillis();
        long sum2 = numbers.parallelStream()
            .mapToLong(Integer::longValue)
            .sum();
        long parallel = System.currentTimeMillis() - start;
        System.out.println("Parallel: " + parallel + "ms, Sum: " + sum2);
    }
    
    // When NOT to use parallel streams
    public void parallelStreamPitfalls() {
        List<Integer> numbers = Arrays.asList(1, 2, 3, 4, 5);
        
        // BAD: Side effects with shared mutable state
        List<Integer> result = new ArrayList<>();
        numbers.parallelStream()
            .forEach(n -> result.add(n * 2));  // NOT thread-safe!
        
        // GOOD: Use collectors
        List<Integer> result2 = numbers.parallelStream()
            .map(n -> n * 2)
            .collect(Collectors.toList());
        
        // BAD: Order-dependent operations
        numbers.parallelStream()
            .forEach(System.out::println);  // Order not guaranteed
        
        // GOOD: Use forEachOrdered if order matters
        numbers.parallelStream()
            .forEachOrdered(System.out::println);  // Maintains order
    }
}
```

## 4.6 Real-World Example: Transaction Processing

```java
import java.util.*;
import java.util.stream.*;

public class TransactionProcessing {
    
    static class Transaction {
        private String id;
        private String customerId;
        private String type;  // "DEPOSIT", "WITHDRAWAL", "TRANSFER"
        private double amount;
        private Date date;
        
        public Transaction(String id, String customerId, String type, 
                          double amount, Date date) {
            this.id = id;
            this.customerId = customerId;
            this.type = type;
            this.amount = amount;
            this.date = date;
        }
        
        public String getId() { return id; }
        public String getCustomerId() { return customerId; }
        public String getType() { return type; }
        public double getAmount() { return amount; }
        public Date getDate() { return date; }
        
        @Override
        public String toString() {
            return String.format("%s: %s $%.2f", id, type, amount);
        }
    }
    
    public static void main(String[] args) {
        List<Transaction> transactions = Arrays.asList(
            new Transaction("T1", "C001", "DEPOSIT", 1000, new Date()),
            new Transaction("T2", "C002", "WITHDRAWAL", 500, new Date()),
            new Transaction("T3", "C001", "TRANSFER", 200, new Date()),
            new Transaction("T4", "C003", "DEPOSIT", 1500, new Date()),
            new Transaction("T5", "C002", "DEPOSIT", 800, new Date()),
            new Transaction("T6", "C001", "WITHDRAWAL", 300, new Date()),
            new Transaction("T7", "C003", "TRANSFER", 400, new Date()),
            new Transaction("T8", "C001", "DEPOSIT", 2000, new Date())
        );
        
        // 1. Find all deposits greater than 1000
        System.out.println("=== Large Deposits ===");
        List<Transaction> largeDeposits = transactions.stream()
            .filter(t -> "DEPOSIT".equals(t.getType()))
            .filter(t -> t.getAmount() > 1000)
            .collect(Collectors.toList());
        largeDeposits.forEach(System.out::println);
        
        // 2. Group transactions by customer
        System.out.println("\n=== Transactions by Customer ===");
        Map<String, List<Transaction>> byCustomer = transactions.stream()
            .collect(Collectors.groupingBy(Transaction::getCustomerId));
        byCustomer.forEach((customerId, txns) -> {
            System.out.println(customerId + ": " + txns.size() + " transactions");
        });
        
        // 3. Total amount by transaction type
        System.out.println("\n=== Total by Type ===");
        Map<String, Double> totalByType = transactions.stream()
            .collect(Collectors.groupingBy(
                Transaction::getType,
                Collectors.summingDouble(Transaction::getAmount)
            ));
        totalByType.forEach((type, total) -> 
            System.out.printf("%s: $%.2f%n", type, total));
        
        // 4. Customer with highest total transaction amount
        System.out.println("\n=== Top Customer ===");
        Map<String, Double> totalByCustomer = transactions.stream()
            .collect(Collectors.groupingBy(
                Transaction::getCustomerId,
                Collectors.summingDouble(Transaction::getAmount)
            ));
        
        Optional<Map.Entry<String, Double>> topCustomer = totalByCustomer.entrySet().stream()
            .max(Map.Entry.comparingByValue());
        topCustomer.ifPresent(entry -> 
            System.out.printf("%s: $%.2f%n", entry.getKey(), entry.getValue()));
        
        // 5. Average transaction amount by type
        System.out.println("\n=== Average by Type ===");
        Map<String, Double> avgByType = transactions.stream()
            .collect(Collectors.groupingBy(
                Transaction::getType,
                Collectors.averagingDouble(Transaction::getAmount)
            ));
        avgByType.forEach((type, avg) -> 
            System.out.printf("%s: $%.2f%n", type, avg));
        
        // 6. Get transaction IDs for withdrawals
        System.out.println("\n=== Withdrawal IDs ===");
        String withdrawalIds = transactions.stream()
            .filter(t -> "WITHDRAWAL".equals(t.getType()))
            .map(Transaction::getId)
            .collect(Collectors.joining(", "));
        System.out.println(withdrawalIds);
        
        // 7. Statistics for all transaction amounts
        System.out.println("\n=== Transaction Statistics ===");
        DoubleSummaryStatistics stats = transactions.stream()
            .collect(Collectors.summarizingDouble(Transaction::getAmount));
        System.out.println("Count: " + stats.getCount());
        System.out.printf("Total: $%.2f%n", stats.getSum());
        System.out.printf("Average: $%.2f%n", stats.getAverage());
        System.out.printf("Min: $%.2f%n", stats.getMin());
        System.out.printf("Max: $%.2f%n", stats.getMax());
        
        // 8. Partition transactions: high value (>= 1000) vs low value
        System.out.println("\n=== High vs Low Value ===");
        Map<Boolean, List<Transaction>> partitioned = transactions.stream()
            .collect(Collectors.partitioningBy(t -> t.getAmount() >= 1000));
        System.out.println("High value (" + partitioned.get(true).size() + "): " + 
                          partitioned.get(true));
        System.out.println("Low value (" + partitioned.get(false).size() + "): " + 
                          partitioned.get(false));
    }
}
```

---

# 5. OPTIONAL

## 5.1 Creating and Using Optional

```java
import java.util.*;

public class OptionalBasics {
    
    public void creatingOptionals() {
        // Empty Optional
        Optional<String> empty = Optional.empty();
        System.out.println(empty.isPresent());  // false
        
        // Optional with non-null value
        Optional<String> notEmpty = Optional.of("Hello");
        System.out.println(notEmpty.isPresent());  // true
        
        // Optional.of with null throws NullPointerException
        try {
            Optional<String> nullOpt = Optional.of(null);
        } catch (NullPointerException e) {
            System.out.println("Cannot create Optional.of(null)");
        }
        
        // Optional with potentially null value
        String value = null;
        Optional<String> nullable = Optional.ofNullable(value);
        System.out.println(nullable.isPresent());  // false
        
        value = "World";
        nullable = Optional.ofNullable(value);
        System.out.println(nullable.isPresent());  // true
    }
    
    public void checkingPresence() {
        Optional<String> optional = Optional.of("Hello");
        
        // isPresent
        if (optional.isPresent()) {
            System.out.println(optional.get());
        }
        
        // isEmpty (Java 11+)
        if (optional.isEmpty()) {
            System.out.println("Empty");
        }
        
        // ifPresent with Consumer
        optional.ifPresent(value -> System.out.println(value));
        optional.ifPresent(System.out::println);
    }
    
    public void gettingValues() {
        Optional<String> optional = Optional.of("Hello");
        
        // get - throws NoSuchElementException if empty
        String value = optional.get();
        System.out.println(value);
        
        // orElse - return default if empty
        String result1 = optional.orElse("Default");
        System.out.println(result1);  // Hello
        
        Optional<String> empty = Optional.empty();
        String result2 = empty.orElse("Default");
        System.out.println(result2);  // Default
        
        // orElseGet - return from Supplier if empty (lazy evaluation)
        String result3 = empty.orElseGet(() -> {
            System.out.println("Computing default...");
            return "Computed Default";
        });
        
        // orElseThrow - throw exception if empty
        try {
            String result4 = empty.orElseThrow();  // Java 10+
        } catch (NoSuchElementException e) {
            System.out.println("Empty optional");
        }
        
        // orElseThrow with custom exception
        try {
            String result5 = empty.orElseThrow(() -> 
                new IllegalStateException("Value not found"));
        } catch (IllegalStateException e) {
            System.out.println(e.getMessage());
        }
    }
    
    public void transformingOptionals() {
        Optional<String> optional = Optional.of("hello");
        
        // map - transform value
        Optional<String> upper = optional.map(String::toUpperCase);
        System.out.println(upper.get());  // HELLO
        
        Optional<Integer> length = optional.map(String::length);
        System.out.println(length.get());  // 5
        
        // flatMap - avoid nested Optionals
        Optional<Optional<String>> nested = optional.map(s -> Optional.of(s.toUpperCase()));
        Optional<String> flat = optional.flatMap(s -> Optional.of(s.toUpperCase()));
        
        System.out.println(flat.get());  // HELLO
    }
    
    public void filteringOptionals() {
        Optional<Integer> optional = Optional.of(42);
        
        // filter - keep value only if predicate matches
        Optional<Integer> even = optional.filter(n -> n % 2 == 0);
        System.out.println(even.isPresent());  // true
        
        Optional<Integer> odd = optional.filter(n -> n % 2 != 0);
        System.out.println(odd.isPresent());  // false
    }
    
    // Java 9+ methods
    public void java9Methods() {
        Optional<String> optional = Optional.of("Hello");
        Optional<String> empty = Optional.empty();
        
        // ifPresentOrElse
        optional.ifPresentOrElse(
            value -> System.out.println("Present: " + value),
            () -> System.out.println("Empty")
        );
        
        // or - return alternative Optional if empty
        Optional<String> result = empty.or(() -> Optional.of("Alternative"));
        System.out.println(result.get());  // Alternative
        
        // stream - convert to Stream
        List<String> list = optional.stream()
            .map(String::toUpperCase)
            .collect(java.util.stream.Collectors.toList());
        System.out.println(list);  // [HELLO]
    }
}
```

## 5.2 Optional Anti-Patterns and Best Practices

```java
import java.util.*;

public class OptionalBestPractices {
    
    static class User {
        private String name;
        private String email;
        private Address address;
        
        public User(String name, String email) {
            this.name = name;
            this.email = email;
        }
        
        public String getName() { return name; }
        public Optional<String> getEmail() { 
            return Optional.ofNullable(email); 
        }
        public Optional<Address> getAddress() { 
            return Optional.ofNullable(address); 
        }
        public void setAddress(Address address) { 
            this.address = address; 
        }
    }
    
    static class Address {
        private String city;
        
        public Address(String city) {
            this.city = city;
        }
        
        public String getCity() { return city; }
    }
    
    // ❌ BAD: Using get() without checking
    public String badGetUsage(Optional<String> optional) {
        return optional.get();  // Throws NoSuchElementException if empty!
    }
    
    // ✅ GOOD: Use orElse, orElseGet, or orElseThrow
    public String goodGetUsage(Optional<String> optional) {
        return optional.orElse("Default");
    }
    
    // ❌ BAD: Using isPresent() + get()
    public String badPresenceCheck(Optional<String> optional) {
        if (optional.isPresent()) {
            return optional.get();
        }
        return "Default";
    }
    
    // ✅ GOOD: Use orElse or orElseGet
    public String goodPresenceCheck(Optional<String> optional) {
        return optional.orElse("Default");
    }
    
    // ❌ BAD: Optional as field
    public class BadUserClass {
        private Optional<String> name;  // Don't do this!
        
        public Optional<String> getName() {
            return name;
        }
    }
    
    // ✅ GOOD: Optional as return type only
    public class GoodUserClass {
        private String name;  // Can be null
        
        public Optional<String> getName() {
            return Optional.ofNullable(name);
        }
    }
    
    // ❌ BAD: Optional method parameter
    public void badMethodParameter(Optional<String> name) {
        name.ifPresent(System.out::println);
    }
    
    // ✅ GOOD: Use overloading or nullable parameter
    public void goodMethodParameter(String name) {
        if (name != null) {
            System.out.println(name);
        }
    }
    
    // ❌ BAD: Returning null instead of Optional.empty()
    public Optional<String> badNullReturn() {
        return null;  // Don't do this!
    }
    
    // ✅ GOOD: Return Optional.empty()
    public Optional<String> goodEmptyReturn() {
        return Optional.empty();
    }
    
    // ✅ GOOD: Chaining Optional methods
    public String goodChaining(User user) {
        return Optional.ofNullable(user)
            .flatMap(User::getAddress)
            .map(Address::getCity)
            .orElse("Unknown");
    }
    
    // ❌ BAD: Nested if statements with Optional
    public String badNesting(Optional<User> userOpt) {
        if (userOpt.isPresent()) {
            User user = userOpt.get();
            Optional<Address> addressOpt = user.getAddress();
            if (addressOpt.isPresent()) {
                Address address = addressOpt.get();
                return address.getCity();
            }
        }
        return "Unknown";
    }
    
    // ✅ GOOD: flatMap chaining
    public String goodNesting(Optional<User> userOpt) {
        return userOpt
            .flatMap(User::getAddress)
            .map(Address::getCity)
            .orElse("Unknown");
    }
    
    // ✅ GOOD: Using Optional in streams
    public List<String> getCitiesFromUsers(List<User> users) {
        return users.stream()
            .map(User::getAddress)
            .flatMap(Optional::stream)  // Java 9+
            .map(Address::getCity)
            .collect(java.util.stream.Collectors.toList());
    }
}
```

## 5.3 Real-World Example: Repository Pattern with Optional

```java
import java.util.*;

public class UserRepository {
    
    static class User {
        private Long id;
        private String username;
        private String email;
        
        public User(Long id, String username, String email) {
            this.id = id;
            this.username = username;
            this.email = email;
        }
        
        public Long getId() { return id; }
        public String getUsername() { return username; }
        public String getEmail() { return email; }
        
        @Override
        public String toString() {
            return username + " (" + email + ")";
        }
    }
    
    private Map<Long, User> database = new HashMap<>();
    
    public UserRepository() {
        // Populate with sample data
        database.put(1L, new User(1L, "alice", "alice@example.com"));
        database.put(2L, new User(2L, "bob", "bob@example.com"));
        database.put(3L, new User(3L, "charlie", "charlie@example.com"));
    }
    
    // Find by ID - returns Optional
    public Optional<User> findById(Long id) {
        return Optional.ofNullable(database.get(id));
    }
    
    // Find by username - returns Optional
    public Optional<User> findByUsername(String username) {
        return database.values().stream()
            .filter(user -> user.getUsername().equals(username))
            .findFirst();
    }
    
    // Get email for user ID
    public String getUserEmail(Long userId) {
        return findById(userId)
            .map(User::getEmail)
            .orElse("no-email@example.com");
    }
    
    // Check if user exists
    public boolean userExists(Long userId) {
        return findById(userId).isPresent();
    }
    
    // Update user email
    public Optional<User> updateEmail(Long userId, String newEmail) {
        return findById(userId)
            .map(user -> {
                // In real scenario, update in database
                User updated = new User(user.getId(), user.getUsername(), newEmail);
                database.put(userId, updated);
                return updated;
            });
    }
    
    // Delete user and return deleted user info
    public Optional<User> deleteUser(Long userId) {
        return Optional.ofNullable(database.remove(userId));
    }
    
    // Get user or throw custom exception
    public User getUserOrThrow(Long userId) {
        return findById(userId)
            .orElseThrow(() -> new UserNotFoundException("User not found: " + userId));
    }
    
    static class UserNotFoundException extends RuntimeException {
        public UserNotFoundException(String message) {
            super(message);
        }
    }
    
    // Usage examples
    public static void main(String[] args) {
        UserRepository repo = new UserRepository();
        
        // Find existing user
        repo.findById(1L).ifPresent(user -> 
            System.out.println("Found: " + user));
        
        // Find non-existing user
        repo.findById(999L).ifPresentOrElse(
            user -> System.out.println("Found: " + user),
            () -> System.out.println("User not found")
        );
        
        // Get email with default
        String email1 = repo.getUserEmail(1L);
        System.out.println("Email: " + email1);  // alice@example.com
        
        String email2 = repo.getUserEmail(999L);
        System.out.println("Email: " + email2);  // no-email@example.com
        
        // Update email
        repo.updateEmail(1L, "newalice@example.com")
            .ifPresent(user -> System.out.println("Updated: " + user));
        
        // Delete user
        repo.deleteUser(2L)
            .ifPresent(user -> System.out.println("Deleted: " + user));
        
        // Throw exception if not found
        try {
            User user = repo.getUserOrThrow(999L);
        } catch (UserNotFoundException e) {
            System.out.println(e.getMessage());
        }
    }
}
```

---

# 6. DEFAULT & STATIC METHODS IN INTERFACES

## 6.1 Default Methods

```java
public class DefaultMethodsDemo {
    
    // Interface with default method
    interface Vehicle {
        // Abstract method (must be implemented)
        void start();
        
        // Default method (can be inherited or overridden)
        default void stop() {
            System.out.println("Vehicle stopped");
        }
        
        default void honk() {
            System.out.println("Beep beep!");
        }
    }
    
    // Class using default methods
    static class Car implements Vehicle {
        @Override
        public void start() {
            System.out.println("Car started");
        }
        
        // Inherits default stop() and honk()
    }
    
    // Class overriding default method
    static class Truck implements Vehicle {
        @Override
        public void start() {
            System.out.println("Truck started");
        }
        
        @Override
        public void stop() {
            System.out.println("Truck stopped with air brakes");
        }
        
        // Inherits default honk()
    }
    
    // Multiple inheritance of default methods
    interface Printable {
        default void print() {
            System.out.println("Printing from Printable");
        }
    }
    
    interface Showable {
        default void print() {
            System.out.println("Printing from Showable");
        }
    }
    
    // Must override to resolve conflict
    static class Document implements Printable, Showable {
        @Override
        public void print() {
            // Can call specific interface's default method
            Printable.super.print();
            Showable.super.print();
            System.out.println("Printing from Document");
        }
    }
    
    public static void main(String[] args) {
        Vehicle car = new Car();
        car.start();  // Car started
        car.stop();   // Vehicle stopped (inherited)
        car.honk();   // Beep beep! (inherited)
        
        Vehicle truck = new Truck();
        truck.start();  // Truck started
        truck.stop();   // Truck stopped with air brakes (overridden)
        
        Document doc = new Document();
        doc.print();  // Calls both super methods and own implementation
    }
}
```

## 6.2 Static Methods in Interfaces

```java
public class StaticMethodsDemo {
    
    interface MathUtils {
        // Static method in interface
        static int add(int a, int b) {
            return a + b;
        }
        
        static int multiply(int a, int b) {
            return a * b;
        }
        
        static boolean isEven(int n) {
            return n % 2 == 0;
        }
    }
    
    interface StringUtils {
        static boolean isEmpty(String str) {
            return str == null || str.isEmpty();
        }
        
        static String reverse(String str) {
            return new StringBuilder(str).reverse().toString();
        }
        
        static String capitalize(String str) {
            if (isEmpty(str)) return str;
            return str.substring(0, 1).toUpperCase() + str.substring(1);
        }
    }
    
    public static void main(String[] args) {
        // Call static methods directly on interface
        int sum = MathUtils.add(5, 3);
        System.out.println(sum);  // 8
        
        int product = MathUtils.multiply(4, 6);
        System.out.println(product);  // 24
        
        boolean even = MathUtils.isEven(10);
        System.out.println(even);  // true
        
        String reversed = StringUtils.reverse("hello");
        System.out.println(reversed);  // olleh
        
        String capitalized = StringUtils.capitalize("java");
        System.out.println(capitalized);  // Java
    }
}
```

## 6.3 Real-World Example: Plugin System with Default Methods

```java
import java.util.*;

public class PluginSystem {
    
    // Base plugin interface with default methods
    interface Plugin {
        // Must be implemented
        String getName();
        void execute();
        
        // Default methods
        default String getVersion() {
            return "1.0.0";
        }
        
        default boolean isEnabled() {
            return true;
        }
        
        default void initialize() {
            System.out.println("Initializing plugin: " + getName());
        }
        
        default void shutdown() {
            System.out.println("Shutting down plugin: " + getName());
        }
        
        default Map<String, String> getMetadata() {
            Map<String, String> metadata = new HashMap<>();
            metadata.put("name", getName());
            metadata.put("version", getVersion());
            metadata.put("enabled", String.valueOf(isEnabled()));
            return metadata;
        }
    }
    
    // Simple plugin using defaults
    static class LoggingPlugin implements Plugin {
        @Override
        public String getName() {
            return "Logging Plugin";
        }
        
        @Override
        public void execute() {
            System.out.println("[LOG] Logging events...");
        }
    }
    
    // Plugin overriding some defaults
    static class MonitoringPlugin implements Plugin {
        @Override
        public String getName() {
            return "Monitoring Plugin";
        }
        
        @Override
        public String getVersion() {
            return "2.0.0";  // Override version
        }
        
        @Override
        public void initialize() {
            Plugin.super.initialize();  // Call default implementation
            System.out.println("Starting monitoring threads...");
        }
        
        @Override
        public void execute() {
            System.out.println("[MONITOR] Collecting metrics...");
        }
        
        @Override
        public void shutdown() {
            System.out.println("Stopping monitoring threads...");
            Plugin.super.shutdown();  // Call default implementation
        }
    }
    
    // Disabled plugin
    static class ExperimentalPlugin implements Plugin {
        @Override
        public String getName() {
            return "Experimental Plugin";
        }
        
        @Override
        public boolean isEnabled() {
            return false;  // Disabled
        }
        
        @Override
        public void execute() {
            System.out.println("[EXPERIMENTAL] Running experiment...");
        }
    }
    
    // Plugin manager
    static class PluginManager {
        private List<Plugin> plugins = new ArrayList<>();
        
        public void registerPlugin(Plugin plugin) {
            plugins.add(plugin);
            System.out.println("Registered: " + plugin.getName());
        }
        
        public void initializeAll() {
            System.out.println("\n=== Initializing Plugins ===");
            plugins.stream()
                .filter(Plugin::isEnabled)
                .forEach(Plugin::initialize);
        }
        
        public void executeAll() {
            System.out.println("\n=== Executing Plugins ===");
            plugins.stream()
                .filter(Plugin::isEnabled)
                .forEach(Plugin::execute);
        }
        
        public void shutdownAll() {
            System.out.println("\n=== Shutting Down Plugins ===");
            plugins.stream()
                .filter(Plugin::isEnabled)
                .forEach(Plugin::shutdown);
        }
        
        public void printMetadata() {
            System.out.println("\n=== Plugin Metadata ===");
            plugins.forEach(plugin -> {
                System.out.println(plugin.getName() + ":");
                plugin.getMetadata().forEach((key, value) -> 
                    System.out.println("  " + key + ": " + value));
            });
        }
    }
    
    public static void main(String[] args) {
        PluginManager manager = new PluginManager();
        
        manager.registerPlugin(new LoggingPlugin());
        manager.registerPlugin(new MonitoringPlugin());
        manager.registerPlugin(new ExperimentalPlugin());
        
        manager.printMetadata();
        manager.initializeAll();
        manager.executeAll();
        manager.shutdownAll();
    }
}
```

---

**Part 2 Progress:** 

Covered:
- Stream Terminal Operations (collect, reduce, forEach, count, min, max, anyMatch, etc.) ✅
- Advanced Collectors (groupingBy, partitioningBy, summarizingStatistics) ✅  
- Parallel Streams with performance comparison ✅
- Real-World Stream Example (Transaction Processing) ✅
- Optional complete guide (creation, usage, transformations, filtering) ✅
- Optional Anti-Patterns and Best Practices ✅
- Optional Real-World Example (Repository Pattern) ✅
- Default & Static Methods in Interfaces ✅
- Real-World Plugin System Example ✅

# 7. DATE AND TIME API

## 7.1 LocalDate, LocalTime, LocalDateTime

```java
import java.time.*;
import java.time.format.DateTimeFormatter;

public class LocalDateTimeDemo {
    
    public void demonstrateLocalDate() {
        // Creating LocalDate
        LocalDate today = LocalDate.now();
        System.out.println("Today: " + today);  // 2024-03-16
        
        LocalDate specific = LocalDate.of(2024, 3, 16);
        LocalDate fromString = LocalDate.parse("2024-03-16");
        
        // Getting date components
        int year = today.getYear();
        Month month = today.getMonth();
        int monthValue = today.getMonthValue();
        int day = today.getDayOfMonth();
        DayOfWeek dayOfWeek = today.getDayOfWeek();
        
        System.out.println("Year: " + year);
        System.out.println("Month: " + month + " (" + monthValue + ")");
        System.out.println("Day: " + day);
        System.out.println("Day of week: " + dayOfWeek);
        
        // Adding/Subtracting
        LocalDate tomorrow = today.plusDays(1);
        LocalDate nextWeek = today.plusWeeks(1);
        LocalDate nextMonth = today.plusMonths(1);
        LocalDate nextYear = today.plusYears(1);
        
        LocalDate yesterday = today.minusDays(1);
        LocalDate lastMonth = today.minusMonths(1);
        
        // With methods (replace specific component)
        LocalDate newDate = today.withYear(2025)
                                 .withMonth(12)
                                 .withDayOfMonth(25);
        System.out.println("Christmas 2025: " + newDate);
        
        // Comparisons
        boolean isBefore = today.isBefore(tomorrow);
        boolean isAfter = today.isAfter(yesterday);
        boolean isEqual = today.isEqual(specific);
        
        // Leap year
        boolean isLeap = today.isLeapYear();
        System.out.println("Is leap year: " + isLeap);
    }
    
    public void demonstrateLocalTime() {
        // Creating LocalTime
        LocalTime now = LocalTime.now();
        System.out.println("Now: " + now);  // 14:30:45.123456789
        
        LocalTime specific = LocalTime.of(14, 30);
        LocalTime withSeconds = LocalTime.of(14, 30, 45);
        LocalTime withNanos = LocalTime.of(14, 30, 45, 123456789);
        LocalTime fromString = LocalTime.parse("14:30:45");
        
        // Getting time components
        int hour = now.getHour();
        int minute = now.getMinute();
        int second = now.getSecond();
        int nano = now.getNano();
        
        // Adding/Subtracting
        LocalTime later = now.plusHours(2).plusMinutes(30);
        LocalTime earlier = now.minusHours(1);
        
        // With methods
        LocalTime newTime = now.withHour(16).withMinute(0).withSecond(0);
        
        // Comparisons
        boolean isBefore = now.isBefore(later);
        boolean isAfter = now.isAfter(earlier);
    }
    
    public void demonstrateLocalDateTime() {
        // Creating LocalDateTime
        LocalDateTime now = LocalDateTime.now();
        System.out.println("Now: " + now);  // 2024-03-16T14:30:45.123
        
        LocalDateTime specific = LocalDateTime.of(2024, 3, 16, 14, 30);
        LocalDateTime fromDateAndTime = LocalDateTime.of(
            LocalDate.now(), 
            LocalTime.now()
        );
        LocalDateTime fromString = LocalDateTime.parse("2024-03-16T14:30:45");
        
        // Converting
        LocalDate date = now.toLocalDate();
        LocalTime time = now.toLocalTime();
        
        // All LocalDate and LocalTime operations available
        LocalDateTime tomorrow = now.plusDays(1);
        LocalDateTime nextHour = now.plusHours(1);
        LocalDateTime modified = now.withYear(2025)
                                    .withHour(16)
                                    .withMinute(0);
        
        // Formatting
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
        String formatted = now.format(formatter);
        System.out.println("Formatted: " + formatted);  // 16/03/2024 14:30
        
        // Parsing with custom format
        LocalDateTime parsed = LocalDateTime.parse(
            "16/03/2024 14:30", 
            formatter
        );
    }
}
```

## 7.2 ZonedDateTime and Instant

```java
import java.time.*;
import java.time.format.DateTimeFormatter;

public class ZonedDateTimeDemo {
    
    public void demonstrateZonedDateTime() {
        // Creating ZonedDateTime
        ZonedDateTime now = ZonedDateTime.now();
        System.out.println("Now: " + now);  
        // 2024-03-16T14:30:45.123+01:00[Europe/London]
        
        ZonedDateTime newYork = ZonedDateTime.now(ZoneId.of("America/New_York"));
        ZonedDateTime tokyo = ZonedDateTime.now(ZoneId.of("Asia/Tokyo"));
        
        System.out.println("New York: " + newYork);
        System.out.println("Tokyo: " + tokyo);
        
        // From LocalDateTime
        LocalDateTime localDateTime = LocalDateTime.now();
        ZonedDateTime zoned = localDateTime.atZone(ZoneId.of("Europe/Paris"));
        
        // Converting time zones
        ZonedDateTime parisTime = ZonedDateTime.now(ZoneId.of("Europe/Paris"));
        ZonedDateTime londonTime = parisTime.withZoneSameInstant(
            ZoneId.of("Europe/London")
        );
        System.out.println("Paris: " + parisTime);
        System.out.println("London: " + londonTime);
        
        // Getting zone info
        ZoneId zone = now.getZone();
        ZoneOffset offset = now.getOffset();
        System.out.println("Zone: " + zone);
        System.out.println("Offset: " + offset);
        
        // All available zones
        Set<String> zones = ZoneId.getAvailableZoneIds();
        zones.stream()
             .filter(z -> z.startsWith("America"))
             .sorted()
             .limit(5)
             .forEach(System.out::println);
    }
    
    public void demonstrateInstant() {
        // Instant represents a point on the timeline (UTC)
        Instant now = Instant.now();
        System.out.println("Instant: " + now);  // 2024-03-16T13:30:45.123Z
        
        // Epoch time
        Instant epoch = Instant.ofEpochMilli(0);
        System.out.println("Epoch: " + epoch);  // 1970-01-01T00:00:00Z
        
        long millis = now.toEpochMilli();
        long seconds = now.getEpochSecond();
        
        // Operations
        Instant later = now.plusSeconds(60);
        Instant earlier = now.minusSeconds(3600);
        
        // Converting to/from ZonedDateTime
        ZonedDateTime zonedDateTime = now.atZone(ZoneId.of("UTC"));
        Instant instantFromZoned = zonedDateTime.toInstant();
        
        // Comparisons
        boolean isBefore = now.isBefore(later);
        boolean isAfter = now.isAfter(earlier);
        
        // Duration between instants
        Duration duration = Duration.between(earlier, now);
        System.out.println("Duration: " + duration.toHours() + " hours");
    }
}
```

## 7.3 Period and Duration

```java
import java.time.*;

public class PeriodDurationDemo {
    
    publi void demonstratePeriod() {
        // Period represents date-based amount (years, months, days)
        Period period = Period.of(1, 6, 15);  // 1 year, 6 months, 15 days
        System.out.println(period);  // P1Y6M15D
        
        // Creating periods
        Period oneYear = Period.ofYears(1);
        Period twoMonths = Period.ofMonths(2);
        Period tenDays = Period.ofDays(10);
        Period oneWeek = Period.ofWeeks(1);  // 7 days
        
        // Between two dates
        LocalDate start = LocalDate.of(2024, 1, 1);
        LocalDate end = LocalDate.of(2024, 12, 31);
        Period between = Period.between(start, end);
        System.out.println("Between: " + between);  // P11M30D
        
        System.out.println("Years: " + between.getYears());
        System.out.println("Months: " + between.getMonths());
        System.out.println("Days: " + between.getDays());
        
        // Adding period to date
        LocalDate today = LocalDate.now();
        LocalDate future = today.plus(period);
        LocalDate past = today.minus(Period.ofMonths(3));
        
        // Operations
        Period doubled = period.multipliedBy(2);
        Period negated = period.negated();
    }
    
    public void demonstrateDuration() {
        // Duration represents time-based amount (hours, minutes, seconds)
        Duration duration = Duration.ofHours(2).plusMinutes(30);
        System.out.println(duration);  // PT2H30M
        
        // Creating durations
        Duration oneHour = Duration.ofHours(1);
        Duration thirtyMinutes = Duration.ofMinutes(30);
        Duration tenSeconds = Duration.ofSeconds(10);
        Duration fiveMillis = Duration.ofMillis(5);
        Duration oneNano = Duration.ofNanos(1);
        
        // Between two times
        LocalTime start = LocalTime.of(9, 0);
        LocalTime end = LocalTime.of(17, 30);
        Duration workDay = Duration.between(start, end);
        System.out.println("Work day: " + workDay.toHours() + " hours");
        
        // Between instants
        Instant instant1 = Instant.now();
        Instant instant2 = instant1.plusSeconds(3600);
        Duration hourDuration = Duration.between(instant1, instant2);
        
        // Converting
        long seconds = duration.getSeconds();
        long minutes = duration.toMinutes();
        long hours = duration.toHours();
        long days = duration.toDays();
        long millis = duration.toMillis();
        long nanos = duration.toNanos();
        
        // Operations
        Duration doubled = duration.multipliedBy(2);
        Duration halved = duration.dividedBy(2);
        Duration negated = duration.negated();
        Duration absolute = duration.abs();
        
        // Comparisons
        boolean isZero = duration.isZero();
        boolean isNegative = duration.isNegative();
        
        // Adding duration to time
        LocalTime time = LocalTime.now();
        LocalTime later = time.plus(duration);
    }
    
    // Real-world example: Age calculation
    public int calculateAge(LocalDate birthDate) {
        Period age = Period.between(birthDate, LocalDate.now());
        return age.getYears();
    }
    
    // Real-world example: Time tracking
    public String formatWorkTime(LocalTime start, LocalTime end) {
        Duration duration = Duration.between(start, end);
        long hours = duration.toHours();
        long minutes = duration.toMinutes() % 60;
        return String.format("%d hours %d minutes", hours, minutes);
    }
}
```

## 7.4 Real-World Example: Meeting Scheduler

```java
import java.time.*;
import java.time.format.DateTimeFormatter;
import java.util.*;

public class MeetingScheduler {
    
    static class Meeting {
        private String title;
        private ZonedDateTime startTime;
        private Duration duration;
        private ZoneId timezone;
        
        public Meeting(String title, ZonedDateTime startTime, Duration duration) {
            this.title = title;
            this.startTime = startTime;
            this.duration = duration;
            this.timezone = startTime.getZone();
        }
        
        public ZonedDateTime getEndTime() {
            return startTime.plus(duration);
        }
        
        public ZonedDateTime getStartTimeInZone(ZoneId zone) {
            return startTime.withZoneSameInstant(zone);
        }
        
        public boolean overlaps(Meeting other) {
            ZonedDateTime thisEnd = this.getEndTime();
            ZonedDateTime otherEnd = other.getEndTime();
            
            return !this.startTime.isAfter(otherEnd) && 
                   !thisEnd.isBefore(other.startTime);
        }
        
        public boolean isUpcoming() {
            return startTime.isAfter(ZonedDateTime.now());
        }
        
        public String getTimeUntilStart() {
            Duration until = Duration.between(ZonedDateTime.now(), startTime);
            if (until.isNegative()) {
                return "Meeting has started";
            }
            
            long days = until.toDays();
            long hours = until.toHours() % 24;
            long minutes = until.toMinutes() % 60;
            
            if (days > 0) {
                return String.format("%d days, %d hours", days, hours);
            } else if (hours > 0) {
                return String.format("%d hours, %d minutes", hours, minutes);
            } else {
                return String.format("%d minutes", minutes);
            }
        }
        
        @Override
        public String toString() {
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern(
                "MMM dd, yyyy HH:mm z"
            );
            return String.format("%s: %s (%d min)", 
                title, 
                startTime.format(formatter), 
                duration.toMinutes()
            );
        }
    }
    
    private List<Meeting> meetings = new ArrayList<>();
    
    public boolean scheduleMeeting(Meeting meeting) {
        // Check for conflicts
        for (Meeting existing : meetings) {
            if (meeting.overlaps(existing)) {
                System.out.println("Conflict with: " + existing.title);
                return false;
            }
        }
        meetings.add(meeting);
        return true;
    }
    
    public List<Meeting> getUpcomingMeetings() {
        return meetings.stream()
            .filter(Meeting::isUpcoming)
            .sorted(Comparator.comparing(m -> m.startTime))
            .collect(java.util.stream.Collectors.toList());
    }
    
    public List<Meeting> getMeetingsOnDate(LocalDate date) {
        return meetings.stream()
            .filter(m -> m.startTime.toLocalDate().equals(date))
            .collect(java.util.stream.Collectors.toList());
    }
    
    public void printScheduleForTimezone(ZoneId timezone) {
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("HH:mm z");
        
        meetings.stream()
            .sorted(Comparator.comparing(m -> m.startTime))
            .forEach(meeting -> {
                ZonedDateTime localStart = meeting.getStartTimeInZone(timezone);
                ZonedDateTime localEnd = localStart.plus(meeting.duration);
                System.out.printf("%s: %s - %s%n",
                    meeting.title,
                    localStart.format(formatter),
                    localEnd.format(formatter)
                );
            });
    }
    
    public static void main(String[] args) {
        MeetingScheduler scheduler = new MeetingScheduler();
        
        // Create meetings in different timezones
        ZoneId nyZone = ZoneId.of("America/New_York");
        ZoneId londonZone = ZoneId.of("Europe/London");
        ZoneId tokyoZone = ZoneId.of("Asia/Tokyo");
        
        // Meeting 1: Team Standup (New York time)
        ZonedDateTime standup = ZonedDateTime.of(
            LocalDate.now(),
            LocalTime.of(9, 0),
            nyZone
        );
        Meeting meeting1 = new Meeting(
            "Team Standup",
            standup,
            Duration.ofMinutes(15)
        );
        
        // Meeting 2: Client Call (London time)
        ZonedDateTime clientCall = ZonedDateTime.of(
            LocalDate.now(),
            LocalTime.of(14, 0),
            londonZone
        );
        Meeting meeting2 = new Meeting(
            "Client Call",
            clientCall,
            Duration.ofHours(1)
        );
        
        // Meeting 3: Design Review (New York time)
        ZonedDateTime designReview = ZonedDateTime.of(
            LocalDate.now(),
            LocalTime.of(15, 0),
            nyZone
        );
        Meeting meeting3 = new Meeting(
            "Design Review",
            designReview,
            Duration.ofMinutes(90)
        );
        
        // Schedule meetings
        boolean scheduled1 = scheduler.scheduleMeeting(meeting1);
        boolean scheduled2 = scheduler.scheduleMeeting(meeting2);
        boolean scheduled3 = scheduler.scheduleMeeting(meeting3);
        
        System.out.println("Meeting 1 scheduled: " + scheduled1);
        System.out.println("Meeting 2 scheduled: " + scheduled2);
        System.out.println("Meeting 3 scheduled: " + scheduled3);
        
        // Print schedule in different timezones
        System.out.println("\n=== Schedule (New York Time) ===");
        scheduler.printScheduleForTimezone(nyZone);
        
        System.out.println("\n=== Schedule (London Time) ===");
        scheduler.printScheduleForTimezone(londonZone);
        
        System.out.println("\n=== Schedule (Tokyo Time) ===");
        scheduler.printScheduleForTimezone(tokyoZone);
        
        // Show upcoming meetings with countdown
        System.out.println("\n=== Upcoming Meetings ===");
        scheduler.getUpcomingMeetings().forEach(meeting -> {
            System.out.println(meeting);
            System.out.println("  Starts in: " + meeting.getTimeUntilStart());
        });
    }
}
```

---

# 8. COMPLETABLEFUTURE

## 8.1 Creating CompletableFuture

```java
import java.util.concurrent.*;

public class CompletableFutureCreation {
    
    public void creatingCompletableFutures() {
        // Already completed future
        CompletableFuture<String> completed = 
            CompletableFuture.completedFuture("Hello");
        
        // Manual completion
        CompletableFuture<String> manual = new CompletableFuture<>();
        manual.complete("Result");  // Complete normally
        // manual.completeExceptionally(new RuntimeException());  // Complete with exception
        
        // Async supplier (runs in ForkJoinPool.commonPool())
        CompletableFuture<String> supplyAsync = 
            CompletableFuture.supplyAsync(() -> {
                // Long running task
                return "Async Result";
            });
        
        // Async runnable (returns CompletableFuture<Void>)
        CompletableFuture<Void> runAsync = 
            CompletableFuture.runAsync(() -> {
                System.out.println("Running async task");
            });
        
        // With custom executor
        ExecutorService executor = Executors.newFixedThreadPool(10);
        CompletableFuture<String> customExecutor = 
            CompletableFuture.supplyAsync(() -> {
                return "Result from custom executor";
            }, executor);
    }
    
    public void gettingResults() throws Exception {
        CompletableFuture<String> future = 
            CompletableFuture.supplyAsync(() -> "Result");
        
        // Blocking get (throws checked exceptions)
        String result1 = future.get();
        
        // Blocking get with timeout
        String result2 = future.get(5, TimeUnit.SECONDS);
        
        // Blocking join (throws unchecked exceptions)
        String result3 = future.join();
        
        // Get with default if not completed
        String result4 = future.getNow("Default");
        
        // Check completion status
        boolean isDone = future.isDone();
        boolean isCompletedExceptionally = future.isCompletedExceptionally();
        boolean isCancelled = future.isCancelled();
    }
}
```

## 8.2 Chaining and Combining

```java
import java.util.concurrent.*;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

public class CompletableFutureChaining {
    
    public void demonstrateThenApply() {
        // thenApply - transform result
        CompletableFuture<Integer> future = CompletableFuture.supplyAsync(() -> {
            System.out.println("Computing...");
            return 42;
        }).thenApply(result -> {
            System.out.println("Transforming: " + result);
            return result * 2;
        }).thenApply(result -> {
            System.out.println("Final transform: " + result);
            return result + 10;
        });
        
        System.out.println("Result: " + future.join());  // 94
        
        // Same with method references
        CompletableFuture<String> stringFuture = 
            CompletableFuture.supplyAsync(() -> "hello")
                .thenApply(String::toUpperCase)
                .thenApply(s -> s + " WORLD");
    }
    
    public void demonstrateThenAccept() {
        // thenAccept - consume result (returns CompletableFuture<Void>)
        CompletableFuture<Void> future = CompletableFuture.supplyAsync(() -> {
            return "Hello";
        }).thenAccept(result -> {
            System.out.println("Received: " + result);
        });
        
        future.join();  // Wait for completion
    }
    
    public void demonstrateThenRun() {
        // thenRun - run action after completion (doesn't receive result)
        CompletableFuture<Void> future = CompletableFuture.supplyAsync(() -> {
            return "Hello";
        }).thenRun(() -> {
            System.out.println("Task completed");
        });
    }
    
    public void demonstrateThenCompose() {
        // thenCompose - flatten nested CompletableFutures (like flatMap)
        CompletableFuture<String> future = CompletableFuture.supplyAsync(() -> {
            return "User123";
        }).thenCompose(userId -> {
            // Returns another CompletableFuture
            return CompletableFuture.supplyAsync(() -> {
                return "user123@example.com";  // Fetch user email
            });
        });
        
        System.out.println(future.join());
    }
    
    public void demonstrateThenCombine() {
        // thenCombine - combine two independent futures
        CompletableFuture<Integer> future1 = 
            CompletableFuture.supplyAsync(() -> 10);
        
        CompletableFuture<Integer> future2 = 
            CompletableFuture.supplyAsync(() -> 20);
        
        CompletableFuture<Integer> combined = future1.thenCombine(
            future2,
            (result1, result2) -> result1 + result2
        );
        
        System.out.println("Combined: " + combined.join());  // 30
    }
    
    public void demonstrateThenAcceptBoth() {
        // thenAcceptBoth - consume results of two futures
        CompletableFuture<Integer> future1 = 
            CompletableFuture.supplyAsync(() -> 10);
        
        CompletableFuture<Integer> future2 = 
            CompletableFuture.supplyAsync(() -> 20);
        
        CompletableFuture<Void> combined = future1.thenAcceptBoth(
            future2,
            (result1, result2) -> {
                System.out.println("Results: " + result1 + ", " + result2);
            }
        );
    }
    
    public void demonstrateAllOf() {
        // allOf - wait for all futures to complete
        CompletableFuture<String> future1 = 
            CompletableFuture.supplyAsync(() -> "Task1");
        
        CompletableFuture<String> future2 = 
            CompletableFuture.supplyAsync(() -> "Task2");
        
        CompletableFuture<String> future3 = 
            CompletableFuture.supplyAsync(() -> "Task3");
        
        CompletableFuture<Void> allFutures = 
            CompletableFuture.allOf(future1, future2, future3);
        
        // Wait for all to complete
        allFutures.join();
        
        // Collect results
        List<String> results = Arrays.asList(future1, future2, future3).stream()
            .map(CompletableFuture::join)
            .collect(Collectors.toList());
        
        System.out.println("All results: " + results);
    }
    
    public void demonstrateAnyOf() {
        // anyOf - complete when any future completes
        CompletableFuture<String> future1 = 
            CompletableFuture.supplyAsync(() -> {
                sleep(1000);
                return "Task1";
            });
        
        CompletableFuture<String> future2 = 
            CompletableFuture.supplyAsync(() -> {
                sleep(500);
                return "Task2";  // Completes first
            });
        
        CompletableFuture<String> future3 = 
            CompletableFuture.supplyAsync(() -> {
                sleep(1500);
                return "Task3";
            });
        
        CompletableFuture<Object> anyFuture = 
            CompletableFuture.anyOf(future1, future2, future3);
        
        System.out.println("First result: " + anyFuture.join());  // Task2
    }
    
    private void sleep(long millis) {
        try {
            Thread.sleep(millis);
        } catch (InterruptedException e) {
            throw new RuntimeException(e);
        }
    }
}
```

## 8.3 Exception Handling

```java
import java.util.concurrent.*;

public class CompletableFutureExceptionHandling {
    
    public void demonstrateExceptionally() {
        CompletableFuture<String> future = CompletableFuture.supplyAsync(() -> {
            if (Math.random() > 0.5) {
                throw new RuntimeException("Random failure");
            }
            return "Success";
        }).exceptionally(ex -> {
            System.out.println("Exception: " + ex.getMessage());
            return "Default Value";
        });
        
        System.out.println(future.join());
    }
    
    public void demonstrateHandle() {
        // handle - process both result and exception
        CompletableFuture<String> future = CompletableFuture.supplyAsync(() -> {
            if (Math.random() > 0.5) {
                throw new RuntimeException("Random failure");
            }
            return "Success";
        }).handle((result, ex) -> {
            if (ex != null) {
                System.out.println("Exception: " + ex.getMessage());
                return "Error: " + ex.getMessage();
            }
            return result;
        });
        
        System.out.println(future.join());
    }
    
    public void demonstrateWhenComplete() {
        // whenComplete - side effect, doesn't transform result
        CompletableFuture<String> future = CompletableFuture.supplyAsync(() -> {
            return "Success";
        }).whenComplete((result, ex) -> {
            if (ex != null) {
                System.out.println("Failed: " + ex.getMessage());
            } else {
                System.out.println("Succeeded: " + result);
            }
        });
    }
    
    public void demonstrateExceptionallyCompose() {
        // exceptionallyCompose - return alternative CompletableFuture on exception
        CompletableFuture<String> future = CompletableFuture.supplyAsync(() -> {
            throw new RuntimeException("Primary source failed");
        }).exceptionallyCompose(ex -> {
            System.out.println("Trying fallback...");
            return CompletableFuture.supplyAsync(() -> "Fallback value");
        });
        
        System.out.println(future.join());  // Fallback value
    }
}
```

## 8.4 Real-World Example: Microservice Orchestration

```java
import java.util.concurrent.*;
import java.util.*;

public class MicroserviceOrchestration {
    
    // Simulated external service calls
    static class UserService {
        public static CompletableFuture<User> getUserById(String userId) {
            return CompletableFuture.supplyAsync(() -> {
                sleep(100);  // Simulate network latency
                return new User(userId, "John Doe", "john@example.com");
            });
        }
    }
    
    static class OrderService {
        public static CompletableFuture<List<Order>> getOrdersByUser(String userId) {
            return CompletableFuture.supplyAsync(() -> {
                sleep(150);
                return Arrays.asList(
                    new Order("O1", userId, 100.0),
                    new Order("O2", userId, 200.0)
                );
            });
        }
    }
    
    static class PaymentService {
        public static CompletableFuture<List<Payment>> getPaymentsByUser(String userId) {
            return CompletableFuture.supplyAsync(() -> {
                sleep(120);
                return Arrays.asList(
                    new Payment("P1", userId, 100.0, "COMPLETED"),
                    new Payment("P2", userId, 200.0, "COMPLETED")
                );
            });
        }
    }
    
    static class RecommendationService {
        public static CompletableFuture<List<String>> getRecommendations(String userId) {
            return CompletableFuture.supplyAsync(() -> {
                sleep(200);
                return Arrays.asList("Product1", "Product2", "Product3");
            });
        }
    }
    
    // Data classes
    static class User {
        String id, name, email;
        public User(String id, String name, String email) {
            this.id = id; this.name = name; this.email = email;
        }
    }
    
    static class Order {
        String id, userId;
        double amount;
        public Order(String id, String userId, double amount) {
            this.id = id; this.userId = userId; this.amount = amount;
        }
    }
    
    static class Payment {
        String id, userId, status;
        double amount;
        public Payment(String id, String userId, double amount, String status) {
            this.id = id; this.userId = userId; this.amount = amount; this.status = status;
        }
    }
    
    static class UserProfile {
        User user;
        List<Order> orders;
        List<Payment> payments;
        List<String> recommendations;
        double totalSpent;
        
        @Override
        public String toString() {
            return String.format(
                "User: %s (%s)%nOrders: %d%nPayments: %d%nTotal Spent: $%.2f%nRecommendations: %s",
                user.name, user.email, orders.size(), payments.size(), 
                totalSpent, recommendations
            );
        }
    }
    
    // Sequential approach (slow)
    public UserProfile getUserProfileSequential(String userId) {
        long start = System.currentTimeMillis();
        
        User user = UserService.getUserById(userId).join();
        List<Order> orders = OrderService.getOrdersByUser(userId).join();
        List<Payment> payments = PaymentService.getPaymentsByUser(userId).join();
        List<String> recommendations = RecommendationService.getRecommendations(userId).join();
        
        UserProfile profile = new UserProfile();
        profile.user = user;
        profile.orders = orders;
        profile.payments = payments;
        profile.recommendations = recommendations;
        profile.totalSpent = payments.stream()
            .mapToDouble(p -> p.amount)
            .sum();
        
        long duration = System.currentTimeMillis() - start;
        System.out.println("Sequential took: " + duration + "ms");
        
        return profile;
    }
    
    // Parallel approach (fast)
    public CompletableFuture<UserProfile> getUserProfileParallel(String userId) {
        long start = System.currentTimeMillis();
        
        // Start all requests in parallel
        CompletableFuture<User> userFuture = UserService.getUserById(userId);
        CompletableFuture<List<Order>> ordersFuture = OrderService.getOrdersByUser(userId);
        CompletableFuture<List<Payment>> paymentsFuture = PaymentService.getPaymentsByUser(userId);
        CompletableFuture<List<String>> recommendationsFuture = 
            RecommendationService.getRecommendations(userId);
        
        // Combine all results
        return CompletableFuture.allOf(
            userFuture, ordersFuture, paymentsFuture, recommendationsFuture
        ).thenApply(v -> {
            UserProfile profile = new UserProfile();
            profile.user = userFuture.join();
            profile.orders = ordersFuture.join();
            profile.payments = paymentsFuture.join();
            profile.recommendations = recommendationsFuture.join();
            profile.totalSpent = profile.payments.stream()
                .mapToDouble(p -> p.amount)
                .sum();
            
            long duration = System.currentTimeMillis() - start;
            System.out.println("Parallel took: " + duration + "ms");
            
            return profile;
        });
    }
    
    // With exception handling
    public CompletableFuture<UserProfile> getUserProfileWithFallback(String userId) {
        CompletableFuture<User> userFuture = UserService.getUserById(userId)
            .exceptionally(ex -> new User(userId, "Unknown", "unknown@example.com"));
        
        CompletableFuture<List<Order>> ordersFuture = OrderService.getOrdersByUser(userId)
            .exceptionally(ex -> Collections.emptyList());
        
        CompletableFuture<List<Payment>> paymentsFuture = PaymentService.getPaymentsByUser(userId)
            .exceptionally(ex -> Collections.emptyList());
        
        CompletableFuture<List<String>> recommendationsFuture = 
            RecommendationService.getRecommendations(userId)
                .exceptionally(ex -> Collections.emptyList());
        
        return CompletableFuture.allOf(
            userFuture, ordersFuture, paymentsFuture, recommendationsFuture
        ).thenApply(v -> {
            UserProfile profile = new UserProfile();
            profile.user = userFuture.join();
            profile.orders = ordersFuture.join();
            profile.payments = paymentsFuture.join();
            profile.recommendations = recommendationsFuture.join();
            profile.totalSpent = profile.payments.stream()
                .mapToDouble(p -> p.amount)
                .sum();
            return profile;
        });
    }
    
    public static void main(String[] args) {
        MicroserviceOrchestration orchestration = new MicroserviceOrchestration();
        String userId = "USER123";
        
        // Sequential
        System.out.println("=== Sequential ===");
        UserProfile profile1 = orchestration.getUserProfileSequential(userId);
        System.out.println(profile1);
        
        // Parallel
        System.out.println("\n=== Parallel ===");
        UserProfile profile2 = orchestration.getUserProfileParallel(userId).join();
        System.out.println(profile2);
    }
    
    private static void sleep(long millis) {
        try {
            Thread.sleep(millis);
        } catch (InterruptedException e) {
            throw new RuntimeException(e);
        }
    }
}
```

---

**Part 3 Progress:** 

Covered:
- Date and Time API (LocalDate, LocalTime, LocalDateTime, ZonedDateTime, Instant) ✅
- Period and Duration ✅
- Real-World Meeting Scheduler Example ✅
- CompletableFuture (creation, chaining, combining) ✅
- CompletableFuture Exception Handling ✅
- Real-World Microservice Orchestration Example ✅

# 9. JAVA 9+ FEATURES

## 9.1 Modules (Java 9)

```java
// module-info.java
module com.example.myapp {
    // Export packages
    exports com.example.myapp.api;
    exports com.example.myapp.utils to com.example.another;  // Qualified export
    
    // Require modules
    requires java.sql;
    requires java.logging;
    requires transitive java.xml;  // Transitive dependency
    
    // Service loading
    uses com.example.myapp.spi.ServiceProvider;
    provides com.example.myapp.spi.ServiceProvider 
        with com.example.myapp.impl.ServiceProviderImpl;
    
    // Open for reflection
    opens com.example.myapp.entities;
    opens com.example.myapp.internal to com.example.framework;
}
```

## 9.2 Private Methods in Interfaces (Java 9)

```java
public interface Calculator {
    
    default int addAndMultiply(int a, int b, int c) {
        int sum = add(a, b);
        return multiply(sum, c);
    }
    
    default int subtractAndDivide(int a, int b, int c) {
        int diff = subtract(a, b);
        return divide(diff, c);
    }
    
    // Private method for code reuse
    private int add(int a, int b) {
        return a + b;
    }
    
    private int subtract(int a, int b) {
        return a - b;
    }
    
    private int multiply(int a, int b) {
        return a * b;
    }
    
    private int divide(int a, int b) {
        return a / b;
    }
}
```

## 9.3 Collection Factory Methods (Java 9)

```java
import java.util.*;

public class CollectionFactoryMethods {
    
    public void demonstrateListOf() {
        // Immutable list
        List<String> list = List.of("A", "B", "C");
        // list.add("D");  // UnsupportedOperationException
        // list.set(0, "X");  // UnsupportedOperationException
        
        // Before Java 9
        List<String> oldWay = Collections.unmodifiableList(
            Arrays.asList("A", "B", "C")
        );
    }
    
    public void demonstrateSetOf() {
        // Immutable set (no duplicates)
        Set<String> set = Set.of("A", "B", "C");
        
        // Set.of("A", "A", "B");  // IllegalArgumentException (duplicates)
    }
    
    public void demonstrateMapOf() {
        // Immutable map
        Map<String, Integer> map = Map.of(
            "A", 1,
            "B", 2,
            "C", 3
        );
        
        // For more than 10 entries, use Map.ofEntries
        Map<String, Integer> largeMap = Map.ofEntries(
            Map.entry("A", 1),
            Map.entry("B", 2),
            Map.entry("C", 3),
            Map.entry("D", 4)
        );
    }
}
```

## 9.4 var - Local Variable Type Inference (Java 10)

```java
import java.util.*;

public class VarDemo {
    
    public void demonstrateVar() {
        // var infers type at compile time
        var message = "Hello";  // String
        var number = 42;        // int
        var decimal = 3.14;     // double
        var flag = true;        // boolean
        
        // With collections
        var list = new ArrayList<String>();
        var set = new HashSet<Integer>();
        var map = new HashMap<String, Integer>();
        
        // With complex types
        var future = CompletableFuture.supplyAsync(() -> "Result");
        var stream = list.stream().filter(s -> s.length() > 3);
        
        // With diamond operator
        var list2 = new ArrayList<>();  // ArrayList<Object>
        var list3 = new ArrayList<String>();  // ArrayList<String>
    }
    
    public void varWithLoops() {
        var list = List.of("A", "B", "C");
        
        // Enhanced for loop
        for (var item : list) {
            System.out.println(item);
        }
        
        // Traditional for loop
        for (var i = 0; i < list.size(); i++) {
            System.out.println(list.get(i));
        }
        
        // Try-with-resources
        try (var reader = new java.io.BufferedReader(
                new java.io.FileReader("file.txt"))) {
            var line = reader.readLine();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    // ❌ Cannot use var in these places:
    public void varLimitations() {
        // var field = "value";  // Cannot use for fields
        // Cannot use for method parameters
        // Cannot use for method return types
        // var x;  // Cannot use without initializer
        // var x = null;  // Cannot infer from null
        // var lambda = () -> "Hello";  // Cannot infer lambda type
        // var array = {1, 2, 3};  // Cannot infer array type
}
}
```

## 9.5 Text Blocks (Java 13+)

```java
public class TextBlocksDemo {
    
    public void demonstrateTextBlocks() {
        // Traditional string
        String json1 = "{\n" +
                      "  \"name\": \"John\",\n" +
                      "  \"age\": 30\n" +
                      "}";
        
        // Text block (Java 13+)
        String json2 = """
            {
              "name": "John",
              "age": 30
            }
            """;
        
        // HTML
        String html = """
            <html>
                <body>
                    <h1>Hello World</h1>
                </body>
            </html>
            """;
        
        // SQL
        String sql = """
            SELECT id, name, email
            FROM users
            WHERE age > 18
            ORDER BY name
            """;
        
        // With variables (Java 15+)
        String name = "Alice";
        int age = 25;
String message = """
            Hello, %s!
            You are %d years old.
            """.formatted(name, age);
    }
}
```

## 9.6 Records (Java 14+)

```java
public class RecordsDemo {
    
    // Traditional class (verbose)
    static class PersonOldWay {
        private final String name;
        private final int age;
        
        public PersonOldWay(String name, int age) {
            this.name = name;
            this.age = age;
        }
        
        public String name() { return name; }
        public int age() { return age; }
        
        @Override
        public boolean equals(Object obj) {
            if (!(obj instanceof PersonOldWay)) return false;
            PersonOldWay other = (PersonOldWay) obj;
            return name.equals(other.name) && age == other.age;
        }
        
        @Override
        public int hashCode() {
            return Objects.hash(name, age);
        }
        
        @Override
        public String toString() {
            return "Person[name=" + name + ", age=" + age + "]";
        }
    }
    
    // Record (concise) - Java 14+
    record Person(String name, int age) {
        // Automatic: constructor, getters, equals, hashCode, toString
    }
    
    // Record with validation
    record Employee(String name, int age, double salary) {
        // Compact constructor
        public Employee {
            if (age < 18) {
                throw new IllegalArgumentException("Age must be >= 18");
            }
            if (salary < 0) {
                throw new IllegalArgumentException("Salary must be >= 0");
            }
        }
    }
    
    // Record with custom methods
    record Rectangle(double width, double height) {
        public double area() {
            return width * height;
        }
        
        public double perimeter() {
            return 2 * (width + height);
        }
    }
    
    // Record with static methods
    record Point(int x, int y) {
        public static Point origin() {
            return new Point(0, 0);
        }
        
        public double distanceTo(Point other) {
            int dx = this.x - other.x;
            int dy = this.y - other.y;
            return Math.sqrt(dx * dx + dy * dy);
        }
    }
    
    public static void main(String[] args) {
        // Creating records
        Person person = new Person("Alice", 25);
        System.out.println(person.name());  // Alice
        System.out.println(person.age());   // 25
        System.out.println(person);  // Person[name=Alice, age=25]
        
        // Records are immutable
        // person.name = "Bob";  // Compilation error
        
        // Equality
        Person person2 = new Person("Alice", 25);
        System.out.println(person.equals(person2));  // true
        System.out.println(person == person2);  // false
        
        // Using in collections
        var people = List.of(
            new Person("Alice", 25),
            new Person("Bob", 30),
            new Person("Charlie", 35)
        );
        
        // With streams
        people.stream()
            .filter(p -> p.age() > 25)
            .forEach(System.out::println);
    }
}
```

## 9.7 Sealed Classes (Java 15+)

```java
public class SealedClassesDemo {
    
    // Sealed class - restricts which classes can extend it
    sealed interface Shape permits Circle, Rectangle, Triangle {
        double area();
    }
    
    // Permitted subclasses must be final, sealed, or non-sealed
    final class Circle implements Shape {
        private final double radius;
        
        public Circle(double radius) {
            this.radius = radius;
        }
        
        @Override
        public double area() {
            return Math.PI * radius * radius;
        }
    }
    
    final class Rectangle implements Shape {
        private final double width, height;
        
        public Rectangle(double width, double height) {
            this.width = width;
            this.height = height;
        }
        
        @Override
        public double area() {
            return width * height;
        }
    }
    
    // non-sealed allows further extension
    non-sealed class Triangle implements Shape {
        private final double base, height;
        
        public Triangle(double base, double height) {
            this.base = base;
            this.height = height;
        }
        
        @Override
        public double area() {
            return 0.5 * base * height;
        }
    }
    
    // Can extend non-sealed class
    class EquilateralTriangle extends Triangle {
        public EquilateralTriangle(double side) {
            super(side, side * Math.sqrt(3) / 2);
        }
    }
    
    // Real-world example: API responses
    sealed interface ApiResponse permits SuccessResponse, ErrorResponse {
    }
    
    record SuccessResponse(int statusCode, String body) implements ApiResponse {
    }
    
    record ErrorResponse(int statusCode, String errorMessage) implements ApiResponse {
    }
    
    public void handleResponse(ApiResponse response) {
        // Exhaustive switch (compiler ensures all cases covered)
        switch (response) {
            case SuccessResponse s -> 
                System.out.println("Success: " + s.body());
            case ErrorResponse e -> 
                System.out.println("Error: " + e.errorMessage());
        }
    }
}
```

## 9.8 Pattern Matching for instanceof (Java 14+)

```java
public class PatternMatchingDemo {
    
    // Before Java 14
    public String formatOldWay(Object obj) {
        if (obj instanceof String) {
            String str = (String) obj;  // Cast required
            return str.toUpperCase();
        } else if (obj instanceof Integer) {
            Integer num = (Integer) obj;  // Cast required
            return "Number: " + num;
        } else if (obj instanceof Double) {
            Double dbl = (Double) obj;  // Cast required
            return String.format("%.2f", dbl);
        }
        return obj.toString();
    }
    
    // Java 14+: Pattern matching
    public String formatNewWay(Object obj) {
        if (obj instanceof String str) {
            return str.toUpperCase();  // No cast needed
        } else if (obj instanceof Integer num) {
            return "Number: " + num;
        } else if (obj instanceof Double dbl) {
            return String.format("%.2f", dbl);
        }
        return obj.toString();
    }
    
    // With logical operators
    public void demonstrateWithLogical(Object obj) {
        if (obj instanceof String str && str.length() > 5) {
            System.out.println("Long string: " + str);
        }
        
        if (obj instanceof Integer num && num > 0) {
            System.out.println("Positive number: " + num);
        }
    }
    
    // Complex example
    public int calculateArea(Object shape) {
        if (shape instanceof Rectangle rect) {
            return rect.width * rect.height;
        } else if (shape instanceof Circle circle) {
            return (int) (Math.PI * circle.radius * circle.radius);
        } else {
            return 0;
        }
    }
    
    record Rectangle(int width, int height) {}
    record Circle(int radius) {}
}
```

## 9.9 Switch Expressions (Java 12+)

```java
public class SwitchExpressionsDemo {
    
    enum Day {
        MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY, SUNDAY
    }
    
    // Old switch statement
    public int getDaysOldWay(Day day) {
        int numLetters = 0;
        switch (day) {
            case MONDAY:
            case FRIDAY:
            case SUNDAY:
                numLetters = 6;
                break;
            case TUESDAY:
                numLetters = 7;
                break;
            case THURSDAY:
            case SATURDAY:
                numLetters = 8;
                break;
            case WEDNESDAY:
                numLetters = 9;
                break;
        }
        return numLetters;
    }
    
    // New switch expression (Java 12+)
    public int getDaysNewWay(Day day) {
        return switch (day) {
            case MONDAY, FRIDAY, SUNDAY -> 6;
            case TUESDAY -> 7;
            case THURSDAY, SATURDAY -> 8;
            case WEDNESDAY -> 9;
        };
    }
    
    // With yield (for complex logic)
    public String getDayType(Day day) {
        return switch (day) {
            case MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY -> {
                System.out.println("It's a weekday");
                yield "Weekday";
            }
            case SATURDAY, SUNDAY -> {
                System.out.println("It's a weekend");
                yield "Weekend";
            }
        };
    }
    
    // Pattern matching in switch (Java 17+)
    public String formatValue(Object obj) {
        return switch (obj) {
            case Integer i -> String.format("int %d", i);
            case Long l -> String.format("long %d", l);
            case Double d -> String.format("double %.2f", d);
            case String s -> String.format("String %s", s);
            case null -> "null";
            default -> obj.toString();
        };
    }
    
    // With guards (Java 17+)
    public String categorizeNumber(Object obj) {
        return switch (obj) {
            case Integer i && i > 0 -> "Positive integer";
            case Integer i && i < 0 -> "Negative integer";
            case Integer i -> "Zero";
            case Double d && d > 0 -> "Positive double";
            case Double d && d < 0 -> "Negative double";
            case Double d -> "Zero double";
            default -> "Not a number";
        };
    }
}
```

---

# 10. JAVA 10-17 FEATURES

## Quick Summary

| Feature | Java Version | Description |
|---------|-------------|-------------|
| var | 10 | Local variable type inference |
| Collection.copyOf() | 10 | Create immutable copy |
| String methods | 11 | isBlank(), lines(), strip(), repeat() |
| Files methods | 11 | readString(), writeString() |
| Switch Expressions | 12-14 | Enhanced switch with arrows |
| Text Blocks | 13-15 | Multi-line strings |
| Pattern Matching | 14-16 | instanceof with pattern variable |
| Records | 14-16 | Concise immutable data classes |
| Sealed Classes | 15-17 | Restrict class hierarchy |
| Pattern Match Switch | 17 | Switch with type patterns |

## Java 11 String Enhancements

```java
public class Java11StringMethods {
    
    public void demonstrateNewMethods() {
        // isBlank() - true if empty or only whitespace
        System.out.println("".isBlank());           // true
        System.out.println("  ".isBlank());         // true
        System.out.println(" hello ".isBlank());    // false
        
        // lines() - stream of lines
        String multiline = "Line1\nLine2\nLine3";
        multiline.lines().forEach(System.out::println);
        
        // strip(), stripLeading(), stripTrailing()
        String text = "  hello  ";
        System.out.println(text.strip());          // "hello"
        System.out.println(text.stripLeading());   // "hello  "
        System.out.println(text.stripTrailing());  // "  hello"
        
        // repeat()
        System.out.println("Ha".repeat(3));  // "HaHaHa"
        System.out.println("-".repeat(10));  // "----------"
    }
}
```

## Java 11 Files Enhancements

```java
import java.nio.file.*;
import java.io.IOException;

public class Java11FileMethods {
    
    public void demonstrateFilesMethods() throws IOException {
        Path path = Path.of("test.txt");
        
        // writeString()
        Files.writeString(path, "Hello World");
        
        // readString()
        String content = Files.readString(path);
        System.out.println(content);  // Hello World
        
        // Before Java 11
        // Files.write(path, "Hello".getBytes());
        // new String(Files.readAllBytes(path));
    }
}
```

---

# 11. INTERVIEW QUESTIONS

## Q1: What are functional interfaces? Can you name the built-in ones?

**Answer:**

A functional interface is an interface with exactly one abstract method. It can have multiple default and static methods, but only one abstract method. Used with lambda expressions and method references.

**Built-in Functional Interfaces:**

| Interface | Method | Takes | Returns | Use Case |
|-----------|--------|-------|---------|----------|
| Predicate<T> | test(T) | T | boolean | Filtering/Testing |
| Consumer<T> | accept(T) | T | void | Side effects |
| Supplier<T> | get() | nothing | T | Lazy evaluation |
| Function<T,R> | apply(T) | T | R | Transformation |
| UnaryOperator<T> | apply(T) | T | T | Same type transform |
| BinaryOperator<T> | apply(T,T) | T, T | T | Combining values |

**Example:**
```java
// Custom functional interface
@FunctionalInterface
interface Calculator {
    int calculate(int a, int b);
}

Calculator add = (a, b) -> a + b;
Calculator multiply = (a, b) -> a * b;
```

**Key Points:**
- `@FunctionalInterface` annotation is optional but recommended
- Can have `default` and `static` methods
- Enables functional programming style
- Used extensively in Stream API

---

## Q2: Difference between map() and flatMap() in Streams?

**Answer:**

| Aspect | map() | flatMap() |
|--------|-------|-----------|
| Purpose | Transform each element | Transform + flatten |
| Input | Stream<T> | Stream<T> |
| Output | Stream<R> | Stream<R> |
| Mapping | 1:1 | 1:many |
| Use Case | Simple transformation | Nested structures |

**Examples:**

```java
// map() - one-to-one transformation
List<String> names = Arrays.asList("Alice", "Bob", "Charlie");
List<Integer> lengths = names.stream()
    .map(String::length)  // [5, 3, 7]
    .collect(Collectors.toList());

// flatMap() - one-to-many transformation
List<List<Integer>> nested = Arrays.asList(
    Arrays.asList(1, 2, 3),
    Arrays.asList(4, 5, 6),
    Arrays.asList(7, 8, 9)
);

List<Integer> flattened = nested.stream()
    .flatMap(List::stream)  // [1, 2, 3, 4, 5, 6, 7, 8, 9]
    .collect(Collectors.toList());

// Real-world: Split sentences into words
List<String> sentences = Arrays.asList(
    "Hello World",
    "Java Streams"
);

List<String> words = sentences.stream()
    .flatMap(sentence -> Arrays.stream(sentence.split(" ")))
    .collect(Collectors.toList());  // [Hello, World, Java, Streams]
```

**Key Difference:** `map()` returns Stream of objects, `flatMap()` flattens Stream of Streams into single Stream.

---

## Q3: What is the difference between intermediate and terminal operations in Streams?

**Answer:**

| Aspect | Intermediate | Terminal |
|--------|-------------|----------|
| Return Type | Stream | Non-Stream (or void) |
| Execution | Lazy (deferred) | Eager (immediate) |
| Chaining | Can chain multiple | Ends the pipeline |
| Count | Multiple allowed | Only one per pipeline |

**Intermediate Operations:**
- `filter()`, `map()`, `flatMap()`, `distinct()`, `sorted()`, `peek()`, `limit()`, `skip()`
- Returns a new Stream
- Not executed until terminal operation is called

**Terminal Operations:**
- `collect()`, `forEach()`, `reduce()`, `count()`, `anyMatch()`, `allMatch()`, `findFirst()`, `findAny()`
- Returns a result or produces side effect
- Triggers execution of entire pipeline

**Example:**

```java
List<Integer> numbers = Arrays.asList(1, 2, 3, 4, 5);

// Nothing executes until terminal operation
Stream<Integer> stream = numbers.stream()
    .filter(n -> {
        System.out.println("Filtering: " + n);
        return n % 2 == 0;
    })
    .map(n -> {
        System.out.println("Mapping: " + n);
        return n * 2;
    });

// Terminal operation triggers execution
List<Integer> result = stream.collect(Collectors.toList());
// Output:
// Filtering: 1
// Filtering: 2
// Mapping: 2
// Filtering: 3
// Filtering: 4
// Mapping: 4
// Filtering: 5
```

**Key Point:** Streams are lazy - intermediate operations are not executed until a terminal operation is invoked.

---

## Q4: Optional best practices - what to avoid?

**Answer:**

**❌ DON'T:**

```java
// 1. Don't use get() without checking
Optional<String> opt = Optional.empty();
String value = opt.get();  // NoSuchElementException!

// 2. Don't use isPresent() + get()
if (opt.isPresent()) {
    String value = opt.get();
    System.out.println(value);
}

// 3. Don't use as field
class User {
    private Optional<String> name;  // Bad!
}

// 4. Don't use as method parameter
public void process(Optional<String> name) {  // Bad!
}

// 5. Don't return null
public Optional<String> getName() {
    return null;  // Bad! Return Optional.empty()
}
```

**✅ DO:**

```java
// 1. Use orElse() or orElseGet()
String value = opt.orElse("default");
String value = opt.orElseGet(() -> computeDefault());

// 2. Use ifPresent() or ifPresentOrElse()
opt.ifPresent(System.out::println);
opt.ifPresentOrElse(
    value -> System.out.println(value),
    () -> System.out.println("Empty")
);

// 3. Use as return type only
class User {
    private String name;  // Can be null
    
    public Optional<String> getName() {
        return Optional.ofNullable(name);
    }
}

// 4. Use regular nullable parameter
public void process(String name) {
    if (name != null) {
        // process
    }
}

// 5. Return Optional.empty()
public Optional<String> getName() {
    return Optional.empty();
}

// 6. Chain with map() and flatMap()
String city = Optional.ofNullable(user)
    .flatMap(User::getAddress)
    .map(Address::getCity)
    .orElse("Unknown");
```

---

## Q5: Difference between CompletableFuture and Future?

**Answer:**

| Feature | Future | CompletableFuture |
|---------|--------|-------------------|
| Completion | Only by task | Manual + automatic |
| Chaining | No | Yes (thenApply, etc.) |
| Combining | No | Yes (thenCombine, allOf) |
| Exception | get() throws | exceptionally(), handle() |
| Non-blocking | No | Yes (callbacks) |
| Java Version | 5 | 8 |

**Future (blocking):**

```java
ExecutorService executor = Executors.newFixedThreadPool(10);

Future<String> future = executor.submit(() -> {
    Thread.sleep(1000);
    return "Result";
});

// Blocking call
String result = future.get();  // Waits for completion
```

**CompletableFuture (non-blocking):**

```java
CompletableFuture<String> future = CompletableFuture.supplyAsync(() -> {
    sleep(1000);
    return "Result";
});

// Non-blocking chaining
future.thenApply(String::toUpperCase)
    .thenApply(s -> s + " WORLD")
    .thenAccept(System.out::println)
    .exceptionally(ex -> {
        System.err.println(ex);
        return null;
    });

// Combining multiple futures
CompletableFuture<Integer> future1 = CompletableFuture.supplyAsync(() -> 10);
CompletableFuture<Integer> future2 = CompletableFuture.supplyAsync(() -> 20);

CompletableFuture<Integer> combined = future1.thenCombine(
    future2,
    (a, b) -> a + b
);
```

**Key Advantages of CompletableFuture:**
1. Manual completion: `complete()`, `completeExceptionally()`
2. Chaining: `thenApply()`, `thenAccept()`, `thenRun()`
3. Combining: `thenCombine()`, `allOf()`, `anyOf()`
4. Exception handling: `exceptionally()`, `handle()`, `whenComplete()`
5. Non-blocking callbacks
6. Supports functional composition

---

## Q6: What are default methods? Why were they introduced?

**Answer:**

**Default methods** allow interfaces to have method implementations. Introduced in Java 8 to enable interface evolution without breaking existing implementations.

**Why Introduced:**
1. **Backward Compatibility:** Add new methods to interfaces without breaking implementations
2. **Multiple Inheritance of Behavior:** Classes can inherit behavior from multiple interfaces
3. **Enable Lambda Support:** Facilitate functional programming features

**Example:**

```java
// Java 7 - Cannot add new method without breaking implementations
interface Vehicle {
    void start();
    // void stop();  // Adding this breaks all implementations!
}

// Java 8+ - Can add with default implementation
interface VehicleNew {
    void start();
    
    default void stop() {  // Default implementation
        System.out.println("Vehicle stopped");
    }
    
    default void honk() {
        System.out.println("Beep!");
    }
}

class Car implements VehicleNew {
    @Override
    public void start() {
        System.out.println("Car started");
    }
    // Inherits stop() and honk()
}

class Truck implements VehicleNew {
    @Override
    public void start() {
        System.out.println("Truck started");
    }
    
    @Override
    public void stop() {  // Can override
        System.out.println("Truck stopped with air brakes");
    }
}
```

**Conflict Resolution:**

```java
interface A {
    default void print() {
        System.out.println("A");
    }
}

interface B {
    default void print() {
        System.out.println("B");
    }
}

// Must override to resolve conflict
class C implements A, B {
    @Override
    public void print() {
        A.super.print();  // Call A's implementation
        B.super.print();  // Call B's implementation
    }
}
```

**Real-World Usage:**
- `Collection.stream()` - added to existing Collection interface
- `List.sort()` - added to List interface
- `Map.forEach()`, `Map.getOrDefault()` - added to Map

---

## Q7: Parallel streams - when to use and when to avoid?

**Answer:**

**✅ Use Parallel Streams When:**

1. **Large datasets** (10,000+ elements)
2. **CPU-intensive operations** (computations, transformations)
3. **Independent operations** (no shared state)
4. **Operations take significant time**

```java
// Good use case: Large dataset with CPU-intensive operation
List<Integer> numbers = IntStream.rangeClosed(1, 1_000_000)
    .boxed()
    .collect(Collectors.toList());

// Parallel is faster here
long sum = numbers.parallelStream()
    .map(n -> expensiveComputation(n))
    .reduce(0, Integer::sum);
```

**❌ Avoid Parallel Streams When:**

1. **Small datasets** (< 10,000 elements) - overhead > benefit
2. **Order matters** - parallel can break order
3. **Shared mutable state** - race conditions
4. **Blocking operations** (I/O, database calls)
5. **Using forEach** with side effects

```java
// BAD: Shared mutable state
List<Integer> results = new ArrayList<>();  // Not thread-safe!
numbers.parallelStream()
    .forEach(n -> results.add(n * 2));  // Race condition!

// GOOD: Use collect
List<Integer> results = numbers.parallelStream()
    .map(n -> n * 2)
    .collect(Collectors.toList());  // Thread-safe

// BAD: Order-dependent
numbers.parallelStream()
    .forEach(System.out::println);  // Order not guaranteed

// GOOD: Use forEachOrdered
numbers.parallelStream()
    .forEachOrdered(System.out::println);  // Maintains order
```

**Performance Comparison:**

```java
// Sequential: 100ms
list.stream()
    .filter(...)
    .map(...)
    .collect(...);

// Parallel: Could be 25ms (4 cores) OR 150ms (overhead > benefit)
list.parallelStream()
    .filter(...)
    .map(...)
    .collect(...);
```

**Key Guidelines:**
- Profile before using parallel streams
- Use for CPU-bound, not I/O-bound operations
- Ensure thread safety
- Test with production-sized data

---

## Q8: Records vs regular classes - when to use each?

**Answer:**

**Records (Java 14+):**

**✅ Use When:**
- Immutable data carriers (DTOs, Value Objects)
- Simple data aggregates
- API responses, database entities
- No complex business logic
- Need automatic equals/hashCode/toString

```java
// Perfect for records
record User(Long id, String name, String email) {}
record Point(int x, int y) {}
record ApiResponse(int status, String body) {}

// Usage
User user = new User(1L, "Alice", "alice@example.com");
System.out.println(user.name());  // Accessor
System.out.println(user);  // Auto toString
```

**Regular Classes:**

**✅ Use When:**
- Mutable state required
- Complex behavior/business logic
- Need inheritance hierarchy
- Lazy initialization
- Builder pattern
- Framework requirements (JPA entities with setters)

```java
// Better as regular class
class ShoppingCart {
    private List<Item> items = new ArrayList<>();  // Mutable
    private double total;
    
    public void addItem(Item item) {  // Behavior
        items.add(item);
        total += item.getPrice();
    }
    
    public void removeItem(Item item) {
        items.remove(item);
        total -= item.getPrice();
    }
    
    public double applyDiscount(double percentage) {  // Complex logic
        return total * (1 - percentage / 100);
    }
}
```

**Comparison:**

| Feature | Record | Class |
|---------|--------|-------|
| Mutability | Immutable | Mutable |
| Inheritance | Cannot extend | Can extend |
| Fields | Final | Any |
| Constructor | Auto-generated | Manual |
| Getters | Auto (name()) | Manual |
| equals/hashCode | Auto | Manual |
| toString | Auto | Manual |
| Use Case | Data carriers | Business logic |

**Records with Validation:**

```java
record Employee(String name, int age, double salary) {
    // Compact constructor for validation
    public Employee {
        if (age < 18) {
            throw new IllegalArgumentException("Age must be >= 18");
        }
        if (salary < 0) {
            throw new IllegalArgumentException("Salary must be >= 0");
        }
    }
    
    // Custom methods allowed
    public double annualSalary() {
        return salary * 12;
    }
}
```

---

## Q9: LocalDateTime vs ZonedDateTime vs Instant - when to use?

**Answer:**

| Type | Has Date | Has Time | Has Timezone | Use Case |
|------|----------|----------|--------------|----------|
| LocalDate | ✅ | ❌ | ❌ | Birthdays, holidays |
| LocalTime | ❌ | ✅ | ❌ | Opening hours |
| LocalDateTime | ✅ | ✅ | ❌ | No timezone needed |
| ZonedDateTime | ✅ | ✅ | ✅ | Timezone-aware events |
| Instant | ✅ | ✅ | UTC | Timestamps, logging |

**LocalDateTime:**
```java
// Use for: Meetings in same timezone, local events
LocalDateTime meeting = LocalDateTime.of(2024, 3, 16, 14, 30);
// No timezone info - assumes local context
```

**ZonedDateTime:**
```java
// Use for: International meetings, distributed systems
ZonedDateTime nyMeeting = ZonedDateTime.of(
    LocalDateTime.of(2024, 3, 16, 14, 30),
    ZoneId.of("America/New_York")
);

ZonedDateTime londonMeeting = nyMeeting.withZoneSameInstant(
    ZoneId.of("Europe/London")
);
// NY 14:30 = London 19:30
```

**Instant:**
```java
// Use for: Logs, audit trails, machine timestamps
Instant timestamp = Instant.now();  // UTC timestamp
long epochMillis = timestamp.toEpochMilli();  // 1710599425123

// Converting between Instant and ZonedDateTime
ZonedDateTime zoned = timestamp.atZone(ZoneId.of("UTC"));
Instant instant = zoned.toInstant();
```

**Best Practices:**

```java
// ✅ GOOD: Store as Instant/ZonedDateTime in database
@Entity
class Event {
    @Column
    private Instant createdAt;  // UTC timestamp
    
    @Column
    private ZonedDateTime scheduledTime;  // With timezone
}

// ❌ BAD: Store LocalDateTime in multi-timezone app
@Entity
class Event {
    @Column
    private LocalDateTime scheduledTime;  // Which timezone?!
}

// Converting for display
ZonedDateTime utcTime = instant.atZone(ZoneId.of("UTC"));
ZonedDateTime userTime = utcTime.withZoneSameInstant(userTimeZone);
```

---

## Q10: Method references - all 4 types with examples?

**Answer:**

**1. Static Method Reference: `ClassName::staticMethod`**

```java
// Lambda
Function<String, Integer> lambda1 = s -> Integer.parseInt(s);

// Method reference
Function<String, Integer> methodRef1 = Integer::parseInt;

// Usage
List<String> numbers = Arrays.asList("1", "2", "3");
numbers.stream()
    .map(Integer::parseInt)  // Static method reference
    .forEach(System.out::println);
```

**2. Instance Method of Particular Object: `object::instanceMethod`**

```java
String prefix = "Hello, ";

// Lambda
Function<String, String> lambda2 = s -> prefix.concat(s);

// Method reference
Function<String, String> methodRef2 = prefix::concat;

// Usage
List<String> names = Arrays.asList("Alice", "Bob");
names.forEach(System.out::println);  // Instance method of System.out
```

**3. Instance Method of Arbitrary Object: `ClassName::instanceMethod`**

```java
// Lambda
Comparator<String> lambda3 = (s1, s2) -> s1.compareToIgnoreCase(s2);

// Method reference
Comparator<String> methodRef3 = String::compareToIgnoreCase;

// Usage
List<String> names = Arrays.asList("charlie", "Alice", "bob");
names.sort(String::compareToIgnoreCase);

List<String> upper = names.stream()
    .map(String::toUpperCase)  // Called on each string
    .collect(Collectors.toList());
```

**4. Constructor Reference: `ClassName::new`**

```java
// Lambda
Supplier<List<String>> lambda4 = () -> new ArrayList<>();

// Constructor reference
Supplier<List<String>> methodRef4 = ArrayList::new;

// With parameter
Function<String, Integer> intConstructor = Integer::new;
Integer num = intConstructor.apply("123");

// Array constructor
IntFunction<int[]> arrayCreator = int[]::new;
int[] array = arrayCreator.apply(10);  // Size 10

// Usage in streams
List<String> names = Arrays.asList("Alice", "Bob");
List<String> copy = names.stream()
    .collect(Collectors.toCollection(ArrayList::new));
```

**Summary Table:**

| Type | Syntax | Lambda Equivalent | Example |
|------|--------|-------------------|---------|
| Static | `Class::static` | `args -> Class.static(args)` | `Integer::parseInt` |
| Instance (specific) | `obj::method` | `args -> obj.method(args)` | `System.out::println` |
| Instance (arbitrary) | `Class::instance` | `(obj, args) -> obj.instance(args)` | `String::length` |
| Constructor | `Class::new` | `args -> new Class(args)` | `ArrayList::new` |

---

## Q11-Q15: Quick Fire Questions

**Q11: What is the diamond problem and how do default methods handle it?**

**A:** When a class implements two interfaces with same default method, compilation error occurs. Must override method in class and can call specific interface's implementation using `InterfaceA.super.methodName()`.

**Q12: Can you override default methods?**

**A:** Yes. Classes can override default methods. Subinterfaces can override default methods and make them abstract again.

**Q13: Difference between Stream and Collection?**

**A:** Collections store data, Streams process data. Streams are lazy, single-use, and can be infinite. Collections are eager, reusable, and finite.

**Q14: Can we use var for method parameters or return types?**

**A:** No. `var` only for local variables with initializers. Cannot use for fields, parameters, return types, or without initializer.

**Q15: What are sealed classes used for?**

**A:** Restrict which classes can extend/implement them. Provides exhaustive switch without default case. Used for controlled hierarchies like API responses, state machines, AST nodes.

---

# 12. INTERVIEW TRAPS & EDGE CASES

## Trap 1: Stream Reuse

**❌ TRAP:**

```java
Stream<String> stream = List.of("A", "B", "C").stream();
stream.forEach(System.out::println);  // OK
stream.forEach(System.out::println);  // IllegalStateException!
```

**✅ SOLUTION:**

```java
List<String> list = List.of("A", "B", "C");

// Create new stream each time
list.stream().forEach(System.out::println);
list.stream().map(String::toLowerCase).forEach(System.out::println);
```

**KEY POINT:** Streams are single-use. Once a terminal operation is called, stream is consumed.

---

## Trap 2: Modifying Collection During Stream

**❌ TRAP:**

```java
List<String> names = new ArrayList<>(Arrays.asList("Alice", "Bob", "Charlie"));

names.stream()
    .filter(name -> {
        if (name.startsWith("B")) {
            names.remove(name);  // ConcurrentModificationException!
        }
        return true;
    })
    .forEach(System.out::println);
```

**✅ SOLUTION:**

```java
// Use removeIf
names.removeIf(name -> name.startsWith("B"));

// Or collect to new list
List<String> filtered = names.stream()
    .filter(name -> !name.startsWith("B"))
    .collect(Collectors.toList());
```

---

## Trap 3: Optional.of() with null

**❌ TRAP:**

```java
String value = null;
Optional<String> opt = Optional.of(value);  // NullPointerException!
```

**✅ SOLUTION:**

```java
// Use ofNullable for potentially null values
Optional<String> opt = Optional.ofNullable(value);
```

---

## Trap 4: Lambda Variable Capture

**❌ TRAP:**

```java
List<Runnable> runnables = new ArrayList<>();

for (int i = 0; i < 5; i++) {
    runnables.add(() -> System.out.println(i));  // ERROR: i not effectively final
}
```

**✅ SOLUTION:**

```java
List<Runnable> runnables = new ArrayList<>();

for (int i = 0; i < 5; i++) {
    final int index = i;  // Make copy that's final
    runnables.add(() -> System.out.println(index));
}
```

---

## Trap 5: Collect vs Reduce for Mutability

**❌ TRAP:**

```java
// Using reduce with mutable container - NOT thread-safe in parallel!
List<String> result = strings.parallelStream()
    .reduce(
        new ArrayList<>(),
        (list, item) -> {
            list.add(item);  // Mutating identity!
            return list;
        },
        (list1, list2) -> {
            list1.addAll(list2);  // Race condition!
            return list1;
        }
    );
```

**✅ SOLUTION:**

```java
// Use collect for mutable containers
List<String> result = strings.parallelStream()
    .collect(Collectors.toList());

// Or use collect with custom collector
List<String> result = strings.parallelStream()
    .collect(
        ArrayList::new,      // Supplier
        ArrayList::add,      // Accumulator
        ArrayList::addAll    // Combiner
    );
```

---

## Trap 6: Records Are Shallow Immutable

**❌ TRAP:**

```java
record User(String name, List<String> roles) {}

User user = new User("Alice", new ArrayList<>(List.of("ADMIN")));
user.roles().add("USER");  // Works! List is mutable!
System.out.println(user.roles());  // [ADMIN, USER]
```

**✅ SOLUTION:**

```java
// Defensive copying in record
record User(String name, List<String> roles) {
    public User {
        roles = List.copyOf(roles);  // Make immutable copy
    }
}

User user = new User("Alice", new ArrayList<>(List.of("ADMIN")));
user.roles().add("USER");  // UnsupportedOperationException
```

---

## Trap 7: Method Reference vs Lambda with Exceptions

**❌ TRAP:**

```java
List<String> numbers = Arrays.asList("1", "2", "abc", "4");

// Method reference doesn't handle exceptions
numbers.stream()
    .map(Integer::parseInt)  // NumberFormatException on "abc"!
    .forEach(System.out::println);
```

**✅ SOLUTION:**

```java
// Use lambda with try-catch
List<Integer> result = numbers.stream()
    .map(s -> {
        try {
            return Integer.parseInt(s);
        } catch (NumberFormatException e) {
            return 0;  // Default value
        }
    })
    .collect(Collectors.toList());

// Or filter first
List<Integer> result = numbers.stream()
    .filter(s -> s.matches("\\d+"))  // Filter valid numbers
    .map(Integer::parseInt)
    .collect(Collectors.toList());
```

---

## Trap 8: CompletableFuture Exception Handling

**❌ TRAP:**

```java
CompletableFuture<String> future = CompletableFuture.supplyAsync(() -> {
    throw new RuntimeException("Error");
});

// Exception is wrapped in CompletionException
try {
    future.join();
} catch (RuntimeException e) {
    // e is CompletionException, not RuntimeException!
    System.out.println(e.getClass());  // CompletionException
    System.out.println(e.getCause().getClass());  // RuntimeException
}
```

**✅ SOLUTION:**

```java
// Handle exceptions in the chain
CompletableFuture<String> future = CompletableFuture.supplyAsync(() -> {
    throw new RuntimeException("Error");
}).exceptionally(ex -> {
    // ex.getCause() is the original exception
    System.out.println("Caught: " + ex.getCause().getMessage());
    return "Default";
});

// Or use handle()
future.handle((result, ex) -> {
    if (ex != null) {
        return "Error: " + ex.getCause().getMessage();
    }
    return result;
});
```

---

## Trap 9: ZonedDateTime Comparison

**❌ TRAP:**

```java
ZonedDateTime ny = ZonedDateTime.of(
    LocalDateTime.of(2024, 3, 16, 14, 0),
    ZoneId.of("America/New_York")
);

ZonedDateTime london = ZonedDateTime.of(
    LocalDateTime.of(2024, 3, 16, 14, 0),  // Same local time
    ZoneId.of("Europe/London")
);

System.out.println(ny.equals(london));  // false! Different instants
System.out.println(ny.isEqual(london));  // false! Different instants
```

**✅ SOLUTION:**

```java
// Compare instants, not local times
Instant nyInstant = ny.toInstant();
Instant londonInstant = london.toInstant();
System.out.println(nyInstant.equals(londonInstant));  // false

// Convert to same timezone for comparison
ZonedDateTime londonInNY = london.withZoneSameInstant(ZoneId.of("America/New_York"));
System.out.println(londonInNY.getHour());  // 9 (London 14:00 = NY 09:00)
```

---

## Trap 10: Text Blocks Indentation

**❌ TRAP:**

```java
String json = """
    {
      "name": "John",
      "age": 30
    }
    """;
// All indentation preserved!
// Output has leading spaces
```

**✅ SOLUTION:**

```java
// Text block trims common indentation
String json = """
    {
      "name": "John",
      "age": 30
    }
    """;
// Output:
// {
//   "name": "John",
//   "age": 30
// }

// Use stripIndent() or indent() for control
String withIndent = text.indent(4);
String noIndent = text.stripIndent();
```

---

# 13. CODING PROBLEMS

## Problem 1: Implement Custom Collector for Grouping

**Problem:** Create a custom collector that groups strings by length and counts occurrences.

```java
import java.util.*;
import java.util.function.*;
import java.util.stream.*;

public class Problem1CustomCollector {
    
    /**
     * Create collector that groups strings by length
     * and counts how many strings of each length
     * 
     * Input: ["a", "bb", "ccc", "dd", "e"]
     * Output: {1=2, 2=2, 3=1}
     */
    
    // Solution 1: Using existing collectors
    public static Map<Integer, Long> groupByLengthBuiltIn(List<String> strings) {
        return strings.stream()
            .collect(Collectors.groupingBy(
                String::length,
                Collectors.counting()
            ));
    }
    
    // Solution 2: Custom Collector from scratch
    public static Collector<String, ?, Map<Integer, Long>> lengthGroupingCollector() {
        return Collector.of(
            // Supplier: create accumulator
            HashMap::new,
            
            // Accumulator: add element
            (map, str) -> map.merge(str.length(), 1L, Long::sum),
            
            // Combiner: combine two accumulators (for parallel)
            (map1, map2) -> {
                map2.forEach((key, value) -> 
                    map1.merge(key, value, Long::sum));
                return map1;
            },
            
            // Optional: Finisher (identity function here)
            Collector.Characteristics.IDENTITY_FINISH
        );
    }
    
    // Solution 3: More complex - group and collect actual strings
    public static Collector<String, ?, Map<Integer, List<String>>> 
            lengthGroupingWithStrings() {
        
        return Collector.of(
            HashMap::new,
            (map, str) -> map.computeIfAbsent(
                str.length(), 
                k -> new ArrayList<>()
            ).add(str),
            (map1, map2) -> {
                map2.forEach((key, value) -> 
                    map1.computeIfAbsent(key, k -> new ArrayList<>())
                       .addAll(value));
                return map1;
            }
        );
    }
    
    // Test
    public static void main(String[] args) {
        List<String> words = Arrays.asList(
            "a", "bb", "ccc", "dd", "e", "fff", "g"
        );
        
        // Solution 1
        Map<Integer, Long> counts1 = groupByLengthBuiltIn(words);
        System.out.println("Built-in: " + counts1);
        // {1=3, 2=2, 3=2}
        
        // Solution 2
        Map<Integer, Long> counts2 = words.stream()
            .collect(lengthGroupingCollector());
        System.out.println("Custom: " + counts2);
        // {1=3, 2=2, 3=2}
        
        // Solution 3
        Map<Integer, List<String>> groups = words.stream()
            .collect(lengthGroupingWithStrings());
        System.out.println("With strings: " + groups);
        // {1=[a, e, g], 2=[bb, dd], 3=[ccc, fff]}
    }
}
```

**Key Concepts:**
- Custom Collector with Supplier, Accumulator, Combiner
- `merge()` for combining map values
- `computeIfAbsent()` for lazy initialization
- Collector characteristics

---

## Problem 2: FlatMap - Find All Unique Characters

**Problem:** Given list of strings, find all unique characters across all strings, sorted alphabetically.

```java
import java.util.*;
import java.util.stream.*;

public class Problem2UniqueCharacters {
    
    /**
     * Find all unique characters from list of strings
     * 
     * Input: ["hello", "world"]
     * Output: ['d', 'e', 'h', 'l', 'o', 'r', 'w']
     */
    
    // Solution 1: Using flatMap with chars()
    public static List<Character> findUniqueChars1(List<String> strings) {
        return strings.stream()
            .flatMapToInt(String::chars)  // IntStream of char codes
            .distinct()
            .sorted()
            .mapToObj(c -> (char) c)  // Convert back to Character
            .collect(Collectors.toList());
    }
    
    // Solution 2: Using flatMap with split
    public static List<Character> findUniqueChars2(List<String> strings) {
        return strings.stream()
            .flatMap(s -> s.chars().mapToObj(c -> (char) c))
            .distinct()
            .sorted()
            .collect(Collectors.toList());
    }
    
    // Solution 3: Using Set for deduplication
    public static Set<Character> findUniqueCharsSet(List<String> strings) {
        return strings.stream()
            .flatMapToInt(String::chars)
            .mapToObj(c -> (char) c)
            .collect(Collectors.toCollection(TreeSet::new));  // Sorted set
    }
    
    // Extension: Count character frequencies
    public static Map<Character, Long> countCharFrequencies(List<String> strings) {
        return strings.stream()
            .flatMapToInt(String::chars)
            .mapToObj(c -> (char) c)
            .collect(Collectors.groupingBy(
                c -> c,
                Collectors.counting()
            ));
    }
    
    // Extension: Find characters appearing in all strings
    public static Set<Character> findCommonChars(List<String> strings) {
        if (strings.isEmpty()) return Collections.emptySet();
        
        // Get character set for first string
        Set<Character> commonChars = strings.get(0)
            .chars()
            .mapToObj(c -> (char) c)
            .collect(Collectors.toSet());
        
        // Retain only characters present in all strings
        strings.stream()
            .skip(1)
            .forEach(s -> {
                Set<Character> currentChars = s.chars()
                    .mapToObj(c -> (char) c)
                    .collect(Collectors.toSet());
                commonChars.retainAll(currentChars);
            });
        
        return commonChars;
    }
    
    // Test
    public static void main(String[] args) {
        List<String> words = Arrays.asList("hello", "world", "java");
        
        System.out.println("Unique chars (List): " + 
            findUniqueChars1(words));
        // [a, d, e, h, j, l, o, r, v, w]
        
        System.out.println("Unique chars (Set): " + 
            findUniqueCharsSet(words));
        // [a, d, e, h, j, l, o, r, v, w]
        
        System.out.println("Character frequencies: " + 
            countCharFrequencies(words));
        // {a=3, d=1, e=1, h=1, j=1, l=4, o=2, r=1, v=1, w=1}
        
        System.out.println("Common characters: " + 
            findCommonChars(words));
        // [l, o]
    }
}
```

**Key Concepts:**
- `flatMap()` to flatten nested structures
- `chars()` returns IntStream of character codes
- `mapToObj()` to convert primitive stream to object stream
- `distinct()` for deduplication
- TreeSet for sorted unique elements

---

## Problem 3: CompletableFuture - Parallel API Aggregation

**Problem:** Fetch data from multiple APIs in parallel,aggregate results, with timeout and fallback.

```java
import java.util.*;
import java.util.concurrent.*;
import java.util.stream.*;

public class Problem3ParallelAPIAggregation {
    
    /**
     * Fetch data from multiple services in parallel
     * - Timeout after 2 seconds
     * - Fallback if service fails
     * - Return aggregated result
     */
    
    // Simulated API services
    static class UserService {
        public static CompletableFuture<String> fetchUser(String userId) {
            return CompletableFuture.supplyAsync(() -> {
                sleep(500);
                if (Math.random() > 0.8) {
                    throw new RuntimeException("UserService failed");
                }
                return "User:" + userId;
            });
        }
    }
    
    static class OrderService {
        public static CompletableFuture<List<String>> fetchOrders(String userId) {
            return CompletableFuture.supplyAsync(() -> {
                sleep(800);
                return Arrays.asList("Order1", "Order2");
            });
        }
    }
    
    static class PaymentService {
        public static CompletableFuture<Double> fetchBalance(String userId) {
            return CompletableFuture.supplyAsync(() -> {
                sleep(600);
                return 1000.0;
            });
        }
    }
    
    static class ProfileResponse {
        String user;
        List<String> orders;
        Double balance;
        
        @Override
        public String toString() {
            return String.format("Profile[user=%s, orders=%d, balance=%.2f]",
                user, orders.size(), balance);
        }
    }
    
    // Solution: Parallel aggregation with timeout and fallbacks
    public static CompletableFuture<ProfileResponse> fetchUserProfile(String userId) {
        // Start all requests in parallel
        CompletableFuture<String> userFuture = UserService.fetchUser(userId)
            .completeOnTimeout("Unknown User", 2, TimeUnit.SECONDS)  // Timeout
            .exceptionally(ex -> "Guest User");  // Fallback
        
        CompletableFuture<List<String>> ordersFuture = OrderService.fetchOrders(userId)
            .completeOnTimeout(Collections.emptyList(), 2, TimeUnit.SECONDS)
            .exceptionally(ex -> Collections.emptyList());
        
        CompletableFuture<Double> balanceFuture = PaymentService.fetchBalance(userId)
            .completeOnTimeout(0.0, 2, TimeUnit.SECONDS)
            .exceptionally(ex -> 0.0);
        
        // Combine all results
        return userFuture.thenCombine(ordersFuture, (user, orders) -> {
            ProfileResponse profile = new ProfileResponse();
            profile.user = user;
            profile.orders = orders;
            return profile;
        }).thenCombine(balanceFuture, (profile, balance) -> {
            profile.balance = balance;
            return profile;
        });
    }
    
    // Alternative: Using allOf()
    public static CompletableFuture<ProfileResponse> fetchUserProfileAllOf(String userId) {
        CompletableFuture<String> userFuture = UserService.fetchUser(userId)
            .exceptionally(ex -> "Guest User");
        
        CompletableFuture<List<String>> ordersFuture = OrderService.fetchOrders(userId)
            .exceptionally(ex -> Collections.emptyList());
        
        CompletableFuture<Double> balanceFuture = PaymentService.fetchBalance(userId)
            .exceptionally(ex -> 0.0);
        
        return CompletableFuture.allOf(userFuture, ordersFuture, balanceFuture)
            .thenApply(v -> {
                ProfileResponse profile = new ProfileResponse();
                profile.user = userFuture.join();
                profile.orders = ordersFuture.join();
                profile.balance = balanceFuture.join();
                return profile;
            });
    }
    
    // Fetch multiple users in parallel
    public static CompletableFuture<List<ProfileResponse>> fetchMultipleProfiles(
            List<String> userIds) {
        
        List<CompletableFuture<ProfileResponse>> futures = userIds.stream()
            .map(Problem3ParallelAPIAggregation::fetchUserProfile)
            .collect(Collectors.toList());
        
        return CompletableFuture.allOf(futures.toArray(new CompletableFuture[0]))
            .thenApply(v -> futures.stream()
                .map(CompletableFuture::join)
                .collect(Collectors.toList()));
    }
    
    // Test
    public static void main(String[] args) {
        long start = System.currentTimeMillis();
        
        // Single user
        ProfileResponse profile = fetchUserProfile("USER123")
            .join();
        
        long duration = System.currentTimeMillis() - start;
        System.out.println(profile);
        System.out.println("Took: " + duration + "ms");  // ~800ms (parallel)
        
        // Multiple users
        List<String> userIds = Arrays.asList("USER1", "USER2", "USER3");
        List<ProfileResponse> profiles = fetchMultipleProfiles(userIds)
            .join();
        
        System.out.println("\nMultiple profiles:");
        profiles.forEach(System.out::println);
    }
    
    private static void sleep(long millis) {
        try {
            Thread.sleep(millis);
        } catch (InterruptedException e) {
            throw new RuntimeException(e);
        }
    }
}
```

**Key Concepts:**
- Parallel API calls with `CompletableFuture.supplyAsync()`
- Combining futures with `thenCombine()` and `allOf()`
- Timeout with `completeOnTimeout()`
- Exception handling with `exceptionally()`
- Processing multiple items in parallel

---

## Problem 4: Stream Reduce - Implement Custom Operations

**Problem:** Implement various custom aggregation operations using `reduce()`.

```java
import java.util.*;
import java.util.stream.*;

public class Problem4CustomReduceOperations {
    
    /**
     * Implement custom reductions:
     * 1. Find max value
     * 2. Calculate product
     * 3. Reverse concatenate strings
     * 4. Complex object aggregation
     */
    
    static class Transaction {
        String type;
        double amount;
        
        public Transaction(String type, double amount) {
            this.type = type;
            this.amount = amount;
        }
    }
    
    // 1. Find maximum using reduce
    public static Optional<Integer> findMax(List<Integer> numbers) {
        return numbers.stream()
            .reduce((a, b) -> a > b ? a : b);
        
        // Or using Integer::max
        // return numbers.stream().reduce(Integer::max);
    }
    
    // 2. Calculate product of all numbers
    public static int calculateProduct(List<Integer> numbers) {
        return numbers.stream()
            .reduce(1, (a, b) -> a * b);
    }
    
    // 3. Reverse concatenate strings with separator
    public static String reverseConcatenate(List<String> strings) {
        return strings.stream()
            .reduce("", (result, str) -> str + " " + result)
            .trim();
    }
    
    // 4. Calculate net balance from transactions
    public static double calculateNetBalance(List<Transaction> transactions) {
        return transactions.stream()
            .reduce(
                0.0,  // Initial balance
                (balance, transaction) -> {
                    if ("DEPOSIT".equals(transaction.type)) {
                        return balance + transaction.amount;
                    } else if ("WITHDRAWAL".equals(transaction.type)) {
                        return balance - transaction.amount;
                    }
                    return balance;
                },
                Double::sum  // Combiner for parallel streams
            );
    }
    
    // 5. Find longest string
    public static Optional<String> findLongest(List<String> strings) {
        return strings.stream()
            .reduce((s1, s2) -> s1.length() >= s2.length() ? s1 : s2);
    }
    
    // 6. Build statistics object
    static class Statistics {
        int count;
        int sum;
        int min;
        int max;
        
        @Override
        public String toString() {
            return String.format(
                "Statistics[count=%d, sum=%d, min=%d, max=%d, avg=%.2f]",
                count, sum, min, max, (double) sum / count
            );
        }
    }
    
    public static Statistics calculateStatistics(List<Integer> numbers) {
        return numbers.stream()
            .reduce(
                new Statistics(),  // Identity
                (stats, num) -> {
                    if (stats.count == 0) {
                        stats.min = num;
                        stats.max = num;
                    }
                    stats.count++;
                    stats.sum += num;
                    stats.min = Math.min(stats.min, num);
                    stats.max = Math.max(stats.max, num);
                    return stats;
                },
                (stats1, stats2) -> {  // Combiner
                    stats1.count += stats2.count;
                    stats1.sum += stats2.sum;
                    stats1.min = Math.min(stats1.min, stats2.min);
                    stats1.max = Math.max(stats1.max, stats2.max);
                    return stats1;
                }
            );
    }
    
    // 7. Custom joining with prefix/suffix
    public static String customJoin(List<String> strings, 
                                   String delimiter, 
                                   String prefix, 
                                   String suffix) {
        String joined = strings.stream()
            .reduce((s1, s2) -> s1 + delimiter + s2)
            .orElse("");
        return prefix + joined + suffix;
    }
    
    // Test
    public static void main(String[] args) {
        // Test 1: Find max
        List<Integer> numbers = Arrays.asList(5, 2, 8, 1, 9, 3);
        System.out.println("Max: " + findMax(numbers).get());  // 9
        
        // Test 2: Product
        List<Integer> nums = Arrays.asList(2, 3, 4);
        System.out.println("Product: " + calculateProduct(nums));  // 24
        
        // Test 3: Reverse concatenate
        List<String> words = Arrays.asList("Hello", "World", "Java");
        System.out.println("Reversed: " + reverseConcatenate(words));
        // "Java World Hello"
        
        // Test 4: Net balance
        List<Transaction> transactions = Arrays.asList(
            new Transaction("DEPOSIT", 1000),
            new Transaction("WITHDRAWAL", 200),
            new Transaction("DEPOSIT", 500),
            new Transaction("WITHDRAWAL", 300)
        );
        System.out.println("Balance: $" + calculateNetBalance(transactions));
        // 1000.0
        
        // Test 5: Longest string
        System.out.println("Longest: " + findLongest(words).get());
        // "Hello" or "World" (both length 5)
        
        // Test 6: Statistics
        System.out.println(calculateStatistics(numbers));
        // Statistics[count=6, sum=28, min=1, max=9, avg=4.67]
        
        // Test 7: Custom join
        System.out.println(customJoin(words, ", ", "[", "]"));
        // [Hello, World, Java]
    }
}
```

**Key Concepts:**
- `reduce(identity, accumulator, combiner)` form
- Identity value for initialization
- Accumulator function combines element with result
- Combiner function merges results in parallel streams
- Building complex objects with reduce

---

**SUMMARY:**

This comprehensive Java 8+ Features Interview Guide covers:

✅ **Core Topics:**
- Lambda Expressions & Functional Interfaces
- Method References (all 4 types)
- Stream API (creation, intermediate, terminal operations)
- Optional API with best practices
- Default & Static Methods in Interfaces
- Date/Time API (LocalDate, ZonedDateTime, Instant, Period, Duration)
- CompletableFuture for async programming

✅ **Modern Java (9-17):**
- Modules, Collection Factory Methods
- var LocalVariable Type Inference
- Text Blocks
- Records
- Sealed Classes
- Pattern Matching for instanceof
- Switch Expressions

✅ **Interview Preparation:**
- 15 Interview Questions with detailed answers
- 10 Interview Traps & Edge Cases
- 4 Complete Coding Problems with multiple solutions
- Real-world examples throughout

**Total:** ~5000+ lines of production-quality interview preparation material for 5+ year experienced backend developers!

**Continue with next topic?**
