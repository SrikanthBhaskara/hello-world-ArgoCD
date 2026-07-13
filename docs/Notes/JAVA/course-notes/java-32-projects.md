# Real-World Java Projects

## Project 1: RESTful Task Management API

### Overview
A production-ready REST API for task management with authentication, validation, and database persistence.

### Tech Stack
- Spring Boot 3.1
- Spring Security (JWT)
- Spring Data JPA
- MySQL/PostgreSQL
- Maven
- Lombok

### Project Structure

```
task-api/
├── src/main/java/com/example/taskapi/
│   ├── TaskApiApplication.java
│   ├── config/
│   │   ├── SecurityConfig.java
│   │   └── JwtConfig.java
│   ├── controller/
│   │   ├── AuthController.java
│   │   └── TaskController.java
│   ├── model/
│   │   ├── User.java
│   │   └── Task.java
│   ├── repository/
│   │   ├── UserRepository.java
│   │   └── TaskRepository.java
│   ├── service/
│   │   ├── AuthService.java
│   │   └── TaskService.java
│   ├── dto/
│   │   ├── LoginRequest.java
│   │   ├── TaskRequest.java
│   │   └── TaskResponse.java
│   ├── security/
│   │   ├── JwtTokenProvider.java
│   │   └── JwtAuthenticationFilter.java
│   └── exception/
│       ├── GlobalExceptionHandler.java
│       └── ResourceNotFoundException.java
├── src/main/resources/
│   ├── application.properties
│   └── schema.sql
└── pom.xml
```

### Key Files

**pom.xml**:
```xml
<dependencies>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-data-jpa</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-security</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-validation</artifactId>
    </dependency>
    <dependency>
        <groupId>io.jsonwebtoken</groupId>
        <artifactId>jjwt-api</artifactId>
        <version>0.11.5</version>
    </dependency>
    <dependency>
        <groupId>io.jsonwebtoken</groupId>
        <artifactId>jjwt-impl</artifactId>
        <version>0.11.5</version>
    </dependency>
    <dependency>
        <groupId>io.jsonwebtoken</groupId>
        <artifactId>jjwt-jackson</artifactId>
        <version>0.11.5</version>
    </dependency>
    <dependency>
        <groupId>mysql</groupId>
        <artifactId>mysql-connector-java</artifactId>
    </dependency>
    <dependency>
        <groupId>org.projectlombok</groupId>
        <artifactId>lombok</artifactId>
    </dependency>
</dependencies>
```

**Task.java**:
```java
@Entity
@Table(name = "tasks")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Task {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @NotBlank
    @Size(min = 3, max = 100)
    private String title;
    
    @Size(max = 500)
    private String description;
    
    @Enumerated(EnumType.STRING)
    private Status status = Status.TODO;
    
    @Enumerated(EnumType.STRING)
    private Priority priority = Priority.MEDIUM;
    
    private LocalDateTime dueDate;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user;
    
    @CreatedDate
    private LocalDateTime createdAt;
    
    @LastModifiedDate
    private LocalDateTime updatedAt;
    
    public enum Status {
        TODO, IN_PROGRESS, DONE
    }
    
    public enum Priority {
        LOW, MEDIUM, HIGH
    }
}
```

**TaskController.java**:
```java
@RestController
@RequestMapping("/api/tasks")
@RequiredArgsConstructor
public class TaskController {
    private final TaskService taskService;
    
    @PostMapping
    public ResponseEntity<TaskResponse> createTask(
            @Valid @RequestBody TaskRequest request,
            @AuthenticationPrincipal UserDetails userDetails) {
        TaskResponse task = taskService.createTask(request, userDetails.getUsername());
        return ResponseEntity.status(HttpStatus.CREATED).body(task);
    }
    
    @GetMapping
    public ResponseEntity<Page<TaskResponse>> getTasks(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(required = false) Task.Status status,
            @AuthenticationPrincipal UserDetails userDetails) {
        Page<TaskResponse> tasks = taskService.getTasks(
            userDetails.getUsername(), status, page, size);
        return ResponseEntity.ok(tasks);
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<TaskResponse> getTask(
            @PathVariable Long id,
            @AuthenticationPrincipal UserDetails userDetails) {
        TaskResponse task = taskService.getTask(id, userDetails.getUsername());
        return ResponseEntity.ok(task);
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<TaskResponse> updateTask(
            @PathVariable Long id,
            @Valid @RequestBody TaskRequest request,
            @AuthenticationPrincipal UserDetails userDetails) {
        TaskResponse task = taskService.updateTask(id, request, userDetails.getUsername());
        return ResponseEntity.ok(task);
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteTask(
            @PathVariable Long id,
            @AuthenticationPrincipal UserDetails userDetails) {
        taskService.deleteTask(id, userDetails.getUsername());
        return ResponseEntity.noContent().build();
    }
}
```

