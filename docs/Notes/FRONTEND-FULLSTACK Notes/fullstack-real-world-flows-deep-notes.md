# Full-Stack Real-World Flows Deep Notes

## Why This Topic Matters
- Interviews often move from theory to "how would you build this in production?"
- Real systems involve uploads, notifications, feature flags, auditability, and cross-region considerations.

## File Upload Architecture

### Typical Flow
1. client requests upload permission
2. backend returns pre-signed URL or upload session
3. client uploads file to object storage
4. backend stores metadata and processing state

### Why This Is Better
- avoids routing large file traffic through app server
- improves scalability
- simplifies retry behavior

## Resumable Uploads
- useful for large files and unstable networks
- split file into chunks
- track upload progress by session id
- support retry of failed chunks

## File Download Security
- validate authorization before generating access
- avoid exposing raw internal storage paths
- consider time-limited download URLs

## Notifications

### Patterns
- email
- SMS
- push notifications
- in-app notifications

### Good Design
- decouple notification creation from user request path
- use queue or event-driven model
- track delivery status

## Audit Logging
- record important actions such as:
  - login
  - role changes
  - payment actions
  - data exports
- include actor, action, target, timestamp, and request correlation id

## Feature Flags
- release incomplete code safely
- enable canary rollout
- disable risky feature quickly without redeploy

Risks:
- stale flags
- flag explosion
- inconsistent evaluation across services

## Multi-Region Thinking
- active-passive or active-active
- replicate data carefully
- think about latency, consistency, failover, and cost

Interview-safe answer:
- I would not jump to multi-region by default. I would justify it based on availability, latency, and business impact.

## Real Interview Question

### How would you design a large file upload system?
Short answer:
Use direct object storage upload with pre-signed URLs and asynchronous post-processing.

Better answer:
I would keep the app server out of the heavy data path by issuing pre-signed upload URLs, store metadata in the backend, support chunked or resumable upload for reliability, and trigger asynchronous scanning or processing after the upload completes.
