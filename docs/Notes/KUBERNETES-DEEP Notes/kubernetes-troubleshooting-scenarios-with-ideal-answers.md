# Kubernetes Troubleshooting Scenarios With Ideal Answers

## 1. Pod Is Running but the Application Is Still Down

### Scenario

The Pod status is `Running`, but the application is not working.

### Ideal Answer

I would not assume `Running` means healthy. First I would check readiness status, container logs, `kubectl describe pod`, mounted config, secrets, service wiring, and any downstream dependency the application needs during startup.

## 2. Pod Is in `CrashLoopBackOff`

### Scenario

The container starts and crashes repeatedly.

### Ideal Answer

I would inspect `kubectl describe pod` and previous logs first to see whether the process is crashing or being killed by probes. Then I would verify startup command, environment variables, secret values, mounted files, and whether the app needs more startup time before readiness or liveness checks begin.

## 3. Pod Is in `ImagePullBackOff`

### Scenario

The workload cannot pull the image.

### Ideal Answer

I would read the Pod event message carefully, because it usually tells whether the issue is image not found, wrong tag, registry authentication, or network access. Then I would confirm the image reference, registry credentials, and whether the runtime actually has permission to pull.

## 4. Service Exists but No Traffic Reaches the App

### Scenario

The Service is created, but requests fail.

### Ideal Answer

I would verify the selector labels, Pod labels, target port, container port, and whether endpoints are created for the Service. In many cases the issue is a selector mismatch or the application not listening on the port the Service expects.

## 5. Ingress Exists but the URL Fails

### Scenario

The Ingress is present, but external access does not work.

### Ideal Answer

I would move outward layer by layer: ingress object, ingress controller, backend Service, endpoints, DNS, and TLS. If Pods are healthy but traffic still fails, the problem is usually in routing, DNS, certificate configuration, or edge-controller behavior.

## 6. Readiness Probe Keeps Failing

### Scenario

The Pod starts but never becomes ready.

### Ideal Answer

I would check whether the probe path, port, and expected response actually match application behavior. I would also verify whether the app simply needs more startup time, because an aggressive readiness configuration can keep a healthy app from ever entering service.

## 7. Liveness Probe Causes Frequent Restarts

### Scenario

The container keeps restarting because liveness checks fail.

### Ideal Answer

I would check whether liveness is configured too aggressively or is pointing to a path that does not reflect real process health. Liveness should detect a truly stuck or broken app, not punish a slow-starting but otherwise normal application.

## 8. Secret Exists but Authentication Still Fails

### Scenario

The Secret object is present, but the application still cannot authenticate.

### Ideal Answer

I would confirm the Secret key names, whether the Pod references the intended Secret, whether the application expects a different format, and whether the container needs restart or reload to pick up the values. Often the issue is not missing Secret but wrong key mapping or application expectation mismatch.

## 9. ConfigMap Was Updated but the App Did Not Reflect the Change

### Scenario

Configuration changed, but runtime behavior did not.

### Ideal Answer

I would check how the application consumes the ConfigMap. If it is loaded only at startup through environment variables, the Pod usually needs restart. If it is mounted as a file, I would verify whether the app supports live reload or still requires restart logic.

## 10. Deployment Rollout Gets Stuck

### Scenario

The Deployment does not finish rolling out.

### Ideal Answer

I would check rollout status, unavailable replicas, readiness failures, image pull issues, quota problems, and whether new Pods are ever becoming ready. A stuck rollout often points to readiness, scheduling, or bad image/config rather than the Deployment object itself.

## 11. Pods Stay Pending

### Scenario

Pods are created but never scheduled.

### Ideal Answer

I would inspect scheduling events first to see whether the issue is CPU or memory shortage, taints, node selectors, affinity rules, PVC binding, or quota limits. Pending Pods are usually a scheduling or dependency issue rather than an application bug.

## 12. Persistent Volume Claim Does Not Bind

### Scenario

The workload depends on storage, but PVC stays unbound.

### Ideal Answer

I would verify the storage class, access mode, requested size, and whether a matching provisioner exists. Then I would confirm whether the workload assumptions fit the underlying storage model, especially for zone or access-mode constraints.

## 13. Node Is Ready but One App Family Keeps Failing

### Scenario

The cluster looks healthy, but only specific workloads are unstable.

### Ideal Answer

That suggests the problem is likely at the workload layer rather than a full cluster issue. I would compare config, image version, resource settings, service account, secrets, and network path for the failing app group against a healthy one.

## 14. Resource Usage Is Fine but Users Still See Errors

### Scenario

CPU and memory look normal, but traffic fails.

### Ideal Answer

I would look beyond node-level metrics and inspect logs, error rate, readiness state, service endpoints, ingress routing, and downstream dependency behavior. A healthy node does not guarantee a healthy user path.

## 15. Manual Hotfix Worked but Keeps Disappearing

### Scenario

An engineer edits a live resource, but the change does not stay.

### Ideal Answer

If the cluster is managed through GitOps or another reconciliation system, that is expected. I would explain that the right fix is to update the source of truth, not rely on manual live edits that create temporary drift.

## 16. Namespace Quota or Policy Blocks Deployment

### Scenario

The manifest is valid, but resources do not get created.

### Ideal Answer

I would inspect events, namespace quotas, admission policies, and RBAC results. Kubernetes failures are not always syntax or runtime problems; policy and governance controls can block valid manifests too.

## 17. Service-to-Service Calls Fail Intermittently

### Scenario

Pods are healthy, but internal calls are unstable.

### Ideal Answer

I would check service endpoints, DNS resolution, network policies, rolling updates, and whether clients handle connection reuse or retries properly. Intermittent failures often come from networking transitions or dependency behavior under rollout.

## 18. Cluster Looks Fine but Production Recovery Is Slow

### Scenario

The issue is eventually fixed, but restoration took too long.

### Ideal Answer

I would review observability quality, alert clarity, ownership, rollback readiness, and whether the team had a known troubleshooting path. Slow recovery is usually a system-design or operational-discipline problem, not only an isolated incident.
