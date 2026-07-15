# AWS and EKS Troubleshooting Scenarios With Ideal Answers

## 1. EKS Cluster Is Running but Pods Stay Pending

### Scenario

The cluster exists, but new pods are not getting scheduled.

### Ideal Answer

I would first check whether the problem is lack of nodes, resource pressure, taints, node readiness, or subnet and IP exhaustion. In EKS, scheduling problems are not always pure Kubernetes issues because network capacity can also block effective scaling.

## 2. Pods Cannot Pull Image From ECR

### Scenario

The pod is created but image pull fails.

### Ideal Answer

I would verify the exact ECR image URL and tag first, then confirm the image really exists in the registry. After that I would check whether the node or workload has the right AWS access path and whether any network restriction prevents pull access.

## 3. Workload Cannot Access AWS Secrets Manager

### Scenario

The application starts but fails when reading a secret from AWS.

### Ideal Answer

I would confirm which identity model the workload is supposed to use, verify the IAM permissions for that workload, and check whether the secret name, region, and access policy are correct. I would also confirm whether the failure is access-related or secret-content-related.

## 4. Ingress Exists but the Application Is Not Reachable

### Scenario

The ingress resource is present, but user traffic fails.

### Ideal Answer

I would check the ingress controller path first, then validate whether the service selector, service port, target port, and pod readiness are correct. On the AWS side I would also check whether the load balancer is provisioned as expected and whether networking or security rules allow the path.

## 5. ALB Is Created but Routes to the Wrong Backend

### Scenario

The load balancer exists, but traffic is not reaching the intended application path.

### Ideal Answer

I would validate ingress rules, host and path matching, service references, target group behavior, and whether the pods behind the service are actually healthy. This is usually a routing or service mapping problem rather than only a cloud problem.

## 6. External Secrets Are Not Appearing in Kubernetes

### Scenario

Secrets exist in AWS, but Kubernetes workloads cannot see the expected secret objects.

### Ideal Answer

I would check the external secret controller health, the configured secret store reference, IAM permissions, namespace placement, and whether the target secret name matches what the workload expects. I would also verify refresh timing and controller logs.

## 7. Node Group Scales but Application Still Fails

### Scenario

More nodes are created, but the service is still unstable.

### Ideal Answer

That suggests capacity was not the only issue. I would check whether workload replicas are actually increasing, whether readiness probes are failing, whether the application depends on unavailable downstream services, and whether ingress or service routing is still broken.

## 8. EKS Workload Makes AWS API Calls but Gets Access Denied

### Scenario

The pod can run, but AWS API operations fail with permission errors.

### Ideal Answer

I would confirm the intended workload identity path, then inspect the exact denied action and resource. Usually the next step is verifying whether the assumed IAM permissions are too narrow, attached to the wrong workload, or not reaching the pod the way we expected.

## 9. DNS Resolution Fails From Pods

### Scenario

Pods cannot resolve internal or external names.

### Ideal Answer

I would first confirm whether it is a cluster DNS problem, a namespace service discovery problem, or a broader network egress issue. Then I would inspect pod-level DNS config, cluster DNS health, VPC resolver behavior, and whether the issue affects all pods or only a subset.

## 10. Traffic Works Internally but Not From the Internet

### Scenario

Service-to-service traffic works, but external users cannot reach the application.

### Ideal Answer

That usually means the application itself is up, but the exposure path is wrong. I would inspect ingress, load balancer type, listeners, target health, DNS records, TLS configuration, and security group rules controlling the entry path.

## 11. EKS Upgrade Introduces Application Instability

### Scenario

The cluster or node upgrade completed, but workloads behave unexpectedly afterward.

### Ideal Answer

I would separate whether the issue comes from Kubernetes version compatibility, add-on changes, node image differences, deprecated APIs, or application assumptions around scheduling and networking. Version-aware validation matters a lot during platform upgrades.

## 12. Pods Restart Frequently After Deployment

### Scenario

The deployment rolls out, but pods keep restarting.

### Ideal Answer

I would inspect logs, events, startup behavior, and probes first. If the workload depends on AWS secrets, storage, or network calls at startup, I would validate those dependencies because restart loops often reflect configuration or dependency timing issues.

## 13. EBS-Backed Workload Is Not Mounting Storage

### Scenario

The pod stays stuck or fails because persistent storage is not available.

### Ideal Answer

I would check the PVC and PV state, storage class configuration, CSI behavior, and whether the workload scheduling assumptions align with the storage model. I would also confirm whether the volume lifecycle and node placement are consistent with how the workload was designed.

## 14. EFS-Based Shared Storage Is Slow or Inconsistent

### Scenario

Multiple pods mount shared storage, but performance or access behavior is not as expected.

### Ideal Answer

I would verify whether the workload truly needs shared filesystem semantics, then inspect mount configuration, access pattern, and whether the performance expectations match the chosen storage model. Many teams pick shared storage before validating the actual application access pattern.

## 15. CloudWatch Shows Errors but Kubernetes Looks Fine

### Scenario

AWS-side metrics suggest failures, but Kubernetes objects seem healthy.

### Ideal Answer

I would correlate the specific AWS metric with the user-facing path. For example, load balancer error trends can reveal ingress routing or target health issues even if pods are technically running. A healthy pod does not always mean healthy end-user traffic.

## 16. Load Balancer Exists but Targets Stay Unhealthy

### Scenario

The AWS load balancer is created, but the targets never become healthy.

### Ideal Answer

I would check target port mapping, readiness behavior, service configuration, application bind port, and whether health check expectations match the actual app path. This often comes down to health path mismatch or service wiring issues.

## 17. Workloads in Private Subnets Cannot Reach Required External AWS Services

### Scenario

Internal workloads fail when calling AWS or internet dependencies.

### Ideal Answer

I would inspect the egress path first, including route tables, NAT pattern, DNS resolution, and security policy. In private-subnet designs, outbound access failures are often caused by incomplete route or egress assumptions rather than the application itself.

## 18. EKS Costs Suddenly Increase

### Scenario

The platform is working, but AWS cost rises unexpectedly.

### Ideal Answer

I would check node count trends, idle compute, log retention growth, unnecessary load balancers, storage expansion, and traffic patterns. In EKS, cost troubleshooting should include both Kubernetes resource behavior and AWS infrastructure consumption.
