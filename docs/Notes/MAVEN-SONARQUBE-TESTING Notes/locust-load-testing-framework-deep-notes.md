# Locust Load Testing Framework Deep Notes

## What Locust Is
- Locust is a Python-based load testing framework.
- It is used to simulate concurrent users against HTTP APIs, web applications, and custom protocols.
- Instead of defining tests in a GUI, you write user behavior in Python.
- That makes it flexible, version-controllable, and easy to integrate with CI/CD.

## When Teams Choose Locust
- When they want code-driven load testing.
- When the team is comfortable with Python.
- When they need custom request flows or dynamic test data.
- When they want to run tests locally, in containers, or in distributed mode.

## What Problem It Solves
- Validates whether the system can handle expected traffic.
- Finds bottlenecks before production.
- Measures response time, throughput, and failure rate.
- Helps compare behavior before and after architectural changes.

## Core Concepts

### User
- A user represents one simulated client.
- Each user executes tasks repeatedly.
- Different user classes can represent different traffic patterns.

### HttpUser
- `HttpUser` is used for HTTP and REST API testing.
- It provides a built-in HTTP client through `self.client`.

### Task
- A task is one user action.
- Example:
  - login
  - get products
  - create order
  - check status

### Wait Time
- Wait time controls think time between requests.
- This makes traffic more realistic than a tight loop.

### Weight
- Task weights define how often one task runs compared to another.
- This helps model realistic production mix.

## Basic Example

```python
from locust import HttpUser, task, between


class ApiUser(HttpUser):
    wait_time = between(1, 3)

    @task(3)
    def get_products(self):
        self.client.get("/api/products")

    @task(1)
    def create_order(self):
        payload = {
            "customerId": "cust-101",
            "itemId": "item-55",
            "quantity": 1
        }
        self.client.post("/api/orders", json=payload)
```

## Running Locust

### UI Mode
```bash
locust -f locustfile.py
```

- This starts the web UI, where you can enter:
  - host
  - number of users
  - spawn rate

### Headless Mode
```bash
locust -f locustfile.py --headless --host=http://localhost:8080 -u 100 -r 10 -t 5m
```

- `-u` means total users.
- `-r` means spawn rate per second.
- `-t` means test duration.

## Important Metrics
- requests per second
- average response time
- p95 response time
- p99 response time
- failure rate
- number of active users

Interview point:
- Senior interviewers usually care more about percentiles like p95 or p99 than simple averages.

## Response Validation
- Do not only send traffic.
- Validate correctness too.
- A fast system returning incorrect responses is still failing.

Example:

```python
@task
def get_health(self):
    with self.client.get("/actuator/health", catch_response=True) as response:
        if response.status_code != 200:
            response.failure("Health check failed")
```

## Authentication Example

```python
from locust import HttpUser, task, between


class AuthenticatedUser(HttpUser):
    wait_time = between(1, 2)

    def on_start(self):
        response = self.client.post("/login", json={
            "username": "demo",
            "password": "demo123"
        })
        token = response.json()["token"]
        self.client.headers.update({
            "Authorization": f"Bearer {token}"
        })

    @task
    def get_profile(self):
        self.client.get("/api/profile")
```

## Test Design Patterns

### Smoke Load Test
- Small load for a short time.
- Checks basic stability and no immediate failures.

### Baseline Test
- Measures current normal behavior under expected load.

### Stress Test
- Push beyond expected capacity to find the breaking point.

### Spike Test
- Increase users very quickly to observe recovery behavior.

### Soak Test
- Run for a long duration to find memory leaks, connection leaks, or degradation over time.

## Realistic User Flow Example
- login
- browse products
- add item to cart
- create order
- poll order status

This is often more valuable than isolated endpoint-only testing because it reflects actual business behavior.

## Distributed Mode

### Why Use It
- A single machine may not generate enough load.
- Distributed mode allows multiple workers to generate traffic together.

### Commands
Master:
```bash
locust -f locustfile.py --master
```

Worker:
```bash
locust -f locustfile.py --worker --master-host=<master-host>
```

## Custom Data and Correlation
- Use dynamic payloads for:
  - user ids
  - order ids
  - tokens
  - randomized search terms
- Keep correlation ids when testing distributed systems so logs can be traced later.

## Common Mistakes
- Testing only one endpoint instead of real flows.
- Not validating response content.
- Running load from a weak machine and blaming the application.
- Ignoring DB, cache, or downstream bottlenecks.
- Using unrealistic test data or no think time.
- Looking only at average latency.

## Locust in CI/CD
- Run smoke or baseline tests as part of pipeline gates.
- Avoid heavy long-duration tests on every commit.
- Good pipeline strategy:
  - PR: unit tests and functional tests
  - nightly: smoke or short load tests
  - pre-release: full performance suite

## Locust and Observability
- Best results come when load tests are combined with:
  - application metrics
  - JVM metrics
  - DB metrics
  - logs
  - traces

Interview-friendly point:
- A load test result is incomplete if you do not know where the bottleneck is.

## Example: Checking SLO Under Load
- Goal:
  - 500 concurrent users
  - p95 latency under 300 ms
  - error rate under 1 percent
- A good test plan clearly defines pass or fail criteria before execution.

## Advanced Example with Custom Request Naming

```python
from locust import HttpUser, task


class PaymentUser(HttpUser):
    @task
    def process_payment(self):
        payload = {
            "orderId": "ord-1001",
            "amount": 100,
            "currency": "USD"
        }
        self.client.post("/api/payments", json=payload, name="/api/payments")
```

- The `name` parameter helps group dynamic URLs or similar requests into one metric line.

## How to Answer in Interviews

### What is Locust?
Short answer:
It is a Python-based load testing framework used to simulate users and measure system performance.

Better answer:
Locust is a code-driven load testing framework where we model real user behavior in Python. I use it to simulate concurrent traffic, validate throughput and latency, and observe how the application, database, and dependencies behave under normal, peak, and failure conditions.

### Why use Locust instead of only Postman or unit tests?
Short answer:
Because functional correctness does not prove production performance.

Better answer:
Unit and API functional tests tell me whether the behavior is correct for one request. Locust tells me whether the system remains stable and responsive under concurrency, retries, connection pressure, and realistic traffic patterns. They solve different problems.

## What 5 to 7 Year Interviewers Expect
- You should know how to model realistic user journeys, not only raw requests.
- You should talk about percentiles, failure rate, saturation, and bottleneck analysis.
- You should explain how load tests fit into release safety, performance tuning, and incident prevention.
