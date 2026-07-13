# Java Lambda & Functional Programming

## Lambda Expressions (Java 8+)

### What is a Lambda?

A lambda expression is a concise way to represent an anonymous function (a function without a name).

```java
// Anonymous class (old way)
Runnable runnable1 = new Runnable() {
    @Override
    public void run() {
        System.out.println("Hello");
    }
};

// Lambda expression (new way)
Runnable runnable2 = () -> System.out.println("Hello");
```

### Lambda Syntax

```java
// Syntax: (parameters) -> expression
// or: (parameters) -> { statements; }

// No parameters
() -> System.out.println("Hello")
() -> { return 42; }

// One parameter (parentheses optional)
x -> x * x
(x) -> x * x

// Multiple parameters
(x, y) -> x + y
(x, y) -> { return x + y; }

// With types
(int x, int y) -> x + y
(String s) -> s.length()
```

## Functional Interfaces

### What is a Functional Interface?

An interface with exactly ONE abstract method. Can be used with lambdas.

```java
@FunctionalInterface
public interface Calculator {
    int calculate(int a, int b);  // Single abstract method
    
    // Can have default methods
    default void print(int result) {
        System.out.println("Result: " + result);
    }
    
    // Can have static methods
    static Calculator add() {
        return (a, b) -> a + b;
    }
}

// Usage
Calculator add = (a, b) -> a + b;
Calculator multiply = (a, b) -> a * b;

System.out.println(add.calculate(5, 3));      // 8
System.out.println(multiply.calculate(5, 3)); // 15
```

### Built-in Functional Interfaces

#### Predicate<T> - Tests a condition

```java
import java.util.function.Predicate;

public class PredicateDemo {
    public static void main(String[] args) {
        // Predicate: T -> boolean
        Predicate<String> isEmpty = s -> s.isEmpty();
        Predicate<Integer> isEven = n -> n % 2 == 0;
        Predicate<String> startsWithA = s -> s.startsWith("A");
        
        System.out.println(isEmpty.test(""));        // true
        System.out.println(isEven.test(10));         // true
        System.out.println(startsWithA.test("Apple")); // true
        
        // Combining predicates
        Predicate<Integer> isPositive = n -> n > 0;
        Predicate<Integer> isPositiveEven = isEven.and(isPositive);
        
        System.out.println(isPositiveEven.test(10));  // true
        System.out.println(isPositiveEven.test(-10)); // false
    }
}
```

#### Function<T, R> - Transforms input to output

```java
import java.util.function.Function;

public class FunctionDemo {
    public static void main(String[] args) {
        // Function: T -> R
        Function<String, Integer> length = s -> s.length();
        Function<Integer, Integer> square = n -> n * n;
        Function<String, String> uppercase = s -> s.toUpperCase();
        
        System.out.println(length.apply("Hello"));    // 5
        System.out.println(square.apply(5));          // 25
        System.out.println(uppercase.apply("java"));  // JAVA
        
        // Chaining functions
        Function<String, Integer> lengthSquared = length.andThen(square);
        System.out.println(lengthSquared.apply("Hi")); // 4 (length=2, square=4)
        
        // Composing functions
        Function<Integer, String> asString = Object::toString;
        Function<String, Integer> parseAndSquare = asString.compose(square);
        System.out.println(parseAndSquare.apply(5)); // 25
    }
}
```

#### Consumer<T> - Accepts input, returns nothing

```java
import java.util.function.Consumer;

public class ConsumerDemo {
    public static void main(String[] args) {
        // Consumer: T -> void
        Consumer<String> print = s -> System.out.println(s);
        Consumer<Integer> printSquare = n -> System.out.println(n * n);
        
        print.accept("Hello");      // Hello
        printSquare.accept(5);      // 25
        
        // Chaining consumers
        Consumer<String> printUppercase = s -> System.out.println(s.toUpperCase());
        Consumer<String> printAndUppercase = print.andThen(printUppercase);
        
        printAndUppercase.accept("java");
        // Output:
        // java
        // JAVA
    }
}
```

