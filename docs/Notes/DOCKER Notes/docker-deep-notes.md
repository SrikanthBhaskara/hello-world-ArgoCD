# Docker Deep Notes

## 1. What Docker Solves

Docker solves the problem of inconsistent runtime environments.

Before containers, teams often faced:
- works on my machine issues
- different dependency versions across environments
- slow and inconsistent deployment packaging
- difficult application portability

Docker improves this by packaging:
- application code
- runtime
- libraries
- system dependencies
- startup behavior

Good interview line:

"Docker gives a consistent application packaging boundary between development, CI, and runtime environments."

## 2. Image vs Container

### Image

An image is the build artifact.

It is:
- read-only
- versionable
- reusable

### Container

A container is the running instance of an image.

It includes:
- runtime state
- process execution
- writable layer
- environment-specific configuration

Strong answer:

"An image is the packaged blueprint, while a container is the live runtime instance created from that blueprint."

## 3. Containers vs Virtual Machines

Virtual machines:
- include a full guest OS
- virtualize hardware
- are heavier and slower to start

Containers:
- share the host kernel
- virtualize at the OS level
- are lighter and faster to start

Important tradeoff:
- containers are efficient and great for application packaging
- VMs can still be useful for stronger isolation or broader OS-level separation

## 4. Docker Architecture Basics

Main pieces:
- Docker client
- Docker daemon
- Docker images
- Docker containers
- Docker registry

Common flow:
1. Developer writes Dockerfile.
2. Docker builds image.
3. Image is tagged.
4. Image is pushed to registry.
5. Runtime pulls and starts containers.

## 5. Dockerfile Purpose

A Dockerfile defines how to build an image in a repeatable way.

Typical instructions:
- `FROM`
- `WORKDIR`
- `COPY`
- `RUN`
- `ENV`
- `EXPOSE`
- `CMD`
- `ENTRYPOINT`

Why it matters:
- image builds become reproducible
- image creation stays version-controlled

## 6. Layers and Build Cache

Each Dockerfile instruction usually creates a layer.

Why layers matter:
- cached builds can be much faster
- image reuse becomes more efficient
- bad Dockerfile ordering can slow CI drastically

Best practice idea:
- put less frequently changing layers first where practical
- avoid invalidating heavy dependency layers unnecessarily

## 7. Base Images

The base image is the starting point of the image build.

Good base image choices should consider:
- size
- security
- compatibility
- supportability

Important principle:
- smaller is usually better, but not at the cost of correctness or maintainability

## 8. Multi-Stage Builds

Multi-stage builds let you:
- build in one stage
- ship only runtime artifacts in final stage

Benefits:
- smaller images
- fewer tools in runtime image
- lower attack surface

Strong answer:

"I use multi-stage builds to keep build tooling out of the final runtime image and reduce both size and security exposure."

## 9. `CMD` vs `ENTRYPOINT`

`ENTRYPOINT` defines the main executable.

`CMD` provides:
- default command
- or default arguments

Why this matters:
- startup behavior becomes predictable
- overrides can be controlled more cleanly

## 10. `COPY` vs `ADD`

`COPY`:
- simple
- explicit
- preferred in most cases

`ADD`:
- has extra behaviors
- should be used intentionally

Best practice:
- prefer `COPY` unless there is a clear reason for the additional `ADD` behavior

## 11. Image Size and Why It Matters

Smaller images help:
- reduce pull time
- speed CI/CD
- reduce storage usage
- reduce attack surface

Why oversized images happen:
- unnecessary packages
- build tools included in runtime image
- bad `.dockerignore`
- copying too much build context

## 12. `.dockerignore`

`.dockerignore` prevents unnecessary files from entering build context.

This matters because:
- large context slows builds
- sensitive files may accidentally be included
- cache invalidation becomes worse

Typical exclusions:
- `.git`
- logs
- build output
- IDE files
- secrets

## 13. Container Networking Basics

Containers run with isolated networking by default.

