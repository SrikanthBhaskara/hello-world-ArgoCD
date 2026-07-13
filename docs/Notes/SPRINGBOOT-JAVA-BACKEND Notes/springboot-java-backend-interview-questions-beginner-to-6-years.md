# Spring Boot / Java Backend Interview Questions with Answers: Beginner to 6 Years

## Purpose

This file prepares you for Spring Boot and Java backend interviews with strong answer guidance from beginner to around 6 years of experience.

## Beginner (0 to 2 Years)

### 1. What is Spring Boot?
Short answer:
Spring Boot is a framework that simplifies building production-ready Spring applications.

Better answer:
Spring Boot reduces boilerplate by providing auto-configuration, embedded servers, starter dependencies, externalized configuration, and production features like health endpoints. It helps teams build backend services faster with consistent structure.

### 2. Difference between Spring and Spring Boot?
Short answer:
Spring is the broader framework ecosystem, while Spring Boot simplifies configuration and setup for Spring applications.

Better answer:
Spring provides the core programming model and many modules like MVC, data, security, and dependency injection. Spring Boot builds on top of that to reduce setup effort and help teams create runnable applications faster with sensible defaults and starter-based configuration.

### 3. What is dependency injection?
Short answer:
Dependency injection is a way to provide objects to a class instead of the class creating them directly.

Better answer:
Dependency injection improves testability, modularity, and loose coupling. Instead of hardcoding object creation inside business classes, dependencies are provided from the framework container, which makes the code easier to replace, mock, and maintain.

### 4. What is an IoC container?
Short answer:
An IoC container manages object creation, wiring, lifecycle, and dependency resolution.

Better answer:
Inversion of Control means application objects are managed by the framework instead of each class constructing everything manually. In Spring, the container creates beans, resolves dependencies, applies configuration, and manages lifecycle behavior.

### 5. What is a REST API?
Short answer:
A REST API is an HTTP-based interface that exposes resources through endpoints and standard methods like GET, POST, PUT, and DELETE.

Better answer:
In backend systems, REST APIs are commonly used to expose business functionality to clients or other services. A good REST API uses consistent resource design, clear status codes, validation, and predictable request and response structures.

### 6. What are `@RestController` and `@RequestMapping` used for?
Short answer:
`@RestController` marks a class as a REST endpoint handler, and `@RequestMapping` defines URL mapping and request routing rules.

Better answer:
`@RestController` combines controller behavior with automatic response-body serialization. `@RequestMapping` or the method-level variants like `@GetMapping` and `@PostMapping` define how HTTP paths and methods map to Java methods.

### 7. Difference between `@Component`, `@Service`, and `@Repository`?
Short answer:
All are Spring-managed beans, but they communicate different intent: generic component, business service, and persistence-related component.

Better answer:
Technically they are similar in terms of bean registration, but they improve readability and architecture clarity. `@Service` signals business logic, `@Repository` signals data-access concerns, and `@Component` is more generic. Using the right stereotype helps code organization and team understanding.

### 8. What is `application.properties` or `application.yml` used for?
Short answer:
They are used to externalize configuration such as ports, database settings, feature values, and environment-specific properties.

Better answer:
Externalized configuration keeps code separate from deployment-specific values. This is important because applications should behave differently across dev, test, and production without code changes.

### 9. What is the purpose of `@SpringBootApplication`?
Short answer:
It is a convenience annotation that combines configuration, component scanning, and auto-configuration.

Better answer:
`@SpringBootApplication` is the standard starting point for a Spring Boot application. It reduces boilerplate by combining common annotations and signals that the application should use Boot's auto-configuration and component discovery model.

### 10. What is the difference between `GET`, `POST`, `PUT`, and `DELETE`?
Short answer:
GET reads data, POST creates or submits data, PUT updates or replaces data, and DELETE removes data.

Better answer:
The important part is not just naming the methods but using them consistently with API behavior. Good backend design uses HTTP methods to express intent, with clear status codes and predictable request structure.

## Intermediate (2 to 4 Years)

### 11. What is auto-configuration in Spring Boot?
Short answer:
Auto-configuration allows Spring Boot to configure common components automatically based on the classpath, beans, and properties.

Better answer:
It reduces manual setup by detecting what libraries are present and configuring common framework pieces accordingly. It is valuable because it speeds up development, but I still need to understand how to override or customize it when defaults are not enough.

### 12. What are Spring Boot starters?
Short answer:
Starters are dependency bundles that bring together a common set of libraries for a particular capability.

Better answer:
For example, `spring-boot-starter-web` provides the typical web stack needed for REST APIs. Starters reduce dependency-management complexity and help keep project setup consistent across teams.

### 13. How do you handle exceptions in a Spring Boot REST API?
Short answer:
I prefer centralized exception handling using `@ControllerAdvice` so the API returns consistent error responses.