**JwtTokenProvider.java**:
```java
@Component
public class JwtTokenProvider {
    @Value("${jwt.secret}")
    private String secret;
    
    @Value("${jwt.expiration}")
    private long expiration;
    
    public String generateToken(String username) {
        Date now = new Date();
        Date expiryDate = new Date(now.getTime() + expiration);
        
        return Jwts.builder()
            .setSubject(username)
            .setIssuedAt(now)
            .setExpiration(expiryDate)
            .signWith(SignatureAlgorithm.HS512, secret)
            .compact();
    }
    
    public String getUsernameFromToken(String token) {
        Claims claims = Jwts.parserBuilder()
            .setSigningKey(secret)
            .build()
            .parseClaimsJws(token)
            .getBody();
        
        return claims.getSubject();
    }
    
    public boolean validateToken(String token) {
        try {
            Jwts.parserBuilder()
                .setSigningKey(secret)
                .build()
                .parseClaimsJws(token);
            return true;
        } catch (JwtException | IllegalArgumentException e) {
            return false;
        }
    }
}
```

### API Endpoints

```
POST   /api/auth/register    - Register new user
POST   /api/auth/login       - Login and get JWT token

GET    /api/tasks            - Get all tasks (paginated, filterable)
POST   /api/tasks            - Create new task
GET    /api/tasks/{id}       - Get task by ID
PUT    /api/tasks/{id}       - Update task
DELETE /api/tasks/{id}       - Delete task
```

### Testing

```bash
# Register user
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"john","email":"john@example.com","password":"password123"}'

# Login
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"john","password":"password123"}'

# Create task (use token from login)
curl -X POST http://localhost:8080/api/tasks \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{"title":"Learn Spring Boot","description":"Complete tutorial","priority":"HIGH","dueDate":"2024-12-31T23:59:59"}'

# Get all tasks
curl -X GET http://localhost:8080/api/tasks?page=0&size=10 \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

## Project 2: E-Commerce Microservices

### Overview
Microservices architecture for an e-commerce platform with service discovery, API gateway, and distributed tracing.

### Architecture

```
┌─────────────────┐
│   API Gateway   │ (Port 8080)
│   (Spring Cloud)│
└────────┬────────┘
         │
    ┌────┴──────────────────┬──────────────┐
    │                       │              │
┌───▼────────┐    ┌────────▼────┐   ┌────▼──────────┐
│ User Service│    │Order Service│   │Product Service│
│  (Port 8081)│    │ (Port 8082) │   │  (Port 8083)  │
└─────────────┘    └─────────────┘   └───────────────┘
         │                │                   │
         └────────────────┴───────────────────┘
                          │
                ┌─────────▼─────────┐
                │Service Discovery  │
                │  (Eureka Server)  │
                │   (Port 8761)     │
                └───────────────────┘
