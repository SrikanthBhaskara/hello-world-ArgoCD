# Java Performance Optimization

## Performance Fundamentals

### Measuring Performance

```java
public class PerformanceMeasurement {
    // Simple timing
    public static void measureTime(Runnable operation, String name) {
        long start = System.nanoTime();
        operation.run();
        long duration = System.nanoTime() - start;
        System.out.printf("%s took %d ms%n", name, duration / 1_000_000);
    }
    
    // More accurate benchmarking
    public static long benchmark(Runnable operation, int iterations) {
        // Warm-up
        for (int i = 0; i < iterations / 10; i++) {
            operation.run();
        }
        
        // Measure
        long start = System.nanoTime();
        for (int i = 0; i < iterations; i++) {
            operation.run();
        }
        long duration = System.nanoTime() - start;
        return duration / iterations;  // Average time per operation
    }
    
    public static void main(String[] args) {
        measureTime(() -> {
            List<Integer> list = new ArrayList<>();
            for (int i = 0; i < 100000; i++) {
                list.add(i);
            }
        }, "ArrayList population");
    }
}
```

### JMH (Java Microbenchmark Harness)

```xml
<!-- Maven dependency -->
<dependency>
    <groupId>org.openjdk.jmh</groupId>
    <artifactId>jmh-core</artifactId>
    <version>1.37</version>
</dependency>
<dependency>
    <groupId>org.openjdk.jmh</groupId>
    <artifactId>jmh-generator-annprocess</artifactId>
    <version>1.37</version>
</dependency>
```

```java
import org.openjdk.jmh.annotations.*;
import java.util.concurrent.TimeUnit;

@BenchmarkMode(Mode.AverageTime)
@OutputTimeUnit(TimeUnit.NANOSECONDS)
@State(Scope.Thread)
public class StringConcatenationBenchmark {
    private static final int ITERATIONS = 1000;
    
    @Benchmark
    public String stringConcatenation() {
        String result = "";
        for (int i = 0; i < ITERATIONS; i++) {
            result += "a";
        }
        return result;
    }
    
    @Benchmark
    public String stringBuilder() {
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < ITERATIONS; i++) {
            sb.append("a");
        }
        return sb.toString();
    }
    
    @Benchmark
    public String stringBuffer() {
        StringBuffer sb = new StringBuffer();
        for (int i = 0; i < ITERATIONS; i++) {
            sb.append("a");
        }
        return sb.toString();
    }
}
```

## String Performance

### String Concatenation

```java
public class StringPerformance {
    // SLOW: String concatenation in loop
    public String slowConcatenation(List<String> items) {
        String result = "";
        for (String item : items) {
            result += item;  // Creates new String object each time!
        }
        return result;
    }
    
    // FAST: StringBuilder
    public String fastConcatenation(List<String> items) {
        StringBuilder sb = new StringBuilder(items.size() * 10);  // Pre-size
        for (String item : items) {
            sb.append(item);
        }
        return sb.toString();
    }
    
    // FASTEST: String.join() for simple cases
    public String joinStrings(List<String> items) {
        return String.join("", items);
    }
    
    // For small, fixed strings, + is optimized by compiler
    public String simpleConcat(String name, int age) {
        return "Name: " + name + ", Age: " + age;  // OK, optimized to StringBuilder
    }
}
```

### String Comparison

```java
public class StringComparison {
    // SLOW: equals() in loop
    public boolean containsSlow(List<String> list, String target) {
        for (String item : list) {
            if (item.equals(target)) {
                return true;
            }
        }
        return false;
    }
    
    // FAST: Use Set for lookups
    public boolean containsFast(Set<String> set, String target) {
        return set.contains(target);  // O(1) vs O(n)
    }
    
    // String interning for repeated comparisons
    public void stringInterning() {
        String s1 = new String("hello").intern();
        String s2 = "hello";  // From string pool
        
        // Fast reference comparison (instead of content comparison)
        if (s1 == s2) {
            System.out.println("Same reference");
        }
    }
}
```

## Collection Performance

### Choosing the Right Collection

