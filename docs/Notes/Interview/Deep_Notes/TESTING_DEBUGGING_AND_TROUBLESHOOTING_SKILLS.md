# Testing, Debugging, and Troubleshooting Skills

## Why This Area Matters
Interviewers use this topic to check whether you can work in real systems where problems are unclear, failures are partial, and fixes must be safe. Strong engineers do not just write code. They detect issues, isolate causes, validate fixes, and prevent repeat failures.

## Testing in Depth

### What good testing means
Good testing is not only unit testing. It means choosing the right validation level for the type of change, the risk of the area, and the kind of failure you want to catch.

### Unit testing
Unit tests validate a small piece of logic in isolation. They are useful for calculations, parsing, state transitions, validation logic, and utility behavior.

Strength:
Fast and focused.

Limitation:
They do not prove that multiple components work correctly together.

### Integration testing
Integration tests verify that modules interact correctly. They help catch interface mismatches, dependency issues, and incorrect assumptions between components.

### API testing
API tests validate request and response format, status codes, error handling, and backward compatibility. They are important when changes affect clients or service contracts.

### Regression testing
Regression testing ensures a fix does not reopen older failures or break working behavior. This matters most in mature codebases where one change can affect neighboring flows.

### Manual and scenario-based testing
Not all important behavior is easy to capture with automated tests. Environment-dependent paths, operational workflows, and platform-specific behavior often need targeted scenario validation.

### Production-like validation
For high-risk fixes, the best validation may be running the change in an environment that resembles production behavior closely enough to expose integration risks.

## Debugging in Depth

### What debugging really is
Debugging is the process of turning an unclear symptom into a clear explanation. Good debugging is not random trial and error. It is structured reasoning guided by evidence.

### A strong debugging process
1. Clarify the failure in precise terms.
2. Identify expected behavior and actual behavior.
3. Narrow the scope of possible causes.
4. Check logs, inputs, dependencies, recent changes, and environment differences.
5. Build a hypothesis.
6. Validate the hypothesis.
7. Fix the root cause.
8. Re-check that the full explanation now makes sense.

### Symptom versus root cause
If a service times out, the timeout is often only the symptom. The root cause may be a slow dependency, bad retry logic, lock contention, or malformed data causing expensive processing.

### Common debugging tools and signals
- Logs
- Stack traces
- Metrics
- Alerts
- Request tracing
- Config comparison
- Reproduction steps
- Diff of recent changes

## Troubleshooting in Production Systems

### Why production troubleshooting is harder
Production issues may be intermittent, distributed, configuration-sensitive, or data-dependent. You often cannot attach a debugger or reproduce the issue immediately.

### Practical production troubleshooting flow
1. Understand impact.
2. Check whether the issue is ongoing or historical.
3. Compare healthy and failing requests or systems.
4. Look for recent changes in code, config, traffic, or dependencies.
5. Determine whether the problem is code, infra, data, or external dependency.
6. Stabilize first if needed.
7. Then fix the root cause.

### Stabilize versus solve
Sometimes the correct first move is to reduce impact, for example by rolling back, disabling a risky path, or throttling load. That is not the same as solving the problem, but it can protect users while investigation continues.

## Root Cause Analysis

### What a good RCA includes
- What happened
- What users or systems were affected
- Why the failure occurred
- Why it was not detected sooner
- How it was fixed
- What should prevent recurrence

### What weak RCA looks like
- It only restates the symptom.
- It does not explain why the system reached the bad state.
- It ignores detection gaps.

## How to Speak About This in Interviews

### Strong answer structure
- Explain how you narrow a problem.
- Mention logs, evidence, and validation.
- Show that you protect production safety.
- Describe how you confirm the fix.

### Sample interview answer
When I debug an issue, I first make the problem precise by defining the failing path and expected behavior. Then I gather evidence from logs, recent changes, inputs, and environment differences to narrow the likely cause. Once I can explain why the failure is happening, I make a targeted fix and validate both the direct issue and nearby flows to avoid regression.

## Common Interview Questions

### How do you debug an issue you cannot reproduce locally
Use logs, configuration comparison, production behavior analysis, and healthy-versus-failing path comparison. Try to identify the exact condition that triggers failure even if you cannot reproduce the full environment immediately.

### How do you avoid fixing only the symptom
Trace the logic far enough to explain why the system reached the bad state. If you cannot explain the full path, you probably have not reached the true cause yet.

### How do you validate a risky fix
Validate the direct issue, adjacent behavior, rollback possibility, environment-sensitive cases, and whether monitoring will catch recurrence.

### How do you decide whether to roll back or patch forward
Compare user impact, time to safe recovery, confidence in the diagnosis, and whether the rollback itself is lower risk than the forward fix.

## Real Skills Interviewers Want to See
- Calmness under uncertainty
- Evidence-based reasoning
- Ability to use logs and system signals
- Understanding of regression risk
- Balanced decision making under production pressure

## Quick Revision Checklist
- Can I explain unit, integration, API, and regression testing clearly?
- Can I describe my debugging process step by step?
- Can I explain the difference between stabilization and root-cause fixing?
- Can I give one real example of a production issue I handled?
- Can I explain how I validated the final fix?

## Interview Style Q&A

### Q1. How do you choose between unit testing and integration testing?
I choose based on the risk and the kind of failure I want to catch. Unit tests are best for isolated logic. Integration tests are better when the risk comes from interaction between modules, services, or data layers.

### Q2. What is your first step when debugging a complex issue?
My first step is to define the failure clearly. I want to know what is failing, what is expected, who is affected, and whether the issue is reproducible or environment-specific. That prevents random debugging.

### Q3. How do you handle a production issue when time pressure is high?
I focus on impact first, then on stabilization if needed. After that, I narrow the root cause using logs, system signals, and recent changes. I avoid rushing into a speculative code fix because that can make the incident worse.

### Q4. How do you know a bug is fully fixed?
I know the fix is strong when I can explain the root cause clearly, reproduce or reason about the failing path, validate the direct issue, and confirm nearby flows did not break.

### Q5. What is the difference between troubleshooting and debugging?
Troubleshooting is broader and often operational. It includes scoping impact, identifying whether the issue is code, config, infra, or dependency related, and stabilizing the system. Debugging is the deeper process of finding the exact technical cause.