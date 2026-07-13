# Java Database Connectivity (JDBC)

## JDBC Overview

JDBC enables Java applications to interact with databases.

```
Java Application
    ↓
JDBC API (java.sql.*)
    ↓
JDBC Driver (database-specific)
    ↓
Database (MySQL, PostgreSQL, Oracle, etc.)
```

## Setup

### Maven Dependencies

```xml
<!-- MySQL -->
<dependency>
    <groupId>com.mysql</groupId>
    <artifactId>mysql-connector-j</artifactId>
    <version>8.2.0</version>
</dependency>

<!-- PostgreSQL -->
<dependency>
    <groupId>org.postgresql</groupId>
    <artifactId>postgresql</artifactId>
    <version>42.7.0</version>
</dependency>

<!-- H2 (in-memory database) -->
<dependency>
    <groupId>com.h2database</groupId>
    <artifactId>h2</artifactId>
    <version>2.2.224</version>
</dependency>

<!-- HikariCP (connection pooling) -->
<dependency>
    <groupId>com.zaxxer</groupId>
    <artifactId>HikariCP</artifactId>
    <version>5.1.0</version>
</dependency>
```

## Basic JDBC Operations

### Connecting to Database

```java
import java.sql.*;

public class DatabaseConnection {
    // JDBC URL format: jdbc:mysql://host:port/database
    private static final String URL = "jdbc:mysql://localhost:3306/mydb";
    private static final String USER = "root";
    private static final String PASSWORD = "password";
    
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
    
    public static void main(String[] args) {
        try (Connection conn = getConnection()) {
            System.out.println("Connected to database!");
            System.out.println("Database: " + conn.getCatalog());
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
```

### Create Table

```java
public class CreateTable {
    public static void main(String[] args) {
        String createTableSQL = """
            CREATE TABLE IF NOT EXISTS users (
                id INT PRIMARY KEY AUTO_INCREMENT,
                name VARCHAR(100) NOT NULL,
                email VARCHAR(100) UNIQUE NOT NULL,
                age INT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
            """;
        
        try (Connection conn = DatabaseConnection.getConnection();
             Statement stmt = conn.createStatement()) {
            
            stmt.executeUpdate(createTableSQL);
            System.out.println("Table created successfully!");
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
```

### Insert Data

```java
public class InsertData {
    // Using Statement (not recommended - SQL injection risk)
    public static void insertUnsafe(String name, String email, int age) {
        String sql = "INSERT INTO users (name, email, age) VALUES " +
                     "('" + name + "', '" + email + "', " + age + ")";
        
        try (Connection conn = DatabaseConnection.getConnection();
             Statement stmt = conn.createStatement()) {
            
            int rows = stmt.executeUpdate(sql);
            System.out.println(rows + " row(s) inserted");
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    
    // Using PreparedStatement (recommended - prevents SQL injection)
    public static void insertSafe(String name, String email, int age) {
        String sql = "INSERT INTO users (name, email, age) VALUES (?, ?, ?)";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, name);
            pstmt.setString(2, email);
            pstmt.setInt(3, age);
            
            int rows = pstmt.executeUpdate();
            System.out.println(rows + " row(s) inserted");
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    
    // Get auto-generated ID
    public static long insertAndReturnId(String name, String email, int age) {
        String sql = "INSERT INTO users (name, email, age) VALUES (?, ?, ?)";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, 
                 Statement.RETURN_GENERATED_KEYS)) {
            
            pstmt.setString(1, name);
            pstmt.setString(2, email);
            pstmt.setInt(3, age);
            
            int rows = pstmt.executeUpdate();
            
            if (rows > 0) {
                try (ResultSet rs = pstmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getLong(1);
                    }
                }
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return -1;
    }
    
    public static void main(String[] args) {
        insertSafe("Alice", "alice@email.com", 25);
        insertSafe("Bob", "bob@email.com", 30);
        
        long id = insertAndReturnId("Charlie", "charlie@email.com", 28);
        System.out.println("Inserted user with ID: " + id);
    }
}
```

### Select Data

```java
public class SelectData {
    public static void selectAll() {
        String sql = "SELECT * FROM users";
        
        try (Connection conn = DatabaseConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                int id = rs.getInt("id");
                String name = rs.getString("name");
                String email = rs.getString("email");
                int age = rs.getInt("age");
                Timestamp created = rs.getTimestamp("created_at");
                
                System.out.printf("ID: %d, Name: %s, Email: %s, Age: %d, Created: %s%n",
                    id, name, email, age, created);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    
    public static User findById(int id) {
        String sql = "SELECT * FROM users WHERE id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, id);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return new User(
                        rs.getInt("id"),
                        rs.getString("name"),
                        rs.getString("email"),
                        rs.getInt("age")
                    );
                }
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return null;
    }
    
    public static List<User> findByAge(int minAge) {
        List<User> users = new ArrayList<>();
        String sql = "SELECT * FROM users WHERE age >= ? ORDER BY age";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, minAge);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    users.add(new User(
                        rs.getInt("id"),
                        rs.getString("name"),
                        rs.getString("email"),
                        rs.getInt("age")
                    ));
                }
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return users;
    }
}
```