Common concepts:
- container port
- host port mapping
- bridge networking
- service-to-service communication

Important point:
- exposing a port in the image is not the same as publishing it externally

## 14. `EXPOSE` vs Published Port

`EXPOSE`:
- documents the intended internal port

Published port:
- actually makes the port reachable from outside the container host path

Good answer:

"`EXPOSE` is image metadata, while runtime publishing is what actually creates outside access."

## 15. Volumes and Persistent Data

Containers are usually designed to be replaceable.

That means persistent data should live outside the container writable layer.

Common options:
- Docker volumes
- bind mounts

Volumes are useful for:
- databases
- logs
- persistent application state

## 16. Bind Mounts vs Volumes

Bind mounts:
- map a specific host path
- often useful in local development

Volumes:
- managed by Docker
- usually better for cleaner persistence handling

## 17. Environment Variables and Runtime Configuration

Docker images should usually stay environment-neutral where possible.

Environment-specific configuration should come at runtime through:
- environment variables
- mounted files
- external config systems

Important principle:
- avoid baking environment-specific secrets or mutable config directly into images

## 18. Logging in Containers

A good containerized app should log to:
- stdout
- stderr

Why:
- orchestrators and runtime platforms collect container output more easily that way

Bad pattern:
- writing logs only to hidden internal file paths with no collection strategy

## 19. Container Security Basics

Common Docker security concerns:
- running as root
- oversized images
- outdated vulnerable dependencies
- secrets in image layers
- unnecessary package installation

Good practices:
- use minimal image
- run as non-root where possible
- scan images in CI
- keep secrets out of Dockerfile and image layers

## 20. Immutable Container Principle

A strong container workflow treats images as immutable.

That means:
- rebuild instead of patching live container by hand
- redeploy instead of editing runtime state manually

Why:
- reproducibility
- easier debugging
- safer rollback

## 21. Container Startup Failures

Common reasons containers exit immediately:
- wrong startup command
- missing environment variable
- missing file or mounted dependency
- permission problem
- dependency startup failure

Troubleshooting approach:
1. check logs
2. inspect command and entrypoint
3. check environment and mounts
4. inspect image contents if needed

## 22. Build Failures

Common reasons image builds fail:
- wrong file path in Dockerfile
- missing file in build context
- broken dependency download step
- invalid base image reference
- cache assumptions that are no longer valid

## 23. Registry Flow

Images are commonly stored in registries such as:
- Docker Hub
- ECR
- private internal registries

Flow:
1. build image
2. tag image
3. push image
4. deployment platform pulls image

Important principle:
- image tagging should be traceable to source and build

## 24. Tagging Strategy

Good image tags should help answer:
- what code version is this
- what build produced it
- what environment uses it

Weak tagging:
- only `latest`

Better tagging:
- commit SHA
- build number
- semantic version when relevant

## 25. Docker in CI/CD

Docker often becomes the packaging boundary in pipelines.

Typical flow:
- code checkout
- build
- test
- image build
- image scan
- registry publish
- deployment using that exact image

Strong answer:

"In CI/CD, Docker gives us a traceable artifact boundary between build and runtime."

## 26. Docker Anti-Patterns

- treating containers like full VMs
- manually editing running containers
- huge images
- running everything as root
- baking secrets into images
- unclear startup commands
- weak logging strategy

## 27. Strong Interview Statements

- "A container image should be small, reproducible, and runtime-focused."
- "I prefer immutable images and externalized configuration."
- "Build-time and runtime concerns should be separated cleanly."
- "Logging to stdout and stderr fits container orchestration best."
- "A fast build is good, but a traceable and secure image is more important than speed alone."

## 28. Final Revision Checklist

Make sure you can explain:
- image vs container
- container vs VM
- Dockerfile purpose
- layering and cache
- multi-stage builds
- `CMD` vs `ENTRYPOINT`
- `.dockerignore`
- volumes vs bind mounts
- image security basics
- logging and runtime config
- CI/CD image flow
