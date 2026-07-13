# Java Best Practices

## Code Style and Naming

### Naming Conventions

```java
// Classes: PascalCase
public class UserService { }
public class ShoppingCart { }

// Methods and variables: camelCase
public void calculateTotal() { }
private int itemCount;

// Constants: UPPER_SNAKE_CASE
public static final int MAX_SIZE = 100;
public static final String API_URL = "https://api.example.com";

// Packages: lowercase
package com.example.myapp.service;

// Interfaces: Can use 'I' prefix or descriptive names
interface Runnable { }        // Good
interface UserRepository { }  // Good
interface IUserService { }    // Less common in Java
```

### Meaningful Names

```java
// BAD
int d;  // What does 'd' mean?
String str;
List<String> list1;

// GOOD
int daysSinceCreation;
String username;
List<String> activeUsers;

// BAD
public void process() { }  // Too generic

// GOOD
public void validateUserInput() { }
public void calculateTotalPrice() { }
```

## Class Design

### Single Responsibility Principle

```java
// BAD: Class doing too much
public class User {
    private String name;
    private String email;
    
    public void saveToDatabase() { }
    public void sendEmail() { }
    public void generateReport() { }
}

// GOOD: Separate responsibilities
public class User {
    private String name;
    private String email;
    // Only user data and behavior
}

public class UserRepository {
    public void save(User user) { }
}

public class EmailService {
    public void sendEmail(User user) { }
}

public class ReportGenerator {
    public void generate(User user) { }
}
```

### Favor Composition Over Inheritance

```java
// BAD: Deep inheritance hierarchy
class Animal { }
class Mammal extends Animal { }
class Dog extends Mammal { }
class Retriever extends Dog { }  // Too deep!

// GOOD: Composition
interface Movable {
    void move();
}

interface Eatable {
    void eat();
}

class Dog implements Movable, Eatable {
    private Legs legs = new Legs();
    private Stomach stomach = new Stomach();
    
    public void move() {
        legs.walk();
    }
    
    public void eat() {
        stomach.digest();
    }
}
```

### Immutability

```java
// Mutable (not thread-safe)
public class MutablePerson {
    private String name;
    private int age;
    
    public void setName(String name) { this.name = name; }
    public void setAge(int age) { this.age = age; }
}

// Immutable (thread-safe)
public final class ImmutablePerson {
    private final String name;
    private final int age;
    
    public ImmutablePerson(String name, int age) {
        this.name = name;
        this.age = age;
    }
    
    public String getName() { return name; }
    public int getAge() { return age; }
    
    // Return new instance for changes
    public ImmutablePerson withName(String newName) {
        return new ImmutablePerson(newName, this.age);
    }
}
```

## Method Design

### Keep Methods Small

```java
// BAD: Method doing too much
public void processOrder(Order order) {
    // Validate
    if (order == null) throw new IllegalArgumentException();
    if (order.getItems().isEmpty()) throw new IllegalArgumentException();
    
    // Calculate
    double total = 0;
    for (Item item : order.getItems()) {
        total += item.getPrice() * item.getQuantity();
    }
    
    // Apply discount
    if (total > 100) total *= 0.9;
    
    // Save to database
    Connection conn = DriverManager.getConnection(url);
    PreparedStatement stmt = conn.prepareStatement("INSERT INTO orders...");
    // ...
    
    // Send email
    // ...
}

// GOOD: Small, focused methods
public void processOrder(Order order) {
    validateOrder(order);
    double total = calculateTotal(order);
    total = applyDiscount(total);
    saveOrder(order, total);
    sendConfirmationEmail(order);
}

private void validateOrder(Order order) {
    if (order == null || order.getItems().isEmpty()) {
        throw new IllegalArgumentException("Invalid order");
    }
}

private double calculateTotal(Order order) {
    return order.getItems().stream()
        .mapToDouble(item -> item.getPrice() * item.getQuantity())
        .sum();
}

private double applyDiscount(double total) {
    return total > 100 ? total * 0.9 : total;
}
```

### Method Parameters

```java
// BAD: Too many parameters
public void createUser(String firstName, String lastName, String email, 
                      String phone, String address, String city, 
                      String state, String zip) { }

// GOOD: Use object
public class UserDetails {
    private String firstName;
    private String lastName;
    private String email;
    private Address address;
}

public void createUser(UserDetails details) { }

// BAD: Boolean parameters (unclear meaning)
public List<User> findUsers(true);  // What does true mean?

// GOOD: Enum or separate methods
public enum UserStatus { ACTIVE, INACTIVE }
public List<User> findUsersByStatus(UserStatus status);

// Or separate methods
public List<User> findActiveUsers();
public List<User> findInactiveUsers();
```

