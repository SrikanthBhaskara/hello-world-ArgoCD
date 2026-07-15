# Frontend Testing Deep Notes

## Why Frontend Testing Matters
- Frontend bugs often appear at interaction boundaries, not just pure functions.
- A mature frontend test strategy covers behavior, integration, and user-facing flows.

## Testing Layers

### Unit Tests
- test small utility functions or isolated component logic
- fast and cheap

### Component Tests
- verify rendered behavior, props, user interaction, and state changes

### Integration Tests
- verify multiple components or UI plus API mocking behavior together

### End-to-End Tests
- verify full application flow in a browser-like environment

## Jest
- common JS and TS test runner
- good for unit and component-level testing
- supports mocks, spies, snapshots, and assertions

## React Testing Library
- encourages testing behavior closer to user experience
- focuses on rendered output and interactions rather than component internals

Good principle:
- test what the user sees and does, not private implementation details

Example:

```ts
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import LoginForm from "./LoginForm";

test("submits valid credentials", async () => {
  render(<LoginForm />);

  await userEvent.type(screen.getByLabelText(/username/i), "demo");
  await userEvent.type(screen.getByLabelText(/password/i), "secret");
  await userEvent.click(screen.getByRole("button", { name: /login/i }));

  expect(screen.getByText(/welcome/i)).toBeInTheDocument();
});
```

## Playwright
- modern browser automation tool
- strong for end-to-end testing across Chromium, Firefox, and WebKit
- good for parallelization and debugging

## Cypress
- strong developer experience for browser testing
- popular for end-to-end and integration-style browser tests
- good interactive debugging model

## Playwright vs Cypress

### Playwright
- broad browser coverage
- strong modern automation feature set
- strong for CI at scale

### Cypress
- great local DX
- easy onboarding for many frontend teams

Interview-safe answer:
- I care more about stable scenario design than brand loyalty. I choose the tool that fits browser coverage, CI behavior, and team familiarity.

## Mocking APIs
- use mocks to isolate frontend behavior
- use contract-aware fixtures where possible
- avoid unrealistic mocks that drift from actual backend behavior

Common options:
- mocked fetch
- MSW
- test doubles in browser or node layer

## What To Test
- rendering logic
- loading states
- error states
- form validation
- conditional UI
- navigation
- accessibility-critical behavior

## What Not To Over-Test
- trivial implementation details
- every internal hook state transition
- snapshots with no meaningful assertions

## Common Anti-Patterns
- brittle selectors
- sleeping with arbitrary timeouts
- mocking everything so the test proves nothing
- relying on CSS classes as the primary assertion target

## Good Practices
- prefer semantic selectors like role or label
- keep fixtures realistic
- make tests deterministic
- separate smoke tests from long regression suites
- run critical paths in CI

## Interview Questions

### React Testing Library vs Enzyme-style thinking?
Short answer:
RTL emphasizes user behavior over component internals.

Better answer:
I prefer React Testing Library because it encourages tests that reflect what the user can actually see and do. That usually creates more resilient tests than tightly coupling assertions to component implementation details.

### When do you use Playwright or Cypress?
Short answer:
For end-to-end flows and browser-level confidence.

Better answer:
I use Playwright or Cypress when I need confidence that routing, API integration, rendering, and browser interaction all work together. They are especially useful for login, checkout, file upload, and other high-value business journeys.
