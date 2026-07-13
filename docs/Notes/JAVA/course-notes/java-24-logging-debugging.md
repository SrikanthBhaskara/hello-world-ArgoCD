# Java Logging & Debugging

## Logging Frameworks

### SLF4J + Logback (Recommended)

**Maven Dependencies**:
```xml
<dependencies>
    <!-- SLF4J API -->
    <dependency>
        <groupId>org.slf4j</groupId>
        <artifactId>slf4j-api</artifactId>
        <version>2.0.9</version>
    </dependency>
    
    <!-- Logback (implementation) -->
    <dependency>
        <groupId>ch.qos.logback</groupId>
        <artifactId>logback-classic</artifactId>
        <version>1.4.11</version>
    </dependency>
</dependencies>
```

### Basic Logging

```java
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class UserService {
    private static final Logger logger = LoggerFactory.getLogger(UserService.class);
    
    public User findUser(Long id) {
        logger.debug("Finding user with id: {}", id);
        
        try {
            User user = repository.findById(id);
            
            if (user == null) {
                logger.warn("User not found: {}", id);
                return null;
            }
            
            logger.info("User found: {}", user.getName());
            return user;
            
        } catch (Exception e) {
            logger.error("Error finding user: {}", id, e);
            throw e;
        }
    }
}
```

### Log Levels

```java
public class LogLevelDemo {
    private static final Logger logger = LoggerFactory.getLogger(LogLevelDemo.class);
    
    public void demonstrateLevels() {
        // TRACE: Very detailed, rarely used
        logger.trace("Entering method with args: {}, {}", arg1, arg2);
        
        // DEBUG: Detailed information for debugging
        logger.debug("Processing item: {}", item);
        
        // INFO: Important events (default level)
        logger.info("Application started successfully");
        
        // WARN: Warning, not an error but needs attention
        logger.warn("Cache miss for key: {}", key);
        
        // ERROR: Error that needs attention
        logger.error("Failed to process order: {}", orderId);
        
        // With exception
        try {
            riskyOperation();
        } catch (Exception e) {
            logger.error("Operation failed", e);  // Logs stack trace
        }
    }
}

/* Log Levels (from least to most severe):
   TRACE < DEBUG < INFO < WARN < ERROR
   
   If level is set to INFO:
   - TRACE and DEBUG are not logged
   - INFO, WARN, ERROR are logged
*/
```

### Parameterized Logging

```java
public class ParameterizedLogging {
    private static final Logger logger = LoggerFactory.getLogger(ParameterizedLogging.class);
    
    public void goodExample() {
        String name = "John";
        int age = 30;
        
        // GOOD: Parameterized (efficient)
        logger.info("User {} is {} years old", name, age);
        
        // Multiple parameters
        logger.debug("Processing: user={}, order={}, total={}", 
            userId, orderId, total);
    }
    
    public void badExample() {
        String name = "John";
        int age = 30;
        
        // BAD: String concatenation (inefficient)
        logger.info("User " + name + " is " + age + " years old");
        
        // String concatenation happens even if INFO level is disabled!
    }
    
    public void checkBeforeLogging() {
        // Only if expensive computation is needed
        if (logger.isDebugEnabled()) {
            logger.debug("Expensive result: {}", computeExpensiveValue());
        }
    }
}
```

## Logback Configuration

