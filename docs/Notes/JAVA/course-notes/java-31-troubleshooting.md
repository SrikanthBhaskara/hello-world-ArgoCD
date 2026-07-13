# Java Troubleshooting Guide

## Common Exceptions and Solutions

### NullPointerException

```java
// Problem
String name = null;
System.out.println(name.length());  // NullPointerException!

// Solutions
// 1. Null check
if (name != null) {
    System.out.println(name.length());
}

// 2. Optional (Java 8+)
Optional<String> opt = Optional.ofNullable(name);
opt.ifPresent(n -> System.out.println(n.length()));

// 3. Default value
String safeName = name != null ? name : "default";

// 4. Objects.requireNonNull
Objects.requireNonNull(name, "Name cannot be null");
```

**Prevention**:
- Use `@NonNull` annotations
- Return empty collections instead of null
- Use Optional for possibly-absent values
- Fail fast with Objects.requireNonNull

### ClassNotFoundException / NoClassDefFoundError

```bash
# ClassNotFoundException: Class not found at runtime
java.lang.ClassNotFoundException: com.example.MyClass

# NoClassDefFoundError: Class was present at compile time but missing at runtime
java.lang.NoClassDefFoundError: com/example/MyClass
```

**Solutions**:
1. **Check classpath**:
```bash
# Show classpath
java -cp "lib/*:." MyApp

# Or in manifest
Class-Path: lib/dependency1.jar lib/dependency2.jar
```

2. **Maven**: Ensure dependency in pom.xml
```xml
<dependency>
    <groupId>com.example</groupId>
    <artifactId>my-library</artifactId>
    <version>1.0.0</version>
</dependency>
```

3. **Gradle**: Check build.gradle
```groovy
dependencies {
    implementation 'com.example:my-library:1.0.0'
}
```

4. **IDE**: Rebuild project, refresh dependencies

### OutOfMemoryError

#### 1. Heap Space

```bash
java.lang.OutOfMemoryError: Java heap space
```

**Causes**:
- Creating too many objects
- Memory leaks
- Large collections
- Insufficient heap size

**Solutions**:
```bash
# Increase heap size
java -Xms1g -Xmx4g MyApp

# Analyze heap dump
java -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/tmp/heapdump.hprof MyApp
```

**Fix memory leaks**:
```java
// Problem: Static collection grows unbounded
public class Cache {
    private static Map<String, Object> cache = new HashMap<>();  // Memory leak!
    
    public void add(String key, Object value) {
        cache.put(key, value);  // Never removed!
    }
}

// Solution: Use weak references or bounded cache
import com.google.common.cache.*;

public class Cache {
    private static LoadingCache<String, Object> cache = CacheBuilder.newBuilder()
        .maximumSize(1000)
        .expireAfterWrite(10, TimeUnit.MINUTES)
        .build(new CacheLoader<String, Object>() {
            public Object load(String key) {
                return loadFromDatabase(key);
            }
        });
}
```

#### 2. Metaspace (Java 8+)

```bash
java.lang.OutOfMemoryError: Metaspace
```

**Causes**:
- Too many classes loaded
- Classloader leaks
- Excessive use of dynamic proxies

**Solutions**:
```bash
# Increase metaspace
java -XX:MetaspaceSize=256m -XX:MaxMetaspaceSize=512m MyApp
```

#### 3. PermGen (Java 7 and earlier)

```bash
java.lang.OutOfMemoryError: PermGen space
```

**Solution**: Upgrade to Java 8+ or increase PermGen
```bash
java -XX:PermSize=256m -XX:MaxPermSize=512m MyApp
```

### ConcurrentModificationException

```java
// Problem
List<String> list = new ArrayList<>(Arrays.asList("A", "B", "C"));
for (String s : list) {
    if (s.equals("B")) {
        list.remove(s);  // ConcurrentModificationException!
    }
}

// Solution 1: Iterator
Iterator<String> it = list.iterator();
while (it.hasNext()) {
    String s = it.next();
    if (s.equals("B")) {
        it.remove();  // OK
    }
}

// Solution 2: removeIf (Java 8+)
list.removeIf(s -> s.equals("B"));

// Solution 3: CopyOnWriteArrayList (for concurrent access)
List<String> list = new CopyOnWriteArrayList<>(Arrays.asList("A", "B", "C"));
for (String s : list) {
    list.remove(s);  // OK, but expensive
}
```

### StackOverflowError

```java
// Problem: Infinite recursion
public int factorial(int n) {
    return n * factorial(n - 1);  // Never stops!
}

// Solution 1: Base case
public int factorial(int n) {
    if (n <= 1) return 1;  // Base case
    return n * factorial(n - 1);
}

// Solution 2: Iteration
public int factorial(int n) {
    int result = 1;
    for (int i = 2; i <= n; i++) {
        result *= i;
    }
    return result;
}
```

**Also increase stack size if needed**:
```bash
java -Xss2m MyApp  # Default is usually 1MB
```

## Database Issues

### Connection Pool Exhausted

