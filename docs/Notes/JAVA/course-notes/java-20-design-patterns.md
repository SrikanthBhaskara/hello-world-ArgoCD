# Java Design Patterns

## Creational Patterns

### Singleton

**Purpose**: Ensure a class has only one instance.

```java
// Eager initialization
public class Singleton {
    private static final Singleton INSTANCE = new Singleton();
    
    private Singleton() {
        // Private constructor
    }
    
    public static Singleton getInstance() {
        return INSTANCE;
    }
}

// Lazy initialization (thread-safe)
public class LazySingleton {
    private static volatile LazySingleton instance;
    
    private LazySingleton() {}
    
    public static LazySingleton getInstance() {
        if (instance == null) {
            synchronized (LazySingleton.class) {
                if (instance == null) {
                    instance = new LazySingleton();
                }
            }
        }
        return instance;
    }
}

// Enum (best way)
public enum EnumSingleton {
    INSTANCE;
    
    public void doSomething() {
        System.out.println("Singleton method");
    }
}
```

### Factory Method

**Purpose**: Create objects without specifying exact class.

```java
// Product interface
interface Animal {
    void speak();
}

class Dog implements Animal {
    public void speak() { System.out.println("Woof!"); }
}

class Cat implements Animal {
    public void speak() { System.out.println("Meow!"); }
}

// Factory
class AnimalFactory {
    public static Animal createAnimal(String type) {
        switch (type.toLowerCase()) {
            case "dog": return new Dog();
            case "cat": return new Cat();
            default: throw new IllegalArgumentException("Unknown animal");
        }
    }
}

// Usage
public class FactoryDemo {
    public static void main(String[] args) {
        Animal dog = AnimalFactory.createAnimal("dog");
        dog.speak();  // Woof!
        
        Animal cat = AnimalFactory.createAnimal("cat");
        cat.speak();  // Meow!
    }
}
```

### Builder

**Purpose**: Construct complex objects step by step.

```java
public class Person {
    // Required parameters
    private final String firstName;
    private final String lastName;
    
    // Optional parameters
    private final int age;
    private final String phone;
    private final String address;
    
    private Person(Builder builder) {
        this.firstName = builder.firstName;
        this.lastName = builder.lastName;
        this.age = builder.age;
        this.phone = builder.phone;
        this.address = builder.address;
    }
    
    public static class Builder {
        // Required
        private final String firstName;
        private final String lastName;
        
        // Optional (with defaults)
        private int age = 0;
        private String phone = "";
        private String address = "";
        
        public Builder(String firstName, String lastName) {
            this.firstName = firstName;
            this.lastName = lastName;
        }
        
        public Builder age(int age) {
            this.age = age;
            return this;
        }
        
        public Builder phone(String phone) {
            this.phone = phone;
            return this;
        }
        
        public Builder address(String address) {
            this.address = address;
            return this;
        }
        
        public Person build() {
            return new Person(this);
        }
    }
    
    @Override
    public String toString() {
        return "Person{firstName=" + firstName + ", lastName=" + lastName +
               ", age=" + age + ", phone=" + phone + ", address=" + address + "}";
    }
}

// Usage
public class BuilderDemo {
    public static void main(String[] args) {
        Person person = new Person.Builder("John", "Doe")
            .age(30)
            .phone("123-456-7890")
            .address("123 Main St")
            .build();
        
        System.out.println(person);
    }
}
```

### Prototype

**Purpose**: Clone existing objects.

```java
public abstract class Shape implements Cloneable {
    private String id;
    protected String type;
    
    public abstract void draw();
    
    public String getType() {
        return type;
    }
    
    public String getId() {
        return id;
    }
    
    public void setId(String id) {
        this.id = id;
    }
    
    @Override
    public Object clone() {
        Object clone = null;
        try {
            clone = super.clone();
        } catch (CloneNotSupportedException e) {
            e.printStackTrace();
        }
        return clone;
    }
}

class Circle extends Shape {
    public Circle() {
        type = "Circle";
    }
    
    public void draw() {
        System.out.println("Drawing Circle");
    }
}

class Rectangle extends Shape {
    public Rectangle() {
        type = "Rectangle";
    }
    
    public void draw() {
        System.out.println("Drawing Rectangle");
    }
}

// Usage
public class PrototypeDemo {
    public static void main(String[] args) {
        Circle circle1 = new Circle();
        circle1.setId("1");
        
        Circle circle2 = (Circle) circle1.clone();
        circle2.setId("2");
        
        System.out.println(circle1.getId());  // 1
        System.out.println(circle2.getId());  // 2
    }
}
```

