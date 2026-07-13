# Java Exception Handling - Complete Interview Guide
## For 5+ Years Backend Developers

---

# 1. EXCEPTION HIERARCHY & BASICS

## 1.1 Concept Explanation

**Exception** is an unwanted or unexpected event that occurs during program execution and disrupts the normal flow of instructions.

**Java Exception Hierarchy:**

```
                    Object
                      |
                  Throwable
                   /     \
              Error      Exception
               |            /      \
         (unchecked)   IOException  RuntimeException
                       (checked)      (unchecked)
                                         |
                                    NullPointerException
                                    ArrayIndexOutOfBoundsException
                                    ArithmeticException
                                    etc.
```

**Key Categories:**

1. **Checked Exceptions** (Compile-time exceptions)
   - Must be handled or declared
   - Compiler forces you to handle
   - Examples: IOException, SQLException, ClassNotFoundException

2. **Unchecked Exceptions** (Runtime exceptions)
   - Not required to be handled
   - Compiler doesn't check
   - Examples: NullPointerException, ArrayIndexOutOfBoundsException, ArithmeticException

3. **Errors**
   - Serious problems that applications shouldn't try to catch
   - Examples: OutOfMemoryError, StackOverflowError, VirtualMachineError

**Why Exception Handling?**
- Separate error handling code from normal code
- Propagate errors up the call stack
- Group and differentiate error types
- Recover from errors gracefully

## 1.2 Checked vs Unchecked Exceptions

### Checked Exceptions - Real-World Example

```java
import java.io.*;
import java.sql.*;

public class FileProcessor {
    
    // Method declares checked exceptions
    public String readFile(String filePath) throws IOException {
        // Compiler forces you to handle IOException
        BufferedReader reader = new BufferedReader(new FileReader(filePath));
        try {
            StringBuilder content = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
                content.append(line).append("\n");
            }
            return content.toString();
        } finally {
            reader.close();  // Always close
        }
    }
    
    // Better: try-with-resources (Java 7+)
    public String readFileSafe(String filePath) throws IOException {
        try (BufferedReader reader = new BufferedReader(new FileReader(filePath))) {
            StringBuilder content = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
                content.append(line).append("\n");
            }
            return content.toString();
        }  // Automatically closes reader
    }
    
    // Handle checked exception
    public String readFileWithHandling(String filePath) {
        try {
            return readFile(filePath);
        } catch (FileNotFoundException e) {
            System.err.println("File not found: " + filePath);
            return "";
        } catch (IOException e) {
            System.err.println("Error reading file: " + e.getMessage());
            return "";
        }
    }
    
    // Database operations - checked exceptions
    public User getUserById(int id) throws SQLException {
        String query = "SELECT * FROM users WHERE id = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setInt(1, id);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return new User(
                    rs.getInt("id"),
                    rs.getString("name"),
                    rs.getString("email")
                );
            }
            return null;
        }  // SQLException propagated to caller
    }
    
    private Connection getConnection() throws SQLException {
        return DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/mydb",
            "user",
            "password"
        );
    }
}
```

### Unchecked Exceptions - Real-World Example

```java
public class Calculator {
    
    // Runtime exceptions - no need to declare
    public int divide(int a, int b) {
        // ArithmeticException (unchecked) can occur
        return a / b;  // Throws if b is 0
    }
    
    // Better: Validate and throw meaningful exception
    public int divideSafe(int a, int b) {
        if (b == 0) {
            throw new IllegalArgumentException("Divisor cannot be zero");
        }
        return a / b;
    }
    
    // Handle runtime exception
    public Integer divideWithHandling(int a, int b) {
        try {
            return a / b;
        } catch (ArithmeticException e) {
            System.err.println("Division by zero");
            return null;
        }
    }
}

public class UserService {
    private Map<String, User> users = new HashMap<>();
    
    // NullPointerException can occur
    public String getUserEmail(String userId) {
        User user = users.get(userId);
        return user.getEmail();  // NPE if user is null
    }
    
    // Better: Defensive programming
    public String getUserEmailSafe(String userId) {
        if (userId == null) {
            throw new IllegalArgumentException("User ID cannot be null");
        }
        
        User user = users.get(userId);
        if (user == null) {
            throw new IllegalStateException("User not found: " + userId);
        }
        
        return user.getEmail();
    }
    
    // Or return Optional
    public Optional<String> getUserEmailOptional(String userId) {
        return Optional.ofNullable(users.get(userId))
                       .map(User::getEmail);
    }
}

public class ArrayProcessor {
    
    // ArrayIndexOutOfBoundsException can occur
    public int getElement(int[] array, int index) {
        return array[index];  // Unchecked exception
    }
    
    // Better: Validate
    public int getElementSafe(int[] array, int index) {
        if (array == null) {
            throw new IllegalArgumentException("Array cannot be null");
        }
        if (index < 0 || index >= array.length) {
            throw new IndexOutOfBoundsException(
                "Index " + index + " out of bounds for length " + array.length
            );
        }
        return array[index];
    }
}
```

## 1.3 Try-Catch-Finally

### Basic Try-Catch

```java
public class TryCatchExamples {
    
    // Single catch
    public void singleCatch() {
        try {
            int result = 10 / 0;
        } catch (ArithmeticException e) {
            System.err.println("Cannot divide by zero");
        }
    }
    
    // Multiple catch blocks
    public void multipleCatch() {
        try {
            String str = null;
            int length = str.length();  // NullPointerException
        } catch (NullPointerException e) {
            System.err.println("Null pointer: " + e.getMessage());
        } catch (Exception e) {
            System.err.println("General exception: " + e.getMessage());
        }
    }
    
    // Multi-catch (Java 7+)
    public void multiCatch() {
        try {
            // Some operation
            performOperation();
        } catch (IOException | SQLException e) {
            // Handle both exceptions the same way
            System.err.println("I/O or SQL error: " + e.getMessage());
            logError(e);
        }
    }
    
    // Catch order matters - specific before general
    public void catchOrder() {
        try {
            readFile("test.txt");
        } catch (FileNotFoundException e) {
            // Specific exception first
            System.err.println("File not found");
        } catch (IOException e) {
            // More general exception after
            System.err.println("I/O error");
        } catch (Exception e) {
            // Most general last
            System.err.println("Unknown error");
        }
    }
    
    // Wrong order - compile error
    /*
    public void wrongOrder() {
        try {
            readFile("test.txt");
        } catch (Exception e) {  // Catches everything
            System.err.println("Error");
        } catch (IOException e) {  // COMPILE ERROR: Already caught by Exception
            System.err.println("I/O error");
        }
    }
    */
}
```

### Finally Block

```java
public class FinallyExamples {
    
    // Finally always executes
    public void finallyAlwaysRuns() {
        try {
            System.out.println("Try block");
            return;  // Even with return
        } catch (Exception e) {
            System.out.println("Catch block");
        } finally {
            System.out.println("Finally block");  // Still executes!
        }
    }
    
    // Resource cleanup
    public String readFileOldWay(String filePath) {
        BufferedReader reader = null;
        try {
            reader = new BufferedReader(new FileReader(filePath));
            return reader.readLine();
        } catch (IOException e) {
            System.err.println("Error reading file");
            return null;
        } finally {
            // Always close resources
            if (reader != null) {
                try {
                    reader.close();
                } catch (IOException e) {
                    System.err.println("Error closing reader");
                }
            }
        }
    }
    
    // Finally with return - tricky!
    public int finallyWithReturn() {
        try {
            return 1;
        } finally {
            return 2;  // This value is returned! (BAD PRACTICE)
        }
        // Returns 2, not 1
    }
    
    // Finally modifying return value
    public int[] finallyModifyingReturn() {
        int[] result = {1, 2, 3};
        try {
            return result;
        } finally {
            result[0] = 999;  // Modifies before return (BAD PRACTICE)
        }
        // Returns {999, 2, 3}
    }
    
    // System.exit prevents finally
    public void systemExitPreventsFinally() {
        try {
            System.exit(0);  // JVM exits
        } finally {
            System.out.println("This won't print");  // Not executed!
        }
    }
}
```

### Try-with-Resources (Java 7+)

