# Spring Boot Auto-Configuration and Configuration Deep Notes

This note focuses on Spring Boot auto-configuration, starters, conditional configuration, profiles, and externalized configuration.

---

## 1. What Auto-Configuration Does

Spring Boot auto-configuration configures common framework components automatically based on:

- classpath
- existing beans
- application properties

### Examples

- if web libraries are present, Boot can configure MVC defaults
- if datasource settings are present, Boot can configure database connectivity
- if Actuator is present, Boot can expose operational endpoints

### Strong interview answer

Auto-configuration reduces setup effort, but in production I still need to understand what beans and defaults Boot applied so I can override them safely when requirements differ.

---

## 2. Starters

Starters are dependency bundles for common capabilities.

Examples:

- `spring-boot-starter-web`
- `spring-boot-starter-data-jpa`
- `spring-boot-starter-security`
- `spring-boot-starter-actuator`
- `spring-boot-starter-test`

### Why they matter

Starters simplify dependency management and keep project setup more consistent across teams.

### Tradeoff

Starters save time, but they can also bring transitive dependencies and defaults that engineers must still understand.

---

## 3. Conditional Configuration

Boot often decides configuration using conditional annotations such as:

- `@ConditionalOnClass`
- `@ConditionalOnMissingBean`
- `@ConditionalOnProperty`
- `@ConditionalOnBean`

### Why this matters

This is part of how Boot avoids creating unnecessary beans and allows custom overrides.

### Strong interview point

If a bean is not being created or a default bean behaves differently than expected, conditional configuration is one of the first places to investigate.

---

## 4. Overriding Auto-Configuration

You can override Boot defaults by:

- defining your own bean
- changing configuration properties
- excluding specific auto-configurations

Example:

```java
@SpringBootApplication(exclude = DataSourceAutoConfiguration.class)
public class DemoApplication {
}
```

### Caution

Excluding auto-configuration should be done intentionally. Blind exclusions can break transitive behavior unexpectedly.

---

## 5. Externalized Configuration

Spring Boot supports configuration from:

- `application.properties`
- `application.yml`
- environment variables
- command-line arguments
- profile-specific files

### Why it matters

Applications should behave differently across environments without code changes.

---

## 6. Profiles

Profiles help activate environment-specific configuration.

Examples:

- `dev`
- `test`
- `prod`

Typical files:

- `application-dev.yml`
- `application-test.yml`
- `application-prod.yml`

### Good practice

Use profiles carefully. Too many profile combinations can make behavior hard to reason about.

---

## 7. `@ConfigurationProperties`

`@ConfigurationProperties` is useful for structured configuration binding.

Example:

```java
@ConfigurationProperties(prefix = "payment.gateway")
public class PaymentGatewayProperties {
    private String baseUrl;
    private int timeoutMs;

    public String getBaseUrl() {
        return baseUrl;
    }

    public void setBaseUrl(String baseUrl) {
        this.baseUrl = baseUrl;
    }

    public int getTimeoutMs() {
        return timeoutMs;
    }

    public void setTimeoutMs(int timeoutMs) {
        this.timeoutMs = timeoutMs;
    }
}
```

### Why it is better than scattered `@Value`

- cleaner grouping
- easier validation
- easier testing
- more maintainable for larger configs

---

## 8. Property Source Precedence

Spring Boot resolves configuration from multiple sources with precedence rules.

In interviews, the important idea is:

- local files are not the only configuration source
- environment variables and runtime overrides may win

### Real-world debugging example

If the application is using an unexpected port or database URL, I verify whether the value came from a profile file, environment variable, container env, Helm value, or runtime argument.

---

## 9. Secrets and Sensitive Configuration

Good practice:

- do not hardcode secrets
- do not commit secrets into Git
- load secrets from secure external systems or runtime injection

### Strong answer

Configuration design is also a security concern. I separate standard config from secrets and make sure secret delivery is environment-safe and auditable.

---

## 10. Production Configuration Concerns

Senior answers should include:

- environment parity
- secret handling
- safe override behavior
- clear rollback path
- observability of actual config values in use

### Strong interview line

I do not treat configuration as a simple file problem. In production, config is part of deployment behavior, secret handling, and rollback safety.