### logback.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <!-- Console Appender -->
    <appender name="CONSOLE" class="ch.qos.logback.core.ConsoleAppender">
        <encoder>
            <pattern>%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level %logger{36} - %msg%n</pattern>
        </encoder>
    </appender>
    
    <!-- File Appender -->
    <appender name="FILE" class="ch.qos.logback.core.FileAppender">
        <file>logs/application.log</file>
        <encoder>
            <pattern>%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level %logger{36} - %msg%n</pattern>
        </encoder>
    </appender>
    
    <!-- Rolling File Appender -->
    <appender name="ROLLING" class="ch.qos.logback.core.rolling.RollingFileAppender">
        <file>logs/app.log</file>
        <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
            <!-- Daily rollover -->
            <fileNamePattern>logs/app.%d{yyyy-MM-dd}.log</fileNamePattern>
            <!-- Keep 30 days -->
            <maxHistory>30</maxHistory>
            <!-- Total size cap -->
            <totalSizeCap>1GB</totalSizeCap>
        </rollingPolicy>
        <encoder>
            <pattern>%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level %logger{36} - %msg%n</pattern>
        </encoder>
    </appender>
    
    <!-- Size-based Rolling -->
    <appender name="SIZE_ROLLING" class="ch.qos.logback.core.rolling.RollingFileAppender">
        <file>logs/app.log</file>
        <rollingPolicy class="ch.qos.logback.core.rolling.SizeAndTimeBasedRollingPolicy">
            <fileNamePattern>logs/app-%d{yyyy-MM-dd}.%i.log</fileNamePattern>
            <maxFileSize>10MB</maxFileSize>
            <maxHistory>30</maxHistory>
            <totalSizeCap>1GB</totalSizeCap>
        </rollingPolicy>
        <encoder>
            <pattern>%d{yyyy-MM-dd HH:mm:ss} %-5level %logger{36} - %msg%n</pattern>
        </encoder>
    </appender>
    
    <!-- Package-specific logging -->
    <logger name="com.example.myapp" level="DEBUG"/>
    <logger name="org.springframework" level="INFO"/>
    <logger name="org.hibernate" level="WARN"/>
    
    <!-- Root logger -->
    <root level="INFO">
        <appender-ref ref="CONSOLE"/>
        <appender-ref ref="ROLLING"/>
    </root>
</configuration>
```

### Pattern Layout

```xml
<!-- Common patterns -->
%d{yyyy-MM-dd HH:mm:ss}  <!-- Date/time -->
%thread                   <!-- Thread name -->
%-5level                  <!-- Log level (right-padded to 5 chars) -->
%logger{36}              <!-- Logger name (max 36 chars) -->
%msg                     <!-- Log message -->
%n                       <!-- New line -->
%exception               <!-- Exception stack trace -->
%X{userId}               <!-- MDC value -->

<!-- Full example -->
<pattern>%d{yyyy-MM-dd HH:mm:ss.SSS} [%thread] %-5level %logger{36} - %msg%n</pattern>

<!-- Colored console (if terminal supports) -->
<pattern>%d{yyyy-MM-dd HH:mm:ss} [%thread] %highlight(%-5level) %cyan(%logger{36}) - %msg%n</pattern>
```

## MDC (Mapped Diagnostic Context)

### Tracking Request Context

```java
import org.slf4j.MDC;

public class RequestFilter implements Filter {
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        
        // Add request ID to MDC
        String requestId = UUID.randomUUID().toString();
        MDC.put("requestId", requestId);
        
        // Add user ID if authenticated
        String userId = getUserId(httpRequest);
        if (userId != null) {
            MDC.put("userId", userId);
        }
        
        try {
            chain.doFilter(request, response);
        } finally {
            // Clean up MDC
            MDC.clear();
        }
    }
}

// In logback.xml pattern:
<pattern>%d [%X{requestId}] [%X{userId}] %-5level %logger - %msg%n</pattern>

// Log output:
// 2024-03-15 10:30:00 [abc-123] [user-456] INFO  c.e.UserService - User logged in
```

### MDC with CompletableFuture

```java
public class MDCUtil {
    public static <T> CompletableFuture<T> withMDC(
        Supplier<CompletableFuture<T>> supplier
    ) {
        // Capture current MDC
        Map<String, String> contextMap = MDC.getCopyOfContextMap();
        
        return CompletableFuture.supplyAsync(() -> {
            // Set MDC in new thread
            if (contextMap != null) {
                MDC.setContextMap(contextMap);
            }
            
            try {
                return supplier.get().join();
            } finally {
                MDC.clear();
            }
        });
    }
}
```

## Java Debugger (JDB)

### Basic Debugging

```bash
# Compile with debug info
javac -g MyClass.java

# Run with debugger
jdb MyClass

