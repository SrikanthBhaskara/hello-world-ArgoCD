# Java Interview Preparation

## Core Java Questions

### 1. What is Java? What are its key features?

**Answer**: Java is a high-level, class-based, object-oriented programming language. Key features:
- **Platform Independent**: Write Once, Run Anywhere (WORA)
- **Object-Oriented**: Based on objects and classes
- **Simple**: Similar to C++, but removes complex features
- **Secure**: No explicit pointers, runs in JVM sandbox
- **Robust**: Strong memory management, exception handling
- **Multithreaded**: Built-in support for concurrent programming
- **Architecture Neutral**: Bytecode can run on any platform

### 2. Difference between JDK, JRE, and JVM?

**Answer**:
- **JVM (Java Virtual Machine)**: Executes Java bytecode, provides runtime environment
- **JRE (Java Runtime Environment)**: JVM + libraries needed to run Java applications
- **JDK (Java Development Kit)**: JRE + development tools (compiler, debugger, etc.)

```
JDK = JRE + Development Tools
JRE = JVM + Libraries
```

### 3. What is the difference between == and equals()?

**Answer**:
```java
String s1 = new String("hello");
String s2 = new String("hello");

s1 == s2;           // false (compares object references)
s1.equals(s2);      // true  (compares object content)

// For primitives, == compares values
int a = 5, b = 5;
a == b;             // true
```

### 4. Explain public static void main(String[] args)

**Answer**:
- `public`: Accessible from anywhere; JVM can call it
- `static`: Can be called without creating an instance
- `void`: Doesn't return any value
- `main`: Entry point of the program
- `String[] args`: Command-line arguments

### 5. Can we overload the main method?

**Answer**: Yes, but JVM will only call `public static void main(String[] args)`.

```java
public class Test {
    // JVM calls this
    public static void main(String[] args) {
        System.out.println("Main method");
        main(5);
    }
    
    // Overloaded version
    public static void main(int x) {
        System.out.println("Overloaded: " + x);
    }
}
```

## OOP Concepts

### 6. What are the four pillars of OOP?

**Answer**:

1. **Encapsulation**: Bundling data and methods, hiding internal details
```java
public class Account {
    private double balance;  // Hidden
    
    public double getBalance() {
        return balance;
    }
    
    public void deposit(double amount) {
        if (amount > 0) balance += amount;
    }
}
```

2. **Inheritance**: Creating new classes from existing ones
```java
class Animal { }
class Dog extends Animal { }
```

3. **Polymorphism**: Same interface, different implementations
```java
class Shape {
    void draw() { }
}
class Circle extends Shape {
    void draw() { /* Circle drawing */ }
}
```

4. **Abstraction**: Hiding complexity, showing only essentials
```java
abstract class Vehicle {
    abstract void start();
}
```

### 7. Difference between Abstract Class and Interface?

| Feature | Abstract Class | Interface |
|---------|---------------|-----------|
| Methods | Can have abstract and concrete | All abstract (Java 8: default, static) |
| Variables | Any type | public static final only |
| Inheritance | Single | Multiple |
| Constructor | Can have | Cannot have |
| Access Modifiers | Any | public only (default: public) |
| When to use | "is-a" relationship | "can-do" relationship |

```java
// Abstract class: partial implementation
abstract class Animal {
    String name;
    abstract void makeSound();
    void sleep() { System.out.println("Sleeping..."); }
}

// Interface: contract
interface Flyable {
    void fly();
}

class Bird extends Animal implements Flyable {
    void makeSound() { System.out.println("Chirp"); }
    public void fly() { System.out.println("Flying"); }
}
```

### 8. What is method overloading and overriding?

**Overloading** (Compile-time polymorphism):
```java
class Calculator {
    int add(int a, int b) { return a + b; }
    double add(double a, double b) { return a + b; }
    int add(int a, int b, int c) { return a + b + c; }
}
```

**Overriding** (Runtime polymorphism):
```java
class Animal {
    void makeSound() { System.out.println("Some sound"); }
}

class Dog extends Animal {
    @Override
    void makeSound() { System.out.println("Bark"); }
}
```