### Return Values

```java
// BAD: Return null
public User findUser(Long id) {
    // ...
    return null;  // Caller must check for null
}

// GOOD: Use Optional
public Optional<User> findUser(Long id) {
    // ...
    return Optional.empty();
}

// Usage
Optional<User> user = findUser(1L);
user.ifPresent(u -> System.out.println(u.getName()));

// Or with default
String name = findUser(1L)
    .map(User::getName)
    .orElse("Unknown");
```

## Exception Handling

### Use Specific Exceptions

```java
// BAD: Too generic
public void readFile(String path) throws Exception {
    // ...
}

// GOOD: Specific exceptions
public void readFile(String path) throws FileNotFoundException, IOException {
    // ...
}

// BAD: Catching generic exception
try {
    riskyOperation();
} catch (Exception e) {  // Too broad
    // ...
}

// GOOD: Catch specific exceptions
try {
    riskyOperation();
} catch (IOException e) {
    // Handle I/O error
} catch (SQLException e) {
    // Handle database error
}
```

### Don't Swallow Exceptions

```java
// BAD: Empty catch block
try {
    riskyOperation();
} catch (Exception e) {
    // Exception lost!
}

// GOOD: Log or rethrow
try {
    riskyOperation();
} catch (Exception e) {
    logger.error("Operation failed", e);
    throw new ServiceException("Operation failed", e);
}
```

### Clean Up Resources

```java
// BAD: Manual cleanup
Connection conn = null;
try {
    conn = getConnection();
    // Use connection
} finally {
    if (conn != null) {
        conn.close();
    }
}

// GOOD: try-with-resources
try (Connection conn = getConnection()) {
    // Use connection
}  // Automatically closed
```

## Collections

### Choose the Right Collection

```java
// ArrayList: Fast random access, slow insertion/deletion
List<String> arrayList = new ArrayList<>();

// LinkedList: Fast insertion/deletion, slow random access
List<String> linkedList = new LinkedList<>();

// HashSet: Unique elements, no order
Set<String> hashSet = new HashSet<>();

// TreeSet: Unique elements, sorted
Set<String> treeSet = new TreeSet<>();

// HashMap: Key-value pairs, fast lookup
Map<String, Integer> hashMap = new HashMap<>();

// Use interface type
List<String> list = new ArrayList<>();  // Good: can change implementation
ArrayList<String> list = new ArrayList<>();  // Bad: tied to ArrayList
```

### Initialize Collections Properly

```java
// Empty collections
List<String> list = new ArrayList<>();
Set<Integer> set = new HashSet<>();
Map<String, String> map = new HashMap<>();

// With known size (better performance)
List<String> list = new ArrayList<>(100);
Set<Integer> set = new HashSet<>(50);

// Immutable collections (Java 9+)
List<String> immutableList = List.of("a", "b", "c");
Set<Integer> immutableSet = Set.of(1, 2, 3);
Map<String, Integer> immutableMap = Map.of("a", 1, "b", 2);

// From existing collection
List<String> copy = new ArrayList<>(existingList);
```

## Strings

### Use StringBuilder for Concatenation

```java
// BAD: String concatenation in loop
String result = "";
for (int i = 0; i < 1000; i++) {
    result += i;  // Creates new String object each time!
}

// GOOD: StringBuilder
StringBuilder sb = new StringBuilder();
for (int i = 0; i < 1000; i++) {
    sb.append(i);
}
String result = sb.toString();

// For simple cases, + is fine
String message = "Hello " + name + "!";  // OK

// Java 15+: Text blocks for multiline strings
String json = """
    {
        "name": "John",
        "age": 30
    }
    """;
```

## Comparisons

### Use equals() for Objects

```java
// BAD: Using == for strings
String s1 = new String("hello");
String s2 = new String("hello");
if (s1 == s2) { }  // false! Compares references

// GOOD: Using equals()
if (s1.equals(s2)) { }  // true! Compares content

// Null-safe comparison
if (Objects.equals(s1, s2)) { }  // Handles null

// For primitives, == is fine
int a = 5;
int b = 5;
if (a == b) { }  // OK
```

## Streams and Lambdas

### Use Streams for Collection Operations

```java
List<String> names = Arrays.asList("Alice", "Bob", "Charlie", "David");

// BAD: Traditional loop
List<String> filtered = new ArrayList<>();
for (String name : names) {
    if (name.length() > 4) {
        filtered.add(name.toUpperCase());
    }
}

// GOOD: Stream
List<String> filtered = names.stream()
    .filter(name -> name.length() > 4)
    .map(String::toUpperCase)
    .toList();

// Use method references when possible
names.forEach(System.out::println);  // Better than: name -> System.out.println(name)
```

