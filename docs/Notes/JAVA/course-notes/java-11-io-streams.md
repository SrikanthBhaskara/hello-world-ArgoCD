# Java I/O and File Handling

## Stream Types

```
Java I/O Streams
├── Byte Streams (binary data)
│   ├── InputStream
│   │   ├── FileInputStream
│   │   ├── BufferedInputStream
│   │   └── ByteArrayInputStream
│   └── OutputStream
│       ├── FileOutputStream
│       ├── BufferedOutputStream
│       └── ByteArrayOutputStream
└── Character Streams (text data)
    ├── Reader
    │   ├── FileReader
    │   ├── BufferedReader
    │   └── StringReader
    └── Writer
        ├── FileWriter
        ├── BufferedWriter
        └── PrintWriter
```

## File Operations (java.io.File)

### Basic File Operations

```java
import java.io.File;
import java.io.IOException;

public class FileDemo {
    public static void main(String[] args) throws IOException {
        // Create File object
        File file = new File("example.txt");
        
        // File properties
        System.out.println("Exists: " + file.exists());
        System.out.println("Is file: " + file.isFile());
        System.out.println("Is directory: " + file.isDirectory());
        System.out.println("Absolute path: " + file.getAbsolutePath());
        System.out.println("Size: " + file.length() + " bytes");
        System.out.println("Can read: " + file.canRead());
        System.out.println("Can write: " + file.canWrite());
        
        // Create new file
        if (file.createNewFile()) {
            System.out.println("File created");
        } else {
            System.out.println("File already exists");
        }
        
        // Delete file
        if (file.delete()) {
            System.out.println("File deleted");
        }
    }
}
```

### Directory Operations

```java
import java.io.File;

public class DirectoryDemo {
    public static void main(String[] args) {
        // Create directory
        File dir = new File("mydir");
        if (dir.mkdir()) {
            System.out.println("Directory created");
        }
        
        // Create nested directories
        File nestedDir = new File("parent/child/grandchild");
        if (nestedDir.mkdirs()) {
            System.out.println("Nested directories created");
        }
        
        // List files in directory
        File folder = new File(".");
        String[] files = folder.list();
        for (String file : files) {
            System.out.println(file);
        }
        
        // List with File objects
        File[] fileObjects = folder.listFiles();
        for (File f : fileObjects) {
            System.out.println(f.getName() + " - " + 
                (f.isDirectory() ? "DIR" : "FILE"));
        }
    }
}
```

## Reading Files

### FileReader with BufferedReader

```java
import java.io.*;

public class ReadFileExample {
    // Read line by line
    public static void readWithBufferedReader(String filename) {
        try (BufferedReader reader = new BufferedReader(
                new FileReader(filename))) {
            String line;
            while ((line = reader.readLine()) != null) {
                System.out.println(line);
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
    
    // Read entire file
    public static String readEntireFile(String filename) throws IOException {
        StringBuilder content = new StringBuilder();
        try (BufferedReader reader = new BufferedReader(
                new FileReader(filename))) {
            String line;
            while ((line = reader.readLine()) != null) {
                content.append(line).append("\n");
            }
        }
        return content.toString();
    }
}
```

### FileInputStream (Binary)

```java
import java.io.*;

public class BinaryReadExample {
    // Read byte by byte
    public static void readBytes(String filename) {
        try (FileInputStream fis = new FileInputStream(filename)) {
            int data;
            while ((data = fis.read()) != -1) {
                System.out.print((char) data);
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
    
    // Read into byte array
    public static byte[] readAllBytes(String filename) throws IOException {
        try (FileInputStream fis = new FileInputStream(filename);
             ByteArrayOutputStream buffer = new ByteArrayOutputStream()) {
            byte[] chunk = new byte[1024];
            int bytesRead;
            while ((bytesRead = fis.read(chunk)) != -1) {
                buffer.write(chunk, 0, bytesRead);
            }
            return buffer.toByteArray();
        }
    }
}
```

### Scanner for Reading

```java
import java.io.*;
import java.util.Scanner;

public class ScannerFileRead {
    public static void readWithScanner(String filename) {
        try (Scanner scanner = new Scanner(new File(filename))) {
            while (scanner.hasNextLine()) {
                String line = scanner.nextLine();
                System.out.println(line);
            }
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        }
    }
    
    // Read structured data
    public static void readStructuredData(String filename) {
        try (Scanner scanner = new Scanner(new File(filename))) {
            while (scanner.hasNext()) {
                String name = scanner.next();
                int age = scanner.nextInt();
                double salary = scanner.nextDouble();
                System.out.printf("%s: %d years, $%.2f%n", name, age, salary);
            }
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        }
    }
}
```

## Writing Files

### FileWriter with BufferedWriter

```java
import java.io.*;

public class WriteFileExample {
    // Write with BufferedWriter
    public static void writeLines(String filename, String[] lines) {
        try (BufferedWriter writer = new BufferedWriter(
                new FileWriter(filename))) {
            for (String line : lines) {
                writer.write(line);
                writer.newLine();  // Platform-independent newline
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
    
    // Append to file
    public static void appendToFile(String filename, String text) {
        try (BufferedWriter writer = new BufferedWriter(
                new FileWriter(filename, true))) {  // true = append mode
            writer.write(text);
            writer.newLine();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
```