#### Supplier<T> - Provides a value

```java
import java.util.function.Supplier;

public class SupplierDemo {
    public static void main(String[] args) {
        // Supplier: () -> T
        Supplier<String> hello = () -> "Hello";
        Supplier<Double> random = () -> Math.random();
        Supplier<Integer> constant = () -> 42;
        
        System.out.println(hello.get());    // Hello
        System.out.println(random.get());   // 0.123456...
        System.out.println(constant.get()); // 42
        
        // Lazy evaluation
        Supplier<String> expensiveOperation = () -> {
            System.out.println("Computing...");
            return "Result";
        };
        
        // Not executed until get() is called
        System.out.println("Before get()");
        String result = expensiveOperation.get();
        System.out.println("After get(): " + result);
    }
}
```

#### BiFunction<T, U, R> - Two inputs, one output

```java
import java.util.function.BiFunction;

public class BiFunctionDemo {
    public static void main(String[] args) {
        // BiFunction: (T, U) -> R
        BiFunction<Integer, Integer, Integer> add = (a, b) -> a + b;
        BiFunction<String, String, String> concat = (s1, s2) -> s1 + s2;
        BiFunction<Integer, Integer, Double> average = 
            (a, b) -> (a + b) / 2.0;
        
        System.out.println(add.apply(5, 3));           // 8
        System.out.println(concat.apply("Hello", " World")); // Hello World
        System.out.println(average.apply(10, 20));     // 15.0
    }
}
```

### All Built-in Functional Interfaces

```java
import java.util.function.*;

public class AllFunctionalInterfaces {
    public static void main(String[] args) {
        // Basic
        Predicate<String> predicate = s -> s.isEmpty();     // T -> boolean
        Function<String, Integer> function = s -> s.length(); // T -> R
        Consumer<String> consumer = s -> System.out.println(s); // T -> void
        Supplier<String> supplier = () -> "Hello";           // () -> T
        
        // Binary versions
        BiPredicate<String, String> biPredicate = (s1, s2) -> s1.equals(s2);
        BiFunction<Integer, Integer, Integer> biFunction = (a, b) -> a + b;
        BiConsumer<String, Integer> biConsumer = (s, i) -> System.out.println(s + i);
        
        // Unary/Binary operators (same type input and output)
        UnaryOperator<Integer> unary = n -> n * 2;          // T -> T
        BinaryOperator<Integer> binary = (a, b) -> a + b;   // (T, T) -> T
        
        // Primitive specializations
        IntPredicate intPredicate = n -> n > 0;
        IntFunction<String> intFunction = n -> String.valueOf(n);
        IntConsumer intConsumer = n -> System.out.println(n);
        IntSupplier intSupplier = () -> 42;
        IntUnaryOperator intUnary = n -> n * 2;
        IntBinaryOperator intBinary = (a, b) -> a + b;
        
        // Similar for: LongXxx, DoubleXxx
    }
}
```

## Method References

### Types of Method References

```java
import java.util.*;
import java.util.function.*;

public class MethodReferenceDemo {
    // 1. Static method reference
    Function<String, Integer> parseInt1 = s -> Integer.parseInt(s);
    Function<String, Integer> parseInt2 = Integer::parseInt;
    
    // 2. Instance method on particular object
    String prefix = "Hello";
    Predicate<String> startsWith1 = s -> prefix.startsWith(s);
    Predicate<String> startsWith2 = prefix::startsWith;
    
    //3. Instance method on arbitrary object
    Function<String, String> toUpper1 = s -> s.toUpperCase();
    Function<String, String> toUpper2 = String::toUpperCase;
    
    // 4. Constructor reference
    Supplier<List<String>> listSupplier1 = () -> new ArrayList<>();
    Supplier<List<String>> listSupplier2 = ArrayList::new;
    
    public static void main(String[] args) {
        // Static method
        List<String> numbers = Arrays.asList("1", "2", "3");
        List<Integer> ints = numbers.stream()
            .map(Integer::parseInt)
            .toList();
        
        // Instance method
        List<String> words = Arrays.asList("java", "python", "javascript");
        words.forEach(System.out::println);
        
        // Arbitrary object method
        words.stream()
             .map(String::toUpperCase)
             .forEach(System.out::println);
        
        // Constructor
        Supplier<StringBuilder> sbSupplier = StringBuilder::new;
        StringBuilder sb = sbSupplier.get();
    }
}
```

