# Java Basics

## Variables and Data Types

### Primitive Data Types

Java has 8 primitive data types:

```java
// Integer types
byte myByte = 127;           // 8-bit: -128 to 127
short myShort = 32000;       // 16-bit: -32,768 to 32,767
int myInt = 2147483647;      // 32-bit: -2^31 to 2^31-1
long myLong = 9223372036854775807L; // 64-bit: -2^63 to 2^63-1

// Floating-point types
float myFloat = 3.14f;       // 32-bit: ~7 decimal digits
double myDouble = 3.14159;   // 64-bit: ~15 decimal digits

// Character type
char myChar = 'A';           // 16-bit Unicode character

// Boolean type
boolean myBoolean = true;    // true or false
```

### Reference Types

```java
// String (most common reference type)
String name = "Alice";
String empty = "";
String nullString = null;

// Arrays
int[] numbers = {1, 2, 3, 4, 5};
String[] names = new String[10];

// Objects
Scanner scanner = new Scanner(System.in);
ArrayList<Integer> list = new ArrayList<>();
```

### Variable Declaration and Initialization

```java
// Declaration
int age;

// Initialization
age = 25;

// Declaration + Initialization
int score = 100;

// Multiple variables
int x = 1, y = 2, z = 3;

// Final variables (constants)
final double PI = 3.14159;
final int MAX_USERS = 100;
```

### Type Conversion

```java
// Implicit conversion (widening - automatic)
int myInt = 100;
long myLong = myInt;        // int to long
double myDouble = myInt;    // int to double

// Explicit conversion (narrowing - manual casting)
double d = 9.78;
int i = (int) d;            // i = 9 (decimal part lost)

long l = 100L;
int x = (int) l;            // Possible data loss if l > Integer.MAX_VALUE

// String to number
String str = "123";
int num = Integer.parseInt(str);
double dbl = Double.parseDouble("3.14");

// Number to String
String s1 = String.valueOf(123);
String s2 = Integer.toString(456);
String s3 = "" + 789;       // Concatenation trick
```

## Operators

### Arithmetic Operators

```java
int a = 10, b = 3;

int sum = a + b;        // 13 (Addition)
int diff = a - b;       // 7  (Subtraction)
int product = a * b;    // 30 (Multiplication)
int quotient = a / b;   // 3  (Division - integer division)
int remainder = a % b;  // 1  (Modulus - remainder)

// Double division
double result = (double) a / b;  // 3.3333...

// Increment and Decrement
int x = 5;
x++;    // Post-increment: x = 6
++x;    // Pre-increment: x = 7
x--;    // Post-decrement: x = 6
--x;    // Pre-decrement: x = 5

// Difference between pre and post
int y = 10;
int z = y++;    // z = 10, y = 11 (use then increment)
int w = ++y;    // w = 12, y = 12 (increment then use)
```

### Assignment Operators

```java
int x = 10;

x += 5;     // x = x + 5  → x = 15
x -= 3;     // x = x - 3  → x = 12
x *= 2;     // x = x * 2  → x = 24
x /= 4;     // x = x / 4  → x = 6
x %= 4;     // x = x % 4  → x = 2
```

### Comparison Operators

```java
int a = 5, b = 10;

boolean result;

result = (a == b);   // false (equal to)
result = (a != b);   // true  (not equal to)
result = (a > b);    // false (greater than)
result = (a < b);    // true  (less than)
result = (a >= b);   // false (greater than or equal)
result = (a <= b);   // true  (less than or equal)
```

### Logical Operators

```java
boolean x = true, y = false;

boolean result;

result = x && y;    // false (AND - both must be true)
result = x || y;    // true  (OR - at least one must be true)
result = !x;        // false (NOT - inverts the value)

// Short-circuit evaluation
int a = 5, b = 0;
if (b != 0 && a / b > 2) {  // b != 0 is false, so a/b never evaluated
    // Avoids division by zero
}
```

### Bitwise Operators

```java
int a = 5;      // Binary: 0101
int b = 3;      // Binary: 0011

int and = a & b;    // 1 (0001) - AND
int or = a | b;     // 7 (0111) - OR
int xor = a ^ b;    // 6 (0110) - XOR
int not = ~a;       // -6 (inverts all bits)

int leftShift = a << 1;   // 10 (1010) - shift left
int rightShift = a >> 1;  // 2  (0010) - shift right
```

