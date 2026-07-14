# Python Coding Questions With Solutions

This file contains common Python interview coding questions with clean solutions and short explanations.

## 1. Reverse a String

```python
def reverse_string(value: str) -> str:
    return value[::-1]
```

Explanation:
Python slicing is the cleanest answer for this problem.

## 2. Check Palindrome

```python
def is_palindrome(value: str) -> bool:
    return value == value[::-1]
```

Explanation:
This is concise and easy to explain in interviews.

## 3. Count Character Frequency

```python
from collections import Counter


def char_frequency(value: str) -> dict[str, int]:
    return dict(Counter(value))
```

Explanation:
`Counter` is an interviewer-friendly built-in tool for counting.

## 4. Find First Non-Repeated Character

```python
from collections import Counter


def first_non_repeated(value: str) -> str | None:
    counts = Counter(value)
    for char in value:
        if counts[char] == 1:
            return char
    return None
```

## 5. Two Sum

```python
def two_sum(nums: list[int], target: int) -> list[int]:
    seen: dict[int, int] = {}

    for index, number in enumerate(nums):
        complement = target - number
        if complement in seen:
            return [seen[complement], index]
        seen[number] = index

    return []
```

Explanation:
Hash map lookup reduces brute-force `O(n^2)` to `O(n)`.

## 6. Remove Duplicates While Preserving Order

```python
def remove_duplicates(items: list[int]) -> list[int]:
    seen = set()
    result = []

    for item in items:
        if item not in seen:
            seen.add(item)
            result.append(item)

    return result
```

## 7. FizzBuzz

```python
def fizz_buzz(n: int) -> list[str]:
    result = []
    for i in range(1, n + 1):
        if i % 15 == 0:
            result.append("FizzBuzz")
        elif i % 3 == 0:
            result.append("Fizz")
        elif i % 5 == 0:
            result.append("Buzz")
        else:
            result.append(str(i))
    return result
```

## 8. Flatten a Nested List

```python
def flatten(values: list) -> list:
    result = []
    for value in values:
        if isinstance(value, list):
            result.extend(flatten(value))
        else:
            result.append(value)
    return result
```

## 9. Find Missing Number

```python
def missing_number(nums: list[int]) -> int:
    n = len(nums)
    expected = n * (n + 1) // 2
    return expected - sum(nums)
```

## 10. Merge Two Sorted Lists

```python
def merge_sorted_lists(a: list[int], b: list[int]) -> list[int]:
    i = 0
    j = 0
    result = []

    while i < len(a) and j < len(b):
        if a[i] <= b[j]:
            result.append(a[i])
            i += 1
        else:
            result.append(b[j])
            j += 1

    result.extend(a[i:])
    result.extend(b[j:])
    return result
```

## 11. Valid Parentheses

```python
def is_valid_parentheses(value: str) -> bool:
    pairs = {")": "(", "}": "{", "]": "["}
    stack: list[str] = []

    for char in value:
        if char in pairs.values():
            stack.append(char)
        elif char in pairs:
            if not stack or stack.pop() != pairs[char]:
                return False

    return not stack
```

## 12. Maximum Subarray

```python
def max_subarray(nums: list[int]) -> int:
    current = best = nums[0]
    for value in nums[1:]:
        current = max(value, current + value)
        best = max(best, current)
    return best
```

Explanation:
This is Kadane's algorithm.

## 13. Longest Substring Without Repeating Characters

```python
def longest_unique_substring(value: str) -> int:
    last_seen: dict[str, int] = {}
    left = 0
    best = 0

    for right, char in enumerate(value):
        if char in last_seen:
            left = max(left, last_seen[char] + 1)
        last_seen[char] = right
        best = max(best, right - left + 1)

    return best
```

## 14. Binary Search

```python
def binary_search(nums: list[int], target: int) -> int:
    left = 0
    right = len(nums) - 1

    while left <= right:
        mid = left + (right - left) // 2
        if nums[mid] == target:
            return mid
        if nums[mid] < target:
            left = mid + 1
        else:
            right = mid - 1

    return -1
```

## 15. Group Anagrams

```python
from collections import defaultdict


def group_anagrams(words: list[str]) -> list[list[str]]:
    groups: defaultdict[tuple[str, ...], list[str]] = defaultdict(list)

    for word in words:
        groups[tuple(sorted(word))].append(word)

    return list(groups.values())
```

## 16. Top K Frequent Elements

```python
from collections import Counter


def top_k_frequent(nums: list[int], k: int) -> list[int]:
    return [item for item, _ in Counter(nums).most_common(k)]
```

## 17. Word Count

```python
from collections import Counter


def word_count(text: str) -> dict[str, int]:
    return dict(Counter(text.split()))
```

## 18. Check if Two Strings Are Anagrams

```python
from collections import Counter


def is_anagram(first: str, second: str) -> bool:
    return Counter(first) == Counter(second)
```

## 19. Fibonacci With Memoization

```python
from functools import lru_cache


@lru_cache(maxsize=None)
def fibonacci(n: int) -> int:
    if n <= 1:
        return n
    return fibonacci(n - 1) + fibonacci(n - 2)
```

## 20. Merge Intervals

```python
def merge_intervals(intervals: list[list[int]]) -> list[list[int]]:
    intervals.sort(key=lambda interval: interval[0])
    merged: list[list[int]] = []

    for interval in intervals:
        if not merged or merged[-1][1] < interval[0]:
            merged.append(interval)
        else:
            merged[-1][1] = max(merged[-1][1], interval[1])

    return merged
```

## 21. Number of Islands

```python
def num_islands(grid: list[list[str]]) -> int:
    rows = len(grid)
    cols = len(grid[0])
    count = 0

    def dfs(row: int, col: int) -> None:
        if row < 0 or col < 0 or row >= rows or col >= cols or grid[row][col] != "1":
            return

        grid[row][col] = "0"
        dfs(row + 1, col)
        dfs(row - 1, col)
        dfs(row, col + 1)
        dfs(row, col - 1)

    for row in range(rows):
        for col in range(cols):
            if grid[row][col] == "1":
                count += 1
                dfs(row, col)

    return count
```

## 22. LRU Cache Using Standard Library

```python
from collections import OrderedDict


class LRUCache:
    def __init__(self, capacity: int):
        self.capacity = capacity
        self.cache: OrderedDict[int, int] = OrderedDict()

    def get(self, key: int) -> int:
        if key not in self.cache:
            return -1
        self.cache.move_to_end(key)
        return self.cache[key]

    def put(self, key: int, value: int) -> None:
        if key in self.cache:
            self.cache.move_to_end(key)
        self.cache[key] = value
        if len(self.cache) > self.capacity:
            self.cache.popitem(last=False)
```

## 23. Decorator for Timing

```python
import time
from functools import wraps


def timing_decorator(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        start = time.time()
        try:
            return func(*args, **kwargs)
        finally:
            end = time.time()
            print(f"{func.__name__} took {end - start:.6f} seconds")

    return wrapper
```

## 24. Custom Context Manager

```python
class ManagedResource:
    def __enter__(self):
        print("resource acquired")
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        print("resource released")
        return False
```

## 25. Find Duplicates in a List

```python
from collections import Counter


def find_duplicates(items: list[int]) -> list[int]:
    counts = Counter(items)
    return [item for item, count in counts.items() if count > 1]
```
