# Practical Python Interview Questions for 5 to 7 Years Experience

## Purpose
This file focuses on practical Python interview questions for engineers with 5 to 7 years of experience. The goal is not only to know syntax, but to explain how Python is used in production systems, debugging, automation, APIs, and maintainable backend development.

## 1. Core Python Questions

### 1. What is the difference between list, tuple, set, and dictionary?
Answer:
A list is ordered and mutable. A tuple is ordered and immutable. A set stores unique values and is useful for membership checks. A dictionary stores key-value pairs and is useful for fast lookups by key.

### 2. What is the difference between `is` and `==`?
Answer:
`==` checks value equality, while `is` checks object identity, meaning whether two variables point to the same object in memory.

### 3. What are mutable and immutable types in Python?
Answer:
Mutable types can be changed after creation, such as lists and dictionaries. Immutable types cannot be changed after creation, such as strings, tuples, and integers.

### 4. What is the difference between shallow copy and deep copy?
Answer:
A shallow copy copies the outer object but still references nested objects. A deep copy recursively copies nested objects as well. Deep copy is safer when nested mutable objects should not be shared.

### 5. What are `*args` and `**kwargs`?
Answer:
`*args` collects positional arguments into a tuple. `**kwargs` collects keyword arguments into a dictionary. They are useful when functions need flexible argument handling.

## 2. Practical Python Usage Questions

### 1. How do you write maintainable Python code in a production codebase?
Answer:
I keep functions small and focused, use meaningful names, avoid unnecessary cleverness, handle errors explicitly, and separate business logic from helper or transport logic. I also prefer readable code over compact but unclear code.

### 2. How do you handle exceptions in Python services or scripts?
Answer:
I catch only the exceptions I can handle meaningfully. I log enough context for debugging, avoid silently swallowing errors, and return controlled responses or cleanup behavior where appropriate. I avoid broad `except Exception` unless it is part of a top-level safety boundary.

### 3. When would you use a generator?
Answer:
I use a generator when I want lazy evaluation, especially for large data processing or streaming scenarios. Generators help reduce memory usage because they yield values one at a time instead of building the full collection in memory.

### 4. What is a decorator, and when do you use it?
Answer:
A decorator wraps another function to add reusable behavior such as logging, timing, authentication, or retries without changing the function’s main logic.

### 5. What is a context manager?
Answer:
A context manager ensures setup and cleanup behavior around a block of code, usually via `with`. It is commonly used for files, locks, and database connections so resources are always released properly.

## 3. Debugging and Performance Questions

### 1. A Python service is consuming too much memory. What do you check?
Answer:
I would check whether large objects are being held longer than needed, whether data is being loaded eagerly instead of lazily, whether caches are bounded, and whether references are preventing garbage collection. I would also inspect repeated growth patterns in logs or profiling output.

### 2. How do you debug a slow Python script?
Answer:
I first identify which part is slow by adding timing logs or using profiling tools. Then I check expensive loops, database or network calls, repeated conversions, unnecessary data loading, and inefficient algorithms. I optimize only after identifying the real bottleneck.

### 3. What are common Python performance issues?
Answer:
Common issues include repeated string concatenation, unnecessary nested loops, loading large datasets into memory at once, inefficient data structures, excessive serialization, too many blocking I/O calls, and repeated database access inside loops.

### 4. How do you think about concurrency in Python?
Answer:
I choose the approach based on workload type. For I/O-bound work, threads or async can help. For CPU-bound work, multiprocessing may be better because of the GIL. The choice depends on whether the problem is waiting on I/O or performing CPU-heavy computation.

## 4. Python in Backend and Automation

### 1. Why is Python commonly used in backend systems and automation?
Answer:
Python is productive, readable, and has strong library support. It works well for APIs, scripting, automation, monitoring tools, integration layers, and operational workflows where development speed and maintainability matter.

### 2. How do you organize a Python project cleanly?
Answer:
I separate modules by responsibility, keep configuration separate from code, isolate utility functions from business logic, and structure tests clearly. I also try to make imports and dependencies predictable and easy to understand.

### 3. What is the importance of virtual environments?
Answer:
Virtual environments isolate project dependencies so different projects do not interfere with each other. They help keep package versions controlled and make local development more reproducible.

### 4. How do you manage dependencies safely?
Answer:
I pin versions where needed, keep the dependency list clear, avoid unnecessary packages, and review security or compatibility impacts before upgrades. For production systems, dependency changes should be treated carefully because they can introduce hidden regressions.

## 5. Scenario-Based Python Questions

### 1. A Python batch job fails only on large inputs. What do you suspect?
Answer:
I would suspect memory usage, inefficient algorithms, recursion depth, unbounded intermediate structures, or data-specific edge cases. I would compare small and large input paths to see what scales badly.

### 2. A script works locally but fails in production. What do you check?
Answer:
I would check Python version, dependency versions, environment variables, permissions, file paths, OS-level differences, input data differences, and external service behavior.

### 3. A Python service intermittently returns wrong results. What do you inspect?
Answer:
I would inspect shared mutable state, race conditions, stale cache values, partial updates, retry side effects, and any non-thread-safe code paths.

