# Java Concurrency & Multithreading

## Threads Basics

### Creating Threads

```java
// Method 1: Extend Thread class
class MyThread extends Thread {
    @Override
    public void run() {
        System.out.println("Thread running: " + Thread.currentThread().getName());
    }
}

// Method 2: Implement Runnable
class MyRunnable implements Runnable {
    @Override
    public void run() {
        System.out.println("Runnable running: " + Thread.currentThread().getName());
    }
}

public class ThreadCreation {
    public static void main(String[] args) {
        // Using Thread class
        MyThread thread1 = new MyThread();
        thread1.start();
        
        // Using Runnable
        Thread thread2 = new Thread(new MyRunnable());
        thread2.start();
        
        // Using lambda (Java 8+)
        Thread thread3 = new Thread(() -> {
            System.out.println("Lambda thread: " + Thread.currentThread().getName());
        });
        thread3.start();
        
        // Using method reference
        Thread thread4 = new Thread(ThreadCreation::task);
        thread4.start();
    }
    
    public static void task() {
        System.out.println("Method reference: " + Thread.currentThread().getName());
    }
}
```

### Thread Methods

```java
public class ThreadMethods {
    public static void main(String[] args) throws InterruptedException {
        Thread thread = new Thread(() -> {
            for (int i = 0; i < 5; i++) {
                System.out.println("Count: " + i);
                try {
                    Thread.sleep(1000);  // Sleep 1 second
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        });
        
        thread.setName("MyThread");  // Set thread name
        thread.setPriority(Thread.MAX_PRIORITY);  // Set priority (1-10)
        
        thread.start();  // Start thread
        
        System.out.println("Is alive: " + thread.isAlive());
        System.out.println("State: " + thread.getState());
        
        thread.join();  // Wait for thread to complete
        
        System.out.println("Thread finished");
    }
}
```

## Synchronization

### synchronized Keyword

```java
class Counter {
    private int count = 0;
    
    // Synchronized method
    public synchronized void increment() {
        count++;
    }
    
    // Synchronized block
    public void decrement() {
        synchronized (this) {
            count--;
        }
    }
    
    public int getCount() {
        return count;
    }
}

public class SynchronizationDemo {
    public static void main(String[] args) throws InterruptedException {
        Counter counter = new Counter();
        
        // Create 1000 threads that increment
        Thread[] threads = new Thread[1000];
        for (int i = 0; i < 1000; i++) {
            threads[i] = new Thread(counter::increment);
            threads[i].start();
        }
        
        // Wait for all threads
        for (Thread thread : threads) {
            thread.join();
        }
        
        System.out.println("Final count: " + counter.getCount());  // 1000
    }
}
```

### Race Condition Example

```java
// WITHOUT synchronization
class BankAccount {
    private int balance = 1000;
    
    public void withdraw(int amount) {
        if (balance >= amount) {
            // Simulate processing time
            try { Thread.sleep(10); } catch (InterruptedException e) {}
            balance -= amount;
            System.out.println("Withdrawn: " + amount + ", Balance: " + balance);
        } else {
            System.out.println("Insufficient funds");
        }
    }
}

// WITH synchronization
class SafeBankAccount {
    private int balance = 1000;
    
    public synchronized void withdraw(int amount) {
        if (balance >= amount) {
            try { Thread.sleep(10); } catch (InterruptedException e) {}
            balance -= amount;
            System.out.println("Withdrawn: " + amount + ", Balance: " + balance);
        } else {
            System.out.println("Insufficient funds");
        }
    }
}
```

## Locks (java.util.concurrent.locks)

### ReentrantLock

```java
import java.util.concurrent.locks.*;

public class ReentrantLockDemo {
    private final Lock lock = new ReentrantLock();
    private int count = 0;
    
    public void increment() {
        lock.lock();
        try {
            count++;
        } finally {
            lock.unlock();  // Always unlock in finally
        }
    }
    
    public void decrement() {
        if (lock.tryLock()) {  // Try to acquire lock
            try {
                count--;
            } finally {
                lock.unlock();
            }
        } else {
            System.out.println("Could not acquire lock");
        }
    }
    
    public int getCount() {
        lock.lock();
        try {
            return count;
        } finally {
            lock.unlock();
        }
    }
}
```

### ReadWriteLock

```java
import java.util.concurrent.locks.*;

public class ReadWriteLockDemo {
    private final ReadWriteLock rwLock = new ReentrantReadWriteLock();
    private final Lock readLock = rwLock.readLock();
    private final Lock writeLock = rwLock.writeLock();
    
    private String data = "Initial";
    
    public String read() {
        readLock.lock();
        try {
            System.out.println("Reading: " + data);
            return data;
        } finally {
            readLock.unlock();
        }
    }
    
    public void write(String newData) {
        writeLock.lock();
        try {
            System.out.println("Writing: " + newData);
            data = newData;
        } finally {
            writeLock.unlock();
        }
    }
}
```

## ExecutorService

### Thread Pool

