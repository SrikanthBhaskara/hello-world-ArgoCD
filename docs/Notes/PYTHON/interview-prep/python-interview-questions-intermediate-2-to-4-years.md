# Python Interview Questions: Intermediate 2 to 4 Years

## 1. How does Python manage memory?

### Short Answer

CPython uses reference counting and cyclic garbage collection.

### Better Answer

Most objects are cleaned up when their reference count becomes zero. Cyclic garbage collection helps remove objects involved in reference cycles. I still watch for lingering references in caches, globals, and long-lived containers.

## 2. What is the GIL?

### Short Answer

The Global Interpreter Lock allows only one thread to execute Python bytecode at a time in CPython.

### Better Answer

The GIL limits CPU-bound multithreaded execution in CPython, but threads are still useful for I/O-bound workloads. For CPU-heavy tasks I usually consider multiprocessing.

## 3. When would you use threading, multiprocessing, or asyncio?

### Short Answer

Threading for I/O-bound work, multiprocessing for CPU-bound work, and asyncio for high-concurrency async I/O.

### Better Answer

I choose based on the bottleneck. If tasks wait on network or disk I use threads or asyncio. If tasks spend time doing computation, multiprocessing is usually better because it bypasses the GIL.

## 4. What is a generator and why is it useful?

### Short Answer

A generator yields values lazily instead of storing everything in memory.

### Better Answer

Generators are great for streaming, pipelines, and large datasets because they improve memory efficiency and let me process values one at a time.

## 5. What is a decorator?

### Short Answer

A decorator adds behavior to a function without changing its core implementation.

### Better Answer

Decorators are useful for cross-cutting concerns like logging, retries, metrics, authentication, and caching. They help keep business logic clean.

## 6. What is a closure?

### Short Answer

A closure is an inner function that remembers variables from its outer scope.

### Better Answer

Closures are useful when I want lightweight stateful behavior without creating a full class, especially in decorators and factory functions.

## 7. What are dunder methods?

### Short Answer

They are special methods like `__init__`, `__str__`, and `__len__` that define built-in behavior.

### Better Answer

Dunder methods let custom objects behave naturally with Python syntax and built-ins. For example, `__repr__` improves debugging and `__eq__` customizes equality logic.

## 8. What is the difference between `@staticmethod` and `@classmethod`?

### Short Answer

Static methods do not receive class or instance. Class methods receive the class as `cls`.

### Better Answer

I use `@staticmethod` for utility logic related to the class domain but not needing object state. I use `@classmethod` for alternate constructors or class-level behavior.

## 9. What is monkey patching?

### Short Answer

Monkey patching means changing classes or functions at runtime.

### Better Answer

It can be useful in tests or controlled extension points, but in production code it can reduce predictability and make debugging harder, so I use it cautiously.

## 10. How do you optimize Python code?

### Short Answer

Measure first, then optimize data structures, algorithms, and hot paths.

### Better Answer

I start with profiling, then improve the algorithm or data structure before micro-optimizing. In many cases switching from list lookup to set or dict lookup gives a much bigger improvement than syntax-level tuning.

## 11. What are type hints and why do they matter?

### Short Answer

Type hints improve readability and static checking.

### Better Answer

They help teammates, IDEs, and tools like `mypy`, especially in larger codebases. They do not change Python into a statically typed runtime language, but they reduce ambiguity and catch mistakes earlier.

## 12. How would you structure a Python project?

### Short Answer

I separate business logic, API layer, configuration, tests, and utilities into clear modules.

### Better Answer

I prefer a layout that keeps core domain logic independent from framework details. That improves testability, maintainability, and makes refactoring easier as the project grows.

## 13. What is the difference between `__str__` and `__repr__`?

### Short Answer

`__str__` is user-friendly, `__repr__` is developer-oriented.

### Better Answer

I use `__str__` for readable display and `__repr__` for debugging and logs. A good `__repr__` should ideally help reconstruct the object or at least show enough detail to identify it.

## 14. What is a context manager?

### Short Answer

A context manager handles setup and cleanup around a block of code.

### Better Answer

It makes resource handling safer and clearer. I use context managers for files, locks, transactions, and temporary resources so cleanup happens even if exceptions occur.

## 15. What is a dataclass and when would you use it?

### Short Answer

A dataclass reduces boilerplate for data-centric classes.

### Better Answer

I use dataclasses when the main purpose of the class is storing structured data with predictable fields. They keep the model clean and reduce repetitive code for constructors and representation.
