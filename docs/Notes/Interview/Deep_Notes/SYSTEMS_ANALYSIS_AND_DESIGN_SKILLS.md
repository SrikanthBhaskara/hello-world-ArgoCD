# Systems Analysis and Design Skills

## Why This Area Matters
Systems analysis and design skills show whether you can understand a problem before jumping into implementation. Interviewers want to know if you can break down requirements, identify constraints, model behavior, and design maintainable solutions.

## Systems Analysis in Depth

### What systems analysis means
Systems analysis is understanding what the system must do, what constraints exist, where the risks are, and how changes will affect current behavior.

### Key analysis dimensions
- Functional requirements
- Non-functional requirements
- Existing architecture constraints
- Dependency map
- Data flow
- Failure modes
- Operational expectations

### Functional versus non-functional requirements
Functional requirements describe what the system must do.

Examples:
- Create a route entry.
- Process an uploaded file.
- Return search results.

Non-functional requirements describe how the system must behave.

Examples:
- Respond within 200 ms.
- Remain available during node failure.
- Log all security-sensitive actions.

## Requirement Breakdown

### Important questions to ask
- What problem are we solving?
- Who uses this system?
- What are the inputs and outputs?
- What dependencies exist?
- What failure cases are possible?
- What performance or security constraints matter?
- What must remain backward compatible?

### Why requirement clarity matters
Many bad designs start with incomplete understanding. If the actual requirement is unclear, even a technically elegant implementation can solve the wrong problem.

## System Design in Depth

### What system design means
System design is choosing the structure of the solution. It includes components, data flow, interfaces, scaling strategy, reliability approach, and operational visibility.

### Core design considerations
- Modularity
- Clear interfaces
- Data flow clarity
- Failure handling
- Scalability
- Maintainability
- Observability
- Security boundaries

## How to Analyze a New Requirement
1. Clarify the functional requirement.
2. Identify non-functional requirements.
3. Understand existing system behavior.
4. List assumptions and unknowns.
5. Break the problem into components.
6. Compare possible approaches.
7. Choose the design with best tradeoff for the context.
8. Plan validation and observability.

## Design Decomposition

### Breaking a system into parts
A strong design often separates:
- Request handling
- Business logic
- Data access
- Background processing
- Observability
- Error handling

This separation helps reduce coupling and makes testing easier.

## Interface Design

### What a good interface should provide
- Clear responsibility
- Predictable inputs and outputs
- Stable contract
- Minimal side effects
- Useful error handling

Interfaces are important because many system problems come from unclear boundaries rather than bad core logic.

## Design Tradeoffs Matter
There is rarely one perfect design. Interviewers expect you to compare alternatives.

### Typical tradeoffs
- Simplicity vs flexibility
- Performance vs consistency
- Fast delivery vs long-term maintainability
- Synchronous vs asynchronous processing
- Local optimization vs system-wide clarity
- Tight coupling vs abstraction overhead

## Failure-Oriented Thinking

### Questions strong designers ask
- What happens if the dependency is slow?
- What happens if the database is unavailable?
- What if requests are retried?
- What if data arrives out of order?
- What if the system partially succeeds?

Good design is not only about the happy path.

## Observability as a Design Concern
Logging, metrics, tracing, and alerting should be considered during design, not after incidents begin. If a system fails and nobody can quickly understand why, the design is incomplete.

## How to Speak About Design in Interviews

### Strong answer structure
- Start with requirements.
- Call out constraints.
- Propose a design.
- Explain tradeoffs.
- Mention failure handling and observability.
- Explain why this is the right level of complexity.

### Sample interview answer
When I design a system or a feature, I first clarify the real requirement and the main constraints. Then I break the problem into smaller components, define the data flow and interfaces, and compare a few approaches. I choose the option that is simplest while still meeting reliability, scale, and maintainability needs, and I make sure failure handling and observability are part of the design from the beginning.

## Common Interview Questions

### How do you approach designing a new feature in an existing system
Understand the current architecture first, identify dependencies, minimize unnecessary coupling, and make the change easy to validate and maintain.

### How do you know if a design is too complex
If the design solves hypothetical future problems at the cost of current clarity and delivery, it may be too complex.

### How do you deal with incomplete requirements
Document assumptions, ask clarifying questions early, and design in a way that keeps future changes manageable.

### How do you balance speed and design quality
I try to choose the simplest design that safely meets current needs without creating obvious long-term pain. The goal is not perfect abstraction, but practical sustainability.

## Quick Revision Checklist
- Can I explain how I break down requirements?
- Can I distinguish functional from non-functional requirements?
- Can I describe tradeoffs in a balanced way?
- Can I explain why interfaces matter in design?
- Can I give an example where I chose a simpler design intentionally?
- Can I explain how I factor in scale, failure, and maintenance?

## Interview Style Q&A

### Q1. What is the difference between systems analysis and system design?
Systems analysis is about understanding the problem, requirements, constraints, and current behavior. System design is about choosing the structure of the solution after that analysis is done.

### Q2. How do you start designing a feature in an existing system?
I first understand the current architecture and where the feature fits. Then I identify dependencies, inputs, outputs, failure risks, and what should remain stable. Only after that do I propose component or interface changes.

### Q3. How do you avoid making a design too complex?
I compare the proposed complexity against current requirements and likely near-term needs. If the design is solving hypothetical future problems more than current real ones, it is probably too complex.

### Q4. What tradeoffs do you usually think about in design discussions?
I usually think about simplicity versus flexibility, delivery speed versus maintainability, consistency versus performance, and synchronous versus asynchronous behavior.

### Q5. Why is observability part of design and not only operations?
Because if a system cannot be understood when it fails, the design is incomplete. Logging, metrics, and tracing help teams operate and debug the design safely in production.