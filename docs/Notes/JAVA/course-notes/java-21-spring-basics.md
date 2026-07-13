# Spring Framework Basics

## What is Spring?

Spring is a comprehensive framework for enterprise Java development, providing:
- **Dependency Injection (DI)**: Manage object dependencies
- **Spring MVC**: Web application framework
- **Spring Boot**: Rapid application development
- **Spring Data**: Database access
- **Spring Security**: Authentication and authorization

## Spring Boot Setup

### Maven pom.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0">
    <modelVersion>4.0.0</modelVersion>
    
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.2.0</version>
    </parent>
    
    <groupId>com.example</groupId>
    <artifactId>demo</artifactId>
    <version>1.0.0</version>
    
    <properties>
        <java.version>17</java.version>
    </properties>
    
    <dependencies>
        <!-- Spring Boot Web -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        
        <!-- Spring Boot Data JPA -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-jpa</artifactId>
        </dependency>
        
        <!-- H2 Database (in-memory) -->
        <dependency>
            <groupId>com.h2database</groupId>
            <artifactId>h2</artifactId>
            <scope>runtime</scope>
        </dependency>
        
        <!-- Lombok (optional) -->
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <optional>true</optional>
        </dependency>
        
        <!-- Spring Boot Test -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
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

### Main Application

```java
package com.example.demo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class DemoApplication {
    public static void main(String[] args) {
        SpringApplication.run(DemoApplication.class, args);
    }
}
```

## Dependency Injection

### Constructor Injection (Recommended)

```java
import org.springframework.stereotype.Service;
import org.springframework.stereotype.Component;

@Service
public class UserService {
    private final UserRepository repository;
    
    // Constructor injection
    public UserService(UserRepository repository) {
        this.repository = repository;
    }
    
    public User findUser(Long id) {
        return repository.findById(id);
    }
}

@Component
public class UserRepository {
    public User findById(Long id) {
        // Database logic
        return new User(id, "John");
    }
}
```

### Field Injection (Not Recommended)

```java
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class UserService {
    @Autowired
    private UserRepository repository;  // Field injection
    
    public User findUser(Long id) {
        return repository.findById(id);
    }
}
```

### @Component Annotations

```java
@Component      // Generic component
@Service        // Business logic layer
@Repository     // Data access layer
@Controller     // Web controller (returns views)
@RestController // REST API controller (returns JSON)
```

## REST API with Spring

### Simple REST Controller

```java
import org.springframework.web.bind.annotation.*;
import java.util.*;

@RestController
@RequestMapping("/api/users")
public class UserController {
    private final UserService userService;
    
    public UserController(UserService userService) {
        this.userService = userService;
    }
    
    // GET /api/users
    @GetMapping
    public List<User> getAllUsers() {
        return userService.findAll();
    }
    
    // GET /api/users/1
    @GetMapping("/{id}")
    public User getUser(@PathVariable Long id) {
        return userService.findById(id);
    }
    
    // POST /api/users
    @PostMapping
    public User createUser(@RequestBody User user) {
        return userService.save(user);
    }
    
    // PUT /api/users/1
    @PutMapping("/{id}")
    public User updateUser(@PathVariable Long id, @RequestBody User user) {
        return userService.update(id, user);
    }
    
    // DELETE /api/users/1
    @DeleteMapping("/{id}")
    public void deleteUser(@PathVariable Long id) {
        userService.delete(id);
    }
}
```

### Request Parameters and Path Variables

```java
@RestController
@RequestMapping("/api")
public class ApiController {
    // Path variable: /api/users/123
    @GetMapping("/users/{id}")
    public User getUser(@PathVariable Long id) {
        return new User(id, "John");
    }
    
    // Query parameter: /api/search?name=John
    @GetMapping("/search")
    public List<User> search(@RequestParam String name) {
        return userService.findByName(name);
    }
    
    // Multiple parameters: /api/users?age=25&city=NYC
    @GetMapping("/users")
    public List<User> filter(
        @RequestParam(required = false) Integer age,
        @RequestParam(required = false) String city
    ) {
        return userService.filter(age, city);
    }
    
    // Request body
    @PostMapping("/users")
    public User create(@RequestBody User user) {
        return userService.save(user);
    }
}
```

## Entity and Repository (Spring Data JPA)

