# Spring Boot and Java Backend Coding Questions with Solutions

This file focuses on coding-style Spring Boot and backend questions with sample solutions and explanation.

---

## 1. Create a simple REST endpoint

### Question

Create a Spring Boot endpoint `GET /api/hello` that returns `{"message":"hello"}`.

### Solution

```java
@RestController
@RequestMapping("/api")
public class HelloController {

    @GetMapping("/hello")
    public Map<String, String> hello() {
        return Map.of("message", "hello");
    }
}
```

### Explanation

This tests basic controller setup, request mapping, and JSON serialization.

---

## 2. Add request validation

### Question

Create an endpoint to register a user with name and email validation.

### Solution

```java
public record RegisterUserRequest(
        @NotBlank String name,
        @Email String email
) {}

@RestController
@RequestMapping("/api/users")
public class UserController {

    @PostMapping
    public ResponseEntity<RegisterUserRequest> create(@Valid @RequestBody RegisterUserRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(request);
    }
}
```

### Explanation

This checks whether the candidate understands `@Valid`, bean validation, and REST request handling.

---

## 3. Implement centralized exception handling

### Question

How would you return a proper 404 response when a user is not found?

### Solution

```java
public class ResourceNotFoundException extends RuntimeException {
    public ResourceNotFoundException(String message) {
        super(message);
    }
}

public record ErrorResponse(String code, String message) {}

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(ResourceNotFoundException.class)
    @ResponseStatus(HttpStatus.NOT_FOUND)
    public ErrorResponse handleNotFound(ResourceNotFoundException ex) {
        return new ErrorResponse("NOT_FOUND", ex.getMessage());
    }
}
```

### Explanation

Interviewers often expect centralized exception handling instead of ad hoc `try/catch` in controllers.

---

## 4. Implement service and repository layering

### Question

Show a clean controller-service-repository flow for getting a user by ID.

### Solution

```java
@Entity
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String name;
    private String email;

    // getters and setters
}

public interface UserRepository extends JpaRepository<User, Long> {
}

public record UserResponse(Long id, String name, String email) {}

@Service
public class UserService {
    private final UserRepository userRepository;

    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public UserResponse getById(Long id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        return new UserResponse(user.getId(), user.getName(), user.getEmail());
    }
}

@RestController
@RequestMapping("/api/users")
public class UserController {
    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping("/{id}")
    public UserResponse getById(@PathVariable Long id) {
        return userService.getById(id);
    }
}
```

### Explanation

This shows layer separation and DTO mapping rather than exposing entities directly.

---

## 5. Add pagination

### Question

How do you implement paginated `GET /api/users`?

### Solution

```java
@GetMapping
public Page<UserResponse> getUsers(Pageable pageable) {
    return userRepository.findAll(pageable)
            .map(user -> new UserResponse(user.getId(), user.getName(), user.getEmail()));
}
```

### Explanation

This tests Spring Data pagination, API design, and mapping from entity to DTO.

---

## 6. Create a transactional service method

### Question

Show how you would create an order and update inventory in one transaction.

### Solution

```java
@Service
public class OrderService {
    private final OrderRepository orderRepository;
    private final InventoryRepository inventoryRepository;

    public OrderService(OrderRepository orderRepository, InventoryRepository inventoryRepository) {
        this.orderRepository = orderRepository;
        this.inventoryRepository = inventoryRepository;
    }

    @Transactional
    public void placeOrder(Long productId, int quantity) {
        Inventory inventory = inventoryRepository.findByProductId(productId)
                .orElseThrow(() -> new ResourceNotFoundException("Inventory not found"));

        if (inventory.getAvailable() < quantity) {
            throw new IllegalArgumentException("Insufficient stock");
        }

        inventory.setAvailable(inventory.getAvailable() - quantity);
        inventoryRepository.save(inventory);

        Order order = new Order();
        order.setProductId(productId);
        order.setQuantity(quantity);
        orderRepository.save(order);
    }
}
```

### Explanation

This checks understanding of transaction boundaries and atomic business actions.

---

## 7. Secure an endpoint with Spring Security

### Question

Restrict `DELETE /api/users/{id}` to admin users.

### Solution

```java
@Configuration
@EnableMethodSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable())
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/users/**").authenticated()
                .anyRequest().permitAll()
            );

        return http.build();
    }
}

@RestController
@RequestMapping("/api/users")
public class AdminUserController {

    @PreAuthorize("hasRole('ADMIN')")
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteUser(@PathVariable Long id) {
        return ResponseEntity.noContent().build();
    }
}
```

### Explanation

This shows endpoint security plus method-level authorization.

---

## 8. Configure password encoding

