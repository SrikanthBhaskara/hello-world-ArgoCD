# Java Testing with JUnit

## JUnit 5 Basics

### First Test

```java
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

public class CalculatorTest {
    @Test
    void testAddition() {
        Calculator calc = new Calculator();
        int result = calc.add(2, 3);
        assertEquals(5, result);
    }
    
    @Test
    void testSubtraction() {
        Calculator calc = new Calculator();
        assertEquals(2, calc.subtract(5, 3));
    }
}

class Calculator {
    public int add(int a, int b) { return a + b; }
    public int subtract(int a, int b) { return a - b; }
    public int multiply(int a, int b) { return a * b; }
    public int divide(int a, int b) { return a / b; }
}
```

### Assertions

```java
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

public class AssertionsTest {
    @Test
    void assertionsDemo() {
        // Equality
        assertEquals(5, 2 + 3);
        assertEquals("Hello", "Hello");
        assertNotEquals(5, 3);
        
        // Boolean
        assertTrue(5 > 3);
        assertFalse(5 < 3);
        
        // Null
        String str = null;
        assertNull(str);
        str = "Not null";
        assertNotNull(str);
        
        // Same/Not same (reference equality)
        String s1 = new String("test");
        String s2 = new String("test");
        assertEquals(s1, s2);      // Value equality
        assertNotSame(s1, s2);     // Reference inequality
        
        // Arrays
        int[] expected = {1, 2, 3};
        int[] actual = {1, 2, 3};
        assertArrayEquals(expected, actual);
        
        // Exceptions
        assertThrows(ArithmeticException.class, () -> {
            int result = 10 / 0;
        });
        
        Exception ex = assertThrows(IllegalArgumentException.class, () -> {
            throw new IllegalArgumentException("Invalid argument");
        });
        assertEquals("Invalid argument", ex.getMessage());
        
        // Timeout
        assertTimeout(Duration.ofSeconds(2), () -> {
            Thread.sleep(1000);  // Should complete within 2 seconds
        });
        
        // All assertions
        assertAll("person",
            () -> assertEquals("John", person.getName()),
            () -> assertEquals(30, person.getAge())
        );
    }
}
```

## Test Lifecycle

### @BeforeEach and @AfterEach

```java
import org.junit.jupiter.api.*;

public class LifecycleTest {
    private StringBuilder output;
    
    @BeforeAll  // Runs once before all tests
    static void setupAll() {
        System.out.println("@BeforeAll - runs once");
    }
    
    @BeforeEach  // Runs before each test
    void setUp() {
        output = new StringBuilder();
        System.out.println("@BeforeEach - runs before each test");
    }
    
    @Test
    void test1() {
        output.append("test1");
        assertTrue(output.toString().contains("test1"));
    }
    
    @Test
    void test2() {
        output.append("test2");
        assertTrue(output.toString().contains("test2"));
    }
    
    @AfterEach  // Runs after each test
    void tearDown() {
        output = null;
        System.out.println("@AfterEach - runs after each test");
    }
    
    @AfterAll  // Runs once after all tests
    static void tearDownAll() {
        System.out.println("@AfterAll - runs once");
    }
}
```

## Test Organization

### @DisplayName

```java
import org.junit.jupiter.api.*;

@DisplayName("Calculator Tests")
public class CalculatorTest {
    
    @Test
    @DisplayName("Addition of two positive numbers")
    void testAddPositive() {
        assertEquals(5, new Calculator().add(2, 3));
    }
    
    @Test
    @DisplayName("Division by zero throws exception")
    void testDivideByZero() {
        assertThrows(ArithmeticException.class, () -> {
            new Calculator().divide(10, 0);
        });
    }
}
```

### @Nested Tests

