# Spring Web MVC

## Spring MVC Architecture

```
Request Flow:
Client → DispatcherServlet → HandlerMapping → Controller → Service → Repository → Database
         ↓                                         ↓
     ViewResolver ← View ← Model ← ─────────────────┘
```

## REST API Development

### Simple REST Controller

```java
import org.springframework.web.bind.annotation.*;
import org.springframework.http.*;
import java.util.*;

@RestController
@RequestMapping("/api/products")
public class ProductController {
    private final ProductService productService;
    
    public ProductController(ProductService productService) {
        this.productService = productService;
    }
    
    @GetMapping
    public List<Product> getAllProducts() {
        return productService.findAll();
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<Product> getProduct(@PathVariable Long id) {
        return productService.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }
    
    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public Product createProduct(@RequestBody @Valid Product product) {
        return productService.save(product);
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<Product> updateProduct(
        @PathVariable Long id,
        @RequestBody @Valid Product product
    ) {
        return productService.update(id, product)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }
    
    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteProduct(@PathVariable Long id) {
        productService.delete(id);
    }
}
```

### Request/Response Handling

```java
@RestController
@RequestMapping("/api/users")
public class UserController {
    
    // Path variable: /api/users/123
    @GetMapping("/{id}")
    public User getUser(@PathVariable Long id) {
        return userService.findById(id);
    }
    
    // Query parameters: /api/users?name=John&age=25
    @GetMapping
    public List<User> searchUsers(
        @RequestParam(required = false) String name,
        @RequestParam(required = false) Integer age
    ) {
        return userService.search(name, age);
    }
    
    // Request header
    @GetMapping("/me")
    public User getCurrentUser(@RequestHeader("Authorization") String token) {
        return userService.findByToken(token);
    }
    
    // Request body
    @PostMapping
    public ResponseEntity<User> createUser(@RequestBody @Valid UserDTO userDTO) {
        User created = userService.create(userDTO);
        URI location = ServletUriComponentsBuilder
            .fromCurrentRequest()
            .path("/{id}")
            .buildAndExpand(created.getId())
            .toUri();
        return ResponseEntity.created(location).body(created);
    }
    
    // Multiple path variables
    @GetMapping("/{userId}/posts/{postId}")
    public Post getUserPost(
        @PathVariable Long userId,
        @PathVariable Long postId
    ) {
        return postService.findByUserAndId(userId, postId);
    }
    
    // Matrix variables: /api/users;name=John;age=25
    @GetMapping
    public List<User> filterUsers(@MatrixVariable Map<String, String> filters) {
        return userService.filter(filters);
    }
}
```

### Response Status Codes

```java
@RestController
@RequestMapping("/api/orders")
public class OrderController {
    
    // 200 OK (default)
    @GetMapping("/{id}")
    public Order getOrder(@PathVariable Long id) {
        return orderService.findById(id);
    }
    
    // 201 Created
    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public Order createOrder(@RequestBody Order order) {
        return orderService.save(order);
    }
    
    // 204 No Content
    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteOrder(@PathVariable Long id) {
        orderService.delete(id);
    }
    
    // 400 Bad Request
    @PostMapping("/validate")
    public ResponseEntity<?> validateOrder(@RequestBody Order order) {
        if (!orderService.isValid(order)) {
            return ResponseEntity.badRequest()
                .body(Map.of("error", "Invalid order"));
        }
        return ResponseEntity.ok(order);
    }
    
    // 404 Not Found
    @GetMapping("/{id}")
    public ResponseEntity<Order> findOrder(@PathVariable Long id) {
        return orderService.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }
    
    // 500 Internal Server Error (automatic for unhandled exceptions)
}
```

## Validation

### Bean Validation Annotations