### Ternary Operator

```java
// Syntax: condition ? valueIfTrue : valueIfFalse

int age = 20;
String status = (age >= 18) ? "Adult" : "Minor";

int max = (a > b) ? a : b;

// Nested ternary (not recommended - hard to read)
String grade = (score >= 90) ? "A" :
               (score >= 80) ? "B" :
               (score >= 70) ? "C" : "F";
```

## Input and Output

### Console Output

```java
// println - prints with newline
System.out.println("Hello World");
System.out.println(123);
System.out.println(3.14);

// print - no newline
System.out.print("Hello ");
System.out.print("World");  // Output: Hello World

// printf - formatted output
System.out.printf("Name: %s, Age: %d%n", "Alice", 25);
System.out.printf("Price: $%.2f%n", 19.99);

// Format specifiers
%s    // String
%d    // Integer
%f    // Float/Double
%.2f  // Float with 2 decimal places
%n    // Newline (platform independent)
%c    // Character
%b    // Boolean
```

### Console Input

```java
import java.util.Scanner;

public class InputExample {
    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        
        // Read different types
        System.out.print("Enter your name: ");
        String name = scanner.nextLine();
        
        System.out.print("Enter age: ");
        int age = scanner.nextInt();
        
        System.out.print("Enter salary: ");
        double salary = scanner.nextDouble();
        
        System.out.print("Continue? (true/false): ");
        boolean cont = scanner.nextBoolean();
        
        // Always close the scanner
        scanner.close();
        
        System.out.println("Name: " + name);
        System.out.println("Age: " + age);
    }
}
```

### Input Pitfalls

```java
Scanner scanner = new Scanner(System.in);

// Problem: mixing nextInt() with nextLine()
System.out.print("Enter number: ");
int num = scanner.nextInt();        // Reads number but leaves newline

System.out.print("Enter name: ");
String name = scanner.nextLine();   // Reads the leftover newline!

// Solution: consume the newline
scanner.nextLine();                 // Consume leftover newline
System.out.print("Enter name: ");
name = scanner.nextLine();          // Now works correctly
```

## Strings

### String Basics

```java
// String creation
String str1 = "Hello";              // String literal
String str2 = new String("Hello");  // New object
String str3 = "";                   // Empty string
String str4 = null;                 // Null reference

// String concatenation
String fullName = "John" + " " + "Doe";
String message = "Age: " + 25;      // Auto-converts to string

// String length
int len = "Hello".length();         // 5

// String comparison
String a = "hello";
String b = "hello";
String c = "Hello";

boolean result = (a == b);          // true (same literal)
boolean result2 = a.equals(b);      // true (same content)
boolean result3 = a.equals(c);      // false (case-sensitive)
boolean result4 = a.equalsIgnoreCase(c);  // true
```

### Common String Methods

```java
String text = "  Hello World  ";

// Case conversion
text.toUpperCase();         // "  HELLO WORLD  "
text.toLowerCase();         // "  hello world  "

// Trimming
text.trim();                // "Hello World" (removes leading/trailing spaces)
text.strip();               // "Hello World" (Java 11+, handles Unicode)

// Substring
text.substring(7);          // "World  " (from index 7)
text.substring(2, 7);       // "Hello" (from 2 to 6, end exclusive)

// Character access
char ch = text.charAt(2);   // 'H'
int index = text.indexOf("World");  // 8
int lastIndex = text.lastIndexOf("o");  // 9

// Contains and checking
text.contains("World");     // true
text.startsWith("  Hello"); // true
text.endsWith("  ");        // true
text.isEmpty();             // false
text.isBlank();             // false (Java 11+)

// Replace
text.replace("World", "Java");      // "  Hello Java  "
text.replaceAll("\\s+", "-");       // "--Hello-World--"

// Split
String csv = "apple,banana,orange";
String[] fruits = csv.split(",");   // ["apple", "banana", "orange"]

// Join (Java 8+)
String joined = String.join(", ", fruits);  // "apple, banana, orange"
```

### String Immutability