## 6. Python Coding Questions

### 1. Reverse a string.
Question:
Write a function to reverse a string.

Sample Answer:
```python
def reverse_string(value):
	return value[::-1]
```

What Interviewer Checks:
- Basic Python syntax
- String slicing knowledge

### 2. Check if a string is a palindrome.
Question:
Write a function to check whether a string is a palindrome.

Sample Answer:
```python
def is_palindrome(value):
	cleaned = value.lower().replace(" ", "")
	return cleaned == cleaned[::-1]
```

What Interviewer Checks:
- String handling
- Input normalization
- Clear function design

### 3. Find duplicates in a list.
Question:
Given a list, return duplicate values.

Sample Answer:
```python
def find_duplicates(items):
	seen = set()
	duplicates = set()

	for item in items:
		if item in seen:
			duplicates.add(item)
		else:
			seen.add(item)

	return list(duplicates)
```

What Interviewer Checks:
- Set usage
- Time complexity awareness

### 4. Count the frequency of characters in a string.
Question:
Write a function to count how many times each character appears.

Sample Answer:
```python
def char_frequency(value):
	counts = {}

	for char in value:
		counts[char] = counts.get(char, 0) + 1

	return counts
```

What Interviewer Checks:
- Dictionary usage
- Clean loop logic

### 5. Merge two sorted lists.
Question:
Merge two sorted lists into one sorted list.

Sample Answer:
```python
def merge_sorted_lists(left, right):
	merged = []
	left_index = 0
	right_index = 0

	while left_index < len(left) and right_index < len(right):
		if left[left_index] <= right[right_index]:
			merged.append(left[left_index])
			left_index += 1
		else:
			merged.append(right[right_index])
			right_index += 1

	merged.extend(left[left_index:])
	merged.extend(right[right_index:])
	return merged
```

What Interviewer Checks:
- List traversal
- Index handling
- Sorted merge logic

### 6. Find the first non-repeating character.
Question:
Write a function to find the first non-repeating character in a string.

Sample Answer:
```python
def first_non_repeating_char(value):
	counts = {}

	for char in value:
		counts[char] = counts.get(char, 0) + 1

	for char in value:
		if counts[char] == 1:
			return char

	return None
```

What Interviewer Checks:
- Two-pass logic
- Dictionary counting

### 7. Flatten a nested list.
Question:
Flatten a nested list like `[1, [2, 3], [4, [5]]]`.

Sample Answer:
```python
def flatten(items):
	result = []

	for item in items:
		if isinstance(item, list):
			result.extend(flatten(item))
		else:
			result.append(item)

	return result
```

What Interviewer Checks:
- Recursion
- Type handling
- Clean decomposition

### 8. Read a file safely and count lines.
Question:
Write a function that reads a file and returns the number of lines.

Sample Answer:
```python
def count_lines(file_path):
	with open(file_path, "r") as handle:
		return sum(1 for _ in handle)
```

What Interviewer Checks:
- Context manager usage
- File handling basics

### 9. Write a decorator to measure execution time.
Question:
Write a decorator that prints how long a function takes.

Sample Answer:
```python
import time


def measure_time(function):
	def wrapper(*args, **kwargs):
		start_time = time.time()
		result = function(*args, **kwargs)
		end_time = time.time()
		print("Execution time:", end_time - start_time)
		return result

	return wrapper
```

What Interviewer Checks:
- Decorator understanding
- Wrapper arguments
- Practical utility coding

### 10. Group items by a key.
Question:
Given a list of dictionaries, group them by a field such as `department`.

Sample Answer:
```python
def group_by_key(items, key):
	grouped = {}

	for item in items:
		group_value = item[key]
		grouped.setdefault(group_value, []).append(item)

	return grouped
```

What Interviewer Checks:
- Dictionary patterns
- Practical data transformation

### 11. Explain time complexity for a Python solution.
Question:
If you solve a duplicate-finding problem using a set, what is the time complexity?

Sample Answer:
Using a set usually gives average-case $O(1)$ lookup, so traversing the list once results in overall $O(n)$ time complexity. Space complexity is also $O(n)$ because extra storage is used for seen values.

What Interviewer Checks:
- Ability to reason beyond syntax
- Awareness of time and space tradeoffs

### 12. How do you improve a Python coding answer in an interview?
Answer:
After writing the working solution, I explain edge cases, time complexity, space complexity, and whether the solution is readable and production-safe. If useful, I mention alternative approaches and why I prefer one.

## 7. Strong Interview Answer Style for Python
- Explain the Python concept simply.
- Mention where you have used it in practice.
- Call out tradeoffs such as readability, performance, safety, or memory usage.
- Show how you would debug or validate behavior in production.

## 8. Quick Revision Topics
- Mutable vs immutable
- List vs tuple vs set vs dict
- `is` vs `==`
- Shallow copy vs deep copy
- Generators
- Decorators
- Context managers
- Exception handling
- Concurrency choices in Python
- Memory and performance debugging
- Common coding patterns using dict, set, list, recursion, and file handling

## Final Note
At 5 to 7 years of experience, Python interviews often focus less on syntax memorization and more on how you use Python to build reliable, readable, and production-safe systems.