```java
import jakarta.validation.constraints.*;

public class UserDTO {
    @NotNull(message = "Name is required")
    @Size(min = 2, max = 50, message = "Name must be between 2 and 50 characters")
    private String name;
    
    @NotBlank(message = "Email is required")
    @Email(message = "Invalid email format")
    private String email;
    
    @Min(value = 18, message = "Age must be at least 18")
    @Max(value = 100, message = "Age must be less than 100")
    private Integer age;
    
    @Pattern(regexp = "^\\+?[0-9]{10,}$", message = "Invalid phone number")
    private String phone;
    
    @NotEmpty(message = "Password is required")
    @Size(min = 8, message = "Password must be at least 8 characters")
    private String password;
    
    @Past(message = "Birth date must be in the past")
    private LocalDate birthDate;
    
    @Future(message = "Appointment must be in the future")
    private LocalDateTime appointmentTime;
    
    @DecimalMin(value = "0.0", message = "Price must be positive")
    @DecimalMax(value = "10000.0", message = "Price too high")
    private BigDecimal price;
    
    @Positive
    private Integer quantity;
    
    @URL
    private String website;
    
    // Getters and setters
}
```

### Custom Validator

```java
// Custom annotation
@Target({ElementType.FIELD})
@Retention(RetentionPolicy.RUNTIME)
@Constraint(validatedBy = UsernameValidator.class)
public @interface ValidUsername {
    String message() default "Invalid username";
    Class<?>[] groups() default {};
    Class<? extends Payload>[] payload() default {};
}

// Validator implementation
public class UsernameValidator implements ConstraintValidator<ValidUsername, String> {
    @Override
    public boolean isValid(String username, ConstraintValidatorContext context) {
        if (username == null) {
            return false;
        }
        // Username must be alphanumeric and 3-20 characters
        return username.matches("^[a-zA-Z0-9]{3,20}$");
    }
}

// Usage
public class UserDTO {
    @ValidUsername
    private String username;
}
```

### Validation in Controller

```java
@RestController
@RequestMapping("/api/users")
public class UserController {
    
    @PostMapping
    public ResponseEntity<?> createUser(@Valid @RequestBody UserDTO userDTO) {
        // If validation fails, throws MethodArgumentNotValidException
        User user = userService.create(userDTO);
        return ResponseEntity.status(HttpStatus.CREATED).body(user);
    }
    
    // Handle validation errors
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<Map<String, String>> handleValidationErrors(
        MethodArgumentNotValidException ex
    ) {
        Map<String, String> errors = new HashMap<>();
        ex.getBindingResult().getFieldErrors().forEach(error ->
            errors.put(error.getField(), error.getDefaultMessage())
        );
        return ResponseEntity.badRequest().body(errors);
    }
}
```

## Exception Handling

### @ControllerAdvice

```java
import org.springframework.web.bind.annotation.*;
import org.springframework.http.*;

@RestControllerAdvice
public class GlobalExceptionHandler {
    
    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleNotFound(
        ResourceNotFoundException ex,
        WebRequest request
    ) {
        ErrorResponse error = ErrorResponse.builder()
            .timestamp(LocalDateTime.now())
            .status(HttpStatus.NOT_FOUND.value())
            .error("Not Found")
            .message(ex.getMessage())
            .path(request.getDescription(false))
            .build();
        
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(error);
    }
    
    @ExceptionHandler(DuplicateResourceException.class)
    public ResponseEntity<ErrorResponse> handleDuplicate(
        DuplicateResourceException ex
    ) {
        ErrorResponse error = ErrorResponse.builder()
            .timestamp(LocalDateTime.now())
            .status(HttpStatus.CONFLICT.value())
            .error("Conflict")
            .message(ex.getMessage())
            .build();
        
        return ResponseEntity.status(HttpStatus.CONFLICT).body(error);
    }
    
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ValidationErrorResponse> handleValidation(
        MethodArgumentNotValidException ex
    ) {
        Map<String, String> errors = new HashMap<>();
        ex.getBindingResult().getFieldErrors().forEach(error ->
            errors.put(error.getField(), error.getDefaultMessage())
        );
        
        ValidationErrorResponse response = ValidationErrorResponse.builder()
            .timestamp(LocalDateTime.now())
            .status(HttpStatus.BAD_REQUEST.value())
            .errors(errors)
            .build();
        
        return ResponseEntity.badRequest().body(response);
    }
    
    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleGeneral(Exception ex) {
        ErrorResponse error = ErrorResponse.builder()
            .timestamp(LocalDateTime.now())
            .status(HttpStatus.INTERNAL_SERVER_ERROR.value())
            .error("Internal Server Error")
            .message("An unexpected error occurred")
            .build();
        
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
    }
}

@Data
@Builder
class ErrorResponse {
    private LocalDateTime timestamp;
    private int status;
    private String error;
    private String message;
    private String path;
}

@Data
@Builder
class ValidationErrorResponse {
    private LocalDateTime timestamp;
    private int status;
    private Map<String, String> errors;
}
```