```java
import org.junit.jupiter.api.*;

@DisplayName("String Tests")
public class StringTest {
    
    @Nested
    @DisplayName("Tests for empty strings")
    class EmptyStrings {
        @Test
        void isEmpty() {
            assertTrue("".isEmpty());
        }
        
        @Test
        void lengthIsZero() {
            assertEquals(0, "".length());
        }
    }
    
    @Nested
    @DisplayName("Tests for non-empty strings")
    class NonEmptyStrings {
        @Test
        void isNotEmpty() {
            assertFalse("Hello".isEmpty());
        }
        
        @Test
        void lengthGreaterThanZero() {
            assertTrue("Hello".length() > 0);
        }
    }
}
```

## Parameterized Tests

### @ValueSource

```java
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.*;

public class ParameterizedTests {
    @ParameterizedTest
    @ValueSource(ints = {1, 2, 3, 4, 5})
    void testIsPositive(int number) {
        assertTrue(number > 0);
    }
    
    @ParameterizedTest
    @ValueSource(strings = {"", "  ", "\t", "\n"})
    void testIsBlank(String input) {
        assertTrue(input.isBlank());
    }
}
```

### @CsvSource

```java
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;

public class CsvSourceTest {
    @ParameterizedTest
    @CsvSource({
        "1, 1, 2",
        "2, 3, 5",
        "5, 7, 12"
    })
    void testAdd(int a, int b, int expected) {
        assertEquals(expected, new Calculator().add(a, b));
    }
    
    @ParameterizedTest
    @CsvSource({
        "apple, 5",
        "banana, 6",
        "cherry, 6"
    })
    void testStringLength(String word, int length) {
        assertEquals(length, word.length());
    }
}
```

### @MethodSource

```java
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.MethodSource;
import java.util.stream.Stream;

public class MethodSourceTest {
    @ParameterizedTest
    @MethodSource("provideStrings")
    void testIsNotEmpty(String str) {
        assertFalse(str.isEmpty());
    }
    
    static Stream<String> provideStrings() {
        return Stream.of("apple", "banana", "cherry");
    }
    
    @ParameterizedTest
    @MethodSource("provideArguments")
    void testAdd(int a, int b, int expected) {
        assertEquals(expected, new Calculator().add(a, b));
    }
    
    static Stream<Arguments> provideArguments() {
        return Stream.of(
            Arguments.of(1, 1, 2),
            Arguments.of(2, 3, 5),
            Arguments.of(5, 7, 12)
        );
    }
}
```

## Mocking with Mockito

### Basic Mocking

```java
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;
import static org.mockito.Mockito.*;
import static org.junit.jupiter.api.Assertions.*;

interface UserRepository {
    User findById(int id);
    void save(User user);
}

class UserService {
    private UserRepository repository;
    
    public UserService(UserRepository repository) {
        this.repository = repository;
    }
    
    public User getUser(int id) {
        return repository.findById(id);
    }
}

public class MockitoTest {
    @Test
    void testGetUser() {
        // Create mock
        UserRepository mockRepo = mock(UserRepository.class);
        
        // Define behavior
        User user = new User(1, "John");
        when(mockRepo.findById(1)).thenReturn(user);
        
        // Use mock
        UserService service = new UserService(mockRepo);
        User result = service.getUser(1);
        
        // Verify
        assertEquals("John", result.getName());
        verify(mockRepo).findById(1);  // Verify method was called
    }
}
```

### @Mock and @InjectMocks

```java
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
public class AnnotationMockTest {
    @Mock
    private UserRepository repository;
    
    @InjectMocks
    private UserService service;  // Automatically injects mocks
    
    @Test
    void testGetUser() {
        User user = new User(1, "John");
        when(repository.findById(1)).thenReturn(user);
        
        User result = service.getUser(1);
        
        assertEquals("John", result.getName());
        verify(repository).findById(1);
    }
}
```

### Stubbing Methods

