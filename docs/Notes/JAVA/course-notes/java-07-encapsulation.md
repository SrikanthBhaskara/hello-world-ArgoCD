# Java Encapsulation & Access Modifiers

## Access Modifiers

### Four Access Levels

```java
public class AccessDemo {
    // public: accessible everywhere
    public int publicVar = 1;
    
    // protected: accessible in package + subclasses
    protected int protectedVar = 2;
    
    // default (no modifier): accessible in package only
    int defaultVar = 3;
    
    // private: accessible only in this class
    private int privateVar = 4;
    
    public void demo() {
        // All accessible within the same class
        System.out.println(publicVar);
        System.out.println(protectedVar);
        System.out.println(defaultVar);
        System.out.println(privateVar);
    }
}
```

### Access Modifier Summary

| Modifier | Class | Package | Subclass | World |
|----------|-------|---------|----------|-------|
| public | ✓ | ✓ | ✓ | ✓ |
| protected | ✓ | ✓ | ✓ | ✗ |
| default | ✓ | ✓ | ✗ | ✗ |
| private | ✓ | ✗ | ✗ | ✗ |

## Encapsulation Principles

### Private Fields with Public Methods

```java
public class BankAccount {
    // Private fields - hidden from outside
    private String accountNumber;
    private String ownerName;
    private double balance;
    private boolean isActive;
    
    // Constructor
    public BankAccount(String accountNumber, String ownerName) {
        this.accountNumber = accountNumber;
        this.ownerName = ownerName;
        this.balance = 0.0;
        this.isActive = true;
    }
    
    // Getters - controlled read access
    public String getAccountNumber() {
        return accountNumber;
    }
    
    public String getOwnerName() {
        return ownerName;
    }
    
    public double getBalance() {
        return balance;
    }
    
    public boolean isActive() {
        return isActive;
    }
    
    // Setters with validation
    public void setOwnerName(String ownerName) {
        if (ownerName != null && !ownerName.trim().isEmpty()) {
            this.ownerName = ownerName;
        } else {
            throw new IllegalArgumentException("Name cannot be empty");
        }
    }
    
    // Business methods - controlled operations
    public void deposit(double amount) {
        if (!isActive) {
            throw new IllegalStateException("Account is closed");
        }
        if (amount <= 0) {
            throw new IllegalArgumentException("Amount must be positive");
        }
        balance += amount;
    }
    
    public boolean withdraw(double amount) {
        if (!isActive) {
            throw new IllegalStateException("Account is closed");
        }
        if (amount <= 0) {
            throw new IllegalArgumentException("Amount must be positive");
        }
        if (amount > balance) {
            return false;  // Insufficient funds
        }
        balance -= amount;
        return true;
    }
    
    public void closeAccount() {
        if (balance > 0) {
            throw new IllegalStateException("Cannot close account with balance");
        }
        isActive = false;
    }
}
```

## JavaBean Conventions

### Standard Naming Patterns

```java
public class Person {
    private String name;
    private int age;
    private boolean employed;
    
    // Default constructor (required for JavaBean)
    public Person() {
    }
    
    // Getters follow pattern: get + PropertyName
    public String getName() {
        return name;
    }
    
    public int getAge() {
        return age;
    }
    
    // Boolean getters can use "is" prefix
    public boolean isEmployed() {
        return employed;
    }
    
    // Setters follow pattern: set + PropertyName
    public void setName(String name) {
        this.name = name;
    }
    
    public void setAge(int age) {
        if (age >= 0 && age <= 150) {
            this.age = age;
        }
    }
    
    public void setEmployed(boolean employed) {
        this.employed = employed;
    }
}
```

## Immutable Classes

### Making Classes Immutable

```java
// Immutable class checklist:
// 1. Make class final
// 2. Make all fields private and final
// 3. No setters
// 4. Initialize all fields via constructor
// 5. Return copies of mutable objects

public final class ImmutablePerson {
    private final String name;
    private final int age;
    private final List<String> hobbies;
    
    public ImmutablePerson(String name, int age, List<String> hobbies) {
        this.name = name;
        this.age = age;
        // Create defensive copy of mutable object
        this.hobbies = new ArrayList<>(hobbies);
    }
    
    // Only getters, no setters
    public String getName() {
        return name;
    }
    
    public int getAge() {
        return age;
    }
    
    // Return copy to prevent modification
    public List<String> getHobbies() {
        return new ArrayList<>(hobbies);
    }
    
    // To "modify", create new instance
    public ImmutablePerson withAge(int newAge) {
        return new ImmutablePerson(this.name, newAge, this.hobbies);
    }
    
    public ImmutablePerson withHobby(String hobby) {
        List<String> newHobbies = new ArrayList<>(this.hobbies);
        newHobbies.add(hobby);
        return new ImmutablePerson(this.name, this.age, newHobbies);
    }
}

// Usage
public class Main {
    public static void main(String[] args) {
        List<String> hobbies = Arrays.asList("Reading", "Coding");
        ImmutablePerson person = new ImmutablePerson("Alice", 25, hobbies);
        
        // Cannot modify original
        // person.age = 30;  // Compile error - field is private
        
        // Create new instance with different age
        ImmutablePerson older = person.withAge(26);
        
        System.out.println(person.getAge());  // 25 (unchanged)
        System.out.println(older.getAge());   // 26
    }
}
```