```
java.sql.SQLException: No connections available in pool
```

**Causes**:
- Connections not closed
- Pool size too small
- Connection leaks

**Solutions**:

```java
// Problem: Connection not closed
Connection conn = dataSource.getConnection();
// Use conn
// Forgot to close!

// Solution: try-with-resources
try (Connection conn = dataSource.getConnection();
     PreparedStatement stmt = conn.prepareStatement(sql)) {
    // Use conn and stmt
}  // Automatically closed

// Increase pool size
HikariConfig config = new HikariConfig();
config.setMaximumPoolSize(20);  // Default is 10
config.setMinimumIdle(5);
```

### SQL Exceptions

#### Syntax Error

```sql
-- Problem
SELECT * FROM users WHERE name = John  -- Missing quotes

-- Solution
SELECT * FROM users WHERE name = 'John'
```

#### Constraint Violation

```
java.sql.SQLIntegrityConstraintViolationException: Duplicate entry
```

**Solution**: Check before inserting
```java
if (!userRepository.existsByEmail(email)) {
    userRepository.save(user);
} else {
    throw new DuplicateEmailException();
}
```

## Spring Boot Issues

### Port Already in Use

```
Error: Port 8080 is already in use
```

**Solutions**:

```bash
# 1. Kill process using port (Windows)
netstat -ano | findstr :8080
taskkill /PID <PID> /F

# 2. Kill process (Linux/Mac)
lsof -ti:8080 | xargs kill -9

# 3. Change port in application.properties
server.port=8081
```

### Bean Not Found

```
NoSuchBeanDefinitionException: No qualifying bean of type 'UserService'
```

**Solutions**:

```java
// 1. Add @Service annotation
@Service
public class UserService {
    // ...
}

// 2. Component scan
@SpringBootApplication
@ComponentScan(basePackages = {"com.example"})
public class Application {
    // ...
}

// 3. Create bean manually
@Configuration
public class AppConfig {
    @Bean
    public UserService userService() {
        return new UserService();
    }
}
```

### Circular Dependency

```
BeanCurrentlyInCreationException: Circular dependency
```

**Problem**:
```java
@Service
public class ServiceA {
    @Autowired
    private ServiceB serviceB;
}

@Service
public class ServiceB {
    @Autowired
    private ServiceA serviceA;  // Circular!
}
```

**Solutions**:

```java
// 1. Constructor injection with @Lazy
@Service
public class ServiceA {
    private final ServiceB serviceB;
    
    public ServiceA(@Lazy ServiceB serviceB) {
        this.serviceB = serviceB;
    }
}

// 2. Setter injection
@Service
public class ServiceA {
    private ServiceB serviceB;
    
    @Autowired
    public void setServiceB(ServiceB serviceB) {
        this.serviceB = serviceB;
    }
}

// 3. Refactor (best solution)
@Service
public class ServiceC {
    public void sharedLogic() {
        // ...
    }
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

## Performance Issues

### Slow Application

**Diagnostic Tools**:

```bash
# 1. JVisualVM
jvisualvm

# 2. Java Flight Recorder
java -XX:StartFlightRecording=duration=60s,filename=recording.jfr MyApp
jcmd <pid> JFR.dump filename=recording.jfr

# 3. Thread dump
jstack <pid> > threaddump.txt
# Or
kill -3 <pid>  # Sends SIGQUIT

# 4. Heap dump
jmap -dump:live,format=b,file=heap.bin <pid>

# 5. GC logs
java -Xlog:gc*:file=gc.log:time,tags MyApp
```

**Common Issues**:

1. **N+1 Query Problem**:
```java
// Problem: Lazy loading in loop
List<User> users = userRepository.findAll();
for (User user : users) {
    System.out.println(user.getOrders());  // Fetches orders for each user (N+1 queries)
}

// Solution: Fetch join
@Query("SELECT u FROM User u JOIN FETCH u.orders")
List<User> findAllWithOrders();
```

2. **Missing Index**:
```sql
-- Add index for frequently queried columns
CREATE INDEX idx_user_email ON users(email);
CREATE INDEX idx_order_user_id ON orders(user_id);
```

3. **Too Many Objects Created**:
```java
// Problem
for (int i = 0; i < 1000000; i++) {
    Date date = new Date();  // Creates 1M Date objects!
}