```java
import java.util.concurrent.*;

public class ExecutorServiceDemo {
    public static void main(String[] args) {
        // Fixed thread pool (5 threads)
        ExecutorService executor = Executors.newFixedThreadPool(5);
        
        // Submit tasks
        for (int i = 0; i < 10; i++) {
            final int taskId = i;
            executor.submit(() -> {
                System.out.println("Task " + taskId + " executing on " + 
                    Thread.currentThread().getName());
                try {
                    Thread.sleep(1000);
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                }
            });
        }
        
        executor.shutdown();  // Shutdown executor
        try {
            executor.awaitTermination(1, TimeUnit.MINUTES);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }
}
```

### Different Executor Types

```java
import java.util.concurrent.*;

public class ExecutorTypes {
    public static void main(String[] args) {
        // Fixed thread pool
        ExecutorService fixed = Executors.newFixedThreadPool(5);
        
        // Cached thread pool (creates threads as needed)
        ExecutorService cached = Executors.newCachedThreadPool();
        
        // Single thread executor
        ExecutorService single = Executors.newSingleThreadExecutor();
        
        // Scheduled executor (for delayed/periodic tasks)
        ScheduledExecutorService scheduled = Executors.newScheduledThreadPool(3);
        
        // Schedule task after 5 seconds
        scheduled.schedule(() -> {
            System.out.println("Delayed task");
        }, 5, TimeUnit.SECONDS);
        
        // Schedule task every 3 seconds
        scheduled.scheduleAtFixedRate(() -> {
            System.out.println("Periodic task");
        }, 0, 3, TimeUnit.SECONDS);
        
        // Cleanup
        scheduled.shutdown();
    }
}
```

### Callable and Future

```java
import java.util.concurrent.*;

public class CallableFutureDemo {
    public static void main(String[] args) throws Exception {
        ExecutorService executor = Executors.newFixedThreadPool(3);
        
        // Callable returns a result
        Callable<Integer> task = () -> {
            Thread.sleep(2000);
            return 42;
        };
        
        // Submit and get Future
        Future<Integer> future = executor.submit(task);
        
        System.out.println("Task submitted");
        
        // Check if done
        System.out.println("Is done: " + future.isDone());
        
        // Get result (blocks until ready)
        Integer result = future.get();
        System.out.println("Result: " + result);
        
        // Multiple tasks
        List<Callable<String>> tasks = Arrays.asList(
            () -> "Task 1",
            () -> "Task 2",
            () -> "Task 3"
        );
        
        List<Future<String>> futures = executor.invokeAll(tasks);
        for (Future<String> f : futures) {
            System.out.println(f.get());
        }
        
        executor.shutdown();
    }
}
```

## Concurrent Collections

### ConcurrentHashMap

```java
import java.util.concurrent.*;

public class ConcurrentHashMapDemo {
    public static void main(String[] args) {
        ConcurrentHashMap<String, Integer> map = new ConcurrentHashMap<>();
        
        // Thread-safe operations
        map.put("key1", 1);
        map.putIfAbsent("key2", 2);
        
        // Atomic operations
        map.compute("key1", (k, v) -> v + 1);  // 2
        map.merge("key2", 5, Integer::sum);    // 7
        
        // Safe iteration (no ConcurrentModificationException)
        map.forEach((key, value) -> {
            System.out.println(key + " = " + value);
        });
    }
}
```

### Other Concurrent Collections

```java
import java.util.concurrent.*;

public class ConcurrentCollections {
    public static void main(String[] args) {
        // Thread-safe queue
        BlockingQueue<String> queue = new LinkedBlockingQueue<>();
        
        // Producer
        new Thread(() -> {
            try {
                queue.put("Item 1");
                queue.put("Item 2");
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
        }).start();
        
        // Consumer
        new Thread(() -> {
            try {
                String item = queue.take();  // Blocks if empty
                System.out.println("Consumed: " + item);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
        }).start();
        
        // Other collections
        CopyOnWriteArrayList<String> list = new CopyOnWriteArrayList<>();
        ConcurrentSkipListSet<Integer> set = new ConcurrentSkipListSet<>();
    }
}
```

## Atomic Variables

```java
import java.util.concurrent.atomic.*;

public class AtomicDemo {
    private AtomicInteger counter = new AtomicInteger(0);
    private AtomicLong longCounter = new AtomicLong(0L);
    private AtomicBoolean flag = new AtomicBoolean(false);
    
    public void increment() {
        counter.incrementAndGet();  // Atomic increment
    }
    
    public void compareAndSet() {
        counter.compareAndSet(10, 20);  // If value is 10, set to 20
    }
    
    public void updateAndGet() {
        counter.updateAndGet(x -> x * 2);  // Atomic update
    }
    
    public int get() {
        return counter.get();
    }
    
    public static void main(String[] args) throws InterruptedException {
        AtomicDemo demo = new AtomicDemo();
        
        Thread[] threads = new Thread[1000];
        for (int i = 0; i < 1000; i++) {
            threads[i] = new Thread(demo::increment);
            threads[i].start();
        }
        
        for (Thread thread : threads) {
            thread.join();
        }
        
        System.out.println("Counter: " + demo.get());  // 1000
    }
}
```

