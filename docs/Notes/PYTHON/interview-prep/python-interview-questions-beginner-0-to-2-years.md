# Python Interview Questions: Beginner 0 to 2 Years

## 1. What is Python and why is it popular?

### Short Answer

Python is a high-level, readable programming language used for scripting, backend development, automation, data work, and testing.

### Better Answer

Python is popular because it has simple syntax, a rich standard library, strong community support, and good productivity for both small scripts and large applications.

## 2. What is the difference between list and tuple?

### Short Answer

List is mutable. Tuple is immutable.

### Better Answer

I use a list when values need to change, and a tuple when the data should stay fixed. Tuples can also be safer for read-only data and can be used as dictionary keys if all elements are hashable.

## 3. What is the difference between `==` and `is`?

### Short Answer

`==` checks value equality. `is` checks whether both references point to the same object.

### Better Answer

I use `==` when comparing values and `is` when checking object identity, especially for `None`, like `if value is None`.

## 4. What are lists, sets, and dictionaries used for?

### Short Answer

Lists store ordered items, sets store unique items, and dictionaries store key-value pairs.

### Better Answer

I choose them based on access pattern. A list is good for ordered traversal, a set is useful for fast membership checks, and a dictionary is best when I need lookup by key.

## 5. What is a dictionary?

### Short Answer

A dictionary stores key-value pairs.

### Better Answer

A dictionary maps keys to values and is one of the most important Python data structures. It is commonly used for counting, indexing, configuration, caching, and JSON-like data handling.

## 6. What is a function in Python?

### Short Answer

A function is a reusable block of code defined using `def`.

### Better Answer

A function helps organize logic, improve reuse, and make code easier to test. Python functions also support default arguments, keyword arguments, `*args`, and `**kwargs`.

## 7. What are `*args` and `**kwargs`?

### Short Answer

`*args` collects positional arguments and `**kwargs` collects keyword arguments.

### Better Answer

I use `*args` when the number of positional arguments can vary and `**kwargs` when the named options can vary. They are useful in wrappers, utility APIs, and decorators.

## 8. What is a list comprehension?

### Short Answer

A list comprehension is a concise way to build a list.

### Better Answer

It is a compact syntax for transforming or filtering data, for example `[x * x for x in range(5)]`. I use it when it improves readability, but I avoid overly complex nested comprehensions.

## 9. How do you handle exceptions in Python?

### Short Answer

Using `try`, `except`, `finally`, and sometimes `else`.

### Better Answer

I catch only specific exceptions when possible, handle them close to the right boundary, and avoid swallowing errors silently because that makes debugging harder.

## 10. What is the `with` statement used for?

### Short Answer

It is used for resource management.

### Better Answer

`with` ensures setup and cleanup happen correctly. It is commonly used for files, database connections, locks, and custom context managers.

## 11. What is the difference between shallow copy and deep copy?

### Short Answer

Shallow copy copies the outer object, deep copy copies nested objects too.

### Better Answer

This matters when nested mutable objects exist. A shallow copy can still share inner lists or dictionaries, which may lead to unexpected side effects.

## 12. What is a module?

### Short Answer

A module is a Python file containing reusable code.

### Better Answer

Modules help organize code into logical units. Multiple modules can be grouped into packages for larger applications.

## 13. What is a virtual environment?

### Short Answer

A virtual environment isolates Python dependencies for a project.

### Better Answer

I use a virtual environment to avoid dependency conflicts between projects and to make local development more predictable.

## 14. What is the difference between mutable and immutable objects?

### Short Answer

Mutable objects can change after creation, immutable objects cannot.

### Better Answer

This affects function behavior, copying, hashing, and bugs like mutable default arguments. Lists and dictionaries are mutable, while strings and tuples are immutable.

## 15. Why should mutable default arguments be avoided?

### Short Answer

Because the same object can be reused across function calls.

### Better Answer

Default argument values are evaluated once at function definition time, so a mutable default like `[]` can keep old state across calls. I use `None` and initialize inside the function instead.