## CORS Configuration

```java
@Configuration
public class CorsConfig implements WebMvcConfigurer {
    
    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/api/**")
            .allowedOrigins("http://localhost:3000", "https://example.com")
            .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
            .allowedHeaders("*")
            .allowCredentials(true)
            .maxAge(3600);
    }
}

// Or use annotation on controller
@RestController
@CrossOrigin(origins = "http://localhost:3000")
@RequestMapping("/api/users")
public class UserController {
    // ...
}
```

## File Upload/Download

### File Upload

```java
@RestController
@RequestMapping("/api/files")
public class FileController {
    private final String uploadDir = "uploads/";
    
    @PostMapping("/upload")
    public ResponseEntity<String> uploadFile(
        @RequestParam("file") MultipartFile file
    ) {
        try {
            if (file.isEmpty()) {
                return ResponseEntity.badRequest().body("Please select a file");
            }
            
            // Check file size (10MB max)
            if (file.getSize() > 10 * 1024 * 1024) {
                return ResponseEntity.badRequest().body("File too large");
            }
            
            // Save file
            String filename = System.currentTimeMillis() + "_" + file.getOriginalFilename();
            Path path = Paths.get(uploadDir + filename);
            Files.createDirectories(path.getParent());
            Files.write(path, file.getBytes());
            
            return ResponseEntity.ok("File uploaded: " + filename);
            
        } catch (IOException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body("Upload failed");
        }
    }
    
    @PostMapping("/upload-multiple")
    public ResponseEntity<List<String>> uploadMultiple(
        @RequestParam("files") MultipartFile[] files
    ) {
        List<String> filenames = new ArrayList<>();
        
        for (MultipartFile file : files) {
            // Save each file
            // Add to filenames list
        }
        
        return ResponseEntity.ok(filenames);
    }
}

// application.properties
// spring.servlet.multipart.max-file-size=10MB
// spring.servlet.multipart.max-request-size=20MB
```

### File Download

```java
@RestController
@RequestMapping("/api/files")
public class FileController {
    
    @GetMapping("/download/{filename}")
    public ResponseEntity<Resource> downloadFile(@PathVariable String filename) {
        try {
            Path filePath = Paths.get("uploads/" + filename);
            Resource resource = new InputStreamResource(Files.newInputStream(filePath));
            
            return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION,
                    "attachment; filename=\"" + filename + "\"")
                .contentType(MediaType.APPLICATION_OCTET_STREAM)
                .contentLength(Files.size(filePath))
                .body(resource);
                
        } catch (IOException e) {
            return ResponseEntity.notFound().build();
        }
    }
    
    @GetMapping("/view/{filename}")
    public ResponseEntity<Resource> viewFile(@PathVariable String filename) {
        try {
            Path filePath = Paths.get("uploads/" + filename);
            Resource resource = new UrlResource(filePath.toUri());
            
            String contentType = Files.probeContentType(filePath);
            if (contentType == null) {
                contentType = "application/octet-stream";
            }
            
            return ResponseEntity.ok()
                .contentType(MediaType.parseMediaType(contentType))
                .body(resource);
                
        } catch (IOException e) {
            return ResponseEntity.notFound().build();
        }
    }
}
```

## Pagination and Sorting

