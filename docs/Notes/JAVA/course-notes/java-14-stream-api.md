# Java Stream API

## What is a Stream?

A Stream is a sequence of elements supporting sequential and parallel aggregate operations.

```java
import java.util.*;
import java.util.stream.*;

public class StreamIntro {
    public static void main(String[] args) {
        List<Integer> numbers = Arrays.asList(1, 2, 3, 4, 5);
        
        // Traditional approach
        int sum = 0;
        for (int num : numbers) {
            if (num % 2 == 0) {
                sum += num * num;
            }
        }
        System.out.println("Sum: " + sum); // 20
        
        // Stream approach
        int streamSum = numbers.stream()
            .filter(n -> n % 2 == 0)    // Keep even numbers
            .map(n -> n * n)             // Square them
            .reduce(0, Integer::sum);    // Sum them up
        System.out.println("Stream sum: " + streamSum); // 20
    }
}
```

## Creating Streams

### From Collections

```java
import java.util.*;
import java.util.stream.*;

public class CreateStreams {
    public static void main(String[] args) {
        // From List
        List<String> list = Arrays.asList("a", "b", "c");
        Stream<String> stream1 = list.stream();
        
        // From Set
        Set<Integer> set = new HashSet<>(Arrays.asList(1, 2, 3));
        Stream<Integer> stream2 = set.stream();
        
        // From Map
        Map<String, Integer> map = Map.of("a", 1, "b", 2);
        Stream<Map.Entry<String, Integer>> stream3 = map.entrySet().stream();
        Stream<String> keys = map.keySet().stream();
        Stream<Integer> values = map.values().stream();
        
        // From array
        String[] array = {"x", "y", "z"};
        Stream<String> stream4 = Arrays.stream(array);
        Stream<String> stream5 = Stream.of(array);
        
        // Directly
        Stream<String> stream6 = Stream.of("1", "2", "3");
        
        // Empty stream
        Stream<String> empty = Stream.empty();
        
        // Infinite streams
        Stream<Integer> infinite1 = Stream.iterate(0, n -> n + 1); // 0,1,2,3...
        Stream<Double> infinite2 = Stream.generate(Math::random);
        
        // Primitive streams
        IntStream intStream = IntStream.range(1, 5);        // 1,2,3,4
        IntStream intStream2 = IntStream.rangeClosed(1, 5); // 1,2,3,4,5
        LongStream longStream = LongStream.of(1L, 2L, 3L);
        DoubleStream doubleStream = DoubleStream.of(1.0, 2.0, 3.0);
    }
}
```

## Intermediate Operations

### filter() - Select elements

```java
List<Integer> numbers = Arrays.asList(1, 2, 3, 4, 5, 6, 7, 8, 9, 10);

// Get even numbers
List<Integer> evens = numbers.stream()
    .filter(n -> n % 2 == 0)
    .toList();
System.out.println(evens); // [2, 4, 6, 8, 10]

// Get numbers > 5
List<Integer> greaterThan5 = numbers.stream()
    .filter(n -> n > 5)
    .toList();
System.out.println(greaterThan5); // [6, 7, 8, 9, 10]

// Multiple filters
List<Integer> result = numbers.stream()
    .filter(n -> n > 3)
    .filter(n -> n % 2 == 0)
    .toList();
System.out.println(result); // [4, 6, 8, 10]
```

### map() - Transform elements

```java
List<String> words = Arrays.asList("hello", "world", "java");

// To uppercase
List<String> upper = words.stream()
    .map(String::toUpperCase)
    .toList();
System.out.println(upper); // [HELLO, WORLD, JAVA]

// Get lengths
List<Integer> lengths = words.stream()
    .map(String::length)
    .toList();
System.out.println(lengths); // [5, 5, 4]

// Chain transformations
List<Integer> squaredLengths = words.stream()
    .map(String::length)
    .map(n -> n * n)
    .toList();
System.out.println(squaredLengths); // [25, 25, 16]
```

### flatMap() - Flatten nested structures

