# Java Control Flow

## Conditional Statements

### if Statement

```java
// Basic if
if (condition) {
    // executes if condition is true
}

// if-else
if (age >= 18) {
    System.out.println("Adult");
} else {
    System.out.println("Minor");
}

// if-else-if ladder
int score = 85;
if (score >= 90) {
    System.out.println("Grade: A");
} else if (score >= 80) {
    System.out.println("Grade: B");
} else if (score >= 70) {
    System.out.println("Grade: C");
} else if (score >= 60) {
    System.out.println("Grade: D");
} else {
    System.out.println("Grade: F");
}

// Nested if
if (age >= 18) {
    if (hasLicense) {
        System.out.println("Can drive");
    } else {
        System.out.println("Get a license first");
    }
}
```

### Ternary Operator

```java
// Syntax: condition ? valueIfTrue : valueIfFalse

int age = 20;
String status = (age >= 18) ? "Adult" : "Minor";

// Nested ternary (avoid - hard to read)
String grade = (score >= 90) ? "A" :
               (score >= 80) ? "B" :
               (score >= 70) ? "C" : "F";

// Better: use if-else for complex logic
```

### switch Statement

```java
// Traditional switch (Java 1-13)
int day = 3;
String dayName;

switch (day) {
    case 1:
        dayName = "Monday";
        break;
    case 2:
        dayName = "Tuesday";
        break;
    case 3:
        dayName = "Wednesday";
        break;
    case 4:
        dayName = "Thursday";
        break;
    case 5:
        dayName = "Friday";
        break;
    case 6:
    case 7:
        dayName = "Weekend";
        break;
    default:
        dayName = "Invalid day";
}

// Multiple cases (fall-through)
switch (month) {
    case 12:
    case 1:
    case 2:
        System.out.println("Winter");
        break;
    case 3:
    case 4:
    case 5:
        System.out.println("Spring");
        break;
    case 6:
    case 7:
    case 8:
        System.out.println("Summer");
        break;
    case 9:
    case 10:
    case 11:
        System.out.println("Fall");
        break;
}

// Switch with String
String command = "start";
switch (command) {
    case "start":
        System.out.println("Starting...");
        break;
    case "stop":
        System.out.println("Stopping...");
        break;
    case "pause":
        System.out.println("Pausing...");
        break;
    default:
        System.out.println("Unknown command");
}
```

### Switch Expressions (Java 12+)

```java
// Modern switch (no break needed)
String dayName = switch (day) {
    case 1 -> "Monday";
    case 2 -> "Tuesday";
    case 3 -> "Wednesday";
    case 4 -> "Thursday";
    case 5 -> "Friday";
    case 6, 7 -> "Weekend";
    default -> "Invalid day";
};

// Multiple lines with block
String result = switch (status) {
    case 1 -> {
        System.out.println("Processing status 1");
        yield "Active";
    }
    case 2 -> {
        System.out.println("Processing status 2");
        yield "Inactive";
    }
    default -> "Unknown";
};

// Switch with enum
enum Size { SMALL, MEDIUM, LARGE }

Size size = Size.MEDIUM;
int price = switch (size) {
    case SMALL -> 5;
    case MEDIUM -> 10;
    case LARGE -> 15;
};
```

## Loops

### for Loop

```java
// Basic for loop
for (int i = 0; i < 5; i++) {
    System.out.println(i);  // 0, 1, 2, 3, 4
}

// Counting down
for (int i = 10; i >= 0; i--) {
    System.out.println(i);
}

// Step by 2
for (int i = 0; i < 10; i += 2) {
    System.out.println(i);  // 0, 2, 4, 6, 8
}

// Nested loops
for (int i = 1; i <= 3; i++) {
    for (int j = 1; j <= 3; j++) {
        System.out.print(i * j + " ");
    }
    System.out.println();
}
// Output:
// 1 2 3
// 2 4 6
// 3 6 9

// Multiple variables
for (int i = 0, j = 10; i < j; i++, j--) {
    System.out.println(i + " " + j);
}

// Infinite loop
for (;;) {
    // runs forever until break
    if (condition) break;
}
```

### Enhanced for Loop (for-each)

```java
// Array iteration
int[] numbers = {1, 2, 3, 4, 5};
for (int num : numbers) {
    System.out.println(num);
}

// Collection iteration
List<String> names = Arrays.asList("Alice", "Bob", "Charlie");
for (String name : names) {
    System.out.println(name);
}

// Cannot modify index or remove elements
for (int num : numbers) {
    // num = num * 2;  // Only changes local variable
}
```

### while Loop

```java
// Basic while
int i = 0;
while (i < 5) {
    System.out.println(i);
    i++;
}

// Condition-based loop
Scanner scanner = new Scanner(System.in);
String input = "";
while (!input.equals("quit")) {
    System.out.print("Enter command (quit to exit): ");
    input = scanner.nextLine();
    System.out.println("You entered: " + input);
}

// Reading until end of input
while (scanner.hasNext()) {
    String line = scanner.nextLine();
    System.out.println(line);
}

// Infinite loop
while (true) {
    // runs forever until break
    if (condition) break;
}
```

