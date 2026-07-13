# Java Exception Handling

## Exception Hierarchy

```
Throwable
├── Error (system errors, don't catch)
│   ├── OutOfMemoryError
│   ├── StackOverflowError
│   └── VirtualMachineError
└── Exception
    ├── RuntimeException (unchecked)
    │   ├── NullPointerException
    │   ├── ArrayIndexOutOfBoundsException
    │   ├── ArithmeticException
    │   ├── IllegalArgumentException
    │   └── ClassCastException
    └── Checked Exceptions
        ├── IOException
        ├── SQLException
        ├── ClassNotFoundException
        └── InterruptedException
```

## try-catch-finally

### Basic Exception Handling

```java
public class ExceptionDemo {
    public static void main(String[] args) {
        try {
            int result = divide(10, 0);
            System.out.println(result);
        } catch (ArithmeticException e) {
            System.out.println("Cannot divide by zero!");
            System.out.println("Error: " + e.getMessage());
        }
        
        System.out.println("Program continues...");
    }
    
    public static int divide(int a, int b) {
        return a / b;  // Throws ArithmeticException if b == 0
    }
}
```

### Multiple catch Blocks

```java
public class MultipleCatch {
    public static void main(String[] args) {
        try {
            String[] arr = {"1", "2", "abc"};
            int index = 5;
            int num = Integer.parseInt(arr[index]);
        } catch (ArrayIndexOutOfBoundsException e) {
            System.out.println("Invalid array index");
        } catch (NumberFormatException e) {
            System.out.println("Cannot parse number");
        } catch (Exception e) {
            System.out.println("Generic error: " + e);
        }
    }
}
```

### Multi-catch (Java 7+)

```java
try {
    // Code that might throw multiple exceptions
} catch (IOException | SQLException e) {
    // Handle both exceptions the same way
    System.out.println("Error: " + e.getMessage());
}
```

### finally Block

```java
public class FinallyDemo {
    public static void readFile(String filename) {
        FileReader reader = null;
        try {
            reader = new FileReader(filename);
            // Read file...
        } catch (IOException e) {
            System.out.println("Error reading file");
        } finally {
            // Always executes (cleanup code)
            if (reader != null) {
                try {
                    reader.close();
                } catch (IOException e) {
                    System.out.println("Error closing file");
                }
            }
        }
    }
}
```

## try-with-resources (Java 7+)

### Automatic Resource Management

```java
// Old way
public static void readFileOld(String path) {
    BufferedReader reader = null;
    try {
        reader = new BufferedReader(new FileReader(path));
        String line = reader.readLine();
    } catch (IOException e) {
        e.printStackTrace();
    } finally {
        if (reader != null) {
            try {
                reader.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }
}

// New way - automatic close
public static void readFileNew(String path) {
    try (BufferedReader reader = new BufferedReader(new FileReader(path))) {
        String line = reader.readLine();
    } catch (IOException e) {
        e.printStackTrace();
    }
    // reader automatically closed
}
```

### Multiple Resources

```java
try (
    FileInputStream fis = new FileInputStream("input.txt");
    FileOutputStream fos = new FileOutputStream("output.txt")
) {
    // Use both streams
    int data;
    while ((data = fis.read()) != -1) {
        fos.write(data);
    }
} catch (IOException e) {
    e.printStackTrace();
}
// Both streams automatically closed in reverse order
```

## Throwing Exceptions

### throw Statement

```java
public class BankAccount {
    private double balance;
    
    public void withdraw(double amount) {
        if (amount <= 0) {
            throw new IllegalArgumentException("Amount must be positive");
        }
        if (amount > balance) {
            throw new IllegalStateException("Insufficient funds");
        }
        balance -= amount;
    }
    
    public void setAge(int age) {
        if (age < 0 || age > 150) {
            throw new IllegalArgumentException(
                "Age must be between 0 and 150, got: " + age
            );
        }
    }
}
```

### throws Declaration