```java
public class CollectionPerformance {
    @Test
    public void arrayListVsLinkedList() {
        int size = 100000;
        
        // ArrayList: Fast random access, slow insertion/deletion at beginning
        List<Integer> arrayList = new ArrayList<>();
        long start = System.nanoTime();
        for (int i = 0; i < size; i++) {
            arrayList.add(i);
        }
        System.out.println("ArrayList add: " + (System.nanoTime() - start) / 1_000_000 + "ms");
        
        start = System.nanoTime();
        arrayList.get(size / 2);
        System.out.println("ArrayList get: " + (System.nanoTime() - start) + "ns");
        
        // LinkedList: Fast insertion/deletion, slow random access
        List<Integer> linkedList = new LinkedList<>();
        start = System.nanoTime();
        for (int i = 0; i < size; i++) {
            linkedList.add(i);
        }
        System.out.println("LinkedList add: " + (System.nanoTime() - start) / 1_000_000 + "ms");
        
        start = System.nanoTime();
        linkedList.get(size / 2);
        System.out.println("LinkedList get: " + (System.nanoTime() - start) + "ns");
    }
    
    @Test
    public void setPerformance() {
        int size = 100000;
        
        // HashSet: O(1) operations, no order
        Set<Integer> hashSet = new HashSet<>();
        measureSetOperations(hashSet, size, "HashSet");
        
        // TreeSet: O(log n) operations, sorted order
        Set<Integer> treeSet = new TreeSet<>();
        measureSetOperations(treeSet, size, "TreeSet");
        
        // LinkedHashSet: O(1) operations, insertion order
        Set<Integer> linkedSet = new LinkedHashSet<>();
        measureSetOperations(linkedSet, size, "LinkedHashSet");
    }
    
    private void measureSetOperations(Set<Integer> set, int size, String name) {
        long start = System.nanoTime();
        for (int i = 0; i < size; i++) {
            set.add(i);
        }
        System.out.println(name + " add: " + (System.nanoTime() - start) / 1_000_000 + "ms");
        
        start = System.nanoTime();
        set.contains(size / 2);
        System.out.println(name + " contains: " + (System.nanoTime() - start) + "ns");
    }
}
```

### Pre-sizing Collections

```java
public class CollectionSizing {
    // BAD: Default size, multiple resizes
    public List<Integer> withoutPresize(int count) {
        List<Integer> list = new ArrayList<>();  // Default capacity: 10
        for (int i = 0; i < count; i++) {
            list.add(i);  // Resizes at 10, 20, 40, 80...
        }
        return list;
    }
    
    // GOOD: Pre-sized, no resizes
    public List<Integer> withPresize(int count) {
        List<Integer> list = new ArrayList<>(count);  // Initial capacity: count
        for (int i = 0; i < count; i++) {
            list.add(i);  // No resizing needed
        }
        return list;
    }
    
    // Maps too
    public Map<String, String> createMap(int expectedSize) {
        // Account for load factor (default 0.75)
        int initialCapacity = (int) (expectedSize / 0.75) + 1;
        return new HashMap<>(initialCapacity);
    }
}
```

## Stream Performance

### When to Use Streams

```java
public class StreamPerformance {
    // For small collections, loops are faster
    public int sumSmallList(List<Integer> numbers) {
        int sum = 0;
        for (int n : numbers) {
            sum += n;
        }
        return sum;
    }
    
    // For large collections or complex operations, streams are competitive
    public int sumLargeList(List<Integer> numbers) {
        return numbers.stream()
            .mapToInt(Integer::intValue)
            .sum();
    }
    
    // Parallel streams for CPU-intensive operations on large collections
    public long parallelSum(List<Integer> numbers) {
        return numbers.parallelStream()
            .mapToLong(Integer::longValue)
            .sum();
    }
    
    // Primitive streams are faster than boxed
    public int primitiveStream(int[] numbers) {
        return IntStream.of(numbers).sum();  // Fast
    }
    
    public int boxedStream(Integer[] numbers) {
        return Arrays.stream(numbers)
            .mapToInt(Integer::intValue)    // Unboxing overhead
            .sum();
    }
}
```

### Stream Optimization

```java
public class StreamOptimization {
    // BAD: Multiple iterations
    public void multipleIterations(List<String> items) {
        long count = items.stream().filter(s -> s.length() > 5).count();
        List<String> upper = items.stream().filter(s -> s.length() > 5)
            .map(String::toUpperCase).toList();
    }
    
    // GOOD: Single iteration
    public void singleIteration(List<String> items) {
        List<String> upper = items.stream()
            .filter(s -> s.length() > 5)
            .map(String::toUpperCase)
            .toList();
        long count = upper.size();
    }
    
    // Use findFirst/findAny with short-circuit
    public Optional<String> findMatch(List<String> items) {
        return items.stream()
            .filter(s -> s.startsWith("A"))
            .findFirst();  // Stops at first match
    }
    
    // Avoid unnecessary boxing/unboxing
    public int sumFast(List<Integer> numbers) {
        return numbers.stream()
            .mapToInt(Integer::intValue)  // Primitive stream
            .sum();
    }
}
```

