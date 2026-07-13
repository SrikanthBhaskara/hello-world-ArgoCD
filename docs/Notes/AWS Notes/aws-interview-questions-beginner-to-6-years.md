# AWS Interview Questions with Answers: Beginner to 6 Years

## Purpose

This file prepares you for AWS interviews from beginner to around 6 years of experience, with answers designed to sound clear and convincing in interviews.

## Beginner (0 to 2 Years)

### 1. What is AWS?
Short answer:
AWS is Amazon's cloud platform that provides compute, storage, networking, databases, and many managed services.

Better answer:
AWS is a cloud platform that lets teams provision infrastructure and managed services on demand instead of owning physical servers. It supports scalable application deployment, storage, networking, IAM, automation, and platform services.

### 2. What is the difference between EC2 and S3?
Short answer:
EC2 provides virtual servers for compute, while S3 provides object storage.

Better answer:
EC2 is used when I need a running machine or host-level control for an application or service. S3 is used to store objects like files, backups, logs, or static assets. One is compute, the other is storage, so they solve very different problems.

### 3. What is IAM?
Short answer:
IAM controls who can access AWS resources and what actions they are allowed to perform.

Better answer:
IAM is the identity and access control layer of AWS. It manages users, roles, policies, and permissions. In real systems, IAM is critical for least-privilege access and safe automation.

### 4. What is an IAM role?
Short answer:
An IAM role is an AWS identity with permissions that can be assumed by users, services, or workloads.

Better answer:
Unlike an IAM user, a role is usually assumed temporarily and is heavily used by applications, Kubernetes workloads, EC2 instances, and CI/CD systems. Roles are safer than long-lived access keys because they support temporary credentials and cleaner permission boundaries.

### 5. What is the difference between a security group and a network ACL?
Short answer:
A security group is stateful and applies at the instance or ENI level; a network ACL is stateless and applies at the subnet level.

Better answer:
I think of security groups as instance-level firewalls and NACLs as subnet-level filters. Security groups automatically track return traffic because they are stateful, while NACLs require explicit inbound and outbound rules because they are stateless.

### 6. What is a VPC?
Short answer:
A VPC is a logically isolated virtual network in AWS.

Better answer:
A VPC gives me control over IP ranges, subnets, routing, internet access patterns, and security boundaries for AWS resources. It is the networking foundation for most AWS application environments.

### 7. Difference between public subnet and private subnet?
Short answer:
A public subnet can route to the internet through an internet gateway, while a private subnet does not expose resources directly that way.

Better answer:
Public subnets are used for components that need direct internet-facing access, such as load balancers or bastion-style entry points. Private subnets are used for internal workloads like application services or databases, where access should stay controlled and indirect.

### 8. What is an EBS volume?
Short answer:
An EBS volume is block storage that can be attached to EC2 instances.

Better answer:
EBS is persistent block storage used when an EC2 instance needs durable disk-like storage. It is commonly used for application data, logs, or mounted storage that should survive instance restart or replacement workflows.

### 9. What is Route 53?
Short answer:
Route 53 is AWS's DNS and domain-routing service.

Better answer:
Route 53 manages domain records, DNS routing, and health-aware traffic direction. It is used to map human-friendly names to services and can also support routing strategies for availability or failover needs.

### 10. What is CloudWatch?
Short answer:
CloudWatch provides metrics, logs, alarms, and monitoring for AWS resources and applications.

Better answer:
CloudWatch helps teams observe both infrastructure and application behavior. In real systems it is useful for metrics, log collection, alarms, dashboards, and basic operational visibility so issues can be detected before they become major incidents.

## Intermediate (2 to 4 Years)

### 11. What is the difference between an IAM user, IAM role, and IAM policy?
Short answer:
An IAM user is a named identity, a role is an assumable identity, and a policy is the permission document attached to users, groups, or roles.

Better answer:
An IAM user usually represents a person or system identity. A role is typically assumed temporarily by workloads, services, or automation. A policy defines the permissions. In modern systems, roles are preferred over long-lived static credentials whenever possible.

### 12. Why are IAM roles better than hardcoded access keys?
Short answer:
Roles reduce secret sprawl, support temporary credentials, and align with least-privilege security.

Better answer:
Hardcoded keys are harder to rotate, easier to leak, and riskier operationally. Roles are safer because they provide temporary credentials, fit better with workload identity, and remove the need to distribute static secrets across code, pipelines, or runtime environments.

### 13. What is the difference between ECR and S3?
Short answer:
ECR stores container images, while S3 stores generic objects.

Better answer:
ECR is purpose-built for container image storage and distribution. S3 is general object storage used for many file and data use cases. If I am publishing Docker images for Kubernetes or ECS-style workloads, ECR is the right tool.

### 14. What is AWS Secrets Manager and why use it?
Short answer:
Secrets Manager stores and controls access to secrets like API keys, passwords, and tokens.

