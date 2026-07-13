# Modern Java Features (Java 8-21)

## Java 8 (2014) - Revolution

### Lambda Expressions

```java
// Before Java 8
List<String> names = Arrays.asList("Alice", "Bob", "Charlie");
Collections.sort(names, new Comparator<String>() {
    public int compare(String a, String b) {
        return a.compareTo(b);
    }
});

// Java 8+
names.sort((a, b) -> a.compareTo(b));
// Or
names.sort(String::compareTo);
```

### Stream API

```java
List<Integer> numbers = Arrays.asList(1, 2, 3, 4, 5, 6, 7, 8, 9, 10);

// Filter, map, reduce
int sum = numbers.stream()
    .filter(n -> n % 2 == 0)
    .map(n -> n * n)
    .reduce(0, Integer::sum);

System.out.println(sum);  // 220
```

### Optional

```java
// Avoid NullPointerException
Optional<String> optional = Optional.ofNullable(getName());

// Old way
String name = optional.isPresent() ? optional.get() : "Unknown";

// Better way
String name = optional.orElse("Unknown");

// Even better
optional.ifPresent(n -> System.out.println("Name: " + n));

// Chain operations
String result = findUser(id)
    .map(User::getName)
    .map(String::toUpperCase)
    .orElse("UNKNOWN");
```

### Default Methods in Interfaces

```java
public interface Vehicle {
    void start();
    
    // Default method (since Java 8)
    default void stop() {
        System.out.println("Vehicle stopped");
    }
    
    // Static method (since Java 8)
    static void honk() {
        System.out.println("Honk!");
    }
}

class Car implements Vehicle {
    public void start() {
        System.out.println("Car started");
    }
    // Can use default stop() or override it
}
```

### Date/Time API

```java
// Old way (before Java 8)
Date date = new Date();
Calendar cal = Calendar.getInstance();

// New way (Java 8+)
LocalDate today = LocalDate.now();
LocalTime time = LocalTime.now();
LocalDateTime dateTime = LocalDateTime.now();
ZonedDateTime zonedDateTime = ZonedDateTime.now();

// Operations
LocalDate tomorrow = today.plusDays(1);
LocalDate lastWeek = today.minusWeeks(1);
LocalDate specificDate = LocalDate.of(2024, 3, 15);

// Formatting
DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
String formattedDate = today.format(formatter);

// Parsing
LocalDate parsed = LocalDate.parse("2024-03-15", formatter);
```

## Java 9 (2017)

### Module System (JPMS)

```java
// module-info.java
module com.example.myapp {
    requires java.sql;
    requires spring.core;
    
    exports com.example.myapp.api;
    opens com.example.myapp.model to jackson.databind;
}
```

### Factory Methods for Collections

```java
// Immutable collections
List<String> list = List.of("a", "b", "c");
Set<Integer> set = Set.of(1, 2, 3);
Map<String, Integer> map = Map.of("a", 1, "b", 2);

// Map with more entries
Map<String, Integer> bigMap = Map.ofEntries(
    Map.entry("a", 1),
    Map.entry("b", 2),
    Map.entry("c", 3)
);
```

### Private Methods in Interfaces

```java
public interface Calculator {
    default int addAndMultiply(int a, int b, int c) {
        return multiply(add(a, b), c);
    }
    
    private int add(int a, int b) {
        return a + b;
    }
    
    private int multiply(int a, int b) {
        return a * b;
    }
}
```

### Try-with-resources Enhancement

```java
// Java 7-8
BufferedReader reader = new BufferedReader(new FileReader("file.txt"));
try (BufferedReader br = reader) {
    // Use br
}

// Java 9+
BufferedReader reader = new BufferedReader(new FileReader("file.txt"));
try (reader) {  // No need to redeclare
    // Use reader
}
```

## Java 10 (2018)

### Local Variable Type Inference (var)

