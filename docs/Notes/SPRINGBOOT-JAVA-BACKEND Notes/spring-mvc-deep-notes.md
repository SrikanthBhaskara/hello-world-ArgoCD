# Spring MVC Deep Notes

This note focuses specifically on Spring MVC concepts used in backend service and web API development.

---

## 1. What Spring MVC Does

Spring MVC handles:

- request routing
- request binding
- validation
- response generation
- exception handling

For REST services, it is the part of Spring that maps HTTP requests to controller methods.

---

## 2. Core MVC Annotations

Common annotations:

- `@Controller`
- `@RestController`
- `@RequestMapping`
- `@GetMapping`
- `@PostMapping`
- `@PutMapping`
- `@DeleteMapping`
- `@PathVariable`
- `@RequestParam`
- `@RequestBody`

### Interview point

`@RestController` is effectively `@Controller` plus automatic response-body serialization.

---

## 3. Request Flow

Typical Spring MVC flow:

1. request comes in
2. DispatcherServlet receives it
3. handler mapping finds the controller method
4. request parameters/body are bound to method arguments
5. validation happens if enabled
6. controller returns response object
7. response is serialized and sent back

### Strong answer

Spring MVC is not just annotations on controllers. Under the hood, DispatcherServlet coordinates request routing, argument binding, and response handling.

---

## 4. `@Controller` vs `@RestController`

### `@Controller`

- used for MVC view-based applications
- often returns view names

### `@RestController`

- used for APIs
- returns serialized objects directly

### Practical meaning

In REST APIs, `@RestController` is usually the default choice.

---

## 5. Request Binding

Spring MVC can bind:

- path variables
- query parameters
- headers
- request bodies

Example:

```java
@GetMapping("/users/{id}")
public UserResponse getUser(
        @PathVariable Long id,
        @RequestParam(defaultValue = "false") boolean includeOrders
) {
    return userService.getUser(id, includeOrders);
}
```

---

## 6. Validation in MVC

Validation usually happens using `@Valid`.

Example:

```java
@PostMapping("/users")
public UserResponse createUser(@Valid @RequestBody CreateUserRequest request) {
    return userService.create(request);
}
```

### Why it matters

Validation belongs near the request boundary so bad input is rejected early and consistently.

---

## 7. ResponseEntity

`ResponseEntity` gives explicit control over:

- status code
- headers
- response body

Example:

```java
@DeleteMapping("/{id}")
public ResponseEntity<Void> delete(@PathVariable Long id) {
    userService.delete(id);
    return ResponseEntity.noContent().build();
}
```

---

## 8. MVC Exception Handling

Use centralized handling with:

- `@ControllerAdvice`
- `@RestControllerAdvice`

This helps return consistent error responses.

### Senior point

Good MVC design keeps happy-path controllers small and pushes cross-cutting error formatting into centralized handlers.

---

## 9. Common MVC Interview Questions

- how requests are routed
- difference between `@Controller` and `@RestController`
- request binding and validation
- exception handling
- file upload handling
- pagination and filtering patterns
- versioning and backward compatibility

---

## 10. Production Concerns in MVC

Strong answers should include:

- stable API contracts
- error response consistency
- validation and security at request boundary
- backward-compatible API changes
- observability using logs and correlation IDs