### Question

How do you store passwords safely?

### Solution

```java
@Configuration
public class PasswordConfig {

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}

@Service
public class RegistrationService {
    private final PasswordEncoder passwordEncoder;

    public RegistrationService(PasswordEncoder passwordEncoder) {
        this.passwordEncoder = passwordEncoder;
    }

    public String encodePassword(String rawPassword) {
        return passwordEncoder.encode(rawPassword);
    }
}
```

### Explanation

Interviewers often ask this because plain-text password handling is a major red flag.

---

## 9. Create a JWT authentication filter skeleton

### Question

Show the basic idea of a JWT filter.

### Solution

```java
@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain) throws ServletException, IOException {

        String authHeader = request.getHeader("Authorization");

        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            String token = authHeader.substring(7);

            // validate token
            // extract username and roles
            // build Authentication
            // SecurityContextHolder.getContext().setAuthentication(authentication);
        }

        filterChain.doFilter(request, response);
    }
}
```

### Explanation

This tests whether the candidate understands where JWT processing fits in the request pipeline.

---

## 10. Add `@Cacheable` for read-heavy data

### Question

Show how to cache a frequently requested product lookup.

### Solution

```java
@Service
public class ProductService {
    private final ProductRepository productRepository;

    public ProductService(ProductRepository productRepository) {
        this.productRepository = productRepository;
    }

    @Cacheable("products")
    public ProductResponse getProduct(Long id) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Product not found"));
        return new ProductResponse(product.getId(), product.getName());
    }
}
```

### Explanation

This checks whether the candidate knows when Spring caching can improve read performance.

---

## 11. Write a simple unit test for a service

### Question

Show a unit test for `UserService#getById`.

### Solution

```java
@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @Mock
    private UserRepository userRepository;

    @InjectMocks
    private UserService userService;

    @Test
    void shouldReturnUserById() {
        User user = new User();
        user.setId(1L);
        user.setName("Alice");
        user.setEmail("alice@example.com");

        when(userRepository.findById(1L)).thenReturn(Optional.of(user));

        UserResponse response = userService.getById(1L);

        assertEquals(1L, response.id());
        assertEquals("Alice", response.name());
    }
}
```

### Explanation

This checks unit testing basics, mocking, and service-layer testing.

---

## 12. Write a controller test with MockMvc

### Question

Show how to test a controller endpoint.

### Solution

```java
@WebMvcTest(UserController.class)
class UserControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private UserService userService;

    @Test
    void shouldReturnUser() throws Exception {
        when(userService.getById(1L))
                .thenReturn(new UserResponse(1L, "Alice", "alice@example.com"));

        mockMvc.perform(get("/api/users/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.name").value("Alice"));
    }
}
```

### Explanation

This tests request mapping and response structure without loading the full application.

---

## 13. Implement a global request logging filter

### Question

How would you add a request logging filter?

### Solution

```java
@Component
public class RequestLoggingFilter extends OncePerRequestFilter {

    private static final Logger log = LoggerFactory.getLogger(RequestLoggingFilter.class);

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain) throws ServletException, IOException {

        long start = System.currentTimeMillis();
        filterChain.doFilter(request, response);
        long duration = System.currentTimeMillis() - start;

        log.info("method={} path={} status={} durationMs={}",
                request.getMethod(),
                request.getRequestURI(),
                response.getStatus(),
                duration);
    }
}
```

### Explanation

This checks filter usage, observability awareness, and operational thinking.

---

## 14. Prevent exposing JPA entity directly

### Question

Why is returning entity objects directly from controllers risky, and how would you avoid it?

### Solution

```java
public record ProductResponse(Long id, String name, BigDecimal price) {}

@Service
public class ProductMapperService {
    public ProductResponse toResponse(Product product) {
        return new ProductResponse(product.getId(), product.getName(), product.getPrice());
    }
}
```

### Explanation

Returning entities directly can expose internal fields, ORM relationships, and lazy-loading problems. DTO mapping gives better API control.

---

## 15. Add a custom query method

### Question

Show how to find active users by email domain.

### Solution

```java
public interface UserRepository extends JpaRepository<User, Long> {

    @Query("""
           select u from User u
           where u.active = true
             and u.email like concat('%', :domain)
           """)
    List<User> findActiveUsersByDomain(@Param("domain") String domain);
}
```

### Explanation

This checks repository usage, query writing, and simple filtering logic.

---

## Quick Coding Revision Topics

- REST controllers
- request validation
- centralized exception handling
- service-repository layering
- transactions
- paging
- security configuration
- password encoding
- JWT filter basics
- caching
- unit testing
- controller testing