```java
// Checked exception must be declared or caught
public void readFile(String path) throws IOException {
    FileReader reader = new FileReader(path);
    // IOException might be thrown
}

// Multiple exceptions
public void processData() throws IOException, SQLException {
    // Code that might throw either exception
}

// Caller must handle
public void caller() {
    try {
        readFile("data.txt");
    } catch (IOException e) {
        System.out.println("File error");
    }
}
```

## Custom Exceptions

### Creating Custom Exceptions

```java
// Custom checked exception
public class InsufficientFundsException extends Exception {
    private double amount;
    
    public InsufficientFundsException(double amount) {
        super("Insufficient funds: requested " + amount);
        this.amount = amount;
    }
    
    public double getAmount() {
        return amount;
    }
}

// Custom unchecked exception
public class InvalidAccountException extends RuntimeException {
    public InvalidAccountException(String message) {
        super(message);
    }
    
    public InvalidAccountException(String message, Throwable cause) {
        super(message, cause);
    }
}

// Usage
public class BankAccount {
    private double balance;
    
    public void withdraw(double amount) throws InsufficientFundsException {
        if (amount > balance) {
            throw new InsufficientFundsException(amount);
        }
        balance -= amount;
    }
}
```

## Exception Information

### Getting Exception Details

```java
try {
    int result = 10 / 0;
} catch (ArithmeticException e) {
    // Exception message
    System.out.println(e.getMessage());     // / by zero
    
    // Exception type
    System.out.println(e.getClass().getName());  // java.lang.ArithmeticException
    
    // Stack trace
    e.printStackTrace();
    
    // Stack trace as array
    StackTraceElement[] trace = e.getStackTrace();
    for (StackTraceElement element : trace) {
        System.out.println(element);
    }
}
```

### Exception Chaining

```java
public class ExceptionChaining {
    public void method1() throws CustomException {
        try {
            // Some operation that throws IOException
            FileReader reader = new FileReader("missing.txt");
        } catch (IOException e) {
            // Wrap IOException in custom exception
            throw new CustomException("Failed to read file", e);
        }
    }
    
    public void caller() {
        try {
            method1();
        } catch (CustomException e) {
            System.out.println("Error: " + e.getMessage());
            System.out.println("Caused by: " + e.getCause());
            e.printStackTrace();
        }
    }
}
```

## Common Exceptions

### NullPointerException

```java
String str = null;
// str.length();  // NullPointerException!

// Prevention
if (str != null) {
    int len = str.length();
}

// Or use Optional (Java 8+)
Optional<String> optional = Optional.ofNullable(str);
int len = optional.map(String::length).orElse(0);
```

### ArrayIndexOutOfBoundsException

```java
int[] numbers = {1, 2, 3};
// int x = numbers[5];  // ArrayIndexOutOfBoundsException!

// Prevention
if (index >= 0 && index < numbers.length) {
    int x = numbers[index];
}
```

### ClassCastException

```java
Object obj = "Hello";
// Integer num = (Integer) obj;  // ClassCastException!

// Prevention
if (obj instanceof Integer) {
    Integer num = (Integer) obj;
}

// Pattern matching (Java 16+)
if (obj instanceof Integer num) {
    // Use num directly
}
```

### NumberFormatException

```java
String str = "abc";
// int num = Integer.parseInt(str);  // NumberFormatException!

// Prevention
try {
    int num = Integer.parseInt(str);
} catch (NumberFormatException e) {
    System.out.println("Invalid number");
}
```

## Exception Best Practices

### Don't Catch Generic Exception

```java
// BAD
try {
    // code
} catch (Exception e) {
    // Too broad, might catch unexpected exceptions
}

// GOOD
try {
    // code
} catch (IOException e) {
    // Specific exception
} catch (SQLException e) {
    // Another specific exception
}
```

### Don't Swallow Exceptions

```java
// BAD
try {
    riskyOperation();
} catch (Exception e) {
    // Empty catch block - error is lost!
}

// GOOD
try {
    riskyOperation();
} catch (Exception e) {
    logger.error("Operation failed", e);
    // Or rethrow
    throw new RuntimeException("Operation failed", e);
}
```

### Use Specific Exceptions

