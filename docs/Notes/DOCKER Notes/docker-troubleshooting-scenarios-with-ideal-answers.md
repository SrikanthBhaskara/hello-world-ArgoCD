# Docker Troubleshooting Scenarios With Ideal Answers

## 1. Container Exits Immediately After Startup

### Scenario

The container starts and stops right away.

### Ideal Answer

I would first check `docker logs` to see whether the application crashed or whether the startup command is incorrect. Then I would inspect the configured command, environment variables, mounted files, and permissions to determine whether the failure is in application startup or container configuration.

## 2. Image Build Fails During `COPY`

### Scenario

The Docker build fails because a file cannot be found.

### Ideal Answer

I would confirm that the file actually exists in the build context and is not excluded by `.dockerignore`. Then I would verify that the Dockerfile path is correct relative to the build context used in the build command.

## 3. Docker Build Is Very Slow

### Scenario

Image builds take too long in CI.

### Ideal Answer

I would look at the Dockerfile layer order, dependency download steps, cache invalidation pattern, and whether the build context is unnecessarily large. In many cases the main issue is weak cache design or too much content being copied too early.

## 4. Container Works Locally but Fails in Another Environment

### Scenario

It runs on a developer machine but not in CI or server runtime.

### Ideal Answer

I would compare environment variables, mounted files, networking assumptions, image tag consistency, and whether the local system is relying on cached state or local files that do not exist elsewhere.

## 5. Port Is Exposed but Application Is Still Not Reachable

### Scenario

The Dockerfile has `EXPOSE`, but requests still fail.

### Ideal Answer

I would verify whether the port is actually published at runtime, whether the application is truly listening on the expected internal port, and whether the host-to-container mapping is correct. `EXPOSE` alone does not create outside access.

## 6. Logs Are Empty but the App Is Failing

### Scenario

The container is unhealthy but `docker logs` shows little or nothing.

### Ideal Answer

I would check whether the application writes logs only to internal files instead of stdout or stderr. If needed, I would start an interactive shell and inspect the filesystem, startup behavior, and app configuration directly.

## 7. Image Pull Fails From Registry

### Scenario

The deployment platform cannot pull the image.

### Ideal Answer

I would verify the exact image name and tag first, then confirm the image exists in the registry, then check authentication and network access. This usually comes down to wrong image reference, missing artifact, or registry credential issues.

## 8. Container Has the Right Image but Uses Old Code

### Scenario

The container started successfully, but the application behavior looks outdated.

### Ideal Answer

I would validate the image tag, digest, and build traceability. Then I would check whether the latest code was actually included in the image build or whether cache behavior, wrong branch, or incorrect artifact copy step caused an old version to be packaged.

## 9. Secrets Are Visible Inside the Image

### Scenario

A review finds that sensitive values were baked into the image.

### Ideal Answer

I would treat that as both a security and process issue. The fix is to remove secrets from the image build path, rotate the exposed secret, rebuild the image, and redesign runtime secret delivery through environment injection or a secret-management system.

## 10. Container Uses Too Much Disk Space

### Scenario

The image is much larger than expected.

### Ideal Answer

I would inspect the base image choice, Dockerfile layers, unused packages, copied build artifacts, and whether build tools were left in the runtime image. Multi-stage builds usually help fix this quickly.

## 11. Application Cannot Write Required Data

### Scenario

The app runs but fails when writing files.

### Ideal Answer

I would check file paths, mounted volumes, directory ownership, and whether the container is running as a non-root user without appropriate write permission. This often comes down to runtime filesystem expectations versus container security posture.

## 12. Container Restart Loop Happens Repeatedly

### Scenario

The container keeps restarting under a platform manager or orchestrator.

### Ideal Answer

I would review startup logs, health behavior, resource usage, dependency timing, and whether the main process exits cleanly or crashes. Restart loops often reflect startup dependency or configuration issues rather than only platform instability.

## 13. Development Setup Needs Live Code Changes

### Scenario

The team wants code changes reflected quickly without rebuilding images every time.

### Ideal Answer

I would usually use bind mounts for local development so source files map directly into the container. For production-like environments, I would keep immutable image flow and avoid depending on live container mutation.

## 14. Build Succeeds but Runtime Command Is Wrong

### Scenario

The image builds, but the container starts the wrong process.

### Ideal Answer

I would inspect `CMD`, `ENTRYPOINT`, and any runtime override. Many startup problems come from misunderstanding how those fields combine, especially when arguments are overridden by the runtime platform.

## 15. Team Uses `latest` for Everything and Rollback Is Hard

### Scenario

The registry and deployments rely only on `latest`.

### Ideal Answer

I would explain that this is a traceability problem. The fix is to use explicit versioned tags like commit SHA or build number so teams can identify what is running and rollback to a previous image predictably.

## 16. Dockerfile Leaks Too Much Into the Build Context

### Scenario

Builds are slow and sensitive files may be included accidentally.

### Ideal Answer

I would improve `.dockerignore`, reduce copied content, and check whether local artifacts, `.git`, logs, or secrets are being included unnecessarily. Build context hygiene is a basic but high-value improvement.

## 17. Runtime Platform Pulls Image Slowly During Scale Events

### Scenario

Scaling is delayed because image pulls take too long.

### Ideal Answer

I would inspect image size first, then remove unnecessary dependencies, use multi-stage builds, and verify whether registry access is healthy. Slow image pulls directly affect rollout and recovery performance.

## 18. Containerization Effort Exists but Delivery Is Still Fragile

### Scenario

The team uses Docker, but deployments are still unreliable.

### Ideal Answer

That usually means Docker solved packaging consistency but the larger delivery system still has problems. I would look at config externalization, registry tagging, observability, deployment strategy, secret flow, and rollback readiness rather than assuming Docker alone should solve release stability.