## CompletableFuture (Java 8+)

### Async Operations

```java
import java.util.concurrent.*;

public class CompletableFutureDemo {
    public static void main(String[] args) throws Exception {
        // Run async task
        CompletableFuture<Void> future1 = CompletableFuture.runAsync(() -> {
            System.out.println("Async task");
        });
        
        // Supply async result
        CompletableFuture<String> future2 = CompletableFuture.supplyAsync(() -> {
            return "Hello";
        });
        
        String result = future2.get();
        System.out.println(result);
        
        // Chain operations
        CompletableFuture<Integer> future3 = CompletableFuture.supplyAsync(() -> "42")
            .thenApply(Integer::parseInt)
            .thenApply(n -> n * 2);
        
        System.out.println(future3.get());  // 84
        
        // Combine futures
        CompletableFuture<String> f1 = CompletableFuture.supplyAsync(() -> "Hello");
        CompletableFuture<String> f2 = CompletableFuture.supplyAsync(() -> "World");
        
        CompletableFuture<String> combined = f1.thenCombine(f2, (s1, s2) -> s1 + " " + s2);
        System.out.println(combined.get());  // Hello World
        
        // Handle exceptions
        CompletableFuture<Integer> future4 = CompletableFuture.supplyAsync(() -> {
            if (Math.random() > 0.5) {
                throw new RuntimeException("Error!");
            }
            return 42;
        }).exceptionally(ex -> {
            System.out.println("Handled: " + ex.getMessage());
            return -1;
        });
        
        System.out.println(future4.get());
    }
}
```

## Thread Communication

### wait() and notify()

```java
class SharedResource {
    private boolean available = false;
    
    public synchronized void produce() {
        while (available) {  // Wait if already available
            try {
                wait();
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
        }
        
        System.out.println("Produced");
        available = true;
        notify();  // Notify waiting consumer
    }
    
    public synchronized void consume() {
        while (!available) {  // Wait if not available
            try {
                wait();
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
        }
        
        System.out.println("Consumed");
        available = false;
        notify();  // Notify waiting producer
    }
}

public class WaitNotifyDemo {
    public static void main(String[] args) {
        SharedResource resource = new SharedResource();
        
        Thread producer = new Thread(() -> {
            for (int i = 0; i < 5; i++) {
                resource.produce();
            }
        });
        
        Thread consumer = new Thread(() -> {
            for (int i = 0; i < 5; i++) {
                resource.consume();
            }
        });
        
        producer.start();
        consumer.start();
    }
}
```

## Thread Safety Best Practices

```java
// 1. Immutable objects (thread-safe)
public final class ImmutablePerson {
    private final String name;
    private final int age;
    
    public ImmutablePerson(String name, int age) {
        this.name = name;
        this.age = age;
    }
    
    public String getName() { return name; }
    public int getAge() { return age; }
}

// 2. ThreadLocal variables
public class ThreadLocalDemo {
    private static ThreadLocal<Integer> threadLocal = ThreadLocal.withInitial(() -> 0);
    
    public static void increment() {
        threadLocal.set(threadLocal.get() + 1);
    }
    
    public static int get() {
        return threadLocal.get();
    }
}

// 3. Volatile for visibility
public class VolatileDemo {
    private volatile boolean running = true;
    
    public void stop() {
        running = false;  // Visible to all threads immediately
    }
    
    public void run() {
        while (running) {
            // Do work
        }
    }
}
```

## Quick Reference

```java
// Creating threads
Thread thread = new Thread(() -> System.out.println("Hello"));
thread.start();

// ExecutorService
ExecutorService executor = Executors.newFixedThreadPool(5);
executor.submit(() -> System.out.println("Task"));
executor.shutdown();

// Future
Future<Integer> future = executor.submit(() -> 42);
Integer result = future.get();

// CompletableFuture
CompletableFuture.supplyAsync(() -> "Hello")
    .thenApply(String::toUpperCase)
    .thenAccept(System.out::println);

// Synchronized
synchronized (object) {
    // Critical section
}

// Lock
Lock lock = new ReentrantLock();
lock.lock();
try {
    // Critical section
} finally {
    lock.unlock();
}

// Atomic
AtomicInteger counter = new AtomicInteger(0);
counter.incrementAndGet();

// Concurrent collections
ConcurrentHashMap<K, V> map = new ConcurrentHashMap<>();
BlockingQueue<T> queue = new LinkedBlockingQueue<>();
```

## Common Patterns

| Pattern | Use Case |
|---------|----------|
| Thread Pool | Fixed number of worker threads |
| Callable/Future | Task with return value |
| CompletableFuture | Async programming, chaining |
| CountDownLatch | Wait for N events |
| CyclicBarrier | Sync multiple threads at point |
| Semaphore | Limit concurrent access |
| BlockingQueue | Producer-consumer |

---

**Previous**: [← Stream API](java-14-stream-api.md) | **Next**: [Build Tools →](java-18-build-tools.md)
