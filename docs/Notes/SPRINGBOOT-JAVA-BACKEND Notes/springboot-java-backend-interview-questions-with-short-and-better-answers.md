# Spring Boot and Java Backend Interview Questions with Short and Better Answers

This file focuses on interview-style answers for Spring Boot, backend engineering, and Spring Security.

---

## 1. What is Spring Boot?

Short answer:
Spring Boot is a framework that makes it easier to build production-ready Spring applications quickly.

Better answer:
Spring Boot reduces boilerplate by providing auto-configuration, starter dependencies, embedded servers, externalized configuration, and operational features like Actuator. It helps teams deliver backend services faster while still using the full Spring ecosystem.

## 2. What is the difference between Spring and Spring Boot?

Short answer:
Spring is the larger framework ecosystem, and Spring Boot simplifies building runnable Spring applications.

Better answer:
Spring provides core capabilities like dependency injection, web MVC, data access, AOP, and security. Spring Boot builds on top of Spring and reduces configuration effort with opinionated defaults and starter-based setup.

## 3. What is dependency injection?

Short answer:
Dependency injection means objects receive their dependencies from outside instead of creating them directly.

Better answer:
Dependency injection improves loose coupling, testability, and maintainability. In Spring, the container manages object creation and wiring, which makes services easier to replace, mock, and evolve.

## 4. Why is constructor injection preferred?

Short answer:
Constructor injection makes dependencies explicit and easier to test.

Better answer:
Constructor injection makes required dependencies visible, supports immutable fields, and reduces hidden framework behavior. It also makes unit testing cleaner because dependencies can be passed directly without reflection or field injection tricks.

## 5. What is auto-configuration?

Short answer:
Auto-configuration lets Spring Boot configure common components automatically based on the classpath and properties.

Better answer:
Spring Boot checks what libraries, beans, and configuration values are available and then applies sensible defaults. This reduces setup time, but strong engineers still understand how to override the defaults when needed.

## 6. What are Spring Boot starters?

Short answer:
Starters are dependency bundles for common capabilities like web, data, security, and testing.

Better answer:
Starters simplify dependency management. For example, `spring-boot-starter-web` brings in the typical web stack needed for a REST API. They help keep project setup more predictable across teams.

## 7. What is the use of `@SpringBootApplication`?

Short answer:
It combines configuration, component scanning, and auto-configuration into one annotation.

Better answer:
`@SpringBootApplication` is the main entry point for most Spring Boot apps. It reduces boilerplate and signals that Boot should scan components, apply configuration, and enable auto-configuration behavior.

## 8. What is the difference between `@Component`, `@Service`, and `@Repository`?

Short answer:
All are Spring-managed beans, but they represent different architectural intent.

Better answer:
`@Component` is generic, `@Service` is for business logic, and `@Repository` is for persistence concerns. Using the correct stereotype improves readability and keeps the architecture easier to understand.

## 9. What is a DTO and why do we need it?

Short answer:
A DTO is a data transfer object used to shape request or response payloads.

Better answer:
DTOs help separate API contracts from persistence models. This prevents accidental exposure of internal database structure, reduces serialization problems, and keeps API design more stable over time.

## 10. How do you validate request payloads?

Short answer:
I use bean validation with annotations like `@Valid`, `@NotNull`, and `@NotBlank`.

Better answer:
Validation should happen at the request boundary so bad input is rejected early and consistently. I usually combine bean validation, clear error messages, and centralized exception handling so clients get predictable responses.

## 11. How do you handle exceptions in a REST API?

Short answer:
I prefer centralized exception handling using `@RestControllerAdvice`.

Better answer:
Centralized exception handling keeps controllers clean and ensures the API returns consistent error responses. I separate validation failures, business exceptions, and unexpected technical failures so the contract stays stable and useful.

## 12. What is the role of `@Transactional`?

Short answer:
`@Transactional` defines a transaction boundary so related operations succeed or fail together.

Better answer:
It is used to maintain data consistency when multiple database operations belong to a single business action. I typically place transaction boundaries in the service layer and try to keep transactions small and focused.

## 13. What are common JPA performance issues?

Short answer:
Common issues include N+1 queries, unnecessary eager loading, missing indexes, and fetching too much data.

Better answer:
When JPA performance is poor, I first check query count, SQL execution plan, fetch strategy, pagination, and transaction scope. I avoid blaming JPA generically and look for the exact bottleneck.

## 14. What is Actuator and why is it useful?

Short answer:
Actuator provides production-friendly endpoints like health, metrics, and application info.

Better answer:
Actuator improves observability and operations. It helps with monitoring, health checking, debugging, and exposing runtime information that is useful in deployments and incident handling.

