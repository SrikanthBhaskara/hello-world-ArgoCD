# Java 17 Notes

## Purpose

This file is a deeper study note for Java 17.

Use it for:

- interview preparation
- revision notes
- understanding what changed from Java 11 to Java 17
- migration planning for enterprise applications
- learning modern Java syntax as a stable LTS baseline

## Java 17 in One Line

Java 17 is the LTS where modern Java syntax, better data modeling, and stronger platform boundaries became mainstream.

## Release Identity

Java 17 is not just "Java 11 plus a few new features".

It represents the combined effect of the Java 12 to 17 releases, especially:

- switch expressions
- text blocks
- records
- sealed classes
- pattern matching for `instanceof`
- stronger encapsulation

For many teams, Java 17 is the next major modernization step after Java 11.

## Compared With Java 11

### Newly added

- switch expressions
- text blocks
- records
- sealed classes
- pattern matching for `instanceof`
- helpful NullPointerExceptions
- `jpackage`

### Removed, deprecated, or strongly restricted

- Nashorn removed by Java 15
- CMS garbage collector removed by Java 14
- Pack200 removed by Java 14
- RMI Activation removed in Java 17
- Applet API deprecated for removal
- Security Manager deprecated for removal
- JDK internal APIs became strongly encapsulated

### Modified behavior and platform changes

- reflective access to internal JDK classes became much stricter
- modularity and encapsulation changed what old code can access
- records and sealed classes change how data models and hierarchies are designed
- debugging null errors became easier because of helpful NullPointerExceptions

## Most Important Language Features

### `var`

```java
var names = List.of("a", "b", "c");
```

Why it matters:

- removes redundant local type declarations
- can improve readability when the type is obvious

When to use it:

- obvious initializers
- short local scope

When not to use it:

- when type becomes unclear
- when code becomes harder to read

### Switch expressions

Old:

```java
String label;
switch (code) {
    case 200:
        label = "ok";
        break;
    default:
        label = "other";
}
```

Java 17:

```java
String label = switch (code) {
    case 200 -> "ok";
    default -> "other";
};
```

Why it matters:

- less fall-through confusion
- clearer expression-oriented code

What to know:

- `switch` can now return a value
- `yield` exists for more complex switch blocks

### Text blocks

Old:

```java
String json = "{\n" +
    "  \"name\": \"ARES\"\n" +
    "}";
```

Java 17:

```java
String json = """
    {
      "name": "ARES"
    }
    """;
```

Why it matters:

- ideal for JSON, SQL, XML, HTML
- much less escaping noise

What to understand:

- indentation rules
- trailing newline behavior
- readability benefits

### Records

```java
record Employee(String id, String name, int age) {}
```

Why it matters:

- removes boilerplate
- great for immutable data carriers
- auto-generates constructor, accessors, `equals`, `hashCode`, and `toString`

Old style:

```java
final class Employee {
    private final String id;
    private final String name;
    private final int age;

    Employee(String id, String name, int age) {
        this.id = id;
        this.name = name;
        this.age = age;
    }

    String id() { return id; }
    String name() { return name; }
    int age() { return age; }
}
```

When records are a great fit:

- DTOs
- API payloads
- immutable domain value types

When not to use them:

- mutable entities
- models with complex framework lifecycle needs
- types with identity-heavy behavior

### Sealed classes

```java
sealed interface Result permits Success, Failure {}

record Success(String value) implements Result {}
record Failure(String error) implements Result {}
```

Why it matters:

- controls inheritance
- models fixed domains cleanly
- works well with pattern matching and switch logic

What to understand:

- `sealed`
- `permits`
- `final`
- `non-sealed`

### Pattern matching for `instanceof`

Old:

```java
if (obj instanceof String) {
    String s = (String) obj;
    System.out.println(s.toUpperCase());
}
```

Java 17:

```java
if (obj instanceof String s) {
    System.out.println(s.toUpperCase());
}
```

