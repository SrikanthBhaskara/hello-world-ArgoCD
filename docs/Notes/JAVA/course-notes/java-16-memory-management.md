# Java Memory Management & Garbage Collection

## JVM Memory Structure

```
JVM Memory
├── Heap (shared)
│   ├── Young Generation
│   │   ├── Eden Space
│   │   └── Survivor Spaces (S0, S1)
│   └── Old Generation (Tenured)
├── Method Area (shared)
│   ├── Class metadata
│   └── Runtime constant pool
├── Stack (per thread)
│   └── Local variables, method calls
├── PC Register (per thread)
└── Native Method Stack (per thread)
```

## Memory Areas

### Heap Memory

**Young Generation**: Where new objects are created
- **Eden Space**: New objects allocated here
- **Survivor Spaces (S0, S1)**: Objects that survive one GC

**Old Generation**: Long-lived objects

```java
public class MemoryDemo {
    public static void main(String[] args) {
        // Allocated in Eden space
        String str = new String("Hello");
        
        // After surviving GC cycles, moves to Old Generation
        List<String> list = new ArrayList<>();
        for (int i = 0; i < 1000000; i++) {
            list.add("Item " + i);
        }
    }
}
```

### Stack Memory

**Stack**: Stores local variables and method calls (LIFO)

```java
public class StackDemo {
    public static void main(String[] args) {
        int x = 5;           // Stored in stack
        int y = 10;          // Stored in stack
        calculate(x, y);     // Method call on stack
    }
    
    public static int calculate(int a, int b) {
        int result = a + b;  // Local variable in stack
        return result;       // Popped when method returns
    }
}
```

**Stack vs Heap**:
```java
public class MemoryAllocation {
    public static void main(String[] args) {
        int age = 25;                    // Stack: primitive
        String name = "John";            // Stack: reference, Heap: object
        Person person = new Person();    // Stack: reference, Heap: object
        
        method(age, person);
    }
    
    public static void method(int value, Person p) {
        // value and p references are in stack
        // Person object is in heap
    }
}
```

## Garbage Collection

### How GC Works

```java
public class GarbageCollectionDemo {
    public static void main(String[] args) {
        // Object eligible for GC
        String temp = new String("temporary");
        temp = null;  // Now eligible for GC
        
        // Objects referenced are NOT garbage
        String kept = new String("keep this");
        
        // Suggest GC (not guaranteed to run)
        System.gc();
        
        // Force finalization (not recommended)
        System.runFinalization();
    }
}
```

### Object Lifecycle

```java
public class ObjectLifecycle {
    private String data;
    
    public ObjectLifecycle(String data) {
        this.data = data;
        System.out.println("Object created: " + data);
    }
    
    // Called before GC (deprecated since Java 9)
    @Override
    protected void finalize() throws Throwable {
        try {
            System.out.println("Object finalized: " + data);
        } finally {
            super.finalize();
        }
    }
    
    public static void main(String[] args) {
        ObjectLifecycle obj1 = new ObjectLifecycle("Object 1");
        ObjectLifecycle obj2 = new ObjectLifecycle("Object 2");
        
        obj1 = null;  // Eligible for GC
        obj2 = null;  // Eligible for GC
        
        System.gc();  // Suggest GC
        
        try {
            Thread.sleep(1000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }
}
```

## GC Algorithms

### Minor GC vs Major GC

```java
// Minor GC: Cleans Young Generation (fast, frequent)
// Major GC: Cleans Old Generation (slow, infrequent)
// Full GC: Cleans entire heap (slowest)

public class GCTypes {
    public static void main(String[] args) {
        List<byte[]> list = new ArrayList<>();
        
        for (int i = 0; i < 1000; i++) {
            // Creates many short-lived objects (Minor GC)
            String temp = "Temporary " + i;
            
            // Long-lived objects (eventually Major GC)
            if (i % 100 == 0) {
                list.add(new byte[1024 * 1024]);  // 1MB
            }
        }
    }
}
```

### GC Collectors

**Serial GC**: Single thread
```bash
java -XX:+UseSerialGC MyApp
```

**Parallel GC**: Multiple threads (default in Java 8)
```bash
java -XX:+UseParallelGC MyApp
```

**CMS (Concurrent Mark Sweep)**: Low pause time (deprecated Java 9+)
```bash
java -XX:+UseConcMarkSweepGC MyApp
```

**G1GC (Garbage First)**: Default since Java 9
```bash
java -XX:+UseG1GC MyApp
```

**ZGC**: Ultra-low latency (Java 11+)
```bash
java -XX:+UseZGC MyApp
```

**Shenandoah**: Low pause time
```bash
java -XX:+UseShenandoahGC MyApp
```

## Memory Leaks

### Common Causes

