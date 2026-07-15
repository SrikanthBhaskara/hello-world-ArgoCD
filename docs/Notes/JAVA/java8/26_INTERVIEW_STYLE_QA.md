# Interview-Style Q&A

## Q1. What made Java 8 such a significant release?
Java 8 introduced a more expressive programming style through lambdas, streams, Optional, interface enhancements, and modern date/time handling. It reduced boilerplate and improved how developers write transformation-heavy and callback-driven logic.

## Q2. Why are streams useful in real projects?
Streams make collection processing more declarative and often easier to read. They help developers focus on transformation steps instead of manual iteration details.

## Q3. When would you avoid streams?
I avoid them when a simple loop is clearer, when the logic is very stateful, or when side effects dominate the flow.

## Q4. Why is Optional better than returning null directly?
Optional makes absence explicit and encourages safer handling, especially in API return values.

## Q5. Are parallel streams always a good idea?
No. They help only when the workload is suitable. For small tasks or stateful logic, they may reduce clarity and even hurt performance.

## Q6. What is the practical value of default methods?
They help evolve interfaces without breaking old implementations, which is especially useful in libraries and large systems.

## Q7. What is the difference between method references and lambdas?
Method references are a shorthand when an existing method already matches the required lambda shape.

## Q8. What is the biggest mistake developers make with Optional?
The biggest mistake is using Optional everywhere without thinking about clarity. It is most useful in return types, but using it for fields or parameters can make code awkward.

## Q9. Why are default methods useful in library design?
They allow interface behavior to evolve without immediately breaking all implementations, which is very valuable in large or widely used APIs.

## Q10. When is `collect` better than `reduce`?
`collect` is better when the goal is to build structured results like lists, sets, or grouped maps. `reduce` is more suitable when the goal is to combine elements into one final value such as a sum or concatenated result.

## Q11. Why can side effects inside streams be risky?
They reduce clarity, can break declarative style, and become especially dangerous when parallel execution is involved. Streams are easiest to reason about when transformations stay mostly side-effect free.