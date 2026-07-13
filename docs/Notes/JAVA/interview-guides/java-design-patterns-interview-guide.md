# DESIGN PATTERNS - COMPLETE INTERVIEW GUIDE

**For 5+ Years Experienced Backend Developers**

---

## TABLE OF CONTENTS

1. [Design Patterns Overview](#1-design-patterns-overview)
2. [Creational Patterns](#2-creational-patterns)
   - Singleton, Factory, Abstract Factory, Builder, Prototype
3. [Structural Patterns](#3-structural-patterns)
   - Adapter, Decorator, Proxy, Facade, Bridge, Composite, Flyweight
4. [Behavioral Patterns](#4-behavioral-patterns)
   - Strategy, Observer, Command, Template Method, Iterator, State, Chain of Responsibility
5. [J2EE/Enterprise Patterns](#5-j2ee-enterprise-patterns)
   - DAO, DTO, Service Locator, MVC, Front Controller
6. [Design Patterns in Spring Framework](#6-design-patterns-in-spring-framework)
7. [SOLID Principles](#7-solid-principles)
8. [Anti-Patterns to Avoid](#8-anti-patterns-to-avoid)
9. [Interview Questions with Answers](#9-interview-questions-with-answers)
10. [Interview Traps & Edge Cases](#10-interview-traps--edge-cases)
11. [Coding Problems with Solutions](#11-coding-problems-with-solutions)
12. [Summary & Quick Reference](#12-summary--quick-reference)

---

# 1. DESIGN PATTERNS OVERVIEW

## 1.1 What are Design Patterns?

**Design Patterns** are reusable solutions to common software design problems.

**Categories:**

```
Creational: Object creation
  - Singleton, Factory, Abstract Factory, Builder, Prototype

Structural: Object composition/structure
  - Adapter, Decorator, Proxy, Facade, Bridge, Composite, Flyweight

Behavioral: Object interaction/communication
  - Strategy, Observer, Command, Template Method, Iterator, State,
    Chain of Responsibility, Mediator, Memento, Visitor
```

## 1.2 When to Use Design Patterns

✅ **Use When:**
- Problem matches pattern exactly
- Improves code readability/maintainability
- Team familiar with pattern
- Future flexibility needed

❌ **Avoid When:**
- Overengineering simple code
- Pattern doesn't fit problem
- Adds unnecessary complexity

---

# 2. CREATIONAL PATTERNS

## 2.1 Singleton Pattern

**Purpose:** Ensure only ONE instance of a class exists.

**Use Cases:**
- Database connection pool
- Configuration manager
- Logger
- Cache

### Eager Initialization (Thread-Safe)

```java
public class ConfigManager {
    // Created at class loading
    private static final ConfigManager INSTANCE = new ConfigManager();
    
    private Properties properties;
    
    private ConfigManager() {
        // Private constructor prevents instantiation
        properties = new Properties();
        loadProperties();
    }
    
    public static ConfigManager getInstance() {
        return INSTANCE;
    }
    
    private void loadProperties() {
        // Load from file
    }
    
    public String getProperty(String key) {
        return properties.getProperty(key);
    }
}

// Usage:
ConfigManager config = ConfigManager.getInstance();
String dbUrl = config.getProperty("db.url");
```

### Lazy Initialization (Thread-Safe - Double-Checked Locking)

```java
public class DatabaseConnection {
    private static volatile DatabaseConnection instance;
    
    private Connection connection;
    
    private DatabaseConnection() {
        // Expensive initialization
        connection = DriverManager.getConnection(DB_URL, USER, PASS);
    }
    
    public static DatabaseConnection getInstance() {
        if (instance == null) {  // First check (no locking)
            synchronized (DatabaseConnection.class) {
                if (instance == null) {  // Second check (with locking)
                    instance = new DatabaseConnection();
                }
            }
        }
        return instance;
    }
    
    public Connection getConnection() {
        return connection;
    }
}
```

### Bill Pugh Singleton (Best - Lazy + Thread-Safe)

```java
public class Logger {
    
    private Logger() {
        // Private constructor
    }
    
    // Inner static class - loaded only when getInstance() called
    private static class SingletonHelper {
        private static final Logger INSTANCE = new Logger();
    }
    
    public static Logger getInstance() {
        return SingletonHelper.INSTANCE;
    }
    
    public void log(String message) {
        System.out.println("[LOG] " + message);
    }
}
```

### Enum Singleton (Best - Thread-Safe + Serialization-Safe)

```java
public enum CacheManager {
    INSTANCE;
    
    private Map<String, Object> cache = new ConcurrentHashMap<>();
    
    public void put(String key, Object value) {
        cache.put(key, value);
    }
    
    public Object get(String key) {
        return cache.get(key);
    }
}

// Usage:
CacheManager.INSTANCE.put("user:1", user);
User user = (User) CacheManager.INSTANCE.get("user:1");
```

**Singleton Problems:**

```java
/**
 * Issues with Singleton:
 * 1. Global state (hard to test)
 * 2. Hidden dependencies (not visible in constructor)
 * 3. Tight coupling
 * 4. Difficult to mock in tests
 * 
 * Better Alternative: Dependency Injection (Spring)
 */

// Instead of Singleton:
public class UserService {
    public User getUser(Long id) {
        ConfigManager config = ConfigManager.getInstance();  // Hidden dependency!
        String url = config.getProperty("api.url");
        // ...
    }
}

// Better: Dependency Injection
@Service
public class UserService {
    private final ConfigManager configManager;
    
    @Autowired
    public UserService(ConfigManager configManager) {
        this.configManager = configManager;  // Explicit dependency
    }
}
```

---

## 2.2 Factory Pattern

**Purpose:** Create objects without specifying exact class.

**Use Cases:**
- Object creation logic complex
- Multiple implementations of interface
- Runtime decision on which class to instantiate

### Simple Factory

```java
// Product interface
public interface Vehicle {
    void drive();
}

// Concrete products
public class Car implements Vehicle {
    @Override
    public void drive() {
        System.out.println("Driving a car");
    }
}

public class Bike implements Vehicle {
    @Override
    public void drive() {
        System.out.println("Riding a bike");
    }
}

public class Truck implements Vehicle {
    @Override
    public void drive() {
        System.out.println("Driving a truck");
    }
}

// Factory
public class VehicleFactory {
    
    public static Vehicle createVehicle(String type) {
        switch (type.toLowerCase()) {
            case "car":
                return new Car();
            case "bike":
                return new Bike();
            case "truck":
                return new Truck();
            default:
                throw new IllegalArgumentException("Unknown vehicle type: " + type);
        }
    }
}

// Usage:
Vehicle vehicle = VehicleFactory.createVehicle("car");
vehicle.drive();  // Driving a car

// Client doesn't know concrete class (Car, Bike, Truck)
```

### Factory Method Pattern

```java
// Product
public interface Payment {
    void processPayment(BigDecimal amount);
}

public class CreditCardPayment implements Payment {
    @Override
    public void processPayment(BigDecimal amount) {
        System.out.println("Processing credit card payment: $" + amount);
    }
}

public class PayPalPayment implements Payment {
    @Override
    public void processPayment(BigDecimal amount) {
        System.out.println("Processing PayPal payment: $" + amount);
    }
}

// Creator (abstract)
public abstract class PaymentProcessor {
    
    public void process(BigDecimal amount) {
        Payment payment = createPayment();  // Factory method
        payment.processPayment(amount);
    }
    
    protected abstract Payment createPayment();  // Subclasses decide
}

// Concrete creators
public class CreditCardProcessor extends PaymentProcessor {
    @Override
    protected Payment createPayment() {
        return new CreditCardPayment();
    }
}

public class PayPalProcessor extends PaymentProcessor {
    @Override
    protected Payment createPayment() {
        return new PayPalPayment();
    }
}

// Usage:
PaymentProcessor processor = new CreditCardProcessor();
processor.process(new BigDecimal("100.00"));

processor = new PayPalProcessor();
processor.process(new BigDecimal("50.00"));
```

---

## 2.3 Abstract Factory Pattern

**Purpose:** Create families of related objects without specifying concrete classes.

**Use Case:** UI components for different platforms (Windows/Mac), Database drivers

```java
// Abstract products
public interface Button {
    void render();
}

public interface Checkbox {
    void render();
}

// Concrete products - Windows
public class WindowsButton implements Button {
    @Override
    public void render() {
        System.out.println("Rendering Windows button");
    }
}

public class WindowsCheckbox implements Checkbox {
    @Override
    public void render() {
        System.out.println("Rendering Windows checkbox");
    }
}

// Concrete products - Mac
public class MacButton implements Button {
    @Override
    public void render() {
        System.out.println("Rendering Mac button");
    }
}

public class MacCheckbox implements Checkbox {
    @Override
    public void render() {
        System.out.println("Rendering Mac checkbox");
    }
}

// Abstract factory
public interface GUIFactory {
    Button createButton();
    Checkbox createCheckbox();
}

// Concrete factories
public class WindowsFactory implements GUIFactory {
    @Override
    public Button createButton() {
        return new WindowsButton();
    }
    
    @Override
    public Checkbox createCheckbox() {
        return new WindowsCheckbox();
    }
}

public class MacFactory implements GUIFactory {
    @Override
    public Button createButton() {
        return new MacButton();
    }
    
    @Override
    public Checkbox createCheckbox() {
        return new MacCheckbox();
    }
}

// Client code
public class Application {
    private Button button;
    private Checkbox checkbox;
    
    public Application(GUIFactory factory) {
        button = factory.createButton();
        checkbox = factory.createCheckbox();
    }
    
    public void render() {
        button.render();
        checkbox.render();
    }
}

// Usage:
String os = System.getProperty("os.name");
GUIFactory factory;

if (os.contains("Windows")) {
    factory = new WindowsFactory();
} else {
    factory = new MacFactory();
}

Application app = new Application(factory);
app.render();
// Renders Windows or Mac components (consistent family)
```

---

## 2.4 Builder Pattern

**Purpose:** Build complex objects step by step.

**Use Cases:**
- Objects with many optional parameters
- Immutable objects
- Complex construction logic

### Classic Builder

```java
public class User {
    // Required parameters
    private final String username;
    private final String email;
    
    // Optional parameters
    private final String firstName;
    private final String lastName;
    private final int age;
    private final String phone;
    private final String address;
    
    private User(Builder builder) {
        this.username = builder.username;
        this.email = builder.email;
        this.firstName = builder.firstName;
        this.lastName = builder.lastName;
        this.age = builder.age;
        this.phone = builder.phone;
        this.address = builder.address;
    }
    
    // Getters only (immutable)
    public String getUsername() { return username; }
    public String getEmail() { return email; }
    // ... other getters
    
    // Builder class
    public static class Builder {
        // Required
        private final String username;
        private final String email;
        
        // Optional (defaults)
        private String firstName = "";
        private String lastName = "";
        private int age = 0;
        private String phone = "";
        private String address = "";
        
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
        
        public Builder phone(String phone) {
            this.phone = phone;
            return this;
        }
        
        public Builder address(String address) {
            this.address = address;
            return this;
        }
        
        public User build() {
            // Validation
            if (age < 0 || age > 150) {
                throw new IllegalArgumentException("Invalid age");
            }
            return new User(this);
        }
    }
}

// Usage:
User user = new User.Builder("john_doe", "john@example.com")
                .firstName("John")
                .lastName("Doe")
                .age(30)
                .phone("555-1234")
                .build();

// Much better than:
// User user = new User("john_doe", "john@example.com", "John", "Doe", 30, "555-1234", "");
```

### Lombok Builder (Simpler)

```java
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class User {
    private String username;
    private String email;
    private String firstName;
    private String lastName;
    private int age;
    private String phone;
}

// Usage:
User user = User.builder()
                .username("john_doe")
                .email("john@example.com")
                .firstName("John")
                .age(30)
                .build();
```

---

## 2.5 Prototype Pattern

**Purpose:** Create new objects by cloning existing objects.

**Use Cases:**
- Object creation expensive
- Avoid repeated database queries
- Configuration objects

```java
// Cloneable product
public abstract class Shape implements Cloneable {
    protected String color;
    protected int x;
    protected int y;
    
    public abstract void draw();
    
    @Override
    public Shape clone() {
        try {
            return (Shape) super.clone();
        } catch (CloneNotSupportedException e) {
            throw new RuntimeException(e);
        }
    }
    
    // Getters and setters
}

public class Circle extends Shape {
    private int radius;
    
    public Circle(String color, int x, int y, int radius) {
        this.color = color;
        this.x = x;
        this.y = y;
        this.radius = radius;
    }
    
    @Override
    public void draw() {
        System.out.println("Drawing Circle: " + color + " at (" + x + "," + y + ") radius=" + radius);
    }
    
    @Override
    public Circle clone() {
        return (Circle) super.clone();
    }
    
    public void setRadius(int radius) {
        this.radius = radius;
    }
}

public class Rectangle extends Shape {
    private int width;
    private int height;
    
    public Rectangle(String color, int x, int y, int width, int height) {
        this.color = color;
        this.x = x;
        this.y = y;
        this.width = width;
        this.height = height;
    }
    
    @Override
    public void draw() {
        System.out.println("Drawing Rectangle: " + color + " at (" + x + "," + y + ") " + width + "x" + height);
    }
    
    @Override
    public Rectangle clone() {
        return (Rectangle) super.clone();
    }
}

// Prototype registry
public class ShapeCache {
    private static Map<String, Shape> shapeMap = new HashMap<>();
    
    public static Shape getShape(String shapeId) {
        Shape cachedShape = shapeMap.get(shapeId);
        return cachedShape.clone();  // Clone instead of creating new
    }
    
    public static void loadCache() {
        Circle circle = new Circle("Red", 0, 0, 10);
        shapeMap.put("circle", circle);
        
        Rectangle rectangle = new Rectangle("Blue", 0, 0, 20, 30);
        shapeMap.put("rectangle", rectangle);
    }
}

// Usage:
ShapeCache.loadCache();

Shape shape1 = ShapeCache.getShape("circle");
shape1.draw();  // Drawing Circle: Red at (0,0) radius=10

Shape shape2 = ShapeCache.getShape("circle");
((Circle) shape2).setRadius(20);
shape2.draw();  // Drawing Circle: Red at (0,0) radius=20

shape1.draw();  // Still radius=10 (independent copy)
```

---

# 3. STRUCTURAL PATTERNS

## 3.1 Adapter Pattern

**Purpose:** Make incompatible interfaces work together.

**Use Cases:**
- Legacy code integration
- Third-party library adaptation
- Interface compatibility

```java
// Target interface (what client expects)
public interface MediaPlayer {
    void play(String audioType, String fileName);
}

// Adaptee (existing incompatible interface)
public interface AdvancedMediaPlayer {
    void playVlc(String fileName);
    void playMp4(String fileName);
}

// Concrete adaptee implementations
public class VlcPlayer implements AdvancedMediaPlayer {
    @Override
    public void playVlc(String fileName) {
        System.out.println("Playing VLC file: " + fileName);
    }
    
    @Override
    public void playMp4(String fileName) {
        // Do nothing
    }
}

public class Mp4Player implements AdvancedMediaPlayer {
    @Override
    public void playVlc(String fileName) {
        // Do nothing
    }
    
    @Override
    public void playMp4(String fileName) {
        System.out.println("Playing MP4 file: " + fileName);
    }
}

// Adapter (makes AdvancedMediaPlayer work with MediaPlayer interface)
public class MediaAdapter implements MediaPlayer {
    private AdvancedMediaPlayer advancedPlayer;
    
    public MediaAdapter(String audioType) {
        if (audioType.equalsIgnoreCase("vlc")) {
            advancedPlayer = new VlcPlayer();
        } else if (audioType.equalsIgnoreCase("mp4")) {
            advancedPlayer = new Mp4Player();
        }
    }
    
    @Override
    public void play(String audioType, String fileName) {
        if (audioType.equalsIgnoreCase("vlc")) {
            advancedPlayer.playVlc(fileName);
        } else if (audioType.equalsIgnoreCase("mp4")) {
            advancedPlayer.playMp4(fileName);
        }
    }
}

// Client
public class AudioPlayer implements MediaPlayer {
    private MediaAdapter mediaAdapter;
    
    @Override
    public void play(String audioType, String fileName) {
        // Built-in support for mp3
        if (audioType.equalsIgnoreCase("mp3")) {
            System.out.println("Playing MP3 file: " + fileName);
        }
        // Use adapter for other formats
        else if (audioType.equalsIgnoreCase("vlc") || audioType.equalsIgnoreCase("mp4")) {
            mediaAdapter = new MediaAdapter(audioType);
            mediaAdapter.play(audioType, fileName);
        } else {
            System.out.println("Invalid format: " + audioType);
        }
    }
}

// Usage:
MediaPlayer player = new AudioPlayer();
player.play("mp3", "song.mp3");    // Playing MP3 file: song.mp3
player.play("vlc", "movie.vlc");   // Playing VLC file: movie.vlc
player.play("mp4", "video.mp4");   // Playing MP4 file: video.mp4
```

---

## 3.2 Decorator Pattern

**Purpose:** Add new functionality to objects dynamically without altering structure.

**Use Cases:**
- Add responsibilities to objects at runtime
- Alternative to subclassing
- IO streams, servlet filters

```java
// Component interface
public interface Coffee {
    String getDescription();
    double getCost();
}

// Concrete component
public class SimpleCoffee implements Coffee {
    @Override
    public String getDescription() {
        return "Simple Coffee";
    }
    
    @Override
    public double getCost() {
        return 2.0;
    }
}

// Decorator base class
public abstract class CoffeeDecorator implements Coffee {
    protected Coffee decoratedCoffee;
    
    public CoffeeDecorator(Coffee coffee) {
        this.decoratedCoffee = coffee;
    }
    
    @Override
    public String getDescription() {
        return decoratedCoffee.getDescription();
    }
    
    @Override
    public double getCost() {
        return decoratedCoffee.getCost();
    }
}

// Concrete decorators
public class MilkDecorator extends CoffeeDecorator {
    public MilkDecorator(Coffee coffee) {
        super(coffee);
    }
    
    @Override
    public String getDescription() {
        return decoratedCoffee.getDescription() + ", Milk";
    }
    
    @Override
    public double getCost() {
        return decoratedCoffee.getCost() + 0.5;
    }
}

public class SugarDecorator extends CoffeeDecorator {
    public SugarDecorator(Coffee coffee) {
        super(coffee);
    }
    
    @Override
    public String getDescription() {
        return decoratedCoffee.getDescription() + ", Sugar";
    }
    
    @Override
    public double getCost() {
        return decoratedCoffee.getCost() + 0.2;
    }
}

public class WhipDecorator extends CoffeeDecorator {
    public WhipDecorator(Coffee coffee) {
        super(coffee);
    }
    
    @Override
    public String getDescription() {
        return decoratedCoffee.getDescription() + ", Whip";
    }
    
    @Override
    public double getCost() {
        return decoratedCoffee.getCost() + 0.7;
    }
}

// Usage:
Coffee coffee = new SimpleCoffee();
System.out.println(coffee.getDescription() + " $" + coffee.getCost());
// Simple Coffee $2.0

coffee = new MilkDecorator(coffee);
System.out.println(coffee.getDescription() + " $" + coffee.getCost());
// Simple Coffee, Milk $2.5

coffee = new SugarDecorator(coffee);
System.out.println(coffee.getDescription() + " $" + coffee.getCost());
// Simple Coffee, Milk, Sugar $2.7

coffee = new WhipDecorator(coffee);
System.out.println(coffee.getDescription() + " $" + coffee.getCost());
// Simple Coffee, Milk, Sugar, Whip $3.4

// Real-world: Java IO
BufferedReader reader = new BufferedReader(  // Decorator
    new InputStreamReader(                    // Decorator
        new FileInputStream("file.txt")       // Component
    )
);
```

## 3.3 Proxy Pattern

**Purpose:** Provide placeholder/surrogate for another object to control access.

**Types:**
- **Virtual Proxy**: Lazy initialization
- **Protection Proxy**: Access control
- **Remote Proxy**: Remote object representation
- **Caching Proxy**: Cache results

```java
// Subject interface
public interface Image {
    void display();
}

// Real subject (expensive to create)
public class RealImage implements Image {
    private String filename;
    
    public RealImage(String filename) {
        this.filename = filename;
        loadFromDisk();  // Expensive operation
    }
    
    private void loadFromDisk() {
        System.out.println("Loading image: " + filename);
        // Simulate expensive I/O operation
        try {
            Thread.sleep(1000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }
    
    @Override
    public void display() {
        System.out.println("Displaying " + filename);
    }
}

// Proxy (lazy loading)
public class ProxyImage implements Image {
    private String filename;
    private RealImage realImage;
    
    public ProxyImage(String filename) {
        this.filename = filename;
    }
    
    @Override
    public void display() {
        if (realImage == null) {
            realImage = new RealImage(filename);  // Lazy load
        }
        realImage.display();
    }
}

// Usage:
Image image1 = new ProxyImage("photo1.jpg");
Image image2 = new ProxyImage("photo2.jpg");

// Images not loaded yet

image1.display();  // Loading image: photo1.jpg
                   // Displaying photo1.jpg

image1.display();  // Displaying photo1.jpg (already loaded)

// Real-world: Spring AOP uses proxies for @Transactional, @Cacheable, etc.
```

## 3.4 Facade Pattern

**Purpose:** Provide simplified interface to complex subsystem.

```java
// Complex subsystem classes
class CPU {
    public void freeze() { System.out.println("CPU: Freeze"); }
    public void jump(long position) { System.out.println("CPU: Jump to " + position); }
    public void execute() { System.out.println("CPU: Execute"); }
}

class Memory {
    public void load(long position, byte[] data) {
        System.out.println("Memory: Load data at " + position);
    }
}

class HardDrive {
    public byte[] read(long lba, int size) {
        System.out.println("HardDrive: Read " + size + " bytes from " + lba);
        return new byte[size];
    }
}

// Facade
public class ComputerFacade {
    private CPU cpu;
    private Memory memory;
    private HardDrive hardDrive;
    
    public ComputerFacade() {
        this.cpu = new CPU();
        this.memory = new Memory();
        this.hardDrive = new HardDrive();
    }
    
    public void start() {
        cpu.freeze();
        memory.load(0, hardDrive.read(0, 1024));
        cpu.jump(0);
        cpu.execute();
    }
}

// Usage:
ComputerFacade computer = new ComputerFacade();
computer.start();  // Simple interface hides complexity
```

---

# 4. BEHAVIORAL PATTERNS

## 4.1 Strategy Pattern

**Purpose:** Define family of algorithms, make them interchangeable.

```java
// Strategy interface
public interface PaymentStrategy {
    void pay(int amount);
}

// Concrete strategies
public class CreditCardStrategy implements PaymentStrategy {
    private String cardNumber;
    private String cvv;
    
    public CreditCardStrategy(String cardNumber, String cvv) {
        this.cardNumber = cardNumber;
        this.cvv = cvv;
    }
    
    @Override
    public void pay(int amount) {
        System.out.println("Paid $" + amount + " using Credit Card");
    }
}

public class PayPalStrategy implements PaymentStrategy {
    private String email;
    
    public PayPalStrategy(String email) {
        this.email = email;
    }
    
    @Override
    public void pay(int amount) {
        System.out.println("Paid $" + amount + " using PayPal");
    }
}

// Context
public class ShoppingCart {
    private List<Item> items = new ArrayList<>();
    private PaymentStrategy paymentStrategy;
    
    public void addItem(Item item) {
        items.add(item);
    }
    
    public void setPaymentStrategy(PaymentStrategy strategy) {
        this.paymentStrategy = strategy;
    }
    
    public void checkout() {
        int total = items.stream().mapToInt(Item::getPrice).sum();
        paymentStrategy.pay(total);
    }
}

// Usage:
ShoppingCart cart = new ShoppingCart();
cart.addItem(new Item("Book", 20));
cart.addItem(new Item("Pen", 5));

cart.setPaymentStrategy(new CreditCardStrategy("1234-5678", "123"));
cart.checkout();  // Paid $25 using Credit Card

cart.setPaymentStrategy(new PayPalStrategy("user@example.com"));
cart.checkout();  // Paid $25 using PayPal
```

## 4.2 Observer Pattern

**Purpose:** One-to-many dependency notification.

```java
// Observer interface
public interface Observer {
    void update(String message);
}

// Subject interface
public interface Subject {
    void attach(Observer observer);
    void detach(Observer observer);
    void notifyObservers();
}

// Concrete subject
public class NewsAgency implements Subject {
    private List<Observer> observers = new ArrayList<>();
    private String news;
    
    @Override
    public void attach(Observer observer) {
        observers.add(observer);
    }
    
    @Override
    public void detach(Observer observer) {
        observers.remove(observer);
    }
    
    @Override
    public void notifyObservers() {
        for (Observer observer : observers) {
            observer.update(news);
        }
    }
    
    public void setNews(String news) {
        this.news = news;
        notifyObservers();
    }
}

// Concrete observers
public class NewsChannel implements Observer {
    private String name;
    
    public NewsChannel(String name) {
        this.name = name;
    }
    
    @Override
    public void update(String message) {
        System.out.println(name + " received news: " + message);
    }
}

// Usage:
NewsAgency agency = new NewsAgency();

Observer channel1 = new NewsChannel("Channel 1");
Observer channel2 = new NewsChannel("Channel 2");

agency.attach(channel1);
agency.attach(channel2);

agency.setNews("Breaking: New Java version released!");
// Channel 1 received news: Breaking: New Java version released!
// Channel 2 received news: Breaking: New Java version released!
```

## 4.3 Template Method Pattern

**Purpose:** Define algorithm skeleton, let subclasses override steps.

```java
public abstract class DataProcessor {
    
    // Template method
    public final void process() {
        readData();
        processData();
        writeData();
        closeResources();
    }
    
    protected abstract void readData();
    protected abstract void processData();
    protected abstract void writeData();
    
    // Hook (optional override)
    protected void closeResources() {
        System.out.println("Default: Closing resources");
    }
}

public class CSVDataProcessor extends DataProcessor {
    @Override
    protected void readData() {
        System.out.println("Reading data from CSV");
    }
    
    @Override
    protected void processData() {
        System.out.println("Processing CSV data");
    }
    
    @Override
    protected void writeData() {
        System.out.println("Writing data to CSV");
    }
}

public class JSONDataProcessor extends DataProcessor {
    @Override
    protected void readData() {
        System.out.println("Reading data from JSON");
    }
    
    @Override
    protected void processData() {
        System.out.println("Processing JSON data");
    }
    
    @Override
    protected void writeData() {
        System.out.println("Writing data to JSON");
    }
}

// Usage:
DataProcessor processor = new CSVDataProcessor();
processor.process();
// Reading data from CSV
// Processing CSV data
// Writing data to CSV
// Default: Closing resources
```

---

# 5. J2EE/ENTERPRISE PATTERNS

## 5.1 DAO (Data Access Object) Pattern

```java
// Entity
public class User {
    private Long id;
    private String name;
    private String email;
    // Getters and setters
}

// DAO interface
public interface UserDAO {
    User findById(Long id);
    List<User> findAll();
    void save(User user);
    void update(User user);
    void delete(Long id);
}

// DAO implementation
@Repository
public class UserDAOImpl implements UserDAO {
    
    @PersistenceContext
    private EntityManager em;
    
    @Override
    public User findById(Long id) {
        return em.find(User.class, id);
    }
    
    @Override
    public List<User> findAll() {
        return em.createQuery("SELECT u FROM User u", User.class).getResultList();
    }
    
    @Override
    @Transactional
    public void save(User user) {
        em.persist(user);
    }
    
    @Override
    @Transactional
    public void update(User user) {
        em.merge(user);
    }
    
    @Override
    @Transactional
    public void delete(Long id) {
        User user = findById(id);
        if (user != null) {
            em.remove(user);
        }
    }
}

// Service uses DAO
@Service
public class UserService {
    @Autowired
    private UserDAO userDAO;
    
    public User getUser(Long id) {
        return userDAO.findById(id);
    }
}
```

## 5.2 DTO (Data Transfer Object) Pattern

```java
// Entity (Database)
@Entity
public class User {
    @Id
    private Long id;
    private String username;
    private String password;  // Sensitive!
    private String email;
    private LocalDateTime createdAt;
}

// DTO (API)
public class UserDTO {
    private Long id;
    private String username;
    private String email;
    // No password! (security)
    
    public static UserDTO from(User user) {
        UserDTO dto = new UserDTO();
        dto.setId(user.getId());
        dto.setUsername(user.getUsername());
        dto.setEmail(user.getEmail());
        return dto;
    }
}

// Controller
@RestController
@RequestMapping("/users")
public class UserController {
    
    @Autowired
    private UserService userService;
    
    @GetMapping("/{id}")
    public ResponseEntity<UserDTO> getUser(@PathVariable Long id) {
        User user = userService.findById(id);
        return ResponseEntity.ok(UserDTO.from(user));
        // Returns DTO, not entity (no password exposed)
    }
}
```

---

# 6. DESIGN PATTERNS IN SPRING FRAMEWORK

```java
/**
 * Spring uses many design patterns:
 * 
 * 1. Singleton: All beans are singleton by default
 * 
 * 2. Factory: BeanFactory creates beans
 * 
 * 3. Proxy: AOP, @Transactional, @Cacheable use proxies
 * 
 * 4. Template Method: JdbcTemplate, RestTemplate, etc.
 * 
 * 5. Dependency Injection: Core of Spring IoC
 * 
 * 6. Observer: ApplicationEventPublisher
 * 
 * 7. MVC: DispatcherServlet implements Front Controller
 */

// Example: Spring Event (Observer Pattern)
@Component
public class UserRegisteredEvent extends ApplicationEvent {
   private User user;
    
    public UserRegisteredEvent(Object source, User user) {
        super(source);
        this.user = user;
    }
    
    public User getUser() {
        return user;
    }
}

@Component
public class EmailEventListener {
    
    @EventListener
    public void handleUserRegistered(UserRegisteredEvent event) {
        User user = event.getUser();
        sendWelcomeEmail(user);
    }
    
    private void sendWelcomeEmail(User user) {
        System.out.println("Sending welcome email to: " + user.getEmail());
    }
}

@Service
public class UserService {
    
    @Autowired
    private ApplicationEventPublisher eventPublisher;
    
    public User registerUser(User user) {
        // Save user
        userRepository.save(user);
        
        // Publish event
        eventPublisher.publishEvent(new UserRegisteredEvent(this, user));
        
        return user;
    }
}
```

---

# 7. SOLID PRINCIPLES

## 7.1 Single Responsibility Principle (SRP)

```java
// ❌ BAD: Multiple responsibilities
public class User {
    private String name;
    private String email;
    
    public void save() {
        // Database logic
    }
    
    public void sendEmail() {
        // Email logic
    }
    
    public String generateReport() {
        // Reporting logic
    }
}

// ✅ GOOD: Single responsibility per class
public class User {
    private String name;
    private String email;
    // Only user data
}

public class UserRepository {
    public void save(User user) {
        // Database logic only
    }
}

public class EmailService {
    public void sendEmail(User user) {
        // Email logic only
    }
}

public class ReportGenerator {
    public String generateReport(User user) {
        // Reporting logic only
    }
}
```

## 7.2 Open/Closed Principle (OCP)

```java
// Open for extension, closed for modification

// ❌ BAD: Must modify class to add new types
public class PaymentProcessor {
    public void process(String type, double amount) {
        if (type.equals("credit")) {
            // Credit card logic
        } else if (type.equals("paypal")) {
            // PayPal logic
        }
        // Must modify to add new types!
    }
}

// ✅ GOOD: Open for extension
public interface PaymentMethod {
    void process(double amount);
}

public class CreditCardPayment implements PaymentMethod {
    @Override
    public void process(double amount) {
        // Credit card logic
    }
}

public class PayPalPayment implements PaymentMethod {
    @Override
    public void process(double amount) {
        // PayPal logic
    }
}

// Add new method without modifying existing code
public class CryptoPayment implements PaymentMethod {
    @Override
    public void process(double amount) {
        // Crypto logic
    }
}
```

## 7.3 Liskov Substitution Principle (LSP)

```java
// Subtypes must be substitutable for base types

// ❌ BAD: Square breaks Rectangle behavior
public class Rectangle {
    protected int width;
    protected int height;
    
    public void setWidth(int width) { this.width = width; }
    public void setHeight(int height) { this.height = height; }
    public int getArea() { return width * height; }
}

public class Square extends Rectangle {
    @Override
    public void setWidth(int width) {
        this.width = width;
        this.height = width;  // Breaks expectation!
    }
    
    @Override
    public void setHeight(int height) {
        this.width = height;
        this.height = height;
    }
}

// Test fails:
Rectangle rect = new Square();
rect.setWidth(5);
rect.setHeight(10);
assert rect.getArea() == 50;  // FAILS! (returns 100)

// ✅ GOOD: Separate interfaces
public interface Shape {
    int getArea();
}

public class Rectangle implements Shape {
    private int width;
    private int height;
    
    public Rectangle(int width, int height) {
        this.width = width;
        this.height = height;
    }
    
    public int getArea() { return width * height; }
}

public class Square implements Shape {
    private int side;
    
    public Square(int side) {
        this.side = side;
    }
    
    public int getArea() { return side * side; }
}
```

## 7.4 Interface Segregation Principle (ISP)

```java
// Clients shouldn't depend on interfaces they don't use

// ❌ BAD: Fat interface
public interface Worker {
    void work();
    void eat();
    void sleep();
}

public class Human implements Worker {
    public void work() { }
    public void eat() { }
    public void sleep() { }
}

public class Robot implements Worker {
    public void work() { }
    public void eat() { }  // Robots don't eat!
    public void sleep() { }  // Robots don't sleep!
}

// ✅ GOOD: Segregated interfaces
public interface Workable {
    void work();
}

public interface Eatable {
    void eat();
}

public interface Sleepable {
    void sleep();
}

public class Human implements Workable, Eatable, Sleepable {
    public void work() { }
    public void eat() { }
    public void sleep() { }
}

public class Robot implements Workable {
    public void work() { }
    // Only implements what it needs
}
```

## 7.5 Dependency Inversion Principle (DIP)

```java
// Depend on abstractions, not concretions

// ❌ BAD: High-level depends on low-level
public class MySQLDatabase {
    public void save(String data) {
        // MySQL-specific logic
    }
}

public class UserService {
    private MySQLDatabase database = new MySQLDatabase();  // Tight coupling!
    
    public void createUser(User user) {
        database.save(user.toString());
    }
}

// ✅ GOOD: Depend on abstraction
public interface Database {
    void save(String data);
}

public class MySQLDatabase implements Database {
    public void save(String data) {
        // MySQL logic
    }
}

public class MongoDatabase implements Database {
    public void save(String data) {
        // MongoDB logic
    }
}

@Service
public class UserService {
    private final Database database;
    
    @Autowired
    public UserService(Database database) {  // Depends on abstraction
        this.database = database;
    }
    
    public void createUser(User user) {
        database.save(user.toString());
    }
}
```

---

# 8. ANTI-PATTERNS TO AVOID

```java
/**
 * 1. God Object: Class that does everything
 * 2. Spaghetti Code: No structure, hard to maintain
 * 3. Golden Hammer: Using same solution for everything
 * 4. Premature Optimization: Optimizing before knowing bottlenecks
 * 5. Hard Coding: Magic numbers, URLs in code
 * 6. Tight Coupling: Classes depend on concrete implementations
 * 7. Copy-Paste Programming: Duplicate code everywhere
 */

// Anti-pattern: God Object
public class OrderManager {
    public void createOrder() { }
    public void processPayment() { }
    public void sendEmail() { }
    public void updateInventory() { }
    public void generateInvoice() { }
    public void shipOrder() { }
    // Does EVERYTHING!
}

// Better: Single Responsibility
@Service
public class OrderService {
    @Autowired private PaymentService paymentService;
    @Autowired private EmailService emailService;
    @Autowired private InventoryService inventoryService;
    @Autowired private InvoiceService invoiceService;
    @Autowired private ShippingService shippingService;
    
    public void createOrder(Order order) {
        // Delegates to specialized services
    }
}
```

---

# 9. INTERVIEW QUESTIONS WITH ANSWERS

## Q1: When would you use Factory Pattern vs Abstract Factory?

**Answer:**

**Factory Pattern:**
- Creating objects of ONE type
- Simple object creation
- Runtime decision on which class to instantiate

**Abstract Factory:**
- Creating FAMILIES of related objects
- Multiple product types that work together
- Example: UI components (Button + Checkbox) for different platforms

```java
// Factory: Single product type
Vehicle vehicle = VehicleFactory.create("car");

// Abstract Factory: Family of products
GUIFactory factory = new WindowsFactory();
Button button = factory.createButton();
Checkbox checkbox = factory.createCheckbox();
```

---

## Q2: Explain Singleton Pattern thread-safety issues.

**Answer:**

```java
// ❌ NOT thread-safe
public class Singleton {
    private static Singleton instance;
    
    public static Singleton getInstance() {
        if (instance == null) {  // Race condition!
            instance = new Singleton();
        }
        return instance;
    }
}

// ✅ Thread-safe solutions:

// 1. Eager initialization
private static final Singleton INSTANCE = new Singleton();

// 2. Double-checked locking
private static volatile Singleton instance;
public static Singleton getInstance() {
    if (instance == null) {
        synchronized (Singleton.class) {
            if (instance == null) {
                instance = new Singleton();
            }
        }
    }
    return instance;
}

// 3. Enum (best)
public enum Singleton {
    INSTANCE;
}
```

---

# 10. INTERVIEW TRAPS & EDGE CASES

## Trap: Decorator vs Inheritance

❌ **Wrong assumption:** "Decorator is just inheritance"

**Difference:**
- **Inheritance**: Compile-time, static
- **Decorator**: Runtime, dynamic, stackable

```java
// Inheritance: Fixed at compile time
Coffee milkCoffee = new MilkCoffee();

// Decorator: Dynamic at runtime
Coffee coffee = new SimpleCoffee();
coffee = new MilkDecorator(coffee);
coffee = new SugarDecorator(coffee);
coffee = new WhipDecorator(coffee);
// Can add decorators dynamically!
```

---

# 11. CODING PROBLEMS WITH SOLUTIONS

## Problem: Implement Notification System with Strategy

```java
// Strategy interface
public interface NotificationStrategy {
    void send(String message, String recipient);
}

// Strategies
public class EmailNotification implements NotificationStrategy {
    @Override
    public void send(String message, String recipient) {
        System.out.println("Email to " + recipient + ": " + message);
    }
}

public class SMSNotification implements NotificationStrategy {
    @Override
    public void send(String message, String recipient) {
        System.out.println("SMS to " + recipient + ": " + message);
    }
}

public class PushNotification implements NotificationStrategy {
    @Override
    public void send(String message, String recipient) {
        System.out.println("Push to " + recipient + ": " + message);
    }
}

// Context
@Service
public class NotificationService {
    private Map<String, NotificationStrategy> strategies = new HashMap<>();
    
    public NotificationService() {
        strategies.put("email", new EmailNotification());
        strategies.put("sms", new SMSNotification());
        strategies.put("push", new PushNotification());
    }
    
    public void notify(String type, String message, String recipient) {
        NotificationStrategy strategy = strategies.get(type);
        if (strategy != null) {
            strategy.send(message, recipient);
        }
    }
}
```

---

# 12. SUMMARY & QUICK REFERENCE

## Pattern Selection Guide

```
Need one instance? → Singleton
Need flexible object creation? → Factory
Need family of related objects? → Abstract Factory
Need complex object construction? → Builder
Need to clone objects? → Prototype

Need interface compatibility? → Adapter
Need add features dynamically? → Decorator
Need control access? → Proxy
Need simplify complex system? → Facade

Need interchangeable algorithms? → Strategy
Need notify multiple objects? → Observer
Need define algorithm steps? → Template Method
Need encapsulate requests? → Command
```

## SOLID Quick Reference

```
S - Single Responsibility: One reason to change
O - Open/Closed: Open for extension, closed for modification
L - Liskov Substitution: Subtypes must be substitutable
I - Interface Segregation: Small, focused interfaces
D - Dependency Inversion: Depend on abstractions
```

---

**END OF DESIGN PATTERNS INTERVIEW GUIDE**

Master these patterns for clean, maintainable, and scalable code. Essential for senior developer interviews!

**Next Guide:** Microservices Architecture (Topic 4 of 5)