# Java Classes & Objects

## Class Basics

### Defining a Class

```java
// Class definition
public class Person {
    // Fields (instance variables)
    String name;
    int age;
    String email;
    
    // Constructor
    public Person(String name, int age, String email) {
        this.name = name;
        this.age = age;
        this.email = email;
    }
    
    // Method
    public void introduce() {
        System.out.println("Hi, I'm " + name + ", " + age + " years old");
    }
}

// Using the class
public class Main {
    public static void main(String[] args) {
        // Create object (instantiate)
        Person person = new Person("Alice", 25, "alice@example.com");
        
        // Access fields
        System.out.println(person.name);  // Alice
        
        // Call method
        person.introduce();  // Hi, I'm Alice, 25 years old
    }
}
```

## Constructors

### Default Constructor

```java
public class Book {
    String title;
    String author;
    
    // Default constructor (no parameters)
    public Book() {
        title = "Unknown";
        author = "Unknown";
    }
    
    // If you don't define any constructor,
    // Java provides a default no-arg constructor automatically
}
```

### Parameterized Constructors

```java
public class Book {
    String title;
    String author;
    int pages;
    
    // Constructor with all parameters
    public Book(String title, String author, int pages) {
        this.title = title;
        this.author = author;
        this.pages = pages;
    }
    
    // Constructor with some parameters
    public Book(String title, String author) {
        this.title = title;
        this.author = author;
        this.pages = 0;  // Default value
    }
    
    // Default constructor
    public Book() {
        this.title = "Unknown";
        this.author = "Unknown";
        this.pages = 0;
    }
}
```

### Constructor Chaining

```java
public class Employee {
    String name;
    int id;
    double salary;
    
    // Primary constructor
    public Employee(String name, int id, double salary) {
        this.name = name;
        this.id = id;
        this.salary = salary;
    }
    
    // Calls primary constructor with default salary
    public Employee(String name, int id) {
        this(name, id, 50000.0);  // this() must be first statement
    }
    
    // Calls above constructor with default id
    public Employee(String name) {
        this(name, 0);
    }
}
```

## this Keyword

```java
public class Rectangle {
    int width;
    int height;
    
    // this refers to current object
    public Rectangle(int width, int height) {
        this.width = width;    // Distinguish from parameter
        this.height = height;
    }
    
    // this in method
    public Rectangle scale(int factor) {
        this.width *= factor;
        this.height *= factor;
        return this;  // Return current object for chaining
    }
    
    // Method chaining
    public static void main(String[] args) {
        Rectangle rect = new Rectangle(5, 10);
        rect.scale(2).scale(3);  // Chaining
        System.out.println(rect.width);  // 30
    }
}
```

## Instance vs Static Members

### Instance Variables and Methods

```java
public class Counter {
    // Instance variable - each object has its own copy
    private int count = 0;
    
    // Instance method - operates on instance
    public void increment() {
        count++;
    }
    
    public int getCount() {
        return count;
    }
    
    public static void main(String[] args) {
        Counter c1 = new Counter();
        Counter c2 = new Counter();
        
        c1.increment();
        c1.increment();
        c2.increment();
        
        System.out.println(c1.getCount());  // 2
        System.out.println(c2.getCount());  // 1 (separate)
    }
}
```

### Static Variables and Methods

```java
public class Student {
    String name;
    int age;
    
    // Static variable - shared by all instances
    static int studentCount = 0;
    
    // Static constant
    static final String SCHOOL_NAME = "Example High School";
    
    public Student(String name, int age) {
        this.name = name;
        this.age = age;
        studentCount++;  // Increment for each new student
    }
    
    // Static method - belongs to class
    public static int getStudentCount() {
        // Cannot access instance variables here!
        // Cannot use 'this' keyword
        return studentCount;
    }
    
    public static void main(String[] args) {
        System.out.println(Student.studentCount);  // 0
        
        Student s1 = new Student("Alice", 20);
        Student s2 = new Student("Bob", 22);
        
        System.out.println(Student.studentCount);  // 2
        System.out.println(Student.getStudentCount());  // 2
    }
}
```

### Static Blocks

```java
public class Config {
    static String databaseUrl;
    static int maxConnections;
    
    // Static initialization block
    // Runs once when class is loaded
    static {
        System.out.println("Loading configuration...");
        databaseUrl = "jdbc:mysql://localhost:3306/db";
        maxConnections = 10;
    }
    
    // Can have multiple static blocks
    static {
        System.out.println("Additional setup...");
    }
}
```

## Encapsulation

### Private Fields with Getters and Setters

