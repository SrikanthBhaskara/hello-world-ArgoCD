# Java OOP Interview Guide - Complete Reference
## For 5+ Years Backend Developers

---

# 1. ENCAPSULATION

## 1.1 Concept Explanation

**Encapsulation** is the bundling of data (fields) and methods that operate on that data within a single unit (class), and restricting direct access to some components. It's achieved through:
- Private fields
- Public getter/setter methods
- Access modifiers (private, protected, public, default)

**Why Encapsulation?**
- **Data Protection**: Prevent unauthorized access and modification
- **Flexibility**: Change internal implementation without affecting external code
- **Validation**: Control how data is set through validation in setters
- **Read-only/Write-only**: Create fields that are only readable or only writable
- **Loose Coupling**: Hide implementation details from other classes

## 1.2 Real-World Examples

### Example 1: Banking System

```java
public class BankAccount {
    // Private fields - hidden from outside world
    private String accountNumber;
    private String accountHolderName;
    private double balance;
    private String pin;  // Sensitive data
    private List<Transaction> transactions;
    
    public BankAccount(String accountNumber, String name, String pin) {
        this.accountNumber = accountNumber;
        this.accountHolderName = name;
        this.pin = hashPin(pin);  // Never store plain pin
        this.balance = 0.0;
        this.transactions = new ArrayList<>();
    }
    
    // Read-only access to account number
    public String getAccountNumber() {
        return accountNumber;
    }
    
    // Read-only access to balance
    public double getBalance() {
        return balance;
    }
    
    // Controlled write access with validation
    public void setAccountHolderName(String name) {
        if (name == null || name.trim().isEmpty()) {
            throw new IllegalArgumentException("Name cannot be empty");
        }
        if (name.length() < 3) {
            throw new IllegalArgumentException("Name must be at least 3 characters");
        }
        this.accountHolderName = name;
    }
    
    // Business logic with validation
    public boolean deposit(double amount, String description) {
        if (amount <= 0) {
            throw new IllegalArgumentException("Deposit amount must be positive");
        }
        if (amount > 1000000) {  // Business rule
            throw new IllegalArgumentException("Single deposit cannot exceed 1,000,000");
        }
        
        balance += amount;
        transactions.add(new Transaction("DEPOSIT", amount, description));
        return true;
    }
    
    public boolean withdraw(double amount, String enteredPin) {
        // Multiple validations
        if (!verifyPin(enteredPin)) {
            throw new SecurityException("Invalid PIN");
        }
        if (amount <= 0) {
            throw new IllegalArgumentException("Withdrawal amount must be positive");
        }
        if (amount > balance) {
            throw new InsufficientFundsException("Insufficient balance");
        }
        if (amount > 50000) {  // Daily limit
            throw new IllegalArgumentException("Daily withdrawal limit exceeded");
        }
        
        balance -= amount;
        transactions.add(new Transaction("WITHDRAWAL", amount, "ATM Withdrawal"));
        return true;
    }
    
    // No getter for PIN - security measure
    public boolean verifyPin(String enteredPin) {
        return this.pin.equals(hashPin(enteredPin));
    }
    
    public void changePin(String oldPin, String newPin) {
        if (!verifyPin(oldPin)) {
            throw new SecurityException("Invalid old PIN");
        }
        if (newPin.length() != 4) {
            throw new IllegalArgumentException("PIN must be 4 digits");
        }
        this.pin = hashPin(newPin);
    }
    
    // Read-only copy of transactions (defensive copying)
    public List<Transaction> getTransactions() {
        return new ArrayList<>(transactions);  // Return copy, not original
    }
    
    private String hashPin(String pin) {
        // Simple hash for demo - use proper hashing in production
        return Integer.toString(pin.hashCode());
    }
}
```

### Example 2: Employee Management System

```java
public class Employee {
    private String employeeId;
    private String name;
    private String department;
    private double salary;
    private LocalDate joiningDate;
    private LocalDate lastPromotionDate;
    private EmployeeStatus status;
    
    public Employee(String employeeId, String name, String department, double salary) {
        this.employeeId = employeeId;
        this.name = name;
        this.department = department;
        this.salary = salary;
        this.joiningDate = LocalDate.now();
        this.status = EmployeeStatus.ACTIVE;
    }
    
    // Read-only properties
    public String getEmployeeId() {
        return employeeId;
    }
    
    public LocalDate getJoiningDate() {
        return joiningDate;
    }
    
    // Computed property - no backing field
    public int getYearsOfService() {
        return Period.between(joiningDate, LocalDate.now()).getYears();
    }
    
    // Controlled salary access - only display formatted
    public String getFormattedSalary() {
        return String.format("$%,.2f", salary);
    }
    
    // Only allow salary increase, not decrease
    public void increaseSalary(double percentage, String approvedBy) {
        if (percentage <= 0 || percentage > 50) {
            throw new IllegalArgumentException("Invalid percentage");
        }
        if (approvedBy == null || approvedBy.isEmpty()) {
            throw new IllegalArgumentException("Approval required");
        }
        
        double increment = salary * (percentage / 100);
        salary += increment;
        lastPromotionDate = LocalDate.now();
        
        // Log for audit
        System.out.println("Salary increased by " + percentage + "% approved by " + approvedBy);
    }
    
    // Business logic encapsulated
    public boolean isEligibleForPromotion() {
        if (status != EmployeeStatus.ACTIVE) {
            return false;
        }
        if (lastPromotionDate == null) {
            return getYearsOfService() >= 2;
        }
        return Period.between(lastPromotionDate, LocalDate.now()).getYears() >= 2;
    }
}

enum EmployeeStatus {
    ACTIVE, ON_LEAVE, RESIGNED, TERMINATED
}
```

## 1.3 Interview Questions and Answers

### Q1: What is encapsulation and why is it important?

**Answer:**
Encapsulation is one of the four fundamental OOP principles that bundles data (fields) and methods into a single unit (class) while hiding the internal state from outside access. It's important because:

1. **Data Protection**: Prevents external code from directly manipulating object state
2. **Flexibility**: Allows changing internal implementation without breaking client code
3. **Validation**: Enables data validation before state changes
4. **Maintainability**: Reduces coupling between classes
5. **Security**: Sensitive data can be hidden completely

Example: A `BankAccount` class hides the balance field and only allows modifications through validated methods like `deposit()` and `withdraw()`.

### Q2: Difference between Encapsulation and Abstraction?

**Answer:**
| Encapsulation | Abstraction |
|---------------|-------------|
| **Implementation hiding** - How data is stored and manipulated | **Complexity hiding** - What operations are available |
| Uses private fields + public methods | Uses abstract classes/interfaces |
| Focuses on data security | Focuses on design and architecture |
| Bundles data with methods | Provides contract/blueprint |
| `private int balance;` with getters/setters | `abstract void processPayment();` |

**Example:**
```java
// Encapsulation: Hiding HOW balance is stored
public class Account {
    private double balance;  // Could change to BigDecimal later
    
    public double getBalance() {
        return balance;
    }
}

// Abstraction: Hiding WHAT payment methods exist
public abstract class PaymentProcessor {
    public abstract void processPayment(double amount);  // Don't care how
}
```

### Q3: Can you have a class with only private members?

**Answer:**
Yes, but it's generally not useful. Such a class cannot be instantiated or used from outside. However, valid use cases include:

1. **Utility classes with static methods**:
```java
public class MathUtils {
    private MathUtils() {}  // Prevent instantiation
    
    public static int add(int a, int b) {
        return a + b;
    }
}
```

2. **Singleton pattern**:
```java
public class DatabaseConnection {
    private static DatabaseConnection instance;
    private Connection connection;
    
    private DatabaseConnection() {
        // Initialize connection
    }
    
    public static DatabaseConnection getInstance() {
        if (instance == null) {
            instance = new DatabaseConnection();
        }
        return instance;
    }
}
```

### Q4: What are the different access modifiers in Java?

**Answer:**

| Modifier | Same Class | Same Package | Subclass (Different Package) | World |
|----------|------------|--------------|------------------------------|-------|
| **private** | ✓ | ✗ | ✗ | ✗ |
| **default** (no modifier) | ✓ | ✓ | ✗ | ✗ |
| **protected** | ✓ | ✓ | ✓ | ✗ |
| **public** | ✓ | ✓ | ✓ | ✓ |

**Example:**
```java
package com.company;

public class Parent {
    public int publicVar = 1;        // Accessible everywhere
    protected int protectedVar = 2;  // Accessible in package + subclasses
    int defaultVar = 3;              // Accessible only in package
    private int privateVar = 4;      // Accessible only in this class
}

package com.other;
import com.company.Parent;

public class Child extends Parent {
    public void test() {
        System.out.println(publicVar);     // OK - public
        System.out.println(protectedVar);  // OK - protected accessible in subclass
        // System.out.println(defaultVar);  // ERROR - not in same package
        // System.out.println(privateVar);  // ERROR - private
    }
}
```

### Q5: Why are getters and setters needed if we can make fields public?

**Answer:**
Getters and setters provide several advantages over public fields:

1. **Validation**: Prevent invalid data
2. **Computed values**: Return calculated results
3. **Lazy initialization**: Create object only when needed
4. **Side effects**: Trigger events or logging
5. **Backward compatibility**: Change internal representation
6. **Access control**: Read-only or write-only properties
7. **Debugging**: Add breakpoints

**Example:**
```java
public class Person {
    private String name;
    private int age;
    private String email;
    
    // Validation in setter
    public void setAge(int age) {
        if (age < 0 || age > 150) {
            throw new IllegalArgumentException("Invalid age: " + age);
        }
        this.age = age;
    }
    
    // Email validation
    public void setEmail(String email) {
        if (!email.matches("^[A-Za-z0-9+_.-]+@(.+)$")) {
            throw new IllegalArgumentException("Invalid email");
        }
        this.email = email.toLowerCase();  // Normalize
    }
    
    // Read-only computed property
    public String getDisplayName() {
        return name + " (" + age + " years old)";
    }
    
    // Side effect - logging
    public void setName(String name) {
        System.out.println("Name changed from " + this.name + " to " + name);
        this.name = name;
    }
}
```

## 1.4 Interview Traps and Edge Cases

### Trap 1: Breaking Encapsulation with Mutable Objects

❌ **Bad:**
```java
public class Container {
    private List<String> items = new ArrayList<>();
    
    // Returns reference to internal list - BREAKS ENCAPSULATION!
    public List<String> getItems() {
        return items;  // External code can modify internal state!
    }
}

// Usage
Container c = new Container();
c.getItems().add("Hacked!");  // Directly modifying internal state!
```

✅ **Good:**
```java
public class Container {
    private List<String> items = new ArrayList<>();
    
    // Return defensive copy
    public List<String> getItems() {
        return new ArrayList<>(items);
    }
    
    // Or return unmodifiable view
    public List<String> getItemsReadOnly() {
        return Collections.unmodifiableList(items);
    }
    
    // Or provide controlled methods
    public void addItem(String item) {
        if (item != null && !item.isEmpty()) {
            items.add(item);
        }
    }
}
```

### Trap 2: Date/Calendar Mutability

❌ **Bad:**
```java
public class Event {
    private Date eventDate;
    
    public Date getEventDate() {
        return eventDate;  // Mutable Date can be changed!
    }
}

// Usage
Event event = new Event();
Date date = event.getEventDate();
date.setTime(0);  // Modifies internal state!
```

✅ **Good:**
```java
public class Event {
    private LocalDateTime eventDate;  // Immutable in Java 8+
    
    public LocalDateTime getEventDate() {
        return eventDate;  // Safe - LocalDateTime is immutable
    }
    
    // Or with old Date
    private Date eventDate;
    
    public Date getEventDate() {
        return new Date(eventDate.getTime());  // Return copy
    }
}
```

### Trap 3: Inheritance Breaking Encapsulation

```java
public class Parent {
    private int count = 0;
    
    public void increment() {
        count++;
    }
    
    public void incrementBy(int n) {
        for (int i = 0; i < n; i++) {
            increment();  // Calls overridden method!
        }
    }
}

public class Child extends Parent {
    private int callCount = 0;
    
    @Override
    public void increment() {
        callCount++;
        super.increment();
    }
    
    // Problem: incrementBy() calls overridden increment()
    // Leading to unexpected behavior
}
```

### Trap 4: Serialization Breaking Encapsulation

```java
public class SecureData implements Serializable {
    private String password;  // Will be serialized!
    
    // Use transient to prevent serialization
    private transient String password;
    
    // Or implement custom serialization
    private void writeObject(ObjectOutputStream oos) throws IOException {
        oos.defaultWriteObject();
        oos.writeObject(encrypt(password));
    }
    
    private void readObject(ObjectInputStream ois) 
            throws IOException, ClassNotFoundException {
        ois.defaultReadObject();
        password = decrypt((String) ois.readObject());
    }
}
```

## 1.5 Coding Problems with Solutions

### Problem 1: Immutable Class Implementation

**Question:** Design an immutable `Person` class with name, age, and addresses (List). Ensure complete immutability.

```java
public final class Person {  // final - cannot be extended
    private final String name;
    private final int age;
    private final List<String> addresses;
    
    public Person(String name, int age, List<String> addresses) {
        this.name = name;
        this.age = age;
        // Deep copy to prevent external modification
        this.addresses = new ArrayList<>(addresses);
    }
    
    public String getName() {
        return name;
    }
    
    public int getAge() {
        return age;
    }
    
    public List<String> getAddresses() {
        // Return unmodifiable view
        return Collections.unmodifiableList(addresses);
    }
    
    // If you need to "modify", create new instance
    public Person withName(String newName) {
        return new Person(newName, this.age, this.addresses);
    }
    
    public Person withAge(int newAge) {
        return new Person(this.name, newAge, this.addresses);
    }
}
```

### Problem 2: Thread-Safe Counter

**Question:** Implement a thread-safe counter with proper encapsulation.

```java
public class ThreadSafeCounter {
    private int count = 0;
    private final Object lock = new Object();
    
    public void increment() {
        synchronized (lock) {
            count++;
        }
    }
    
    public void decrement() {
        synchronized (lock) {
            count--;
        }
    }
    
    public int getCount() {
        synchronized (lock) {
            return count;
        }
    }
    
    // Atomic operations
    public int incrementAndGet() {
        synchronized (lock) {
            return ++count;
        }
    }
    
    public int getAndIncrement() {
        synchronized (lock) {
            return count++;
        }
    }
}

// Or use AtomicInteger
public class ThreadSafeCounter2 {
    private final AtomicInteger count = new AtomicInteger(0);
    
    public void increment() {
        count.incrementAndGet();
    }
    
    public int getCount() {
        return count.get();
    }
}
```

### Problem 3: Validated Email Field

**Question:** Create a class with email validation that ensures email is always valid.

```java
public class User {
    private String email;
    private static final Pattern EMAIL_PATTERN = 
        Pattern.compile("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");
    
    public User(String email) {
        setEmail(email);  // Validate in constructor
    }
    
    public String getEmail() {
        return email;
    }
    
    public void setEmail(String email) {
        if (email == null || email.trim().isEmpty()) {
            throw new IllegalArgumentException("Email cannot be null or empty");
        }
        
        String trimmed = email.trim().toLowerCase();
        
        if (!EMAIL_PATTERN.matcher(trimmed).matches()) {
            throw new IllegalArgumentException("Invalid email format: " + email);
        }
        
        if (trimmed.length() > 254) {  // RFC 5321
            throw new IllegalArgumentException("Email too long");
        }
        
        this.email = trimmed;
    }
}
```

---

# 2. INHERITANCE

## 2.1 Concept Explanation

**Inheritance** is a mechanism where a new class (child/subclass/derived class) inherits properties and behavior from an existing class (parent/superclass/base class). It enables code reusability and establishes an "IS-A" relationship.

**Types of Inheritance in Java:**
1. **Single Inheritance**: One class extends one class
2. **Multilevel Inheritance**: Chain of inheritance (A → B → C)
3. **Hierarchical Inheritance**: Multiple classes extend one class
4. **Multiple Inheritance**: ONE class extends MULTIPLE classes (NOT supported via classes, but via interfaces)
5. **Hybrid Inheritance**: Combination of above (NOT fully supported)

**Key Points:**
- Java supports single inheritance for classes
- Java supports multiple inheritance through interfaces
- Use `extends` keyword for class inheritance
- Use `implements` keyword for interface implementation
- Constructor chaining: Child constructor calls parent constructor
- `super` keyword: Access parent class members

## 2.2 Types of Inheritance Explained

### 2.2.1 Single Inheritance

```java
// Parent class
class Vehicle {
    protected String brand;
    protected int year;
    
    public Vehicle(String brand, int year) {
        this.brand = brand;
        this.year = year;
    }
    
    public void displayInfo() {
        System.out.println(brand + " " + year);
    }
}

// Child class extends one parent
class Car extends Vehicle {
    private int doors;
    
    public Car(String brand, int year, int doors) {
        super(brand, year);  // Call parent constructor
        this.doors = doors;
    }
    
    public void displayCarInfo() {
        displayInfo();  // Inherited method
        System.out.println("Doors: " + doors);
    }
}
```

