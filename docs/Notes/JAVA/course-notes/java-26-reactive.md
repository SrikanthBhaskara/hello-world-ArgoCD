# Reactive Programming in Java

## What is Reactive Programming?

Reactive programming is a programming paradigm focused on asynchronous data streams and the propagation of change.

**Key Principles (Reactive Manifesto)**:
- **Responsive**: System responds in a timely manner
- **Resilient**: System stays responsive in face of failure
- **Elastic**: System scales up/down as needed
- **Message-driven**: Asynchronous message-passing

## Project Reactor

### Maven Dependencies

```xml
<dependencies>
    <!-- Reactor Core -->
    <dependency>
        <groupId>io.projectreactor</groupId>
        <artifactId>reactor-core</artifactId>
        <version>3.6.0</version>
    </dependency>
    
    <!-- Reactor Test -->
    <dependency>
        <groupId>io.projectreactor</groupId>
        <artifactId>reactor-test</artifactId>
        <version>3.6.0</version>
        <scope>test</scope>
    </dependency>
    
    <!-- Spring WebFlux (for reactive web) -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-webflux</artifactId>
    </dependency>
</dependencies>
```

## Mono and Flux

### Mono (0 or 1 element)

```java
import reactor.core.publisher.Mono;

public class MonoExamples {
    // Create Mono
    public static void main(String[] args) {
        // Empty Mono
        Mono<String> empty = Mono.empty();
        
        // Mono with value
        Mono<String> mono = Mono.just("Hello");
        
        // Mono from callable
        Mono<String> fromCallable = Mono.fromCallable(() -> "Hello");
        
        // Mono from supplier
        Mono<String> fromSupplier = Mono.fromSupplier(() -> "Hello");
        
        // Mono from CompletableFuture
        Mono<String> fromFuture = Mono.fromFuture(
            CompletableFuture.supplyAsync(() -> "Hello")
        );
        
        // Subscribe to see values
        mono.subscribe(
            value -> System.out.println("Value: " + value),
            error -> System.err.println("Error: " + error),
            () -> System.out.println("Completed")
        );
    }
}
```

### Flux (0 to N elements)

```java
import reactor.core.publisher.Flux;

public class FluxExamples {
    public static void main(String[] args) {
        // Create Flux
        Flux<String> flux = Flux.just("A", "B", "C");
        
        // From array
        Flux<Integer> fromArray = Flux.fromArray(new Integer[]{1, 2, 3});
        
        // From iterable
        Flux<String> fromList = Flux.fromIterable(List.of("A", "B", "C"));
        
        // Range
        Flux<Integer> range = Flux.range(1, 10);  // 1 to 10
        
        // Interval
        Flux<Long> interval = Flux.interval(Duration.ofSeconds(1));  // Emits 0, 1, 2...
        
        // Empty
        Flux<String> empty = Flux.empty();
        
        // Subscribe
        flux.subscribe(
            value -> System.out.println("Value: " + value),
            error -> System.err.println("Error: " + error),
            () -> System.out.println("Completed")
        );
    }
}
```

## Operators

### Transformation Operators

```java
public class TransformationOperators {
    public static void main(String[] args) {
        // map: Transform each element
        Flux.just(1, 2, 3, 4, 5)
            .map(n -> n * 2)
            .subscribe(System.out::println);  // 2, 4, 6, 8, 10
        
        // flatMap: Transform to Publisher and flatten
        Flux.just("A", "B", "C")
            .flatMap(s -> Flux.just(s + "1", s + "2"))
            .subscribe(System.out::println);  // A1, A2, B1, B2, C1, C2
        
        // concatMap: Like flatMap but preserves order
        Flux.just("A", "B", "C")
            .concatMap(s -> Flux.just(s + "1", s + "2"))
            .subscribe(System.out::println);
        
        // flatMapSequential: Parallel but ordered
        Flux.just("A", "B", "C")
            .flatMapSequential(s -> 
                Mono.just(s).delayElement(Duration.ofMillis(100)))
            .subscribe(System.out::println);
    }
}
```

### Filtering Operators