```java
// Before Java 10
ArrayList<String> list = new ArrayList<>();
Map<String, List<Integer>> map = new HashMap<>();

// Java 10+
var list = new ArrayList<String>();
var map = new HashMap<String, List<Integer>>();

// Works with streams
var filtered = list.stream()
    .filter(s -> s.length() > 5)
    .collect(Collectors.toList());

// Cannot use without initializer
// var x;  // Error!
// var x = null;  // Error!

// Not for fields, only local variables
public class Example {
    // private var field = "test";  // Error!
    
    public void method() {
        var local = "test";  // OK
    }
}
```

## Java 11 (2018) - LTS

### String Methods

```java
String str = "  Hello World  ";

// Check if blank
str.isBlank();  // false
"   ".isBlank();  // true

// Strip (unlike trim, handles Unicode whitespace)
str.strip();        // "Hello World"
str.stripLeading(); // "Hello World  "
str.stripTrailing();// "  Hello World"

// Repeat
"Ha".repeat(3);  // "HaHaHa"

// Lines
"Line1\nLine2\nLine3".lines()
    .forEach(System.out::println);
```

### Files Methods

```java
// Read entire file as string
String content = Files.readString(Path.of("file.txt"));

// Write string to file
Files.writeString(Path.of("output.txt"), "Hello World");

// Is same file
boolean same = Files.isSameFile(path1, path2);
```

### Local Variable Syntax for Lambda

```java
// Java 11+
list.stream()
    .map((var s) -> s.toUpperCase())
    .forEach(System.out::println);

// Useful with annotations
list.stream()
    .map((@NonNull var s) -> s.toUpperCase())
    .forEach(System.out::println);
```

## Java 12-13 (2019)

### Switch Expressions (Preview in 12, Standard in 14)

```java
// Old switch
String result;
switch (day) {
    case MONDAY:
    case FRIDAY:
        result = "Work";
        break;
    case SATURDAY:
    case SUNDAY:
        result = "Weekend";
        break;
    default:
        result = "Other";
}

// New switch expression
String result = switch (day) {
    case MONDAY, FRIDAY -> "Work";
    case SATURDAY, SUNDAY -> "Weekend";
    default -> "Other";
};

// With yield (for multiple statements)
int value = switch (grade) {
    case 'A' -> {
        System.out.println("Excellent!");
        yield 100;
    }
    case 'B' -> 80;
    case 'C' -> 60;
    default -> 0;
};
```

### Text Blocks (Preview in 13, Standard in 15)

```java
// Old way
String json = "{\n" +
              "  \"name\": \"John\",\n" +
              "  \"age\": 30\n" +
              "}";

// Text blocks (Java 15+)
String json = """
    {
      "name": "John",
      "age": 30
    }
    """;

// HTML
String html = """
    <html>
        <body>
            <p>Hello World</p>
        </body>
    </html>
    """;

// SQL
String query = """
    SELECT id, name, email
    FROM users
    WHERE age > 18
    ORDER BY name
    """;
```

## Java 14 (2020)

### Records (Preview in 14, Standard in 16)

```java
// Old way
public class Point {
    private final int x;
    private final int y;
    
    public Point(int x, int y) {
        this.x = x;
        this.y = y;
    }
    
    public int x() { return x; }
    public int y() { return y; }
    
    // equals, hashCode, toString...
}

// Records (Java 16+)
public record Point(int x, int y) {}

// Usage
Point p = new Point(1, 2);
System.out.println(p.x());  // 1
System.out.println(p.y());  // 2
System.out.println(p);      // Point[x=1, y=2]

// Custom methods in records
public record Person(String name, int age) {
    // Compact constructor
    public Person {
        if (age < 0) {
            throw new IllegalArgumentException("Age cannot be negative");
        }
    }
    
    // Additional methods
    public boolean isAdult() {
        return age >= 18;
    }
    
    // Static factory method
    public static Person of(String name, int age) {
        return new Person(name, age);
    }
}
```

### Pattern Matching for instanceof (Preview in 14, Standard in 16)