### 2.2.2 Multilevel Inheritance

```java
// Level 1
class Animal {
    public void eat() {
        System.out.println("Animal eats");
    }
}

// Level 2
class Mammal extends Animal {
    public void breathe() {
        System.out.println("Mammal breathes");
    }
}

// Level 3
class Dog extends Mammal {
    public void bark() {
        System.out.println("Dog barks");
    }
}

// Usage
Dog dog = new Dog();
dog.eat();      // From Animal
dog.breathe();  // From Mammal
dog.bark();     // From Dog
```

### 2.2.3 Hierarchical Inheritance

```java
// One parent, multiple children
class Shape {
    protected String color;
    
    public void setColor(String color) {
        this.color = color;
    }
}

class Circle extends Shape {
    private double radius;
    
    public double area() {
        return Math.PI * radius * radius;
    }
}

class Rectangle extends Shape {
    private double length;
    private double width;
    
    public double area() {
        return length * width;
    }
}

class Triangle extends Shape {
    private double base;
    private double height;
    
    public double area() {
        return 0.5 * base * height;
    }
}
```

### 2.2.4 Multiple Inheritance (Through Interfaces)

```java
// Multiple interfaces
interface Flyable {
    void fly();
    default void takeOff() {
        System.out.println("Taking off...");
    }
}

interface Swimmable {
    void swim();
    default void dive() {
        System.out.println("Diving...");
    }
}

// Class implementing multiple interfaces
class Duck implements Flyable, Swimmable {
    @Override
    public void fly() {
        System.out.println("Duck flying");
    }
    
    @Override
    public void swim() {
        System.out.println("Duck swimming");
    }
}

// Diamond Problem Solution
interface A {
    default void show() {
        System.out.println("A");
    }
}

interface B extends A {
    default void show() {
        System.out.println("B");
    }
}

interface C extends A {
    default void show() {
        System.out.println("C");
    }
}

class D implements B, C {
    // Must override to resolve ambiguity
    @Override
    public void show() {
        B.super.show();  // Explicitly call B's implementation
        // Or C.super.show();
        // Or provide own implementation
    }
}
```

## 2.3 Real-World Examples

### Example 1: Employee Management System

```java
// Base class
public abstract class Employee {
    protected String employeeId;
    protected String name;
    protected String department;
    protected LocalDate joiningDate;
    
    public Employee(String employeeId, String name, String department) {
        this.employeeId = employeeId;
        this.name = name;
        this.department = department;
        this.joiningDate = LocalDate.now();
    }
    
    // Common method for all employees
    public void clockIn() {
        System.out.println(name + " clocked in at " + LocalTime.now());
    }
    
    public void clockOut() {
        System.out.println(name + " clocked out at " + LocalTime.now());
    }
    
    // Abstract method - each employee type calculates salary differently
    public abstract double calculateSalary();
    
    public abstract String getEmployeeType();
}

// Full-time employee
public class FullTimeEmployee extends Employee {
    private double annualSalary;
    private double bonus;
    
    public FullTimeEmployee(String id, String name, String dept, double salary) {
        super(id, name, dept);
        this.annualSalary = salary;
        this.bonus = 0;
    }
    
    @Override
    public double calculateSalary() {
        return (annualSalary / 12) + bonus;
    }
    
    @Override
    public String getEmployeeType() {
        return "Full-Time";
    }
    
    public void setBonus(double bonus) {
        this.bonus = bonus;
    }
}

// Part-time employee
public class PartTimeEmployee extends Employee {
    private double hourlyRate;
    private int hoursWorked;
    
    public PartTimeEmployee(String id, String name, String dept, double rate) {
        super(id, name, dept);
        this.hourlyRate = rate;
        this.hoursWorked = 0;
    }
    
    @Override
    public double calculateSalary() {
        return hourlyRate * hoursWorked;
    }
    
    @Override
    public String getEmployeeType() {
        return "Part-Time";
    }
    
    public void logHours(int hours) {
        this.hoursWorked += hours;
    }
}

// Contractor
public class Contractor extends Employee {
    private double projectFee;
    private int projectsCompleted;
    
    public Contractor(String id, String name, String dept, double fee) {
        super(id, name, dept);
        this.projectFee = fee;
        this.projectsCompleted = 0;
    }
    
    @Override
    public double calculateSalary() {
        return projectFee * projectsCompleted;
    }
    
    @Override
    public String getEmployeeType() {
        return "Contractor";
    }
    
    public void completeProject() {
        projectsCompleted++;
    }
}

// Manager extends FullTimeEmployee (multilevel)
public class Manager extends FullTimeEmployee {
    private List<Employee> team;
    private double teamBonus;
    
    public Manager(String id, String name, String dept, double salary) {
        super(id, name, dept, salary);
        this.team = new ArrayList<>();
    }
    
    @Override
    public double calculateSalary() {
        return super.calculateSalary() + teamBonus;
    }
    
    @Override
    public String getEmployeeType() {
        return "Manager";
    }
    
    public void addTeamMember(Employee employee) {
        team.add(employee);
    }
    
    public void distributeTeamBonus(double totalBonus) {
        double perPerson = totalBonus / team.size();
        for (Employee emp : team) {
            if (emp instanceof FullTimeEmployee) {
                ((FullTimeEmployee) emp).setBonus(perPerson);
            }
        }
    }
}
```

### Example 2: Payment Processing System

```java
// Base payment class
public abstract class Payment {
    protected String paymentId;
    protected double amount;
    protected LocalDateTime timestamp;
    protected PaymentStatus status;
    
    public Payment(double amount) {
        this.paymentId = UUID.randomUUID().toString();
        this.amount = amount;
        this.timestamp = LocalDateTime.now();
        this.status = PaymentStatus.PENDING;
    }
    
    // Template method pattern
    public final boolean processPayment() {
        if (!validateAmount()) {
            status = PaymentStatus.FAILED;
            return false;
        }
        
        if (!validatePaymentDetails()) {
            status = PaymentStatus.FAILED;
            return false;
        }
        
        boolean result = executePayment();
        
        if (result) {
            status = PaymentStatus.SUCCESS;
            sendConfirmation();
        } else {
            status = PaymentStatus.FAILED;
        }
        
        return result;
    }
    
    protected boolean validateAmount() {
        return amount > 0 && amount < 100000;
    }
    
    // Each payment type implements these
    protected abstract boolean validatePaymentDetails();
    protected abstract boolean executePayment();
    protected abstract void sendConfirmation();
    
    public PaymentStatus getStatus() {
        return status;
    }
}

enum PaymentStatus {
    PENDING, SUCCESS, FAILED, REFUNDED
}

// Credit card payment
public class CreditCardPayment extends Payment {
    private String cardNumber;
    private String cvv;
    private String expiryDate;
    
    public CreditCardPayment(double amount, String cardNumber, 
                             String cvv, String expiryDate) {
        super(amount);
        this.cardNumber = cardNumber;
        this.cvv = cvv;
        this.expiryDate = expiryDate;
    }
    
    @Override
    protected boolean validatePaymentDetails() {
        // Validate card number (Luhn algorithm)
        if (cardNumber.length() != 16) {
            return false;
        }
        // Validate CVV
        if (cvv.length() != 3) {
            return false;
        }
        // Validate expiry
        // ... validation logic
        return true;
    }
    
    @Override
    protected boolean executePayment() {
        // Call payment gateway API
        System.out.println("Processing credit card payment: " + amount);
        // Simulate API call
        return true;
    }
    
    @Override
    protected void sendConfirmation() {
        System.out.println("Credit card payment confirmation sent");
    }
}

// PayPal payment
public class PayPalPayment extends Payment {
    private String email;
    private String password;
    
    public PayPalPayment(double amount, String email, String password) {
        super(amount);
        this.email = email;
        this.password = password;
    }
    
    @Override
    protected boolean validatePaymentDetails() {
        return email.contains("@") && password.length() >= 8;
    }
    
    @Override
    protected boolean executePayment() {
        System.out.println("Processing PayPal payment: " + amount);
        return true;
    }
    
    @Override
    protected void sendConfirmation() {
        System.out.println("PayPal confirmation sent to: " + email);
    }
}

// UPI payment (India-specific)
public class UPIPayment extends Payment {
    private String upiId;
    private String pin;
    
    public UPIPayment(double amount, String upiId, String pin) {
        super(amount);
        this.upiId = upiId;
        this.pin = pin;
    }
    
    @Override
    protected boolean validatePaymentDetails() {
        return upiId.contains("@") && pin.length() == 4;
    }
    
    @Override
    protected boolean executePayment() {
        System.out.println("Processing UPI payment: " + amount);
        return true;
    }
    
    @Override
    protected void sendConfirmation() {
        System.out.println("UPI confirmation sent");
    }
}
```

## 2.4 Interview Questions and Answers

### Q1: Why doesn't Java support multiple inheritance through classes?

**Answer:**
Java doesn't support multiple inheritance through classes to avoid the **Diamond Problem**, which creates ambiguity.

**Diamond Problem Example:**
```java
// If this were allowed (it's not!)
class A {
    public void show() {
        System.out.println("A");
    }
}

class B extends A {
    public void show() {
        System.out.println("B");
    }
}

class C extends A {
    public void show() {
        System.out.println("C");
    }
}

// Which show() method should D inherit?
class D extends B, C {  // NOT ALLOWED IN JAVA
    // Ambiguity: Should it call B's show() or C's show()?
}
```

**Java's Solutions:**
1. **Interfaces**: Can implement multiple interfaces
2. **Default methods** (Java 8+): Must explicitly resolve conflicts
3. **Composition over Inheritance**: Use `has-a` instead of `is-a`

**With Interfaces:**
```java
interface B {
    default void show() {
        System.out.println("B");
    }
}

interface C {
    default void show() {
        System.out.println("C");
    }
}

class D implements B, C {
    @Override
    public void show() {
        B.super.show();  // Explicitly choose B's implementation
        // or C.super.show();
        // or provide own implementation
    }
}
```

### Q2: What is the difference between method overloading and overriding?

**Answer:**

| Method Overloading | Method Overriding |
|--------------------|-------------------|
| Same class | Parent-child classes |
| Same method name, different parameters | Same method signature |
| Compile-time (static) polymorphism | Runtime (dynamic) polymorphism |
| Return type can be different | Return type must be same or covariant |
| Access modifier can be any | Cannot be more restrictive |
| No @Override annotation | Should use @Override |
| Can overload static methods | Cannot override static methods |

**Example:**
```java
// Overloading
class Calculator {
    public int add(int a, int b) {
        return a + b;
    }
    
    public double add(double a, double b) {  // Overloaded - different params
        return a + b;
    }
    
    public int add(int a, int b, int c) {  // Overloaded - different param count
        return a + b + c;
    }
}

// Overriding
class Animal {
    public void sound() {
        System.out.println("Animal makes sound");
    }
}

class Dog extends Animal {
    @Override
    public void sound() {  // Overridden - same signature
        System.out.println("Dog barks");
    }
}
```

### Q3: Can you override a private or final method?

**Answer:**
**NO** to both, but for different reasons:

1. **Private methods**: Cannot be overridden because they're not inherited
```java
class Parent {
    private void display() {
        System.out.println("Parent");
    }
}

class Child extends Parent {
    // This is NOT overriding, it's a new method
    private void display() {
        System.out.println("Child");
    }
}
```

2. **Final methods**: Cannot be overridden to prevent modification
```java
class Parent {
    public final void display() {
        System.out.println("Parent");
    }
}

class Child extends Parent {
    // Compile error: Cannot override final method
    // public void display() {
    //     System.out.println("Child");
    // }
}
```

3. **Final classes**: Cannot be extended
```java
public final class String {  // Cannot be extended
    // ...
}

// This won't compile
// class MyString extends String {
// }
```

### Q4: What is constructor chaining in inheritance?

**Answer:**
Constructor chaining is the process where child class constructor automatically calls parent class constructor.

**Rules:**
1. First statement in child constructor must be `super()` or `this()`
2. If not explicitly called, compiler adds `super()` (no-arg constructor)
3. Parent constructor executes before child constructor
4. Chain continues to topmost parent (Object class)

**Example:**
```java
class GrandParent {
    public GrandParent() {
        System.out.println("1. GrandParent constructor");
    }
}

class Parent extends GrandParent {
    public Parent() {
        super();  // Call GrandParent constructor (implicit)
        System.out.println("2. Parent constructor");
    }
    
    public Parent(String name) {
        this();  // Call Parent() first
        System.out.println("3. Parent parameterized constructor");
    }
}

class Child extends Parent {
    public Child() {
        super("Test");  // Call Parent(String)
        System.out.println("4. Child constructor");
    }
}

// Output when creating Child:
// 1. GrandParent constructor
// 2. Parent constructor
// 3. Parent parameterized constructor
// 4. Child constructor
```

**Common Error:**
```java
class Parent {
    private String name;
    
    // No no-arg constructor!
    public Parent(String name) {
        this.name = name;
    }
}

class Child extends Parent {
    public Child() {
        // Compile error: no default constructor in Parent
        // Must explicitly call super(name)
    }
    
    public Child(String name) {
        super(name);  // Correct
    }
}
```

### Q5: What is covariant return type in Java?

**Answer:**
Covariant return type allows overriding method to return a subtype of the return type declared in parent method (since Java 5).

**Example:**
```java
class Animal {
    public Animal reproduce() {
        return new Animal();
    }
}

class Dog extends Animal {
    @Override
    public Dog reproduce() {  // Covariant return - Dog is subtype of Animal
        return new Dog();
    }
}

class Cat extends Animal {
    @Override
    public Cat reproduce() {  // Covariant return
        return new Cat();
    }
}

// Usage
Animal animal = new Dog();
Animal offspring = animal.reproduce();  // Returns Dog, assigned to Animal

Dog dog = new Dog();
Dog puppy = dog.reproduce();  // Returns Dog, no casting needed
```

**Benefits:**
- Type safety
- No casting required
- More specific return types

**Rules:**
- Return type must be subtype of parent's return type
- Cannot widen the return type
- Primitive types cannot use covariant returns (int → long not allowed)

### Q6: Can you override static methods?

**Answer:**
**NO**, static methods cannot be overridden. They can be **hidden** but not overridden because static methods are bound to class, not object.

```java
class Parent {
    public static void display() {
        System.out.println("Parent static method");
    }
    
    public void show() {
        System.out.println("Parent instance method");
    }
}

class Child extends Parent {
    // This HIDES parent static method, not overrides
    public static void display() {
        System.out.println("Child static method");
    }
    
    @Override
    public void show() {
        System.out.println("Child instance method");
    }
}

// Usage
Parent p1 = new Parent();
Parent p2 = new Child();
Child c = new Child();

// Static methods - called on class/reference type
p1.display();  // Parent static method
p2.display();  // Parent static method (reference type is Parent!)
c.display();   // Child static method

// Instance methods - called on object type
p1.show();  // Parent instance method
p2.show();  // Child instance method (runtime polymorphism)
c.show();   // Child instance method
```

**Key Difference:**
- **Overriding**: Runtime polymorphism (depends on object type)
- **Hiding**: Compile-time binding (depends on reference type)

## 2.5 Interview Traps and Edge Cases

### Trap 1: Constructor Calling Overridden Methods

❌ **Dangerous:**
```java
class Parent {
    public Parent() {
        init();  // Calls overridden method!
    }
    
    public void init() {
        System.out.println("Parent init");
    }
}

class Child extends Parent {
    private String name = "John";
    
    @Override
    public void init() {
        System.out.println("Child init: " + name);  // name is null here!
    }
}

// Usage
Child child = new Child();
// Output: Child init: null   (name not initialized yet!)
```

**Why?** Constructor execution order:
1. Parent constructor starts
2. Calls `init()` → goes to Child's overridden version
3. But Child's instance variables not initialized yet!
4. `name` is null

✅ **Solution:** Don't call overridable methods in constructors

```java
class Parent {
    public Parent() {
        // Don't call overridable methods
        parentInit();
    }
    
    private void parentInit() {  // final or private
        System.out.println("Parent init");
    }
}
```

### Trap 2: Access Modifier in Overriding

❌ **Compile Error:**
```java
class Parent {
    public void display() {
        System.out.println("Parent");
    }
}

class Child extends Parent {
    // Compile error: Cannot reduce visibility!
    protected void display() {  // More restrictive than public
        System.out.println("Child");
    }
}
```

✅ **Rules:**
```java
class Parent {
    protected void display() {
        System.out.println("Parent");
    }
}

class Child extends Parent {
    // OK: Same or less restrictive
    public void display() {  // public is less restrictive than protected
        System.out.println("Child");
    }
}
```