### PrintWriter

```java
import java.io.*;

public class PrintWriterExample {
    public static void writeWithPrintWriter(String filename) {
        try (PrintWriter writer = new PrintWriter(filename)) {
            writer.println("Hello, World!");
            writer.printf("Formatted: %d %.2f%n", 42, 3.14);
            writer.print("No newline");
            
            // Auto-flush available
            // PrintWriter writer = new PrintWriter(
            //     new FileWriter(filename), true);
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        }
    }
}
```

### FileOutputStream (Binary)

```java
import java.io.*;

public class BinaryWriteExample {
    // Write bytes
    public static void writeBytes(String filename, byte[] data) {
        try (FileOutputStream fos = new FileOutputStream(filename)) {
            fos.write(data);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
    
    // Copy binary file
    public static void copyFile(String source, String dest) {
        try (FileInputStream fis = new FileInputStream(source);
             FileOutputStream fos = new FileOutputStream(dest)) {
            byte[] buffer = new byte[1024];
            int bytesRead;
            while ((bytesRead = fis.read(buffer)) != -1) {
                fos.write(buffer, 0, bytesRead);
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
```

## NIO (New I/O) - java.nio.file

### Files Class (Modern Approach)

```java
import java.nio.file.*;
import java.io.IOException;
import java.util.List;

public class NIOExample {
    // Read all lines
    public static void readWithNIO(String filename) {
        try {
            Path path = Paths.get(filename);
            List<String> lines = Files.readAllLines(path);
            for (String line : lines) {
                System.out.println(line);
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
    
    // Write lines
    public static void writeWithNIO(String filename, List<String> lines) {
        try {
            Path path = Paths.get(filename);
            Files.write(path, lines);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
    
    // Read entire file as string
    public static String readString(String filename) throws IOException {
        return Files.readString(Paths.get(filename));  // Java 11+
    }
    
    // Write string
    public static void writeString(String filename, String content) throws IOException {
        Files.writeString(Paths.get(filename), content);  // Java 11+
    }
}
```

### Path Operations

```java
import java.nio.file.*;

public class PathDemo {
    public static void main(String[] args) throws IOException {
        Path path = Paths.get("data/file.txt");
        
        // Path information
        System.out.println("File name: " + path.getFileName());
        System.out.println("Parent: " + path.getParent());
        System.out.println("Root: " + path.getRoot());
        System.out.println("Absolute: " + path.toAbsolutePath());
        
        // File operations
        System.out.println("Exists: " + Files.exists(path));
        System.out.println("Is directory: " + Files.isDirectory(path));
        System.out.println("Size: " + Files.size(path));
        System.out.println("Last modified: " + Files.getLastModifiedTime(path));
        
        // Create, copy, move, delete
        Files.createFile(Paths.get("newfile.txt"));
        Files.copy(path, Paths.get("copy.txt"), StandardCopyOption.REPLACE_EXISTING);
        Files.move(Paths.get("copy.txt"), Paths.get("moved.txt"));
        Files.delete(Paths.get("moved.txt"));
    }
}
```

### Directory Walking

```java
import java.nio.file.*;
import java.io.IOException;
import java.util.stream.Stream;

public class DirectoryWalking {
    // List files in directory
    public static void listFiles(String dirPath) throws IOException {
        try (Stream<Path> paths = Files.list(Paths.get(dirPath))) {
            paths.forEach(System.out::println);
        }
    }
    
    // Walk directory tree
    public static void walkDirectory(String dirPath) throws IOException {
        try (Stream<Path> paths = Files.walk(Paths.get(dirPath))) {
            paths.filter(Files::isRegularFile)
                 .forEach(System.out::println);
        }
    }
    
    // Find files by pattern
    public static void findFiles(String dirPath, String pattern) throws IOException {
        PathMatcher matcher = FileSystems.getDefault()
            .getPathMatcher("glob:**/*" + pattern);
        
        try (Stream<Path> paths = Files.walk(Paths.get(dirPath))) {
            paths.filter(matcher::matches)
                 .forEach(System.out::println);
        }
    }
}
```

## Serialization

### Basic Serialization

```java
import java.io.*;

// Class must implement Serializable
class Person implements Serializable {
    private static final long serialVersionUID = 1L;
    private String name;
    private int age;
    private transient String password;  // Not serialized
    
    public Person(String name, int age, String password) {
        this.name = name;
        this.age = age;
        this.password = password;
    }
    
    @Override
    public String toString() {
        return "Person{name='" + name + "', age=" + age + "}";
    }
}

public class SerializationDemo {
    // Serialize object
    public static void serialize(Person person, String filename) {
        try (ObjectOutputStream oos = new ObjectOutputStream(
                new FileOutputStream(filename))) {
            oos.writeObject(person);
            System.out.println("Object serialized");
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
    
    // Deserialize object
    public static Person deserialize(String filename) {
        try (ObjectInputStream ois = new ObjectInputStream(
                new FileInputStream(filename))) {
            Person person = (Person) ois.readObject();
            System.out.println("Object deserialized");
            return person;
        } catch (IOException | ClassNotFoundException e) {
            e.printStackTrace();
            return null;
        }
    }
    
    public static void main(String[] args) {
        Person person = new Person("Alice", 30, "secret123");
        serialize(person, "person.ser");
        Person loaded = deserialize("person.ser");
        System.out.println(loaded);
    }
}
```

