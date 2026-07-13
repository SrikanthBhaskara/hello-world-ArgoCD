# JAVA STRINGS - COMPLETE INTERVIEW GUIDE

**Comprehensive guide covering String internals, String Pool, immutability, StringBuilder vs StringBuffer, and string manipulation for 4-5 years experience interviews.**

---

# TABLE OF CONTENTS

1. [String Fundamentals](#1-string-fundamentals)
2. [String Pool (String Interning)](#2-string-pool-string-interning)
3. [String Immutability](#3-string-immutability)
4. [StringBuilder vs StringBuffer](#4-stringbuilder-vs-stringbuffer)
5. [String Performance](#5-string-performance)
6. [String Methods Deep Dive](#6-string-methods-deep-dive)
7. [Regular Expressions](#7-regular-expressions)
8. [String Encoding](#8-string-encoding)
9. [Interview Questions](#9-interview-questions)
10. [Interview Traps](#10-interview-traps)
11. [Coding Problems](#11-coding-problems)
12. [Summary & Quick Reference](#12-summary--quick-reference)

---

# 1. STRING FUNDAMENTALS

## What is String?

```java
/**
 * String is immutable sequence of characters
 * 
 * Internal representation:
 * - Java 8 and earlier: char[] array
 * - Java 9+: byte[] array + encoding flag (compact strings)
 */

public final class String implements Serializable, Comparable<String>, CharSequence {
    // Java 9+
    private final byte[] value;      // Character storage
    private final byte coder;         // LATIN1 or UTF16
    private int hash;                 // Cached hashcode
}
```

## String Creation

```java
// 1. String literals (recommended)
String s1 = "Hello";              // Created in String Pool

// 2. Using new keyword
String s2 = new String("Hello");   // Creates object in Heap

// 3. Character array
char[] chars = {'H', 'e', 'l', 'l', 'o'};
String s3 = new String(chars);

// 4. Byte array
byte[] bytes = {72, 101, 108, 108, 111};
String s4 = new String(bytes);

// 5. StringBuilder/StringBuffer
StringBuilder sb = new StringBuilder("Hello");
String s5 = sb.toString();
```

## String Comparison

```java
String s1 = "Hello";
String s2 = "Hello";
String s3 = new String("Hello");

// == operator (reference comparison)
System.out.println(s1 == s2);      // true (same reference in String Pool)
System.out.println(s1 == s3);      // false (different objects)

// equals() method (content comparison)
System.out.println(s1.equals(s3)); // true (same content)

// equalsIgnoreCase()
System.out.println("Hello".equalsIgnoreCase("hello")); // true

// compareTo() - lexicographic comparison
System.out.println("apple".compareTo("banana"));  // negative (apple < banana)
System.out.println("banana".compareTo("apple"));  // positive (banana > apple)
System.out.println("apple".compareTo("apple"));   // 0 (equal)
```

---

# 2. STRING POOL (STRING INTERNING)

## What is String Pool?

**String Pool** (String Constant Pool) is a special memory region in the **Java Heap** (since Java 7) that stores String literals to optimize memory usage.

```java
/**
 * Location:
 * - Java 6 and earlier: PermGen space
 * - Java 7+: Heap memory
 * 
 * Purpose: Reuse String literals to save memory
 */

String s1 = "Hello";  // Created in String Pool
String s2 = "Hello";  // Reuses same object from Pool

System.out.println(s1 == s2);  // true (same reference)
```

## How String Pool Works

```java
// Literals go to String Pool
String s1 = "Java";      // Creates "Java" in Pool
String s2 = "Java";      // Reuses existing "Java"
String s3 = "Programming";  // Creates "Programming" in Pool

System.out.println(s1 == s2);  // true

// new String() creates object in Heap
String s4 = new String("Java");  // Creates new object in Heap
System.out.println(s1 == s4);    // false

// intern() adds to String Pool
String s5 = new String("Java").intern();
System.out.println(s1 == s5);    // true (now points to Pool)
```

## String Pool Memory Diagram

```
┌─────────────────────────────────────┐
│  HEAP                               │
│                                     │
│  ┌──────────────────┐               │
│  │  String Pool     │               │
│  │                  │               │
│  │  "Hello" ←───────┼──── s1, s2   │
│  │  "World"         │               │
│  └──────────────────┘               │
│                                     │
│  ┌──────────────────┐               │
│  │  Regular Objects │               │
│  │                  │               │
│  │  String("Hello") ←──── s3       │
│  └──────────────────┘               │
└─────────────────────────────────────┘
```

## intern() Method

```java
/**
 * intern() adds String to pool if not already present
 * Returns reference from pool
 */

String s1 = "Hello";
String s2 = new String("Hello");
String s3 = s2.intern();

System.out.println(s1 == s2);  // false (different objects)
System.out.println(s1 == s3);  // true (both from pool)

// Practical use case: Memory optimization for duplicate strings
List<String> usernames = new ArrayList<>();
for (String username : database.getAllUsernames()) {
    usernames.add(username.intern());  // Reuse if duplicate
}
```

## Concatenation and String Pool

```java
// Compile-time concatenation → String Pool
String s1 = "Hello" + "World";     // "HelloWorld" in Pool
String s2 = "HelloWorld";
System.out.println(s1 == s2);      // true

// Runtime concatenation → Heap
String hello = "Hello";
String world = "World";
String s3 = hello + world;         // New object in Heap
System.out.println(s1 == s3);      // false

// Using final → Compile-time constant
final String HELLO = "Hello";
final String WORLD = "World";
String s4 = HELLO + WORLD;         // "HelloWorld" in Pool
System.out.println(s1 == s4);      // true
```

---

# 3. STRING IMMUTABILITY

## Why Strings are Immutable?

```java
/**
 * Reasons for immutability:
 * 
 * 1. String Pool optimization: Safe to share references
 * 2. Security: Strings used in network connections, file paths
 * 3. Thread-safety: No synchronization needed
 * 4. Hashcode caching: Immutable → hash can be cached
 */

public final class String {
    private final byte[] value;  // Cannot be modified
    // No setter methods
}
```

## Immutability in Action

```java
String original = "Hello";
String modified = original.concat(" World");

System.out.println(original);   // "Hello" (unchanged)
System.out.println(modified);   // "Hello World" (new object)

// All String methods return new String
original.toUpperCase();         // Returns new String
System.out.println(original);   // Still "Hello"

original = original.toUpperCase();  // Must reassign
System.out.println(original);       // "HELLO"
```

## Benefits of Immutability

### 1. Thread-Safety

```java
public class ThreadSafeExample {
    private String sharedString = "Shared Data";
    
    // No synchronization needed
    public String getData() {
        return sharedString;  // Safe to return reference
    }
    
    public void updateData(String newData) {
        sharedString = newData;  // Only reference changes
    }
}
```

### 2. Hashcode Caching

```java
public final class String {
    private int hash;  // Cached hashcode
    
    public int hashCode() {
        int h = hash;
        if (h == 0 && value.length > 0) {
            h = calculateHash();  // Calculate once
            hash = h;             // Cache it
        }
        return h;
    }
}

// HashMap/HashSet performance benefit
Map<String, User> userMap = new HashMap<>();
userMap.put("john", user);  // hashCode() cached
```

### 3. Security

```java
// Immutability prevents security vulnerabilities
public class SecurityExample {
    
    public void authenticateUser(String username, String password) {
        // username and password cannot be changed by malicious code
        if (isValid(username, password)) {
            grantAccess();
        }
    }
    
    public void openFile(String filePath) {
        // filePath cannot be changed to access unauthorized files
        File file = new File(filePath);
    }
}
```

## Memory Impact of Immutability

```java
// ❌ BAD: Creates many String objects
String result = "";
for (int i = 0; i < 10000; i++) {
    result += i;  // Creates new String each iteration!
}
// Creates 10,000 String objects → GC pressure

// ✅ GOOD: Use mutable StringBuilder
StringBuilder sb = new StringBuilder();
for (int i = 0; i < 10000; i++) {
    sb.append(i);  // Modifies same object
}
String result = sb.toString();  // Single final String
```

---

# 4. STRINGBUILDER VS STRINGBUFFER

## Comparison Table

| **Aspect** | **String** | **StringBuilder** | **StringBuffer** |
|------------|------------|-------------------|------------------|
| **Mutability** | Immutable | Mutable | Mutable |
| **Thread-Safe** | Yes | No | Yes (synchronized) |
| **Performance** | Slow for concatenation | Fast | Slower than StringBuilder |
| **Use Case** | Fixed strings | Single-threaded manipulation | Multi-threaded manipulation |
| **Memory** | Creates new objects | Reuses same object | Reuses same object |
| **Since** | Java 1.0 | Java 5 | Java 1.0 |

## StringBuilder

```java
// StringBuilder - mutable, NOT thread-safe, fast
StringBuilder sb = new StringBuilder();
sb.append("Hello");
sb.append(" ");
sb.append("World");
String result = sb.toString();  // "Hello World"

// Chaining methods
sb.append("!").append(" ").append("Java");

// Capacity management
StringBuilder sb2 = new StringBuilder(100);  // Initial capacity
System.out.println(sb2.capacity());          // 100

// Common methods
sb.insert(5, ",");              // Insert at index
sb.delete(5, 6);                // Delete range [5, 6)
sb.deleteCharAt(5);             // Delete single char
sb.replace(0, 5, "Hi");         // Replace range
sb.reverse();                   // Reverse content
sb.setLength(5);                // Truncate or extend
```

## StringBuffer

```java
// StringBuffer - mutable, thread-safe, synchronized methods
StringBuffer sbuf = new StringBuffer("Hello");
sbuf.append(" World");

// Thread-safe example
public class ThreadSafeAppender {
    private StringBuffer buffer = new StringBuffer();
    
    public synchronized void append(String text) {
        buffer.append(text);  // Already synchronized internally
    }
    
    public String getResult() {
        return buffer.toString();
    }
}
```

## Performance Comparison

```java
// Benchmark: Concatenate 10,000 strings
public class StringPerformanceTest {
    
    private static final int ITERATIONS = 10000;
    
    // String concatenation: ~5000ms
    public static String usingString() {
        String result = "";
        for (int i = 0; i < ITERATIONS; i++) {
            result += i;  // O(n²) - creates n*(n+1)/2 objects
        }
        return result;
    }
    
    // StringBuilder: ~5ms (1000x faster!)
    public static String usingStringBuilder() {
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < ITERATIONS; i++) {
            sb.append(i);  // O(n) - reuses same object
        }
        return sb.toString();
    }
    
    // StringBuffer: ~10ms (slower than StringBuilder due to sync)
    public static String usingStringBuffer() {
        StringBuffer sb = new StringBuffer();
        for (int i = 0; i < ITERATIONS; i++) {
            sb.append(i);
        }
        return sb.toString();
    }
}
```

## When to Use Each

```java
/**
 * Use String when:
 * - Value won't change
 * - Need to use as HashMap key
 * - Few concatenations (1-2)
 */
String name = "John Doe";
String email = "john@example.com";

/**
 * Use StringBuilder when:
 * - Many string manipulations (loops)
 * - Single-threaded context
 * - Need performance
 */
public String generateReport(List<String> lines) {
    StringBuilder report = new StringBuilder();
    for (String line : lines) {
        report.append(line).append("\n");
    }
    return report.toString();
}

/**
 * Use StringBuffer when:
 * - Multi-threaded environment
 * - Shared mutable string across threads
 */
public class LogAggregator {
    private StringBuffer logs = new StringBuffer();
    
    public void addLog(String message) {
        logs.append(message).append("\n");  // Thread-safe
    }
}
```

---

# 5. STRING PERFORMANCE

## Concatenation Performance

```java
// ❌ WORST: String concatenation in loop
public String badConcatenation(String[] words) {
    String result = "";
    for (String word : words) {
        result += word + " ";  // O(n²) time complexity
    }
    return result;
}

// ✅ BEST: StringBuilder
public String goodConcatenation(String[] words) {
    StringBuilder sb = new StringBuilder();
    for (String word : words) {
        sb.append(word).append(" ");
    }
    return sb.toString();
}

// ✅ BEST: String.join() for simple cases
public String simpleConcatenation(String[] words) {
    return String.join(" ", words);  // Internally uses StringBuilder
}
```

## Compiler Optimization

```java
// Compiler optimizes single-line concatenation
String s1 = "Hello" + " " + "World";
// Compiled to:
String s1 = "Hello World";  // Constant folding

// Compiler uses StringBuilder for expression
String hello = "Hello";
String world = "World";
String s2 = hello + " " + world;
// Compiled to (approximately):
StringBuilder temp = new StringBuilder();
temp.append(hello).append(" ").append(world);
String s2 = temp.toString();

// ❌ But NOT in loops!
String result = "";
for (int i = 0; i < 100; i++) {
    result += i;  // Creates NEW StringBuilder each iteration!
}
```

## Memory Optimization

```java
// String interning for memory savings
public class MemoryOptimization {
    
    // Scenario: Loading millions of duplicate strings
    public List<String> loadUsernames(Database db) {
        List<String> usernames = new ArrayList<>();
        
        // Without interning: Each duplicate creates new object
        for (User user : db.getAllUsers()) {
            usernames.add(user.getUsername());
        }
        
        // With interning: Duplicates share same object
        for (User user : db.getAllUsers()) {
            usernames.add(user.getUsername().intern());
        }
        
        return usernames;
    }
}

// Caution: intern() has cost
// Use only when:
// 1. Many duplicate strings
// 2. Strings live long in memory
// 3. Memory is more critical than CPU
```

---

# 6. STRING METHODS DEEP DIVE

## Common Methods

```java
String str = "  Hello World  ";

// Length
str.length();                    // 15

// Character access
str.charAt(2);                   // 'H'
str.toCharArray();               // char[] array

// Whitespace handling
str.trim();                      // "Hello World" (removes leading/trailing)
str.strip();                     // "Hello World" (Java 11+, handles Unicode)
str.stripLeading();              // "Hello World  " (Java 11+)
str.stripTrailing();             // "  Hello World" (Java 11+)

// Case conversion
str.toUpperCase();               // "  HELLO WORLD  "
str.toLowerCase();               // "  hello world  "

// Substring
str.substring(2);                // "Hello World  " (from index 2)
str.substring(2, 7);             // "Hello" (from 2 to 6, end exclusive)

// Search
str.indexOf("World");            // 8
str.lastIndexOf("l");            // 11
str.contains("World");           // true
str.startsWith("  Hello");       // true
str.endsWith("World  ");         // true

// Replace
str.replace("World", "Java");    // "  Hello Java  "
str.replaceAll("\\s+", "-");    // "--Hello-World--"
str.replaceFirst("l", "L");      // "  HeLlo World  "

// Split
str.trim().split(" ");           // ["Hello", "World"]
str.split("\\s+");               // ["", "Hello", "World"]

// Matching
str.matches(".*World.*");        // true

// Repeat (Java 11+)
"abc".repeat(3);                 // "abcabcabc"

// isEmpty() and isBlank()
"".isEmpty();                    // true
"  ".isEmpty();                  // false
"  ".isBlank();                  // true (Java 11+)
```

## String Formatting

```java
// String.format()
String name = "John";
int age = 30;
double salary = 75000.50;

String.format("Name: %s", name);                    // "Name: John"
String.format("Age: %d", age);                      // "Age: 30"
String.format("Salary: $%.2f", salary);             // "Salary: $75000.50"
String.format("%s is %d years old", name, age);     // "John is 30 years old"

// Width and alignment
String.format("|%10s|", "text");                    // "|      text|"
String.format("|%-10s|", "text");                   // "|text      |"
String.format("%08d", 42);                          // "00000042"

// Formatted output (Java 13+)
String formatted = """
    Name: %s
    Age: %d
    Salary: $%.2f
    """.formatted(name, age, salary);
```

---

# 7. REGULAR EXPRESSIONS

## Basic Regex Patterns

```java
String text = "Hello 123 World 456";

// matches() - entire string must match
text.matches("\\d+");              // false
"12345".matches("\\d+");           // true

// replaceAll() with regex
text.replaceAll("\\d+", "NUM");    // "Hello NUM World NUM"

// split() with regex
text.split("\\s+");                // ["Hello", "123", "World", "456"]

// Pattern and Matcher
Pattern pattern = Pattern.compile("\\d+");
Matcher matcher = pattern.matcher(text);

while (matcher.find()) {
    System.out.println(matcher.group());  // "123", "456"
}
```

## Common Patterns

```java
// Email validation
String email = "user@example.com";
boolean valid = email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$");

// Phone number
String phone = "123-456-7890";
boolean validPhone = phone.matches("\\d{3}-\\d{3}-\\d{4}");

// URL
String url = "https://example.com";
boolean validUrl = url.matches("^https?://.*");

// Extract groups
String date = "2024-03-17";
Pattern datePattern = Pattern.compile("(\\d{4})-(\\d{2})-(\\d{2})");
Matcher dateMatcher = datePattern.matcher(date);
if (dateMatcher.matches()) {
    String year = dateMatcher.group(1);   // "2024"
    String month = dateMatcher.group(2);  // "03"
    String day = dateMatcher.group(3);    // "17"
}
```

---

# 8. STRING ENCODING

```java
// Default encoding (UTF-8 in most systems)
String text = "Hello";
byte[] bytes = text.getBytes();  // Platform default

// Specific encoding
byte[] utf8Bytes = text.getBytes(StandardCharsets.UTF_8);
byte[] utf16Bytes = text.getBytes(StandardCharsets.UTF_16);

// Decode bytes to String
String decoded = new String(utf8Bytes, StandardCharsets.UTF_8);

// Handle special characters
String unicode = "Hello 你好 🌍";
System.out.println(unicode.length());  // Character count
```

---

# 9. INTERVIEW QUESTIONS

## Q1: Why are Strings immutable in Java?

**Answer:**

1. **String Pool optimization**: Safe to share references
2. **Security**: Strings used in file paths, network connections, database queries
3. **Thread-safety**: No synchronization needed
4. **Hashcode caching**: Immutable → hash can be cached for HashMap/HashSet
5. **Class loading**: Class names are Strings

```java
// Security example
public void openFile(String filePath) {
    if (isAuthorized(filePath)) {
        // If String were mutable, filePath could be changed here!
        File file = new File(filePath);
    }
}
```

---

## Q2: What is String Pool? Where is it located?

**Answer:**

**String Pool** is a special memory region that stores String literals to avoid duplicates.

**Location:**
- **Java 6 and earlier**: PermGen space (limited, can cause OutOfMemoryError)
- **Java 7+**: Heap memory (collected by GC)

```java
String s1 = "Hello";  // Created in String Pool
String s2 = "Hello";  // Reuses s1
System.out.println(s1 == s2);  // true
```

---

## Q3: Difference between String, StringBuilder, and StringBuffer?

| **Feature** | **String** | **StringBuilder** | **StringBuffer** |
|-------------|------------|-------------------|------------------|
| **Mutable** | No | Yes | Yes |
| **Thread-Safe** | Yes | No | Yes |
| **Performance** | Slow | Fast | Medium |
| **Use Case** | Immutable text | Single-threaded manipulation | Multi-threaded manipulation |

```java
// String: Immutable
String s = "Hello";
s.concat(" World");  // Returns new String, s unchanged

// StringBuilder: Mutable, fast
StringBuilder sb = new StringBuilder("Hello");
sb.append(" World");  // Modifies sb

// StringBuffer: Mutable, thread-safe
StringBuffer sbuf = new StringBuffer("Hello");
sbuf.append(" World");  // Synchronized method
```

---

## Q4: How does == differ from equals() for Strings?

**Answer:**

- **==**: Compares **references** (memory addresses)
- **equals()**: Compares **content** (character sequences)

```java
String s1 = "Hello";
String s2 = "Hello";
String s3 = new String("Hello");

s1 == s2;         // true (same reference in String Pool)
s1 == s3;         // false (s3 is different object in Heap)
s1.equals(s3);    // true (same content)
```

---

## Q5: What does intern() do?

**Answer:**

`intern()` adds the String to the String Pool (if not present) and returns the reference from the pool.

```java
String s1 = "Hello";
String s2 = new String("Hello");
String s3 = s2.intern();

System.out.println(s1 == s2);  // false
System.out.println(s1 == s3);  // true (both from pool)
```

**Use case**: Memory optimization when loading many duplicate strings from database/file.

---

## Q6: Why is String class final?

**Answer:**

1. **Security**: Prevents malicious subclass from changing behavior
2. **Immutability guarantee**: Subclass can't add mutable state
3. **Performance**: JVM can optimize final classes
4. **String Pool**: Safe to share references

```java
// If String weren't final:
class MaliciousString extends String {
    // Could override methods and break security
}
```

---

## Q7: How many objects are created?

```java
String s1 = "Hello";           // 1 object (String Pool)
String s2 = "Hello";           // 0 objects (reuses s1)
String s3 = new String("Hello"); // 2 objects (1 in Pool + 1 in Heap)
```

**Answer:**
- `s1`: 1 object in String Pool
- `s2`: 0 new objects, reuses s1
- `s3`: 2 objects total (1 in Pool if first occurrence, 1 in Heap)

---

## Q8: Performance: String vs StringBuilder?

**Answer:**

**String concatenation in loop**: O(n²) time
- Each concatenation creates new String
- Copies all previous characters

**StringBuilder**: O(n) time
- Reuses same buffer
- Grows when needed (doubles capacity)

```java
// String: ~5000ms for 10,000 iterations
String result = "";
for (int i = 0; i < 10000; i++) {
    result += i;  // Creates 10,000 String objects
}

// StringBuilder: ~5ms (1000x faster!)
StringBuilder sb = new StringBuilder();
for (int i = 0; i < 10000; i++) {
    sb.append(i);
}
```

---

# 10. INTERVIEW TRAPS

## Trap 1: String concatenation in loops

```java
// ❌ WRONG: Creates n String objects
public String concatenate(List<String> words) {
    String result = "";
    for (String word : words) {
        result += word;  // O(n²)
    }
    return result;
}

// ✅ CORRECT: Use StringBuilder
public String concatenate(List<String> words) {
    StringBuilder sb = new StringBuilder();
    for (String word : words) {
        sb.append(word);  // O(n)
    }
    return sb.toString();
}
```

---

## Trap 2: Comparing with ==

```java
// ❌ WRONG: Comparing references
String user Input = getUserInput();
if (userName == "admin") {  // May fail!
    grantAccess();
}

// ✅ CORRECT: Compare content
if ("admin".equals(userName)) {  // Safe (null-safe pattern)
    grantAccess();
}
```

---

## Trap 3: Modifying String in place

```java
// ❌ MISCONCEPTION: Strings are mutable
String str = "Hello";
str.toUpperCase();  // Returns new String, str unchanged!
System.out.println(str);  // Still "Hello"

// ✅ CORRECT: Reassign result
str = str.toUpperCase();
System.out.println(str);  // "HELLO"
```

---

## Trap 4: substring() memory leak (Java 6)

```java
// Java 6: substring() shared char[] with original
String large = readLargeFile();  // 1GB
String small = large.substring(0, 10);  // Still holds reference to 1GB!
large = null;  // 1GB not collected!

// Java 7+: substring() creates copy (no leak)
String small = large.substring(0, 10);  // Independent copy
large = null;  // 1GB can be collected
```

---

# 11. CODING PROBLEMS

## Problem 1: Reverse Words in String

```java
/**
 * Input: "The sky is blue"
 * Output: "blue is sky The"
 */
public String reverseWords(String s) {
    // Trim and split by whitespace
    String[] words = s.trim().split("\\s+");
    
    // Reverse array
    int left = 0, right = words.length - 1;
    while (left < right) {
        String temp = words[left];
        words[left] = words[right];
        words[right] = temp;
        left++;
        right--;
    }
    
    return String.join(" ", words);
}

// Alternative: Using Collections
public String reverseWordsAlt(String s) {
    List<String> words = Arrays.asList(s.trim().split("\\s+"));
    Collections.reverse(words);
    return String.join(" ", words);
}
```

---

## Problem 2: Check if Strings are Anagrams

```java
/**
 * Input: s1 = "listen", s2 = "silent"
 * Output: true
 */
public boolean isAnagram(String s1, String s2) {
    if (s1.length() != s2.length()) {
        return false;
    }
    
    // Sort and compare
    char[] chars1 = s1.toCharArray();
    char[] chars2 = s2.toCharArray();
    Arrays.sort(chars1);
    Arrays.sort(chars2);
    
    return Arrays.equals(chars1, chars2);
}

// Optimized: Using frequency map
public boolean isAnagramOptimized(String s1, String s2) {
    if (s1.length() != s2.length()) return false;
    
    int[] counts = new int[26];
    for (int i = 0; i < s1.length(); i++) {
        counts[s1.charAt(i) - 'a']++;
        counts[s2.charAt(i) - 'a']--;
    }
    
    for (int count : counts) {
        if (count != 0) return false;
    }
    return true;
}
```

---

## Problem 3: First Non-Repeating Character

```java
/**
 * Input: "leetcode"
 * Output: 'l'
 */
public char firstNonRepeatingChar(String s) {
    // Count frequency
    Map<Character, Integer> freq = new LinkedHashMap<>();
    for (char c : s.toCharArray()) {
        freq.put(c, freq.getOrDefault(c, 0) + 1);
    }
    
    // Find first with frequency 1
    for (Map.Entry<Character, Integer> entry : freq.entrySet()) {
        if (entry.getValue() == 1) {
            return entry.getKey();
        }
    }
    
    return '_';  // Not found
}
```

---

## Problem 4: Longest Palindromic Substring

```java
/**
 * Input: "babad"
 * Output: "bab" or "aba"
 */
public String longestPalindrome(String s) {
    if (s == null || s.length() < 2) return s;
    
    int start = 0, maxLen = 0;
    
    for (int i = 0; i < s.length(); i++) {
        // Odd length palindromes
        int len1 = expandAroundCenter(s, i, i);
        // Even length palindromes
        int len2 = expandAroundCenter(s, i, i + 1);
        
        int len = Math.max(len1, len2);
        if (len > maxLen) {
            maxLen = len;
            start = i - (len - 1) / 2;
        }
    }
    
    return s.substring(start, start + maxLen);
}

private int expandAroundCenter(String s, int left, int right) {
    while (left >= 0 && right < s.length() && s.charAt(left) == s.charAt(right)) {
        left--;
        right++;
    }
    return right - left - 1;
}
```

---

## Problem 5: String Compression

```java
/**
 * Input: "aabcccccaaa"
 * Output: "a2b1c5a3"
 */
public String compress(String s) {
    StringBuilder sb = new StringBuilder();
    int count = 1;
    
    for (int i = 1; i <= s.length(); i++) {
        if (i < s.length() && s.charAt(i) == s.charAt(i - 1)) {
            count++;
        } else {
            sb.append(s.charAt(i - 1)).append(count);
            count = 1;
        }
    }
    
    // Return compressed only if shorter
    return sb.length() < s.length() ? sb.toString() : s;
}
```

---

# 12. SUMMARY & QUICK REFERENCE

## Key Concepts

```java
// String Pool
String s1 = "Hello";              // Pool
String s2 = new String("Hello");  // Heap
String s3 = s2.intern();          // Pool

// Immutability
String s = "Hello";
s.concat(" World");  // Returns new String, s unchanged

// Performance
// BAD: String concatenation in loop
// GOOD: StringBuilder

// Comparison
s1 == s2;         // Reference comparison
s1.equals(s2);    // Content comparison
```

## Quick Reference

| **Operation** | **Method** | **Example** |
|---------------|------------|-------------|
| Length | `length()` | `"Hello".length()` → 5 |
| Get character | `charAt(i)` | `"Hello".charAt(0)` → 'H' |
| Substring | `substring(start, end)` | `"Hello".substring(1, 4)` → "ell" |
| Search | `indexOf(str)` | `"Hello".indexOf("ll")` → 2 |
| Replace | `replace(old, new)` | `"Hello".replace("l", "x")` → "Hexxo" |
| Split | `split(regex)` | `"a,b,c".split(",")` → ["a","b","c"] |
| Join | `String.join(delim, arr)` | `String.join(",", arr)` |
| Format | `String.format(fmt, args)` | `String.format("Age: %d", 30)` |

## Best Practices

```
1. Use String literals instead of new String()
2. Use StringBuilder for concatenation in loops
3. Use equals() for comparison, not ==
4. Consider intern() for duplicate-heavy scenarios
5. Use String.join() or StringBuilder for building strings
6. Cache hashCode for frequently used Strings
7. Use text blocks (Java 13+) for multiline strings
```

---

**END OF JAVA STRINGS INTERVIEW GUIDE**

Master String internals, String Pool, and manipulation techniques for confident interviews!