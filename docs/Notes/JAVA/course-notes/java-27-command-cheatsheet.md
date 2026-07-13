# Java Command Cheat Sheet

## Basic Commands

### Compilation

```bash
# Compile single file
javac HelloWorld.java

# Compile with specific encoding
javac -encoding UTF-8 MyProgram.java

# Compile multiple files
javac File1.java File2.java File3.java

# Compile all Java files in directory
javac *.java

# Specify output directory
javac -d bin src/MyProgram.java

# Include external JARs in classpath
javac -cp lib/library.jar MyProgram.java

# Show warnings
javac -Xlint MyProgram.java

# Show all warnings
javac -Xlint:all MyProgram.java

# Show deprecation warnings
javac -deprecation MyProgram.java

# Compile for specific Java version
javac -source 11 -target 11 MyProgram.java

# Enable preview features
javac --enable-preview --release 21 MyProgram.java
```

### Execution

```bash
# Run program
java HelloWorld

# Run with classpath
java -cp bin HelloWorld

# Run with multiple classpath entries
java -cp "lib/*:bin" HelloWorld                # Linux/Mac
java -cp "lib/*;bin" HelloWorld                # Windows

# Run JAR file
java -jar myapp.jar

# Pass command-line arguments
java HelloWorld arg1 arg2 arg3

# Set system properties
java -Dfile.encoding=UTF-8 HelloWorld
java -Dspring.profiles.active=prod MyApp

# Set JVM heap size
java -Xms512m -Xmx2g MyProgram
# -Xms: Initial heap size
# -Xmx: Maximum heap size

# Enable assertions
java -ea MyProgram              # Enable all assertions
java -ea:MyClass MyProgram      # Enable for specific class
java -ea:com.mypackage... MyProgram  # Enable for package

# Enable preview features
java --enable-preview MyProgram

# Show Java version
java -version
```

## JAR (Java Archive) Commands

### Create JAR

```bash
# Create JAR from class files
jar cvf myapp.jar -C bin .

# Create JAR with manifest
jar cvfm myapp.jar manifest.txt -C bin .

# Create executable JAR (manifest with Main-Class)
jar cvfe myapp.jar com.example.Main -C bin .

# Flags:
# c: create
# v: verbose
# f: file name
# m: manifest
# e: entry point (main class)
```

### Extract/View JAR

```bash
# Extract JAR
jar xvf myapp.jar

# List contents
jar tvf myapp.jar

# Update JAR
jar uvf myapp.jar MyClass.class
```

### Executable JAR

**manifest.txt**:
```
Main-Class: com.example.MainClass
Class-Path: lib/dependency1.jar lib/dependency2.jar

```
Note: Must end with blank line

```bash
# Create with manifest
jar cvfm myapp.jar manifest.txt -C bin .

# Run
java -jar myapp.jar
```

## Package Management

### Compile with Packages

```bash
# File structure:
# src/com/example/MyClass.java

# Compile
javac -d bin src/com/example/MyClass.java

# Creates:
# bin/com/example/MyClass.class

# Run
java -cp bin com.example.MyClass
```

### Import External JARs

```bash
# Compile with external JAR
javac -cp lib/library.jar:. MyProgram.java         # Linux/Mac
javac -cp lib/library.jar;. MyProgram.java         # Windows

# Run with external JAR
java -cp lib/library.jar:bin MyProgram             # Linux/Mac
java -cp lib/library.jar;bin MyProgram             # Windows

# Use wildcard for all JARs in directory
java -cp "lib/*:bin" MyProgram
```

## JVM Options

### Memory Management

```bash
# Heap size
java -Xms512m -Xmx2g MyProgram
# -Xms: Initial heap (min)
# -Xmx: Maximum heap
# Units: k (KB), m (MB), g (GB)

# Stack size
java -Xss1m MyProgram

# Metaspace (Java 8+)
java -XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=512m MyProgram

# PermGen (Java 7 and below, deprecated)
java -XX:PermSize=128m -XX:MaxPermSize=256m MyProgram

# Print memory usage
java -XX:+PrintGCDetails -XX:+PrintGCTimeStamps MyProgram
```

### Garbage Collection

```bash
# Use G1 GC (default in Java 9+)
java -XX:+UseG1GC MyProgram

# Use Parallel GC
java -XX:+UseParallelGC MyProgram

# Use CMS GC (deprecated in Java 9)
java -XX:+UseConcMarkSweepGC MyProgram

# Use ZGC (Java 11+)
java -XX:+UseZGC MyProgram

# Verbose GC
java -verbose:gc MyProgram
java -Xlog:gc MyProgram  # Java 9+

# Generate heap dump on OutOfMemoryError
java -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/tmp/dump.hprof MyProgram
```

### Debugging and Monitoring

```bash
# Enable remote debugging
java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005 MyProgram

# Enable JMX monitoring
java -Dcom.sun.management.jmxremote \
     -Dcom.sun.management.jmxremote.port=9010 \
     -Dcom.sun.management.jmxremote.authenticate=false \
     -Dcom.sun.management.jmxremote.ssl=false \
     MyProgram

# Print JVM flags
java -XX:+PrintFlagsFinal -version

# Verbose class loading
java -verbose:class MyProgram

# Print compilation
java -XX:+PrintCompilation MyProgram

# Show what's going on
java -XX:+UnlockDiagnosticVMOptions -XX:+LogCompilation MyProgram
```

## Development Tools

### javadoc - Generate Documentation

```bash
# Generate docs
javadoc -d docs src/com/example/*.java

# With packages
javadoc -d docs -sourcepath src com.example

# With external links
javadoc -d docs -link https://docs.oracle.com/en/java/javase/17/docs/api/ src/*.java

# Private members included
javadoc -private -d docs src/*.java
```

