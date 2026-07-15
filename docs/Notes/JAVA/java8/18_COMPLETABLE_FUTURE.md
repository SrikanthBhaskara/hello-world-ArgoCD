# CompletableFuture

## What it is
`CompletableFuture` is a Java 8 API for asynchronous programming and future result composition. It allows developers to create non-blocking workflows that can be chained and combined more cleanly than manual thread handling.

## Why it matters
Before Java 8, asynchronous logic with `Future` was more limited and awkward. `CompletableFuture` added composition, callbacks, chaining, and exception handling.

## Basic example
```java
CompletableFuture<String> future = CompletableFuture
    .supplyAsync(() -> "Hello")
    .thenApply(value -> value + " World");
```

## Common methods
- `supplyAsync`
- `runAsync`
- `thenApply`
- `thenAccept`
- `thenCompose`
- `thenCombine`
- `exceptionally`
- `handle`
- `join`

## Important concepts

### `supplyAsync`
Starts async work that returns a value.

### `runAsync`
Starts async work that does not return a value.

### `thenApply`
Transforms one completed result into another value.

### `thenCompose`
Chains another async operation and flattens the result.

### `thenCombine`
Combines the results of two independent futures.

## Example of chaining
```java
CompletableFuture<String> future = CompletableFuture
    .supplyAsync(() -> "Java")
    .thenApply(text -> text + " 8")
    .thenApply(String::toUpperCase);
```

## Example of exception handling
```java
CompletableFuture<String> future = CompletableFuture
    .supplyAsync(() -> {
        if (true) {
            throw new RuntimeException("Failure");
        }
        return "ok";
    })
    .exceptionally(ex -> "fallback");
```

## `join()` vs `get()`
- `join()` throws unchecked exceptions wrapped in `CompletionException`
- `get()` throws checked exceptions

## Common mistakes
- Blocking too early with `join()` or `get()`
- Confusing `thenApply` and `thenCompose`
- Forgetting exception handling
- Building async code without real async benefit

## Interview-style answer
CompletableFuture in Java 8 is used for asynchronous and composable programming. Its practical value is that it allows chained async workflows, combination of dependent tasks, and structured error handling without manual thread coordination. A key interview distinction is that `thenApply` transforms a result, while `thenCompose` is used when the next step itself returns another CompletableFuture.