# DATABASE & JPA/HIBERNATE - COMPLETE INTERVIEW GUIDE

**For 5+ Years Experienced Backend Developers**

---

## TABLE OF CONTENTS

1. [JDBC Fundamentals](#1-jdbc-fundamentals)
2. [JPA Overview & Architecture](#2-jpa-overview--architecture)
3. [Entity Mappings & Annotations](#3-entity-mappings--annotations)
4. [Entity Relationships](#4-entity-relationships)
5. [JPQL & Native Queries](#5-jpql--native-queries)
6. [Hibernate Internals](#6-hibernate-internals)
7. [First-Level & Second-Level Cache](#7-first-level--second-level-cache)
8. [Lazy Loading vs Eager Loading](#8-lazy-loading-vs-eager-loading)
9. [N+1 Query Problem & Solutions](#9-n1-query-problem--solutions)
10. [Transaction Management](#10-transaction-management)
11. [Connection Pooling](#11-connection-pooling)
12. [Query Optimization Techniques](#12-query-optimization-techniques)
13. [Spring Data JPA](#13-spring-data-jpa)
14. [Interview Questions with Answers](#14-interview-questions-with-answers)
15. [Interview Traps & Edge Cases](#15-interview-traps--edge-cases)
16. [Coding Problems with Solutions](#16-coding-problems-with-solutions)
17. [Summary & Quick Reference](#17-summary--quick-reference)

---

# 1. JDBC FUNDAMENTALS

## 1.1 What is JDBC?

**JDBC (Java Database Connectivity)** is a Java API for connecting to relational databases and executing SQL queries.

**JDBC Architecture:**

```
Java Application
     ↓
JDBC API (java.sql.*)
     ↓
JDBC Driver Manager
     ↓
JDBC Driver (MySQL, PostgreSQL, Oracle, etc.)
     ↓
Database
```

## 1.2 Basic JDBC Example

```java
import java.sql.*;

public class JdbcExample {
    
    // Old approach (manual resource management)
    public List<User> getAllUsersOldWay() {
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;
        List<User> users = new ArrayList<>();
        
        try {
            // 1. Load driver (not needed for JDBC 4.0+)
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // 2. Establish connection
            conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/mydb",
                "root",
                "password"
            );
            
            // 3. Create statement
            stmt = conn.createStatement();
            
            // 4. Execute query
            rs = stmt.executeQuery("SELECT * FROM users");
            
            // 5. Process results
            while (rs.next()) {
                User user = new User();
                user.setId(rs.getLong("id"));
                user.setName(rs.getString("name"));
                user.setEmail(rs.getString("email"));
                users.add(user);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            // 6. Close resources (important!)
            try { if (rs != null) rs.close(); } catch (SQLException e) { }
            try { if (stmt != null) stmt.close(); } catch (SQLException e) { }
            try { if (conn != null) conn.close(); } catch (SQLException e) { }
        }
        
        return users;
    }
    
    // Modern approach (try-with-resources)
    public List<User> getAllUsersModernWay() {
        List<User> users = new ArrayList<>();
        String sql = "SELECT * FROM users";
        
        try (Connection conn = DriverManager.getConnection(
                 "jdbc:mysql://localhost:3306/mydb", "root", "password");
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                User user = new User();
                user.setId(rs.getLong("id"));
                user.setName(rs.getString("name"));
                user.setEmail(rs.getString("email"));
                users.add(user);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Database error", e);
        }
        
        return users;
    }
}
```

## 1.3 PreparedStatement (SQL Injection Prevention)

```java
public class PreparedStatementExample {
    
    // ❌ DANGEROUS: SQL Injection vulnerability
    public User findUserByNameBad(String name) {
        String sql = "SELECT * FROM users WHERE name = '" + name + "'";
        // If name = "John' OR '1'='1" → returns all users!
        
        try (Connection conn = getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            if (rs.next()) {
                return mapUser(rs);
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
        return null;
    }
    
    // ✅ SAFE: PreparedStatement prevents SQL injection
    public User findUserByNameGood(String name) {
        String sql = "SELECT * FROM users WHERE name = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, name);  // Parameter binding (safe)
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapUser(rs);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
        return null;
    }
    
    // Complex PreparedStatement
    public void createUser(String name, String email, int age) {
        String sql = "INSERT INTO users (name, email, age, created_at) VALUES (?, ?, ?, ?)";
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            pstmt.setString(1, name);
            pstmt.setString(2, email);
            pstmt.setInt(3, age);
            pstmt.setTimestamp(4, new Timestamp(System.currentTimeMillis()));
            
            int rowsAffected = pstmt.executeUpdate();
            System.out.println("Rows inserted: " + rowsAffected);
            
            // Get generated ID
            try (ResultSet generatedKeys = pstmt.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    long id = generatedKeys.getLong(1);
                    System.out.println("Generated ID: " + id);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }
    
    // Batch insert
    public void createUsersBatch(List<User> users) {
        String sql = "INSERT INTO users (name, email) VALUES (?, ?)";
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            conn.setAutoCommit(false);  // Manual transaction
            
            for (User user : users) {
                pstmt.setString(1, user.getName());
                pstmt.setString(2, user.getEmail());
                pstmt.addBatch();  // Add to batch
            }
            
            int[] results = pstmt.executeBatch();  // Execute all at once
            conn.commit();  // Commit transaction
            
            System.out.println("Inserted " + results.length + " users");
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }
}
```

## 1.4 JDBC Transaction Management

```java
public class TransactionExample {
    
    // Transaction: Transfer money between accounts
    public void transferMoney(Long fromAccountId, Long toAccountId, BigDecimal amount) {
        Connection conn = null;
        
        try {
            conn = getConnection();
            conn.setAutoCommit(false);  // Start transaction
            
            // Debit from account
            String debitSql = "UPDATE accounts SET balance = balance - ? WHERE id = ?";
            try (PreparedStatement pstmt = conn.prepareStatement(debitSql)) {
                pstmt.setBigDecimal(1, amount);
                pstmt.setLong(2, fromAccountId);
                pstmt.executeUpdate();
            }
            
            // Simulate error
            // if (true) throw new SQLException("Simulated error");
            
            // Credit to account
            String creditSql = "UPDATE accounts SET balance = balance + ? WHERE id = ?";
            try (PreparedStatement pstmt = conn.prepareStatement(creditSql)) {
                pstmt.setBigDecimal(1, amount);
                pstmt.setLong(2, toAccountId);
                pstmt.executeUpdate();
            }
            
            conn.commit();  // Commit transaction (both updates succeed)
            System.out.println("Transfer successful");
            
        } catch (SQLException e) {
            // Rollback transaction (neither update succeeds)
            if (conn != null) {
                try {
                    conn.rollback();
                    System.err.println("Transaction rolled back");
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            throw new RuntimeException("Transfer failed", e);
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);  // Reset auto-commit
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }
    
    // Savepoint (partial rollback)
    public void complexTransaction() {
        Connection conn = null;
        Savepoint savepoint1 = null;
        Savepoint savepoint2 = null;
        
        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            
            // Operation 1
            executeUpdate(conn, "INSERT INTO users (name) VALUES ('John')");
            savepoint1 = conn.setSavepoint("Savepoint1");
            
            // Operation 2
            executeUpdate(conn, "INSERT INTO orders (user_id) VALUES (1)");
            savepoint2 = conn.setSavepoint("Savepoint2");
            
            // Operation 3 (might fail)
            executeUpdate(conn, "INSERT INTO invalid_table (data) VALUES ('test')");
            
            conn.commit();
        } catch (SQLException e) {
            try {
                if (savepoint2 != null) {
                    conn.rollback(savepoint2);  // Rollback to savepoint2
                    System.out.println("Rolled back to Savepoint2");
                } else if (savepoint1 != null) {
                    conn.rollback(savepoint1);  // Rollback to savepoint1
                    System.out.println("Rolled back to Savepoint1");
                } else {
                    conn.rollback();  // Rollback entire transaction
                    System.out.println("Full rollback");
                }
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        } finally {
            closeConnection(conn);
        }
    }
}
```

## 1.5 Problems with Raw JDBC

```java
/**
 * Problems with JDBC:
 * 
 * 1. Boilerplate Code:
 *    - Manual connection management
 *    - Manual statement creation
 *    - Manual result set processing
 *    - Manual resource cleanup
 * 
 * 2. Error-Prone:
 *    - Resource leaks (forgot to close)
 *    - SQL injection (string concatenation)
 *    - Exception handling complexity
 * 
 * 3. No Object Mapping:
 *    - Manual conversion: ResultSet → Object → ResultSet
 *    - No automatic relationship handling
 * 
 * 4. No Caching:
 *    - Same query executed multiple times → database hit each time
 * 
 * 5. No Lazy Loading:
 *    - Must load all data upfront (even if not needed)
 * 
 * 6. Transaction Management:
 *    - Manual begin/commit/rollback
 *    - Complex nested transactions
 * 
 * 7. Database Portability:
 *    - Different SQL dialects for different databases
 *    - Different data types
 * 
 * **Solution: JPA/Hibernate**
 * - Automatic object-relational mapping
 * - Transparent persistence
 * - Caching (first-level, second-level)
 * - Lazy loading
 * - Automatic transaction management
 * - Database-independent JPQL
 */
```

---

# 2. JPA OVERVIEW & ARCHITECTURE

## 2.1 What is JPA?

**JPA (Java Persistence API)** is a specification for object-relational mapping (ORM) in Java.

```
JPA = Specification (javax.persistence.* / jakarta.persistence.*)
Hibernate = Implementation (most popular)
Other implementations: EclipseLink, OpenJPA
```

**JPA vs Hibernate:**

| Aspect | JPA | Hibernate |
|--------|-----|-----------|
| **Type** | Specification (Interface) | Implementation |
| **Package** | javax.persistence.* | org.hibernate.* |
| **Portability** | Switch implementations easily | Tied to Hibernate |
| **Features** | Standard features only | Extra features (Criteria API, caching) |
| **Annotations** | @Entity, @Id, @ManyToOne | @Formula, @Type, @DynamicUpdate |

**Best Practice:** Use JPA annotations whenever possible for portability.

## 2.2 JPA Architecture

```
Application
    ↓
EntityManager (main interface)
    ↓
Persistence Context (manages entities)
    ↓
Entity (mapped Java objects)
    ↓
Database (tables)
```

**Key Components:**

1. **Entity**: Java class mapped to database table
2. **EntityManager**: API for CRUD operations
3. **Persistence Context**: Cache of managed entities
4. **EntityManagerFactory**: Creates EntityManager instances
5. **Persistence Unit**: Configuration (persistence.xml)

## 2.3 Setting Up JPA/Hibernate

**Maven Dependencies:**

```xml
<dependencies>
    <!-- JPA API -->
    <dependency>
        <groupId>javax.persistence</groupId>
        <artifactId>javax.persistence-api</artifactId>
        <version>2.2</version>
    </dependency>
    
    <!-- Hibernate (JPA implementation) -->
    <dependency>
        <groupId>org.hibernate</groupId>
        <artifactId>hibernate-core</artifactId>
        <version>5.6.14.Final</version>
    </dependency>
    
    <!-- MySQL Driver -->
    <dependency>
        <groupId>mysql</groupId>
        <artifactId>mysql-connector-java</artifactId>
        <version>8.0.33</version>
    </dependency>
</dependencies>
```

**persistence.xml (JPA Configuration):**

```xml
<!-- src/main/resources/META-INF/persistence.xml -->
<persistence xmlns="http://xmlns.jcp.org/xml/ns/persistence" version="2.2">
    
    <persistence-unit name="myPersistenceUnit">
        <provider>org.hibernate.jpa.HibernatePersistenceProvider</provider>
        
        <class>com.example.entity.User</class>
        <class>com.example.entity.Order</class>
        
        <properties>
            <!-- Database connection -->
            <property name="javax.persistence.jdbc.url" 
                      value="jdbc:mysql://localhost:3306/mydb"/>
            <property name="javax.persistence.jdbc.user" value="root"/>
            <property name="javax.persistence.jdbc.password" value="password"/>
            <property name="javax.persistence.jdbc.driver" 
                      value="com.mysql.cj.jdbc.Driver"/>
            
            <!-- Hibernate properties -->
            <property name="hibernate.dialect" 
                      value="org.hibernate.dialect.MySQL8Dialect"/>
            <property name="hibernate.hbm2ddl.auto" value="update"/>
            <property name="hibernate.show_sql" value="true"/>
            <property name="hibernate.format_sql" value="true"/>
            
            <!-- Connection pool (HikariCP recommended) -->
            <property name="hibernate.connection.provider_class" 
                      value="com.zaxxer.hikari.hibernate.HikariConnectionProvider"/>
            <property name="hibernate.hikari.maximumPoolSize" value="20"/>
            <property name="hibernate.hikari.minimumIdle" value="5"/>
        </properties>
    </persistence-unit>
</persistence>
```

**Spring Boot Configuration (Auto-Configuration):**

```yaml
# application.yml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/mydb
    username: root
    password: password
    driver-class-name: com.mysql.cj.jdbc.Driver
    
  jpa:
    hibernate:
      ddl-auto: update  # create, create-drop, update, validate, none
    show-sql: true
    properties:
      hibernate:
        format_sql: true
        dialect: org.hibernate.dialect.MySQL8Dialect
        
        # Performance tuning
        jdbc:
          batch_size: 20
          fetch_size: 50
        order_inserts: true
        order_updates: true
        
        # Second-level cache
        cache:
          use_second_level_cache: true
          region:
            factory_class: org.hibernate.cache.ehcache.EhCacheRegionFactory
```

## 2.4 Basic JPA Usage

```java
import javax.persistence.*;

// Create EntityManagerFactory (application startup)
public class JpaExample {
    
    private static EntityManagerFactory emf;
    
    static {
        emf = Persistence.createEntityManagerFactory("myPersistenceUnit");
    }
    
    // CRUD operations
    public static void main(String[] args) {
        // Create
        User user = new User();
        user.setName("John");
        user.setEmail("john@example.com");
        saveUser(user);
        
        // Read
        User found = findUser(user.getId());
        System.out.println("Found: " + found.getName());
        
        // Update
        found.setEmail("newemail@example.com");
        updateUser(found);
        
        // Delete
        deleteUser(found.getId());
        
        emf.close();  // Application shutdown
    }
    
    // CREATE
    public static void saveUser(User user) {
        EntityManager em = emf.createEntityManager();
        EntityTransaction tx = em.getTransaction();
        
        try {
            tx.begin();
            em.persist(user);  // Insert into database
            tx.commit();
        } catch (Exception e) {
            if (tx.isActive()) {
                tx.rollback();
            }
            throw e;
        } finally {
            em.close();
        }
    }
    
    // READ
    public static User findUser(Long id) {
        EntityManager em = emf.createEntityManager();
        try {
            return em.find(User.class, id);  // SELECT * FROM users WHERE id = ?
        } finally {
            em.close();
        }
    }
    
    // UPDATE
    public static void updateUser(User user) {
        EntityManager em = emf.createEntityManager();
        EntityTransaction tx = em.getTransaction();
        
        try {
            tx.begin();
            em.merge(user);  // UPDATE users SET ... WHERE id = ?
            tx.commit();
        } catch (Exception e) {
            if (tx.isActive()) {
                tx.rollback();
            }
            throw e;
        } finally {
            em.close();
        }
    }
    
    // DELETE
    public static void deleteUser(Long id) {
        EntityManager em = emf.createEntityManager();
        EntityTransaction tx = em.getTransaction();
        
        try {
            tx.begin();
            User user = em.find(User.class, id);
            if (user != null) {
                em.remove(user);  // DELETE FROM users WHERE id = ?
            }
            tx.commit();
        } catch (Exception e) {
            if (tx.isActive()) {
                tx.rollback();
            }
            throw e;
        } finally {
            em.close();
        }
    }
}
```

---

# 3. ENTITY MAPPINGS & ANNOTATIONS

## 3.1 Basic Entity

```java
import javax.persistence.*;
import java.time.LocalDateTime;

@Entity  // Marks class as JPA entity
@Table(name = "users")  // Maps to 'users' table (optional if class name = table name)
public class User {
    
    @Id  // Primary key
    @GeneratedValue(strategy = GenerationType.IDENTITY)  // Auto-increment
    private Long id;
    
    @Column(name = "username", nullable = false, unique = true, length = 50)
    private String username;
    
    @Column(nullable = false)
    private String email;
    
    @Column(name = "age")
    private Integer age;
    
    @Column(name = "created_at", updatable = false)  // Cannot be updated
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    @Transient  // Not persisted to database
    private String temporaryData;
    
    // Lifecycle callbacks
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }
    
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
    
    // Getters and setters
}

/**
 * @Entity: Mandatory, marks class as entity
 * @Table: Optional, customize table name
 * @Id: Mandatory, primary key
 * @GeneratedValue: Auto-generate ID
 * @Column: Optional, customize column mapping
 * @Transient: Exclude field from persistence
 */
```

## 3.2 Primary Key Generation Strategies

```java
// 1. IDENTITY: Auto-increment (MySQL, PostgreSQL)
@Entity
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    // Database auto-generates ID on INSERT
    // INSERT INTO users (name, email) VALUES ('John', 'john@example.com')
    // → id = 1 (generated by database)
}

// 2. SEQUENCE: Database sequence (PostgreSQL, Oracle)
@Entity
public class Product {
    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "product_seq")
    @SequenceGenerator(name = "product_seq", sequenceName = "product_id_seq", 
                       allocationSize = 1)
    private Long id;
    
    // SELECT nextval('product_id_seq') → id = 1
    // INSERT INTO products (id, name) VALUES (1, 'Product1')
}

// 3. TABLE: Database table for ID generation (portable)
@Entity
public class Order {
    @Id
    @GeneratedValue(strategy = GenerationType.TABLE, generator = "order_gen")
    @TableGenerator(name = "order_gen", table = "id_generator", 
                    pkColumnName = "gen_name", valueColumnName = "gen_value",
                    pkColumnValue = "order_id", allocationSize = 1)
    private Long id;
    
    // SELECT gen_value FROM id_generator WHERE gen_name = 'order_id'
    // UPDATE id_generator SET gen_value = gen_value + 1 WHERE gen_name = 'order_id'
}

// 4. AUTO: JPA provider chooses strategy
@Entity
public class Customer {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)  // Hibernate decides
    private Long id;
}

// 5. UUID: Generate UUID
@Entity
public class Document {
    @Id
    @GeneratedValue(generator = "uuid2")
    @GenericGenerator(name = "uuid2", strategy = "uuid2")
    @Column(columnDefinition = "BINARY(16)")  // Store as binary
    private UUID id;
}

// 6. Custom Generator
@Entity
public class Invoice {
    @Id
    @GeneratedValue(generator = "custom-id")
    @GenericGenerator(name = "custom-id", 
                      strategy = "com.example.CustomIdGenerator")
    private String id;  // e.g., "INV-2024-001"
}

// Custom ID generator
public class CustomIdGenerator implements IdentifierGenerator {
    @Override
    public Serializable generate(SessionImplementor session, Object obj) {
        String prefix = "INV";
        String year = String.valueOf(Year.now().getValue());
        
        // Query max ID from database
        String query = "SELECT MAX(CAST(SUBSTRING(id, 10) AS UNSIGNED)) FROM invoices";
        Integer maxId = (Integer) session.createNativeQuery(query).uniqueResult();
        int nextId = (maxId == null) ? 1 : maxId + 1;
        
        return String.format("%s-%s-%03d", prefix, year, nextId);
        // Result: INV-2024-001, INV-2024-002, etc.
    }
}
```

## 3.3 Composite Primary Key

```java
// Method 1: @EmbeddedId
@Embeddable
public class OrderItemId implements Serializable {
    private Long orderId;
    private Long productId;
    
    // Default constructor
    public OrderItemId() {}
    
    public OrderItemId(Long orderId, Long productId) {
        this.orderId = orderId;
        this.productId = productId;
    }
    
    // equals() and hashCode() required!
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        OrderItemId that = (OrderItemId) o;
        return Objects.equals(orderId, that.orderId) && 
               Objects.equals(productId, that.productId);
    }
    
    @Override
    public int hashCode() {
        return Objects.hash(orderId, productId);
    }
}

@Entity
@Table(name = "order_items")
public class OrderItem {
    @EmbeddedId
    private OrderItemId id;
    
    private Integer quantity;
    private BigDecimal price;
    
    // Getters and setters
}

// Usage:
OrderItemId id = new OrderItemId(1L, 100L);
OrderItem item = new OrderItem();
item.setId(id);
item.setQuantity(5);
entityManager.persist(item);

// Method 2: @IdClass (less common)
@IdClass(OrderItemId.class)
@Entity
public class OrderItem {
    @Id
    private Long orderId;
    
    @Id
    private Long productId;
    
    private Integer quantity;
    
    // Getters and setters
}
```

## 3.4 Enum Mapping

```java
public enum OrderStatus {
    PENDING, PROCESSING, SHIPPED, DELIVERED, CANCELLED
}

@Entity
public class Order {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    // Option 1: Store as String (default)
    @Enumerated(EnumType.STRING)
    @Column(length = 20)
    private OrderStatus status;
    // Database: 'PENDING', 'PROCESSING', etc. (readable)
    
    // Option 2: Store as Integer (ordinal)
    @Enumerated(EnumType.ORDINAL)
    private OrderStatus statusOrdinal;
    // Database: 0, 1, 2, 3, 4 (breaks if enum order changes!)
    
    // ⚠️ NEVER use EnumType.ORDINAL in production!
    // Adding new enum value in middle breaks existing data
}

// Best Practice: Custom converter for complex enums
public enum PaymentMethod {
    CREDIT_CARD("CC"),
    DEBIT_CARD("DC"),
    PAYPAL("PP"),
    BANK_TRANSFER("BT");
    
    private final String code;
    
    PaymentMethod(String code) {
        this.code = code;
    }
    
    public String getCode() {
        return code;
    }
    
    public static PaymentMethod fromCode(String code) {
        for (PaymentMethod method : values()) {
            if (method.code.equals(code)) {
                return method;
            }
        }
        throw new IllegalArgumentException("Unknown code: " + code);
    }
}

@Converter(autoApply = true)
public class PaymentMethodConverter 
        implements AttributeConverter<PaymentMethod, String> {
    
    @Override
    public String convertToDatabaseColumn(PaymentMethod attribute) {
        return attribute == null ? null : attribute.getCode();
    }
    
    @Override
    public PaymentMethod convertToEntityAttribute(String dbData) {
        return dbData == null ? null : PaymentMethod.fromCode(dbData);
    }
}

@Entity
public class Payment {
    @Id
    private Long id;
    
    private PaymentMethod method;  // Stored as 'CC', 'DC', etc.
}
```

## 3.5 Date/Time Mapping

```java
import java.time.*;
import java.util.Date;

@Entity
public class Event {
    @Id
    private Long id;
    
    // Legacy Date (avoid)
    @Temporal(TemporalType.DATE)  // Only date (yyyy-MM-dd)
    private Date eventDate;
    
    @Temporal(TemporalType.TIME)  // Only time (HH:mm:ss)
    private Date eventTime;
    
    @Temporal(TemporalType.TIMESTAMP)  // Date + time
    private Date eventTimestamp;
    
    // Modern Java 8 Date/Time API (recommended)
    private LocalDate date;               // yyyy-MM-dd
    private LocalTime time;               // HH:mm:ss
    private LocalDateTime dateTime;       // yyyy-MM-dd HH:mm:ss
    private ZonedDateTime zonedDateTime;  // With timezone
    private Instant instant;              // UTC timestamp
    
    // Hibernate automatically converts Java 8 date/time types
    // No @Temporal needed for LocalDate, LocalDateTime, etc.
}
```

## 3.6 LOB (Large Objects)

```java
@Entity
public class Document {
    @Id
    private Long id;
    
    // CLOB: Character Large Object (text)
    @Lob
    @Column(columnDefinition = "TEXT")
    private String content;  // Large text (> 65535 chars)
    
    // BLOB: Binary Large Object (binary data)
    @Lob
    @Column(columnDefinition = "BLOB")
    private byte[] fileData;  // Files, images, etc.
    
    // ⚠️ WARNING: LOBs loaded eagerly by default
    // Always use lazy fetching for large data
    @Lob
    @Basic(fetch = FetchType.LAZY)
    private byte[] largeFile;
}
```

---

**[Part 2 continues with Entity Relationships, JPQL, Hibernate Internals, Caching, Lazy Loading, N+1 Problem, Transactions, Optimization, Interview Questions, Traps, and Coding Problems...]**

---

# 4. ENTITY RELATIONSHIPS

## 4.1 @OneToOne

```java
// Uni-directional One-to-One
@Entity
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    private String name;
    
    @OneToOne(cascade = CascadeType.ALL)
    @JoinColumn(name = "profile_id", referencedColumnName = "id")
    private UserProfile profile;
    
    // User owns the relationship (has foreign key)
}

@Entity
public class UserProfile {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    private String bio;
    private String avatar;
    
    // No reference back to User (uni-directional)
}

// Bi-directional One-to-One (preferred for navigation)
@Entity
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    private String name;
    
    @OneToOne(mappedBy = "user", cascade = CascadeType.ALL, orphanRemoval = true)
    private UserProfile profile;  // Inverse side (doesn't own FK)
    
    public void setProfile(UserProfile profile) {
        this.profile = profile;
        profile.setUser(this);  // Maintain bi-directional link
    }
}

@Entity
public class UserProfile {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    private String bio;
    
    @OneToOne
    @JoinColumn(name = "user_id")  // Owning side (has foreign key)
    private User user;
}

// Usage:
User user = new User();
user.setName("John");

UserProfile profile = new UserProfile();
profile.setBio("Software Engineer");

user.setProfile(profile);  // Sets both sides of relationship

entityManager.persist(user);  // Cascades to profile
```

## 4.2 @OneToMany and @ManyToOne

```java
// Bi-directional One-to-Many / Many-to-One
@Entity
public class Department {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    private String name;
    
    @OneToMany(mappedBy = "department", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Employee> employees = new ArrayList<>();
    
    // Helper methods to maintain bi-directional link
    public void addEmployee(Employee employee) {
        employees.add(employee);
        employee.setDepartment(this);
    }
    
    public void removeEmployee(Employee employee) {
        employees.remove(employee);
        employee.setDepartment(null);
    }
}

@Entity
public class Employee {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    private String name;
    
    @ManyToOne(fetch = FetchType.LAZY)  // Always use LAZY for @ManyToOne!
    @JoinColumn(name = "department_id")  // Foreign key column
    private Department department;
}

// Usage:
Department dept = new Department();
dept.setName("Engineering");

Employee emp1 = new Employee();
emp1.setName("John");

Employee emp2 = new Employee();
emp2.setName("Jane");

dept.addEmployee(emp1);  // Sets both sides
dept.addEmployee(emp2);

entityManager.persist(dept);  // Cascades to employees

// Query:
Department found = entityManager.find(Department.class, 1L);
List<Employee> employees = found.getEmployees();  // Lazy loaded when accessed
```

## 4.3 @ManyToMany

```java
// Many-to-Many with Join Table
@Entity
public class Student {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    private String name;
    
    @ManyToMany
    @JoinTable(
        name = "student_course",  // Join table name
        joinColumns = @JoinColumn(name = "student_id"),  // FK to this entity
        inverseJoinColumns = @JoinColumn(name = "course_id")  // FK to other entity
    )
    private Set<Course> courses = new HashSet<>();
    
    public void addCourse(Course course) {
        courses.add(course);
        course.getStudents().add(this);
    }
    
    public void removeCourse(Course course) {
        courses.remove(course);
        course.getStudents().remove(this);
    }
}

@Entity
public class Course {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    private String title;
    
    @ManyToMany(mappedBy = "courses")  // Inverse side
    private Set<Student> students = new HashSet<>();
}

// Usage:
Student student = new Student();
student.setName("John");

Course math = new Course();
math.setTitle("Mathematics");

Course physics = new Course();
physics.setTitle("Physics");

student.addCourse(math);
student.addCourse(physics);

entityManager.persist(student);
entityManager.persist(math);
entityManager.persist(physics);

// Many-to-Many with Extra Attributes (Join Entity)
@Entity
public class Student {
    @Id
    private Long id;
    private String name;
    
    @OneToMany(mappedBy = "student")
    private Set<Enrollment> enrollments = new HashSet<>();
}

@Entity
public class Course {
    @Id
    private Long id;
    private String title;
    
    @OneToMany(mappedBy = "course")
    private Set<Enrollment> enrollments = new HashSet<>();
}

@Entity
@Table(name = "enrollments")
public class Enrollment {
    @EmbeddedId
    private EnrollmentId id;
    
    @ManyToOne
    @MapsId("studentId")
    @JoinColumn(name = "student_id")
    private Student student;
    
    @ManyToOne
    @MapsId("courseId")
    @JoinColumn(name = "course_id")
    private Course course;
    
    private LocalDate enrollmentDate;
    private Integer grade;  // Extra attribute!
    
    // Constructors, getters, setters
}

@Embeddable
public class EnrollmentId implements Serializable {
    private Long studentId;
    private Long courseId;
    
    // equals() and hashCode()
}

// Usage:
Student student = new Student();
Course course = new Course();

Enrollment enrollment = new Enrollment();
enrollment.setId(new EnrollmentId(student.getId(), course.getId()));
enrollment.setStudent(student);
enrollment.setCourse(course);
enrollment.setEnrollmentDate(LocalDate.now());
enrollment.setGrade(95);

entityManager.persist(enrollment);
```

## 4.4 Cascade Types

```java
@Entity
public class Order {
    @Id
    private Long id;
    
    // CascadeType.ALL: All operations cascade
    @OneToMany(mappedBy = "order", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<OrderItem> items = new ArrayList<>();
    
    // CascadeType.PERSIST: Only persist cascades
    @ManyToOne(cascade = CascadeType.PERSIST)
    private Customer customer;
    
    // CascadeType.MERGE: Only merge cascades
    @ManyToOne(cascade = CascadeType.MERGE)
    private Address shippingAddress;
    
    // CascadeType.REMOVE: Only remove cascades
    @OneToOne(cascade = CascadeType.REMOVE)
    private Invoice invoice;
    
    // CascadeType.REFRESH: Only refresh cascades
    @ManyToOne(cascade = CascadeType.REFRESH)
    private PaymentMethod paymentMethod;
    
    // Multiple cascade types
    @OneToMany(cascade = {CascadeType.PERSIST, CascadeType.MERGE})
    private List<OrderNote> notes;
}

/**
 * Cascade Types:
 * 
 * PERSIST: child saved when parent saved
 * MERGE: child merged when parent merged
 * REMOVE: child deleted when parent deleted
 * REFRESH: child refreshed when parent refreshed
 * DETACH: child detached when parent detached
 * ALL: all of the above
 * 
 * orphanRemoval = true: Delete child when removed from collection
 */

// Example:
Order order = new Order();
OrderItem item1 = new OrderItem();
OrderItem item2 = new OrderItem();

order.addItem(item1);  // Add to collection
order.addItem(item2);

entityManager.persist(order);  // Cascades to item1 and item2 (saved automatically)

// Later:
order.removeItem(item1);  // Remove from collection
entityManager.merge(order);  // item1 deleted (orphanRemoval = true)
```

## 4.5 Fetch Types

```java
@Entity
public class User {
    @Id
    private Long id;
    
    // LAZY (default for OneToMany, ManyToMany): Load when accessed
    @OneToMany(mappedBy = "user", fetch = FetchType.LAZY)
    private List<Order> orders;  // Not loaded until orders.get(0) called
    
    // EAGER (default for ManyToOne, OneToOne): Load immediately
    @ManyToOne(fetch = FetchType.EAGER)
    private Department department;  // Loaded with User
}

/**
 * Default Fetch Types:
 * 
 * @OneToOne:   EAGER
 * @ManyToOne:  EAGER  
 * @OneToMany:  LAZY
 * @ManyToMany: LAZY
 * 
 * Best Practice:
 * - ALWAYS use LAZY for @ManyToOne and @OneToOne
 * - Override EAGER default to avoid unnecessary queries
 * - Use JOIN FETCH in queries when you need data
 */

// Bad (EAGER causes N+1 problem):
@ManyToOne  // Default EAGER
private Department department;

List<User> users = entityManager.createQuery("FROM User", User.class).getResultList();
// Executes 1 query for users + N queries for departments!

// Good (LAZY + JOIN FETCH):
@ManyToOne(fetch = FetchType.LAZY)
private Department department;

List<User> users = entityManager
    .createQuery("SELECT u FROM User u JOIN FETCH u.department", User.class)
    .getResultList();
// Executes 1 query with JOIN!
```

# 5. JPQL & NATIVE QUERIES

## 5.1 JPQL (Java Persistence Query Language)

**JPQL** queries entities (objects), not tables.

```java
// Basic JPQL queries
@Service
public class UserService {
    
    @PersistenceContext
    private EntityManager em;
    
    // SELECT all
    public List<User> findAll() {
        return em.createQuery("SELECT u FROM User u", User.class)
                 .getResultList();
        // FROM User (entity name), not FROM users (table name)
    }
    
    // WHERE clause
    public List<User> findByName(String name) {
        return em.createQuery("SELECT u FROM User u WHERE u.name = :name", User.class)
                 .setParameter("name", name)
                 .getResultList();
    }
    
    // Multiple conditions
    public List<User> findByNameAndAge(String name, Integer minAge) {
        return em.createQuery(
            "SELECT u FROM User u WHERE u.name LIKE :name AND u.age >= :minAge",
            User.class)
            .setParameter("name", "%" + name + "%")
            .setParameter("minAge", minAge)
            .getResultList();
    }
    
    // JOIN
    public List<User> findUsersWithOrders() {
        return em.createQuery(
            "SELECT DISTINCT u FROM User u JOIN u.orders o",
            User.class)
            .getResultList();
    }
    
    // LEFT JOIN FETCH (avoid N+1)
    public List<User> findAllWithDepartments() {
        return em.createQuery(
            "SELECT u FROM User u LEFT JOIN FETCH u.department",
            User.class)
            .getResultList();
        // Fetches users and departments in one query
    }
    
    // Aggregate functions
    public Long countUsers() {
        return em.createQuery("SELECT COUNT(u) FROM User u", Long.class)
                 .getSingleResult();
    }
    
    public Double averageAge() {
        return em.createQuery("SELECT AVG(u.age) FROM User u", Double.class)
                 .getSingleResult();
    }
    
    // GROUP BY
    public List<Object[]> countUsersByDepartment() {
        return em.createQuery(
            "SELECT u.department.name, COUNT(u) FROM User u GROUP BY u.department.name",
            Object[].class)
            .getResultList();
        // Returns: [["Engineering", 10], ["Sales", 5]]
    }
    
    // ORDER BY
    public List<User> findAllOrderedByName() {
        return em.createQuery(
            "SELECT u FROM User u ORDER BY u.name ASC, u.age DESC",
            User.class)
            .getResultList();
    }
    
    // Pagination
    public List<User> findUsersPage(int page, int size) {
        return em.createQuery("SELECT u FROM User u ORDER BY u.id", User.class)
                 .setFirstResult(page * size)  // Offset
                 .setMaxResults(size)          // Limit
                 .getResultList();
    }
    
    // Subquery
    public List<User> findUsersWithAboveAverageAge() {
        return em.createQuery(
            "SELECT u FROM User u WHERE u.age > (SELECT AVG(u2.age) FROM User u2)",
            User.class)
            .getResultList();
    }
    
    // UPDATE
    public int updateUserEmail(Long userId, String newEmail) {
        return em.createQuery(
            "UPDATE User u SET u.email = :email WHERE u.id = :id")
            .setParameter("email", newEmail)
            .setParameter("id", userId)
            .executeUpdate();  // Returns number of rows updated
    }
    
    // DELETE
    public int deleteInactiveUsers() {
        return em.createQuery(
            "DELETE FROM User u WHERE u.lastLogin < :cutoffDate")
            .setParameter("cutoffDate", LocalDate.now().minusYears(1))
            .executeUpdate();
    }
}
```

## 5.2 Named Queries

```java
// Define named queries on entity
@Entity
@NamedQueries({
    @NamedQuery(
        name = "User.findAll",
        query = "SELECT u FROM User u ORDER BY u.name"
    ),
    @NamedQuery(
        name = "User.findByEmail",
        query = "SELECT u FROM User u WHERE u.email = :email"
    ),
    @NamedQuery(
        name = "User.findActive",
        query = "SELECT u FROM User u WHERE u.active = true"
    )
})
public class User {
    @Id
    private Long id;
    private String name;
    private String email;
    private boolean active;
}

// Usage:
public class UserRepository {
    @PersistenceContext
    private EntityManager em;
    
    public List<User> findAll() {
        return em.createNamedQuery("User.findAll", User.class)
                 .getResultList();
    }
    
    public User findByEmail(String email) {
        return em.createNamedQuery("User.findByEmail", User.class)
                 .setParameter("email", email)
                 .getSingleResult();
    }
}

// Named native query
@NamedNativeQuery(
    name = "User.findByEmailNative",
    query = "SELECT * FROM users WHERE email = :email",
    resultClass = User.class
)
```

## 5.3 Native Queries

```java
@Service
public class UserService {
    
    @PersistenceContext
    private EntityManager em;
    
    // Native query returning entities
    public List<User> findByNativeQuery(String name) {
        return em.createNativeQuery(
            "SELECT * FROM users WHERE name LIKE ?",
            User.class)
            .setParameter(1, "%" + name + "%")
            .getResultList();
    }
    
    // Native query returning scalars
    public List<Object[]> getUserStatistics() {
        return em.createNativeQuery(
            "SELECT department_id, COUNT(*), AVG(age) " +
            "FROM users " +
            "GROUP BY department_id")
            .getResultList();
        // Returns: [[1, 10, 30.5], [2, 5, 28.3]]
    }
    
    // Native query with result mapping
    @SqlResultSetMapping(
        name = "UserStatsMapping",
        classes = @ConstructorResult(
            targetClass = UserStats.class,
            columns = {
                @ColumnResult(name = "department_id", type = Long.class),
                @ColumnResult(name = "user_count", type = Long.class),
                @ColumnResult(name = "avg_age", type = Double.class)
            }
        )
    )
    public List<UserStats> getUserStats() {
        return em.createNativeQuery(
            "SELECT department_id, COUNT(*) as user_count, AVG(age) as avg_age " +
            "FROM users GROUP BY department_id",
            "UserStatsMapping")
            .getResultList();
    }
    
    // Database-specific features (stored procedures, etc.)
    public void callStoredProcedure(Long userId) {
        StoredProcedureQuery query = em.createStoredProcedureQuery("update_user_status");
        query.registerStoredProcedureParameter(1, Long.class, ParameterMode.IN);
        query.registerStoredProcedureParameter(2, String.class, ParameterMode.OUT);
        
        query.setParameter(1, userId);
        query.execute();
        
        String result = (String) query.getOutputParameterValue(2);
        System.out.println("Procedure result: " + result);
    }
}

// DTO for native query result
public class UserStats {
    private Long departmentId;
    private Long userCount;
    private Double avgAge;
    
    public UserStats(Long departmentId, Long userCount, Double avgAge) {
        this.departmentId = departmentId;
        this.userCount = userCount;
        this.avgAge = avgAge;
    }
    
    // Getters
}
```

## 5.4 Criteria API (Type-Safe Queries)

```java
import javax.persistence.criteria.*;

@Service
public class UserSearchService {
    
    @PersistenceContext
    private EntityManager em;
    
    // Simple criteria query
    public List<User> findByName(String name) {
        CriteriaBuilder cb = em.getCriteriaBuilder();
        CriteriaQuery<User> cq = cb.createQuery(User.class);
        Root<User> user = cq.from(User.class);
        
        cq.select(user)
          .where(cb.equal(user.get("name"), name));
        
        return em.createQuery(cq).getResultList();
    }
    
    // Dynamic query (conditional WHERE clauses)
    public List<User> searchUsers(String name, Integer minAge, Integer maxAge, String email) {
        CriteriaBuilder cb = em.getCriteriaBuilder();
        CriteriaQuery<User> cq = cb.createQuery(User.class);
        Root<User> user = cq.from(User.class);
        
        List<Predicate> predicates = new ArrayList<>();
        
        if (name != null && !name.isEmpty()) {
            predicates.add(cb.like(user.get("name"), "%" + name + "%"));
        }
        
        if (minAge != null) {
            predicates.add(cb.greaterThanOrEqualTo(user.get("age"), minAge));
        }
        
        if (maxAge != null) {
            predicates.add(cb.lessThanOrEqualTo(user.get("age"), maxAge));
        }
        
        if (email != null && !email.isEmpty()) {
            predicates.add(cb.equal(user.get("email"), email));
        }
        
        cq.where(predicates.toArray(new Predicate[0]));
        
        return em.createQuery(cq).getResultList();
    }
    
    // Join with Criteria API
    public List<User> findUsersInDepartment(String departmentName) {
        CriteriaBuilder cb = em.getCriteriaBuilder();
        CriteriaQuery<User> cq = cb.createQuery(User.class);
        Root<User> user = cq.from(User.class);
        Join<User, Department> department = user.join("department");
        
        cq.select(user)
          .where(cb.equal(department.get("name"), departmentName));
        
        return em.createQuery(cq).getResultList();
    }
    
    // Aggregate with Criteria API
    public Long countUsersByDepartment(Long departmentId) {
        CriteriaBuilder cb = em.getCriteriaBuilder();
        CriteriaQuery<Long> cq = cb.createQuery(Long.class);
        Root<User> user = cq.from(User.class);
        
        cq.select(cb.count(user))
          .where(cb.equal(user.get("department").get("id"), departmentId));
        
        return em.createQuery(cq).getSingleResult();
    }
    
    // Order by with Criteria API
    public List<User> findAllOrderedByAge() {
        CriteriaBuilder cb = em.getCriteriaBuilder();
        CriteriaQuery<User> cq = cb.createQuery(User.class);
        Root<User> user = cq.from(User.class);
        
        cq.select(user)
          .orderBy(cb.desc(user.get("age")));
        
        return em.createQuery(cq).getResultList();
    }
}
```

---

# 6. HIBERNATE INTERNALS

## 6.1 Entity States

```java
/**
 * Entity Lifecycle States:
 * 
 * 1. TRANSIENT: New object, not associated with EntityManager
 * 2. PERSISTENT (MANAGED): Associated with EntityManager, changes tracked
 * 3. DETACHED: Was persistent, now EntityManager closed
 * 4. REMOVED: Marked for deletion
 */

@Service
public class EntityLifecycleExample {
    
    @PersistenceContext
    private EntityManager em;
    
    public void demonstrateStates() {
        // 1. TRANSIENT state
        User user = new User();
        user.setName("John");
        // No DB interaction yet, not tracked by EntityManager
        
        // 2. PERSISTENT (MANAGED) state
        em.persist(user);
        // Now tracked by EntityManager
        // Changes automatically synced to database
        
        user.setEmail("john@example.com");
        // No need to call em.merge() or em.update()
        // Change detected and flushed automatically on transaction commit
        
        // Check state
        boolean isManaged = em.contains(user);  // true
        
        // 3. DETACHED state
        em.detach(user);
        // or em.clear() to detach all entities
        // or EntityManager closed
        
        user.setEmail("newemail@example.com");
        // Change NOT tracked (detached)
        
        isManaged = em.contains(user);  // false
        
        // Re-attach (merge)
        User managed = em.merge(user);
        // Now changes tracked again
        
        // 4. REMOVED state
        em.remove(managed);
        // Marked for deletion, will be deleted on flush/commit
    }
}
```

## 6.2 Persistence Context & Session

```java
/**
 * Persistence Context = First-Level Cache
 * 
 * - One EntityManager = One Persistence Context
 * - Entities in persistence context are tracked
 * - Changes automatically synced to database
 * - Acts as cache (same entity instance returned for same ID)
 */

@Service
@Transactional
public class PersistenceContextExample {
    
    @PersistenceContext
    private EntityManager em;
    
    public void demonstratePersistenceContext() {
        // First find
        User user1 = em.find(User.class, 1L);
        // SQL: SELECT * FROM users WHERE id = 1
        
        // Second find (same ID)
        User user2 = em.find(User.class, 1L);
        // NO SQL! Returned from persistence context (cache)
        
        System.out.println(user1 == user2);  // true (same instance!)
        
        // Modify
        user1.setName("New Name");
        // Change tracked, will be flushed on transaction commit
        
        // Manual flush
        em.flush();
        // SQL: UPDATE users SET name = 'New Name' WHERE id = 1
        // Synchronizes persistence context with database
        
        // Clear persistence context
        em.clear();
        // All entities detached, cache cleared
        
        User user3 = em.find(User.class, 1L);
        // SQL executed again (not in cache anymore)
    }
    
    // Detach specific entity
    public void detachExample() {
        User user = em.find(User.class, 1L);
        
        em.detach(user);  // Detach single entity
        // or
        em.clear();       // Detach all entities
        
        user.setName("Changed");  // NOT tracked
        
        // Re-attach
        user = em.merge(user);  // Now tracked again
    }
    
    // Refresh entity from database
    public void refreshExample() {
        User user = em.find(User.class, 1L);
        user.setName("Changed in memory");
        
        em.refresh(user);  // Reload from database
        // Discards in-memory changes, reloads from DB
    }
}
```

## 6.3 Flush Modes

```java
@Service
@Transactional
public class FlushModeExample {
    
    @PersistenceContext
    private EntityManager em;
    
    public void demonstrateFlushModes() {
        // AUTO (default): Flush before query if needed
        em.setFlushMode(FlushModeType.AUTO);
        
        User user = new User();
        user.setName("John");
        em.persist(user);
        
        // Query executed
        List<User> users = em.createQuery("SELECT u FROM User u", User.class)
                             .getResultList();
        // AUTO mode: Hibernate flushes changes BEFORE query
        // So John is included in results
        
        // COMMIT: Only flush on transaction commit
        em.setFlushMode(FlushModeType.COMMIT);
        
        User user2 = new User();
        user2.setName("Jane");
        em.persist(user2);
        
        List<User> users2 = em.createQuery("SELECT u FROM User u", User.class)
                              .getResultList();
        // COMMIT mode: Does NOT flush before query
        // Jane is NOT included in results (not yet in database)
        
        // Transaction commit
        // Now Jane is flushed to database
    }
    
    // Manual flush
    public void manualFlush() {
        User user = new User();
        user.setName("John");
        em.persist(user);
        
        em.flush();  // Force flush now
        // SQL: INSERT INTO users ...
        
        // Can now get generated ID
        System.out.println("Generated ID: " + user.getId());
    }
}
```

## 6.4 Dirty Checking

```java
/**
 * Dirty Checking:
 * Hibernate automatically detects changes to managed entities
 * and generates UPDATE statements on flush/commit.
 */

@Service
@Transactional
public class DirtyCheckingExample {
    
    @PersistenceContext
    private EntityManager em;
    
    public void updateUser(Long userId, String newEmail) {
        User user = em.find(User.class, userId);
        // Entity is MANAGED (tracked by persistence context)
        
        user.setEmail(newEmail);
        // No need to call em.update() or em.merge()!
        
        // On transaction commit:
        // Hibernate detects change (dirty checking)
        // Automatically generates: UPDATE users SET email = ? WHERE id = ?
    }
    
    // Disable dirty checking for read-only query
    @Transactional(readOnly = true)
    public User getUser(Long userId) {
        User user = em.find(User.class, userId);
        
        // Even if we modify:
        user.setEmail("changed@example.com");
        
        // NO UPDATE executed (readOnly = true)
        // Dirty checking disabled for read-only transactions
        
        return user;
    }
    
    // Selective dirty checking with @DynamicUpdate
    @Entity
    @DynamicUpdate  // Only changed columns in UPDATE
    public class User {
        @Id
        private Long id;
        private String name;
        private String email;
        private Integer age;
    }
    
    // Without @DynamicUpdate:
    // UPDATE users SET name=?, email=?, age=? WHERE id=?
    
    // With @DynamicUpdate:
    // UPDATE users SET email=? WHERE id=?
    // (Only changed column)
}
```

---

# 7. FIRST-LEVEL & SECOND-LEVEL CACHE

## 7.1 First-Level Cache (Persistence Context)

```java
/**
 * First-Level Cache:
 * - Per EntityManager (per transaction)
 * - Always enabled
 * - Cannot be disabled
 * - Ensures same entity instance returned for same ID within transaction
 */

@Service
@Transactional
public class FirstLevelCacheExample {
    
    @PersistenceContext
    private EntityManager em;
    
    public void demonstrateFirstLevelCache() {
        System.out.println("First find:");
        User user1 = em.find(User.class, 1L);
        // SQL: SELECT * FROM users WHERE id = 1
        
        System.out.println("Second find (same transaction):");
        User user2 = em.find(User.class, 1L);
        // NO SQL! Retrieved from first-level cache
        
        System.out.println(user1 == user2);  // true (same instance)
        
        // Clear cache
        em.clear();
        
        System.out.println("Third find (after clear):");
        User user3 = em.find(User.class, 1L);
        // SQL: SELECT * FROM users WHERE id = 1
        // Cache was cleared, so query executed again
    }
}
```

## 7.2 Second-Level Cache (Shared Cache)

```java
/**
 * Second-Level Cache:
 * - Shared across EntityManagers (application-wide)
 * - Optional (disabled by default)
 * - Requires cache provider (EHCache, Infinispan, Hazelcast)
 * - Caches entities, collections, queries
 */

// Enable second-level cache in application.properties
```

```yaml
spring:
  jpa:
    properties:
      hibernate:
        cache:
          use_second_level_cache: true
          region:
            factory_class: org.hibernate.cache.jcache.JCacheRegionFactory
        javax:
          cache:
            provider: org.ehcache.jsr107.EhcacheCachingProvider
            uri: classpath:ehcache.xml
```

```java
// Mark entity as cacheable
@Entity
@Cacheable  //Enable caching for this entity
@org.hibernate.annotations.Cache(usage = CacheConcurrencyStrategy.READ_WRITE)
public class Product {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    private String name;
    private BigDecimal price;
    
    // Cache collections
    @OneToMany(mappedBy = "product")
    @org.hibernate.annotations.Cache(usage = CacheConcurrencyStrategy.READ_WRITE)
    private List<Review> reviews = new ArrayList<>();
}

// Cache concurrency strategies:
// READ_ONLY: Read-only data (never updated)
// NONSTRICT_READ_WRITE: Infrequent updates, slight data staleness acceptable
// READ_WRITE: Frequent updates, strict consistency
// TRANSACTIONAL: JTA transactions, full ACID

@Service
public class ProductService {
    
    @PersistenceContext
    private EntityManager em;
    
    @Transactional(readOnly = true)
    public Product getProduct(Long id) {
        // First call: Database query
        Product product1 = em.find(Product.class, id);
        // Stored in second-level cache
        
        em.clear();  // Clear first-level cache
        
        // Second call: Retrieved from second-level cache (NO SQL)
        Product product2 = em.find(Product.class, id);
        
        return product2;
    }
    
    // Query cache (separate from entity cache)
    @Transactional(readOnly = true)
    public List<Product> findExpensiveProducts() {
        return em.createQuery("SELECT p FROM Product p WHERE p.price > 1000", Product.class)
                 .setHint("org.hibernate.cacheable", true)  // Enable query cache
                 .getResultList();
        // First call: SQL executed, results cached
        // Second call: Results from cache (NO SQL)
    }
    
    // Evict from cache
    public void evictProduct(Long id) {
        Cache cache = em.getEntityManagerFactory().getCache();
        cache.evict(Product.class, id);  // Remove specific entity
        // or
        cache.evict(Product.class);      // Remove all entities of type
        // or
        cache.evictAll();                // Clear entire cache
    }
    
    // Check if in cache
    public boolean isInCache(Long id) {
        Cache cache = em.getEntityManagerFactory().getCache();
        return cache.contains(Product.class, id);
    }
}
```

**EHCache Configuration (ehcache.xml):**

```xml
<ehcache>
    <defaultCache
        maxEntriesLocalHeap="1000"
        eternal="false"
        timeToIdleSeconds="300"
        timeToLiveSeconds="600"/>
    
    <cache name="com.example.entity.Product"
           maxEntriesLocalHeap="5000"
           timeToLiveSeconds="3600"/>
    
    <cache name="com.example.entity.Product.reviews"
           maxEntriesLocalHeap="10000"
           timeToLiveSeconds="1800"/>
</ehcache>
```

---

# 8. LAZY LOADING VS EAGER LOADING

## 8.1 Understanding Lazy Loading

```java
/**
 * LAZY Loading:
 * - Data loaded only when accessed
 * - Reduces initial query size
 * - May cause LazyInitializationException if accessed outside transaction
 * 
 * EAGER Loading:
 * - Data loaded immediately with parent entity
 * - Single query (or multiple queries)
 * - May load unnecessary data
 */

@Entity
public class User {
    @Id
    private Long id;
    private String name;
    
    // LAZY (default for collections)
    @OneToMany(mappedBy = "user", fetch = FetchType.LAZY)
    private List<Order> orders = new ArrayList<>();
    
    // EAGER (default for @ManyToOne, @OneToOne)
    @ManyToOne(fetch = FetchType.EAGER)
    private Department department;
}

@Service
@Transactional
public class UserService {
    
    @PersistenceContext
    private EntityManager em;
    
    public void demonstrateLazyLoading() {
        User user = em.find(User.class, 1L);
        // SQL: SELECT * FROM users WHERE id = 1
        // Orders NOT loaded yet (LAZY)
        
        System.out.println(user.getName());  // OK
        
        List<Order> orders = user.getOrders();  // Triggers loading
        // SQL: SELECT * FROM orders WHERE user_id = 1
        
        for (Order order : orders) {
            System.out.println(order.getId());
        }
    }
    
    // LazyInitializationException
    public void causeLazyException() {
        User user = em.find(User.class, 1L);
        // Transaction/EntityManager still open
        
        // Access lazy collection
        user.getOrders().size();  // OK (within transaction)
    }
    
    @Transactional
    public User getUserWithOrders(Long id) {
        return em.find(User.class, id);
    }
}

// Using returned user outside transaction
@RestController
public class UserController {
    
    @Autowired
    private UserService userService;
    
    @GetMapping("/users/{id}")
    public User getUser(@PathVariable Long id) {
        User user = userService.getUserWithOrders(id);
        // Transaction closed here
        
        user.getOrders().size();  // LazyInitializationException!
        // Orders are lazy, but transaction is closed
        
        return user;
    }
}
```

## 8.2 Solutions to LazyInitializationException

```java
// Solution 1: JOIN FETCH in query
@Service
@Transactional(readOnly = true)
public class UserService {
    
    @PersistenceContext
    private EntityManager em;
    
    public User getUserWithOrders(Long id) {
        return em.createQuery(
            "SELECT u FROM User u LEFT JOIN FETCH u.orders WHERE u.id = :id",
            User.class)
            .setParameter("id", id)
            .getSingleResult();
        // Single query with JOIN, orders loaded eagerly
        // Can access orders outside transaction
    }
}

// Solution 2: Hibernate.initialize()
import org.hibernate.Hibernate;

@Service
@Transactional
public class UserService {
    
    @PersistenceContext
    private EntityManager em;
    
    public User getUserWithOrders(Long id) {
        User user = em.find(User.class, id);
        Hibernate.initialize(user.getOrders());  // Force loading
        return user;
    }
}

// Solution 3: DTOs (preferred for APIs)
public class UserDTO {
    private Long id;
    private String name;
    private List<OrderDTO> orders;
    
    public static UserDTO from(User user) {
        UserDTO dto = new UserDTO();
        dto.setId(user.getId());
        dto.setName(user.getName());
        dto.setOrders(user.getOrders().stream()
            .map(OrderDTO::from)
            .collect(Collectors.toList()));
        return dto;
    }
}

@Service
@Transactional(readOnly = true)
public class UserService {
    
    public UserDTO getUserDTO(Long id) {
        User user = em.find(User.class, id);
        return UserDTO.from(user);  // Converted within transaction
        // DTO can be safely returned outside transaction
    }
}

// Solution 4: @Transactional on Controller (anti-pattern, avoid!)
@RestController
@Transactional  // Opens transaction for entire request
public class UserController {
    
    @GetMapping("/users/{id}")
    public User getUser(@PathVariable Long id) {
        User user = userService.getUser(id);
        user.getOrders().size();  // OK, but bad practice
        return user;
    }
}
// Problem: Long-running transactions, database connections held too long

// Solution 5: Open EntityManager in View (Spring)
// spring.jpa.open-in-view=true (default in Spring Boot)
// Keeps EntityManager open until view rendered
// ⚠️ Anti-pattern: Hides performance issues, avoid in production
```

# 9. N+1 QUERY PROBLEM & SOLUTIONS

## 9.1 Understanding N+1 Problem

```java
/**
 * N+1 Problem:
 * 1 query to fetch parent entities
 * + N queries to fetch each parent's child entities
 * = N+1 queries total
 * 
 * Example: Fetch 100 users with their departments
 * - 1 query for users
 * - 100 queries for departments (one per user)
 * =  101 queries! (performance disaster)
 */

@Entity
public class User {
    @Id
    private Long id;
    private String name;
    
    @ManyToOne(fetch = FetchType.LAZY)  // Even LAZY causes N+1!
    private Department department;
}

@Service
@Transactional(readOnly = true)
public class UserService {
    
    @PersistenceContext
    private EntityManager em;
    
    // PROBLEM: N+1 queries
    public List<UserDTO> getAllUsersWithDepartments() {
        List<User> users = em.createQuery("SELECT u FROM User u", User.class)
                             .getResultList();
        // Query 1: SELECT * FROM users
        
        List<UserDTO> dtos = new ArrayList<>();
        for (User user : users) {
            UserDTO dto = new UserDTO();
            dto.setName(user.getName());
            dto.setDepartmentName(user.getDepartment().getName());
            // Query 2-N: SELECT * FROM departments WHERE id = ?
            // Executed for EACH user!
            dtos.add(dto);
        }
        
        return dtos;
    }
}
```

## 9.2 Solution 1: JOIN FETCH

```java
// Solution: JOIN FETCH (best for small collections)
@Service
@Transactional(readOnly = true)
public class UserService {
    
    @PersistenceContext
    private EntityManager em;
    
    public List<User> getAllUsersWithDepartments() {
        return em.createQuery(
            "SELECT u FROM User u LEFT JOIN FETCH u.department",
            User.class)
            .getResultList();
        // Single query with JOIN!
        // SELECT u.*, d.* FROM users u LEFT JOIN departments d ON u.department_id = d.id
    }
    
    // Multiple JOIN FETCH
    public List<User> getUsersWithDepartmentAndOrders() {
        return em.createQuery(
            "SELECT DISTINCT u FROM User u " +
            "LEFT JOIN FETCH u.department " +
            "LEFT JOIN FETCH u.orders",
            User.class)
            .getResultList();
        // DISTINCT required to avoid duplicate users (Cartesian product)
    }
    
    // ⚠️ WARNING: Cannot JOIN FETCH multiple collections!
    public List<User> badExample() {
        return em.createQuery(
            "SELECT u FROM User u " +
            "LEFT JOIN FETCH u.orders " +
            "LEFT JOIN FETCH u.roles",  // ERROR!
            User.class)
            .getResultList();
        // MultipleBagFetchException:
        // cannot simultaneously fetch multiple bags
    }
}
```

## 9.3 Solution 2: @EntityGraph

```java
@Entity
@NamedEntityGraph(
    name = "User.withDepartment",
    attributeNodes = @NamedAttributeNode("department")
)
@NamedEntityGraph(
    name = "User.withDepartmentAndOrders",
    attributeNodes = {
        @NamedAttributeNode("department"),
        @NamedAttributeNode("orders")
    }
)
public class User {
    @Id
    private Long id;
    private String name;
    
    @ManyToOne(fetch = FetchType.LAZY)
    private Department department;
    
    @OneToMany(mappedBy = "user", fetch = FetchType.LAZY)
    private List<Order> orders;
}

@Service
@Transactional(readOnly = true)
public class UserService {
    
    @PersistenceContext
    private EntityManager em;
    
    public List<User> getAllWithEntityGraph() {
        return em.createQuery("SELECT u FROM User u", User.class)
                 .setHint("javax.persistence.fetchgraph", 
                         em.getEntityGraph("User.withDepartment"))
                 .getResultList();
        // Single query with JOIN
    }
}

// Spring Data JPA with @EntityGraph
@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    
    @EntityGraph(attributePaths = {"department", "orders"})
    List<User> findAll();
    
    @EntityGraph(value = "User.withDepartmentAndOrders")
    List<User> findByNameLike(String name);
}
```

## 9.4 Solution 3: Batch Fetching

```java
// Hibernate batch fetching
@Entity
public class User {
    @Id
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @BatchSize(size = 25)  // Load 25 departments at once
    private Department department;
}

// In application.properties:
// spring.jpa.properties.hibernate.default_batch_fetch_size=25

// How it works:
// Instead of N queries:
//   SELECT * FROM departments WHERE id = 1
//   SELECT * FROM departments WHERE id = 2
//   ...
// Batches into fewer queries:
//   SELECT * FROM departments WHERE id IN (1, 2, 3, ..., 25)
//   SELECT * FROM departments WHERE id IN (26, 27, 28, ..., 50)
```

## 9.5 Solution 4: Projection/DTO

```java
// Best solution: Don't load entities at all
@Service
@Transactional(readOnly = true)
public class UserService {
    
    @PersistenceContext
    private EntityManager em;
    
    // DTO projection in JPQL
    public List<UserDTO> getUsersWithDepartment() {
        return em.createQuery(
            "SELECT new com.example.dto.UserDTO(u.id, u.name, d.name) " +
            "FROM User u LEFT JOIN u.department d",
            UserDTO.class)
            .getResultList();
        // Single efficient query, only selected columns
        // No entity objects created, no lazy loading issues
    }
}

public class UserDTO {
    private Long id;
    private String name;
    private String departmentName;
    
    public UserDTO(Long id, String name, String departmentName) {
        this.id = id;
        this.name = name;
        this.departmentName = departmentName;
    }
    
    // Getters
}
```

---

# 10. TRANSACTION MANAGEMENT

## 10.1 Spring @Transactional

```java
/**
 * @Transactional:
 * - Opens database transaction
 * - Commits on success
 * - Rolls back on RuntimeException
 * - Transaction boundaries = method boundaries
 */

@Service
public class BankService {
    
    @Autowired
    private AccountRepository accountRepository;
    
    // Declarative transaction
    @Transactional
    public void transferMoney(Long fromId, Long toId, BigDecimal amount) {
        Account from = accountRepository.findById(fromId).orElseThrow();
        Account to = accountRepository.findById(toId).orElseThrow();
        
        from.setBalance(from.getBalance().subtract(amount));
        to.setBalance(to.getBalance().add(amount));
        
        accountRepository.save(from);
        accountRepository.save(to);
        
        // If exception thrown here, both saves rolled back
    }
    
    // Read-only transaction (optimization)
    @Transactional(readOnly = true)
    public List<Account> getAllAccounts() {
        return accountRepository.findAll();
        // Hibernate disables dirty checking
        // Faster for read-only operations
    }
    
    // Timeout
    @Transactional(timeout = 5)  // 5 seconds
    public void longRunningOperation() {
        // Rolls back if exceeds 5 seconds
    }
    
    // Isolation level
    @Transactional(isolation = Isolation.SERIALIZABLE)
    public void criticalOperation() {
        // Highest isolation (slowest)
    }
    
    // Propagation
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void independentTransaction() {
        // Always creates new transaction
        // Even if called from another @Transactional method
    }
    
    // Rollback rules
    @Transactional(rollbackFor = Exception.class)
    public void rollbackOnChecked() {
        // Rolls back on checked exceptions too
    }
    
    @Transactional(noRollbackFor = CustomException.class)
    public void noRollbackForCustom() {
        // Doesn't rollback for CustomException
    }
}
```

## 10.2 Transaction Propagation

```java
@Service
public class OrderService {
    
    @Autowired
    private InventoryService inventoryService;
    
    // REQUIRED (default): Join existing transaction or create new
    @Transactional(propagation = Propagation.REQUIRED)
    public void placeOrder() {
        // If called without transaction: creates new
        // If called within transaction: joins existing
        
        inventoryService.updateInventory();  // Joins this transaction
    }
    
    // REQUIRES_NEW: Always create new transaction (suspend current)
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void auditLog() {
        // Always new transaction
        // Commits independently (even if parent rolls back)
    }
    
    // Example usage:
    @Transactional
    public void processOrder() {
        // Transaction 1 starts
        placeOrder();  // Joins Transaction 1
        
        auditLog();  // Transaction 2 (new, independent)
        
        if (error) {
            throw new RuntimeException();
            // Transaction 1 rolls back (placeOrder rolled back)
            // Transaction 2 NOT rolled back (auditLog committed)
        }
    }
    
    // NESTED: Create savepoint (partial rollback)
    @Transactional(propagation = Propagation.NESTED)
    public void nestedOperation() {
        // Creates savepoint in existing transaction
        // Can rollback to savepoint without affecting parent
    }
    
    // MANDATORY: Must be called within transaction
    @Transactional(propagation = Propagation.MANDATORY)
    public void mustBeInTransaction() {
        // Throws exception if no active transaction
    }
    
    // NEVER: Must NOT be called within transaction
    @Transactional(propagation = Propagation.NEVER)
    public void noTransaction() {
        // Throws exception if called within transaction
    }
    
    // NOT_SUPPORTED: Suspend current transaction
    @Transactional(propagation = Propagation.NOT_SUPPORTED)
    public void suspendTransaction() {
        // Runs without transaction (suspends if exists)
    }
}
```

## 10.3 Programmatic Transaction Management

```java
@Service
public class PaymentService {
    
    @Autowired
    private PlatformTransactionManager transactionManager;
    
    // Programmatic transaction with TransactionTemplate
    @Autowired
    private TransactionTemplate transactionTemplate;
    
    public void processPaymentTemplate() {
        transactionTemplate.execute(status -> {
            try {
                // Transaction code here
                Account account = accountRepository.findById(1L).get();
                account.debit(100);
                accountRepository.save(account);
                
                return null;  // Success
            } catch (Exception e) {
                status.setRollbackOnly();  // Mark for rollback
                throw e;
            }
        });
    }
    
    // Manual transaction management
    public void processPaymentManual() {
        TransactionDefinition def = new DefaultTransactionDefinition();
        TransactionStatus status = transactionManager.getTransaction(def);
        
        try {
            // Transaction code
            Account account = accountRepository.findById(1L).get();
            account.debit(100);
            accountRepository.save(account);
            
            transactionManager.commit(status);  // Commit
        } catch (Exception e) {
            transactionManager.rollback(status);  // Rollback
            throw e;
        }
    }
}
```

---

# 11. CONNECTION POOLING

## 11.1 Why Connection Pooling?

```java
/**
 * Without Connection Pool:
 * - Create new connection for each request
 * - Close connection after request
 * - Expensive: TCP handshake, authentication, etc.
 * 
 * With Connection Pool:
 * - Pre-create connections at startup
 * - Reuse connections across requests
 * - Much faster (no connection overhead)
 */

// Spring Boot auto-configures HikariCP (best performance)
```

## 11.2 HikariCP Configuration

```yaml
# application.yml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/mydb
    username: root
    password: secret
    driver-class-name: com.mysql.cj.jdbc.Driver
    
    hikari:
      # Pool size
      minimum-idle: 5                    # Minimum connections
      maximum-pool-size: 20              # Maximum connections
      
      # Connection timeout
      connection-timeout: 30000          # 30 seconds
      idle-timeout: 600000               # 10 minutes
      max-lifetime: 1800000              # 30 minutes
      
      # Connection testing
      connection-test-query: SELECT 1    # Validate connection
      
      # Leak detection
      leak-detection-threshold: 60000    # 60 seconds
      
      # Pool name
      pool-name: MyHikariPool
      
      # Auto-commit
      auto-commit: true
```

```java
// Programmatic configuration
@Configuration
public class DataSourceConfig {
    
    @Bean
    public DataSource dataSource() {
        HikariConfig config = new HikariConfig();
        config.setJdbcUrl("jdbc:mysql://localhost:3306/mydb");
        config.setUsername("root");
        config.setPassword("secret");
        config.setDriverClassName("com.mysql.cj.jdbc.Driver");
        
        config.setMinimumIdle(5);
        config.setMaximumPoolSize(20);
        config.setConnectionTimeout(30000);
        config.setIdleTimeout(600000);
        config.setMaxLifetime(1800000);
        
        return new HikariDataSource(config);
    }
}
```

## 11.3 Monitoring Connection Pool

```java
@RestController
@RequestMapping("/admin/datasource")
public class DataSourceController {
    
    @Autowired
    private DataSource dataSource;
    
    @GetMapping("/stats")
    public Map<String, Object> getStats() {
        if (dataSource instanceof HikariDataSource) {
            HikariDataSource hikari = (HikariDataSource) dataSource;
            HikariPoolMXBean pool = hikari.getHikariPoolMXBean();
            
            Map<String, Object> stats = new HashMap<>();
            stats.put("activeConnections", pool.getActiveConnections());
            stats.put("idleConnections", pool.getIdleConnections());
            stats.put("totalConnections", pool.getTotalConnections());
            stats.put("threadsAwaitingConnection", pool.getThreadsAwaitingConnection());
            
            return stats;
        }
        
        return Collections.emptyMap();
    }
}
```

---

# 12. QUERY OPTIMIZATION TECHNIQUES

## 12.1 Pagination

```java
@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    
    // Pagination with Pageable
    Page<User> findByActive(boolean active, Pageable pageable);
}

@Service
@Transactional(readOnly = true)
public class UserService {
    
    @Autowired
    private UserRepository userRepository;
    
    public Page<User> getUsers(int page, int size) {
        Pageable pageable = PageRequest.of(page, size, Sort.by("name").ascending());
        return userRepository.findByActive(true, pageable);
        // SQL: SELECT * FROM users WHERE active = true ORDER BY name LIMIT 10 OFFSET 0
    }
}
```

## 12.2 Projections (Select Only Needed Columns)

```java
// Interface-based projection
public interface UserSummary {
    Long getId();
    String getName();
    String getEmail();
}

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    
    List<UserSummary> findAllBy();
    // SELECT id, name, email FROM users (not all columns!)
}

// Class-based projection (DTO)
public class UserDTO {
    private Long id;
    private String name;
    
    // Constructor matching query
    public UserDTO(Long id, String name) {
        this.id = id;
        this.name = name;
    }
}

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    
    @Query("SELECT new com.example.dto.UserDTO(u.id, u.name) FROM User u")
    List<UserDTO> findAllDTOs();
}
```

## 12.3 Batch Operations

```java
@Service
@Transactional
public class UserService {
    
    @PersistenceContext
    private EntityManager em;
    
    // Batch insert (efficient)
    public void createUsers(List<User> users) {
        int batchSize = 25;
        
        for (int i = 0; i < users.size(); i++) {
            em.persist(users.get(i));
            
            if (i > 0 && i % batchSize == 0) {
                em.flush();  // Flush batch
                em.clear();  // Clear persistence context
            }
        }
        
        em.flush();
        em.clear();
    }
    
    // Batch update with JPQL (most efficient)
    public int updateUserStatus(List<Long> userIds, String status) {
        return em.createQuery(
            "UPDATE User u SET u.status = :status WHERE u.id IN :ids")
            .setParameter("status", status)
            .setParameter("ids", userIds)
            .executeUpdate();
        // Single UPDATE statement!
    }
}

// Configure batch size in application.properties
// spring.jpa.properties.hibernate.jdbc.batch_size=25
// spring.jpa.properties.hibernate.order_inserts=true
// spring.jpa.properties.hibernate.order_updates=true
```

---

# 13. SPRING DATA JPA

## 13.1 Repository Interfaces

```java
// Basic CRUD operations
@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    // Inherited methods:
    // save(), findById(), findAll(), delete(), count(), exists(), etc.
}

@Service
public class UserService {
    
    @Autowired
    private UserRepository userRepository;
    
    public void demonstrateRepositoryMethods() {
        // Save
        User user = new User("John", "john@example.com");
        userRepository.save(user);
        
        // Find by ID
        Optional<User> found = userRepository.findById(1L);
        
        // Find all
        List<User> all = userRepository.findAll();
        
        // Count
        long count = userRepository.count();
        
        // Exists
        boolean exists = userRepository.existsById(1L);
        
        // Delete
        userRepository.deleteById(1L);
    }
}
```

## 13.2 Query Methods (Derived Queries)

```java
@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    
    // Find by single field
    List<User> findByName(String name);
    // SELECT * FROM users WHERE name = ?
    
    // Find by multiple fields
    List<User> findByNameAndEmail(String name, String email);
    // SELECT * FROM users WHERE name = ? AND email = ?
    
    // LIKE query
    List<User> findByNameContaining(String keyword);
    // SELECT * FROM users WHERE name LIKE %keyword%
    
    List<User> findByNameStartingWith(String prefix);
    List<User> findByNameEndingWith(String suffix);
    
    // Comparison
    List<User> findByAgeGreaterThan(Integer age);
    List<User> findByAgeLessThanEqual(Integer age);
    List<User> findByAgeBetween(Integer start, Integer end);
    
    // IN clause
    List<User> findByNameIn(List<String> names);
    
    // Null check
    List<User> findByEmailIsNull();
    List<User> findByEmailIsNotNull();
    
    // Boolean
    List<User> findByActiveTrue();
    List<User> findByActiveFalse();
    
    // Sorting
    List<User> findByNameOrderByAgeDesc(String name);
    
    // Limiting results
    List<User> findTop10ByActive(boolean active);
    List<User> findFirst5ByOrderByAgeDesc();
    
    // Distinct
    List<User> findDistinctByName(String name);
    
    // Ignoring case
    List<User> findByNameIgnoreCase(String name);
    List<User> findByNameAndEmailAllIgnoreCase(String name, String email);
    
    // Exists
    boolean existsByEmail(String email);
    
    // Count
    long countByActive(boolean active);
    
    // Delete
    void deleteByActive(boolean active);
    
    // Complex query
    List<User> findByNameContainingAndAgeGreaterThanAndActiveTrue(
        String name, Integer age);
}
```

## 13.3 @Query Annotation

```java
@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    
    // JPQL query
    @Query("SELECT u FROM User u WHERE u.name = :name")
    List<User> findByNameCustom(@Param("name") String name);
    
    // Native query
    @Query(value = "SELECT * FROM users WHERE name = ?1", nativeQuery = true)
    List<User> findByNameNative(String name);
    
    // Join query
    @Query("SELECT u FROM User u JOIN u.department d WHERE d.name = :deptName")
    List<User> findByDepartmentName(@Param("deptName") String deptName);
    
    // Projection
    @Query("SELECT new com.example.dto.UserDTO(u.id, u.name) FROM User u")
    List<UserDTO> findAllDTOs();
    
    // Update query
    @Modifying
    @Query("UPDATE User u SET u.active = :active WHERE u.id = :id")
    int updateUserActive(@Param("id") Long id, @Param("active") boolean active);
    
    // Delete query
    @Modifying
    @Query("DELETE FROM User u WHERE u.lastLogin < :date")
    int deleteInactiveUsers(@Param("date") LocalDate date);
}

@Service
@Transactional
public class UserService {
    
    @Autowired
    private UserRepository userRepository;
    
    public void updateUser(Long id) {
        int updated = userRepository.updateUserActive(id, true);
        System.out.println("Updated " + updated + " users");
    }
}
```

---

# 14. INTERVIEW QUESTIONS WITH ANSWERS

## Q1: Explain the difference between JPA and Hibernate.

**Answer:**

| Aspect | JPA | Hibernate |
|--------|-----|-----------|
| **Type** | Specification (API) | Implementation |
| **Package** | javax.persistence.* | org.hibernate.* |
| **Portability** | Can switch implementations | Tied to Hibernate |
| **Features** | Standard only | Extra features |
| **Annotations** | @Entity, @Id, @OneToMany | @Formula, @Type, @Cache |

**Best Practice:** Use JPA annotations for maximum portability. Use Hibernate-specific features only when absolutely necessary.

---

## Q2: What causes LazyInitializationException and how do you fix it?

**Answer:**

**Cause:** Accessing lazy-loaded entity/collection outside active transaction/EntityManager.

```java
// Problem:
@Transactional
public User getUser(Long id) {
    return userRepository.findById(id).get();
}  // Transaction closes here

public void use() {
    User user = service.getUser(1L);
    user.getOrders().size();  // LazyInitializationException!
}
```

**Solutions:**

1. **JOIN FETCH** (Best):
```java
@Query("SELECT u FROM User u LEFT JOIN FETCH u.orders WHERE u.id = :id")
```

2. **DTOs**:
```java
return UserDTO.from(user);  // Convert within transaction
```

3. **Hibernate.initialize()**:
```java
Hibernate.initialize(user.getOrders());
```

4. **@EntityGraph**:
```java
@EntityGraph(attributePaths = "orders")
```

---

## Q3: Explain the N+1 query problem.

**Answer:**

**Problem:** 1 query for parent + N queries for each child = N+1 total queries.

```java
List<User> users = em.createQuery("SELECT u FROM User u").getResultList();
// 1 query

for (User user : users) {
    System.out.println(user.getDepartment().getName());
    // N queries (one per user!)
}
```

**Solution:** JOIN FETCH

```java
List<User> users = em.createQuery(
    "SELECT u FROM User u LEFT JOIN FETCH u.department"
).getResultList();
// Single query with JOIN
```

---

## Q4: What is the difference between persist() and merge()?

**Answer:**

| Operation | persist() | merge() |
|-----------|-----------|---------|
| **State** | NEW → MANAGED | DETACHED → MANAGED |
| **Returns** | void | Managed entity |
| **ID** | Must be null | Can have ID |
| **Use Case** | New entities | Update entities |

```java
// persist()
User newUser = new User();
em.persist(newUser);
// newUser is now MANAGED

// merge()
User detached = new User();
detached.setId(1L);
detached.setName("Updated");
User managed = em.merge(detached);
// detached still DETACHED
// managed is MANAGED (returned entity)
```

---

## Q5: How do you optimize Hibernate performance?

**Answer:**

1. **Enable Second-Level Cache**
```java
@Entity
@Cacheable
@Cache(usage = CacheConcurrencyStrategy.READ_WRITE)
public class Product { }
```

2. **Use Batch Fetching**
```properties
spring.jpa.properties.hibernate.default_batch_fetch_size=25
```

3. **Use JOIN FETCH/EntityGraph**
```java
@Query("SELECT u FROM User u LEFT JOIN FETCH u.department")
```

4. **Use Projections/DTOs**
```java
@Query("SELECT new UserDTO(u.id, u.name) FROM User u")
```

5. **Enable Batch Inserts/Updates**
```properties
spring.jpa.properties.hibernate.jdbc.batch_size=25
spring.jpa.properties.hibernate.order_inserts=true
```

6. **Use Read-Only Transactions**
```java
@Transactional(readOnly = true)
```

7. **Lazy Loading** (default for collections)
```java
@OneToMany(fetch = FetchType.LAZY)
```

---

# 15. INTERVIEW TRAPS & EDGE CASES

## Trap 1: Modifying Detached Entities

❌ **Wrong:**
```java
User user = em.find(User.class, 1L);
em.detach(user);
user.setName("Changed");
// Change NOT persisted!
```

✅ **Right:**
```java
User user = em.find(User.class, 1L);
em.detach(user);
user.setName("Changed");
user = em.merge(user);  // Re-attach first
```

---

## Trap 2: equals() and hashCode() with JPA

❌ **Wrong:**
```java
@Entity
public class User {
    @Id
    @GeneratedValue
    private Long id;
    
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        User user = (User) o;
        return Objects.equals(id, user.id);  // PROBLEM: id is null before persist!
    }
}
```

✅ **Right:**
```java
@Entity
public class User {
    @Id
    @GeneratedValue
    private Long id;
    
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof User)) return false;
        User user = (User) o;
        return id != null && Objects.equals(id, user.id);
    }
    
    @Override
    public int hashCode() {
        return getClass().hashCode();  // Constant hash code
    }
}
```

---

## Trap 3: Bidirectional Relationship Synchronization

❌ **Wrong:**
```java
Order order = new Order();
OrderItem item = new OrderItem();
order.getItems().add(item);  // Only one side set!
em.persist(order);
// item.order is NULL in database!
```

✅ **Right:**
```java
@Entity
public class Order {
    @OneToMany(mappedBy = "order", cascade = CascadeType.ALL)
    private List<OrderItem> items = new ArrayList<>();
    
    public void addItem(OrderItem item) {
        items.add(item);
        item.setOrder(this);  // Set both sides!
    }
}
```

---

# 16. CODING PROBLEMS WITH SOLUTIONS

## Problem 1: Implement Audit Fields

**Problem:** Add createdAt, updatedAt, createdBy, updatedBy to all entities.

**Solution:**

```java
@MappedSuperclass
@EntityListeners(AuditingEntityListener.class)
public abstract class AuditableEntity {
    
    @CreatedDate
    @Column(updatable = false)
    private LocalDateTime createdAt;
    
    @LastModifiedDate
    private LocalDateTime updatedAt;
    
    @CreatedBy
    @Column(updatable = false)
    private String createdBy;
    
    @LastModifiedBy
    private String updatedBy;
    
    // Getters and setters
}

@Entity
public class User extends AuditableEntity {
    @Id
    private Long id;
    private String name;
    // createdAt, updatedAt, createdBy, updatedBy inherited
}

@Configuration
@EnableJpaAuditing
public class JpaConfig {
    
    @Bean
    public AuditorAware<String> auditorProvider() {
        return () -> {
            // Get current user from security context
            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            if (auth != null) {
                return Optional.of(auth.getName());
            }
            return Optional.of("system");
        };
    }
}
```

---

## Problem 2: Implement Soft Delete

**Problem:** Don't actually delete records, mark them as deleted.

**Solution:**

```java
@MappedSuperclass
public abstract class SoftDeletableEntity {
    
    @Column(name = "deleted")
    private boolean deleted = false;
    
    @Column(name = "deleted_at")
    private LocalDateTime deletedAt;
    
    public void softDelete() {
        this.deleted = true;
        this.deletedAt = LocalDateTime.now();
    }
    
    // Getters and setters
}

@Entity
@SQLDelete(sql = "UPDATE users SET deleted = true, deleted_at = NOW() WHERE id = ?")
@Where(clause = "deleted = false")  // Automatic filter
public class User extends SoftDeletableEntity {
    @Id
    private Long id;
    private String name;
}

// Repository
@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    
    // Finds only non-deleted (automatic)
    List<User> findAll();
    
    // Find deleted users
    @Query("SELECT u FROM User u WHERE u.deleted = true")
    List<User> findDeleted();
    
    // Permanent delete
    @Modifying
    @Query("DELETE FROM User u WHERE u.id = :id")
    void permanentDelete(@Param("id") Long id);
}
```

---

# 17. SUMMARY & QUICK REFERENCE

## JPA Annotations

```java
@Entity                 // Mark as entity
@Table(name = "users")  // Table mapping
@Id                     // Primary key
@GeneratedValue         // Auto-generate ID
@Column                 // Column mapping
@Transient              // Exclude from persistence

// Relationships
@OneToOne
@OneToMany
@ManyToOne
@ManyToMany
@JoinColumn
@JoinTable

// Fetching
FetchType.LAZY          // Load on demand
FetchType.EAGER         // Load immediately

// Cascade
CascadeType.PERSIST     // Cascade persist
CascadeType.REMOVE      // Cascade delete
CascadeType.ALL         // Cascade all

// Lifecycle
@PrePersist
@PostPersist
@PreUpdate
@PostUpdate
@PreRemove
@PostRemove
```

## Performance Tips

```
1. Use LAZY loading for associations
2. JOIN FETCH to avoid N+1
3. Use projections/DTOs
4. Enable second-level cache
5. Use batch fetching
6. Enable batch inserts/updates
7. Use readOnly transactions
8. Paginate large result sets
9. Use native queries for complex operations
10. Monitor SQL with show_sql=true
```

---

**END OF DATABASE & JPA/HIBERNATE INTERVIEW GUIDE**

This comprehensive guide covers JDBC, JPA, Hibernate internals, relationships, caching, lazy loading, N+1 problem, transactions, optimization, and Spring Data JPA. Master these concepts for backend developer interviews!

**Next Guide:** Design Patterns (Topic 3 of 5)