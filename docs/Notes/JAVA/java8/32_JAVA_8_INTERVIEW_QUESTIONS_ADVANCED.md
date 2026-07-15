# Java 8 Interview Questions Advanced Level

## Advanced Questions

### 1. How do lambdas differ from anonymous inner classes beyond syntax?

Solved answer:
Beyond syntax, lambdas differ in scoping behavior. Inside a lambda, `this` refers to the enclosing class instance, while in an anonymous inner class `this` refers to the anonymous object itself. Lambdas also require a functional interface target and are generally lighter and clearer for behavior-passing.

### 2. Why must captured local variables be effectively final in lambdas?

Solved answer:
Captured local variables must be effectively final because lambdas may outlive the method stack frame where those variables were defined. Restricting mutation avoids confusing state behavior and makes variable capture safer and more predictable.

### 3. Why can parallel streams sometimes reduce performance?

Solved answer:
Parallel streams can reduce performance when the dataset is small, the work per element is light, ordering is important, or splitting and combining overhead is high. They are not automatically faster just because multiple threads are used.

### 4. What makes `reduce` safe or unsafe for parallel execution?

Solved answer:
For parallel execution, the reduce operation should use an associative accumulator and a correct identity value. If the combining logic depends on ordering or mutable shared state, the result may become incorrect or unpredictable.

### 5. What are the risks of side effects inside stream operations?

Solved answer:
Side effects inside streams reduce clarity and can introduce bugs, especially with parallel streams. They make reasoning about execution harder and can lead to race conditions or incorrect results when shared mutable state is involved.

### 6. When would you avoid Optional even though it is available?

Solved answer:
I avoid Optional as a field or parameter when it makes the model awkward and adds little value. It is most useful in return types where absence is meaningful and needs to be handled explicitly.

### 7. How do you resolve default method conflicts across multiple interfaces?

Solved answer:
Java resolves default method conflicts with clear rules: class methods win over interface defaults, more specific interfaces win over parent interfaces, and if ambiguity still remains, the implementing class must override the method explicitly.

### 8. What is the difference between `thenApply` and `thenCompose`?

Solved answer:
`thenApply` transforms a completed result into another value. `thenCompose` is used when the next step returns another CompletableFuture and I want to flatten the async chain instead of producing nested futures.

### 9. What are common mistakes when using CompletableFuture?

Solved answer:
Common mistakes include blocking too early with `join()` or `get()`, forgetting exception handling, confusing `thenApply` with `thenCompose`, and building async code where synchronous code would be simpler and clearer.

### 10. When is a loop better than a stream?

Solved answer:
A loop is better when the logic is highly stateful, contains complex branching, or becomes harder to understand as a stream pipeline. Streams are good for clear transformations, but loops are sometimes the simpler engineering choice.

## What interviewers test here
- Deeper reasoning
- Design awareness
- Performance understanding
- Knowledge of misuse and edge cases