### 9. Can we override static methods?

**Answer**: No, static methods belong to the class, not instances. They are hidden, not overridden.

```java
class Parent {
    static void display() { System.out.println("Parent"); }
}

class Child extends Parent {
    static void display() { System.out.println("Child"); }
}

Parent p = new Child();
p.display();  // Output: "Parent" (method hiding, not overriding)
```

### 10. What is super and this keyword?

**Answer**:
```java
class Parent {
    int x = 10;
    Parent() { System.out.println("Parent constructor"); }
}

class Child extends Parent {
    int x = 20;
    
    Child() {
        super();  // Call parent constructor (must be first)
        System.out.println("Child constructor");
    }
    
    void display() {
        System.out.println(this.x);   // 20 (child's x)
        System.out.println(super.x);  // 10 (parent's x)
    }
}
```

## String and Memory

### 11. Why String is immutable?

**Answer**: Benefits of immutability:
1. **Security**: Prevents modification of sensitive data
2. **Thread Safety**: Can be safely shared between threads
3. **String Pool**: Enables string interning for memory efficiency
4. **Hashcode Caching**: Hashcode can be cached

```java
String s1 = "hello";
String s2 = "hello";  // Points to same object in string pool

s1 = s1 + " world";   // Creates new object, s1 now points to it
// s2 still points to "hello"
```

### 12. Difference between String, StringBuilder, and StringBuffer?

| Feature | String | StringBuilder | StringBuffer |
|---------|--------|--------------|--------------|
| Mutability | Immutable | Mutable | Mutable |
| Thread Safety | Yes | No | Yes (synchronized) |
| Performance | Slow (creates new objects) | Fast | Slower than StringBuilder |
| When to use | Few modifications | Single-threaded, many modifications | Multi-threaded |

```java
// String: creates many objects
String s = "hello";
for (int i = 0; i < 1000; i++) {
    s += i;  // Creates 1000 new String objects!
}

// StringBuilder: better performance
StringBuilder sb = new StringBuilder("hello");
for (int i = 0; i < 1000; i++) {
    sb.append(i);  // Modifies same object
}
```

### 13. What is String Pool?

**Answer**: String Pool is a special memory region in heap where String literals are stored to optimize memory.

```java
String s1 = "hello";        // Created in string pool
String s2 = "hello";        // Reuses same object from pool
String s3 = new String("hello");  // Created in heap (not pool)

System.out.println(s1 == s2);     // true (same object)
System.out.println(s1 == s3);     // false (different objects)
System.out.println(s1.equals(s3)); // true (same content)

// intern() method adds to pool
String s4 = s3.intern();
System.out.println(s1 == s4);     // true
```

## Collections Framework

### 14. Explain ArrayList vs LinkedList

| Feature | ArrayList | LinkedList |
|---------|-----------|------------|
| Internal Structure | Dynamic array | Doubly linked list |
| Access Time | O(1) - fast | O(n) - slow |
| Insert/Delete (middle) | O(n) - slow | O(1) - fast |
| Memory | Less (just data) | More (data + pointers) |
| When to use | Frequent access, rare modification | Frequent insertion/deletion |

```java
// ArrayList: fast access
List<Integer> arrayList = new ArrayList<>();
arrayList.get(1000);  // Very fast

// LinkedList: fast insertion
List<Integer> linkedList = new LinkedList<>();
linkedList.add(0, 999);  // Fast insertion at beginning
```

### 15. HashMap vs Hashtable vs ConcurrentHashMap

| Feature | HashMap | Hashtable | ConcurrentHashMap |
|---------|---------|-----------|-------------------|
| Thread Safety | No | Yes (synchronized) | Yes (segments) |
| Null Key | 1 allowed | Not allowed | Not allowed |
| Null Values | Allowed | Not allowed | Not allowed |
| Performance | Fast | Slow | Moderate |
| Legacy | No | Yes | No (Java 5+) |