```java
public class TryWithResourcesExamples {
    
    // Basic try-with-resources
    public String readFile(String filePath) throws IOException {
        try (BufferedReader reader = new BufferedReader(new FileReader(filePath))) {
            return reader.readLine();
        }  // Automatically closes reader, even if exception occurs
    }
    
    // Multiple resources
    public void copyFile(String source, String dest) throws IOException {
        try (BufferedReader reader = new BufferedReader(new FileReader(source));
             BufferedWriter writer = new BufferedWriter(new FileWriter(dest))) {
            
            String line;
            while ((line = reader.readLine()) != null) {
                writer.write(line);
                writer.newLine();
            }
        }  // Both closed automatically in reverse order
    }
    
    // With catch and finally
    public void tryWithResourcesComplete(String filePath) {
        try (BufferedReader reader = new BufferedReader(new FileReader(filePath))) {
            String line = reader.readLine();
            System.out.println(line);
        } catch (FileNotFoundException e) {
            System.err.println("File not found: " + filePath);
        } catch (IOException e) {
            System.err.println("Error reading file");
        } finally {
            System.out.println("Cleanup if needed");
        }
    }
    
    // Custom resource
    public void customResource() {
        try (MyResource resource = new MyResource()) {
            resource.doSomething();
        } catch (Exception e) {
            System.err.println("Error: " + e.getMessage());
        }
    }
}

// Custom resource class
class MyResource implements AutoCloseable {
    
    public MyResource() {
        System.out.println("Resource opened");
    }
    
    public void doSomething() {
        System.out.println("Using resource");
    }
    
    @Override
    public void close() {
        System.out.println("Resource closed");
    }
}

// Database example
public class DatabaseExample {
    
    public List<User> getAllUsers() throws SQLException {
        String query = "SELECT * FROM users";
        List<User> users = new ArrayList<>();
        
        // All three resources auto-closed
        try (Connection conn = getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(query)) {
            
            while (rs.next()) {
                users.add(new User(
                    rs.getInt("id"),
                    rs.getString("name"),
                    rs.getString("email")
                ));
            }
        }
        
        return users;
    }
    
    private Connection getConnection() throws SQLException {
        return DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/mydb",
            "user",
            "password"
        );
    }
}
```

## 1.4 Interview Questions and Answers

### Q1: What's the difference between checked and unchecked exceptions?

**Answer:**

| Checked Exceptions | Unchecked Exceptions |
|-------------------|---------------------|
| Checked at compile time | Checked at runtime |
| Must be handled or declared | Not required to handle |
| Extend Exception (except RuntimeException) | Extend RuntimeException |
| Recoverable errors | Programming errors |
| Examples: IOException, SQLException | Examples: NullPointerException, IllegalArgumentException |
| Caller must handle | Optional to handle |

**Example:**
```java
// Checked exception - must handle
public void readFile(String path) throws IOException {  // Must declare
    FileReader reader = new FileReader(path);  // Can throw IOException
}

public void callReadFile() {
    try {
        readFile("test.txt");  // Must handle
    } catch (IOException e) {
        // Handle
    }
}

// Unchecked exception - optional to handle
public void divide(int a, int b) {  // No need to declare
    int result = a / b;  // Can throw ArithmeticException
}

public void callDivide() {
    divide(10, 0);  // Compiles fine, no handling required
}
```

**When to use which?**
- **Checked**: For recoverable conditions (file not found, network error)
- **Unchecked**: For programming errors (null pointer, illegal argument)

### Q2: Can we have try without catch or finally?

**Answer:**
**No** to plain try, but **Yes** with try-with-resources.

```java
// Compile error - try needs catch or finally
/*
public void invalidTry() {
    try {
        // code
    }
    // ERROR: Missing catch or finally
}
*/

// Valid - try with catch
public void tryWithCatch() {
    try {
        // code
    } catch (Exception e) {
        // handle
    }
}

// Valid - try with finally
public void tryWithFinally() {
    try {
        // code
    } finally {
        // cleanup
    }
}

// Valid - try with both
public void tryWithBoth() {
    try {
        // code
    } catch (Exception e) {
        // handle
    } finally {
        // cleanup
    }
}

// Valid - try-with-resources without catch/finally
public void tryWithResources() throws IOException {
    try (FileReader reader = new FileReader("test.txt")) {
        // code
    }
    // AutoCloseable resource is closed automatically
}

// Also valid - try-with-resources with catch
public void tryWithResourcesAndCatch() {
    try (FileReader reader = new FileReader("test.txt")) {
        // code
    } catch (IOException e) {
        // handle
    }
}
```

### Q3: What happens if exception occurs in catch or finally block?

**Answer:**

**Exception in catch block:**
```java
public class ExceptionInCatch {
    public void exceptionInCatchBlock() {
        try {
            int result = 10 / 0;  // ArithmeticException
        } catch (ArithmeticException e) {
            System.out.println("Handling ArithmeticException");
            String str = null;
            str.length();  // NullPointerException in catch!
            // Original ArithmeticException is lost
        }
    }
    // NullPointerException propagates, ArithmeticException is suppressed
    
    // Better: Nested try-catch
    public void betterHandling() {
        try {
            int result = 10 / 0;
        } catch (ArithmeticException e) {
            try {
                // Risky operation
                performCleanup();
            } catch (Exception cleanupException) {
                // Handle cleanup exception
                System.err.println("Cleanup failed: " + cleanupException);
            }
        }
    }
}
```

**Exception in finally block:**
```java
public class ExceptionInFinally {
    public void exceptionInFinallyBlock() {
        try {
            return;  // About to return
        } finally {
            throw new RuntimeException("Finally exception");
            // This exception propagates, return is suppressed
        }
    }
    
    // Suppressed exception
    public void suppressedException() {
        try {
            throw new IOException("Try exception");
        } finally {
            throw new RuntimeException("Finally exception");
            // IOException is suppressed by RuntimeException
        }
    }
    
    // Try-with-resources handles this better
    public void tryWithResourcesSuppressed() {
        try (MyResource resource = new MyResource()) {
            throw new IOException("Main exception");
        } catch (IOException e) {
            System.out.println("Main: " + e.getMessage());
            
            // Suppressed exceptions from close()
            Throwable[] suppressed = e.getSuppressed();
            for (Throwable t : suppressed) {
                System.out.println("Suppressed: " + t.getMessage());
            }
        }
    }
}

class MyResource implements AutoCloseable {
    @Override
    public void close() throws Exception {
        throw new Exception("Close exception");
    }
}
```

### Q4: Can constructor throw exceptions?

**Answer:**
**Yes**, constructors can throw both checked and unchecked exceptions.

```java
public class User {
    private String email;
    private int age;
    
    // Constructor throwing unchecked exception
    public User(String email, int age) {
        if (email == null || !email.contains("@")) {
            throw new IllegalArgumentException("Invalid email");
        }
        if (age < 0 || age > 150) {
            throw new IllegalArgumentException("Invalid age");
        }
        this.email = email;
        this.age = age;
    }
    
    // Constructor throwing checked exception
    public User(File userFile) throws IOException {
        // Read from file
        BufferedReader reader = new BufferedReader(new FileReader(userFile));
        this.email = reader.readLine();
        this.age = Integer.parseInt(reader.readLine());
        reader.close();
    }
}

// Subclass constructor
class Employee extends User {
    private String employeeId;
    
    // Must declare or handle parent's checked exception
    public Employee(File file, String employeeId) throws IOException {
        super(file);  // Parent constructor throws IOException
        this.employeeId = employeeId;
    }
}

// Usage
public class ConstructorExceptionDemo {
    public static void main(String[] args) {
        try {
            User user1 = new User("invalid-email", 25);  // Throws IllegalArgumentException
        } catch (IllegalArgumentException e) {
            System.err.println("Invalid user: " + e.getMessage());
        }
        
        try {
            User user2 = new User(new File("user.txt"));  // Can throw IOException
        } catch (IOException e) {
            System.err.println("Error reading file: " + e.getMessage());
        }
    }
}
```

**Important Notes:**
- If constructor throws exception, object is NOT created
- Partially constructed object is not accessible
- Finally block executes even if constructor fails
- Parent constructor exception must be handled in child

### Q5: What is exception chaining?

**Answer:**
**Exception chaining** is wrapping one exception into another to preserve the original cause.

```java
public class ExceptionChaining {
    
    // Without chaining - original exception lost
    public void withoutChaining() {
        try {
            connectToDatabase();
        } catch (SQLException e) {
            // Original exception lost!
            throw new RuntimeException("Database error");
        }
    }
    
    // With chaining - preserves original exception
    public void withChaining() {
        try {
            connectToDatabase();
        } catch (SQLException e) {
            // Wrap original exception
            throw new RuntimeException("Database error", e);  // Chain it!
        }
    }
    
    // Getting original cause
    public void getCause() {
        try {
            performOperation();
        } catch (Exception e) {
            System.out.println("Exception: " + e.getMessage());
            
            Throwable cause = e.getCause();
            if (cause != null) {
                System.out.println("Caused by: " + cause.getMessage());
            }
            
            // Get root cause
            Throwable rootCause = getRootCause(e);
            System.out.println("Root cause: " + rootCause.getMessage());
        }
    }
    
    private Throwable getRootCause(Throwable throwable) {
        Throwable cause = throwable;
        while (cause.getCause() != null && cause.getCause() != cause) {
            cause = cause.getCause();
        }
        return cause;
    }
    
    // Real-world example
    public User getUserById(int id) {
        try {
            return fetchUserFromDatabase(id);
        } catch (SQLException e) {
            // Chain SQL exception with custom exception
            throw new DataAccessException("Failed to fetch user with ID: " + id, e);
        }
    }
    
    private User fetchUserFromDatabase(int id) throws SQLException {
        try {
            // Database code
            Connection conn = getConnection();
            // ...
            return new User();
        } catch (SQLException e) {
            // Add context before re-throwing
            throw new SQLException("Database query failed for user ID: " + id, e);
        }
    }
    
    private Connection getConnection() throws SQLException {
        throw new SQLException("Connection failed");
    }
}

// Stack trace with chaining
/*
Exception in thread "main" DataAccessException: Failed to fetch user with ID: 123
    at ExceptionChaining.getUserById(ExceptionChaining.java:50)
    at Main.main(Main.java:10)
Caused by: java.sql.SQLException: Database query failed for user ID: 123
    at ExceptionChaining.fetchUserFromDatabase(ExceptionChaining.java:58)
    at ExceptionChaining.getUserById(ExceptionChaining.java:48)
    ... 1 more
Caused by: java.sql.SQLException: Connection failed
    at ExceptionChaining.getConnection(ExceptionChaining.java:64)
    at ExceptionChaining.fetchUserFromDatabase(ExceptionChaining.java:54)
    ... 2 more
*/
```

