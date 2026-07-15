# AWS ECS Deep Notes

## 1. What ECS Is

ECS is Amazon Elastic Container Service.

It is AWS's native container orchestration service for running containers without requiring full Kubernetes management.

Good interview line:

"ECS is AWS's managed container orchestration platform, designed to run containers with tighter AWS-native integration and lower control-plane complexity than Kubernetes."

## 2. Why Teams Choose ECS

Teams often choose ECS when they want:
- container orchestration without Kubernetes overhead
- tighter AWS-native experience
- simpler operational model
- easier adoption for teams focused mainly on application delivery

Why it is attractive:
- simpler than managing full Kubernetes for many use cases
- integrates well with IAM, CloudWatch, ALB, NLB, ECR, and auto scaling
- supports both EC2-backed and serverless execution patterns

## 3. ECS Core Building Blocks

### Cluster

An ECS cluster is the logical boundary where services and tasks run.

It groups:
- compute capacity
- task placement
- service workloads

### Task Definition

A task definition is like a container runtime blueprint.

It defines:
- container image
- CPU and memory
- ports
- environment variables
- secrets
- logging
- IAM role usage

### Task

A task is a running instance of a task definition.

You can think of it as:
- similar to a running pod or workload unit

### Service

A service keeps the desired number of tasks running.

It handles:
- maintaining task count
- replacing failed tasks
- integrating with load balancers
- rolling deployments

## 4. ECS on EC2 vs ECS on Fargate

This is one of the most important interview topics.

### ECS on EC2

Containers run on EC2 instances that you manage.

Benefits:
- more control
- useful for custom host requirements
- can be more cost-efficient at scale

Tradeoffs:
- you manage instance capacity
- patching and scaling are more involved

### ECS on Fargate

Containers run without managing servers directly.

Benefits:
- simpler operations
- no host management
- good for teams wanting faster platform simplicity

Tradeoffs:
- less control over host layer
- cost model may differ from EC2-backed setup

Strong answer:

"I choose ECS on EC2 when I need more control or specific host behavior, and Fargate when reducing infrastructure management is the bigger priority."

## 5. ECS Networking Concepts

ECS uses AWS networking patterns, so understanding VPC basics is still essential.

Key concerns:
- subnets
- security groups
- public vs private placement
- load balancer integration

For container workloads, I think about:
- how traffic reaches the service
- whether tasks need internet access
- whether tasks should stay private
- how outbound dependencies are reached

## 6. Public vs Private ECS Workloads

Public-facing workloads:
- often sit behind ALB or NLB
- should still be designed carefully rather than exposing tasks directly

Private workloads:
- internal APIs
- background workers
- queue consumers
- internal service-to-service workloads

Good answer:

"Even when a service is internet-facing, I usually want the controlled entry point to be the load balancer, while the containers themselves remain in a tighter network posture."

## 7. IAM in ECS

IAM matters at multiple levels in ECS.

### Task Execution Role

This is used by ECS infrastructure for things like:
- pulling images
- sending logs

### Task Role

This is used by the application container itself to access AWS services.

Examples:
- S3
- Secrets Manager
- SQS
- DynamoDB

Strong interview line:

"I separate the execution role from the task role because the infrastructure and the application have different permission needs."

## 8. ECS and ECR

ECR commonly stores the images ECS runs.

Typical flow:
1. CI builds container image
2. CI tags and pushes image to ECR
3. ECS task definition references image
4. ECS launches tasks using that image

Common issues:
- wrong image tag
- wrong registry path
- ECR access problems
- deployment still pointing to old task definition revision

## 9. ECS Load Balancing

ECS commonly integrates with:
- ALB
- NLB

### ALB

Useful for:
- HTTP or HTTPS services
- path-based routing
- host-based routing

### NLB

Useful for:
- TCP-focused services
- simpler high-performance transport-level routing

Important design point:
- load balancing choice depends on protocol and routing requirements

## 10. ECS Service Discovery

ECS services may need internal discovery for service-to-service communication.

Common concerns:
- stable naming
- internal routing
- whether traffic stays private

Strong answer:

"I want service discovery to be predictable and environment-aware so application containers do not depend on fragile hardcoded addresses."

## 11. ECS Autoscaling

ECS scaling can happen in multiple ways:
- scaling task count
- scaling underlying EC2 capacity if using EC2-backed ECS

Important considerations:
- CPU and memory thresholds
- request volume
- queue depth for worker-style services
- cold start or placement delay

Good answer:

"I size scaling around actual workload pressure, not only raw CPU, because some services are request-heavy, some are memory-bound, and some are queue-driven."

## 12. ECS Deployment Model

When you update a task definition and deploy through a service, ECS handles replacement of tasks based on deployment configuration.

Important operational ideas:
- desired count
- minimum healthy tasks
- rollout pacing
- health checks

This matters because:
- safe deployment is about replacement strategy, not just starting containers