## Structural Patterns

### Adapter

**Purpose**: Make incompatible interfaces work together.

```java
// Target interface
interface MediaPlayer {
    void play(String audioType, String fileName);
}

// Adaptee (incompatible class)
class VLCPlayer {
    public void playVLC(String fileName) {
        System.out.println("Playing VLC file: " + fileName);
    }
}

class MP4Player {
    public void playMP4(String fileName) {
        System.out.println("Playing MP4 file: " + fileName);
    }
}

// Adapter
class MediaAdapter implements MediaPlayer {
    private VLCPlayer vlcPlayer;
    private MP4Player mp4Player;
    
    public MediaAdapter(String audioType) {
        if (audioType.equalsIgnoreCase("vlc")) {
            vlcPlayer = new VLCPlayer();
        } else if (audioType.equalsIgnoreCase("mp4")) {
            mp4Player = new MP4Player();
        }
    }
    
    @Override
    public void play(String audioType, String fileName) {
        if (audioType.equalsIgnoreCase("vlc")) {
            vlcPlayer.playVLC(fileName);
        } else if (audioType.equalsIgnoreCase("mp4")) {
            mp4Player.playMP4(fileName);
        }
    }
}

// Client
class AudioPlayer implements MediaPlayer {
    @Override
    public void play(String audioType, String fileName) {
        if (audioType.equalsIgnoreCase("mp3")) {
            System.out.println("Playing MP3 file: " + fileName);
        } else if (audioType.equalsIgnoreCase("vlc") || 
                   audioType.equalsIgnoreCase("mp4")) {
            MediaAdapter adapter = new MediaAdapter(audioType);
            adapter.play(audioType, fileName);
        } else {
            System.out.println("Invalid format");
        }
    }
}
```

### Decorator

**Purpose**: Add new functionality to objects dynamically.

```java
// Component interface
interface Coffee {
    String getDescription();
    double getCost();
}

// Concrete component
class SimpleCoffee implements Coffee {
    public String getDescription() {
        return "Simple Coffee";
    }
    
    public double getCost() {
        return 2.0;
    }
}

// Decorator
abstract class CoffeeDecorator implements Coffee {
    protected Coffee coffee;
    
    public CoffeeDecorator(Coffee coffee) {
        this.coffee = coffee;
    }
    
    public String getDescription() {
        return coffee.getDescription();
    }
    
    public double getCost() {
        return coffee.getCost();
    }
}

// Concrete decorators
class Milk extends CoffeeDecorator {
    public Milk(Coffee coffee) {
        super(coffee);
    }
    
    public String getDescription() {
        return coffee.getDescription() + ", Milk";
    }
    
    public double getCost() {
        return coffee.getCost() + 0.5;
    }
}

class Sugar extends CoffeeDecorator {
    public Sugar(Coffee coffee) {
        super(coffee);
    }
    
    public String getDescription() {
        return coffee.getDescription() + ", Sugar";
    }
    
    public double getCost() {
        return coffee.getCost() + 0.2;
    }
}

// Usage
public class DecoratorDemo {
    public static void main(String[] args) {
        Coffee coffee = new SimpleCoffee();
        System.out.println(coffee.getDescription() + " $" + coffee.getCost());
        
        coffee = new Milk(coffee);
        System.out.println(coffee.getDescription() + " $" + coffee.getCost());
        
        coffee = new Sugar(coffee);
        System.out.println(coffee.getDescription() + " $" + coffee.getCost());
        // Output: Simple Coffee, Milk, Sugar $2.7
    }
}
```

### Facade

**Purpose**: Provide simplified interface to complex system.

