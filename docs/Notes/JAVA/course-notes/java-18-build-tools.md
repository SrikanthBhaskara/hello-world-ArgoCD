# Java Build Tools - Maven & Gradle

## Maven

### What is Maven?

Maven is a build automation and project management tool that uses XML configuration (pom.xml).

**Key Concepts**:
- **Project Object Model (POM)**: Configuration file (`pom.xml`)
- **Convention over Configuration**: Standard directory structure
- **Dependencies Management**: Automatically downloads libraries
- **Build Lifecycle**: Predefined build phases

### Project Structure

```
my-project/
├── pom.xml
├── src/
│   ├── main/
│   │   ├── java/           # Java source code
│   │   ├── resources/      # Config files, properties
│   │   └── webapp/         # Web resources (if web app)
│   └── test/
│       ├── java/           # Test code
│       └── resources/      # Test resources
└── target/                 # Compiled output (generated)
```

### Basic pom.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    
    <!-- Project coordinates -->
    <groupId>com.example</groupId>
    <artifactId>my-app</artifactId>
    <version>1.0-SNAPSHOT</version>
    <packaging>jar</packaging>
    
    <name>My Application</name>
    <description>A sample Java application</description>
    
    <!-- Properties -->
    <properties>
        <maven.compiler.source>17</maven.compiler.source>
        <maven.compiler.target>17</maven.compiler.target>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    </properties>
    
    <!-- Dependencies -->
    <dependencies>
        <!-- JUnit 5 -->
        <dependency>
            <groupId>org.junit.jupiter</groupId>
            <artifactId>junit-jupiter</artifactId>
            <version>5.10.0</version>
            <scope>test</scope>
        </dependency>
    </dependencies>
    
    <!-- Build configuration -->
    <build>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.11.0</version>
            </plugin>
        </plugins>
    </build>
</project>
```

### Maven Commands

```bash
# Create new project from archetype
mvn archetype:generate -DgroupId=com.example -DartifactId=my-app -DarchetypeArtifactId=maven-archetype-quickstart

# Compile
mvn compile

# Run tests
mvn test

# Package (create JAR/WAR)
mvn package

# Install to local repository
mvn install

# Clean build directory
mvn clean

# Full build
mvn clean install

# Skip tests
mvn package -DskipTests

# Run specific test
mvn test -Dtest=MyTestClass

# Run application
mvn exec:java -Dexec.mainClass="com.example.Main"

# Generate project documentation
mvn site

# Dependency tree
mvn dependency:tree

# Update dependencies
mvn versions:use-latest-versions
```

### Common Dependencies

```xml
<dependencies>
    <!-- Logging: SLF4J + Logback -->
    <dependency>
        <groupId>org.slf4j</groupId>
        <artifactId>slf4j-api</artifactId>
        <version>2.0.9</version>
    </dependency>
    <dependency>
        <groupId>ch.qos.logback</groupId>
        <artifactId>logback-classic</artifactId>
        <version>1.4.11</version>
    </dependency>
    
    <!-- Apache Commons -->
    <dependency>
        <groupId>org.apache.commons</groupId>
        <artifactId>commons-lang3</artifactId>
        <version>3.13.0</version>
    </dependency>
    
    <!-- Jackson (JSON) -->
    <dependency>
        <groupId>com.fasterxml.jackson.core</groupId>
        <artifactId>jackson-databind</artifactId>
        <version>2.15.3</version>
    </dependency>
    
    <!-- Lombok -->
    <dependency>
        <groupId>org.projectlombok</groupId>
        <artifactId>lombok</artifactId>
        <version>1.18.30</version>
        <scope>provided</scope>
    </dependency>
    
    <!-- JUnit 5 -->
    <dependency>
        <groupId>org.junit.jupiter</groupId>
        <artifactId>junit-jupiter</artifactId>
        <version>5.10.0</version>
        <scope>test</scope>
    </dependency>
    
    <!-- Mockito -->
    <dependency>
        <groupId>org.mockito</groupId>
        <artifactId>mockito-core</artifactId>
        <version>5.7.0</version>
        <scope>test</scope>
    </dependency>
