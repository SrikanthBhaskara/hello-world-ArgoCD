# Java Abstraction & Interfaces

## Abstract Classes

### Defining Abstract Classes

```java
// Abstract class - cannot be instantiated
public abstract class Vehicle {
    protected String brand;
    protected int year;
    
    public Vehicle(String brand, int year) {
        this.brand = brand;
        this.year = year;
    }
    
    // Abstract method - no implementation
    public abstract void start();
    public abstract void stop();
    public abstract double getMaxSpeed();
    
    // Concrete method - has implementation
    public void displayInfo() {
        System.out.println(brand + " " + year);
    }
    
    // Can have static methods
    public static void generalInfo() {
        System.out.println("This is a vehicle");
    }
}

// Concrete class must implement all abstract methods
public class Car extends Vehicle {
    private int doors;
    
    public Car(String brand, int year, int doors) {
        super(brand, year);
        this.doors = doors;
    }
    
    @Override
    public void start() {
        System.out.println("Car starting with key");
    }
    
    @Override
    public void stop() {
        System.out.println("Car stopping");
    }
    
    @Override
    public double getMaxSpeed() {
        return 200.0;
    }
}
```

## Interfaces

### Defining Interfaces

```java
// Interface - contract for classes
public interface Drawable {
    // Abstract method (implicitly public abstract)
    void draw();
    void resize(double factor);
    
    // Constant (implicitly public static final)
    String TYPE = "2D";
    int DEFAULT_SIZE = 100;
}

// Implementing interface
public class Circle implements Drawable {
    private double radius;
    
    public Circle(double radius) {
        this.radius = radius;
    }
    
    @Override
    public void draw() {
        System.out.println("Drawing circle with radius " + radius);
    }
    
    @Override
    public void resize(double factor) {
        radius *= factor;
    }
}
```

### Multiple Interfaces

```java
public interface Flyable {
    void fly();
    double getAltitude();
}

public interface Swimmable {
    void swim();
    double getDepth();
}

// Class can implement multiple interfaces
public class Duck implements Flyable, Swimmable {
    @Override
    public void fly() {
        System.out.println("Duck flying");
    }
    
    @Override
    public double getAltitude() {
        return 100.0;
    }
    
    @Override
    public void swim() {
        System.out.println("Duck swimming");
    }
    
    @Override
    public double getDepth() {
        return 2.0;
    }
}
```

### Default Methods (Java 8+)

```java
public interface Vehicle {
    // Abstract methods
    void start();
    void stop();
    
    // Default method - provides implementation
    default void honk() {
        System.out.println("Beep beep!");
    }
    
    default void displayInfo() {
        System.out.println("This is a vehicle");
    }
}

public class Car implements Vehicle {
    @Override
    public void start() {
        System.out.println("Car starting");
    }
    
    @Override
    public void stop() {
        System.out.println("Car stopping");
    }
    
    // Can override default method
    @Override
    public void honk() {
        System.out.println("Car horn: HONK!");
    }
    
    // Or use default implementation for displayInfo()
}
```

### Static Methods in Interfaces (Java 8+)

```java
public interface MathOperations {
    // Static method in interface
    static int add(int a, int b) {
        return a + b;
    }
    
    static double multiply(double a, double b) {
        return a * b;
    }
    
    // Abstract method
    int calculate(int x, int y);
}

// Usage
public class Main {
    public static void main(String[] args) {
        // Call static method directly on interface
        int result = MathOperations.add(5, 3);
        System.out.println(result);  // 8
    }
}
```

### Private Methods in Interfaces (Java 9+)

```java
public interface Logger {
    default void logInfo(String message) {
        log("INFO", message);
    }
    
    default void logError(String message) {
        log("ERROR", message);
    }
    
    // Private method - common implementation
    private void log(String level, String message) {
        System.out.println("[" + level + "] " + message);
    }
}
```

## Interface Inheritance

```java
// Interface can extend other interfaces
public interface Animal {
    void eat();
    void sleep();
}

public interface Pet extends Animal {
    void play();
    String getName();
}

public interface WildAnimal extends Animal {
    void hunt();
    String getHabitat();
}

// Multiple inheritance
public interface FlyingPet extends Pet, Flyable {
    // Inherits methods from Pet and Flyable
}
```

## Abstract Class vs Interface

| Feature | Abstract Class | Interface |
|---------|---------------|-----------|
| Multiple inheritance | No | Yes |
| Constructor | Yes | No |
| Instance variables | Yes | No (only constants) |
| Method types | Abstract & concrete | Abstract, default, static |
| Access modifiers | Any | public only |
| When to use | IS-A relationship | CAN-DO capability |

