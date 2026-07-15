# Spring Boot and Java Backend Deep Notes

This note is for deeper understanding of Spring Boot backend development from interview and production perspectives. It covers core Spring concepts, web APIs, data access, transactions, observability, microservice-friendly design, and Spring Security fundamentals.

---

## 1. Spring vs Spring Boot

### Spring

Spring is the larger ecosystem that provides:

- dependency injection
- AOP
- web MVC
- data access
- transactions
- security
- integration support

### Spring Boot

Spring Boot sits on top of Spring and reduces setup effort through:

- auto-configuration
- starter dependencies
- embedded servers
- actuator endpoints
- externalized configuration
- opinionated defaults

### Interview-ready explanation

Spring gives the programming model. Spring Boot makes it faster to build and run production-ready Spring services with less boilerplate.

---

## 2. Dependency Injection and IoC

### Why DI matters

Dependency injection helps us:

- reduce tight coupling
- make testing easier
- keep code modular
- move object creation to the framework

### Preferred style

Use constructor injection for required dependencies.

```java
@Service
public class OrderService {
    private final OrderRepository orderRepository;

    public OrderService(OrderRepository orderRepository) {
        this.orderRepository = orderRepository;
    }
}
```

### Why constructor injection is preferred

- dependencies are explicit
- fields can be `final`
- easier unit testing
- avoids hidden framework magic

---

## 3. Bean Lifecycle

Typical lifecycle:

1. bean definition is discovered
2. dependencies are resolved
3. bean is created
4. init callbacks run
5. bean is used
6. destroy callbacks run during shutdown

Common lifecycle tools:

- `@PostConstruct`
- `@PreDestroy`
- `InitializingBean`
- `DisposableBean`

---

## 4. Auto-Configuration

Spring Boot auto-configuration decides what to configure based on:

- classpath
- existing beans
- properties

Examples:

- if `spring-webmvc` is present, Boot can configure MVC defaults
- if JPA libraries and datasource properties are present, Boot can configure JPA support

### Important point

Auto-configuration saves time, but strong engineers still understand how to override defaults when needed.

---

## 5. Configuration and Profiles

Use externalized configuration for:

- ports
- database URLs
- secrets references
- feature flags
- timeouts

Common files:

- `application.properties`
- `application.yml`
- `application-dev.yml`
- `application-prod.yml`

### Good practice

- keep secrets out of Git
- use environment variables or secret managers
- use profiles carefully and keep them understandable

---

## 6. Layered Backend Design

Typical structure:

- `controller`
- `service`
- `repository`
- `dto`
- `entity`
- `config`
- `exception`

### Good boundaries

- controllers handle HTTP concerns
- services hold business logic
- repositories handle persistence
- DTOs shape API contracts
- entities represent database state

### Anti-pattern

Do not place business logic directly in controllers.

---

## 7. REST API Design in Spring Boot

Useful annotations:

- `@RestController`
- `@RequestMapping`
- `@GetMapping`
- `@PostMapping`
- `@PutMapping`
- `@DeleteMapping`
- `@PathVariable`
- `@RequestParam`
- `@RequestBody`

### API design expectations

- meaningful resource names
- correct HTTP methods
- consistent status codes
- validation at the boundary
- stable DTO contracts

### Example

```java
@RestController
@RequestMapping("/api/orders")
public class OrderController {

    private final OrderService orderService;

    public OrderController(OrderService orderService) {
        this.orderService = orderService;
    }

    @GetMapping("/{id}")
    public OrderResponse getOrder(@PathVariable Long id) {
        return orderService.getById(id);
    }
}
```

---

## 8. Validation

Bean Validation helps reject bad input early.

Common annotations:

- `@NotNull`
- `@NotBlank`
- `@Size`
- `@Email`
- `@Min`
- `@Max`
- `@Pattern`

Example:

```java
public record CreateUserRequest(
        @NotBlank String name,
        @Email String email,
        @Size(min = 8) String password
) {}
```

Use `@Valid` in controller methods:

```java
@PostMapping
public UserResponse create(@Valid @RequestBody CreateUserRequest request) {
    return userService.create(request);
}
```

---

## 9. Exception Handling

Centralized exception handling makes APIs consistent.

Common pattern:

- business exceptions for domain failures
- validation exceptions for request failures
- generic fallback for unexpected errors

Example:

```java
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(ResourceNotFoundException.class)
    @ResponseStatus(HttpStatus.NOT_FOUND)
    public ErrorResponse handleNotFound(ResourceNotFoundException ex) {
        return new ErrorResponse("NOT_FOUND", ex.getMessage());
    }
}
```

### Good production rule

Never leak stack traces or internal implementation details in API responses.

---

## 10. DTOs vs Entities

### Entity

- maps to persistence model
- tied to ORM concerns
- can include relationships and lazy loading

### DTO

- shapes request or response data
- should reflect API contract
- should not expose internal persistence details

### Why separation matters

- prevents accidental data leakage
- keeps API stable
- avoids lazy-loading surprises in serialization

---

## 11. Spring Data JPA Basics

Spring Data JPA reduces repository boilerplate.

Example:

```java
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
}
```

### Benefits

- CRUD support
- paging and sorting
- query derivation
- JPQL/native query support

### Risks

- hidden N+1 problems
- lazy loading surprises
- overreliance on repository magic without understanding SQL impact

---

## 12. Transactions

`@Transactional` helps define atomic units of work.

Typical use cases:

- create parent and child records together
- update multiple tables consistently
- rollback if part of a business action fails

### Important ideas

- transaction boundary usually belongs in service layer
- unchecked exceptions typically trigger rollback
- long transactions increase lock and performance risk

Example:

```java
@Transactional
public OrderResponse createOrder(CreateOrderRequest request) {
    // persist order
    // persist items
    // update stock
    return response;
}
```

---

## 13. JPA Performance Topics

Common issues:

- N+1 queries
- unnecessary eager loading
- missing indexes
- fetching too much data
- large object graphs in API responses

Useful strategies:

- fetch joins where justified
- projections
- pagination
- indexes at DB level
- query review through logs and execution plans

### Strong interview answer

When JPA is slow, I first confirm whether the issue is query count, query plan, data volume, or transaction design rather than blaming JPA generically.

---

## 14. Spring Boot Actuator and Observability

Actuator adds operational endpoints such as:

- `/actuator/health`
- `/actuator/info`
- `/actuator/metrics`
- `/actuator/prometheus`

Production observability should include:

- structured logs
- correlation IDs
- health checks
- metrics
- alerting-friendly signals
- traces where useful

---

## 15. Logging

Use logging intentionally:

- `INFO` for normal business milestones
- `WARN` for recoverable issues
- `ERROR` for failures requiring attention

Good logging principles:

- no sensitive data in logs
- include request or correlation identifiers
- log enough context to debug incidents
- avoid noisy duplicate logs

---

## 16. Caching

Spring supports caching via annotations like:

- `@EnableCaching`
- `@Cacheable`
- `@CachePut`
- `@CacheEvict`

Example:

```java
@Cacheable("products")
public ProductResponse getProduct(Long id) {
    return productRepository.findById(id)
            .map(this::toResponse)
            .orElseThrow(() -> new ResourceNotFoundException("Product not found"));
}
```

### Caution

Caching is useful only when you understand cache invalidation, staleness, memory usage, and key design.

---

## 17. Asynchronous Processing

Common cases:

- email sending
- file processing
- report generation
- notification workflows

Typical choices:

- `@Async` for simple async needs
- message queues for stronger decoupling and reliability

### Engineering point

If work must survive process restarts and requires retry or delivery guarantees, a queue is usually safer than only using in-memory async execution.

---

## 18. Testing Strategy

Useful test layers:

- unit tests for service logic
- web-layer tests for controllers
- repository tests for persistence
- integration tests for full application behavior

Common tools:

- JUnit 5
- Mockito
- Spring Boot Test
- MockMvc
- Testcontainers

### Good interview answer

I do not rely only on one test type. I use smaller fast tests for logic and focused integration tests for wiring, persistence, and request flow.

---

## 19. Spring Security Deep Notes

Spring Security is about authentication, authorization, filter chains, password handling, session or token strategy, and secure defaults.

### Core concepts

- **Authentication**: who the user is
- **Authorization**: what the user can do
- **Principal**: current authenticated identity
- **GrantedAuthority**: permissions or roles
- **SecurityFilterChain**: request security pipeline

### Common flow

1. request enters filter chain
2. security checks or creates authentication
3. authentication is stored in security context
4. authorization rules decide access
5. request proceeds or is rejected

---

## 20. Authentication Models

### Session-based authentication

- server stores session state
- browser sends session cookie
- common for traditional web apps

### Token-based authentication

- common for APIs
- often uses JWT or opaque tokens
- useful for stateless services

### Good choice guidance

- browser-based server-rendered app: session-based often fits
- distributed API ecosystem: token-based often fits better

---

## 21. Password Security

Never store plain-text passwords.

Use a password encoder such as BCrypt:

```java
PasswordEncoder encoder = new BCryptPasswordEncoder();
String hashed = encoder.encode(rawPassword);
```

### Important rule

Passwords are verified by encoding comparison, not by decrypting.

---

## 22. SecurityFilterChain Example

```java
@Configuration
@EnableMethodSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable())
            .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/actuator/health", "/auth/**").permitAll()
                .requestMatchers("/admin/**").hasRole("ADMIN")
                .anyRequest().authenticated()
            );

        return http.build();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
```

### What to explain in interviews

- why CSRF may be disabled for stateless APIs
- why `SessionCreationPolicy.STATELESS` fits token-based APIs
- how path rules and role checks work

---

## 23. Method-Level Security

Useful annotations:

- `@PreAuthorize`
- `@PostAuthorize`
- `@Secured`
- `@RolesAllowed`

Example:

```java
@PreAuthorize("hasRole('ADMIN')")
public void deleteUser(Long id) {
    // admin-only action
}
```

### Good use case

Path-level security protects routes. Method-level security protects business operations even if invocation paths change.

---

## 24. JWT Basics

JWT-based API flow usually looks like:

1. user authenticates with credentials
2. server validates credentials
3. server issues token
4. client sends token in `Authorization: Bearer <token>`
5. filter validates token and builds authentication

### Common claims

- subject
- roles/authorities
- issued at
- expiration

### Security cautions

- short token expiry
- signature validation
- no sensitive secrets in token payload
- refresh-token strategy if needed

---

## 25. Common Spring Security Interview Pitfalls

- confusing authentication with authorization
- storing plain passwords
- disabling all security for convenience
- exposing actuator endpoints openly
- forgetting role vs authority conventions
- not securing method-level operations
- not validating JWT expiry or signature

---

## 26. Production Backend Design Expectations

For 5 to 7 year roles, interviewers usually expect:

- clean service boundaries
- transaction awareness
- security-by-default thinking
- observability
- clear API contracts
- reliable testing strategy
- performance awareness
- deployment and runtime debugging mindset

---

## 27. Quick Revision Checklist

- DI and IoC
- auto-configuration
- bean lifecycle
- REST controller design
- DTO vs entity
- validation and exception handling
- JPA and transaction boundaries
- actuator and observability
- caching and async processing
- Spring Security filter chain
- JWT flow
- password encoding
- method-level authorization