**Benefits:**
- Preserves original exception information
- Adds context at each layer
- Helps debugging with complete stack trace
- Converts checked to unchecked exceptions

### Q6: Can we re-throw an exception?

**Answer:**
**Yes**, we can re-throw exceptions in three ways:

```java
public class RethrowExamples {
    
    // 1. Simple re-throw - same exception
    public void simpleRethrow() throws IOException {
        try {
            readFile("test.txt");
        } catch (IOException e) {
            System.err.println("Logging error: " + e.getMessage());
            throw e;  // Re-throw same exception
        }
    }
    
    // 2. Wrap and throw - exception chaining
    public void wrapAndThrow() {
        try {
            performDatabaseOperation();
        } catch (SQLException e) {
            // Wrap in unchecked exception
            throw new RuntimeException("Database operation failed", e);
        }
    }
    
    // 3. Throw new exception - replace
    public void throwNewException() throws CustomException {
        try {
            riskyOperation();
        } catch (Exception e) {
            // Throw completely different exception
            throw new CustomException("Operation failed");
        }
    }
    
    // Partial handling and re-throw
    public void partialHandling() throws IOException {
        try {
            readFile("test.txt");
        } catch (FileNotFoundException e) {
            // Handle this specific exception
            System.err.println("File not found, using default");
            useDefaultFile();
        } catch (IOException e) {
            // Re-throw other IOExceptions
            throw e;
        }
    }
    
    // Transform checked to unchecked
    public void transformException() {
        try {
            readFile("test.txt");
        } catch (IOException e) {
            // Convert checked to unchecked
            throw new UncheckedIOException(e);
        }
    }
    
    // Java 7+ - Multi-catch re-throw
    public void multiCatchRethrow() throws IOException, SQLException {
        try {
            performOperation();
        } catch (IOException | SQLException e) {
            System.err.println("Error: " + e.getMessage());
            throw e;  // Re-throw either exception
        }
    }
    
    // Java 7+ - Precise rethrow
    public void preciseRethrow() throws FileNotFoundException, SQLException {
        try {
            performOperation();
        } catch (Exception e) {  // Catches any exception
            throw e;  // But compiler knows it's only FileNotFoundException or SQLException
        }
    }
}
```

## 1.5 Interview Traps and Edge Cases

### Trap 1: Multiple Returns with Finally

```java
public class ReturnTrap {
    
    // Which value is returned?
    public int mysteryReturn() {
        try {
            return 1;
        } catch (Exception e) {
            return 2;
        } finally {
            return 3;  // This is returned! (BAD PRACTICE)
        }
    }
    // Returns: 3
    
    // Finally modifies variable
    public int[] modifyInFinally() {
        int[] result = {1, 2, 3};
        try {
            return result;  // Returns reference
        } finally {
            result[0] = 999;  // Modifies before return!
        }
    }
    // Returns: {999, 2, 3}
    
    // Correct way
    public int correctReturn() {
        int result = 0;
        try {
            result = 1;
        } catch (Exception e) {
            result = 2;
        } finally {
            // Don't return here!
            System.out.println("Cleanup");
        }
        return result;
    }
}
```

### Trap 2: Exception in AutoCloseable

```java
public class AutoCloseableTrap implements AutoCloseable {
    private String name;
    
    public AutoCloseableTrap(String name) {
        this.name = name;
        System.out.println(name + " created");
    }
    
    public void doWork() throws Exception {
        System.out.println(name + " working");
        throw new Exception(name + " work exception");
    }
    
    @Override
    public void close() throws Exception {
        System.out.println(name + " closing");
        throw new Exception(name + " close exception");
    }
    
    public static void main(String[] args) {
        try (AutoCloseableTrap resource = new AutoCloseableTrap("Resource")) {
            resource.doWork();
        } catch (Exception e) {
            System.out.println("Caught: " + e.getMessage());
            
            // Check suppressed exceptions
            Throwable[] suppressed = e.getSuppressed();
            for (Throwable t : suppressed) {
                System.out.println("Suppressed: " + t.getMessage());
            }
        }
    }
}

/* Output:
Resource created
Resource working
Resource closing
Caught: Resource work exception
Suppressed: Resource close exception
*/
```

### Trap 3: Catch Block Order

```java
public class CatchOrderTrap {
    
    // Compile error - unreachable catch
    /*
    public void wrongOrder() {
        try {
            riskyOperation();
        } catch (Exception e) {
            // Catches everything
        } catch (IOException e) {  // COMPILE ERROR: Already caught
            // Unreachable
        }
    }
    */
    
    // Correct order - specific first
    public void correctOrder() {
        try {
            riskyOperation();
        } catch (FileNotFoundException e) {
            // Most specific
        } catch (IOException e) {
            // Less specific
        } catch (Exception e) {
            // Most general
        }
    }
    
    // Multi-catch trap
    /*
    public void multiCatchTrap() {
        try {
            riskyOperation();
        } catch (FileNotFoundException | IOException e) {
            // COMPILE ERROR: FileNotFoundException is subclass of IOException
        }
    }
    */
    
    // Correct multi-catch - unrelated exceptions
    public void correctMultiCatch() {
        try {
            riskyOperation();
        } catch (IOException | SQLException e) {
            // OK - unrelated exceptions
        }
    }
}
```

### Trap 4: Overriding and Exceptions

```java
class Parent {
    public void method1() throws IOException {
        // ...
    }
    
    public void method2() {
        // ...
    }
}

class Child extends Parent {
    // OK - Same exception
    @Override
    public void method1() throws IOException {
        // ...
    }
    
    // OK - Subclass exception (more specific)
    @Override
    public void method1() throws FileNotFoundException {
        // ...
    }
    
    // OK - No exception
    @Override
    public void method1() {
        // ...
    }
    
    // COMPILE ERROR - Broader exception
    /*
    @Override
    public void method1() throws Exception {
        // ERROR: Cannot throw broader exception
    }
    */
    
    // COMPILE ERROR - Adding checked exception to method without it
    /*
    @Override
    public void method2() throws IOException {
        // ERROR: Parent doesn't throw IOException
    }
    */
    
    // OK - Can add unchecked exception
    @Override
    public void method2() throws RuntimeException {
        // OK - Unchecked exceptions not checked in overriding
    }
}
```

## 1.6 Coding Problems with Solutions

### Problem 1: Retry Mechanism with Exponential Backoff

**Question:** Implement a retry mechanism that retries failing operations with exponential backoff.