</dependencies>
```

### Dependency Scopes

```xml
<!-- compile: Default, available everywhere -->
<dependency>
    <groupId>commons-io</groupId>
    <artifactId>commons-io</artifactId>
    <version>2.15.0</version>
    <scope>compile</scope>
</dependency>

<!-- provided: Available at compile time, not packaged -->
<dependency>
    <groupId>javax.servlet</groupId>
    <artifactId>javax.servlet-api</artifactId>
    <version>4.0.1</version>
    <scope>provided</scope>
</dependency>

<!-- runtime: Available at runtime, not compile -->
<dependency>
    <groupId>mysql</groupId>
    <artifactId>mysql-connector-java</artifactId>
    <version>8.0.33</version>
    <scope>runtime</scope>
</dependency>

<!-- test: Only for tests -->
<dependency>
    <groupId>org.junit.jupiter</groupId>
    <artifactId>junit-jupiter</artifactId>
    <version>5.10.0</version>
    <scope>test</scope>
</dependency>
```

### Build Plugins

```xml
<build>
    <plugins>
        <!-- Compiler plugin -->
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-compiler-plugin</artifactId>
            <version>3.11.0</version>
            <configuration>
                <source>17</source>
                <target>17</target>
            </configuration>
        </plugin>
        
        <!-- JAR plugin -->
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-jar-plugin</artifactId>
            <version>3.3.0</version>
            <configuration>
                <archive>
                    <manifest>
                        <mainClass>com.example.Main</mainClass>
                    </manifest>
                </archive>
            </configuration>
        </plugin>
        
        <!-- Create fat JAR with dependencies -->
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-shade-plugin</artifactId>
            <version>3.5.1</version>
            <executions>
                <execution>
                    <phase>package</phase>
                    <goals>
                        <goal>shade</goal>
                    </goals>
                    <configuration>
                        <transformers>
                            <transformer implementation="org.apache.maven.plugins.shade.resource.ManifestResourceTransformer">
                                <mainClass>com.example.Main</mainClass>
                            </transformer>
                        </transformers>
                    </configuration>
                </execution>
            </executions>
        </plugin>
        
        <!-- Surefire (test) plugin -->
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-surefire-plugin</artifactId>
            <version>3.2.2</version>
        </plugin>
        
        <!-- Code coverage -->
        <plugin>
            <groupId>org.jacoco</groupId>
            <artifactId>jacoco-maven-plugin</artifactId>
            <version>0.8.11</version>
            <executions>
                <execution>
                    <goals>
                        <goal>prepare-agent</goal>
                    </goals>
                </execution>
                <execution>
                    <id>report</id>
                    <phase>test</phase>
                    <goals>
                        <goal>report</goal>
                    </goals>
                </execution>
            </executions>
        </plugin>
    </plugins>
</build>
```

### Profiles

```xml
<profiles>
    <!-- Development profile -->
    <profile>
        <id>dev</id>
        <activation>
            <activeByDefault>true</activeByDefault>
        </activation>
        <properties>
            <env>development</env>
            <db.url>jdbc:mysql://localhost:3306/dev_db</db.url>
        </properties>
    </profile>
    
    <!-- Production profile -->
    <profile>
        <id>prod</id>
        <properties>
            <env>production</env>
            <db.url>jdbc:mysql://prod-server:3306/prod_db</db.url>
        </properties>
    </profile>
</profiles>

