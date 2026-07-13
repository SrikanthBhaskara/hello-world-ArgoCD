# Java Strings & Text Processing

## String Basics

### Creating Strings

```java
// String literals
String str1 = "Hello";

// new keyword
String str2 = new String("Hello");

// Character array
char[] chars = {'H', 'e', 'l', 'l', 'o'};
String str3 = new String(chars);

// Empty strings
String empty1 = "";
String empty2 = new String();
```

### String Pool

```java
// String literals are stored in pool
String s1 = "Hello";
String s2 = "Hello";
System.out.println(s1 == s2);  // true (same reference in pool)

// new creates separate object
String s3 = new String("Hello");
System.out.println(s1 == s3);  // false (different objects)

// intern() adds to pool
String s4 = s3.intern();
System.out.println(s1 == s4);  // true (now same reference)
```

## String Immutability

```java
String str = "Hello";
str.concat(" World");        // Creates new string
System.out.println(str);     // Still "Hello" (unchanged)

str = str.concat(" World");  // Reassign to capture new string
System.out.println(str);     // "Hello World"

// Strings are immutable - cannot be changed after creation
char[] chars = str.toCharArray();
chars[0] = 'h';             // Changes array, not original string
System.out.println(str);     // Still "Hello World"
```

## String Methods

### Length and Characters

```java
String str = "Hello World";

// Length
int len = str.length();  // 11

// Character at index
char ch = str.charAt(0);  // 'H'
char last = str.charAt(str.length() - 1);  // 'd'

// Get all characters
char[] chars = str.toCharArray();

// Code point (Unicode)
int codePoint = str.codePointAt(0);
```

### Comparison

```java
String s1 = "Hello";
String s2 = "hello";
String s3 = "Hello";

// equals() - content comparison
s1.equals(s3);           // true
s1.equals(s2);           // false

// equalsIgnoreCase()
s1.equalsIgnoreCase(s2); // true

// compareTo() - lexicographic comparison
s1.compareTo(s3);        // 0 (equal)
s1.compareTo(s2);        // negative (s1 < s2)
"apple".compareTo("banana");  // negative

// compareToIgnoreCase()
s1.compareToIgnoreCase(s2);  // 0
```

### Searching

```java
String str = "Hello World Hello";

// indexOf()
int index = str.indexOf("World");     // 6
int index2 = str.indexOf("Hello");    // 0 (first occurrence)
int index3 = str.indexOf("Hello", 1); // 12 (from index 1)
int notFound = str.indexOf("Java");   // -1

// lastIndexOf()
int last = str.lastIndexOf("Hello");  // 12

// contains()
boolean has = str.contains("World");  // true

// startsWith() / endsWith()
str.startsWith("Hello");  // true
str.endsWith("World");    // false
str.endsWith("Hello");    // true
```

### Modification

```java
String str = "  Hello World  ";

// Case conversion
str.toUpperCase();  // "  HELLO WORLD  "
str.toLowerCase();  // "  hello world  "

// Trim whitespace
str.trim();         // "Hello World"
str.strip();        // "Hello World" (Java 11+, handles Unicode)

// Substring
str.substring(7);       // "World  " (from index 7)
str.substring(2, 7);    // "Hello" (from 2 to 6, end exclusive)

// Replace
str.replace("World", "Java");        // "  Hello Java  "
str.replaceAll("\\s+", "-");        // "--Hello-World--"
str.replaceFirst("l", "L");         // "  HeLlo World  "

// Split
String csv = "apple,banana,orange";
String[] fruits = csv.split(",");    // ["apple", "banana", "orange"]
String[] words = str.trim().split(" ");  // ["Hello", "World"]
```

### StringBuilder and StringBuffer

```java
// StringBuilder - mutable, not thread-safe, faster
StringBuilder sb = new StringBuilder();
sb.append("Hello");
sb.append(" ");
sb.append("World");
String result = sb.toString();  // "Hello World"

// Chaining
sb.append("!").append(" ").append("Java");

// Other methods
sb.insert(5, ",");         // Insert at index
sb.delete(5, 6);          // Delete range
sb.deleteCharAt(5);       // Delete single character
sb.replace(6, 11, "Java"); // Replace range
sb.reverse();             // Reverse string
sb.setLength(5);          // Truncate or extend

// StringBuffer - mutable, thread-safe, slower
StringBuffer sbuf = new StringBuffer("Hello");
sbuf.append(" World");
```

### StringBuilder vs String

