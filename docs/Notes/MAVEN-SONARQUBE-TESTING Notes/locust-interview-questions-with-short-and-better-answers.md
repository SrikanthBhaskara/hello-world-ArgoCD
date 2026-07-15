# Locust Interview Questions with Short and Better Answers

## 1. What is Locust?
Short answer:
Locust is a Python-based load testing framework used to simulate concurrent users and measure performance.

Better answer:
Locust is a code-first performance testing tool where we define user behavior in Python. It is useful for simulating realistic concurrent traffic, validating response times and throughput, and observing how the entire system behaves under load.

## 2. Why would you choose Locust?
Short answer:
Because it is flexible, scriptable, and easy to integrate into CI/CD.

Better answer:
I choose Locust when I want load tests as code, realistic workflow modeling, distributed execution, and easy integration with source control and automation pipelines. It works well for teams that want performance tests to evolve along with application code.

## 3. What is the difference between Locust and JMeter?
Short answer:
Locust is code-driven in Python, while JMeter is often UI and XML driven.

Better answer:
Both can do load testing, but Locust is especially strong when the team prefers test logic in code and wants maintainable, programmable behavior. JMeter is widely used and has a broad plugin ecosystem, but Locust often feels lighter and easier to version and customize for developers comfortable with Python.

## 4. What is `HttpUser` in Locust?
Short answer:
It is a user class for simulating HTTP traffic.

Better answer:
`HttpUser` is the base class I use when testing REST APIs or web endpoints. It provides `self.client`, which behaves like an HTTP client, so I can define tasks such as login, search, checkout, or health checks.

## 5. What is a task in Locust?
Short answer:
A task is one user action executed by a simulated user.

Better answer:
A task represents a business step like viewing products, creating an order, or checking status. By combining multiple tasks with weights and wait times, I can model realistic traffic instead of just sending isolated requests in a loop.

## 6. Why is wait time important?
Short answer:
It simulates think time and makes traffic more realistic.

Better answer:
Without wait time, users behave like bots firing requests continuously, which often exaggerates throughput and gives unrealistic patterns. I use wait time to better approximate real user pacing and avoid misleading results.

## 7. What is spawn rate?
Short answer:
It is how quickly Locust creates users during ramp-up.

Better answer:
Spawn rate controls how many simulated users are added per second. It matters because a system may behave very differently during gradual growth versus a sudden spike, so ramp-up strategy should match the scenario being tested.

## 8. What metrics do you look at in Locust?
Short answer:
RPS, response time, p95 or p99 latency, and failure rate.

Better answer:
I look at throughput, error rate, and latency percentiles, but I never stop there. I also correlate those with application, JVM, database, and infrastructure metrics so I can identify whether the bottleneck is CPU, threads, DB pool, cache, network, or a downstream dependency.

## 9. Why are percentiles important?
Short answer:
Because averages can hide slow requests.

Better answer:
Average latency can look healthy while a meaningful portion of users experience timeouts or delays. Percentiles such as p95 and p99 tell me whether tail latency is under control, which is usually more relevant for production user experience.

## 10. How do you validate responses in Locust?
Short answer:
Use `catch_response=True` and mark failures explicitly when needed.

Better answer:
I do not treat every HTTP 200 as success automatically. I validate important response fields, business states, and sometimes downstream effects. With `catch_response=True`, I can mark functional mismatches as failures even when the transport request succeeded.

## 11. How would you test an authenticated API?
Short answer:
Authenticate in `on_start` and reuse the token in later requests.

Better answer:
I usually log in during `on_start`, extract the token, and add it to the session headers for that simulated user. That gives a more realistic flow and avoids hardcoding static credentials into every request.

## 12. What types of performance tests can you run with Locust?
Short answer:
Smoke, baseline, stress, spike, and soak tests.

Better answer:
Locust can support different test goals. I use smoke tests to catch immediate instability, baseline tests for known load, stress tests to find failure points, spike tests for sudden traffic surges, and soak tests to expose degradation over time such as memory or connection leaks.

## 13. Can Locust run in distributed mode?
Short answer:
Yes, with master and worker processes.

Better answer:
Yes. When one machine is not enough to generate the required traffic, Locust can run in distributed mode using one master and multiple workers. That helps scale load generation and is useful for higher concurrency targets.

## 14. What is a common mistake in load testing?
Short answer:
Sending unrealistic traffic and assuming the results reflect production.

Better answer:
A common mistake is treating load testing as just increasing request count. If the scenario ignores realistic user journeys, authentication, think time, payload diversity, and downstream bottlenecks, the test can produce confident but misleading conclusions.

## 15. How would you use Locust in CI/CD?
Short answer:
Run small smoke tests in pipelines and reserve heavy tests for scheduled or release stages.

Better answer:
I would not run a large soak or stress test on every commit. In CI/CD I usually keep a small smoke or threshold-based performance gate, then run deeper performance suites nightly or before release so the signal stays useful and the pipeline stays fast.

## 16. How do you decide pass or fail for a Locust test?
Short answer:
Define latency, throughput, and error thresholds in advance.

Better answer:
I define acceptance criteria before the test, such as p95 under a target, failure rate below a threshold, and stable resource usage. A load test is only meaningful if success criteria are clear before execution, not after looking at the graph.

## 17. What if Locust shows poor response times?
Short answer:
Correlate it with backend metrics before assuming the root cause.

Better answer:
Locust only tells me the symptom from the client side. I would check application metrics, thread pools, DB connections, cache hit ratio, GC behavior, and dependency latency to identify the real bottleneck before proposing fixes.

## 18. How is load testing different from stress testing?
Short answer:
Load testing validates expected traffic; stress testing pushes past limits.

Better answer:
Load testing checks whether the system meets normal or planned demand. Stress testing intentionally pushes beyond that to observe failure behavior, bottlenecks, and recovery characteristics. Both are useful, but they answer different questions.

## 19. How would you model a realistic e-commerce flow in Locust?
Short answer:
Login, browse, add to cart, checkout, and order status checks with weighted tasks.

Better answer:
I would model the user journey, not just one endpoint. For example, users may browse far more often than they check out, so I would use weighted tasks, session state, dynamic data, and think time to reflect how production traffic actually behaves.

## 20. What would a strong senior answer sound like?
Short answer:
It connects Locust results to architecture, bottlenecks, and release safety.

Better answer:
At senior level, I would explain not only how to run Locust, but how to design scenarios, define SLO-driven thresholds, correlate failures with observability data, isolate bottlenecks, and use the findings to improve scaling, resilience, and production readiness.