**Hierarchy:** private < default < protected < public

### Trap 3: Exception Handling in Overriding

❌ **Compile Error:**
```java
class Parent {
    public void process() throws IOException {
        // ...
    }
}

class Child extends Parent {
    // Compile error: Cannot throw broader exception!
    @Override
    public void process() throws Exception {  // Broader than IOException
        // ...
    }
}
```

✅ **Rules:**
```java
class Parent {
    public void process() throws IOException {
        // ...
    }
}

class Child extends Parent {
    // OK: Same or narrower exception
    @Override
    public void process() throws FileNotFoundException {  // Subclass of IOException
        // ...
    }
    
    // OK: No exception
    @Override
    public void process() {  // Not throwing exception is fine
        // ...
    }
    
    // OK: Unchecked exception
    @Override
    public void process() throws RuntimeException {  // Unchecked exceptions allowed
        // ...
    }
}
```

### Trap 4: Field Hiding

```java
class Parent {
    public String name = "Parent";
    
    public void display() {
        System.out.println("Name: " + name);
    }
}

class Child extends Parent {
    public String name = "Child";  // Hides parent field
    
    @Override
    public void display() {
        System.out.println("Child name: " + name);
        System.out.println("Parent name: " + super.name);
    }
}

// Usage
Parent p = new Child();
System.out.println(p.name);  // Prints "Parent" (reference type!)
p.display();  // Prints "Child" (object type)

Child c = new Child();
System.out.println(c.name);  // Prints "Child"
```

**Key Point:** Fields are not overridden, they are hidden. Field access depends on reference type, not object type.

## 2.6 Coding Problems with Solutions

### Problem 1: Design Shape Hierarchy

**Question:** Design a shape hierarchy with area and perimeter calculation. Support Circle, Rectangle, and Triangle.

```java
// Base class
public abstract class Shape {
    protected String color;
    protected boolean filled;
    
    public Shape(String color, boolean filled) {
        this.color = color;
        this.filled = filled;
    }
    
    public abstract double getArea();
    public abstract double getPerimeter();
    
    public String getColor() {
        return color;
    }
    
    public void setColor(String color) {
        this.color = color;
    }
    
    public boolean isFilled() {
        return filled;
    }
    
    public void setFilled(boolean filled) {
        this.filled = filled;
    }
    
    @Override
    public String toString() {
        return String.format("Shape[color=%s, filled=%s]", color, filled);
    }
}

// Circle
public class Circle extends Shape {
    private double radius;
    
    public Circle(double radius, String color, boolean filled) {
        super(color, filled);
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
    
    public double getRadius() {
        return radius;
    }
    
    @Override
    public String toString() {
        return String.format("Circle[radius=%.2f, %s, area=%.2f, perimeter=%.2f]",
                radius, super.toString(), getArea(), getPerimeter());
    }
}

// Rectangle
public class Rectangle extends Shape {
    private double length;
    private double width;
    
    public Rectangle(double length, double width, String color, boolean filled) {
        super(color, filled);
        this.length = length;
        this.width = width;
    }
    
    @Override
    public double getArea() {
        return length * width;
    }
    
    @Override
    public double getPerimeter() {
        return 2 * (length + width);
    }
    
    @Override
    public String toString() {
        return String.format("Rectangle[length=%.2f, width=%.2f, %s, area=%.2f, perimeter=%.2f]",
                length, width, super.toString(), getArea(), getPerimeter());
    }
}

// Square (special case of Rectangle)
public class Square extends Rectangle {
    public Square(double side, String color, boolean filled) {
        super(side, side, color, filled);
    }
    
    public double getSide() {
        return super.length;  // length == width for square
    }
    
    public void setSide(double side) {
        super.length = side;
        super.width = side;
    }
    
    @Override
    public String toString() {
        return String.format("Square[side=%.2f, %s, area=%.2f, perimeter=%.2f]",
                getSide(), super.toString(), getArea(), getPerimeter());
    }
}

// Triangle
public class Triangle extends Shape {
    private double side1;
    private double side2;
    private double side3;
    
    public Triangle(double side1, double side2, double side3, String color, boolean filled) {
        super(color, filled);
        if (!isValidTriangle(side1, side2, side3)) {
            throw new IllegalArgumentException("Invalid triangle sides");
        }
        this.side1 = side1;
        this.side2 = side2;
        this.side3 = side3;
    }
    
    private boolean isValidTriangle(double a, double b, double c) {
        return (a + b > c) && (b + c > a) && (c + a > b);
    }
    
    @Override
    public double getArea() {
        // Heron's formula
        double s = getPerimeter() / 2;
        return Math.sqrt(s * (s - side1) * (s - side2) * (s - side3));
    }
    
    @Override
    public double getPerimeter() {
        return side1 + side2 + side3;
    }
    
    @Override
    public String toString() {
        return String.format("Triangle[sides=(%.2f, %.2f, %.2f), %s, area=%.2f, perimeter=%.2f]",
                side1, side2, side3, super.toString(), getArea(), getPerimeter());
    }
}

// Usage
public class ShapeTest {
    public static void main(String[] args) {
        Shape[] shapes = {
            new Circle(5.0, "Red", true),
            new Rectangle(4.0, 6.0, "Blue", false),
            new Square(5.0, "Green", true),
            new Triangle(3.0, 4.0, 5.0, "Yellow", true)
        };
        
        for (Shape shape : shapes) {
            System.out.println(shape);
        }
        
        // Calculate total area
        double totalArea = 0;
        for (Shape shape : shapes) {
            totalArea += shape.getArea();
        }
        System.out.printf("Total area: %.2f%n", totalArea);
    }
}
```

### Problem 2: Vehicle Rental System

**Question:** Design a vehicle rental system with different pricing for different vehicle types.

```java
// Base class
public abstract class Vehicle {
    protected String vehicleId;
    protected String brand;
    protected String model;
    protected int year;
    protected double basePricePerDay;
    protected boolean isAvailable;
    
    public Vehicle(String vehicleId, String brand, String model, int year, double basePricePerDay) {
        this.vehicleId = vehicleId;
        this.brand = brand;
        this.model = model;
        this.year = year;
        this.basePricePerDay = basePricePerDay;
        this.isAvailable = true;
    }
    
    public abstract double calculateRentalCost(int days);
    public abstract String getVehicleType();
    
    public void rent() {
        if (!isAvailable) {
            throw new IllegalStateException("Vehicle not available");
        }
        isAvailable = false;
    }
    
    public void returnVehicle() {
        isAvailable = true;
    }
    
    public boolean isAvailable() {
        return isAvailable;
    }
    
    public String getVehicleId() {
        return vehicleId;
    }
    
    @Override
    public String toString() {
        return String.format("%s - %s %s %d [%s]",
                vehicleId, brand, model, year, isAvailable ? "Available" : "Rented");
    }
}

// Car
public class Car extends Vehicle {
    private int seats;
    private boolean hasAC;
    
    public Car(String vehicleId, String brand, String model, int year,
               double basePricePerDay, int seats, boolean hasAC) {
        super(vehicleId, brand, model, year, basePricePerDay);
        this.seats = seats;
        this.hasAC = hasAC;
    }
    
    @Override
    public double calculateRentalCost(int days) {
        double cost = basePricePerDay * days;
        
        // Extra charges
        if (hasAC) {
            cost += 10 * days;  // $10/day for AC
        }
        
        // Discount for long-term rental
        if (days >= 7) {
            cost *= 0.9;  // 10% discount for weekly rental
        } else if (days >= 30) {
            cost *= 0.75;  // 25% discount for monthly rental
        }
        
        return cost;
    }
    
    @Override
    public String getVehicleType() {
        return "Car";
    }
    
    @Override
    public String toString() {
        return String.format("Car[%s, %d seats, AC: %s] - $%.2f/day",
                super.toString(), seats, hasAC ? "Yes" : "No", basePricePerDay);
    }
}

// Bike
public class Bike extends Vehicle {
    private int engineCapacity;  // in cc
    
    public Bike(String vehicleId, String brand, String model, int year,
                double basePricePerDay, int engineCapacity) {
        super(vehicleId, brand, model, year, basePricePerDay);
        this.engineCapacity = engineCapacity;
    }
    
    @Override
    public double calculateRentalCost(int days) {
        double cost = basePricePerDay * days;
        
        // Higher engine = higher cost
        if (engineCapacity > 500) {
            cost += 5 * days;
        }
        
        return cost;
    }
    
    @Override
    public String getVehicleType() {
        return "Bike";
    }
    
    @Override
    public String toString() {
        return String.format("Bike[%s, %dcc] - $%.2f/day",
                super.toString(), engineCapacity, basePricePerDay);
    }
}

// Truck
public class Truck extends Vehicle {
    private double loadCapacity;  // in tons
    
    public Truck(String vehicleId, String brand, String model, int year,
                 double basePricePerDay, double loadCapacity) {
        super(vehicleId, brand, model, year, basePricePerDay);
        this.loadCapacity = loadCapacity;
    }
    
    @Override
    public double calculateRentalCost(int days) {
        double cost = basePricePerDay * days;
        
        // Extra charge based on load capacity
        cost += loadCapacity * 20 * days;  // $20 per ton per day
        
        return cost;
    }
    
    @Override
    public String getVehicleType() {
        return "Truck";
    }
    
    @Override
    public String toString() {
        return String.format("Truck[%s, %.1f tons] - $%.2f/day",
                super.toString(), loadCapacity, basePricePerDay);
    }
}

// Rental Management
public class RentalService {
    private List<Vehicle> vehicles = new ArrayList<>();
    private Map<String, Rental> activeRentals = new HashMap<>();
    
    public void addVehicle(Vehicle vehicle) {
        vehicles.add(vehicle);
    }
    
    public List<Vehicle> getAvailableVehicles(String type) {
        return vehicles.stream()
                .filter(Vehicle::isAvailable)
                .filter(v -> type == null || v.getVehicleType().equalsIgnoreCase(type))
                .collect(Collectors.toList());
    }
    
    public Rental rentVehicle(String vehicleId, String customerId, int days) {
        Vehicle vehicle = findVehicleById(vehicleId);
        
        if (vehicle == null) {
            throw new IllegalArgumentException("Vehicle not found");
        }
        
        if (!vehicle.isAvailable()) {
            throw new IllegalStateException("Vehicle not available");
        }
        
        double cost = vehicle.calculateRentalCost(days);
        vehicle.rent();
        
        Rental rental = new Rental(vehicle, customerId, days, cost);
        activeRentals.put(vehicleId, rental);
        
        return rental;
    }
    
    public void returnVehicle(String vehicleId) {
        Rental rental = activeRentals.get(vehicleId);
        if (rental == null) {
            throw new IllegalArgumentException("No active rental for this vehicle");
        }
        
        rental.getVehicle().returnVehicle();
        rental.complete();
        activeRentals.remove(vehicleId);
    }
    
    private Vehicle findVehicleById(String vehicleId) {
        return vehicles.stream()
                .filter(v -> v.getVehicleId().equals(vehicleId))
                .findFirst()
                .orElse(null);
    }
}

class Rental {
    private Vehicle vehicle;
    private String customerId;
    private int days;
    private double cost;
    private LocalDateTime startDate;
    private LocalDateTime endDate;
    
    public Rental(Vehicle vehicle, String customerId, int days, double cost) {
        this.vehicle = vehicle;
        this.customerId = customerId;
        this.days = days;
        this.cost = cost;
        this.startDate = LocalDateTime.now();
    }
    
    public void complete() {
        this.endDate = LocalDateTime.now();
    }
    
    public Vehicle getVehicle() {
        return vehicle;
    }
    
    @Override
    public String toString() {
        return String.format("Rental[%s, Customer: %s, Days: %d, Cost: $%.2f]",
                vehicle.getVehicleId(), customerId, days, cost);
    }
}
```

---

# 3. POLYMORPHISM

## 3.1 Concept Explanation

**Polymorphism** means "many forms". It's the ability of an object to take multiple forms. In Java, polymorphism allows one interface to be used for a general class of actions.

**Types of Polymorphism:**
1. **Compile-time Polymorphism** (Static Binding / Early Binding)
   - Method Overloading
   - Operator Overloading (not in Java)
   
2. **Runtime Polymorphism** (Dynamic Binding / Late Binding)
   - Method Overriding
   - Interface implementation

**Key Points:**
- Reference type determines which methods CAN be called
- Object type determines which method implementation IS called
- Achieved through inheritance and interfaces
- Enables writing more flexible and maintainable code

## 3.2 Runtime Polymorphism Examples

### Example 1: Payment Processing

```java
// Base class
public abstract class Payment {
    protected double amount;
    protected String transactionId;
    
    public Payment(double amount) {
        this.amount = amount;
        this.transactionId = UUID.randomUUID().toString();
    }
    
    // Abstract method - implemented by subclasses
    public abstract boolean process();
    public abstract String getPaymentMethod();
    
    public double getAmount() {
        return amount;
    }
    
    public String getTransactionId() {
        return transactionId;
    }
}

class CreditCardPayment extends Payment {
    private String cardNumber;
    
    public CreditCardPayment(double amount, String cardNumber) {
        super(amount);
        this.cardNumber = cardNumber;
    }
    
    @Override
    public boolean process() {
        System.out.println("Processing credit card payment: $" + amount);
        // Credit card processing logic
        return true;
    }
    
    @Override
    public String getPaymentMethod() {
        return "Credit Card ending with " + cardNumber.substring(cardNumber.length() - 4);
    }
}

class PayPalPayment extends Payment {
    private String email;
    
    public PayPalPayment(double amount, String email) {
        super(amount);
        this.email = email;
    }
    
    @Override
    public boolean process() {
        System.out.println("Processing PayPal payment: $" + amount);
        // PayPal processing logic
        return true;
    }
    
    @Override
    public String getPaymentMethod() {
        return "PayPal account: " + email;
    }
}

class CryptoPayment extends Payment {
    private String walletAddress;
    
    public CryptoPayment(double amount, String walletAddress) {
        super(amount);
        this.walletAddress = walletAddress;
    }
    
    @Override
    public boolean process() {
        System.out.println("Processing cryptocurrency payment: $" + amount);
        // Crypto processing logic
        return true;
    }
    
    @Override
    public String getPaymentMethod() {
        return "Crypto wallet: " + walletAddress;
    }
}

// Polymorphic usage
public class PaymentProcessor {
    public void processPayments(List<Payment> payments) {
        for (Payment payment : payments) {
            // payment can be CreditCard, PayPal, or Crypto
            // Correct method called based on actual object type
            System.out.println("Processing via " + payment.getPaymentMethod());
            boolean success = payment.process();  // Polymorphic call
            
            if (success) {
                System.out.println("Payment successful: " + payment.getTransactionId());
            } else {
                System.out.println("Payment failed!");
            }
        }
    }
    
    public static void main(String[] args) {
        List<Payment> payments = Arrays.asList(
            new CreditCardPayment(100.50, "1234567890123456"),
            new PayPalPayment(75.25, "user@email.com"),
            new CryptoPayment(200.00, "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb7")
        );
        
        PaymentProcessor processor = new PaymentProcessor();
        processor.processPayments(payments);  // Polymorphism in action
    }
}
```

### Example 2: Notification System

```java
public interface Notification {
    void send(String message, String recipient);
    boolean isDelivered();
    String getDeliveryStatus();
}

class EmailNotification implements Notification {
    private boolean delivered = false;
    
    @Override
    public void send(String message, String recipient) {
        System.out.println("Sending email to: " + recipient);
        System.out.println("Message: " + message);
        // Email sending logic
        delivered = true;
    }
    
    @Override
    public boolean isDelivered() {
        return delivered;
    }
    
    @Override
    public String getDeliveryStatus() {
        return "Email " + (delivered ? "delivered" : "pending");
    }
}

class SMSNotification implements Notification {
    private boolean delivered = false;
    
    @Override
    public void send(String message, String recipient) {
        System.out.println("Sending SMS to: " + recipient);
        System.out.println("Message: " + message);
        // SMS sending logic
        delivered = true;
    }
    
    @Override
    public boolean isDelivered() {
        return delivered;
    }
    
    @Override
    public String getDeliveryStatus() {
        return "SMS " + (delivered ? "delivered" : "pending");
    }
}

class PushNotification implements Notification {
    private boolean delivered = false;
    
    @Override
    public void send(String message, String recipient) {
        System.out.println("Sending push notification to device: " + recipient);
        System.out.println("Message: " + message);
        // Push notification logic
        delivered = true;
    }
    
    @Override
    public boolean isDelivered() {
        return delivered;
    }
    
    @Override
    public String getDeliveryStatus() {
        return "Push notification " + (delivered ? "delivered" : "pending");
    }
}

// Notification service using polymorphism
public class NotificationService {
    public void sendNotifications(List<Notification> notifications, String message) {
        for (Notification notification : notifications) {
            notification.send(message, "user");  // Polymorphic call
            System.out.println(notification.getDeliveryStatus());
            System.out.println("---");
        }
    }
    
    // Factory method
    public static Notification createNotification(String type) {
        switch (type.toLowerCase()) {
            case "email":
                return new EmailNotification();
            case "sms":
                return new SMSNotification();
            case "push":
                return new PushNotification();
            default:
                throw new IllegalArgumentException("Unknown notification type");
        }
    }
    
    public static void main(String[] args) {
        List<Notification> notifications = Arrays.asList(
            createNotification("email"),
            createNotification("sms"),
            createNotification("push")
        );
        
        NotificationService service = new NotificationService();
        service.sendNotifications(notifications, "Your order has been shipped!");
    }
}
```