<!-- Activate profile:
mvn clean package -Pprod
-->
```

## Gradle

### What is Gradle?

Gradle is a flexible build tool using Groovy or Kotlin DSL for configuration.

**Key Features**:
- **Groovy/Kotlin DSL**: More concise than XML
- **Incremental Builds**: Faster builds
- **Dependency Management**: Similar to Maven
- **Multi-project Builds**: Easy to configure

### Project Structure

```
my-project/
├── build.gradle         # Build configuration
├── settings.gradle      # Project settings
├── gradlew             # Gradle wrapper (Unix)
├── gradlew.bat         # Gradle wrapper (Windows)
├── gradle/
│   └── wrapper/
├── src/
│   ├── main/
│   │   ├── java/
│   │   └── resources/
│   └── test/
│       ├── java/
│       └── resources/
└── build/              # Compiled output (generated)
```

### Basic build.gradle (Groovy)

```groovy
plugins {
    id 'java'
    id 'application'
}

group = 'com.example'
version = '1.0-SNAPSHOT'

sourceCompatibility = '17'
targetCompatibility = '17'

repositories {
    mavenCentral()
}

dependencies {
    // Compile dependencies
    implementation 'org.apache.commons:commons-lang3:3.13.0'
    implementation 'com.fasterxml.jackson.core:jackson-databind:2.15.3'
    
    // Test dependencies
    testImplementation 'org.junit.jupiter:junit-jupiter:5.10.0'
    testImplementation 'org.mockito:mockito-core:5.7.0'
}

application {
    mainClass = 'com.example.Main'
}

test {
    useJUnitPlatform()
}

// Custom task
task hello {
    doLast {
        println 'Hello, Gradle!'
    }
}
```

### Basic build.gradle.kts (Kotlin)

```kotlin
plugins {
    java
    application
}

group = "com.example"
version = "1.0-SNAPSHOT"

java {
    sourceCompatibility = JavaVersion.VERSION_17
    targetCompatibility = JavaVersion.VERSION_17
}

repositories {
    mavenCentral()
}

dependencies {
    implementation("org.apache.commons:commons-lang3:3.13.0")
    implementation("com.fasterxml.jackson.core:jackson-databind:2.15.3")
    
    testImplementation("org.junit.jupiter:junit-jupiter:5.10.0")
    testImplementation("org.mockito:mockito-core:5.7.0")
}

application {
    mainClass.set("com.example.Main")
}

tasks.test {
    useJUnitPlatform()
}
```

### Gradle Commands

```bash
# Build project
./gradlew build

# Compile
./gradlew compileJava

# Run tests
./gradlew test

# Clean
./gradlew clean

# Full clean build
./gradlew clean build

# Run application
./gradlew run

# Create JAR
./gradlew jar

# Skip tests
./gradlew build -x test

# Show dependencies
./gradlew dependencies

# Show tasks
./gradlew tasks

# Continuous build
./gradlew build --continuous

# Show project info
./gradlew projects

# Refresh dependencies
./gradlew build --refresh-dependencies
```

### Dependency Configurations

```groovy
dependencies {
    // Compile and runtime
    implementation 'com.google.guava:guava:32.1.3-jre'
    
    // Compile only (like Maven's provided)
    compileOnly 'org.projectlombok:lombok:1.18.30'
    
    // Runtime only
    runtimeOnly 'mysql:mysql-connector-java:8.0.33'
    
    // Test compile and runtime
    testImplementation 'org.junit.jupiter:junit-jupiter:5.10.0'
    
    // Test runtime only
    testRuntimeOnly 'org.junit.platform:junit-platform-launcher'
    
    // Annotation processor
    annotationProcessor 'org.projectlombok:lombok:1.18.30'
}
```

### Multi-Module Project

**settings.gradle**:
```groovy
rootProject.name = 'my-multi-module-project'

include 'common'
include 'api'
include 'web'
```

**Root build.gradle**:
```groovy
subprojects {
    apply plugin: 'java'
    
    group = 'com.example'
    version = '1.0-SNAPSHOT'
    
    sourceCompatibility = '17'
    
    repositories {
        mavenCentral()
    }
    
    dependencies {
        testImplementation 'org.junit.jupiter:junit-jupiter:5.10.0'
    }
    
    test {
        useJUnitPlatform()
    }
}
```

**api/build.gradle**:
```groovy
dependencies {
    implementation project(':common')
    implementation 'org.springframework.boot:spring-boot-starter-web'
}
```

### Gradle Plugins

```groovy
plugins {
    id 'java'
    id 'application'
    id 'org.springframework.boot' version '3.2.0'
    id 'io.spring.dependency-management' version '1.1.4'
    id 'jacoco'  // Code coverage
}