### More Method Reference Examples

```java
public class MoreMethodReferences {
    public static void main(String[] args) {
        List<String> names = Arrays.asList("Alice", "Bob", "Charlie");
        
        // Method reference to println
        names.forEach(System.out::println);
        
        // Method reference to String length
        List<Integer> lengths = names.stream()
            .map(String::length)
            .toList();
        
        // Method reference to equals
        BiPredicate<String, String> equals = String::equals;
        System.out.println(equals.test("Hello", "Hello")); // true
        
        // Array constructor reference
        IntFunction<int[]> arrayCreator = int[]::new;
        int[] array = arrayCreator.apply(5); // Creates int[5]
    }
}
```

## Practical Examples

### Filtering and Processing Lists

```java
import java.util.*;
import java.util.function.Predicate;

public class FilteringExample {
    public static void main(String[] args) {
        List<String> names = Arrays.asList(
            "Alice", "Bob", "Charlie", "David", "Eve"
        );
        
        // Filter names starting with 'A'
        Predicate<String> startsWithA = s -> s.startsWith("A");
        List<String> filtered = new ArrayList<>();
        for (String name : names) {
            if (startsWithA.test(name)) {
                filtered.add(name);
            }
        }
        System.out.println(filtered); // [Alice]
        
        // Generic filter method
        List<String> longNames = filter(names, s -> s.length() > 4);
        System.out.println(longNames); // [Alice, Charlie, David]
    }
    
    public static <T> List<T> filter(List<T> list, Predicate<T> predicate) {
        List<T> result = new ArrayList<>();
        for (T item : list) {
            if (predicate.test(item)) {
                result.add(item);
            }
        }
        return result;
    }
}
```

### Transformation with Functions

```java
import java.util.*;
import java.util.function.Function;

public class TransformExample {
    public static void main(String[] args) {
        List<String> words = Arrays.asList("hello", "world", "java");
        
        // Transform to uppercase
        Function<String, String> toUpper = String::toUpperCase;
        List<String> upper = transform(words, toUpper);
        System.out.println(upper); // [HELLO, WORLD, JAVA]
        
        // Transform to lengths
        Function<String, Integer> length = String::length;
        List<Integer> lengths = transform(words, length);
        System.out.println(lengths); // [5, 5, 4]
    }
    
    public static <T, R> List<R> transform(List<T> list, Function<T, R> function) {
        List<R> result = new ArrayList<>();
        for (T item : list) {
            result.add(function.apply(item));
        }
        return result;
    }
}
```

### Custom Functional Interface

```java
@FunctionalInterface
interface StringOperation {
    String apply(String s1, String s2);
}

public class CustomFunctionalInterface {
    public static void main(String[] args) {
        // Different implementations
        StringOperation concat = (s1, s2) -> s1 + s2;
        StringOperation withSpace = (s1, s2) -> s1 + " " + s2;
        StringOperation reverse = (s1, s2) -> s2 + s1;
        
        System.out.println(concat.apply("Hello", "World"));     // HelloWorld
        System.out.println(withSpace.apply("Hello", "World"));  // Hello World
        System.out.println(reverse.apply("Hello", "World"));    // WorldHello
        
        // Use in method
        String result = combine("Java", "8", concat);
        System.out.println(result); // Java8
    }
    
    public static String combine(String s1, String s2, StringOperation op) {
        return op.apply(s1, s2);
    }
}
```

### Comparator with Lambdas