```java
public class FilteringOperators {
    public static void main(String[] args) {
        // filter: Keep elements that match predicate
        Flux.range(1, 10)
            .filter(n -> n % 2 == 0)
            .subscribe(System.out::println);  // 2, 4, 6, 8, 10
        
        // take: Take first N elements
        Flux.range(1, 10)
            .take(5)
            .subscribe(System.out::println);  // 1, 2, 3, 4, 5
        
        // skip: Skip first N elements
        Flux.range(1, 10)
            .skip(5)
            .subscribe(System.out::println);  // 6, 7, 8, 9, 10
        
        // distinct: Remove duplicates
        Flux.just(1, 2, 2, 3, 3, 3, 4)
            .distinct()
            .subscribe(System.out::println);  // 1, 2, 3, 4
        
        // distinctUntilChanged: Remove consecutive duplicates
        Flux.just(1, 1, 2, 2, 3, 3, 2, 1)
            .distinctUntilChanged()
            .subscribe(System.out::println);  // 1, 2, 3, 2, 1
    }
}
```

### Combining Operators

```java
public class CombiningOperators {
    public static void main(String[] args) {
        // concat: Concatenate publishers sequentially
        Flux<String> flux1 = Flux.just("A", "B");
        Flux<String> flux2 = Flux.just("C", "D");
        
        Flux.concat(flux1, flux2)
            .subscribe(System.out::println);  // A, B, C, D
        
        // merge: Merge publishers (interleaved)
        Flux.merge(flux1, flux2)
            .subscribe(System.out::println);
        
        // zip: Combine corresponding elements
        Flux<Integer> numbers = Flux.just(1, 2, 3);
        Flux<String> letters = Flux.just("A", "B", "C");
        
        Flux.zip(numbers, letters, (n, l) -> n + l)
            .subscribe(System.out::println);  // 1A, 2B, 3C
        
        // combineLatest: Combine latest values
        Flux.combineLatest(numbers, letters, (n, l) -> n + l)
            .subscribe(System.out::println);
    }
}
```

### Error Handling

```java
public class ErrorHandling {
    public static void main(String[] args) {
        // onErrorReturn: Return default value on error
        Flux.just(1, 2, 0, 4)
            .map(n -> 10 / n)
            .onErrorReturn(0)
            .subscribe(System.out::println);
        
        // onErrorResume: Continue with another publisher
        Flux.just(1, 2, 0, 4)
            .map(n -> 10 / n)
            .onErrorResume(e -> Flux.just(-1, -2, -3))
            .subscribe(System.out::println);
        
        // onErrorContinue: Skip error and continue
        Flux.just(1, 2, 0, 4)
            .map(n -> {
                if (n == 0) throw new ArithmeticException("Division by zero");
                return 10 / n;
            })
            .onErrorContinue((error, value) -> 
                System.err.println("Error for " + value + ": " + error))
            .subscribe(System.out::println);
        
        // retry: Retry on error
        Flux.just(1, 2, 0, 4)
            .map(n -> 10 / n)
            .retry(3)  // Retry 3 times
            .subscribe(
                System.out::println,
                error -> System.err.println("Failed: " + error)
            );
    }
}
```

## Spring WebFlux

### Reactive REST API

```java
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.*;

@RestController
@RequestMapping("/api/users")
public class UserController {
    private final UserService userService;
    
    public UserController(UserService userService) {
        this.userService = userService;
    }
    
    // Return Mono<User>
    @GetMapping("/{id}")
    public Mono<User> getUser(@PathVariable String id) {
        return userService.findById(id);
    }
    
    // Return Flux<User>
    @GetMapping
    public Flux<User> getAllUsers() {
        return userService.findAll();
    }
    
    // Post with Mono
    @PostMapping
    public Mono<User> createUser(@RequestBody Mono<User> userMono) {
        return userMono.flatMap(userService::save);
    }
    
    // Delete returns Mono<Void>
    @DeleteMapping("/{id}")
    public Mono<Void> deleteUser(@PathVariable String id) {
        return userService.deleteById(id);
    }
    
    // Stream with Server-Sent Events
    @GetMapping(value = "/stream", produces = "text/event-stream")
    public Flux<User> streamUsers() {
        return userService.findAll()
            .delayElements(Duration.ofSeconds(1));
    }
}
```

### Reactive Repository

