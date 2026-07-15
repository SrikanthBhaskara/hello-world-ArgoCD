# Spring Core and Bean Management Deep Notes

This note focuses on Spring Core concepts that often appear in backend interviews and real projects.

---

## 1. IoC and Dependency Injection

Spring's core value is **Inversion of Control**.

Instead of classes creating dependencies directly, the container manages object creation and wiring.

### Why this matters

- lower coupling
- easier testing
- clearer replacement of implementations
- more maintainable architecture

### Constructor injection example

```java
@Service
public class PaymentService {
    private final PaymentGateway paymentGateway;

    public PaymentService(PaymentGateway paymentGateway) {
        this.paymentGateway = paymentGateway;
    }
}
```

### Why constructor injection is preferred

- required dependencies are explicit
- fields can be final
- simpler unit tests
- avoids hidden wiring

---

## 2. Bean Lifecycle

Typical bean flow:

1. Spring discovers bean definition
2. dependencies are resolved
3. bean is instantiated
4. post-processing happens
5. init callbacks run
6. bean is used
7. destroy callbacks run during shutdown

Useful lifecycle annotations:

- `@PostConstruct`
- `@PreDestroy`

---

## 3. `@Component`, `@Service`, `@Repository`, `@Controller`

These are stereotypes for Spring-managed beans.

### Usage intent

- `@Component`: generic bean
- `@Service`: business logic
- `@Repository`: persistence/data access
- `@Controller` / `@RestController`: web layer

### Why intent matters

The annotations are not just syntax. They help keep architectural boundaries clear for teams.

---

## 4. Bean Scope

Common scopes:

- singleton
- prototype
- request
- session

### Interview point

Most backend beans are singleton by default. If mutable state is placed in singleton beans carelessly, concurrency bugs can appear.

---

## 5. Configuration Classes and `@Bean`

Use `@Configuration` and `@Bean` when:

- a class is from an external library
- you need fine-grained configuration
- direct annotation-based component scanning is not enough

Example:

```java
@Configuration
public class AppConfig {

    @Bean
    public ObjectMapper objectMapper() {
        return new ObjectMapper();
    }
}
```

---

## 6. Auto-Configuration vs Manual Configuration

Spring Boot auto-configuration reduces setup effort, but senior engineers still need to know:

- what was configured
- why it was configured
- how to override it safely

### Strong answer

Auto-configuration helps speed, but I do not rely on it blindly in production. I verify important beans, defaults, and security-sensitive behavior explicitly.