```java
// 1. Static collections never released
public class MemoryLeak1 {
    private static List<Object> cache = new ArrayList<>();
    
    public void addToCache(Object obj) {
        cache.add(obj);  // Never removed, grows forever!
    }
}

// 2. Unclosed resources
public class MemoryLeak2 {
    public void readFile(String path) {
        try {
            FileInputStream fis = new FileInputStream(path);
            // fis never closed! Memory leak
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
    
    // FIXED: Use try-with-resources
    public void readFileFixed(String path) {
        try (FileInputStream fis = new FileInputStream(path)) {
            // Auto-closed
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}

// 3. Inner class holding outer reference
public class MemoryLeak3 {
    private byte[] data = new byte[1024 * 1024];  // 1MB
    
    public class InnerClass {
        public void doSomething() {
            // Implicitly holds reference to MemoryLeak3
            // If InnerClass survives, MemoryLeak3 can't be GC'd
        }
    }
    
    // FIXED: Use static inner class
    public static class FixedInnerClass {
        public void doSomething() {
            // No implicit outer reference
        }
    }
}

// 4. Thread-local not cleaned up
public class MemoryLeak4 {
    private static ThreadLocal<byte[]> threadLocal = new ThreadLocal<>();
    
    public void useThreadLocal() {
        threadLocal.set(new byte[1024 * 1024]);
        // Should call threadLocal.remove() when done
    }
    
    public void cleanup() {
        threadLocal.remove();  // Clean up
    }
}

// 5. HashMap with bad hashCode/equals
class BadKey {
    private int value;
    
    public BadKey(int value) {
        this.value = value;
    }
    
    // No hashCode/equals override!
}

public class MemoryLeak5 {
    public static void main(String[] args) {
        Map<BadKey, String> map = new HashMap<>();
        
        for (int i = 0; i < 1000; i++) {
            BadKey key = new BadKey(i);
            map.put(key, "Value " + i);
        }
        
        // Can't retrieve values because new BadKey(0) != original key
        System.out.println(map.get(new BadKey(0)));  // null!
        // All entries leak because we lost references to keys
    }
}
```

### Detecting Memory Leaks

```java
// Monitor memory usage
public class MemoryMonitor {
    public static void printMemoryUsage() {
        Runtime runtime = Runtime.getRuntime();
        
        long maxMemory = runtime.maxMemory();      // Max heap
        long totalMemory = runtime.totalMemory();  // Current heap size
        long freeMemory = runtime.freeMemory();    // Free memory
        long usedMemory = totalMemory - freeMemory;
        
        System.out.println("Max Memory: " + (maxMemory / 1024 / 1024) + " MB");
        System.out.println("Total Memory: " + (totalMemory / 1024 / 1024) + " MB");
        System.out.println("Used Memory: " + (usedMemory / 1024 / 1024) + " MB");
        System.out.println("Free Memory: " + (freeMemory / 1024 / 1024) + " MB");
    }
    
    public static void main(String[] args) {
        printMemoryUsage();
        
        // Allocate memory
        List<byte[]> list = new ArrayList<>();
        for (int i = 0; i < 100; i++) {
            list.add(new byte[1024 * 1024]);  // 1MB each
        }
        
        printMemoryUsage();
    }
}
```

## Memory Management Best Practices

### Object Pooling

```java
public class ObjectPool<T> {
    private final Queue<T> pool = new ConcurrentLinkedQueue<>();
    private final int maxSize;
    private final Supplier<T> factory;
    
    public ObjectPool(int maxSize, Supplier<T> factory) {
        this.maxSize = maxSize;
        this.factory = factory;
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
ObjectPool<StringBuilder> pool = new ObjectPool<>(10, StringBuilder::new);

StringBuilder sb = pool.acquire();
sb.append("Hello");
// Use sb...
sb.setLength(0);  // Reset
pool.release(sb);  // Return to pool
```

### Weak References

```java
import java.lang.ref.*;

public class WeakReferenceDemo {
    public static void main(String[] args) {
        // Strong reference (normal)
        Object strongRef = new Object();
        
        // Weak reference (can be GC'd)
        WeakReference<Object> weakRef = new WeakReference<>(strongRef);
        
        System.out.println("Before GC: " + weakRef.get());  // Not null
        
        strongRef = null;  // Remove strong reference
        System.gc();
        
        System.out.println("After GC: " + weakRef.get());  // null (GC'd)
    }
}

// Cache with weak references
public class WeakCache<K, V> {
    private Map<K, WeakReference<V>> cache = new HashMap<>();
    
    public void put(K key, V value) {
        cache.put(key, new WeakReference<>(value));
    }
    
    public V get(K key) {
        WeakReference<V> ref = cache.get(key);
        if (ref != null) {
            V value = ref.get();
            if (value == null) {
                cache.remove(key);  // Clean up dead reference
            }
            return value;
        }
        return null;
    }
}
```

### Soft References