```java
// HashMap: not thread-safe, allows null
Map<String, Integer> hashMap = new HashMap<>();
hashMap.put(null, 1);  // OK

// Hashtable: thread-safe (legacy)
Map<String, Integer> hashtable = new Hashtable<>();
// hashtable.put(null, 1);  // NullPointerException

// ConcurrentHashMap: modern thread-safe
Map<String, Integer> concurrentMap = new ConcurrentHashMap<>();
// Segment-level locking for better performance
```

### 16. How does HashMap work internally?

**Answer**: HashMap uses an array of "buckets" and stores key-value pairs in Entry objects.

```
1. hashCode() is calculated for the key
2. Index = hash % array_length
3. Entry is stored at that index
4. If collision occurs, entries are chained (linked list/tree)
```

```java
map.put("key", "value");

// Internally:
// 1. hash = "key".hashCode()
// 2. index = hash % buckets.length
// 3. buckets[index].add(new Entry("key", "value"))
```

### 17. When to use List vs Set vs Map?

**Answer**:
- **List**: Ordered collection, allows duplicates (ArrayList, LinkedList)
- **Set**: Unordered collection, no duplicates (HashSet, TreeSet)
- **Map**: Key-value pairs (HashMap, TreeMap)

```java
// List: Shopping cart (can have duplicate items)
List<String> cart = new ArrayList<>();
cart.add("Apple");
cart.add("Apple");  // Duplicate allowed

// Set: Unique user IDs
Set<Integer> userIds = new HashSet<>();
userIds.add(101);
userIds.add(101);  // Duplicate ignored

// Map: User profiles (ID -> Name)
Map<Integer, String> users = new HashMap<>();
users.put(101, "Alice");
users.put(102, "Bob");
```

## Exception Handling

### 18. Difference between Checked and Unchecked Exceptions?

**Checked Exceptions**: Must be handled or declared (compile-time)
```java
// Must handle with try-catch or throws
public void readFile() throws IOException {
    FileReader fr = new FileReader("file.txt");
}
```

**Unchecked Exceptions**: Runtime exceptions, not mandatory to handle
```java
// Optional to handle
int[] arr = new int[5];
arr[10] = 5;  // ArrayIndexOutOfBoundsException
```

### 19. Can we have try without catch?

**Answer**: Yes, with `finally` or try-with-resources.

```java
// try-finally
try {
    // code
} finally {
    // cleanup
}

// try-with-resources
try (FileReader fr = new FileReader("file.txt")) {
    // Automatically closes resource
} catch (IOException e) {
    // Handle exception
}
```

### 20. What is the difference between throw and throws?

```java
// throw: used to explicitly throw an exception
public void validate(int age) {
    if (age < 18) {
        throw new IllegalArgumentException("Age must be 18+");
    }
}

// throws: declares that method might throw exception
public void readFile() throws IOException {
    FileReader fr = new FileReader("file.txt");
}
```

## Multithreading

### 21. How to create a thread in Java?

**Answer**: Two ways:

```java
// 1. Extend Thread class
class MyThread extends Thread {
    public void run() {
        System.out.println("Thread running");
    }
}
MyThread t = new MyThread();
t.start();

// 2. Implement Runnable interface (preferred)
class MyRunnable implements Runnable {
    public void run() {
        System.out.println("Thread running");
    }
}
Thread t = new Thread(new MyRunnable());
t.start();

// 3. Lambda (Java 8+)
Thread t = new Thread(() -> {
    System.out.println("Thread running");
});
t.start();
```

### 22. Difference between start() and run()?

```java
Thread t = new MyThread();

t.start();  // Creates new thread and calls run()
t.run();    // Executes run() in current thread (no new thread)
```

### 23. What is synchronization?

**Answer**: Ensures only one thread accesses a resource at a time.

```java
class Counter {
    private int count = 0;
    
    // Synchronized method
    public synchronized void increment() {
        count++;
    }
    
    // Synchronized block
    public void decrement() {
        synchronized(this) {
            count--;
        }
    }
}
```

## Java 8+ Features

### 24. What are Lambda Expressions?