## 15. What is Spring Security?

Short answer:
Spring Security is the Spring module for authentication, authorization, and application security.

Better answer:
Spring Security protects applications through filter chains, authentication providers, password encoding, authorization rules, and support for sessions, tokens, and method-level access control. It is a core part of building secure APIs and web applications.

## 16. What is the difference between authentication and authorization?

Short answer:
Authentication verifies who the user is, and authorization decides what the user is allowed to do.

Better answer:
Authentication establishes identity, for example by validating credentials or a token. Authorization applies access rules after identity is known, such as checking roles or permissions for a given endpoint or method.

## 17. What is a `SecurityFilterChain`?

Short answer:
It defines how incoming requests are processed and secured in Spring Security.

Better answer:
The security filter chain is where request security rules, authentication behavior, session strategy, CSRF handling, and authorization checks are configured. It is one of the most important concepts in modern Spring Security configuration.

## 18. Why do we use a `PasswordEncoder`?

Short answer:
We use a password encoder to store hashed passwords instead of plain-text passwords.

Better answer:
Passwords must never be stored in plain text. A password encoder like BCrypt hashes passwords safely so the application can verify them during login without ever needing to decrypt stored password values.

## 19. What is JWT and when would you use it?

Short answer:
JWT is a token format commonly used for stateless API authentication.

Better answer:
JWT is useful when clients call APIs and the service wants to avoid server-side session storage. A token usually contains identity and authorization claims, and the server validates its signature and expiration on each request.

## 20. Why is CSRF often disabled in stateless APIs?

Short answer:
Because stateless token-based APIs usually do not rely on browser session cookies in the same way traditional web apps do.

Better answer:
CSRF primarily targets browser-based session workflows where credentials are sent automatically by the browser. In stateless APIs using bearer tokens, the threat model is different, so CSRF is often disabled intentionally while other protections remain in place.

## 21. What is the difference between role-based and method-level security?

Short answer:
Role-based security often protects endpoints, while method-level security protects business operations directly.

Better answer:
Path-based rules are useful at the HTTP layer, but method-level security adds protection closer to business logic. That makes the security model stronger if the same service method can be reached in multiple ways.

## 22. How would you secure a Spring Boot REST API?

Short answer:
I would secure it with authentication, authorization rules, password hashing, token or session strategy, validation, and careful endpoint exposure.

Better answer:
For an API, I typically think about secure authentication, principle of least privilege, token or session approach, input validation, actuator exposure, error handling, and secret management. I also make sure logs do not leak credentials and that health or admin endpoints are protected correctly.

## 23. What is the difference between `permitAll()` and `hasRole()`?

Short answer:
`permitAll()` allows anyone to access an endpoint, while `hasRole()` restricts access to users with a specific role.

Better answer:
`permitAll()` is useful for public endpoints like login or health checks when intended. `hasRole()` is used when access must be restricted, for example admin-only operations. The key is to apply those rules intentionally and minimally.

## 24. How do you approach backend performance issues?

Short answer:
I first identify whether the bottleneck is CPU, memory, database, remote calls, I/O, or concurrency design.

Better answer:
I avoid guessing and start with evidence from logs, metrics, traces, and query analysis. Once I know whether the issue is in the application, database, or external dependencies, I optimize the real bottleneck instead of doing random tuning.

## 25. How do you explain a clean backend architecture?

Short answer:
I separate controllers, services, repositories, DTOs, configuration, and exception handling clearly.

Better answer:
Clean backend design keeps HTTP concerns in controllers, business logic in services, persistence in repositories, and contracts in DTOs. It also includes security, observability, validation, transaction boundaries, and testing strategy as first-class design concerns.

## 26. What are common Spring Boot backend anti-patterns?

Short answer:
Fat controllers, leaking entities, weak exception handling, hardcoded secrets, and poor observability are common anti-patterns.

Better answer:
I also watch for hidden framework magic, unbounded transactions, poor separation of concerns, missing tests, and overengineering. Good backend design should be easy to reason about in production, not just compile successfully.

## 27. How would you answer experience-level questions for 5 to 7 years?

Short answer:
I would answer with ownership, tradeoffs, production thinking, and maintainability in mind.

Better answer:
At that level, interviewers expect more than definitions. They want to hear how you design APIs, secure services, handle incidents, optimize runtime behavior, choose between patterns, and guide maintainable architecture decisions under real constraints.

---

## Quick Revision Topics

- DI and IoC
- constructor injection
- auto-configuration and starters
- validation and exception handling
- DTO vs entity
- transactions
- JPA performance issues
- actuator and observability
- Spring Security basics
- JWT flow
- password encoding
- method-level authorization