```java
List<List<Integer>> nested = Arrays.asList(
    Arrays.asList(1, 2, 3),
    Arrays.asList(4, 5),
    Arrays.asList(6, 7, 8, 9)
);

// Flatten to single list
List<Integer> flat = nested.stream()
    .flatMap(List::stream)
    .toList();
System.out.println(flat); // [1, 2, 3, 4, 5, 6, 7, 8, 9]

// Split strings into words
List<String> sentences = Arrays.asList("Hello World", "Java Streams");
List<String> allWords = sentences.stream()
    .flatMap(s -> Arrays.stream(s.split(" ")))
    .toList();
System.out.println(allWords); // [Hello, World, Java, Streams]
```

### distinct() - Remove duplicates

```java
List<Integer> numbersWithDuplicates = Arrays.asList(1, 2, 2, 3, 3, 3, 4, 5, 5);

List<Integer> unique = numbersWithDuplicates.stream()
    .distinct()
    .toList();
System.out.println(unique); // [1, 2, 3, 4, 5]
```

### sorted() - Sort elements

```java
List<Integer> numbers = Arrays.asList(5, 2, 8, 1, 9, 3);

// Natural order
List<Integer> sorted = numbers.stream()
    .sorted()
    .toList();
System.out.println(sorted); // [1, 2, 3, 5, 8, 9]

// Reverse order
List<Integer> reversed = numbers.stream()
    .sorted(Comparator.reverseOrder())
    .toList();
System.out.println(reversed); // [9, 8, 5, 3, 2, 1]

// Custom comparator
List<String> words = Arrays.asList("apple", "pie", "banana", "kiwi");
List<String> byLength = words.stream()
    .sorted(Comparator.comparingInt(String::length))
    .toList();
System.out.println(byLength); // [pie, kiwi, apple, banana]
```

### limit() and skip()

```java
List<Integer> numbers = Arrays.asList(1, 2, 3, 4, 5, 6, 7, 8, 9, 10);

// Take first 5
List<Integer> first5 = numbers.stream()
    .limit(5)
    .toList();
System.out.println(first5); // [1, 2, 3, 4, 5]

// Skip first 5
List<Integer> skipFirst5 = numbers.stream()
    .skip(5)
    .toList();
System.out.println(skipFirst5); // [6, 7, 8, 9, 10]

// Pagination: get items 11-20
List<Integer> page2 = numbers.stream()
    .skip(10)
    .limit(10)
    .toList();
```

### peek() - Debug/side effects

```java
List<Integer> numbers = Arrays.asList(1, 2, 3, 4, 5);

// Debug intermediate values
List<Integer> result = numbers.stream()
    .peek(n -> System.out.println("Original: " + n))
    .map(n -> n * 2)
    .peek(n -> System.out.println("After map: " + n))
    .filter(n -> n > 5)
    .peek(n -> System.out.println("After filter: " + n))
    .toList();
```

## Terminal Operations

### collect() - Gather results

```java
List<String> words = Arrays.asList("apple", "banana", "cherry");

// To List
List<String> list = words.stream().collect(Collectors.toList());
// Or (Java 16+)
List<String> list2 = words.stream().toList();

// To Set
Set<String> set = words.stream().collect(Collectors.toSet());

// To Map
Map<String, Integer> map = words.stream()
    .collect(Collectors.toMap(
        w -> w,              // key
        String::length       // value
    ));
System.out.println(map); // {apple=5, banana=6, cherry=6}

// Joining strings
String joined = words.stream()
    .collect(Collectors.joining(", "));
System.out.println(joined); // apple, banana, cherry

// Joining with prefix/suffix
String withBrackets = words.stream()
    .collect(Collectors.joining(", ", "[", "]"));
System.out.println(withBrackets); // [apple, banana, cherry]
```

### Collectors Examples

```java
List<Integer> numbers = Arrays.asList(1, 2, 3, 4, 5, 6, 7, 8, 9, 10);

// Summarizing
IntSummaryStatistics stats = numbers.stream()
    .collect(Collectors.summarizingInt(Integer::intValue));
System.out.println("Count: " + stats.getCount());      // 10
System.out.println("Sum: " + stats.getSum());          // 55
System.out.println("Average: " + stats.getAverage());  // 5.5
System.out.println("Min: " + stats.getMin());          // 1
System.out.println("Max: " + stats.getMax());          // 10

// Grouping
Map<Boolean, List<Integer>> partitioned = numbers.stream()
    .collect(Collectors.partitioningBy(n -> n % 2 == 0));
System.out.println("Even: " + partitioned.get(true));  // [2,4,6,8,10]
System.out.println("Odd: " + partitioned.get(false));  // [1,3,5,7,9]

// Grouping by criteria
List<String> words = Arrays.asList("a", "bb", "ccc", "dd", "e");
Map<Integer, List<String>> byLength = words.stream()
    .collect(Collectors.groupingBy(String::length));
System.out.println(byLength); // {1=[a, e], 2=[bb, dd], 3=[ccc]}

// Counting
Map<Integer, Long> countByLength = words.stream()
    .collect(Collectors.groupingBy(String::length, Collectors.counting()));
System.out.println(countByLength); // {1=2, 2=2, 3=1}
```