```java
import java.lang.ref.SoftReference;

// Soft references: GC'd only when memory is low
public class ImageCache {
    private Map<String, SoftReference<BufferedImage>> cache = new HashMap<>();
    
    public BufferedImage getImage(String path) {
        SoftReference<BufferedImage> ref = cache.get(path);
        
        if (ref != null) {
            BufferedImage image = ref.get();
            if (image != null) {
                return image;  // Cache hit
            }
        }
        
        // Load image
        BufferedImage image = loadImageFromDisk(path);
        cache.put(path, new SoftReference<>(image));
        return image;
    }
    
    private BufferedImage loadImageFromDisk(String path) {
        // Load logic
        return null;
    }
}
```

## JVM Tuning

### Heap Size Configuration

```bash
# Set initial heap size
java -Xms512m MyApp

# Set maximum heap size
java -Xmx2g MyApp

# Set both
java -Xms512m -Xmx2g MyApp

# Young generation size
java -Xmn256m MyApp

# Metaspace (Java 8+)
java -XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=256m MyApp

# Stack size per thread
java -Xss512k MyApp
```

### GC Logging

```bash
# Java 8
java -Xlog:gc*:file=gc.log -XX:+PrintGCDetails -XX:+PrintGCDateStamps MyApp

# Java 9+
java -Xlog:gc*:file=gc.log:time,level,tags MyApp

# Verbose GC
java -verbose:gc MyApp
```

### Performance Tuning

```bash
# Use G1GC with specific settings
java -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -XX:G1HeapRegionSize=16m MyApp

# Parallel GC threads
java -XX:ParallelGCThreads=4 MyApp

# Enable native memory tracking
java -XX:NativeMemoryTracking=summary MyApp

# Dump heap on OutOfMemoryError
java -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/tmp/heapdump.hprof MyApp
```

## Monitoring Tools

### Command Line Tools

```bash
# JVM process status
jps

# JVM statistics
jstat -gc <pid> 1000  # Every 1 second

# Heap dump
jmap -dump:format=b,file=heap.bin <pid>

# Heap histogram
jmap -histo <pid>

# Thread dump
jstack <pid>

# JVM info
jinfo <pid>
```

### Programmatic Monitoring

```java
import java.lang.management.*;

public class JVMMonitoring {
    public static void main(String[] args) {
        // Memory usage
        MemoryMXBean memoryBean = ManagementFactory.getMemoryMXBean();
        MemoryUsage heapUsage = memoryBean.getHeapMemoryUsage();
        
        System.out.println("Heap Init: " + heapUsage.getInit());
        System.out.println("Heap Used: " + heapUsage.getUsed());
        System.out.println("Heap Committed: " + heapUsage.getCommitted());
        System.out.println("Heap Max: " + heapUsage.getMax());
        
        // Thread info
        ThreadMXBean threadBean = ManagementFactory.getThreadMXBean();
        System.out.println("Thread Count: " + threadBean.getThreadCount());
        System.out.println("Peak Thread Count: " + threadBean.getPeakThreadCount());
        
        // GC info
        List<GarbageCollectorMXBean> gcBeans = ManagementFactory.getGarbageCollectorMXBeans();
        for (GarbageCollectorMXBean gcBean : gcBeans) {
            System.out.println("GC Name: " + gcBean.getName());
            System.out.println("GC Count: " + gcBean.getCollectionCount());
            System.out.println("GC Time: " + gcBean.getCollectionTime() + " ms");
        }
    }
}
```

## Quick Reference

```bash
# Heap configuration
-Xms<size>              # Initial heap size
-Xmx<size>              # Maximum heap size
-Xmn<size>              # Young generation size
-Xss<size>              # Stack size per thread

# GC selection
-XX:+UseSerialGC        # Serial GC
-XX:+UseParallelGC      # Parallel GC
-XX:+UseG1GC            # G1 GC (default Java 9+)
-XX:+UseZGC             # ZGC (Java 11+)

# GC tuning
-XX:MaxGCPauseMillis=<ms>     # Target max pause time
-XX:ParallelGCThreads=<n>      # Parallel GC threads
-XX:G1HeapRegionSize=<size>    # G1 region size

# Monitoring
-verbose:gc                    # Basic GC logging
-Xlog:gc*:file=gc.log         # Detailed GC log
-XX:+HeapDumpOnOutOfMemoryError  # Dump on OOM
-XX:+PrintGCDetails            # GC details (Java 8)
```

## Best Practices

1. **Set heap size appropriately** - Start with -Xms = -Xmx
2. **Choose right GC** - G1GC for most applications
3. **Monitor GC logs** - Watch for long pauses
4. **Close resources** - Use try-with-resources
5. **Avoid memory leaks** - Clear static collections, close streams
6. **Use weak/soft references** - For caches
7. **Profile your application** - Use VisualVM, JProfiler
8. **Don't call System.gc()** - Let JVM handle GC
9. **Tune based on needs** - Throughput vs latency
10. **Test under load** - Monitor memory in production-like conditions

---

**Previous**: [← Concurrency](java-15-concurrency.md) | **Next**: [JDBC Database →](java-17-jdbc-database.md)