## Object Creation

### Object Pooling

```java
public class ObjectPool<T> {
    private final Queue<T> pool;
    private final Supplier<T> factory;
    private final int maxSize;
    
    public ObjectPool(Supplier<T> factory, int maxSize) {
        this.factory = factory;
        this.maxSize = maxSize;
        this.pool = new ConcurrentLinkedQueue<>();
    }
    
    public T acquire() {
        T obj = pool.poll();
        return obj != null ? obj : factory.get();
    }
    
    public void release(T obj) {
        if (pool.size() < maxSize) {
            pool.offer(obj);
        }
    }
}

// Usage
ObjectPool<StringBuilder> pool = new ObjectPool<>(StringBuilder::new, 100);

StringBuilder sb = pool.acquire();
try {
    sb.append("Hello");
    // Use sb
} finally {
    sb.setLength(0);  // Reset
    pool.release(sb);
}
```

### Lazy Initialization

```java
public class LazyInitialization {
    // Eager (always created)
    private final ExpensiveObject eager = new ExpensiveObject();
    
    // Lazy (created on first use)
    private ExpensiveObject lazy;
    
    public ExpensiveObject getLazy() {
        if (lazy == null) {
            lazy = new ExpensiveObject();
        }
        return lazy;
    }
    
    // Thread-safe lazy (double-checked locking)
    private volatile ExpensiveObject threadSafe;
    
    public ExpensiveObject getThreadSafe() {
        if (threadSafe == null) {
            synchronized (this) {
                if (threadSafe == null) {
                    threadSafe = new ExpensiveObject();
                }
            }
        }
        return threadSafe;
    }
    
    // Holder pattern (best for singletons)
    private static class Holder {
        static final ExpensiveObject INSTANCE = new ExpensiveObject();
    }
    
    public static ExpensiveObject getInstance() {
        return Holder.INSTANCE;
    }
}
```

## Caching

### Simple Cache

```java
public class SimpleCache<K, V> {
    private final Map<K, V> cache = new ConcurrentHashMap<>();
    private final Function<K, V> loader;
    
    public SimpleCache(Function<K, V> loader) {
        this.loader = loader;
    }
    
    public V get(K key) {
        return cache.computeIfAbsent(key, loader);
    }
    
    public void invalidate(K key) {
        cache.remove(key);
    }
    
    public void clear() {
        cache.clear();
    }
}

// Usage
SimpleCache<String, User> userCache = new SimpleCache<>(
    userId -> database.findUser(userId)
);

User user = userCache.get("user123");  // Loads from DB on first call
User same = userCache.get("user123");  // Returns cached value
```

### Guava Cache

```xml
<dependency>
    <groupId>com.google.guava</groupId>
    <artifactId>guava</artifactId>
    <version>32.1.3-jre</version>
</dependency>
```

```java
import com.google.common.cache.*;

public class GuavaCacheExample {
    private final LoadingCache<String, User> cache = CacheBuilder.newBuilder()
        .maximumSize(1000)                // Max entries
        .expireAfterWrite(10, TimeUnit.MINUTES)  // TTL
        .recordStats()                    // Enable statistics
        .build(new CacheLoader<String, User>() {
            @Override
            public User load(String userId) {
                return database.findUser(userId);
            }
        });
    
    public User getUser(String userId) {
        try {
            return cache.get(userId);
        } catch (ExecutionException e) {
            throw new RuntimeException(e);
        }
    }
    
    public void printStats() {
        CacheStats stats = cache.stats();
        System.out.println("Hits: " + stats.hitCount());
        System.out.println("Misses: " + stats.missCount());
        System.out.println("Hit rate: " + stats.hitRate());
    }
}
```

## I/O Performance

### Buffered I/O