// Jacoco configuration
jacoco {
    toolVersion = "0.8.11"
}

jacocoTestReport {
    reports {
        xml.required = true
        html.required = true
    }
}

// Fat JAR
jar {
    manifest {
        attributes(
            'Main-Class': 'com.example.Main'
        )
    }
    from {
        configurations.runtimeClasspath.collect { it.isDirectory() ? it : zipTree(it) }
    }
    duplicatesStrategy = DuplicatesStrategy.EXCLUDE
}
```

### Custom Tasks

```groovy
// Simple task
task hello {
    doLast {
        println 'Hello from Gradle!'
    }
}

// Task with dependencies
task compile(dependsOn: 'compileJava') {
    doLast {
        println 'Compilation complete'
    }
}

// Typed task
task copyDocs(type: Copy) {
    from 'docs'
    into 'build/docs'
}

// Task with configuration
task customZip(type: Zip) {
    archiveFileName = 'custom.zip'
    from 'src/main/resources'
}

// Run custom task:
// ./gradlew hello
```

## Maven vs Gradle

| Feature | Maven | Gradle |
|---------|-------|--------|
| Configuration | XML (pom.xml) | Groovy/Kotlin DSL |
| Performance | Slower | Faster (incremental builds) |
| Learning Curve | Easier | Steeper |
| Flexibility | Less flexible | More flexible |
| IDE Support | Excellent | Excellent |
| Build Cache | No | Yes |
| Multi-module | Good | Better |
| Android | No | Yes (official) |

## Maven Wrapper

```bash
# Create wrapper
mvn wrapper:wrapper

# Use wrapper (instead of mvn)
./mvnw clean install    # Unix
mvnw.cmd clean install  # Windows
```

**Benefits**: Project includes specific Maven version, no need to install Maven globally.

## Gradle Wrapper

```bash
# Create wrapper
gradle wrapper

# Use wrapper
./gradlew build    # Unix
gradlew.bat build  # Windows

# Update wrapper
./gradlew wrapper --gradle-version 8.5
```

## Publishing to Repository

### Maven Central (Maven)

```xml
<distributionManagement>
    <repository>
        <id>central</id>
        <url>https://oss.sonatype.org/service/local/staging/deploy/maven2/</url>
    </repository>
</distributionManagement>

<build>
    <plugins>
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-deploy-plugin</artifactId>
            <version>3.1.1</version>
        </plugin>
    </plugins>
</build>
```

```bash
mvn clean deploy
```

### Publishing (Gradle)

```groovy
plugins {
    id 'maven-publish'
}

publishing {
    publications {
        maven(MavenPublication) {
            from components.java
            
            groupId = 'com.example'
            artifactId = 'my-library'
            version = '1.0.0'
        }
    }
    
    repositories {
        maven {
            url = 'https://your-repo-url'
            credentials {
                username = project.findProperty('repoUser')
                password = project.findProperty('repoPassword')
            }
        }
    }
}
```

```bash
./gradlew publish
```

## Quick Reference

```bash
# Maven
mvn clean install           # Full build
mvn package                 # Create JAR/WAR
mvn test                    # Run tests
mvn dependency:tree         # Show dependencies
mvn exec:java -Dexec.mainClass="Main"  # Run

# Gradle
./gradlew build             # Full build
./gradlew jar               # Create JAR
./gradlew test              # Run tests
./gradlew dependencies      # Show dependencies
./gradlew run               # Run application
```

---

**Previous**: [← JDBC Database](java-17-jdbc-database.md) | **Next**: [Testing →](java-19-testing.md)