### do-while Loop

```java
// Executes at least once
int i = 0;
do {
    System.out.println(i);
    i++;
} while (i < 5);

// Menu example
Scanner scanner = new Scanner(System.in);
int choice;
do {
    System.out.println("Menu:");
    System.out.println("1. Option 1");
    System.out.println("2. Option 2");
    System.out.println("0. Exit");
    System.out.print("Choose: ");
    choice = scanner.nextInt();
    
    switch (choice) {
        case 1:
            System.out.println("Option 1 selected");
            break;
        case 2:
            System.out.println("Option 2 selected");
            break;
        case 0:
            System.out.println("Exiting...");
            break;
        default:
            System.out.println("Invalid choice");
    }
} while (choice != 0);
```

## Loop Control Statements

### break

```java
// Exit loop immediately
for (int i = 0; i < 10; i++) {
    if (i == 5) {
        break;  // Loop stops at i=5
    }
    System.out.println(i);  // Prints 0-4
}

// Break from nested loop (only inner)
for (int i = 0; i < 3; i++) {
    for (int j = 0; j < 3; j++) {
        if (j == 1) break;
        System.out.println(i + "," + j);
    }
}

// Labeled break (exit outer loop)
outer: for (int i = 0; i < 3; i++) {
    for (int j = 0; j < 3; j++) {
        if (j == 1) break outer;
        System.out.println(i + "," + j);
    }
}

// Search example
int[] numbers = {5, 3, 8, 1, 9};
int target = 8;
boolean found = false;
for (int num : numbers) {
    if (num == target) {
        found = true;
        break;
    }
}
```

### continue

```java
// Skip current iteration
for (int i = 0; i < 10; i++) {
    if (i % 2 == 0) {
        continue;  // Skip even numbers
    }
    System.out.println(i);  // Prints odd numbers
}

// Skip negative numbers
int[] numbers = {1, -2, 3, -4, 5};
for (int num : numbers) {
    if (num < 0) continue;
    System.out.println(num);  // 1, 3, 5
}

// Labeled continue
outer: for (int i = 0; i < 3; i++) {
    for (int j = 0; j < 3; j++) {
        if (j == 1) continue outer;
        System.out.println(i + "," + j);
    }
}
```

### return

```java
// Exit method immediately
public static int findFirst(int[] arr, int target) {
    for (int i = 0; i < arr.length; i++) {
        if (arr[i] == target) {
            return i;  // Exit method, return index
        }
    }
    return -1;  // Not found
}

// Multiple returns
public static String getGrade(int score) {
    if (score >= 90) return "A";
    if (score >= 80) return "B";
    if (score >= 70) return "C";
    if (score >= 60) return "D";
    return "F";
}
```

## Common Patterns

### Counting

```java
// Count occurrences
int[] numbers = {1, 2, 3, 2, 4, 2, 5};
int count = 0;
for (int num : numbers) {
    if (num == 2) count++;
}
System.out.println("Count: " + count);  // 3
```

### Sum and Average

```java
int[] numbers = {10, 20, 30, 40, 50};
int sum = 0;

for (int num : numbers) {
    sum += num;
}

double average = (double) sum / numbers.length;
System.out.println("Sum: " + sum);          // 150
System.out.println("Average: " + average);   // 30.0
```

### Finding Min/Max

```java
int[] numbers = {5, 3, 8, 1, 9, 2};

int min = numbers[0];
int max = numbers[0];

for (int num : numbers) {
    if (num < min) min = num;
    if (num > max) max = num;
}

System.out.println("Min: " + min);  // 1
System.out.println("Max: " + max);  // 9
```

### Validation Loop

```java
Scanner scanner = new Scanner(System.in);
int age;

do {
    System.out.print("Enter age (0-120): ");
    age = scanner.nextInt();
    
    if (age < 0 || age > 120) {
        System.out.println("Invalid age!");
    }
} while (age < 0 || age > 120);

System.out.println("Valid age: " + age);
```

### Pattern Printing

```java
// Right triangle
for (int i = 1; i <= 5; i++) {
    for (int j = 1; j <= i; j++) {
        System.out.print("* ");
    }
    System.out.println();
}
// *
// * *
// * * *
// * * * *
// * * * * *

// Pyramid
int n = 5;
for (int i = 1; i <= n; i++) {
    for (int j = 1; j <= n - i; j++) {
        System.out.print(" ");
    }
    for (int j = 1; j <= 2 * i - 1; j++) {
        System.out.print("*");
    }
    System.out.println();
}
//     *
//    ***
//   *****
//  *******
// *********
```

## Practice Exercises

### Exercise 1: Multiplication Table

