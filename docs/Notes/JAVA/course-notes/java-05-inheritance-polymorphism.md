# Java Inheritance & Polymorphism

## Inheritance Basics

### Extending Classes

```java
// Parent class (superclass/base class)
public class Animal {
    protected String name;
    protected int age;
    
    public Animal(String name, int age) {
        this.name = name;
        this.age = age;
    }
    
    public void eat() {
        System.out.println(name + " is eating");
    }
    
    public void sleep() {
        System.out.println(name + " is sleeping");
    }
}

// Child class (subclass/derived class)
public class Dog extends Animal {
    private String breed;
    
    public Dog(String name, int age, String breed) {
        super(name, age);  // Call parent constructor
        this.breed = breed;
    }
    
    // New method specific to Dog
    public void bark() {
        System.out.println(name + " is barking!");
    }
    
    // Override parent method
    @Override
    public void eat() {
        System.out.println(name + " is eating dog food");
    }
}

//Usage
public class Main {
    public static void main(String[] args) {
        Dog dog = new Dog("Buddy", 3, "Golden Retriever");
        dog.eat();    // is eating dog food (overridden)
        dog.sleep();  // is sleeping (inherited)
        dog.bark();   // is barking! (new method)
    }
}
```

## super Keyword

```java
public class Vehicle {
    protected String brand;
    protected int year;
    
    public Vehicle(String brand, int year) {
        this.brand = brand;
        this.year = year;
    }
    
    public void displayInfo() {
        System.out.println(brand + " - " + year);
    }
}

public class Car extends Vehicle {
    private int doors;
    
    public Car(String brand, int year, int doors) {
        super(brand, year);  // Call parent constructor
        this.doors = doors;
    }
    
    @Override
    public void displayInfo() {
        super.displayInfo();  // Call parent method
        System.out.println("Doors: " + doors);
    }
    
    public void accessParentField() {
        System.out.println(super.brand);  // Access parent field
    }
}
```

## Method Overriding

### Rules for Overriding

```java
public class Parent {
    // Original method
    public void display() {
        System.out.println("Parent display");
    }
    
    // Method with return value
    public String getMessage() {
        return "Parent message";
    }
    
    // Protected method
    protected void protectedMethod() { }
}

public class Child extends Parent {
    // Must have same signature
    @Override  // Recommended annotation
    public void display() {
        System.out.println("Child display");
    }
    
    // Return type can be covariant (subtype)
    @Override
    public String getMessage() {
        return "Child message";
    }
    
    // Access modifier can be less restrictive
    @Override
    public void protectedMethod() {  // protected → public OK
        // private → protected NOT OK
    }
    
    // CANNOT override static methods (method hiding instead)
    // CANNOT override final methods
    // CANNOT override private methods
}
```

### final Keyword

```java
// final class - cannot be extended
public final class FinalClass {
    // Cannot create subclass of FinalClass
}

public class RegularClass {
    // final method - cannot be overridden
    public final void finalMethod() {
        System.out.println("Cannot override this");
    }
    
    // final variable - constant
    public final int CONSTANT = 100;
}
```

## Polymorphism

### Runtime Polymorphism

```java
public class Shape {
    public void draw() {
        System.out.println("Drawing shape");
    }
    
    public double getArea() {
        return 0.0;
    }
}

public class Circle extends Shape {
    private double radius;
    
    public Circle(double radius) {
        this.radius = radius;
    }
    
    @Override
    public void draw() {
        System.out.println("Drawing circle");
    }
    
    @Override
    public double getArea() {
        return Math.PI * radius * radius;
    }
}

public class Rectangle extends Shape {
    private double width;
    private double height;
    
    public Rectangle(double width, double height) {
        this.width = width;
        this.height = height;
    }
    
    @Override
    public void draw() {
        System.out.println("Drawing rectangle");
    }
    
    @Override
    public double getArea() {
        return width * height;
    }
}

// Polymorphism in action
public class Main {
    public static void main(String[] args) {
        // Parent reference, child object
        Shape shape1 = new Circle(5);
        Shape shape2 = new Rectangle(4, 6);
        
        shape1.draw();      // Drawing circle
        shape2.draw();      // Drawing rectangle
        
        System.out.println(shape1.getArea());  // 78.53...
        System.out.println(shape2.getArea());  // 24.0
        
        // Array of shapes
        Shape[] shapes = {
            new Circle(3),
            new Rectangle(4, 5),
            new Circle(7)
        };
        
        for (Shape shape : shapes) {
            shape.draw();
            System.out.println("Area: " + shape.getArea());
        }
    }
}
```