```java
// BAD: Creates many String objects
String result = "";
for (int i = 0; i < 1000; i++) {
    result += i;  // Creates new String each iteration!
}

// GOOD: Uses single mutable object
StringBuilder sb = new StringBuilder();
for (int i = 0; i < 1000; i++) {
    sb.append(i);
}
String result = sb.toString();
```

## Formatting

### String.format()

```java
// Basic formatting
String name = "Alice";
int age = 25;
String formatted = String.format("Name: %s, Age: %d", name, age);

// Format specifiers
%s    // String
%d    // Integer (decimal)
%f    // Floating point
%c    // Character
%b    // Boolean
%n    // Newline (platform-independent)

// Width and precision
String.format("%10s", "text");      // "      text" (width 10)
String.format("%-10s", "text");     // "text      " (left-aligned)
String.format("%.2f", 3.14159);     // "3.14" (2 decimal places)
String.format("%,d", 1000000);      // "1,000,000" (with commas)
String.format("%08d", 42);          // "00000042" (zero-padded)
```

### System.out.printf()

```java
String name = "Bob";
int score = 95;
double percentage = 95.5;

System.out.printf("Name: %s%n", name);
System.out.printf("Score: %d%n", score);
System.out.printf("Percentage: %.1f%%%n", percentage);  // 95.5%

// Table formatting
System.out.printf("%-10s %5d %8.2f%n", "Alice", 95, 95.5);
System.out.printf("%-10s %5d %8.2f%n", "Bob", 87, 87.3);
```

## Advanced String Operations

### Joining Strings

```java
// String.join() (Java 8+)
String joined = String.join(", ", "apple", "banana", "orange");
// "apple, banana, orange"

// With collection
List<String> list = Arrays.asList("a", "b", "c");
String result = String.join("-", list);  // "a-b-c"

// StringJoiner
StringJoiner joiner = new StringJoiner(", ", "[", "]");
joiner.add("apple").add("banana").add("orange");
System.out.println(joiner);  // [apple, banana, orange]
```

### Regular Expressions

```java
String text = "Hello 123 World 456";

// matches() - entire string must match
text.matches("\\d+");           // false (not all digits)
"12345".matches("\\d+");        // true

// replaceAll() with regex
text.replaceAll("\\d+", "NUM");  // "Hello NUM World NUM"

// split() with regex
String[] parts = text.split("\\s+");  // Split by whitespace

// Pattern and Matcher
Pattern pattern = Pattern.compile("\\d+");
Matcher matcher = pattern.matcher(text);

while (matcher.find()) {
    System.out.println(matcher.group());  // 123, 456
}
```

### Common Regex Patterns

```java
// Validation patterns
String email = "user@example.com";
boolean validEmail = email.matches("^[A-Za-z0-9+_.-]+@(.+)$");

String phone = "123-456-7890";
boolean validPhone = phone.matches("\\d{3}-\\d{3}-\\d{4}");

String url = "https://example.com";
boolean validUrl = url.matches("^https?://.*");

// Extract all digits
String text = "Price: $123.45";
Pattern p = Pattern.compile("\\d+");
Matcher m = p.matcher(text);
while (m.find()) {
    System.out.println(m.group());  // 123, 45
}

// Groups/capture patterns
String date = "2024-03-16";
Pattern datePattern = Pattern.compile("(\\d{4})-(\\d{2})-(\\d{2})");
Matcher dateMatcher = datePattern.matcher(date);
if (dateMatcher.matches()) {
    String year = dateMatcher.group(1);   // 2024
    String month = dateMatcher.group(2);  // 03
    String day = dateMatcher.group(3);    // 16
}
```

## String Utilities

### Checking Empty/Null

```java
public static boolean isEmpty(String str) {
    return str == null || str.isEmpty();
}

public static boolean isBlank(String str) {
    return str == null || str.isBlank();  // Java 11+
}

// Usage
String empty = "";
String blank = "   ";
String nullStr = null;

empty.isEmpty();    // true
blank.isEmpty();    // false
blank.isBlank();    // true (Java 11+)
```

### Padding and Alignment

```java
public class StringUtils {
    public static String padLeft(String str, int length, char pad) {
        return String.format("%" + length + "s", str).replace(' ', pad);
    }
    
    public static String padRight(String str, int length, char pad) {
        return String.format("%-" + length + "s", str).replace(' ', pad);
    }
    
    public static String center(String str, int length) {
        if (str.length() >= length) return str;
        int padSize = (length - str.length()) / 2;
        return " ".repeat(padSize) + str + " ".repeat(length - str.length() - padSize);
    }
}

// Usage
String text = "Hello";
System.out.println(StringUtils.padLeft(text, 10, '0'));   // 00000Hello
System.out.println(StringUtils.padRight(text, 10, '0'));  // Hello00000
System.out.println(StringUtils.center(text, 11));         // "   Hello   "
```

