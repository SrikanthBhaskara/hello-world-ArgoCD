# AWS / EKS Senior 5 to 7 Years Production Interview Guide

This guide converts AWS and EKS topics from definition-level answers into production-focused interview answers.

---

## What Strong AWS Answers Should Include

- service fit for the use case
- security boundary thinking
- cost and operational tradeoffs
- observability and incident response
- rollout and rollback strategy

---

## 1. VPC and Networking

Do not stop at "VPC is a virtual network."

Explain:

- public vs private subnets
- route table behavior
- NAT dependency
- security groups vs NACLs
- where EKS nodes, load balancers, and data services should live

### Senior answer angle

If workloads should not be directly internet reachable, place nodes and internal services in private subnets and expose only controlled ingress points.

---

## 2. IAM and IRSA

Interviewers expect more than "IAM controls access."

Explain:

- least privilege
- difference between node role and workload role
- why IRSA is safer than giving broad node permissions
- blast radius if too many Pods share the same permissions

### Debugging mindset

If a Pod cannot access AWS APIs, check:

- service account annotation
- IAM role trust policy
- OIDC provider
- permissions policy
- application logs

---

## 3. EKS Control Plane vs Worker Nodes

Strong answer:

EKS manages the control plane for you, but you still own node sizing, IAM usage, Pod scheduling behavior, networking, add-ons, cost, and operational health.

### Tradeoff

Managed control plane reduces operational burden, but node and workload problems are still fully yours.

---

## 4. Ingress and Traffic Flow

For ingress discussions, explain:

- ALB or NLB choice
- TLS termination location
- internal vs internet-facing ingress
- health check behavior
- routing impact during rollouts

### Safe change thinking

Do not change ingress annotations blindly in production. Validate target group behavior, path rules, certificate impact, and rollback path first.

---

## 5. External Secrets and Secret Flow

Senior answer should include:

- why secrets should not be hardcoded
- secret sync path
- least-privilege IAM access
- rotation behavior
- what happens if secret sync fails

### Debugging example

If the app starts failing due to missing secrets:

- check `ExternalSecret` and `SecretStore`
- verify operator health
- verify IAM/IRSA access
- verify AWS secret exists and expected key names match

---

## 6. ECR and Image Pull Failures

Do not say only "ECR stores Docker images."

Explain:

- image pull permissions
- node or workload identity path
- tag management risks
- immutable image preference

### Common incident

`ImagePullBackOff` may come from:

- missing image
- wrong tag
- auth permission issue
- network or DNS issue

---

## 7. Cost and Scaling Tradeoffs

Strong answers mention:

- right-sizing nodes
- autoscaling behavior
- overprovisioning vs stability
- managed services vs self-managed operational cost

### Example tradeoff

More nodes improve bin-packing safety and rollout stability, but increase baseline cost.

---

## 8. Production-Safe AWS / EKS Changes

Before changing:

- confirm IAM blast radius
- confirm ingress/networking impact
- confirm compatibility with existing workloads
- validate metrics and alarms
- use staged rollout where possible

### Good answer line

"I do not treat cloud changes as only configuration updates. I check security impact, traffic impact, and rollback readiness before rollout."
