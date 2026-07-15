# Spring Testing Deep Notes

This note focuses on testing patterns that commonly appear in Spring Boot interviews and real backend systems.

---

## 1. Testing Layers in Spring

A good Spring test strategy usually has multiple layers:

- unit tests
- web-layer tests
- repository tests
- integration tests

### Why this matters

Using only one style of test is usually not enough. Fast tests validate logic, while integration-style tests validate wiring and runtime behavior.

---

## 2. Unit Tests

Unit tests focus on business logic without starting the Spring container.

Common tools:

- JUnit 5
- Mockito

Example:

```java
@ExtendWith(MockitoExtension.class)
class OrderServiceTest {

    @Mock
    private OrderRepository orderRepository;

    @InjectMocks
    private OrderService orderService;
}
```

### Strong point

Unit tests should validate logic, edge cases, and branching, not framework wiring.

---

## 3. `@SpringBootTest`

`@SpringBootTest` loads the full application context.

Use it when:

- full wiring matters
- configuration integration matters
- multiple layers must work together

### Tradeoff

It is powerful but slower than focused test slices.

---

## 4. `@WebMvcTest`

`@WebMvcTest` is for focused controller and MVC behavior testing.

It usually loads:

- controller layer
- MVC infrastructure

It does not load the full application by default.

### Common tool

- `MockMvc`

Example:

```java
@WebMvcTest(UserController.class)
class UserControllerTest {
}
```

---

## 5. `@DataJpaTest`

`@DataJpaTest` is for focused JPA and repository testing.

Use it when you want to validate:

- entity mapping
- repository behavior
- query correctness

### Strong interview point

Repository tests are useful when query correctness matters, especially for custom queries or non-trivial mapping behavior.

---

## 6. `MockMvc`

`MockMvc` is useful for testing:

- request routing
- validation behavior
- response status
- JSON structure

### Why interviewers like it

It shows that you can verify API behavior without always launching the whole application stack.

---

## 7. Testcontainers

Testcontainers helps run real dependencies for tests, such as:

- PostgreSQL
- MongoDB
- Kafka

### Why it matters

It reduces the gap between local tests and real runtime dependencies.

### Strong answer

I use Testcontainers when mocked behavior is not enough and I want higher confidence in integration behavior with real dependency semantics.

---

## 8. Common Testing Tradeoffs

### Fast tests

- easier to run often
- lower confidence in wiring and dependency behavior

### Full integration tests

- higher confidence
- slower and more operationally expensive

### Strong answer

I prefer a layered strategy: many small fast tests, then a smaller number of focused integration tests for higher-risk paths.

---

## 9. What Good Spring Tests Should Cover

- happy path
- invalid input
- exception mapping
- security restrictions
- transaction behavior where relevant
- repository query correctness
- integration with real config/dependency behavior where needed

---

## 10. Senior Testing Mindset

At 5 to 7 years, testing answers should include:

- which test type fits which risk
- what should be mocked vs real
- how to test rollback or failure cases
- how to keep tests trustworthy and maintainable

### Strong interview line

I do not optimize only for test count. I optimize for confidence, speed, and whether the test actually protects the risk that matters.