```java
import java.util.function.Supplier;

public class RetryMechanism {
    
    /**
     * Retries an operation with exponential backoff
     * @param operation The operation to retry
     * @param maxAttempts Maximum number of attempts
     * @param initialDelay Initial delay in milliseconds
     * @param maxDelay Maximum delay in milliseconds
     * @return Result of the operation
     * @throws Exception if all attempts fail
     */
    public static <T> T retryWithExponentialBackoff(
            Supplier<T> operation,
            int maxAttempts,
            long initialDelay,
            long maxDelay) throws Exception {
        
        Exception lastException = null;
        long delay = initialDelay;
        
        for (int attempt = 1; attempt <= maxAttempts; attempt++) {
            try {
                System.out.printf("Attempt %d/%d...%n", attempt, maxAttempts);
                return operation.get();  // Try the operation
                
            } catch (Exception e) {
                lastException = e;
                System.out.printf("Attempt %d failed: %s%n", attempt, e.getMessage());
                
                if (attempt < maxAttempts) {
                    try {
                        System.out.printf("Waiting %d ms before retry...%n", delay);
                        Thread.sleep(delay);
                        
                        // Exponential backoff
                        delay = Math.min(delay * 2, maxDelay);
                        
                    } catch (InterruptedException ie) {
                        Thread.currentThread().interrupt();
                        throw new Exception("Retry interrupted", ie);
                    }
                }
            }
        }
        
        throw new Exception("Operation failed after " + maxAttempts + " attempts", lastException);
    }
    
    // Retry specific exceptions only
    public static <T> T retryOnSpecificException(
            Supplier<T> operation,
            Class<? extends Exception> retryableException,
            int maxAttempts,
            long delay) throws Exception {
        
        Exception lastException = null;
        
        for (int attempt = 1; attempt <= maxAttempts; attempt++) {
            try {
                return operation.get();
                
            } catch (Exception e) {
                // Only retry if exception matches
                if (!retryableException.isInstance(e)) {
                    throw e;  // Don't retry, throw immediately
                }
                
                lastException = e;
                System.out.printf("Attempt %d failed: %s%n", attempt, e.getMessage());
                
                if (attempt < maxAttempts) {
                    Thread.sleep(delay);
                }
            }
        }
        
        throw lastException;
    }
    
    // Usage examples
    public static void main(String[] args) {
        // Example 1: Retry HTTP request
        try {
            String response = retryWithExponentialBackoff(
                () -> makeHttpRequest("https://api.example.com"),
                5,      // 5 attempts
                1000,   // Start with 1 second
                30000   // Max 30 seconds
            );
            System.out.println("Success: " + response);
            
        } catch (Exception e) {
            System.err.println("All attempts failed: " + e.getMessage());
        }
        
        // Example 2: Retry database connection
        try {
            Connection conn = retryOnSpecificException(
                () -> connectToDatabase(),
                SQLException.class,
                3,
                2000
            );
            System.out.println("Connected: " + conn);
            
        } catch (Exception e) {
            System.err.println("Connection failed: " + e.getMessage());
        }
    }
    
    // Simulated operations
    private static int httpAttempts = 0;
    private static String makeHttpRequest(String url) {
        httpAttempts++;
        if (httpAttempts < 3) {
            throw new RuntimeException("Connection timeout");
        }
        return "Success response";
    }
    
    private static int dbAttempts = 0;
    private static Connection connectToDatabase() throws SQLException {
        dbAttempts++;
        if (dbAttempts < 2) {
            throw new SQLException("Connection refused");
        }
        return new Connection("Connected");
    }
}

// Simple Connection class for demo
class Connection {
    private String status;
    
    public Connection(String status) {
        this.status = status;
    }
    
    @Override
    public String toString() {
        return status;
    }
}
```

### Problem 2: Resource Pool with Exception Handling

**Question:** Implement a thread-safe resource pool with proper exception handling.

```java
import java.util.concurrent.*;

public class ResourcePool<T> {
    private final BlockingQueue<T> available;
    private final Set<T> inUse;
    private final Factory<T> factory;
    private final int maxSize;
    private int currentSize;
    private final Object lock = new Object();
    
    public interface Factory<T> {
        T create() throws Exception;
        void destroy(T resource);
        boolean validate(T resource);
    }
    
    public ResourcePool(Factory<T> factory, int maxSize) {
        this.factory = factory;
        this.maxSize = maxSize;
        this.available = new LinkedBlockingQueue<>();
        this.inUse = new ConcurrentHashMap<>().newKeySet();
        this.currentSize = 0;
    }
    
    /**
     * Acquire a resource from the pool
     * @param timeout Maximum wait time
     * @param unit Time unit
     * @return Resource
     * @throws Exception if resource cannot be acquired
     */
    public T acquire(long timeout, TimeUnit unit) throws Exception {
        long deadline = System.nanoTime() + unit.toNanos(timeout);
        
        while (true) {
            // Try to get from available pool
            T resource = available.poll();
            
            if (resource != null) {
                // Validate before returning
                if (factory.validate(resource)) {
                    inUse.add(resource);
                    return resource;
                } else {
                    // Invalid resource, destroy and try again
                    destroyResource(resource);
                    continue;
                }
            }
            
            // No available resource, try to create new one
            synchronized (lock) {
                if (currentSize < maxSize) {
                    try {
                        resource = factory.create();
                        currentSize++;
                        inUse.add(resource);
                        return resource;
                    } catch (Exception e) {
                        throw new ResourceCreationException(
                            "Failed to create resource", e
                        );
                    }
                }
            }
            
            // Pool full, wait for available resource
            long remainingNanos = deadline - System.nanoTime();
            if (remainingNanos <= 0) {
                throw new TimeoutException(
                    "Timeout waiting for resource after " + timeout + " " + unit
                );
            }
            
            resource = available.poll(remainingNanos, TimeUnit.NANOSECONDS);
            if (resource == null) {
                throw new TimeoutException("Timeout acquiring resource");
            }
        }
    }
    
    /**
     * Release resource back to pool
     */
    public void release(T resource) {
        if (resource == null) {
            throw new IllegalArgumentException("Resource cannot be null");
        }
        
        if (!inUse.remove(resource)) {
            throw new IllegalStateException(
                "Resource not in use or already released"
            );
        }
        
        try {
            if (factory.validate(resource)) {
                available.offer(resource);
            } else {
                destroyResource(resource);
            }
        } catch (Exception e) {
            System.err.println("Error validating resource: " + e.getMessage());
            destroyResource(resource);
        }
    }
    
    /**
     * Safely destroy a resource
     */
    private void destroyResource(T resource) {
        try {
            factory.destroy(resource);
        } catch (Exception e) {
            System.err.println("Error destroying resource: " + e.getMessage());
        } finally {
            synchronized (lock) {
                currentSize--;
            }
        }
    }
    
    /**
     * Shutdown pool and destroy all resources
     */
    public void shutdown() {
        System.out.println("Shutting down resource pool...");
        
        // Destroy available resources
        T resource;
        while ((resource = available.poll()) != null) {
            destroyResource(resource);
        }
        
        // Wait for in-use resources (in real implementation, set timeout)
        while (!inUse.isEmpty()) {
            System.err.println("Warning: " + inUse.size() + " resources still in use");
            try {
                Thread.sleep(1000);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                break;
            }
        }
        
        System.out.println("Resource pool shut down");
    }
    
    public int getAvailableCount() {
        return available.size();
    }
    
    public int getInUseCount() {
        return inUse.size();
    }
    
    public int getTotalSize() {
        synchronized (lock) {
            return currentSize;
        }
    }
}

// Custom exceptions
class ResourceCreationException extends Exception {
    public ResourceCreationException(String message, Throwable cause) {
        super(message, cause);
    }
}

// Example: Database connection pool
class DatabaseConnectionPool {
    
    static class ConnectionFactory implements ResourcePool.Factory<Connection> {
        private int connectionCount = 0;
        
        @Override
        public Connection create() throws Exception {
            System.out.println("Creating new connection...");
            
            // Simulate potential connection failure
            if (Math.random() < 0.2) {  // 20% failure rate
                throw new SQLException("Connection failed");
            }
            
            return new Connection("Connection-" + (++connectionCount));
        }
        
        @Override
        public void destroy(Connection resource) {
            System.out.println("Destroying: " + resource.getId());
        }
        
        @Override
        public boolean validate(Connection resource) {
            // Simulate validation
            return resource.isValid();
        }
    }
    
    public static void main(String[] args) {
        ResourcePool<Connection> pool = new ResourcePool<>(
            new ConnectionFactory(),
            5  // Max 5 connections
        );
        
        ExecutorService executor = Executors.newFixedThreadPool(10);
        
        // Simulate concurrent access
        for (int i = 0; i < 20; i++) {
            final int taskId = i;
            executor.submit(() -> {
                Connection conn = null;
                try {
                    System.out.printf("Task %d: Acquiring connection...%n", taskId);
                    conn = pool.acquire(5, TimeUnit.SECONDS);
                    
                    System.out.printf("Task %d: Got %s%n", taskId, conn.getId());
                    
                    // Simulate work
                    Thread.sleep((long) (Math.random() * 2000));
                    
                } catch (TimeoutException e) {
                    System.err.printf("Task %d: Timeout - %s%n", taskId, e.getMessage());
                } catch (Exception e) {
                    System.err.printf("Task %d: Error - %s%n", taskId, e.getMessage());
                } finally {
                    if (conn != null) {
                        try {
                            pool.release(conn);
                            System.out.printf("Task %d: Released %s%n", taskId, conn.getId());
                        } catch (Exception e) {
                            System.err.printf("Task %d: Release error - %s%n", 
                                            taskId, e.getMessage());
                        }
                    }
                }
            });
        }
        
        executor.shutdown();
        try {
            executor.awaitTermination(30, TimeUnit.SECONDS);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
        
        System.out.printf("%nPool stats: Total=%d, Available=%d, InUse=%d%n",
            pool.getTotalSize(), pool.getAvailableCount(), pool.getInUseCount());
        
        pool.shutdown();
    }
}

// Simple Connection class
class Connection {
    private String id;
    private boolean valid = true;
    
    public Connection(String id) {
        this.id = id;
    }
    
    public String getId() {
        return id;
    }
    
    public boolean isValid() {
        return valid;
    }
    
    public void invalidate() {
        this.valid = false;
    }
}

class SQLException extends Exception {
    public SQLException(String message) {
        super(message);
    }
}
```

---

*Continued in Part 2...*

