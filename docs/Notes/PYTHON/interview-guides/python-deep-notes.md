# Python Deep Notes

## 1. Python Execution Model

Python is an interpreted high-level language, but in normal CPython execution the source is first compiled to bytecode and then executed by the Python virtual machine.

Important interview points:
- Python source is not directly executed line by line as plain text
- `.pyc` files may be generated for cached bytecode
- CPython is the most common implementation
- other implementations include PyPy, Jython, and IronPython

## 2. Dynamic Typing and Strong Typing

Python is dynamically typed because variable types are resolved at runtime. It is strongly typed because it does not silently coerce unrelated types in many operations.

Example:

```python
x = 10
x = "hello"
```

The variable can point to different object types over time.

## 3. Mutability vs Immutability

Immutable objects:
- `int`
- `float`
- `bool`
- `str`
- `tuple`

Mutable objects:
- `list`
- `dict`
- `set`

Interview importance:
- mutable defaults can cause bugs
- immutable objects are safer for keys and shared state

Bad example:

```python
def add_item(item, bucket=[]):
    bucket.append(item)
    return bucket
```

Better example:

```python
def add_item(item, bucket=None):
    if bucket is None:
        bucket = []
    bucket.append(item)
    return bucket
```

## 4. List vs Tuple vs Set vs Dict

`list`
- ordered
- mutable
- allows duplicates

`tuple`
- ordered
- immutable
- can be used as dictionary key if its members are hashable

`set`
- unordered unique elements
- useful for membership tests

`dict`
- key-value mapping
- insertion order preserved in modern Python

## 5. Identity vs Equality

`==` checks value equality.

`is` checks object identity.

Example:

```python
a = [1, 2]
b = [1, 2]

a == b   # True
a is b   # False
```

Use `is None` instead of `== None`.

## 6. Shallow Copy vs Deep Copy

Shallow copy copies the outer container but reuses nested references.

Deep copy recursively copies nested objects.

```python
import copy

original = [[1, 2], [3, 4]]
shallow = copy.copy(original)
deep = copy.deepcopy(original)
```

## 7. Iterators and Generators

An iterator implements `__iter__()` and `__next__()`.

A generator is a simpler way to create iterators using `yield`.

```python
def squares(n):
    for i in range(n):
        yield i * i
```

Benefits:
- memory efficient
- lazy evaluation
- useful for large streams and pipelines

## 8. Decorators

A decorator wraps a function and adds behavior without changing the original business logic.

```python
def log_calls(func):
    def wrapper(*args, **kwargs):
        print(f"calling {func.__name__}")
        return func(*args, **kwargs)
    return wrapper

@log_calls
def greet(name):
    return f"Hello {name}"
```

Common uses:
- logging
- timing
- authorization
- retries
- caching

## 9. Closures

A closure is an inner function that remembers variables from the outer scope even after the outer function has returned.

```python
def multiplier(factor):
    def inner(value):
        return value * factor
    return inner
```

## 10. Context Managers

A context manager manages setup and cleanup using `with`.

```python
with open("data.txt", "r") as file:
    content = file.read()
```

Custom context managers can be created with:
- `__enter__` and `__exit__`
- `contextlib.contextmanager`

## 11. `*args` and `**kwargs`

`*args` collects extra positional arguments.

`**kwargs` collects extra named arguments.

```python
def demo(*args, **kwargs):
    return args, kwargs
```

Interview explanation:
- use `*args` when count of positional parameters varies
- use `**kwargs` when optional named parameters vary

## 12. Comprehensions

Comprehensions are concise ways to build collections.

```python
squares = [x * x for x in range(5)]
even_set = {x for x in range(10) if x % 2 == 0}
index_map = {x: x * x for x in range(5)}
```

Good interview note:
- use them when readable
- avoid deeply nested comprehensions that hurt clarity

## 13. Exception Handling

Use exceptions for exceptional situations, not normal control flow.

```python
try:
    value = int("10")
except ValueError:
    value = 0
finally:
    print("done")
```

Best practice:
- catch specific exceptions
- preserve context
- avoid broad `except Exception` unless boundary handling is intended

## 14. GIL

The Global Interpreter Lock in CPython allows only one thread to execute Python bytecode at a time.

Important clarification:
- GIL does not mean threading is useless
- threads still help in I/O-bound workloads
- CPU-bound workloads often benefit more from multiprocessing

Interview answer:
- use threading for network calls, waiting, I/O
- use multiprocessing for CPU-heavy parallel work

## 15. Threading vs Multiprocessing vs Asyncio

Threading:
- good for I/O-bound work
- simpler shared-memory model
- limited by GIL for CPU-bound tasks

Multiprocessing:
- good for CPU-bound work
- separate processes avoid the GIL
- higher memory overhead

Asyncio:
- single-threaded cooperative concurrency
- strong for high-volume I/O tasks such as API calls and sockets

## 16. Memory Management and Garbage Collection

CPython primarily uses reference counting and also has cyclic garbage collection.

Interview points:
- objects are destroyed when reference count reaches zero
- cyclic references may require garbage collector support
- memory leaks can still happen through lingering references, caches, globals, or open resources

## 17. OOP in Python

Key ideas:
- everything is object-based
- classes support inheritance and polymorphism
- Python supports multiple inheritance
- composition is often cleaner than deep inheritance

Method types:
- instance methods use `self`
- class methods use `cls`
- static methods do not need instance or class state

## 18. Dunder Methods

Dunder methods customize built-in behavior.

Examples:
- `__init__`
- `__str__`
- `__repr__`
- `__len__`
- `__iter__`
- `__eq__`

Example:

```python
class User:
    def __init__(self, name):
        self.name = name

    def __repr__(self):
        return f"User(name={self.name!r})"
```

## 19. Dataclasses

`dataclass` reduces boilerplate for data-holding classes.

```python
from dataclasses import dataclass

@dataclass
class Employee:
    id: int
    name: str
```

Benefits:
- auto-generated `__init__`
- readable models
- less boilerplate

## 20. Typing Hints

Type hints improve readability, tooling, and maintainability.

```python
from typing import List, Dict

def total(values: List[int]) -> int:
    return sum(values)
```

Important interview angle:
- Python remains dynamically typed
- type hints help static analysis but are not runtime enforcement by default

## 21. Common Performance Notes

Useful points:
- membership in a `set` or `dict` is usually faster than in a `list`
- generators save memory
- local variable lookups are cheaper than repeated global lookups
- avoid repeated string concatenation in loops for large workloads
- choose the right data structure before micro-optimizing

## 22. Common Interview Pitfalls

- mutable default arguments
- confusing `is` with `==`
- shallow copy mistakes
- modifying a list while iterating
- broad exception swallowing
- misunderstanding GIL
- not knowing when to use generator versus list
- ignoring time complexity of built-ins

## 23. Strong Interview Phrases

- "Python is dynamically typed but strongly typed."
- "In CPython, bytecode execution is protected by the GIL."
- "For CPU-bound workloads I would prefer multiprocessing, while for I/O-bound workloads threading or asyncio is often more suitable."
- "I would choose readability first and then optimize after measuring the hot path."
