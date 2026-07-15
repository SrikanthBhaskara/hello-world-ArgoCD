# ArgoCD Troubleshooting Scenarios With Ideal Answers

## 1. Application Is OutOfSync but Pods Look Fine

### Scenario

ArgoCD shows `OutOfSync`, but the application appears to be working.

### Ideal Answer

I would first inspect the diff in ArgoCD to understand what changed. If the difference is caused by expected mutation from another controller, generated fields, or HPA-driven replica count changes, I would decide whether diff customization is appropriate. If it is an unintended manual change, I would sync or enable self-heal depending on the environment policy.

## 2. Application Is Synced but Health Is Degraded

### Scenario

The application is `Synced`, but ArgoCD marks it `Degraded`.

### Ideal Answer

This tells me Git and cluster match, so deployment reconciliation likely succeeded. I would then shift to Kubernetes runtime debugging by checking pod status, logs, events, probes, image pull results, service dependencies, and secret availability.

## 3. Sync Fails With Permission Denied

### Scenario

ArgoCD cannot create or update resources due to RBAC errors.

### Ideal Answer

I would confirm whether the ArgoCD application destination and service account have the required permissions for that namespace and resource kind. Then I would review AppProject restrictions, cluster RBAC, and whether the target resource is intentionally blocked by policy.

## 4. Helm-Based Application Fails to Render

### Scenario

A sync fails during manifest generation for a Helm-based application.

### Ideal Answer

I would inspect chart path, revision, values files, and parameter overrides first. Then I would validate whether the chart template expects values that are missing or malformed. If needed, I would render the chart locally or through the repo server context to isolate the exact template failure.

## 5. Pods Crash After Successful Sync

### Scenario

ArgoCD sync succeeds, but the deployment is not stable.

### Ideal Answer

That means ArgoCD successfully applied manifests, but the workload is failing at runtime. I would check container logs, environment variables, secrets, ConfigMaps, health probes, service discovery, and downstream dependencies to find the operational cause.

## 6. Secret-Dependent App Fails to Start

### Scenario

Pods crash because a required secret is missing.

### Ideal Answer

I would verify whether the secret is supposed to come from ArgoCD-managed manifests, an External Secrets workflow, or another controller. Then I would check ordering, secret controller health, namespace correctness, and whether the workload starts before the secret becomes available.

## 7. ApplicationSet Generates Wrong Applications

### Scenario

ApplicationSet creates too many or incorrectly targeted Applications.

### Ideal Answer

I would inspect the generator inputs first, such as cluster list, git paths, or matrix combinations. Then I would review template variables and naming rules. This kind of issue is important because ApplicationSet mistakes can create broad blast radius across environments.

## 8. CRD-Based Resource Fails During Sync

### Scenario

A custom resource fails because the CRD is not ready.

### Ideal Answer

I would check whether the CRD and dependent custom resources are applied in the same sync without proper ordering. In that case I would use sync waves or split the deployment so CRDs are applied before their custom resources.

## 9. Manual Cluster Change Keeps Reappearing

### Scenario

An engineer changes a live deployment, but ArgoCD keeps reverting it.

### Ideal Answer

That is expected if self-heal is enabled and Git is the source of truth. I would explain that the right fix is to update the manifest in Git rather than change the live cluster directly, unless it is a short-lived emergency action with agreed follow-up.

## 10. Git Change Is Merged but ArgoCD Does Not Deploy It

### Scenario

The change is in Git, but cluster state does not update.

### Ideal Answer

I would check the configured repo URL, branch or tag, path, and webhook or polling status. I would also confirm whether automated sync is enabled and whether the application is blocked by sync errors, health gates, or repo access issues.

## 11. Prune Deletes Something Unexpected

### Scenario

After sync, an important resource is deleted.

### Ideal Answer

I would first identify whether the resource was removed from Git intentionally or by mistake. Then I would review repo history, sync options, and ownership boundaries. This is why prune is powerful but should be combined with strong review and safe repo structure.

## 12. ArgoCD Shows Noise in Diff for Every Sync

### Scenario

An application repeatedly shows diffs even when nothing meaningful changed.

### Ideal Answer

I would inspect whether another controller or admission webhook is mutating fields after apply. If the fields are operationally safe to ignore, I would configure diff customization rather than force teams to live with permanent noisy drift.

## 13. Sync Hook Fails

### Scenario

A `PreSync` or `PostSync` hook job fails and the deployment stops.

### Ideal Answer

I would check the hook pod logs, its RBAC, image, environment variables, and dependencies. Then I would confirm whether the hook should be blocking, retried, or redesigned. Hooks are useful, but if they are too fragile they can make release flow unreliable.

## 14. ArgoCD UI Shows Unknown Status

### Scenario

Application or resource status is `Unknown`.

### Ideal Answer

I would inspect whether the controller can read the resource, whether the resource kind is supported for health evaluation, and whether there are connectivity or permission issues between ArgoCD and the target cluster.

## 15. Production Rollback Is Needed Quickly

### Scenario

A new deployment is causing issues and rollback is required.

### Ideal Answer

I would prefer reverting the bad Git commit and syncing the previous known good state. That keeps rollback consistent with GitOps, preserves auditability, and reduces the risk of creating a new source of truth outside Git.

## 16. ArgoCD App Is Healthy but User Traffic Fails

### Scenario

ArgoCD says the app is healthy, but real users still see failures.

### Ideal Answer

I would treat this as an application-path or networking issue rather than only an ArgoCD problem. I would check service selectors, ingress rules, DNS, TLS, downstream calls, and application logs because ArgoCD health alone does not guarantee end-to-end business functionality.

## 17. Repo Server Has Access Problems

### Scenario

ArgoCD cannot fetch the repository.

### Ideal Answer

I would verify repository credentials, connectivity, certificate trust, repo URL correctness, and whether access tokens or SSH keys expired. Without repo access, desired manifests cannot be rendered, so sync cannot proceed.

## 18. Multi-Cluster Deployment Goes to Wrong Cluster

### Scenario

An app is deployed to an unexpected cluster.

### Ideal Answer

I would inspect the Application destination settings and, if ApplicationSet is used, the cluster generator inputs and template variables. I would also review naming and project restrictions, because destination mistakes can become high-risk in multi-cluster environments.