```java
import static org.mockito.Mockito.*;

public class StubbingTest {
    @Test
    void stubbingExamples() {
        List<String> mockList = mock(List.class);
        
        // Return value
        when(mockList.get(0)).thenReturn("first");
        when(mockList.get(1)).thenReturn("second");
        
        assertEquals("first", mockList.get(0));
        assertEquals("second", mockList.get(1));
        
        // Throw exception
        when(mockList.get(2)).thenThrow(new IndexOutOfBoundsException());
        
        assertThrows(IndexOutOfBoundsException.class, () -> {
            mockList.get(2);
        });
        
        // Multiple calls
        when(mockList.size())
            .thenReturn(1)
            .thenReturn(2)
            .thenReturn(3);
        
        assertEquals(1, mockList.size());
        assertEquals(2, mockList.size());
        assertEquals(3, mockList.size());
        
        // Argument matchers
        when(mockList.get(anyInt())).thenReturn("element");
        assertEquals("element", mockList.get(100));
        
        // Answer
        when(mockList.get(anyInt())).thenAnswer(invocation -> {
            int index = invocation.getArgument(0);
            return "Element at " + index;
        });
    }
}
```

### Verification

```java
import static org.mockito.Mockito.*;

public class VerificationTest {
    @Test
    void verificationExamples() {
        List<String> mockList = mock(List.class);
        
        mockList.add("one");
        mockList.add("two");
        mockList.add("two");
        mockList.clear();
        
        // Verify method calls
        verify(mockList).add("one");
        verify(mockList, times(2)).add("two");
        verify(mockList, times(1)).clear();
        verify(mockList, never()).remove("one");
        verify(mockList, atLeast(1)).add(anyString());
        verify(mockList, atMost(3)).add(anyString());
        
        // Verify order
        InOrder inOrder = inOrder(mockList);
        inOrder.verify(mockList).add("one");
        inOrder.verify(mockList).add("two");
        inOrder.verify(mockList).clear();
        
        // Verify no more interactions
        verifyNoMoreInteractions(mockList);
    }
}
```

## Test-Driven Development (TDD)

### TDD Example: String Calculator

```java
// Step 1: Write failing test
@Test
void emptyStringShouldReturnZero() {
    StringCalculator calc = new StringCalculator();
    assertEquals(0, calc.add(""));
}

// Step 2: Write minimal code to pass
class StringCalculator {
    public int add(String numbers) {
        return 0;
    }
}

// Step 3: Write next test
@Test
void singleNumberShouldReturnItself() {
    StringCalculator calc = new StringCalculator();
    assertEquals(5, calc.add("5"));
}

// Step 4: Implement
class StringCalculator {
    public int add(String numbers) {
        if (numbers.isEmpty()) {
            return 0;
        }
        return Integer.parseInt(numbers);
    }
}

// Step 5: Continue with more tests
@Test
void twoNumbersShouldReturnSum() {
    StringCalculator calc = new StringCalculator();
    assertEquals(8, calc.add("3,5"));
}

// Final implementation
class StringCalculator {
    public int add(String numbers) {
       if (numbers.isEmpty()) {
            return 0;
        }
        String[] nums = numbers.split(",");
        return Arrays.stream(nums)
            .mapToInt(Integer::parseInt)
            .sum();
    }
}
```

## Integration Testing

### Testing with Database (in-memory H2)

```java
import org.junit.jupiter.api.*;
import java.sql.*;

public class DatabaseTest {
    private Connection connection;
    
    @BeforeEach
    void setUp() throws SQLException {
        // In-memory H2 database
        connection = DriverManager.getConnection(
            "jdbc:h2:mem:testdb", "sa", ""
        );
        
        // Create table
        Statement stmt = connection.createStatement();
        stmt.execute("CREATE TABLE users (id INT PRIMARY KEY, name VARCHAR(50))");
    }
    
    @Test
    void testInsertAndSelect() throws SQLException {
        // Insert
        PreparedStatement insert = connection.prepareStatement(
            "INSERT INTO users VALUES (?, ?)"
        );
        insert.setInt(1, 1);
        insert.setString(2, "John");
        insert.executeUpdate();
        
        // Select
        Statement select = connection.createStatement();
        ResultSet rs = select.executeQuery("SELECT * FROM users WHERE id = 1");
        
        assertTrue(rs.next());
        assertEquals("John", rs.getString("name"));
    }
    
    @AfterEach
    void tearDown() throws SQLException {
        connection.close();
    }
}
```