### Reversing Strings

```java
// Method 1: StringBuilder
public static String reverse(String str) {
    return new StringBuilder(str).reverse().toString();
}

// Method 2: Manual
public static String reverseManual(String str) {
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

### Counting Characters

```java
public static int countOccurrences(String str, char ch) {
    int count = 0;
    for (int i = 0; i < str.length(); i++) {
        if (str.charAt(i) == ch) count++;
    }
    return count;
}

// Java 8+ with streams
public static long countChar(String str, char ch) {
    return str.chars().filter(c -> c == ch).count();
}
```

## Practical Examples

### Word Count

```java
public class WordCounter {
    public static int countWords(String text) {
        if (text == null || text.trim().isEmpty()) {
            return 0;
        }
        return text.trim().split("\\s+").length;
    }
    
    public static Map<String, Integer> wordFrequency(String text) {
        Map<String, Integer> freq = new HashMap<>();
        String[] words = text.toLowerCase().split("\\W+");
        for (String word : words) {
            if (!word.isEmpty()) {
                freq.put(word, freq.getOrDefault(word, 0) + 1);
            }
        }
        return freq;
    }
}
```

### Palindrome Check

```java
public static boolean isPalindrome(String str) {
    // Remove non-alphanumeric and convert to lowercase
    str = str.toLowerCase().replaceAll("[^a-z0-9]", "");
    int left = 0, right = str.length() - 1;
    while (left < right) {
        if (str.charAt(left++) != str.charAt(right--)) {
            return false;
        }
    }
    return true;
}

// Test
System.out.println(isPalindrome("A man, a plan, a canal: Panama"));  // true
System.out.println(isPalindrome("race a car"));  // false
```

### Title Case Conversion

```java
public static String toTitleCase(String str) {
    if (str == null || str.isEmpty()) return str;
    
    String[] words = str.toLowerCase().split("\\s+");
    StringBuilder result = new StringBuilder();
    
    for (String word : words) {
        if (!word.isEmpty()) {
            result.append(Character.toUpperCase(word.charAt(0)))
                  .append(word.substring(1))
                  .append(" ");
        }
    }
    
    return result.toString().trim();
}

// "hello world" → "Hello World"
```

### URL Encoding/Decoding

```java
import java.net.URLEncoder;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;

public class UrlUtils {
    public static String encode(String str) {
        return URLEncoder.encode(str, StandardCharsets.UTF_8);
    }
    
    public static String decode(String str) {
        return URLDecoder.decode(str, StandardCharsets.UTF_8);
    }
}

// Usage
String text = "Hello World!";
String encoded = UrlUtils.encode(text);  // "Hello+World%21"
String decoded = UrlUtils.decode(encoded);  // "Hello World!"
```

## Performance Tips

```java
// DON'T: Concatenate in loop
String result = "";
for (int i = 0; i < 1000; i++) {
    result += i;  // Creates 1000 String objects!
}

// DO: Use StringBuilder
StringBuilder sb = new StringBuilder();
for (int i = 0; i < 1000; i++) {
    sb.append(i);
}
String result = sb.toString();

// DON'T: Multiple replace calls
String text = str.replace("a", "").replace("e", "").replace("i", "");

// DO: Single replaceAll with regex
String text = str.replaceAll("[aei]", "");

// Reuse Pattern for multiple operations
Pattern pattern = Pattern.compile("\\d+");
for (String line : lines) {
    Matcher matcher = pattern.matcher(line);
    // Process...
}
```

## Quick Reference

```java
// Creation
String str = "text";

// Length
int len = str.length();

// Access
char ch = str.charAt(0);

// Comparison
str.equals("text");
str.equalsIgnoreCase("TEXT");
str.compareTo("text");

// Search
str.indexOf("ex");
str.contains("ex");
str.startsWith("te");
str.endsWith("xt");

// Modification
str.toUpperCase();
str.toLowerCase();
str.trim();
str.substring(1, 3);
str.replace("t", "T");

// Split/Join
String[] parts = str.split(",");
String joined = String.join(",", parts);

// Mutable strings
StringBuilder sb = new StringBuilder();
sb.append("text").insert(0, "pre");
```

---

**Previous**: [← Encapsulation](java-07-encapsulation.md) | **Next**: [Collections →](java-09-collections.md)