## 3.3 Interview Questions and Answers

### Q1: What is polymorphism? Explain with real-world example.

**Answer:**
Polymorphism means "many forms". It's the ability of different objects to respond to the same method call in their own way.

**Real-world analogy:** A remote control (interface) can operate different devices (TV, AC, Fan). Pressing "power" button does different things for each device, but the interface remains the same.

**Code example:**
```java
abstract class Animal {
    abstract void makeSound();
}

class Dog extends Animal {
    @Override
    void makeSound() {
        System.out.println("Bark!");
    }
}

class Cat extends Animal {
    @Override
    void makeSound() {
        System.out.println("Meow!");
    }
}

// Polymorphism
Animal animal1 = new Dog();
Animal animal2 = new Cat();

animal1.makeSound();  // Bark!
animal2.makeSound();  // Meow!  - Same method call, different behavior
```

### Q2: Difference between compile-time and runtime polymorphism?

**Answer:**

| Compile-time Polymorphism | Runtime Polymorphism |
|---------------------------|----------------------|
| **Method Overloading** | **Method Overriding** |
| Resolved at compile time | Resolved at runtime |
| Same class | Parent-child classes |
| Static binding | Dynamic binding |
| Faster (no runtime overhead) | Slower (requires method lookup) |
| Based on method signature | Based on object type |

**Examples:**
```java
// Compile-time polymorphism (Overloading)
class Calculator {
    int add(int a, int b) {  // Method 1
        return a + b;
    }
    
    double add(double a, double b) {  // Method 2
        return a + b;
    }
}

Calculator calc = new Calculator();
calc.add(5, 10);      // Calls Method 1 - decided at compile time
calc.add(5.5, 10.5);  // Calls Method 2 - decided at compile time

// Runtime polymorphism (Overriding)
class Parent {
    void display() {
        System.out.println("Parent");
    }
}

class Child extends Parent {
    @Override
    void display() {
        System.out.println("Child");
    }
}

Parent obj = new Child();
obj.display();  // Prints "Child" - decided at runtime based on object type
```

### Q3: What is dynamic method dispatch?

**Answer:**
Dynamic method dispatch is the mechanism by which a call to an overridden method is resolved at runtime rather than compile time. It's the implementation of runtime polymorphism.

**How it works:**
1. Reference type determines which methods CAN be called
2. Object type determines which implementation IS executed
3. JVM looks up the actual object type at runtime
4. Calls the appropriate overridden method

**Example:**
```java
class Animal {
    void eat() {
        System.out.println("Animal eating");
    }
    
    void sleep() {
        System.out.println("Animal sleeping");
    }
}

class Dog extends Animal {
    @Override
    void eat() {
        System.out.println("Dog eating");
    }
    
    void bark() {
        System.out.println("Dog barking");
    }
}

// Dynamic method dispatch
Animal animal = new Dog();  // Reference: Animal, Object: Dog

animal.eat();    // Prints "Dog eating" - calls Dog's version (runtime resolution)
animal.sleep();  // Prints "Animal sleeping" - Dog doesn't override, so Animal's version

// animal.bark();  // Compile error - bark() not in Animal reference type

// To call bark(), need to cast
((Dog) animal).bark();  // or Dog dog = (Dog) animal;
```

**Under the hood:**
```
1. Compiler checks: Does Animal have eat()? Yes → Allowed
2. Runtime: What's the actual object? Dog
3. JVM: Does Dog override eat()? Yes → Call Dog's eat()
```

### Q4: Can you achieve polymorphism without inheritance?

**Answer:**
Yes, through **interfaces**. Polymorphism doesn't require inheritance with `extends`, it requires a common contract.

**Example:**
```java
// Interface - no inheritance involved
interface Drawable {
    void draw();
}

class Circle implements Drawable {
    @Override
    public void draw() {
        System.out.println("Drawing circle");
    }
}

class Rectangle implements Drawable {
    @Override
    public void draw() {
        System.out.println("Drawing rectangle");
    }
}

// Polymorphism without inheritance
public class DrawingApp {
    public void renderShapes(List<Drawable> shapes) {
        for (Drawable shape : shapes) {
            shape.draw();  // Polymorphic behavior
        }
    }
    
    public static void main(String[] args) {
        List<Drawable> shapes = Arrays.asList(
            new Circle(),
            new Rectangle()
        );
        
        DrawingApp app = new DrawingApp();
        app.renderShapes(shapes);  // Polymorphism via interface
    }
}
```

### Q5: What happens when you cast objects in polymorphism?

**Answer:**
Casting changes the reference type but NOT the object type.

**Types of casting:**
1. **Upcasting** (implicit): Child → Parent
2. **Downcasting** (explicit): Parent → Child

**Example:**
```java
class Animal {
    void eat() {
        System.out.println("Animal eating");
    }
}

class Dog extends Animal {
    @Override
    void eat() {
        System.out.println("Dog eating");
    }
    
    void bark() {
        System.out.println("Dog barking");
    }
}

// Upcasting (implicit)
Dog dog = new Dog();
Animal animal = dog;  // Upcasting - OK, automatic
animal.eat();  // Prints "Dog eating" - object type is still Dog

// Downcasting (explicit)
Animal animal2 = new Dog();
Dog dog2 = (Dog) animal2;  // Downcasting - needs explicit cast
dog2.bark();  // OK now

// ClassCastException
Animal animal3 = new Animal();
Dog dog3 = (Dog) animal3;  // RuntimeException: Animal cannot be cast to Dog!

// Safe downcasting with instanceof
if (animal3 instanceof Dog) {
    Dog dog4 = (Dog) animal3;
    dog4.bark();
} else {
    System.out.println("Not a Dog!");
}

// Pattern matching (Java 16+)
if (animal3 instanceof Dog dog5) {
    dog5.bark();  // dog5 is automatically cast
}
```

**Key Points:**
- Upcasting is always safe
- Downcasting requires runtime check
- Use `instanceof` before downcasting
- `ClassCastException` thrown if invalid downcast

## 3.4 Interview Traps and Edge Cases

### Trap 1: Method Hiding vs Method Overriding

```java
class Parent {
    // Instance method
    public void display() {
        System.out.println("Parent display");
    }
    
    // Static method
    public static void show() {
        System.out.println("Parent show");
    }
}

class Child extends Parent {
    // Overriding instance method
    @Override
    public void display() {
        System.out.println("Child display");
    }
    
    // Hiding static method (NOT overriding!)
    public static void show() {
        System.out.println("Child show");
    }
}

// Usage
Parent p = new Child();

p.display();  // Prints "Child display" - Overriding (runtime polymorphism)
p.show();     // Prints "Parent show" - Hiding (compile-time binding)

Child c = new Child();
c.show();     // Prints "Child show"
```

**Key Point:** Static methods are bound to class, not object. No runtime polymorphism for static methods.

### Trap 2: Private Method "Overriding"

```java
class Parent {
    private void display() {
        System.out.println("Parent private display");
    }
    
    public void callDisplay() {
        display();  // Calls Parent's private display
    }
}

class Child extends Parent {
    // This is NOT overriding! It's a new method.
    public void display() {
        System.out.println("Child display");
    }
}

// Usage
Parent p = new Child();
p.callDisplay();  // Prints "Parent private display"
// Private methods are not inherited, so cannot be overridden!

Child c = new Child();
c.display();  // Prints "Child display"
```

### Trap 3: Variable Hiding

```java
class Parent {
    String name = "Parent";
    
    void display() {
        System.out.println("Name in method: " + name);
    }
}

class Child extends Parent {
    String name = "Child";  // Hides parent's variable
    
    @Override
    void display() {
        System.out.println("Child name: " + name);
        System.out.println("Parent name: " + super.name);
    }
}

// Usage
Parent p = new Child();
System.out.println(p.name);  // Prints "Parent" - variables not polymorphic!
p.display();  // Prints "Child name: Child" - methods are polymorphic

Child c = new Child();
System.out.println(c.name);  // Prints "Child"
```

**Key Point:** Variables are not polymorphic! Variable access depends on reference type, not object type.

### Trap 4: Constructor Calls and Polymorphism

```java
class Parent {
    public Parent() {
        System.out.println("Parent constructor");
        initialize();  // Polymorphic call from constructor - DANGEROUS!
    }
    
    public void initialize() {
        System.out.println("Parent initialize");
    }
}

class Child extends Parent {
    private String name = "John";
   
    public Child() {
        System.out.println("Child constructor");
    }
    
    @Override
    public void initialize() {
        System.out.println("Child initialize: " + name);  // name is null here!
    }
}

// Usage
Child child = new Child();
/* Output:
Parent constructor
Child initialize: null   (name not initialized yet!)
Child constructor
*/
```

**Reason:** 
1. Parent constructor runs first
2. Calls `initialize()` → goes to Child's overridden version
3. But Child's instance variables not initialized yet!

✅ **Solution:** Don't call overridable methods from constructors

## 3.5 Coding Problems with Solutions

### Problem 1: Database Connection Factory

**Question:** Implement a database connection system that supports MySQL, PostgreSQL, and MongoDB using polymorphism.

```java
// Base interface
public interface DatabaseConnection {
    void connect(String host, int port, String database);
    void disconnect();
    void executeQuery(String query);
    boolean isConnected();
    String getConnectionInfo();
}

// MySQL implementation
public class MySQLConnection implements DatabaseConnection {
    private String host;
    private int port;
    private String database;
    private boolean connected = false;
    
    @Override
    public void connect(String host, int port, String database) {
        this.host = host;
        this.port = port;
        this.database = database;
        System.out.println("Connecting to MySQL: " + getConnectionString());
        // Actual MySQL connection logic
        connected = true;
    }
    
    @Override
    public void disconnect() {
        System.out.println("Disconnecting from MySQL");
        connected = false;
    }
    
    @Override
    public void executeQuery(String query) {
        if (!connected) {
            throw new IllegalStateException("Not connected");
        }
        System.out.println("Executing MySQL query: " + query);
        // Execute SQL query
    }
    
    @Override
    public boolean isConnected() {
        return connected;
    }
    
    @Override
    public String getConnectionInfo() {
        return "MySQL @ " + getConnectionString();
    }
    
    private String getConnectionString() {
        return String.format("%s:%d/%s", host, port, database);
    }
}

// PostgreSQL implementation
public class PostgresConnection implements DatabaseConnection {
    private String host;
    private int port;
    private String database;
    private boolean connected = false;
    
    @Override
    public void connect(String host, int port, String database) {
        this.host = host;
        this.port = port;
        this.database = database;
        System.out.println("Connecting to PostgreSQL: " + getConnectionString());
        connected = true;
    }
    
    @Override
    public void disconnect() {
        System.out.println("Disconnecting from PostgreSQL");
        connected = false;
    }
    
    @Override
    public void executeQuery(String query) {
        if (!connected) {
            throw new IllegalStateException("Not connected");
        }
        System.out.println("Executing PostgreSQL query: " + query);
    }
    
    @Override
    public boolean isConnected() {
        return connected;
    }
    
    @Override
    public String getConnectionInfo() {
        return "PostgreSQL @ " + getConnectionString();
    }
    
    private String getConnectionString() {
        return String.format("%s:%d/%s", host, port, database);
    }
}

// MongoDB implementation (different query syntax)
public class MongoDBConnection implements DatabaseConnection {
    private String host;
    private int port;
    private String database;
    private boolean connected = false;
    
    @Override
    public void connect(String host, int port, String database) {
        this.host = host;
        this.port = port;
        this.database = database;
        System.out.println("Connecting to MongoDB: " + getConnectionString());
        connected = true;
    }
    
    @Override
    public void disconnect() {
        System.out.println("Disconnecting from MongoDB");
        connected = false;
    }
    
    @Override
    public void executeQuery(String query) {
        if (!connected) {
            throw new IllegalStateException("Not connected");
        }
        System.out.println("Executing MongoDB query: " + query);
        // MongoDB has different query format (JSON-like)
    }
    
    @Override
    public boolean isConnected() {
        return connected;
    }
    
    @Override
    public String getConnectionInfo() {
        return "MongoDB @ " + getConnectionString();
    }
    
    private String getConnectionString() {
        return String.format("%s:%d/%s", host, port, database);
    }
}

// Factory pattern
public class DatabaseConnectionFactory {
    public static DatabaseConnection createConnection(String type) {
        switch (type.toUpperCase()) {
            case "MYSQL":
                return new MySQLConnection();
            case "POSTGRESQL":
            case "POSTGRES":
                return new PostgresConnection();
            case "MONGODB":
            case "MONGO":
                return new MongoDBConnection();
            default:
                throw new IllegalArgumentException("Unknown database type: " + type);
        }
    }
}

// Usage - Polymorphic behavior
public class DatabaseManager {
    private List<DatabaseConnection> connections = new ArrayList<>();
    
    public void addConnection(DatabaseConnection connection) {
        connections.add(connection);
    }
    
    public void connectAll() {
        for (DatabaseConnection conn : connections) {
            if (!conn.isConnected()) {
                System.out.println("Connecting to: " + conn.getConnectionInfo());
                // Polymorphic call - each database connects differently
            }
        }
    }
    
    public void executeOnAll(String query) {
        for (DatabaseConnection conn : connections) {
            conn.executeQuery(query);  // Polymorphic behavior
        }
    }
    
    public void disconnectAll() {
        for (DatabaseConnection conn : connections) {
            conn.disconnect();
        }
    }
    
    public static void main(String[] args) {
        DatabaseManager manager = new DatabaseManager();
        
        // Create different database connections
        DatabaseConnection mysql = DatabaseConnectionFactory.createConnection("mysql");
        DatabaseConnection postgres = DatabaseConnectionFactory.createConnection("postgres");
        DatabaseConnection mongo = DatabaseConnectionFactory.createConnection("mongo");
        
        // Connect
        mysql.connect("localhost", 3306, "mydb");
        postgres.connect("localhost", 5432, "mydb");
        mongo.connect("localhost", 27017, "mydb");
        
        // Add to manager
        manager.addConnection(mysql);
        manager.addConnection(postgres);
        manager.addConnection(mongo);
        
        // Execute same query on all databases - polymorphism!
        manager.executeOnAll("SELECT * FROM users");
        
        // Disconnect all
        manager.disconnectAll();
    }
}
```

### Problem 2: Sorting Strategy Pattern

**Question:** Implement different sorting algorithms using polymorphism.