```java
import org.springframework.data.domain.*;

@RestController
@RequestMapping("/api/users")
public class UserController {
    
    // Pagination: /api/users?page=0&size=10
    @GetMapping
    public Page<User> getUsers(
        @RequestParam(defaultValue = "0") int page,
        @RequestParam(defaultValue = "10") int size
    ) {
        Pageable pageable = PageRequest.of(page, size);
        return userService.findAll(pageable);
    }
    
    // Sorting: /api/users?sort=name,asc
    @GetMapping("/sorted")
    public List<User> getUsersSorted(
        @RequestParam(defaultValue = "name") String sortBy,
        @RequestParam(defaultValue = "asc") String direction
    ) {
        Sort sort = direction.equals("asc") ?
            Sort.by(sortBy).ascending() :
            Sort.by(sortBy).descending();
        
        return userService.findAll(sort);
    }
    
    // Pagination + Sorting: /api/users/paged?page=0&size=10&sort=name,asc
    @GetMapping("/paged")
    public Page<User> getUsersPaged(Pageable pageable) {
        return userService.findAll(pageable);
    }
    
    // Custom response
    @GetMapping("/list")
    public ResponseEntity<?> getUserList(
        @RequestParam(defaultValue = "0") int page,
        @RequestParam(defaultValue = "10") int size
    ) {
        Page<User> userPage = userService.findAll(PageRequest.of(page, size));
        
        Map<String, Object> response = new HashMap<>();
        response.put("users", userPage.getContent());
        response.put("currentPage", userPage.getNumber());
        response.put("totalItems", userPage.getTotalElements());
        response.put("totalPages", userPage.getTotalPages());
        
        return ResponseEntity.ok(response);
    }
}

// Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Page<User> findByNameContaining(String name, Pageable pageable);
    List<User> findByAge(Integer age, Sort sort);
}
```

## Request/Response Interceptors

```java
@Component
public class LoggingInterceptor implements HandlerInterceptor {
    private static final Logger logger = LoggerFactory.getLogger(LoggingInterceptor.class);
    
    @Override
    public boolean preHandle(
        HttpServletRequest request,
        HttpServletResponse response,
        Object handler
    ) {
        logger.info("Request: {} {}", request.getMethod(), request.getRequestURI());
        request.setAttribute("startTime", System.currentTimeMillis());
        return true;
    }
    
    @Override
    public void postHandle(
        HttpServletRequest request,
        HttpServletResponse response,
        Object handler,
        ModelAndView modelAndView
    ) {
        long startTime = (Long) request.getAttribute("startTime");
        long duration = System.currentTimeMillis() - startTime;
        logger.info("Response: {} - {}ms", response.getStatus(), duration);
    }
    
    @Override
    public void afterCompletion(
        HttpServletRequest request,
        HttpServletResponse response,
        Object handler,
        Exception ex
    ) {
        if (ex != null) {
            logger.error("Request failed", ex);
        }
    }
}

@Configuration
public class WebConfig implements WebMvcConfigurer {
    @Autowired
    private LoggingInterceptor loggingInterceptor;
    
    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(loggingInterceptor)
            .addPathPatterns("/api/**");
    }
}
```

## Content Negotiation

```java
@RestController
@RequestMapping("/api/users")
public class UserController {
    
    // Produces JSON or XML based on Accept header
    @GetMapping(produces = {
        MediaType.APPLICATION_JSON_VALUE,
        MediaType.APPLICATION_XML_VALUE
    })
    public List<User> getUsers() {
        return userService.findAll();
    }
    
    // Consumes JSON or XML based on Content-Type header
    @PostMapping(consumes = {
        MediaType.APPLICATION_JSON_VALUE,
        MediaType.APPLICATION_XML_VALUE
    })
    public User createUser(@RequestBody User user) {
        return userService.save(user);
    }
}
```

## Quick Reference

```java
// REST annotations
@RestController              // Combines @Controller + @ResponseBody
@RequestMapping("/api")      // Base path
@GetMapping                  // HTTP GET
@PostMapping                 // HTTP POST
@PutMapping                  // HTTP PUT
@DeleteMapping               // HTTP DELETE
@PatchMapping                // HTTP PATCH

// Request parameters
@PathVariable                // URL path: /{id}
@RequestParam                // Query param: ?name=value
@RequestBody                 // Request body (JSON)
@RequestHeader               // HTTP header
@Valid                       // Enable validation

// Response
ResponseEntity.ok(body)
ResponseEntity.created(uri).body(body)
ResponseEntity.noContent().build()
ResponseEntity.notFound().build()
ResponseEntity.badRequest().body(error)

// Exception handling
@RestControllerAdvice        // Global exception handler
@ExceptionHandler           // Handle specific exception

// Validation
@NotNull, @NotBlank, @NotEmpty
@Size, @Min, @Max
@Email, @Pattern
@Past, @Future
```

---

**Previous**: [← Spring Basics](java-21-spring-basics.md) | **Next**: [Modern Java →](java-23-modern-java.md)
