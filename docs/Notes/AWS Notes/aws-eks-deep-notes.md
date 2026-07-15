# AWS and EKS Deep Notes

## 1. What AWS Provides in Real Systems

AWS is not just a collection of isolated services. In real projects, it becomes the operating platform for:
- compute
- networking
- storage
- identity and access
- observability
- secret management
- Kubernetes hosting

For cloud-native platforms, AWS often provides:
- VPC and subnet design
- IAM and workload permissions
- container registry through ECR
- Kubernetes through EKS
- secret storage through Secrets Manager
- monitoring through CloudWatch
- DNS through Route 53
- load balancing through ALB or NLB

Good interview line:

"I think of AWS as the infrastructure control plane around the application platform, and EKS as one of the runtime layers for containerized workloads."

## 2. Core Networking Concepts

### VPC

A VPC is a logically isolated network in AWS.

It defines:
- CIDR range
- subnets
- routing
- internet or private connectivity
- security boundaries

Why it matters:
- all EKS worker nodes, internal services, and load balancers depend on VPC design

### Public vs Private Subnets

Public subnets:
- route to an internet gateway
- typically used for internet-facing load balancers or edge access points

Private subnets:
- do not directly expose workloads to the internet
- usually host worker nodes, internal services, and databases

Strong practical answer:

"In production, I usually prefer EKS worker nodes and sensitive workloads in private subnets, while internet-facing entry points such as ALBs are placed where public connectivity is appropriate."

### Route Tables

Route tables determine where traffic goes.

Common patterns:
- internal traffic stays within VPC
- internet-bound public subnet traffic goes through internet gateway
- private subnet outbound traffic may go through NAT

### Security Groups vs Network ACLs

Security groups:
- stateful
- attached to instance or ENI level
- usually the main day-to-day security control

Network ACLs:
- stateless
- apply at subnet level
- usually broader guardrail style control

Good interview line:

"I use security groups as the primary workload-level network control and treat NACLs as subnet-level coarse-grained filtering when needed."

## 3. IAM Deep Understanding

IAM is one of the most important AWS topics for both interviews and real systems.

### IAM Users

IAM users are long-lived identities, usually representing humans or legacy systems.

### IAM Roles

IAM roles are assumable identities with temporary credentials.

Roles are preferred for:
- EC2
- EKS workloads
- CI/CD systems
- automation

### IAM Policies

Policies define permissions.

Key best practice:
- least privilege

Bad practice:
- broad wildcard access like full admin for convenience

Strong answer:

"I prefer roles over static keys because temporary credentials reduce secret sprawl and align much better with least-privilege design."

## 4. Why EKS Matters

EKS is Amazon Elastic Kubernetes Service.

It gives:
- managed Kubernetes control plane
- AWS integration around networking, IAM, and load balancing
- easier cluster lifecycle compared to fully self-managed Kubernetes

What EKS manages:
- control plane availability
- Kubernetes API server and related managed control components

What you still manage:
- node groups or compute profiles
- cluster add-ons
- workload deployment
- permissions, observability, and cost control

Important interview point:

EKS does not remove Kubernetes complexity. It reduces control-plane management burden, but platform ownership still matters.

## 5. EKS Architecture Basics

Main parts:
- managed control plane
- worker nodes or serverless execution path
- VPC networking
- IAM integration
- Kubernetes add-ons

### Control Plane

AWS manages the control plane.

This reduces:
- etcd management burden
- API server patching burden
- control-plane availability overhead

### Worker Nodes

Workloads run on nodes or equivalent compute execution model.

Common patterns:
- managed node groups
- self-managed nodes
- serverless execution option depending on architecture choice

### Kubernetes API Access

Cluster access depends on:
- kubeconfig setup
- IAM permissions
- cluster auth mapping or newer access configuration models

## 6. EKS Node Models

### Managed Node Groups

AWS helps manage:
- lifecycle
- updates
- scaling integration

This is often the operationally easier option.

### Self-Managed Nodes

You manage the EC2 worker fleet more directly.

Useful when:
- highly custom setup is needed
- stronger control is required