### Update Data

```java
public class UpdateData {
    public static int updateUser(int id, String name, String email, int age) {
        String sql = "UPDATE users SET name = ?, email = ?, age = ? WHERE id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, name);
            pstmt.setString(2, email);
            pstmt.setInt(3, age);
            pstmt.setInt(4, id);
            
            int rows = pstmt.executeUpdate();
            System.out.println(rows + " row(s) updated");
            return rows;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }
    
    public static int updateAge(int id, int newAge) {
        String sql = "UPDATE users SET age = ? WHERE id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, newAge);
            pstmt.setInt(2, id);
            
            return pstmt.executeUpdate();
            
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }
}
```

### Delete Data

```java
public class DeleteData {
    public static int deleteUser(int id) {
        String sql = "DELETE FROM users WHERE id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, id);
            
            int rows = pstmt.executeUpdate();
            System.out.println(rows + " row(s) deleted");
            return rows;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }
    
    public static int deleteOldUsers(int maxAge) {
        String sql = "DELETE FROM users WHERE age > ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, maxAge);
            return pstmt.executeUpdate();
            
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }
}
```

## Transactions

### Manual Transaction Management

```java
public class TransactionExample {
    public static void transferMoney(int fromUserId, int toUserId, double amount) {
        Connection conn = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false);  // Start transaction
            
            // Deduct from sender
            String deductSQL = "UPDATE accounts SET balance = balance - ? WHERE user_id = ?";
            try (PreparedStatement pstmt = conn.prepareStatement(deductSQL)) {
                pstmt.setDouble(1, amount);
                pstmt.setInt(2, fromUserId);
                pstmt.executeUpdate();
            }
            
            // Add to receiver
            String addSQL = "UPDATE accounts SET balance = balance + ? WHERE user_id = ?";
            try (PreparedStatement pstmt = conn.prepareStatement(addSQL)) {
                pstmt.setDouble(1, amount);
                pstmt.setInt(2, toUserId);
                pstmt.executeUpdate();
            }
            
            conn.commit();  // Commit transaction
            System.out.println("Transfer successful!");
            
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();  // Rollback on error
                    System.out.println("Transaction rolled back");
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);  // Restore auto-commit
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }
}
```

### Savepoints

```java
public class SavepointExample {
    public static void processWithSavepoints() {
        try (Connection conn = DatabaseConnection.getConnection()) {
            conn.setAutoCommit(false);
            
            // First operation
            executeUpdate(conn, "INSERT INTO users (name, email, age) VALUES ('User1', 'user1@email.com', 25)");
            
            Savepoint savepoint1 = conn.setSavepoint("Savepoint1");
            
            // Second operation
            executeUpdate(conn, "INSERT INTO users (name, email, age) VALUES ('User2', 'user2@email.com', 30)");
            
            try {
                // Risky operation
                executeUpdate(conn, "INSERT INTO users (name, email, age) VALUES ('User3', 'invalid', 35)");
            } catch (SQLException e) {
                // Rollback to savepoint
                conn.rollback(savepoint1);
                System.out.println("Rolled back to savepoint");
            }
            
            conn.commit();
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    
    private static void executeUpdate(Connection conn, String sql) throws SQLException {
        try (Statement stmt = conn.createStatement()) {
            stmt.executeUpdate(sql);
        }
    }
}
```

## Batch Processing

```java
public class BatchProcessing {
    public static void insertBatch(List<User> users) {
        String sql = "INSERT INTO users (name, email, age) VALUES (?, ?, ?)";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            conn.setAutoCommit(false);
            
            for (User user : users) {
                pstmt.setString(1, user.getName());
                pstmt.setString(2, user.getEmail());
                pstmt.setInt(3, user.getAge());
                pstmt.addBatch();
            }
            
            int[] results = pstmt.executeBatch();
            conn.commit();
            
            System.out.println("Inserted " + results.length + " records");
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    
    public static void main(String[] args) {
        List<User> users = Arrays.asList(
            new User(0, "User1", "user1@email.com", 25),
            new User(0, "User2", "user2@email.com", 30),
            new User(0, "User3", "user3@email.com", 35)
        );
        
        insertBatch(users);
    }
}
```

## Connection Pooling with HikariCP