## Validation in Setters

```java
public class Employee {
    private String name;
    private int age;
    private double salary;
    private String email;
    
    public void setName(String name) {
        if (name == null || name.trim().isEmpty()) {
            throw new IllegalArgumentException("Name cannot be empty");
        }
        if (name.length() < 2 || name.length() > 50) {
            throw new IllegalArgumentException("Name length must be 2-50 characters");
        }
        this.name = name;
    }
    
    public void setAge(int age) {
        if (age < 18 || age > 65) {
            throw new IllegalArgumentException("Age must be between 18 and 65");
        }
        this.age = age;
    }
    
    public void setSalary(double salary) {
        if (salary < 0) {
            throw new IllegalArgumentException("Salary cannot be negative");
        }
        if (salary > 1000000) {
            throw new IllegalArgumentException("Salary exceeds maximum");
        }
        this.salary = salary;
    }
    
    public void setEmail(String email) {
        if (email == null || !email.matches("^[A-Za-z0-9+_.-]+@(.+)$")) {
            throw new IllegalArgumentException("Invalid email format");
        }
        this.email = email;
    }
}
```

## Read-Only Properties

```java
public class Product {
    private final String id;  // Cannot be changed
    private String name;
    private double price;
    
    public Product(String id, String name, double price) {
        this.id = id;
        this.name = name;
        this.price = price;
    }
    
    // Read-only: getter but no setter
    public String getId() {
        return id;
    }
    
    // Read-write: getter and setter
    public String getName() {
        return name;
    }
    
    public void setName(String name) {
        this.name = name;
    }
    
    public double getPrice() {
        return price;
    }
    
    public void setPrice(double price) {
        if (price >= 0) {
            this.price = price;
        }
    }
}
```

## Computed Properties

```java
public class Rectangle {
    private double width;
    private double height;
    
    public Rectangle(double width, double height) {
        this.width = width;
        this.height = height;
    }
    
    // Regular getters/setters
    public double getWidth() {
        return width;
    }
    
    public void setWidth(double width) {
        if (width > 0) {
            this.width = width;
        }
    }
    
    public double getHeight() {
        return height;
    }
    
    public void setHeight(double height) {
        if (height > 0) {
            this.height = height;
        }
    }
    
    // Computed properties - calculated, not stored
    public double getArea() {
        return width * height;
    }
    
    public double getPerimeter() {
        return 2 * (width + height);
    }
    
    public double getDiagonal() {
        return Math.sqrt(width * width + height * height);
    }
    
    // Computed with derived logic
    public boolean isSquare() {
        return width == height;
    }
}
```

## Lazy Initialization

```java
public class ExpensiveObject {
    private String data;
    private List<String> processedData;  // Expensive to compute
    
    public ExpensiveObject(String data) {
        this.data = data;
        // Don't process yet - lazy initialization
    }
    
    // Compute only when first accessed
    public List<String> getProcessedData() {
        if (processedData == null) {
            System.out.println("Processing data...");
            processedData = processData(data);
        }
        return processedData;
    }
    
    private List<String> processData(String data) {
        // Expensive operation
        return Arrays.asList(data.split("\\s+"));
    }
}
```

## Package-Private Classes

```java
// File: internal/Helper.java
package com.example.internal;

// Package-private class (no public modifier)
class Helper {
    void helpMethod() {
        System.out.println("Internal helper");
    }
}

// Public class in same package can access
public class PublicClass {
    private Helper helper = new Helper();
    
    public void doSomething() {
        helper.helpMethod();  // OK - same package
    }
}

// File: api/ClientCode.java
package com.example.api;
import com.example.internal.Helper;  // Compile error!

public class ClientCode {
    // Cannot access Helper from different package
}
```

## Data Transfer Objects (DTOs)

```java
// DTO with all public fields (acceptable for data transfer)
public class UserDTO {
    public String username;
    public String email;
    public int age;
    
    public UserDTO() {
    }
    
    public UserDTO(String username, String email, int age) {
        this.username = username;
        this.email = email;
        this.age = age;
    }
}

// Better: DTO with private fields and getters/setters
public class UserDTO {
    private String username;
    private String email;
    private int age;
    
    // Getters and setters
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    
    public int getAge() { return age; }
    public void setAge(int age) { this.age = age; }
}
```

