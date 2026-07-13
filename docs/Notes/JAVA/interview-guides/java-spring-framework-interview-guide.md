# SPRING FRAMEWORK & SPRING BOOT - COMPLETE INTERVIEW GUIDE

**Target Audience:** 5+ Years Experienced Backend Java Developers  
**Last Updated:** March 2026  
**Difficulty:** Intermediate to Advanced  

---

## TABLE OF CONTENTS

1. [Spring Core Concepts](#1-spring-core-concepts)
2. [Dependency Injection & IoC Container](#2-dependency-injection--ioc-container)
3. [Bean Lifecycle & Scopes](#3-bean-lifecycle--scopes)
4. [Aspect-Oriented Programming (AOP)](#4-aspect-oriented-programming-aop)
5. [Spring Boot Fundamentals](#5-spring-boot-fundamentals)
6. [Spring Boot Auto-Configuration](#6-spring-boot-auto-configuration)
7. [REST APIs with Spring MVC](#7-rest-apis-with-spring-mvc)
8. [Exception Handling & Validation](#8-exception-handling--validation)
9. [Spring Data JPA](#9-spring-data-jpa)
10. [Transactions in Spring](#10-transactions-in-spring)
11. [Spring Security Basics](#11-spring-security-basics)
12. [Testing Spring Applications](#12-testing-spring-applications)
13. [Spring Boot Production Features](#13-spring-boot-production-features)
14. [Interview Questions](#14-interview-questions)
15. [Interview Traps & Edge Cases](#15-interview-traps--edge-cases)
16. [Coding Problems](#16-coding-problems)
17. [Summary & Quick Reference](#17-summary--quick-reference)

---

# 1. SPRING CORE CONCEPTS

## 1.1 What is Spring Framework?

**Spring Framework** is a comprehensive enterprise application development framework for Java. It provides:

- **Inversion of Control (IoC)**: Manages object lifecycle
- **Dependency Injection (DI)**: Automatically wires dependencies
- **Aspect-Oriented Programming (AOP)**: Cross-cutting concerns
- **Data Access**: JDBC, ORM, Transactions
- **MVC Framework**: Web applications
- **Security**: Authentication & Authorization
- **Testing**: Mock objects, integration testing

**Spring vs Spring Boot:**

| Aspect | Spring Framework | Spring Boot |
|--------|-----------------|-------------|
| **Configuration** | XML or Java Config (verbose) | Convention over configuration |
| **Setup** | Manual dependency management | Starter dependencies |
| **Server** | External (Tomcat, Jetty) | Embedded server |
| **Auto-Configuration** | Manual | Automatic based on classpath |
| **Production Ready** | Manual setup | Built-in (Actuator, Metrics) |
| **Learning Curve** | Steeper | Easier |

## 1.2 Spring Architecture (Modules)

```
Spring Framework
├── Core Container
│   ├── spring-core       (Core utilities)
│   ├── spring-beans      (Bean factory, DI)
│   ├── spring-context    (Application context, internationalization)
│   └── spring-expression (SpEL - Spring Expression Language)
├── AOP & Instrumentation
│   ├── spring-aop        (Aspect-Oriented Programming)
│   └── spring-aspects    (AspectJ integration)
├── Data Access/Integration
│   ├── spring-jdbc       (JDBC abstraction)
│   ├── spring-tx         (Transaction management)
│   ├── spring-orm        (JPA, Hibernate integration)
│   └── spring-oxm        (Object-XML mapping)
├── Web
│   ├── spring-web        (Web basics, REST clients)
│   ├── spring-webmvc     (MVC framework, REST APIs)
│   └── spring-websocket  (WebSocket support)
└── Test
    └── spring-test       (Unit & Integration testing)
```

## 1.3 Hello World Example

**Traditional Spring (XML Configuration):**

```xml
<!-- applicationContext.xml -->
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
       http://www.springframework.org/schema/beans/spring-beans.xsd">
    
    <bean id="userService" class="com.example.UserService">
        <property name="userRepository" ref="userRepository"/>
    </bean>
    
    <bean id="userRepository" class="com.example.UserRepository"/>
</beans>
```

```java
public class App {
    public static void main(String[] args) {
        ApplicationContext context = 
            new ClassPathXmlApplicationContext("applicationContext.xml");
        
        UserService userService = context.getBean(UserService.class);
        userService.createUser("John");
    }
}
```

**Modern Spring (Java Configuration):**

```java
@Configuration
public class AppConfig {
    
    @Bean
    public UserRepository userRepository() {
        return new UserRepository();
    }
    
    @Bean
    public UserService userService() {
        return new UserService(userRepository());
    }
}

public class App {
    public static void main(String[] args) {
        ApplicationContext context = 
            new AnnotationConfigApplicationContext(AppConfig.class);
        
        UserService userService = context.getBean(UserService.class);
        userService.createUser("John");
    }
}
```

**Spring Boot (Simplest):**

```java
@SpringBootApplication
public class Application {
    
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}

@Service
public class UserService {
    
    private final UserRepository userRepository;
    
    @Autowired  // Optional in single constructor
    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }
    
    public void createUser(String name) {
        userRepository.save(new User(name));
    }
}

@Repository
public class UserRepository {
    public void save(User user) {
        // Save logic
    }
}
```

---

# 2. DEPENDENCY INJECTION & IOC CONTAINER

## 2.1 What is IoC (Inversion of Control)?

**Traditional Approach (You Control Objects):**

```java
public class UserService {
    private UserRepository repository = new UserRepository();  // Tight coupling
    
    public void createUser(String name) {
        repository.save(new User(name));
    }
}

// Problems:
// 1. Hard to test (can't mock repository)
// 2. Tight coupling
// 3. Cannot change implementation
// 4. Manual lifecycle management
```

**IoC Approach (Framework Controls Objects):**

```java
@Service
public class UserService {
    private final UserRepository repository;
    
    @Autowired
    public UserService(UserRepository repository) {  // Injected by Spring
        this.repository = repository;
    }
    
    public void createUser(String name) {
        repository.save(new User(name));
    }
}

// Benefits:
// 1. Easy to test (inject mock)
// 2. Loose coupling
// 3. Can swap implementations
// 4. Spring manages lifecycle
```

## 2.2 Types of Dependency Injection

### Constructor Injection (Recommended ✅)

```java
@Service
public class OrderService {
    
    private final UserRepository userRepository;
    private final ProductRepository productRepository;
    private final EmailService emailService;
    
    // Spring injects dependencies via constructor
    @Autowired  // Optional if only one constructor
    public OrderService(UserRepository userRepository,
                       ProductRepository productRepository,
                       EmailService emailService) {
        this.userRepository = userRepository;
        this.productRepository = productRepository;
        this.emailService = emailService;
    }
    
    public Order createOrder(Long userId, Long productId) {
        User user = userRepository.findById(userId);
        Product product = productRepository.findById(productId);
        Order order = new Order(user, product);
        emailService.sendOrderConfirmation(user.getEmail(), order);
        return order;
    }
}

// Advantages:
// - Immutable (final fields)
// - All dependencies required at construction
// - Easy to test (pass mocks in constructor)
// - Prevents NullPointerException
// - Clear dependencies
```

### Setter Injection (Legacy ⚠️)

```java
@Service
public class NotificationService {
    
    private EmailService emailService;
    private SmsService smsService;
    
    @Autowired
    public void setEmailService(EmailService emailService) {
        this.emailService = emailService;
    }
    
    @Autowired
    public void setSmsService(SmsService smsService) {
        this.smsService = smsService;
    }
}

// Disadvantages:
// - Mutable (not final)
// - Optional dependencies (can be null)
// - Order of injection undefined
// - Not recommended in modern Spring
```

### Field Injection (Avoid ❌)

```java
@Service
public class PaymentService {
    
    @Autowired
    private PaymentGateway paymentGateway;  // Field injection
    
    @Autowired
    private AccountService accountService;
}

// Problems:
// - Cannot make fields final (mutable)
// - Hard to test (need reflection or Spring context)
// - Hides dependencies
// - Breaks encapsulation
// - Not recommended by Spring team
```

## 2.3 Qualifier - Resolving Multiple Beans

**Problem: Multiple Implementations:**

```java
public interface NotificationService {
    void send(String message);
}

@Service
public class EmailNotificationService implements NotificationService {
    public void send(String message) {
        // Send email
    }
}

@Service
public class SmsNotificationService implements NotificationService {
    public void send(String message) {
        // Send SMS
    }
}

@Service
public class OrderService {
    
    @Autowired
    private NotificationService notificationService;  
    // ERROR: NoUniqueBeanDefinitionException
    // Which one? EmailNotificationService or SmsNotificationService?
}
```

**Solution 1: @Qualifier**

```java
@Service
public class OrderService {
    
    private final NotificationService emailService;
    private final NotificationService smsService;
    
    public OrderService(
            @Qualifier("emailNotificationService") NotificationService emailService,
            @Qualifier("smsNotificationService") NotificationService smsService) {
        this.emailService = emailService;
        this.smsService = smsService;
    }
    
    public void notifyUser(User user, String message) {
        if (user.hasEmail()) {
            emailService.send(message);
        }
        if (user.hasPhone()) {
            smsService.send(message);
        }
    }
}
```

**Solution 2: @Primary**

```java
@Service
@Primary  // Default choice when multiple beans available
public class EmailNotificationService implements NotificationService {
    public void send(String message) {
        // Send email
    }
}

@Service
public class SmsNotificationService implements NotificationService {
    public void send(String message) {
        // Send SMS
    }
}

@Service
public class OrderService {
    
    @Autowired
    private NotificationService notificationService;  
    // Injects EmailNotificationService (marked as @Primary)
}
```

**Solution 3: List Injection**

```java
@Service
public class NotificationDispatcher {
    
    private final List<NotificationService> notificationServices;
    
    public NotificationDispatcher(List<NotificationService> notificationServices) {
        this.notificationServices = notificationServices;
        // Injects ALL implementations (Email, SMS)
    }
    
    public void notifyAll(String message) {
        notificationServices.forEach(service -> service.send(message));
    }
}
```

## 2.4 @Conditional - Conditional Bean Registration

```java
@Configuration
public class CacheConfig {
    
    // Register bean only if Redis is available
    @Bean
    @ConditionalOnClass(name = "org.springframework.data.redis.core.RedisTemplate")
    public CacheManager redisCacheManager() {
        return new RedisCacheManager();
    }
    
    // Register bean if Redis NOT available (fallback)
    @Bean
    @ConditionalOnMissingBean(CacheManager.class)
    public CacheManager simpleCacheManager() {
        return new ConcurrentMapCacheManager();
    }
    
    // Register based on property
    @Bean
    @ConditionalOnProperty(name = "app.cache.enabled", havingValue = "true")
    public CacheService cacheService() {
        return new CacheService();
    }
}
```

**Common Conditional Annotations:**

```java
@ConditionalOnBean(DataSource.class)          // If DataSource bean exists
@ConditionalOnMissingBean(DataSource.class)   // If DataSource bean missing
@ConditionalOnClass(RedisTemplate.class)      // If class in classpath
@ConditionalOnMissingClass("com.example.Foo") // If class NOT in classpath
@ConditionalOnProperty(name = "app.enabled", havingValue = "true")
@ConditionalOnResource(resources = "classpath:config.properties")
@ConditionalOnExpression("${app.port} > 8080")
@ConditionalOnWebApplication               // If web application
@ConditionalOnNotWebApplication            // If NOT web application
```

---

# 3. BEAN LIFECYCLE & SCOPES

## 3.1 Bean Lifecycle

**Complete Bean Lifecycle:**

```
1. Instantiation         → Constructor called
2. Populate Properties   → Setter injection, field injection
3. BeanNameAware         → setBeanName() called
4. BeanFactoryAware      → setBeanFactory() called
5. ApplicationContextAware → setApplicationContext() called
6. BeanPostProcessor     → postProcessBeforeInitialization()
7. @PostConstruct        → Custom initialization method
8. InitializingBean      → afterPropertiesSet() called
9. init-method           → Custom init method (XML or @Bean(initMethod))
10. BeanPostProcessor    → postProcessAfterInitialization()
11. Bean Ready           → Bean ready for use
12. @PreDestroy          → Custom cleanup method
13. DisposableBean       → destroy() called
14. destroy-method       → Custom destroy method
```

**Example:**

```java
@Component
public class LifecycleBean implements InitializingBean, DisposableBean, 
                                      BeanNameAware, ApplicationContextAware {
    
    private String beanName;
    private ApplicationContext context;
    
    // 1. Constructor
    public LifecycleBean() {
        System.out.println("1. Constructor called");
    }
    
    // 3. BeanNameAware
    @Override
    public void setBeanName(String name) {
        this.beanName = name;
        System.out.println("3. BeanNameAware: setBeanName() - " + name);
    }
    
    // 5. ApplicationContextAware
    @Override
    public void setApplicationContext(ApplicationContext context) {
        this.context = context;
        System.out.println("5. ApplicationContextAware: setApplicationContext()");
    }
    
    // 7. @PostConstruct (recommended)
    @PostConstruct
    public void postConstruct() {
        System.out.println("7. @PostConstruct called");
    }
    
    // 8. InitializingBean (alternative)
    @Override
    public void afterPropertiesSet() {
        System.out.println("8. InitializingBean: afterPropertiesSet()");
    }
    
    // Custom init method (alternative)
    public void customInit() {
        System.out.println("9. Custom init method");
    }
    
    // 12. @PreDestroy (recommended)
    @PreDestroy
    public void preDestroy() {
        System.out.println("12. @PreDestroy called");
    }
    
    // 13. DisposableBean (alternative)
    @Override
    public void destroy() {
        System.out.println("13. DisposableBean: destroy()");
    }
    
    // Custom destroy method (alternative)
    public void customDestroy() {
        System.out.println("14. Custom destroy method");
    }
}

// Configuration
@Configuration
public class AppConfig {
    
    @Bean(initMethod = "customInit", destroyMethod = "customDestroy")
    public LifecycleBean lifecycleBean() {
        return new LifecycleBean();
    }
}
```

**BeanPostProcessor (Global Hook):**

```java
@Component
public class CustomBeanPostProcessor implements BeanPostProcessor {
    
    @Override
    public Object postProcessBeforeInitialization(Object bean, String beanName) {
        System.out.println("6. BeanPostProcessor: BEFORE init - " + beanName);
        return bean;  // Can return wrapped bean (proxy)
    }
    
    @Override
    public Object postProcessAfterInitialization(Object bean, String beanName) {
        System.out.println("10. BeanPostProcessor: AFTER init - " + beanName);
        return bean;  // Can return wrapped bean (AOP proxy)
    }
}
```

## 3.2 Bean Scopes

```java
// 1. SINGLETON (Default) - One instance per Spring container
@Service
@Scope("singleton")  // or @Scope(ConfigurableBeanFactory.SCOPE_SINGLETON)
public class SingletonService {
    // Single instance shared across entire application
}

// 2. PROTOTYPE - New instance every time bean requested
@Service
@Scope("prototype")  // or @Scope(ConfigurableBeanFactory.SCOPE_PROTOTYPE)
public class PrototypeService {
    // New instance for each @Autowired or getBean() call
}

// 3. REQUEST - New instance per HTTP request (Web only)
@Service
@Scope(value = WebApplicationContext.SCOPE_REQUEST, proxyMode = ScopedProxyMode.TARGET_CLASS)
public class RequestScopedService {
    // New instance for each HTTP request
}

// 4. SESSION - One instance per HTTP session (Web only)
@Service
@Scope(value = WebApplicationContext.SCOPE_SESSION, proxyMode = ScopedProxyMode.TARGET_CLASS)
public class SessionScopedService {
    // Same instance within HTTP session
}

// 5. APPLICATION - One instance per ServletContext (Web only)
@Service
@Scope(value = WebApplicationContext.SCOPE_APPLICATION, proxyMode = ScopedProxyMode.TARGET_CLASS)
public class ApplicationScopedService {
    // Single instance per web application
}

// 6. Custom Scope
public class CustomScope implements Scope {
    // Implement custom scope logic
}
```

**Scope Comparison:**

```java
@SpringBootApplication
public class ScopeDemo implements CommandLineRunner {
    
    @Autowired
    private ApplicationContext context;
    
    @Override
    public void run(String... args) {
        // SINGLETON - Same instance
        SingletonService s1 = context.getBean(SingletonService.class);
        SingletonService s2 = context.getBean(SingletonService.class);
        System.out.println("Singleton equal: " + (s1 == s2));  // true
        
        // PROTOTYPE - Different instances
        PrototypeService p1 = context.getBean(PrototypeService.class);
        PrototypeService p2 = context.getBean(PrototypeService.class);
        System.out.println("Prototype equal: " + (p1 == p2));  // false
    }
}
```

## 3.3 Lazy Initialization

```java
// Eager initialization (default) - Created at startup
@Service
public class EagerService {
    public EagerService() {
        System.out.println("EagerService created at startup");
    }
}

// Lazy initialization - Created when first used
@Service
@Lazy
public class LazyService {
    public LazyService() {
        System.out.println("LazyService created when first accessed");
    }
}

// Lazy injection
@Service
public class UserService {
    
    @Autowired
    @Lazy  // LazyService not created until first access
    private LazyService lazyService;
    
    public void doSomething() {
        lazyService.process();  // Created NOW
    }
}

// Global lazy initialization (application.properties)
// spring.main.lazy-initialization=true
```

**When to Use Lazy:**

✅ **Use Lazy:**
- Bean rarely used
- Expensive initialization (reduces startup time)
- Conditional usage

❌ **Avoid Lazy:**
- Critical services needed at startup
- Errors hidden until first use
- Slower first request

---

# 4. ASPECT-ORIENTED PROGRAMMING (AOP)

## 4.1 What is AOP?

**AOP** separates cross-cutting concerns (logging, security, transactions) from business logic.

**Key Concepts:**

- **Aspect**: Modularized concern (e.g., logging aspect)
- **Join Point**: Point in execution (method call, exception thrown)
- **Advice**: Action at join point (before, after, around)
- **Pointcut**: Expression matching join points
- **Weaving**: Applying aspects to target objects

## 4.2 AOP Example - Logging

```java
@Aspect
@Component
public class LoggingAspect {
    
    private static final Logger logger = LoggerFactory.getLogger(LoggingAspect.class);
    
    // Pointcut: All methods in service package
    @Pointcut("execution(* com.example.service..*(..))")
    public void serviceMethods() {}
    
    // BEFORE advice - Runs before method execution
    @Before("serviceMethods()")
    public void logBefore(JoinPoint joinPoint) {
        String methodName = joinPoint.getSignature().toShortString();
        Object[] args = joinPoint.getArgs();
        logger.info("BEFORE: {} with args: {}", methodName, Arrays.toString(args));
    }
    
    // AFTER advice - Runs after method execution (success or exception)
    @After("serviceMethods()")
    public void logAfter(JoinPoint joinPoint) {
        logger.info("AFTER: {}", joinPoint.getSignature().toShortString());
    }
    
    // AFTER RETURNING - Runs after successful method execution
    @AfterReturning(pointcut = "serviceMethods()", returning = "result")
    public void logAfterReturning(JoinPoint joinPoint, Object result) {
        logger.info("AFTER RETURNING: {} returned: {}", 
                   joinPoint.getSignature().toShortString(), result);
    }
    
    // AFTER THROWING - Runs if method throws exception
    @AfterThrowing(pointcut = "serviceMethods()", throwing = "ex")
    public void logAfterThrowing(JoinPoint joinPoint, Exception ex) {
        logger.error("AFTER THROWING: {} threw: {}", 
                    joinPoint.getSignature().toShortString(), ex.getMessage());
    }
    
    // AROUND advice - Most powerful, wraps method execution
    @Around("serviceMethods()")
    public Object logAround(ProceedingJoinPoint joinPoint) throws Throwable {
        String methodName = joinPoint.getSignature().toShortString();
        
        logger.info("AROUND BEFORE: {}", methodName);
        long startTime = System.currentTimeMillis();
        
        try {
            Object result = joinPoint.proceed();  // Execute actual method
            
            long duration = System.currentTimeMillis() - startTime;
            logger.info("AROUND AFTER: {} completed in {}ms, returned: {}", 
                       methodName, duration, result);
            
            return result;
        } catch (Exception ex) {
            logger.error("AROUND EXCEPTION: {} threw: {}", methodName, ex.getMessage());
            throw ex;
        }
    }
}
```

## 4.3 Pointcut Expressions

```java
@Aspect
@Component
public class PointcutExamples {
    
    // 1. Execution - Method execution
    @Before("execution(* com.example.service.UserService.findById(..))")
    public void specificMethod() {}
    
    // 2. All methods in a class
    @Before("execution(* com.example.service.UserService.*(..))")
    public void allMethodsInClass() {}
    
    // 3. All methods in package
    @Before("execution(* com.example.service..*(..))")
    public void allMethodsInPackage() {}
    
    // 4. Methods with specific return type
    @Before("execution(com.example.model.User com.example.service..*(..))")
    public void methodsReturningUser() {}
    
    // 5. Methods with specific parameters
    @Before("execution(* com.example.service..*(Long, String))")
    public void methodsWithParams() {}
    
    // 6. Within - All methods within type
    @Before("within(com.example.service.UserService)")
    public void withinClass() {}
    
    // 7. Within package
    @Before("within(com.example.service..*)")
    public void withinPackage() {}
    
    // 8. @annotation - Methods with specific annotation
    @Before("@annotation(com.example.annotation.Loggable)")
    public void methodsWithAnnotation() {}
    
    // 9. Bean - All methods in specific bean
    @Before("bean(userService)")
    public void methodsInBean() {}
    
    // 10. Combining expressions (AND, OR, NOT)
    @Before("execution(* com.example.service..*(..)) && @annotation(org.springframework.transaction.annotation.Transactional)")
    public void transactionalServiceMethods() {}
    
    @Before("execution(* com.example.service..*(..)) || execution(* com.example.repository..*(..))")
    public void serviceOrRepositoryMethods() {}
    
    @Before("execution(* com.example..*(..)) && !within(com.example.internal..*)")
    public void publicApiMethods() {}
}
```

## 4.4 Real-World AOP Use Cases

### Performance Monitoring

```java
@Aspect
@Component
public class PerformanceMonitoringAspect {
    
    private static final Logger logger = LoggerFactory.getLogger(PerformanceMonitoringAspect.class);
    
    @Around("@annotation(com.example.annotation.Monitored)")
    public Object monitorPerformance(ProceedingJoinPoint joinPoint) throws Throwable {
        String methodName = joinPoint.getSignature().toShortString();
        
        long startTime = System.nanoTime();
        try {
            return joinPoint.proceed();
        } finally {
            long duration = System.nanoTime() - startTime;
            double ms = duration / 1_000_000.0;
            
            if (ms > 1000) {
                logger.warn("SLOW METHOD: {} took {}ms", methodName, String.format("%.2f", ms));
            } else {
                logger.debug("Method {} took {}ms", methodName, String.format("%.2f", ms));
            }
        }
    }
}

// Usage
@Service
public class OrderService {
    
    @Monitored
    public Order processOrder(Long orderId) {
        // Business logic
        return order;
    }
}
```

### Security Check

```java
@Aspect
@Component
public class SecurityAspect {
    
    @Autowired
    private SecurityService securityService;
    
    @Before("@annotation(requiresRole)")
    public void checkRole(JoinPoint joinPoint, RequiresRole requiresRole) {
        String[] roles = requiresRole.value();
        
        if (!securityService.hasAnyRole(roles)) {
            throw new AccessDeniedException("User does not have required role: " + 
                                           String.join(", ", roles));
        }
    }
}

@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
public @interface RequiresRole {
    String[] value();
}

// Usage
@Service
public class AdminService {
    
    @RequiresRole({"ADMIN", "SUPER_ADMIN"})
    public void deleteUser(Long userId) {
        // Only ADMIN or SUPER_ADMIN can execute
    }
}
```

### Retry Logic

```java
@Aspect
@Component
public class RetryAspect {
    
    private static final Logger logger = LoggerFactory.getLogger(RetryAspect.class);
    
    @Around("@annotation(retryable)")
    public Object retry(ProceedingJoinPoint joinPoint, Retryable retryable) throws Throwable {
        int maxAttempts = retryable.maxAttempts();
        long delay = retryable.delay();
        
        int attempts = 0;
        while (attempts < maxAttempts) {
            try {
                return joinPoint.proceed();
            } catch (Exception ex) {
                attempts++;
                
                if (attempts >= maxAttempts) {
                    logger.error("Max retry attempts ({}) reached for {}", 
                               maxAttempts, joinPoint.getSignature().toShortString());
                    throw ex;
                }
                
                logger.warn("Attempt {}/{} failed for {}, retrying in {}ms...", 
                           attempts, maxAttempts, joinPoint.getSignature().toShortString(), delay);
                Thread.sleep(delay);
            }
        }
        
        throw new RuntimeException("Should not reach here");
    }
}

@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
public @interface Retryable {
    int maxAttempts() default 3;
    long delay() default 1000;  // milliseconds
}

// Usage
@Service
public class ExternalApiService {
    
    @Retryable(maxAttempts = 3, delay = 2000)
    public String callExternalApi() {
        // May fail, will retry 3 times with 2 second delay
        return restTemplate.getForObject("https://api.example.com/data", String.class);
    }
}
```

### Caching

```java
@Aspect
@Component
public class CachingAspect {
    
    private final Map<String, Object> cache = new ConcurrentHashMap<>();
    
    @Around("@annotation(cacheable)")
    public Object cache(ProceedingJoinPoint joinPoint, Cacheable cacheable) throws Throwable {
        String key = generateKey(joinPoint);
        
        // Check cache
        if (cache.containsKey(key)) {
            return cache.get(key);
        }
        
        // Execute method
        Object result = joinPoint.proceed();
        
        // Store in cache
        cache.put(key, result);
        
        return result;
    }
    
    private String generateKey(ProceedingJoinPoint joinPoint) {
        String methodName = joinPoint.getSignature().toShortString();
        String args = Arrays.toString(joinPoint.getArgs());
        return methodName + args;
    }
}
```

---

# 5. SPRING BOOT FUNDAMENTALS

## 5.1 What is Spring Boot?

**Spring Boot** = Spring Framework + Convention Over Configuration + Embedded Server + Production Features

**Key Features:**

1. **Auto-Configuration**: Automatically configures Spring based on classpath
2. **Starters**: Pre-packaged dependency bundles
3. **Embedded Server**: Tomcat, Jetty, or Undertow embedded
4. **Production-Ready**: Actuator, Metrics, Health Checks
5. **Standalone**: Run as JAR with `java -jar app.jar`

## 5.2 @SpringBootApplication

```java
@SpringBootApplication
public class Application {
    
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}
```

**@SpringBootApplication is a meta-annotation combining:**

```java
@SpringBootApplication
= @SpringBootConfiguration  // = @Configuration (indicates configuration class)
+ @EnableAutoConfiguration  // Enable auto-configuration
+ @ComponentScan            // Scan for @Component, @Service, @Repository, @Controller
```

**Equivalent to:**

```java
@Configuration
@EnableAutoConfiguration
@ComponentScan(basePackages = "com.example")
public class Application {
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}
```

## 5.3 Spring Boot Starters

**Starters** are pre-configured dependency bundles.

```xml
<!-- pom.xml -->

<!-- Web applications (REST APIs) -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
</dependency>
<!-- Includes: spring-webmvc, tomcat-embed-core, jackson, validation -->

<!-- Data JPA -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-jpa</artifactId>
</dependency>
<!-- Includes: spring-data-jpa, hibernate-core, spring-jdbc -->

<!-- Security -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-security</artifactId>
</dependency>

<!-- Testing -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-test</artifactId>
    <scope>test</scope>
</dependency>
<!-- Includes: JUnit 5, Mockito, AssertJ, Spring Test -->

<!-- Validation -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-validation</artifactId>
</dependency>

<!-- Actuator (Production monitoring) -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>

<!-- Redis -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-redis</artifactId>
</dependency>

<!-- MongoDB -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-mongodb</artifactId>
</dependency>
```

## 5.4 Application Configuration

**application.properties:**

```properties
# Server
server.port=8080
server.servlet.context-path=/api

# Database
spring.datasource.url=jdbc:mysql://localhost:3306/mydb
spring.datasource.username=root
spring.datasource.password=secret
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver

# JPA/Hibernate
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.MySQL8Dialect

# Logging
logging.level.root=INFO
logging.level.com.example=DEBUG
logging.file.name=app.log
logging.pattern.console=%d{yyyy-MM-dd HH:mm:ss} - %msg%n

# Jackson
spring.jackson.serialization.indent-output=true
spring.jackson.default-property-inclusion=non_null

# Actuator
management.endpoints.web.exposure.include=health,info,metrics
management.endpoint.health.show-details=always
```

**application.yml (YAML format):**

```yaml
server:
  port: 8080
  servlet:
    context-path: /api

spring:
  datasource:
    url: jdbc:mysql://localhost:3306/mydb
    username: root
    password: secret
    driver-class-name: com.mysql.cj.jdbc.Driver
  
  jpa:
    hibernate:
      ddl-auto: update
    show-sql: true
    properties:
      hibernate:
        dialect: org.hibernate.dialect.MySQL8Dialect

logging:
  level:
    root: INFO
    com.example: DEBUG
  file:
    name: app.log
```

**Profile-Specific Configuration:**

```properties
# application-dev.properties
spring.datasource.url=jdbc:h2:mem:testdb
logging.level.com.example=DEBUG

# application-prod.properties
spring.datasource.url=jdbc:mysql://prod-server:3306/proddb
logging.level.com.example=WARN
```

**Activate Profile:**

```bash
# Command line
java -jar app.jar --spring.profiles.active=prod

# Or in application.properties
spring.profiles.active=dev
```

**@Value - Injecting Properties:**

```java
@Service
public class EmailService {
    
    @Value("${app.email.from}")
    private String fromEmail;
    
    @Value("${app.email.max-retries:3}")  // Default = 3
    private int maxRetries;
    
    @Value("${app.features.email-enabled:true}")
    private boolean emailEnabled;
    
    public void sendEmail(String to, String subject, String body) {
        if (!emailEnabled) {
            return;
        }
        // Send from fromEmail
    }
}
```

**@ConfigurationProperties - Type-Safe Configuration:**

```java
@ConfigurationProperties(prefix = "app.email")
@Component
public class EmailProperties {
    
    private String from;
    private String host;
    private int port;
    private int maxRetries = 3;
    private boolean enabled = true;
    
    // Getters and Setters
}

// application.properties
app.email.from=noreply@example.com
app.email.host=smtp.gmail.com
app.email.port=587
app.email.max-retries=5
app.email.enabled=true

// Usage
@Service
public class EmailService {
    
    private final EmailProperties emailProperties;
    
    public EmailService(EmailProperties emailProperties) {
        this.emailProperties = emailProperties;
    }
    
    public void sendEmail(String to, String subject, String body) {
        if (!emailProperties.isEnabled()) {
            return;
        }
        // Use emailProperties.getFrom(), getHost(), etc.
    }
}
```

---

# 6. SPRING BOOT AUTO-CONFIGURATION

## 6.1 How Auto-Configuration Works

Spring Boot auto-configuration automatically configures beans based on:
1. **Classpath contents** (dependencies)
2. **Existing bean definitions**
3. **Property settings**

**Example: DataSource Auto-Configuration**

When you add spring-boot-starter-data-jpa:
1. Spring Boot detects JPA classes in classpath
2. Reads `spring.datasource.*` properties
3. Automatically creates:
   - DataSource bean
   - EntityManagerFactory bean
   - TransactionManager bean
   - JdbcTemplate bean

**No manual configuration needed!**

```java
// You don't need to write this anymore:
@Configuration
public class DataSourceConfig {
    
    @Bean
    public DataSource dataSource() {
        DriverManagerDataSource dataSource = new DriverManagerDataSource();
        dataSource.setDriverClassName("com.mysql.cj.jdbc.Driver");
        dataSource.setUrl("jdbc:mysql://localhost:3306/mydb");
        dataSource.setUsername("root");
        dataSource.setPassword("secret");
        return dataSource;
    }
}

// Spring Boot does it automatically!
// Just add properties:
spring.datasource.url=jdbc:mysql://localhost:3306/mydb
spring.datasource.username=root
spring.datasource.password=secret
```

## 6.2 Viewing Auto-Configuration Report

```bash
# Run with debug flag
java -jar app.jar --debug

# Or in application.properties
debug=true
```

**Output:**

```
============================
CONDITIONS EVALUATION REPORT
============================

Positive matches:  (Auto-configured beans)
-----------------

   DataSourceAutoConfiguration matched:
      - @ConditionalOnClass found required classes 'javax.sql.DataSource', 'org.springframework.jdbc.datasource.embedded.EmbeddedDatabaseType' (OnClassCondition)

   HibernateJpaAutoConfiguration matched:
      - @ConditionalOnClass found required class 'org.hibernate.SessionFactory' (OnClassCondition)

Negative matches: (Not auto-configured)
-----------------

   RedisAutoConfiguration:
      Did not match:
         - @ConditionalOnClass did not find required class 'org.springframework.data.redis.core.RedisTemplate' (OnClassCondition)
```

## 6.3 Customizing Auto-Configuration

**Override Auto-Configured Bean:**

```java
@Configuration
public class CustomDataSourceConfig {
    
    // Override auto-configured DataSource
    @Bean
    public DataSource dataSource() {
        HikariConfig config = new HikariConfig();
        config.setJdbcUrl("jdbc:mysql://localhost:3306/mydb");
        config.setUsername("root");
        config.setPassword("secret");
        config.setMaximumPoolSize(20);
        config.setMinimumIdle(5);
        config.setConnectionTimeout(30000);
        return new HikariDataSource(config);
    }
}
```

**Exclude Auto-Configuration:**

```java
@SpringBootApplication(exclude = {
    DataSourceAutoConfiguration.class,
    HibernateJpaAutoConfiguration.class
})
public class Application {
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}

// Or in application.properties
spring.autoconfigure.exclude=org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration
```

## 6.4 Creating Custom Auto-Configuration

```java
// 1. Auto-configuration class
@Configuration
@ConditionalOnClass(MyService.class)
@EnableConfigurationProperties(MyServiceProperties.class)
public class MyServiceAutoConfiguration {
    
    @Bean
    @ConditionalOnMissingBean
    public MyService myService(MyServiceProperties properties) {
        return new MyService(properties.getApiKey());
    }
}

// 2. Configuration properties
@ConfigurationProperties(prefix = "myservice")
public class MyServiceProperties {
    private String apiKey;
    private int timeout = 5000;
    
    // Getters and Setters
}

// 3. Register auto-configuration
// Create: META-INF/spring.factories
org.springframework.boot.autoconfigure.EnableAutoConfiguration=\
com.example.autoconfigure.MyServiceAutoConfiguration

// 4. Usage in other projects
// Add dependency to your-auto-config.jar
// Configure in application.properties
myservice.api-key=abc123
myservice.timeout=10000

// Automatically available!
@Autowired
private MyService myService;
```

---

# 7. REST APIs WITH SPRING MVC

## 7.1 Basic REST Controller

```java
@RestController  // = @Controller + @ResponseBody
@RequestMapping("/api/users")
public class UserController {
    
    private final UserService userService;
    
    public UserController(UserService userService) {
        this.userService = userService;
    }
    
    // GET /api/users - Get all users
    @GetMapping
    public List<User> getAllUsers() {
        return userService.findAll();
    }
    
    // GET /api/users/123 - Get user by ID
    @GetMapping("/{id}")
    public User getUserById(@PathVariable Long id) {
        return userService.findById(id);
    }
    
    // GET /api/users?name=John&age=25 - Query parameters
    @GetMapping("/search")
    public List<User> searchUsers(
            @RequestParam(required = false) String name,
            @RequestParam(required = false) Integer age) {
        return userService.search(name, age);
    }
    
    // POST /api/users - Create user
    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public User createUser(@RequestBody User user) {
        return userService.create(user);
    }
    
    // PUT /api/users/123 - Update user
    @PutMapping("/{id}")
    public User updateUser(@PathVariable Long id, @RequestBody User user) {
        return userService.update(id, user);
    }
    
    // PATCH /api/users/123 - Partial update
    @PatchMapping("/{id}")
    public User partialUpdate(@PathVariable Long id, @RequestBody Map<String, Object> updates) {
        return userService.partialUpdate(id, updates);
    }
    
    // DELETE /api/users/123 - Delete user
    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteUser(@PathVariable Long id) {
        userService.delete(id);
    }
}
```

## 7.2 Request & Response Handling

**Path Variables:**

```java
// /api/users/123/orders/456
@GetMapping("/users/{userId}/orders/{orderId}")
public Order getOrder(@PathVariable Long userId, @PathVariable Long orderId) {
    return orderService.findOrder(userId, orderId);
}

// Optional path variable
@GetMapping({"/users", "/users/{id}"})
public ResponseEntity<?> getUsers(@PathVariable(required = false) Long id) {
    if (id != null) {
        return ResponseEntity.ok(userService.findById(id));
    }
    return ResponseEntity.ok(userService.findAll());
}
```

**Request Parameters:**

```java
// /api/users?page=0&size=10&sort=name
@GetMapping("/users")
public Page<User> getUsers(
        @RequestParam(defaultValue = "0") int page,
        @RequestParam(defaultValue = "10") int size,
        @RequestParam(defaultValue = "name") String sort) {
    Pageable pageable = PageRequest.of(page, size, Sort.by(sort));
    return userService.findAll(pageable);
}

// Multiple values: /api/users?ids=1,2,3 or /api/users?ids=1&ids=2&ids=3
@GetMapping("/users")
public List<User> getUsersByIds(@RequestParam List<Long> ids) {
    return userService.findAllById(ids);
}
```

**Request Headers:**

```java
@GetMapping("/users")
public List<User> getUsers(
        @RequestHeader("X-Api-Key") String apiKey,
        @RequestHeader(value = "User-Agent", required = false) String userAgent) {
    // Validate apiKey
    return userService.findAll();
}
```

**Response Entity:**

```java
@GetMapping("/{id}")
public ResponseEntity<User> getUserById(@PathVariable Long id) {
    return userService.findById(id)
        .map(user -> ResponseEntity.ok()
            .header("X-User-Id", user.getId().toString())
            .body(user))
        .orElse(ResponseEntity.notFound().build());
}

// Custom status codes
@PostMapping
public ResponseEntity<User> createUser(@RequestBody User user) {
    User created = userService.create(user);
    URI location = ServletUriComponentsBuilder
        .fromCurrentRequest()
        .path("/{id}")
        .buildAndExpand(created.getId())
        .toUri();
    
    return ResponseEntity
        .created(location)
        .body(created);
}
```

## 7.3 Content Negotiation

```java
@RestController
@RequestMapping("/api/users")
public class UserController {
    
    // Produces JSON (default)
    @GetMapping(produces = MediaType.APPLICATION_JSON_VALUE)
    public List<User> getUsersJson() {
        return userService.findAll();
    }
    
    // Produces XML
    @GetMapping(produces = MediaType.APPLICATION_XML_VALUE)
    public List<User> getUsersXml() {
        return userService.findAll();
    }
    
    // Accept multiple formats
    @GetMapping(produces = {MediaType.APPLICATION_JSON_VALUE, MediaType.APPLICATION_XML_VALUE})
    public List<User> getUsers() {
        return userService.findAll();
        // Returns JSON or XML based on Accept header
    }
    
    // Consumes JSON
    @PostMapping(consumes = MediaType.APPLICATION_JSON_VALUE)
    public User createUser(@RequestBody User user) {
        return userService.create(user);
    }
}
```

## 7.4 File Upload & Download

```java
@RestController
@RequestMapping("/api/files")
public class FileController {
    
    // Upload single file
    @PostMapping("/upload")
    public ResponseEntity<String> uploadFile(@RequestParam("file") MultipartFile file) {
        if (file.isEmpty()) {
            return ResponseEntity.badRequest().body("File is empty");
        }
        
        try {
            String filename = file.getOriginalFilename();
            Path path = Paths.get("uploads/" + filename);
            Files.write(path, file.getBytes());
            
            return ResponseEntity.ok("File uploaded: " + filename);
        } catch (IOException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body("Upload failed: " + e.getMessage());
        }
    }
    
    // Upload multiple files
    @PostMapping("/upload-multiple")
    public ResponseEntity<List<String>> uploadFiles(@RequestParam("files") MultipartFile[] files) {
        List<String> filenames = new ArrayList<>();
        
        for (MultipartFile file : files) {
            if (!file.isEmpty()) {
                try {
                    String filename = file.getOriginalFilename();
                    Path path = Paths.get("uploads/" + filename);
                    Files.write(path, file.getBytes());
                    filenames.add(filename);
                } catch (IOException e) {
                    // Log error
                }
            }
        }
        
        return ResponseEntity.ok(filenames);
    }
    
    // Download file
    @GetMapping("/download/{filename}")
    public ResponseEntity<Resource> downloadFile(@PathVariable String filename) {
        try {
            Path path = Paths.get("uploads/" + filename);
            Resource resource = new UrlResource(path.toUri());
            
            if (resource.exists() && resource.isReadable()) {
                return ResponseEntity.ok()
                    .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + filename + "\"")
                    .body(resource);
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
}

// Configure max file size in application.properties
spring.servlet.multipart.max-file-size=10MB
spring.servlet.multipart.max-request-size=10MB
```

---

# 8. EXCEPTION HANDLING & VALIDATION

## 8.1 Global Exception Handler

```java
@RestControllerAdvice
public class GlobalExceptionHandler {
    
    private static final Logger logger = LoggerFactory.getLogger(GlobalExceptionHandler.class);
    
    // Handle specific exception
    @ExceptionHandler(UserNotFoundException.class)
    @ResponseStatus(HttpStatus.NOT_FOUND)
    public ErrorResponse handleUserNotFound(UserNotFoundException ex) {
        logger.error("User not found: {}", ex.getMessage());
        return new ErrorResponse(
            HttpStatus.NOT_FOUND.value(),
            ex.getMessage(),
            LocalDateTime.now()
        );
    }
    
    // Handle validation errors
    @ExceptionHandler(MethodArgumentNotValidException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public ValidationErrorResponse handleValidationErrors(MethodArgumentNotValidException ex) {
        Map<String, String> errors = new HashMap<>();
        
        ex.getBindingResult().getFieldErrors().forEach(error -> 
            errors.put(error.getField(), error.getDefaultMessage())
        );
        
        return new ValidationErrorResponse(
            HttpStatus.BAD_REQUEST.value(),
            "Validation failed",
            errors,
            LocalDateTime.now()
        );
    }
    
    // Handle constraint violations
    @ExceptionHandler(ConstraintViolationException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public ErrorResponse handleConstraintViolation(ConstraintViolationException ex) {
        String message = ex.getConstraintViolations().stream()
            .map(ConstraintViolation::getMessage)
            .collect(Collectors.joining(", "));
        
        return new ErrorResponse(
            HttpStatus.BAD_REQUEST.value(),
            message,
            LocalDateTime.now()
        );
    }
    
    // Handle data integrity violations (e.g., duplicate email)
    @ExceptionHandler(DataIntegrityViolationException.class)
    @ResponseStatus(HttpStatus.CONFLICT)
    public ErrorResponse handleDataIntegrityViolation(DataIntegrityViolationException ex) {
        return new ErrorResponse(
            HttpStatus.CONFLICT.value(),
            "Data integrity violation: " + ex.getMostSpecificCause().getMessage(),
            LocalDateTime.now()
        );
    }
    
    // Handle all other exceptions
    @ExceptionHandler(Exception.class)
    @ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
    public ErrorResponse handleAllExceptions(Exception ex) {
        logger.error("Unexpected error", ex);
        return new ErrorResponse(
            HttpStatus.INTERNAL_SERVER_ERROR.value(),
            "An unexpected error occurred",
            LocalDateTime.now()
        );
    }
}

// Error response DTOs
@Data
@AllArgsConstructor
public class ErrorResponse {
    private int status;
    private String message;
    private LocalDateTime timestamp;
}

@Data
@AllArgsConstructor
public class ValidationErrorResponse {
    private int status;
    private String message;
    private Map<String, String> errors;
    private LocalDateTime timestamp;
}

// Custom exception
public class UserNotFoundException extends RuntimeException {
    public UserNotFoundException(Long id) {
        super("User not found with id: " + id);
    }
}
```

## 8.2 Bean Validation

```java
// Entity with validation annotations
@Entity
public class User {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @NotNull(message = "Name is required")
    @Size(min = 2, max = 50, message = "Name must be between 2 and 50 characters")
    private String name;
    
    @NotNull(message = "Email is required")
    @Email(message = "Email must be valid")
    private String email;
    
    @Min(value = 18, message = "Age must be at least 18")
    @Max(value = 120, message = "Age must be at most 120")
    private Integer age;
    
    @Pattern(regexp = "^\\+?[1-9]\\d{1,14}$", message = "Phone number must be valid E.164 format")
    private String phone;
    
    @NotEmpty(message = "Roles cannot be empty")
    private List<String> roles;
    
    @Past(message = "Birth date must be in the past")
    private LocalDate birthDate;
    
    @Future(message = "Expiry date must be in the future")
    private LocalDate expiryDate;
    
    // Getters and Setters
}

// Controller with @Valid
@RestController
@RequestMapping("/api/users")
@Validated  // Enable validation for path variables and request params
public class UserController {
    
    // Validate request body
    @PostMapping
    public User createUser(@Valid @RequestBody User user) {
        return userService.create(user);
    }
    
    // Validate path variable
    @GetMapping("/{id}")
    public User getUserById(@PathVariable @Min(1) Long id) {
        return userService.findById(id);
    }
    
    // Validate request parameter
    @GetMapping("/search")
    public List<User> searchUsers(
            @RequestParam @Size(min = 2, max = 50) String name) {
        return userService.findByName(name);
    }
}
```

**Custom Validator:**

```java
// Custom annotation
@Target({ElementType.FIELD, ElementType.PARAMETER})
@Retention(RetentionPolicy.RUNTIME)
@Constraint(validatedBy = UniqueEmailValidator.class)
public @interface UniqueEmail {
    String message() default "Email already exists";
    Class<?>[] groups() default {};
    Class<? extends Payload>[] payload() default {};
}

// Validator implementation
@Component
public class UniqueEmailValidator implements ConstraintValidator<UniqueEmail, String> {
    
    @Autowired
    private UserRepository userRepository;
    
    @Override
    public boolean isValid(String email, ConstraintValidatorContext context) {
        if (email == null) {
            return true;  // @NotNull handles null check
        }
        return !userRepository.existsByEmail(email);
    }
}

// Usage
@Entity
public class User {
    
    @Email
    @UniqueEmail  // Custom validator
    private String email;
}
```

---

# 9. SPRING DATA JPA

## 9.1 Repository Interface

```java
// Basic CRUD operations (no implementation needed!)
@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    // Inherited methods from JpaRepository:
    // save(User), findById(Long), findAll(), deleteById(Long), count(), etc.
}

// Usage
@Service
public class UserService {
    
    private final UserRepository userRepository;
    
    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }
    
    public User createUser(User user) {
        return userRepository.save(user);  // INSERT
    }
    
    public User updateUser(Long id, User user) {
        user.setId(id);
        return userRepository.save(user);  // UPDATE (if id exists)
    }
    
    public User findById(Long id) {
        return userRepository.findById(id)
            .orElseThrow(() -> new UserNotFoundException(id));
    }
    
    public List<User> findAll() {
        return userRepository.findAll();
    }
    
    public void deleteById(Long id) {
        userRepository.deleteById(id);
    }
    
    public long count() {
        return userRepository.count();
    }
    
    public boolean exists(Long id) {
        return userRepository.existsById(id);
    }
}
```

## 9.2 Query Methods (Method Name Convention)

```java
@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    
    // SELECT * FROM user WHERE email = ?
    Optional<User> findByEmail(String email);
    
    // SELECT * FROM user WHERE name = ? AND age = ?
    List<User> findByNameAndAge(String name, Integer age);
    
    // SELECT * FROM user WHERE age > ?
    List<User> findByAgeGreaterThan(Integer age);
    
    // SELECT * FROM user WHERE age >= ? AND age <= ?
    List<User> findByAgeBetween(Integer minAge, Integer maxAge);
    
    // SELECT * FROM user WHERE name LIKE ?
    List<User> findByNameContaining(String keyword);
    
    // SELECT * FROM user WHERE name LIKE ? (starts with)
    List<User> findByNameStartingWith(String prefix);
    
    // SELECT * FROM user WHERE name IN (?, ?, ?)
    List<User> findByNameIn(List<String> names);
    
    // SELECT * FROM user WHERE created_date > ?
    List<User> findByCreatedDateAfter(LocalDateTime date);
    
    // SELECT * FROM user ORDER BY name ASC
    List<User> findAllByOrderByNameAsc();
    
    // SELECT * FROM user WHERE active = true ORDER BY created_date DESC
    List<User> findByActiveTrueOrderByCreatedDateDesc();
    
    // COUNT
    long countByActive(boolean active);
    
    // EXISTS
    boolean existsByEmail(String email);
    
    // DELETE
    void deleteByEmail(String email);
    
    // FIRST/TOP
    User findFirstByOrderByCreatedDateDesc();
    List<User> findTop10ByOrderByAgeDesc();
    
    // DISTINCT
    List<User> findDistinctByName(String name);
    
    // IGNORE CASE
    Optional<User> findByEmailIgnoreCase(String email);
}
```

## 9.3 Custom Queries with @Query

```java
@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    
    // JPQL (Java Persistence Query Language)
    @Query("SELECT u FROM User u WHERE u.email = :email")
    Optional<User> findByEmailJPQL(@Param("email") String email);
    
    // JPQL with multiple parameters
    @Query("SELECT u FROM User u WHERE u.age >= :minAge AND u.age <= :maxAge")
    List<User> findByAgeRange(@Param("minAge") Integer minAge, @Param("maxAge") Integer maxAge);
    
    // JPQL with JOIN
    @Query("SELECT u FROM User u JOIN u.orders o WHERE o.total > :amount")
    List<User> findUsersWithOrdersAbove(@Param("amount") BigDecimal amount);
    
    // Native SQL query
    @Query(value = "SELECT * FROM users WHERE email = ?1", nativeQuery = true)
    Optional<User> findByEmailNative(String email);
    
    // Native SQL with named parameters
    @Query(value = "SELECT * FROM users WHERE age BETWEEN :minAge AND :maxAge", nativeQuery = true)
    List<User> findByAgeRangeNative(@Param("minAge") Integer minAge, @Param("maxAge") Integer maxAge);
    
    // UPDATE query
    @Modifying
    @Transactional
    @Query("UPDATE User u SET u.active = :active WHERE u.id = :id")
    int updateActive(@Param("id") Long id, @Param("active") boolean active);
    
    // DELETE query
    @Modifying
    @Transactional
    @Query("DELETE FROM User u WHERE u.active = false")
    int deleteInactiveUsers();
    
    // Projection (select specific fields)
    @Query("SELECT u.name, u.email FROM User u WHERE u.id = :id")
    Object[] findNameAndEmailById(@Param("id") Long id);
    
    // DTO projection
    @Query("SELECT new com.example.dto.UserDTO(u.name, u.email) FROM User u WHERE u.id = :id")
    UserDTO findUserDTOById(@Param("id") Long id);
    
    // Aggregation
    @Query("SELECT COUNT(u) FROM User u WHERE u.active = true")
    long countActiveUsers();
    
    @Query("SELECT AVG(u.age) FROM User u")
    Double averageAge();
}
```

## 9.4 Pagination and Sorting

```java
@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    
    // Method name with Pageable
    Page<User> findByActive(boolean active, Pageable pageable);
    
    // @Query with Pageable
    @Query("SELECT u FROM User u WHERE u.age >= :minAge")
    Page<User> findByMinAge(@Param("minAge") Integer minAge, Pageable pageable);
}

@RestController
@RequestMapping("/api/users")
public class UserController {
    
    @Autowired
    private UserRepository userRepository;
    
    // GET /api/users?page=0&size=10&sort=name,asc
    @GetMapping
    public Page<User> getUsers(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "name") String sortBy,
            @RequestParam(defaultValue = "asc") String sortDir) {
        
        Sort sort = sortDir.equalsIgnoreCase("asc") 
            ? Sort.by(sortBy).ascending()
            : Sort.by(sortBy).descending();
        
        Pageable pageable = PageRequest.of(page, size, sort);
        return userRepository.findAll(pageable);
    }
    
    // Multiple sort fields
    @GetMapping("/sorted")
    public Page<User> getUsersSorted(@RequestParam(defaultValue = "0") int page,
                                     @RequestParam(defaultValue = "10") int size) {
        Sort sort = Sort.by("age").descending().and(Sort.by("name").ascending());
        Pageable pageable = PageRequest.of(page, size, sort);
        return userRepository.findAll(pageable);
    }
}
```

## 9.5 Entity Relationships

**One-to-Many:**

```java
@Entity
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    private String name;
    
    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Order> orders = new ArrayList<>();
    
    public void addOrder(Order order) {
        orders.add(order);
        order.setUser(this);
    }
    
    public void removeOrder(Order order) {
        orders.remove(order);
        order.setUser(null);
    }
}

@Entity
public class Order {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    private BigDecimal total;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user;
}
```

**Many-to-Many:**

```java
@Entity
public class Student {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    private String name;
    
    @ManyToMany
    @JoinTable(
        name = "student_course",
        joinColumns = @JoinColumn(name = "student_id"),
        inverseJoinColumns = @JoinColumn(name = "course_id")
    )
    private Set<Course> courses = new HashSet<>();
    
    public void enrollCourse(Course course) {
        courses.add(course);
        course.getStudents().add(this);
    }
    
    public void unenrollCourse(Course course) {
        courses.remove(course);
        course.getStudents().remove(this);
    }
}

@Entity
public class Course {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    private String name;
    
    @ManyToMany(mappedBy = "courses")
    private Set<Student> students = new HashSet<>();
}
```

---

# 10. TRANSACTIONS IN SPRING

## 10.1 @Transactional Basics

```java
@Service
public class OrderService {
    
    @Autowired
    private OrderRepository orderRepository;
    
    @Autowired
    private InventoryService inventoryService;
    
    @Autowired
    private PaymentService paymentService;
    
    @Transactional  // All or nothing
    public Order createOrder(OrderRequest request) {
        // 1. Create order
        Order order = new Order();
        order.setUserId(request.getUserId());
        order.setTotal(request.getTotal());
        orderRepository.save(order);
        
        // 2. Deduct inventory
        inventoryService.deductStock(request.getProductId(), request.getQuantity());
        
        // 3. Process payment
        paymentService.charge(request.getUserId(), request.getTotal());
        
        // If any step fails, entire transaction rolls back
        return order;
    }
}
```

## 10.2 Transaction Propagation

```java
@Service
public class OrderService {
    
    // REQUIRED (default) - Join existing transaction or create new
    @Transactional(propagation = Propagation.REQUIRED)
    public void createOrder() {
        // If caller has transaction, join it
        // Otherwise, create new transaction
    }
    
    // REQUIRES_NEW - Always create new transaction (suspend existing)
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void logAudit() {
        // Always runs in separate transaction
        // Commits even if caller transaction rolls back
    }
    
    // MANDATORY - Must be called within existing transaction
    @Transactional(propagation = Propagation.MANDATORY)
    public void updateInventory() {
        // Throws exception if no active transaction
    }
    
    // NESTED - Execute within nested transaction (savepoint)
    @Transactional(propagation = Propagation.NESTED)
    public void updateStock() {
        // Can roll back without affecting outer transaction
    }
    
    // NEVER - Must NOT be called within transaction
    @Transactional(propagation = Propagation.NEVER)
    public void sendEmail() {
        // Throws exception if called within transaction
    }
    
    // NOT_SUPPORTED - Execute outside transaction (suspend existing)
    @Transactional(propagation = Propagation.NOT_SUPPORTED)
    public void generateReport() {
        // Suspends current transaction, executes without transaction
    }
}
```

**Real-World Example:**

```java
@Service
public class OrderService {
    
    @Autowired
    private AuditService auditService;
    
    @Transactional
    public Order createOrder(OrderRequest request) {
        try {
            // Main business logic
            Order order = new Order();
            orderRepository.save(order);
            
            // Log audit (separate transaction)
            auditService.logOrderCreated(order.getId());
            
            return order;
        } catch (Exception ex) {
            // Main transaction rolls back
            // But audit log persists (REQUIRES_NEW)
            throw ex;
        }
    }
}

@Service
public class AuditService {
    
    @Autowired
    private AuditRepository auditRepository;
    
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void logOrderCreated(Long orderId) {
        Audit audit = new Audit();
        audit.setAction("ORDER_CREATED");
        audit.setEntityId(orderId);
        auditRepository.save(audit);
        // Commits immediately, separate from caller's transaction
    }
}
```

## 10.3 Transaction Isolation

```java
@Service
public class AccountService {
    
    // READ_UNCOMMITTED - Dirty reads possible
    @Transactional(isolation = Isolation.READ_UNCOMMITTED)
    public void readUncommitted() {
        // Can read uncommitted changes from other transactions
        // Fastest, least safe
    }
    
    // READ_COMMITTED - Prevents dirty reads
    @Transactional(isolation = Isolation.READ_COMMITTED)
    public void readCommitted() {
        // Only reads committed data
        // Non-repeatable reads possible
    }
    
    // REPEATABLE_READ - Prevents dirty and non-repeatable reads
    @Transactional(isolation = Isolation.REPEATABLE_READ)
    public void repeatableRead() {
        // Same query returns same result within transaction
        // Phantom reads possible
    }
    
    // SERIALIZABLE - Prevents all concurrency issues
    @Transactional(isolation = Isolation.SERIALIZABLE)
    public void serializable() {
        // Strongest isolation, slowest performance
        // No dirty, non-repeatable, or phantom reads
    }
}
```

## 10.4 Rollback Rules

```java
@Service
public class PaymentService {
    
    // Rollback on all exceptions (default: only RuntimeException)
    @Transactional(rollbackFor = Exception.class)
    public void processPayment() throws Exception {
        // Rolls back on checked exceptions too
    }
    
    // Don't rollback on specific exception
    @Transactional(noRollbackFor = NotFoundException.class)
    public void updateOrder() {
        // Doesn't rollback if NotFoundException thrown
    }
    
    // Programmatic rollback
    @Transactional
    public void createOrder() {
        try {
            // Business logic
        } catch (Exception ex) {
            // Force rollback
            TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
            throw ex;
        }
    }
}
```

# 11. SPRING SECURITY BASICS

## 11.1 Basic Security Configuration

```java
@Configuration
@EnableWebSecurity
public class SecurityConfig {
    
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/public/**").permitAll()
                .requestMatchers("/api/admin/**").hasRole("ADMIN")
                .requestMatchers("/api/user/**").hasAnyRole("USER", "ADMIN")
                .anyRequest().authenticated()
            )
            .formLogin(form -> form
                .loginPage("/login")
                .permitAll()
            )
            .logout(logout -> logout
                .permitAll()
            )
            .csrf(csrf -> csrf.disable());  // Disable for REST APIs
        
        return http.build();
    }
    
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
```

## 11.2 JWT Authentication

```java
// JWT Utility
@Component
public class JwtUtil {
    
    @Value("${jwt.secret}")
    private String secret;
    
    @Value("${jwt.expiration}")
    private Long expiration;  // milliseconds
    
    public String generateToken(String username) {
        Map<String, Object> claims = new HashMap<>();
        return Jwts.builder()
            .setClaims(claims)
            .setSubject(username)
            .setIssuedAt(new Date())
            .setExpiration(new Date(System.currentTimeMillis() + expiration))
            .signWith(SignatureAlgorithm.HS512, secret)
            .compact();
    }
    
    public String extractUsername(String token) {
        return extractClaim(token, Claims::getSubject);
    }
    
    public Date extractExpiration(String token) {
        return extractClaim(token, Claims::getExpiration);
    }
    
    public <T> T extractClaim(String token, Function<Claims, T> claimsResolver) {
        final Claims claims = extractAllClaims(token);
        return claimsResolver.apply(claims);
    }
    
    private Claims extractAllClaims(String token) {
        return Jwts.parser().setSigningKey(secret).parseClaimsJws(token).getBody();
    }
    
    public Boolean isTokenExpired(String token) {
        return extractExpiration(token).before(new Date());
    }
    
    public Boolean validateToken(String token, UserDetails userDetails) {
        final String username = extractUsername(token);
        return (username.equals(userDetails.getUsername()) && !isTokenExpired(token));
    }
}

// JWT Filter
@Component
public class JwtRequestFilter extends OncePerRequestFilter {
    
    @Autowired
    private JwtUtil jwtUtil;
    
    @Autowired
    private UserDetailsService userDetailsService;
    
    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, 
                                   FilterChain chain) throws ServletException, IOException {
        
        final String authorizationHeader = request.getHeader("Authorization");
        
        String username = null;
        String jwt = null;
        
        if (authorizationHeader != null && authorizationHeader.startsWith("Bearer ")) {
            jwt = authorizationHeader.substring(7);
            username = jwtUtil.extractUsername(jwt);
        }
        
        if (username != null && SecurityContextHolder.getContext().getAuthentication() == null) {
            UserDetails userDetails = userDetailsService.loadUserByUsername(username);
            
            if (jwtUtil.validateToken(jwt, userDetails)) {
                UsernamePasswordAuthenticationToken authToken = 
                    new UsernamePasswordAuthenticationToken(userDetails, null, userDetails.getAuthorities());
                authToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                SecurityContextHolder.getContext().setAuthentication(authToken);
            }
        }
        
        chain.doFilter(request, response);
    }
}

// Authentication Controller
@RestController
@RequestMapping("/api/auth")
public class AuthController {
    
    @Autowired
    private AuthenticationManager authenticationManager;
    
    @Autowired
    private JwtUtil jwtUtil;
    
    @Autowired
    private UserDetailsService userDetailsService;
    
    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody AuthRequest authRequest) {
        try {
            authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(authRequest.getUsername(), authRequest.getPassword())
            );
        } catch (BadCredentialsException e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid credentials");
        }
        
        final UserDetails userDetails = userDetailsService.loadUserByUsername(authRequest.getUsername());
        final String jwt = jwtUtil.generateToken(userDetails.getUsername());
        
        return ResponseEntity.ok(new AuthResponse(jwt));
    }
}
```

## 11.3 Method-Level Security

```java
@Configuration
@EnableGlobalMethodSecurity(
    prePostEnabled = true,      // @PreAuthorize, @PostAuthorize
    securedEnabled = true,      // @Secured
    jsr250Enabled = true        // @RolesAllowed
)
public class MethodSecurityConfig {
}

@Service
public class UserService {
    
    // Only ADMIN can execute
    @PreAuthorize("hasRole('ADMIN')")
    public void deleteUser(Long id) {
        userRepository.deleteById(id);
    }
    
    // Only owner or ADMIN can execute
    @PreAuthorize("hasRole('ADMIN') or #userId == authentication.principal.id")
    public User updateUser(Long userId, User user) {
        return userRepository.save(user);
    }
    
    // Check return value (filter returned object)
    @PostAuthorize("returnObject.username == authentication.principal.username or hasRole('ADMIN')")
    public User getUserById(Long id) {
        return userRepository.findById(id).orElseThrow();
    }
    
    // @Secured (alternative)
    @Secured({"ROLE_ADMIN", "ROLE_SUPER_ADMIN"})
    public void deleteAllUsers() {
        userRepository.deleteAll();
    }
    
    // @RolesAllowed (JSR-250)
    @RolesAllowed("ADMIN")
    public void dangerousOperation() {
        // Only ADMIN
    }
}
```

---

# 12. TESTING SPRING APPLICATIONS

## 12.1 Unit Testing with Mockito

```java
@ExtendWith(MockitoExtension.class)
class UserServiceTest {
    
    @Mock
    private UserRepository userRepository;
    
    @InjectMocks
    private UserService userService;
    
    @Test
    void testCreateUser() {
        // Given
        User user = new User();
        user.setName("John");
        user.setEmail("john@example.com");
        
        when(userRepository.save(any(User.class))).thenReturn(user);
        
        // When
        User created = userService.createUser(user);
        
        // Then
        assertNotNull(created);
        assertEquals("John", created.getName());
        verify(userRepository, times(1)).save(user);
    }
    
    @Test
    void testFindById_NotFound() {
        // Given
        when(userRepository.findById(1L)).thenReturn(Optional.empty());
        
        // When & Then
        assertThrows(UserNotFoundException.class, () -> {
            userService.findById(1L);
        });
    }
}
```

## 12.2 Integration Testing

```java
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class UserControllerIntegrationTest {
    
    @Autowired
    private MockMvc mockMvc;
    
    @Autowired
    private ObjectMapper objectMapper;
    
    @Autowired
    private UserRepository userRepository;
    
    @BeforeEach
    void setUp() {
        userRepository.deleteAll();
    }
    
    @Test
    void testCreateUser() throws Exception {
        User user = new User();
        user.setName("John");
        user.setEmail("john@example.com");
        user.setAge(25);
        
        mockMvc.perform(post("/api/users")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(user)))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.name").value("John"))
            .andExpect(jsonPath("$.email").value("john@example.com"));
        
        assertEquals(1, userRepository.count());
    }
    
    @Test
    void testGetUserById() throws Exception {
        User user = new User();
        user.setName("John");
        user.setEmail("john@example.com");
        user.setAge(25);
        User saved = userRepository.save(user);
        
        mockMvc.perform(get("/api/users/" + saved.getId()))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.name").value("John"))
            .andExpect(jsonPath("$.email").value("john@example.com"));
    }
    
    @Test
    void testGetUserById_NotFound() throws Exception {
        mockMvc.perform(get("/api/users/999"))
            .andExpect(status().isNotFound());
    }
    
    @Test
    void testValidation_InvalidEmail() throws Exception {
        User user = new User();
        user.setName("John");
        user.setEmail("invalid-email");  // Invalid
        user.setAge(25);
        
        mockMvc.perform(post("/api/users")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(user)))
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.errors.email").value("Email must be valid"));
    }
}
```

## 12.3 Repository Testing

```java
@DataJpaTest
@ActiveProfiles("test")
class UserRepositoryTest {
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private TestEntityManager entityManager;
    
    @Test
    void testFindByEmail() {
        // Given
        User user = new User();
        user.setName("John");
        user.setEmail("john@example.com");
        entityManager.persist(user);
        entityManager.flush();
        
        // When
        Optional<User> found = userRepository.findByEmail("john@example.com");
        
        // Then
        assertTrue(found.isPresent());
        assertEquals("John", found.get().getName());
    }
    
    @Test
    void testFindByAgeGreaterThan() {
        // Given
        User user1 = new User();
        user1.setName("John");
        user1.setAge(25);
        entityManager.persist(user1);
        
        User user2 = new User();
        user2.setName("Jane");
        user2.setAge(30);
        entityManager.persist(user2);
        
        entityManager.flush();
        
        // When
        List<User> users = userRepository.findByAgeGreaterThan(28);
        
        // Then
        assertEquals(1, users.size());
        assertEquals("Jane", users.get(0).getName());
    }
}
```

## 12.4 Testing with Test Containers

```java
@SpringBootTest
@Testcontainers
@ActiveProfiles("test")
class UserServiceIntegrationTest {
    
    @Container
    static MySQLContainer<?> mysql = new MySQLContainer<>("mysql:8.0")
        .withDatabaseName("testdb")
        .withUsername("test")
        .withPassword("test");
    
    @DynamicPropertySource
    static void configureProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", mysql::getJdbcUrl);
        registry.add("spring.datasource.username", mysql::getUsername);
        registry.add("spring.datasource.password", mysql::getPassword);
    }
    
    @Autowired
    private UserService userService;
    
    @Test
    void testUserCreation() {
        User user = new User();
        user.setName("John");
        user.setEmail("john@example.com");
        
        User created = userService.createUser(user);
        
        assertNotNull(created.getId());
        assertEquals("John", created.getName());
    }
}
```

---

# 13. SPRING BOOT PRODUCTION FEATURES

## 13.1 Actuator Endpoints

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
```

```properties
# Expose all actuator endpoints
management.endpoints.web.exposure.include=*

# Or specific endpoints
management.endpoints.web.exposure.include=health,info,metrics,env

# Health details
management.endpoint.health.show-details=always

# Custom info
info.app.name=My Application
info.app.version=1.0.0
info.app.description=Spring Boot Demo
```

**Available Endpoints:**

```
GET /actuator/health        - Application health
GET /actuator/info          - Application info
GET /actuator/metrics       - Application metrics
GET /actuator/metrics/{name} - Specific metric
GET /actuator/env           - Environment properties
GET /actuator/loggers       - Logger configuration
GET /actuator/httptrace     - Recent HTTP requests
GET /actuator/threaddump    - Thread dump
GET /actuator/heapdump      - Heap dump
GET /actuator/beans         - All Spring beans
GET /actuator/mappings      - All @RequestMapping
```

## 13.2 Custom Health Indicator

```java
@Component
public class DatabaseHealthIndicator implements HealthIndicator {
    
    @Autowired
    private DataSource dataSource;
    
    @Override
    public Health health() {
        try (Connection connection = dataSource.getConnection()) {
            if (connection.isValid(1)) {
                return Health.up()
                    .withDetail("database", "Available")
                    .withDetail("validationQuery", "SELECT 1")
                    .build();
            } else {
                return Health.down()
                    .withDetail("database", "Unavailable")
                    .build();
            }
        } catch (Exception e) {
            return Health.down(e)
                .withDetail("error", e.getMessage())
                .build();
        }
    }
}

// Custom health for external API
@Component
public class ExternalApiHealthIndicator implements HealthIndicator {
    
    @Autowired
    private RestTemplate restTemplate;
    
    @Override
    public Health health() {
        try {
            ResponseEntity<String> response = restTemplate.getForEntity(
                "https://api.example.com/health", String.class);
            
            if (response.getStatusCode().is2xxSuccessful()) {
                return Health.up()
                    .withDetail("externalApi", "Available")
                    .build();
            } else {
                return Health.down()
                    .withDetail("externalApi", "Unavailable")
                    .withDetail("statusCode", response.getStatusCode())
                    .build();
            }
        } catch (Exception e) {
            return Health.down(e)
                .withDetail("error", e.getMessage())
                .build();
        }
    }
}
```

## 13.3 Custom Metrics

```java
@Service
public class OrderService {
    
    private final MeterRegistry meterRegistry;
    private final Counter orderCounter;
    private final Timer orderTimer;
    
    public OrderService(MeterRegistry meterRegistry) {
        this.meterRegistry = meterRegistry;
        
        // Counter
        this.orderCounter = Counter.builder("orders.created")
            .description("Total orders created")
            .tag("status", "success")
            .register(meterRegistry);
        
        // Timer
        this.orderTimer = Timer.builder("orders.processing.time")
            .description("Order processing time")
            .register(meterRegistry);
    }
    
    public Order createOrder(OrderRequest request) {
        return orderTimer.record(() -> {
            try {
                Order order = processOrder(request);
                orderCounter.increment();  // Increment counter
                return order;
            } catch (Exception e) {
                Counter.builder("orders.created")
                    .tag("status", "failed")
                    .register(meterRegistry)
                    .increment();
                throw e;
            }
        });
    }
    
    // Gauge (current value)
    @Bean
    public Gauge activeUsers(MeterRegistry registry, UserService userService) {
        return Gauge.builder("users.active", userService, UserService::getActiveUserCount)
            .description("Current active users")
            .register(registry);
    }
}

// Access metrics
// GET /actuator/metrics/orders.created
// GET /actuator/metrics/orders.processing.time
```

## 13.4 Application Properties Best Practices

```properties
# Production configuration

# Server
server.port=8080
server.compression.enabled=true
server.http2.enabled=true

# Connection pool (HikariCP)
spring.datasource.hikari.maximum-pool-size=20
spring.datasource.hikari.minimum-idle=5
spring.datasource.hikari.connection-timeout=30000
spring.datasource.hikari.idle-timeout=600000
spring.datasource.hikari.max-lifetime=1800000

# JPA
spring.jpa.hibernate.ddl-auto=validate  # NEVER use 'update' or 'create' in production!
spring.jpa.show-sql=false
spring.jpa.properties.hibernate.format_sql=false
spring.jpa.properties.hibernate.jdbc.batch_size=20
spring.jpa.properties.hibernate.order_inserts=true
spring.jpa.properties.hibernate.order_updates=true

# Logging
logging.level.root=WARN
logging.level.com.example=INFO
logging.file.name=/var/log/app/application.log
logging.file.max-size=10MB
logging.file.max-history=30

# Actuator security
management.endpoints.web.base-path=/actuator
management.endpoints.web.exposure.include=health,info,metrics
management.endpoint.health.show-details=when-authorized

# Security
spring.security.user.name=admin
spring.security.user.password=${ADMIN_PASSWORD}  # From environment variable

# Graceful shutdown
server.shutdown=graceful
spring.lifecycle.timeout-per-shutdown-phase=30s
```

---

# 14. INTERVIEW QUESTIONS

## Q1: Explain Dependency Injection. What are its benefits?

**Answer:**

**Dependency Injection (DI)** is a design pattern where objects receive their dependencies from external sources rather than creating them internally.

**Traditional Approach (No DI):**

```java
public class UserService {
    private UserRepository repository = new UserRepositoryImpl();  // Tight coupling
}
```

**With DI:**

```java
@Service
public class UserService {
    private final UserRepository repository;
    
    @Autowired  // Spring injects dependency
    public UserService(UserRepository repository) {
        this.repository = repository;
    }
}
```

**Benefits:**

1. **Loose Coupling**: Change implementation without modifying UserService
2. **Testability**: Easy to inject mocks for testing
3. **Reusability**: Same UserService works with different repositories
4. **Maintainability**: Dependencies explicit and centralized
5. **Separation of Concerns**: UserService doesn't manage dependencies

---

## Q2: Difference between @Component, @Service, @Repository, and @Controller?

**Answer:**

All are specializations of `@Component` for **semantic clarity**:

```java
@Component  // Generic Spring-managed bean
public class GenericComponent { }

@Service    // Business logic layer
public class UserService { }

@Repository // Data access layer
public class UserRepository { }
// Additional benefit: Exception translation (catches DB exceptions, wraps in DataAccessException)

@Controller // Web layer (returns views)
public class UserController { }

@RestController  // = @Controller + @ResponseBody (returns JSON/XML)
public class UserRestController { }
```

**Technical Differences:**

- **@Repository**: Adds exception translation via PersistenceExceptionTranslationPostProcessor
- **@Service, @Controller**: No technical difference from @Component, just semantic

**Best Practice:** Use specific stereotype for clarity:
- Business logic → `@Service`
- Database operations → `@Repository`
- Web endpoints → `@Controller` or `@RestController`
- Generic beans → `@Component`

---

## Q3: How does Spring Boot Auto-Configuration work?

**Answer:**

Spring Boot auto-configuration automatically configures beans based on:
1. **Classpath contents**
2. **Existing bean definitions**
3. **Application properties**

**Process:**

1. `@EnableAutoConfiguration` triggers auto-configuration
2. Spring Boot scans `META-INF/spring.factories` files in JARs
3. Loads auto-configuration classes (e.g., `DataSourceAutoConfiguration`)
4. Each class has `@Conditional` annotations to determine if it should apply

**Example: DataSource Auto-Configuration**

```java
@Configuration
@ConditionalOnClass(DataSource.class)  // Only if DataSource in classpath
@EnableConfigurationProperties(DataSourceProperties.class)
public class DataSourceAutoConfiguration {
    
    @Bean
    @ConditionalOnMissingBean  // Only if no DataSource bean exists
    public DataSource dataSource(DataSourceProperties properties) {
        // Create DataSource from application.properties
        return DataSourceBuilder.create()
            .url(properties.getUrl())
            .username(properties.getUsername())
            .password(properties.getPassword())
            .build();
    }
}
```

**How to View What's Auto-Configured:**

```bash
java -jar app.jar --debug
# Shows all auto-configuration decisions
```

**Override Auto-Configuration:**

```java
@Configuration
public class MyConfig {
    @Bean
    public DataSource dataSource() {
        // Your custom DataSource overrides auto-configured one
        return new HikariDataSource();
    }
}
```

---

## Q4: Explain @Transactional. What happens if a method annotated with @Transactional calls another @Transactional method in the same class?

**Answer:**

**@Transactional** marks a method to execute within a database transaction (all-or-nothing).

**Normal Usage:**

```java
@Service
public class OrderService {
    
    @Transactional
    public void createOrder(Order order) {
        orderRepository.save(order);
        inventoryService.deductStock(order.getProductId());
        // If deductStock throws exception, save() is rolled back
    }
}
```

**Self-Invocation Problem:**

```java
@Service
public class OrderService {
    
    public void publicMethod() {
        internalTransactionalMethod();  // @Transactional NOT APPLIED!
    }
    
    @Transactional
    private void internalTransactionalMethod() {
        // Transaction not started!
    }
}
```

**Why?**

Spring uses **AOP proxies** to implement @Transactional:
- Spring creates proxy: `OrderServiceProxy → OrderService`
- External calls go through proxy (transaction starts)
- Internal calls bypass proxy (NO transaction!)

**Solutions:**

1. **Call through another bean (Recommended):**

```java
@Service
public class OrderService {
    @Autowired
    private TransactionalOperations transactionalOps;
    
    public void publicMethod() {
        transactionalOps.internalOperation();  // Goes through proxy
    }
}

@Service
public class TransactionalOperations {
    @Transactional
    public void internalOperation() {
        // Transaction works!
    }
}
```

2. **Self-injection (works but awkward):**

```java
@Service
public class OrderService {
    @Autowired
    private OrderService self;  // Injects proxy
    
    public void publicMethod() {
        self.internalTransactionalMethod();  // Goes through proxy
    }
    
    @Transactional
    public void internalTransactionalMethod() {
        // Transaction works!
    }
}
```

---

## Q5: What is the difference between @RequestParam and @PathVariable?

**Answer:**

```java
@RestController
public class UserController {
    
    // @PathVariable - Part of URL path
    // GET /api/users/123
    @GetMapping("/users/{id}")
    public User getUser(@PathVariable Long id) {
        return userService.findById(id);
    }
    
    // @RequestParam - Query parameter
    // GET /api/users?name=John&age=25
    @GetMapping("/users")
    public List<User> searchUsers(
            @RequestParam String name,
            @RequestParam Integer age) {
        return userService.search(name, age);
    }
    
    // Optional @RequestParam
    // GET /api/users?page=0
    @GetMapping("/users")
    public Page<User> getUsers(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(required = false) String filter) {
        return userService.findAll(page, filter);
    }
    
    // Multiple path variables
    // GET /api/users/123/orders/456
    @GetMapping("/users/{userId}/orders/{orderId}")
    public Order getOrder(@PathVariable Long userId, @PathVariable Long orderId) {
        return orderService.find(userId, orderId);
    }
}
```

**Summary:**

| Aspect | @PathVariable | @RequestParam |
|--------|---------------|----------------|
| **Location** | Part of URL path | Query parameter |
| **Format** | `/users/{id}` | `/users?id=123` |
| **Required** | Yes (by default) | Optional (can set `required=false`) |
| **Use Case** | Resource identification | Filtering, pagination, optional params |
| **Example** | `/users/123` | `/users?name=John&age=25` |

---

## Q6: How do you handle exceptions globally in Spring Boot?

**Answer:**

Use **@RestControllerAdvice** (or @ControllerAdvice for non-REST):

```java
@RestControllerAdvice
public class GlobalExceptionHandler {
    
    // Handle specific exception
    @ExceptionHandler(UserNotFoundException.class)
    @ResponseStatus(HttpStatus.NOT_FOUND)
    public ErrorResponse handleUserNotFound(UserNotFoundException ex) {
        return new ErrorResponse(
            HttpStatus.NOT_FOUND.value(),
            ex.getMessage(),
            LocalDateTime.now()
        );
    }
    
    // Handle validation errors
    @ExceptionHandler(MethodArgumentNotValidException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public ValidationErrorResponse handleValidation(MethodArgumentNotValidException ex) {
        Map<String, String> errors = new HashMap<>();
        ex.getBindingResult().getFieldErrors()
            .forEach(error -> errors.put(error.getField(), error.getDefaultMessage()));
        
        return new ValidationErrorResponse(
            HttpStatus.BAD_REQUEST.value(),
            "Validation failed",
            errors,
            LocalDateTime.now()
        );
    }
    
    // Handle all other exceptions
    @ExceptionHandler(Exception.class)
    @ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
    public ErrorResponse handleAllExceptions(Exception ex) {
        logger.error("Unexpected error", ex);
        return new ErrorResponse(
            HttpStatus.INTERNAL_SERVER_ERROR.value(),
            "An unexpected error occurred",
            LocalDateTime.now()
        );
    }
}
```

**Benefits:**

1. **Centralized**: All exception handling in one place
2. **Consistent**: Same error format across application
3. **Clean**: Controllers don't have try-catch blocks
4. **Maintainable**: Easy to modify error responses

---

## Q7: Explain Spring Bean Scopes. When would you use Prototype scope?

**Answer:**

**Bean Scopes:**

```java
// 1. SINGLETON (default) - One instance per Spring container
@Service
@Scope("singleton")
public class SingletonService { }

// 2. PROTOTYPE - New instance every time requested
@Service
@Scope("prototype")
public class PrototypeService { }

// 3. REQUEST - One instance per HTTP request (Web only)
@Service
@Scope(value = "request", proxyMode = ScopedProxyMode.TARGET_CLASS)
public class RequestScopedService { }

// 4. SESSION - One instance per HTTP session (Web only)
@Service
@Scope(value = "session", proxyMode = ScopedProxyMode.TARGET_CLASS)
public class SessionScopedService { }

// 5. APPLICATION - One instance per ServletContext (Web only)
@Service
@Scope(value = "application", proxyMode = ScopedProxyMode.TARGET_CLASS)
public class ApplicationScopedService { }
```

**When to Use Prototype:**

✅ **Use Prototype:**
- Beans with mutable state
- Short-lived objects
- Different configuration per instance
- Stateful operations

```java
// Example: PDF Generator (different config per generation)
@Service
@Scope("prototype")
public class PdfGenerator {
    private String template;
    private Map<String, Object> data;
    
    public void setTemplate(String template) {
        this.template = template;
    }
    
    public void setData(Map<String, Object> data) {
        this.data = data;
    }
    
    public byte[] generate() {
        // Generate PDF with this instance's config
    }
}

// Usage (get new instance each time)
@Service
public class ReportService {
    @Autowired
    private ApplicationContext context;
    
    public byte[] generateReport(String template, Map<String, Object> data) {
        PdfGenerator generator = context.getBean(PdfGenerator.class);  // New instance
        generator.setTemplate(template);
        generator.setData(data);
        return generator.generate();
    }
}
```

❌ **Don't Use Prototype:**
- Stateless services
- Expensive initialization
- Shared resources (connection pools, caches)

**Default Choice:** Always use **SINGLETON** unless you have a specific reason for Prototype.

---

*[More interview questions continue...]*

---

# 15. INTERVIEW TRAPS & EDGE CASES

## Trap 1: @Transactional on Private Methods Doesn't Work

❌ **Wrong:**

```java
@Service
public class UserService {
    
    @Transactional  // IGNORED!
    private void updateUser(User user) {
        userRepository.save(user);
    }
}
```

**Why:** Spring AOP proxies only intercept **public** methods.

✅ **Right:**

```java
@Service
public class UserService {
    
    @Transactional  // Works
    public void updateUser(User user) {
        userRepository.save(user);
    }
}
```

---

## Trap 2: Lazy Fetch Can Cause LazyInitializationException

❌ **Problem:**

```java
@Entity
public class User {
    @OneToMany(fetch = FetchType.LAZY)  // Lazy by default
    private List<Order> orders;
}

@Service
public class UserService {
    
    @Transactional
    public User findUser(Long id) {
        return userRepository.findById(id).orElseThrow();
    }
}

@RestController
public class UserController {
    
    @GetMapping("/users/{id}")
    public User getUser(@PathVariable Long id) {
        User user = userService.findUser(id);  // Transaction ends here
        user.getOrders().size();  // LazyInitializationException!
    }
}
```

✅ **Solutions:**

```java
// Option 1: Fetch within transaction
@Transactional(readOnly = true)
public User findUserWithOrders(Long id) {
    User user = userRepository.findById(id).orElseThrow();
    user.getOrders().size();  // Force initialization
    return user;
}

// Option 2: @EntityGraph
@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    @EntityGraph(attributePaths = "orders")
    Optional<User> findById(Long id);
}

// Option 3: Open Session in View (NOT RECOMMENDED)
spring.jpa.open-in-view=true  // Keep session open for entire request
```

---

## Trap 3: Circular Dependencies

❌ **Problem:**

```java
@Service
public class ServiceA {
    @Autowired
    private ServiceB serviceB;  // ServiceA depends on ServiceB
}

@Service
public class ServiceB {
    @Autowired
    private ServiceA serviceA;  // ServiceB depends on ServiceA → CIRCULAR!
}

// Error: The dependencies of some of the beans in the application context form a cycle
```

✅ **Solutions:**

```java
// Option 1: Constructor injection + @Lazy
@Service
public class ServiceA {
    private final ServiceB serviceB;
    
    public ServiceA(@Lazy ServiceB serviceB) {  // Break cycle with @Lazy
        this.serviceB = serviceB;
    }
}

// Option 2: Setter injection
@Service
public class ServiceA {
    private ServiceB serviceB;
    
    @Autowired
    public void setServiceB(ServiceB serviceB) {
        this.serviceB = serviceB;
    }
}

// Option 3: Refactor (BEST)
// Extract shared logic into ServiceC
@Service
public class ServiceC {
    public void sharedLogic() { }
}

@Service
public class ServiceA {
    @Autowired
    private ServiceC serviceC;
}

@Service
public class ServiceB {
    @Autowired
    private ServiceC serviceC;
}
```

---

## Trap 4: @Value Not Working in @Configuration

❌ **Problem:**

```java
@Configuration
public class AppConfig {
    
    @Value("${app.name}")
    private String appName;
    
    @Bean
    public MyService myService() {
        System.out.println(appName);  // NULL!
        return new MyService(appName);
    }
}
```

**Why:** `@Value` populated after `@Bean` methods execute.

✅ **Solution:**

```java
@Configuration
public class AppConfig {
    
    @Bean
    public MyService myService(@Value("${app.name}") String appName) {
        return new MyService(appName);  // Works!
    }
}
```

---

## Trap 5: Transaction Rollback Only on RuntimeException

❌ **Problem:**

```java
@Service
public class OrderService {
    
    @Transactional
    public void createOrder(Order order) throws IOException {
        orderRepository.save(order);
        throw new IOException("File not found");  // Transaction NOT rolled back!
    }
}
```

**Why:** Default `@Transactional` only rolls back on **RuntimeException** and **Error**, not checked exceptions.

✅ **Solutions:**

```java
// Option 1: Rollback on all exceptions
@Transactional(rollbackFor = Exception.class)
public void createOrder(Order order) throws IOException {
    orderRepository.save(order);
    throw new IOException();  // Now rolls back
}

// Option 2: Use RuntimeException (recommended)
@Transactional
public void createOrder(Order order) {
    orderRepository.save(order);
    throw new RuntimeException("File not found");  // Rolls back
}
```

---

# 16. CODING PROBLEMS

## Problem 1: Implement Pagination with Spring Data JPA

**Problem:** Create a REST API with pagination, sorting, and filtering.

**Solution:**

```java
// Entity
@Entity
public class Product {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String name;
    private BigDecimal price;
    private String category;
    private boolean inStock;
}

// Repository
@Repository
public interface ProductRepository extends JpaRepository<Product, Long> {
    Page<Product> findByCategoryAndInStock(String category, boolean inStock, Pageable pageable);
    Page<Product> findByPriceBetween(BigDecimal minPrice, BigDecimal maxPrice, Pageable pageable);
}

// Service
@Service
public class ProductService {
    
    @Autowired
    private ProductRepository productRepository;
    
    public Page<Product> searchProducts(String category, boolean inStock, int page, int size, String sortBy, String sortDir) {
        Sort sort = sortDir.equalsIgnoreCase("asc") 
            ? Sort.by(sortBy).ascending()
            : Sort.by(sortBy).descending();
        
        Pageable pageable = PageRequest.of(page, size, sort);
        
        if (category != null) {
            return productRepository.findByCategoryAndInStock(category, inStock, pageable);
        }
        
        return productRepository.findAll(pageable);
    }
}

// Controller
@RestController
@RequestMapping("/api/products")
public class ProductController {
    
    @Autowired
    private ProductService productService;
    
    @GetMapping
    public ResponseEntity<Page<Product>> getProducts(
            @RequestParam(required = false) String category,
            @RequestParam(defaultValue = "true") boolean inStock,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "name") String sortBy,
            @RequestParam(defaultValue = "asc") String sortDir) {
        
        Page<Product> products = productService.searchProducts(category, inStock, page, size, sortBy, sortDir);
        
        return ResponseEntity.ok(products);
    }
}

// Response:
{
  "content": [...],
  "pageable": {
    "pageNumber": 0,
    "pageSize": 10,
    "sort": { "sorted": true }
  },
  "totalPages": 5,
  "totalElements": 50,
  "last": false,
  "first": true,
  "numberOfElements": 10
}
```

---

## Problem 2: Implement Caching in Spring Boot

**Problem:** Add caching to improve performance of frequently accessed data.

**Solution:**

```java
// 1. Enable caching
@SpringBootApplication
@EnableCaching
public class Application {
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}

// 2. Configure cache manager (optional)
@Configuration
public class CacheConfig {
    
    @Bean
    public CacheManager cacheManager() {
        SimpleCacheManager cacheManager = new SimpleCacheManager();
        cacheManager.setCaches(Arrays.asList(
            new ConcurrentMapCache("users"),
            new ConcurrentMapCache("products")
        ));
        return cacheManager;
    }
}

// 3. Use caching annotations
@Service
public class UserService {
    
    @Autowired
    private UserRepository userRepository;
    
    // Cache result
    @Cacheable(value = "users", key = "#id")
    public User findById(Long id) {
        System.out.println("Fetching user from database: " + id);
        return userRepository.findById(id).orElseThrow();
    }
    
    // Remove from cache after update
    @CachePut(value = "users", key = "#user.id")
    public User update(User user) {
        return userRepository.save(user);
    }
    
    // Evict from cache
    @CacheEvict(value = "users", key = "#id")
    public void delete(Long id) {
        userRepository.deleteById(id);
    }
    
    // Evict all entries
    @CacheEvict(value = "users", allEntries = true)
    public void deleteAll() {
        userRepository.deleteAll();
    }
    
    // Conditional caching
    @Cacheable(value = "users", key = "#id", condition = "#id > 0", unless = "#result == null")
    public User findByIdConditional(Long id) {
        return userRepository.findById(id).orElse(null);
    }
}

// Test:
User user1 = userService.findById(1L);  // Database query
User user2 = userService.findById(1L);  // From cache (no DB query)
```

---

# 17. SUMMARY & QUICK REFERENCE

## Spring Core Concepts

```
IoC (Inversion of Control): Framework manages object lifecycle
DI (Dependency Injection): Automatic dependency wiring
  - Constructor Injection (Recommended)
  - Setter Injection
  - Field Injection (Avoid)

Bean Scopes:
  - Singleton (default) - One instance per container
  - Prototype - New instance each time
  - Request/Session/Application - Web scopes

Bean Lifecycle:
  Constructor → Dependency Injection → @PostConstruct → Ready → @PreDestroy → Destroyed
```

## Spring Boot Key Annotations

```java
@SpringBootApplication = @Configuration + @EnableAutoConfiguration + @ComponentScan

@Component     // Generic Spring bean
@Service       // Business logic layer
@Repository    // Data access layer
@Controller    // Web layer (views)
@RestController // REST API (@Controller + @ResponseBody)

@Autowired     // Dependency injection
@Value         // Inject property value
@ConfigurationProperties // Type-safe properties

@Transactional // Database transaction
@Cacheable     // Cache result
@Async         // Async execution
```

## REST API Annotations

```java
@RequestMapping  // Map requests to methods
@GetMapping      // GET requests
@PostMapping     // POST requests
@PutMapping      // PUT requests
@DeleteMapping   // DELETE requests
@PatchMapping    // PATCH requests

@PathVariable    // URL path variable
@RequestParam    // Query parameter
@RequestBody     // Request body (JSON)
@RequestHeader   // HTTP header
```

## Spring Data JPA

```java
// Repository methods (auto-implemented):
save(), findById(), findAll(), deleteById(), count(), existsById()

// Query methods:
findByEmail()
findByNameAndAge()
findByAgeGreaterThan()
findByNameContaining()
Page<User> findAll(Pageable)

// Custom queries:
@Query("SELECT u FROM User u WHERE u.email = :email")
Optional<User> findByEmail(@Param("email") String email);
```

## Testing

```java
@SpringBootTest         // Full Spring context
@WebMvcTest            // Only web layer
@DataJpaTest           // Only JPA layer
@MockBean              // Mock bean in context
@Autowired MockMvc     // Test REST endpoints
```

## Production (Actuator)

```
/actuator/health   - Health check
/actuator/metrics  - Application metrics
/actuator/info     - Application info
/actuator/env      - Environment properties
```

---

**END OF SPRING FRAMEWORK & SPRING BOOT INTERVIEW GUIDE**

This comprehensive guide covers Spring Core, Spring Boot, REST APIs, JPA, Transactions, Security, Testing, and Production features. Master these concepts for your backend developer interviews. Good luck! 🚀

**Next Guide:** Database & JPA/Hibernate (Topic 2 of 5)