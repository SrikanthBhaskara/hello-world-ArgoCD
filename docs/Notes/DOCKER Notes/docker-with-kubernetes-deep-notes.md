# Docker With Kubernetes Deep Notes

## 1. Why Docker Knowledge Still Matters in Kubernetes

Even when Kubernetes is the runtime orchestrator, container packaging quality still matters.

Kubernetes does not fix:
- bad image design
- large images
- weak startup commands
- poor logging behavior
- secrets baked into images

Good interview line:

"Kubernetes manages containers at scale, but the quality of the container image still heavily affects startup reliability, rollout speed, and operational safety."

## 2. Docker Is the Packaging Layer, Kubernetes Is the Orchestration Layer

Simple mental model:

- Docker or container build process creates the artifact
- registry stores the artifact
- Kubernetes pulls and runs the artifact

Why this matters:
- build mistakes become deployment problems later
- image design decisions affect scheduling, rollout, and debugging

## 3. Image Build Flow Into Kubernetes

Typical flow:
1. code is built in CI
2. Docker image is created
3. image is tagged and pushed to registry
4. Kubernetes deployment references that tag
5. cluster nodes pull and start the container

Strong answer:

"In Kubernetes environments, the image is the runtime contract between CI and the cluster."

## 4. Why Small Images Matter More in Kubernetes

Large images hurt Kubernetes operations because they increase:
- image pull time
- rollout duration
- node storage pressure
- recovery time after restart

This becomes especially important when:
- pods scale frequently
- nodes are replaced
- multi-zone clusters need repeated pulls

## 5. Multi-Stage Builds Help Kubernetes Too

Multi-stage builds improve Kubernetes runtime because:
- images pull faster
- fewer tools exist in runtime layer
- startup environment is cleaner

Operational benefit:
- rollouts become safer and more efficient

## 6. Ports and Kubernetes Services

Docker image may expose an internal port, but Kubernetes controls service access.

Important distinction:
- container listens on an internal port
- Kubernetes `Service` exposes or routes traffic to that port
- `Ingress` may expose it externally

Good answer:

"The container port is an application detail, while Service and Ingress define how traffic reaches that container in the cluster."

## 7. `EXPOSE` Does Not Replace Kubernetes Service Definition

Even if a Dockerfile includes `EXPOSE 8080`, Kubernetes still needs explicit service or ingress configuration.

Why:
- Kubernetes networking is declarative and separate from image metadata

## 8. Logging in Docker Images for Kubernetes

In Kubernetes, the best logging pattern is still:
- log to stdout
- log to stderr

Why:
- `kubectl logs` depends on container output
- centralized log systems often rely on container stdout or stderr collection

Bad pattern:
- writing only to a file inside the container with no collector strategy

## 9. Configuration Management

Docker images should not contain environment-specific runtime config when Kubernetes is responsible for deploying them across environments.

Better pattern:
- image stays generic
- environment config comes from:
  - environment variables
  - ConfigMaps
  - Secrets

Strong answer:

"I want the same image promoted across environments while runtime configuration changes through Kubernetes config and secret objects."

## 10. Secrets and Docker Images

Never bake secrets into:
- Dockerfile
- image layers
- committed runtime files copied into image

Why this is especially dangerous in Kubernetes:
- the same image may be pulled across many nodes and environments
- registry access can widen exposure

## 11. Image Pull Failures in Kubernetes

Common causes:
- wrong image name
- wrong tag
- private registry auth issue
- image does not exist
- node cannot access registry

Troubleshooting flow:
1. inspect pod events
2. verify image reference
3. confirm registry auth or pull secret
4. confirm image exists

## 12. Startup Commands and Probes

Weak image startup behavior often causes Kubernetes issues.

Examples:
- app crashes immediately
- app starts too slowly
- wrong entrypoint or command
- readiness probe fails because app never binds correctly

Important relationship:
- container startup design directly affects liveness and readiness behavior

## 13. Health Checks and Containers

Kubernetes health checks assume the container behaves predictably.

If image design is weak:
- probes fail
- rollouts hang
- restarts become noisy

This is why Docker and Kubernetes cannot be treated as separate interview topics.

## 14. Resource Usage and Image Design

Image design affects runtime usage indirectly through:
- included runtime footprint
- startup cost
- dependency weight
- process behavior

Kubernetes-level resource configuration still matters:
- CPU requests
- CPU limits
- memory requests
- memory limits

But poor container design can still make resource tuning harder.

## 15. Docker Volumes vs Kubernetes Volumes

Docker local persistence often uses:
- volumes
- bind mounts

Kubernetes uses:
- volume abstractions
- PVC and PV patterns
- storage classes

Good answer:

"In local Docker, persistence is usually simple host or Docker-managed storage. In Kubernetes, persistence becomes a declarative platform concern with volume and storage abstractions."

## 16. Registry and Artifact Promotion

In Kubernetes delivery, the image registry becomes a key part of promotion.

Typical model:
- CI builds once
- same image is promoted
- manifests or Helm values change by environment

Why this is better:
- avoids rebuilding different artifacts for each environment
- improves traceability

## 17. Kubernetes Rollouts Depend on Container Quality

Rollout safety is affected by:
- image pull speed
- startup reliability
- probe behavior
- dependency initialization
- backward compatibility of config

So even if Kubernetes deployment strategy is strong, poor container images still create unstable rollouts.

## 18. Common Docker-to-Kubernetes Anti-Patterns

- using `latest` tag in deployments
- baking environment-specific config into image
- large image with slow pulls
- poor logging design
- app not listening on expected port
- startup command that behaves differently locally and in cluster
- mutable container assumptions

## 19. Local Docker vs Kubernetes Runtime Differences

Something can work locally in Docker and still fail in Kubernetes because of:
- different environment variables
- different startup timing
- missing secret or ConfigMap
- readiness or liveness probes
- service routing expectations
- resource limits

Good interview line:

"A local container run proves only the image can start in one context. Kubernetes introduces orchestration, networking, probes, config injection, and scaling concerns beyond that."

## 20. Example Runtime Chain

```text
Code
  -> Docker build
  -> Image pushed to registry
  -> Kubernetes Deployment references image
  -> Pod starts container
  -> Service routes internal traffic
  -> Ingress or Load Balancer routes external traffic
```

## 21. Strong Interview Statements

- "A good Kubernetes deployment starts with a good image."
- "Container images should stay generic and environment-neutral."
- "If logs are not on stdout or stderr, Kubernetes troubleshooting becomes harder."
- "Registry, image tag, startup command, and probes all form one operational chain."
- "Kubernetes scales containers, but it does not fix poor container design."

## 22. Final Revision Checklist

Make sure you can clearly explain:
- Docker as packaging, Kubernetes as orchestration
- why image size affects Kubernetes rollout speed
- why config should stay outside the image
- why logging to stdout matters
- how image pull failures appear in Kubernetes
- why probes depend on correct startup behavior
- why same image should move across environments