```java
// Strategy interface
public interface SortingStrategy {
    void sort(int[] array);
    String getAlgorithmName();
}

// Bubble Sort
public class BubbleSort implements SortingStrategy {
    @Override
    public void sort(int[] array) {
        int n = array.length;
        for (int i = 0; i < n - 1; i++) {
            for (int j = 0; j < n - i - 1; j++) {
                if (array[j] > array[j + 1]) {
                    // Swap
                    int temp = array[j];
                    array[j] = array[j + 1];
                    array[j + 1] = temp;
                }
            }
        }
    }
    
    @Override
    public String getAlgorithmName() {
        return "Bubble Sort";
    }
}

// Quick Sort
public class QuickSort implements SortingStrategy {
    @Override
    public void sort(int[] array) {
        quickSort(array, 0, array.length - 1);
    }
    
    private void quickSort(int[] arr, int low, int high) {
        if (low < high) {
            int pi = partition(arr, low, high);
            quickSort(arr, low, pi - 1);
            quickSort(arr, pi + 1, high);
        }
    }
    
    private int partition(int[] arr, int low, int high) {
        int pivot = arr[high];
        int i = low - 1;
        
        for (int j = low; j < high; j++) {
            if (arr[j] < pivot) {
                i++;
                int temp = arr[i];
                arr[i] = arr[j];
                arr[j] = temp;
            }
        }
        
        int temp = arr[i + 1];
        arr[i + 1] = arr[high];
        arr[high] = temp;
        
        return i + 1;
    }
    
    @Override
    public String getAlgorithmName() {
        return "Quick Sort";
    }
}

// Merge Sort
public class MergeSort implements SortingStrategy {
    @Override
    public void sort(int[] array) {
        mergeSort(array, 0, array.length - 1);
    }
    
    private void mergeSort(int[] arr, int left, int right) {
        if (left < right) {
            int mid = (left + right) / 2;
            mergeSort(arr, left, mid);
            mergeSort(arr, mid + 1, right);
            merge(arr, left, mid, right);
        }
    }
    
    private void merge(int[] arr, int left, int mid, int right) {
        int n1 = mid - left + 1;
        int n2 = right - mid;
        
        int[] L = new int[n1];
        int[] R = new int[n2];
        
        System.arraycopy(arr, left, L, 0, n1);
        System.arraycopy(arr, mid + 1, R, 0, n2);
        
        int i = 0, j = 0, k = left;
        
        while (i < n1 && j < n2) {
            if (L[i] <= R[j]) {
                arr[k++] = L[i++];
            } else {
                arr[k++] = R[j++];
            }
        }
        
        while (i < n1) {
            arr[k++] = L[i++];
        }
        
        while (j < n2) {
            arr[k++] = R[j++];
        }
    }
    
    @Override
    public String getAlgorithmName() {
        return "Merge Sort";
    }
}

// Context class
public class Sorter {
    private SortingStrategy strategy;
    
    public void setStrategy(SortingStrategy strategy) {
        this.strategy = strategy;
    }
    
    public void sort(int[] array) {
        if (strategy == null) {
            throw new IllegalStateException("Sorting strategy not set");
        }
        
        long startTime = System.nanoTime();
        strategy.sort(array);
        long endTime = System.nanoTime();
        
        double duration = (endTime - startTime) / 1_000_000.0;
        System.out.printf("%s completed in %.2f ms%n", 
                strategy.getAlgorithmName(), duration);
    }
}

// Factory
public class SortingFactory {
    public static SortingStrategy getStrategy(String type) {
        switch (type.toUpperCase()) {
            case "BUBBLE":
                return new BubbleSort();
            case "QUICK":
                return new QuickSort();
            case "MERGE":
                return new MergeSort();
            default:
                throw new IllegalArgumentException("Unknown sorting algorithm: " + type);
        }
    }
    
    // Choose automatically based on array size
    public static SortingStrategy getOptimalStrategy(int arraySize) {
        if (arraySize < 10) {
            return new BubbleSort();  // Simple for small arrays
        } else if (arraySize < 1000) {
            return new QuickSort();  // Fast for medium arrays
        } else {
            return new MergeSort();  // Stable for large arrays
        }
    }
}

// Usage
public class SortingDemo {
    public static void main(String[] args) {
        int[] array1 = {64, 34, 25, 12, 22, 11, 90};
        int[] array2 = Arrays.copyOf(array1, array1.length);
        int[] array3 = Arrays.copyOf(array1, array1.length);
        
        Sorter sorter = new Sorter();
        
        // Use different strategies polymorphically
        sorter.setStrategy(new BubbleSort());
        sorter.sort(array1);
        System.out.println("Result: " + Arrays.toString(array1));
        
        sorter.setStrategy(new QuickSort());
        sorter.sort(array2);
        System.out.println("Result: " + Arrays.toString(array2));
        
        sorter.setStrategy(new MergeSort());
        sorter.sort(array3);
        System.out.println("Result: " + Arrays.toString(array3));
        
        // Factory pattern
        int[] array4 = {5, 2, 8, 1, 9};
        SortingStrategy strategy = SortingFactory.getOptimalStrategy(array4.length);
        sorter.setStrategy(strategy);
        sorter.sort(array4);
    }
}
```

---

# 4. ABSTRACTION

## 4.1 Concept Explanation

**Abstraction** is the process of hiding implementation details and showing only essential features to the user. It focuses on "what" an object does rather than "how" it does it.

**Two ways to achieve abstraction in Java:**
1. **Abstract Classes** (0-100% abstraction)
2. **Interfaces** (100% abstraction - before Java 8, now can have default methods)

**Key Points:**
- Abstract class cannot be instantiated
- Abstract methods have no body (must be implemented by subclass)
- Can have both abstract and concrete methods
- Reduces complexity by hiding implementation details
- Provides a template for future specific classes

**Abstract Class vs Interface:**

| Feature | Abstract Class | Interface |
|---------|---------------|-----------|
| Methods | Abstract + Concrete | Abstract + Default + Static (Java 8+) |
| Variables | Any type | Only public static final |
| Constructor | Yes | No |
| Multiple Inheritance | No (single inheritance) | Yes (multiple interfaces) |
| Access Modifiers | All | public only (methods) |
| When to use | IS-A relationship, share code | Contract, multiple inheritance |

## 4.2 Abstract Classes - Real-World Examples

### Example 1: Banking System

```java
// Abstract base class
public abstract class Account {
    protected String accountNumber;
    protected String holderName;
    protected double balance;
    protected LocalDateTime createdDate;
    
    public Account(String accountNumber, String holderName, double initialBalance) {
        this.accountNumber = accountNumber;
        this.holderName = holderName;
        this.balance = initialBalance;
        this.createdDate = LocalDateTime.now();
    }
    
    // Abstract methods - must be implemented by subclasses
    public abstract double calculateInterest();
    public abstract double getMinimumBalance();
    public abstract String getAccountType();
    
    // Concrete methods - common to all accounts
    public void deposit(double amount) {
        if (amount <= 0) {
            throw new IllegalArgumentException("Deposit amount must be positive");
        }
        balance += amount;
        System.out.println("Deposited: $" + amount + ", New balance: $" + balance);
    }
    
    public boolean withdraw(double amount) {
        if (amount <= 0) {
            throw new IllegalArgumentException("Withdrawal amount must be positive");
        }
        if (balance - amount < getMinimumBalance()) {
            System.out.println("Insufficient funds. Minimum balance: $" + getMinimumBalance());
            return false;
        }
        balance -= amount;
        System.out.println("Withdrawn: $" + amount + ", New balance: $" + balance);
        return true;
    }
    
    public void displayAccountInfo() {
        System.out.println("Account Type: " + getAccountType());
        System.out.println("Account Number: " + accountNumber);
        System.out.println("Holder: " + holderName);
        System.out.println("Balance: $" + balance);
        System.out.println("Minimum Balance: $" + getMinimumBalance());
    }
    
    public double getBalance() {
        return balance;
    }
}

// Savings Account
public class SavingsAccount extends Account {
    private double interestRate = 4.5;  // 4.5% per annum
    
    public SavingsAccount(String accountNumber, String holderName, double initialBalance) {
        super(accountNumber, holderName, initialBalance);
    }
    
    @Override
    public double calculateInterest() {
        return balance * interestRate / 100;
    }
    
    @Override
    public double getMinimumBalance() {
        return 500.0;  // Minimum $500
    }
    
    @Override
    public String getAccountType() {
        return "Savings Account";
    }
    
    public void setInterestRate(double rate) {
        if (rate < 0 || rate > 15) {
            throw new IllegalArgumentException("Interest rate must be between 0 and 15");
        }
        this.interestRate = rate;
    }
}

// Current Account
public class CurrentAccount extends Account {
    private double overdraftLimit;
    
    public CurrentAccount(String accountNumber, String holderName, 
                         double initialBalance, double overdraftLimit) {
        super(accountNumber, holderName, initialBalance);
        this.overdraftLimit = overdraftLimit;
    }
    
    @Override
    public double calculateInterest() {
        return 0;  // No interest on current account
    }
    
    @Override
    public double getMinimumBalance() {
        return -overdraftLimit;  // Can go negative up to overdraft limit
    }
    
    @Override
    public String getAccountType() {
        return "Current Account";
    }
    
    @Override
    public boolean withdraw(double amount) {
        if (balance - amount < getMinimumBalance()) {
            System.out.println("Overdraft limit exceeded");
            return false;
        }
        balance -= amount;
        System.out.println("Withdrawn: $" + amount + ", Balance: $" + balance);
        return true;
    }
}

// Fixed Deposit Account
public class FixedDepositAccount extends Account {
    private int tenureMonths;
    private double interestRate;
    private boolean isMatured;
    
    public FixedDepositAccount(String accountNumber, String holderName, 
                               double amount, int tenureMonths) {
        super(accountNumber, holderName, amount);
        this.tenureMonths = tenureMonths;
        this.interestRate = calculateInterestRate(tenureMonths);
        this.isMatured = false;
    }
    
    private double calculateInterestRate(int months) {
        if (months <= 6) return 5.5;
        else if (months <= 12) return 6.5;
        else if (months <= 24) return 7.0;
        else return 7.5;
    }
    
    @Override
    public double calculateInterest() {
        return balance * interestRate * tenureMonths / (100 * 12);
    }
    
    @Override
    public double getMinimumBalance() {
        return balance;  // Cannot reduce balance
    }
    
    @Override
    public String getAccountType() {
        return "Fixed Deposit Account";
    }
    
    @Override
    public void deposit(double amount) {
        throw new UnsupportedOperationException("Cannot deposit to FD account");
    }
    
    @Override
    public boolean withdraw(double amount) {
        if (!isMatured) {
            throw new IllegalStateException("FD not matured yet. Cannot withdraw.");
        }
        return super.withdraw(amount);
    }
    
    public void mature() {
        isMatured = true;
        double interest = calculateInterest();
        balance += interest;
        System.out.println("FD matured. Interest: $" + interest + ", Total: $" + balance);
    }
}

// Usage
public class BankingSystem {
    public static void main(String[] args) {
        // Cannot instantiate abstract class
        // Account account = new Account("123", "John", 1000);  // Compile error
        
        // Create different account types
        Account savings = new SavingsAccount("SAV001", "Alice", 5000);
        Account current = new CurrentAccount("CUR001", "Bob", 10000, 5000);
        Account fd = new FixedDepositAccount("FD001", "Charlie", 50000, 12);
        
        savings.displayAccountInfo();
        System.out.println("Interest: $" + savings.calculateInterest());
        savings.deposit(1000);
        savings.withdraw(500);
        
        System.out.println("\n---");
        current.displayAccountInfo();
        current.withdraw(12000);  // Uses overdraft
        
        System.out.println("\n---");
        fd.displayAccountInfo();
        // fd.withdraw(1000);  // Runtime error - not matured
        ((FixedDepositAccount) fd).mature();
        fd.withdraw(10000);  // Now allowed
    }
}
```

### Example 2: File Processing System

```java
// Abstract class for file processors
public abstract class FileProcessor {
    protected String filePath;
    protected String fileExtension;
    
    public FileProcessor(String filePath) {
        this.filePath = filePath;
        this.fileExtension = getFileExtension(filePath);
    }
    
    // Template method pattern
    public final void processFile() {
        if (!validateFile()) {
            throw new IllegalArgumentException("Invalid file: " + filePath);
        }
        
        openFile();
        readContent();
        processContent();
        closeFile();
    }
    
    // Abstract methods - specific to file type
    protected abstract void readContent();
    protected abstract void processContent();
    protected abstract boolean validateFile();
    
    // Concrete methods - common to all files
    protected void openFile() {
        System.out.println("Opening file: " + filePath);
    }
    
    protected void closeFile() {
        System.out.println("Closing file: " + filePath);
    }
    
    private String getFileExtension(String path) {
        int lastDot = path.lastIndexOf('.');
        return lastDot > 0 ? path.substring(lastDot + 1).toLowerCase() : "";
    }
    
    public String getFilePath() {
        return filePath;
    }
}

// CSV Processor
public class CSVProcessor extends FileProcessor {
    private List<String[]> rows = new ArrayList<>();
    
    public CSVProcessor(String filePath) {
        super(filePath);
    }
    
    @Override
    protected void readContent() {
        System.out.println("Reading CSV file...");
        // Read CSV using BufferedReader or library like OpenCSV
        rows.add(new String[]{"Name", "Age", "City"});
        rows.add(new String[]{"Alice", "25", "NYC"});
        rows.add(new String[]{"Bob", "30", "LA"});
    }
    
    @Override
    protected void processContent() {
        System.out.println("Processing CSV data...");
        for (String[] row : rows) {
            System.out.println(String.join(", ", row));
        }
    }
    
    @Override
    protected boolean validateFile() {
        return fileExtension.equals("csv");
    }
}

// JSON Processor
public class JSONProcessor extends FileProcessor {
    private String jsonContent;
    
    public JSONProcessor(String filePath) {
        super(filePath);
    }
    
    @Override
    protected void readContent() {
        System.out.println("Reading JSON file...");
        jsonContent = "{\"users\": [{\"name\":\"Alice\", \"age\":25}]}";
    }
    
    @Override
    protected void processContent() {
        System.out.println("Processing JSON data...");
        System.out.println(jsonContent);
        // Parse JSON using Jackson or Gson
    }
    
    @Override
    protected boolean validateFile() {
        return fileExtension.equals("json");
    }
}

// XML Processor
public class XMLProcessor extends FileProcessor {
    private String xmlContent;
    
    public XMLProcessor(String filePath) {
        super(filePath);
    }
    
    @Override
    protected void readContent() {
        System.out.println("Reading XML file...");
        xmlContent = "<users><user><name>Alice</name><age>25</age></user></users>";
    }
    
    @Override
    protected void processContent() {
        System.out.println("Processing XML data...");
        System.out.println(xmlContent);
        // Parse XML using JAXB or DOM parser
    }
    
    @Override
    protected boolean validateFile() {
        return fileExtension.equals("xml");
    }
}

// Factory
public class FileProcessorFactory {
    public static FileProcessor createProcessor(String filePath) {
        String extension = filePath.substring(filePath.lastIndexOf('.') + 1).toLowerCase();
        
        switch (extension) {
            case "csv":
                return new CSVProcessor(filePath);
            case "json":
                return new JSONProcessor(filePath);
            case "xml":
                return new XMLProcessor(filePath);
            default:
                throw new IllegalArgumentException("Unsupported file type: " + extension);
        }
    }
}
```

## 4.3 Interfaces - Real-World Examples

### Example 1: Payment Gateway Integration

```java
// Payment interface
public interface PaymentGateway {
    boolean initiatePayment(double amount, String currency);
    boolean verifyPayment(String transactionId);
    void refundPayment(String transactionId, double amount);
    String getPaymentStatus(String transactionId);
    
    // Default method (Java 8+)
    default void logTransaction(String message) {
        System.out.println("[" + LocalDateTime.now() + "] " + message);
    }
    
    // Static method
    static boolean isValidAmount(double amount) {
        return amount > 0 && amount <= 1000000;
    }
}

// Stripe Payment Gateway
public class StripePaymentGateway implements PaymentGateway {
    private String apiKey;
    private Map<String, String> transactions = new HashMap<>();
    
    public StripePaymentGateway(String apiKey) {
        this.apiKey = apiKey;
    }
    
    @Override
    public boolean initiatePayment(double amount, String currency) {
        if (!PaymentGateway.isValidAmount(amount)) {
            return false;
        }
        
        String txnId = "STRIPE_" + UUID.randomUUID().toString();
        logTransaction("Initiating Stripe payment: $" + amount + " " + currency);
        
        // Call Stripe API
        transactions.put(txnId, "SUCCESS");
        System.out.println("Stripe transaction ID: " + txnId);
        return true;
    }
    
    @Override
    public boolean verifyPayment(String transactionId) {
        logTransaction("Verifying Stripe payment: " + transactionId);
        return "SUCCESS".equals(transactions.get(transactionId));
    }
    
    @Override
    public void refundPayment(String transactionId, double amount) {
        logTransaction("Refunding Stripe payment: " + transactionId + " - $" + amount);
        transactions.put(transactionId, "REFUNDED");
    }
    
    @Override
    public String getPaymentStatus(String transactionId) {
        return transactions.getOrDefault(transactionId, "UNKNOWN");
    }
}

// PayPal Payment Gateway
public class PayPalPaymentGateway implements PaymentGateway {
    private String clientId;
    private String clientSecret;
    private Map<String, String> transactions = new HashMap<>();
    
    public PayPalPaymentGateway(String clientId, String clientSecret) {
        this.clientId = clientId;
        this.clientSecret = clientSecret;
    }
    
    @Override
    public boolean initiatePayment(double amount, String currency) {
        if (!PaymentGateway.isValidAmount(amount)) {
            return false;
        }
        
        String txnId = "PAYPAL_" + UUID.randomUUID().toString();
        logTransaction("Initiating PayPal payment: $" + amount + " " + currency);
        
        // Call PayPal API
        transactions.put(txnId, "SUCCESS");
        System.out.println("PayPal transaction ID: " + txnId);
        return true;
    }
    
    @Override
    public boolean verifyPayment(String transactionId) {
        logTransaction("Verifying PayPal payment: " + transactionId);
        return "SUCCESS".equals(transactions.get(transactionId));
    }
    
    @Override
    public void refundPayment(String transactionId, double amount) {
        logTransaction("Refunding PayPal payment: " + transactionId + " - $" + amount);
        transactions.put(transactionId, "REFUNDED");
    }
    
    @Override
    public String getPaymentStatus(String transactionId) {
        return transactions.getOrDefault(transactionId, "UNKNOWN");
    }
    
    @Override
    public void logTransaction(String message) {
        // Custom logging for PayPal
        System.out.println("[PAYPAL - " + LocalDateTime.now() + "] " + message);
    }
}

// Razorpay Payment Gateway
public class RazorpayPaymentGateway implements PaymentGateway {
    private String merchantId;
    private Map<String, String> transactions = new HashMap<>();
    
    public RazorpayPaymentGateway(String merchantId) {
        this.merchantId = merchantId;
    }
    
    @Override
    public boolean initiatePayment(double amount, String currency) {
        if (!PaymentGateway.isValidAmount(amount)) {
            return false;
        }
        
        String txnId = "RAZORPAY_" + UUID.randomUUID().toString();
        logTransaction("Initiating Razorpay payment: " + amount + " " + currency);
        
        transactions.put(txnId, "SUCCESS");
        System.out.println("Razorpay transaction ID: " + txnId);
        return true;
    }
    
    @Override
    public boolean verifyPayment(String transactionId) {
        return "SUCCESS".equals(transactions.get(transactionId));
    }
    
    @Override
    public void refundPayment(String transactionId, double amount) {
        logTransaction("Refunding Razorpay payment: " + transactionId);
        transactions.put(transactionId, "REFUNDED");
    }
    
    @Override
    public String getPaymentStatus(String transactionId) {
        return transactions.getOrDefault(transactionId, "UNKNOWN");
    }
}

// Service using interface
public class PaymentService {
    private PaymentGateway gateway;
    
    public void setPaymentGateway(PaymentGateway gateway) {
        this.gateway = gateway;
    }
    
    public boolean processPayment(double amount, String currency) {
        if (gateway == null) {
            throw new IllegalStateException("Payment gateway not configured");
        }
        
        return gateway.initiatePayment(amount, currency);
    }
}
```

