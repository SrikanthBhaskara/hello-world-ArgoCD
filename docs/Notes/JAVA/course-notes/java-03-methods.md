# Java Methods & Functions

## Method Basics

### Method Declaration

```java
// Syntax:
// accessModifier returnType methodName(parameters) {
//     // method body
//     return value;
// }

public class Calculator {
    // Method with return value
    public int add(int a, int b) {
        return a + b;
    }
    
    // Method without return value (void)
    public void printMessage(String message) {
        System.out.println(message);
    }
    
    // Method with no parameters
    public String getGreeting() {
        return "Hello!";
    }
    
    // Method with multiple parameters
    public double calculateAverage(int a, int b, int c) {
        return (a + b + c) / 3.0;
    }
}
```

### Calling Methods

```java
public class Main {
    public static void main(String[] args) {
        Calculator calc = new Calculator();
        
        // Call method and store result
        int result = calc.add(5, 3);
        System.out.println(result);  // 8
        
        // Call void method
        calc.printMessage("Hello World");
        
        // Chain method calls
        System.out.println(calc.getGreeting());
        
        // Pass method result as argument
        System.out.println(calc.add(2, calc.add(3, 4)));
    }
}
```

## Access Modifiers

```java
public class AccessDemo {
    // public: accessible everywhere
    public void publicMethod() { }
    
    // private: accessible only within this class
    private void privateMethod() { }
    
    // protected: accessible within package and subclasses
    protected void protectedMethod() { }
    
    // default (no modifier): accessible within package
    void packageMethod() { }
}
```

## Static Methods

```java
public class MathUtils {
    // Static method - belongs to class, not instance
    public static int square(int n) {
        return n * n;
    }
    
    public static double average(double... numbers) {
        double sum = 0;
        for (double num : numbers) {
            sum += num;
        }
        return sum / numbers.length;
    }
    
    public static void main(String[] args) {
        // Call static method without creating instance
        int result = MathUtils.square(5);  // 25
        
        // Can also call on instance (not recommended)
        MathUtils utils = new MathUtils();
        result = utils.square(5);  // Works but discouraged
        
        double avg = MathUtils.average(1, 2, 3, 4, 5);  // 3.0
    }
}
```

## Parameters

### Pass by Value

```java
// Java is ALWAYS pass-by-value
public class PassByValue {
    public static void changeValue(int x) {
        x = 100;  // Only changes local copy
    }
    
    public static void changeArray(int[] arr) {
        arr[0] = 100;  // Modifies original array
        // (passes copy of reference, not copy of array)
    }
    
    public static void main(String[] args) {
        int num = 10;
        changeValue(num);
        System.out.println(num);  // Still 10
        
        int[] numbers = {1, 2, 3};
        changeArray(numbers);
        System.out.println(numbers[0]);  // Now 100
    }
}
```

### Variable Arguments (Varargs)

```java
public class VarargsDemo {
    // Varargs parameter (must be last)
    public static int sum(int... numbers) {
        int total = 0;
        for (int num : numbers) {
            total += num;
        }
        return total;
    }
    
    // Varargs with other parameters
    public static String format(String prefix, String... items) {
        StringBuilder sb = new StringBuilder(prefix);
        for (String item : items) {
            sb.append(" ").append(item);
        }
        return sb.toString();
    }
    
    public static void main(String[] args) {
        System.out.println(sum(1, 2, 3));        // 6
        System.out.println(sum(1, 2, 3, 4, 5));  // 15
        System.out.println(sum());               // 0
        
        String result = format("Items:", "apple", "banana", "orange");
        System.out.println(result);  // Items: apple banana orange
    }
}
```

## Method Overloading

```java
public class Calculator {
    // Same method name, different parameters
    public int add(int a, int b) {
        return a + b;
    }
    
    public double add(double a, double b) {
        return a + b;
    }
    
    public int add(int a, int b, int c) {
        return a + b + c;
    }
    
    // Different parameter types
    public String add(String a, String b) {
        return a + b;
    }
    
    public static void main(String[] args) {
        Calculator calc = new Calculator();
        
        System.out.println(calc.add(5, 3));           // 8
        System.out.println(calc.add(5.5, 3.2));       // 8.7
        System.out.println(calc.add(1, 2, 3));        // 6
        System.out.println(calc.add("Hello", "World")); // HelloWorld
    }
}
```