```java
// Old way
if (obj instanceof String) {
    String str = (String) obj;
    System.out.println(str.length());
}

// Pattern matching (Java 16+)
if (obj instanceof String str) {
    System.out.println(str.length());  // No cast needed
}

// More examples
if (obj instanceof Integer i && i > 0) {
    System.out.println("Positive: " + i);
}

// In expressions
String formatted = obj instanceof String str
    ? str.toUpperCase()
    : obj.toString();
```

## Java 15 (2020)

### Sealed Classes (Preview in 15, Standard in 17)

```java
// Define permitted subclasses
public abstract sealed class Shape
    permits Circle, Rectangle, Triangle {
    
    public abstract double area();
}

public final class Circle extends Shape {
    private final double radius;
    
    public Circle(double radius) {
        this.radius = radius;
    }
    
    @Override
    public double area() {
        return Math.PI * radius * radius;
    }
}

public final class Rectangle extends Shape {
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

public non-sealed class Triangle extends Shape {
    // Can be extended further
    @Override
    public double area() {
        return 0;  // Implementation
    }
}

// Only Circle, Rectangle, Triangle can extend Shape
// class Square extends Shape {}  // Compile error!
```

## Java 17 (2021) - LTS

### Pattern Matching for Switch (Preview)

```java
// Traditional
static String format(Object obj) {
    String result;
    if (obj instanceof Integer i) {
        result = String.format("int %d", i);
    } else if (obj instanceof Long l) {
        result = String.format("long %d", l);
    } else if (obj instanceof Double d) {
        result = String.format("double %f", d);
    } else if (obj instanceof String s) {
        result = String.format("String %s", s);
    } else {
        result = obj.toString();
    }
    return result;
}

// Pattern matching switch (Preview Java 17, Standard Java 21)
static String format(Object obj) {
    return switch (obj) {
        case Integer i -> String.format("int %d", i);
        case Long l -> String.format("long %d", l);
        case Double d -> String.format("double %f", d);
        case String s -> String.format("String %s", s);
        default -> obj.toString();
    };
}

// With guards
static String classify(Object obj) {
    return switch (obj) {
        case Integer i when i > 0 -> "Positive integer";
        case Integer i when i < 0 -> "Negative integer";
        case Integer i -> "Zero";
        case String s when s.isEmpty() -> "Empty string";
        case String s -> "Non-empty string: " + s;
        default -> "Unknown";
    };
}
```

## Java 19-20 (2022-2023)

### Virtual Threads (Preview)

```java
// Traditional threads
Thread thread = new Thread(() -> {
    System.out.println("Hello from thread");
});
thread.start();

// Virtual threads (Java 19+ preview, 21 standard)
Thread virtualThread = Thread.startVirtualThread(() -> {
    System.out.println("Hello from virtual thread");
});

// ExecutorService with virtual threads
try (var executor = Executors.newVirtualThreadPerTaskExecutor()) {
    for (int i = 0; i < 10000; i++) {
        executor.submit(() -> {
            // Task
            Thread.sleep(1000);
            return "Result";
        });
    }
}

// Structured concurrency (Incubator)
try (var scope = new StructuredTaskScope.ShutdownOnFailure()) {
    Future<String> user = scope.fork(() -> fetchUser(id));
    Future<List<Order>> orders = scope.fork(() -> fetchOrders(id));
    
    scope.join();
    scope.throwIfFailed();
    
    // Both completed successfully
    System.out.println(user.resultNow());
    System.out.println(orders.resultNow());
}
```

### Record Patterns (Preview)

```java
record Point(int x, int y) {}

// Pattern matching with records
static void printPoint(Object obj) {
    if (obj instanceof Point(int x, int y)) {
        System.out.println("x: " + x + ", y: " + y);
    }
}

// In switch
static String describe(Object obj) {
    return switch (obj) {
        case Point(int x, int y) -> "Point at (" + x + ", " + y + ")";
        case String s -> "String: " + s;
        default -> "Unknown";
    };
}
```

## Java 21 (2023) - LTS

### String Templates (Preview)

