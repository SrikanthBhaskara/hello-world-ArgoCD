# Maven Deep Notes

These notes focus on what a Java developer should understand about Maven from beginner to senior-developer level. Interviewers usually start with commands and lifecycle phases, but for 5 to 7 years roles they expect you to reason about dependency hygiene, build reliability, CI integration, and release safety.

## 1. What Maven Is

Maven is a build and dependency management tool for Java projects.

It helps teams standardize:
- project structure
- dependency resolution
- compilation
- testing
- packaging
- plugin-driven build behavior

Important point:
- Maven is not just a command runner
- Maven gives structure and repeatability to Java builds

## 2. Standard Maven Project Layout

Typical structure:

```text
src/
  main/
    java/
    resources/
  test/
    java/
    resources/
pom.xml
```

Why useful:
- shared conventions reduce custom build scripts
- tools integrate more easily
- developers can move across projects faster

## 3. What `pom.xml` Really Does

`pom.xml` defines:
- project identity
- packaging type
- dependencies
- plugins
- build configuration
- profiles
- parent inheritance

Simple example:

```xml
<project>
  <modelVersion>4.0.0</modelVersion>
  <groupId>com.example</groupId>
  <artifactId>order-service</artifactId>
  <version>1.0.0</version>
  <packaging>jar</packaging>
</project>
```

## 4. Coordinates

Every Maven artifact is identified by:
- `groupId`
- `artifactId`
- `version`

Example:

```xml
<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-web</artifactId>
  <version>3.3.1</version>
</dependency>
```

## 5. Maven Lifecycle

Common lifecycle phases:
- `validate`
- `compile`
- `test`
- `package`
- `verify`
- `install`
- `deploy`

Meaning:
- `compile` compiles source
- `test` runs unit tests
- `package` creates jar or war
- `verify` runs additional checks
- `install` installs artifact to local repository
- `deploy` publishes artifact to remote repository

Interview answer:
- I explain Maven lifecycle as a standard contract for build progression, so all teams and tools do not invent different scripts for compile, test, package, and publish behavior.

## 6. Common Commands

```bash
mvn clean
mvn compile
mvn test
mvn package
mvn verify
mvn install
mvn dependency:tree
```

What they are used for:
- `clean` removes previous build output
- `test` runs tests up to test phase
- `package` builds distributable artifact
- `verify` is useful for stricter CI checks
- `dependency:tree` helps inspect transitive dependencies

## 7. Dependencies and Repositories

Maven resolves dependencies from repositories such as:
- Maven Central
- internal artifact repositories
- company-hosted proxies

Important points:
- direct dependencies are what you declare
- transitive dependencies come through other dependencies
- dependency conflicts can create runtime issues

## 8. Transitive Dependencies

Example problem:
- Project depends on library A
- Library A depends on library B version 1
- Another dependency brings library B version 2

This can cause:
- compilation mismatch
- runtime method-not-found issues
- classpath confusion

Useful command:

```bash
mvn dependency:tree
```

Interview answer:
- I use `mvn dependency:tree` to inspect where a conflicting library version comes from, then I decide whether to use exclusions or explicit dependency management to control the version safely.

## 9. Dependency Management

`dependencyManagement` helps centralize versions.

Example:

```xml
<dependencyManagement>
  <dependencies>
    <dependency>
      <groupId>org.junit.jupiter</groupId>
      <artifactId>junit-jupiter</artifactId>
      <version>5.10.2</version>
    </dependency>
  </dependencies>
</dependencyManagement>
```

Why useful:
- version consistency
- easier upgrades
- less repeated version declaration

## 10. Exclusions

Sometimes a dependency brings an unwanted transitive library.

Example:

```xml
<dependency>
  <groupId>com.example</groupId>
  <artifactId>legacy-client</artifactId>
  <version>1.2.0</version>
  <exclusions>
    <exclusion>
      <groupId>commons-logging</groupId>
      <artifactId>commons-logging</artifactId>
    </exclusion>
  </exclusions>
</dependency>
```

Use exclusions carefully:
- they solve classpath issues
- they can also break expected runtime behavior if used blindly

## 11. Plugins

Maven behavior is plugin-driven.

Common plugins:
- compiler plugin
- surefire plugin
- failsafe plugin
- jar plugin
- spring-boot plugin
- sonar plugin

Example compiler plugin:

```xml
<plugin>
  <groupId>org.apache.maven.plugins</groupId>
  <artifactId>maven-compiler-plugin</artifactId>
  <version>3.11.0</version>
  <configuration>
    <source>17</source>
    <target>17</target>
  </configuration>
</plugin>
```

## 12. Surefire vs Failsafe

This is a very common interview topic.

### Surefire

Usually runs unit tests in `test` phase.

### Failsafe

Usually runs integration tests in:
- `integration-test`
- `verify`

Why separation matters:
- unit tests stay fast
- integration tests can run with heavier setup
- CI pipelines can structure feedback more clearly

## 13. Profiles

Profiles allow environment-specific or conditional behavior.

Example:

```xml
<profiles>
  <profile>
    <id>prod</id>
    <properties>
      <env.name>prod</env.name>
    </properties>
  </profile>
</profiles>
```

Activate:

```bash
mvn clean package -Pprod
```

Use carefully:
- profiles are useful
- too many hidden profile differences can make builds harder to reason about

## 14. Parent POM and Multi-Module Projects

Larger projects often use:
- parent POM
- child modules

Example:

```xml
<packaging>pom</packaging>
<modules>
  <module>api</module>
  <module>service</module>
  <module>integration-tests</module>
</modules>
```

Why useful:
- shared plugin versions
- shared dependency management
- build consistency across modules

## 15. Maven in CI/CD

Typical CI use:
1. checkout code
2. `mvn clean verify`
3. run quality analysis
4. package artifact
5. publish artifact or container image

Important CI ideas:
- keep builds reproducible
- fail fast
- avoid hidden local-only dependencies
- make logs readable

Interview answer:
- Maven is the backbone of Java CI because it standardizes compile, test, package, and plugin execution. A strong pipeline uses Maven not only to build artifacts but also to make delivery predictable and auditable.

## 16. Common Maven Problems

Common issues:
- dependency conflict
- plugin version mismatch
- build works locally but fails in CI
- wrong Java version
- stale local repository issue
- transitive dependency surprise

Debugging approach:
1. read exact phase of failure
2. inspect dependency tree if classpath looks suspicious
3. confirm Java version and plugin compatibility
4. compare local and CI environment
5. clean local cache only when justified

## 17. Best Practices

- use clear parent and dependency management
- pin important plugin versions
- separate unit and integration test execution clearly
- avoid unnecessary dependency sprawl
- keep build reproducible in CI
- review dependency tree during upgrades

## 18. What Different Experience Levels Should Know

### 0 to 2 years

Should know:
- what Maven is
- what `pom.xml` does
- common lifecycle phases
- basic commands like `test`, `package`, `clean`
- how to add dependencies

### 2 to 4 years

Should know:
- transitive dependencies
- plugin purpose
- profiles
- multi-module basics
- dependency conflict handling
- Surefire vs Failsafe

### 4 to 7 years

Should know:
- dependency hygiene and upgrade strategy
- plugin version standardization
- CI build stability
- reproducible builds
- how to reduce build time and failure noise
- how to review blast radius of dependency or plugin changes

If you can explain those with examples, your Maven knowledge will sound much more real and project-tested.