### Compile-time Polymorphism (Method Overloading)

```java
public class Calculator {
    // Same method name, different parameters
    public int add(int a, int b) {
        return a + b;
    }
    
    public double add(double a, double b) {
        return a + b;
    }
    
    public int add(int a, int b, int c) {
        return a + b + c;
    }
}
```

## Type Casting

### Upcasting and Downcasting

```java
public class Animal {
    public void makeSound() {
        System.out.println("Some sound");
    }
}

public class Dog extends Animal {
    @Override
    public void makeSound() {
        System.out.println("Bark");
    }
    
    public void fetch() {
        System.out.println("Fetching...");
    }
}

public class Main {
    public static void main(String[] args) {
        // Upcasting (implicit) - safe
        Animal animal = new Dog();
        animal.makeSound();  // Bark (polymorphism)
        // animal.fetch();   // ERROR: Animal doesn't have fetch()
        
        // Downcasting (explicit) - potentially unsafe
        Dog dog = (Dog) animal;  // Cast to Dog
        dog.fetch();  // Now works
        
        // Check type before casting
        if (animal instanceof Dog) {
            Dog d = (Dog) animal;
            d.fetch();
        }
        
        // Pattern matching (Java 16+)
        if (animal instanceof Dog d) {
            d.fetch();  // 'd' automatically available
        }
    }
}
```

### instanceof Operator

```java
public class TypeCheckDemo {
    public static void processAnimal(Animal animal) {
        if (animal instanceof Dog) {
            Dog dog = (Dog) animal;
            dog.fetch();
        } else if (animal instanceof Cat) {
            Cat cat = (Cat) animal;
            cat.meow();
        }
    }
    
    public static void main(String[] args) {
        Animal a = new Dog("Buddy", 3, "Retriever");
        
        System.out.println(a instanceof Animal);  // true
        System.out.println(a instanceof Dog);     // true
        System.out.println(a instanceof Cat);     // false
        
        // null is not instance of anything
        Animal nullAnimal = null;
        System.out.println(nullAnimal instanceof Animal);  // false
    }
}
```

## Object Class

### Universal Parent Class

```java
// Every class implicitly extends Object
public class MyClass {
    // Inherits these methods from Object:
    // - toString()
    // - equals(Object obj)
    // - hashCode()
    // - getClass()
    // - clone()
    // - finalize() [deprecated]
}
```

### Overriding Object Methods

```java
public class Employee {
    private int id;
    private String name;
    private double salary;
    
    public Employee(int id, String name, double salary) {
        this.id = id;
        this.name = name;
        this.salary = salary;
    }
    
    @Override
    public String toString() {
        return String.format("Employee[id=%d, name=%s, salary=%.2f]", 
                            id, name, salary);
    }
    
    @Override
    public boolean equals(Object obj) {
        if (this == obj) return true;
        if (obj == null || getClass() != obj.getClass()) return false;
        Employee employee = (Employee) obj;
        return id == employee.id;
    }
    
    @Override
    public int hashCode() {
        return Integer.hashCode(id);
    }
}
```

## Abstract Methods and Classes (Preview)

```java
// Abstract class - cannot be instantiated
public abstract class Animal {
    protected String name;
    
    public Animal(String name) {
        this.name = name;
    }
    
    // Abstract method - must be implemented by subclass
    public abstract void makeSound();
    
    // Concrete method - inherited normally
    public void sleep() {
        System.out.println(name + " is sleeping");
    }
}

public class Dog extends Animal {
    public Dog(String name) {
        super(name);
    }
    
    // Must implement abstract method
    @Override
    public void makeSound() {
        System.out.println(name + " barks");
    }
}
```

## Multilevel Inheritance

```java
// Grandparent
public class LivingBeing {
    public void breathe() {
        System.out.println("Breathing...");
    }
}

// Parent
public class Animal extends LivingBeing {
    public void move() {
        System.out.println("Moving...");
    }
}

// Child
public class Dog extends Animal {
    public void bark() {
        System.out.println("Barking...");
    }
}

// Usage
public class Main {
    public static void main(String[] args) {
        Dog dog = new Dog();
        dog.breathe();  // From LivingBeing
        dog.move();     // From Animal
        dog.bark();     // From Dog
    }
}
```

## Method Hiding (Static Methods)