```java
import org.springframework.data.repository.reactive.ReactiveCrudRepository;
import reactor.core.publisher.*;

public interface UserRepository extends ReactiveCrudRepository<User, String> {
    Flux<User> findByName(String name);
    
    Flux<User> findByAgeGreaterThan(int age);
    
    Mono<User> findByEmail(String email);
    
    Mono<Boolean> existsByEmail(String email);
}

@Service
public class UserService {
    private final UserRepository repository;
    
    public UserService(UserRepository repository) {
        this.repository = repository;
    }
    
    public Flux<User> findAll() {
        return repository.findAll();
    }
    
    public Mono<User> findById(String id) {
        return repository.findById(id)
            .switchIfEmpty(Mono.error(
                new NotFoundException("User not found: " + id)
            ));
    }
    
    public Mono<User> save(User user) {
        return repository.existsByEmail(user.getEmail())
            .flatMap(exists -> {
                if (exists) {
                    return Mono.error(
                        new DuplicateException("Email already exists")
                    );
                }
                return repository.save(user);
            });
    }
    
    public Mono<Void> deleteById(String id) {
        return repository.deleteById(id);
    }
}
```

### Reactive WebClient

```java
import org.springframework.web.reactive.function.client.WebClient;

@Service
public class ApiClient {
    private final WebClient webClient;
    
    public ApiClient(WebClient.Builder builder) {
        this.webClient = builder
            .baseUrl("https://api.example.com")
            .build();
    }
    
    // GET request
    public Mono<User> getUser(String id) {
        return webClient
            .get()
            .uri("/users/{id}", id)
            .retrieve()
            .bodyToMono(User.class);
    }
    
    // GET list
    public Flux<User> getAllUsers() {
        return webClient
            .get()
            .uri("/users")
            .retrieve()
            .bodyToFlux(User.class);
    }
    
    // POST request
    public Mono<User> createUser(User user) {
        return webClient
            .post()
            .uri("/users")
            .bodyValue(user)
            .retrieve()
            .bodyToMono(User.class);
    }
    
    // Error handling
    public Mono<User> getUserWithErrorHandling(String id) {
        return webClient
            .get()
            .uri("/users/{id}", id)
            .retrieve()
            .onStatus(HttpStatus::is4xxClientError,
                response -> Mono.error(new NotFoundException()))
            .onStatus(HttpStatus::is5xxServerError,
                response -> Mono.error(new ServiceException()))
            .bodyToMono(User.class)
            .retryWhen(Retry.backoff(3, Duration.ofSeconds(1)));
    }
}
```

## Backpressure

### Handling Slow Consumers

```java
public class BackpressureExamples {
    public static void main(String[] args) {
        // Fast producer, slow consumer
        Flux.range(1, 1000)
            .onBackpressureBuffer()  // Buffer elements
            .subscribe(new BaseSubscriber<Integer>() {
                @Override
                protected void hookOnSubscribe(Subscription subscription) {
                    request(10);  // Request 10 items
                }
                
                @Override
                protected void hookOnNext(Integer value) {
                    System.out.println("Processing: " + value);
                    // Slow processing
                    try {
                        Thread.sleep(100);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                    request(1);  // Request next item
                }
            });
        
        // Drop strategy
        Flux.range(1, 1000)
            .onBackpressureDrop(dropped -> 
                System.out.println("Dropped: " + dropped))
            .subscribe(System.out::println);
        
        // Latest strategy (keep only latest)
        Flux.range(1, 1000)
            .onBackpressureLatest()
            .subscribe(System.out::println);
    }
}
```

## Testing Reactive Code

### StepVerifier

