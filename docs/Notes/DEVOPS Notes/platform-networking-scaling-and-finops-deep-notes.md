# Platform Networking, Scaling, and FinOps Deep Notes

## Why This Topic Matters
- Senior engineers are expected to understand more than application code.
- They should be able to speak about ingress, service-to-service traffic, autoscaling, capacity, and cost.

## NGINX
- common reverse proxy and ingress component
- used for TLS termination, routing, caching, compression, and headers

## Envoy
- modern L7 proxy often used in service mesh and advanced traffic management
- strong observability and policy integration

## Service Mesh
- adds traffic policy, mTLS, retries, and observability between services
- examples: Istio, Linkerd

Interview-safe answer:
- a service mesh is useful when service-to-service security and traffic policy are important, but it adds operational complexity and should not be adopted casually.

## KEDA
- event-driven autoscaling for Kubernetes
- useful for queue depth or custom event metrics

## Karpenter
- dynamic Kubernetes node provisioning
- helps match cluster capacity to workload demand more efficiently

## DNS
- translates names to reachable endpoints
- important for service discovery, failover, and CDN routing

## TLS
- secures traffic in transit
- certificate lifecycle and renewal matter operationally

## HTTP/2 and HTTP/3
- HTTP/2 improves multiplexing and connection efficiency
- HTTP/3 builds on QUIC and can improve behavior on unreliable networks

## FinOps and Cost Optimization
- right-size compute
- remove idle resources
- use storage tiers wisely
- watch data transfer cost
- choose managed services where operational savings justify them

## Interview Questions

### Why use Envoy instead of only NGINX?
Short answer:
Envoy is strong for dynamic service-to-service traffic policy and observability.

Better answer:
NGINX is excellent for many ingress and reverse proxy needs. Envoy becomes attractive when I need richer service-to-service traffic control, mesh integration, dynamic discovery, and deeper telemetry in distributed systems.

### What is FinOps?
Short answer:
Cost-aware engineering and cloud spending discipline.

Better answer:
FinOps is not just cutting bills. It is making architecture, scaling, and platform decisions with both technical and financial accountability so teams understand the cost impact of their design choices.