## Test Coverage

### Running with Maven

```xml
<!-- pom.xml -->
<build>
    <plugins>
        <plugin>
            <groupId>org.jacoco</groupId>
            <artifactId>jacoco-maven-plugin</artifactId>
            <version>0.8.11</version>
            <executions>
                <execution>
                    <goals>
                        <goal>prepare-agent</goal>
                    </goals>
                </execution>
                <execution>
                    <id>report</id>
                    <phase>test</phase>
                    <goals>
                        <goal>report</goal>
                    </goals>
                </execution>
            </executions>
        </plugin>
    </plugins>
</build>
```

```bash
# Run tests with coverage
mvn clean test

# View report at: target/site/jacoco/index.html
```

## Best Practices

### Good Test Principles

```java
public class GoodTestPrinciples {
    // 1. Independent tests (no shared state)
    @Test
    void testA() {
        List<String> list = new ArrayList<>();
        list.add("item");
        assertEquals(1, list.size());
    }
    
    @Test
    void testB() {
        List<String> list = new ArrayList<>();  // New instance
        assertEquals(0, list.size());
    }
    
    // 2. Clear test names
    @Test
    void should_ReturnEmptyList_When_NoItemsMatch() {
        // Test code
    }
    
    // 3. Arrange-Act-Assert pattern
    @Test
    void testCalculation() {
        // Arrange
        Calculator calc = new Calculator();
        int a = 5, b = 3;
        
        // Act
        int result = calc.add(a, b);
        
        // Assert
        assertEquals(8, result);
    }
    
    // 4. One assertion concept per test
    @Test
    void testPositiveNumber() {
        int number = 5;
        assertTrue(number > 0);
    }
    
    @Test
    void testEvenNumber() {
        int number = 4;
        assertEquals(0, number % 2);
    }
}
```

## Quick Reference

```java
// JUnit 5
@Test                    // Test method
@BeforeEach             // Before each test
@AfterEach              // After each test
@BeforeAll              // Before all tests (static)
@AfterAll               // After all tests (static)
@DisplayName("name")    // Custom test name
@Disabled               // Skip test
@Nested                 // Nested test class

// Assertions
assertEquals(expected, actual)
assertNotEquals(a, b)
assertTrue(condition)
assertFalse(condition)
assertNull(object)
assertNotNull(object)
assertSame(o1, o2)
assertNotSame(o1, o2)
assertArrayEquals(expected, actual)
assertThrows(Exception.class, () -> {...})
assertTimeout(duration, () -> {...})
assertAll(() -> {...}, () -> {...})

// Parameterized
@ParameterizedTest
@ValueSource(ints = {1, 2, 3})
@CsvSource({"a,1", "b,2"})
@MethodSource("methodName")

// Mockito
mock(Class.class)
when(mock.method()).thenReturn(value)
verify(mock).method()
verify(mock, times(n)).method()
@Mock, @InjectMocks
```

## Maven Dependencies

```xml
<dependencies>
    <!-- JUnit 5 -->
    <dependency>
        <groupId>org.junit.jupiter</groupId>
        <artifactId>junit-jupiter</artifactId>
        <version>5.10.0</version>
        <scope>test</scope>
    </dependency>
    
    <!-- Mockito -->
    <dependency>
        <groupId>org.mockito</groupId>
        <artifactId>mockito-core</artifactId>
        <version>5.5.0</version>
        <scope>test</scope>
    </dependency>
    
    <!-- Mockito JUnit Integration -->
    <dependency>
        <groupId>org.mockito</groupId>
        <artifactId>mockito-junit-jupiter</artifactId>
        <version>5.5.0</version>
        <scope>test</scope>
    </dependency>
</dependencies>
```

---

**Previous**: [← Concurrency](java-15-concurrency.md) | **Next**: [Design Patterns →](java-20-design-patterns.md)
