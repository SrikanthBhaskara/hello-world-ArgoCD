# JAVA MICROSERVICES ARCHITECTURE INTERVIEW GUIDE

**Complete guide covering microservices architecture, Spring Cloud, distributed systems, service communication, and production best practices for senior developer interviews.**

---

# TABLE OF CONTENTS

1. [Microservices Fundamentals](#1-microservices-fundamentals)
2. [Service Discovery (Eureka)](#2-service-discovery-eureka)
3. [API Gateway](#3-api-gateway)
4. [Load Balancing](#4-load-balancing)
5. [Configuration Management](#5-configuration-management)
6. [Circuit Breaker Pattern](#6-circuit-breaker-pattern)
7. [Inter-Service Communication](#7-inter-service-communication)
8. [Distributed Tracing](#8-distributed-tracing)
9. [Messaging with Kafka/RabbitMQ](#9-messaging-with-kafkarabbitmq)
10. [Saga Pattern (Distributed Transactions)](#10-saga-pattern-distributed-transactions)
11. [CQRS & Event Sourcing](#11-cqrs--event-sourcing)
12. [Security in Microservices](#12-security-in-microservices)
13. [Monitoring & Health Checks](#13-monitoring--health-checks)
14. [Deployment & Docker](#14-deployment--docker)
15. [Interview Questions](#15-interview-questions)
16. [Interview Traps](#16-interview-traps)
17. [Coding Problems](#17-coding-problems)
18. [Summary & Quick Reference](#18-summary--quick-reference)

---

# 1. MICROSERVICES FUNDAMENTALS

## What are Microservices?

**Microservices** are an architectural style where an application is composed of small, independent services that communicate over a network.

## Monolith vs Microservices

| **Aspect** | **Monolith** | **Microservices** |
|------------|--------------|------------------|
| **Deployment** | Single unit | Independent services |
| **Scaling** | Scale entire app | Scale individual services |
| **Technology** | Single tech stack | Polyglot (multiple technologies) |
| **Development** | Shared codebase | Independent teams |
| **Failure** | Single point of failure | Isolated failures |
| **Complexity** | Simple to start | Complex (distributed system) |

## Microservices Characteristics

```java
/**
 * 1. Single Responsibility: Each service does one thing
 * 2. Autonomous: Can be deployed independently
 * 3. Decentralized: Own database per service
 * 4. Resilient: Failure isolation
 * 5. Observable: Centralized logging & monitoring
 */

// Example: E-commerce microservices
- user-service (port 8081)
- product-service (port 8082)
- order-service (port 8083)
- payment-service (port 8084)
- notification-service (port 8085)
```

## When to Use Microservices?

**✅ Use when:**
- Large, complex application
- Multiple teams working independently
- Need to scale specific components
- Different technologies/languages needed

**❌ Avoid when:**
- Small application
- Simple business logic
- Team lacks distributed systems experience
- Network latency is critical

---

# 2. SERVICE DISCOVERY (EUREKA)

## Problem: How do services find each other?

With microservices, IP addresses change dynamically (containers, scaling). **Service Discovery** provides a registry to find services.

## Eureka Server Setup

```xml
<!-- pom.xml -->
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-netflix-eureka-server</artifactId>
</dependency>
```

```java
@SpringBootApplication
@EnableEurekaServer
public class EurekaServerApplication {
    public static void main(String[] args) {
        SpringApplication.run(EurekaServerApplication.class, args);
    }
}
```

```yaml
# application.yml
server:
  port: 8761

eureka:
  client:
    register-with-eureka: false  # Don't register itself
    fetch-registry: false          # Don't fetch registry
```

**Access:** http://localhost:8761

## Eureka Client (Service Registration)

```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-netflix-eureka-client</artifactId>
</dependency>
```

```java
@SpringBootApplication
@EnableEurekaClient  // or @EnableDiscoveryClient
public class ProductServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(ProductServiceApplication.class, args);
    }
}
```

```yaml
# application.yml
server:
  port: 8082

spring:
  application:
    name: product-service  # Service name in Eureka

eureka:
  client:
    service-url:
      defaultZone: http://localhost:8761/eureka/
  instance:
    prefer-ip-address: true
```

## Service Discovery in Action

```java
@RestController
@RequestMapping("/orders")
public class OrderController {
    
    @Autowired
    private DiscoveryClient discoveryClient;
    
    @Autowired
    private RestTemplate restTemplate;
    
    @GetMapping("/{id}")
    public Order getOrder(@PathVariable Long id) {
        // Get service instances from Eureka
        List<ServiceInstance> instances = 
            discoveryClient.getInstances("product-service");
        
        if (instances.isEmpty()) {
            throw new ServiceException("Product service not available");
        }
        
        ServiceInstance instance = instances.get(0);
        String url = instance.getUri() + "/products/1";
        
        // Call product service
        Product product = restTemplate.getForObject(url, Product.class);
        
        return new Order(id, product);
    }
}

// Configuration
@Configuration
public class Config {
    @Bean
    @LoadBalanced  // Enables service name resolution
    public RestTemplate restTemplate() {
        return new RestTemplate();
    }
}

// With @LoadBalanced, you can use service name:
Product product = restTemplate.getForObject(
    "http://product-service/products/1",  // Service name instead of URL
    Product.class
);
```

---

# 3. API GATEWAY

## Problem: Clients calling multiple microservices directly

- Too many endpoints
- Security handled per service
- CORS issues
- Multiple round trips

## Solution: API Gateway

**Single entry point** for all client requests. Routes requests to appropriate microservices.

## Spring Cloud Gateway

```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-gateway</artifactId>
</dependency>
```

```java
@SpringBootApplication
public class ApiGatewayApplication {
    public static void main(String[] args) {
        SpringApplication.run(ApiGatewayApplication.class, args);
    }
}
```

```yaml
# application.yml
server:
  port: 8080

spring:
  application:
    name: api-gateway
  cloud:
    gateway:
      routes:
        - id: user-service
          uri: lb://user-service  # lb = load balanced
          predicates:
            - Path=/api/users/**
          filters:
            - StripPrefix=1  # Remove /api from path
            
        - id: product-service
          uri: lb://product-service
          predicates:
            - Path=/api/products/**
          filters:
            - StripPrefix=1
            
        - id: order-service
          uri: lb://order-service
          predicates:
            - Path=/api/orders/**
          filters:
            - StripPrefix=1

eureka:
  client:
    service-url:
      defaultZone: http://localhost:8761/eureka/
```

**Requests:**
```
GET http://localhost:8080/api/users/1
→ Routed to: http://user-service:8081/users/1

GET http://localhost:8080/api/products/5
→ Routed to: http://product-service:8082/products/5
```

## Custom Gateway Filters

```java
@Component
public class AuthenticationFilter implements GlobalFilter, Ordered {
    
    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        ServerHttpRequest request = exchange.getRequest();
        
        // Check for Authorization header
        if (!request.getHeaders().containsKey("Authorization")) {
            exchange.getResponse().setStatusCode(HttpStatus.UNAUTHORIZED);
            return exchange.getResponse().setComplete();
        }
        
        String token = request.getHeaders().getFirst("Authorization");
        
        // Validate token
        if (!isValidToken(token)) {
            exchange.getResponse().setStatusCode(HttpStatus.UNAUTHORIZED);
            return exchange.getResponse().setComplete();
        }
        
        // Continue filter chain
        return chain.filter(exchange);
    }
    
    @Override
    public int getOrder() {
        return -1;  // High priority
    }
    
    private boolean isValidToken(String token) {
        // JWT validation logic
        return token != null && token.startsWith("Bearer ");
    }
}
```

---

# 4. LOAD BALANCING

## Client-Side Load Balancing (Spring Cloud LoadBalancer)

```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-loadbalancer</artifactId>
</dependency>
```

```java
@Configuration
public class LoadBalancerConfig {
    
    @Bean
    @LoadBalanced
    public RestTemplate restTemplate() {
        return new RestTemplate();
    }
}

@Service
public class OrderService {
    
    @Autowired
    private RestTemplate restTemplate;
    
    public Product getProduct(Long id) {
        // Load balancer automatically distributes requests
        // across all product-service instances
        return restTemplate.getForObject(
            "http://product-service/products/" + id,
            Product.class
        );
    }
}
```

## Load Balancing Algorithms

```java
/**
 * 1. Round Robin (default): Cycles through instances
 * 2. Random: Random instance selection
 * 3. Weighted: Based on instance capacity
 * 4. Least Connections: Route to instance with fewest active connections
 */

// Custom load balancer configuration
@Configuration
public class CustomLoadBalancerConfig {
    
    @Bean
    public ReactorLoadBalancer<ServiceInstance> reactorServiceInstanceLoadBalancer(
            Environment environment,
            LoadBalancerClientFactory loadBalancerClientFactory) {
        String name = environment.getProperty(LoadBalancerClientFactory.PROPERTY_NAME);
        return new RandomLoadBalancer(
            loadBalancerClientFactory.getLazyProvider(name, ServiceInstanceListSupplier.class),
            name
        );
    }
}
```

---

# 5. CONFIGURATION MANAGEMENT

## Problem: Managing configurations across multiple services

**Spring Cloud Config Server** centralizes configuration management.

## Config Server Setup

```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-config-server</artifactId>
</dependency>
```

```java
@SpringBootApplication
@EnableConfigServer
public class ConfigServerApplication {
    public static void main(String[] args) {
        SpringApplication.run(ConfigServerApplication.class, args);
    }
}
```

```yaml
# application.yml
server:
  port: 8888

spring:
  application:
    name: config-server
  cloud:
    config:
      server:
        git:
          uri: https://github.com/your-repo/config-repo
          default-label: main
          search-paths: '{application}'
```

**Git Repository Structure:**
```
config-repo/
  ├── application.yml        # Common config for all services
  ├── product-service.yml    # Product service specific
  ├── order-service.yml      # Order service specific
  └── user-service.yml       # User service specific
```

## Config Client (Service)

```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-config</artifactId>
</dependency>
```

```yaml
# application.yml
spring:
  application:
    name: product-service
  config:
    import: optional:configserver:http://localhost:8888
  cloud:
    config:
      fail-fast: true
      retry:
        max-attempts: 5
```

## Refreshing Configuration

```java
@RestController
@RefreshScope  // Allows config refresh without restart
public class ProductController {
    
    @Value("${product.message:Default message}")
    private String message;
    
    @GetMapping("/config")
    public String getConfig() {
        return message;
    }
}
```

**Refresh endpoint:**
```bash
POST http://localhost:8082/actuator/refresh
```

---

# 6. CIRCUIT BREAKER PATTERN

## Problem: Cascading failures in distributed systems

If one service is down, calls to it will timeout, blocking threads and potentially crashing other services.

## Solution: Circuit Breaker (Resilience4j)

```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-circuitbreaker-resilience4j</artifactId>
</dependency>
```

```yaml
# application.yml
resilience4j:
  circuitbreaker:
    instances:
      productService:
        register-health-indicator: true
        sliding-window-size: 10
        minimum-number-of-calls: 5
        permitted-number-of-calls-in-half-open-state: 3
        wait-duration-in-open-state: 10s
        failure-rate-threshold: 50
        slow-call-duration-threshold: 2s
        slow-call-rate-threshold: 50
```

```java
@Service
public class OrderService {
    
    @Autowired
    private RestTemplate restTemplate;
    
    @CircuitBreaker(name = "productService", fallbackMethod = "getProductFallback")
    public Product getProduct(Long id) {
        return restTemplate.getForObject(
            "http://product-service/products/" + id,
            Product.class
        );
    }
    
    // Fallback method (same signature + Throwable)
    public Product getProductFallback(Long id, Throwable throwable) {
        log.error("Circuit breaker activated for product: " + id, throwable);
        // Return cached data or default
        return new Product(id, "Default Product", 0.0);
    }
}
```

## Circuit Breaker States

```
CLOSED → OPEN → HALF_OPEN → CLOSED|OPEN

1. CLOSED: Normal operation
   - Requests pass through
   - Tracks failures

2. OPEN: Too many failures
   - Requests fail immediately
   - Fallback method called
   - After wait duration → HALF_OPEN

3. HALF_OPEN: Testing if service recovered
   - Limited requests pass through
   - If success → CLOSED
   - If failure → OPEN
```

## Retry Pattern

```java
@Service
public class ProductService {
    
    @Retry(name = "productRetry", fallbackMethod = "getProductFallback")
    public Product getProduct(Long id) {
        return restTemplate.getForObject(
            "http://product-service/products/" + id,
            Product.class
        );
    }
    
    public Product getProductFallback(Long id, Exception e) {
        return new Product(id, "Unavailable", 0.0);
    }
}
```

```yaml
resilience4j:
  retry:
    instances:
      productRetry:
        max-attempts: 3
        wait-duration: 1s
        retry-exceptions:
          - java.net.ConnectException
```

---

# 7. INTER-SERVICE COMMUNICATION

## Synchronous (REST)

```java
@Service
public class OrderService {
    
    @Autowired
    private RestTemplate restTemplate;
    
    public Order createOrder(OrderRequest request) {
        // 1. Get user
        User user = restTemplate.getForObject(
            "http://user-service/users/" + request.getUserId(),
            User.class
        );
        
        // 2. Get product
        Product product = restTemplate.getForObject(
            "http://product-service/products/" + request.getProductId(),
            Product.class
        );
        
        // 3. Process payment
        PaymentResponse payment = restTemplate.postForObject(
            "http://payment-service/payments",
            new PaymentRequest(user.getId(), product.getPrice()),
            PaymentResponse.class
        );
        
        // 4. Create order
        Order order = new Order();
        order.setUserId(user.getId());
        order.setProductId(product.getId());
        order.setPaymentId(payment.getId());
        
        return orderRepository.save(order);
    }
}
```

**Problem with synchronous:** Blocking, tight coupling, cascading failures

## Asynchronous (Messaging)

```java
@Service
public class OrderService {
    
    @Autowired
    private KafkaTemplate<String, OrderEvent> kafkaTemplate;
    
    public Order createOrder(OrderRequest request) {
        // Create order
        Order order = new Order();
        order.setUserId(request.getUserId());
        order.setProductId(request.getProductId());
        order.setStatus("PENDING");
        
        Order savedOrder = orderRepository.save(order);
        
        // Publish event (non-blocking)
        OrderEvent event = new OrderEvent(
            savedOrder.getId(),
            savedOrder.getUserId(),
            savedOrder.getProductId()
        );
        kafkaTemplate.send("order-created", event);
        
        return savedOrder;
    }
}

// Payment Service listens to events
@Service
public class PaymentEventListener {
    
    @KafkaListener(topics = "order-created", groupId = "payment-service")
    public void handleOrderCreated(OrderEvent event) {
        // Process payment asynchronously
        processPayment(event);
    }
}
```

---

# 8. DISTRIBUTED TRACING

## Problem: Debugging requests across multiple services

**Spring Cloud Sleuth** adds trace and span IDs to requests.

```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-sleuth</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-sleuth-zipkin</artifactId>
</dependency>
```

```yaml
# application.yml
spring:
  sleuth:
    sampler:
      probability: 1.0  # Sample 100% of requests
  zipkin:
    base-url: http://localhost:9411  # Zipkin server
```

**Log output with tracing:**
```
[order-service,abc123,def456] Processing order
[payment-service,abc123,ghi789] Processing payment
[notification-service,abc123,jkl012] Sending email

TraceID: abc123 (same across all services)
SpanID: Unique per service
```

## Zipkin UI

Access: http://localhost:9411

Shows request flow across services with timing information.

---

# 9. MESSAGING WITH KAFKA/RABBITMQ

## Kafka Producer

```xml
<dependency>
    <groupId>org.springframework.kafka</groupId>
    <artifactId>spring-kafka</artifactId>
</dependency>
```

```yaml
spring:
  kafka:
    bootstrap-servers: localhost:9092
    producer:
      key-serializer: org.apache.kafka.common.serialization.StringSerializer
      value-serializer: org.springframework.kafka.support.serializer.JsonSerializer
```

```java
@Service
public class OrderService {
    
    @Autowired
    private KafkaTemplate<String, OrderEvent> kafkaTemplate;
    
    public void createOrder(Order order) {
        orderRepository.save(order);
        
        // Publish event
        OrderEvent event = new OrderEvent(order.getId(), order.getUserId());
        kafkaTemplate.send("order-events", event);
    }
}
```

## Kafka Consumer

```yaml
spring:
  kafka:
    bootstrap-servers: localhost:9092
    consumer:
      group-id: notification-service
      key-deserializer: org.apache.kafka.common.serialization.StringDeserializer
      value-deserializer: org.springframework.kafka.support.serializer.JsonDeserializer
      properties:
        spring.json.trusted.packages: "*"
```

```java
@Service
public class NotificationService {
    
    @KafkaListener(topics = "order-events", groupId = "notification-service")
    public void handleOrderEvent(OrderEvent event) {
        log.info("Received order event: " + event.getOrderId());
        sendNotification(event.getUserId(), "Order created");
    }
}
```

---

# 10. SAGA PATTERN (DISTRIBUTED TRANSACTIONS)

## Problem: ACID transactions don't work across microservices

Each service has its own database. Can't use traditional transactions.

## Saga Pattern: Choreography-Based

```java
// Order Service
@Service
public class OrderService {
    
    @Autowired
    private KafkaTemplate<String, OrderEvent> kafkaTemplate;
    
    @Transactional
    public Order createOrder(OrderRequest request) {
        // 1. Create order (PENDING)
        Order order = new Order();
        order.setStatus("PENDING");
        Order savedOrder = orderRepository.save(order);
        
        // 2. Publish event
        OrderCreatedEvent event = new OrderCreatedEvent(savedOrder.getId());
        kafkaTemplate.send("order-created", event);
        
        return savedOrder;
    }
    
    // Listen for payment failure
    @KafkaListener(topics = "payment-failed")
    public void handlePaymentFailed(PaymentFailedEvent event) {
        Order order = orderRepository.findById(event.getOrderId()).orElseThrow();
        order.setStatus("CANCELLED");
        orderRepository.save(order);
    }
}

// Payment Service
@Service
public class PaymentService {
    
    @KafkaListener(topics = "order-created")
    public void handleOrderCreated(OrderCreatedEvent event) {
        try {
            // Process payment
            Payment payment = processPayment(event.getOrderId());
            
            // Success: Publish event
            PaymentSuccessEvent successEvent = new PaymentSuccessEvent(event.getOrderId());
            kafkaTemplate.send("payment-success", successEvent);
            
        } catch (Exception e) {
            // Failure: Publish compensating event
            PaymentFailedEvent failedEvent = new PaymentFailedEvent(event.getOrderId());
            kafkaTemplate.send("payment-failed", failedEvent);
        }
    }
}
```

**Saga Flow:**
```
OrderService → order-created event
  ↓
PaymentService → process payment
  ↓ (success)
payment-success event → ShippingService
  ↓ (failure)
payment-failed event → OrderService (compensate: cancel order)
```

---

# 11. CQRS & EVENT SOURCING

## CQRS (Command Query Responsibility Segregation)

Separate **read** and **write** models.

```java
// Command side (Write)
@Service
public class OrderCommandService {
    
    @Transactional
    public Order createOrder(CreateOrderCommand command) {
        Order order = new Order();
        order.setUserId(command.getUserId());
        order.setProductId(command.getProductId());
        return orderRepository.save(order);
    }
}

// Query side (Read)
@Service
public class OrderQueryService {
    
    @Autowired
    private OrderReadRepository readRepository;  // Read-optimized database
    
    public List<OrderDTO> getUserOrders(Long userId) {
        return readRepository.findByUserId(userId);  // Optimized for reads
    }
}

// Different databases
Write DB: PostgreSQL (normalized)
Read DB: MongoDB (denormalized for fast queries)
```

---

# 12. SECURITY IN MICROSERVICES

## JWT Authentication

```java
@RestController
@RequestMapping("/auth")
public class AuthController {
    
    @Autowired
    private JwtTokenProvider tokenProvider;
    
    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest request) {
        // Authenticate user
        Authentication auth = authenticationManager.authenticate(
            new UsernamePasswordAuthenticationToken(
                request.getUsername(),
                request.getPassword()
            )
        );
        
        // Generate JWT
        String token = tokenProvider.generateToken(auth);
        return ResponseEntity.ok(new JwtResponse(token));
    }
}

// JWT Filter
@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {
    
    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {
        
        String jwt = getJwtFromRequest(request);
        
        if (jwt != null && tokenProvider.validateToken(jwt)) {
            String username = tokenProvider.getUsernameFromToken(jwt);
            
            UserDetails userDetails = userDetailsService.loadUserByUsername(username);
            UsernamePasswordAuthenticationToken authentication =
                new UsernamePasswordAuthenticationToken(userDetails, null, userDetails.getAuthorities());
            
            SecurityContextHolder.getContext().setAuthentication(authentication);
        }
        
        filterChain.doFilter(request, response);
    }
}
```

---

# 13. MONITORING & HEALTH CHECKS

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
```

```yaml
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,prometheus
  endpoint:
    health:
      show-details: always
```

**Access:**
- http://localhost:8082/actuator/health
- http://localhost:8082/actuator/metrics

---

# 14. DEPLOYMENT & DOCKER

## Dockerfile

```dockerfile
FROM openjdk:17-slim
WORKDIR /app
COPY target/product-service.jar app.jar
EXPOSE 8082
ENTRYPOINT ["java", "-jar", "app.jar"]
```

## docker-compose.yml

```yaml
version: '3.8'
services:
  eureka:
    image: eureka-server:latest
    ports:
      - "8761:8761"
  
  product-service:
    image: product-service:latest
    ports:
      - "8082:8082"
    environment:
      - EUREKA_CLIENT_SERVICEURL_DEFAULTZONE=http://eureka:8761/eureka/
    depends_on:
      - eureka
  
  order-service:
    image: order-service:latest
    ports:
      - "8083:8083"
    environment:
      - EUREKA_CLIENT_SERVICEURL_DEFAULTZONE=http://eureka:8761/eureka/
    depends_on:
      - eureka
```

---

# 15. INTERVIEW QUESTIONS

## Q1: Monolith vs Microservices trade-offs?

**Monolith Pros:**
- Simple deployment
- Easy debugging
- No network latency

**Microservices Pros:**
- Independent scaling
- Technology flexibility
- Fault isolation

**When to use Microservices:** Large, complex applications with multiple teams.

---

## Q2: How do you handle distributed transactions?

**Answer:** Use **Saga pattern** (choreography or orchestration).

```java
// Choreography: Services communicate via events
Order created → Payment processed → Inventory updated
If payment fails → Publish compensating event → Cancel order
```

---

## Q3: What is Circuit Breaker and why use it?

**Answer:** Prevents cascading failures.

**Without Circuit Breaker:**
- Service A calls Service B (down)
- Requests timeout (30s)
- Threads blocked
- Service A crashes

**With Circuit Breaker:**
- After 50% failures → Circuit OPEN
- Requests fail fast (no timeout)
- Fallback method returns cached data
- Service A remains responsive

---

# 16. INTERVIEW TRAPS

## Trap: "Use 2-Phase Commit for distributed transactions"

❌ **Wrong:** 2PC doesn't scale in microservices (blocking, requires lock manager)

✅ **Right:** Use Saga pattern (eventual consistency)

---

# 17. CODING PROBLEMS

## Problem: Implement Order Service with Circuit Breaker

```java
@Service
public class OrderService {
    
    @Autowired
    private RestTemplate restTemplate;
    
    @CircuitBreaker(name = "inventoryService", fallbackMethod = "checkInventoryFallback")
    public boolean checkInventory(Long productId) {
        InventoryResponse response = restTemplate.getForObject(
            "http://inventory-service/check/" + productId,
            InventoryResponse.class
        );
        return response.isAvailable();
    }
    
    public boolean checkInventoryFallback(Long productId, Throwable t) {
        log.warn("Inventory service down, using fallback");
        return false;  // Assume out of stock
    }
    
    public Order createOrder(OrderRequest request) {
        boolean available = checkInventory(request.getProductId());
        if (!available) {
            throw new OutOfStockException("Product unavailable");
        }
        
        Order order = new Order();
        order.setProductId(request.getProductId());
        return orderRepository.save(order);
    }
}
```

---

# 18. SUMMARY & QUICK REFERENCE

## Microservices Components

| **Component** | **Technology** | **Purpose** |
|---------------|----------------|-------------|
| Service Discovery | Eureka | Find services dynamically |
| API Gateway | Spring Cloud Gateway | Single entry point |
| Load Balancer | Spring Cloud LoadBalancer | Distribute requests |
| Config Management | Spring Cloud Config | Centralized configuration |
| Circuit Breaker | Resilience4j | Prevent cascading failures |
| Distributed Tracing | Sleuth + Zipkin | Track requests across services |
| Messaging | Kafka/RabbitMQ | Async communication |
| Monitoring | Actuator + Prometheus | Health checks & metrics |

## Key Patterns

```
Service Discovery: Dynamic service location
API Gateway: Single entry point
Circuit Breaker: Fault tolerance
Saga: Distributed transactions
CQRS: Separate read/write models
Event Sourcing: Store events not state
```

---

**END OF MICROSERVICES ARCHITECTURE INTERVIEW GUIDE**

Master these concepts for distributed systems and microservices interviews!

**Next Guide:** Testing & Build Tools (Topic 5 of 5)
