# Testing Deep Notes

These notes focus on what software developers should know about testing up to 7 years of experience. Good interview answers are not just about naming test types. They show that you understand confidence, speed, isolation, failure diagnosis, and how testing supports safe delivery.

## 1. Why Testing Matters

Testing helps teams:
- validate behavior
- prevent regressions
- refactor more safely
- detect integration problems earlier
- release with more confidence

Important point:
- the goal of testing is confidence, not just numbers

## 2. Main Test Types

Common categories:
- unit tests
- integration tests
- API tests
- contract tests
- end-to-end tests
- smoke tests

Each gives a different kind of confidence.

## 3. Unit Testing

Unit tests validate small isolated behavior.

Good unit test traits:
- fast
- deterministic
- focused
- clear assertions
- independent of external systems

Example:

```java
class PriceCalculatorTest {
    @Test
    void shouldApplyDiscountWhenUserIsPremium() {
        PriceCalculator calculator = new PriceCalculator();

        BigDecimal result = calculator.finalPrice(new BigDecimal("100"), true);

        assertEquals(new BigDecimal("90"), result);
    }
}
```

Interview answer:
- I use unit tests for business logic because they provide fast and precise feedback. They should stay isolated from databases, network calls, and framework-heavy setup whenever possible.

## 4. Integration Testing

Integration tests verify interaction between components.

Examples:
- service and database
- controller and serialization
- repository and persistence layer
- message consumer and broker contract behavior

Why valuable:
- catches wiring and framework issues
- validates real component interaction

Tradeoff:
- slower than unit tests
- heavier setup

## 5. API Testing

API tests verify HTTP-level behavior.

Examples:
- status codes
- request validation
- response structure
- serialization
- error handling

Example topics to test:
- `200 OK` for success
- `400` for validation errors
- `404` for missing resources
- auth failure cases

## 6. End-to-End Testing

End-to-end tests validate full workflow across multiple components.

Examples:
- user creates order
- payment succeeds
- order status updates
- notification is sent

Use carefully:
- strongest broad confidence
- highest maintenance cost
- slowest feedback

Best practice:
- keep only critical flows at E2E level

## 7. Test Pyramid Thinking

Classic idea:
- many unit tests
- fewer integration tests
- very selective end-to-end tests

Why:
- fast feedback at lower layers
- targeted confidence at higher layers

Interview answer:
- I prefer a testing strategy where unit tests cover most business logic, integration tests validate framework behavior and external interaction points, and only critical journeys become end-to-end tests.

## 8. Assertions Matter More Than Coverage Alone

Weak tests often have:
- no meaningful assertions
- only “method runs” validation
- too much implementation coupling

Strong tests verify:
- correct result
- correct state transition
- correct failure behavior

## 9. Mocking

Mocking isolates the unit under test from dependencies.

Good use cases:
- external clients
- repositories in pure unit tests
- slow or nondeterministic collaborators

Bad use cases:
- mocking everything just to satisfy structure
- testing implementation details instead of behavior

Interview answer:
- I use mocks to isolate business logic and keep unit tests fast, but I avoid excessive mocking because it makes tests brittle and too tied to internal implementation.

## 10. Test Data and Determinism

Reliable tests need:
- controlled input
- predictable time handling
- isolated state
- no hidden dependence on execution order

Common causes of flakiness:
- shared mutable state
- random data without control
- real clock dependence
- network or external service dependence
- environment-specific assumptions

## 11. Flaky Tests

Flaky tests fail inconsistently.

Why dangerous:
- teams stop trusting CI
- real failures get ignored
- release speed slows down

How to fix:
1. reproduce reliably
2. remove timing assumptions
3. isolate shared state
4. reduce external dependency reliance
5. improve test setup/cleanup

## 12. Testing in Spring and Backend Services

Typical layers:
- unit tests for service logic
- repository integration tests
- controller tests
- selective full application tests

Good approach:
- choose the smallest test that gives the required confidence

## 13. Contract Testing

Contract tests validate that producer and consumer expectations match.

Why useful:
- catches integration drift early
- reduces fear of independent deployment

This is especially helpful in microservice environments.

## 14. Code Coverage

Coverage is useful, but incomplete.

Why:
- 90 percent coverage can still miss critical behavior
- poor assertions can inflate coverage

Better use:
- use coverage to identify risk gaps
- do not confuse coverage with correctness

## 15. CI-Friendly Testing Strategy

A strong CI-friendly strategy usually means:
- fast unit tests on every change
- focused integration tests in CI
- selective heavier tests where justified
- stable and readable reports

Goal:
- fast feedback without losing meaningful confidence

## 16. Example JUnit and Mockito Test

```java
@ExtendWith(MockitoExtension.class)
class OrderServiceTest {

    @Mock
    private OrderRepository repository;

    @InjectMocks
    private OrderService service;

    @Test
    void shouldSaveOrderWhenInputIsValid() {
        Order input = new Order("A123");

        service.create(input);

        verify(repository).save(input);
    }
}
```

What this demonstrates:
- isolated unit test
- dependency mocked
- interaction verified

## 17. What Makes a Good Test Suite

A good test suite is:
- fast enough to run often
- stable enough to trust
- expressive enough to understand failures
- broad enough to protect important behavior

## 18. Common Testing Anti-Patterns

Bad patterns:
- testing implementation details too heavily
- too many brittle end-to-end tests
- excessive mocking
- no negative-path testing
- environment-dependent tests
- shared test state

## 19. Debugging Failed Tests

Good debugging flow:
1. identify whether failure is deterministic
2. inspect assertion and test data
3. confirm whether code changed or environment changed
4. separate test bug from product bug
5. improve test clarity after fixing

## 20. What Different Experience Levels Should Know

### 0 to 2 years

Should know:
- what unit and integration tests are
- why tests matter
- basic JUnit structure
- clear assertions

### 2 to 4 years

Should know:
- mocking properly
- API and repository testing
- flaky test causes
- CI-friendly test design
- coverage limitations

### 4 to 7 years

Should know:
- testing strategy design for services
- balancing speed and confidence
- reducing CI noise
- deciding what belongs in unit vs integration vs E2E
- how to stabilize flaky suites
- how to explain testing tradeoffs to the team

If you can explain those with examples and practical judgment, your testing discussion will sound much stronger for developer interviews up to 7 years.