```

### Services

**1. Eureka Server (Service Discovery)**:

```java
@SpringBootApplication
@EnableEurekaServer
public class EurekaServerApplication {
    public static void main(String[] args) {
        SpringApplication.run(EurekaServerApplication.class, args);
    }
}
```

**application.properties**:
```properties
server.port=8761
eureka.client.register-with-eureka=false
eureka.client.fetch-registry=false
```

**2. API Gateway**:

```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-gateway</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-netflix-eureka-client</artifactId>
</dependency>
```

```java
@SpringBootApplication
@EnableDiscoveryClient
public class ApiGatewayApplication {
    public static void main(String[] args) {
        SpringApplication.run(ApiGatewayApplication.class, args);
    }
}
```

**application.yml**:
```yaml
spring:
  cloud:
    gateway:
      routes:
        - id: user-service
          uri: lb://USER-SERVICE
          predicates:
            - Path=/api/users/**
        
        - id: product-service
          uri: lb://PRODUCT-SERVICE
          predicates:
            - Path=/api/products/**
        
        - id: order-service
          uri: lb://ORDER-SERVICE
          predicates:
            - Path=/api/orders/**

eureka:
  client:
    service-url:
      defaultZone: http://localhost:8761/eureka
```

**3. Product Service**:

```java
@RestController
@RequestMapping("/api/products")
public class ProductController {
    private final ProductService productService;
    
    @GetMapping
    public List<Product> getAllProducts() {
        return productService.findAll();
    }
    
    @GetMapping("/{id}")
    public Product getProduct(@PathVariable Long id) {
        return productService.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("Product not found"));
    }
    
    @PostMapping
    public Product createProduct(@Valid @RequestBody Product product) {
        return productService.save(product);
    }
    
    @PutMapping("/{id}")
    public Product updateProduct(@PathVariable Long id, @RequestBody Product product) {
        product.setId(id);
        return productService.save(product);
    }
}
```

**4. Order Service** (with Feign Client):

```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-openfeign</artifactId>
</dependency>
```

```java
@FeignClient(name = "product-service")
public interface ProductClient {
    @GetMapping("/api/products/{id}")
    Product getProduct(@PathVariable Long id);
}

@Service
public class OrderService {
    private final OrderRepository orderRepository;
    private final ProductClient productClient;
    
    public Order createOrder(OrderRequest request) {
        // Get product details from product service
        Product product = productClient.getProduct(request.getProductId());
        
        // Create order
        Order order = new Order();
        order.setProductId(product.getId());
        order.setProductName(product.getName());
        order.setQuantity(request.getQuantity());
        order.setTotalPrice(product.getPrice() * request.getQuantity());
        
        return orderRepository.save(order);
    }
}
```

### Running the Project

```bash
# 1. Start Eureka Server
cd eureka-server
mvn spring-boot:run

# 2. Start services (in separate terminals)
cd product-service
mvn spring-boot:run

cd order-service
mvn spring-boot:run

cd user-service
mvn spring-boot:run

# 3. Start API Gateway
cd api-gateway
mvn spring-boot:run

# Access:
# Eureka Dashboard: http://localhost:8761
# API Gateway: http://localhost:8080
# Products: http://localhost:8080/api/products
# Orders: http://localhost:8080/api/orders
```

---

## Project 3: Real-Time Chat Application

### Overview
WebSocket-based real-time chat with Spring Boot and React.

### Backend

**pom.xml**:
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-websocket</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-mongodb</artifactId>
</dependency>
```

**WebSocketConfig.java**:
```java
@Configuration
@EnableWebSocketMessageBroker
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {
    
    @Override
    public void configureMessageBroker(MessageBrokerRegistry registry) {
        registry.enableSimpleBroker("/topic");
        registry.setApplicationDestinationPrefixes("/app");
    }
    
    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        registry.addEndpoint("/ws")
            .setAllowedOrigins("http://localhost:3000")
            .withSockJS();
    }
}
```

**ChatController.java**:
```java
@Controller
public class ChatController {
    
    @MessageMapping("/chat.send")
    @SendTo("/topic/public")
    public ChatMessage sendMessage(@Payload ChatMessage message) {
        return message;
    }
    
    @MessageMapping("/chat.addUser")
    @SendTo("/topic/public")
    public ChatMessage addUser(@Payload ChatMessage message) {
        message.setType(ChatMessage.MessageType.JOIN);
        return message;
    }
}
```

**ChatMessage.java**:
```java
@Data
@Document(collection = "messages")
public class ChatMessage {
    @Id
    private String id;
    private MessageType type;
    private String content;
    private String sender;
    private LocalDateTime timestamp;
    
    public enum MessageType {
        CHAT, JOIN, LEAVE
    }
}
```

### Frontend (React)

```javascript
import SockJS from 'sockjs-client';
import { Stomp } from '@stomp/stompjs';

let stompClient = null;

export const connect = (onMessageReceived) => {
  const socket = new SockJS('http://localhost:8080/ws');
  stompClient = Stomp.over(socket);

  stompClient.connect({}, () => {
    stompClient.subscribe('/topic/public', (message) => {
      onMessageReceived(JSON.parse(message.body));
    });
  });
};

export const sendMessage = (message) => {
  if (stompClient) {
    stompClient.send("/app/chat.send", {}, JSON.stringify(message));
  }
};

export const disconnect = () => {
  if (stompClient) {
    stompClient.disconnect();
  }
};
```

---

## Project 4: Batch Processing System

### Overview
Spring Batch application for processing large CSV files and loading into database.

**Job Configuration**:
```java
@Configuration
@EnableBatchProcessing
public class BatchConfig {
    
    @Bean
    public Job importUserJob(JobRepository jobRepository, Step step1) {
        return new JobBuilder("importUserJob", jobRepository)
            .start(step1)
            .build();
    }
    
    @Bean
    public Step step1(JobRepository jobRepository, PlatformTransactionManager transactionManager,
                      ItemReader<User> reader, ItemProcessor<User, User> processor,
                      ItemWriter<User> writer) {
        return new StepBuilder("step1", jobRepository)
            .<User, User>chunk(100, transactionManager)
            .reader(reader)
            .processor(processor)
            .writer(writer)
            .build();
    }
    
    @Bean
    public FlatFileItemReader<User> reader() {
        return new FlatFileItemReaderBuilder<User>()
            .name("userItemReader")
            .resource(new ClassPathResource("users.csv"))
            .delimited()
            .names("name", "email", "age")
            .targetType(User.class)
            .build();
    }
    
    @Bean
    public ItemProcessor<User, User> processor() {
        return user -> {
            // Transform, validate, or enrich data
            user.setEmail(user.getEmail().toLowerCase());
            return user;
        };
    }
    
    @Bean
    public JdbcBatchItemWriter<User> writer(DataSource dataSource) {
        return new JdbcBatchItemWriterBuilder<User>()
            .sql("INSERT INTO users (name, email, age) VALUES (:name, :email, :age)")
            .dataSource(dataSource)
            .beanMapped()
            .build();
    }
}
```

---

## Deployment

### Docker

**Dockerfile**:
```dockerfile
FROM openjdk:17-jdk-slim
WORKDIR /app
COPY target/myapp.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

**docker-compose.yml**:
```yaml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "8080:8080"
    environment:
      SPRING_DATASOURCE_URL: jdbc:mysql://db:3306/mydb
      SPRING_DATASOURCE_USERNAME: root
      SPRING_DATASOURCE_PASSWORD: password
    depends_on:
      - db
  
  db:
    image: mysql:8
    environment:
      MYSQL_ROOT_PASSWORD: password
      MYSQL_DATABASE: mydb
    ports:
      - "3306:3306"
    volumes:
      - db-data:/var/lib/mysql

volumes:
  db-data:
```

**Build and run**:
```bash
# Build JAR
mvn clean package

# Build Docker image
docker build -t myapp:latest .

# Run with Docker Compose
docker-compose up -d

# View logs
docker-compose logs -f app

# Stop
docker-compose down
```

---

## Best Practices

✅ **Code Organization**: Follow package-by-feature structure  
✅ **Configuration**: Use profiles (dev, test, prod)  
✅ **Security**: Never commit secrets, use environment variables  
✅ **Logging**: Use SLF4J, appropriate log levels  
✅ **Testing**: Unit tests (JUnit), integration tests (TestContainers)  
✅ **Documentation**: README, API docs (Swagger/OpenAPI)  
✅ **CI/CD**: GitHub Actions, Jenkins, or GitLab CI  
✅ **Monitoring**: Actuator endpoints, Prometheus, Grafana  
✅ **Error Handling**: Global exception handler  
✅ **Versioning**: Semantic versioning (1.0.0)  

---

**Previous**: [← Troubleshooting](java-31-troubleshooting.md) | **Index**: [↑ Java Learning Index](java-index.md)
