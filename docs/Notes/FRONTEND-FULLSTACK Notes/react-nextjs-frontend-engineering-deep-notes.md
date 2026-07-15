# React and Next.js Frontend Engineering Deep Notes

## Why This Topic Matters
- For full-stack and frontend interviews, React is often the default UI framework discussion.
- Next.js adds production concerns such as routing, rendering strategy, and deployment behavior.
- At senior level, interviewers want more than hook syntax. They want component design, data flow, performance, and rendering tradeoffs.

## React Mental Model
- UI is a function of state.
- Components receive props and manage local state.
- Rendering is declarative, not imperative DOM manipulation.
- State changes trigger re-rendering.

## Component Design

### Good Components
- have one clear responsibility
- keep props explicit
- isolate side effects
- avoid mixing data fetching, presentation, and business logic in one giant file

### Common Anti-Patterns
- prop drilling everywhere without thinking about state ownership
- giant stateful components
- excessive global state
- side effects inside render logic

## State Management

### Local State
- use when state belongs to one component or a small subtree
- examples:
  - input value
  - modal open or closed
  - selected tab

### Shared State
- use when many components need the same data or behavior
- options:
  - context
  - reducer pattern
  - external state libraries such as Zustand or Redux

Interview-safe answer:
- I start with local state, move to context for modest shared concerns, and use a dedicated state library only when the complexity justifies it.

## React Hooks

### `useState`
- simple local state

### `useEffect`
- run side effects such as API calls, subscriptions, cleanup

### `useRef`
- store mutable value without re-render
- useful for DOM references or instance-like values

### `useReducer`
- better for state transitions that have multiple event types

### `useDeferredValue` and `startTransition`
- useful for keeping UI responsive under heavy updates
- good for search results, filtering, or non-urgent UI updates

## Side Effects
- fetch data
- attach listeners
- subscribe to sockets
- timers and cleanup

Common trap:
- using `useEffect` to derive simple values that should have been computed during render

## Component Lifecycle Thinking
- mount
- update
- unmount

Functional components express lifecycle through hooks rather than class lifecycle methods.

Interview point:
- I think in terms of render and side-effect phases, not only "componentDidMount replacement."

## Forms
- controlled components give explicit state control
- uncontrolled components can be simpler for very small forms
- use schema validation where possible
- keep form state and server-side validation errors separate

## Routing

### React Router
- common for SPAs
- client-side route transitions

### Next.js Routing
- file-based routing
- route segments
- layouts
- API routes or route handlers depending on app structure

## Next.js Rendering Models

### CSR
- client-side rendering
- browser fetches and renders most of the UI after bundle loads

### SSR
- server renders HTML per request
- better for dynamic SEO-sensitive or personalized pages

### SSG
- static HTML generated at build time
- great for content that changes infrequently

### ISR
- incremental static regeneration
- blends static performance with periodic content freshness

## SSR vs CSR vs SSG

### CSR
- simpler SPA feeling
- slower first content for some routes
- weaker SEO by default

### SSR
- stronger initial render and SEO
- more server cost and request-time work

### SSG
- best performance for stable content
- not suitable for highly dynamic user-specific pages

Interview-safe answer:
- I choose based on content freshness, SEO requirements, personalization, and infrastructure cost rather than treating one rendering mode as universally best.

## Data Fetching Strategy
- fetch on server when SEO or fast first paint matters
- fetch on client when personalization or interactivity dominates
- cache carefully
- separate loading states, error states, and empty states clearly

## Performance Topics
- memoization only where needed
- list virtualization for large lists
- route-level code splitting
- image optimization
- avoid unnecessary re-renders
- watch bundle size

## Accessibility
- semantic HTML
- keyboard navigation
- ARIA only when needed
- focus management in modals and dialogs

## Interview Questions

### Why React?
Short answer:
It provides component-based UI with predictable state-driven rendering.

Better answer:
React works well because it breaks complex interfaces into reusable components and gives a consistent model where UI updates follow state changes. In larger applications, that makes behavior easier to reason about than direct DOM manipulation.

### When would you choose SSR over CSR?
Short answer:
When SEO or fast first-page render matters more.

Better answer:
I prefer SSR when the first paint, crawlability, or request-time personalization matters. I prefer CSR when the app behaves more like an authenticated dashboard where interactivity dominates and SEO is less important.

### How do you avoid overengineering frontend state?
Short answer:
Keep state as local as possible and promote it only when needed.

Better answer:
I start by asking who owns the data and who consumes it. Many state problems come from moving everything global too early. I keep state local until multiple independent parts of the app genuinely need coordinated access.