```java
// Complex subsystems
class CPU {
    public void freeze() { System.out.println("CPU freezing..."); }
    public void jump(long position) { System.out.println("CPU jumping to " + position); }
    public void execute() { System.out.println("CPU executing..."); }
}

class Memory {
    public void load(long position, byte[] data) {
        System.out.println("Loading data to memory at " + position);
    }
}

class HardDrive {
    public byte[] read(long lba, int size) {
        System.out.println("Reading " + size + " bytes from sector " + lba);
        return new byte[size];
    }
}

// Facade
class ComputerFacade {
    private CPU cpu;
    private Memory memory;
    private HardDrive hardDrive;
    
    public ComputerFacade() {
        this.cpu = new CPU();
        this.memory = new Memory();
        this.hardDrive = new HardDrive();
    }
    
    public void start() {
        System.out.println("Starting computer...");
        cpu.freeze();
        memory.load(0, hardDrive.read(0, 1024));
        cpu.jump(0);
        cpu.execute();
        System.out.println("Computer started!");
    }
}

// Usage
public class FacadeDemo {
    public static void main(String[] args) {
        ComputerFacade computer = new ComputerFacade();
        computer.start();  // Simple interface to complex startup
    }
}
```

### Proxy

**Purpose**: Control access to another object.

```java
interface Image {
    void display();
}

class RealImage implements Image {
    private String fileName;
    
    public RealImage(String fileName) {
        this.fileName = fileName;
        loadFromDisk();
    }
    
    private void loadFromDisk() {
        System.out.println("Loading " + fileName);
    }
    
    public void display() {
        System.out.println("Displaying " + fileName);
    }
}

// Proxy
class ProxyImage implements Image {
    private RealImage realImage;
    private String fileName;
    
    public ProxyImage(String fileName) {
        this.fileName = fileName;
    }
    
    public void display() {
        if (realImage == null) {
            realImage = new RealImage(fileName);  // Lazy loading
        }
        realImage.display();
    }
}

// Usage
public class ProxyDemo {
    public static void main(String[] args) {
        Image image = new ProxyImage("photo.jpg");
        
        // Image loaded from disk only on first display
        image.display();  // Loading + Displaying
        image.display();  // Only Displaying
    }
}
```

## Behavioral Patterns

### Strategy

**Purpose**: Define family of algorithms, make them interchangeable.

```java
// Strategy interface
interface PaymentStrategy {
    void pay(int amount);
}

// Concrete strategies
class CreditCardPayment implements PaymentStrategy {
    private String cardNumber;
    
    public CreditCardPayment(String cardNumber) {
        this.cardNumber = cardNumber;
    }
    
    public void pay(int amount) {
        System.out.println("Paid $" + amount + " using Credit Card: " + cardNumber);
    }
}

class PayPalPayment implements PaymentStrategy {
    private String email;
    
    public PayPalPayment(String email) {
        this.email = email;
    }
    
    public void pay(int amount) {
        System.out.println("Paid $" + amount + " using PayPal: " + email);
    }
}

// Context
class ShoppingCart {
    private PaymentStrategy paymentStrategy;
    
    public void setPaymentStrategy(PaymentStrategy strategy) {
        this.paymentStrategy = strategy;
    }
    
    public void checkout(int amount) {
        paymentStrategy.pay(amount);
    }
}

// Usage
public class StrategyDemo {
    public static void main(String[] args) {
        ShoppingCart cart = new ShoppingCart();
        
        cart.setPaymentStrategy(new CreditCardPayment("1234-5678"));
        cart.checkout(100);
        
        cart.setPaymentStrategy(new PayPalPayment("user@email.com"));
        cart.checkout(200);
    }
}
```

### Observer

**Purpose**: Notify multiple objects of state changes.

```java
import java.util.*;

// Subject
interface Subject {
    void attach(Observer observer);
    void detach(Observer observer);
    void notifyObservers();
}

// Observer
interface Observer {
    void update(String message);
}

// Concrete subject
class NewsAgency implements Subject {
    private List<Observer> observers = new ArrayList<>();
    private String news;
    
    public void setNews(String news) {
        this.news = news;
        notifyObservers();
    }
    
    public void attach(Observer observer) {
        observers.add(observer);
    }
    
    public void detach(Observer observer) {
        observers.remove(observer);
    }
    
    public void notifyObservers() {
        for (Observer observer : observers) {
            observer.update(news);
        }
    }
}

// Concrete observers
class NewsChannel implements Observer {
    private String name;
    
    public NewsChannel(String name) {
        this.name = name;
    }
    
    public void update(String news) {
        System.out.println(name + " received news: " + news);
    }
}

// Usage
public class ObserverDemo {
    public static void main(String[] args) {
        NewsAgency agency = new NewsAgency();
        
        NewsChannel channel1 = new NewsChannel("Channel 1");
        NewsChannel channel2 = new NewsChannel("Channel 2");
        
        agency.attach(channel1);
        agency.attach(channel2);
        
        agency.setNews("Breaking News!");
        // Output:
        // Channel 1 received news: Breaking News!
        // Channel 2 received news: Breaking News!
    }
}
```

