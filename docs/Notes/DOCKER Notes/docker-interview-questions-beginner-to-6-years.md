# Docker Interview Questions with Answers: Beginner to 6 Years

## Purpose

This file prepares you for Docker interviews from beginner to around 6 years of experience.

Deep revision files:
- [Docker deep notes](./docker-deep-notes.md)
- [Docker with Kubernetes deep notes](./docker-with-kubernetes-deep-notes.md)

It includes:
- question
- short answer
- better answer for interviews
- what interviewer is checking
- sample commands where useful

## Beginner (0 to 2 Years)

### 1. What is Docker?
Short answer:
Docker is a containerization platform used to package an application with its dependencies so it runs consistently across environments.

Better answer:
Docker helps package code, runtime, libraries, and configuration into an image that can run the same way on a laptop, CI system, or server. It reduces environment mismatch and makes delivery faster and more predictable.

What interviewer checks:
- basic containerization understanding
- environment consistency concept

### 2. Difference between a container and a virtual machine?
Short answer:
A VM includes a full guest OS, while a container shares the host kernel and is lighter.

Better answer:
Virtual machines virtualize hardware and run their own OS, so they use more resources and take longer to start. Containers virtualize at the OS level, share the host kernel, and start faster. VMs are useful for stronger isolation or mixed OS needs, while containers are ideal for app packaging and scaling.

What interviewer checks:
- architecture basics
- tradeoff awareness

### 3. Difference between a Docker image and a Docker container?
Short answer:
An image is a read-only blueprint, and a container is a running instance of that image.

Better answer:
A Docker image is the packaged artifact created during the build step. A container is the live runtime instance created from that image. Multiple containers can run from the same image with different runtime settings.

What interviewer checks:
- image lifecycle understanding
- build vs runtime clarity

### 4. What is a Dockerfile?
Short answer:
A Dockerfile contains instructions to build a Docker image.

Better answer:
A Dockerfile defines repeatable image creation steps such as selecting a base image, copying files, installing dependencies, exposing ports, and defining the startup command. Because it is version-controlled, it makes builds reproducible.

### 5. Difference between `CMD` and `ENTRYPOINT`?
Short answer:
`CMD` provides a default command or arguments, while `ENTRYPOINT` defines the main executable.

Better answer:
Use `ENTRYPOINT` when the container should always start a specific executable. Use `CMD` for default arguments or a fallback command. Together they let you define stable startup behavior while still allowing overrides.

Sample:
```bash
docker run my-image --help
```
If `ENTRYPOINT` is fixed, `--help` can become an argument to it.

### 6. Difference between `COPY` and `ADD`?
Short answer:
`COPY` is the simpler file-copy instruction, while `ADD` has extra behavior like archive extraction.

Better answer:
In production Dockerfiles, `COPY` is usually preferred because it is explicit and predictable. `ADD` should be used only when you intentionally need its extra behavior.

### 7. What is a Docker volume?
Short answer:
A volume is persistent storage managed outside the container lifecycle.

Better answer:
Volumes keep data alive even if the container is deleted. They are commonly used for databases, logs, or any state that should survive container replacement.

### 8. Difference between a bind mount and a volume?
Short answer:
A bind mount maps a host path directly, while a volume is managed by Docker.

Better answer:
Bind mounts are useful in development when you want live access to local files. Volumes are better for stable, Docker-managed persistent storage in shared or production-like environments.

### 9. What is port mapping in Docker?
Short answer:
It maps a host port to a container port so the application can be reached from outside the container.

Better answer:
Containers have their own network namespace. Port mapping publishes the application through the host so users or other systems can access it.

Sample:
```bash
docker run -p 8080:8080 my-app
```

### 10. How do you see container logs?
Short answer:
Use `docker logs <container>`.

Better answer:
I typically start with `docker logs`, then check whether the container exited, inspect the startup command, and if needed open an interactive shell for deeper debugging.

Sample:
```bash
docker logs my-app
docker logs -f my-app
```

## Intermediate (2 to 4 Years)

### 11. What are common Dockerfile best practices?
Short answer:
Use small base images, multi-stage builds, pinned versions, non-root users, and a `.dockerignore` file.

Better answer:
A good Dockerfile is optimized for security, repeatability, and build speed. I prefer multi-stage builds, minimal runtime images, explicit dependency versions where needed, non-root execution, and keeping secrets out of the build context.

### 12. What is a multi-stage build and why is it useful?
Short answer:
It uses multiple build stages so the final image contains only runtime artifacts.

Better answer:
Multi-stage builds reduce image size and improve security by removing build tools from the final image. For example, a Java service can be compiled in one stage and only the jar and runtime files copied into a smaller runtime image.

