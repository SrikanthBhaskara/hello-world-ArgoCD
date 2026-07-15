# Practical Backend and API Interview Questions for 5 to 7 Years Experience

## Purpose
This file contains practical backend and API interview questions for engineers with 5 to 7 years of experience. It focuses on real implementation thinking, tradeoffs, reliability, and production-safe behavior.

## 1. API Design Questions

### 1. How do you design a clean REST API?
Answer:
I use clear resource-oriented URLs, meaningful HTTP methods, predictable request and response structures, proper status codes, validation, and structured error responses. I also try to separate transport concerns from business logic so the API remains maintainable.

### 2. What is idempotency, and why does it matter?
Answer:
Idempotency means repeating the same operation produces the same result after the first successful application. It matters for retries, distributed systems, and reliability, especially when requests may be repeated because of timeouts or network errors.

### 3. How do you version an API?
Answer:
I version an API when changes can break existing clients. Common approaches include versioning in the URL or header. The main goal is to evolve the API safely without surprising existing consumers.

### 4. How do you design error responses?
Answer:
I keep them structured and predictable. They should include an error code, human-readable message, and enough context for clients to understand the failure. Internal implementation details should not be exposed unnecessarily.

## 2. Backend Reliability Questions

### 1. How do you make a backend service reliable?
Answer:
I focus on clear contracts, validation, safe error handling, observability, timeouts, retries where appropriate, dependency isolation, and rollback-safe deployment practices. Reliability also depends on handling partial failures gracefully.

### 2. How do you handle timeouts and retries?
Answer:
I set timeouts intentionally so a request does not wait forever. I use retries only when the operation is safe or idempotent, and I avoid retry storms by using limits and backoff strategies.

### 3. What is the difference between synchronous and asynchronous backend processing?
Answer:
Synchronous processing keeps the client waiting for completion. Asynchronous processing allows the request path to return earlier while the work continues separately. Async improves responsiveness, but it adds complexity around tracking, retries, and observability.

### 4. When would you use a queue?
Answer:
I would use a queue when work is slow, independent, retryable, or should be decoupled from the user-facing request. Queues are useful for background jobs, notifications, heavy processing, and workload smoothing.

## 3. Data and Database Questions

### 1. How do you debug a slow database-backed API?
Answer:
I check query count, query plan, missing indexes, large result sets, N+1 query patterns, connection pool usage, and whether the API is doing unnecessary data transformation. I try to identify whether time is spent in the database, application layer, or dependency calls.

### 2. When do you choose SQL versus NoSQL in backend systems?
Answer:
I choose SQL when strong relationships, structured transactions, and consistency are important. I choose NoSQL when schema flexibility, large-volume semi-structured data, or distributed scalability matters more than relational querying.

### 3. What is a connection pool, and why does it matter?
Answer:
A connection pool keeps reusable connections available so the service does not create a new database connection for every request. This improves performance and reduces overhead under load.

## 4. Security and API Safety Questions

### 1. What is the difference between authentication and authorization?
Answer:
Authentication verifies identity. Authorization decides what that identity is allowed to do. Both are necessary for a secure backend system.

### 2. What backend security issues do you watch for?
Answer:
I watch for input validation gaps, injection risks, broken auth checks, insecure error handling, missing rate limiting, weak secrets management, unsafe logging of sensitive data, and dependency vulnerabilities.

### 3. How do you protect APIs from abuse?
Answer:
I use authentication, authorization, rate limiting, validation, request size limits, logging, and monitoring. For sensitive operations, I also consider auditability and stronger access controls.

## 5. Scenario-Based Backend Questions

### 1. An API returns 200 but wrong business data. How do you investigate?
Answer:
I verify the input, business logic path, database reads, caching behavior, dependency responses, and transformation layers. A technically successful status code does not mean the business result is correct.

### 2. A new deployment causes a spike in 500 errors. What do you check first?
Answer:
I correlate the error spike with the deployment timing, then inspect logs, changed configuration, dependency health, request patterns, and any rollout conditions or feature flags. I check whether rollback is needed while investigation continues.

### 3. A backend endpoint is stable in test but unstable in production. What differences matter?
Answer:
Differences in traffic volume, concurrency, permissions, timeouts, dependency behavior, data shape, security settings, and environment configuration can all matter. Production issues often come from conditions not present in smaller test environments.

## 6. Strong Backend Interview Answer Style
- Explain the concept clearly.
- Show where it matters in a real service.
- Mention tradeoffs like consistency, latency, maintainability, or failure handling.
- Talk about debugging and validation, not only implementation.

## 7. Quick Revision Topics
- REST API design
- Idempotency
- Status codes
- Timeouts and retries
- Queues and async work
- SQL vs NoSQL
- Connection pooling
- Authentication vs authorization
- Input validation and backend security
- Observability and safe deployments

## Final Note
For 5 to 7 years experience, backend interviews usually test whether you can design APIs and services that behave correctly under real production conditions, not just whether you know the terminology.