// Solution: Reuse or cache
Date date = new Date();
for (int i = 0; i < 1000000; i++) {
    // Use same date or use System.currentTimeMillis()
}
```

## Debugging Tips

### Enable Debug Logging

```properties
# application.properties
logging.level.root=INFO
logging.level.com.example=DEBUG
logging.level.org.springframework.web=DEBUG
logging.level.org.hibernate.SQL=DEBUG
logging.level.org.hibernate.type.descriptor.sql.BasicBinder=TRACE
```

### Remote Debugging

```bash
# Start application with debug port
java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005 MyApp
```

In IntelliJ:
1. Run → Edit Configurations
2. Add New → Remote JVM Debug
3. Port: 5005
4. Start debugging

### Print Stack Trace

```java
try {
    // Code
} catch (Exception e) {
    e.printStackTrace();  // Console
    logger.error("Error occurred", e);  // Log file
    
    // Get as string
    StringWriter sw = new StringWriter();
    e.printStackTrace(new PrintWriter(sw));
    String stackTrace = sw.toString();
}
```

### Analyze Heap Dump

1. **Generate heap dump**:
```bash
jmap -dump:live,format=b,file=heap.bin <pid>
```

2. **Analyze with Eclipse MAT** (Memory Analyzer Tool):
   - Download from eclipse.org/mat
   - Open heap.bin
   - Run "Leak Suspects Report"
   - Identify objects taking most memory

3. **Or use jhat** (deprecated but simple):
```bash
jhat heap.bin
# Open http://localhost:7000
```

## Build Issues

### Maven

```bash
# Clean and rebuild
mvn clean install

# Skip tests
mvn clean install -DskipTests

# Update dependencies
mvn clean install -U

# Dependency tree
mvn dependency:tree

# Resolve conflicts
mvn dependency:analyze
```

**Common Issues**:

1. **Dependency Conflict**:
```xml
<!-- Exclude conflicting transitive dependency -->
<dependency>
    <groupId>com.example</groupId>
    <artifactId>library</artifactId>
    <version>1.0.0</version>
    <exclusions>
        <exclusion>
            <groupId>org.slf4j</groupId>
            <artifactId>slf4j-log4j12</artifactId>
        </exclusion>
    </exclusions>
</dependency>
```

2. **Wrong Java Version**:
```xml
<properties>
    <maven.compiler.source>17</maven.compiler.source>
    <maven.compiler.target>17</maven.compiler.target>
</properties>
```

### Gradle

```bash
# Clean and rebuild
./gradlew clean build

# Refresh dependencies
./gradlew build --refresh-dependencies

# Dependency tree
./gradlew dependencies
```

## IDE Issues

### IntelliJ IDEA

**Project Not Building**:
1. File → Invalidate Caches / Restart
2. File → Project Structure → Check SDK
3. Maven/Gradle → Reload Project
4. Delete `.idea` folder and reimport

**Code Not Found**:
1. Mark directory as Sources Root (right-click → Mark Directory As)
2. Check Project Structure → Modules

### Eclipse

**Project Not Building**:
1. Project → Clean
2. Project → Update Project (for Maven)
3. Delete workspace `.metadata` and reimport

## Production Issues

### Application Won't Start

**Check logs**:
```bash
# Application logs
tail -f /var/log/myapp/application.log

# System logs
journalctl -u myapp -f
```

**Common causes**:
- Wrong Java version
- Missing environment variables
- Port already in use
- Database connection failure
- Missing configuration file

### High CPU Usage

```bash
# Find Java process
ps aux | grep java

# Thread dump
jstack <pid> > threaddump.txt

# Look for threads in RUNNABLE state
grep RUNNABLE threaddump.txt -A 5
```

### High Memory Usage

```bash
# Check memory
jstat -gc <pid> 1000  # Every second

# Heap dump
jmap -dump:live,format=b,file=heap.bin <pid>

# Analyze with MAT
```

### Too Many Threads

```bash
# Count threads
ps -eLf | grep java | wc -l

# Thread dump
jstack <pid>

# Check for thread leaks (threads not terminating)
```

## Quick Troubleshooting Checklist

1. ✅ **Check logs** (application.log, error.log)
2. ✅ **Check Java version** (`java -version`)
3. ✅ **Check classpath** (missing dependencies?)
4. ✅ **Check configuration** (application.properties, environment variables)
5. ✅ **Check database** (connection, credentials, schema)
6. ✅ **Check memory** (`jstat -gc <pid>`)
7. ✅ **Check threads** (`jstack <pid>`)
8. ✅ **Check ports** (netstat, lsof)
9. ✅ **Enable debug logging**
10. ✅ **Reproduce in minimal example**

## Common Error Messages and Solutions

| Error | Cause | Solution |
|-------|-------|----------|
| `NullPointerException` | Null reference | Add null checks or use Optional |
| `ClassNotFoundException` | Class not in classpath | Add dependency, check classpath |
| `OutOfMemoryError` | Insufficient heap | Increase `-Xmx`, fix memory leaks |
| `StackOverflowError` | Infinite recursion | Add base case, increase `-Xss` |
| `ConcurrentModificationException` | Modifying collection during iteration | Use Iterator.remove() or removeIf() |
| `IllegalStateException` | Invalid state | Check preconditions |
| `NumberFormatException` | Invalid number format | Validate input |
| `NoSuchBeanDefinitionException` | Bean not found | Add @Service/@Component annotation |
| `Port already in use` | Another process using port | Kill process or change port |
| `Connection refused` | Service not running | Start service, check firewall |

---

**Previous**: [← Reactive Programming](java-26-reactive.md) | **Next**: [Real-World Projects →](java-32-projects.md)