```java
public class BankAccount {
    // Private fields - cannot be accessed directly
    private String accountNumber;
    private double balance;
    private String ownerName;
    
    public BankAccount(String accountNumber, String ownerName) {
        this.accountNumber = accountNumber;
        this.ownerName = ownerName;
        this.balance = 0.0;
    }
    
    // Getter methods
    public String getAccountNumber() {
        return accountNumber;
    }
    
    public double getBalance() {
        return balance;
    }
    
    public String getOwnerName() {
        return ownerName;
    }
    
    // Setter with validation
    public void setOwnerName(String ownerName) {
        if (ownerName != null && !ownerName.trim().isEmpty()) {
            this.ownerName = ownerName;
        }
    }
    
    // Business methods
    public void deposit(double amount) {
        if (amount > 0) {
            balance += amount;
        }
    }
    
    public boolean withdraw(double amount) {
        if (amount > 0 && amount <= balance) {
            balance -= amount;
            return true;
        }
        return false;
    }
}
```

## Object Methods

### toString()

```java
public class Person {
    String name;
    int age;
    
    public Person(String name, int age) {
        this.name = name;
        this.age = age;
    }
    
    // Override toString() for readable output
    @Override
    public String toString() {
        return "Person{name='" + name + "', age=" + age + "}";
    }
    
    public static void main(String[] args) {
        Person p = new Person("Alice", 25);
        System.out.println(p);  // Person{name='Alice', age=25}
    }
}
```

### equals() and hashCode()

```java
import java.util.Objects;

public class Person {
    String name;
    int age;
    
    public Person(String name, int age) {
        this.name = name;
        this.age = age;
    }
    
    // Override equals()
    @Override
    public boolean equals(Object obj) {
        if (this == obj) return true;
        if (obj == null || getClass() != obj.getClass()) return false;
        Person person = (Person) obj;
        return age == person.age && Objects.equals(name, person.name);
    }
    
    // MUST override hashCode() when overriding equals()
    @Override
    public int hashCode() {
        return Objects.hash(name, age);
    }
    
    public static void main(String[] args) {
        Person p1 = new Person("Alice", 25);
        Person p2 = new Person("Alice", 25);
        
        System.out.println(p1 == p2);          // false (different objects)
        System.out.println(p1.equals(p2));     // true (same content)
    }
}
```

## Nested Classes

### Inner Class

```java
public class OuterClass {
    private int outerField = 10;
    
    // Non-static inner class
    class InnerClass {
        void display() {
            // Can access outer class members
            System.out.println("Outer field: " + outerField);
        }
    }
    
    public static void main(String[] args) {
        OuterClass outer = new OuterClass();
        OuterClass.InnerClass inner = outer.new InnerClass();
        inner.display();  // Outer field: 10
    }
}
```

### Static Nested Class

```java
public class OuterClass {
    private static int staticField = 20;
    private int instanceField = 30;
    
    // Static nested class
    static class StaticNestedClass {
        void display() {
            System.out.println("Static field: " + staticField);
            // Cannot access instanceField directly
        }
    }
    
    public static void main(String[] args) {
        OuterClass.StaticNestedClass nested = new OuterClass.StaticNestedClass();
        nested.display();  // Static field: 20
    }
}
```

### Anonymous Classes

```java
public class AnonymousDemo {
    public static void main(String[] args) {
        // Anonymous class implementing interface
        Runnable r = new Runnable() {
            @Override
            public void run() {
                System.out.println("Running...");
            }
        };
        r.run();
        
        // With lambda (Java 8+)
        Runnable r2 = () -> System.out.println("Running with lambda...");
        r2.run();
    }
}
```

## Object Creation Patterns

### Builder Pattern

```java
public class User {
    // Required parameters
    private final String username;
    private final String email;
    
    // Optional parameters
    private final String firstName;
    private final String lastName;
    private final int age;
    
    private User(Builder builder) {
        this.username = builder.username;
        this.email = builder.email;
        this.firstName = builder.firstName;
        this.lastName = builder.lastName;
        this.age = builder.age;
    }
    
    // Builder class
    public static class Builder {
        // Required
        private final String username;
        private final String email;
        
        // Optional - with default values
        private String firstName = "";
        private String lastName = "";
        private int age = 0;
        
        public Builder(String username, String email) {
            this.username = username;
            this.email = email;
        }
        
        public Builder firstName(String firstName) {
            this.firstName = firstName;
            return this;
        }
        
        public Builder lastName(String lastName) {
            this.lastName = lastName;
            return this;
        }
        
        public Builder age(int age) {
            this.age = age;
            return this;
        }
        
        public User build() {
            return new User(this);
        }
    }
    
    public static void main(String[] args) {
        User user = new User.Builder("john_doe", "john@example.com")
            .firstName("John")
            .lastName("Doe")
            .age(30)
            .build();
    }
}
```

