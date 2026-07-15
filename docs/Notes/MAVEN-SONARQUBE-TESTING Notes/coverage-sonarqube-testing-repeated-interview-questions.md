# Code Coverage, SonarQube, and Testing Repeated Interview Questions

These are the kinds of testing and quality questions that come up very often for Java backend and DevOps-aware developer interviews from around 2 to 7 years of experience.

Use this file when you want focused revision on:
- code coverage
- test quality
- flaky tests
- SonarQube quality gates
- release confidence
- practical testing tradeoffs

## 1. What is code coverage?

Short answer:
Code coverage measures how much of the code is executed by automated tests.

Better answer:
Code coverage is a testing metric that shows which parts of the codebase were executed while tests ran. It helps identify untested areas, but it should be treated as a signal, not proof that the code is correct.

## 2. Is 100 percent coverage always good?

Short answer:
No. High coverage alone does not guarantee quality.

Better answer:
I do not treat 100 percent coverage as the goal by itself. A project can show very high coverage and still miss important bugs if assertions are weak or tests only execute code without validating meaningful behavior. I care more about critical-path coverage and test quality than chasing a vanity number.

## 3. What is the difference between line coverage and branch coverage?

Short answer:
Line coverage checks whether lines ran, while branch coverage checks whether different decision paths were tested.

Better answer:
Line coverage tells us whether a line executed at least once. Branch coverage goes deeper by checking whether both true and false decision paths were exercised. Branch coverage usually gives stronger confidence for conditional business logic.

## 4. Why can high code coverage still miss bugs?

Short answer:
Because execution is not the same as validation.

Better answer:
Coverage only tells me code was touched, not that behavior was correctly asserted. A test may execute many lines and still miss incorrect output, broken edge cases, missing negative-path checks, or flawed business rules. That is why I focus on assertion quality and important scenarios, not just the percentage.

## 5. What is a good code coverage target?

Short answer:
There is no single universal number.

Better answer:
I prefer practical thresholds based on risk and code type. Core business logic should usually have strong coverage, while simple DTOs or framework wiring do not always need the same focus. I use coverage thresholds as guidance, then prioritize critical behavior, regressions, and failure-prone areas.

## 6. How do you improve coverage without writing useless tests?

Short answer:
Focus on business logic, edge cases, and meaningful assertions.

Better answer:
I start by identifying important logic that is untested, especially branching rules, validations, calculations, and failure paths. Then I add focused tests with clear assertions instead of writing superficial tests that only increase the percentage.

## 7. What is a quality gate in SonarQube?

Short answer:
A quality gate is a pass or fail policy based on configured quality conditions.

Better answer:
A quality gate is an automated decision point in SonarQube. It evaluates things like coverage on new code, blocker issues, vulnerabilities, duplication, or maintainability thresholds. If the gate fails, the CI pipeline can block promotion until the issues are reviewed or fixed.

## 8. How does SonarQube use code coverage?

Short answer:
SonarQube reads coverage reports and includes them in quality analysis.

Better answer:
SonarQube itself does not generate all coverage data directly. Usually the test framework and coverage tool produce reports, and SonarQube consumes those reports to show coverage trends and evaluate rules such as minimum new-code coverage.

## 9. What is the difference between code coverage and code quality?

Short answer:
Coverage is one metric, while code quality is much broader.

Better answer:
Coverage only tells me how much code tests executed. Code quality includes correctness, readability, maintainability, security, duplication, complexity, and reliability. That is why a healthy engineering process combines tests, code review, static analysis, and production feedback instead of relying on one metric.

## 10. What is flaky testing?

Short answer:
A flaky test passes and fails inconsistently without real code changes.

Better answer:
A flaky test is dangerous because it reduces trust in CI. Once people stop believing failures are meaningful, real bugs can slip through. I treat flaky tests as a quality problem and try to make them deterministic by removing timing assumptions, shared state, and unstable dependencies.

## 11. Why are flaky tests dangerous?

Short answer:
They reduce trust in the pipeline.

Better answer:
Flaky tests create noise, slow delivery, and make teams ignore failures. Over time that erodes the value of CI itself because developers no longer know whether a red build means a real defect or just another random failure.

## 12. How do you debug flaky tests?

Short answer:
I try to make the failure reproducible and then remove nondeterministic behavior.

Better answer:
I start by checking whether the test depends on timing, shared data, random input, external services, or execution order. Then I reduce those variables by using controlled test data, isolated setup, predictable clocks, and smaller dependency scope until the test becomes deterministic.

## 13. What types of tests should a backend service have?

Short answer:
Unit tests, integration tests, and a selective number of API or end-to-end tests.

