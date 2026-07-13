# JAVA CODING INTERVIEW PROBLEMS

**20 comprehensive coding problems with solutions for 4-5 years experience interviews. Covers arrays, strings, collections, multithreading, design, streams, and real-world scenarios.**

---

# TABLE OF CONTENTS

1. [Arrays & Strings (Problems 1-5)](#1-arrays--strings)
2. [Collections & Data Structures (Problems 6-9)](#2-collections--data-structures)
3. [Multithreading & Concurrency (Problems 10-12)](#3-multithreading--concurrency)
4. [Java 8 Streams & Functional (Problems 13-16)](#4-java-8-streams--functional)
5. [Design & OOP (Problems 17-19)](#5-design--oop)
6. [Real-World Scenarios (Problem 20)](#6-real-world-scenarios)

---

# 1. ARRAYS & STRINGS

## Problem 1: Two Sum

**Difficulty:** Easy  
**Companies:** Amazon, Google, Microsoft

**Problem:**
Given an array of integers and a target sum, return indices of the two numbers that add up to the target.

```java
/**
 * Input: nums = [2, 7, 11, 15], target = 9
 * Output: [0, 1] (because nums[0] + nums[1] = 2 + 7 = 9)
 */
public class TwoSum {
    
    // Brute Force: O(n²) time, O(1) space
    public int[] twoSumBruteForce(int[] nums, int target) {
        for (int i = 0; i < nums.length; i++) {
            for (int j = i + 1; j < nums.length; j++) {
                if (nums[i] + nums[j] == target) {
                    return new int[]{i, j};
                }
            }
        }
        throw new IllegalArgumentException("No solution");
    }
    
    // Optimized: O(n) time, O(n) space using HashMap
    public int[] twoSum(int[] nums, int target) {
        Map<Integer, Integer> map = new HashMap<>();
        
        for (int i = 0; i < nums.length; i++) {
            int complement = target - nums[i];
            
            if (map.containsKey(complement)) {
                return new int[]{map.get(complement), i};
            }
            
            map.put(nums[i], i);
        }
        
        throw new IllegalArgumentException("No solution");
    }
    
    @Test
    public void testTwoSum() {
        int[] nums = {2, 7, 11, 15};
        int[] result = twoSum(nums, 9);
        assertArrayEquals(new int[]{0, 1}, result);
    }
}
```

**Key Points:**
- HashMap for O(1) lookup
- Store complements while iterating
- Handle edge cases (no solution, duplicate numbers)

---

## Problem 2: Longest Substring Without Repeating Characters

**Difficulty:** Medium  
**Companies:** Amazon, Facebook, Google

```java
/**
 * Input: "abcabcbb"
 * Output: 3 ("abc")
 */
public class LongestSubstring {
    
    // Sliding Window: O(n) time, O(min(n,m)) space
    public int lengthOfLongestSubstring(String s) {
        Map<Character, Integer> charIndex = new HashMap<>();
        int maxLength = 0;
        int left = 0;
        
        for (int right = 0; right < s.length(); right++) {
            char c = s.charAt(right);
            
            // If char seen before and in current window
            if (charIndex.containsKey(c) && charIndex.get(c) >= left) {
                left = charIndex.get(c) + 1;  // Move left pointer
            }
            
            charIndex.put(c, right);
            maxLength = Math.max(maxLength, right - left + 1);
        }
        
        return maxLength;
    }
    
    @Test
    public void testLongestSubstring() {
        assertEquals(3, lengthOfLongestSubstring("abcabcbb"));
        assertEquals(1, lengthOfLongestSubstring("bbbbb"));
        assertEquals(3, lengthOfLongestSubstring("pwwkew"));
    }
}
```

**Key Points:**
- Sliding window technique
- HashMap to track character positions
- Update window when duplicate found

---

## Problem 3: Merge Intervals

**Difficulty:** Medium  
**Companies:** Microsoft, Amazon, Bloomberg

```java
/**
 * Input: [[1,3],[2,6],[8,10],[15,18]]
 * Output: [[1,6],[8,10],[15,18]]
 */
public class MergeIntervals {
    
    public int[][] merge(int[][] intervals) {
        if (intervals.length <= 1) return intervals;
        
        // Sort by start time
        Arrays.sort(intervals, (a, b) -> Integer.compare(a[0], b[0]));
        
        List<int[]> result = new ArrayList<>();
        int[] current = intervals[0];
        result.add(current);
        
        for (int[] interval : intervals) {
            int currentEnd = current[1];
            int nextStart = interval[0];
            int nextEnd = interval[1];
            
            if (nextStart <= currentEnd) {
                // Overlapping, merge
                current[1] = Math.max(currentEnd, nextEnd);
            } else {
                // Non-overlapping, add new interval
                current = interval;
                result.add(current);
            }
        }
        
        return result.toArray(new int[result.size()][]);
    }
    
    @Test
    public void testMergeIntervals() {
        int[][] intervals = {{1,3}, {2,6}, {8,10}, {15,18}};
        int[][] expected = {{1,6}, {8,10}, {15,18}};
        assertArrayEquals(expected, merge(intervals));
    }
}
```

**Key Points:**
- Sort intervals by start time
- Iterate and merge overlapping intervals
- Track current merged interval

---

## Problem 4: Valid Parentheses

**Difficulty:** Easy  
**Companies:** Amazon, Microsoft, Facebook

```java
/**
 * Input: "({[]})"
 * Output: true
 * 
 * Input: "([)]"
 * Output: false
 */
public class ValidParentheses {
    
    public boolean isValid(String s) {
        Stack<Character> stack = new Stack<>();
        Map<Character, Character> pairs = Map.of(
            ')', '(',
            ']', '[',
            '}', '{'
        );
        
        for (char c : s.toCharArray()) {
            if (pairs.containsValue(c)) {
                // Opening bracket
                stack.push(c);
            } else if (pairs.containsKey(c)) {
                // Closing bracket
                if (stack.isEmpty() || stack.pop() != pairs.get(c)) {
                    return false;
                }
            }
        }
        
        return stack.isEmpty();
    }
    
    @Test
    public void testValidParentheses() {
        assertTrue(isValid("()"));
        assertTrue(isValid("()[]{}"));
        assertTrue(isValid("{[]}"));
        assertFalse(isValid("(]"));
        assertFalse(isValid("([)]"));
    }
}
```

**Key Points:**
- Use stack for matching pairs
- Push opening brackets, pop for closing
- Check stack is empty at end

---

## Problem 5: Rotate Array

**Difficulty:** Medium  
**Companies:** Amazon, Microsoft

```java
/**
 * Input: nums = [1,2,3,4,5,6,7], k = 3
 * Output: [5,6,7,1,2,3,4]
 */
public class RotateArray {
    
    // Approach 1: Reverse - O(n) time, O(1) space
    public void rotate(int[] nums, int k) {
        k = k % nums.length;  // Handle k > length
        
        // Reverse entire array
        reverse(nums, 0, nums.length - 1);
        
        // Reverse first k elements
        reverse(nums, 0, k - 1);
        
        // Reverse remaining elements
        reverse(nums, k, nums.length - 1);
    }
    
    private void reverse(int[] nums, int start, int end) {
        while (start < end) {
            int temp = nums[start];
            nums[start] = nums[end];
            nums[end] = temp;
            start++;
            end--;
        }
    }
    
    // Approach 2: Extra array - O(n) time, O(n) space
    public void rotateExtraArray(int[] nums, int k) {
        k = k % nums.length;
        int[] result = new int[nums.length];
        
        for (int i = 0; i < nums.length; i++) {
            result[(i + k) % nums.length] = nums[i];
        }
        
        System.arraycopy(result, 0, nums, 0, nums.length);
    }
    
    @Test
    public void testRotate() {
        int[] nums = {1, 2, 3, 4, 5, 6, 7};
        rotate(nums, 3);
        assertArrayEquals(new int[]{5, 6, 7, 1, 2, 3, 4}, nums);
    }
}
```

**Key Points:**
- Reverse algorithm: reverse all → reverse parts
- Handle k > array length with modulo
- In-place rotation for O(1) space

---

# 2. COLLECTIONS & DATA STRUCTURES

## Problem 6: LRU Cache

**Difficulty:** Medium  
**Companies:** Amazon, Google, Microsoft, Facebook

```java
/**
 * Implement Least Recently Used (LRU) cache with O(1) operations
 */
public class LRUCache {
    
    private class Node {
        int key, value;
        Node prev, next;
        
        Node(int key, int value) {
            this.key = key;
            this.value = value;
        }
    }
    
    private final int capacity;
    private final Map<Integer, Node> map;
    private final Node head, tail;
    
    public LRUCache(int capacity) {
        this.capacity = capacity;
        this.map = new HashMap<>();
        
        // Dummy head and tail
        head = new Node(0, 0);
        tail = new Node(0, 0);
        head.next = tail;
        tail.prev = head;
    }
    
    public int get(int key) {
        if (!map.containsKey(key)) {
            return -1;
        }
        
        Node node = map.get(key);
        remove(node);
        addToHead(node);
        return node.value;
    }
    
    public void put(int key, int value) {
        if (map.containsKey(key)) {
            Node node = map.get(key);
            node.value = value;
            remove(node);
            addToHead(node);
        } else {
            if (map.size() >= capacity) {
                // Remove LRU (tail)
                Node lru = tail.prev;
                remove(lru);
                map.remove(lru.key);
            }
            
            Node newNode = new Node(key, value);
            addToHead(newNode);
            map.put(key, newNode);
        }
    }
    
    private void addToHead(Node node) {
        node.next = head.next;
        node.prev = head;
        head.next.prev = node;
        head.next = node;
    }
    
    private void remove(Node node) {
        node.prev.next = node.next;
        node.next.prev = node.prev;
    }
    
    @Test
    public void testLRUCache() {
        LRUCache cache = new LRUCache(2);
        cache.put(1, 1);
        cache.put(2, 2);
        assertEquals(1, cache.get(1));  // Returns 1
        cache.put(3, 3);                 // Evicts key 2
        assertEquals(-1, cache.get(2));  // Returns -1 (not found)
        cache.put(4, 4);                 // Evicts key 1
        assertEquals(-1, cache.get(1));  // Returns -1 (not found)
        assertEquals(3, cache.get(3));   // Returns 3
        assertEquals(4, cache.get(4));   // Returns 4
    }
}
```

**Key Points:**
- HashMap + Doubly Linked List
- O(1) get and put operations
- Most recently used at head, least at tail

---

## Problem 7: Group Anagrams

**Difficulty:** Medium  
**Companies:** Amazon, Facebook, Uber

```java
/**
 * Input: ["eat","tea","tan","ate","nat","bat"]
 * Output: [["bat"],["nat","tan"],["ate","eat","tea"]]
 */
public class GroupAnagrams {
    
    public List<List<String>> groupAnagrams(String[] strs) {
        Map<String, List<String>> map = new HashMap<>();
        
        for (String str : strs) {
            // Sort string to get key
            char[] chars = str.toCharArray();
            Arrays.sort(chars);
            String key = new String(chars);
            
            // Add to group
            map.computeIfAbsent(key, k -> new ArrayList<>()).add(str);
        }
        
        return new ArrayList<>(map.values());
    }
    
    // Optimized: Character frequency as key
    public List<List<String>> groupAnagramsOptimized(String[] strs) {
        Map<String, List<String>> map = new HashMap<>();
        
        for (String str : strs) {
            // Create frequency key: "a2e1t1"
            int[] counts = new int[26];
            for (char c : str.toCharArray()) {
                counts[c - 'a']++;
            }
            
            StringBuilder key = new StringBuilder();
            for (int i = 0; i < 26; i++) {
                if (counts[i] > 0) {
                    key.append((char) ('a' + i)).append(counts[i]);
                }
            }
            
            map.computeIfAbsent(key.toString(), k -> new ArrayList<>()).add(str);
        }
        
        return new ArrayList<>(map.values());
    }
    
    @Test
    public void testGroupAnagrams() {
        String[] input = {"eat", "tea", "tan", "ate", "nat", "bat"};
        List<List<String>> result = groupAnagrams(input);
        assertEquals(3, result.size());
    }
}
```

**Key Points:**
- Use sorted string as HashMap key
- Or use character frequency as key
- Group anagrams under same key

---

## Problem 8: Top K Frequent Elements

**Difficulty:** Medium  
**Companies:** Amazon, Microsoft, Facebook

```java
/**
 * Input: nums = [1,1,1,2,2,3], k = 2
 * Output: [1,2]
 */
public class TopKFrequent {
    
    // Approach 1: Heap - O(n log k) time
    public int[] topKFrequent(int[] nums, int k) {
        // Count frequencies
        Map<Integer, Integer> freq = new HashMap<>();
        for (int num : nums) {
            freq.put(num, freq.getOrDefault(num, 0) + 1);
        }
        
        // Min heap of size k
        PriorityQueue<Integer> heap = new PriorityQueue<>(
            (a, b) -> freq.get(a) - freq.get(b)
        );
        
        for (int num : freq.keySet()) {
            heap.offer(num);
            if (heap.size() > k) {
                heap.poll();  // Remove least frequent
            }
        }
        
        // Build result
        int[] result = new int[k];
        for (int i = k - 1; i >= 0; i--) {
            result[i] = heap.poll();
        }
        return result;
    }
    
    // Approach 2: Bucket Sort - O(n) time
    public int[] topKFrequentBucket(int[] nums, int k) {
        Map<Integer, Integer> freq = new HashMap<>();
        for (int num : nums) {
            freq.put(num, freq.getOrDefault(num, 0) + 1);
        }
        
        // Bucket sort: index = frequency
        List<Integer>[] buckets = new List[nums.length + 1];
        for (int num : freq.keySet()) {
            int frequency = freq.get(num);
            if (buckets[frequency] == null) {
                buckets[frequency] = new ArrayList<>();
            }
            buckets[frequency].add(num);
        }
        
        // Collect top k
        int[] result = new int[k];
        int index = 0;
        for (int i = buckets.length - 1; i >= 0 && index < k; i--) {
            if (buckets[i] != null) {
                for (int num : buckets[i]) {
                    result[index++] = num;
                    if (index == k) break;
                }
            }
        }
        
        return result;
    }
    
    @Test
    public void testTopKFrequent() {
        int[] nums = {1, 1, 1, 2, 2, 3};
        int[] result = topKFrequent(nums, 2);
        assertTrue(Arrays.equals(new int[]{1, 2}, result) || 
                   Arrays.equals(new int[]{2, 1}, result));
    }
}
```

**Key Points:**
- Count frequencies with HashMap
- Use min heap to keep top k
- Or bucket sort for O(n) time

---

## Problem 9: Design HashMap

**Difficulty:** Easy  
**Companies:** Amazon, Google

```java
/**
 * Implement HashMap from scratch
 */
public class MyHashMap {
    
    private class Node {
        int key, value;
        Node next;
        
        Node(int key, int value) {
            this.key = key;
            this.value = value;
        }
    }
    
    private final int SIZE = 1000;
    private Node[] buckets;
    
    public MyHashMap() {
        buckets = new Node[SIZE];
    }
    
    private int hash(int key) {
        return key % SIZE;
    }
    
    public void put(int key, int value) {
        int index = hash(key);
        
        if (buckets[index] == null) {
            buckets[index] = new Node(key, value);
            return;
        }
        
        // Check if key exists
        Node node = buckets[index];
        Node prev = null;
        while (node != null) {
            if (node.key == key) {
                node.value = value;  // Update
                return;
            }
            prev = node;
            node = node.next;
        }
        
        // Add new node
        prev.next = new Node(key, value);
    }
    
    public int get(int key) {
        int index = hash(key);
        Node node = buckets[index];
        
        while (node != null) {
            if (node.key == key) {
                return node.value;
            }
            node = node.next;
        }
        
        return -1;  // Not found
    }
    
    public void remove(int key) {
        int index = hash(key);
        Node node = buckets[index];
        Node prev = null;
        
        while (node != null) {
            if (node.key == key) {
                if (prev == null) {
                    buckets[index] = node.next;
                } else {
                    prev.next = node.next;
                }
                return;
            }
            prev = node;
            node = node.next;
        }
    }
    
    @Test
    public void testMyHashMap() {
        MyHashMap map = new MyHashMap();
        map.put(1, 1);
        map.put(2, 2);
        assertEquals(1, map.get(1));
        assertEquals(-1, map.get(3));
        map.put(2, 1);
        assertEquals(1, map.get(2));
        map.remove(2);
        assertEquals(-1, map.get(2));
    }
}
```

**Key Points:**
- Array of linked lists (separate chaining)
- Hash function: key % size
- Handle collisions with linked list

---

# 3. MULTITHREADING & CONCURRENCY

## Problem 10: Print Numbers Alternately (Producer-Consumer)

**Difficulty:** Medium  
**Companies:** Amazon, Microsoft

```java
/**
 * Two threads print numbers alternately:
 * Thread 1: 1, 3, 5, 7...
 * Thread 2: 2, 4, 6, 8...
 */
public class PrintNumbersAlternately {
    
    private int count = 1;
    private final int max;
    private final Object lock = new Object();
    
    public PrintNumbersAlternately(int max) {
        this.max = max;
    }
    
    public void printOdd() {
        synchronized (lock) {
            while (count <= max) {
                while (count % 2 == 0) {
                    try {
                        lock.wait();
                    } catch (InterruptedException e) {
                        Thread.currentThread().interrupt();
                    }
                }
                
                if (count <= max) {
                    System.out.println(Thread.currentThread().getName() + ": " + count++);
                    lock.notify();
                }
            }
        }
    }
    
    public void printEven() {
        synchronized (lock) {
            while (count <= max) {
                while (count % 2 == 1) {
                    try {
                        lock.wait();
                    } catch (InterruptedException e) {
                        Thread.currentThread().interrupt();
                    }
                }
                
                if (count <= max) {
                    System.out.println(Thread.currentThread().getName() + ": " + count++);
                    lock.notify();
                }
            }
        }
    }
    
    public static void main(String[] args) {
        PrintNumbersAlternately printer = new PrintNumbersAlternately(10);
        
        Thread t1 = new Thread(printer::printOdd, "OddThread");
        Thread t2 = new Thread(printer::printEven, "EvenThread");
        
        t1.start();
        t2.start();
    }
}
```

**Key Points:**
- wait() and notify() for coordination
- Synchronized block for mutual exclusion
- Check condition in while loop (not if)

---

## Problem 11: Implement Thread-Safe Singleton

**Difficulty:** Easy/Medium  
**Companies:** Amazon, Microsoft, Oracle

```java
/**
 * Thread-safe Singleton implementation
 */
public class ThreadSafeSingleton {
    
    // Approach 1: Eager initialization (thread-safe)
    private static final ThreadSafeSingleton INSTANCE = new ThreadSafeSingleton();
    
    private ThreadSafeSingleton() {
        if (INSTANCE != null) {
            throw new IllegalStateException("Singleton already initialized");
        }
    }
    
    public static ThreadSafeSingleton getInstance() {
        return INSTANCE;
    }
}

// Approach 2: Lazy with double-checked locking
public class LazyThreadSafeSingleton {
    
    private static volatile LazyThreadSafeSingleton instance;
    
    private LazyThreadSafeSingleton() {
        if (instance != null) {
            throw new IllegalStateException("Singleton already initialized");
        }
    }
    
    public static LazyThreadSafeSingleton getInstance() {
        if (instance == null) {
            synchronized (LazyThreadSafeSingleton.class) {
                if (instance == null) {
                    instance = new LazyThreadSafeSingleton();
                }
            }
        }
        return instance;
    }
}

// Approach 3: Bill Pugh (best)
public class BillPughSingleton {
    
    private BillPughSingleton() {}
    
    private static class SingletonHelper {
        private static final BillPughSingleton INSTANCE = new BillPughSingleton();
    }
    
    public static BillPughSingleton getInstance() {
        return SingletonHelper.INSTANCE;
    }
}

// Approach 4: Enum (most concise)
public enum EnumSingleton {
    INSTANCE;
    
    public void doSomething() {
        System.out.println("Singleton action");
    }
}
```

**Key Points:**
- volatile for double-checked locking
- Bill Pugh inner static class (lazy + thread-safe)
- Enum is simplest and prevents reflection attacks

---

## Problem 12: Rate Limiter

**Difficulty:** Medium  
**Companies:** Google, Facebook, Uber

```java
/**
 * Implement rate limiter: Max N requests per second
 */
public class RateLimiter {
    
    // Token Bucket Algorithm
    private final int maxTokens;
    private final long refillIntervalMillis;
    private int availableTokens;
    private long lastRefillTime;
    private final Object lock = new Object();
    
    public RateLimiter(int requestsPerSecond) {
        this.maxTokens = requestsPerSecond;
        this.availableTokens = requestsPerSecond;
        this.refillIntervalMillis = 1000;  // 1 second
        this.lastRefillTime = System.currentTimeMillis();
    }
    
    public boolean tryAcquire() {
        synchronized (lock) {
            refillTokens();
            
            if (availableTokens > 0) {
                availableTokens--;
                return true;
            }
            
            return false;
        }
    }
    
    private void refillTokens() {
        long now = System.currentTimeMillis();
        long timeSinceLastRefill = now - lastRefillTime;
        
        if (timeSinceLastRefill >= refillIntervalMillis) {
            int tokensToAdd = (int) (timeSinceLastRefill / refillIntervalMillis) * maxTokens;
            availableTokens = Math.min(maxTokens, availableTokens + tokensToAdd);
            lastRefillTime = now;
        }
    }
    
    // Sliding Window Algorithm
    public class SlidingWindowRateLimiter {
        private final int maxRequests;
        private final long windowSizeMillis;
        private final Queue<Long> timestamps;
        
        public SlidingWindowRateLimiter(int maxRequests, long windowSizeMillis) {
            this.maxRequests = maxRequests;
            this.windowSizeMillis = windowSizeMillis;
            this.timestamps = new ConcurrentLinkedQueue<>();
        }
        
        public synchronized boolean tryAcquire() {
            long now = System.currentTimeMillis();
            long windowStart = now - windowSizeMillis;
            
            // Remove old timestamps
            while (!timestamps.isEmpty() && timestamps.peek() < windowStart) {
                timestamps.poll();
            }
            
            if (timestamps.size() < maxRequests) {
                timestamps.offer(now);
                return true;
            }
            
            return false;
        }
    }
    
    @Test
    public void testRateLimiter() throws InterruptedException {
        RateLimiter limiter = new RateLimiter(5);  // 5 requests per second
        
        // Should allow 5 requests
        for (int i = 0; i < 5; i++) {
            assertTrue(limiter.tryAcquire());
        }
        
        // Should deny 6th request
        assertFalse(limiter.tryAcquire());
        
        // Wait 1 second and try again
        Thread.sleep(1000);
        assertTrue(limiter.tryAcquire());
    }
}
```

**Key Points:**
- Token Bucket or Sliding Window algorithm
- Thread-safe with synchronized
- Refill tokens periodically

---

# 4. JAVA 8 STREAMS & FUNCTIONAL

## Problem 13: Find Second Highest Salary

**Difficulty:** Easy  
**Companies:** Amazon, Microsoft

```java
/**
 * Find second highest salary using Java 8 Streams
 */
public class SecondHighestSalary {
    
    public static class Employee {
        String name;
        double salary;
        
        public Employee(String name, double salary) {
            this.name = name;
            this.salary = salary;
        }
        
        public double getSalary() { return salary; }
    }
    
    public Double secondHighestSalary(List<Employee> employees) {
        return employees.stream()
            .map(Employee::getSalary)
            .distinct()
            .sorted((a, b) -> Double.compare(b, a))  // Descending
            .skip(1)  // Skip highest
            .findFirst()
            .orElse(null);
    }
    
    @Test
    public void testSecondHighest() {
        List<Employee> employees = Arrays.asList(
            new Employee("John", 100000),
            new Employee("Jane", 120000),
            new Employee("Bob", 90000),
            new Employee("Alice", 120000)  // Duplicate highest
        );
        
        assertEquals(100000.0, secondHighestSalary(employees), 0.01);
    }
}
```

**Key Points:**
- Stream API with distinct(), sorted(), skip()
- Handle duplicates and edge cases
- Use Optional for null-safety

---

## Problem 14: Group Employees by Department and Calculate Average Salary

**Difficulty:** Medium  
**Companies:** Amazon, Oracle

```java
public class EmployeeAnalytics {
    
    public static class Employee {
        String name;
        String department;
        double salary;
        
        public Employee(String name, String department, double salary) {
            this.name = name;
            this.department = department;
            this.salary = salary;
        }
        
        public String getDepartment() { return department; }
        public double getSalary() { return salary; }
    }
    
    // Group by department, calculate average salary
    public Map<String, Double> averageSalaryByDepartment(List<Employee> employees) {
        return employees.stream()
            .collect(Collectors.groupingBy(
                Employee::getDepartment,
                Collectors.averagingDouble(Employee::getSalary)
            ));
    }
    
    // Find department with highest average salary
    public Optional<Map.Entry<String, Double>> highestPayingDepartment(
            List<Employee> employees) {
        return employees.stream()
            .collect(Collectors.groupingBy(
                Employee::getDepartment,
                Collectors.averagingDouble(Employee::getSalary)
            ))
            .entrySet()
            .stream()
            .max(Map.Entry.comparingByValue());
    }
    
    // Get top N highest paid employees
    public List<Employee> topNEmployees(List<Employee> employees, int n) {
        return employees.stream()
            .sorted((a, b) -> Double.compare(b.getSalary(), a.getSalary()))
            .limit(n)
            .collect(Collectors.toList());
    }
    
    @Test
    public void testEmployeeAnalytics() {
        List<Employee> employees = Arrays.asList(
            new Employee("John", "IT", 100000),
            new Employee("Jane", "IT", 120000),
            new Employee("Bob", "HR", 80000),
            new Employee("Alice", "HR", 90000)
        );
        
        Map<String, Double> avgSalaries = averageSalaryByDepartment(employees);
        assertEquals(110000.0, avgSalaries.get("IT"), 0.01);
        assertEquals(85000.0, avgSalaries.get("HR"), 0.01);
    }
}
```

**Key Points:**
- Collectors.groupingBy() for grouping
- Collectors.averagingDouble() for aggregation
- Chaining stream operations

---

## Problem 15: FlatMap - Find All Unique Words from Sentences

**Difficulty:** Easy  
**Companies:** Google, Amazon

```java
public class FlatMapExample {
    
    public List<String> findUniqueWords(List<String> sentences) {
        return sentences.stream()
            .flatMap(sentence -> Arrays.stream(sentence.split("\\s+")))
            .map(String::toLowerCase)
            .distinct()
            .sorted()
            .collect(Collectors.toList());
    }
    
    // Find words appearing in multiple sentences
    public Set<String> findCommonWords(List<String> sentences) {
        if (sentences.isEmpty()) return Collections.emptySet();
        
        List<Set<String>> wordSets = sentences.stream()
            .map(sentence -> Arrays.stream(sentence.split("\\s+"))
                .map(String::toLowerCase)
                .collect(Collectors.toSet()))
            .collect(Collectors.toList());
        
        // Find intersection
        Set<String> common = new HashSet<>(wordSets.get(0));
        wordSets.forEach(common::retainAll);
        
        return common;
    }
    
    @Test
    public void testFlatMap() {
        List<String> sentences = Arrays.asList(
            "Hello World",
            "Hello Java",
            "Java Streams are powerful"
        );
        
        List<String> unique = findUniqueWords(sentences);
        assertTrue(unique.contains("hello"));
        assertTrue(unique.contains("java"));
        assertTrue(unique.contains("streams"));
    }
}
```

**Key Points:**
- flatMap() to flatten nested structures
- Split sentences into words
- Use distinct() for uniqueness

---

## Problem 16: Parallel Stream Processing

**Difficulty:** Medium  
**Companies:** Amazon, Google

```java
public class ParallelStreamProcessing {
    
    // Sequential processing
    public long sumSequential(List<Integer> numbers) {
        return numbers.stream()
            .mapToLong(Integer::longValue)
            .sum();
    }
    
    // Parallel processing
    public long sumParallel(List<Integer> numbers) {
        return numbers.parallelStream()
            .mapToLong(Integer::longValue)
            .sum();
    }
    
    // Custom reduction
    public int customReduce(List<Integer> numbers) {
        return numbers.parallelStream()
            .reduce(0, Integer::sum);
    }
    
    // Parallel processing with thread safety
    public Map<String, Long> wordFrequencyParallel(List<String> words) {
        return words.parallelStream()
            .collect(Collectors.groupingByConcurrent(
                Function.identity(),
                Collectors.counting()
            ));
    }
    
    @Test
    public void testParallelProcessing() {
        List<Integer> largeList = IntStream.rangeClosed(1, 1_000_000)
            .boxed()
            .collect(Collectors.toList());
        
        long startSeq = System.currentTimeMillis();
        long sumSeq = sumSequential(largeList);
        long endSeq = System.currentTimeMillis();
        
        long startPar = System.currentTimeMillis();
        long sumPar = sumParallel(largeList);
        long endPar = System.currentTimeMillis();
        
        assertEquals(sumSeq, sumPar);
        System.out.println("Sequential: " + (endSeq - startSeq) + "ms");
        System.out.println("Parallel: " + (endPar - startPar) + "ms");
    }
}
```

**Key Points:**
- parallelStream() for parallel processing
- Use Collectors.groupingByConcurrent() for thread-safety
- Parallel streams benefit large datasets

---

# 5. DESIGN & OOP

## Problem 17: Design a Parking Lot System

**Difficulty:** Hard  
**Companies:** Amazon, Microsoft, Google

```java
/**
 * Design parking lot with multiple levels, different vehicle types
 */
public class ParkingLotSystem {
    
    // Enum for vehicle types
    enum VehicleType {
        MOTORCYCLE(1),
        CAR(2),
        TRUCK(3);
        
        private final int size;
        
        VehicleType(int size) {
            this.size = size;
        }
        
        public int getSize() { return size; }
    }
    
    // Vehicle class
    abstract class Vehicle {
        protected String licensePlate;
        protected VehicleType type;
        
        public Vehicle(String licensePlate, VehicleType type) {
            this.licensePlate = licensePlate;
            this.type = type;
        }
        
        public VehicleType getType() { return type; }
        public String getLicensePlate() { return licensePlate; }
    }
    
    class Motorcycle extends Vehicle {
        public Motorcycle(String licensePlate) {
            super(licensePlate, VehicleType.MOTORCYCLE);
        }
    }
    
    class Car extends Vehicle {
        public Car(String licensePlate) {
            super(licensePlate, VehicleType.CAR);
        }
    }
    
    class Truck extends Vehicle {
        public Truck(String licensePlate) {
            super(licensePlate, VehicleType.TRUCK);
        }
    }
    
    // Parking spot
    class ParkingSpot {
        private final int id;
        private final VehicleType supportedType;
        private Vehicle vehicle;
        
        public ParkingSpot(int id, VehicleType supportedType) {
            this.id = id;
            this.supportedType = supportedType;
        }
        
        public synchronized boolean park(Vehicle vehicle) {
            if (isFree() && canFit(vehicle)) {
                this.vehicle = vehicle;
                return true;
            }
            return false;
        }
        
        public synchronized void unpark() {
            this.vehicle = null;
        }
        
        public boolean isFree() {
            return vehicle == null;
        }
        
        private boolean canFit(Vehicle vehicle) {
            return vehicle.getType().getSize() <= supportedType.getSize();
        }
        
        public int getId() { return id; }
    }
    
    // Parking level
    class ParkingLevel {
        private final int levelId;
        private final List<ParkingSpot> spots;
        
        public ParkingLevel(int levelId, int motorcycleSpots, int carSpots, int truckSpots) {
            this.levelId = levelId;
            this.spots = new ArrayList<>();
            
            int spotId = 0;
            for (int i = 0; i < motorcycleSpots; i++) {
                spots.add(new ParkingSpot(spotId++, VehicleType.MOTORCYCLE));
            }
            for (int i = 0; i < carSpots; i++) {
                spots.add(new ParkingSpot(spotId++, VehicleType.CAR));
            }
            for (int i = 0; i < truckSpots; i++) {
                spots.add(new ParkingSpot(spotId++, VehicleType.TRUCK));
            }
        }
        
        public synchronized ParkingSpot parkVehicle(Vehicle vehicle) {
            for (ParkingSpot spot : spots) {
                if (spot.park(vehicle)) {
                    return spot;
                }
            }
            return null;
        }
        
        public synchronized void unparkVehicle(ParkingSpot spot) {
            spot.unpark();
        }
        
        public int getAvailableSpots() {
            return (int) spots.stream().filter(ParkingSpot::isFree).count();
        }
    }
    
    // Parking lot
    class ParkingLot {
        private final List<ParkingLevel> levels;
        private final Map<String, ParkingSpot> vehicleSpotMap;
        
        public ParkingLot(int numLevels, int spotsPerLevel) {
            this.levels = new ArrayList<>();
            this.vehicleSpotMap = new ConcurrentHashMap<>();
            
            for (int i = 0; i < numLevels; i++) {
                levels.add(new ParkingLevel(i, 10, 20, 5));  // Example capacity
            }
        }
        
        public boolean parkVehicle(Vehicle vehicle) {
            for (ParkingLevel level : levels) {
                ParkingSpot spot = level.parkVehicle(vehicle);
                if (spot != null) {
                    vehicleSpotMap.put(vehicle.getLicensePlate(), spot);
                    return true;
                }
            }
            return false;  // No available spot
        }
        
        public boolean unparkVehicle(String licensePlate) {
            ParkingSpot spot = vehicleSpotMap.get(licensePlate);
            if (spot != null) {
                spot.unpark();
                vehicleSpotMap.remove(licensePlate);
                return true;
            }
            return false;
        }
        
        public int getTotalAvailableSpots() {
            return levels.stream()
                .mapToInt(ParkingLevel::getAvailableSpots)
                .sum();
        }
    }
    
    @Test
    public void testParkingLot() {
        ParkingLot lot = new ParkingLot(3, 35);
        
        Vehicle car = new Car("ABC123");
        Vehicle truck = new Truck("XYZ789");
        
        assertTrue(lot.parkVehicle(car));
        assertTrue(lot.parkVehicle(truck));
        
        assertTrue(lot.unparkVehicle("ABC123"));
        assertFalse(lot.unparkVehicle("NOT_EXIST"));
    }
}
```

**Key Points:**
- OOP principles (inheritance, encapsulation)
- Thread-safety with synchronized
- Enums for vehicle types
- HashMap to track vehicle locations

---

## Problem 18: Design a Logger with Rate Limiting

**Difficulty:** Medium  
**Companies:** Google, Facebook

```java
/**
 * Logger that prints message only once every 10 seconds per message
 */
public class Logger {
    
    private final Map<String, Long> messageTimestamps;
    private final long throttleWindow;
    
    public Logger() {
        this(10000);  // Default 10 seconds
    }
    
    public Logger(long throttleWindowMillis) {
        this.messageTimestamps = new ConcurrentHashMap<>();
        this.throttleWindow = throttleWindowMillis;
    }
    
    public boolean shouldPrintMessage(long timestamp, String message) {
        Long lastTimestamp = messageTimestamps.get(message);
        
        if (lastTimestamp == null || timestamp - lastTimestamp >= throttleWindow) {
            messageTimestamps.put(message, timestamp);
            return true;
        }
        
        return false;
    }
    
    // Cleanup old entries periodically
    public void cleanup(long currentTimestamp) {
        messageTimestamps.entrySet().removeIf(entry -> 
            currentTimestamp - entry.getValue() > throttleWindow
        );
    }
    
    @Test
    public void testLogger() {
        Logger logger = new Logger(10000);
        
        // Should print
        assertTrue(logger.shouldPrintMessage(1000, "Hello"));
        
        // Should not print (within 10 seconds)
        assertFalse(logger.shouldPrintMessage(5000, "Hello"));
        
        // Should print (after 10 seconds)
        assertTrue(logger.shouldPrintMessage(12000, "Hello"));
        
        // Different message should print
        assertTrue(logger.shouldPrintMessage(5000, "World"));
    }
}
```

**Key Points:**
- ConcurrentHashMap for thread-safety
- Track last timestamp per message
- Cleanup mechanism for memory management

---

## Problem 19: Implement a Thread Pool

**Difficulty:** Hard  
**Companies:** Amazon, Google

```java
/**
 * Custom thread pool implementation
 */
public class SimpleThreadPool {
    
    private final BlockingQueue<Runnable> taskQueue;
    private final List<WorkerThread> threads;
    private volatile boolean isShutdown;
    
    public SimpleThreadPool(int numThreads, int maxQueueSize) {
        this.taskQueue = new LinkedBlockingQueue<>(maxQueueSize);
        this.threads = new ArrayList<>();
        this.isShutdown = false;
        
        // Create and start worker threads
        for (int i = 0; i < numThreads; i++) {
            WorkerThread thread = new WorkerThread();
            threads.add(thread);
            thread.start();
        }
    }
    
    public void submit(Runnable task) throws InterruptedException {
        if (isShutdown) {
            throw new IllegalStateException("Thread pool is shut down");
        }
        taskQueue.put(task);
    }
    
    public void shutdown() {
        isShutdown = true;
        for (WorkerThread thread : threads) {
            thread.interrupt();
        }
    }
    
    private class WorkerThread extends Thread {
        @Override
        public void run() {
            while (!isShutdown) {
                try {
                    Runnable task = taskQueue.take();
                    task.run();
                } catch (InterruptedException e) {
                    if (isShutdown) {
                        break;
                    }
                } catch (Exception e) {
                    // Log task execution error
                    e.printStackTrace();
                }
            }
        }
    }
    
    @Test
    public void testThreadPool() throws InterruptedException {
        SimpleThreadPool pool = new SimpleThreadPool(4, 100);
        
        AtomicInteger counter = new AtomicInteger(0);
        
        // Submit 10 tasks
        for (int i = 0; i < 10; i++) {
            pool.submit(() -> {
                counter.incrementAndGet();
                try {
                    Thread.sleep(100);
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                }
            });
        }
        
        // Wait for completion
        Thread.sleep(500);
        assertEquals(10, counter.get());
        
        pool.shutdown();
    }
}
```

**Key Points:**
- BlockingQueue for task queue
- Worker threads consume tasks
- Graceful shutdown mechanism

---

# 6. REAL-WORLD SCENARIOS

## Problem 20: Design URL Shortener

**Difficulty:** Medium/Hard  
**Companies:** Google, Amazon, Facebook, Twitter

```java
/**
 * Design URL shortener like bit.ly
 * Requirements:
 * - Shorten long URLs
 * - Retrieve original URL from short URL
 * - Thread-safe
 * - Handle collisions
 */
public class URLShortener {
    
    private static final String BASE62 = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    private final Map<String, String> urlMap;         // shortUrl -> longUrl
    private final Map<String, String> reverseMap;     // longUrl -> shortUrl
    private final AtomicLong counter;
    
    public URLShortener() {
        this.urlMap = new ConcurrentHashMap<>();
        this.reverseMap = new ConcurrentHashMap<>();
        this.counter = new AtomicLong(1000000);  // Start from 1M
    }
    
    // Shorten URL
    public String shorten(String longUrl) {
        // Check if already shortened
        if (reverseMap.containsKey(longUrl)) {
            return reverseMap.get(longUrl);
        }
        
        // Generate short URL
        long id = counter.getAndIncrement();
        String shortUrl = encode(id);
        
        // Store mappings
        urlMap.put(shortUrl, longUrl);
        reverseMap.put(longUrl, shortUrl);
        
        return shortUrl;
    }
    
    // Retrieve original URL
    public String expand(String shortUrl) {
        return urlMap.get(shortUrl);
    }
    
    // Encode number to Base62
    private String encode(long num) {
        StringBuilder sb = new StringBuilder();
        
        while (num > 0) {
            sb.append(BASE62.charAt((int) (num % 62)));
            num /= 62;
        }
        
        return sb.reverse().toString();
    }
    
    // Decode Base62 to number
    private long decode(String str) {
        long num = 0;
        
        for (char c : str.toCharArray()) {
            num = num * 62 + BASE62.indexOf(c);
        }
        
        return num;
    }
    
    // Custom short URL (with collision handling)
    public String shortenCustom(String longUrl, String desiredShort) {
        if (urlMap.containsKey(desiredShort)) {
            throw new IllegalArgumentException("Short URL already exists");
        }
        
        urlMap.put(desiredShort, longUrl);
        reverseMap.put(longUrl, desiredShort);
        
        return desiredShort;
    }
    
    // Analytics: Get click count (would use separate counter in production)
    public int getClickCount(String shortUrl) {
        // In production, use Redis or database
        return 0;  // Placeholder
    }
    
    @Test
    public void testURLShortener() {
        URLShortener shortener = new URLShortener();
        
        String longUrl = "https://www.example.com/very/long/url/path";
        String shortUrl = shortener.shorten(longUrl);
        
        assertNotNull(shortUrl);
        assertTrue(shortUrl.length() < longUrl.length());
        
        // Verify expansion
        assertEquals(longUrl, shortener.expand(shortUrl));
        
        // Verify idempotency (same long URL returns same short URL)
        String shortUrl2 = shortener.shorten(longUrl);
        assertEquals(shortUrl, shortUrl2);
    }
}
```

**Key Points:**
- Base62 encoding for short URLs
- ConcurrentHashMap for thread-safety
- Bidirectional mapping (long ↔ short)
- AtomicLong for ID generation
- Handle collisions and custom URLs

---

# SUMMARY & TIPS

## Problem-Solving Strategy

```
1. Clarify requirements and constraints
2. Discuss edge cases
3. Start with brute force solution
4. Optimize time/space complexity
5. Write clean, readable code
6. Test with examples
```

## Common Patterns

| **Pattern** | **Use Case** | **Example** |
|-------------|--------------|-------------|
| Two Pointers | Sorted arrays, palindromes | Two Sum II |
| Sliding Window | Substrings, subarrays | Longest Substring |
| HashMap | Frequency counting, lookups | Anagrams |
| Stack | Parentheses, parsing | Valid Parentheses |
| Heap | Top K elements | Top K Frequent |
| DFS/BFS | Graph, tree traversal | Binary Tree |
| Dynamic Programming | Optimization problems | Fibonacci |

## Time Complexity

```
O(1) - Constant: HashMap lookup
O(log n) - Logarithmic: Binary search
O(n) - Linear: Single loop
O(n log n) - Linearithmic: Merge sort
O(n²) - Quadratic: Nested loops
O(2^n) - Exponential: Recursion
```

## Interview Tips

1. **Communicate**: Think aloud, explain approach
2. **Test**: Verify with examples, edge cases
3. **Optimize**: Discuss trade-offs (time vs space)
4. **Clean Code**: Use meaningful names, proper indentation
5. **Handle Errors**: Null checks, validations

---

**END OF JAVA CODING INTERVIEW PROBLEMS**

Practice these 20 problems covering all key areas for 4-5 years experience interviews!