```java
String str = "Hello";
str.concat(" World");       // Creates new string, but doesn't change str
System.out.println(str);    // Still "Hello"

// To modify, reassign
str = str.concat(" World"); // Now str = "Hello World"

// For many modifications, use StringBuilder
StringBuilder sb = new StringBuilder("Hello");
sb.append(" World");        // Modifies the same object
sb.insert(5, ",");          // "Hello, World"
sb.delete(5, 6);            // "Hello World"
String result = sb.toString();
```

## Constants and Final Variables

```java
// Constants - cannot be changed after initialization
public class Constants {
    // Class constant (static final)
    public static final double PI = 3.14159;
    public static final int MAX_SIZE = 100;
    public static final String APP_NAME = "MyApp";
    
    public static void main(String[] args) {
        // Local constant
        final int daysInWeek = 7;
        
        // daysInWeek = 8;  // ERROR: cannot assign to final variable
        
        System.out.println(PI);
        System.out.println(MAX_SIZE);
    }
}
```

## Practice Exercises

### Exercise 1: Calculator
```java
// Create a simple calculator that takes two numbers and an operator
public class Calculator {
    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        
        System.out.print("Enter first number: ");
        double num1 = scanner.nextDouble();
        
        System.out.print("Enter operator (+, -, *, /): ");
        char operator = scanner.next().charAt(0);
        
        System.out.print("Enter second number: ");
        double num2 = scanner.nextDouble();
        
        double result = 0;
        
        switch (operator) {
            case '+':
                result = num1 + num2;
                break;
            case '-':
                result = num1 - num2;
                break;
            case '*':
                result = num1 * num2;
                break;
            case '/':
                if (num2 != 0) {
                    result = num1 / num2;
                } else {
                    System.out.println("Error: Division by zero");
                    return;
                }
                break;
            default:
                System.out.println("Invalid operator");
                return;
        }
        
        System.out.printf("%.2f %c %.2f = %.2f%n", 
                         num1, operator, num2, result);
        scanner.close();
    }
}
```

### Exercise 2: Temperature Converter
```java
// Convert between Celsius and Fahrenheit
public class TempConverter {
    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        
        System.out.println("1. Celsius to Fahrenheit");
        System.out.println("2. Fahrenheit to Celsius");
        System.out.print("Choose option: ");
        int choice = scanner.nextInt();
        
        System.out.print("Enter temperature: ");
        double temp = scanner.nextDouble();
        
        double result;
        
        if (choice == 1) {
            result = (temp * 9/5) + 32;
            System.out.printf("%.2f°C = %.2f°F%n", temp, result);
        } else if (choice == 2) {
            result = (temp - 32) * 5/9;
            System.out.printf("%.2f°F = %.2f°C%n", temp, result);
        } else {
            System.out.println("Invalid choice");
        }
        
        scanner.close();
    }
}
```

## Common Mistakes

### 1. Integer Division
```java
int a = 5, b = 2;
double result = a / b;      // result = 2.0 (integer division!)

// Fix: cast to double
double correct = (double) a / b;  // 2.5
```

### 2. Comparing Strings with ==
```java
String s1 = new String("hello");
String s2 = new String("hello");

if (s1 == s2) {             // false (different objects)
    System.out.println("Equal");
}

if (s1.equals(s2)) {        // true (same content)
    System.out.println("Equal");
}
```

### 3. Not Closing Scanner
```java
// Always close resources
Scanner scanner = new Scanner(System.in);
// ... use scanner ...
scanner.close();            // Important!
```

## Quick Reference

```java
// Variable declaration
int x = 10;
double y = 3.14;
String s = "Hello";
boolean flag = true;

// Arithmetic
int sum = a + b;
int diff = a - b;
int product = a * b;
int quotient = a / b;
int remainder = a % b;

// Comparison
a == b    // equal
a != b    // not equal
a > b     // greater than
a < b     // less than

// Logical
&&        // AND
||        // OR
!         // NOT

// Input
Scanner sc = new Scanner(System.in);
int num = sc.nextInt();
String str = sc.nextLine();

// Output
System.out.println(x);
System.out.printf("Value: %d%n", x);
```

---

**Previous**: [← Java Overview](java-00-overview.md) | **Next**: [Control Flow →](java-02-control-flow.md)