**Current Coverage:**
✅ Exception Hierarchy & Basics
✅ Checked vs Unchecked Exceptions  
✅ Try-Catch-Finally
✅ Try-with-Resources
✅ Interview Questions (6 questions)
✅ Interview Traps & Edge Cases
✅ Coding Problems (2 problems)

---

# 2. CUSTOM EXCEPTIONS

## 2.1 Creating Custom Exceptions

### Basic Custom Exception

```java
// Custom checked exception
public class InsufficientFundsException extends Exception {
    private double balance;
    private double amount;
    
    public InsufficientFundsException(double balance, double amount) {
        super("Insufficient funds: Balance=" + balance + ", Requested=" + amount);
        this.balance = balance;
        this.amount = amount;
    }
    
    public double getBalance() {
        return balance;
    }
    
    public double getAmount() {
        return amount;
    }
    
    public double getShortfall() {
        return amount - balance;
    }
}

// Custom unchecked exception
public class InvalidEmailException extends RuntimeException {
    private String email;
    
    public InvalidEmailException(String email) {
        super("Invalid email format: " + email);
        this.email = email;
    }
    
    public InvalidEmailException(String email, Throwable cause) {
        super("Invalid email format: " + email, cause);
        this.email = email;
    }
    
    public String getEmail() {
        return email;
    }
}
```

### Exception Hierarchy for Application

```java
// Base application exception
public class ApplicationException extends Exception {
    private String errorCode;
    private LocalDateTime timestamp;
    
    public ApplicationException(String message, String errorCode) {
        super(message);
        this.errorCode = errorCode;
        this.timestamp = LocalDateTime.now();
    }
    
    public ApplicationException(String message, String errorCode, Throwable cause) {
        super(message, cause);
        this.errorCode = errorCode;
        this.timestamp = LocalDateTime.now();
    }
    
    public String getErrorCode() {
        return errorCode;
    }
    
    public LocalDateTime getTimestamp() {
        return timestamp;
    }
}

// Business logic exceptions
public class BusinessException extends ApplicationException {
    public BusinessException(String message, String errorCode) {
        super(message, errorCode);
    }
    
    public BusinessException(String message, String errorCode, Throwable cause) {
        super(message, errorCode, cause);
    }
}

//Specific business exceptions
public class OrderNotFoundException extends BusinessException {
    private String orderId;
    
    public OrderNotFoundException(String orderId) {
        super("Order not found: " + orderId, "ORDER_NOT_FOUND");
        this.orderId = orderId;
    }
    
    public String getOrderId() {
        return orderId;
    }
}

public class OutOfStockException extends BusinessException {
    private String productId;
    private int available;
    private int requested;
    
    public OutOfStockException(String productId, int available, int requested) {
        super(String.format("Product %s out of stock. Available: %d, Requested: %d",
                           productId, available, requested),
             "OUT_OF_STOCK");
        this.productId = productId;
        this.available = available;
        this.requested = requested;
    }
    
    public String getProductId() {
        return productId;
    }
    
    public int getAvailable() {
        return available;
    }
    
    public int getRequested() {
        return requested;
    }
}

// Data access exceptions
public class DataAccessException extends ApplicationException {
    public DataAccessException(String message, String errorCode) {
        super(message, errorCode);
    }
    
    public DataAccessException(String message, String errorCode, Throwable cause) {
        super(message, errorCode, cause);
    }
}

public class DatabaseConnectionException extends DataAccessException {
    private String databaseUrl;
    
    public DatabaseConnectionException(String databaseUrl, Throwable cause) {
        super("Failed to connect to database: " + databaseUrl,
             "DB_CONNECTION_ERROR",
             cause);
        this.databaseUrl = databaseUrl;
    }
}

// Validation exceptions
public class ValidationException extends RuntimeException {
    private Map<String, String> errors = new HashMap<>();
    
    public ValidationException(String message) {
        super(message);
    }
    
    public ValidationException(Map<String, String> errors) {
        super("Validation failed");
        this.errors = errors;
    }
    
    public void addError(String field, String error) {
        errors.put(field, error);
    }
    
    public Map<String, String> getErrors() {
        return new HashMap<>(errors);
    }
    
    @Override
    public String getMessage() {
        if (errors.isEmpty()) {
            return super.getMessage();
        }
        return "Validation failed: " + errors.toString();
    }
}
```

### Using Custom Exceptions

```java
public class BankAccount {
    private String accountNumber;
    private double balance;
    
    public BankAccount(String accountNumber, double initialBalance) {
        this.accountNumber = accountNumber;
        this.balance = initialBalance;
    }
    
    public void withdraw(double amount) throws InsufficientFundsException {
        if (amount <= 0) {
            throw new IllegalArgumentException("Amount must be positive");
        }
        
        if (amount > balance) {
            throw new InsufficientFundsException(balance, amount);
        }
        
        balance -= amount;
    }
    
    public void deposit(double amount) {
        if (amount <= 0) {
            throw new IllegalArgumentException("Amount must be positive");
        }
        balance += amount;
    }
    
    public double getBalance() {
        return balance;
    }
}

// Service layer
public class OrderService {
    private OrderRepository orderRepository;
    private InventoryService inventoryService;
    
    public Order createOrder(String customerId, List<OrderItem> items) 
            throws BusinessException {
        
        // Validate inventory
        for (OrderItem item : items) {
            int available = inventoryService.getAvailableQuantity(item.getProductId());
            
            if (available < item.getQuantity()) {
                throw new OutOfStockException(
                    item.getProductId(),
                    available,
                    item.getQuantity()
                );
            }
        }
        
        // Create order
        Order order = new Order(customerId, items);
        
        try {
            return orderRepository.save(order);
        } catch (SQLException e) {
            throw new DataAccessException(
                "Failed to save order",
                "DB_ERROR",
                e
            );
        }
    }
    
    public Order getOrder(String orderId) throws OrderNotFoundException {
        Order order = orderRepository.findById(orderId);
        
        if (order == null) {
            throw new OrderNotFoundException(orderId);
        }
        
        return order;
    }
}

// Usage
public class OrderDemo {
    public static void main(String[] args) {
        OrderService service = new OrderService();
        
        // Handle business exceptions
        try {
            List<OrderItem> items = Arrays.asList(
                new OrderItem("PROD-001", 5),
                new OrderItem("PROD-002", 10)
            );
            
            Order order = service.createOrder("CUST-123", items);
            System.out.println("Order created: " + order.getId());
            
        } catch (OutOfStockException e) {
            System.err.printf("Product %s out of stock. Available: %d, Requested: %d%n",
                            e.getProductId(), e.getAvailable(), e.getRequested());
            // Offer alternatives
            
        } catch (DataAccessException e) {
            System.err.println("System error: " + e.getMessage());
            // Retry or log
            
        } catch (BusinessException e) {
            System.err.println("Business error [" + e.getErrorCode() + "]: " + 
                             e.getMessage());
        }
        
        // Handle account exceptions
        BankAccount account = new BankAccount("ACC-001", 1000);
        
        try {
            account.withdraw(1500);
        } catch (InsufficientFundsException e) {
            System.err.printf("Insufficient funds. Balance: %.2f, Requested: %.2f, Short by: %.2f%n",
                            e.getBalance(), e.getAmount(), e.getShortfall());
        }
    }
}
```

## 2.2 Best Practices for Custom Exceptions

### 1. Naming Convention

```java
// Good names - Clear and descriptive
public class UserNotFoundException extends Exception { }
public class InvalidPasswordException extends Exception { }
public class PaymentProcessingException extends Exception { }

// Bad names - Vague
public class Problem extends Exception { }  // Too generic
public class MyException extends Exception { }  // Not descriptive
```

### 2. Provide Context

```java
// Good - Provides context and data
public class ProductNotFoundException extends Exception {
    private String productId;
    private String category;
    
    public ProductNotFoundException(String productId, String category) {
        super(String.format("Product not found: ID=%s, Category=%s", 
                          productId, category));
        this.productId = productId;
        this.category = category;
    }
    
    // Getters for context
    public String getProductId() { return productId; }
    public String getCategory() { return category; }
}

// Bad - No context
public class ProductNotFoundException extends Exception {
    public ProductNotFoundException() {
        super("Product not found");
    }
}
```

### 3. Use Proper Exception Type

```java
// Checked exception - for recoverable conditions
public class FileUploadException extends Exception {
    // Caller must handle
}

// Unchecked exception - for programming errors
public class InvalidConfigurationException extends RuntimeException {
    // No need to declare
}

// When to use which?
// Checked: Business logic errors, external system failures
// Unchecked: Programming errors, validation failures
```

### 4. Constructor Patterns

```java
public class CustomException extends Exception {
    
    // Basic constructor
    public CustomException(String message) {
        super(message);
    }
    
    // With cause (exception chaining)
    public CustomException(String message, Throwable cause) {
        super(message, cause);
    }
    
    // With suppression and writable stack trace (advanced)
    public CustomException(String message, Throwable cause,
                          boolean enableSuppression,
                          boolean writableStackTrace) {
        super(message, cause, enableSuppression, writableStackTrace);
    }
    
    // With additional context
    private String errorCode;
    
    public CustomException(String message, String errorCode) {
        super(message);
        this.errorCode = errorCode;
    }
    
    public CustomException(String message, String errorCode, Throwable cause) {
        super(message, cause);
        this.errorCode = errorCode;
    }
}
```