## Practical Example: Student Management

```java
public class Student {
    // Private fields
    private final int id;  // Immutable
    private String name;
    private String email;
    private double gpa;
    private List<String> courses;
    
    private static int nextId = 1000;
    
    // Constructor
    public Student(String name, String email) {
        this.id = nextId++;
        setName(name);  // Use setter for validation
        setEmail(email);
        this.gpa = 0.0;
        this.courses = new ArrayList<>();
    }
    
    // Read-only property
    public int getId() {
        return id;
    }
    
    // Validated setters
    public void setName(String name) {
        if (name == null || name.trim().isEmpty()) {
            throw new IllegalArgumentException("Name cannot be empty");
        }
        this.name = name.trim();
    }
    
    public String getName() {
        return name;
    }
    
    public void setEmail(String email) {
        if (email == null || !email.contains("@")) {
            throw new IllegalArgumentException("Invalid email");
        }
        this.email = email.toLowerCase();
    }
    
    public String getEmail() {
        return email;
    }
    
    public void setGpa(double gpa) {
        if (gpa < 0.0 || gpa > 4.0) {
            throw new IllegalArgumentException("GPA must be between 0.0 and 4.0");
        }
        this.gpa = gpa;
    }
    
    public double getGpa() {
        return gpa;
    }
    
    // Return copy to prevent modification
    public List<String> getCourses() {
        return new ArrayList<>(courses);
    }
    
    // Controlled modification
    public void addCourse(String course) {
        if (course != null && !course.trim().isEmpty()) {
            courses.add(course.trim());
        }
    }
    
    public void removeCourse(String course) {
        courses.remove(course);
    }
    
    // Computed property
    public boolean isHonorStudent() {
        return gpa >= 3.5;
    }
    
    public String getAcademicStanding() {
        if (gpa >= 3.5) return "Excellent";
        if (gpa >= 3.0) return "Good";
        if (gpa >= 2.0) return "Satisfactory";
        return "Probation";
    }
    
    @Override
    public String toString() {
        return String.format("Student[id=%d, name=%s, gpa=%.2f]", 
                            id, name, gpa);
    }
}
```

## Benefits of Encapsulation

```java
// Without encapsulation - BAD
class BadAccount {
    public double balance;  // Anyone can modify!
}

BadAccount acc = new BadAccount();
acc.balance = -1000;  // Invalid state!

// With encapsulation - GOOD
class GoodAccount {
    private double balance;
    
    public void deposit(double amount) {
        if (amount > 0) balance += amount;
    }
    
    public boolean withdraw(double amount) {
        if (amount > 0 && amount <= balance) {
            balance -= amount;
            return true;
        }
        return false;
    }
    
    public double getBalance() {
        return balance;
    }
}

GoodAccount acc = new GoodAccount();
// acc.balance = -1000;  // Compile error!
acc.deposit(1000);       // Only valid operations allowed
```

## Best Practices

```java
public class BestPractices {
    // 1. Make fields private
    private String field;
    
    // 2. Provide public getters/setters only when needed
    public String getField() { return field; }
    public void setField(String field) { this.field = field; }
    
    // 3. Validate in setters
    public void setAge(int age) {
        if (age < 0) throw new IllegalArgumentException();
        this.age = age;
    }
    
    // 4. Return copies of mutable objects
    private List<String> items;
    public List<String> getItems() {
        return new ArrayList<>(items);
    }
    
    // 5. Make immutable fields final
    private final String id;
    
    // 6. Use meaningful names
    public boolean isActive() { }  // Not: getActive()
    public int getCount() { }      // Not: count()
}
```

## Quick Reference

```java
// Access modifiers
public class MyClass {
    public int publicField;       // Accessible everywhere
    protected int protectedField; // Package + subclasses
    int defaultField;             // Package only
    private int privateField;     // This class only
}

// Encapsulation pattern
public class EncapsulatedClass {
    private Type field;           // Private field
    
    public Type getField() {      // Public getter
        return field;
    }
    
    public void setField(Type field) {  // Public setter
        // Validation
        this.field = field;
    }
}

// Immutable class
public final class Immutable {
    private final Type field;     // Final field
    public Immutable(Type field) { // Constructor
        this.field = field;
    }
    public Type getField() {      // Only getter
        return field;
    }
}
```

---

**Previous**: [← Abstraction & Interfaces](java-06-abstraction-interfaces.md) | **Next**: [Strings →](java-08-strings.md)
