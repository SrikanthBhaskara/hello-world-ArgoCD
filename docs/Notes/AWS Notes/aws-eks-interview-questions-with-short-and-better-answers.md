# AWS EKS Interview Questions With Short and Better Answers

## 1. What is EKS?

### Short Answer

EKS is Amazon Elastic Kubernetes Service, a managed Kubernetes service on AWS.

### Better Answer

EKS is AWS's managed Kubernetes offering. AWS manages the control plane, while teams still manage workloads, node strategy, networking, permissions, scaling behavior, and operational tooling around the cluster.

## 2. Why use EKS instead of self-managed Kubernetes?

### Short Answer

EKS reduces control-plane management effort and integrates well with AWS services.

### Better Answer

EKS removes much of the operational burden around running the Kubernetes control plane and fits naturally with AWS networking, IAM, load balancing, and registry patterns. It does not remove Kubernetes complexity, but it reduces infrastructure ownership in an important area.

## 3. What does AWS manage in EKS and what do you still manage?

### Short Answer

AWS manages the control plane. Teams still manage worker compute, workloads, security, add-ons, and day-two operations.

### Better Answer

AWS handles the control plane availability and lifecycle. We still own workload deployment, node or compute strategy, permissions, observability, cost control, networking design, ingress behavior, storage choices, and troubleshooting.

## 4. What is the difference between EKS and ECS?

### Short Answer

EKS is Kubernetes-based, while ECS is AWS's native container orchestration service.

### Better Answer

I choose EKS when Kubernetes ecosystem compatibility, portability, and Kubernetes-native tooling matter. ECS can be simpler when the team wants a more AWS-native container platform without full Kubernetes operational depth.

## 5. What are managed node groups in EKS?

### Short Answer

Managed node groups are AWS-managed groups of worker nodes for EKS clusters.

### Better Answer

Managed node groups simplify node lifecycle operations such as provisioning and rolling updates. They reduce platform burden compared to fully self-managed nodes, while still giving enough control for many production workloads.

## 6. What is the difference between managed node groups and self-managed nodes?

### Short Answer

Managed node groups reduce operational work, while self-managed nodes give more direct control.

### Better Answer

Managed node groups are a better default for most teams because they reduce maintenance effort. Self-managed nodes are useful when there are special bootstrap, AMI, or infrastructure requirements that need tighter control.

## 7. How do EKS workloads access AWS services securely?

### Short Answer

By using identity-based access patterns instead of hardcoded credentials.

### Better Answer

I avoid embedding static AWS keys in pods. Instead, I prefer workload identity patterns that map Kubernetes workloads to narrowly scoped AWS permissions. That keeps access temporary, auditable, and aligned with least privilege.

## 8. Why are IAM roles better than static access keys in EKS?

### Short Answer

Roles avoid long-lived secrets and are safer operationally.

### Better Answer

Static keys are harder to rotate and easier to leak. IAM-role-based access is safer because credentials are temporary, permissions are easier to scope, and secret distribution becomes much cleaner.

## 9. What is IRSA in EKS?

### Short Answer

IRSA is a way to associate Kubernetes service accounts with AWS IAM roles.

### Better Answer

IRSA lets specific Kubernetes workloads assume specific AWS roles through their service accounts. It is a strong pattern because it gives pod-level permission boundaries instead of broad node-level access.

## 10. Why is IRSA important?

### Short Answer

It gives least-privilege AWS access to Kubernetes workloads.

### Better Answer

IRSA is important because it prevents every pod on a node from inheriting the same broad AWS permissions. It improves isolation, reduces blast radius, and supports cleaner security design.

## 11. What AWS services are commonly used with EKS?

### Short Answer

IAM, VPC, ECR, Secrets Manager, CloudWatch, Route 53, ALB or NLB, and EBS or EFS.

### Better Answer

In real EKS platforms, those services usually form the surrounding runtime ecosystem. EKS runs workloads, IAM controls access, VPC provides network boundaries, ECR stores images, Secrets Manager holds secrets, and load balancers expose traffic.

## 12. How does EKS networking work at a high level?

### Short Answer

EKS workloads run inside AWS VPC networking, so subnet, IP, and security design matter a lot.

### Better Answer

EKS networking is tightly tied to the AWS VPC model. That means subnet sizing, route tables, pod IP capacity, internal versus external exposure, and security group design all directly affect cluster reliability and scale.

## 13. Why do subnet and IP planning matter in EKS?

### Short Answer

Because pod and node scale can run into IP exhaustion if network planning is weak.

### Better Answer

In EKS, poor subnet sizing can become a real production issue. If cluster growth or pod density exceeds available IP capacity, scheduling and scaling can fail even if the application itself is healthy.