### Overloading Rules

```java
public class OverloadingRules {
    // Valid overloads
    void method(int a) { }
    void method(double a) { }
    void method(int a, int b) { }
    void method(String a) { }
    
    // INVALID: Return type alone doesn't count
    // int method(int a) { }  // Compile error!
    
    // INVALID: Parameter names don't count
    // void method(int b) { }  // Compile error!
    
    // Valid: Different order
    void process(int a, String b) { }
    void process(String a, int b) { }
}
```

## Recursion

```java
public class RecursionExamples {
    // Factorial
    public static long factorial(int n) {
        if (n <= 1) {
            return 1;  // Base case
        }
        return n * factorial(n - 1);  // Recursive case
    }
    
    // Fibonacci
    public static int fibonacci(int n) {
        if (n <= 1) return n;
        return fibonacci(n - 1) + fibonacci(n - 2);
    }
    
    // Sum of digits
    public static int sumDigits(int n) {
        if (n == 0) return 0;
        return n % 10 + sumDigits(n / 10);
    }
    
    // Power
    public static double power(double base, int exp) {
        if (exp == 0) return 1;
        if (exp < 0) return 1 / power(base, -exp);
        return base * power(base, exp - 1);
    }
    
    // Binary search (recursive)
    public static int binarySearch(int[] arr, int target, int left, int right) {
        if (left > right) return -1;
        
        int mid = left + (right - left) / 2;
        
        if (arr[mid] == target) return mid;
        if (arr[mid] > target) return binarySearch(arr, target, left, mid - 1);
        return binarySearch(arr, target, mid + 1, right);
    }
    
    public static void main(String[] args) {
        System.out.println(factorial(5));      // 120
        System.out.println(fibonacci(7));      // 13
        System.out.println(sumDigits(1234));   // 10
        System.out.println(power(2, 10));      // 1024.0
        
        int[] arr = {1, 3, 5, 7, 9, 11, 13};
        System.out.println(binarySearch(arr, 7, 0, arr.length - 1));  // 3
    }
}
```

### Recursion vs Iteration

```java
// Factorial - Recursive
public static long factorialRecursive(int n) {
    if (n <= 1) return 1;
    return n * factorialRecursive(n - 1);
}

// Factorial - Iterative (usually more efficient)
public static long factorialIterative(int n) {
    long result = 1;
    for (int i = 2; i <= n; i++) {
        result *= i;
    }
    return result;
}
```

## Method Return

### Single Return Value

```java
public class ReturnDemo {
    public static int divide(int a, int b) {
        if (b == 0) {
            return -1;  // Error indicator
        }
        return a / b;
    }
    
    // Multiple return statements
    public static String getGrade(int score) {
        if (score >= 90) return "A";
        if (score >= 80) return "B";
        if (score >= 70) return "C";
        if (score >= 60) return "D";
        return "F";
    }
}
```

### Returning Objects

```java
public class ArrayUtils {
    // Return array
    public static int[] createArray(int size) {
        int[] arr = new int[size];
        for (int i = 0; i < size; i++) {
            arr[i] = i * 2;
        }
        return arr;
    }
    
    // Return String
    public static String concatenate(String... strings) {
        return String.join(" ", strings);
    }
    
    // Return custom object
    public static Person createPerson(String name, int age) {
        return new Person(name, age);
    }
}
```

### Returning Multiple Values

```java
// Option 1: Return array
public static int[] minMax(int[] numbers) {
    int min = numbers[0];
    int max = numbers[0];
    for (int num : numbers) {
        if (num < min) min = num;
        if (num > max) max = num;
    }
    return new int[]{min, max};
}

// Option 2: Return object/class
class Result {
    int min;
    int max;
    Result(int min, int max) {
        this.min = min;
        this.max = max;
    }
}

public static Result minMax2(int[] numbers) {
    int min = numbers[0];
    int max = numbers[0];
    for (int num : numbers) {
        if (num < min) min = num;
        if (num > max) max = num;
    }
    return new Result(min, max);
}

// Option 3: Use Map
public static Map<String, Integer> minMax3(int[] numbers) {
    Map<String, Integer> result = new HashMap<>();
    int min = numbers[0];
    int max = numbers[0];
    for (int num : numbers) {
        if (num < min) min = num;
        if (num > max) max = num;
    }
    result.put("min", min);
    result.put("max", max);
    return result;
}
```

