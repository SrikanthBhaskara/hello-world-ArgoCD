# CI/CD, GitOps, Rollback, and Observability Architecture Examples

## 1. Classic CI/CD Architecture Flow

High-level flow:

1. Developer pushes code to Git.
2. CI pipeline triggers.
3. Build and unit tests run.
4. Static analysis and security checks run.
5. Artifact is packaged.
6. Artifact is published to registry or artifact store.
7. Deployment pipeline updates target environment.
8. Post-deployment verification runs.
9. Monitoring confirms runtime health.

Good interview line:

"A good CI/CD architecture separates build validation, artifact publishing, deployment control, and post-release verification."

## 2. Example Stage Layout for a Pipeline

```text
Source
  -> Build
  -> Unit Test
  -> Static Analysis
  -> Security Scan
  -> Package
  -> Publish Artifact
  -> Deploy to Dev
  -> Smoke Test
  -> Promote to QA
  -> Approval or Policy Gate
  -> Deploy to Prod
  -> Post-Deploy Observability Check
```

## 3. Strong CI/CD Design Principles

- same artifact should move across environments when possible
- environment-specific config should stay externalized
- secrets should not be baked into artifacts
- every deployment should be traceable to commit and build
- rollback path should be defined before production release

## 4. GitOps Architecture Flow

High-level flow:

1. Application code is built in CI.
2. CI publishes the artifact.
3. CI updates deployment config in Git.
4. Git becomes the desired-state source.
5. GitOps controller detects the change.
6. Controller reconciles runtime environment to match Git.
7. Drift is continuously detected.

Good interview line:

"In GitOps, CI produces and publishes the artifact, while the runtime controller is responsible for convergence of environment state from Git."

## 5. Push-Based vs Pull-Based Architecture

### Push-Based

```text
Developer -> CI Pipeline -> Direct Deploy to Environment
```

### Pull-Based

```text
Developer -> CI Pipeline -> Update Desired State in Git -> Controller Syncs Environment
```

### Practical Difference

- push-based is simpler to start
- pull-based improves declarative control and drift visibility

## 6. GitOps Promotion Example

```text
Code Commit
  -> CI Build and Test
  -> Image Publish
  -> Update Dev Manifest in Git
  -> Controller Syncs Dev
  -> Validation
  -> Promote by Updating QA Manifest
  -> Controller Syncs QA
  -> Approval
  -> Promote by Updating Prod Manifest
  -> Controller Syncs Prod
```

Good practice:
- promotion should be explicit and reviewable
- avoid rebuilding different artifacts for each environment

## 7. Rollback Architecture Thinking

Rollback should be part of the delivery design, not an afterthought.

Possible rollback models:
- previous artifact redeploy
- Git revert and environment resync
- blue-green traffic switchback
- canary halt and rollback

Important questions:
- how fast can rollback happen
- how safely can rollback happen
- how do we confirm rollback worked

## 8. Blue-Green Rollback Example

```text
Blue = current production
Green = new release candidate

Deploy Green
Run validation
Shift traffic to Green
If failure occurs:
  Shift traffic back to Blue
```

Benefits:
- fast rollback
- clearer isolation between old and new versions

Tradeoff:
- more infrastructure overhead during the transition

## 9. Canary Rollout Example

```text
Deploy new version to 5%
Observe metrics and errors
Increase to 25%
Observe again
Increase to 100% if healthy
Rollback if error rate increases
```

Benefits:
- smaller blast radius
- real traffic validation

Tradeoff:
- requires strong observability and traffic control

## 10. Observability Architecture Layers

A practical observability architecture usually includes:
- metrics
- logs
- traces
- dashboards
- alerts
- deployment correlation

High-level model:

```text
Application
  -> emits logs
  -> emits metrics
  -> emits traces

Infrastructure
  -> emits host or platform metrics

Monitoring Stack
  -> stores, correlates, alerts, visualizes
```

## 11. What Good Post-Deployment Observability Looks Like

After a release, I want to know:
- which version was deployed
- when it was deployed
- whether error rate changed
- whether latency changed
- whether resource usage changed
- whether user-facing traffic broke

This is what closes the gap between "deploy succeeded" and "service is actually healthy."

## 12. Release Correlation Example

Good architecture should make it easy to answer:
- which commit is in production
- which image tag is in production
- which pipeline deployed it
- what changed just before the incident

Example flow:

```text
Commit SHA
  -> Build ID
  -> Artifact Version
  -> Image Tag
  -> Deployment Event
  -> Dashboard Annotation
```

## 13. Example Rollback-Aware Deployment Flow

```text
Build
  -> Test
  -> Package
  -> Publish
  -> Deploy to Staging
  -> Smoke Test
  -> Production Deploy
  -> Health Verification
  -> Auto or Manual Rollback Trigger if unhealthy
```

## 14. Example GitOps Architecture Notes

Good GitOps architecture usually includes:
- separate application code and deployment config responsibility
- clear environment structure
- controller-based reconciliation
- drift visibility
- limited direct manual changes
- environment promotion by reviewed Git changes

## 15. Example Observability Signal Set

For a production service, I usually want:
- request count
- error rate
- latency percentiles
- saturation signals such as CPU or memory
- restart count
- dependency failure trends
- deployment events overlaid on dashboards

## 16. Strong Interview Statements

- "A deployment pipeline is incomplete if it cannot explain what changed, where it went, and how to recover."
- "GitOps improves runtime state control, but CI is still responsible for build quality and artifact integrity."
- "Rollback should be designed before the release, not invented during the incident."
- "Observability is what turns release automation into safe release automation."