```java
// Traditional
String name = "John";
int age = 30;
String message = "Name: " + name + ", Age: " + age;

// String templates (Preview in Java 21)
String message = STR."Name: \{name}, Age: \{age}";

// With expressions
String info = STR."Next year: \{age + 1}";

// Multi-line
String json = STR."""
    {
        "name": "\{name}",
        "age": \{age}
    }
    """;
```

### Sequenced Collections

```java
// New interfaces: SequencedCollection, SequencedSet, SequencedMap

List<String> list = new ArrayList<>(List.of("a", "b", "c"));

// First and last
String first = list.getFirst();  // "a"
String last = list.getLast();    // "c"

list.addFirst("x");  // [x, a, b, c]
list.addLast("z");   // [x, a, b, c, z]

list.removeFirst();  // [a, b, c, z]
list.removeLast();   // [a, b, c]

// Reversed view
List<String> reversed = list.reversed();  // [c, b, a]
```

### Pattern Matching for Switch (Standard)

```java
sealed interface Shape permits Circle, Rectangle {}
record Circle(double radius) implements Shape {}
record Rectangle(double width, double height) implements Shape {}

static double area(Shape shape) {
    return switch (shape) {
        case Circle(double r) -> Math.PI * r * r;
        case Rectangle(double w, double h) -> w * h;
    };
}

// Exhaustive (no default needed for sealed types)
```

## Quick Feature Timeline

```java
// Java 8 (2014) - LTS
- Lambda expressions
- Stream API
- Optional
- Default methods
- New Date/Time API

// Java 9 (2017)
- Module system
- Collection factories (List.of, Set.of, Map.of)
- Private interface methods

// Java 10 (2018)
- var (local variable type inference)

// Java 11 (2018) - LTS
- String methods (isBlank, strip, repeat, lines)
- Files.readString / writeString
- var in lambda parameters

// Java 12-13 (2019)
- Switch expressions (preview)
- Text blocks (preview)

// Java 14 (2020)
- Records (preview)
- Pattern matching for instanceof (preview)

// Java 15 (2020)
- Text blocks (standard)
- Sealed classes (preview)

// Java 16 (2021)
- Records (standard)
- Pattern matching for instanceof (standard)

// Java 17 (2021) - LTS
- Sealed classes (standard)
- Pattern matching for switch (preview)

// Java 21 (2023) - LTS
- Virtual threads (standard)
- Pattern matching for switch (standard)
- Sequenced collections
- Record patterns (preview)
- String templates (preview)
```

## Migration Tips

```java
// Modernize old code gradually

// 1. Replace anonymous classes with lambdas
// Old
Collections.sort(list, new Comparator<String>() {
    public int compare(String a, String b) {
        return a.compareTo(b);
    }
});
// New
list.sort(String::compareTo);

// 2. Use streams for collection processing
// Old
List<String> result = new ArrayList<>();
for (String s : list) {
    if (s.length() > 5) {
        result.add(s.toUpperCase());
    }
}
// New
List<String> result = list.stream()
    .filter(s -> s.length() > 5)
    .map(String::toUpperCase)
    .toList();

// 3. Use Optional instead of null
// Old
public String getName() {
    return name != null ? name : "Unknown";
}
// New
public Optional<String> getName() {
    return Optional.ofNullable(name);
}

// 4. Use var for obvious types
// Old
HashMap<String, List<Integer>> map = new HashMap<>();
// New
var map = new HashMap<String, List<Integer>>();

// 5. Use records for data classes
// Old
public class Point {
    private final int x, y;
    // Constructor, getters, equals, hashCode, toString
}
// New
public record Point(int x, int y) {}

// 6. Use text blocks for multiline strings
// Old
String sql = "SELECT * FROM users\n" +
             "WHERE age > 18\n" +
             "ORDER BY name";
// New
String sql = """
    SELECT * FROM users
    WHERE age > 18
    ORDER BY name
    """;
```

---

**Previous**: [← Spring Web](java-22-spring-web.md) | **Next**: [Logging & Debugging →](java-24-logging-debugging.md)
