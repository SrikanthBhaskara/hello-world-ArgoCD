# JAVA TESTING & BUILD TOOLS INTERVIEW GUIDE

**Complete guide covering JUnit 5, Mockito, Spring Boot testing, integration testing, test strategies, Maven/Gradle, and best practices for senior developer interviews.**

---

# TABLE OF CONTENTS

1. [Testing Fundamentals](#1-testing-fundamentals)
2. [JUnit 5 Basics](#2-junit-5-basics)
3. [JUnit 5 Advanced Features](#3-junit-5-advanced-features)
4. [Mockito Fundamentals](#4-mockito-fundamentals)
5. [Mockito Advanced Features](#5-mockito-advanced-features)
6. [Spring Boot Testing](#6-spring-boot-testing)
7. [Integration Testing](#7-integration-testing)
8. [REST API Testing](#8-rest-api-testing)
9. [Database Testing](#9-database-testing)
10. [Test Containers](#10-test-containers)
11. [Code Coverage](#11-code-coverage)
12. [Testing Best Practices](#12-testing-best-practices)
13. [Maven](#13-maven)
14. [Gradle](#14-gradle)
15. [Interview Questions](#15-interview-questions)
16. [Interview Traps](#16-interview-traps)
17. [Coding Problems](#17-coding-problems)
18. [Summary & Quick Reference](#18-summary--quick-reference)

---

# 1. TESTING FUNDAMENTALS

## Test Pyramid

```
        /\
       /  \     E2E Tests (Few, Slow, Expensive)
      /____\
     /      \   Integration Tests (Some, Medium)
    /________\
   /          \ Unit Tests (Many, Fast, Cheap)
  /__________\
```

## Types of Testing

| **Type** | **Scope** | **Speed** | **Dependencies** |
|----------|-----------|-----------|------------------|
| **Unit Test** | Single class/method | Fast (ms) | Mock all dependencies |
| **Integration Test** | Multiple components | Medium (seconds) | Real dependencies |
| **E2E Test** | Full application | Slow (minutes) | Real system |

## AAA Pattern

```java
@Test
public void testCalculatorAdd() {
    // Arrange: Setup
    Calculator calculator = new Calculator();
    
    // Act: Execute
    int result = calculator.add(2, 3);
    
    // Assert: Verify
    assertEquals(5, result);
}
```

---

# 2. JUNIT 5 BASICS

## Dependency

```xml
<dependency>
    <groupId>org.junit.jupiter</groupId>
    <artifactId>junit-jupiter</artifactId>
    <version>5.9.2</version>
    <scope>test</scope>
</dependency>
```

## Basic Annotations

```java
import org.junit.jupiter.api.*;
import static org.junit.jupiter.api.Assertions.*;

public class CalculatorTest {
    
    private Calculator calculator;
    
    @BeforeAll
    static void setupAll() {
        // Runs once before all tests (must be static)
        System.out.println("Starting test suite");
    }
    
    @BeforeEach
    void setup() {
        // Runs before each test
        calculator = new Calculator();
    }
    
    @Test
    void testAdd() {
        assertEquals(5, calculator.add(2, 3));
    }
    
    @Test
    void testSubtract() {
        assertEquals(1, calculator.subtract(3, 2));
    }
    
    @Test
    @Disabled("Not implemented yet")
    void testDivide() {
        // Skipped
    }
    
    @AfterEach
    void tearDown() {
        // Runs after each test
        calculator = null;
    }
    
    @AfterAll
    static void tearDownAll() {
        // Runs once after all tests
        System.out.println("Test suite complete");
    }
}
```

## Assertions

```java
@Test
void testAssertions() {
    // Basic assertions
    assertEquals(4, 2 + 2);
    assertNotEquals(5, 2 + 2);
    assertTrue(5 > 3);
    assertFalse(5 < 3);
    assertNull(null);
    assertNotNull("Hello");
    
    // Array assertions
    assertArrayEquals(new int[]{1, 2, 3}, new int[]{1, 2, 3});
    
    // Object assertions
    String str1 = "Hello";
    String str2 = "Hello";
    assertSame(str1, str1);  // Same reference
    assertEquals(str1, str2);  // Equal value
    
    // Exception assertions
    assertThrows(IllegalArgumentException.class, () -> {
        calculator.divide(10, 0);
    });
    
    // Grouped assertions (all executed, all failures reported)
    assertAll("person",
        () -> assertEquals("John", person.getFirstName()),
        () -> assertEquals("Doe", person.getLastName()),
        () -> assertEquals(30, person.getAge())
    );
    
    // Timeout assertions
    assertTimeout(Duration.ofSeconds(1), () -> {
        // Code that should complete within 1 second
        Thread.sleep(500);
    });
    
    // Custom message
    assertEquals(5, calculator.add(2, 3), "2 + 3 should equal 5");
}
```

---

# 3. JUNIT 5 ADVANCED FEATURES

## Parameterized Tests

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
    
    @ParameterizedTest
    @CsvSource({
        "1, 1, 2",
        "2, 3, 5",
        "5, 5, 10"
    })
    void testAdd(int a, int b, int expected) {
        assertEquals(expected, calculator.add(a, b));
    }
    
    @ParameterizedTest
    @CsvFileSource(resources = "/test-data.csv", numLinesToSkip = 1)
    void testFromCsvFile(String input, String expected) {
        assertEquals(expected, process(input));
    }
    
    @ParameterizedTest
    @MethodSource("numberProvider")
    void testWithMethodSource(int number) {
        assertTrue(number > 0);
    }
    
    static Stream<Integer> numberProvider() {
        return Stream.of(1, 2, 3, 4, 5);
    }
    
    @ParameterizedTest
    @MethodSource("userProvider")
    void testUser(User user) {
        assertNotNull(user.getName());
        assertTrue(user.getAge() > 0);
    }
    
    static Stream<User> userProvider() {
        return Stream.of(
            new User("John", 25),
            new User("Jane", 30),
            new User("Bob", 40)
        );
    }
}
```

## Nested Tests

```java
@DisplayName("User Service Tests")
public class UserServiceTest {
    
    private UserService userService;
    
    @BeforeEach
    void setup() {
        userService = new UserService();
    }
    
    @Nested
    @DisplayName("When user is new")
    class WhenNew {
        
        @Test
        @DisplayName("Should save user successfully")
        void shouldSaveUser() {
            User user = new User("john@example.com");
            User saved = userService.save(user);
            assertNotNull(saved.getId());
        }
        
        @Test
        @DisplayName("Should throw exception for duplicate email")
        void shouldThrowForDuplicateEmail() {
            User user1 = new User("john@example.com");
            userService.save(user1);
            
            User user2 = new User("john@example.com");
            assertThrows(DuplicateEmailException.class, () -> {
                userService.save(user2);
            });
        }
    }
    
    @Nested
    @DisplayName("When user exists")
    class WhenExists {
        
        private User existingUser;
        
        @BeforeEach
        void setupExistingUser() {
            existingUser = userService.save(new User("john@example.com"));
        }
        
        @Test
        @DisplayName("Should update user successfully")
        void shouldUpdateUser() {
            existingUser.setName("John Updated");
            User updated = userService.update(existingUser);
            assertEquals("John Updated", updated.getName());
        }
        
        @Test
        @DisplayName("Should delete user successfully")
        void shouldDeleteUser() {
            userService.delete(existingUser.getId());
            assertFalse(userService.findById(existingUser.getId()).isPresent());
        }
    }
}
```

## Conditional Execution

```java
@Test
@EnabledOnOs(OS.LINUX)
void testOnLinux() {
    // Only runs on Linux
}

@Test
@EnabledOnJre(JRE.JAVA_17)
void testOnJava17() {
    // Only runs on Java 17
}

@Test
@EnabledIf("customCondition")
void testConditional() {
    // Runs if customCondition() returns true
}

boolean customCondition() {
    return System.getProperty("env").equals("dev");
}
```

---

# 4. MOCKITO FUNDAMENTALS

```xml
<dependency>
    <groupId>org.mockito</groupId>
    <artifactId>mockito-core</artifactId>
    <version>5.3.1</version>
    <scope>test</scope>
</dependency>
```

## Creating Mocks

```java
import static org.mockito.Mockito.*;

public class UserServiceTest {
    
    @Test
    void testWithMock() {
        // Create mock
        UserRepository mockRepository = mock(UserRepository.class);
        
        // Stub method behavior
        User user = new User(1L, "John");
        when(mockRepository.findById(1L)).thenReturn(Optional.of(user));
        
        // Use mock
        UserService service = new UserService(mockRepository);
        User found = service.findById(1L);
        
        // Verify
        assertEquals("John", found.getName());
        verify(mockRepository).findById(1L);
    }
}
```

## Using @Mock and @InjectMocks

```java
import org.mockito.Mock;
import org.mockito.InjectMocks;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
public class OrderServiceTest {
    
    @Mock
    private OrderRepository orderRepository;
    
    @Mock
    private PaymentService paymentService;
    
    @InjectMocks
    private OrderService orderService;  // Mocks injected automatically
    
    @Test
    void testCreateOrder() {
        // Arrange
        Order order = new Order();
        when(orderRepository.save(any(Order.class))).thenReturn(order);
        when(paymentService.processPayment(anyDouble())).thenReturn(true);
        
        // Act
        Order created = orderService.createOrder(order);
        
        // Assert
        assertNotNull(created);
        verify(orderRepository).save(order);
        verify(paymentService).processPayment(order.getAmount());
    }
}
```

## Stubbing

```java
@Test
void testStubbing() {
    UserRepository mock = mock(UserRepository.class);
    
    // Return value
    when(mock.findById(1L)).thenReturn(Optional.of(new User("John")));
    
    // Return different values on consecutive calls
    when(mock.count()).thenReturn(5L, 10L, 15L);
    assertEquals(5L, mock.count());
    assertEquals(10L, mock.count());
    assertEquals(15L, mock.count());
    
    // Throw exception
    when(mock.findById(999L)).thenThrow(new NotFoundException());
    
    // Answer (dynamic behavior)
    when(mock.findByName(anyString())).thenAnswer(invocation -> {
        String name = invocation.getArgument(0);
        return Optional.of(new User(name));
    });
    
    // Do nothing (for void methods)
    doNothing().when(mock).delete(any(User.class));
    
    // Default return for all calls
    when(mock.findAll()).thenReturn(List.of(new User("John")));
}
```

## Verification

```java
@Test
void testVerification() {
    UserRepository mock = mock(UserRepository.class);
    
    // Call methods
    mock.findById(1L);
    mock.findById(1L);
    mock.save(new User("John"));
    
    // Verify method called
    verify(mock).findById(1L);
    
    // Verify number of invocations
    verify(mock, times(2)).findById(1L);
    verify(mock, times(1)).save(any(User.class));
    verify(mock, never()).delete(any(User.class));
    verify(mock, atLeast(1)).findById(1L);
    verify(mock, atMost(3)).findById(1L);
    
    // Verify no more interactions
    verifyNoMoreInteractions(mock);
}
```

## Argument Matchers

```java
@Test
void testArgumentMatchers() {
    UserRepository mock = mock(UserRepository.class);
    
    // Any matcher
    when(mock.findById(anyLong())).thenReturn(Optional.of(new User()));
    when(mock.findByName(anyString())).thenReturn(Optional.of(new User()));
    when(mock.save(any(User.class))).thenReturn(new User());
    
    // Specific matchers
    when(mock.findByAge(gt(18))).thenReturn(List.of(new User()));
    when(mock.findByName(startsWith("John"))).thenReturn(Optional.of(new User()));
    
    // Custom matcher
    when(mock.save(argThat(user -> user.getAge() > 0))).thenReturn(new User());
    
    // Mix matcher with exact value (use eq())
    when(mock.findByNameAndAge(eq("John"), anyInt())).thenReturn(Optional.of(new User()));
}
```

---

# 5. MOCKITO ADVANCED FEATURES

## Capturing Arguments

```java
@Test
void testArgumentCaptor() {
    UserRepository mock = mock(UserRepository.class);
    UserService service = new UserService(mock);
    
    // Create argument captor
    ArgumentCaptor<User> userCaptor = ArgumentCaptor.forClass(User.class);
    
    // Execute
    service.createUser("John", "john@example.com");
    
    // Capture argument
    verify(mock).save(userCaptor.capture());
    
    // Verify captured value
    User capturedUser = userCaptor.getValue();
    assertEquals("John", capturedUser.getName());
    assertEquals("john@example.com", capturedUser.getEmail());
}
```

## Spying

```java
@Test
void testSpy() {
    // Spy on real object
    List<String> list = new ArrayList<>();
    List<String> spyList = spy(list);
    
    // Real method called
    spyList.add("one");
    spyList.add("two");
    
    assertEquals(2, spyList.size());
    assertTrue(spyList.contains("one"));
    
    // Stub specific method
    when(spyList.size()).thenReturn(100);
    assertEquals(100, spyList.size());  // Stubbed
    
    // Verify
    verify(spyList).add("one");
    verify(spyList, times(2)).add(anyString());
}
```

## BDD Style (Behavior Driven Development)

```java
import static org.mockito.BDDMockito.*;

@Test
void testBDDStyle() {
    // Given
    UserRepository repository = mock(UserRepository.class);
    User user = new User("John");
    given(repository.findById(1L)).willReturn(Optional.of(user));
    
    UserService service = new UserService(repository);
    
    // When
    User found = service.findById(1L);
    
    // Then
    then(repository).should().findById(1L);
    assertEquals("John", found.getName());
}
```

---

# 6. SPRING BOOT TESTING

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-test</artifactId>
    <scope>test</scope>
</dependency>
```

## @SpringBootTest (Full Application Context)

```java
@SpringBootTest
class UserServiceIntegrationTest {
    
    @Autowired
    private UserService userService;
    
    @Autowired
    private UserRepository userRepository;
    
    @Test
    void testCreateUser() {
        User user = new User("john@example.com");
        User saved = userService.create(user);
        
        assertNotNull(saved.getId());
        assertTrue(userRepository.findById(saved.getId()).isPresent());
    }
}
```

## @WebMvcTest (Controller Layer Only)

```java
@WebMvcTest(UserController.class)
class UserControllerTest {
    
    @Autowired
    private MockMvc mockMvc;
    
    @MockBean
    private UserService userService;
    
    @Test
    void testGetUser() throws Exception {
        // Given
        User user = new User(1L, "John", "john@example.com");
        when(userService.findById(1L)).thenReturn(Optional.of(user));
        
        // When & Then
        mockMvc.perform(get("/users/1"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.id").value(1))
            .andExpect(jsonPath("$.name").value("John"))
            .andExpect(jsonPath("$.email").value("john@example.com"));
        
        verify(userService).findById(1L);
    }
    
    @Test
    void testCreateUser() throws Exception {
        User user = new User(null, "John", "john@example.com");
        User saved = new User(1L, "John", "john@example.com");
        
        when(userService.create(any(User.class))).thenReturn(saved);
        
        mockMvc.perform(post("/users")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"name\":\"John\",\"email\":\"john@example.com\"}"))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.id").value(1))
            .andExpect(jsonPath("$.name").value("John"));
    }
}
```

## @DataJpaTest (Repository Layer Only)

```java
@DataJpaTest
class UserRepositoryTest {
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private TestEntityManager entityManager;
    
    @Test
    void testFindByEmail() {
        // Given
        User user = new User("John", "john@example.com");
        entityManager.persist(user);
        entityManager.flush();
        
        // When
        Optional<User> found = userRepository.findByEmail("john@example.com");
        
        // Then
        assertTrue(found.isPresent());
        assertEquals("John", found.get().getName());
    }
    
    @Test
    void testFindByAge() {
        // Given
        entityManager.persist(new User("John", 25));
        entityManager.persist(new User("Jane", 30));
        entityManager.persist(new User("Bob", 35));
        entityManager.flush();
        
        // When
        List<User> users = userRepository.findByAgeGreaterThan(28);
        
        // Then
        assertEquals(2, users.size());
    }
}
```

---

# 7. INTEGRATION TESTING

## @TestConfiguration

```java
@SpringBootTest
class OrderServiceIntegrationTest {
    
    @Autowired
    private OrderService orderService;
    
    @MockBean
    private PaymentService paymentService;  // Mock external service
    
    @TestConfiguration
    static class TestConfig {
        @Bean
        public EmailService emailService() {
            return new FakeEmailService();  // Use fake for testing
        }
    }
    
    @Test
    void testCreateOrder() {
        when(paymentService.processPayment(anyDouble())).thenReturn(true);
        
        Order order = orderService.createOrder(new OrderRequest());
        
        assertNotNull(order.getId());
        verify(paymentService).processPayment(order.getAmount());
    }
}
```

## Test Profiles

```yaml
# application-test.yml
spring:
  datasource:
    url: jdbc:h2:mem:testdb
    driver-class-name: org.h2.Driver
  jpa:
    hibernate:
      ddl-auto: create-drop
```

```java
@SpringBootTest
@ActiveProfiles("test")
class UserServiceTest {
    // Uses application-test.yml configuration
}
```

---

# 8. REST API TESTING

## MockMvc Examples

```java
@WebMvcTest(ProductController.class)
class ProductControllerTest {
    
    @Autowired
    private MockMvc mockMvc;
    
    @MockBean
    private ProductService productService;
    
    @Test
    void testGetAllProducts() throws Exception {
        List<Product> products = List.of(
            new Product(1L, "Product 1", 10.0),
            new Product(2L, "Product 2", 20.0)
        );
        
        when(productService.findAll()).thenReturn(products);
        
        mockMvc.perform(get("/products"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$", hasSize(2)))
            .andExpect(jsonPath("$[0].name").value("Product 1"))
            .andExpect(jsonPath("$[1].price").value(20.0));
    }
    
    @Test
    void testUpdateProduct() throws Exception {
        Product updated = new Product(1L, "Updated Product", 15.0);
        when(productService.update(eq(1L), any(Product.class))).thenReturn(updated);
        
        mockMvc.perform(put("/products/1")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"name\":\"Updated Product\",\"price\":15.0}"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.name").value("Updated Product"));
    }
    
    @Test
    void testDeleteProduct() throws Exception {
        doNothing().when(productService).delete(1L);
        
        mockMvc.perform(delete("/products/1"))
            .andExpect(status().isNoContent());
        
        verify(productService).delete(1L);
    }
    
    @Test
    void testNotFound() throws Exception {
        when(productService.findById(999L)).thenReturn(Optional.empty());
        
        mockMvc.perform(get("/products/999"))
            .andExpect(status().isNotFound());
    }
}
```

---

# 9. DATABASE TESTING

## H2 In-Memory Database

```xml
<dependency>
    <groupId>com.h2database</groupId>
    <artifactId>h2</artifactId>
    <scope>test</scope>
</dependency>
```

```yaml
# application-test.yml
spring:
  datasource:
    url: jdbc:h2:mem:testdb
  jpa:
    hibernate:
      ddl-auto: create-drop
    show-sql: true
```

## @Sql Annotation

```java
@DataJpaTest
class UserRepositoryTest {
    
    @Autowired
    private UserRepository userRepository;
    
    @Test
    @Sql("/test-data.sql")  // Execute SQL before test
    void testFindAll() {
        List<User> users = userRepository.findAll();
        assertEquals(5, users.size());
    }
    
    @Test
    @Sql(scripts = "/insert-users.sql", executionPhase = Sql.ExecutionPhase.BEFORE_TEST_METHOD)
    @Sql(scripts = "/cleanup.sql", executionPhase = Sql.ExecutionPhase.AFTER_TEST_METHOD)
    void testWithSetupAndCleanup() {
        // Test with data
    }
}
```

---

# 10. TEST CONTAINERS

**TestContainers** runs real Docker containers for integration tests.

```xml
<dependency>
    <groupId>org.testcontainers</groupId>
    <artifactId>testcontainers</artifactId>
    <version>1.18.3</version>
    <scope>test</scope>
</dependency>
<dependency>
    <groupId>org.testcontainers</groupId>
    <artifactId>postgresql</artifactId>
    <version>1.18.3</version>
    <scope>test</scope>
</dependency>
```

```java
@SpringBootTest
@Testcontainers
class UserRepositoryIntegrationTest {
    
    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:15")
        .withDatabaseName("testdb")
        .withUsername("test")
        .withPassword("test");
    
    @DynamicPropertySource
    static void configureProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", postgres::getJdbcUrl);
        registry.add("spring.datasource.username", postgres::getUsername);
        registry.add("spring.datasource.password", postgres::getPassword);
    }
    
    @Autowired
    private UserRepository userRepository;
    
    @Test
    void testSaveUser() {
        User user = new User("john@example.com");
        User saved = userRepository.save(user);
        assertNotNull(saved.getId());
    }
}
```

---

# 11. CODE COVERAGE

## JaCoCo

```xml
<plugin>
    <groupId>org.jacoco</groupId>
    <artifactId>jacoco-maven-plugin</artifactId>
    <version>0.8.10</version>
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
        <execution>
            <id>jacoco-check</id>
            <goals>
                <goal>check</goal>
            </goals>
            <configuration>
                <rules>
                    <rule>
                        <element>PACKAGE</element>
                        <limits>
                            <limit>
                                <counter>LINE</counter>
                                <value>COVEREDRATIO</value>
                                <minimum>0.80</minimum>
                            </limit>
                        </limits>
                    </rule>
                </rules>
            </configuration>
        </execution>
    </executions>
</plugin>
```

**Run:**
```bash
mvn clean test
# Report: target/site/jacoco/index.html
```

---

# 12. TESTING BEST PRACTICES

## FIRST Principles

```
F - Fast: Tests should run quickly
I - Independent: Tests don't depend on each other
R - Repeatable: Same result every time
S - Self-Validating: Pass or fail (no manual verification)
T - Timely: Written before or with production code
```

## Test Naming

```java
// ❌ BAD
@Test
void test1() { }

// ✅ GOOD
@Test
void shouldReturnUserWhenValidIdProvided() { }

@Test
void shouldThrowExceptionWhenUserNotFound() { }

// Common patterns:
// should<Expected>When<Condition>
// given<Condition>When<Action>Then<Result>
```

## Don't Test Implementation Details

```java
// ❌ BAD: Testing internal implementation
@Test
void testInternalMethod() {
    userService.internalHelperMethod();  // Private method
}

// ✅ GOOD: Test public behavior
@Test
void shouldCreateUserWithHashedPassword() {
    User user = userService.create("password123");
    assertNotEquals("password123", user.getPassword());  // Verify encrypted
}
```

---

# 13. MAVEN

## pom.xml Structure

```xml
<project>
    <modelVersion>4.0.0</modelVersion>
    
    <groupId>com.example</groupId>
    <artifactId>my-app</artifactId>
    <version>1.0.0</version>
    <packaging>jar</packaging>
    
    <properties>
        <maven.compiler.source>17</maven.compiler.source>
        <maven.compiler.target>17</maven.compiler.target>
        <spring.boot.version>3.1.0</spring.boot.version>
    </properties>
    
    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
            <version>${spring.boot.version}</version>
        </dependency>
        
        <dependency>
            <groupId>org.junit.jupiter</groupId>
            <artifactId>junit-jupiter</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>
    
    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
</project>
```

## Maven Lifecycle

```
clean → validate → compile → test → package → verify → install → deploy

mvn clean        # Delete target/
mvn compile      # Compile source code
mvn test         # Run tests
mvn package      # Create JAR/WAR
mvn install      # Install to local repository ~/.m2/
mvn deploy       # Deploy to remote repository
```

## Multi-Module Project

```xml
<!-- Parent pom.xml -->
<project>
    <groupId>com.example</groupId>
    <artifactId>parent-project</artifactId>
    <packaging>pom</packaging>
    
    <modules>
        <module>core</module>
        <module>web</module>
        <module>service</module>
    </modules>
</project>

<!-- core/pom.xml -->
<project>
    <parent>
        <groupId>com.example</groupId>
        <artifactId>parent-project</artifactId>
        <version>1.0.0</version>
    </parent>
    
    <artifactId>core</artifactId>
</project>
```

---

# 14. GRADLE

## build.gradle (Groovy)

```groovy
plugins {
    id 'java'
    id 'org.springframework.boot' version '3.1.0'
    id 'io.spring.dependency-management' version '1.1.0'
}

group = 'com.example'
version = '1.0.0'
sourceCompatibility = '17'

repositories {
    mavenCentral()
}

dependencies {
    implementation 'org.springframework.boot:spring-boot-starter-web'
    implementation 'org.springframework.boot:spring-boot-starter-data-jpa'
    runtimeOnly 'com.h2database:h2'
    
    testImplementation 'org.springframework.boot:spring-boot-starter-test'
}

test {
    useJUnitPlatform()
}
```

## Gradle Tasks

```bash
gradle clean        # Delete build/
gradle build        # Compile + test + package
gradle test         # Run tests
gradle bootRun      # Run Spring Boot application
gradle dependencies # Show dependency tree
```

## Maven vs Gradle

| **Aspect** | **Maven** | **Gradle** |
|------------|-----------|------------|
| **Configuration** | XML (pom.xml) | Groovy/Kotlin (build.gradle) |
| **Performance** | Slower | Faster (incremental builds) |
| **Flexibility** | Convention-based | Highly customizable |
| **Learning Curve** | Easier | Steeper |

---

# 15. INTERVIEW QUESTIONS

## Q1: What is the difference between @Mock, @MockBean, and @Spy?

**Answer:**

- **@Mock** (Mockito): Create mock object (unit tests)
- **@MockBean** (Spring): Replace Spring bean with mock (integration tests)
- **@Spy** (Mockito): Wrap real object, stub only specific methods

```java
@Mock
UserRepository mockRepo;  // Fully mocked

@MockBean
UserRepository mockBeanRepo;  // Replace Spring bean

@Spy
UserRepository spyRepo = new UserRepositoryImpl();  // Real object, partial mock
```

---

## Q2: Explain test slicing in Spring Boot.

**Answer:** Load only specific parts of application context.

- **@WebMvcTest**: Controllers + Web layer only
- **@DataJpaTest**: JPA repositories + database only
- **@RestClientTest**: REST clients only
- **@JsonTest**: JSON serialization only

**Benefit:** Faster tests, focused testing

---

## Q3: How do you test asynchronous methods?

```java
@Service
public class EmailService {
    
    @Async
    public CompletableFuture<String> sendEmail(String to) {
        // Send email
        return CompletableFuture.completedFuture("Sent");
    }
}

@SpringBootTest
class EmailServiceTest {
    
    @Autowired
    private EmailService emailService;
    
    @Test
    void testAsyncEmail() throws Exception {
        CompletableFuture<String> future = emailService.sendEmail("test@example.com");
        
        // Wait for completion
        String result = future.get(5, TimeUnit.SECONDS);
        
        assertEquals("Sent", result);
    }
}
```

---

# 16. INTERVIEW TRAPS

## Trap: Testing private methods

❌ **Wrong:** "I need to test private methods"

✅ **Right:** Test public methods that call private methods. Private methods are implementation details.

---

## Trap: Using real database for unit tests

❌ **Wrong:** Connect to MySQL for unit tests

✅ **Right:** Use H2 in-memory or mocks for unit tests. Real database for integration tests only.

---

# 17. CODING PROBLEMS

## Problem: Test exception handling in controller

```java
@RestController
@RequestMapping("/users")
public class UserController {
    
    @Autowired
    private UserService userService;
    
    @GetMapping("/{id}")
    public ResponseEntity<User> getUser(@PathVariable Long id) {
        return userService.findById(id)
            .map(ResponseEntity::ok)
            .orElseThrow(() -> new UserNotFoundException(id));
    }
}

@ControllerAdvice
public class GlobalExceptionHandler {
    
    @ExceptionHandler(UserNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleUserNotFound(UserNotFoundException ex) {
        ErrorResponse error = new ErrorResponse("User not found: " + ex.getId());
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(error);
    }
}

// Test
@WebMvcTest(UserController.class)
class UserControllerExceptionTest {
    
    @Autowired
    private MockMvc mockMvc;
    
    @MockBean
    private UserService userService;
    
    @Test
    void shouldReturn404WhenUserNotFound() throws Exception {
        when(userService.findById(999L)).thenReturn(Optional.empty());
        
        mockMvc.perform(get("/users/999"))
            .andExpect(status().isNotFound())
            .andExpect(jsonPath("$.message").value("User not found: 999"));
    }
}
```

---

# 18. SUMMARY & QUICK REFERENCE

## Testing Annotations

| **Annotation** | **Purpose** | **Loads** |
|----------------|-------------|-----------|
| `@SpringBootTest` | Full integration test | Full app context |
| `@WebMvcTest` | Controller test | Web layer only |
| `@DataJpaTest` | Repository test | JPA layer only |
| `@Mock` | Mockito mock | Nothing |
| `@MockBean` | Spring mock bean | Replace bean in context |

## Assertion Quick Reference

```java
assertEquals(expected, actual)
assertNotEquals(unexpected, actual)
assertTrue(condition)
assertFalse(condition)
assertNull(object)
assertNotNull(object)
assertThrows(Exception.class, () -> { })
assertAll(() -> { }, () -> { })
```

## Maven vs Gradle

```bash
# Maven
mvn clean install
mvn test
mvn package

# Gradle
gradle clean build
gradle test
gradle bootJar
```

---

**END OF TESTING & BUILD TOOLS INTERVIEW GUIDE**

**🎉 ALL 5 COMPREHENSIVE JAVA INTERVIEW GUIDES COMPLETE! 🎉**

**Complete Series:**
1. ✅ Spring Framework & Spring Boot
2. ✅ Database & JPA/Hibernate
3. ✅ Design Patterns
4. ✅ Microservices Architecture
5. ✅ Testing & Build Tools

Master these guides to ace Java interviews from junior to senior level!