Better answer:
Secrets Manager improves security by keeping secrets out of source code and Git. It also supports access control, auditing, and rotation workflows. In Kubernetes-integrated systems, it works well as the upstream secret source for runtime delivery patterns.

### 15. What is the difference between AWS Secrets Manager and Systems Manager Parameter Store?
Short answer:
Secrets Manager is stronger for secret lifecycle features, while Parameter Store is often used for configuration and simpler parameter storage.

Better answer:
Secrets Manager is designed specifically for secrets and usually offers stronger rotation and secret-management workflows. Parameter Store is commonly used for configuration values and can also store secure strings, but the decision depends on the required security, lifecycle, and operational needs.

### 16. What is an Auto Scaling Group?
Short answer:
An Auto Scaling Group manages a fleet of EC2 instances and can scale it up or down based on rules or metrics.

Better answer:
It helps maintain the desired number of instances, replace unhealthy instances, and respond to traffic or demand changes. It is an important building block when EC2-based applications need resilience and scaling.

### 17. What is a Load Balancer and why is it useful?
Short answer:
A Load Balancer distributes traffic across targets and improves availability and scalability.

Better answer:
In AWS, common types include ALB and NLB. Load balancers help spread requests, avoid single-instance dependency, and provide cleaner entry points into systems. They are important for both scalability and operational resilience.

### 18. How do you secure access between AWS services and Kubernetes workloads?
Short answer:
I avoid static credentials, prefer role-based or short-lived credential patterns, and apply least privilege.

Better answer:
In cloud-native systems, I want workloads to get only the minimum permissions required and ideally through temporary or assumable identity patterns rather than hardcoded keys. I also care about secret delivery path, namespace scoping, and whether access is auditable end to end.

### 19. What is the difference between RDS and self-managed databases on EC2?
Short answer:
RDS is a managed database service, while a database on EC2 gives more control but more operational responsibility.

Better answer:
RDS reduces operational burden around backups, patching, and managed availability features. Self-managed EC2 databases offer more control but require more ownership for maintenance, scaling, security, and recovery. I choose based on control requirements versus operational cost.

### 20. What is the difference between a region and an availability zone?
Short answer:
A region is a geographic AWS area, and an availability zone is an isolated location within that region.

Better answer:
Regions help with geographical placement and major fault boundaries. Availability zones are used to spread workloads for higher resilience inside a region. Good architecture often uses multiple AZs to reduce single-location failure risk.

## Experienced (4 to 6 Years)

### 21. How would you explain your AWS experience from this project?
Short answer:
I worked with AWS services mainly around image publishing, secret management, and runtime access patterns for deployed services.

Better answer:
I worked with AWS services as part of a cloud security scanner platform, especially around ECR image publishing, Secrets Manager integration, secret delivery to Kubernetes through External Secrets, and AWS credential refresh and access flows used by GitOps deployment and runtime workloads.

### 22. How do you design secure secret access in AWS-integrated Kubernetes systems?
Short answer:
I keep secrets out of Git and images, use Secrets Manager as the source, and apply least-privilege access to workloads.

Better answer:
I use a pattern where secrets are stored centrally in AWS Secrets Manager, permissions are limited through IAM, and Kubernetes receives only the needed runtime material through controlled sync or injection patterns. I also verify token freshness, namespace scoping, and the dependency path from AWS identity to Kubernetes Secret availability.

### 23. How would you troubleshoot ECR authentication issues?
Short answer:
I would verify image existence, registry path, token or credentials, and whether the cluster actually received a valid pull secret.

Better answer:
I start by checking whether the image and tag really exist, whether the referenced registry URL is correct, and whether authentication or token generation is valid. Then I confirm the secret is actually created and available to the workload. In automated systems I also inspect controller logs, token refresh flow, and namespace-level secret usage.

### 24. Why is least privilege important in AWS?
Short answer:
Least privilege reduces blast radius and limits damage when credentials or automation are misused.

Better answer:
Least privilege is both a security and operational safety principle. If a credential leaks or an automation path behaves incorrectly, limited permissions prevent broader damage. It also forces cleaner ownership boundaries and more intentional access design.

### 25. What are common AWS mistakes in real projects?
Short answer:
Common mistakes include over-permissive IAM, hardcoded credentials, poor secret rotation, weak monitoring, and misunderstanding network boundaries.

Better answer:
In real projects, I often see excessive IAM permissions, static keys where roles should be used, secrets mixed into deployment repos, weak alerting, and confusion around public versus private network placement. Another common mistake is tying cloud operations too closely to manual steps instead of controlled automation.

## Quick Revision Topics

- IAM users, roles, and policies
- VPC, subnet, SG, NACL
- ECR
- Secrets Manager
- CloudWatch
- region and AZ
- temporary credentials vs static keys