# Common commands
stop at MyClass:10      # Breakpoint at line 10
stop in MyClass.method  # Breakpoint in method
run                     # Start execution
step                    # Step into
next                    # Step over
cont                    # Continue execution
print variable          # Print variable value
dump object             # Dump object state
where                   # Show stack trace
list                    # Show source code
clear                   # Remove breakpoints
quit                    # Exit debugger
```

### Remote Debugging

```bash
# Start application with debug port
java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005 -jar app.jar

# Connect with IDE or jdb
jdb -attach localhost:5005
```

## IDE Debugging

### IntelliJ IDEA / Eclipse

**Breakpoints**:
```java
public class DebugExample {
    public void process(List<String> items) {
        for (String item : items) {
            // Set breakpoint here (click left margin or Ctrl+F8)
            String processed = item.toUpperCase();
            System.out.println(processed);
        }
    }
}
```

**Conditional Breakpoints**:
```java
for (int i = 0; i < 100; i++) {
    // Right-click breakpoint → Condition: i == 50
    processItem(i);
}
```

**Expression Evaluation**:
```java
// During debug, select expression and press Alt+F8
String name = user.getName();
int length = name.length(); // Can evaluate this during debug
```

**Watch Variables**:
```java
// Add to watch window to monitor value changes
private int counter = 0;

public void increment() {
    counter++;  // Watch 'counter' to see it change
}
```

## Profiling Tools

### JVisualVM

```bash
# Start JVisualVM
jvisualvm

# Connect to running JVM
# File → Add JMX Connection → localhost:port

# Features:
# - CPU profiling
# - Memory profiling
# - Heap dump analysis
# - Thread analysis
# - GC monitoring
```

### Java Flight Recorder (JFR)

```bash
# Start application with JFR
java -XX:StartFlightRecording=duration=60s,filename=recording.jfr -jar app.jar

# Or control at runtime
jcmd <pid> JFR.start duration=60s filename=recording.jfr

# Stop recording
jcmd <pid> JFR.stop

# Analyze with JMC (Java Mission Control)
jmc
```

## Exception Handling for Debugging

### Detailed Exception Logging

```java
public class DetailedExceptionLogging {
    private static final Logger logger = LoggerFactory.getLogger(DetailedExceptionLogging.class);
    
    public void processOrder(Order order) {
        try {
            validateOrder(order);
            calculateTotal(order);
            saveOrder(order);
            
        } catch (ValidationException e) {
            logger.error("Validation failed for order: {}", order.getId(), e);
            throw new OrderProcessingException("Invalid order", e);
            
        } catch (CalculationException e) {
            logger.error("Calculation failed: order={}, items={}", 
                order.getId(), order.getItems().size(), e);
            throw new OrderProcessingException("Calculation error", e);
            
        } catch (Exception e) {
            logger.error("Unexpected error processing order: {}", 
                order, e);  // Log entire order
            throw new OrderProcessingException("Processing failed", e);
        }
    }
    
    // Custom exception with context
    public static class OrderProcessingException extends RuntimeException {
        private final String orderId;
        private final Map<String, Object> context;
        
        public OrderProcessingException(String message, Throwable cause) {
            super(message, cause);
            this.orderId = extractOrderId(cause);
            this.context = new HashMap<>();
        }
        
        public void addContext(String key, Object value) {
            context.put(key, value);
        }
        
        @Override
        public String getMessage() {
            return super.getMessage() + 
                   " [orderId=" + orderId + 
                   ", context=" + context + "]";
        }
    }
}
```

### Stack Trace Analysis

```java
public class StackTraceAnalysis {
    private static final Logger logger = LoggerFactory.getLogger(StackTraceAnalysis.class);
    
