# DevOps Troubleshooting Scenarios With Ideal Answers

## 1. Build Starts Failing Suddenly in CI

### Scenario

The pipeline was passing earlier, but now builds fail.

### Ideal Answer

I would first identify whether the failure comes from code changes, dependency resolution, environment changes, expired credentials, or infrastructure issues in the CI runner. Then I would confirm whether the failure is deterministic or intermittent before going deeper.

## 2. Unit Tests Pass but Deployment Fails

### Scenario

The build is green, but deployment to the target environment fails.

### Ideal Answer

That usually means the problem is outside pure application correctness. I would inspect deployment configuration, credentials, environment-specific values, secret references, infrastructure dependencies, and whether the artifact being deployed is actually the intended version.

## 3. Deployment Succeeds but Application Is Unhealthy

### Scenario

The pipeline completes, but the application does not work after release.

### Ideal Answer

I would separate delivery success from runtime success. Then I would check health endpoints, logs, events, resource limits, startup dependencies, configuration, and any load balancer or ingress path issues.

## 4. Pipeline Is Too Slow

### Scenario

Developers complain that CI takes too long and slows delivery.

### Ideal Answer

I would measure where time is being spent first. Then I would look at parallelizing safe stages, improving caching, removing redundant work, separating fast feedback from slower deeper checks, and verifying whether large container builds or test setup are the real bottlenecks.

## 5. Pipeline Is Fast but Production Failures Are Increasing

### Scenario

Delivery speed improved, but change failure rate is rising.

### Ideal Answer

That suggests the pipeline is optimized for speed more than release safety. I would review test quality, configuration validation, deployment strategy, observability after release, and whether we have enough pre-production confidence and rollback readiness.

## 6. Infrastructure Drift Is Detected

### Scenario

Actual infrastructure no longer matches the IaC definition.

### Ideal Answer

I would first identify whether the drift came from manual changes, failed automation, emergency fixes, or unmanaged resources. Then I would decide whether to reconcile back to code-defined state or intentionally capture the new state in IaC after review.

## 7. Secret Is Missing in Runtime

### Scenario

The application starts failing because a required secret is missing.

### Ideal Answer

I would confirm the secret source of truth, the delivery path, the consuming application reference, and whether the secret sync or injection mechanism failed. I would also check whether the issue is permission-related or simply a naming and environment mismatch.

## 8. Rollback Is Needed During a Bad Release

### Scenario

A deployment is causing production impact and needs to be reversed quickly.

### Ideal Answer

I would use the safest available rollback path based on the platform, such as reverting the deployment manifest, switching traffic back, or restoring the previous known good artifact. I would also ensure that the rollback itself is observable and validated before closing the incident.

## 9. Monitoring Shows CPU Is Fine but Users Still See Errors

### Scenario

Infrastructure looks healthy, but the service is failing from the user perspective.

### Ideal Answer

That means infrastructure metrics alone are not enough. I would inspect logs, traces, upstream and downstream dependency errors, ingress or load balancer behavior, and business-level health signals to locate the failure boundary.

## 10. Alerts Are Too Noisy

### Scenario

The team receives many alerts, but most are not actionable.

### Ideal Answer

I would review which alerts correlate with real incidents and which do not. Then I would reduce noise by improving thresholds, removing low-value signals, and making alerts more service-impact-aware so engineers can trust them again.

## 11. A Release Works in Dev but Fails in Prod

### Scenario

The same application behaves differently across environments.

### Ideal Answer

I would compare environment-specific configuration, secrets, traffic path, infrastructure assumptions, and dependency versions. This usually points to environment drift or config mismatch rather than a purely random application failure.

## 12. Container Build Works Locally but Fails in CI

### Scenario

Developers can build locally, but CI fails.

### Ideal Answer

I would compare build context, base image availability, dependency access, environment variables, Dockerfile assumptions, and whether local machines rely on cached state that CI does not have.

## 13. GitOps App Keeps Returning to the Old State

### Scenario

A manual runtime change is made, but it does not persist.

### Ideal Answer

That is expected in a GitOps model if the controller is reconciling desired state from Git. The right fix is to update the source-controlled desired state rather than relying on manual environment edits.

## 14. Incident Recovery Took Too Long

### Scenario

The system eventually recovered, but the response time was poor.

### Ideal Answer

I would review the detection delay, ownership clarity, observability quality, rollback readiness, and whether the team had a clear runbook or known recovery path. Slow recovery often reflects system design gaps, not just human delay.

## 15. Prod Change Was Made Manually and Nobody Knows Why

### Scenario

An environment change happened outside the normal workflow and caused confusion later.

### Ideal Answer

That is a governance and traceability issue. I would restore controlled change flow by identifying the difference, deciding whether to revert or codify it, and reducing the ability to make undocumented runtime changes in the future.

## 16. Autoscaling Did Not Prevent User Impact

### Scenario

Traffic increased, scaling happened, but the service still struggled.

### Ideal Answer

Scaling does not always solve the real bottleneck. I would check whether the delay was in scale-up time, dependency saturation, database or queue pressure, cold start impact, or whether the resource metric itself was the wrong signal for scaling.

## 17. A Deployment Pipeline Needs Better Safety

### Scenario

Changes reach production too easily without enough confidence checks.

### Ideal Answer

I would add validation where it gives the most value, such as stronger automated tests, config validation, image or dependency scanning, progressive rollout, health verification, and rollback readiness. The goal is controlled delivery, not simply more gates.

## 18. Nobody Knows Which Version Is Running

### Scenario

During an incident, the team cannot quickly confirm what artifact is in production.

### Ideal Answer

That is a traceability gap. I would improve artifact versioning, deployment metadata visibility, release dashboards, and links between commit, build, image tag, and runtime environment so release state becomes obvious.