### Don't Overuse Streams

```java
// BAD: Overkill for simple operation
List<String> names = Arrays.asList("Alice", "Bob");
names.stream().forEach(System.out::println);

// GOOD: Simple loop is clearer
for (String name : names) {
    System.out.println(name);
}

// Or even simpler
names.forEach(System.out::println);
```

## Performance

### Avoid Premature Optimization

```java
// Focus on correctness first, optimize if needed
public double calculateAverage(List<Integer> numbers) {
    return numbers.stream()
        .mapToInt(Integer::intValue)
        .average()
        .orElse(0.0);
}

// If performance is critical, measure first!
// Then optimize if needed
```

### Use Primitive Types When Possible

```java
// BAD: Unnecessary boxing
List<Integer> numbers = new ArrayList<>();
for (int i = 0; i < 1000000; i++) {
    numbers.add(i);  // Boxing overhead
}

// GOOD: Use primitive array or specialized collections
int[] numbers = new int[1000000];
for (int i = 0; i < 1000000; i++) {
    numbers[i] = i;
}

// For streams with primitives
IntStream.range(0, 1000000)  // Specialized stream
    .sum();
```

## Testing

### Write Testable Code

```java
// BAD: Hard to test (dependencies are hidden)
public class UserService {
    public void registerUser(User user) {
        UserRepository repo = new UserRepository();  // Hard-coded dependency
        repo.save(user);
    }
}

// GOOD: Inject dependencies (easy to test with mocks)
public class UserService {
    private final UserRepository repository;
    
    public UserService(UserRepository repository) {
        this.repository = repository;
    }
    
    public void registerUser(User user) {
        repository.save(user);
    }
}
```

### Follow AAA Pattern

```java
@Test
void testCalculation() {
    // Arrange
    Calculator calc = new Calculator();
    int a = 5;
    int b = 3;
    
    // Act
    int result = calc.add(a, b);
    
    // Assert
    assertEquals(8, result);
}
```

## Code Documentation

### JavaDoc for Public APIs

```java
/**
 * Calculates the total price including tax.
 *
 * @param basePrice the base price before tax
 * @param taxRate the tax rate as a decimal (e.g., 0.1 for 10%)
 * @return the total price including tax
 * @throws IllegalArgumentException if basePrice or taxRate is negative
 */
public double calculateTotalPrice(double basePrice, double taxRate) {
    if (basePrice < 0 || taxRate < 0) {
        throw new IllegalArgumentException("Price and tax rate must be non-negative");
    }
    return basePrice * (1 + taxRate);
}
```

### Comments Should Explain Why, Not What

```java
// BAD: Obvious comment
// Increment i
i++;

// Add item to list
list.add(item);

// GOOD: Explain why
// Using binary search because list is sorted
int index = Collections.binarySearch(list, key);

// Retry logic for network requests
for (int attempt = 0; attempt < MAX_RETRIES; attempt++) {
    // ...
}
```

## Modern Java Features (Java 8+)

### Use Records for Data Classes (Java 14+)

```java
// Old way
public class Point {
    private final int x;
    private final int y;
    
    public Point(int x, int y) {
        this.x = x;
        this.y = y;
    }
    
    public int getX() { return x; }
    public int getY() { return y; }
    
    // equals, hashCode, toString...
}

// Modern way with record
public record Point(int x, int y) {
    // Auto-generates constructor, getters, equals, hashCode, toString
}
```

### Use Switch Expressions (Java 12+)

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

// Modern switch expression
String result = switch (day) {
    case MONDAY, FRIDAY -> "Work";
    case SATURDAY, SUNDAY -> "Weekend";
    default -> "Other";
};
```

## Quick Checklist

- ✅ Use meaningful variable and method names
- ✅ Keep methods small (<20 lines ideally)
- ✅ Follow Single Responsibility Principle
- ✅ Use exceptions for exceptional cases
- ✅ Always close resources (use try-with-resources)
- ✅ Use specific collection types
- ✅ Prefer composition over inheritance
- ✅ Write unit tests
- ✅ Use Optional instead of returning null
- ✅ Make classes immutable when possible
- ✅ Use StringBuilder for string concatenation in loops
- ✅ Use equals() for object comparison
- ✅ Leverage streams for collection operations
- ✅ Document public APIs with JavaDoc
- ✅ Use modern Java features (records, switch expressions, etc.)

---

**Previous**: [← Spring Basics](java-21-spring-basics.md) | **Next**: [Interview Prep →](java-29-interview-prep.md)