## Practical Examples

### Complete Student Class

```java
public class Student {
    private int id;
    private String name;
    private double gpa;
    private static int studentCount = 0;
    
    // Constructor
    public Student(String name, double gpa) {
        this.id = ++studentCount;
        this.name = name;
        this.gpa = gpa;
    }
    
    // Getters
    public int getId() { return id; }
    public String getName() { return name; }
    public double getGpa() { return gpa; }
    
    // Setter with validation
    public void setGpa(double gpa) {
        if (gpa >= 0.0 && gpa <= 4.0) {
            this.gpa = gpa;
        }
    }
    
    // Business methods
    public boolean isHonorStudent() {
        return gpa >= 3.5;
    }
    
    public String getGrade() {
        if (gpa >= 3.7) return "A";
        if (gpa >= 3.0) return "B";
        if (gpa >= 2.0) return "C";
        if (gpa >= 1.0) return "D";
        return "F";
    }
    
    @Override
    public String toString() {
        return String.format("Student{id=%d, name='%s', gpa=%.2f}", 
                            id, name, gpa);
    }
    
    @Override
    public boolean equals(Object obj) {
        if (this == obj) return true;
        if (!(obj instanceof Student)) return false;
        Student student = (Student) obj;
        return id == student.id;
    }
    
    @Override
    public int hashCode() {
        return Integer.hashCode(id);
    }
}
```

### Shopping Cart Example

```java
import java.util.ArrayList;
import java.util.List;

class Product {
    private String name;
    private double price;
    
    public Product(String name, double price) {
        this.name = name;
        this.price = price;
    }
    
    public String getName() { return name; }
    public double getPrice() { return price; }
}

class CartItem {
    private Product product;
    private int quantity;
    
    public CartItem(Product product, int quantity) {
        this.product = product;
        this.quantity = quantity;
    }
    
    public double getTotal() {
        return product.getPrice() * quantity;
    }
    
    public Product getProduct() { return product; }
    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }
}

public class ShoppingCart {
    private List<CartItem> items;
    
    public ShoppingCart() {
        items = new ArrayList<>();
    }
    
    public void addItem(Product product, int quantity) {
        // Check if product already in cart
        for (CartItem item : items) {
            if (item.getProduct().equals(product)) {
                item.setQuantity(item.getQuantity() + quantity);
                return;
            }
        }
        items.add(new CartItem(product, quantity));
    }
    
    public void removeItem(Product product) {
        items.removeIf(item -> item.getProduct().equals(product));
    }
    
    public double getTotal() {
        double total = 0;
        for (CartItem item : items) {
            total += item.getTotal();
        }
        return total;
    }
    
    public void displayCart() {
        System.out.println("Shopping Cart:");
        for (CartItem item : items) {
            System.out.printf("%s x%d - $%.2f%n",
                item.getProduct().getName(),
                item.getQuantity(),
                item.getTotal());
        }
        System.out.printf("Total: $%.2f%n", getTotal());
    }
}
```

## Best Practices

### Immutable Classes

```java
// Immutable class - state cannot be changed after creation
public final class ImmutablePerson {
    private final String name;
    private final int age;
    
    public ImmutablePerson(String name, int age) {
        this.name = name;
        this.age = age;
    }
    
    // Only getters, no setters
    public String getName() { return name; }
    public int getAge() { return age; }
    
    // To "change" values, create new object
    public ImmutablePerson withAge(int newAge) {
        return new ImmutablePerson(this.name, newAge);
    }
}
```

### Single Responsibility Principle

```java
// BAD: Class does too many things
class User {
    void validateEmail() { }
    void saveToDatabase() { }
    void sendEmail() { }
    void generateReport() { }
}

// GOOD: Each class has one responsibility
class User {
    // Just user data
}

class UserValidator {
    void validateEmail(User user) { }
}

class UserRepository {
    void save(User user) { }
}

class EmailService {
    void send(User user, String message) { }
}
```

## Quick Reference

```java
// Class definition
public class ClassName {
    // Fields
    private int field;
    
    // Constructor
    public ClassName(int field) {
        this.field = field;
    }
    
    // Methods
    public void method() { }
    
    // Static members
    static int staticField;
    static void staticMethod() { }
}

// Create object
ClassName obj = new ClassName(10);

// Access members
obj.method();
ClassName.staticMethod();
```

---

**Previous**: [← Methods](java-03-methods.md) | **Next**: [Inheritance →](java-05-inheritance-polymorphism.md)
