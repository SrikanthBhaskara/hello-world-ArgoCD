# Serverless and Edge Functions Deep Notes: AWS Lambda and Vercel Edge

## What Serverless Means
- You write application logic without managing traditional always-on servers directly.
- The platform handles infrastructure provisioning, scaling, and much of the runtime management.
- You still own code, security, latency, cost, and failure handling.

## What Edge Functions Mean
- Edge functions run closer to the user at distributed edge locations.
- They are useful for low-latency personalization, request rewriting, lightweight auth checks, and geo-aware behavior.

## AWS Lambda

### What It Is
- AWS Lambda runs event-driven code on demand.
- Common triggers:
  - API Gateway
  - SQS
  - EventBridge
  - S3
  - DynamoDB streams

### Strengths
- auto-scaling
- pay per use
- strong AWS integration
- good fit for event-driven architectures

### Concerns
- cold starts
- timeout limits
- package size
- observability complexity if many functions exist

## Vercel Edge Functions

### What They Are
- Lightweight functions executed near users on the edge network.
- Often used for:
  - authentication checks
  - redirects
  - personalization
  - geo-based routing
  - header manipulation

### Best Fit
- small, latency-sensitive logic
- content shaping close to the user

### Not Best Fit
- heavy CPU workloads
- long-running jobs
- complex stateful workflows

## Lambda vs Edge

### Lambda
- broader integration ecosystem
- stronger for backend event processing
- can support heavier business workflows

### Edge Functions
- better for ultra-low-latency request handling near users
- smaller runtime surface
- better for lightweight request-time logic

## Cost Thinking
- serverless can be cost-efficient at variable or bursty traffic
- always-on services may be cheaper at steady high volume
- bad design can make serverless expensive through chatty calls or repeated cold-start-heavy workflows

## Common Patterns
- API endpoint
- async job processor
- image transformation
- webhook receiver
- authentication middleware
- edge redirect and geolocation routing

## Example Lambda Handler

```js
export const handler = async (event) => {
  return {
    statusCode: 200,
    body: JSON.stringify({
      message: "Hello from Lambda"
    })
  };
};
```

## Example Edge Middleware Idea

```ts
export default function middleware(request: Request) {
  const country = request.headers.get("x-country") || "unknown";

  if (country === "IN") {
    return new Response("Regional content");
  }

  return new Response("Default content");
}
```

## Operational Concerns
- keep functions small and focused
- monitor invocation errors and latency
- manage secrets safely
- minimize startup cost
- avoid hidden dependency bloat

## When to Use Serverless
- bursty traffic
- event-driven workflows
- lightweight APIs
- background processing
- proof-of-concept or fast delivery needs

## When Not to Use It
- long-running compute-heavy workloads
- extremely latency-sensitive logic with bad cold-start tolerance
- systems needing complex in-memory state

## Interview Questions

### Why choose Lambda?
Short answer:
For event-driven, autoscaling, pay-per-use backend logic.

Better answer:
I choose Lambda when the workload is event-driven, bursty, or operational simplicity matters more than fine-grained infrastructure control. It is especially strong when integrated with AWS triggers like API Gateway, SQS, or EventBridge and when the workload can tolerate the serverless execution model.

### When would you choose edge functions?
Short answer:
For lightweight, latency-sensitive logic close to the user.

Better answer:
I use edge functions when I need fast request-time decisions such as redirects, auth prechecks, localization, or personalization near the user. I avoid pushing heavy business workflows there because edge runtimes are better suited for short, lightweight execution.