---

# 3. EXCEPTION HANDLING IN SPRING BOOT

## 3.1 Global Exception Handler

```java
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.context.request.WebRequest;
import org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler;

// Global exception handler for REST API
@RestControllerAdvice
public class GlobalExceptionHandler extends ResponseEntityExceptionHandler {
    
    // Handle specific custom exception
    @ExceptionHandler(OrderNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleOrderNotFound(
            OrderNotFoundException ex, WebRequest request) {
        
        ErrorResponse error = new ErrorResponse(
            HttpStatus.NOT_FOUND.value(),
            ex.getMessage(),
            ex.getErrorCode(),
            request.getDescription(false)
        );
        
        return new ResponseEntity<>(error, HttpStatus.NOT_FOUND);
    }
    
    // Handle multiple exceptions
    @ExceptionHandler({OutOfStockException.class, InsufficientFundsException.class})
    public ResponseEntity<ErrorResponse> handleBusinessExceptions(
            BusinessException ex, WebRequest request) {
        
        ErrorResponse error = new ErrorResponse(
            HttpStatus.BAD_REQUEST.value(),
            ex.getMessage(),
            ex.getErrorCode(),
            request.getDescription(false)
        );
        
        return new ResponseEntity<>(error, HttpStatus.BAD_REQUEST);
    }
    
    // Handle validation errors
    @ExceptionHandler(ValidationException.class)
    public ResponseEntity<ValidationErrorResponse> handleValidation(
            ValidationException ex, WebRequest request) {
        
        ValidationErrorResponse error = new ValidationErrorResponse(
            HttpStatus.BAD_REQUEST.value(),
            "Validation failed",
            ex.getErrors()
        );
        
        return new ResponseEntity<>(error, HttpStatus.BAD_REQUEST);
    }
    
    // Handle method argument validation (@Valid)
    @Override
    protected ResponseEntity<Object> handleMethodArgumentNotValid(
            MethodArgumentNotValidException ex,
            HttpHeaders headers,
            HttpStatus status,
            WebRequest request) {
        
        Map<String, String> errors = new HashMap<>();
        ex.getBindingResult().getFieldErrors().forEach(error ->
            errors.put(error.getField(), error.getDefaultMessage())
        );
        
        ValidationErrorResponse response = new ValidationErrorResponse(
            HttpStatus.BAD_REQUEST.value(),
            "Validation failed",
            errors
        );
        
        return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
    }
    
    // Handle data access exceptions
    @ExceptionHandler(DataAccessException.class)
    public ResponseEntity<ErrorResponse> handleDataAccess(
            DataAccessException ex, WebRequest request) {
        
        ErrorResponse error = new ErrorResponse(
            HttpStatus.INTERNAL_SERVER_ERROR.value(),
            "Database error occurred",
            ex.getErrorCode(),
            request.getDescription(false)
        );
        
        // Log the actual error
        logger.error("Database error", ex);
        
        return new ResponseEntity<>(error, HttpStatus.INTERNAL_SERVER_ERROR);
    }
    
    // Handle all uncaught exceptions
    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleGlobalException(
            Exception ex, WebRequest request) {
        
        ErrorResponse error = new ErrorResponse(
            HttpStatus.INTERNAL_SERVER_ERROR.value(),
            "An unexpected error occurred",
            "INTERNAL_ERROR",
            request.getDescription(false)
        );
        
        // Log the exception
        logger.error("Unexpected error", ex);
        
        return new ResponseEntity<>(error, HttpStatus.INTERNAL_SERVER_ERROR);
    }
}

// Error response classes
@Data
@AllArgsConstructor
public class ErrorResponse {
    private int status;
    private String message;
    private String errorCode;
    private String path;
    private LocalDateTime timestamp = LocalDateTime.now();
    
    public ErrorResponse(int status, String message, String errorCode, String path) {
        this.status = status;
        this.message = message;
        this.errorCode = errorCode;
        this.path = path;
    }
}

@Data
public class ValidationErrorResponse extends ErrorResponse {
    private Map<String, String> fieldErrors;
    
    public ValidationErrorResponse(int status, String message, 
                                  Map<String, String> fieldErrors) {
        super(status, message, "VALIDATION_ERROR", "");
        this.fieldErrors = fieldErrors;
    }
}
```

## 3.2 Controller Exception Handling

```java
@RestController
@RequestMapping("/api/orders")
public class OrderController {
    
    @Autowired
    private OrderService orderService;
    
    // Method-level exception handling
    @GetMapping("/{orderId}")
    public ResponseEntity<Order> getOrder(@PathVariable String orderId) {
        try {
            Order order = orderService.getOrder(orderId);
            return ResponseEntity.ok(order);
            
        } catch (OrderNotFoundException e) {
            // Handled by global handler
            throw e;
            
        } catch (DataAccessException e) {
            // Can also handle locally if needed
            logger.error("Failed to fetch order: " + orderId, e);
            throw new ResponseStatusException(
                HttpStatus.INTERNAL_SERVER_ERROR,
                "Error fetching order",
                e
            );
        }
    }
    
    // Using @ResponseStatus
    @PostMapping
    public ResponseEntity<Order> createOrder(@Valid @RequestBody OrderRequest request) {
        Order order = orderService.createOrder(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(order);
    }
    
    // Local exception handler for this controller only
    @ExceptionHandler(IllegalArgumentException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public ErrorResponse handleIllegalArgument(IllegalArgumentException ex) {
        return new ErrorResponse(
            HttpStatus.BAD_REQUEST.value(),
            ex.getMessage(),
            "INVALID_ARGUMENT",
            ""
        );
    }
}

// Using @ResponseStatus annotation
@ResponseStatus(HttpStatus.NOT_FOUND)
public class ResourceNotFoundException extends RuntimeException {
    public ResourceNotFoundException(String message) {
        super(message);
    }
}
```

## 3.3 Async Exception Handling

```java
@Configuration
public class AsyncConfig implements AsyncConfigurer {
    
    @Override
    public Executor getAsyncExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(5);
        executor.setMaxPoolSize(10);
        executor.setQueueCapacity(25);
        executor.setThreadNamePrefix("Async-");
        executor.initialize();
        return executor;
    }
    
    @Override
    public AsyncUncaughtExceptionHandler getAsyncUncaughtExceptionHandler() {
        return new CustomAsyncExceptionHandler();
    }
}

public class CustomAsyncExceptionHandler implements AsyncUncaughtExceptionHandler {
    
    private static final Logger logger = LoggerFactory.getLogger(
        CustomAsyncExceptionHandler.class
    );
    
    @Override
    public void handleUncaughtException(Throwable throwable, Method method, 
                                       Object... params) {
        logger.error("Async method {} threw exception with params {}",
                    method.getName(), Arrays.toString(params), throwable);
        
        // Send alert, log to monitoring system, etc.
        sendAlert(throwable, method);
    }
    
    private void sendAlert(Throwable throwable, Method method) {
        // Implement alerting logic
    }
}

// Service with async methods
@Service
public class NotificationService {
    
    @Async
    public CompletableFuture<String> sendEmailAsync(String to, String subject) {
        try {
            // Send email
            Thread.sleep(2000);  // Simulate delay
            return CompletableFuture.completedFuture("Email sent to " + to);
            
        } catch (Exception e) {
            logger.error("Failed to send email", e);
            return CompletableFuture.failedFuture(e);
        }
    }
    
    @Async
    public void sendNotificationAsync(String userId, String message) {
        try {
            // Send notification
            Thread.sleep(1000);
            logger.info("Notification sent to user: " + userId);
            
        } catch (Exception e) {
            // Exception caught by AsyncUncaughtExceptionHandler
            throw new RuntimeException("Notification failed for user: " + userId, e);
        }
    }
}
```

---

# 4. ADVANCED EXCEPTION HANDLING

## 4.1 Exception Translation Pattern

```java
// DAO layer - throws SQLException
public class UserDao {
    public User findById(int id) throws SQLException {
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(
                 "SELECT * FROM users WHERE id = ?")) {
            
            stmt.setInt(1, id);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return new User(
                    rs.getInt("id"),
                    rs.getString("name"),
                    rs.getString("email")
                );
            }
            return null;
        }
    }
}

// Service layer - translates to business exception
public class UserService {
    private UserDao userDao;
    
    public User getUser(int id) throws UserNotFoundException {
        try {
            User user = userDao.findById(id);
            
            if (user == null) {
                throw new UserNotFoundException("User not found: " + id);
            }
            
            return user;
            
        } catch (SQLException e) {
            // Translate data access exception to business exception
            throw new DataAccessException(
                "Failed to fetch user: " + id,
                "DB_ERROR",
                e
            );
        }
    }
}

// Controller layer - translates to HTTP response
@RestController
public class UserController {
    @Autowired
    private UserService userService;
    
    @GetMapping("/users/{id}")
    public ResponseEntity<User> getUser(@PathVariable int id) {
        try {
            User user = userService.getUser(id);
            return ResponseEntity.ok(user);
            
        } catch (UserNotFoundException e) {
            // Translate to HTTP 404
            throw new ResponseStatusException(
                HttpStatus.NOT_FOUND,
                e.getMessage(),
                e
            );
            
        } catch (DataAccessException e) {
            // Translate to HTTP 500
            throw new ResponseStatusException(
                HttpStatus.INTERNAL_SERVER_ERROR,
                "System error",
                e
            );
        }
    }
}
```