Why it matters:

- removes manual casts
- reduces boilerplate
- safer and clearer

## Important API and Platform Additions

### HTTP Client

```java
HttpClient client = HttpClient.newHttpClient();
```

Why it matters:

- cleaner standard HTTP support
- HTTP/2 capable
- async support available
- less need for external clients in simpler cases

What to learn:

- `HttpClient`
- `HttpRequest`
- `HttpResponse`
- sync vs async usage

### Useful library additions by the Java 17 era

- `String.isBlank`
- `String.lines`
- `String.repeat`
- `String.strip`
- `Files.readString`
- `Files.writeString`
- `Optional.isEmpty`
- `List.of`, `Set.of`, `Map.of`

Why they matter:

- less utility-code boilerplate
- cleaner standard-library usage

### Helpful NullPointerExceptions

Why it matters:

- makes debugging null problems much easier
- points to the actual null-producing part more clearly

## Strongly Modified Behavior

### Strong encapsulation of JDK internals

Before:

- many legacy applications accessed internal JDK classes directly

By Java 17:

- this access is strongly restricted

Why it matters:

- older frameworks or hacks may fail
- code using `sun.*` or internal packages often needs cleanup
- reflective access assumptions that still survived on Java 11 frequently break harder by Java 17

### Module-era impact, even if you do not use modules directly

Why it matters:

- many migration failures from Java 11 to 17 are really about stronger enforcement of post-Java-9 platform changes
- even classpath-based apps can feel the impact of stronger platform boundaries

## Removed and Deprecated Areas Explained

### Java EE and CORBA modules

What changed:

- these were removed from the JDK

Why it matters:

- old projects that assumed JAXB or related APIs were bundled may fail to compile or run

Typical fix:

- add explicit external dependencies

### Nashorn

What changed:

- removed by Java 15

Why it matters:

- applications embedding JavaScript through Nashorn need a new approach

### Security Manager

What changed:

- deprecated for removal by Java 17

Why it matters:

- very old security models based on it are on a dead-end path

## What To Learn Deeply

- records
- sealed classes
- pattern matching for `instanceof`
- text blocks
- switch expressions
- `var`
- HTTP client
- strong encapsulation and module-era migration issues

## Interview Questions To Expect

- What is a record?
- When should you not use a record?
- What problem do sealed classes solve?
- Difference between switch statement and switch expression?
- Why did old code break more often by Java 17?
- What does strong encapsulation mean?
- When should `var` be avoided?
- Why are text blocks useful?

## Migration Notes

If you move from Java 11 to Java 17:

- remove dependencies on internal JDK APIs
- review reflection-heavy libraries
- replace old HTTP client code where beneficial
- modernize data models with records where useful
- use text blocks for SQL and JSON-heavy code
- validate build tools, plugins, and test frameworks on Java 17

## Common Pitfalls

- using `var` where types become unclear
- overusing records where mutation or identity matters
- forgetting removals and restrictions that still impact teams moving beyond Java 11
- ignoring reflective-access warnings until upgrade day

## Practice Topics

- convert a DTO class to a record
- replace if-cast code with pattern matching for `instanceof`
- rewrite a switch statement as a switch expression
- replace escaped multiline strings with text blocks
- send a simple request with `HttpClient`

## Deeper Notes on Records

### Records are about data semantics

A record says:

- this type is mainly a transparent carrier for data

That is stronger than just "less boilerplate".

When you choose a record, you are communicating:

- the state is central
- equality should be based on components
- immutability is the intended default style

### Canonical and compact constructors

Why this matters:

- records still allow validation logic
- you can enforce invariants while keeping the record model

Typical use:

- null checks
- value normalization
- validation

### Record limitations

Important constraints:

- records cannot extend another class
- their state model is fixed by record components
- they are not a drop-in replacement for every entity type

## Deeper Notes on Sealed Classes