### reduce() - Combine elements

```java
List<Integer> numbers = Arrays.asList(1, 2, 3, 4, 5);

// Sum
int sum = numbers.stream()
    .reduce(0, (a, b) -> a + b);
System.out.println(sum); // 15

// Or with method reference
int sum2 = numbers.stream()
    .reduce(0, Integer::sum);

// Product
int product = numbers.stream()
    .reduce(1, (a, b) -> a * b);
System.out.println(product); // 120

// Max
Optional<Integer> max = numbers.stream()
    .reduce((a, b) -> a > b ? a : b);
System.out.println(max.get()); // 5

// Or simpler
Optional<Integer> max2 = numbers.stream()
    .reduce(Integer::max);

// Concatenate strings
List<String> words = Arrays.asList("Hello", "World", "Java");
String combined = words.stream()
    .reduce("", (a, b) -> a + " " + b).trim();
System.out.println(combined); // Hello World Java
```

### forEach() - Iterate

```java
List<String> words = Arrays.asList("apple", "banana", "cherry");

// Print each
words.stream().forEach(System.out::println);

// Or
words.forEach(System.out::println);

// With index (not directly available)
IntStream.range(0, words.size())
    .forEach(i -> System.out.println(i + ": " + words.get(i)));
```

### count(), min(), max()

```java
List<Integer> numbers = Arrays.asList(1, 2, 3, 4, 5);

// Count
long count = numbers.stream().count();
System.out.println("Count: " + count); // 5

// Min
Optional<Integer> min = numbers.stream().min(Integer::compareTo);
System.out.println("Min: " + min.get()); // 1

// Max
Optional<Integer> max = numbers.stream().max(Integer::compareTo);
System.out.println("Max: " + max.get()); // 5
```

### anyMatch(), allMatch(), noneMatch()

```java
List<Integer> numbers = Arrays.asList(1, 2, 3, 4, 5);

// Any match
boolean hasEven = numbers.stream()
    .anyMatch(n -> n % 2 == 0);
System.out.println("Has even: " + hasEven); // true

// All match
boolean allPositive = numbers.stream()
    .allMatch(n -> n > 0);
System.out.println("All positive: " + allPositive); // true

// None match
boolean noneNegative = numbers.stream()
    .noneMatch(n -> n < 0);
System.out.println("None negative: " + noneNegative); // true
```

### findFirst(), findAny()

```java
List<Integer> numbers = Arrays.asList(1, 2, 3, 4, 5);

// Find first even number
Optional<Integer> firstEven = numbers.stream()
    .filter(n -> n % 2 == 0)
    .findFirst();
System.out.println(firstEven.get()); // 2

// Find any (useful for parallel streams)
Optional<Integer> anyEven = numbers.stream()
    .filter(n -> n % 2 == 0)
    .findAny();
System.out.println(anyEven.get()); // 2
```

## Practical Examples

### Filter and Transform

```java
class Person {
    String name;
    int age;
    String city;
    
    Person(String name, int age, String city) {
        this.name = name;
        this.age = age;
        this.city = city;
    }
}

public class StreamExample {
    public static void main(String[] args) {
        List<Person> people = Arrays.asList(
            new Person("Alice", 25, "New York"),
            new Person("Bob", 30, "London"),
            new Person("Charlie", 35, "New York"),
            new Person("David", 28, "Paris")
        );
        
        // Get names of people in New York, age > 26
        List<String> names = people.stream()
            .filter(p -> p.city.equals("New York"))
            .filter(p -> p.age > 26)
            .map(p -> p.name)
            .toList();
        System.out.println(names); // [Charlie]
        
        // Average age by city
        Map<String, Double> avgAgeByCity = people.stream()
            .collect(Collectors.groupingBy(
                p -> p.city,
                Collectors.averagingInt(p -> p.age)
            ));
        System.out.println(avgAgeByCity); // {New York=30.0, London=30.0, Paris=28.0}
    }
}
```

