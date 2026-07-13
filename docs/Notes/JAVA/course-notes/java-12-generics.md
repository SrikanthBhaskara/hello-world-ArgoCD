# Java Generics

## Why Generics?

### Before Generics (Java 1.4 and earlier)

```java
// Type-unsafe collection
List list = new ArrayList();
list.add("Hello");
list.add(123);
list.add(new Date());

// Runtime error - no compile-time checking!
String str = (String) list.get(1);  // ClassCastException!
```

### With Generics

```java
// Type-safe collection
List<String> list = new ArrayList<>();
list.add("Hello");
list.add("World");
// list.add(123);  // Compile-time error!

String str = list.get(0);  // No cast needed!
```

## Generic Classes

### Basic Generic Class

```java
public class Box<T> {
    private T content;
    
    public void set(T content) {
        this.content = content;
    }
    
    public T get() {
        return content;
    }
    
    public static void main(String[] args) {
        // Box of String
        Box<String> stringBox = new Box<>();
        stringBox.set("Hello");
        String str = stringBox.get();
        
        // Box of Integer
        Box<Integer> intBox = new Box<>();
        intBox.set(42);
        int num = intBox.get();
    }
}
```

### Multiple Type Parameters

```java
public class Pair<K, V> {
    private K key;
    private V value;
    
    public Pair(K key, V value) {
        this.key = key;
        this.value = value;
    }
    
    public K getKey() { return key; }
    public V getValue() { return value; }
    
    public void setKey(K key) { this.key = key; }
    public void setValue(V value) { this.value = value; }
    
    @Override
    public String toString() {
        return key + "=" + value;
    }
}

// Usage
Pair<String, Integer> pair = new Pair<>("Age", 25);
System.out.println(pair);  // Age=25
```

### Generic Stack Implementation

```java
public class Stack<T> {
    private List<T> elements = new ArrayList<>();
    
    public void push(T item) {
        elements.add(item);
    }
    
    public T pop() {
        if (isEmpty()) {
            throw new EmptyStackException();
        }
        return elements.remove(elements.size() - 1);
    }
    
    public T peek() {
        if (isEmpty()) {
            throw new EmptyStackException();
        }
        return elements.get(elements.size() - 1);
    }
    
    public boolean isEmpty() {
        return elements.isEmpty();
    }
    
    public int size() {
        return elements.size();
    }
}

// Usage
Stack<String> stack = new Stack<>();
stack.push("First");
stack.push("Second");
System.out.println(stack.pop());  // Second
```

## Generic Methods

### Basic Generic Method

```java
public class GenericMethods {
    // Generic method
    public static <T> void printArray(T[] array) {
        for (T element : array) {
            System.out.print(element + " ");
        }
        System.out.println();
    }
    
    public static void main(String[] args) {
        Integer[] intArray = {1, 2, 3, 4, 5};
        String[] strArray = {"A", "B", "C"};
        
        printArray(intArray);  // 1 2 3 4 5
        printArray(strArray);  // A B C
    }
}
```

### Generic Method with Return Type

```java
public class Utilities {
    // Find maximum element
    public static <T extends Comparable<T>> T max(T a, T b) {
        return a.compareTo(b) > 0 ? a : b;
    }
    
    // Convert array to list
    public static <T> List<T> toList(T[] array) {
        List<T> list = new ArrayList<>();
        for (T element : array) {
            list.add(element);
        }
        return list;
    }
    
    // Swap elements
    public static <T> void swap(T[] array, int i, int j) {
        T temp = array[i];
        array[i] = array[j];
        array[j] = temp;
    }
    
    public static void main(String[] args) {
        System.out.println(max(5, 10));  // 10
        System.out.println(max("apple", "banana"));  // banana
        
        Integer[] nums = {1, 2, 3};
        List<Integer> list = toList(nums);
        
        swap(nums, 0, 2);  // [3, 2, 1]
    }
}
```

## Bounded Type Parameters

### Upper Bound (extends)

```java
// T must be Number or subclass
public class NumberBox<T extends Number> {
    private T number;
    
    public NumberBox(T number) {
        this.number = number;
    }
    
    public double getDouble() {
        return number.doubleValue();  // Can use Number methods
    }
    
    // Generic method with upper bound
    public static <T extends Number> double sum(T a, T b) {
        return a.doubleValue() + b.doubleValue();
    }
}

// Usage
NumberBox<Integer> intBox = new NumberBox<>(42);
NumberBox<Double> doubleBox = new NumberBox<>(3.14);
// NumberBox<String> stringBox = new NumberBox<>("fail");  // Compile error!

System.out.println(NumberBox.sum(10, 20.5));  // 30.5
```