## Common Utility Methods

### String Methods

```java
public class StringUtils {
    public static boolean isPalindrome(String str) {
        str = str.toLowerCase().replaceAll("[^a-z0-9]", "");
        int left = 0, right = str.length() - 1;
        while (left < right) {
            if (str.charAt(left++) != str.charAt(right--)) {
                return false;
            }
        }
        return true;
    }
    
    public static String reverse(String str) {
        return new StringBuilder(str).reverse().toString();
    }
    
    public static int countWords(String str) {
        if (str == null || str.trim().isEmpty()) return 0;
        return str.trim().split("\\s+").length;
    }
}
```

### Array Methods

```java
public class ArrayUtils {
    public static int[] reverse(int[] arr) {
        int[] result = new int[arr.length];
        for (int i = 0; i < arr.length; i++) {
            result[i] = arr[arr.length - 1 - i];
        }
        return result;
    }
    
    public static boolean contains(int[] arr, int target) {
        for (int num : arr) {
            if (num == target) return true;
        }
        return false;
    }
    
    public static int[] removeDuplicates(int[] arr) {
        return Arrays.stream(arr).distinct().toArray();
    }
}
```

### Math Methods

```java
public class MathUtils {
    public static boolean isPrime(int n) {
        if (n <= 1) return false;
        if (n <= 3) return true;
        if (n % 2 == 0 || n % 3 == 0) return false;
        for (int i = 5; i * i <= n; i += 6) {
            if (n % i == 0 || n % (i + 2) == 0) return false;
        }
        return true;
    }
    
    public static int gcd(int a, int b) {
        while (b != 0) {
            int temp = b;
            b = a % b;
            a = temp;
        }
        return a;
    }
    
    public static int lcm(int a, int b) {
        return (a * b) / gcd(a, b);
    }
}
```

## Method Design Best Practices

### Single Responsibility

```java
// BAD: Method does too much
public void processUserData(String name, int age) {
    // Validates
    if (name.isEmpty()) { /* error */ }
    // Saves to database
    database.save(name, age);
    // Sends email
    email.send("Welcome " + name);
    // Logs
    logger.log("User created");
}

// GOOD: Separate concerns
public void createUser(String name, int age) {
    validateUserData(name, age);
    User user = saveUser(name, age);
    sendWelcomeEmail(user);
    logUserCreation(user);
}

private void validateUserData(String name, int age) { }
private User saveUser(String name, int age) { }
private void sendWelcomeEmail(User user) { }
private void logUserCreation(User user) { }
```

### Keep Methods Short

```java
// Aim for 20-30 lines max
public void longMethod() {
    // If method gets long, break into smaller methods
}

// Extract complex logic
private boolean isValid() {
    // Complex validation logic
}
```

### Meaningful Names

```java
// BAD
public int calc(int x, int y) { }
public void proc() { }

// GOOD
public int calculateTotalPrice(int quantity, int unitPrice) { }
public void processPayment() { }
```

## Common Mistakes

### Modifying Parameters

```java
// BAD: Confusing behavior
public void increment(int n) {
    n++;  // Only modifies local copy
}

// GOOD: Return new value
public int increment(int n) {
    return n + 1;
}
```

### Not Handling Edge Cases

```java
// BAD
public int divide(int a, int b) {
    return a / b;  // Crashes if b == 0
}

// GOOD
public int divide(int a, int b) {
    if (b == 0) {
        throw new IllegalArgumentException("Division by zero");
    }
    return a / b;
}
```

## Quick Reference

```java
// Method declaration
returnType methodName(parameters) { }

// Static method
static returnType methodName(parameters) { }

// Void method (no return)
void methodName(parameters) { }

// Varargs
returnType methodName(Type... args) { }

// Method overloading
void method(int a) { }
void method(double a) { }
void method(int a, int b) { }

// Recursion
returnType method(params) {
    if (baseCase) return value;
    return method(modifiedParams);
}
```

---

**Previous**: [← Control Flow](java-02-control-flow.md) | **Next**: [Classes & Objects →](java-04-classes-objects.md)