### Template Method

**Purpose**: Define skeleton of algorithm, let subclasses override steps.

```java
abstract class Game {
    // Template method
    public final void play() {
        initialize();
        startPlay();
        endPlay();
    }
    
    abstract void initialize();
    abstract void startPlay();
    abstract void endPlay();
}

class Cricket extends Game {
    void initialize() {
        System.out.println("Cricket: Initialize");
    }
    
    void startPlay() {
        System.out.println("Cricket: Start");
    }
    
    void endPlay() {
        System.out.println("Cricket: End");
    }
}

class Football extends Game {
    void initialize() {
        System.out.println("Football: Initialize");
    }
    
    void startPlay() {
        System.out.println("Football: Start");
    }
    
    void endPlay() {
        System.out.println("Football: End");
    }
}

// Usage
public class TemplateMethodDemo {
    public static void main(String[] args) {
        Game cricket = new Cricket();
        cricket.play();
        
        Game football = new Football();
        football.play();
    }
}
```

### Command

**Purpose**: Encapsulate requests as objects.

```java
// Command interface
interface Command {
    void execute();
    void undo();
}

// Receiver
class Light {
    public void on() {
        System.out.println("Light is ON");
    }
    
    public void off() {
        System.out.println("Light is OFF");
    }
}

// Concrete commands
class LightOnCommand implements Command {
    private Light light;
    
    public LightOnCommand(Light light) {
        this.light = light;
    }
    
    public void execute() {
        light.on();
    }
    
    public void undo() {
        light.off();
    }
}

class LightOffCommand implements Command {
    private Light light;
    
    public LightOffCommand(Light light) {
        this.light = light;
    }
    
    public void execute() {
        light.off();
    }
    
    public void undo() {
        light.on();
    }
}

// Invoker
class RemoteControl {
    private Command command;
    
    public void setCommand(Command command) {
        this.command = command;
    }
    
    public void pressButton() {
        command.execute();
    }
    
    public void pressUndo() {
        command.undo();
    }
}

// Usage
public class CommandDemo {
    public static void main(String[] args) {
        Light light = new Light();
        Command lightOn = new LightOnCommand(light);
        Command lightOff = new LightOffCommand(light);
        
        RemoteControl remote = new RemoteControl();
        
        remote.setCommand(lightOn);
        remote.pressButton();  // Light is ON
        remote.pressUndo();    // Light is OFF
        
        remote.setCommand(lightOff);
        remote.pressButton();  // Light is OFF
    }
}
```

## Quick Reference

### Creational Patterns
- **Singleton**: One instance only
- **Factory**: Create objects without specifying class
- **Builder**: Build complex objects step-by-step
- **Prototype**: Clone existing objects
- **Abstract Factory**: Create families of related objects

### Structural Patterns
- **Adapter**: Make incompatible interfaces compatible
- **Decorator**: Add functionality dynamically
- **Facade**: Simplify complex systems
- **Proxy**: Control access to objects
- **Composite**: Treat individual and composite objects uniformly
- **Bridge**: Separate abstraction from implementation

### Behavioral Patterns
- **Strategy**: Select algorithm at runtime
- **Observer**: Notify dependents of state changes
- **Template Method**: Define algorithm skeleton
- **Command**: Encapsulate requests as objects
- **Iterator**: Access elements sequentially
- **State**: Change behavior based on state
- **Chain of Responsibility**: Pass request along chain

---

**Previous**: [← Testing](java-19-testing.md) | **Next**: [Spring Basics →](java-21-spring-basics.md)