```java
// Abstract class for IS-A relationship
abstract class Animal {
    protected String name;
    abstract void makeSound();
}

class Dog extends Animal {
    void makeSound() { System.out.println("Bark"); }
}

// Interface for CAN-DO capability
interface Flyable {
    void fly();
}

interface Swimmable {
    void swim();
}

class Duck extends Animal implements Flyable, Swimmable {
    void makeSound() { System.out.println("Quack"); }
    public void fly() { System.out.println("Flying"); }
    public void swim() { System.out.println("Swimming"); }
}
```

## Functional Interfaces

### Single Abstract Method

```java
// Functional interface - exactly one abstract method
@FunctionalInterface
public interface Calculator {
    int calculate(int a, int b);
    
    // Can have default methods
    default void displayResult(int result) {
        System.out.println("Result: " + result);
    }
    
    // Can have static methods
    static void info() {
        System.out.println("Calculator interface");
    }
}

// Lambda expression (Java 8+)
public class Main {
    public static void main(String[] args) {
        // Old way - anonymous class
        Calculator add = new Calculator() {
            @Override
            public int calculate(int a, int b) {
                return a + b;
            }
        };
        
        // New way - lambda
        Calculator add2 = (a, b) -> a + b;
        Calculator multiply = (a, b) -> a * b;
        
        System.out.println(add2.calculate(5, 3));      // 8
        System.out.println(multiply.calculate(5, 3));   // 15
    }
}
```

### Built-in Functional Interfaces

```java
import java.util.function.*;

public class FunctionalInterfaceDemo {
    public static void main(String[] args) {
        // Predicate<T> - takes T, returns boolean
        Predicate<Integer> isEven = n -> n % 2 == 0;
        System.out.println(isEven.test(4));  // true
        
        // Function<T,R> - takes T, returns R
        Function<String, Integer> length = s -> s.length();
        System.out.println(length.apply("Hello"));  // 5
        
        // Consumer<T> - takes T, returns void
        Consumer<String> printer = s -> System.out.println(s);
        printer.accept("Hello");  // Hello
        
        // Supplier<T> - takes nothing, returns T
        Supplier<Double> random = () -> Math.random();
        System.out.println(random.get());
        
        // BiFunction<T,U,R> - takes T and U, returns R
        BiFunction<Integer, Integer, Integer> add = (a, b) -> a + b;
        System.out.println(add.apply(5, 3));  // 8
    }
}
```

## Marker Interfaces

```java
// Empty interface - marks a class with special property
public interface Serializable {
    // No methods
}

public class Person implements Serializable {
    // Now Person can be serialized
}
```

## Practical Examples

### Payment System

```java
// Common interface
public interface PaymentMethod {
    boolean processPayment(double amount);
    String getPaymentType();
    
    default void printReceipt(double amount) {
        System.out.println("Payment received: $" + amount);
        System.out.println("Method: " + getPaymentType());
    }
}

// Different implementations
public class CreditCard implements PaymentMethod {
    private String cardNumber;
    private String cvv;
    
    public CreditCard(String cardNumber, String cvv) {
        this.cardNumber = cardNumber;
        this.cvv = cvv;
    }
    
    @Override
    public boolean processPayment(double amount) {
        System.out.println("Processing credit card payment: $" + amount);
        // Validation logic
        return true;
    }
    
    @Override
    public String getPaymentType() {
        return "Credit Card";
    }
}

public class PayPal implements PaymentMethod {
    private String email;
    
    public PayPal(String email) {
        this.email = email;
    }
    
    @Override
    public boolean processPayment(double amount) {
        System.out.println("Processing PayPal payment: $" + amount);
        return true;
    }
    
    @Override
    public String getPaymentType() {
        return "PayPal";
    }
}

public class Bitcoin implements PaymentMethod {
    private String walletAddress;
    
    public Bitcoin(String walletAddress) {
        this.walletAddress = walletAddress;
    }
    
    @Override
    public boolean processPayment(double amount) {
        System.out.println("Processing Bitcoin payment: $" + amount);
        return true;
    }
    
    @Override
    public String getPaymentType() {
        return "Bitcoin";
    }
}

// Usage
public class PaymentProcessor {
    public void process(PaymentMethod payment, double amount) {
        if (payment.processPayment(amount)) {
            payment.printReceipt(amount);
        }
    }
    
    public static void main(String[] args) {
        PaymentProcessor processor = new PaymentProcessor();
        
        PaymentMethod[] payments = {
            new CreditCard("1234-5678-9012-3456", "123"),
            new PayPal("user@example.com"),
            new Bitcoin("1A2B3C4D5E6F...")
        };
        
        for (PaymentMethod payment : payments) {
            processor.process(payment, 100.0);
        }
    }
}
```