Better answer:
Centralized exception handling keeps controller code clean and makes error responses predictable. It also helps separate validation errors, business errors, and unexpected technical failures while maintaining a stable API contract.

### 14. How do you validate request payloads?
Short answer:
I use bean validation with annotations like `@Valid` and return clear validation error responses.

Better answer:
Validation should happen close to the request boundary so bad input is rejected early and consistently. I typically use standard validation annotations, structured error responses, and centralized handling so clients know exactly which fields failed and why.

### 15. What is the difference between DTO and entity?
Short answer:
DTOs shape API or transport data, while entities represent persistence models.

Better answer:
Keeping DTOs separate from entities improves API stability, reduces accidental exposure of database structure, and helps the codebase evolve more cleanly. It also prevents external contracts from being too tightly coupled to persistence concerns.

### 16. What is the difference between `@Autowired` constructor injection and field injection?
Short answer:
Constructor injection is generally preferred because dependencies are explicit and easier to test.

Better answer:
Constructor injection makes required dependencies visible, supports immutability, and simplifies unit testing. Field injection hides dependencies and is harder to test or reason about cleanly, so I prefer constructor-based injection in production code.

### 17. How do you externalize configuration for different environments?
Short answer:
I use profile-based or environment-based configuration and keep sensitive values outside the codebase.

Better answer:
Applications should not require code changes just to move between environments. I use externalized configuration, environment overrides, profiles where appropriate, and secret-management patterns so dev, test, and production differ safely through configuration rather than branching source code.

### 18. How do you make a Spring Boot service observable?
Short answer:
I use structured logs, health checks, metrics, and where relevant tracing or correlation IDs.

Better answer:
A production-ready service must be diagnosable. That means useful logs, health endpoints, metrics, alert-friendly signals, and enough context to trace a request or incident across systems. Observability is part of service design, not an afterthought.

### 19. What is the difference between synchronous and asynchronous processing in a backend service?
Short answer:
Synchronous processing returns the result in the same request flow, while asynchronous processing defers work and often completes it later.

Better answer:
Synchronous processing is simpler when the caller needs the result immediately. Asynchronous processing is useful for long-running or decoupled work such as file processing, notifications, or background jobs. The right choice depends on latency needs, reliability, and workflow boundaries.

### 20. How do you secure sensitive configuration in a Spring Boot service?
Short answer:
Sensitive values should come from secret-management systems or runtime injection, not be hardcoded or committed to Git.

Better answer:
Security improves when secrets are managed externally and delivered at runtime in a controlled way. I avoid placing credentials in application source, properties files, or container images, and I combine external secret sources with least-privilege runtime access.

## Experienced (4 to 6 Years)

### 21. How do you design a clean Java backend service?
Short answer:
I separate controller, service, repository, DTO, configuration, and integration concerns clearly.

Better answer:
I keep business logic out of controllers, centralize error handling, separate internal models from external contracts, and make the service observable and testable. I also design for configuration clarity, runtime diagnosability, and maintainability under team growth.

### 22. How do you explain your Spring Boot and Java backend experience from this project?
Short answer:
I worked on Java 17 and Spring Boot services with focus on service readiness, configuration, deployment integration, and troubleshooting.

Better answer:
I worked on Java 17 and Spring Boot based scanner services and supporting deployment flows. My work included backend service readiness, endpoint and integration behavior, runtime configuration through secret systems, health validation, CI/CD integration, and Kubernetes deployment troubleshooting.

### 23. How do you choose between records, normal classes, and sealed hierarchies in modern Java backend code?
Short answer:
I use records for immutable transport models, normal classes for richer behavior or lifecycle needs, and sealed types for controlled closed hierarchies.

Better answer:
The choice depends on semantics, not syntax convenience. Records work well for immutable value-style models. Classes fit mutable or behavior-heavy types. Sealed hierarchies fit domains where only a limited set of variants should exist and be enforced explicitly.

### 24. How do you approach performance issues in a backend service?
Short answer:
I first identify whether the bottleneck is CPU, memory, I/O, database, remote calls, or concurrency design.

Better answer:
I avoid guessing and start with evidence. I use logs, metrics, traces, profiling, and runtime diagnostics to isolate whether the issue is application logic, allocation pressure, database latency, remote dependency slowness, or threading design. Optimization should be driven by actual bottlenecks.

### 25. What are common backend anti-patterns?
Short answer:
Common anti-patterns include fat controllers, leaking entities to APIs, hardcoded config or secrets, weak exception handling, and poor observability.

Better answer:
I also watch for business logic scattered across layers, too much hidden framework magic, poor contract boundaries, and overengineering that adds complexity without clear value. Strong backend design keeps ownership, contracts, and operational behavior understandable.

## Quick Revision Topics

- DI and IoC
- REST basics
- exception handling
- validation
- DTO vs entity
- constructor injection
- environment config
- secret handling
- Java 17+ modeling choices