## 4.2 Circuit Breaker Pattern with Exceptions

```java
import io.github.resilience4j.circuitbreaker.annotation.CircuitBreaker;
import io.github.resilience4j.retry.annotation.Retry;

@Service
public class ExternalApiService {
    
    private static final Logger logger = LoggerFactory.getLogger(ExternalApiService.class);
    
    // Circuit breaker with fallback
    @CircuitBreaker(name = "externalApi", fallbackMethod = "fallbackGetData")
    @Retry(name = "externalApi")
    public String getData(String endpoint) {
        try {
            // Call external API
            return restTemplate.getForObject(endpoint, String.class);
            
        } catch (RestClientException e) {
            logger.error("API call failed: " + endpoint, e);
            throw new ExternalServiceException("Failed to fetch data from: " + endpoint, e);
        }
    }
    
    // Fallback method - same signature + Throwable parameter
    public String fallbackGetData(String endpoint, Throwable throwable) {
        logger.warn("Circuit breaker fallback for: " + endpoint, throwable);
        
        // Return cached data or default
        return getCachedData(endpoint);
    }
    
    private String getCachedData(String endpoint) {
        // Return from cache
        return "Cached data";
    }
}

// Custom exception
public class ExternalServiceException extends RuntimeException {
    public ExternalServiceException(String message, Throwable cause) {
        super(message, cause);
    }
}
```

## 4.3 Exception Metrics and Monitoring

```java
import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.MeterRegistry;

@Component
@Aspect
public class ExceptionMetricsAspect {
    
    private final MeterRegistry meterRegistry;
    
    public ExceptionMetricsAspect(MeterRegistry meterRegistry) {
        this.meterRegistry = meterRegistry;
    }
    
    @AfterThrowing(pointcut = "execution(* com.example.service..*(..))", 
                   throwing = "exception")
    public void recordException(JoinPoint joinPoint, Exception exception) {
        String className = joinPoint.getSignature().getDeclaringTypeName();
        String methodName = joinPoint.getSignature().getName();
        String exceptionType = exception.getClass().getSimpleName();
        
        // Record exception metric
        Counter.builder("application.exceptions")
            .tag("class", className)
            .tag("method", methodName)
            .tag("exception", exceptionType)
            .register(meterRegistry)
            .increment();
        
        // Log for monitoring
        logger.error("Exception in {}.{}: {}",
                    className, methodName, exception.getMessage(), exception);
    }
}

// Service with monitored exceptions
@Service
public class OrderService {
    
    private final Counter orderFailures;
    
    public OrderService(MeterRegistry meterRegistry) {
        this.orderFailures = Counter.builder("orders.failures")
            .description("Number of failed order operations")
            .register(meterRegistry);
    }
    
    public Order createOrder(OrderRequest request) {
        try {
            // Create order
            return processOrder(request);
            
        } catch (OutOfStockException e) {
            orderFailures.increment();
            throw e;
            
        } catch (Exception e) {
            orderFailures.increment();
            throw new OrderProcessingException("Failed to create order", e);
        }
    }
}
```

---

# 5. MORE INTERVIEW QUESTIONS

## Q7: How do you handle exceptions in ​multithreaded environment?

**Answer:**

```java
public class MultithreadedExceptionHandling {
    
    // 1. Thread's default exception handler
    public void threadExceptionHandler() {
        Thread thread = new Thread(() -> {
            throw new RuntimeException("Thread exception");
        });
        
        // Set uncaught exception handler
        thread.setUncaughtExceptionHandler((t, e) -> {
            System.err.println("Thread " + t.getName() + " threw exception: " + e.getMessage());
            // Log, send alert, etc.
        });
        
        thread.start();
    }
    
    // 2. Global default uncaught exception handler
    public void setGlobalHandler() {
        Thread.setDefaultUncaughtExceptionHandler((t, e) -> {
            System.err.println("Uncaught exception in thread " + t.getName());
            System.err.println("Exception: " + e.getMessage());
            // Log to error tracking system
        });
    }
    
    // 3. ExecutorService with Future
    public void executorWithFuture() {
        ExecutorService executor = Executors.newFixedThreadPool(2);
        
        Future<String> future = executor.submit(() -> {
            if (Math.random() > 0.5) {
                throw new RuntimeException("Task failed");
            }
            return "Success";
        });
        
        try {
            String result = future.get();  // This will throw exception if task failed
            System.out.println(result);
            
        } catch (ExecutionException e) {
            // Wrapped exception from the task
            Throwable cause = e.getCause();
            System.err.println("Task threw exception: " + cause.getMessage());
            
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            System.err.println("Task interrupted");
        } finally {
            executor.shutdown();
        }
    }
    
    // 4. Custom ThreadPoolExecutor
    public void customThreadPool() {
        ThreadPoolExecutor executor = new ThreadPoolExecutor(
            2, 4, 60, TimeUnit.SECONDS,
            new LinkedBlockingQueue<>()
        ) {
            @Override
            protected void afterExecute(Runnable r, Throwable t) {
                super.afterExecute(r, t);
                
                if (t == null && r instanceof Future<?>) {
                    try {
                        Future<?> future = (Future<?>) r;
                        if (future.isDone()) {
                            future.get();
                        }
                    } catch (ExecutionException e) {
                        t = e.getCause();
                    } catch (InterruptedException e) {
                        Thread.currentThread().interrupt();
                    } catch (CancellationException e) {
                        t = e;
                    }
                }
                
                if (t != null) {
                    System.err.println("Task threw exception: " + t.getMessage());
                    // Handle exception
                }
            }
        };
    }
    
    // 5. CompletableFuture exception handling
    public void completableFutureExceptions() {
        CompletableFuture<String> future = CompletableFuture.supplyAsync(() -> {
            if (Math.random() > 0.5) {
                throw new RuntimeException("Async task failed");
            }
            return "Success";
        });
        
        // Handle exception
        future.exceptionally(throwable -> {
            System.err.println("Exception: " + throwable.getMessage());
            return "Default value";
        }).thenAccept(result -> {
            System.out.println("Result: " + result);
        });
        
        // Or use handle()
        future.handle((result, throwable) -> {
            if (throwable != null) {
                System.err.println("Failed: " + throwable.getMessage());
                return "Error";
            }
            return result;
        });
    }
}
```

## Q8: What are suppressed exceptions?

**Answer:**
**Suppressed exceptions** are exceptions that occur while handling another exception, typically in try-with-resources or finally blocks.

```java
public class SuppressedExceptionDemo {
    
    // Try-with-resources automatically handles suppressed exceptions
    public void tryWithResourcesSuppressed() {
        try (ResourceWithException resource = new ResourceWithException()) {
            throw new IOException("Main exception");
            
        } catch (IOException e) {
            System.out.println("Main exception: " + e.getMessage());
            
            // Get suppressed exceptions
            Throwable[] suppressed = e.getSuppressed();
            System.out.println("Suppressed count: " + suppressed.length);
            
            for (Throwable t : suppressed) {
                System.out.println("Suppressed: " + t.getMessage());
            }
        }
    }
    
    // Manual suppressed exception handling
    public void manualSuppression() {
        Exception primaryException = null;
        Resource resource = null;
        
        try {
            resource = new Resource();
            throw new IOException("Primary exception");
            
        } catch (Exception e) {
            primaryException = e;
            throw e;
            
        } finally {
            if (resource != null) {
                try {
                    resource.close();
                } catch (Exception closeException) {
                    if (primaryException != null) {
                        // Add as suppressed
                        primaryException.addSuppressed(closeException);
                    } else {
                        throw closeException;
                    }
                }
            }
        }
    }
    
    // Adding multiple suppressed exceptions
    public void multipleSuppressed() {
        Exception mainException = new Exception("Main exception");
        
        mainException.addSuppressed(new SQLException("DB error"));
        mainException.addSuppressed(new IOException("File error"));
        mainException.addSuppressed(new RuntimeException("Runtime error"));
        
        try {
            throw mainException;
        } catch (Exception e) {
            System.out.println("Main: " + e.getMessage());
            
            for (Throwable suppressed : e.getSuppressed()) {
                System.out.println("  Suppressed: " + suppressed.getMessage());
            }
        }
    }
}

class ResourceWithException implements AutoCloseable {
    @Override
    public void close() throws Exception {
        throw new Exception("Exception during close");
    }
}
```

