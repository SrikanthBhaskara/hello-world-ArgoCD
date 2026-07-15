# Spring REST API Design Deep Notes

This note focuses on Spring MVC, request/response design, DTOs, validation, and exception handling.

---

## 1. REST Controller Design

Common annotations:

- `@RestController`
- `@RequestMapping`
- `@GetMapping`
- `@PostMapping`
- `@PutMapping`
- `@DeleteMapping`

### Good controller rule

Controllers should handle HTTP concerns, not core business logic.

---

## 2. DTOs vs Entities

### DTO

- API contract object
- request or response shape

### Entity

- persistence model
- ORM-focused data structure

### Why separation matters

- avoids leaking internal schema
- prevents serialization surprises
- keeps API contract stable

---

## 3. Validation

Use validation at the request boundary.

Common annotations:

- `@NotNull`
- `@NotBlank`
- `@Size`
- `@Email`
- `@Min`
- `@Max`

Example:

```java
public record CreateAccountRequest(
        @NotBlank String name,
        @Email String email
) {}
```

---

## 4. Exception Handling

Use centralized exception handling for stable API behavior.

Example:

```java
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(IllegalArgumentException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public Map<String, String> handleBadRequest(IllegalArgumentException ex) {
        return Map.of("error", ex.getMessage());
    }
}
```

### Good practice

- consistent error format
- no internal stack traces in response
- separate validation, business, and technical failures

---

## 5. API Design Tradeoffs

Strong backend answers should include:

- idempotency where relevant
- stable contracts
- pagination
- filtering and sorting patterns
- backward compatibility

### Senior-level point

Changing API contracts in production is not only a code change. It is a compatibility and rollout concern.