Sample:
```dockerfile
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn -q -DskipTests package

FROM eclipse-temurin:17-jre
COPY --from=build /app/target/app.jar /app/app.jar
ENTRYPOINT ["java","-jar","/app/app.jar"]
```

### 13. Why are small images important?
Short answer:
They reduce pull time, attack surface, and storage usage.

Better answer:
Smaller images improve CI/CD speed, reduce registry and node storage usage, and lower the number of unnecessary packages that could become security risks.

### 14. What is the purpose of `.dockerignore`?
Short answer:
It prevents unnecessary files from being sent to the Docker build context.

Better answer:
Without `.dockerignore`, the build context may include logs, build artifacts, `.git`, local secrets, or temporary files. That slows builds and can accidentally leak sensitive or unnecessary content into images.

### 15. How do you troubleshoot a container that exits immediately?
Short answer:
Check logs, inspect the command, and verify environment variables, file paths, and permissions.

Better answer:
I first run `docker logs`, confirm the entrypoint and command, inspect environment variables, check mounted files, and verify whether the process is crashing during startup. If needed, I start the image with a shell to inspect the runtime environment interactively.

### 16. How do you troubleshoot image build failures?
Short answer:
Check the failed layer, build context, file paths, and dependency or network-related steps.

Better answer:
I identify the failing instruction, confirm the referenced files actually exist in the build context, validate base-image availability, and check whether package or dependency downloads are failing. Build failures are usually caused by wrong paths, bad cache assumptions, or broken external dependency steps.

### 17. Difference between `EXPOSE` and actual port publishing?
Short answer:
`EXPOSE` documents the intended port in the image, but publishing happens at runtime with `-p` or orchestration config.

Better answer:
`EXPOSE` does not make a service reachable by itself. It simply describes the internal port. Real access requires host-port publishing or orchestrator-level networking rules.

### 18. What security problems should you watch for in Docker images?
Short answer:
Watch for root users, secrets baked into images, unnecessary packages, and outdated vulnerable dependencies.

Better answer:
The main risks are oversized images, running as root, embedded credentials, weak base-image hygiene, and dependency vulnerabilities. I try to keep images minimal, run as a non-root user, and scan images in CI when possible.

### 19. Why should containers usually be immutable?
Short answer:
Because reproducible containers are easier to scale, debug, and redeploy.

Better answer:
If teams modify containers manually after startup, runtime drift appears and debugging gets harder. Immutable images support predictable rollouts because every environment runs the same artifact.

## Experienced (4 to 6 Years)

### 20. How does Docker fit into a CI/CD pipeline?
Short answer:
The application is built, tested, packaged as an image, pushed to a registry, and then deployed through automation.

Better answer:
In most pipelines, Docker is the packaging boundary between build and deployment. CI creates a versioned image, scans or validates it, pushes it to a registry, and deployment systems pull that exact artifact into the target environment.

### 21. How do you explain your Docker experience from this project?
Short answer:
I used Docker to package services consistently for CI/CD and Kubernetes deployment.

Better answer:
I worked with Dockerized Java and platform services where images were built through CI, tagged and pushed to registries such as ECR, and then consumed by Kubernetes or GitOps-based delivery flows. I also handled debugging of image build issues, startup failures, registry authentication, and runtime configuration problems.

### 22. What are common Docker anti-patterns?
Short answer:
Large images, root execution, hardcoded secrets, mutable runtime changes, and weak observability.

Better answer:
The most common anti-patterns are treating containers like full VMs, installing too much into the image, hardcoding credentials, modifying containers manually, and not logging clearly to stdout or stderr. Those patterns make delivery fragile and operations harder.

### 23. How do you think about image tagging strategy?
Short answer:
Tags should be traceable, stable where needed, and tied to a clear build source.

Better answer:
I prefer immutable versioned tags such as commit SHA or release number, sometimes with a convenience tag like `latest` for non-production use. The important part is traceability from a running container back to the exact build.

### 24. How would you debug `ImagePullBackOff` in Kubernetes when the image itself was built correctly?
Short answer:
Check registry auth, image name, tag, repository permissions, and pull secrets.

Better answer:
A good image can still fail at deploy time because of registry reachability, bad image tag references, missing image pull secrets, or service-account configuration issues. I debug both the registry side and the cluster side.

## Quick Revision Topics

- image vs container
- Dockerfile instructions
- volumes and bind mounts
- multi-stage builds
- `CMD` vs `ENTRYPOINT`
- `.dockerignore`
- image security basics
- logs and startup troubleshooting