```java
public class MultiplicationTable {
    public static void main(String[] args) {
        int n = 10;
        
        // Print header
        System.out.print("    ");
        for (int i = 1; i <= n; i++) {
            System.out.printf("%4d", i);
        }
        System.out.println();
        System.out.println("    " + "-".repeat(n * 4));
        
        // Print table
        for (int i = 1; i <= n; i++) {
            System.out.printf("%2d |", i);
            for (int j = 1; j <= n; j++) {
                System.out.printf("%4d", i * j);
            }
            System.out.println();
        }
    }
}
```

### Exercise 2: Prime Number Checker

```java
public class PrimeChecker {
    public static boolean isPrime(int n) {
        if (n <= 1) return false;
        if (n <= 3) return true;
        if (n % 2 == 0 || n % 3 == 0) return false;
        
        for (int i = 5; i * i <= n; i += 6) {
            if (n % i == 0 || n % (i + 2) == 0) {
                return false;
            }
        }
        return true;
    }
    
    public static void main(String[] args) {
        System.out.println("Prime numbers up to 100:");
        for (int i = 2; i <= 100; i++) {
            if (isPrime(i)) {
                System.out.print(i + " ");
            }
        }
    }
}
```

### Exercise 3: Factorial Calculator

```java
public class Factorial {
    public static long factorial(int n) {
        long result = 1;
        for (int i = 2; i <= n; i++) {
            result *= i;
        }
        return result;
    }
    
    public static void main(String[] args) {
        for (int i = 0; i <= 10; i++) {
            System.out.println(i + "! = " + factorial(i));
        }
    }
}
```

### Exercise 4: Number Guessing Game

```java
import java.util.Random;
import java.util.Scanner;

public class GuessingGame {
    public static void main(String[] args) {
        Random random = new Random();
        Scanner scanner = new Scanner(System.in);
        
        int number = random.nextInt(100) + 1;
        int attempts = 0;
        int guess;
        
        System.out.println("Guess the number (1-100):");
        
        do {
            System.out.print("Enter guess: ");
            guess = scanner.nextInt();
            attempts++;
            
            if (guess < number) {
                System.out.println("Too low!");
            } else if (guess > number) {
                System.out.println("Too high!");
            }
        } while (guess != number);
        
        System.out.println("Correct! Attempts: " + attempts);
        scanner.close();
    }
}
```

### Exercise 5: Diamond Pattern

```java
public class Diamond {
    public static void printDiamond(int n) {
        // Upper half
        for (int i = 1; i <= n; i++) {
            for (int j = 1; j <= n - i; j++) {
                System.out.print(" ");
            }
            for (int j = 1; j <= 2 * i - 1; j++) {
                System.out.print("*");
            }
            System.out.println();
        }
        
        // Lower half
        for (int i = n - 1; i >= 1; i--) {
            for (int j = 1; j <= n - i; j++) {
                System.out.print(" ");
            }
            for (int j = 1; j <= 2 * i - 1; j++) {
                System.out.print("*");
            }
            System.out.println();
        }
    }
    
    public static void main(String[] args) {
        printDiamond(5);
    }
}
```

## Common Mistakes

### 1. Off-by-One Errors

```java
// WRONG: Misses last element
for (int i = 0; i < array.length - 1; i++) {
    System.out.println(array[i]);
}

// CORRECT
for (int i = 0; i < array.length; i++) {
    System.out.println(array[i]);
}
```

### 2. Infinite Loops

```java
// WRONG: Never increments
int i = 0;
while (i < 10) {
    System.out.println(i);
    // Missing: i++;
}

// WRONG: Condition never false
while (true) {
    System.out.println("Running...");
    // Missing: break condition
}
```

### 3. Modifying Loop Variable in for-each

```java
// WRONG: Doesn't modify array
int[] numbers = {1, 2, 3};
for (int num : numbers) {
    num = num * 2;  // Only changes local variable!
}

// CORRECT: Use regular for loop
for (int i = 0; i < numbers.length; i++) {
    numbers[i] = numbers[i] * 2;
}
```

### 4. Forgetting break in switch

```java
// WRONG: Falls through
switch (day) {
    case 1:
        System.out.println("Monday");
        // Missing break!
    case 2:
        System.out.println("Tuesday");
        break;
}

// CORRECT
switch (day) {
    case 1:
        System.out.println("Monday");
        break;
    case 2:
        System.out.println("Tuesday");
        break;
}
```

## Quick Reference

```java
// if-else
if (condition) { } else { }

// Ternary
result = condition ? trueValue : falseValue;

// switch (traditional)
switch (value) {
    case 1: /* code */ break;
    default: /* code */
}

// switch expression (Java 12+)
result = switch (value) {
    case 1 -> "one";
    default -> "other";
};

// for loop
for (init; condition; update) { }

// for-each
for (Type item : collection) { }

// while
while (condition) { }

// do-while
do { } while (condition);

// break: exit loop
// continue: skip iteration
// return: exit method
```

---

**Previous**: [← Java Basics](java-01-basics.md) | **Next**: [Methods →](java-03-methods.md)
