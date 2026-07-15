# Technical Interview Questions and Answers for 5 to 7 Years Experience

## Purpose
This document contains technical interview questions and answers for a software engineer with 5 to 7 years of experience. The questions are grouped by difficulty level: easy, intermediate, and difficult. The focus is on practical backend, API, debugging, system, database, and engineering concepts commonly asked in interviews.

## How to Use This File
- Start with the easy section to build confidence.
- Use the intermediate section to prepare for standard technical rounds.
- Use the difficult section to prepare for senior-level discussion, production debugging, and design-oriented interviews.

---

## Easy Level Questions

### 1. What is the difference between a process and a thread?
Answer:
A process is an independent running program with its own memory space. A thread is a smaller execution unit inside a process and shares memory with other threads in the same process. Processes provide better isolation, while threads are lighter and useful for concurrency.

### 2. What is the difference between a list and a tuple in Python?
Answer:
A list is mutable, which means it can be changed after creation. A tuple is immutable, which means it cannot be changed after creation. Lists are used when data needs updates, while tuples are useful for fixed values.

### 3. What is a REST API?
Answer:
A REST API is an HTTP-based interface used for communication between systems. It usually exposes resources through URLs and uses methods like GET, POST, PUT, and DELETE.

### 4. What is the difference between GET and POST?
Answer:
GET is used to retrieve data from a server. POST is used to send data to the server, usually to create or process something. GET is generally idempotent, while POST may change system state.

### 5. What is exception handling?
Answer:
Exception handling is a way to catch runtime errors and handle them safely, instead of letting the program crash unexpectedly.

### 6. What is indexing in a database?
Answer:
An index is a database structure that helps queries find rows faster. It improves read performance, but too many indexes can slow insert and update operations.

### 7. What is normalization?
Answer:
Normalization is the process of organizing tables to reduce duplicate data and improve consistency.

### 8. What is SQL vs NoSQL?
Answer:
SQL databases are relational and use structured schemas. NoSQL databases are more flexible and are often used for document, key-value, or large-scale distributed storage use cases.

### 9. What is multithreading?
Answer:
Multithreading means running multiple execution paths inside one process at the same time. It is useful for concurrency and responsiveness.

### 10. What is a deadlock?
Answer:
A deadlock happens when two or more threads or processes wait for each other indefinitely, so execution stops making progress.

---

## Intermediate Level Questions

### 1. How do you debug a production issue?
Answer:
I start by understanding the impact, logs, and failure symptoms. Then I check recent code or configuration changes, reproduce the issue if possible, and trace the affected code path. I narrow the root cause using evidence, not assumptions. After that, I implement the safest possible fix and validate deployment and rollback considerations.

### 2. What is the difference between concurrency and parallelism?
Answer:
Concurrency means managing multiple tasks in overlapping time periods. Parallelism means actually running multiple tasks at the same time, usually on multiple CPU cores. A system can be concurrent without being truly parallel.

### 3. What is idempotency in APIs?
Answer:
An operation is idempotent if performing it multiple times has the same result as performing it once. For example, setting a resource status to `active` multiple times should still leave it as `active`.

### 4. What are race conditions?
Answer:
A race condition happens when multiple threads or processes access shared data and the final result depends on the order of execution. This can lead to inconsistent or incorrect behavior.

### 5. What is the difference between horizontal scaling and vertical scaling?
Answer:
Vertical scaling means increasing the power of a single machine, such as adding CPU or memory. Horizontal scaling means adding more machines or instances to distribute load.

### 6. What is caching and what are its challenges?
Answer:
Caching stores frequently used data temporarily so it can be accessed faster. Challenges include stale data, invalidation complexity, memory usage, and maintaining consistency with the source of truth.

### 7. What is the difference between authentication and authorization?
Answer:
Authentication verifies who a user is. Authorization determines what that user is allowed to do.

### 8. How do you make code maintainable?
Answer:
I keep code simple, modular, readable, and focused on the root problem. I use meaningful naming, minimize unnecessary complexity, handle edge cases clearly, and avoid mixing unrelated responsibilities in the same function or class.

### 9. What is a connection pool?
Answer:
A connection pool is a set of reusable database or network connections maintained by an application. It improves performance by avoiding the cost of opening and closing a connection for every request.

### 10. What is the difference between optimistic and pessimistic locking?
Answer:
Optimistic locking assumes conflicts are rare and checks for changes before writing. Pessimistic locking prevents conflicts by locking the resource before modification.

### 11. What are HTTP status codes 200, 201, 204, 400, 401, 403, 404, and 500?
Answer:
- 200: Request successful
- 201: Resource created successfully
- 204: Request successful with no response body
- 400: Bad request
- 401: Unauthorized, authentication required
- 403: Forbidden, authenticated but not allowed
- 404: Resource not found
- 500: Internal server error

### 12. What is logging and what makes good logging?
Answer:
Logging records events that help monitor and debug a system. Good logging is structured, useful, non-noisy, and includes enough context such as request IDs, error details, and important state transitions.

---

## Difficult Level Questions

### 1. How would you handle a production issue that cannot be reproduced locally?
Answer:
I would gather logs, metrics, environment details, request patterns, configuration differences, and timing information. I would compare production behavior with non-production environments, identify what is unique in production, and add targeted diagnostics if needed. I would avoid guessing and only implement a fix when evidence supports the root cause.