Better answer:
I usually want many fast unit tests for business logic, targeted integration tests for persistence or framework wiring, API-level tests for contract behavior, and only a small number of end-to-end tests for critical flows. The goal is confidence with manageable execution time and maintenance cost.

## 14. What is the difference between unit test, integration test, and end-to-end test?

Short answer:
Unit tests isolate logic, integration tests validate component interaction, and end-to-end tests validate full workflows.

Better answer:
Unit tests are best for fast feedback on isolated logic. Integration tests verify real framework or dependency behavior such as database interaction or serialization. End-to-end tests validate full user or system journeys across multiple components, but they are slower and more expensive to maintain.

## 15. What is mocking and when should you use it?

Short answer:
Mocking isolates the unit under test from external dependencies.

Better answer:
I use mocks when I want unit tests to focus on business logic without depending on a real database, external API, or slow service. But I avoid over-mocking because that can make tests too coupled to implementation details and less representative of real behavior.

## 16. What are common testing anti-patterns?

Short answer:
Over-mocking, weak assertions, too many brittle end-to-end tests, and environment-dependent tests.

Better answer:
Some of the worst patterns are chasing coverage without meaningful assertions, testing implementation details instead of behavior, allowing flaky suites to remain unresolved, and building pipelines with too many slow tests that developers start bypassing mentally.

## 17. What is test pyramid thinking?

Short answer:
It means many unit tests, fewer integration tests, and very selective end-to-end tests.

Better answer:
The idea is to maximize fast, reliable feedback at the lower layers and use heavier tests only where they provide real additional confidence. That keeps pipelines efficient while still protecting important integration points and workflows.

## 18. Should low code coverage always fail the pipeline?

Short answer:
Not always in a simplistic way.

Better answer:
I prefer thoughtful quality gates rather than rigid blanket rules. For example, low coverage on newly added business logic may justify failure, but enforcing the same threshold blindly on all legacy code can create noise and resistance. The gate should improve quality, not become a checkbox game.

## 19. How do you explain coverage on new code versus overall coverage?

Short answer:
New-code coverage focuses on recent changes, while overall coverage includes the whole codebase.

Better answer:
New-code coverage is often more practical because it improves quality incrementally without forcing teams to solve all legacy debt at once. It encourages developers to keep new work clean while allowing broader improvement over time.

## 20. What do you do when SonarQube reports issues but the code seems fine?

Short answer:
I review the rule in context instead of ignoring it blindly.

Better answer:
I check whether it is a real bug, a maintainability concern, or a false positive. If it is valid, I fix it. If it is not meaningful in context, I document or suppress it carefully and, if the rule is repeatedly noisy, I recommend tuning the quality profile rather than normalizing blanket suppression.

## 21. What is the difference between code smell, bug, and vulnerability?

Short answer:
A code smell affects maintainability, a bug affects correctness, and a vulnerability affects security.

Better answer:
A code smell usually signals design or maintainability risk. A bug is likely incorrect behavior. A vulnerability is a security weakness that could be exploitable. Understanding the difference helps prioritize which findings are immediately dangerous and which are long-term quality concerns.

## 22. How do Maven, tests, and SonarQube work together in CI?

Short answer:
Maven runs the build and tests, and SonarQube analyzes quality using that build output and reports.

Better answer:
In a typical Java pipeline, Maven compiles the code, runs tests, and often generates coverage data. SonarQube then consumes that information to analyze quality, check rules, and enforce gates before packaging or promotion continues.

## 23. How do you know code is safe enough to release?

Short answer:
I do not rely on one signal. I look at tests, code review, static analysis, and runtime confidence together.

Better answer:
Release confidence comes from layered evidence: meaningful unit and integration tests, passing CI, clean or acceptable Sonar findings, code review, and awareness of operational impact. For critical changes, I also think about observability, rollback safety, and how the change behaves in production-like conditions.

## 24. What should a 5 to 7 years developer say differently on testing questions?

Short answer:
They should explain tradeoffs, not only definitions.

Better answer:
At 5 to 7 years, I am expected to explain why a test belongs at a certain layer, how to balance coverage and build time, how to reduce flaky CI noise, how to set practical quality gates, and how testing supports safe delivery rather than just satisfying process rules.

## 25. Strong Final Answer Pattern for These Questions

If you are asked any testing or coverage question, a strong answer usually includes:
- what the metric or concept means
- what it is useful for
- what its limitation is
- how you use it in real projects

Example:

“Code coverage is useful to identify untested areas, especially around new business logic, but I do not treat the number alone as proof of quality. I focus on meaningful assertions, critical-path behavior, and a balanced testing strategy across unit and integration levels. In CI, I use coverage and SonarQube as guardrails, not as substitutes for engineering judgment.”