### Entity Class

```java
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "users")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false)
    private String name;
    
    @Column(unique = true)
    private String email;
    
    private Integer age;
}
```

### Repository Interface

```java
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    // Spring Data automatically implements these based on method name
    
    Optional<User> findByEmail(String email);
    
    List<User> findByName(String name);
    
    List<User> findByAgeGreaterThan(Integer age);
    
    List<User> findByNameAndAge(String name, Integer age);
    
    List<User> findByNameContaining(String keyword);
    
    List<User> findByEmailStartingWith(String prefix);
    
    Long countByAge(Integer age);
    
    boolean existsByEmail(String email);
    
    void deleteByEmail(String email);
    
    // Custom query
    @Query("SELECT u FROM User u WHERE u.age > ?1")
    List<User> findUsersOlderThan(Integer age);
    
    @Query("SELECT u FROM User u WHERE u.name = :name AND u.age = :age")
    List<User> findByNameAndAge(@Param("name") String name, @Param("age") Integer age);
}
```

### Service Layer

```java
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;

@Service
@Transactional
public class UserService {
    private final UserRepository repository;
    
    public UserService(UserRepository repository) {
        this.repository = repository;
    }
    
    public List<User> findAll() {
        return repository.findAll();
    }
    
    public User findById(Long id) {
        return repository.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("User not found"));
    }
    
    public User save(User user) {
        if (repository.existsByEmail(user.getEmail())) {
            throw new DuplicateEmailException("Email already exists");
        }
        return repository.save(user);
    }
    
    public User update(Long id, User userDetails) {
        User user = findById(id);
        user.setName(userDetails.getName());
        user.setEmail(userDetails.getEmail());
        user.setAge(userDetails.getAge());
        return repository.save(user);
    }
    
    public void delete(Long id) {
        User user = findById(id);
        repository.delete(user);
    }
}
```

## Configuration

### application.properties

```properties
# Server
server.port=8080

# Database (H2 in-memory)
spring.datasource.url=jdbc:h2:mem:testdb
spring.datasource.driverClassName=org.h2.Driver
spring.datasource.username=sa
spring.datasource.password=

# JPA/Hibernate
spring.jpa.database-platform=org.hibernate.dialect.H2Dialect
spring.jpa.hibernate.ddl-auto=create-drop
spring.jpa.show-sql=true

# H2 Console
spring.h2.console.enabled=true
spring.h2.console.path=/h2-console

# Logging
logging.level.org.springframework=INFO
logging.level.com.example=DEBUG
```

### application.yml (Alternative)

```yaml
server:
  port: 8080

spring:
  datasource:
    url: jdbc:h2:mem:testdb
    username: sa
    password:
  jpa:
    hibernate:
      ddl-auto: create-drop
    show-sql: true
  h2:
    console:
      enabled: true

logging:
  level:
    org.springframework: INFO
    com.example: DEBUG
```

## Exception Handling

### Global Exception Handler

```java
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;

@RestControllerAdvice
public class GlobalExceptionHandler {
    
    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleNotFound(ResourceNotFoundException ex) {
        ErrorResponse error = new ErrorResponse(
            HttpStatus.NOT_FOUND.value(),
            ex.getMessage(),
            System.currentTimeMillis()
        );
        return new ResponseEntity<>(error, HttpStatus.NOT_FOUND);
    }
    
    @ExceptionHandler(DuplicateEmailException.class)
    public ResponseEntity<ErrorResponse> handleDuplicate(DuplicateEmailException ex) {
        ErrorResponse error = new ErrorResponse(
            HttpStatus.CONFLICT.value(),
            ex.getMessage(),
            System.currentTimeMillis()
        );
        return new ResponseEntity<>(error, HttpStatus.CONFLICT);
    }
    
    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleGeneral(Exception ex) {
        ErrorResponse error = new ErrorResponse(
            HttpStatus.INTERNAL_SERVER_ERROR.value(),
            "Internal server error",
            System.currentTimeMillis()
        );
        return new ResponseEntity<>(error, HttpStatus.INTERNAL_SERVER_ERROR);
    }
}

@Data
@AllArgsConstructor
class ErrorResponse {
    private int status;
    private String message;
    private long timestamp;
}

class ResourceNotFoundException extends RuntimeException {
    public ResourceNotFoundException(String message) {
        super(message);
    }
}
```