### Notification System

```java
public interface Notifiable {
    void send(String recipient, String message);
    String getNotificationType();
}

public class EmailNotification implements Notifiable {
    @Override
    public void send(String recipient, String message) {
        System.out.println("Sending email to: " + recipient);
        System.out.println("Message: " + message);
    }
    
    @Override
    public String getNotificationType() {
        return "Email";
    }
}

public class SMSNotification implements Notifiable {
    @Override
    public void send(String recipient, String message) {
        System.out.println("Sending SMS to: " + recipient);
        System.out.println("Message: " + message);
    }
    
    @Override
    public String getNotificationType() {
        return "SMS";
    }
}

public class PushNotification implements Notifiable {
    @Override
    public void send(String recipient, String message) {
        System.out.println("Sending push notification to: " + recipient);
        System.out.println("Message: " + message);
    }
    
    @Override
    public String getNotificationType() {
        return "Push";
    }
}
```

### Shape Hierarchy

```java
// Abstract base class
public abstract class Shape {
    protected String color;
    
    public Shape(String color) {
        this.color = color;
    }
    
    // Abstract methods
    public abstract double getArea();
    public abstract double getPerimeter();
    
    // Concrete method
    public String getColor() {
        return color;
    }
    
    public void displayInfo() {
        System.out.println("Color: " + color);
        System.out.println("Area: " + getArea());
        System.out.println("Perimeter: " + getPerimeter());
    }
}

// Interfaces for capabilities
public interface Rotatable {
    void rotate(double degrees);
}

public interface Scalable {
    void scale(double factor);
}

// Concrete classes
public class Circle extends Shape implements Rotatable, Scalable {
    private double radius;
    
    public Circle(String color, double radius) {
        super(color);
        this.radius = radius;
    }
    
    @Override
    public double getArea() {
        return Math.PI * radius * radius;
    }
    
    @Override
    public double getPerimeter() {
        return 2 * Math.PI * radius;
    }
    
    @Override
    public void rotate(double degrees) {
        System.out.println("Circle rotated by " + degrees + " degrees");
    }
    
    @Override
    public void scale(double factor) {
        radius *= factor;
    }
}

public class Rectangle extends Shape implements Rotatable, Scalable {
    private double width;
    private double height;
    
    public Rectangle(String color, double width, double height) {
        super(color);
        this.width = width;
        this.height = height;
    }
    
    @Override
    public double getArea() {
        return width * height;
    }
    
    @Override
    public double getPerimeter() {
        return 2 * (width + height);
    }
    
    @Override
    public void rotate(double degrees) {
        System.out.println("Rectangle rotated by " + degrees + " degrees");
    }
    
    @Override
    public void scale(double factor) {
        width *= factor;
        height *= factor;
    }
}
```

## Best Practices

### Interface Segregation Principle

```java
// BAD: Fat interface
interface Worker {
    void work();
    void eat();
    void sleep();
    void getMaintenance();  // Only for robots!
}

// GOOD: Segregated interfaces
interface Workable {
    void work();
}

interface Eatable {
    void eat();
}

interface Sleepable {
    void sleep();
}

interface Maintainable {
    void getMaintenance();
}

class Human implements Workable, Eatable, Sleepable {
    public void work() { }
    public void eat() { }
    public void sleep() { }
}

class Robot implements Workable, Maintainable {
    public void work() { }
    public void getMaintenance() { }
}
```

### Programming to Interfaces

```java
// GOOD: Use interface as type
List<String> list = new ArrayList<>();  // List is interface
Map<String, Integer> map = new HashMap<>();

// BAD: Use concrete type
ArrayList<String> list2 = new ArrayList<>();
```

## Quick Reference

```java
// Abstract class
abstract class ClassName {
    abstract void method();         // Must be implemented
    void concreteMethod() { }      // Optional to override
}

// Interface
interface InterfaceName {
    void method();                 // Implicitly public abstract
    default void defaultMethod() { }  // Java 8+
    static void staticMethod() { }    // Java 8+
    private void privateMethod() { }  // Java 9+
}

// Implementation
class MyClass extends AbstractClass implements Interface1, Interface2 {
    // Implement all abstract methods
}
```

---

**Previous**: [← Inheritance](java-05-inheritance-polymorphism.md) | **Next**: [Encapsulation →](java-07-encapsulation.md)