### Example 2: Multiple Interfaces - Animal Characteristics

```java
// Multiple interfaces for different capabilities
public interface Walkable {
    void walk();
    int getNumberOfLegs();
}

public interface Swimmable {
    void swim();
    double getSwimmingSpeed();  // km/h
}

public interface Flyable {
    void fly();
    double getMaxAltitude();  // meters
}

public interface Soundable {
    void makeSound();
    String getSoundType();
}

// Duck - implements multiple interfaces
public class Duck implements Walkable, Swimmable, Flyable, Soundable {
    private String name;
    
    public Duck(String name) {
        this.name = name;
    }
    
    @Override
    public void walk() {
        System.out.println(name + " is waddling");
    }
    
    @Override
    public int getNumberOfLegs() {
        return 2;
    }
    
    @Override
    public void swim() {
        System.out.println(name + " is swimming");
    }
    
    @Override
    public double getSwimmingSpeed() {
        return 3.0;  // 3 km/h
    }
    
    @Override
    public void fly() {
        System.out.println(name + " is flying");
    }
    
    @Override
    public double getMaxAltitude() {
        return 2000.0;  // 2000 meters
    }
    
    @Override
    public void makeSound() {
        System.out.println(name + " says: Quack quack!");
    }
    
    @Override
    public String getSoundType() {
        return "Quack";
    }
}

// Fish - only swims
public class Fish implements Swimmable, Soundable {
    private String species;
    
    public Fish(String species) {
        this.species = species;
    }
    
    @Override
    public void swim() {
        System.out.println(species + " is swimming gracefully");
    }
    
    @Override
    public double getSwimmingSpeed() {
        return 20.0;  // 20 km/h
    }
    
    @Override
    public void makeSound() {
        System.out.println(species + " makes bubbling sounds");
    }
    
    @Override
    public String getSoundType() {
        return "Bubble";
    }
}

// Dog - walks and swims
public class Dog implements Walkable, Swimmable, Soundable {
    private String breed;
    
    public Dog(String breed) {
        this.breed = breed;
    }
    
    @Override
    public void walk() {
        System.out.println(breed + " is walking");
    }
    
    @Override
    public int getNumberOfLegs() {
        return 4;
    }
    
    @Override
    public void swim() {
        System.out.println(breed + " is doggy paddling");
    }
    
    @Override
    public double getSwimmingSpeed() {
        return 5.0;  // 5 km/h
    }
    
    @Override
    public void makeSound() {
        System.out.println(breed + " says: Woof woof!");
    }
    
    @Override
    public String getSoundType() {
        return "Bark";
    }
}

// Usage
public class ZooSimulation {
    public static void main(String[] args) {
        Duck duck = new Duck("Donald");
        Fish fish = new Fish("Goldfish");
        Dog dog = new Dog("Golden Retriever");
        
        // Duck can do everything
        duck.walk();
        duck.swim();
        duck.fly();
        duck.makeSound();
        
        // Polymorphism with interfaces
        List<Swimmable> swimmers = Arrays.asList(duck, fish, dog);
        System.out.println("\n--- All swimmers ---");
        for (Swimmable swimmer : swimmers) {
            swimmer.swim();
            System.out.println("Speed: " + swimmer.getSwimmingSpeed() + " km/h");
        }
        
        List<Soundable> soundMakers = Arrays.asList(duck, fish, dog);
        System.out.println("\n--- All sound makers ---");
        for (Soundable soundable : soundMakers) {
            soundable.makeSound();
        }
    }
}
```

## 4.4 Interview Questions and Answers

### Q1: When to use abstract class vs interface?

**Answer:**

**Use Abstract Class when:**
1. You want to share code among closely related classes
2. Classes have common fields or require non-public members
3. You want to provide a common base with some implementation
4. You need constructors
5. IS-A relationship (strict hierarchy)

**Use Interface when:**
1. Unrelated classes implement your interface
2. You want to specify behavior without implementation
3. You need multiple inheritance
4. You want to define a contract
5. CAN-DO relationship (capability)

**Example:**

```java
// Abstract class - IS-A relationship
abstract class Animal {
    protected String name;  // Common field
    protected int age;
    
    public Animal(String name, int age) {  // Constructor
        this.name = name;
        this.age = age;
    }
    
    // Common implementation
    public void sleep() {
        System.out.println(name + " is sleeping");
    }
    
    // Each animal makes different sound
    public abstract void makeSound();
}

// Interface - CAN-DO relationship
interface Flyable {
    void fly();  // Contract, no implementation
}

interface Swimmable {
    void swim();
}

// Bird IS-A Animal and CAN fly
class Bird extends Animal implements Flyable {
    public Bird(String name, int age) {
        super(name, age);
    }
    
    @Override
    public void makeSound() {
        System.out.println("Chirp chirp");
    }
    
    @Override
    public void fly() {
        System.out.println(name + " is flying");
    }
}

// Duck IS-A Animal and CAN fly and swim
class Duck extends Animal implements Flyable, Swimmable {
    public Duck(String name, int age) {
        super(name, age);
    }
    
    @Override
    public void makeSound() {
        System.out.println("Quack quack");
    }
    
    @Override
    public void fly() {
        System.out.println(name + " is flying");
    }
    
    @Override
    public void swim() {
        System.out.println(name + " is swimming");
    }
}
```

### Q2: Can an abstract class have a constructor? Why?

**Answer:**
**Yes**, abstract classes can have constructors. Although you cannot instantiate an abstract class directly, the constructor is called when a concrete subclass is instantiated.

**Reasons:**
1. Initialize fields of abstract class
2. Enforce invariants
3. Perform common initialization logic
4. Chain to superclass constructors

**Example:**
```java
abstract class Vehicle {
    protected String registrationNumber;
    protected String manufacturer;
    protected int year;
    
    // Constructor in abstract class
    public Vehicle(String registrationNumber, String manufacturer, int year) {
        if (year < 1900 || year > LocalDate.now().getYear()) {
            throw new IllegalArgumentException("Invalid year");
        }
        this.registrationNumber = registrationNumber;
        this.manufacturer = manufacturer;
        this.year = year;
        System.out.println("Vehicle constructor called");
    }
    
    public abstract void start();
}

class Car extends Vehicle {
    private int doors;
    
    public Car(String regNo, String manufacturer, int year, int doors) {
        super(regNo, manufacturer, year);  // Calls abstract class constructor
        this.doors = doors;
        System.out.println("Car constructor called");
    }
    
    @Override
    public void start() {
        System.out.println("Car starting with key");
    }
}

// Usage
Car car = new Car("ABC123", "Toyota", 2024, 4);
/* Output:
Vehicle constructor called
Car constructor called
*/
```

### Q3: Can we have abstract method in non-abstract class?

**Answer:**
**No**, this is a compile-time error. If a class has even one abstract method, the class must be declared abstract.

```java
// Compile error!
public class MyClass {
    public abstract void myMethod();  // ERROR: MyClass must be abstract
}

// Correct
public abstract class MyClass {
    public abstract void myMethod();  // OK
}
```

**However:**
- Non-abstract class can implement interface with abstract methods
- Must implement all abstract methods from interface

```java
interface MyInterface {
    void myMethod();  // Abstract
}

// OK - implements abstract method
public class MyClass implements MyInterface {
    @Override
    public void myMethod() {
        System.out.println("Implementation");
    }
}
```

### Q4: What are marker interfaces? Give examples.

**Answer:**
**Marker interface** (or tag interface) is an empty interface with no methods. It's used to mark or tag a class for some special behavior.

**Purpose:**
- Provide metadata about class
- Enable runtime type checking
- Grant special capabilities

**Examples from Java:**

```java
// 1. Serializable - marks class as serializable
public class Person implements Serializable {
    private String name;
    private int age;
    // No methods to implement!
}

// 2. Cloneable - marks class as cloneable
public class Student implements Cloneable {
    private String name;
    
    @Override
    public Student clone() throws CloneNotSupportedException {
        return (Student) super.clone();
    }
}

// 3. Remote - marks class for RMI
public interface MyRemoteService extends Remote {
    void doSomething() throws RemoteException;
}
```

**Custom Marker Interface:**
```java
// Custom marker for permission
public interface AdminAccess {
    // Empty - just marks the class
}

public class User {
    private String username;
}

public class AdminUser extends User implements AdminAccess {
    // AdminAccess marks this as admin
}

// Check at runtime
public class SecurityService {
    public void performSensitiveOperation(User user) {
        if (user instanceof AdminAccess) {
            System.out.println("Admin access granted");
            // Perform operation
        } else {
            throw new SecurityException("Admin access required");
        }
    }
}
```

**Modern Alternative:**
Annotations have largely replaced marker interfaces:
```java
@Admin
public class AdminUser extends User {
    // ...
}
```

### Q5: Can an interface extend another interface?

**Answer:**
**Yes**, an interface can extend one or more interfaces. This creates an interface hierarchy.

**Single Inheritance:**
```java
interface Animal {
    void eat();
}

interface Mammal extends Animal {
    void breathe();
}

class Dog implements Mammal {
    @Override
    public void eat() {
        System.out.println("Dog eats");
    }
    
    @Override
    public void breathe() {
        System.out.println("Dog breathes");
    }
}
```

**Multiple Inheritance:**
```java
interface Walkable {
    void walk();
}

interface Swimmable {
    void swim();
}

// Interface extending multiple interfaces
interface Amphibian extends Walkable, Swimmable {
    void adaptToEnvironment();
}

class Frog implements Amphibian {
    @Override
    public void walk() {
        System.out.println("Frog hops");
    }
    
    @Override
    public void swim() {
        System.out.println("Frog swims");
    }
    
    @Override
    public void adaptToEnvironment() {
        System.out.println("Frog adapts to land and water");
    }
}
```

**Diamond Problem Resolution:**
```java
interface A {
    default void show() {
        System.out.println("A");
    }
}

interface B extends A {
    default void show() {
        System.out.println("B");
    }
}

interface C extends A {
    default void show() {
        System.out.println("C");
    }
}

// D extends both B and C
interface D extends B, C {
    @Override
    default void show() {
        B.super.show();  // Choose explicitly
        // or C.super.show();
        // or provide new implementation
    }
}
```

### Q6: Functional Interface vs Normal Interface?

**Answer:**
**Functional Interface** is an interface with exactly one abstract method (SAM - Single Abstract Method). Can have multiple default/static methods.

**Annotated with @FunctionalInterface (optional but recommended)**

**Examples:**

```java
// Functional interface
@FunctionalInterface
public interface Calculator {
    int calculate(int a, int b);  // Single abstract method
    
    // Can have default methods
    default void printResult(int result) {
        System.out.println("Result: " + result);
    }
    
    // Can have static methods
    static boolean isPositive(int num) {
        return num > 0;
    }
}

// Usage with lambda
Calculator add = (a, b) -> a + b;
Calculator multiply = (a, b) -> a * b;

System.out.println(add.calculate(5, 3));      // 8
System.out.println(multiply.calculate(5, 3)); // 15

// Built-in functional interfaces
Predicate<Integer> isEven = num -> num % 2 == 0;
Function<String, Integer> strLength = str -> str.length();
Consumer<String> printer = msg -> System.out.println(msg);
Supplier<Double> randomGen = () -> Math.random();
```

**Normal Interface:**
```java
public interface Shape {
    double getArea();       // Abstract method 1
    double getPerimeter();  // Abstract method 2
    // Multiple abstract methods - NOT functional interface
}
```

## 4.5 Interview Traps and Edge Cases

### Trap 1: Interface with Default Methods

```java
interface Vehicle {
    default void start() {
        System.out.println("Vehicle starting");
    }
}

interface ElectricVehicle {
    default void start() {
        System.out.println("Electric vehicle starting silently");
    }
}

// Compile error: Which start() to inherit?
class ElectricCar implements Vehicle, ElectricVehicle {
    // Must override to resolve ambiguity
    @Override
    public void start() {
        Vehicle.super.start();  // Choose one
        // or ElectricVehicle.super.start();
        // or provide own implementation
    }
}
```

### Trap 2: Abstract Class Implementing Interface

```java
interface Drawable {
    void draw();
    void resize();
}

// Abstract class can choose which methods to implement
abstract class Shape implements Drawable {
    @Override
    public void resize() {
        System.out.println("Resizing shape");
    }
    
    // draw() remains abstract
}

class Circle extends Shape {
    @Override
    public void draw() {
        System.out.println("Drawing circle");
    }
    // resize() inherited from Shape
}
```

### Trap 3: Cannot Reduce Visibility

```java
interface MyInterface {
    void publicMethod();  // Implicitly public
}

class MyClass implements MyInterface {
    // Compile error: Cannot reduce visibility
    // protected void publicMethod() {  // ERROR
    // }
    
    // Must be public
    @Override
    public void publicMethod() {
        System.out.println("Public");
    }
}
```

## 4.6 Coding Problems with Solutions

### Problem 1: Plugin System

**Question:** Design a plugin system where plugins can be loaded dynamically.

