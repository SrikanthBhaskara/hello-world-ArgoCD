# Java Overview & Setup

## What is Java?

Java is a high-level, class-based, object-oriented programming language designed to have as few implementation dependencies as possible. It follows the principle of "Write Once, Run Anywhere" (WORA).

### Key Characteristics

- **Platform Independent**: Java bytecode runs on any platform with JVM
- **Object-Oriented**: Everything is an object (except primitives)
- **Secure**: Built-in security features, no explicit pointers
- **Robust**: Strong memory management, exception handling
- **Multithreaded**: Built-in support for concurrent programming
- **High Performance**: JIT compiler optimizes bytecode

## Java Architecture

```
┌─────────────────────────────────────┐
│      Java Source Code (.java)      │
└─────────────────┬───────────────────┘
                  │
         ┌────────▼────────┐
         │  Java Compiler  │
         │     (javac)     │
         └────────┬────────┘
                  │
┌─────────────────▼───────────────────┐
│      Java Bytecode (.class)        │
└─────────────────┬───────────────────┘
                  │
         ┌────────▼────────┐
         │  Java Virtual   │
         │   Machine (JVM) │
         └────────┬────────┘
                  │
┌─────────────────▼───────────────────┐
│        Platform (Any OS)           │
└─────────────────────────────────────┘
```

### JVM, JRE, and JDK

```
┌──────────────────────────────────────────┐
│                   JDK                    │
│  (Java Development Kit)                  │
│  ┌────────────────────────────────────┐  │
│  │             JRE                    │  │
│  │  (Java Runtime Environment)        │  │
│  │  ┌──────────────────────────────┐  │  │
│  │  │          JVM                 │  │  │
│  │  │  (Java Virtual Machine)      │  │  │
│  │  │  - Classloader               │  │  │
│  │  │  - Bytecode Verifier         │  │  │
│  │  │  - Interpreter               │  │  │
│  │  │  - JIT Compiler              │  │  │
│  │  └──────────────────────────────┘  │  │
│  │  + Java Class Libraries            │  │
│  └────────────────────────────────────┘  │
│  + Development Tools (javac, jar, etc.)  │
└──────────────────────────────────────────┘
```

- **JVM**: Executes Java bytecode
- **JRE**: JVM + libraries needed to run Java applications
- **JDK**: JRE + development tools (compiler, debugger)

## Installation

### Windows