```java
import java.util.*;

class Person {
    String name;
    int age;
    
    Person(String name, int age) {
        this.name = name;
        this.age = age;
    }
    
    @Override
    public String toString() {
        return name + "(" + age + ")";
    }
}

public class ComparatorExample {
    public static void main(String[] args) {
        List<Person> people = Arrays.asList(
            new Person("Alice", 30),
            new Person("Bob", 25),
            new Person("Charlie", 35),
            new Person("David", 25)
        );
        
        // Sort by age
        people.sort((p1, p2) -> Integer.compare(p1.age, p2.age));
        // Or: people.sort(Comparator.comparingInt(p -> p.age));
        System.out.println(people);
        
        // Sort by name
        people.sort((p1, p2) -> p1.name.compareTo(p2.name));
        // Or: people.sort(Comparator.comparing(p -> p.name));
        System.out.println(people);
        
        // Sort by age, then by name
        people.sort(Comparator.comparingInt((Person p) -> p.age)
                              .thenComparing(p -> p.name));
        System.out.println(people);
        
        // Reverse order
        people.sort(Comparator.comparingInt((Person p) -> p.age).reversed());
        System.out.println(people);
    }
}
```

### Callback Pattern

```java
import java.util.function.Consumer;

public class CallbackExample {
    public static void processData(String data, 
                                  Consumer<String> onSuccess,
                                  Consumer<Exception> onError) {
        try {
            // Simulate processing
            if (data == null) {
                throw new IllegalArgumentException("Data cannot be null");
            }
            String processed = data.toUpperCase();
            onSuccess.accept(processed);
        } catch (Exception e) {
            onError.accept(e);
        }
    }
    
    public static void main(String[] args) {
        processData("hello",
            result -> System.out.println("Success: " + result),
            error -> System.err.println("Error: " + error.getMessage())
        );
        
        processData(null,
            result -> System.out.println("Success: " + result),
            error -> System.err.println("Error: " + error.getMessage())
        );
    }
}
```

## Common Patterns

### Factory Pattern with Supplier

```java
import java.util.function.Supplier;

interface Animal {
    void makeSound();
}

class Dog implements Animal {
    public void makeSound() { System.out.println("Woof!"); }
}

class Cat implements Animal {
    public void makeSound() { System.out.println("Meow!"); }
}

public class FactoryPattern {
    public static Animal createAnimal(Supplier<Animal> factory) {
        return factory.get();
    }
    
    public static void main(String[] args) {
        Animal dog = createAnimal(Dog::new);
        Animal cat = createAnimal(Cat::new);
        
        dog.makeSound(); // Woof!
        cat.makeSound(); // Meow!
    }
}
```

### Strategy Pattern with Function

```java
import java.util.function.BiFunction;

public class StrategyPattern {
    public static double calculate(double a, double b, 
                                   BiFunction<Double, Double, Double> strategy) {
        return strategy.apply(a, b);
    }
    
    public static void main(String[] args) {
        double x = 10, y = 5;
        
        System.out.println("Add: " + calculate(x, y, (a, b) -> a + b));
        System.out.println("Subtract: " + calculate(x, y, (a, b) -> a - b));
        System.out.println("Multiply: " + calculate(x, y, (a, b) -> a * b));
        System.out.println("Divide: " + calculate(x, y, (a, b) -> a / b));
    }
}
```

## Quick Reference

```java
// Lambda syntax
(parameters) -> expression
(parameters) -> { statements; }

// Functional interfaces
Predicate<T>        // T -> boolean
Function<T, R>      // T -> R
Consumer<T>         // T -> void
Supplier<T>         // () -> T
BiFunction<T, U, R> // (T, U) -> R
UnaryOperator<T>    // T -> T
BinaryOperator<T>   // (T, T) -> T

// Method references
ClassName::staticMethod
object::instanceMethod
ClassName::instanceMethod
ClassName::new

// Examples
list.forEach(System.out::println);
list.stream().map(String::toUpperCase);
list.stream().filter(s -> s.length() > 3);
list.sort((a, b) -> a.compareTo(b));
```

---

**Previous**: [← Generics](java-12-generics.md) | **Next**: [Stream API →](java-14-stream-api.md)