```java
// Plugin interface
public interface Plugin {
    String getName();
    String getVersion();
    void initialize();
    void execute(Map<String, Object> context);
    void shutdown();
    
    default boolean isEnabled() {
        return true;
    }
}

// Abstract base with common functionality
public abstract class BasePlugin implements Plugin {
    protected String name;
    protected String version;
    protected boolean initialized = false;
    
    public BasePlugin(String name, String version) {
        this.name = name;
        this.version = version;
    }
    
    @Override
    public String getName() {
        return name;
    }
    
    @Override
    public String getVersion() {
        return version;
    }
    
    @Override
    public void initialize() {
        System.out.println("Initializing plugin: " + name);
        initialized = true;
    }
    
    @Override
    public void shutdown() {
        System.out.println("Shutting down plugin: " + name);
        initialized = false;
    }
    
    protected void checkInitialized() {
        if (!initialized) {
            throw new IllegalStateException("Plugin not initialized: " + name);
        }
    }
}

// Logging plugin
public class LoggingPlugin extends BasePlugin {
    private List<String> logs = new ArrayList<>();
    
    public LoggingPlugin() {
        super("Logger", "1.0.0");
    }
    
    @Override
    public void execute(Map<String, Object> context) {
        checkInitialized();
        String message = (String) context.get("message");
        String timestamp = LocalDateTime.now().toString();
        String logEntry = timestamp + " - " + message;
        logs.add(logEntry);
        System.out.println("[LOG] " + logEntry);
    }
    
    public List<String> getLogs() {
        return new ArrayList<>(logs);
    }
}

// Email plugin
public class EmailPlugin extends BasePlugin {
    private String smtpServer;
    
    public EmailPlugin(String smtpServer) {
        super("Email Sender", "2.0.0");
        this.smtpServer = smtpServer;
    }
    
    @Override
    public void initialize() {
        super.initialize();
        System.out.println("Connecting to SMTP server: " + smtpServer);
    }
    
    @Override
    public void execute(Map<String, Object> context) {
        checkInitialized();
        String to = (String) context.get("to");
        String subject = (String) context.get("subject");
        String body = (String) context.get("body");
        
        System.out.println("Sending email to: " + to);
        System.out.println("Subject: " + subject);
        System.out.println("Body: " + body);
    }
}

// Database plugin
public class DatabasePlugin extends BasePlugin {
    private String connectionString;
    
    public DatabasePlugin(String connectionString) {
        super("Database", "1.5.0");
        this.connectionString = connectionString;
    }
    
    @Override
    public void initialize() {
        super.initialize();
        System.out.println("Connecting to database: " + connectionString);
    }
    
    @Override
    public void execute(Map<String, Object> context) {
        checkInitialized();
        String query = (String) context.get("query");
        System.out.println("Executing query: " + query);
    }
}

// Plugin manager
public class PluginManager {
    private Map<String, Plugin> plugins = new HashMap<>();
    
    public void registerPlugin(Plugin plugin) {
        plugins.put(plugin.getName(), plugin);
        System.out.println("Registered plugin: " + plugin.getName() + 
                         " v" + plugin.getVersion());
    }
    
    public void initializeAll() {
        for (Plugin plugin : plugins.values()) {
            if (plugin.isEnabled()) {
                plugin.initialize();
            }
        }
    }
    
    public void executePlugin(String name, Map<String, Object> context) {
        Plugin plugin = plugins.get(name);
        if (plugin == null) {
            throw new IllegalArgumentException("Plugin not found: " + name);
        }
        if (!plugin.isEnabled()) {
            throw new IllegalStateException("Plugin disabled: " + name);
        }
        plugin.execute(context);
    }
    
    public void shutdownAll() {
        for (Plugin plugin : plugins.values()) {
            plugin.shutdown();
        }
    }
    
    public List<String> getPluginList() {
        return plugins.values().stream()
            .map(p -> p.getName() + " v" + p.getVersion())
            .collect(Collectors.toList());
    }
}

// Usage
public class PluginSystem {
    public static void main(String[] args) {
        PluginManager manager = new PluginManager();
        
        // Register plugins
        manager.registerPlugin(new LoggingPlugin());
        manager.registerPlugin(new EmailPlugin("smtp.gmail.com"));
        manager.registerPlugin(new DatabasePlugin("jdbc:mysql://localhost:3306/mydb"));
        
        // Initialize all
        manager.initializeAll();
        
        // Execute plugins
        Map<String, Object> logContext = new HashMap<>();
        logContext.put("message", "Application started");
        manager.executePlugin("Logger", logContext);
        
        Map<String, Object> emailContext = new HashMap<>();
        emailContext.put("to", "user@example.com");
        emailContext.put("subject", "Test Email");
        emailContext.put("body", "Hello from plugin system");
        manager.executePlugin("Email Sender", emailContext);
        
        Map<String, Object> dbContext = new HashMap<>();
        dbContext.put("query", "SELECT * FROM users");
        manager.executePlugin("Database", dbContext);
        
        // List plugins
        System.out.println("\nInstalled plugins:");
        manager.getPluginList().forEach(System.out::println);
        
        // Shutdown
        manager.shutdownAll();
    }
}
```

---

# 5. COMPOSITION VS INHERITANCE

## 5.1 Concept Explanation

**Inheritance** (IS-A relationship):
- "A Car IS-A Vehicle"
- Tight coupling between parent and child
- Child inherits all public/protected members
- Single inheritance in Java

**Composition** (HAS-A relationship):
- "A Car HAS-A Engine"
- Loose coupling
- More flexible - can change behavior at runtime
- Supports multiple "inheritance-like" behaviors

**Favor Composition Over Inheritance** - Design principle encouraging use of composition to achieve code reuse instead of inheritance.

**When to use what:**
- **Use Inheritance**: True IS-A relationship, shared behavior in hierarchy
- **Use Composition**: HAS-A relationship, behavior delegation, flexibility needed

## 5.2 Problems with Inheritance

### Problem 1: Fragile Base Class

```java
// Base class
public class ArrayList {
    private int size = 0;
    
    public void add(Object element) {
        // Add element
        size++;
    }
    
    public void addAll(Collection c) {
        for (Object element : c) {
            add(element);  // Calls add for each element
        }
    }
    
    public int size() {
        return size;
    }
}

// Child class wants to count additions
public class CountingArrayList extends ArrayList {
    private int addCount = 0;
    
    @Override
    public void add(Object element) {
        addCount++;  // Count
        super.add(element);
    }
    
    @Override
    public void addAll(Collection c) {
        addCount += c.size();  // Count all
        super.addAll(c);  // Problem: calls add() for each, double counting!
    }
    
    public int getAddCount() {
        return addCount;
    }
}

// Usage
CountingArrayList list = new CountingArrayList();
list.addAll(Arrays.asList("A", "B", "C"));
System.out.println(list.getAddCount());  // Expected: 3, Actual: 6!
```

**Problem**: Parent class implementation detail affects child class.

### Problem 2: Breaking Encapsulation

```java
class Parent {
    private int value = 10;
    
    public void increment() {
        value++;
        doSomething();  // Calls overridden method
    }
    
    public void doSomething() {
        System.out.println("Parent: " + value);
    }
}

class Child extends Parent {
    @Override
    public void doSomething() {
        System.out.println("Child: " + super.value);  // Error: can't access private!
    }
}
```

### Problem 3: Inflexible Hierarchy

```java
// Rigid hierarchy
class Bird {
    void fly() {
        System.out.println("Flying");
    }
}

class Sparrow extends Bird {
    // OK - sparrow can fly
}

class Ostrich extends Bird {
    // Problem: Ostrich extends Bird but can't fly!
    @Override
    void fly() {
        throw new UnsupportedOperationException("Ostriches can't fly");
    }
}
```

## 5.3 Composition Solutions

### Solution 1: Replace Inheritance with Composition

```java
// Instead of extending ArrayList
public class CountingArrayList {
    private ArrayList list = new ArrayList();  // HAS-A
    private int addCount = 0;
    
    public void add(Object element) {
        addCount++;
        list.add(element);  // Delegate
    }
    
    public void addAll(Collection c) {
        addCount += c.size();
        list.addAll(c);  // Delegate
    }
    
    public int size() {
        return list.size();
    }
    
    public int getAddCount() {
        return addCount;
    }
}
```

### Solution 2: Interface-Based Design

```java
// Define capabilities as interfaces
interface Flyable {
    void fly();
}

interface Walkable {
    void walk();
}

interface Swimmable {
    void swim();
}

// Implementations
class FlyingAbility implements Flyable {
    @Override
    public void fly() {
        System.out.println("Flying in the sky");
    }
}

class WalkingAbility implements Walkable {
    @Override
    public void walk() {
        System.out.println("Walking on ground");
    }
}

class SwimmingAbility implements Swimmable {
    @Override
    public void swim() {
        System.out.println("Swimming in water");
    }
}

// Birds using composition
class Bird {
    protected String name;
    
    public Bird(String name) {
        this.name = name;
    }
}

class Sparrow extends Bird {
    private Flyable flyingAbility = new FlyingAbility();
    private Walkable walkingAbility = new WalkingAbility();
    
    public Sparrow(String name) {
        super(name);
    }
    
    public void fly() {
        System.out.print(name + " - ");
        flyingAbility.fly();
    }
    
    public void walk() {
        System.out.print(name + " - ");
        walkingAbility.walk();
    }
}

class Ostrich extends Bird {
    private Walkable walkingAbility = new WalkingAbility();
    // No flying ability - problem solved!
    
    public Ostrich(String name) {
        super(name);
    }
    
    public void walk() {
        System.out.print(name + " - ");
        walkingAbility.walk();
    }
    
    // No fly() method - clear that ostrich can't fly
}

class Duck extends Bird {
    private Flyable flyingAbility = new FlyingAbility();
    private Walkable walkingAbility = new WalkingAbility();
    private Swimmable swimmingAbility = new SwimmingAbility();
    
    public Duck(String name) {
        super(name);
    }
    
    public void fly() {
        System.out.print(name + " - ");
        flyingAbility.fly();
    }
    
    public void walk() {
        System.out.print(name + " - ");
        walkingAbility.walk();
    }
    
    public void swim() {
        System.out.print(name + " - ");
        swimmingAbility.swim();
    }
}
```

## 5.4 Real-World Examples

### Example 1: Car System

**Bad Design (Inheritance):**

```java
class Vehicle {
    protected String brand;
    protected Engine engine;
    protected Transmission transmission;
    
    public void start() {
        engine.start();
    }
    
    public void changeGear(int gear) {
        transmission.changeGear(gear);
    }
}

class ManualCar extends Vehicle {
    // Inherits everything, even if not needed
}

class AutomaticCar extends Vehicle {
    // What if we want different transmission behavior?
}

class ElectricCar extends Vehicle {
    // Problem: Electric cars don't have traditional transmission!
    // Inherited changeGear() doesn't make sense
}
```

**Good Design (Composition):**

```java
// Components
interface Engine {
    void start();
    void stop();
    int getHorsepower();
}

class PetrolEngine implements Engine {
    private int horsepower;
    
    public PetrolEngine(int horsepower) {
        this.horsepower = horsepower;
    }
    
    @Override
    public void start() {
        System.out.println("Petrol engine starting with ignition");
    }
    
    @Override
    public void stop() {
        System.out.println("Petrol engine stopping");
    }
    
    @Override
    public int getHorsepower() {
        return horsepower;
    }
}

class ElectricMotor implements Engine {
    private int horsepower;
    
    public ElectricMotor(int horsepower) {
        this.horsepower = horsepower;
    }
    
    @Override
    public void start() {
        System.out.println("Electric motor starting silently");
    }
    
    @Override
    public void stop() {
        System.out.println("Electric motor stopping");
    }
    
    @Override
    public int getHorsepower() {
        return horsepower;
    }
}

interface Transmission {
    void changeGear(int gear);
    String getType();
}

class ManualTransmission implements Transmission {
    private int currentGear = 0;
    
    @Override
    public void changeGear(int gear) {
        if (gear < 0 || gear > 6) {
            throw new IllegalArgumentException("Invalid gear");
        }
        currentGear = gear;
        System.out.println("Shifted to gear: " + gear);
    }
    
    @Override
    public String getType() {
        return "Manual";
    }
}

class AutomaticTransmission implements Transmission {
    private int currentGear = 0;
    
    @Override
    public void changeGear(int gear) {
        currentGear = gear;
        System.out.println("Automatically shifted to gear: " + gear);
    }
    
    @Override
    public String getType() {
        return "Automatic";
    }
}

// No transmission for electric
class NoTransmission implements Transmission {
    @Override
    public void changeGear(int gear) {
        System.out.println("No gears in electric vehicle");
    }
    
    @Override
    public String getType() {
        return "None";
    }
}

// Car using composition
public class Car {
    private String brand;
    private String model;
    private Engine engine;
    private Transmission transmission;
    
    public Car(String brand, String model, Engine engine, Transmission transmission) {
        this.brand = brand;
        this.model = model;
        this.engine = engine;
        this.transmission = transmission;
    }
    
    public void start() {
        System.out.println("Starting " + brand + " " + model);
        engine.start();
    }
    
    public void stop() {
        engine.stop();
    }
    
    public void changeGear(int gear) {
        transmission.changeGear(gear);
    }
    
    public void displayInfo() {
        System.out.println(brand + " " + model);
        System.out.println("Engine: " + engine.getHorsepower() + " HP");
        System.out.println("Transmission: " + transmission.getType());
    }
    
    // Can change components at runtime!
    public void replaceEngine(Engine newEngine) {
        System.out.println("Replacing engine...");
        this.engine = newEngine;
    }
}

// Usage
public class CarDemo {
    public static void main(String[] args) {
        // Petrol manual car
        Car manualCar = new Car(
            "Honda",
            "Civic",
            new PetrolEngine(150),
            new ManualTransmission()
        );
        manualCar.displayInfo();
        manualCar.start();
        manualCar.changeGear(1);
        manualCar.changeGear(2);
        
        System.out.println("\n---\n");
        
        // Electric car
        Car electricCar = new Car(
            "Tesla",
            "Model 3",
            new ElectricMotor(300),
            new NoTransmission()
        );
        electricCar.displayInfo();
        electricCar.start();
        electricCar.changeGear(1);  // Does nothing
        
        System.out.println("\n---\n");
        
        // Can replace components
        manualCar.replaceEngine(new PetrolEngine(200));
        manualCar.start();
    }
}
```

### Example 2: Employee System

**Bad Design (Inheritance):**

```java
class Employee {
    protected String name;
    protected double baseSalary;
    
    public double calculateSalary() {
        return baseSalary;
    }
    
    public void checkEmail() {
        System.out.println("Checking company email");
    }
}

class Manager extends Employee {
    private double bonus;
    
    @Override
    public double calculateSalary() {
        return baseSalary + bonus;
    }
}

// Problem: What if we have Manager who is also Engineer?
// Can't extend both Manager and Engineer!
```

**Good Design (Composition):**

```java
// Roles as components
interface Role {
    String getRoleName();
    double calculateBonus(double baseSalary);
    List<String> getResponsibilities();
}

class ManagerRole implements Role {
    private int teamSize;
    
    public ManagerRole(int teamSize) {
        this.teamSize = teamSize;
    }
    
    @Override
    public String getRoleName() {
        return "Manager";
    }
    
    @Override
    public double calculateBonus(double baseSalary) {
        return baseSalary * 0.2 * (teamSize / 5.0);  // 20% bonus per 5 team members
    }
    
    @Override
    public List<String> getResponsibilities() {
        return Arrays.asList(
            "Team management",
            "Performance reviews",
            "Resource allocation"
        );
    }
}

class DeveloperRole implements Role {
    private String expertise;
    
    public DeveloperRole(String expertise) {
        this.expertise = expertise;
    }
    
    @Override
    public String getRoleName() {
        return "Developer (" + expertise + ")";
    }
    
    @Override
    public double calculateBonus(double baseSalary) {
        return baseSalary * 0.15;  // 15% bonus
    }
    
    @Override
    public List<String> getResponsibilities() {
        return Arrays.asList(
            "Code development",
            "Code review",
            "Technical documentation"
        );
    }
}

class ArchitectRole implements Role {
    @Override
    public String getRoleName() {
        return "Architect";
    }
    
    @Override
    public double calculateBonus(double baseSalary) {
        return baseSalary * 0.25;  // 25% bonus
    }
    
    @Override
    public List<String> getResponsibilities() {
        return Arrays.asList(
            "System design",
            "Technology decisions",
            "Performance optimization"
        );
    }
}

// Employee with composition
public class Employee {
    private String name;
    private double baseSalary;
    private List<Role> roles = new ArrayList<>();
    
    public Employee(String name, double baseSalary) {
        this.name = name;
        this.baseSalary = baseSalary;
    }
    
    public void addRole(Role role) {
        roles.add(role);
    }
    
    public void removeRole(Role role) {
        roles.remove(role);
    }
    
    public double calculateTotalSalary() {
        double total = baseSalary;
        for (Role role : roles) {
            total += role.calculateBonus(baseSalary);
        }
        return total;
    }
    
    public void displayInfo() {
        System.out.println("Employee: " + name);
        System.out.println("Base Salary: $" + baseSalary);
        System.out.println("Roles:");
        for (Role role : roles) {
            System.out.println("  - " + role.getRoleName());
            System.out.println("    Bonus: $" + role.calculateBonus(baseSalary));
            System.out.println("    Responsibilities:");
            for (String resp : role.getResponsibilities()) {
                System.out.println("      * " + resp);
            }
        }
        System.out.println("Total Salary: $" + calculateTotalSalary());
    }
}

// Usage
public class CompanyDemo {
    public static void main(String[] args) {
        // Employee with single role
        Employee dev = new Employee("Alice", 80000);
        dev.addRole(new DeveloperRole("Java"));
        dev.displayInfo();
        
        System.out.println("\n---\n");
        
        // Employee with multiple roles (not possible with inheritance!)
        Employee techLead = new Employee("Bob", 100000);
        techLead.addRole(new DeveloperRole("Full Stack"));
        techLead.addRole(new ManagerRole(5));
        techLead.displayInfo();
        
        System.out.println("\n---\n");
        
        // Senior architect who also manages
        Employee seniorArch = new Employee("Charlie", 150000);
        seniorArch.addRole(new ArchitectRole());
        seniorArch.addRole(new ManagerRole(10));
        seniorArch.displayInfo();
        
        // Can change roles at runtime
        System.out.println("\n--- Bob promoted to Architect ---\n");
        techLead.addRole(new ArchitectRole());
        techLead.displayInfo();
    }
}
```

## 5.5 Interview Questions and Answers

### Q1: Why prefer composition over inheritance?

**Answer:**
**Reasons to prefer composition:**