### 2. How do you approach fixing a bug in a critical system without causing regressions?
Answer:
I first validate the exact root cause and understand the affected code path and adjacent flows. I prefer the smallest safe change that solves the actual issue. I then review edge cases, backward compatibility, rollback options, and operational impact. If needed, I document deployment precautions and additional monitoring steps.

### 3. How would you design an API that is reliable and easy to maintain?
Answer:
I would use consistent resource naming, clear request and response contracts, proper status codes, idempotent behavior where appropriate, versioning strategy, good validation, structured error responses, authentication, authorization, logging, and observability. I would also keep business logic separate from transport logic so the API remains maintainable over time.

### 4. What steps do you take during root cause analysis?
Answer:
I start with symptoms and impact, then collect logs, traces, and code-path information. I compare expected behavior with actual behavior, identify where the divergence starts, validate the hypothesis with evidence, and confirm whether the issue is code, configuration, dependency, or environment related. Finally, I document the root cause, fix, test scope, and prevention ideas.

### 5. How do you decide whether a problem should be solved in code, configuration, or process?
Answer:
I look at where the real failure originates. If the issue comes from incorrect runtime behavior, it may need a code fix. If the software is correct but deployed with the wrong values, configuration is the right place. If repeated incidents happen because steps are inconsistent or unclear, then process improvement may be needed. The goal is to fix the problem at the correct layer.

### 6. What are common causes of performance bottlenecks in backend systems?
Answer:
Common causes include inefficient queries, missing indexes, too much network latency, high lock contention, excessive serialization, poor caching strategy, blocking I/O, oversized payloads, memory pressure, or thread contention. The correct fix depends on finding where time is actually being spent.

### 7. How do you handle legacy code when implementing a fix?
Answer:
I first try to understand the intent and behavior of the existing logic instead of rewriting blindly. Then I isolate the minimal area that needs change, preserve compatible behavior where necessary, and avoid broad refactors unless they are justified. In legacy systems, safe incremental change is often better than aggressive rewrites.

### 8. What is eventual consistency and where is it acceptable?
Answer:
Eventual consistency means data may not be immediately consistent across all nodes, but it becomes consistent over time. It is acceptable in systems like analytics, feeds, or replicated caches, where temporary differences are acceptable. It is usually less suitable for financial or strongly transactional operations.

### 9. How would you explain a difficult bug fix to a non-technical stakeholder?
Answer:
I would avoid deep code details and explain the issue in terms of impact, cause, action taken, and outcome. For example: a system component was updating data in a risky way, which could create instability; we changed it to update only what was necessary, making the system safer and more stable.

### 10. How do you balance delivery speed with engineering quality?
Answer:
I balance them by understanding risk. For urgent fixes, I focus on solving the root cause with the smallest safe change. I avoid unnecessary redesign during incidents, but I still review regression risk, operational safety, and rollback readiness. Quality matters most when the change affects production-critical behavior.

### 11. What is backpressure in distributed or backend systems?
Answer:
Backpressure is a way of controlling the rate of incoming work when a system is overloaded. Instead of allowing unlimited requests or data flow, the system slows intake, queues work safely, or rejects excess load to stay stable.

### 12. What is the difference between synchronous and asynchronous processing?
Answer:
In synchronous processing, one step waits for the previous step to finish before continuing. In asynchronous processing, work can continue without waiting immediately for the previous operation to complete. Asynchronous designs improve throughput, but they also make debugging and error handling more complex.

---

## Scenario-Based Questions

### 1. A service becomes slow after a new deployment. What do you check first?
Answer:
I would check whether the slowdown correlates exactly with the deployment, then look at logs, metrics, latency graphs, error rates, configuration changes, resource usage, and dependency health. I would compare before and after behavior to identify what changed.

### 2. An API sometimes returns incorrect data, but not always. How do you investigate?
Answer:
I would check for race conditions, stale caches, inconsistent database reads, retry behavior, shared mutable state, and environment-specific differences. Intermittent issues usually require correlation across logs, timestamps, and specific request conditions.

### 3. A bug fix works in test but fails in production. What could be the reason?
Answer:
Possible reasons include different configuration, data volume, concurrency, dependencies, security settings, environment variables, permissions, network behavior, or missing production-only edge cases.

### 4. A query is slow in production. What steps do you take?
Answer:
I would inspect the query plan, check indexes, review join conditions, compare data volume, identify full table scans, and confirm whether recent schema or data changes affected performance. Then I would optimize based on evidence instead of guessing.

---

## Quick Revision Section

### Easy Topics to Revise
- Process vs thread
- List vs tuple
- REST API basics
- GET vs POST
- Exception handling
- Multithreading
- Deadlock
- SQL vs NoSQL
- Normalization
- Indexing

### Intermediate Topics to Revise
- Debugging production issues
- Concurrency vs parallelism
- Idempotency
- Race conditions
- Caching
- Authentication vs authorization
- Locking strategies
- Logging best practices

### Difficult Topics to Revise
- Root cause analysis
- Regression-safe bug fixing
- API design tradeoffs
- Performance bottlenecks
- Legacy code handling
- Eventual consistency
- Backpressure
- Synchronous vs asynchronous systems

## Final Tip
For 5 to 7 years of experience, technical interviews are usually not only about definitions. Interviewers often expect you to explain how concepts apply in real systems, how you debug actual problems, how you think about tradeoffs, and how safely you handle production-impacting changes.