## Practical Examples

### File Copy Utility

```java
import java.io.*;

public class FileCopyUtility {
    public static void copyFile(String source, String dest) throws IOException {
        try (InputStream in = new BufferedInputStream(
                new FileInputStream(source));
             OutputStream out = new BufferedOutputStream(
                new FileOutputStream(dest))) {
            
            byte[] buffer = new byte[8192];
            int bytesRead;
            while ((bytesRead = in.read(buffer)) != -1) {
                out.write(buffer, 0, bytesRead);
            }
        }
    }
    
    // With progress
    public static void copyWithProgress(String source, String dest) throws IOException {
        File sourceFile = new File(source);
        long totalBytes = sourceFile.length();
        long copiedBytes = 0;
        
        try (InputStream in = new BufferedInputStream(new FileInputStream(source));
             OutputStream out = new BufferedOutputStream(new FileOutputStream(dest))) {
            
            byte[] buffer = new byte[8192];
            int bytesRead;
            while ((bytesRead = in.read(buffer)) != -1) {
                out.write(buffer, 0, bytesRead);
                copiedBytes += bytesRead;
                int progress = (int) ((copiedBytes * 100) / totalBytes);
                System.out.print("\rProgress: " + progress + "%");
            }
            System.out.println("\nCopy complete!");
        }
    }
}
```

### CSV Reader

```java
import java.io.*;
import java.util.*;

public class CSVReader {
    public static List<String[]> readCSV(String filename) {
        List<String[]> records = new ArrayList<>();
        
        try (BufferedReader reader = new BufferedReader(
                new FileReader(filename))) {
            String line;
            while ((line = reader.readLine()) != null) {
                String[] fields = line.split(",");
                records.add(fields);
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        
        return records;
    }
    
    public static void writeCSV(String filename, List<String[]> records) {
        try (PrintWriter writer = new PrintWriter(filename)) {
            for (String[] record : records) {
                writer.println(String.join(",", record));
            }
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        }
    }
}
```

### Configuration File Reader

```java
import java.io.*;
import java.util.*;

public class ConfigReader {
    public static Map<String, String> readConfig(String filename) {
        Map<String, String> config = new HashMap<>();
        
        try (BufferedReader reader = new BufferedReader(
                new FileReader(filename))) {
            String line;
            while ((line = reader.readLine()) != null) {
                line = line.trim();
                if (line.isEmpty() || line.startsWith("#")) {
                    continue;  // Skip empty lines and comments
                }
                
                String[] parts = line.split("=", 2);
                if (parts.length == 2) {
                    String key = parts[0].trim();
                    String value = parts[1].trim();
                    config.put(key, value);
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        
        return config;
    }
    
    // Usage:
    // host=localhost
    // port=8080
    // # This is a comment
    // timeout=5000
}
```

## Quick Reference

```java
// Read text file (modern way)
List<String> lines = Files.readAllLines(Paths.get("file.txt"));
String content = Files.readString(Paths.get("file.txt"));  // Java 11+

// Write text file
Files.write(Paths.get("file.txt"), lines);
Files.writeString(Paths.get("file.txt"), content);  // Java 11+

// Read binary
byte[] data = Files.readAllBytes(Paths.get("file.bin"));

// Write binary
Files.write(Paths.get("file.bin"), data);

// Traditional reading
try (BufferedReader reader = new BufferedReader(new FileReader("file.txt"))) {
    String line;
    while ((line = reader.readLine()) != null) {
        // Process line
    }
}

// Traditional writing
try (PrintWriter writer = new PrintWriter("file.txt")) {
    writer.println("Line 1");
    writer.println("Line 2");
}

// Copy file
Files.copy(source, dest, StandardCopyOption.REPLACE_EXISTING);

// Move file
Files.move(source, dest, StandardCopyOption.REPLACE_EXISTING);

// Delete file
Files.delete(path);
```

## Performance Tips

| Operation | Slow | Fast |
|-----------|------|------|
| Read text | FileReader | BufferedReader + FileReader |
| Read binary | FileInputStream (byte-by-byte) | BufferedInputStream + byte array |
| Write text | FileWriter | BufferedWriter + FileWriter |
| Small files | Traditional I/O | Files.readAllLines() / readString() |
| Large files | readAllLines() | BufferedReader with streaming |

---

**Previous**: [← Exceptions](java-10-exceptions.md) | **Next**: [Generics →](java-12-generics.md)