**Answer**: Anonymous functions that implement functional interfaces.

```java
// Old way
Runnable r1 = new Runnable() {
    @Override
    public void run() {
        System.out.println("Running");
    }
};

// Lambda
Runnable r2 = () -> System.out.println("Running");

// With parameters
Comparator<Integer> comp = (a, b) -> a.compareTo(b);
```

### 25. What is Stream API?

**Answer**: Functional-style operations on collections.

```java
List<Integer> numbers = Arrays.asList(1, 2, 3, 4, 5);

// Filter and map
List<Integer> result = numbers.stream()
    .filter(n -> n % 2 == 0)
    .map(n -> n * 2)
    .collect(Collectors.toList());
// Result: [4, 8]
```

## Coding Challenges

### 26. Reverse a String

```java
// Method 1: StringBuilder
String reversed = new StringBuilder("hello").reverse().toString();

// Method 2: Manual
public static String reverse(String str) {
    char[] chars = str.toCharArray();
    int left = 0, right = chars.length - 1;
    while (left < right) {
        char temp = chars[left];
        chars[left++] = chars[right];
        chars[right--] = temp;
    }
    return new String(chars);
}
```

### 27. Check if String is Palindrome

```java
public static boolean isPalindrome(String str) {
    int left = 0, right = str.length() - 1;
    while (left < right) {
        if (str.charAt(left++) != str.charAt(right--)) {
            return false;
        }
    }
    return true;
}
```

### 28. Find Duplicate Elements in Array

```java
public static Set<Integer> findDuplicates(int[] arr) {
    Set<Integer> seen = new HashSet<>();
    Set<Integer> duplicates = new HashSet<>();
    
    for (int num : arr) {
        if (!seen.add(num)) {
            duplicates.add(num);
        }
    }
    return duplicates;
}
```

### 29. FizzBuzz

```java
for (int i = 1; i <= 100; i++) {
    if (i % 15 == 0) {
        System.out.println("FizzBuzz");
    } else if (i % 3 == 0) {
        System.out.println("Fizz");
    } else if (i % 5 == 0) {
        System.out.println("Buzz");
    } else {
        System.out.println(i);
    }
}
```

### 30. Fibonacci Series

```java
// Iterative
public static int fibonacci(int n) {
    if (n <= 1) return n;
    int a = 0, b = 1;
    for (int i = 2; i <= n; i++) {
        int temp = a + b;
        a = b;
        b = temp;
    }
    return b;
}

// Recursive
public static int fibRecursive(int n) {
    if (n <= 1) return n;
    return fibRecursive(n - 1) + fibRecursive(n - 2);
}
```

## Interview Tips

### Preparation Checklist

- ✅ Core Java concepts (OOP, Collections, Exceptions)
- ✅ Data structures (Array, LinkedList, Tree, HashMap)
- ✅ Algorithms (Sorting, Searching, Recursion)
- ✅ Multithreading basics
- ✅ Java 8+ features (Lambda, Stream, Optional)
- ✅ Design patterns (Singleton, Factory, Observer)
- ✅ Spring Framework basics (if applicable)
- ✅ Database concepts (SQL, JDBC)
- ✅ REST APIs
- ✅ Testing (JUnit)

### Common Behavioral Questions

1. **Tell me about yourself**
   - Brief professional summary
   - Highlight relevant experience
   - Express enthusiasm for role

2. **Why Java?**
   - Platform independence
   - Strong ecosystem
   - Enterprise adoption
   - Continuous evolution

3. **Most challenging project?**
   - Describe the problem
   - Your solution
   - Technologies used
   - Outcome and learnings

### During Interview

- **Clarify requirements** before coding
- **Think out loud** - explain your approach
- **Test your code** with examples
- **Handle edge cases** (null, empty, negative numbers)
- **Optimize** if possible (time/space complexity)
- **Ask questions** about the role and team

---

**Quick Review**: [Java Collections Cheat Sheet](java-28-collections-cheatsheet.md) | [Command Cheat Sheet](java-27-command-cheatsheet.md)