### Multiple Bounds

```java
// T must implement both Comparable and Serializable
public class Processor<T extends Comparable<T> & Serializable> {
    private T data;
    
    public Processor(T data) {
        this.data = data;
    }
    
    public boolean isGreaterThan(T other) {
        return data.compareTo(other) > 0;
    }
    
    public void save() {
        // Can serialize because T implements Serializable
    }
}

// Usage
Processor<String> processor = new Processor<>("Hello");
System.out.println(processor.isGreaterThan("ABC"));  // true
```

## Wildcards

### Unbounded Wildcard (?)

```java
public class WildcardDemo {
    // Accept list of any type
    public static void printList(List<?> list) {
        for (Object elem : list) {
            System.out.print(elem + " ");
        }
        System.out.println();
    }
    
    public static void main(String[] args) {
        List<Integer> intList = Arrays.asList(1, 2, 3);
        List<String> strList = Arrays.asList("A", "B", "C");
        
        printList(intList);  // 1 2 3
        printList(strList);  // A B C
    }
}
```

### Upper Bounded Wildcard (? extends)

```java
public class UpperBoundedWildcard {
    // Accept list of Number or any subclass
    public static double sumOfList(List<? extends Number> list) {
        double sum = 0.0;
        for (Number num : list) {
            sum += num.doubleValue();
        }
        return sum;
    }
    
    public static void main(String[] args) {
        List<Integer> intList = Arrays.asList(1, 2, 3);
        List<Double> doubleList = Arrays.asList(1.5, 2.5, 3.5);
        
        System.out.println(sumOfList(intList));     // 6.0
        System.out.println(sumOfList(doubleList));  // 7.5
    }
}
```

### Lower Bounded Wildcard (? super)

```java
public class LowerBoundedWildcard {
    // Accept list of Integer or any superclass
    public static void addIntegers(List<? super Integer> list) {
        list.add(1);
        list.add(2);
        list.add(3);
    }
    
    public static void main(String[] args) {
        List<Integer> intList = new ArrayList<>();
        List<Number> numList = new ArrayList<>();
        List<Object> objList = new ArrayList<>();
        
        addIntegers(intList);  // OK
        addIntegers(numList);  // OK
        addIntegers(objList);  // OK
        
        System.out.println(intList);  // [1, 2, 3]
    }
}
```

## PECS Principle

**P**roducer **E**xtends, **C**onsumer **S**uper

```java
public class PECSDemo {
    // Producer: use extends (read-only)
    public static void copy(List<? extends Number> source, 
                           List<? super Number> destination) {
        for (Number num : source) {
            destination.add(num);  // Can add to destination
        }
    }
    
    public static void main(String[] args) {
        List<Integer> source = Arrays.asList(1, 2, 3);
        List<Number> dest = new ArrayList<>();
        
        copy(source, dest);
        System.out.println(dest);  // [1, 2, 3]
    }
}

// Collections.copy() uses similar pattern:
// public static <T> void copy(List<? super T> dest, List<? extends T> src)
```

## Type Erasure

### What Happens at Runtime

```java
// Source code
public class Box<T> {
    private T content;
    public T get() { return content; }
    public void set(T content) { this.content = content; }
}

// After type erasure (at runtime)
public class Box {
    private Object content;  // T becomes Object
    public Object get() { return content; }
    public void set(Object content) { this.content = content; }
}

// With bounds: <T extends Number>
// After erasure: T becomes Number
```

### Implications of Type Erasure

```java
public class TypeErasureProblems {
    // CANNOT do these:
    
    // 1. Cannot create generic array
    // T[] array = new T[10];  // Compile error!
    
    // 2. Cannot use instanceof with generic type
    public static <T> boolean isInstance(Object obj) {
        // return obj instanceof T;  // Compile error!
        return false;
    }
    
    // 3. Cannot create instance of type parameter
    public static <T> T createInstance() {
        // return new T();  // Compile error!
        return null;
    }
    
    // 4. Cannot have overloads that differ only in generics
    // public void method(List<String> list) { }
    // public void method(List<Integer> list) { }  // Compile error!
}

// Workarounds
public class TypeErasureWorkarounds {
    // 1. Use ArrayList instead of array
    List<T> list = new ArrayList<>();
    
    // 2. Pass Class object
    public static <T> boolean isInstance(Object obj, Class<T> clazz) {
        return clazz.isInstance(obj);
    }
    
    // 3. Use reflection
    public static <T> T createInstance(Class<T> clazz) 
            throws Exception {
        return clazz. getDeclaredConstructor().newInstance();
    }
}
```