### Word Frequency

```java
public class WordFrequency {
    public static void main(String[] args) {
        String text = "hello world hello java world";
        
        Map<String, Long> frequency = Arrays.stream(text.split(" "))
            .collect(Collectors.groupingBy(
                word -> word,
                Collectors.counting()
            ));
        
        System.out.println(frequency);
        // {world=2, java=1, hello=2}
        
        // Most frequent word
        Optional<Map.Entry<String, Long>> mostFrequent = frequency.entrySet()
            .stream()
            .max(Map.Entry.comparingByValue());
        
        mostFrequent.ifPresent(entry ->
            System.out.println("Most frequent: " + entry.getKey() + " (" + entry.getValue() + ")")
        );
    }
}
```

### Statistics

```java
public class Statistics {
    public static void main(String[] args) {
        List<Integer> numbers = Arrays.asList(10, 20, 30, 40, 50);
        
        // Using IntStream for better performance
        IntSummaryStatistics stats = numbers.stream()
            .mapToInt(Integer::intValue)
            .summaryStatistics();
        
        System.out.println("Count: " + stats.getCount());
        System.out.println("Sum: " + stats.getSum());
        System.out.println("Min: " + stats.getMin());
        System.out.println("Max: " + stats.getMax());
        System.out.println("Average: " + stats.getAverage());
    }
}
```

## Parallel Streams

### When to Use Parallel Streams

```java
List<Integer> largeList = IntStream.rangeClosed(1, 1000000)
    .boxed()
    .toList();

// Sequential
long start = System.currentTimeMillis();
long sum1 = largeList.stream()
    .mapToLong(Integer::longValue)
    .sum();
System.out.println("Sequential: " + (System.currentTimeMillis() - start) + "ms");

// Parallel
start = System.currentTimeMillis();
long sum2 = largeList.parallelStream()
    .mapToLong(Integer::longValue)
    .sum();
System.out.println("Parallel: " + (System.currentTimeMillis() - start) + "ms");

// Or convert to parallel
long sum3 = largeList.stream()
    .parallel()
    .mapToLong(Integer::longValue)
    .sum();
```

### Parallel Stream Pitfalls

```java
// BAD: Non-thread-safe operation
List<Integer> numbers = IntStream.rangeClosed(1, 100).boxed().toList();
List<Integer> result = new ArrayList<>();

numbers.parallelStream()
    .forEach(n -> result.add(n * 2));  // NOT THREAD-SAFE!

// GOOD: Use collect
List<Integer> result2 = numbers.parallelStream()
    .map(n -> n * 2)
    .collect(Collectors.toList());  // Thread-safe
```

## Quick Reference

```java
// Creating streams
List.stream()
Set.stream()
Arrays.stream(array)
Stream.of(elements)
IntStream.range(start, end)

// Intermediate operations (return Stream)
.filter(predicate)
.map(function)
.flatMap(function)
.distinct()
.sorted()
.limit(n)
.skip(n)
.peek(consumer)

// Terminal operations (return result)
.collect(collector)
.forEach(consumer)
.reduce(identity, accumulator)
.count()
.min(comparator)
.max(comparator)
.anyMatch(predicate)
.allMatch(predicate)
.noneMatch(predicate)
.findFirst()
.findAny()

// Common collectors
Collectors.toList()
Collectors.toSet()
Collectors.toMap(keyMapper, valueMapper)
Collectors.joining(delimiter)
Collectors.groupingBy(classifier)
Collectors.partitioningBy(predicate)
Collectors.counting()
Collectors.summarizingInt()
```

## Performance Tips

| Scenario | Recommendation |
|----------|---------------|
| Small collections (< 1000) | Sequential stream |
| Large collections + CPU-intensive | Parallel stream |
| I/O operations | Sequential stream |
| Order matters | Sequential or use `.forEachOrdered()` |
| Primitive types | Use IntStream, LongStream, DoubleStream |
| Side effects | Avoid in parallel streams |

---

**Previous**: [← Lambda & Functional](java-13-lambda-functional.md) | **Next**: [Concurrency →](java-15-concurrency.md)