1. **Download JDK**:
   - Visit [Oracle JDK](https://www.oracle.com/java/technologies/downloads/) or [OpenJDK](https://adoptium.net/)
   - Download the Windows installer (.exe) for latest LTS version

2. **Install**:
   ```powershell
   # Run installer and follow prompts
   # Default location: C:\Program Files\Java\jdk-<version>
   ```

3. **Set Environment Variables**:
   ```powershell
   # Set JAVA_HOME
   setx JAVA_HOME "C:\Program Files\Java\jdk-21"
   
   # Add to PATH
   setx PATH "%PATH%;%JAVA_HOME%\bin"
   ```

4. **Verify Installation**:
   ```bash
   java -version
   javac -version
   ```

### Linux

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install openjdk-21-jdk

# RHEL/CentOS/Fedora
sudo dnf install java-21-openjdk-devel

# Verify
java -version
javac -version

# Set JAVA_HOME (add to ~/.bashrc or ~/.profile)
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk
export PATH=$PATH:$JAVA_HOME/bin
```

### macOS

```bash
# Using Homebrew
brew install openjdk@21

# Add to PATH (add to ~/.zshrc or ~/.bash_profile)
export PATH="/opt/homebrew/opt/openjdk@21/bin:$PATH"

# Verify
java -version
javac -version
```

## Your First Java Program

### Hello World Example

```java
// HelloWorld.java
public class HelloWorld {
    public static void main(String[] args) {
        System.out.println("Hello, World!");
    }
}
```

### Compile and Run

```bash
# Compile (creates HelloWorld.class)
javac HelloWorld.java

# Run
java HelloWorld

# Output: Hello, World!
```

### Understanding the Code

```java
public class HelloWorld {           // 1. Class declaration
    public static void main(       // 2. Main method
        String[] args              // 3. Command-line arguments
    ) {
        System.out.println(        // 4. Print statement
            "Hello, World!"
        );
    }
}
```

1. **Class Declaration**: Every Java program must have at least one class
2. **main() Method**: Entry point of the program
   - `public`: Accessible from anywhere
   - `static`: Can be called without creating an instance
   - `void`: Doesn't return a value
3. **String[] args**: Array of command-line arguments
4. **System.out.println()**: Prints to console with newline

## Java Development Tools

### IDEs (Integrated Development Environments)

1. **IntelliJ IDEA** (Recommended)
   - Industry standard
   - Powerful code completion and refactoring
   - [Download](https://www.jetbrains.com/idea/)

2. **Eclipse**
   - Open-source and free
   - Large plugin ecosystem
   - [Download](https://www.eclipse.org/)

3. **Visual Studio Code**
   - Lightweight
   - Java Extension Pack required
   - [Download](https://code.visualstudio.com/)

4. **NetBeans**
   - Official Oracle IDE
   - Good for beginners
   - [Download](https://netbeans.apache.org/)

### Build Tools

- **Maven**: Dependency management and build automation
- **Gradle**: Modern, flexible build tool
- **Ant**: Legacy build tool (less common now)

## Java Versions

### Long-Term Support (LTS) Versions

| Version | Release Date | End of Support | Key Features |
|---------|--------------|----------------|--------------|
| Java 8  | March 2014   | 2030          | Lambdas, Streams, Optional |
| Java 11 | Sept 2018    | 2027          | HTTP Client, var keyword |
| Java 17 | Sept 2021    | 2029          | Sealed classes, Pattern matching |
| Java 21 | Sept 2023    | 2031          | Virtual threads, Record patterns |

### Choosing a Version

- **Learning**: Use Java 17 or 21 (latest LTS)
- **Enterprise**: Java 11 or 17 (wide support)
- **Legacy**: Java 8 (still common in older projects)

## Basic Program Structure

```java
// 1. Package declaration (optional)
package com.example.myapp;

// 2. Import statements
import java.util.Scanner;
import java.util.ArrayList;

// 3. Class declaration
public class MyProgram {
    
    // 4. Class variables (fields)
    private static int count = 0;
    
    // 5. Constructor
    public MyProgram() {
        count++;
    }
    
    // 6. Methods
    public void doSomething() {
        System.out.println("Doing something...");
    }
    
    // 7. Main method (entry point)
    public static void main(String[] args) {
        MyProgram program = new MyProgram();
        program.doSomething();
    }
}
```

## Naming Conventions

```java
// Classes and Interfaces: PascalCase
public class StudentRecord { }
public interface Drawable { }

// Methods and Variables: camelCase
public void calculateTotal() { }
private int studentAge;

// Constants: UPPER_SNAKE_CASE
public static final int MAX_SIZE = 100;

// Packages: lowercase
package com.company.project;
```

## Comments

```java
// Single-line comment

/*
 * Multi-line comment
 * Can span multiple lines
 */

/**
 * JavaDoc comment - used for documentation
 * @param args command-line arguments
 * @return nothing
 */
public static void main(String[] args) {
    // Method implementation
}
```

## Common Commands

```bash
# Compile a single file
javac MyProgram.java

# Compile with specific output directory
javac -d bin src/MyProgram.java

# Run a program
java MyProgram

# Run with classpath
java -cp bin MyProgram

# Create JAR file
jar cvf myapp.jar -C bin .

# Run JAR file
java -jar myapp.jar

# Check Java version
java -version

# View Java runtime options
java -X
```

## Hello World Variations

### Interactive Program

```java
import java.util.Scanner;

public class Interactive {
    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        
        System.out.print("Enter your name: ");
        String name = scanner.nextLine();
        
        System.out.println("Hello, " + name + "!");
        scanner.close();
    }
}
```

### Command-Line Arguments

```java
public class Arguments {
    public static void main(String[] args) {
        if (args.length == 0) {
            System.out.println("No arguments provided");
        } else {
            System.out.println("Arguments:");
            for (String arg : args) {
                System.out.println("  - " + arg);
            }
        }
    }
}

// Run: java Arguments hello world 123
```

### Formatted Output

```java
public class Formatting {
    public static void main(String[] args) {
        String name = "Alice";
        int age = 25;
        double salary = 75000.50;
        
        // Using printf
        System.out.printf("Name: %s, Age: %d, Salary: $%.2f%n", 
                         name, age, salary);
        
        // Using String.format
        String message = String.format("Welcome, %s!", name);
        System.out.println(message);
    }
}
```

## Next Steps

1. ✅ Verify Java installation
2. ✅ Set up your IDE
3. ✅ Write and run Hello World
4. 📖 Continue to [Java Basics](java-01-basics.md)

## Resources

- **Official Documentation**: [docs.oracle.com/javase](https://docs.oracle.com/javase/)
- **Java API Documentation**: [docs.oracle.com/en/java/javase/21/docs/api/](https://docs.oracle.com/en/java/javase/21/docs/api/)
- **Java Tutorials**: [dev.java](https://dev.java/)
- **OpenJDK**: [openjdk.org](https://openjdk.org/)

---

**Next**: [Java Basics →](java-01-basics.md)