    public void analyzeException(Exception e) {
        // Get stack trace
        StackTraceElement[] trace = e.getStackTrace();
        
        // Log detailed info
        logger.error("Exception: {}", e.getClass().getName());
        logger.error("Message: {}", e.getMessage());
        logger.error("Caused by: {}", e.getCause());
        
        // Analyze stack
        for (StackTraceElement element : trace) {
            logger.error("  at {}. {}({}:{})",
                element.getClassName(),
                element.getMethodName(),
                element.getFileName(),
                element.getLineNumber()
            );
        }
        
        // Suppressed exceptions (Java 7+)
        for (Throwable suppressed : e.getSuppressed()) {
            logger.error("Suppressed: {}", suppressed.getMessage());
        }
    }
}
```

## Performance Monitoring

### Custom Metrics

```java
public class PerformanceLogger {
    private static final Logger logger = LoggerFactory.getLogger(PerformanceLogger.class);
    
    public <T> T measureTime(String operation, Supplier<T> supplier) {
        long start = System.currentTimeMillis();
        
        try {
            T result = supplier.get();
            long duration = System.currentTimeMillis() - start;
            
            if (duration > 1000) {
                logger.warn("Slow operation: {} took {}ms", operation, duration);
            } else {
                logger.debug("Operation: {} took {}ms", operation, duration);
            }
            
            return result;
            
        } catch (Exception e) {
            long duration = System.currentTimeMillis() - start;
            logger.error("Failed operation: {} after {}ms", operation, duration, e);
            throw e;
        }
    }
    
    // Usage
    public void example() {
        User user = measureTime("findUser", 
            () -> userRepository.findById(123L)
        );
    }
}
```

### Aspect-Oriented Logging (Spring AOP)

```java
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.*;
import org.springframework.stereotype.Component;

@Aspect
@Component
public class LoggingAspect {
    private static final Logger logger = LoggerFactory.getLogger(LoggingAspect.class);
    
    // Log all methods in service layer
    @Around("execution(* com.example.service.*.*(..))")
    public Object logAround(ProceedingJoinPoint joinPoint) throws Throwable {
        String methodName = joinPoint.getSignature().getName();
        Object[] args = joinPoint.getArgs();
        
        logger.debug("Entering: {}() with args: {}", methodName, args);
        
        long start = System.currentTimeMillis();
        
        try {
            Object result = joinPoint.proceed();
            long duration = System.currentTimeMillis() - start;
            
            logger.debug("Exiting: {}() with result: {} ({}ms)", 
                methodName, result, duration);
            
            return result;
            
        } catch (Exception e) {
            long duration = System.currentTimeMillis() - start;
            logger.error("Exception in: {}() after {}ms", 
                methodName, duration, e);
            throw e;
        }
    }
}
```

## Debugging Tips

```java
// 1. Add meaningful log messages
logger.debug("Processing user {} with {} orders", userId, orders.size());

// 2. Log method entry/exit for complex flows
public void complexMethod(String param) {
    logger.debug("Entering complexMethod with: {}", param);
    try {
        // Logic
    } finally {
        logger.debug("Exiting complexMethod");
    }
}

// 3. Log state before exceptions
try {
    riskyOperation();
} catch (Exception e) {
    logger.error("Failed with state: {}, {}, {}", var1, var2, var3, e);
    throw e;
}

// 4. Use appropriate log levels
logger.trace("Detailed trace");     // Very verbose
logger.debug("Debug info");         // Development
logger.info("Important event");     // Production
logger.warn("Warning");             // Needs attention
logger.error("Error occurred");     // Critical

// 5. Never log sensitive data
// BAD:
logger.info("User password: {}", password);
logger.info("Credit card: {}", creditCard);

// GOOD:
logger.info("User authenticated: {}", username);
logger.info("Payment processed for user: {}", userId);
```

## Quick Reference

```java
// SLF4J Logging
private static final Logger logger = LoggerFactory.getLogger(MyClass.class);

logger.trace("Trace");
logger.debug("Debug: {}", value);
logger.info("Info: {} {}", val1, val2);
logger.warn("Warning", exception);
logger.error("Error", exception);

// MDC
MDC.put("key", "value");
MDC.get("key");
MDC.clear();

// Check log level
if (logger.isDebugEnabled()) {
    logger.debug("Expensive: {}", expensiveComputation());
}
```

---

**Previous**: [← Modern Java](java-23-modern-java.md) | **Next**: [Performance →](java-25-performance.md)