### Why sealed classes matter architecturally

Before sealed classes, Java developers often used:

- package-private constructors
- private nested classes
- documentation-only inheritance rules

Sealed classes move those restrictions into the type system.

This improves:

- maintainability
- exhaustiveness reasoning
- API clarity

### `sealed`, `non-sealed`, and `final`

Understand the three-way control:

- `sealed` restricts who may extend
- `final` closes a type completely
- `non-sealed` reopens a branch deliberately

This is important in domain modeling because it lets you create a controlled hierarchy instead of an accidental one.

## Modules and Encapsulation: The Hidden Big Topic

Even if your team never writes `module-info.java`, Java 17 still reflects the post-Java-9 world.

Why this matters:

- many migration problems are not caused by records or `var`
- they are caused by stronger platform boundaries

### Practical symptoms during migration

- reflective access warnings or failures
- missing JAXB or JAX-WS classes
- libraries depending on internal JDK packages
- test utilities breaking because of encapsulation changes

### Practical lesson

For many upgrades, the real work is:

- dependency cleanup
- framework upgrades
- build modernization

not just code syntax migration

## More Detail on `var`

### Good `var`

Use `var` when:

- the initializer makes the type obvious
- the local variable has a short, clear scope

Example:

```java
var users = List.of("a", "b");
```

### Bad `var`

Avoid it when:

- the type is not obvious
- the variable name is vague
- the code becomes harder to review

Example of poor readability:

```java
var result = service.process(data);
```

If the type is important to understanding, write it explicitly.

## Real-World Migration Checklist: Java 11 to Java 17

- upgrade build tooling first
- verify test framework compatibility
- search for internal API usage such as `sun.*`
- check reflective-access-heavy frameworks
- upgrade logging, bytecode, proxy, and instrumentation libraries
- validate startup flags and removed JVM options
- modernize selected DTOs with records after the platform upgrade is stable

## When Not to Use Newer Features

### Do not force records everywhere

Avoid records when:

- ORM entities require mutability or proxies
- business identity is more important than structural equality
- lifecycle behavior is complex

### Do not overuse switch expressions

Avoid rewriting simple `if` logic just because switch expressions exist.

Use them when:

- branching is naturally expression-oriented
- cases are clearer as a switch than as `if-else`

### Do not use text blocks blindly

Text blocks are great for:

- SQL
- JSON
- XML

But still review:

- whitespace
- indentation
- exact output formatting

## Advanced Interview Angles

- Why are records not just POJOs with less code?
- What problem do sealed classes solve that abstract classes alone do not?
- Why does a Java 11 to 17 migration often fail before application logic is even tested?
- Why is Java 17 considered a practical modernization target?

## Old Code Structure vs New Code Structure

### DTO structure

Old structure:

```java
final class UserDto {
    private final String id;
    private final String name;

    UserDto(String id, String name) {
        this.id = id;
        this.name = name;
    }

    String id() { return id; }
    String name() { return name; }
}
```

Java 17 structure:

```java
record UserDto(String id, String name) {}
```

### Hierarchy structure

Old structure:

```java
abstract class Result {}

final class Success extends Result {}
final class Failure extends Result {}
```

Java 17 structure:

```java
sealed interface Result permits Success, Failure {}

record Success(String value) implements Result {}
record Failure(String error) implements Result {}
```

### Multiline string structure

Old structure:

```java
String json = "{\n" +
    "  \"name\": \"dev\"\n" +
    "}";
```

Java 17 structure:

```java
String json = """
    {
      "name": "dev"
    }
    """;
```

## Short Summary

Java 17 is mainly about:

- modern language expressiveness
- cleaner data modeling
- better standard APIs
- stronger and safer platform boundaries

## Official References

- Java language changes summary: https://docs.oracle.com/en/java/javase/25/language/java-language-changes-summary.html
- JDK 17: https://openjdk.org/projects/jdk/17/