```java
// BAD
public void setAge(int age) {
    if (age < 0) {
        throw new Exception("Invalid age");  // Too generic
    }
}

// GOOD
public void setAge(int age) {
    if (age < 0) {
        throw new IllegalArgumentException("Age cannot be negative: " + age);
    }
}
```

### Clean Up Resources

```java
// GOOD: Use try-with-resources
try (Connection conn = DriverManager.getConnection(url)) {
    // Use connection
} catch (SQLException e) {
    // Handle exception
}
// Connection automatically closed

// Or use finally
Connection conn = null;
try {
    conn = DriverManager.getConnection(url);
    // Use connection
} catch (SQLException e) {
    // Handle exception
} finally {
    if (conn != null) {
        try {
            conn.close();
        } catch (SQLException e) {
            logger.error("Failed to close connection", e);
        }
    }
}
```

## Practical Examples

### Retry Logic

```java
public class RetryUtil {
    public static <T> T retry(Supplier<T> operation, int maxAttempts) {
        int attempts = 0;
        while (attempts < maxAttempts) {
            try {
                return operation.get();
            } catch (Exception e) {
                attempts++;
                if (attempts >= maxAttempts) {
                    throw new RuntimeException(
                        "Operation failed after " + attempts + " attempts", e
                    );
                }
                System.out.println("Attempt " + attempts + " failed, retrying...");
            }
        }
        throw new IllegalStateException("Should not reach here");
    }
    
    public static void main(String[] args) {
        // Retry database connection
        Connection conn = retry(() -> {
            return DriverManager.getConnection(url);
        }, 3);
    }
}
```

### Input Validation

```java
public class Validator {
    public static int readPositiveInt(Scanner scanner) {
        while (true) {
            try {
                System.out.print("Enter positive number: ");
                int number = Integer.parseInt(scanner.nextLine());
                if (number <= 0) {
                    throw new IllegalArgumentException("Number must be positive");
                }
                return number;
            } catch (NumberFormatException e) {
                System.out.println("Invalid input. Please enter a number.");
            } catch (IllegalArgumentException e) {
                System.out.println(e.getMessage());
            }
        }
    }
}
```

### Transaction Pattern

```java
public class TransactionManager {
    public void executeInTransaction(Runnable operation) {
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            
            operation.run();
            
            conn.commit();
        } catch (Exception e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException rollbackEx) {
                    throw new RuntimeException("Rollback failed", rollbackEx);
                }
            }
            throw new RuntimeException("Transaction failed", e);
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                    // Log but don't throw
                    logger.error("Failed to close connection", e);
                }
            }
        }
    }
}
```

## Assertions

### Using assert

```java
public class AssertionDemo {
    public static double calculateDiscount(double price, int percentage) {
        assert price >= 0 : "Price cannot be negative";
        assert percentage >= 0 && percentage <= 100 
            : "Percentage must be 0-100";
        
        return price * percentage / 100.0;
    }
}

// Enable assertions:
// java -ea MyProgram
// Or disable (default):
// java -da MyProgram
```

## Quick Reference

```java
// try-catch
try {
    riskyOperation();
} catch (SpecificException e) {
    handle(e);
} finally {
    cleanup();
}

// try-with-resources
try (Resource r = new Resource()) {
    use(r);
} catch (Exception e) {
    handle(e);
}

// throw
throw new IllegalArgumentException("message");

// throws
public void method() throws IOException {
    // might throw IOException
}

// Custom exception
public class MyException extends Exception {
    public MyException(String message) {
        super(message);
    }
}
```

## Checked vs Unchecked

| Type | Extends | Checked at Compile Time | When to Use |
|------|---------|------------------------|-------------|
| Checked | Exception | Yes | Recoverable conditions |
| Unchecked | RuntimeException | No | Programming errors |

```java
// Checked - must handle
public void readFile() throws IOException {
    // Must declare or catch
}

// Unchecked - optional to handle
public void divide(int a, int b) {
    return a / b;  // Might throw ArithmeticException
}
```

---

**Previous**: [← Strings](java-08-strings.md) | **Next**: [Collections →](java-09-collections.md)