```java
public class IOPerformance {
    // SLOW: Unbuffered
    public void slowRead(String filename) throws IOException {
        try (FileInputStream fis = new FileInputStream(filename)) {
            int data;
            while ((data = fis.read()) != -1) {
                // Process byte
            }
        }
    }
    
    // FAST: Buffered
    public void fastRead(String filename) throws IOException {
        try (BufferedInputStream bis = new BufferedInputStream(
                new FileInputStream(filename))) {
            int data;
            while ((data = bis.read()) != -1) {
                // Process byte
            }
        }
    }
    
    // FASTEST: Read in chunks
    public void chunkRead(String filename) throws IOException {
        try (FileInputStream fis = new FileInputStream(filename)) {
            byte[] buffer = new byte[8192];
            int bytesRead;
            while ((bytesRead = fis.read(buffer)) != -1) {
                // Process buffer
            }
        }
    }
    
    // NIO for large files
    public void nioRead(String filename) throws IOException {
        try (FileChannel channel = FileChannel.open(Path.of(filename))) {
            ByteBuffer buffer = ByteBuffer.allocate(8192);
            while (channel.read(buffer) != -1) {
                buffer.flip();
                // Process buffer
                buffer.clear();
            }
        }
    }
}
```

## Database Performance

### Connection Pooling

```java
// Always use connection pooling!
import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

public class DatabasePerformance {
    private static HikariDataSource dataSource;
    
    static {
        HikariConfig config = new HikariConfig();
        config.setJdbcUrl("jdbc:mysql://localhost:3306/mydb");
        config.setUsername("user");
        config.setPassword("password");
        config.setMaximumPoolSize(10);
        config.setMinimumIdle(5);
        dataSource = new HikariDataSource(config);
    }
    
    public static Connection getConnection() throws SQLException {
        return dataSource.getConnection();
    }
}
```

### Batch Operations

```java
public class BatchOperations {
    // SLOW: Individual inserts
    public void slowInsert(List<User> users) throws SQLException {
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(
                 "INSERT INTO users (name, email) VALUES (?, ?)")) {
            
            for (User user : users) {
                pstmt.setString(1, user.getName());
                pstmt.setString(2, user.getEmail());
                pstmt.executeUpdate();  // One round-trip per user
            }
        }
    }
    
    // FAST: Batch insert
    public void fastInsert(List<User> users) throws SQLException {
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(
                 "INSERT INTO users (name, email) VALUES (?, ?)")) {
            
            conn.setAutoCommit(false);
            
            for (User user : users) {
                pstmt.setString(1, user.getName());
                pstmt.setString(2, user.getEmail());
                pstmt.addBatch();
            }
            
            pstmt.executeBatch();  // One round-trip for all
            conn.commit();
        }
    }
}
```

## JVM Tuning

### Heap Size

```bash
# Set initial and max heap size
java -Xms2g -Xmx4g MyApp

# Young generation size
java -Xmn1g MyApp

# Metaspace (Java 8+)
java -XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=512m MyApp
```

### Garbage Collection

```bash
# G1GC (default Java 9+)
java -XX:+UseG1GC -XX:MaxGCPauseMillis=200 MyApp

# ZGC (low latency, Java 11+)
java -XX:+UseZGC MyApp

# Enable GC logging
java -Xlog:gc*:file=gc.log:time,tags MyApp
```

## Quick Performance Checklist

✅ **Strings**: Use StringBuilder for concatenation in loops  
✅ **Collections**: Pre-size when size is known  
✅ **Streams**: Use primitive streams for numerical operations  
✅ **Objects**: Pool expensive objects, lazy initialization  
✅ **Caching**: Cache expensive computations  
✅ **I/O**: Use buffered streams, read in chunks  
✅ **Database**: Use connection pooling, batch operations  
✅ **Multithreading**: Use thread pools, not raw threads  
✅ **JVM**: Tune heap size and GC for your workload  
✅ **Profiling**: Measure before optimizing, use JMH for micro-benchmarks  

## Common Anti-Patterns

```java
// ❌ String concatenation in loop
String result = "";
for (String s : list) {
    result += s;
}

// ❌ Creating new objects unnecessarily
for (int i = 0; i < 1000; i++) {
    Date date = new Date();  // Reuse or cache!
}

// ❌ Inefficient collection usage
if (list.contains(item)) {  // O(n) for ArrayList
    // Use Set for contains checks: O(1)
}

// ❌ Premature optimization
// Optimize only after profiling shows a bottleneck!
```

---

**Previous**: [← Logging & Debugging](java-24-logging-debugging.md) | **Next**: [Reactive Programming →](java-26-reactive.md)