### jshell - Interactive REPL (Java 9+)

```bash
# Start JShell
jshell

# Commands:
#   /help    - Show help
#   /list    - List entered code
#   /vars    - Show variables
#   /methods - Show methods
#   /types   - Show types
#   /imports - Show imports
#   /exit    - Exit

# Example session:
$ jshell
|  Welcome to JShell
jshell> int x = 5
x ==> 5
jshell> System.out.println(x * 2)
10
jshell> /exit
```

### jdeps - Dependency Analyzer

```bash
# Analyze dependencies
jdeps myapp.jar

# Show package-level dependencies
jdeps -s myapp.jar

# Find JDK internal API usage
jdeps -jdkinternals myapp.jar

# Analyze with classpath
jdeps -cp lib/* myapp.jar
```

### jps - Java Process Status

```bash
# List running Java processes
jps

# With full class name
jps -l

# With JVM arguments
jps -v

# With main method arguments
jps -m
```

### jmap - Memory Map

```bash
# Generate heap dump
jmap -dump:format=b,file=heap.bin <pid>

# Print heap histogram
jmap -histo <pid>

# Print finalization queue
jmap -finalizerinfo <pid>
```

### jstack - Thread Dump

```bash
# Generate thread dump
jstack <pid>

# With lock information
jstack -l <pid>

# Redirect to file
jstack <pid> > threads.txt
```

### jstat - JVM Statistics

```bash
# GC statistics
jstat -gc <pid>

# GC statistics with timestamps
jstat -gc <pid> 1000    # Every 1 second

# Class loader statistics
jstat -class <pid>

# Compiler statistics
jstat -compiler <pid>
```

### jconsole - Monitoring GUI

```bash
# Start JConsole
jconsole

# Connect to specific process
jconsole <pid>

# Connect to remote JVM
jconsole <hostname>:<port>
```

### jvisualvm - Visual Monitoring

```bash
# Start VisualVM
jvisualvm
```

## Build Tools

### Maven

```bash
# Create new project
mvn archetype:generate -DgroupId=com.example -DartifactId=myapp

# Compile
mvn compile

# Run tests
mvn test

# Package (creates JAR/WAR)
mvn package

# Install to local repository
mvn install

# Clean build
mvn clean install

# Skip tests
mvn install -DskipTests

# Run specific test class
mvn test -Dtest=MyTestClass

# Run with specific profile
mvn install -Pproduction

# Generate project site
mvn site

# Show dependency tree
mvn dependency:tree

# Update dependencies
mvn versions:use-latest-releases
```

### Gradle

```bash
# Create new project
gradle init

# Compile
gradle build

# Run tests
gradle test

# Run application
gradle run

# Clean build
gradle clean build

# Skip tests
gradle build -x test

# Show dependencies
gradle dependencies

# Generate wrapper
gradle wrapper

# Run with wrapper
./gradlew build              # Linux/Mac
gradlew.bat build           # Windows

# Run with specific task
gradle customTask
```

## Testing

### JUnit (from command line)

```bash
# Compile test (with JUnit 5)
javac -cp .:"junit-platform-console-standalone.jar" MyTest.java MyClass.java

# Run tests
java -jar junit-platform-console-standalone.jar --class-path . --scan-class-path

# Run specific test class
java -jar junit-platform-console-standalone.jar --class-path . --select-class com.example.MyTest
```

## Common Workflows

### Complete Build Process

```bash
# 1. Clean previous builds
rm -rf bin/*

# 2. Compile source code
javac -d bin -sourcepath src src/com/example/*.java

# 3. Copy resources
cp -r src/resources/* bin/

# 4. Create JAR
jar cvfm myapp.jar manifest.txt -C bin .

# 5. Run
java -jar myapp.jar
```

### Debug a Program

```bash
# 1. Start with debug enabled
java -agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=5005 MyProgram

# 2. Connect debugger from IDE to port 5005
```

### Profile Performance

```bash
# 1. Run with profiling
java -XX:+UnlockCommercialFeatures -XX:+FlightRecorder \
     -XX:StartFlightRecording=duration=60s,filename=recording.jfr \
     MyProgram

# 2. Analyze recording with jmc
jmc
```

## Environment Variables

```bash
# Set JAVA_HOME
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk        # Linux/Mac
set JAVA_HOME=C:\Program Files\Java\jdk-17           # Windows (cmd)
$env:JAVA_HOME="C:\Program Files\Java\jdk-17"        # Windows (PowerShell)

# Add to PATH
export PATH=$PATH:$JAVA_HOME/bin                     # Linux/Mac
set PATH=%PATH%;%JAVA_HOME%\bin                      # Windows (cmd)
$env:PATH="$env:PATH;$env:JAVA_HOME\bin"            # Windows (PowerShell)

# Set CLASSPATH
export CLASSPATH=.:lib/*:bin                         # Linux/Mac
set CLASSPATH=.;lib\*;bin                            # Windows
```

## Quick Reference Card

### Most Common Commands

```bash
# Compile and run
javac MyProgram.java && java MyProgram

# Create and run JAR
jar cvfe app.jar Main -C bin . && java -jar app.jar

# With dependencies
javac -cp "lib/*" src/*.java && java -cp "lib/*:bin" Main

# Debug
java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005 Main

# Check memory
jps -l && jmap -heap <pid>

# Thread dump
jps -l && jstack <pid>
```

---

**See Also**: [Java Collections Cheat Sheet](java-28-collections-cheatsheet.md) | [Interview Prep](java-29-interview-prep.md)
