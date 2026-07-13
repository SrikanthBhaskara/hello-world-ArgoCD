# Microservices / System Design Interview Notes with Answers: Beginner to 6 Years

## Purpose

This file prepares you for backend microservices and system-design style interviews with answer guidance that sounds clear and practical.

## Beginner (0 to 2 Years)

### 1. What is a microservice?
Short answer:
A microservice is a small independently deployable service focused on a specific business capability.

Better answer:
A microservice owns a focused responsibility, can be deployed independently, and communicates with other services over well-defined interfaces such as REST or messaging. The goal is not small size alone, but clear ownership and maintainability.

### 2. Difference between a monolith and microservices?
Short answer:
A monolith is one deployable unit, while microservices split functionality across multiple services.

Better answer:
A monolith can be simpler to build and operate early on, while microservices offer independent scaling and deployment at the cost of distributed-system complexity.

### 3. Why do teams use microservices?
Short answer:
For independent deployment, team autonomy, flexible scaling, and clearer service ownership.

Better answer:
Teams usually adopt microservices when a single codebase becomes too large or when different domains need different release cadences, scaling profiles, or ownership boundaries.

## Intermediate (2 to 4 Years)

### 4. What are the challenges of microservices?
Short answer:
They introduce network, observability, versioning, security, and deployment coordination complexity.

Better answer:
Microservices improve modularity, but they also create distributed-system concerns such as retries, timeouts, contract compatibility, configuration sprawl, and debugging across service boundaries.

### 5. What is service discovery?
Short answer:
Service discovery is the mechanism by which services find each other dynamically.

Better answer:
Instead of hardcoding hostnames or IPs, services rely on a registry or platform networking layer so consumers can locate the correct service endpoint even when instances change.

### 6. Why are APIs and contracts important in microservices?
Short answer:
Because the API is the boundary between services and teams.

Better answer:
Weak contracts create tight coupling, hidden assumptions, and risky deployments. Stable contracts reduce coordination overhead and allow services to evolve more safely.

### 7. What is an API gateway and when is it useful?
Short answer:
An API gateway is an entry layer that routes, secures, and sometimes aggregates requests for backend services.

Better answer:
Gateways are useful when many clients need a controlled entry point for authentication, rate limiting, routing, and traffic management. They should not become a place where core business logic grows uncontrollably.

### 8. What is eventual consistency?
Short answer:
It means different parts of the system may be temporarily out of sync but converge later.

Better answer:
Eventual consistency is common in distributed systems using asynchronous messaging or replication. It improves decoupling and resilience, but the business flow must tolerate temporary mismatch.

### 9. How do you handle failures between services?
Short answer:
Use timeouts, retries carefully, circuit breakers, idempotence, fallback behavior, and observability.

Better answer:
The main principle is to assume partial failure is normal. Good systems fail fast when appropriate, avoid retry storms, and surface enough telemetry to understand what happened.

### 10. Why is observability critical in microservices?
Short answer:
Because distributed systems are hard to debug with logs alone.

Better answer:
You need metrics, tracing, structured logs, health checks, and correlation IDs to understand request flow across services.

## Experienced (4 to 6 Years)

### 11. How do you decide whether a system should be microservices or a modular monolith?
Short answer:
Decide based on team structure, release independence needs, domain boundaries, and operational maturity.

Better answer:
Microservices are not automatically better. If the organization lacks good CI/CD, ownership clarity, and observability, a modular monolith may be a safer and cheaper choice.

### 12. How do you explain good service boundaries?
Short answer:
A good boundary follows business capability, clear ownership, and minimal runtime coupling.

Better answer:
The goal is cohesive internal logic, stable external contracts, and data ownership that does not force constant cross-service coordination.

### 13. How do you think about synchronous vs asynchronous communication?
Short answer:
Synchronous calls are simpler but more tightly coupled, while asynchronous messaging improves decoupling but adds eventual-consistency complexity.

Better answer:
I choose based on business need. Request-response flows often fit synchronous APIs. Workflows that tolerate delay or need resilience often fit asynchronous events or queues.

### 14. How do you avoid turning microservices into a distributed monolith?
Short answer:
Reduce chatty calls, keep ownership clear, avoid shared databases, and maintain stable contracts.

Better answer:
If every user request fans out across many tightly coupled services, the architecture becomes fragile. Strong boundaries and operational discipline matter more than simply having many repos.

### 15. How do you design for resilience?
Short answer:
Use timeouts, retries with care, idempotence, backpressure awareness, health checks, monitoring, and safe rollout patterns.

Better answer:
Resilience comes from assuming things will fail. Good designs degrade gracefully, recover predictably, and avoid cascading failure.

### 16. How would you explain your system-design experience from this project?
Short answer:
I worked on a multi-service cloud security platform with deployment automation and operational troubleshooting responsibilities.

Better answer:
The system involved multiple scanner and support services, CI/CD automation, secret delivery, Kubernetes deployment, and GitOps-style environment management. My role included both service readiness and platform-level troubleshooting.

### 17. What are common microservices anti-patterns?
Short answer:
Shared database coupling, over-fragmentation, weak observability, too many synchronous dependencies, and unclear ownership.

Better answer:
Another anti-pattern is extracting services too early before the team can operate them effectively. Architecture should match organizational maturity.

## System Design Discussion Prompts

### 18. How would you design a file-scanning platform with multiple backend engines?
Short answer:
Use a gateway or orchestration layer, clear scanner-service boundaries, secure secret handling, normalized results, and strong observability.

Better answer:
I would separate request intake, orchestration, engine execution, result aggregation, and audit or reporting responsibilities. I would also decide carefully which flows are synchronous versus asynchronous based on file size, response-time expectations, and engine cost.

### 19. How would you scale a system where some services are CPU-heavy and others are I/O-heavy?
Short answer:
Scale them independently based on workload profile.

Better answer:
CPU-heavy services usually need resource-aware horizontal scaling and careful concurrency control, while I/O-heavy services may benefit more from async processing, connection-pool tuning, or event-driven design. Splitting them into separate services allows different autoscaling and resource strategies.

### 20. How do you handle configuration and secrets across multiple services?
Short answer:
Externalize configuration and deliver secrets through secure centralized systems.

Better answer:
I avoid embedding environment-specific values in code or images. Config belongs in managed config layers, and secrets should come from secret managers or operators that support rotation and access control.

### 21. How would you explain the difference between horizontal scaling and vertical scaling?
Short answer:
Horizontal scaling adds more instances, while vertical scaling increases resources on the same instance.

Better answer:
Horizontal scaling usually improves resilience and distributed throughput, while vertical scaling is simpler but has practical limits. Modern cloud-native services often prefer horizontal scaling when the workload supports it.

## Quick Revision Topics

- monolith vs microservices
- service boundaries
- observability
- resilience patterns
- synchronous vs asynchronous communication
- distributed-system tradeoffs