## 14. What is the difference between public and private subnets for EKS?

### Short Answer

Public subnets are used for direct internet-routable components, while private subnets are preferred for internal worker and application workloads.

### Better Answer

I usually prefer worker nodes and application workloads in private subnets, with internet-facing entry points handled through appropriate load balancers. That gives better security boundaries and reduces direct exposure.

## 15. How do you expose applications running on EKS?

### Short Answer

Usually through Kubernetes services and an ingress or load balancer integration.

### Better Answer

The exact method depends on traffic type and architecture, but commonly an ingress controller or service annotation drives ALB or NLB provisioning in AWS. I think about exposure in terms of Layer 7 versus Layer 4 behavior, TLS handling, and internal versus internet-facing access.

## 16. What is the difference between ALB and NLB in EKS use cases?

### Short Answer

ALB is better for HTTP or HTTPS routing, while NLB is better for transport-level traffic patterns.

### Better Answer

I use ALB when I need path-based or host-based routing and typical web ingress behavior. I use NLB when I need simpler high-performance transport handling or non-HTTP workloads.

## 17. What is the role of ECR in EKS?

### Short Answer

ECR stores container images that EKS workloads pull at runtime.

### Better Answer

ECR is the container registry layer in the platform flow. CI builds and pushes images to ECR, and EKS workloads reference those images during deployment. Good image management, access control, and tag discipline are important here.

## 18. How do you troubleshoot image pull issues from ECR?

### Short Answer

Check image path, tag, registry auth, and whether the cluster can actually access the image.

### Better Answer

I first verify the image exists with the expected tag, then check whether the workload references the right registry path, and then inspect auth, permissions, and network reachability if the pull still fails.

## 19. How are secrets usually handled in EKS environments?

### Short Answer

Secrets are usually kept in a secure AWS service and then delivered to Kubernetes through controlled runtime patterns.

### Better Answer

I prefer keeping the source of truth in Secrets Manager and using a secure sync or injection approach into Kubernetes. That keeps secrets out of Git and supports better access control, auditing, and rotation.

## 20. Why is Secrets Manager useful with EKS?

### Short Answer

It provides centralized secret storage with controlled access.

### Better Answer

Secrets Manager lets teams avoid putting plaintext secrets in repos or images. It works well with identity-based access and with Kubernetes-side secret delivery patterns when the platform is designed carefully.

## 21. How do you secure an EKS cluster?

### Short Answer

Use least-privilege IAM, private networking where possible, controlled ingress, strong secret handling, and observability.

### Better Answer

For EKS security I think across layers: cluster access, workload access, network design, image trust, secret management, RBAC, and runtime visibility. Good security comes from layered controls, not a single feature.

## 22. What is the role of CloudWatch in EKS platforms?

### Short Answer

CloudWatch provides monitoring, metrics, logs, and alerting around AWS and platform behavior.

### Better Answer

CloudWatch helps connect infrastructure events with application behavior. It is useful for load balancer metrics, node and cloud visibility, alarms, and log aggregation as part of broader observability.

## 23. What storage options are common with EKS?

### Short Answer

EBS and EFS are common storage options depending on workload needs.

### Better Answer

I use EBS when block-style persistent storage is needed, especially for stateful workloads with one-writer style access. I use EFS when multiple workloads need shared filesystem access semantics.

## 24. How do you think about high availability in EKS?

### Short Answer

Use multi-AZ design, resilient workload replicas, healthy ingress, and reliable dependencies.

### Better Answer

High availability in EKS means more than just creating a cluster. I think about multi-AZ node placement, stateless scaling, dependency availability, ingress resilience, and whether the workload behavior actually tolerates node or AZ failure.

## 25. What are common production mistakes in EKS?

### Short Answer

Poor IAM design, weak subnet sizing, static credentials, bad ingress setup, and missing observability.

### Better Answer

The most common mistakes I see are broad AWS permissions, static keys, weak network planning, unclear exposure paths, insufficient logging and alarms, and treating cluster creation as if it completes platform design.

## 26. How do you troubleshoot an EKS application issue?

### Short Answer

Separate whether the issue is cluster runtime, AWS integration, identity, networking, or the application itself.

### Better Answer

I narrow the failure boundary first. I check pod status, logs, and events, then ingress or service path, then AWS dependencies like ECR, secrets, IAM access, and network egress. That keeps troubleshooting structured instead of random.

## 27. What should a senior engineer emphasize when discussing EKS?

### Short Answer

Tradeoffs, security, scaling, networking, platform ownership, and cost.

### Better Answer

A stronger EKS answer includes not just "how to deploy" but also workload identity, subnet planning, ingress design, secret flow, autoscaling behavior, failure boundaries, observability, and operational tradeoffs over time.