## 13. Health Checks in ECS

Health can exist at multiple layers:
- container health
- task health
- load balancer target health
- application endpoint health

A task may be "running" but still not truly healthy for production traffic.

Good answer:

"I always separate container liveness from real service readiness because traffic safety depends on proper health checks, not just process existence."

## 14. ECS Logging and Observability

Common AWS observability areas for ECS:
- CloudWatch logs
- CloudWatch metrics
- service health
- task failures
- load balancer target health

What I usually want to observe:
- restart patterns
- deployment failures
- request-level impact
- scaling behavior
- AWS dependency failures

## 15. ECS Secrets Handling

Avoid:
- putting plaintext secrets in task definitions directly when safer options exist
- hardcoding secrets into images

Preferred direction:
- keep source of truth in a secret-management service
- inject or reference secrets in a controlled way
- scope IAM access tightly

Good line:

"For ECS workloads, I treat secrets as a runtime dependency, not an image or source-code artifact."

## 16. ECS Storage Thinking

Not all ECS workloads need persistent shared storage, but when they do, you should think clearly about:
- stateless vs stateful design
- local ephemeral need vs persistent need
- read-write pattern

Important principle:
- many container services are better when designed statelessly

## 17. ECS Security Considerations

Important layers:
- IAM least privilege
- network boundaries
- image source trust
- secret handling
- logging and auditability

Strong answer:

"I secure ECS by thinking across identity, network, image supply, secret flow, and operational visibility rather than depending on only one control."

## 18. ECS vs EKS

This question comes up often.

### ECS

Better when:
- AWS-native simplicity is preferred
- team does not need full Kubernetes ecosystem
- lower orchestration complexity is valuable

### EKS

Better when:
- Kubernetes standardization matters
- existing Kubernetes ecosystem tooling matters
- portability or advanced Kubernetes patterns matter

Strong answer:

"ECS is often a better fit for teams that want containers without full Kubernetes platform complexity, while EKS is better when Kubernetes itself is a strategic platform choice."

## 19. ECS vs EC2-Hosted Docker by Scripts

Why ECS is better than ad hoc Docker on EC2 in many cases:
- service reconciliation
- deployment control
- health-aware replacement
- AWS integration
- cleaner scaling model

## 20. Common ECS Failure Scenarios

### Task Fails to Start

Possible reasons:
- bad image
- wrong command
- missing environment variable
- secret resolution failure
- permission problem

### Service Keeps Replacing Tasks

Possible reasons:
- app crashes
- health check failure
- port mismatch
- dependency startup issue

### Load Balancer Has Unhealthy Targets

Possible reasons:
- wrong port mapping
- bad health endpoint
- security group path issue
- app not truly listening on expected port

### Tasks Cannot Pull From ECR

Possible reasons:
- image path issue
- tag issue
- execution role issue
- registry access issue

## 21. Troubleshooting Approach

A good ECS troubleshooting flow:

1. Check whether the task started at all.
2. Check service events.
3. Check task logs.
4. Check image and task definition revision.
5. Check task role and execution role.
6. Check load balancer target health if traffic is involved.
7. Check security groups, subnets, and outbound dependencies.

Good interview answer:

"I first narrow whether the issue is startup, deployment, permissions, networking, or traffic path. That avoids mixing infrastructure symptoms with application symptoms."

## 22. Cost Awareness in ECS

Cost topics include:
- always-on task count
- overprovisioned CPU and memory
- idle load balancers
- excessive logs
- Fargate vs EC2 tradeoff

Good answer:

"A strong ECS design is not only functional. It should also be cost-aware, especially around sizing, scaling, and whether the simplicity premium of Fargate is worth it for the workload."

## 23. Strong Interview Questions and Better Answers

### Why choose ECS?

Better answer:

"I choose ECS when I want container orchestration with strong AWS integration and lower platform complexity than Kubernetes. It is especially attractive when the team wants to focus more on application delivery than orchestration internals."

### What is the difference between task role and execution role?

Better answer:

"The execution role is used by ECS infrastructure for actions like pulling images and sending logs. The task role is used by the application code itself when it calls AWS services."

### How do you troubleshoot unhealthy ECS services?

Better answer:

"I check service events, task logs, health checks, target group health, and whether the task definition still matches the actual application behavior. Many ECS issues are really health-path or permission mismatches."

### When would you prefer ECS over EKS?

Better answer:

"If the team does not need Kubernetes-specific flexibility and wants a simpler AWS-native container platform, ECS is often the better operational choice."

## 24. Final Revision Checklist

Make sure you can explain:
- cluster, task definition, task, and service
- ECS on EC2 vs Fargate
- task role vs execution role
- ECR integration
- ALB vs NLB in ECS
- deployment and health-check behavior
- secret handling
- ECS vs EKS tradeoffs
- common troubleshooting paths