```java
import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

public class ConnectionPool {
    private static HikariDataSource dataSource;
    
    static {
        HikariConfig config = new HikariConfig();
        config.setJdbcUrl("jdbc:mysql://localhost:3306/mydb");
        config.setUsername("root");
        config.setPassword("password");
        
        // Pool configuration
        config.setMaximumPoolSize(10);
        config.setMinimumIdle(5);
        config.setConnectionTimeout(30000);
        config.setIdleTimeout(600000);
        config.setMaxLifetime(1800000);
        
        dataSource = new HikariDataSource(config);
    }
    
    public static Connection getConnection() throws SQLException {
        return dataSource.getConnection();
    }
    
    public static void close() {
        if (dataSource != null) {
            dataSource.close();
        }
    }
}

// Usage
public class PoolUsage {
    public static void main(String[] args) {
        try (Connection conn = ConnectionPool.getConnection()) {
            // Use connection
            System.out.println("Got connection from pool");
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
```

## DAO Pattern

```java
// User entity
public class User {
    private int id;
    private String name;
    private String email;
    private int age;
    
    // Constructors, getters, setters, toString
}

// DAO interface
public interface UserDAO {
    User findById(int id);
    List<User> findAll();
    void save(User user);
    void update(User user);
    void delete(int id);
}

// DAO implementation
public class UserDAOImpl implements UserDAO {
    
    @Override
    public User findById(int id) {
        String sql = "SELECT * FROM users WHERE id = ?";
        
        try (Connection conn = ConnectionPool.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, id);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToUser(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return null;
    }
    
    @Override
    public List<User> findAll() {
        List<User> users = new ArrayList<>();
        String sql = "SELECT * FROM users";
        
        try (Connection conn = ConnectionPool.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                users.add(mapResultSetToUser(rs));
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return users;
    }
    
    @Override
    public void save(User user) {
        String sql = "INSERT INTO users (name, email, age) VALUES (?, ?, ?)";
        
        try (Connection conn = ConnectionPool.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql,
                 Statement.RETURN_GENERATED_KEYS)) {
            
            pstmt.setString(1, user.getName());
            pstmt.setString(2, user.getEmail());
            pstmt.setInt(3, user.getAge());
            
            pstmt.executeUpdate();
            
            try (ResultSet rs = pstmt.getGeneratedKeys()) {
                if (rs.next()) {
                    user.setId(rs.getInt(1));
                }
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    
    @Override
    public void update(User user) {
        String sql = "UPDATE users SET name = ?, email = ?, age = ? WHERE id = ?";
        
        try (Connection conn = ConnectionPool.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, user.getName());
            pstmt.setString(2, user.getEmail());
            pstmt.setInt(3, user.getAge());
            pstmt.setInt(4, user.getId());
            
            pstmt.executeUpdate();
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    
    @Override
    public void delete(int id) {
        String sql = "DELETE FROM users WHERE id = ?";
        
        try (Connection conn = ConnectionPool.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, id);
            pstmt.executeUpdate();
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    
    private User mapResultSetToUser(ResultSet rs) throws SQLException {
        return new User(
            rs.getInt("id"),
            rs.getString("name"),
            rs.getString("email"),
            rs.getInt("age")
        );
    }
}
```

## Quick Reference

```java
// Connect
Connection conn = DriverManager.getConnection(url, user, password);

// Statement (not recommended)
Statement stmt = conn.createStatement();
stmt.executeUpdate("INSERT INTO...");
ResultSet rs = stmt.executeQuery("SELECT...");

// PreparedStatement (recommended)
PreparedStatement pstmt = conn.prepareStatement("SELECT * FROM users WHERE id = ?");
pstmt.setInt(1, userId);
ResultSet rs = pstmt.executeQuery();

// Read ResultSet
while (rs.next()) {
    int id = rs.getInt("id");
    String name = rs.getString("name");
}

// Transaction
conn.setAutoCommit(false);
// Execute statements
conn.commit();  // or conn.rollback();

// Batch
pstmt.addBatch();
pstmt.executeBatch();

// Close (use try-with-resources)
try (Connection conn = getConnection();
     PreparedStatement pstmt = conn.prepareStatement(sql)) {
    // Auto-closed
}
```

## Common Database URLs

```java
// MySQL
jdbc:mysql://localhost:3306/database

// PostgreSQL
jdbc:postgresql://localhost:5432/database

// Oracle
jdbc:oracle:thin:@localhost:1521:database

// SQL Server
jdbc:sqlserver://localhost:1433;databaseName=database

// H2 (in-memory)
jdbc:h2:mem:testdb

// H2 (file)
jdbc:h2:file:./data/mydb
```

---

**Previous**: [← Memory Management](java-16-memory-management.md) | **Next**: [Build Tools →](java-18-build-tools.md)