Tradeoff:
- more operational responsibility

### Serverless Execution Pattern

Some teams choose a serverless pod execution model for selected workloads.

Use cases:
- simpler operations for certain workloads
- reduced node management

Tradeoffs:
- cost model
- operational constraints
- fit for workload type

## 7. EKS Networking Model

In EKS, networking is one of the most important real-world topics.

Pods and nodes interact with AWS VPC resources.

Real operational concerns:
- pod IP allocation
- subnet capacity
- security group design
- internal vs external load balancing
- ingress controller placement

Why subnet planning matters:
- EKS clusters can run into IP exhaustion issues if pod density and subnet sizing were not planned well

Strong answer:

"For EKS I always think beyond cluster creation. I also check VPC CIDR sizing, subnet capacity, expected pod density, load balancer placement, and whether internal services should stay private."

## 8. EKS and IAM for Workloads

A big platform topic is how workloads in Kubernetes get AWS permissions.

You should avoid:
- hardcoded access keys in code
- static AWS keys stored loosely in Kubernetes

Better pattern:
- map workload identity to IAM permissions
- keep permissions narrow
- use temporary credential flow

This matters for workloads accessing:
- S3
- Secrets Manager
- SQS
- DynamoDB
- ECR auth helpers

Good interview line:

"For EKS workloads, I prefer identity-based access patterns instead of embedding long-lived AWS credentials in pods."

## 9. ECR and Container Image Flow

ECR is AWS Elastic Container Registry.

It is used to:
- store Docker images
- version images
- integrate with CI/CD
- serve Kubernetes image pulls

Typical flow:
1. CI builds image
2. CI scans and tags image
3. CI pushes image to ECR
4. deployment manifest references ECR image
5. EKS workloads pull image at runtime

Common issues:
- wrong registry URL
- missing image tag
- auth or token failure
- node or workload cannot pull image

## 10. Load Balancing in AWS + EKS

Kubernetes services often need AWS load balancers.

Common external exposure options:
- Application Load Balancer
- Network Load Balancer

### ALB

Better for:
- HTTP/HTTPS routing
- host-based routing
- path-based routing

### NLB

Better for:
- high-performance TCP style exposure
- simpler transport-level load balancing

Important interview answer:

"I choose ALB when I need Layer 7 routing features and NLB when I need simpler high-performance transport behavior."

## 11. Ingress and AWS Integration

In EKS, ingress usually needs controller-based integration with AWS load balancing.

Concerns to understand:
- internet-facing vs internal
- TLS certificate handling
- target type and routing model
- security group exposure

Good practical point:
- ingress success depends on both Kubernetes resources and AWS networking correctness

## 12. Storage in AWS + EKS

There are multiple storage concerns.

### EBS

EBS is block storage.

Typical use:
- persistent volumes for stateful workloads

### EFS

EFS is shared file storage.

Typical use:
- workloads that need shared filesystem semantics across multiple pods

Interview line:

"I use EBS for block-style persistent storage and EFS when multiple workloads need shared filesystem access."

## 13. Secrets in AWS Environments

A strong design avoids plaintext secrets in source code or Git.

Common AWS secret source:
- Secrets Manager

Common runtime pattern:
- Kubernetes fetches or syncs secret material through controlled integration

Important concerns:
- rotation
- namespace scoping
- IAM restriction
- auditability

Strong answer:

"I prefer keeping the source of truth for secrets in AWS Secrets Manager and exposing only the minimum runtime material needed inside Kubernetes."

## 14. Observability

AWS observability often includes:
- CloudWatch metrics
- CloudWatch logs
- dashboards
- alarms

For EKS and containerized platforms, observability usually spans:
- node health
- pod health
- workload logs
- cluster events
- AWS resource metrics
- load balancer metrics

Good interview line:

"I separate infrastructure visibility from application visibility, but I want both connected so cluster events, pod failures, and AWS service metrics can be correlated."

## 15. High Availability Thinking

For AWS and EKS, availability is not just "cluster is running."

