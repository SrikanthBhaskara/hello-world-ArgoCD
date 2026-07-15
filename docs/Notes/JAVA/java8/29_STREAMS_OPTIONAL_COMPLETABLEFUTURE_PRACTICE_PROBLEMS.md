# Streams, Optional, and CompletableFuture Practice Problems

This file contains practice problems focused on the three Java 8 areas that interviewers ask most frequently.

## Part 1: Streams Practice Problems

### Problem 1: Filter and uppercase
Given a list of names, return all names that start with `A` in uppercase.

What to practice:
- `filter`
- `map`
- `collect`

### Problem 2: Count employees by department
Given a list of employees, group them by department and count how many employees each department has.

What to practice:
- `groupingBy`
- `counting`

### Problem 3: Flatten nested tags
Given a list of blog posts, each with a list of tags, return a single list of unique tags.

What to practice:
- `flatMap`
- `distinct`
- `collect`

### Problem 4: Find the longest word
Given a list of words, return the longest one using streams.

What to practice:
- `max`
- `Comparator`

### Problem 5: Sum even numbers
Given a list of integers, return the sum of only even values.

What to practice:
- `filter`
- `reduce`

## Part 2: Optional Practice Problems

### Problem 6: Safe username extraction
Given a `User` object that may be null, return the username if present, otherwise return `guest`.

What to practice:
- `ofNullable`
- `map`
- `orElse`

### Problem 7: Nested optional lookup
Given `User -> Address -> City`, return city name safely without nested null checks.

What to practice:
- chained `map`
- `orElse`

### Problem 8: Lazy fallback
Create a method where a fallback value is expensive to compute, and use `orElseGet` instead of `orElse`.

What to practice:
- `orElseGet`
- lazy evaluation understanding

### Problem 9: Filter with Optional
Return a valid email only if it is present and contains `@`, otherwise return empty Optional.

What to practice:
- `filter`
- `Optional<String>` return patterns

## Part 3: CompletableFuture Practice Problems

### Problem 10: Async user fetch
Simulate asynchronous retrieval of a user name and print the uppercase result.

What to practice:
- `supplyAsync`
- `thenApply`

### Problem 11: Dependent async tasks
Fetch an order ID asynchronously and then fetch order details based on that ID.

What to practice:
- `thenCompose`

### Problem 12: Combine two async calls
Fetch user profile and user account balance asynchronously, then combine both into one result string.

What to practice:
- `thenCombine`

### Problem 13: Async fallback on failure
Create a future that throws an exception and recover using `exceptionally`.

What to practice:
- exception handling
- fallback strategy

### Problem 14: Fire-and-forget background task
Run a background logging or audit simulation that does not return a value.

What to practice:
- `runAsync`

## Practice Strategy
- Solve first using plain Java style.
- Then rewrite using Java 8 style.
- Explain what improved and what became more readable.
- For CompletableFuture, explain how the pipeline executes.