## Validation

### Bean Validation

```java
import jakarta.validation.constraints.*;

@Data
public class UserDTO {
    @NotNull(message = "Name cannot be null")
    @Size(min = 2, max = 50, message = "Name must be between 2 and 50 characters")
    private String name;
    
    @Email(message = "Invalid email format")
    @NotBlank(message = "Email is required")
    private String email;
    
    @Min(value = 18, message = "Age must be at least 18")
    @Max(value = 100, message = "Age must be less than 100")
    private Integer age;
    
    @Pattern(regexp = "^\\+?[0-9]{10,}$", message = "Invalid phone number")
    private String phone;
}

@RestController
@RequestMapping("/api/users")
public class UserController {
    
    @PostMapping
    public User create(@Valid @RequestBody UserDTO userDTO) {
        // If validation fails, throws MethodArgumentNotValidException
        return userService.create(userDTO);
    }
}
```

## Response Status

```java
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
public class UserController {
    
    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public User create(@RequestBody User user) {
        return userService.save(user);
    }
    
    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable Long id) {
        userService.delete(id);
    }
    
    // With ResponseEntity
    @GetMapping("/{id}")
    public ResponseEntity<User> getUser(@PathVariable Long id) {
        User user = userService.findById(id);
        if (user != null) {
            return ResponseEntity.ok(user);
        } else {
            return ResponseEntity.notFound().build();
        }
    }
    
    @PostMapping
    public ResponseEntity<User> create(@RequestBody User user) {
        User created = userService.save(user);
        return ResponseEntity
            .status(HttpStatus.CREATED)
            .body(created);
    }
}
```

## Testing Spring Applications

### Unit Test (Service Layer)

```java
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import static org.mockito.Mockito.*;
import static org.junit.jupiter.api.Assertions.*;

@ExtendWith(MockitoExtension.class)
class UserServiceTest {
    @Mock
    private UserRepository repository;
    
    @InjectMocks
    private UserService service;
    
    @Test
    void testFindById() {
        User user = new User(1L, "John", "john@email.com", 30);
        when(repository.findById(1L)).thenReturn(Optional.of(user));
        
        User result = service.findById(1L);
        
        assertEquals("John", result.getName());
        verify(repository).findById(1L);
    }
}
```

### Integration Test (Controller)

```java
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.web.servlet.MockMvc;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;
import static org.mockito.Mockito.*;

@WebMvcTest(UserController.class)
class UserControllerTest {
    @Autowired
    private MockMvc mockMvc;
    
    @MockBean
    private UserService service;
    
    @Test
    void testGetUser() throws Exception {
        User user = new User(1L, "John", "john@email.com", 30);
        when(service.findById(1L)).thenReturn(user);
        
        mockMvc.perform(get("/api/users/1"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.name").value("John"))
            .andExpect(jsonPath("$.email").value("john@email.com"));
    }
}
```

## Quick Reference

```java
// Annotations
@SpringBootApplication  // Main application class
@RestController        // REST API controller
@Service               // Business logic
@Repository            // Data access
@Component             // Generic Spring bean
@Autowired             // Dependency injection (not recommended)

// REST mappings
@GetMapping            // HTTP GET
@PostMapping           // HTTP POST
@PutMapping            // HTTP PUT
@DeleteMapping         // HTTP DELETE
@RequestMapping        // Base path

// Request/Response
@PathVariable          // URL path parameter
@RequestParam          // Query parameter
@RequestBody           // Request body (JSON)
@ResponseStatus        // HTTP status code
@Valid                 // Validation

// JPA
@Entity                // JPA entity
@Id                    // Primary key
@GeneratedValue        // Auto-generate ID
@Column                // Column mapping
@OneToMany, @ManyToOne // Relationships

// Exception handling
@RestControllerAdvice  // Global exception handler
@ExceptionHandler      // Handle specific exception
```

## Running the Application

```bash
# Maven
mvn spring-boot:run

# Or build and run JAR
mvn clean package
java -jar target/demo-1.0.0.jar

# Access
http://localhost:8080/api/users
http://localhost:8080/h2-console
```

---

**Previous**: [← Design Patterns](java-20-design-patterns.md) | **Next**: [Best Practices →](java-30-best-practices.md)