## Generic Interfaces

### Comparable Interface

```java
public class Person implements Comparable<Person> {
    private String name;
    private int age;
    
    public Person(String name, int age) {
        this.name = name;
        this.age = age;
    }
    
    @Override
    public int compareTo(Person other) {
        return Integer.compare(this.age, other.age);
    }
    
    public static void main(String[] args) {
        List<Person> people = new ArrayList<>();
        people.add(new Person("Alice", 30));
        people.add(new Person("Bob", 25));
        people.add(new Person("Charlie", 35));
        
        Collections.sort(people);  // Uses compareTo
        for (Person p : people) {
            System.out.println(p.name + ": " + p.age);
        }
    }
}
```

### Custom Generic Interface

```java
public interface Repository<T> {
    void save(T entity);
    T findById(int id);
    List<T> findAll();
    void delete(T entity);
}

public class UserRepository implements Repository<User> {
    private Map<Integer, User> storage = new HashMap<>();
    
    @Override
    public void save(User user) {
        storage.put(user.getId(), user);
    }
    
    @Override
    public User findById(int id) {
        return storage.get(id);
    }
    
    @Override
    public List<User> findAll() {
        return new ArrayList<>(storage.values());
    }
    
    @Override
    public void delete(User user) {
        storage.remove(user.getId());
    }
}
```

## Practical Examples

### Generic Result Wrapper

```java
public class Result<T> {
    private final T data;
    private final String error;
    private final boolean success;
    
    private Result(T data, String error, boolean success) {
        this.data = data;
        this.error = error;
        this.success = success;
    }
    
    public static <T> Result<T> success(T data) {
        return new Result<>(data, null, true);
    }
    
    public static <T> Result<T> failure(String error) {
        return new Result<>(null, error, false);
    }
    
    public boolean isSuccess() { return success; }
    public T getData() { return data; }
    public String getError() { return error; }
}

// Usage
public Result<User> getUser(int id) {
    try {
        User user = database.findUser(id);
        if (user != null) {
            return Result.success(user);
        } else {
            return Result.failure("User not found");
        }
    } catch (Exception e) {
        return Result.failure(e.getMessage());
    }
}
```

### Generic Cache

```java
public class Cache<K, V> {
    private final Map<K, V> cache = new HashMap<>();
    private final int maxSize;
    
    public Cache(int maxSize) {
        this.maxSize = maxSize;
    }
    
    public void put(K key, V value) {
        if (cache.size() >= maxSize) {
            K firstKey = cache.keySet().iterator().next();
            cache.remove(firstKey);
        }
        cache.put(key, value);
    }
    
    public V get(K key) {
        return cache.get(key);
    }
    
    public boolean containsKey(K key) {
        return cache.containsKey(key);
    }
}

// Usage
Cache<String, User> userCache = new Cache<>(100);
userCache.put("user123", new User("Alice"));
User user = userCache.get("user123");
```

## Quick Reference

```java
// Generic class
public class Box<T> {
    private T content;
}

// Generic method
public <T> void print(T item) { }

// Bounded type
public <T extends Number> void process(T num) { }

// Multiple bounds
public <T extends Class1 & Interface1 & Interface2> void method(T obj) { }

// Wildcard
List<?> list;                    // Unbounded
List<? extends Number> list;     // Upper bounded
List<? super Integer> list;      // Lower bounded

// Generic interface
public interface Repository<T> {
    void save(T entity);
}
```

## Common Generic Patterns

| Pattern | Use Case |
|---------|----------|
| `<T>` | Single type parameter |
| `<E>` | Element in collection |
| `<K, V>` | Key-value pairs |
| `<N>` | Number |
| `<T extends Comparable<T>>` | Sortable type |
| `List<?>` | List of unknown type |
| `List<? extends Number>` | List of Number or subclass |
| `List<? super Integer>` | List of Integer or superclass |

---

**Previous**: [← I/O Streams](java-11-io-streams.md) | **Next**: [Lambda & Functional →](java-13-lambda-functional.md)