## Q9: How to log exceptions properly?

**Answer:**

```java
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class ExceptionLogging {
    private static final Logger logger = LoggerFactory.getLogger(ExceptionLogging.class);
    
    // Bad logging practices
    public void badLogging() {
        try {
            riskyOperation();
        } catch (Exception e) {
            // BAD: Printing stack trace to console
            e.printStackTrace();
            
            // BAD: Logging only message, losing stack trace
            logger.error(e.getMessage());
            
            // BAD: Logging and re-throwing (duplicate logs)
            logger.error("Error", e);
            throw e;
        }
    }
    
    // Good logging practices
    public void goodLogging() {
        try {
            riskyOperation();
            
       } catch (FileNotFoundException e) {
            // GOOD: Log with context, appropriate level
            logger.warn("File not found: {}. Using default.", e.getMessage());
            useDefault();
            
        } catch (SQLException e) {
            // GOOD: Log with full stack trace
            logger.error("Database error occurred", e);
            
            // Add context
            logger.error("Failed to process user ID: {}", getUserId(), e);
            
            // Re-throw as different exception
            throw new DataAccessException("DB operation failed", e);
            
        } catch (Exception e) {
            // GOOD: Log unexpected exceptions with full details
            logger.error("Unexpected error in operation XYZ. State: {}, User: {}",
                        getState(), getUser(), e);
            throw e;
        }
    }
    
    // Structured logging with MDC (Mapped Diagnostic Context)
    public void structuredLogging(String userId, String operation) {
        // Add context to all log messages in this thread
        MDC.put("userId", userId);
        MDC.put("operation", operation);
        MDC.put("requestId", UUID.randomUUID().toString());
        
        try {
            performOperation();
            logger.info("Operation completed successfully");
            
        } catch (Exception e) {
            // Exception logged with MDC context
            logger.error("Operation failed", e);
            throw e;
            
        } finally {
            // Clean up MDC
            MDC.clear();
        }
    }
    
    // Logging with conditional checks for expensive operations
    public void conditionalLogging() {
        try {
            complexOperation();
            
        } catch (Exception e) {
            // Check log level before expensive operations
            if (logger.isDebugEnabled()) {
                logger.debug("Detailed state: {}", expensiveToString(), e);
            }
            
            logger.error("Operation failed", e);
        }
    }
    
    // Sanitize sensitive data in logs
    public void sanitizedLogging(String password, String ssn) {
        try {
            authenticate(password);
            
        } catch (AuthenticationException e) {
            // DON'T log sensitive data
            logger.error("Authentication failed for user: {}", getUsername());
            // NOT: logger.error("Auth failed with password: {}", password);
            
            // Sanitize if needed
            logger.debug("Request details: {}", sanitize(getRequestDetails()));
        }
    }
    
    private String sanitize(String data) {
        // Remove or mask sensitive information
        return data.replaceAll("password=.*?(&|$)", "password=***$1");
    }
}
```

## Q10: Exception handling performance considerations?

**Answer:**

```java
public class ExceptionPerformance {
    
    // 1. Exceptions are expensive - use for exceptional cases only
    
    // BAD: Using exceptions for control flow
    public int parseIntBad(String str) {
        try {
            return Integer.parseInt(str);
        } catch (NumberFormatException e) {
            return 0;  // Default value
        }
    }
    
    // GOOD: Validate first, exception as last resort
    public int parseIntGood(String str) {
        if (str == null || str.isEmpty()) {
            return 0;
        }
        
        // Use regex or other validation
        if (!str.matches("-?\\d+")) {
            return 0;
        }
        
        try {
            return Integer.parseInt(str);
        } catch (NumberFormatException e) {
            logger.warn("Unexpected parse error for validated string: {}", str);
            return 0;
        }
    }
    
    // 2. Don't create exceptions unnecessarily
    
    // BAD: Creating exception to get stack trace
    public String getCallerBad() {
        Exception e = new Exception();  // Expensive!
        StackTraceElement[] stack = e.getStackTrace();
        return stack[1].getClassName();
    }
    
    // GOOD: Use Thread.getStackTrace()
    public String getCallerGood() {
        StackTraceElement[] stack = Thread.currentThread().getStackTrace();
        return stack[2].getClassName();
    }
    
    // 3. Avoid filling in stack trace for throw-away exceptions
    
    public static class QuickException extends Exception {
        // Don't fill stack trace - much faster
        @Override
        public synchronized Throwable fillInStackTrace() {
            return this;  // Don't create stack trace
        }
    }
    
    // Use for high-frequency exceptions where stack trace not needed
    public void fastException() throws QuickException {
        throw new QuickException();  // Very fast
    }
    
    // 4. Reuse exception instances (with caution)
    
    private static final IllegalStateException INVALID_STATE = 
        new IllegalStateException("Invalid state");
    
    static {
        // Prevent stack trace creation
        INVALID_STATE.setStackTrace(new StackTraceElement[0]);
    }
    
    public void checkState(boolean valid) {
        if (!valid) {
            throw INVALID_STATE;  // Reuse instance (no stack trace)
        }
    }
    
    // 5. Benchmark example
    public void benchmark() {
        int iterations = 100000;
        
        // Test: exception handling
        long start = System.nanoTime();
        for (int i = 0; i < iterations; i++) {
            try {
                if (i % 2 == 0) {
                    throw new Exception();
                }
            } catch (Exception e) {
                // Handle
            }
        }
        long exceptionTime = System.nanoTime() - start;
        
        // Test: normal control flow
        start = System.nanoTime();
        for (int i = 0; i < iterations; i++) {
            if (i % 2 == 0) {
                // Handle
            }
        }
        long normalTime = System.nanoTime() - start;
        
        System.out.printf("Exception: %d ms, Normal: %d ms, Ratio: %.2fx%n",
                         exceptionTime / 1_000_000,
                         normalTime / 1_000_000,
                         (double) exceptionTime / normalTime);
        // Output: Exceptions are 100-1000x slower!
    }
}
```

---

# 6. SUMMARY & BEST PRACTICES

## Key Takeaways

✅ **Exception Types:**
- **Checked**: Must handle, for recoverable errors (IOException, SQLException)
- **Unchecked**: Optional to handle, for programming errors (NullPointerException, IllegalArgumentException)
- **Errors**: Serious problems, don't catch (OutOfMemoryError, StackOverflowError)

✅ **Try-Catch-Finally:**
- Use try-with-resources for automatic resource management
- Catch specific exceptions before general ones
- Finally always executes (except System.exit())
- Don't return from finally block

✅ **Custom Exceptions:**
- Provide meaningful names and context
- Include relevant data in exception
- Use proper hierarchy (checked vs unchecked)
- Implement standard constructors

✅ **Best Practices:**
1. **Don't use exceptions for control flow**
2. **Catch specific exceptions, not Exception**
3. **Log exceptions with context**
4. **Don't swallow exceptions silently**
5. **Use exception chaining to preserve original cause**
6. **Clean up resources in finally or try-with-resources**
7. **Fail fast, fail visibly**
8. **Document exceptions in Javadoc (@throws)**

✅ **Spring Boot:**
- Use @RestControllerAdvice for global exception handling
- Translate exceptions at each layer (DAO → Service → Controller)
- Return appropriate HTTP status codes
- Provide consistent error response format

✅ **Production Tips:**
- Monitor exception metrics
- Implement circuit breakers for external services
- Use structured logging with MDC
- Don't expose sensitive data in error messages
- Set up alerts for critical exceptions

## Quick Reference

```java
// Try-catch-finally
try {
    // Risky operation
} catch (SpecificException e) {
    // Handle specific
} catch (Exception e) {
    // Handle general
} finally {
    // Always executes
}

// Try-with-resources
try (Resource r = new Resource()) {
    // Use resource
}  // Auto-closed

// Custom exception
public class MyException extends Exception {
    public MyException(String message) {
        super(message);
    }
}

// Throw exception
throw new IllegalArgumentException("Invalid input");

// Exception chaining
try {
    operation();
} catch (SQLException e) {
    throw new DataAccessException("DB error", e);  // Chain it
}

// Spring Boot global handler
@RestControllerAdvice
public class GlobalExceptionHandler {
    @ExceptionHandler(MyException.class)
    public ResponseEntity<ErrorResponse> handle(MyException e) {
        return ResponseEntity
            .status(HttpStatus.BAD_REQUEST)
            .body(new ErrorResponse(e.getMessage()));
    }
}
```

---

**Complete Guide Includes:**
✅ Exception Hierarchy & Basics
✅ Checked vs Unchecked Exceptions
✅ Try-Catch-Finally & Try-with-Resources
✅ Custom Exceptions
✅ Spring Boot Exception Handling
✅ Advanced Patterns (Circuit Breaker, Metrics)
✅ 10 Interview Questions with Detailed Answers
✅ Interview Traps & Edge Cases
✅ 2 Complete Coding Problems
✅ Best Practices & Performance Tips

**Ready for interviews!** 🚀
