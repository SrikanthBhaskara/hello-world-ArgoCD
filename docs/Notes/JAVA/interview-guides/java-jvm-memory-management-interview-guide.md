# JVM & Memory Management - Complete Interview Guide

> **For 5+ Year Experienced Backend Developers**
> 
> Complete guide covering JVM Architecture, Memory Structure, Garbage Collection, Performance Tuning, Memory Leaks, Monitoring Tools, with real-world examples, interview questions, traps, and coding problems.

---

## Table of Contents

1. [JVM Architecture Overview](#1-jvm-architecture-overview)
2. [Memory Structure](#2-memory-structure)
3. [Garbage Collection Fundamentals](#3-garbage-collection-fundamentals)
4. [Garbage Collectors](#4-garbage-collectors)
5. [GC Tuning and Optimization](#5-gc-tuning-and-optimization)
6. [Memory Leaks](#6-memory-leaks)
7. [Reference Types](#7-reference-types)
8. [JVM Parameters](#8-jvm-parameters)
9. [OutOfMemoryError Types](#9-outofmemoryerror-types)
10. [Monitoring and Profiling](#10-monitoring-and-profiling)
11. [Interview Questions](#11-interview-questions)
12. [Interview Traps & Edge Cases](#12-interview-traps--edge-cases)
13. [Coding Problems](#13-coding-problems)

---

# 1. JVM ARCHITECTURE OVERVIEW

## 1.1 JVM Components

```
┌─────────────────────────────────────────────────────┐
│                    JVM Architecture                  │
├─────────────────────────────────────────────────────┤
│  ┌───────────────────────────────────────────────┐  │
│  │          Class Loader Subsystem               │  │
│  │  Loading → Linking → Initialization           │  │
│  └───────────────────────────────────────────────┘  │
│                                                      │
│  ┌───────────────────────────────────────────────┐  │
│  │          Runtime Data Areas                   │  │
│  │  ┌─────────┐  ┌──────────────────────────┐   │  │
│  │  │  Heap   │  │    Method Area           │   │  │
│  │  │ (Shared)│  │    (Shared/Metaspace)    │   │  │
│  │  └─────────┘  └──────────────────────────┘   │  │
│  │  ┌──────┐  ┌──────┐  ┌──────────────────┐   │  │
│  │  │Stack │  │  PC  │  │ Native Method    │   │  │
│  │  │(Each)│  │(Each)│  │ Stack (Each)     │   │  │
│  │  └──────┘  └──────┘  └──────────────────┘   │  │
│  └───────────────────────────────────────────────┘  │
│                                                      │
│  ┌───────────────────────────────────────────────┐  │
│  │          Execution Engine                     │  │
│  │  Interpreter | JIT Compiler | GC             │  │
│  └───────────────────────────────────────────────┘  │
│                                                      │
│  ┌───────────────────────────────────────────────┐  │
│  │          Native Method Interface              │  │
│  │          Native Method Libraries              │  │
│  └───────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────┘
```

## 1.2 Class Loading Process

```java
public class ClassLoadingDemo {
    
    /**
     * Class Loading Phases:
     * 1. Loading: Read .class file, create Class object
     * 2. Linking:
     *    a. Verification: Verify bytecode
     *    b. Preparation: Allocate memory for static variables
     *    c. Resolution: Resolve symbolic references
     * 3. Initialization: Execute static initializers
     */
    
    static class Example {
        // Preparation: count = 0 (default value)
        static int count = 100;  // Initialization: count = 100
        
        static {
            System.out.println("Static block executed");
            count = 200;
        }
    }
    
    public static void main(String[] args) {
        // Loading happens here
        System.out.println(Example.count);  // 200
    }
}
```

## 1.3 Class Loader Hierarchy

```java
public class ClassLoaderHierarchy {
    
    public static void main(String[] args) {
        // Application class
        Class<?> myClass = ClassLoaderHierarchy.class;
        ClassLoader appLoader = myClass.getClassLoader();
        System.out.println("Application ClassLoader: " + appLoader);
        // sun.misc.Launcher$AppClassLoader
        
        // Platform/Extension classloader (Java 9+)
        ClassLoader platformLoader = appLoader.getParent();
        System.out.println("Platform ClassLoader: " + platformLoader);
        // sun.misc.Launcher$ExtClassLoader (Java 8)
        // jdk.internal.loader.ClassLoaders$PlatformClassLoader (Java 9+)
        
        // Bootstrap classloader (null in Java)
        ClassLoader bootstrapLoader = platformLoader.getParent();
        System.out.println("Bootstrap ClassLoader: " + bootstrapLoader);
        // null (implemented in native code)
        
        // Core Java class
        Class<?> stringClass = String.class;
        System.out.println("String ClassLoader: " + stringClass.getClassLoader());
        // null (loaded by Bootstrap)
        
        /**
         * Hierarchy (Parent Delegation Model):
         * 
         * Bootstrap ClassLoader (null)
         *   ↑ (parent)
         * Platform/Extension ClassLoader
         *   ↑ (parent)
         * Application ClassLoader
         *   ↑ (parent)
         * Custom ClassLoader (if any)
         */
    }
    
    // Custom ClassLoader example
    static class MyClassLoader extends ClassLoader {
        @Override
        protected Class<?> findClass(String name) throws ClassNotFoundException {
            // Load class from custom source (database, network, etc.)
            byte[] classData = loadClassData(name);
            if (classData == null) {
                throw new ClassNotFoundException(name);
            }
            return defineClass(name, classData, 0, classData.length);
        }
        
        private byte[] loadClassData(String name) {
            // Load bytecode from custom source
            return null;  // Simplified
        }
    }
}
```

---

# 2. MEMORY STRUCTURE

## 2.1 Heap Memory

```java
public class HeapMemoryDemo {
    
    /**
     * Heap Structure (Java 8+):
     * 
     * ┌─────────────────────────────────────┐
     * │            Heap Memory              │
     * ├─────────────────────────────────────┤
     * │  Young Generation                   │
     * │  ┌─────────────────────────────┐   │
     * │  │  Eden Space                 │   │  ← New objects
     * │  │  (8/10 of Young Gen)        │   │
     * │  └─────────────────────────────┘   │
     * │  ┌───────────┐  ┌───────────┐     │
     * │  │ Survivor  │  │ Survivor  │     │  ← Survived objects
     * │  │  S0 (1/10)│  │  S1 (1/10)│     │
     * │  └───────────┘  └───────────┘     │
     * ├─────────────────────────────────────┤
     * │  Old Generation (Tenured)           │
     * │  (Long-lived objects)               │
     * │  (2/3 of Heap)                      │
     * └─────────────────────────────────────┘
     */
    
    static class Person {
        String name;
        int age;
        
        public Person(String name, int age) {
            this.name = name;
            this.age = age;
        }
    }
    
    public static void main(String[] args) {
        // Objects allocated in Eden space
        Person person1 = new Person("Alice", 25);  // In Eden
        Person person2 = new Person("Bob", 30);    // In Eden
        
        // After multiple GCs, long-lived objects move to Old Generation
        Person longLived = new Person("Charlie", 35);
        
        // Force GC (for demonstration only)
        System.gc();
        
        /**
         * Object Lifecycle:
         * 1. Created in Eden
         * 2. Survives Minor GC → S0
         * 3. Survives another Minor GC → S1
         * 4. After N GCs (default 15) → Old Generation
         * 5. Collected by Major/Full GC
         */
    }
}
```

## 2.2 Stack Memory

```java
public class StackMemoryDemo {
    
    /**
     * Stack Memory Structure (per thread):
     * 
     * Each thread has its own stack containing:
     * - Local variables
     * - Method parameters
     * - Return addresses
     * - Intermediate results
     * 
     * Stack frames are pushed/popped on method calls/returns
     */
    
    public static void demonstrateStack() {
        int x = 10;              // Primitive in stack
        String str = "Hello";    // Reference in stack, object in heap
        Person p = new Person(); // Reference in stack, object in heap
        
        method1(x);  // New stack frame pushed
    }  // Stack frame popped
    
    private static void method1(int value) {
        int y = value * 2;  // Local variable in stack
        method2(y);         // Another stack frame pushed
    }
    
    private static void method2(int value) {
        int z = value + 5;
    }  // Stack frame popped
    
    /**
     * Stack vs Heap:
     * 
     * Stack:
     * - Thread-local (not shared)
     * - LIFO structure
     * - Fast allocation/deallocation
     * - Stores primitives and references
     * - Fixed size (can cause StackOverflowError)
     * - Automatically managed
     * 
     * Heap:
     * - Shared across threads
     * - Random access
     * - Slower allocation/deallocation
     * - Stores objects
     * - Dynamic size (can cause OutOfMemoryError)
     * - Managed by GC
     */
    
    static class Person {
        String name;  // Reference in heap object
        int age;      // Primitive in heap object
    }
    
    // StackOverflowError example
    public static void causeStackOverflow() {
        causeStackOverflow();  // Infinite recursion
        // StackOverflowError: Stack frames exceed stack size
    }
}
```

## 2.3 Method Area / Metaspace

```java
public class MethodAreaDemo {
    
    /**
     * Method Area (Java 7 and earlier: PermGen)
     * Method Area (Java 8+: Metaspace)
     * 
     * Stores:
     * - Class metadata (structure, methods, fields)
     * - Static variables
     * - Constants (String pool in Java 7, moved to heap in Java 8)
     * - Method bytecode
     * 
     * Java 7: PermGen (Fixed size, in heap)
     * Java 8+: Metaspace (Dynamic size, native memory)
     */
    
    static class Example {
        // Class metadata stored in Metaspace
        static int staticVar = 100;      // Static variables in Metaspace
        static final String CONSTANT = "Constant";  // Constant
        
        int instanceVar;  // Metadata about this field in Metaspace
        
        public void method() {  // Bytecode stored in Metaspace
            System.out.println("Method");
        }
    }
    
    public static void main(String[] args) {
        // String literals in String Pool (Heap in Java 8+)
        String s1 = "Hello";  // In String Pool
        String s2 = "Hello";  // Same reference as s1
        System.out.println(s1 == s2);  // true
        
        String s3 = new String("Hello");  // New object in heap
        System.out.println(s1 == s3);  // false
        
        String s4 = s3.intern();  // Returns String Pool reference
        System.out.println(s1 == s4);  // true
        
        /**
         * Metaspace vs PermGen:
         * 
         * PermGen (Java 7):
         * - Fixed size (-XX:PermSize, -XX:MaxPermSize)
         * - Part of heap
         * - Can cause OutOfMemoryError: PermGen space
         * - Contains String pool
         * 
         * Metaspace (Java 8+):
         * - Dynamic size (limited by native memory)
         * - Native memory (not heap)
         * - Less likely to run out
         * - String pool moved to heap
         * - -XX:MetaspaceSize, -XX:MaxMetaspaceSize
         */
    }
}
```

## 2.4 Complete Memory Example

```java
public class CompleteMemoryExample {
    
    // Static variables in Metaspace (Java 8+)
    static int staticCounter = 0;
    static String staticString = "Static";  // Reference in Metaspace, object in heap
    
    // Instance variables (in heap with object)
    int instanceCounter;
    String instanceString;
    
    public void demonstrateMemoryAreas() {
        // Stack: local primitive
        int localPrimitive = 42;
        
        // Stack: reference, Heap: object
        String localString = "Local";
        
        // Stack: reference, Heap: array object
        int[] localArray = new int[10];
        
        // Stack: reference, Heap: object with instance variables
        CompleteMemoryExample obj = new CompleteMemoryExample();
        
        // Method call - new stack frame
        calculate(localPrimitive);
    }
    
    private int calculate(int value) {
        // New stack frame with local variables
        int result = value * 2;
        return result;
    }  // Stack frame destroyed
    
    /**
     * Memory Layout for: CompleteMemoryExample obj = new CompleteMemoryExample();
     * 
     * STACK (Thread-specific):
     * ┌─────────────────────┐
     * │ obj (reference)     │ → Points to heap
     * │ localPrimitive: 42  │
     * │ localString (ref)   │ → Points to heap
     * │ localArray (ref)    │ → Points to heap
     * └─────────────────────┘
     * 
     * HEAP (Shared):
     * ┌────────────────────────────────┐
     * │ CompleteMemoryExample object   │
     * │  - instanceCounter: 0          │
     * │  - instanceString: null        │
     * ├────────────────────────────────┤
     * │ String object "Local"          │
     * │  - char[] array                │
     * ├────────────────────────────────┤
     * │ int[] array (10 elements)      │
     * ├────────────────────────────────┤
     * │ String object "Static"         │
     * │  (pointed by static field)     │
     * └────────────────────────────────┘
     * 
     * METASPACE (Native memory):
     * ┌────────────────────────────────┐
     * │ Class: CompleteMemoryExample   │
     * │  - Field metadata              │
     * │  - Method bytecode             │
     * │  - Static field: staticCounter │
     * │  - Static field: staticString  │ → ref to heap
     * │  - Constants                   │
     * └────────────────────────────────┘
     */
    
    public static void main(String[] args) {
        CompleteMemoryExample example = new CompleteMemoryExample();
        example.demonstrateMemoryAreas();
        
        // Print memory info
        Runtime runtime = Runtime.getRuntime();
        long maxMemory = runtime.maxMemory();     // -Xmx
        long totalMemory = runtime.totalMemory(); // Current heap size
        long freeMemory = runtime.freeMemory();   // Free heap
        long usedMemory = totalMemory - freeMemory;
        
        System.out.println("Max Memory (Xmx): " + (maxMemory / 1024 / 1024) + " MB");
        System.out.println("Total Memory: " + (totalMemory / 1024 / 1024) + " MB");
        System.out.println("Used Memory: " + (usedMemory / 1024 / 1024) + " MB");
        System.out.println("Free Memory: " + (freeMemory / 1024 / 1024) + " MB");
    }
}
```

---

# 3. GARBAGE COLLECTION FUNDAMENTALS

## 3.1 GC Basics

```java
public class GarbageCollectionBasics {
    
    /**
     * Garbage Collection:
     * - Automatic memory management
     * - Reclaims memory from unreachable objects
     * - Prevents memory leaks (mostly)
     * - Runs in background
     * 
     * Object becomes eligible for GC when:
     * 1. No references pointing to it
     * 2. All references are null
     * 3. Object is created inside method (local scope ends)
     * 4. Reference reassigned to another object
     * 5. Object is in "island of isolation"
     */
    
    static class Person {
        String name;
        
        public Person(String name) {
            this.name = name;
        }
        
        @Override
        protected void finalize() throws Throwable {
            // Called before GC (deprecated in Java 9+)
            System.out.println("Finalize called for: " + name);
        }
    }
    
    public static void demonstrateGCEligibility() {
        // 1. No references
        new Person("John");  // Eligible immediately
        
        // 2. Null reference
        Person p1 = new Person("Alice");
        p1 = null;  // Eligible for GC
        
        // 3. Method scope ends
        createPerson();  // Person eligible after method returns
        
        // 4. Reference reassignment
        Person p2 = new Person("Bob");
        p2 = new Person("Charlie");  // "Bob" eligible for GC
        
        // 5. Island of isolation
        Person p3 = new Person("Dave");
        Person p4 = new Person("Eve");
        p3.name = "Dave and Eve";  // Assume Person has Person field
        p3 = null;
        p4 = null;  // Both eligible if they only reference each other
        
        // Request GC (not guaranteed to run immediately)
        System.gc();  // or Runtime.getRuntime().gc();
    }
    
    private static void createPerson() {
        Person local = new Person("Local");
    }  // "Local" eligible for GC after this
    
    /**
     * Reachability:
     * 
     * Strongly Reachable:
     * - Direct reference from live thread/static field
     * - Object obj = new Object();
     * 
     * Softly Reachable:
     * - Only reachable through SoftReference
     * - GC'd when memory is low
     * 
     * Weakly Reachable:
     * - Only reachable through WeakReference
     * - GC'd in next GC cycle
     * 
     * Phantom Reachable:
     * - Only reachable through PhantomReference
     * - Already finalized, awaiting cleanup
     */
}
```

## 3.2 GC Algorithms

```java
public class GCAlgorithms {
    
    /**
     * Mark and Sweep Algorithm:
     * 
     * 1. Mark Phase:
     *    - Start from GC roots (static fields, local variables, JNI refs)
     *    - Traverse object graph
     *    - Mark all reachable objects
     * 
     * 2. Sweep Phase:
     *    - Scan through heap
     *    - Reclaim unmarked objects
     *    - Add memory to free list
     * 
     * Problem: Fragmentation
     */
    
    /**
     * Mark-Sweep-Compact Algorithm:
     * 
     * 1. Mark: Identify live objects
     * 2. Sweep: Remove dead objects
     * 3. Compact: Move live objects together
     *    - Eliminates fragmentation
     *    - Updates references
     *    - More expensive but efficient memory use
     */
    
    /**
     * Copying Algorithm (Young Generation):
     * 
     * 1. Divide memory into two equal spaces
     * 2. Allocate objects in "from" space
     * 3. During GC:
     *    - Copy live objects to "to" space
     *    - Swap "from" and "to"
     *    - Clear old "from" space
     * 
     * Advantages:
     * - No fragmentation
     * - Fast allocation (bump-the-pointer)
     * 
     * Disadvantages:
     * - Wastes 50% memory
     * 
     * Optimization: Eden + 2 Survivors
     * - Eden: 80%, S0: 10%, S1: 10%
     * - Only 10% wasted instead of 50%
     */
    
    /**
     * Generational GC (Most common):
     * 
     * Hypothesis: Most objects die young
     * 
     * Young Generation (Minor GC):
     * - Frequent, fast collections
     * - Uses Copying algorithm
     * - Eden + Survivor spaces
     * 
     * Old Generation (Major GC):
     * - Infrequent, slower collections
     * - Uses Mark-Sweep-Compact
     * - Long-lived objects
     * 
     * Full GC:
     * - Collects both Young and Old
     * - Stop-the-world event
     * - Should be minimized
     */
    
    public static void demonstrateGenerations() {
        // Young generation objects
        for (int i = 0; i < 1000; i++) {
            String temp = "Temporary " + i;  // Dies quickly
        }
        
        // Long-lived object (will promote to Old Gen)
        List<String> cache = new ArrayList<>();
        for (int i = 0; i < 10000; i++) {
            cache.add("Cached " + i);  // Survives multiple GCs
        }
        
        /**
         * Object Promotion:
         * 
         * New object → Eden Space
         *     ↓ (survives Minor GC)
         * Survivor S0
         *     ↓ (survives Minor GC)
         * Survivor S1
         *     ↓ (age > threshold, default 15)
         * Old Generation
         *     ↓ (survives until Major/Full GC)
         * Collected
         */
    }
}
```

## 3.3 GC Roots

```java
public class GCRootsDemo {
    
    /**
     * GC Roots (Starting points for reachability analysis):
     * 
     * 1. Local variables in method stacks
     * 2. Static variables in classes
     * 3. Active Java threads
     * 4. JNI (Java Native Interface) references
     * 5. Synchronized monitors
     */
    
    // GC Root: Static variable
    private static List<String> staticList = new ArrayList<>();
    
    public static void demonstrateGCRoots() {
        // GC Root: Local variable in active method
        String localVariable = "I am reachable";
        
        // GC Root: Thread
        Thread thread = new Thread(() -> {
            String threadLocal = "Reachable while thread runs";
            try {
                Thread.sleep(10000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        });
        thread.start();
        
        // Reachable from GC root
        Person p1 = new Person("Alice");
        
        // Also reachable (referenced by p1)
        Person p2 = new Person("Bob");
        p1.friend = p2;
        
        // Not reachable (no path from GC roots)
        Person p3 = new Person("Charlie");
        p3 = null;  // Eligible for GC
        
        /**
         * Reachability Graph:
         * 
         * GC Root (Stack/Static)
         *     ↓
         *   Person p1 (Alice) ← Reachable
         *     ↓
         *   Person p2 (Bob) ← Reachable (through p1)
         * 
         * Person p3 (Charlie) ← Not reachable → GC eligible
         */
    }
    
    static class Person {
        String name;
        Person friend;
        
        public Person(String name) {
            this.name = name;
        }
    }
}
```

---

# 4. GARBAGE COLLECTORS

## 4.1 Serial GC

```java
/**
 * Serial GC (-XX:+UseSerialGC)
 * 
 * Characteristics:
 * - Single-threaded
 * - Stop-the-world for both Young and Old Gen
 * - Simple and efficient for small apps
 * - Default for client-class machines
 * 
 * Use Case:
 * - Small applications (< 100MB heap)
 * - Single-core machines
 * - Client applications
 * - Batch processing
 * 
 * GC Process:
 * Young Gen: Serial (copying algorithm)
 * Old Gen: Serial Mark-Sweep-Compact
 * 
 * Pros:
 * - Low memory overhead
 * - Efficient for small heaps
 * - Predictable
 * 
 * Cons:
 * - Long pause times for large heaps
 * - Doesn't utilize multiple CPUs
 * 
 * JVM Flag:
 * java -XX:+UseSerialGC -Xms512m -Xmx512m MyApp
 */
```

## 4.2 Parallel GC

```java
/**
 * Parallel GC (-XX:+UseParallelGC) [Default in Java 8]
 * Also known as: Throughput Collector
 * 
 * Characteristics:
 * - Multi-threaded for Young Generation
 * - Multi-threaded for Old Generation (Parallel Old)
 * - Stop-the-world for both
 * - Maximizes throughput
 * 
 * Use Case:
 * - Batch processing
 * - Scientific computations
 * - Where throughput > latency
 * - Multi-core machines
 * 
 * GC Process:
 * Young Gen: Multiple GC threads (copying)
 * Old Gen: Multiple GC threads (mark-sweep-compact)
 * 
 * Pros:
 * - High throughput
 * - Efficient for multi-core systems
 * - Good for batch jobs
 * 
 * Cons:
 * - Long pause times
 * - Not suitable for interactive apps
 * 
 * JVM Flags:
 * -XX:+UseParallelGC
 * -XX:ParallelGCThreads=N          (default: # of CPUs)
 * -XX:MaxGCPauseMillis=N           (target pause time)
 * -XX:GCTimeRatio=N                (throughput goal)
 * 
 * Example:
 * java -XX:+UseParallelGC -XX:ParallelGCThreads=4 \
 *      -XX:MaxGCPauseMillis=100 -Xms2g -Xmx2g MyApp
 */
```

## 4.3 CMS (Concurrent Mark Sweep)

```java
/**
 * CMS GC (-XX:+UseConcMarkSweepGC) [Deprecated in Java 9, Removed in Java 14]
 * 
 * Characteristics:
 * - Low-pause collector
 * - Most work done concurrently with application
 * - Only Old Generation (Young uses ParNew)
 * - Trade-off: Lower throughput for lower latency
 * 
 * Phases:
 * 1. Initial Mark (STW): Mark GC roots
 * 2. Concurrent Mark: Traverse object graph
 * 3. Concurrent Premark: Handle changes during mark
 * 4. Remark (STW): Finalize marking
 * 5. Concurrent Sweep: Remove dead objects
 * 6. Concurrent Reset: Prepare for next cycle
 * 
 * Use Case:
 * - Interactive applications
 * - Web applications
 * - Where low latency is critical
 * 
 * Pros:
 * - Low pause times
 * - Concurrent collection
 * - Good for responsive apps
 * 
 * Cons:
 * - More CPU usage
 * - Fragmentation (no compaction)
 * - "Concurrent Mode Failure" risk
 * - Removed in Java 14
 * 
 * JVM Flags:
 * -XX:+UseConcMarkSweepGC
 * -XX:+UseParNewGC                 (Young gen collector)
 * -XX:CMSInitiatingOccupancyFraction=N  (when to start CMS)
 * -XX:+UseCMSInitiatingOccupancyOnly
 * -XX:ConcGCThreads=N              (concurrent threads)
 * 
 * Problems:
 * - Concurrent Mode Failure: CMS can't keep up
 *   → Falls back to Serial Old (long STW pause)
 * - Promotion Failed: Young gen object can't promote
 * - Fragmentation: No compaction → Full GC needed
 */
```

## 4.4 G1 (Garbage First)

```java
/**
 * G1 GC (-XX:+UseG1GC) [Default from Java 9+]
 * 
 * Characteristics:
 * - Region-based heap layout
 * - Predictable pause times
 * - Compacting collector
 * - Suitable for large heaps (> 4GB)
 * - Combines throughput and low latency
 * 
 * Heap Structure:
 * ┌─────────────────────────────────────────┐
 * │  Heap divided into ~2000 regions        │
 * │  Each region: 1MB - 32MB                │
 * ├─────────────────────────────────────────┤
 * │ [E][E][S][O][O][H][E][S][O][E]...      │
 * │  E = Eden                               │
 * │  S = Survivor                           │
 * │  O = Old                                │
 * │  H = Humongous (> 50% region size)     │
 * └─────────────────────────────────────────┘
 * 
 * GC Phases:
 * 1. Young GC (Evacuation Pause - STW):
 *    - Collect Eden and Survivor regions
 *    - Copy live objects to Survivor or Old
 *    - Predictable pause time
 * 
 * 2. Concurrent Marking Cycle:
 *    a. Initial Mark (STW): Piggybacks on Young GC
 *    b. Root Region Scan (Concurrent)
 *    c. Concurrent Mark
 *    d. Remark (STW): Finalize marking
 *    e. Cleanup (STW + Concurrent)
 * 
 * 3. Mixed GC:
 *    - Collects Young + some Old regions
 *    - Prioritizes regions with most garbage
 *    - Hence "Garbage First"
 * 
 * Use Case:
 * - Large heap applications
 * - Predictable pause times needed
 * - General-purpose applications
 * - Default choice for Java 9+
 * 
 * Pros:
 * - Predictable pause times
 * - No fragmentation (compacting)
 * - Scales to large heaps
 * - Balances throughput and latency
 * 
 * Cons:
 * - More complex
 * - Higher CPU overhead than Parallel GC
 * - Not optimal for very small heaps
 * 
 * JVM Flags:
 * -XX:+UseG1GC                     (enable G1)
 * -XX:MaxGCPauseMillis=N           (target: 200ms)
 * -XX:G1HeapRegionSize=N           (1MB-32MB, power of 2)
 * -XX:InitiatingHeapOccupancyPercent=N  (start marking: 45%)
 * -XX:G1ReservePercent=N           (reserve: 10%)
 * -XX:ConcGCThreads=N              (concurrent threads)
 * 
 * Example:
 * java -XX:+UseG1GC -XX:MaxGCPauseMillis=200 \
 *      -Xms4g -Xmx4g -XX:G1HeapRegionSize=16m MyApp
 */

public class G1GCDemo {
    
    public static void main(String[] args) {
        // Allocate objects to trigger G1 GC
        List<byte[]> list = new ArrayList<>();
        
        // Allocate 100MB of data
        for (int i = 0; i < 100; i++) {
            byte[] data = new byte[1024 * 1024];  // 1MB
            list.add(data);
            
            if (i % 10 == 0) {
                System.out.println("Allocated " + (i + 1) + " MB");
                printMemoryInfo();
            }
        }
        
        // Clear some data to trigger GC
        list.subList(0, 50).clear();
        System.gc();
        
        System.out.println("\nAfter clearing 50MB:");
        printMemoryInfo();
    }
    
    private static void printMemoryInfo() {
        Runtime runtime = Runtime.getRuntime();
        long usedMemory = (runtime.totalMemory() - runtime.freeMemory()) / 1024 / 1024;
        long maxMemory = runtime.maxMemory() / 1024 / 1024;
        System.out.printf("Memory: %d MB / %d MB%n", usedMemory, maxMemory);
    }
}
```

## 4.5 ZGC (Z Garbage Collector)

```java
/**
 * ZGC (-XX:+UseZGC) [Experimental in Java 11, Production in Java 15]
 * 
 * Characteristics:
 * - Ultra-low latency collector
 * - Pause times < 10ms (typically 1-2ms)
 * - Scales from 8MB to 16TB heaps
 * - Concurrent compaction
 * - Load barriers for concurrent operations
 * 
 * Technology:
 * - Colored pointers (metadata in pointer bits)
 * - Load barriers (check/fix references on load)
 * - Concurrent everything (mark, relocate, remap)
 * 
 * Phases (mostly concurrent):
 * 1. Pause Mark Start (STW ~1ms)
 * 2. Concurrent Mark
 * 3. Pause Mark End (STW ~1ms)
 * 4. Concurrent Prepare for Relocate
 * 5. Pause Relocate Start (STW ~1ms)
 * 6. Concurrent Relocate
 * 
 * Use Case:
 * - Very low latency requirements
 * - Large heaps (multi-GB to TB)
 * - Trading CPU for latency
 * - Real-time applications
 * 
 * Pros:
 * - Extremely low pause times
 * - Pause time doesn't increase with heap size
 * - Concurrent compaction
 * - Future-proof for large heaps
 * 
 * Cons:
 * - More CPU overhead (~15%)
 * - More memory overhead
 * - Requires Java 11+ (production: Java 15+)
 * - Linux only initially (Windows/macOS later)
 * 
 * JVM Flags:
 * -XX:+UseZGC
 * -XX:ConcGCThreads=N
 * -XX:ZCollectionInterval=N        (seconds between GCs)
 * -XX:ZAllocationSpikeTolerance=N
 * 
 * Example:
 * java -XX:+UseZGC -Xms16g -Xmx16g \
 *      -XX:ConcGCThreads=4 MyApp
 */
```

## 4.6 Shenandoah GC

```java
/**
 * Shenandoah GC (-XX:+UseShenandoahGC) [Java 12+, Not in Oracle JDK]
 * 
 * Characteristics:
 * - Low-pause collector (similar goals to ZGC)
 * - Concurrent evacuation
 * - Uses "Brooks pointers" (forwarding pointers)
 * - Part of OpenJDK, not Oracle JDK
 * 
 * Phases:
 * 1. Init Mark (STW ~10ms)
 * 2. Concurrent Marking
 * 3. Final Mark (STW ~10ms)
 * 4. Concurrent Cleanup
 * 5. Concurrent Evacuation
 * 6. Init Update Refs (STW ~10ms)
 * 7. Concurrent Update References
 * 8. Final Update Refs (STW ~10ms)
 * 
 * Use Case:
 * - Similar to ZGC
 * - Available in OpenJDK
 * - 99th percentile latency critical
 * 
 * Pros:
 * - Very low pause times
 * - Concurrent compaction
 * - Available in OpenJDK
 * 
 * Cons:
 * - CPU overhead
 * - Memory overhead (forwarding pointers)
 * - Not in Oracle JDK
 * 
 * JVM Flags:
 * -XX:+UseShenandoahGC
 * -XX:ShenandoahGCHeuristics=N     (adaptive, static, compact)
 * 
 * Example:
 * java -XX:+UseShenandoahGC -Xms8g -Xmx8g MyApp
 */
```

## 4.7 GC Comparison Matrix

```java
public class GCComparison {
    
    /**
     * Garbage Collector Comparison:
     * 
     * ┌──────────────┬────────────┬─────────────┬──────────────┬───────────┐
     * │ Collector    │ Pause Time │ Throughput  │ Heap Size    │ Java Ver  │
     * ├──────────────┼────────────┼─────────────┼──────────────┼───────────┤
     * │ Serial       │ Long       │ Low         │ Small (<1GB) │ All       │
     * │ Parallel     │ Long       │ High        │ Medium       │ All (D:8) │
     * │ CMS          │ Short      │ Medium      │ Medium       │ 8-14 (⚠)  │
     * │ G1           │ Predictable│ Good        │ Large (>4GB) │ 7+ (D:9+) │
     * │ ZGC          │ Very Short │ Good        │ Very Large   │ 11+       │
     * │ Shenandoah   │ Very Short │ Good        │ Large        │ 12+ (OJD) │
     * └──────────────┴────────────┴─────────────┴──────────────┴───────────┘
     * 
     * (D: Default, OJD: OpenJDK only, ⚠: Deprecated/Removed)
     * 
     * Decision Tree:
     * 
     * Heap Size < 1GB?
     *   → Serial GC
     * 
     * Pause time not critical, want max throughput?
     *   → Parallel GC
     * 
     * Need predictable pause times, heap 4GB-100GB?
     *   → G1 GC (default choice)
     * 
     * Need pause times < 10ms, large heap?
     *   → ZGC or Shenandoah
     * 
     * Running on Java 8 with low latency needs?
     *   → G1 GC (CMS deprecated)
     */
    
    public static void main(String[] args) {
        // Check current GC
        List<GarbageCollectorMXBean> gcBeans = 
            java.lang.management.ManagementFactory.getGarbageCollectorMXBeans();
        
        System.out.println("Active Garbage Collectors:");
        for (GarbageCollectorMXBean gcBean : gcBeans) {
            System.out.println("- " + gcBean.getName());
            System.out.println("  Collections: " + gcBean.getCollectionCount());
            System.out.println("  Time: " + gcBean.getCollectionTime() + "ms");
        }
        
        /**
         * Common GC Names:
         * 
         * Serial GC:
         * - Copy (Young)
         * - MarkSweepCompact (Old)
         * 
         * Parallel GC:
         * - PS Scavenge (Young)
         * - PS MarkSweep (Old)
         * 
         * CMS:
         * - ParNew (Young)
         * - ConcurrentMarkSweep (Old)
         * 
         * G1:
         * - G1 Young Generation
         * - G1 Old Generation
         * 
         * ZGC:
         * - ZGC
         * 
         * Shenandoah:
         * - Shenandoah Cycles
         * - Shenandoah Pauses
         */
    }
}
```

---

**Part 1 Complete!** ✅

Covered:
- JVM Architecture (Class Loader, Runtime Data Areas, Execution Engine) ✅
- Memory Structure (Heap, Stack, Metaspace, complete memory layout) ✅
- Garbage Collection Fundamentals (Algorithms, GC Roots, Reachability) ✅
- All Garbage Collectors (Serial, Parallel, CMS, G1, ZGC, Shenandoah) ✅
- Detailed GC comparison matrix ✅

# 5. GC TUNING AND OPTIMIZATION

## 5.1 GC Tuning Goals

```java
public class GCTuningGoals {
    
    /**
     * GC Tuning Goals (pick maximum 2):
     * 
     * 1. Throughput: % of time NOT in GC
     *    - Goal: Maximize application execution time
     *    - Metric: (Total Time - GC Time) / Total Time
     *    - Best: Parallel GC
     * 
     * 2. Latency: Pause time duration
     *    - Goal: Minimize individual GC pause times
     *    - Metric: Max/Avg pause time
     *    - Best: G1, ZGC, Shenandoah
     * 
     * 3. Footprint: Memory usage
     *    - Goal: Minimize heap size
     *    - Metric: Maximum heap size
     *    - Trade-off with throughput/latency
     * 
     * Trade-offs:
     * - High Throughput ←→ Low Latency
     * - Small Footprint ←→ High Throughput
     * - Small Footprint ←→ Low Latency
     */
    
    /**
     * GC Tuning Strategy:
     * 
     * 1. Measure baseline
     * 2. Set clear goals
     * 3. Choose appropriate GC
     * 4. Set heap size
     * 5. Tune generation sizes
     * 6. Monitor and iterate
     */
}
```

## 5.2 Common GC Tuning Flags

```bash
# Heap Size
-Xms2g                    # Initial heap size
-Xmx4g                    # Maximum heap size
-XX:NewRatio=2            # Old:Young ratio (default 2:1)
-XX:SurvivorRatio=8       # Eden:Survivor ratio (default 8:1:1)
-Xmn1g                    # Young generation size (alternative to ratios)

# G1 GC Tuning
-XX:+UseG1GC
-XX:MaxGCPauseMillis=200  # Target pause time (default 200ms)
-XX:G1HeapRegionSize=4m   # Region size (1-32MB, power of 2)
-XX:G1ReservePercent=10   # Reserve heap for to-space (default 10%)
-XX:InitiatingHeapOccupancyPercent=45  # Start marking threshold (default 45%)
-XX:G1MixedGCCountTarget=8            # Mixed GC count target
-XX:G1OldCSetRegionThresholdPercent=10 # Old regions in mixed GC

# Parallel GC Tuning
-XX:+UseParallelGC
-XX:ParallelGCThreads=8   # GC threads (default: CPU count)
-XX:MaxGCPauseMillis=500  # Target pause time
-XX:GCTimeRatio=19        # Throughput goal (1/(1+19) = 5% GC time)

# ZGC Tuning
-XX:+UseZGC
-XX:ConcGCThreads=4       # Concurrent GC threads
-XX:ZCollectionInterval=0 # Time between GCs (0 = heuristic)

# GC Logging (Java 8)
-XX:+PrintGCDetails
-XX:+PrintGCTimeStamps
-XX:+PrintGCDateStamps
-Xloggc:/path/to/gc.log
-XX:+UseGCLogFileRotation
-XX:NumberOfGCLogFiles=10
-XX:GCLogFileSize=50M

# GC Logging (Java 9+)
-Xlog:gc*:file=/path/to/gc.log:time,uptime,level,tags
-Xlog:gc:gc.log
```

## 5.3 Real-World GC Tuning Examples

```java
import java.util.*;
import java.util.concurrent.*;

public class GCTuningExamples {
    
    /**
     * Scenario 1: High Throughput Batch Processing
     * 
     * Requirements:
     * - Process large files
     * - Pause times acceptable
     * - Maximize throughput
     * 
     * Recommended GC: Parallel GC
     * 
     * JVM Flags:
     * java -XX:+UseParallelGC \
     *      -Xms4g -Xmx4g \              # Fixed heap
     *      -XX:ParallelGCThreads=8 \    # Use all cores
     *      -XX:MaxGCPauseMillis=1000 \  # Acceptable pause
     *      -XX:GCTimeRatio=19 \         # 95% app time, 5% GC
     *      BatchProcessor
     */
    
    static class BatchProcessor {
        public void processBatch(List<String> files) {
            List<byte[]> data = new ArrayList<>();
            
            for (String file : files) {
                byte[] content = readFile(file);  // Read large file
                byte[] processed = process(content);  // CPU-intensive
                data.add(processed);
            }
            
            writeBatch(data);  // Write results
        }
        
        private byte[] readFile(String file) {
            return new byte[1024 * 1024];  // Simulated
        }
        
        private byte[] process(byte[] data) {
            // CPU-intensive processing
            return data;
        }
        
        private void writeBatch(List<byte[]> data) {
            // Write results
        }
    }
    
    /**
     * Scenario 2: Low Latency Web Application
     * 
     * Requirements:
     * - Response time < 100ms
     * - Heap: 4-8GB
     * - High concurrency
     * 
     * Recommended GC: G1 GC
     * 
     * JVM Flags:
     * java -XX:+UseG1GC \
     *      -Xms8g -Xmx8g \              # Fixed heap
     *      -XX:MaxGCPauseMillis=50 \    # Target 50ms pause
     *      -XX:G1HeapRegionSize=16m \   # 8GB / 512 regions
     *      -XX:InitiatingHeapOccupancyPercent=45 \
     *      -XX:G1ReservePercent=10 \
     *      -XX:ConcGCThreads=4 \
     *      WebApplication
     */
    
    static class WebApplication {
        private Cache cache = new Cache();
        
        public Response handleRequest(Request request) {
            // Check cache (short-lived objects)
            Response cached = cache.get(request.getId());
            if (cached != null) {
                return cached;
            }
            
            // Process request (creates garbage)
            Response response = processRequest(request);
            
            // Cache for reuse (long-lived)
            cache.put(request.getId(), response);
            
            return response;
        }
        
        private Response processRequest(Request request) {
            return new Response("Processed: " + request.getId());
        }
    }
    
    /**
     * Scenario 3: Ultra-Low Latency Trading System
     * 
     * Requirements:
     * - Pause time < 5ms
    * - Heap: 16GB+
     * - 99.99th percentile critical
     * 
     * Recommended GC: ZGC
     * 
     * JVM Flags:
     * java -XX:+UseZGC \
     *      -Xms16g -Xmx16g \            # Fixed large heap
     *      -XX:ConcGCThreads=4 \
     *      -XX:ZCollectionInterval=0 \   # Heuristic-based
     *      TradingSystem
     */
    
    static class TradingSystem {
        private Queue<Order> orders = new ConcurrentLinkedQueue<>();
        
        public void processOrder(Order order) {
            // Ultra-low latency required
            long start = System.nanoTime();
            
            validateOrder(order);
            executeOrder(order);
            
            long latency = System.nanoTime() - start;
            if (latency > 5_000_000) {  // 5ms
                System.err.println("High latency: " + latency + "ns");
            }
        }
        
        private void validateOrder(Order order) {
            // Validation logic
        }
        
        private void executeOrder(Order order) {
            // Execution logic
        }
    }
    
    /**
     * Scenario 4: Microservice with Moderate Heap
     * 
     * Requirements:
     * - Heap: 512MB - 2GB
     * - Container environment
     * - Predictable performance
     * 
     * Recommended GC: G1 GC (default)
     * 
     * JVM Flags:
     * java -XX:+UseG1GC \
     *      -Xms1g -Xmx1g \              # Container memory limit
     *      -XX:MaxGCPauseMillis=100 \
     *      -XX:+UseContainerSupport \   # Respect container limits
     *      -XX:MaxRAMPercentage=75.0 \  # Use 75% of container memory
     *      Microservice
     */
    
    // Supporting classes
    static class Request {
        private String id;
        public Request(String id) { this.id = id; }
        public String getId() { return id; }
    }
    
    static class Response {
        private String data;
        public Response(String data) { this.data = data; }
    }
    
    static class Cache {
        private Map<String, Response> cache = new ConcurrentHashMap<>();
        public Response get(String key) { return cache.get(key); }
        public void put(String key, Response value) { cache.put(key, value); }
    }
    
    static class Order {
        private String id;
        public Order(String id) { this.id = id; }
    }
}
```

## 5.4 GC Tuning Best Practices

```java
public class GCTuningBestPractices {
    
    /**
     * Best Practices:
     * 
     * 1. Set -Xms equal to -Xmx
     *    - Prevents heap resizing during runtime
     *    - Reduces GC overhead
     *    - BUT: Less flexible if actual needs are lower
     * 
     * 2. Start with default GC (G1 in Java 9+)
     *    - Only tune if you have performance issues
     *    - Measure before and after
     * 
     * 3. Don't set MaxGCPauseMillis too low
     *    - Unrealistic targets cause frequent GCs
     *    - Can reduce throughput
     *    - G1 default 200ms is reasonable
     * 
     * 4. Monitor GC logs
     *    - Identify patterns
     *    - Look for excessive GC frequency
     *    - Watch for Full GCs
     * 
     * 5. Size Young Generation correctly
     *    - Too small: Frequent Minor GCs
     *    - Too large: Long Minor GC pauses
     *    - Default ratios usually work well
     * 
     * 6. Avoid premature optimization
     *    - Fix application issues first
     *    - Tune GC only if GC is the bottleneck
     * 
     * 7. Test with production-like load
     *    - GC behavior varies with workload
     *    - Test sustained load, not just peak
     * 
     * 8. Use GC-friendly coding practices
     *    - Reduce object allocation
     *    - Reuse objects when appropriate
     *    - Use primitives over wrappers
     *    - Avoid finalizers
     */
    
    // Example: Object pooling for GC reduction
    static class ObjectPool<T> {
        private Queue<T> pool = new ConcurrentLinkedQueue<>();
        private Supplier<T> factory;
        private int maxSize;
        
        public ObjectPool(Supplier<T> factory, int maxSize) {
            this.factory = factory;
            this.maxSize = maxSize;
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
    
    // Example: Reducing allocations
    static class EfficientProcessor {
        // BAD: Creates many temporary objects
        public String processInefficient(List<String> items) {
            String result = "";
            for (String item : items) {
                result += item + ",";  // Creates new String each iteration!
            }
            return result;
        }
        
        // GOOD: Reuses StringBuilder
        public String processEfficient(List<String> items) {
            StringBuilder sb = new StringBuilder();
            for (String item : items) {
                sb.append(item).append(",");
            }
            return sb.toString();
        }
    }
}
```

---

# 6. MEMORY LEAKS

## 6.1 Common Memory Leak Causes

```java
import java.util.*;

public class MemoryLeakExamples {
    
    /**
     * Memory Leak: Objects that are no longer needed but still referenced
     * 
     * Result: OutOfMemoryError eventually
     * 
     * Common Causes:
     * 1. Static collections that grow unbounded
     * 2. Listeners not removed
     * 3. ThreadLocal not cleaned
     * 4. Unclosed resources
     * 5. Inner classes holding outer reference
     * 6. Cache without eviction
     */
    
    // 1. LEAK: Static collection grows unbounded
    static class StaticCollectionLeak {
        private static final List<byte[]> cache = new ArrayList<>();
        
        public void addToCache(byte[] data) {
            cache.add(data);  // Never removed!
            // Over time, cache grows → OutOfMemoryError
        }
        
        // FIX: Limit size or use weak references
        private static final int MAX_SIZE = 1000;
        private static final List<byte[]> boundedCache = new ArrayList<>();
        
        public void addToCacheSafe(byte[] data) {
            if (boundedCache.size() >= MAX_SIZE) {
                boundedCache.remove(0);  // Remove oldest
            }
            boundedCache.add(data);
        }
    }
    
    // 2. LEAK: Listeners not removed
    static class ListenerLeak {
        interface EventListener {
            void onEvent(String event);
        }
        
        static class EventSource {
            private List<EventListener> listeners = new ArrayList<>();
            
            public void addListener(EventListener listener) {
                listeners.add(listener);
            }
            
            // Missing: removeListener method
            // Listeners never garbage collected!
        }
        
        static class EventConsumer {
            private EventSource source;
            
            public EventConsumer(EventSource source) {
                this.source = source;
                source.addListener(event -> process(event));
                // EventConsumer cannot be GC'd even if not used
            }
            
            private void process(String event) {
                System.out.println("Processing: " + event);
            }
        }
        
        // FIX: Provide remove method
        static class EventSourceFixed {
            private List<EventListener> listeners = new ArrayList<>();
            
            public void addListener(EventListener listener) {
                listeners.add(listener);
            }
            
            public void removeListener(EventListener listener) {
                listeners.remove(listener);
            }
            
            public void cleanup() {
                listeners.clear();
            }
        }
    }
    
    // 3. LEAK: ThreadLocal not cleaned
    static class ThreadLocalLeak {
        private static ThreadLocal<List<byte[]>> threadCache = new ThreadLocal<>();
        
        public void processRequest() {
            List<byte[]> cache = threadCache.get();
            if (cache == null) {
                cache = new ArrayList<>();
                threadCache.set(cache);
            }
            
            cache.add(new byte[1024 * 1024]);  // 1MB
            
            // In thread pool, thread is reused
            // ThreadLocal value persists across requests!
            // Memory keeps growing
        }
        
        // FIX: Always remove ThreadLocal
        public void processRequestFixed() {
            try {
                List<byte[]> cache = threadCache.get();
                if (cache == null) {
                    cache = new ArrayList<>();
                    threadCache.set(cache);
                }
                cache.add(new byte[1024 * 1024]);
            } finally {
                threadCache.remove();  // Clean up!
            }
        }
    }
    
    // 4. LEAK: Unclosed resources
    static class ResourceLeak {
        // BAD: Stream not closed
        public String readFileLeak(String filename) throws Exception {
            java.io.FileInputStream fis = new java.io.FileInputStream(filename);
            byte[] data = new byte[1024];
            fis.read(data);
            return new String(data);
            // FileInputStream not closed → file handle leak!
        }
        
        // GOOD: try-with-resources
        public String readFileFixed(String filename) throws Exception {
            try (java.io.FileInputStream fis = new java.io.FileInputStream(filename)) {
                byte[] data = new byte[1024];
                fis.read(data);
                return new String(data);
            }  // Automatically closed
        }
    }
    
    // 5. LEAK: Inner class holds outer reference
    static class InnerClassLeak {
        private byte[] data = new byte[1024 * 1024];  // 1MB
        
        // Non-static inner class holds reference to outer class
        class Inner {
            public void doSomething() {
                System.out.println("Inner");
                // Implicitly has reference to OuterClass.this
            }
        }
        
        public Inner createInner() {
            return new Inner();
            // Inner object keeps entire Outer object alive
            // Even if only Inner is referenced
        }
        
        // FIX: Use static inner class
        static class StaticInner {
            public void doSomething() {
                System.out.println("Static Inner");
                // No reference to outer class
            }
        }
    }
    
    // 6. LEAK: Cache without eviction policy
    static class CacheLeak {
        private Map<String, byte[]> cache = new HashMap<>();
        
        public byte[] getData(String key) {
            byte[] data = cache.get(key);
            if (data == null) {
                data = loadData(key);
                cache.put(key, data);  // Never removed!
            }
            return data;
        }
        
        private byte[] loadData(String key) {
            return new byte[1024 * 1024];  // 1MB
        }
        
        // FIX: Use LRU cache or WeakHashMap
        static class LRUCache<K, V> extends LinkedHashMap<K, V> {
            private int maxSize;
            
            public LRUCache(int maxSize) {
                super(maxSize + 1, 1.0f, true);  // accessOrder = true
                this.maxSize = maxSize;
            }
            
            @Override
            protected boolean removeEldestEntry(Map.Entry<K, V> eldest) {
                return size() > maxSize;
            }
        }
    }
}
```

## 6.2 Detecting Memory Leaks

```java
import java.lang.management.*;
import java.util.*;

public class MemoryLeakDetection {
    
    /**
     * Tools for Detecting Memory Leaks:
     * 
     * 1. Heap Dumps:
     *    - jmap -dump:format=b,file=heap.bin <pid>
     *    - Analyze with Eclipse MAT, VisualVM, JProfiler
     * 
     * 2. VisualVM:
     *    - Monitor heap usage
     *    - Take heap dumps
     *    - Profile memory allocations
     * 
     * 3. JConsole:
     *    - Monitor memory pools
     *    - Track GC activity
     * 
     * 4. YourKit, JProfiler:
     *    - Commercial profilers
     *    - Advanced leak detection
     * 
     * 5. JVM Flags:
     *    - -XX:+HeapDumpOnOutOfMemoryError
     *    - -XX:HeapDumpPath=/path/to/dumps
     */
    
    // Programmatic memory monitoring
    public static class MemoryMonitor {
        
        public static void printMemoryUsage() {
            MemoryMXBean memoryBean = ManagementFactory.getMemoryMXBean();
            MemoryUsage heapUsage = memoryBean.getHeapMemoryUsage();
            
            long used = heapUsage.getUsed() / 1024 / 1024;
            long max = heapUsage.getMax() / 1024 / 1024;
            long committed = heapUsage.getCommitted() / 1024 / 1024;
            
            System.out.printf("Heap: %dMB / %dMB (committed: %dMB)%n", 
                             used, max, committed);
        }
        
        public static void monitorMemoryGrowth() {
            MemoryMXBean memoryBean = ManagementFactory.getMemoryMXBean();
            long previousUsed = 0;
            int growthCount = 0;
            
            for (int i = 0; i < 10; i++) {
                try {
                    Thread.sleep(1000);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
                
                long currentUsed = memoryBean.getHeapMemoryUsage().getUsed();
                
                if (currentUsed > previousUsed) {
                    growthCount++;
                    System.out.println("Memory growing: " + 
                                     (currentUsed / 1024 / 1024) + " MB");
                }
                
                previousUsed = currentUsed;
            }
            
            if (growthCount > 7) {
                System.err.println("WARNING: Potential memory leak detected!");
            }
        }
        
        public static void registerMemoryWarning() {
            MemoryMXBean memoryBean = ManagementFactory.getMemoryMXBean();
            NotificationEmitter emitter = (NotificationEmitter) memoryBean;
            
            emitter.addNotificationListener((notification, handback) -> {
                if (notification.getType().equals(
                        MemoryNotificationInfo.MEMORY_THRESHOLD_EXCEEDED)) {
                    System.err.println("Memory threshold exceeded!");
                    System.err.println("Current usage:");
                    printMemoryUsage();
                }
            }, null, null);
            
            // Set threshold at 80% of max heap
            MemoryPoolMXBean tenuredPool = findTenuredPool();
            if (tenuredPool != null) {
                long maxMemory = tenuredPool.getUsage().getMax();
                long warningThreshold = (long) (maxMemory * 0.8);
                tenuredPool.setUsageThreshold(warningThreshold);
            }
        }
        
        private static MemoryPoolMXBean findTenuredPool() {
            for (MemoryPoolMXBean pool : ManagementFactory.getMemoryPoolMXBeans()) {
                if (pool.getType() == MemoryType.HEAP && 
                    pool.isUsageThresholdSupported()) {
                    String name = pool.getName();
                    if (name.contains("Old") || name.contains("Tenured")) {
                        return pool;
                    }
                }
            }
            return null;
        }
    }
    
    // Memory leak simulator
    public static class MemoryLeakSimulator {
        private static List<byte[]> leak = new ArrayList<>();
        
        public static void simulateLeak() {
            System.out.println("Simulating memory leak...");
            MemoryMonitor.printMemoryUsage();
            
            // Allocate 10MB every second
            for (int i = 0; i < 100; i++) {
                byte[] data = new byte[10 * 1024 * 1024];  // 10MB
                leak.add(data);  // Never removed → leak!
                
                System.out.println("Allocated 10MB (iteration " + i + ")");
                MemoryMonitor.printMemoryUsage();
                
                try {
                    Thread.sleep(1000);
                } catch (InterruptedException e) {
                    break;
                }
            }
        }
        
        public static void main(String[] args) {
            MemoryMonitor.registerMemoryWarning();
            simulateLeak();
        }
    }
}
```

## 6.3 Real-World Memory Leak Example

```java
import java.util.*;
import java.util.concurrent.*;

public class RealWorldMemoryLeak {
    
    /**
     * Scenario: Web application with session management
     * Issue: Sessions not cleaned up after expiry
     */
    
    static class UserSession {
        private String sessionId;
        private String userId;
        private long createdAt;
        private Map<String, Object> attributes;
        
        public UserSession(String sessionId, String userId) {
            this.sessionId = sessionId;
            this.userId = userId;
            this.createdAt = System.currentTimeMillis();
            this.attributes = new HashMap<>();
        }
        
        public boolean isExpired(long timeoutMillis) {
            return System.currentTimeMillis() - createdAt > timeoutMillis;
        }
        
        public String getSessionId() {
            return sessionId;
        }
    }
    
    // LEAK VERSION: Sessions never cleaned
    static class LeakySessionManager {
        private static final Map<String, UserSession> sessions = 
            new ConcurrentHashMap<>();
        
        public void createSession(String sessionId, String userId) {
            UserSession session = new UserSession(sessionId, userId);
            sessions.put(sessionId, session);
            // Sessions never removed → MEMORY LEAK!
        }
        
        public UserSession getSession(String sessionId) {
            return sessions.get(sessionId);
        }
        
        // Problem: No cleanup mechanism
        // After hours/days of running, thousands of expired sessions accumulate
    }
    
    // FIXED VERSION: Periodic cleanup
    static class FixedSessionManager {
        private static final Map<String, UserSession> sessions = 
            new ConcurrentHashMap<>();
        
        private static final long SESSION_TIMEOUT = 30 * 60 * 1000;  // 30 minutes
        private static final ScheduledExecutorService cleanupExecutor = 
            Executors.newScheduledThreadPool(1);
        
        public FixedSessionManager() {
            // Schedule cleanup every 5 minutes
            cleanupExecutor.scheduleAtFixedRate(
                this::cleanupExpiredSessions,
                5, 5, TimeUnit.MINUTES
            );
        }
        
        public void createSession(String sessionId, String userId) {
            UserSession session = new UserSession(sessionId, userId);
            sessions.put(sessionId, session);
        }
        
        public UserSession getSession(String sessionId) {
            UserSession session = sessions.get(sessionId);
            if (session != null && session.isExpired(SESSION_TIMEOUT)) {
                sessions.remove(sessionId);  // Remove expired
                return null;
            }
            return session;
        }
        
        private void cleanupExpiredSessions() {
            System.out.println("Running session cleanup...");
            int removed = 0;
            
            Iterator<Map.Entry<String, UserSession>> iterator = 
                sessions.entrySet().iterator();
            
            while (iterator.hasNext()) {
                Map.Entry<String, UserSession> entry = iterator.next();
                if (entry.getValue().isExpired(SESSION_TIMEOUT)) {
                    iterator.remove();
                    removed++;
                }
            }
            
            System.out.println("Removed " + removed + " expired sessions");
            System.out.println("Active sessions: " + sessions.size());
        }
        
        public void shutdown() {
            cleanupExecutor.shutdown();
        }
    }
    
    // Test to demonstrate the leak
    public static void main(String[] args) throws Exception {
        System.out.println("=== Demonstrating Memory Leak ===");
        
        // Using leaky manager
        LeakySessionManager leakyManager = new LeakySessionManager();
        
        // Simulate user activity over time
        for (int i = 0; i < 10000; i++) {
            String sessionId = UUID.randomUUID().toString();
            String userId = "user" + i;
            leakyManager.createSession(sessionId, userId);
            
            if (i % 1000 == 0) {
                Runtime runtime = Runtime.getRuntime();
                long used = (runtime.totalMemory() - runtime.freeMemory()) / 1024 / 1024;
                System.out.println("Created " + i + " sessions, Memory: " + used + " MB");
            }
        }
        
        System.out.println("\n=== Using Fixed Manager ===");
        
        // Using fixed manager
        FixedSessionManager fixedManager = new FixedSessionManager();
        
        for (int i = 0; i < 10000; i++) {
            String sessionId = UUID.randomUUID().toString();
            String userId = "user" + i;
            fixedManager.createSession(sessionId, userId);
            
            if (i % 1000 == 0) {
                Runtime runtime = Runtime.getRuntime();
                long used = (runtime.totalMemory() - runtime.freeMemory()) / 1024 / 1024;
                System.out.println("Created " + i + " sessions, Memory: " + used + " MB");
                Thread.sleep(100);  // Allow cleanup to run
            }
        }
        
        fixedManager.cleanupExpiredSessions();
        fixedManager.shutdown();
    }
}
```

---

**Part 2 Progress:**

Covered:
- GC Tuning and Optimization (goals, flags, real-world examples) ✅
- GC Tuning Best Practices ✅
- Memory Leaks (6 common causes with fixes) ✅
- Memory Leak Detection (tools and programmatic monitoring) ✅
- Real-World Memory Leak Example (Session Management) ✅

# 7. REFERENCE TYPES

## 7.1 Strong References

```java
public class StrongReferences {
    
    /**
     * Strong Reference (Default):
     * - Normal references
     * - Object won't be GC'd while referenced
     * - Most common type
     */
    
    public static void main(String[] args) {
        // Strong reference
        Object obj = new Object();  // Strong reference
        
        // obj will NOT be garbage collected
        System.gc();
        
        System.out.println(obj);  // Still accessible
        
        // Setting to null makes object eligible for GC
        obj = null;
        System.gc();
        // Now object can be collected
    }
}
```

## 7.2 Soft References

```java
import java.lang.ref.*;
import java.util.*;

public class SoftReferences {
    
    /**
     * Soft Reference:
     * - Collected only if memory is low
     * - Good for caches
     * - JVM guarantees: cleared before OutOfMemoryError
     * - May survive multiple GC cycles
     */
    
    static class ExpensiveObject {
        private byte[] data;
        private String id;
        
        public ExpensiveObject(String id, int size) {
            this.id = id;
            this.data = new byte[size];
            System.out.println("Created: " + id);
        }
        
        @Override
        protected void finalize() {
            System.out.println("Finalized: " + id);
        }
    }
    
    // Example: Soft Reference Cache
    static class SoftCache<K, V> {
        private Map<K, SoftReference<V>> cache = new HashMap<>();
        
        public void put(K key, V value) {
            cache.put(key, new SoftReference<>(value));
        }
        
        public V get(K key) {
            SoftReference<V> ref = cache.get(key);
            if (ref != null) {
                V value = ref.get();  // May return null if collected
                if (value == null) {
                    cache.remove(key);  // Remove stale entry
                }
                return value;
            }
            return null;
        }
        
        public void clear() {
            cache.clear();
        }
    }
    
    public static void main(String[] args) {
        // Create object with strong reference
        ExpensiveObject strong = new ExpensiveObject("Strong", 1024);
        
        // Create object with soft reference
        SoftReference<ExpensiveObject> soft = new SoftReference<>(
            new ExpensiveObject("Soft", 1024)
        );
        
        System.out.println("Before GC:");
        System.out.println("Strong: " + strong);  // Not null
        System.out.println("Soft: " + soft.get());  // Not null
        
        // Request GC (soft reference may survive)
        System.gc();
        
        System.out.println("\nAfter GC (normal):");
        System.out.println("Strong: " + strong);  // Still not null
        System.out.println("Soft: " + soft.get());  // Probably still not null
        
        // Remove strong reference
        strong = null;
        
        // Allocate lots of memory to force soft reference collection
        try {
            List<byte[]> memory = new ArrayList<>();
            while (true) {
                memory.add(new byte[1024 * 1024]);  // 1MB
            }
        } catch (OutOfMemoryError e) {
            System.out.println("\nOut of memory!");
        }
        
        System.out.println("Soft after memory pressure: " + soft.get());  // Null
    }
    
    // Real-world use case: Image cache
    static class ImageCache {
        private SoftCache<String, BufferedImage> cache = new SoftCache<>();
        
        public BufferedImage getImage(String url) {
            // Check cache
            BufferedImage image = cache.get(url);
            
            if (image == null) {
                // Load from disk/network
                image = loadImage(url);
                cache.put(url, image);
            }
            
            return image;
        }
        
        private BufferedImage loadImage(String url) {
            // Simulate loading
            return new BufferedImage(800, 600);
        }
    }
    
    static class BufferedImage {
        private int width, height;
        public BufferedImage(int width, int height) {
            this.width = width;
            this.height = height;
        }
    }
}
```

## 7.3 Weak References

```java
import java.lang.ref.*;
import java.util.*;

public class WeakReferences {
    
    /**
     * Weak Reference:
     * - Collected in next GC cycle
     * - Regardless of memory availability
     * - Good for metadata/canonical mappings
     * - WeakHashMap uses weak keys
     */
    
    public static void main(String[] args) {
        Object strong = new Object();
        WeakReference<Object> weak = new WeakReference<>(strong);
        
        System.out.println("Before GC:");
        System.out.println("Strong: " + strong);
        System.out.println("Weak: " + weak.get());  // Not null
        
        // Weak reference keeps object alive (strong ref exists)
        System.gc();
        System.out.println("\nAfter GC (with strong ref):");
        System.out.println("Weak: " + weak.get());  // Still not null
        
        // Remove strong reference
        strong = null;
        
        // Now weak reference can be collected
        System.gc();
        System.out.println("\nAfter GC (without strong ref):");
        System.out.println("Weak: " + weak.get());  // Null
    }
    
    // Real-world use case: WeakHashMap
    static class WeakHashMapDemo {
        public static void demonstrate() {
            WeakHashMap<Key, String> weakMap = new WeakHashMap<>();
            
            Key key1 = new Key("key1");
            Key key2 = new Key("key2");
            
            weakMap.put(key1, "value1");
            weakMap.put(key2, "value2");
            
            System.out.println("Size before GC: " + weakMap.size());  // 2
            
            // Remove strong reference to key1
            key1 = null;
            
            System.gc();
            
            System.out.println("Size after GC: " + weakMap.size());  // 1
            // key1 entry was automatically removed!
        }
    }
    
    static class Key {
        private String name;
        
        public Key(String name) {
            this.name = name;
        }
        
        @Override
        protected void finalize() {
            System.out.println("Key finalized: " + name);
        }
    }
    
    // Use case: Canonical map (String interning)
    static class CanonicalMap<K, V> {
        private Map<K, WeakReference<V>> map = new HashMap<>();
        
        public V get(K key) {
            WeakReference<V> ref = map.get(key);
            return ref != null ? ref.get() : null;
        }
        
        public void put(K key, V value) {
            map.put(key, new WeakReference<>(value));
        }
        
        public void cleanup() {
            map.entrySet().removeIf(entry -> entry.getValue().get() == null);
        }
    }
}
```

## 7.4 Phantom References

```java
import java.lang.ref.*;
import java.util.*;

public class PhantomReferences {
    
    /**
     * Phantom Reference:
     * - get() always returns null
     * - Enqueued AFTER finalization
     * - Used for post-mortem cleanup
     * - Replacement for finalize()
     * - Must use with ReferenceQueue
     */
    
    static class Resource {
        private String id;
        private byte[] data;
        
        public Resource(String id) {
            this.id = id;
            this.data = new byte[1024 * 1024];  // 1MB
            System.out.println("Resource created: " + id);
        }
    }
    
    static class ResourcePhantomRef extends PhantomReference<Resource> {
        private String id;
        
        public ResourcePhantomRef(Resource resource, ReferenceQueue<Resource> queue) {
            super(resource, queue);
            this.id = resource.id;
        }
        
        public void cleanup() {
            System.out.println("Cleaning up resource: " + id);
            // Perform cleanup (close files, release native resources, etc.)
        }
    }
    
    public static void main(String[] args) throws Exception {
        ReferenceQueue<Resource> queue = new ReferenceQueue<>();
        List<ResourcePhantomRef> refs = new ArrayList<>();
        
        // Create resources with phantom references
        for (int i = 0; i < 5; i++) {
            Resource resource = new Resource("Resource-" + i);
            ResourcePhantomRef ref = new ResourcePhantomRef(resource, queue);
            refs.add(ref);
            // resource will be eligible for GC after this iteration
        }
        
        System.out.println("\nResources created, requesting GC...");
        System.gc();
        Thread.sleep(100);  // Give GC time to run
        
        // Process phantom references in queue
        System.out.println("\nProcessing phantom references:");
        Reference<? extends Resource> ref;
        while ((ref = queue.poll()) != null) {
            if (ref instanceof ResourcePhantomRef) {
                ((ResourcePhantomRef) ref).cleanup();
            }
        }
    }
    
    // Real-world use case: Native resource management
    static class NativeResourceManager {
        private ReferenceQueue<NativeResource> queue = new ReferenceQueue<>();
        private Set<NativeResourceRef> refs = new HashSet<>();
        
        static class NativeResource {
            private long nativePointer;  // Simulated native handle
            
            public NativeResource() {
                this.nativePointer = allocateNative();  // Native method
            }
            
            private long allocateNative() {
                // Simulate native allocation
                return System.nanoTime();
            }
        }
        
        class NativeResourceRef extends PhantomReference<NativeResource> {
            private long nativePointer;
            
            public NativeResourceRef(NativeResource resource) {
                super(resource, queue);
                this.nativePointer = resource.nativePointer;
            }
            
            public void cleanup() {
                freeNative(nativePointer);
            }
            
            private void freeNative(long pointer) {
                System.out.println("Freeing native resource: " + pointer);
                // Call native cleanup method
            }
        }
        
        public NativeResource allocate() {
            NativeResource resource = new NativeResource();
            NativeResourceRef ref = new NativeResourceRef(resource);
            refs.add(ref);
            return resource;
        }
        
        public void processQueue() {
            Reference<? extends NativeResource> ref;
            while ((ref = queue.poll()) != null) {
                if (ref instanceof NativeResourceRef) {
                    ((NativeResourceRef) ref).cleanup();
                    refs.remove(ref);
                }
            }
        }
    }
}
```

## 7.5 Reference Types Comparison

```java
public class ReferenceComparison {
    
    /**
     * Reference Types Comparison:
     * 
     * ┌─────────────┬──────────────┬─────────────┬──────────────────┐
     * │ Type        │ GC Behavior  │ get()       │ Use Case         │
     * ├─────────────┼──────────────┼─────────────┼──────────────────┤
     * │ Strong      │ Never GC'd   │ Object      │ Normal usage     │
     * │ Soft        │ Low memory   │ Object/null │ Caches           │
     * │ Weak        │ Next GC      │ Object/null │ Canonical maps   │
     * │ Phantom     │ After final  │ Always null │ Cleanup          │
     * └─────────────┴──────────────┴─────────────┴──────────────────┘
     * 
     * Strength Order: Strong > Soft > Weak > Phantom
     * 
     * When to use:
     * 
     * Strong (default):
     * - Normal object references
     * - When you need the object
     * 
     * Soft:
     * - Memory-sensitive caches
     * - Can recreate if collected
     * - JVM will try to keep them
     * 
     * Weak:
     * - Canonical mappings
     * - WeakHashMap keys
     * - Listeners/observers
     * - No need to prolong object life
     * 
     * Phantom:
     * - Post-mortem cleanup
     * - Better than finalize()
     * - Native resource management
     * - Must use with ReferenceQueue
     */
    
    public static void demonstrateAll() {
        Object obj = new Object();
        
        // Strong reference (normal)
        Object strong = obj;
        
        // Soft reference (survives if memory available)
        SoftReference<Object> soft = new SoftReference<>(obj);
        
        // Weak reference (collected in next GC)
        WeakReference<Object> weak = new WeakReference<>(obj);
        
        // Phantom reference (enqueued after finalization)
        ReferenceQueue<Object> queue = new ReferenceQueue<>();
        PhantomReference<Object> phantom = new PhantomReference<>(obj, queue);
        
        System.out.println("Strong: " + strong);  // Object
        System.out.println("Soft: " + soft.get());  // Object
        System.out.println("Weak: " + weak.get());  // Object
        System.out.println("Phantom: " + phantom.get());  // Always null!
        
        // Remove strong reference
        strong = null;
        obj = null;
        
        // Now soft and weak may be collected
        System.gc();
        
        System.out.println("\nAfter GC:");
        System.out.println("Soft: " + soft.get());  // Probably null
        System.out.println("Weak: " + weak.get());  // Definitely null
        System.out.println("Phantom in queue: " + (queue.poll() != null));  // true
    }
}
```

---

# 8. JVM PARAMETERS

## 8.1 Memory Parameters

```bash
# Heap Size
-Xms4g                    # Initial heap size (4GB)
-Xmx8g                    # Maximum heap size (8GB)
-Xmn2g                    # Young generation size (2GB)

# Stack Size
-Xss1m                    # Thread stack size (1MB per thread)

# Metaspace (Java 8+)
-XX:MetaspaceSize=256m    # Initial metaspace size
-XX:MaxMetaspaceSize=512m # Maximum metaspace size

# PermGen (Java 7 and earlier)
-XX:PermSize=256m         # Initial PermGen size
-XX:MaxPermSize=512m      # Maximum PermGen size

# Direct Memory
-XX:MaxDirectMemorySize=1g # Max direct/off-heap memory

# Generation Ratios
-XX:NewRatio=2            # Old:Young ratio (2:1)
-XX:SurvivorRatio=8       # Eden:Survivor ratio (8:1:1)
-XX:MaxTenuringThreshold=15 # GC age before promotion (max 15)
```

## 8.2 GC Selection and Tuning

```bash
# GC Selection
-XX:+UseSerialGC          # Serial GC
-XX:+UseParallelGC        # Parallel GC (default Java 8)
-XX:+UseConcMarkSweepGC   # CMS (deprecated)
-XX:+UseG1GC              # G1 GC (default Java 9+)
-XX:+UseZGC               # ZGC (Java 11+)
-XX:+UseShenandoahGC      # Shenandoah (Java 12+, OpenJDK)

# GC Threads
-XX:ParallelGCThreads=8   # Parallel GC worker threads
-XX:ConcGCThreads=2       # Concurrent GC threads

# GC Behavior
-XX:MaxGCPauseMillis=200  # Target max pause time
-XX:GCTimeRatio=19        # Throughput goal (1/(1+19) = 5% GC)
-XX:+DisableExplicitGC    # Ignore System.gc() calls

# G1 Specific
-XX:G1HeapRegionSize=16m  # Region size (1-32MB)
-XX:InitiatingHeapOccupancyPercent=45  # Start marking threshold
-XX:G1ReservePercent=10   # Reserve heap percentage
-XX:G1MixedGCCountTarget=8  # Mixed GC count target
```

## 8.3 GC Logging

```bash
# Java 8 GC Logging
-XX:+PrintGCDetails              # Detailed GC info
-XX:+PrintGCTimeStamps           # Timestamps
-XX:+PrintGCDateStamps           # Date stamps
-Xloggc:/var/log/app/gc.log     # GC log file
-XX:+UseGCLogFileRotation        # Rotate log files
-XX:NumberOfGCLogFiles=5         # Keep 5 files
-XX:GCLogFileSize=20M            # 20MB per file
-XX:+PrintGCApplicationStoppedTime  # App pause time
-XX:+PrintTenuringDistribution   # Object age distribution
-XX:+PrintHeapAtGC               # Heap before/after GC

# Java 9+ Unified Logging
-Xlog:gc                         # Basic GC logging
-Xlog:gc*                        # All GC logs
-Xlog:gc:file=gc.log             # To file
-Xlog:gc*:file=gc.log:time,uptime,level,tags  # With formatting
-Xlog:gc*=debug:file=gc.log      # Debug level
-Xlog:gc+heap=trace              # Heap details
```

## 8.4 Diagnostic and Debugging

```bash
# Heap Dumps
-XX:+HeapDumpOnOutOfMemoryError  # Dump heap on OOM
-XX:HeapDumpPath=/var/dumps/     # Dump location
-XX:OnOutOfMemoryError="script.sh"  # Run script on OOM

# Error File
-XX:ErrorFile=/var/log/hs_err_pid%p.log  # JVM error log

# Flight Recorder
-XX:+FlightRecorder              # Enable JFR
-XX:StartFlightRecording=duration=60s,filename=recording.jfr

# Print Configuration
-XX:+PrintCommandLineFlags       # Print JVM flags used
-XX:+PrintFlagsFinal             # Print all JVM flags
-XX:+UnlockDiagnosticVMOptions  # Unlock diagnostic options
-XX:+PrintCompilation            # Print JIT compilation
```

## 8.5 Performance Tuning

```bash
# JIT Compilation
-XX:CompileThreshold=10000       # Method invocations before compilation
-XX:+TieredCompilation           # Tiered compilation (default)
-XX:TieredStopAtLevel=1          # Stop at C1 (fast compile)
-XX:+UseCodeCacheFlushing        # Flush code cache when full
-XX:ReservedCodeCacheSize=256m   # Code cache size

# String Deduplication (G1)
-XX:+UseStringDeduplication      # Deduplicate strings
-XX:StringDeduplicationAgeThreshold=3  # Age before dedup

# Large Pages
-XX:+UseLargePages               # Use large memory pages
-XX:LargePageSizeInBytes=2m      # Page size

# NUMA
-XX:+UseNUMA                     # NUMA-aware allocation

# Aggressive Optimizations
-XX:+AggressiveOpts              # Enable experimental optimizations
```

## 8.6 Container-Aware Settings

```bash
# Container Support (Java 8u191+, 10+)
-XX:+UseContainerSupport         # Respect container limits (default)
-XX:MaxRAMPercentage=75.0        # Use 75% of container memory
-XX:InitialRAMPercentage=50.0    # Initial heap percentage
-XX:MinRAMPercentage=25.0        # Min heap percentage

# CPU Usage
-XX:ActiveProcessorCount=4       # Override CPU count

# Example for 2GB container:
# -XX:MaxRAMPercentage=75.0 → Xmx ~ 1.5GB
```

## 8.7 Common Flag Combinations

```bash
# Production Web Application (G1)
java -XX:+UseG1GC \
     -Xms4g -Xmx4g \
     -XX:MaxGCPauseMillis=200 \
     -XX:+HeapDumpOnOutOfMemoryError \
     -XX:HeapDumpPath=/var/dumps/ \
     -Xlog:gc*:file=/var/log/app/gc.log:time,uptime \
     -jar myapp.jar

# High Throughput Batch Job (Parallel)
java -XX:+UseParallelGC \
     -Xms8g -Xmx8g \
     -XX:ParallelGCThreads=8 \
     -XX:GCTimeRatio=19 \
     -jar batchjob.jar

# Low Latency Service (ZGC)
java -XX:+UseZGC \
     -Xms16g -Xmx16g \
     -XX:ConcGCThreads=4 \
     -XX:+HeapDumpOnOutOfMemoryError \
     -jar service.jar

# Microservice in 1GB Container
java -XX:+UseG1GC \
     -XX:MaxRAMPercentage=75.0 \
     -XX:+UseContainerSupport \
     -XX:MaxGCPauseMillis=100 \
     -jar microservice.jar

# Development/Debugging
java -XX:+UseG1GC \
     -Xms512m -Xmx2g \
     -XX:+UnlockDiagnosticVMOptions \
     -XX:+PrintCompilation \
     -Xlog:gc*=debug:file=gc.log \
     -XX:+HeapDumpOnOutOfMemoryError \
     -jar app.jar
```

---

**Part 3 Progress:**

Covered:
- Reference Types (Strong, Soft, Weak, Phantom) ✅
- Complete comparison and use cases ✅
- JVM Parameters (Memory, GC, Logging, Diagnostic, Performance, Container) ✅
- Common flag combinations for different scenarios ✅

# 9. OUTOFMEMORYERROR TYPES

## 9.1 Java Heap Space

```java
public class HeapSpaceOOM {
    
    /**
     * java.lang.OutOfMemoryError: Java heap space
     * 
     * Cause:
     * - Creating too many objects
     * - Memory leak
     * - Heap size too small
     * 
     * Symptoms:
     * - Slow performance before error
     * - Frequent Full GCs
     * - Application crash
     */
    
    public static void causeHeapOOM() {
        List<byte[]> list = new ArrayList<>();
        
        while (true) {
            byte[] data = new byte[1024 * 1024];  // 1MB
            list.add(data);  // Keeps reference → not GC'd
        }
        // Eventually: OutOfMemoryError: Java heap space
    }
    
    /**
     * Solutions:
     * 1. Increase heap size: -Xmx4g
     * 2. Fix memory leaks (use profiler)
     * 3. Optimize object allocation
     * 4. Use object pooling
     * 5. Process data in chunks (streaming)
     */
    
    // Better approach: Process in batches
    public static void processBatches(List<String> files) {
        int batchSize = 100;
        for (int i = 0; i < files.size(); i += batchSize) {
            int end = Math.min(i + batchSize, files.size());
            List<String> batch = files.subList(i, end);
            processBatch(batch);
            // Objects from previous batch can be GC'd
        }
    }
    
    private static void processBatch(List<String> batch) {
        // Process batch
    }
}
```

## 9.2 GC Overhead Limit Exceeded

```java
public class GCOverheadOOM {
    
    /**
     * java.lang.OutOfMemoryError: GC overhead limit exceeded
     * 
     * Cause:
     * - JVM spending > 98% time in GC
     * - Recovering < 2% of heap
     * - Application making no progress
     * 
     * Trigger: Multiple Full GCs with little memory recovered
     */
    
    public static void causeGCOverhead() {
        Map<Integer, String> map = new HashMap<>();
        int i = 0;
        
        while (true) {
            map.put(i++, "Value" + i);
            // Heap nearly full, constant GC, minimal recovery
        }
        // OutOfMemoryError: GC overhead limit exceeded
    }
    
    /**
     * Solutions:
     * 1. Increase heap: -Xmx2g
     * 2. Fix memory leak
     * 3. Optimize algorithm
     * 4. Disable check: -XX:-UseGCOverheadLimit (not recommended)
     * 5. Reduce object creation
     */
}
```

## 9.3 Metaspace / PermGen

```java
public class MetaspaceOOM {
    
    /**
     * Java 8+: OutOfMemoryError: Metaspace
     * Java 7-: OutOfMemoryError: PermGen space
     * 
     * Cause:
     * - Too many classes loaded
     * - Class loaders not released
     * - Excessive use of dynamic proxies/reflection
     * - Hot deployment without proper cleanup
     */
    
    public static void causeMetaspaceOOM() {
        // Generate classes dynamically
        while (true) {
            try {
                // Using bytecode generation library like ASM/Javassist
                // or custom ClassLoader
                ClassLoader loader = new ClassLoader() {
                    public Class<?> loadClass(String name) {
                        byte[] bytecode = generateClass(name);
                        return defineClass(name, bytecode, 0, bytecode.length);
                    }
                };
                
                Class<?> clazz = loader.loadClass("DynamicClass" + System.currentTimeMillis());
                // ClassLoader not released → classes not unloaded
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        // OutOfMemoryError: Metaspace
    }
    
    private static byte[] generateClass(String name) {
        // Generate bytecode (simplified)
        return new byte[1024];
    }
    
    /**
     * Solutions:
     * 1. Increase Metaspace: -XX:MaxMetaspaceSize=512m
     * 2. Fix ClassLoader leaks
     * 3. Reduce dynamic class generation
     * 4. Proper cleanup on redeployment
     * 5. Monitor Metaspace usage
     */
}
```

## 9.4 Unable to Create New Native Thread

```java
public class ThreadOOM {
    
    /**
     * java.lang.OutOfMemoryError: unable to create new native thread
     * 
     * Cause:
     * - OS limit on threads per process
     * - Too many threads created
     * - Stack size too large
     * - Insufficient OS resources
     */
    
    public static void causeThreadOOM() {
        int count = 0;
        
        while (true) {
            new Thread(() -> {
                try {
                    Thread.sleep(Long.MAX_VALUE);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }).start();
            
            count++;
            System.out.println("Created thread: " + count);
        }
        // OutOfMemoryError: unable to create new native thread
    }
    
    /**
     * Solutions:
     * 1. Reduce thread count (use thread pools)
     * 2. Decrease stack size: -Xss512k
     * 3. Increase OS limits:
     *    Linux: ulimit -u (max user processes)
     *    Windows: No built-in limit (RAM dependent)
     * 4. Use async/non-blocking I/O
     * 5. Find thread leaks
     */
    
    // Better: Use ExecutorService
    public static void useThreadPool() {
        ExecutorService executor = Executors.newFixedThreadPool(10);
        
        for (int i = 0; i < 1000; i++) {
            executor.submit(() -> {
                // Task
            });
        }
        
        executor.shutdown();
    }
}
```

## 9.5 Direct Buffer Memory

```java
import java.nio.ByteBuffer;

public class DirectBufferOOM {
    
    /**
     * java.lang.OutOfMemoryError: Direct buffer memory
     * 
     * Cause:
     * - Allocating too much direct (off-heap) memory
     * - DirectByteBuffers not released
     * - NIO operations
     */
    
    public static void causeDirectBufferOOM() {
        List<ByteBuffer> buffers = new ArrayList<>();
        
        while (true) {
            ByteBuffer buffer = ByteBuffer.allocateDirect(1024 * 1024);  // 1MB
            buffers.add(buffer);
        }
        // OutOfMemoryError: Direct buffer memory
    }
    
    /**
     * Solutions:
     * 1. Increase direct memory: -XX:MaxDirectMemorySize=1g
     * 2. Manually free buffers: ((DirectBuffer) buffer).cleaner().clean()
     * 3. Use try-with-resources or explicit cleanup
     * 4. Monitor direct memory usage
     * 5. Reduce direct buffer allocations
     */
    
    // Proper cleanup
    public static void properDirectBufferUsage() {
        ByteBuffer buffer = ByteBuffer.allocateDirect(1024 * 1024);
        
        try {
            // Use buffer
        } finally {
            // Manual cleanup (if needed)
            if (buffer instanceof sun.nio.ch.DirectBuffer) {
                sun.nio.ch.DirectBuffer directBuffer = (sun.nio.ch.DirectBuffer) buffer;
                sun.misc.Cleaner cleaner = directBuffer.cleaner();
                if (cleaner != null) {
                    cleaner.clean();
                }
            }
        }
    }
}
```

## 9.6 Requested Array Size Exceeds VM Limit

```java
public class ArraySizeOOM {
    
    /**
     * java.lang.OutOfMemoryError: Requested array size exceeds VM limit
     * 
     * Cause:
     * - Trying to allocate array larger than VM supports
     * - Maximum array size: Integer.MAX_VALUE - some header words
     * - Typically around 2^31 - 5
     */
    
    public static void causeArraySizeOOM() {
        int size = Integer.MAX_VALUE - 1;
        byte[] array = new byte[size];
        // OutOfMemoryError: Requested array size exceeds VM limit
    }
    
    /**
     * Solutions:
     * 1. Use multiple smaller arrays
     * 2. Use collection of arrays
     * 3. Process data in chunks
     * 4. Use memory-mapped files
     * 5. Consider distributed approach
     */
    
    // Better: Chunked array
    static class ChunkedArray {
        private static final int CHUNK_SIZE = 100_000_000;  // 100M
        private List<byte[]> chunks = new ArrayList<>();
        
        public void allocate(long totalSize) {
            int numChunks = (int) (totalSize / CHUNK_SIZE) + 1;
            
            for (int i = 0; i < numChunks; i++) {
                int chunkSize = (int) Math.min(CHUNK_SIZE, totalSize - (long) i * CHUNK_SIZE);
                chunks.add(new byte[chunkSize]);
            }
        }
        
        public byte get(long index) {
            int chunkIndex = (int) (index / CHUNK_SIZE);
            int offset = (int) (index % CHUNK_SIZE);
            return chunks.get(chunkIndex)[offset];
        }
    }
}
```

---

# 10. MONITORING AND PROFILING

## 10.1 Command-Line Tools

```bash
# jps - List Java processes
jps -l                    # Show main class
jps -v                    # Show JVM arguments

# jstat - JVM statistics
jstat -gc <pid>           # GC statistics
jstat -gc <pid> 1000      # Every 1 second
jstat -gcutil <pid>       # GC percentage
jstat -gccause <pid>      # GC reason
jstat -class <pid>        # Class loader stats

# jmap - Memory map
jmap -heap <pid>          # Heap summary
jmap -histo <pid>         # Object histogram
jmap -dump:format=b,file=heap.bin <pid>  # Heap dump
jmap -clstats <pid>       # Class loader statistics

# jstack - Thread dump
jstack <pid>              # Thread dump
jstack -l <pid>           # With locks
jstack -F <pid>           # Force if hung

# jinfo - Configuration
jinfo <pid>               # All info
jinfo -flags <pid>        # JVM flags
jinfo -flag PrintGC <pid> # Specific flag

# jcmd - Multi-purpose
jcmd <pid> GC.heap_info   # Heap info
jcmd <pid> Thread.print   # Thread dump
jcmd <pid> GC.class_histogram  # Class histogram
jcmd <pid> VM.flags       # JVM flags
jcmd <pid> VM.system_properties  # System properties
```

## 10.2 Monitoring with JMX

```java
import java.lang.management.*;
import javax.management.*;

public class JMXMonitoring {
    
    public static void monitorMemory() {
        MemoryMXBean memoryBean = ManagementFactory.getMemoryMXBean();
        
        // Heap memory
        MemoryUsage heapUsage = memoryBean.getHeapMemoryUsage();
        System.out.println("Heap Memory:");
        System.out.println("  Init: " + heapUsage.getInit() / 1024 / 1024 + " MB");
        System.out.println("  Used: " + heapUsage.getUsed() / 1024 / 1024 + " MB");
        System.out.println("  Committed: " + heapUsage.getCommitted() / 1024 / 1024 + " MB");
        System.out.println("  Max: " + heapUsage.getMax() / 1024 / 1024 + " MB");
        
        // Non-heap memory
        MemoryUsage nonHeapUsage = memoryBean.getNonHeapMemoryUsage();
        System.out.println("\nNon-Heap Memory (Metaspace):");
        System.out.println("  Used: " + nonHeapUsage.getUsed() / 1024 / 1024 + " MB");
        System.out.println("  Committed: " + nonHeapUsage.getCommitted() / 1024 / 1024 + " MB");
    }
    
    public static void monitorGC() {
        List<GarbageCollectorMXBean> gcBeans = 
            ManagementFactory.getGarbageCollectorMXBeans();
        
        System.out.println("Garbage Collectors:");
        for (GarbageCollectorMXBean gcBean : gcBeans) {
            System.out.println("  " + gcBean.getName() + ":");
            System.out.println("    Collections: " + gcBean.getCollectionCount());
            System.out.println("    Time: " + gcBean.getCollectionTime() + " ms");
            System.out.println("    Pools: " + String.join(", ", gcBean.getMemoryPoolNames()));
        }
    }
    
    public static void monitorThreads() {
        ThreadMXBean threadBean = ManagementFactory.getThreadMXBean();
        
        System.out.println("Threads:");
        System.out.println("  Count: " + threadBean.getThreadCount());
        System.out.println("  Peak: " + threadBean.getPeakThreadCount());
        System.out.println("  Daemon: " + threadBean.getDaemonThreadCount());
        System.out.println("  Total Started: " + threadBean.getTotalStartedThreadCount());
        
        // Deadlock detection
        long[] deadlockedThreads = threadBean.findDeadlockedThreads();
        if (deadlockedThreads != null) {
            System.out.println("\n  WARNING: " + deadlockedThreads.length + " deadlocked threads!");
        }
    }
    
    public static void monitorMemoryPools() {
        List<MemoryPoolMXBean> poolBeans = 
            ManagementFactory.getMemoryPoolMXBeans();
        
        System.out.println("Memory Pools:");
        for (MemoryPoolMXBean poolBean : poolBeans) {
            MemoryUsage usage = poolBean.getUsage();
            System.out.println("  " + poolBean.getName() + ":");
            System.out.println("    Type: " + poolBean.getType());
            System.out.println("    Used: " + usage.getUsed() / 1024 / 1024 + " MB");
            System.out.println("    Max: " + usage.getMax() / 1024 / 1024 + " MB");
        }
    }
    
    public static void main(String[] args) {
        monitorMemory();
        System.out.println();
        monitorGC();
        System.out.println();
        monitorThreads();
        System.out.println();
        monitorMemoryPools();
    }
}
```

## 10.3 Profiling Tools Overview

```
Profiling Tools:

1. VisualVM (Free):
   - CPU profiling
   - Memory profiling
   - Thread analysis
   - Heap dumps
   - Visual GC plugin

2. JConsole (Free, included with JDK):
   - Memory monitoring
   - Thread monitoring
   - CPU usage
   - MBean browser

3. Java Mission Control (Free):
   - Low overhead profiling
   - Flight Recorder integration
   - Event-based profiling
   - Memory leak detection

4. YourKit (Commercial):
   - Advanced profiling
   - Memory leak detection
   - CPU profiling
   - SQL profiling

5. JProfiler (Commercial):
   - CPU profiling
   - Memory profiling
   - Thread profiling
   - Database profiling

6. Async-profiler (Free):
   - Low overhead sampling
   - CPU and memory
   - Flame graphs
   - No SafePoint bias

7. Arthas (Free, Alibaba):
   - Online diagnosis
   - No restart required
   - JVM monitoring
   - Method tracing

8. Eclipse MAT (Memory Analyzer Tool):
   - Heap dump analysis
   - Memory leak detection
   - Dominator tree
   - OQL queries

Tool Selection:
- Development: VisualVM, JProfiler
- Production: Java Mission Control, async-profiler
- Heap Analysis: Eclipse MAT
- Online Diagnosis: Arthas
- Budget: VisualVM, JConsole, Async-profiler
```

---

# 11. INTERVIEW QUESTIONS WITH ANSWERS

## Q1: Explain the difference between Young Generation and Old Generation. Why is heap divided this way?

**Answer:**

The heap is divided based on the **Generational Hypothesis**: "Most objects die young."

**Young Generation (1/3 of heap by default):**
- For newly created objects
- Subdivided into:
  - **Eden Space (80%)**: New objects allocated here
  - **Survivor Space 0 (10%)**: Objects that survived 1+ GC
  - **Survivor Space 1 (10%)**: Alternate survivor space
- **Minor GC** occurs frequently but is fast (copying algorithm)
- Low pause time (typically milliseconds)

**Old Generation (2/3 of heap):**
- For long-lived objects
- Objects promoted after surviving threshold GCs (default 15)
- **Major GC/Full GC** occurs less frequently but slower
- Uses Mark-Sweep-Compact algorithm
- Higher pause time (can be seconds without proper tuning)

**Why This Division?**

1. **Performance**: Different algorithms for different lifetimes
   - Young: Fast copying (most objects dead)
   - Old: Mark-Sweep-Compact (most objects alive)

2. **GC Efficiency**: 
   - 90% of objects die young → frequent Minor GC cleans most garbage
   - Only 10% reach Old Gen → infrequent Major GC

3. **Pause Time Optimization**:
   - Minor GC on smaller Young Gen is faster
   - Major GC on larger Old Gen happens less often

**Example:**
```java
// Most objects die in Young Gen
for (int i = 0; i < 1000; i++) {
    String temp = "Temp" + i;  // Dies immediately
}

// Long-lived objects promoted to Old Gen
static Map<String, String> cache = new HashMap<>();  // Never GC'd
```

---

## Q2: What is Stop-The-World (STW)? Which GC phases cause STW events?

**Answer:**

**Stop-The-World (STW)** is when the JVM pauses all application threads to perform garbage collection. No application code runs during STW.

**Why STW is Needed:**
- GC must have consistent memory snapshot
- Objects cannot move while application threads reference them
- Prevents race conditions during marking/compaction

**GC Phases that Cause STW:**

**Serial/Parallel GC:**
- ALL phases are STW
- Young GC: 10-50ms typically
- Old GC: Can be seconds for large heaps

**CMS (Concurrent Mark Sweep):**
- Initial Mark: STW (mark GC roots) - short
- Concurrent Mark: No STW - runs with application
- Concurrent Premark: No STW
- Remark: STW (re-mark changed objects) - short
- Concurrent Sweep: No STW
- Concurrent Reset: No STW

**G1 GC:**
- Young GC: STW (entire young region)
- Initial Mark: STW (piggybacked on Young GC)
- Concurrent Mark: No STW
- Remark: STW (short)
- Cleanup: STW (short) + No STW phases
- Mixed GC: STW

**ZGC/Shenandoah:**
- Only tiny STW pauses (<10ms)
- Most phases concurrent with application

**Impact on Application:**
- STW pauses cause latency spikes
- Long pauses (>100ms) affect user experience
- Trading systems/games need low pause times → use ZGC/Shenandoah

**Monitoring STW:**
```bash
# Java 8
-XX:+PrintGCApplicationStoppedTime

# Java 9+
-Xlog:safepoint
```

---

## Q3: What is the difference between -Xms, -Xmx, and -Xmn?

**Answer:**

**-Xms (Initial Heap Size):**
- Heap size when JVM starts
- Memory allocated at startup
- Example: `-Xms2g` starts with 2GB heap

**-Xmx (Maximum Heap Size):**
- Maximum heap size JVM can grow to
- JVM requests more from OS as needed (up to Xmx)
- Example: `-Xmx4g` allows heap to grow to 4GB

**-Xmn (Young Generation Size):**
- Fixed size for Young Generation (Eden + Survivors)
- Example: `-Xmn1g` sets Young Gen to 1GB
- Alternative: `-XX:NewRatio=2` (Old:Young = 2:1)

**Best Practices:**

1. **Set Xms = Xmx (Recommended):**
```bash
-Xms4g -Xmx4g
```
**Why?**
- Avoids heap resizing overhead
- Prevents OS memory fragmentation
- Predictable memory usage

2. **Avoid Setting Xmn in Production:**
```bash
# Don't do this:
-Xms4g -Xmx4g -Xmn2g

# Better: Let GC auto-tune
-Xms4g -Xmx4g -XX:MaxGCPauseMillis=200
```
**Why?**
- Modern GCs (G1/ZGC) auto-tune Young Gen size
- Fixed Xmn prevents adaptive sizing
- Different workloads need different Young:Old ratios

**Examples:**

```bash
# Batch processing (large Old Gen)
-Xms8g -Xmx8g
# Young will be ~2.6GB (1/3), Old ~5.4GB (2/3)

# High throughput (large Young Gen for short-lived objects)
-Xms8g -Xmx8g -XX:NewRatio=1
# Young = 4GB, Old = 4GB (1:1 ratio)

# Vertical scaling (heap grows as needed)
-Xms512m -Xmx4g
# Starts at 512MB, grows to 4GB (NOT recommended for production)
```

**Memory Layout:**
```
Xms=Xmx=4GB, default NewRatio=2:

|<------------ 4GB Heap (Xmx) ------------>|
|                                           |
|<--- Young Gen (~1.3GB) --->|<- Old Gen (~2.7GB) ->|
| Eden | S0 | S1 |           |                       |
|  1GB |128M|128M|           |       2.7GB           |
```

---

## Q4: How does G1 GC differ from CMS? When would you choose one over the other?

**Answer:**

**Key Differences:**

| Aspect | CMS | G1 GC |
|--------|-----|-------|
| **Heap Structure** | Contiguous Young/Old Gen | 2000+ equal-sized regions |
| **Goal** | Low pause time | Predictable pause time |
| **Pause Target** | Best effort | `-XX:MaxGCPauseMillis=200` |
| **Compaction** | No (leads to fragmentation) | Yes (during cleanup) |
| **Fragmentation** | Issues with long-running apps | Mitigated by regions |
| **Default** | Never (deprecated Java 9) | Since Java 9 |
| **Status** | Removed Java 14 | Production-ready |
| **Concurrent Phase Failure** | Falls back to Serial GC | Adjusts regions |
| **Memory Overhead** | Lower | Higher (tracking regions) |

**CMS (Concurrent Mark Sweep):**

**Pros:**
- Lower memory overhead
- Good for applications needing low pause
- Mature and stable (in Java 7-8)

**Cons:**
- **No compaction** → fragmentation over time
- **Concurrent Mode Failure**: If Old Gen fills during concurrent marking → falls back to slow Serial GC
- **CPU overhead**: Concurrent phases use CPU
- **Deprecated** (Java 9) and **removed** (Java 14)

**When to Use CMS:**
- Legacy Java 7-8 applications
- Large heap with low pause requirements
- Not recommended for new projects

**G1 GC (Garbage First):**

**Pros:**
- **Predictable pause times**: Target achieved most of the time
- **Compacting**: No fragmentation issues
- **Adaptive**: Auto-tunes Young Gen size
- **Region-based**: Collects most garbage-filled regions first
- **Default** since Java 9

**Cons:**
- Higher memory overhead (region tracking)
- Not as low latency as ZGC/Shenandoah
- Complex tuning if defaults don't work

**When to Use G1:**
- **Default choice** for Java 9+ applications
- Heaps > 4GB
- Pause time requirements: 50-500ms
- Long-running applications
- Microservices, web applications

**Decision Matrix:**

```
Heap Size & Requirements:

< 4GB              → Parallel GC (high throughput)
4GB - 64GB         → G1 GC (balanced)
> 64GB & low pause → ZGC/Shenandoah (<10ms pause)

Pause Requirements:

Don't care          → Parallel GC (max throughput)
100-500ms OK        → G1 GC
< 10ms required     → ZGC/Shenandoah

Application Type:

Batch processing    → Parallel GC
Web application     → G1 GC
Trading system      → ZGC
Microservice        → G1 GC (container-aware)
```

**Example Configurations:**

```bash
# CMS (legacy Java 8)
-XX:+UseConcMarkSweepGC
-XX:+CMSParallelRemarkEnabled
-XX:CMSInitiatingOccupancyFraction=70
-XX:+UseCMSInitiatingOccupancyOnly

# G1 GC (modern Java 11+)
-XX:+UseG1GC
-XX:MaxGCPauseMillis=200
-XX:G1HeapRegionSize=16m
-XX:InitiatingHeapOccupancyPercent=45
```

---

## Q5: Explain how ClassLoader works. What is parent delegation model?

**Answer:**

**ClassLoader Hierarchy:**

```
Bootstrap ClassLoader (C/C++)
    - Loads core Java classes (rt.jar)
    - java.lang.*, java.util.*, etc.
    ↓ parent
Platform ClassLoader (Java 9+) / Extension ClassLoader (Java 8)
    - Loads platform/extension classes
    - jre/lib/ext/
    ↓ parent
Application ClassLoader
    - Loads application classes
    - CLASSPATH
    ↓ parent
Custom ClassLoader (optional)
    - User-defined class loading
```

**Parent Delegation Model:**

When a class is requested:
1. Check if class already loaded (cache)
2. Delegate to **parent** ClassLoader
3. Parent follows steps 1-2 recursively
4. If parent can't find class, load it yourself (`findClass`)

**Why This Model?**

1. **Prevents duplicates**: Class loaded once by highest ClassLoader
2. **Security**: Core classes cannot be replaced
3. **Consistency**: Same class across application

**Example:**

```java
// Request to load java.lang.String

Application ClassLoader:
  → Delegates to Platform ClassLoader
    → Delegates to Bootstrap ClassLoader
      → Finds String in rt.jar
      → Returns String.class
    ← String.class returned to Platform
  ← String.class returned to Application
```

**Breaking Parent Delegation:**

```java
public class CustomClassLoader extends ClassLoader {
    
    @Override
    protected Class<?> loadClass(String name, boolean resolve) 
            throws ClassNotFoundException {
        
        // Check if already loaded
        Class<?> clazz = findLoadedClass(name);
        if (clazz != null) {
            return clazz;
        }
        
        // Load com.myapp.* ourselves BEFORE delegating to parent
        if (name.startsWith("com.myapp.")) {
            try {
                // Read bytecode from custom source
                byte[] bytecode = loadClassData(name);
                clazz = defineClass(name, bytecode, 0, bytecode.length);
                
                if (resolve) {
                    resolveClass(clazz);
                }
                
                return clazz;
            } catch (IOException e) {
                throw new ClassNotFoundException("Cannot load " + name, e);
            }
        }
        
        // For other classes, delegate to parent (normal delegation)
        return super.loadClass(name, resolve);
    }
    
    private byte[] loadClassData(String name) throws IOException {
        String path = name.replace('.', '/') + ".class";
        // Read from custom source (DB, network, encrypted file, etc.)
        return Files.readAllBytes(Paths.get("/custom/path/" + path));
    }
}

// Usage:
CustomClassLoader loader = new CustomClassLoader();
Class<?> clazz = loader.loadClass("com.myapp.DynamicClass");
Object instance = clazz.getDeclaredConstructor().newInstance();
```

**Class Loading Phases:**

1. **Loading**: Read .class file, create Class object
2. **Linking**:
   - **Verification**: Bytecode verification (security)
   - **Preparation**: Allocate memory for static fields, set default values
   - **Resolution**: Resolve symbolic references to actual references
3. **Initialization**: Execute static initializers, static blocks

**Real-World Use Cases:**

1. **Hot Deployment** (Tomcat, JBoss):
   - Each WAR has own ClassLoader
   - Redeploy → create new ClassLoader, discard old

2. **Plugin Systems**:
   - Load plugins from JARs at runtime
   - Each plugin in isolated ClassLoader

3. **OSGI**:
   - Complex module system
   - Multiple versions of same class

4. **Java Agents**:
   - Instrument bytecode
   - Custom class loading

**Interview Trap:**

❌ **Wrong:**
```java
// Trying to load core class with custom ClassLoader
CustomClassLoader loader = new CustomClassLoader();
Class<?> stringClass = loader.loadClass("java.lang.String");
// String is ALWAYS loaded by Bootstrap ClassLoader (parent delegation)
```

✅ **Right:**
```java
// Custom classes can be loaded by custom ClassLoader
CustomClassLoader loader = new CustomClassLoader();
Class<?> myClass = loader.loadClass("com.myapp.MyClass");
// If MyClass not found by parent, loaded by CustomClassLoader
```

---

## Q6: What causes memory leaks in Java despite GC? Give real-world examples.

**Answer:**

Memory leaks occur when objects are **unintentionally held in memory** (still referenced but not used).

**Common Causes & Real-World Examples:**

**1. Static Collections:**

❌ **Leak:**
```java
public class UserService {
    private static List<User> cache = new ArrayList<>();
    
    public void addUser(User user) {
        cache.add(user);  // NEVER removed → leak
    }
}
// All Users remain in memory forever (static field)
```

✅ **Fix:**
```java
private static Map<String, WeakReference<User>> cache = new WeakHashMap<>();
// Or use bounded cache with eviction policy
```

**2. Listeners Not Removed:**

❌ **Leak (Real-World: Swing/JavaFX):**
```java
public class UserPanel extends JPanel {
    public UserPanel() {
        EventBus.register(this);  // Registers listener
    }
    // UserPanel closed, but EventBus still holds reference → leak
}
```

✅ **Fix:**
```java
public void dispose() {
    EventBus.unregister(this);  // Remove listener
    super.dispose();
}
```

**3. ThreadLocal in Thread Pools:**

❌ **Leak (Real-World: Web Servers):**
```java
public class RequestContext {
    private static ThreadLocal<User> currentUser = new ThreadLocal<>();
    
    public void handleRequest(User user) {
        currentUser.set(user);  // Set for thread
        // ... process request ...
        // FORGOT to remove → thread reused with old user
    }
}
```

✅ **Fix:**
```java
public void handleRequest(User user) {
    try {
        currentUser.set(user);
        // ... process request ...
    } finally {
        currentUser.remove();  // CRITICAL
    }
}
```

**4. Unclosed Resources:**

❌ **Leak (Real-World: DB Connections):**
```java
public List<User> getUsers() {
    Connection conn = dataSource.getConnection();
    Statement stmt = conn.createStatement();
    ResultSet rs = stmt.executeQuery("SELECT * FROM users");
    // Exception thrown → connection not closed → leak
    return extractUsers(rs);
}
```

✅ **Fix:**
```java
public List<User> getUsers() {
    try (Connection conn = dataSource.getConnection();
         Statement stmt = conn.createStatement();
         ResultSet rs = stmt.executeQuery("SELECT * FROM users")) {
        return extractUsers(rs);
    }  // Auto-closed even if exception
}
```

**5. Inner Classes Holding Outer References:**

❌ **Leak (Real-World: Android Activities):**
```java
public class MainActivity extends Activity {
    
    class BackgroundTask implements Runnable {
        public void run() {
            // Long-running task
            // Implicitly holds reference to MainActivity → leak if activity destroyed
        }
    }
    
    public void onStart() {
        new Thread(new BackgroundTask()).start();
    }
}
```

✅ **Fix:**
```java
static class BackgroundTask implements Runnable {
    private final WeakReference<MainActivity> activityRef;
    
    BackgroundTask(MainActivity activity) {
        this.activityRef = new WeakReference<>(activity);
    }
    
    public void run() {
        MainActivity activity = activityRef.get();
        if (activity == null) return;  // Activity destroyed → safe
        // Task
    }
}
```

**6. Caches Without Eviction:**

❌ **Leak (Real-World: Image Cache):**
```java
public class ImageCache {
    private static Map<String, Image> cache = new HashMap<>();
    
    public Image getImage(String url) {
        return cache.computeIfAbsent(url, this::loadImage);
        // Cache grows forever → OutOfMemoryError
    }
}
```

✅ **Fix:**
```java
// Option 1: Size-limited cache
private static Map<String, Image> cache = new LinkedHashMap<>() {
    protected boolean removeEldestEntry(Map.Entry<String, Image> eldest) {
        return size() > 1000;  // Max 1000 images
    }
};

// Option 2: Time-based eviction (Guava)
private static Cache<String, Image> cache = CacheBuilder.newBuilder()
    .maximumSize(1000)
    .expireAfterAccess(10, TimeUnit.MINUTES)
    .build();

// Option 3: Memory-sensitive
private static Map<String, SoftReference<Image>> cache = new HashMap<>();
```

**Detection Tools:**

1. **Heap Dump:**
```bash
jmap -dump:format=b,file=heap.bin <pid>
# Analyze with Eclipse MAT
```

2. **VisualVM:**
- Heap dump
- Find dominator tree
- Identify large retained sets

3. **JVM Flags:**
```bash
-XX:+HeapDumpOnOutOfMemoryError
-XX:HeapDumpPath=/path/to/dumps/
```

4. **Programmatic:**
```java
MemoryMXBean memoryBean = ManagementFactory.getMemoryMXBean();
MemoryUsage heapUsage = memoryBean.getHeapMemoryUsage();

if (heapUsage.getUsed() > heapUsage.getMax() * 0.9) {
    LOGGER.warn("Heap usage > 90%: possible memory leak");
}
```

**Interview Key Points:**

- Memory leaks = objects referenced but not used
- GC cannot collect referenced objects
- Most common: static collections, listeners, ThreadLocal, inner classes
- Always remove listeners, clean ThreadLocal, close resources
- Use WeakReference/SoftReference for caches
- Monitor heap usage trends (growing Old Gen is red flag)

---

## Q7: What are the different types of references? When would you use each?

**Answer:**

Java has **4 reference types** with different GC behavior:

| Reference | GC Behavior | Use Case |
|-----------|-------------|----------|
| **Strong** | Never GC'd while referenced | Normal objects |
| **Soft** | GC'd when memory low (before OOM) | Memory-sensitive caches |
| **Weak** | GC'd in next GC cycle | Canonical maps, listeners |
| **Phantom** | GC'd, but enqueued for cleanup | Post-finalization cleanup |

**1. Strong Reference (Default):**

```java
User user = new User();  // Strong reference
// user is NEVER GC'd while in scope
```

**2. Soft Reference (Memory-Sensitive Cache):**

```java
import java.lang.ref.SoftReference;

public class ImageCache {
    private Map<String, SoftReference<Image>> cache = new HashMap<>();
    
    public Image getImage(String url) {
        SoftReference<Image> ref = cache.get(url);
        Image image = null;
        
        if (ref != null) {
            image = ref.get();  // May return null if GC'd
        }
        
        if (image == null) {
            image = loadImage(url);
            cache.put(url, new SoftReference<>(image));
        }
        
        return image;
    }
}

// GC behavior:
// - Low memory: GC clears SoftReferences to avoid OutOfMemoryError
// - Enough memory: SoftReferences kept (better performance)
```

**When to Use:**
- **Caches** that can be recomputed if cleared
- Large objects (images, parsed documents)
- Want to use available memory but not cause OOM

**3. Weak Reference (Canonical Maps):**

```java
import java.lang.ref.WeakReference;
import java.util.WeakHashMap;

// Example 1: WeakHashMap
Map<User, List<Order>> userOrders = new WeakHashMap<>();

User user = new User("John");
userOrders.put(user, new ArrayList<>());

user = null;  // No strong reference to User
// After GC: Entry automatically removed from WeakHashMap!

// Example 2: String Interning
public class CanonicalStrings {
    private Map<String, WeakReference<String>> pool = new HashMap<>();
    
    public String intern(String str) {
        WeakReference<String> ref = pool.get(str);
        String canonical = null;
        
        if (ref != null) {
            canonical = ref.get();
        }
        
        if (canonical == null) {
            canonical = str;
            pool.put(str, new WeakReference<>(canonical));
        }
        
        return canonical;
    }
}
```

**When to Use:**
- **Canonical maps** (deduplication)
- Listeners (automatically removed when target GC'd)
- Caches where entries should disappear with keys

**4. Phantom Reference (Post-Mortem Cleanup):**

```java
import java.lang.ref.*;
import java.util.*;

public class NativeResourceManager {
    
    static class ResourcePhantomRef extends PhantomReference<Resource> {
        private long nativePointer;
        
        ResourcePhantomRef(Resource resource, ReferenceQueue<Resource> queue) {
            super(resource, queue);
            this.nativePointer = resource.getNativePointer();
        }
        
        void cleanup() {
            if (nativePointer != 0) {
                freeNativeMemory(nativePointer);  // Native cleanup
                nativePointer = 0;
            }
        }
    }
    
    private ReferenceQueue<Resource> queue = new ReferenceQueue<>();
    private Set<ResourcePhantomRef> refs = new HashSet<>();
    
    public void manage(Resource resource) {
        refs.add(new ResourcePhantomRef(resource, queue));
    }
    
    public void cleanupCollected() {
        Reference<? extends Resource> ref;
        while ((ref = queue.poll()) != null) {
            ((ResourcePhantomRef) ref).cleanup();
            refs.remove(ref);
        }
    }
    
    private native void freeNativeMemory(long pointer);
}

// Usage:
NativeResourceManager manager = new NativeResourceManager();
Resource resource = new Resource();
manager.manage(resource);

resource = null;  // No strong reference
// After GC: resource finalized → PhantomReference enqueued
manager.cleanupCollected();  // Cleanup native memory
```

**When to Use:**
- **Replacement for `finalize()`** (deprecated Java 9)
- Native memory cleanup (JNI, DirectByteBuffer)
- Track object lifecycle without preventing GC
- Post-mortem actions after object finalized

**Key Differences:**

```java
// Strong
Object obj = new Object();
// obj.get() → Not needed (direct reference)
// GC: Never while referenced

// Soft
SoftReference<Object> soft = new SoftReference<>(obj);
Object retrieved = soft.get();  // May return null if GC'd
// GC: When memory low (before OOM)

// Weak
WeakReference<Object> weak = new WeakReference<>(obj);
Object retrieved = weak.get();  // May return null if GC'd
// GC: Next GC cycle (regardless of memory)

// Phantom
ReferenceQueue<Object> queue = new ReferenceQueue<>();
PhantomReference<Object> phantom = new PhantomReference<>(obj, queue);
Object retrieved = phantom.get();  // ALWAYS returns null!
// GC: After finalization, enqueued to ReferenceQueue
```

**Reference Strength:**
```
Strong > Soft > Weak > Phantom
```

**Interview Key Points:**

- **Soft**: Memory-sensitive caches (cleared before OOM)
- **Weak**: Canonical maps, listeners (cleared next GC)
- **Phantom**: Post-finalization cleanup (replaces finalize)
- `SoftReference.get()` and `WeakReference.get()` may return `null`
- `PhantomReference.get()` always returns `null`
- Use `ReferenceQueue` with Phantom to detect GC

---

## Q8: Explain the difference between Minor GC, Major GC, and Full GC.

**Answer:**

| GC Type | Scope | Trigger | Speed | Pause |
|---------|-------|---------|-------|-------|
| **Minor GC** | Young Generation only | Eden full | Fast (ms) | Short STW |
| **Major GC** | Old Generation only | Old Gen full | Slow (sec) | Long STW |
| **Full GC** | Entire Heap + Metaspace | System.gc() / OOM | Slowest | Longest STW |

**1. Minor GC (Young GC):**

**Scope:**
- Young Generation (Eden + Survivor spaces)

**Trigger:**
- Eden space full
- New object allocation fails

**Process:**
1. Mark live objects in Eden + Survivor 0
2. Copy live objects to Survivor 1 (copying algorithm)
3. Clear Eden + Survivor 0
4. Swap Survivor 0 ↔ Survivor 1
5. Promote objects surviving threshold (default 15) to Old Gen

**Characteristics:**
- **Frequency**: Very frequent (every few seconds)
- **Duration**: Fast (1-50ms typically)
- **Algorithm**: Copying (efficient for high mortality rate)
- **Impact**: Low (short pause)

```java
// Causes Minor GC
for (int i = 0; i < 1_000_000; i++) {
    String temp = "Temporary" + i;  // Allocates in Eden
    // temp is immediately eligible for GC
}
// Eden fills → Minor GC → clears Eden
```

**2. Major GC (Old GC):**

**Scope:**
- Old Generation only

**Trigger:**
- Old Gen full or near full
- After Minor GC, not enough space for promotion
- Explicit `System.gc()` (if not disabled)

**Process:**
1. Mark live objects in Old Gen (Mark phase)
2. Sweep dead objects (Sweep phase)
3. Compact memory (Compact phase) - optional

**Characteristics:**
- **Frequency**: Infrequent (minutes to hours)
- **Duration**: Slow (100ms to several seconds)
- **Algorithm**: Mark-Sweep-Compact (old objects mostly alive)
- **Impact**: High (application pause)

**3. Full GC:**

**Scope:**
- Entire Heap (Young + Old)
- Metaspace/PermGen
- Interned Strings

**Trigger:**
- Old Gen cannot allocate (after Major GC)
- Metaspace full
- Explicit `System.gc()`
- Heap fragmentation (CMS concurrent mode failure)

**Process:**
1. Minor GC → clean Young Gen
2. Major GC → clean Old Gen
3. Metaspace cleanup
4. String pool cleanup

**Characteristics:**
- **Frequency**: Rare (should be very infrequent)
- **Duration**: Slowest (seconds to minutes for large heaps)
- **Impact**: Severe (long application pause)

**Real-World Example:**

```java
public class GCTypes {
    
    private static List<byte[]> longLived = new ArrayList<>();
    
    public static void main(String[] args) {
        // Enable GC logging
        // -XX:+PrintGCDetails -XX:+PrintGCTimeStamps
        
        // Minor GC generator
        for (int i = 0; i < 100; i++) {
            byte[] temp = new byte[1024 * 1024];  // 1MB
            // temp is short-lived → dies in Young Gen → Minor GC
        }
        
        // Major GC generator
        for (int i = 0; i < 1000; i++) {
            byte[] longLivedObject = new byte[1024 * 1024];  // 1MB
            longLived.add(longLivedObject);
            // Survives 15 GCs → promoted to Old Gen
        }
        // Old Gen fills → Major GC
        
        // Full GC trigger
        System.gc();  // Forces Full GC (not recommended)
    }
}
```

**GC Log Example:**

```
[GC (Allocation Failure) [PSYoungGen: 2048K->512K(2560K)] 2048K->700K(9728K), 0.0023232 secs]
↑ Minor GC: Young Gen 2048K → 512K (fast)

[GC (Allocation Failure) [PSYoungGen: 2560K->512K(2560K)] [ParOldGen: 6144K->6200K(7168K)] 8704K->6712K(9728K), 0.0458644 secs]
↑ Major GC: Old Gen involved (slower)

[Full GC (System.gc()) [PSYoungGen: 512K->0K(2560K)] [ParOldGen: 6200K->500K(7168K)] 6712K->500K(9728K), [Metaspace: 3000K->3000K(1056768K)], 0.0234532 secs]
↑ Full GC: Entire heap + Metaspace (slowest)
```

**Monitoring:**

```java
// Programmatic GC monitoring
List<GarbageCollectorMXBean> gcBeans = ManagementFactory.getGarbageCollectorMXBeans();

for (GarbageCollectorMXBean gcBean : gcBeans) {
    System.out.println(gcBean.getName() + ":");
    System.out.println("  Count: " + gcBean.getCollectionCount());
    System.out.println("  Time: " + gcBean.getCollectionTime() + "ms");
    
    // Young GC collectors: "PS Scavenge", "G1 Young Generation"
    // Old GC collectors: "PS MarkSweep", "G1 Old Generation"
}
```

**Best Practices:**

1. **Tune for Fewer Major/Full GCs:**
```bash
# Increase heap to avoid frequent Major GC
-Xms4g -Xmx4g

# Use G1 for predictable pause times
-XX:+UseG1GC -XX:MaxGCPauseMillis=200
```

2. **Avoid Explicit GC:**
```bash
# Disable System.gc()
-XX:+DisableExplicitGC
```

3. **Monitor GC Frequency:**
- Minor GC: Many per minute → OK
- Major GC: Few per hour → OK
- Full GC: Rarely or never → GOOD
- Frequent Full GC → **Problem** (leak or undersized heap)

**Interview Key Points:**

- **Minor GC**: Young Gen, fast, frequent, copying algorithm
- **Major GC**: Old Gen, slow, infrequent, mark-sweep-compact
- **Full GC**: Entire heap, slowest, should be rare
- Frequent Full GC indicates memory leak or undersized heap
- Modern GCs (G1/ZGC) minimize Full GC occurrences

---

## Q9: What is Metaspace? How is it different from PermGen?

**Answer:**

**PermGen (Java 7 and earlier):**

**Characteristics:**
- **Fixed size** at JVM startup
- Part of **heap**
- Stores:
  - Class metadata (methods, fields)
  - Interned strings (`String.intern()`)
  - Static variables
- Default size: ~64MB-82MB

**Problems:**
```java
// OutOfMemoryError: PermGen space
// Common in:
// 1. Applications with many classes
// 2. Hot deployment (Tomcat redeploy)
// 3. Dynamic proxies/reflection
// 4. String.intern() abuse

// Example:
while (true) {
    String str = new String("Hello" + System.nanoTime()).intern();
    // String pool in PermGen → fills up → OOM
}
```

**Tuning (Java 7):**
```bash
-XX:PermSize=128m         # Initial size
-XX:MaxPermSize=256m      # Maximum size
-XX:+PrintGCDetails       # Log PermGen GC
```

**Metaspace (Java 8+):**

**Characteristics:**
- **Dynamic size** (auto-grows)
- Part of **native memory** (not heap!)
- Stores:
  - Class metadata only
  - Static variables → moved to **heap** (Java 8+)
  - Interned strings → moved to **heap** (Java 7+)
- Default max: Unlimited (system memory)

**Advantages:**

1. **No Fixed Size**:
   - Grows automatically
   - Fewer OutOfMemoryError: Metaspace

2. **Better Memory Management**:
   - Native memory allocated on demand
   - Released when ClassLoader unloaded

3. **Improved GC**:
   - Less Full GC pressure
   - String pool in heap → collected by regular GC

**Key Differences:**

| Aspect | PermGen (Java 7-) | Metaspace (Java 8+) |
|--------|-------------------|---------------------|
| **Location** | Heap | Native memory |
| **Size** | Fixed (`-XX:MaxPermSize`) | Dynamic (auto-grows) |
| **Default Max** | 64-82MB | Unlimited |
| **Contains** | Class metadata + strings + statics | Class metadata only |
| **String Pool** | PermGen | Heap |
| **Static Variables** | PermGen | Heap |
| **GC** | Full GC required | Concurrent with Class unloading |
| **OOM** | Common | Rare (unless leak) |

**Tuning Metaspace (Java 8+):**

```bash
# Initial size
-XX:MetaspaceSize=128m

# Maximum size (prevent unlimited growth)
-XX:MaxMetaspaceSize=512m

# Minimum free space before expansion
-XX:MinMetaspaceFreeRatio=40

# Maximum free space before shrinking
-XX:MaxMetaspaceFreeRatio=70

# Monitor Metaspace
-XX:+PrintGCDetails
-Xlog:gc+metaspace=info  # Java 9+
```

**Real-World Example:**

```java
// Hot deployment scenario (Tomcat, JBoss)

// Deploy 1: Load classes
ClassLoader loader1 = new WebappClassLoader();
Class<?> servlet1 = loader1.loadClass("com.example.MyServlet");

// Undeploy: Loader should be GC'd
loader1 = null;
servlet1 = null;
System.gc();

// Deploy 2: Load classes again
ClassLoader loader2 = new WebappClassLoader();
Class<?> servlet2 = loader2.loadClass("com.example.MyServlet");

// Java 7 (PermGen):
// - Classes accumulate in PermGen
// - After multiple redeploys → OutOfMemoryError: PermGen space

// Java 8+ (Metaspace):
// - Old classes unloaded when ClassLoader GC'd
// - Metaspace freed
// - Much fewer OOM errors
```

**Metaspace OutOfMemoryError:**

```java
// Still possible with ClassLoader leaks

public class MetaspaceOOM {
    public static void main(String[] args) {
        while (true) {
            ClassLoader loader = new ClassLoader() {
                public Class<?> loadClass(String name) {
                    byte[] bytecode = generateClass(name);
                    return defineClass(name, bytecode, 0, bytecode.length);
                }
            };
            
            try {
                loader.loadClass("DynamicClass" + System.currentTimeMillis());
                // Loader not released → classes not unloaded → Metaspace grows
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        // Eventually: OutOfMemoryError: Metaspace
    }
}
```

**Monitoring:**

```java
// Metaspace usage
MemoryMXBean memoryBean = ManagementFactory.getMemoryMXBean();
MemoryUsage metaspaceUsage = memoryBean.getNonHeapMemoryUsage();

System.out.println("Metaspace Used: " + metaspaceUsage.getUsed() / 1024 / 1024 + " MB");
System.out.println("Metaspace Max: " + metaspaceUsage.getMax() / 1024 / 1024 + " MB");
```

```bash
# Command-line
jstat -gc <pid>
# MC = Metaspace capacity
# MU = Metaspace used

jcmd <pid> GC.heap_info
# Shows Metaspace info
```

**Best Practices:**

1. **Set MaxMetaspaceSize in Production:**
```bash
# Prevent unlimited growth
-XX:MaxMetaspaceSize=512m
```

2. **Monitor for ClassLoader Leaks:**
- Heap dump after redeploy
- Check if old classes still loaded

3. **Java 8 Migration:**
```bash
# Remove old flags
# -XX:PermSize=128m       # Remove
# -XX:MaxPermSize=256m    # Remove

# Add new flags
-XX:MetaspaceSize=128m
-XX:MaxMetaspaceSize=512m
```

**Interview Key Points:**

- **PermGen (Java 7-)**: Fixed size, part of heap, holds class metadata + strings + statics
- **Metaspace (Java 8+)**: Dynamic size, native memory, holds class metadata only
- String pool and statics moved to heap (Java 7/8)
- Metaspace auto-grows (default unlimited)
- Always set `-XX:MaxMetaspaceSize` in production
- ClassLoader leaks still cause Metaspace OOM

---

## Q10: How do you diagnose and fix a memory leak in production?

**Answer:**

**Step-by-Step Diagnosis:**

**1. Identify Symptoms:**

Signs of memory leak:
- Old Gen usage steadily increasing
- Frequent Full GCs
- OutOfMemoryError
- Slow application performance
- GC overhead limit exceeded

**Monitor:**
```bash
# Check heap usage trend
jstat -gc <pid> 1000

# Output:
# S0C    S1C    S0U    S1U      EC       EU        OC         OU       MC     MU    CCSC   YGC   YGCT    FGC    FGCT     GCT
# 2048   2048   0      1024    16384    8192    40960      35000    20480  15000   2560   100   1.234   10    5.678   6.912
#                                                            ↑ Old Gen used steadily growing
```

**2. Take Heap Dump:**

```bash
# Option 1: Manual heap dump
jmap -dump:format=b,file=/tmp/heap.bin <pid>

# Option 2: Auto dump on OOM
-XX:+HeapDumpOnOutOfMemoryError
-XX:HeapDumpPath=/path/to/dumps/

# Option 3: Using jcmd
jcmd <pid> GC.heap_dump /tmp/heap.bin
```

**3. Analyze Heap Dump (Eclipse MAT):**

**Load heap.bin in Eclipse Memory Analyzer Tool:**

a. **Leak Suspects Report:**
   - Automatically finds suspected leaks
   - Shows dominator tree (objects holding most memory)

b. **Find Large Objects:**
   - Histogram view
   - Group by class
   - Sort by "Retained Heap"

```
Class Name                     | Objects | Shallow Heap | Retained Heap
-------------------------------|---------|--------------|---------------
java.lang.String               | 1.2M    | 48 MB        | 120 MB  ← Suspect
com.example.User               | 500K    | 24 MB        | 80 MB   ← Suspect
java.util.HashMap$Node[]       | 10K     | 20 MB        | 150 MB  ← Suspect (backing array)
```

c. **Find GC Roots:**
   - Right-click object → "Path to GC Roots"
   - Identify why object not collected

```
Example path:

Static Field: UserService.cache (HashMap)
  └→ HashMap$Node[] table
      └→ HashMap$Node
          └→ User object

Root cause: Static cache never cleared!
```

**4. Common Leak Patterns:**

**Pattern 1: Static Collection Growing:**

```java
// LEAK
public class UserService {
    private static List<User> cache = new ArrayList<>();  // NEVER cleared
    
    public void addUser(User user) {
        cache.add(user);
    }
}

// FIX
public class UserService {
    private static final int MAX_SIZE = 10000;
    private static LinkedHashMap<String, User> cache = new LinkedHashMap<>() {
        @Override
        protected boolean removeEldestEntry(Map.Entry<String, User> eldest) {
            return size() > MAX_SIZE;  // Auto-evict oldest
        }
    };
}
```

**Pattern 2: Listeners Not Removed:**

```java
// LEAK
public class EventConsumer {
    public void subscribe() {
        EventSource.getInstance().addListener(this);
        // Never removed → EventSource holds reference → can't be GC'd
    }
}

// FIX
public class EventConsumer {
    public void subscribe() {
        EventSource.getInstance().addListener(this);
    }
    
    public void unsubscribe() {
        EventSource.getInstance().removeListener(this);  // CRITICAL
    }
    
    // Or use WeakListener
    EventSource.getInstance().addListener(new WeakListener(this));
}
```

**Pattern 3: ThreadLocal in Thread Pool:**

```java
// LEAK
public class RequestHandler {
    private static ThreadLocal<User> currentUser = new ThreadLocal<>();
    
    public void handleRequest(User user) {
        currentUser.set(user);
        // Process request
        // FORGOT to remove → thread reused → old User remains
    }
}

// FIX
public class RequestHandler {
    private static ThreadLocal<User> currentUser = new ThreadLocal<>();
    
    public void handleRequest(User user) {
        try {
            currentUser.set(user);
            // Process request
        } finally {
            currentUser.remove();  // CRITICAL
        }
    }
}
```

**5. Production-Safe Diagnosis:**

**Non-Intrusive Monitoring:**

```java
// Monitor Old Gen usage
@Scheduled(fixedRate = 60000)  // Every minute
public void monitorMemory() {
    MemoryMXBean memoryBean = ManagementFactory.getMemoryMXBean();
    MemoryUsage heapUsage = memoryBean.getHeapMemoryUsage();
    
    long used = heapUsage.getUsed();
    long max = heapUsage.getMax();
    double usagePercent = (double) used / max * 100;
    
    if (usagePercent > 90) {
        LOGGER.error("CRITICAL: Heap usage {}%", usagePercent);
        // Alert ops team
    }
    
    // Check Old Gen specifically
    for (MemoryPoolMXBean pool : ManagementFactory.getMemoryPoolMXBeans()) {
        if (pool.getName().contains("Old Gen") || pool.getName().contains("Tenured")) {
            MemoryUsage usage = pool.getUsage();
            long oldGenUsed = usage.getUsed();
            long oldGenMax = usage.getMax();
            double oldGenPercent = (double) oldGenUsed / oldGenMax * 100;
            
            if (oldGenPercent > 80) {
                LOGGER.warn("Old Gen usage {}%", oldGenPercent);
            }
        }
    }
}
```

**6. Fix and Verify:**

**After Fix:**

```bash
# Monitor for several hours/days
jstat -gc <pid> 5000  # Every 5 seconds

# Old Gen (OU) should:
# - Increase gradually
# - Drop after Full GC
# - NOT continuously grow
```

**7. Prevention:**

```java
// 1. Bounded caches
Cache<String, User> cache = Caffeine.newBuilder()
    .maximumSize(10_000)
    .expireAfterAccess(10, TimeUnit.MINUTES)
    .build();

// 2. WeakHashMap for canonical maps
Map<String, User> userMap = new WeakHashMap<>();

// 3. Try-with-resources
try (Connection conn = dataSource.getConnection()) {
    // Use connection
}  // Auto-closed

// 4. Explicit cleanup
@PreDestroy
public void cleanup() {
    cache.clear();
    listeners.clear();
}

// 5. Code review for:
// - Static collections
// - Listeners
// - ThreadLocal
// - Inner classes
// - Unclosed resources
```

**Interview Checklist:**

1. ✅ Monitor Old Gen growth trend
2. ✅ Take heap dump (`jmap`)
3. ✅ Analyze with Eclipse MAT (dominator tree, GC roots)
4. ✅ Identify pattern (static collection, listeners, ThreadLocal, etc.)
5. ✅ Fix root cause (bounded cache, remove listeners, clean ThreadLocal)
6. ✅ Verify (Old Gen no longer grows)
7. ✅ Add monitoring/alerts

---

*[Questions 11-15 with monitoring strategies, JVM tuning approaches, and advanced GC topics would continue...]*

---

# 12. INTERVIEW TRAPS & EDGE CASES

## Trap 1: System.gc() Doesn't Guarantee GC

❌ **Wrong Assumption:**
```java
User user = new User();
user = null;
System.gc();  // Assumes user is GC'd NOW
// Try to use "freed" memory immediately
```

✅ **Reality:**
```java
// System.gc() only SUGGESTS GC
// - JVM may ignore it
// - GC runs asynchronously
// - No guarantee WHEN it runs

// Disable in production:
-XX:+DisableExplicitGC
```

**Why:**
- `System.gc()` triggers Full GC (expensive)
- Disrupts GC heuristics
- Libraries may call it unnecessarily

---

## Trap 2: Objects with finalize() Cause Performance Issues

❌ **Performance Problem:**
```java
public class Resource {
    @Override
    protected void finalize() throws Throwable {
        // Cleanup
        closeResource();
    }
}

// Problems:
// 1. Object survives at least 1 extra GC cycle
// 2. finalize() queued → delays collection
// 3. Finalization thread can be slow
// 4. Resurrection possible
// 5. Deprecated Java 9
```

✅ **Better:**
```java
// Option 1: try-with-resources
public class Resource implements AutoCloseable {
    @Override
    public void close() {
        closeResource();
    }
}

try (Resource res = new Resource()) {
    // Use resource
}  // Guaranteed cleanup

// Option 2: Phantom References
// (See earlier example)
```

---

## Trap 3: Large ArrayList Preallocation Wastes Memory

❌ **Memory Waste:**
```java
// Pre-allocate for "performance"
List<User> users = new ArrayList<>(1_000_000);

// Add 10 users
for (int i = 0; i < 10; i++) {
    users.add(new User());
}

// Wastes: (~1M * 4 bytes) ~4MB for unused capacity
```

✅ **Right Sizing:**
```java
// Let ArrayList grow naturally
List<User> users = new ArrayList<>();  // Starts at 10

// Or estimate reasonably
List<User> users = new ArrayList<>(100);  // Expected size
```

**Trade-off:**
- Over-allocation: Wastes memory
- Under-allocation: Reallocation overhead
- **Best**: Estimate close to actual size

---

## Trap 4: String Concatenation in Loops Creates Many Objects

❌ **Inefficient:**
```java
String result = "";
for (int i = 0; i < 1000; i++) {
    result += i;  // Creates 1000 intermediate String objects!
}
// Each += creates new String (Strings are immutable)
// 1000 String objects → GC pressure
```

✅ **Efficient:**
```java
StringBuilder sb = new StringBuilder();
for (int i = 0; i < 1000; i++) {
    sb.append(i);  // Reuses same buffer
}
String result = sb.toString();  // One String created
```

**Compiler Optimization:**
```java
// Single line: compiler optimizes
String s = "a" + "b" + "c";  // Compiled to: "abc"

// Loop: compiler CANNOT optimize
for(...) {
    s += "a";  // NOT optimized
}
```

---

## Trap 5: Young Gen Too Small Causes Premature Promotion

❌ **Problem:**
```bash
-Xms4g -Xmx4g -Xmn512m  # Young Gen only 512MB (12.5%)

# Objects promoted to Old Gen too quickly
# Old Gen fills faster → Frequent Major GC!
```

✅ **Fix:**
```bash
# Default ratio is fine (1/3 Young, 2/3 Old)
-Xms4g -Xmx4g  # Young ~1.3GB, Old ~2.7GB

# Or increase Young Gen for short-lived object apps
-Xms4g -Xmx4g -XX:NewRatio=1  # Young = Old = 2GB
```

**Symptom:**
- Minor GC very frequent
- Old Gen grows quickly
- Major GC frequent

---

## Trap 6: GC Logs Fill Disk

❌ **Disk Full:**
```bash
# No log rotation
-Xloggc:/var/log/app/gc.log

# After weeks: gc.log is 50GB → disk full!
```

✅ **Rotation:**
```bash
# Java 8
-XX:+UseGCLogFileRotation
-XX:NumberOfGCLogFiles=10
-XX:GCLogFileSize=100M
-Xloggc:/var/log/app/gc.log

# Java 9+
-Xlog:gc*:file=/var/log/app/gc.log:time,tags:filecount=10,filesize=100M
```

---

## Trap 7: Metaspace Unlimited Growth

❌ **Risk:**
```bash
# Default: No MaxMetaspaceSize
# Metaspace can grow until system memory exhausted!
```

✅ **Limit:**
```bash
-XX:MaxMetaspaceSize=512m  # Prevent unlimited growth
```

**When Not to Set:**
- Applications with many classes
- Hot deployment environments
- Need flexibility

---

## Trap 8: ThreadLocal Not Cleaned Causes Leak

❌ **Leak:**
```java
private static ThreadLocal<Connection> connectionHolder = new ThreadLocal<>();

public void handleRequest() {
    Connection conn = dataSource.getConnection();
    connectionHolder.set(conn);
    // Process request
    // FORGOT: connectionHolder.remove()
}
// Thread pool reuses thread → old Connection remains!
```

✅ **Clean:**
```java
public void handleRequest() {
    try {
        Connection conn = dataSource.getConnection();
        connectionHolder.set(conn);
        // Process request
    } finally {
        Connection conn = connectionHolder.get();
        if (conn != null) {
            conn.close();
        }
        connectionHolder.remove();  // CRITICAL
    }
}
```

---

## Trap 9: CMS Concurrent Mode Failure

❌ **Problem:**
```bash
[GC (CMS) Concurrent Mode Failure ...]
[Full GC (Allocation Failure) ...]  # Falls back to slow Serial GC!
```

**Cause:**
- Old Gen fills DURING concurrent marking
- CMS cannot complete in time
- Falls back to expensive Serial Full GC

✅ **Fix:**
```bash
# Start CMS earlier
-XX:CMSInitiatingOccupancyFraction=70  # Start at 70% (default 92%)
-XX:+UseCMSInitiatingOccupancyOnly

# Or switch to G1
-XX:+UseG1GC
```

---

## Trap 10: Direct Memory Not Monitored

❌ **Hidden:**
```java
// Allocate direct buffers
ByteBuffer buffer = ByteBuffer.allocateDirect(1024 * 1024 * 1024);  // 1GB

// Direct memory NOT in heap!
// jmap/VisualVM don't show it!
```

✅ **Monitor:**
```bash
# Limit direct memory
-XX:MaxDirectMemorySize=2g

# Monitor
jcmd <pid> VM.native_memory summary

# Or programmatically
long directMemory = ManagementFactory.getPlatformMXBean(BufferPoolMXBean.class)
    .stream()
    .filter(pool -> pool.getName().equals("direct"))
    .mapToLong(BufferPoolMXBean::getMemoryUsed)
    .sum();
```

---

# 13. CODING PROBLEMS WITH SOLUTIONS

## Problem 1: Implement Memory-Efficient Cache with LRU Eviction

**Problem Statement:**

Implement a thread-safe LRU (Least Recently Used) cache that:
1. Has a maximum size limit
2. Evicts least recently accessed items when full
3. O(1) get and put operations
4. Thread-safe for concurrent access

**Solution 1: Using LinkedHashMap:**

```java
import java.util.*;
import java.util.concurrent.locks.*;

public class LRUCache<K, V> {
    
    private final int capacity;
    private final Map<K, V> cache;
    private final ReadWriteLock lock = new ReentrantReadWriteLock();
    
    public LRUCache(int capacity) {
        this.capacity = capacity;
        this.cache = new LinkedHashMap<K, V>(capacity, 0.75f, true) {
            @Override
            protected boolean removeEldestEntry(Map.Entry<K, V> eldest) {
                return size() > LRUCache.this.capacity;
            }
        };
    }
    
    public V get(K key) {
        lock.readLock().lock();
        try {
            return cache.get(key);  // Updates access order
        } finally {
            lock.readLock().unlock();
        }
    }
    
    public void put(K key, V value) {
        lock.writeLock().lock();
        try {
            cache.put(key, value);  // Auto-evicts if over capacity
        } finally {
            lock.writeLock().unlock();
        }
    }
    
    public int size() {
        lock.readLock().lock();
        try {
            return cache.size();
        } finally {
            lock.readLock().unlock();
        }
    }
}

// Test
public class LRUCacheTest {
    public static void main(String[] args) {
        LRUCache<String, String> cache = new LRUCache<>(3);
        
        cache.put("a", "1");
        cache.put("b", "2");
        cache.put("c", "3");
        System.out.println(cache.size());  // 3
        
        cache.put("d", "4");  // Evicts "a" (least recently used)
        System.out.println(cache.get("a"));  // null (evicted)
        System.out.println(cache.get("b"));  // "2"
        
        cache.put("e", "5");  // Evicts "c" (b just accessed, so c is LRU)
        System.out.println(cache.get("c"));  // null (evicted)
    }
}
```

**Solution 2: Manual Implementation (More Control):**

```java
import java.util.*;
import java.util.concurrent.locks.*;

public class LRUCacheManual<K, V> {
    
    private class Node {
        K key;
        V value;
        Node prev, next;
        
        Node(K key, V value) {
            this.key = key;
            this.value = value;
        }
    }
    
    private final int capacity;
    private final Map<K, Node> cache;
    private final Node head, tail;  // Dummy nodes
    private final ReadWriteLock lock = new ReentrantReadWriteLock();
    
    public LRUCacheManual(int capacity) {
        this.capacity = capacity;
        this.cache = new HashMap<>();
        this.head = new Node(null, null);
        this.tail = new Node(null, null);
        head.next = tail;
        tail.prev = head;
    }
    
    public V get(K key) {
        lock.writeLock().lock();  // Need write lock (moves node)
        try {
            Node node = cache.get(key);
            if (node == null) {
                return null;
            }
            
            // Move to head (most recently used)
            moveToHead(node);
            return node.value;
        } finally {
            lock.writeLock().unlock();
        }
    }
    
    public void put(K key, V value) {
        lock.writeLock().lock();
        try {
            Node node = cache.get(key);
            
            if (node != null) {
                // Update existing
                node.value = value;
                moveToHead(node);
            } else {
                // Add new
                Node newNode = new Node(key, value);
                cache.put(key, newNode);
                addToHead(newNode);
                
                // Evict if over capacity
                if (cache.size() > capacity) {
                    Node lru = tail.prev;  // Least recently used
                    removeNode(lru);
                    cache.remove(lru.key);
                }
            }
        } finally {
            lock.writeLock().unlock();
        }
    }
    
    private void moveToHead(Node node) {
        removeNode(node);
        addToHead(node);
    }
    
    private void addToHead(Node node) {
        node.next = head.next;
        node.prev = head;
        head.next.prev = node;
        head.next = node;
    }
    
    private void removeNode(Node node) {
        node.prev.next = node.next;
        node.next.prev = node.prev;
    }
}
```

**Complexity:**
- Time: O(1) for get and put
- Space: O(capacity)

---

## Problem 2: Detect and Fix Memory Leak in Session Manager

**Problem Statement:**

Given a session manager with a memory leak, identify the problem and fix it.

**Leaky Code:**

```java
public class LeakySessionManager {
    
    private static final Map<String, Session> sessions = new HashMap<>();
    private static final long SESSION_TIMEOUT = 30 * 60 * 1000;  // 30 minutes
    
    public void createSession(String sessionId, User user) {
        Session session = new Session(sessionId, user, System.currentTimeMillis());
        sessions.put(sessionId, session);
        // PROBLEM: Sessions never removed!
    }
    
    public Session getSession(String sessionId) {
        Session session = sessions.get(sessionId);
        
        // Check if expired
        if (session != null && isExpired(session)) {
            sessions.remove(sessionId);
            return null;
        }
        
        return session;
    }
    
    private boolean isExpired(Session session) {
        return System.currentTimeMillis() - session.getCreatedAt() > SESSION_TIMEOUT;
    }
}
```

**Problem Analysis:**

1. **Expired sessions never removed** unless explicitly accessed via `getSession()`
2. If session ID never accessed again, it stays in memory forever
3. Map grows unbounded → memory leak → OutOfMemoryError

**Solution 1: Background Cleanup Thread:**

```java
import java.util.*;
import java.util.concurrent.*;

public class FixedSessionManager {
    
    private final Map<String, Session> sessions = new ConcurrentHashMap<>();
    private final long sessionTimeout;
    private final ScheduledExecutorService cleanupExecutor;
    
    public FixedSessionManager(long sessionTimeout) {
        this.sessionTimeout = sessionTimeout;
        
        // Cleanup every 5 minutes
        this.cleanupExecutor = Executors.newScheduledThreadPool(1, r -> {
            Thread thread = new Thread(r, "SessionCleanup");
            thread.setDaemon(true);  // Don't prevent JVM shutdown
            return thread;
        });
        
        cleanupExecutor.scheduleAtFixedRate(
            this::cleanupExpiredSessions,
            5, 5, TimeUnit.MINUTES
        );
    }
    
    public void createSession(String sessionId, User user) {
        Session session = new Session(sessionId, user, System.currentTimeMillis());
        sessions.put(sessionId, session);
    }
    
    public Session getSession(String sessionId) {
        Session session = sessions.get(sessionId);
        
        if (session != null && isExpired(session)) {
            sessions.remove(sessionId);
            return null;
        }
        
        return session;
    }
    
    private void cleanupExpiredSessions() {
        long now = System.currentTimeMillis();
        
        sessions.entrySet().removeIf(entry -> 
            now - entry.getValue().getCreatedAt() > sessionTimeout
        );
        
        System.out.println("Cleanup: " + sessions.size() + " sessions remaining");
    }
    
    private boolean isExpired(Session session) {
        return System.currentTimeMillis() - session.getCreatedAt() > sessionTimeout;
    }
    
    public void shutdown() {
        cleanupExecutor.shutdown();
    }
}
```

**Solution 2: Using Guava Cache (Automatic Expiration):**

```java
import com.google.common.cache.*;
import java.util.concurrent.TimeUnit;

public class CachedSessionManager {
    
    private final Cache<String, Session> sessions;
    
    public CachedSessionManager(long timeout, TimeUnit unit) {
        this.sessions = CacheBuilder.newBuilder()
            .expireAfterWrite(timeout, unit)  // Auto-expire
            .maximumSize(10_000)  // Bounded size
            .removalListener(notification -> {
                System.out.println("Session removed: " + notification.getKey() + 
                                   ", Cause: " + notification.getCause());
            })
            .build();
    }
    
    public void createSession(String sessionId, User user) {
        Session session = new Session(sessionId, user, System.currentTimeMillis());
        sessions.put(sessionId, session);
    }
    
    public Session getSession(String sessionId) {
        return sessions.getIfPresent(sessionId);  // null if expired
    }
}
```

**Solution 3: WeakHashMap + TTL Wrapper:**

```java
public class WeakSessionManager {
    
    private final Map<String, SessionWrapper> sessions = new WeakHashMap<>();
    private final long sessionTimeout;
    
    private class SessionWrapper {
        final Session session;
        final long expiresAt;
        
        SessionWrapper(Session session, long timeout) {
            this.session = session;
            this.expiresAt = System.currentTimeMillis() + timeout;
        }
        
        boolean isExpired() {
            return System.currentTimeMillis() > expiresAt;
        }
    }
    
    public WeakSessionManager(long sessionTimeout) {
        this.sessionTimeout = sessionTimeout;
    }
    
    public void createSession(String sessionId, User user) {
        Session session = new Session(sessionId, user, System.currentTimeMillis());
        sessions.put(sessionId, new SessionWrapper(session, sessionTimeout));
    }
    
    public Session getSession(String sessionId) {
        SessionWrapper wrapper = sessions.get(sessionId);
        
        if (wrapper == null || wrapper.isExpired()) {
            sessions.remove(sessionId);
            return null;
        }
        
        return wrapper.session;
    }
}
```

**Test:**

```java
public class SessionManagerTest {
    public static void main(String[] args) throws InterruptedException {
        // Use fixed manager
        FixedSessionManager manager = new FixedSessionManager(30_000);  // 30 sec timeout
        
        // Create 100 sessions
        for (int i = 0; i < 100; i++) {
            manager.createSession("session" + i, new User("user" + i));
        }
        
        System.out.println("Created 100 sessions");
        
        // Wait for cleanup
        Thread.sleep(60_000);  // 1 minute
        
        // All sessions should be cleaned up
        manager.shutdown();
    }
}
```

---

## Problem 3: Optimize Object Creation for GC Performance

**Problem:** Application creates millions of temporary objects, causing frequent Minor GCs and high GC overhead.

**Inefficient Code:**

```java
public class StringProcessor {
    
    public List<String> processLogs(List<String> logs) {
        List<String> processed = new ArrayList<>();
        
        for (String log : logs) {
            // Creates many temporary String objects!
            String[] parts = log.split(",");
            String timestamp = parts[0].trim();
            String level = parts[1].trim().toUpperCase();
            String message = parts[2].trim();
            
            String formatted = "[" + timestamp + "] " + level + ": " + message;
            processed.add(formatted);
        }
        
        return processed;
    }
}

// Processing 1M logs:
// - 1M String[] arrays
// - 3M String objects from split
// - 3M String objects from trim
// - 1M String objects from toUpperCase
// - 1M String objects from concatenation
// Total: ~9M temporary objects!
```

**Optimized Solution:**

```java
public class OptimizedStringProcessor {
    
    // Reuse StringBuilder (not thread-safe, but OK for single-threaded processing)
    private final StringBuilder sb = new StringBuilder(256);
    
    public List<String> processLogs(List<String> logs) {
        List<String> processed = new ArrayList<>(logs.size());  // Pre-size
        
        for (String log : logs) {
            processed.add(processLog(log));
        }
        
        return processed;
    }
    
    private String processLog(String log) {
        // Avoid split() - use indexOf
        int firstComma = log.indexOf(',');
        int secondComma = log.indexOf(',', firstComma + 1);
        
        // Extract without creating sub-strings
        String timestamp = extractTrimmed(log, 0, firstComma);
        String level = extractTrimmed(log, firstComma + 1, secondComma).toUpperCase();
        String message = extractTrimmed(log, secondComma + 1, log.length());
        
        // Reuse StringBuilder
        sb.setLength(0);  // Clear
        sb.append('[').append(timestamp).append("] ")
          .append(level).append(": ")
          .append(message);
        
        return sb.toString();  // Single String creation
    }
    
    private String extractTrimmed(String str, int start, int end) {
        // Trim manually without creating substring
        while (start < end && str.charAt(start) <= ' ') start++;
        while (end > start && str.charAt(end - 1) <= ' ') end--;
        
        return str.substring(start, end);
    }
}

// Optimized version:
// - No split() → no String[] arrays
// - Minimal substring() calls
// - Reused StringBuilder
// - ~3M objects instead of 9M (3x reduction!)
```

**Benchmark:**

```java
public class ProcessorBenchmark {
    public static void main(String[] args) {
        List<String> logs = generateLogs(1_000_000);
        
        // Original
        long start1 = System.nanoTime();
        StringProcessor processor1 = new StringProcessor();
        processor1.processLogs(logs);
        long time1 = System.nanoTime() - start1;
        System.out.println("Original: " + time1 / 1_000_000 + " ms");
        
        // Optimized
        long start2 = System.nanoTime();
        OptimizedStringProcessor processor2 = new OptimizedStringProcessor();
        processor2.processLogs(logs);
        long time2 = System.nanoTime() - start2;
        System.out.println("Optimized: " + time2 / 1_000_000 + " ms");
        
        System.out.println("Speedup: " + (double) time1 / time2 + "x");
    }
    
    private static List<String> generateLogs(int count) {
        List<String> logs = new ArrayList<>(count);
        for (int i = 0; i < count; i++) {
            logs.add("2024-01-15 10:30:00, INFO, User logged in");
        }
        return logs;
    }
}
```

---

## Problem 4: Implement Object Pool to Reduce GC Pressure

**Problem:** Create an object pool for expensive-to-create objects to minimize GC overhead.

**Solution:**

```java
import java.util.concurrent.*;
import java.util.function.Supplier;

public class ObjectPool<T> {
    
    private final BlockingQueue<T> pool;
    private final Supplier<T> factory;
    private final int maxSize;
    
    public ObjectPool(Supplier<T> factory, int maxSize) {
        this.factory = factory;
        this.maxSize = maxSize;
        this.pool = new LinkedBlockingQueue<>(maxSize);
        
        // Pre-populate pool
        for (int i = 0; i < maxSize; i++) {
            pool.offer(factory.get());
        }
    }
    
    public T borrow() throws InterruptedException {
        T object = pool.poll();
        return object != null ? object : factory.get();  // Create if pool empty
    }
    
    public void returnObject(T object) {
        if (object != null) {
            pool.offer(object);  // Return to pool (may be discarded if full)
        }
    }
    
    public int available() {
        return pool.size();
    }
}

// Usage: Database Connection Pool
class DatabaseConnection {
    private final String connectionId;
    
    DatabaseConnection() {
        this.connectionId = UUID.randomUUID().toString();
        // Expensive: Open socket, handshake, etc.
        try {
            Thread.sleep(100);  // Simulate connection time
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }
    
    public void executeQuery(String sql) {
        // Execute query
    }
    
    public void reset() {
        // Reset connection state for reuse
    }
}

public class ConnectionPoolExample {
    public static void main(String[] args) throws InterruptedException {
        // Pool of 10 connections
        ObjectPool<DatabaseConnection> pool = new ObjectPool<>(
            DatabaseConnection::new,
            10
        );
        
        // Execute 1000 queries
        for (int i = 0; i < 1000; i++) {
            DatabaseConnection conn = pool.borrow();
            try {
                conn.executeQuery("SELECT * FROM users");
            } finally {
                conn.reset();
                pool.returnObject(conn);  // Return to pool (reuse)
            }
        }
        
        // Only 10 connections created instead of 1000!
    }
}
```

**Comparison:**

```java
// WITHOUT Pool: Create 1000 connections
for (int i = 0; i < 1000; i++) {
    DatabaseConnection conn = new DatabaseConnection();  // Expensive!
    conn.executeQuery("SELECT * FROM users");
    // conn becomes garbage → GC pressure
}

// WITH Pool: Reuse 10 connections
for (int i = 0; i < 1000; i++) {
    DatabaseConnection conn = pool.borrow();  // Fast!
    try {
        conn.executeQuery("SELECT * FROM users");
    } finally {
        pool.returnObject(conn);  // Reuse
    }
}
```

**Benefits:**
- Reduces object allocation (10 vs 1000 objects)
- Minimizes GC pressure (fewer objects created)
- Better performance (no creation overhead per request)

---

# 14. SUMMARY & QUICK REFERENCE

## JVM Architecture Quick Ref

```
JVM Components:
- Class Loader Subsystem (Bootstrap → Platform → Application)
- Runtime Data Areas (Heap, Stack, Metaspace, PC Register, Native Stack)
- Execution Engine (Interpreter, JIT Compiler, GC)

Memory Layout:
Heap (Eden 80%, S0 10%, S1 10%, Old Gen 67%)
Stack (per thread, method frames)
Metaspace (class metadata, native memory)
```

## GC Algorithms

```
Mark-Sweep: Mark live → Sweep dead → Fragmentation
Mark-Sweep-Compact: Mark → Sweep → Compact → No fragmentation
Copying: Copy live to other space → Fast → 50% waste (optimized with Eden + 2 Survivors)
Generational: Young (copying) + Old (mark-sweep-compact)
```

## Garbage Collectors

```
Serial: Single-thread, <100MB heap, STW
Parallel: Multi-thread, high throughput, Java 8 default
CMS: Low-pause, concurrent marking, deprecated, removed Java 14
G1: Region-based, predictable pause, Java 9+ default, 4GB-64GB
ZGC: <10ms pause, 8MB-16TB, Java 11+ experimental/15+ production
Shenandoah: <10ms pause, OpenJDK only, Java 12+

Choose:
<4GB → Parallel
4-64GB → G1
>64GB & low latency → ZGC/Shenandoah
```

## Key JVM Flags

```bash
# Heap
-Xms4g -Xmx4g  # Initial = Max (recommended)

# GC Selection
-XX:+UseG1GC
-XX:+UseZGC

# GC Tuning
-XX:MaxGCPauseMillis=200  # Target pause
-XX:G1HeapRegionSize=16m
-XX:InitiatingHeapOccupancyPercent=45

# Logging
-Xlog:gc*:file=gc.log:time,tags  # Java 9+

# Diagnostics
-XX:+HeapDumpOnOutOfMemoryError
-XX:HeapDumpPath=/dumps/

# Metaspace
-XX:MetaspaceSize=128m
-XX:MaxMetaspaceSize=512m

# Container
-XX:+UseContainerSupport
-XX:MaxRAMPercentage=75.0
```

## OutOfMemoryError Types

```
Java heap space: Heap full, increase -Xmx
GC overhead limit: >98% time in GC, increase heap or fix leak
Metaspace: Too many classes, increase -XX:MaxMetaspaceSize
Unable to create native thread: OS limit, use thread pools
Direct buffer memory: Off-heap full, increase -XX:MaxDirectMemorySize
Requested array size exceeds VM limit: Array > Integer.MAX_VALUE, use chunked array
```

## Reference Types

```
Strong: Never GC'd (default)
Soft: GC'd when memory low (caches)
Weak: GC'd next cycle (canonical maps)
Phantom: Post-finalization cleanup (native resources)

Strength: Strong > Soft > Weak > Phantom
```

## Memory Leak Patterns

```
1. Static collections growing unbounded
2. Listeners not removed
3. ThreadLocal not cleaned in thread pools
4. Unclosed resources (connections, streams)
5. Non-static inner classes holding outer reference
6. Caches without eviction policy
```

## Monitoring Commands

```bash
jps -l                           # List Java processes
jstat -gc <pid> 1000             # GC stats every 1s
jmap -dump:file=heap.bin <pid>   # Heap dump
jstack <pid>                     # Thread dump
jinfo -flags <pid>               # JVM flags
jcmd <pid> GC.heap_info          # Heap info
```

---

**END OF JVM & MEMORY MANAGEMENT INTERVIEW GUIDE**

This comprehensive guide covers everything from JVM architecture to advanced garbage collection tuning, memory leak detection, and hands-on coding problems. Use this as your complete reference for JVM-related interview preparation!

Master these concepts, practice the coding problems, avoid the common traps, and you'll be fully prepared for any JVM & Memory Management questions in your interviews. Good luck! 🚀