```java
import reactor.test.StepVerifier;

public class ReactiveTests {
    @Test
    public void testMono() {
        Mono<String> mono = Mono.just("Hello");
        
        StepVerifier.create(mono)
            .expectNext("Hello")
            .verifyComplete();
    }
    
    @Test
    public void testFlux() {
        Flux<Integer> flux = Flux.just(1, 2, 3, 4, 5);
        
        StepVerifier.create(flux)
            .expectNext(1)
            .expectNext(2)
            .expectNext(3, 4, 5)
            .verifyComplete();
    }
    
    @Test
    public void testError() {
        Flux<Integer> flux = Flux.just(1, 2, 0, 4)
            .map(n -> 10 / n);
        
        StepVerifier.create(flux)
            .expectNext(10)
            .expectNext(5)
            .expectError(ArithmeticException.class)
            .verify();
    }
    
    @Test
    public void testWithVirtualTime() {
        StepVerifier.withVirtualTime(() -> 
            Flux.interval(Duration.ofSeconds(1)).take(3)
        )
        .expectSubscription()
        .thenAwait(Duration.ofSeconds(3))
        .expectNext(0L, 1L, 2L)
        .verifyComplete();
    }
}
```

## Practical Examples

### Parallel Processing

```java
public class ParallelProcessing {
    public Flux<String> processParallel(List<String> items) {
        return Flux.fromIterable(items)
            .parallel()
            .runOn(Schedulers.parallel())
            .map(this::expensiveOperation)
            .sequential();
    }
    
    private String expensiveOperation(String item) {
        // Simulate expensive operation
        try {
            Thread.sleep(1000);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
        return item.toUpperCase();
    }
}
```

### Combining Multiple API Calls

```java
@Service
public class CompositeService {
    private final UserService userService;
    private final OrderService orderService;
    private final PaymentService paymentService;
    
    // Sequential
    public Mono<OrderDetails> getOrderDetailsSequential(String orderId) {
        return orderService.getOrder(orderId)
            .flatMap(order -> 
                userService.getUser(order.getUserId())
                    .flatMap(user -> 
                        paymentService.getPayment(order.getPaymentId())
                            .map(payment -> 
                                new OrderDetails(order, user, payment)
                            )
                    )
            );
    }
    
    // Parallel (faster)
    public Mono<OrderDetails> getOrderDetailsParallel(String orderId) {
        return orderService.getOrder(orderId)
            .flatMap(order -> {
                Mono<User> userMono = userService.getUser(order.getUserId());
                Mono<Payment> paymentMono = paymentService.getPayment(order.getPaymentId());
                
                return Mono.zip(
                    Mono.just(order),
                    userMono,
                    paymentMono
                ).map(tuple -> new OrderDetails(
                    tuple.getT1(),
                    tuple.getT2(),
                    tuple.getT3()
                ));
            });
    }
}
```

### Timeout and Fallback

```java
@Service
public class ResilientService {
    private final ApiClient apiClient;
    
    public Mono<User> getUserWithFallback(String id) {
        return apiClient.getUser(id)
            .timeout(Duration.ofSeconds(5))
            .onErrorResume(TimeoutException.class, 
                e -> getCachedUser(id))
            .retryWhen(Retry.backoff(3, Duration.ofSeconds(1)));
    }
    
    private Mono<User> getCachedUser(String id) {
        // Return cached user or default
        return Mono.just(new User(id, "Default User"));
    }
}
```

## Quick Reference

```java
// Create
Mono.just(value)
Mono.empty()
Flux.just(values...)
Flux.fromIterable(list)
Flux.range(start, count)

// Transform
.map(v -> v * 2)
.flatMap(v -> Mono.just(v))
.filter(v -> v > 0)

// Combine
Flux.concat(flux1, flux2)
Flux.merge(flux1, flux2)
Flux.zip(flux1, flux2, (a, b) -> a + b)

// Error handling
.onErrorReturn(defaultValue)
.onErrorResume(e -> Flux.empty())
.retry(3)

// Subscribe
.subscribe(
    value -> System.out.println(value),
    error -> System.err.println(error),
    () -> System.out.println("Done")
)

// Block (avoid in production!)
Mono<String> mono = Mono.just("Hello");
String result = mono.block();  // Blocking call
```

## When to Use Reactive

✅ **Use Reactive When**:
- High concurrency requirements
- I/O-intensive applications (REST APIs, database calls)
- Real-time data streaming
- Handling backpressure important

❌ **Don't Use Reactive When**:
- Simple CRUD applications
- CPU-intensive tasks (not I/O bound)
- Team unfamiliar with reactive paradigm
- Legacy code integration difficult

---

**Previous**: [← Performance](java-25-performance.md) | **Next**: [Troubleshooting →](java-31-troubleshooting.md)
