# JUnit, Mockito, Cucumber, and Integration Testing Deep Notes

## Why This Topic Matters
- For 5 to 7 years experience, interviewers expect more than annotations and syntax.
- They want to know how you design fast tests, isolate failures, mock responsibly, and validate real integration behavior.

## Testing Pyramid
- unit tests: fastest, most isolated
- integration tests: verify interaction with DB, queue, HTTP, or framework wiring
- end-to-end tests: validate full business flow

Good answer:
- Keep the base wide with unit tests, use integration tests for critical wiring and persistence behavior, and keep end-to-end tests focused on highest-value journeys.

## JUnit

### What JUnit Is Used For
- test structure
- assertions
- lifecycle hooks
- parameterized tests
- nested tests

### Common Interview Topics
- `@BeforeEach` vs `@BeforeAll`
- parameterized tests
- assertThrows
- test naming and readability
- test isolation

Example:

```java
@ParameterizedTest
@ValueSource(strings = {"admin", "viewer", "editor"})
void shouldAcceptKnownRoles(String role) {
    assertTrue(RoleValidator.isSupported(role));
}
```

## Mockito

### When to Use It
- Mock external collaborators to isolate the unit under test.
- Good for repositories, HTTP clients, message publishers, and gateways.

### When Not to Overuse It
- Do not mock simple value objects.
- Do not turn every test into implementation-detail verification.
- Too many mocks usually indicate the class has too many responsibilities.

Example:

```java
@Test
void shouldRefundWhenShipmentFails() {
    when(paymentGateway.refund("pay-1")).thenReturn(true);

    boolean result = orderRecoveryService.handleShippingFailure("pay-1");

    assertTrue(result);
    verify(paymentGateway).refund("pay-1");
}
```

## JUnit vs Mockito
- JUnit provides the test framework.
- Mockito provides mocking and verification.
- They solve different problems and are commonly used together.

## Cucumber

### Why Teams Use It
- Express business behavior in readable scenarios.
- Bridge product, QA, and engineering language.
- Works well for acceptance tests and end-to-end business flows.

### Gherkin Example

```gherkin
Feature: Payment processing

  Scenario: Prevent duplicate payment on retry
    Given an existing idempotency key for order "123"
    When the client retries the payment request
    Then the API should return the original payment response
    And no second charge should be created
```

### When Cucumber Helps
- regulated flows
- cross-team acceptance criteria
- readable regression coverage

### When Cucumber Hurts
- if scenarios become UI-click automation noise
- if step definitions are too generic or fragile
- if teams duplicate every unit test in Cucumber

## Integration Testing

### What It Should Validate
- Spring wiring
- repository behavior
- SQL mappings
- serialization and deserialization
- HTTP contract
- message production and consumption

### What It Should Not Do
- replace all unit tests
- depend on brittle external environments for every run

## Spring Integration Test Example

```java
@SpringBootTest
@AutoConfigureMockMvc
class PaymentControllerIT {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void shouldReturnBadRequestForMissingCurrency() throws Exception {
        mockMvc.perform(post("/payments")
                .contentType("application/json")
                .content("{\"amount\":100}"))
            .andExpect(status().isBadRequest());
    }
}
```

## Testcontainers Interview Angle
- Good for integration tests with real dependencies like Postgres, Kafka, Redis.
- Better than mocking DB behavior for persistence-heavy code.
- Helps reduce "works on my machine" drift.

## Unit vs Integration Example

### Unit Test
- verify service computes final discount correctly using mocked repository

### Integration Test
- verify repository query returns correct rows from real Postgres schema

## Common Anti-Patterns
- asserting implementation details instead of behavior
- excessive mocking
- flaky async tests with `Thread.sleep`
- shared mutable test data across tests
- tests that pass locally but depend on execution order

## Async Testing Tips
- prefer polling utilities or latches over sleep
- verify eventual state with bounded waits
- keep timeout values realistic

## Coverage: What to Say
- High coverage does not guarantee good tests.
- Low coverage can still miss critical business paths.
- Coverage is a signal, not the goal.

Better interview answer:
- I use coverage to find untested areas, but I prioritize meaningful assertions around critical logic, boundary conditions, failure paths, and integration behavior rather than chasing a number blindly.

## What Interviewers Often Ask

### Difference between unit and integration testing?
Short answer:
Unit tests isolate one component; integration tests verify multiple components working together.

Better answer:
A unit test tells me my class logic is correct in isolation, usually with mocks for collaborators. An integration test tells me the real wiring, persistence, serialization, or external interaction behaves correctly. I want both because production failures often happen at the integration boundary.

### When should you use Mockito?
Short answer:
When you need to isolate the class under test from external collaborators.

Better answer:
I use Mockito when a dependency is slow, non-deterministic, or irrelevant to the behavior I am validating. I avoid over-mocking because that makes tests brittle and tied to implementation details instead of actual behavior.

### Where does Cucumber fit?
Short answer:
For business-readable acceptance scenarios, not for every low-level unit test.

Better answer:
Cucumber is strongest when the team needs shared, readable business scenarios for important workflows. I do not use it as a replacement for fast unit tests. I use it selectively for acceptance and regression coverage of key end-to-end flows.