You should think about:
- multi-AZ placement
- resilient node groups
- replicated workloads
- health checks
- autoscaling
- reliable ingress
- secret and dependency availability

Important interview point:

"Multi-AZ design improves resilience, but only if workloads, networking, storage assumptions, and scaling behavior are also designed for failure boundaries."

## 16. Autoscaling Concepts

Autoscaling can exist at different levels:
- workload replica scaling
- node scaling
- cloud resource scaling

Typical concerns:
- scale-up delay
- scale-down safety
- resource requests and limits
- uneven traffic behavior

For EKS platforms, scaling quality depends heavily on good workload resource configuration.

## 17. Cost Awareness

A strong senior answer includes cost awareness.

Common AWS cost concerns:
- oversized instances
- idle load balancers
- excessive log retention
- overprovisioned storage
- unnecessary cross-AZ traffic
- poor autoscaling configuration

Good line:

"Good cloud design is not only about making the platform work. It is also about making it secure, observable, and cost-aware."

## 18. Common AWS + EKS Failure Scenarios

### Cluster Creates but Workloads Fail

Possible reasons:
- node readiness issues
- permissions issues
- image pull failures
- secret dependency problems
- broken ingress or service wiring

### Pods Cannot Pull From ECR

Possible reasons:
- wrong image path
- image does not exist
- auth/token problems
- networking issue to registry path

### Secrets Not Reaching Pods

Possible reasons:
- wrong IAM permissions
- secret sync controller problem
- wrong namespace or name
- race condition between secret creation and workload startup

### Ingress Exists but App Is Unreachable

Possible reasons:
- service selector mismatch
- wrong target port
- ALB/NLB config mismatch
- TLS or DNS issue
- security group exposure issue

### Outbound AWS Calls Fail From Pods

Possible reasons:
- bad IAM role mapping
- missing permission
- DNS or network egress issue
- wrong region or endpoint config

## 19. Troubleshooting Approach

A good troubleshooting pattern for AWS + EKS systems:

1. Confirm whether the issue is Kubernetes runtime, AWS service access, or deployment configuration.
2. Check pod state, logs, and events.
3. Check service and ingress or load balancer path.
4. Verify image path and registry access.
5. Verify secret availability and IAM permissions.
6. Check networking boundaries: subnets, security groups, routing, DNS.
7. Check AWS-side metrics and logs where relevant.

Strong interview answer:

"I try to narrow the failure boundary first. I separate cluster scheduling issues, application runtime issues, AWS identity issues, and networking issues before going deep into any single layer."

## 20. AWS Services Commonly Mentioned with EKS

You should be able to explain at least a basic role for:
- IAM
- VPC
- ECR
- Secrets Manager
- CloudWatch
- Route 53
- ALB and NLB
- EBS and EFS

## 21. Strong Interview Questions and Better Answers

### Why EKS instead of self-managed Kubernetes?

Better answer:

"EKS reduces operational burden around the control plane and integrates well with AWS networking, IAM, and load-balancing patterns. It does not remove Kubernetes complexity, but it allows the team to focus more on workload and platform engineering than control-plane maintenance."

### How do you secure AWS access from Kubernetes workloads?

Better answer:

"I avoid static keys whenever possible and prefer identity-based access patterns with least privilege. That gives workloads only the permissions they need and reduces secret management risk."

### How do you troubleshoot ECR pull problems?

Better answer:

"I verify the image path and tag first, then auth flow, then node or pod access to the registry, and finally whether the workload is referencing the intended image and namespace-level pull mechanism correctly."

### How do you think about AWS networking in EKS?

Better answer:

"I think from the workload outward: pod and service needs, subnet capacity, private versus public exposure, ingress design, security groups, and how traffic enters and exits the platform."

## 22. Final Revision Checklist

Make sure you can clearly explain:
- VPC, subnet, route table, internet gateway
- security groups vs NACLs
- IAM users, roles, policies
- why temporary credentials are better
- what ECR does
- what EKS manages vs what the team still manages
- how ingress and load balancing work in AWS environments
- EBS vs EFS
- secret-management pattern with AWS
- troubleshooting image, secret, and permission issues