1. **Flexibility**: Change behavior at runtime
2. **Loose Coupling**: Components are independent
3. **Multiple Behaviors**: Can compose multiple capabilities (no diamond problem)
4. **No Fragile Base Class**: Parent changes don't break child
5. **Better Encapsulation**: Don't expose parent's internal details
6. **Easier Testing**: Can mock components easily
7. **Follows Single Responsibility**: Each component has one job

**Example:**
```java
// Inheritance - rigid
class Bird extends Animal {}
class FlyingBird extends Bird {}
// What if bird needs to swim too? Can't extend both Flying and Swimming!

// Composition - flexible
class Bird {
    private MovementBehavior movement;  // Can fly, walk, or swim
    
    public void move() {
        movement.move();
    }
    
    public void setMovement(MovementBehavior behavior) {
        this.movement = behavior;  // Change at runtime!
    }
}
```

### Q2: When should you use inheritance?

**Answer:**
Use inheritance when:

1. **True IS-A relationship**: Child is truly a specialized version of parent
2. **Liskov Substitution Principle**: Child can replace parent everywhere
3. **Shared behavior**: Significant code reuse across hierarchy
4. **Stable hierarchy**: Parent unlikely to change
5. **Framework/Library design**: Providing extension points

**Good inheritance example:**
```java
abstract class Shape {
    abstract double area();
    abstract double perimeter();
}

class Circle extends Shape {
    // Circle IS-A Shape
    // Can replace Shape everywhere
    // Inherits contract
}

class Rectangle extends Shape {
    // Rectangle IS-A Shape
}
```

**Bad inheritance example:**
```java
class Stack extends ArrayList {
    // Stack IS-NOT-A ArrayList
    // Stack has push/pop, ArrayList has get(index)
    // Breaking Liskov Substitution
}

// Better with composition
class Stack {
    private List items = new ArrayList();  // HAS-A list
    public void push(Object item) { items.add(item); }
    public Object pop() { return items.remove(items.size()-1); }
}
```

### Q3: What is delegation?

**Answer:**
**Delegation** is passing responsibility to another object. It's the core technique in composition - your object delegates work to its components.

**Example:**
```java
// Engine interface
interface Engine {
    void start();
    void stop();
}

class V8Engine implements Engine {
    @Override
    public void start() {
        System.out.println("V8 engine roaring to life");
    }
    
    @Override
    public void stop() {
        System.out.println("V8 engine stopping");
    }
}

// Car delegates to Engine
class Car {
    private Engine engine;  // Component
    
    public Car(Engine engine) {
        this.engine = engine;
    }
    
    public void start() {
        System.out.println("Car starting");
        engine.start();  // DELEGATION - Car delegates to Engine
    }
    
    public void stop() {
        engine.stop();  // DELEGATION
        System.out.println("Car stopped");
    }
}

// Usage
Car car = new Car(new V8Engine());
car.start();  // Car doesn't know HOW to start engine, delegates to Engine
```

**Benefits:**
- Loose coupling
- Runtime behavior change
- Better testability (can inject mock engine)

### Q4: Explain Decorator pattern using composition

**Answer:**
**Decorator pattern** adds behavior to objects dynamically using composition instead of inheritance.

**Example - Pizza ordering:**

```java
// Component interface
interface Pizza {
    String getDescription();
    double getCost();
}

// Concrete component
class PlainPizza implements Pizza {
    @Override
    public String getDescription() {
        return "Plain Pizza";
    }
    
    @Override
    public double getCost() {
        return 5.00;
    }
}

// Decorator base
abstract class PizzaDecorator implements Pizza {
    protected Pizza pizza;  // Wraps a pizza
    
    public PizzaDecorator(Pizza pizza) {
        this.pizza = pizza;
    }
}

// Concrete decorators
class CheeseDecorator extends PizzaDecorator {
    public CheeseDecorator(Pizza pizza) {
        super(pizza);
    }
    
    @Override
    public String getDescription() {
        return pizza.getDescription() + ", Extra Cheese";
    }
    
    @Override
    public double getCost() {
        return pizza.getCost() + 1.50;
    }
}

class PepperoniDecorator extends PizzaDecorator {
    public PepperoniDecorator(Pizza pizza) {
        super(pizza);
    }
    
    @Override
    public String getDescription() {
        return pizza.getDescription() + ", Pepperoni";
    }
    
    @Override
    public double getCost() {
        return pizza.getCost() + 2.00;
    }
}

class MushroomDecorator extends PizzaDecorator {
    public MushroomDecorator(Pizza pizza) {
        super(pizza);
    }
    
    @Override
    public String getDescription() {
        return pizza.getDescription() + ", Mushrooms";
    }
    
    @Override
    public double getCost() {
        return pizza.getCost() + 1.00;
    }
}

// Usage
Pizza pizza = new PlainPizza();
System.out.println(pizza.getDescription() + " - $" + pizza.getCost());
// Plain Pizza - $5.0

// Add cheese
pizza = new CheeseDecorator(pizza);
System.out.println(pizza.getDescription() + " - $" + pizza.getCost());
// Plain Pizza, Extra Cheese - $6.5

// Add pepperoni
pizza = new PepperoniDecorator(pizza);
System.out.println(pizza.getDescription() + " - $" + pizza.getCost());
// Plain Pizza, Extra Cheese, Pepperoni - $8.5

// Add mushrooms
pizza = new MushroomDecorator(pizza);
System.out.println(pizza.getDescription() + " - $" + pizza.getCost());
// Plain Pizza, Extra Cheese, Pepperoni, Mushrooms - $9.5
```

**Why better than inheritance?**
- Can add any combination of toppings
- Can add/remove dynamically
- Don't need PepperoniCheesePizza, MushroomPepperoniPizza, etc. classes

### Q5: What is the Liskov Substitution Principle?

**Answer:**
**Liskov Substitution Principle (LSP)**: Objects of a superclass should be replaceable with objects of a subclass without breaking the application.

**Formula**: If S is a subtype of T, then objects of type T can beoted with objects of type S without affecting program correctness.

**Violations:**

```java
// Violation example
class Rectangle {
    protected int width;
    protected int height;
    
    public void setWidth(int width) {
        this.width = width;
    }
    
    public void setHeight(int height) {
        this.height = height;
    }
    
    public int getArea() {
        return width * height;
    }
}

class Square extends Rectangle {
    @Override
    public void setWidth(int width) {
        this.width = width;
        this.height = width;  // Square sides must be equal
    }
    
    @Override
    public void setHeight(int height) {
        this.width = height;  // Square sides must be equal
        this.height = height;
    }
}

// Test
void testRectangle(Rectangle rect) {
    rect.setWidth(5);
    rect.setHeight(4);
    assert rect.getArea() == 20;  // Expected: 20
}

Rectangle rect = new Rectangle();
testRectangle(rect);  // PASS - area is 20

Rectangle square = new Square();
testRectangle(square);  // FAIL - area is 16, not 20!
// Square violated LSP - can't replace Rectangle
```

**Correct design:**
```java
interface Shape {
    int getArea();
}

class Rectangle implements Shape {
    private int width;
    private int height;
    
    public Rectangle(int width, int height) {
        this.width = width;
        this.height = height;
    }
    
    @Override
    public int getArea() {
        return width * height;
    }
    
    // Separate setters
    public void setWidth(int width) {
        this.width = width;
    }
    
    public void setHeight(int height) {
        this.height = height;
    }
}

class Square implements Shape {
    private int side;
    
    public Square(int side) {
        this.side = side;
    }
    
    @Override
    public int getArea() {
        return side * side;
    }
    
    public void setSide(int side) {
        this.side = side;
    }
}

// Now Square and Rectangle are separate, no LSP violation
```

## 5.6 Coding Problems with Solutions

### Problem: Design a Game Character System

**Question:** Design a game character system where characters can have different abilities (attack, defend, heal, cast spell) using composition.

```java
// Ability interfaces
interface AttackAbility {
    int attack();
    String getAttackType();
}

interface DefenseAbility {
    int defend();
    String getDefenseType();
}

interface HealAbility {
    int heal();
    String getHealType();
}

interface MagicAbility {
    int castSpell();
    int getManaCost();
    String getSpellName();
}

// Concrete implementations
class SwordAttack implements AttackAbility {
    @Override
    public int attack() {
        return 50;
    }
    
    @Override
    public String getAttackType() {
        return "Sword Slash";
    }
}

class BowAttack implements AttackAbility {
    @Override
    public int attack() {
        return 40;
    }
    
    @Override
    public String getAttackType() {
        return "Arrow Shot";
    }
}

class MagicAttack implements AttackAbility {
    @Override
    public int attack() {
        return 70;
    }
    
    @Override
    public String getAttackType() {
        return "Magic Blast";
    }
}

class ShieldDefense implements DefenseAbility {
    @Override
    public int defend() {
        return 30;
    }
    
    @Override
    public String getDefenseType() {
        return "Shield Block";
    }
}

class ArmorDefense implements DefenseAbility {
    @Override
    public int defend() {
        return 20;
    }
    
    @Override
    public String getDefenseType() {
        return "Armor Protection";
    }
}

class PotionHeal implements HealAbility {
    @Override
    public int heal() {
        return 30;
    }
    
    @Override
    public String getHealType() {
        return "Health Potion";
    }
}

class MagicHeal implements HealAbility {
    @Override
    public int heal() {
        return 50;
    }
    
    @Override
    public String getHealType() {
        return "Healing Spell";
    }
}

class Fireball implements MagicAbility {
    @Override
    public int castSpell() {
        return 80;
    }
    
    @Override
    public int getManaCost() {
        return 20;
    }
    
    @Override
    public String getSpellName() {
        return "Fireball";
    }
}

class Lightning implements MagicAbility {
    @Override
    public int castSpell() {
        return 100;
    }
    
    @Override
    public int getManaCost() {
        return 30;
    }
    
    @Override
    public String getSpellName() {
        return "Lightning Strike";
    }
}

// Character class using composition
public class GameCharacter {
    private String name;
    private int health;
    private int maxHealth;
    private int mana;
    private int maxMana;
    
    private AttackAbility attackAbility;
    private DefenseAbility defenseAbility;
    private HealAbility healAbility;
    private MagicAbility magicAbility;
    
    public GameCharacter(String name, int maxHealth, int maxMana) {
        this.name = name;
        this.maxHealth = maxHealth;
        this.health = maxHealth;
        this.maxMana = maxMana;
        this.mana = maxMana;
    }
    
    // Setters for abilities
    public void setAttackAbility(AttackAbility ability) {
        this.attackAbility = ability;
    }
    
    public void setDefenseAbility(DefenseAbility ability) {
        this.defenseAbility = ability;
    }
    
    public void setHealAbility(HealAbility ability) {
        this.healAbility = ability;
    }
    
    public void setMagicAbility(MagicAbility ability) {
        this.magicAbility = ability;
    }
    
    // Actions
    public void performAttack(GameCharacter target) {
        if (attackAbility == null) {
            System.out.println(name + " has no attack ability!");
            return;
        }
        
        int damage = attackAbility.attack();
        System.out.println(name + " uses " + attackAbility.getAttackType() + 
                         " dealing " + damage + " damage!");
        target.takeDamage(damage);
    }
    
    public void takeDamage(int damage) {
        int actualDamage = damage;
        
        if (defenseAbility != null) {
            int defense = defenseAbility.defend();
            actualDamage = Math.max(0, damage - defense);
            System.out.println(name + " uses " + defenseAbility.getDefenseType() + 
                             " reducing damage by " + defense);
        }
        
        health = Math.max(0, health - actualDamage);
        System.out.println(name + " takes " + actualDamage + " damage. " +
                         "Health: " + health + "/" + maxHealth);
    }
    
    public void performHeal() {
        if (healAbility == null) {
            System.out.println(name + " has no heal ability!");
            return;
        }
        
        int healAmount = healAbility.heal();
        health = Math.min(maxHealth, health + healAmount);
        System.out.println(name + " uses " + healAbility.getHealType() + 
                         " healing " + healAmount + " HP. Health: " + health + "/" + maxHealth);
    }
    
    public void castSpell(GameCharacter target) {
        if (magicAbility == null) {
            System.out.println(name + " has no magic ability!");
            return;
        }
        
        int manaCost = magicAbility.getManaCost();
        if (mana < manaCost) {
            System.out.println(name + " doesn't have enough mana!");
            return;
        }
        
        mana -= manaCost;
        int damage = magicAbility.castSpell();
        System.out.println(name + " casts " + magicAbility.getSpellName() + 
                         " dealing " + damage + " magical damage! Mana: " + mana + "/" + maxMana);
        target.takeDamage(damage);
    }
    
    public void displayStats() {
        System.out.println("\n=== " + name + " ===");
        System.out.println("Health: " + health + "/" + maxHealth);
        System.out.println("Mana: " + mana + "/" + maxMana);
        System.out.println("Attack: " + (attackAbility != null ? attackAbility.getAttackType() : "None"));
        System.out.println("Defense: " + (defenseAbility != null ? defenseAbility.getDefenseType() : "None"));
        System.out.println("Heal: " + (healAbility != null ? healAbility.getHealType() : "None"));
        System.out.println("Magic: " + (magicAbility != null ? magicAbility.getSpellName() : "None"));
    }
    
    public boolean isAlive() {
        return health > 0;
    }
}

// Character builder for easy creation
class CharacterBuilder {
    public static GameCharacter createWarrior(String name) {
        GameCharacter warrior = new GameCharacter(name, 200, 50);
        warrior.setAttackAbility(new SwordAttack());
        warrior.setDefenseAbility(new ShieldDefense());
        warrior.setHealAbility(new PotionHeal());
        return warrior;
    }
    
    public static GameCharacter createArcher(String name) {
        GameCharacter archer = new GameCharacter(name, 150, 100);
        archer.setAttackAbility(new BowAttack());
        archer.setDefenseAbility(new ArmorDefense());
        archer.setHealAbility(new PotionHeal());
        return archer;
    }
    
    public static GameCharacter createMage(String name) {
        GameCharacter mage = new GameCharacter(name, 100, 200);
        mage.setAttackAbility(new MagicAttack());
        mage.setDefenseAbility(new ArmorDefense());
        mage.setHealAbility(new MagicHeal());
        mage.setMagicAbility(new Fireball());
        return mage;
    }
    
    public static GameCharacter createSorcerer(String name) {
        GameCharacter sorcerer = new GameCharacter(name, 120, 250);
        sorcerer.setAttackAbility(new MagicAttack());
        sorcerer.setHealAbility(new MagicHeal());
        sorcerer.setMagicAbility(new Lightning());
        return sorcerer;
    }
}

// Game simulation
public class GameDemo {
    public static void main(String[] args) {
        GameCharacter warrior = CharacterBuilder.createWarrior("Aragorn");
        GameCharacter mage = CharacterBuilder.createMage("Gandalf");
        
        warrior.displayStats();
        mage.displayStats();
        
        System.out.println("\n=== BATTLE START ===\n");
        
        // Turn 1
        System.out.println("--- Turn 1 ---");
        warrior.performAttack(mage);
        
        System.out.println();
        
        // Turn 2
        System.out.println("--- Turn 2 ---");
        mage.castSpell(warrior);
        
        System.out.println();
        
        // Turn 3
        System.out.println("--- Turn 3 ---");
        warrior.performHeal();
        
        System.out.println();
        
        // Turn 4
        System.out.println("--- Turn 4 ---");
        mage.performAttack(warrior);
        
        warrior.displayStats();
        mage.displayStats();
        
        // Change abilities at runtime!
        System.out.println("\n=== Warrior picks up magic staff! ===");
        warrior.setMagicAbility(new Fireball());
        warrior.displayStats();
        
        System.out.println("\n--- Warrior casts spell ---");
        warrior.castSpell(mage);
    }
}
```

**Key Benefits of This Design:**
1. **Flexibility**: Can mix/match any abilities
2. **Runtime Changes**: Can change abilities during game
3. **Easy Extension**: Add new abilities without modifying characters
4. **No Class Explosion**: Don't need separate class for every combination
5. **Testable**: Can test each ability independently

---

## Summary

✅ **Complete Coverage:**
1. **Encapsulation** - Data hiding, getters/setters, immutability
2. **Inheritance** - All types, IS-A relationship, code reuse
3. **Polymorphism** - Runtime/compile-time, dynamic dispatch
4. **Abstraction** - Abstract classes, interfaces, contracts
5. **Composition vs Inheritance** - HAS-A vs IS-A, flexibility

✅ **Interview Ready:**
- Concept explanations
- Real-world examples
- 25+ interview questions with detailed answers
- Interview traps and edge cases
- 10+ coding problems with complete solutions

✅ **Production-Quality Examples:**
- Banking system
- Payment processing
- Vehicle rental
- Game characters
- Employee management
- File processing
- Plugin system

**Next Topics to Cover:**
- Exception Handling
- Collections Framework
- Generics
- Multithreading
- Java 8+ Features
- Design Patterns
- SOLID Principles

Ready for your interviews! 🚀