```java
public class Parent {
    public static void staticMethod() {
        System.out.println("Parent static method");
    }
}

public class Child extends Parent {
    // This is method HIDING, not overriding
    public static void staticMethod() {
        System.out.println("Child static method");
    }
}

public class Main {
    public static void main(String[] args) {
        Parent p = new Child();
        p.staticMethod();  // "Parent static method"
        // Static methods are resolved at compile-time!
        
        Child c = new Child();
        c.staticMethod();  // "Child static method"
    }
}
```

## Practical Example: Employee Hierarchy

```java
public class Employee {
    protected String name;
    protected int id;
    protected double baseSalary;
    
    public Employee(String name, int id, double baseSalary) {
        this.name = name;
        this.id = id;
        this.baseSalary = baseSalary;
    }
    
    public double calculateSalary() {
        return baseSalary;
    }
    
    public void displayInfo() {
        System.out.println("ID: " + id);
        System.out.println("Name: " + name);
        System.out.println("Salary: $" + calculateSalary());
    }
}

public class Manager extends Employee {
    private double bonus;
    private int teamSize;
    
    public Manager(String name, int id, double baseSalary, 
                   double bonus, int teamSize) {
        super(name, id, baseSalary);
        this.bonus = bonus;
        this.teamSize = teamSize;
    }
    
    @Override
    public double calculateSalary() {
        return baseSalary + bonus;
    }
    
    @Override
    public void displayInfo() {
        super.displayInfo();
        System.out.println("Team Size: " + teamSize);
        System.out.println("Bonus: $" + bonus);
    }
}

public class Developer extends Employee {
    private String programmingLanguage;
    private int projectsCompleted;
    
    public Developer(String name, int id, double baseSalary,
                    String language, int projects) {
        super(name, id, baseSalary);
        this.programmingLanguage = language;
        this.projectsCompleted = projects;
    }
    
    @Override
    public double calculateSalary() {
        return baseSalary + (projectsCompleted * 500);
    }
    
    @Override
    public void displayInfo() {
        super.displayInfo();
        System.out.println("Language: " + programmingLanguage);
        System.out.println("Projects: " + projectsCompleted);
    }
}

// Usage
public class Main {
    public static void main(String[] args) {
        Employee[] employees = {
            new Manager("Alice", 101, 80000, 20000, 10),
            new Developer("Bob", 102, 70000, "Java", 15),
            new Developer("Charlie", 103, 75000, "Python", 12)
        };
        
        double totalSalary = 0;
        for (Employee emp : employees) {
            emp.displayInfo();
            totalSalary += emp.calculateSalary();
            System.out.println("---");
        }
        
        System.out.println("Total Salary Budget: $" + totalSalary);
    }
}
```

## Best Practices

### Favor Composition Over Inheritance

```java
// Sometimes composition is better than inheritance
public class Engine {
    public void start() {
        System.out.println("Engine starting...");
    }
}

// Composition: Car HAS-AN Engine
public class Car {
    private Engine engine;  // Composition
    
    public Car() {
        this.engine = new Engine();
    }
    
    public void start() {
        engine.start();
    }
}

// vs Inheritance: Car IS-A Vehicle
public class Vehicle { }
public class Car extends Vehicle { }
```

### Liskov Substitution Principle

```java
// Subclass should be substitutable for parent class
// BAD: Square breaks this principle
class Rectangle {
    protected int width;
    protected int height;
    
    public void setWidth(int width) { this.width = width; }
    public void setHeight(int height) { this.height = height; }
    public int getArea() { return width * height; }
}

class Square extends Rectangle {
    @Override
    public void setWidth(int width) {
        this.width = this.height = width;  // Breaks expected behavior!
    }
    
    @Override
    public void setHeight(int height) {
        this.width = this.height = height;  // Breaks expected behavior!
    }
}

// GOOD: Separate hierarchies or use composition
```

## Quick Reference

```java
// Inheritance
class Child extends Parent { }

// super keyword
super();                    // Call parent constructor
super.method();            // Call parent method
super.field;               // Access parent field

// Override method
@Override
public void method() { }

// Polymorphism
Parent obj = new Child();
obj.method();              // Calls Child's version

// Type checking and casting
if (obj instanceof Child) {
    Child child = (Child) obj;
}

// final keyword
final class NoExtend { }   // Cannot extend
final void noOverride() { } // Cannot override
final int CONSTANT = 100;   // Cannot change
```

---

**Previous**: [← Classes & Objects](java-04-classes-objects.md) | **Next**: [Abstraction & Interfaces →](java-06-abstraction-interfaces.md)
