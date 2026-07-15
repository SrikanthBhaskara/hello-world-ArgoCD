# Python Coding Questions by Level with Time Complexity and Follow-Up Questions

## Purpose
This document is designed for Python coding interview preparation for 5 to 7 years of experience. It organizes coding problems by difficulty level and includes:
- problem statement
- sample solution
- expected time complexity
- expected space complexity
- common interview follow-up questions

---

## Easy Level Questions

### 1. Reverse a string
Question:
Write a function to reverse a string.

Sample Answer:
```python
def reverse_string(value):
    return value[::-1]
```

Time Complexity:
- $O(n)$

Space Complexity:
- $O(n)$

Follow-Up Questions:
- Q: Can you do it without slicing?
    A: Yes. I can iterate from the end or use two pointers if the input is mutable like a list.
- Q: What changes if the input is a list of characters instead of a string?
    A: Then I can reverse in place using two-pointer swaps, which can reduce extra memory usage.
- Q: How would you handle very large input strings?
    A: I would consider whether a full reversed copy is required. If memory is a concern, I would process data in chunks where possible.

### 2. Check whether a string is a palindrome
Question:
Write a function to check whether a string is a palindrome.

Sample Answer:
```python
def is_palindrome(value):
    cleaned = value.lower().replace(" ", "")
    return cleaned == cleaned[::-1]
```

Time Complexity:
- $O(n)$

Space Complexity:
- $O(n)$

Follow-Up Questions:
- Q: How would you ignore punctuation as well?
    A: I would filter characters using `str.isalnum()` before comparison.
- Q: Can you solve it using two pointers?
    A: Yes. I can move one pointer from the start and one from the end while skipping unwanted characters.
- Q: How would you optimize memory usage?
    A: A two-pointer approach on filtered logic avoids building a fully reversed extra string.

### 3. Count frequency of characters in a string
Question:
Return the frequency of each character in a string.

Sample Answer:
```python
def char_frequency(value):
    counts = {}

    for char in value:
        counts[char] = counts.get(char, 0) + 1

    return counts
```

Time Complexity:
- $O(n)$

Space Complexity:
- $O(k)$ where $k$ is the number of unique characters

Follow-Up Questions:
- Q: How would you sort the output by frequency?
    A: I would sort `counts.items()` using the frequency as the key.
- Q: How would you make it case-insensitive?
    A: I would normalize the string using `lower()` before counting.
- Q: What if the input is a stream instead of a full string?
    A: I would update counts incrementally as characters arrive.

### 4. Find duplicates in a list
Question:
Given a list, return duplicate elements.

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

Time Complexity:
- $O(n)$

Space Complexity:
- $O(n)$

Follow-Up Questions:
- Q: How would you preserve the original order of duplicates?
    A: I would keep a result list and a second set to ensure each duplicate is added only once in encounter order.
- Q: What if duplicates must be counted?
    A: I would use a frequency dictionary instead of just two sets.
- Q: Can you solve it without extra space if modification is allowed?
    A: If sorting is allowed, I can sort first and detect adjacent duplicates, though that changes time complexity.

### 5. Find the first non-repeating character
Question:
Find the first character in a string that appears only once.

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

Time Complexity:
- $O(n)$

Space Complexity:
- $O(k)$

Follow-Up Questions:
- Q: What if case should be ignored?
    A: I would normalize the input with `lower()` before counting.
- Q: How would you return the index instead of the character?
    A: In the second pass, I would return the current index instead of the character.
- Q: What if the input arrives one character at a time?
    A: I would need a streaming-friendly structure, but exact first non-repeating tracking becomes more complex and may require an ordered queue plus counts.

---

## Intermediate Level Questions

### 1. Merge two sorted lists
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

Time Complexity:
- $O(n + m)$

Space Complexity:
- $O(n + m)$

Follow-Up Questions:
- Q: Can you merge in place?
    A: Only if one list has extra buffer space or if mutation is allowed in a special representation. Otherwise a new list is cleaner.
- Q: What if the inputs are iterators instead of lists?
    A: I can write a generator that yields elements one by one without storing the full merged result.
- Q: How is this related to merge sort?
    A: This is the core merge step used after recursively sorting two halves.

### 2. Flatten a nested list
Question:
Flatten a nested list such as `[1, [2, 3], [4, [5]]]`.

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

Time Complexity:
- $O(n)$ where $n$ is the total number of elements

Space Complexity:
- $O(n)$ plus recursion stack

Follow-Up Questions:
- Q: How would you solve it iteratively?
    A: I would use an explicit stack and process items until the stack is empty.
- Q: What if nested tuples should also be flattened?
    A: I would check `isinstance(item, (list, tuple))` instead of just `list`.
- Q: How would you write this as a generator?
    A: Replace list accumulation with `yield` and `yield from`.

### 3. Group a list of dictionaries by a key
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

Time Complexity:
- $O(n)$

Space Complexity:
- $O(n)$

Follow-Up Questions:
- Q: What if the key is missing in some items?
    A: I would either validate and skip, raise a controlled error, or use `item.get(key)` with a default bucket.
- Q: How would you sort groups by size?
    A: I would sort `grouped.items()` using `len(value)`.
- Q: How would you group by multiple keys?
    A: I would use a tuple of fields as the grouping key.

### 4. Return top K frequent elements
Question:
Given a list of numbers, return the top K most frequent elements.

Sample Answer:
```python
def top_k_frequent(items, k):
    counts = {}

    for item in items:
        counts[item] = counts.get(item, 0) + 1

    sorted_items = sorted(counts.items(), key=lambda pair: pair[1], reverse=True)
    return [item for item, _ in sorted_items[:k]]
```

Time Complexity:
- $O(n log n)$ due to sorting

Space Complexity:
- $O(n)$

Follow-Up Questions:
- Q: Can you do better than full sorting?
    A: Yes. A heap or bucket-based solution can improve efficiency depending on the constraints.
- Q: How would you solve this using a heap?
    A: Build a frequency map, then use `heapq.nlargest` or maintain a min-heap of size `k`.
- Q: What if there are ties?
    A: I would clarify expected behavior. If not specified, any valid top-k order among ties may be acceptable.

### 5. Detect if two strings are anagrams
Question:
Check whether two strings are anagrams of each other.

Sample Answer:
```python
def are_anagrams(first, second):
    cleaned_first = sorted(first.replace(" ", "").lower())
    cleaned_second = sorted(second.replace(" ", "").lower())
    return cleaned_first == cleaned_second
```

Time Complexity:
- $O(n log n)$

Space Complexity:
- $O(n)$

Follow-Up Questions:
- Q: Can you solve it in $O(n)$ using frequency maps?
    A: Yes. Count character frequencies for both strings and compare the maps.
- Q: How would you ignore punctuation?
    A: I would preprocess both strings using `isalnum()`.
- Q: What if the strings are very large?
    A: I would avoid sorting and use frequency counts instead, because that keeps time linear.

---

## Difficult Level Questions

### 1. Implement an LRU cache
Question:
Implement a basic LRU cache with `get` and `put` operations.

Sample Answer:
```python
from collections import OrderedDict


class LRUCache(object):
    def __init__(self, capacity):
        self.capacity = capacity
        self.cache = OrderedDict()

    def get(self, key):
        if key not in self.cache:
            return None
        self.cache.move_to_end(key)
        return self.cache[key]

    def put(self, key, value):
        if key in self.cache:
            self.cache.move_to_end(key)
        self.cache[key] = value

        if len(self.cache) > self.capacity:
            self.cache.popitem(last=False)
```

Time Complexity:
- `get`: $O(1)$
- `put`: $O(1)$

Space Complexity:
- $O(capacity)$

Follow-Up Questions:
- Q: How would you implement it without `OrderedDict`?
    A: Use a hash map for lookup and a doubly linked list for usage order.
- Q: Why is LRU useful in real systems?
    A: It keeps recently used data fast to access while bounding memory.
- Q: What are the thread-safety concerns?
    A: Concurrent reads and writes need synchronization to avoid corrupting cache state.

### 2. Write a generator for large file processing
Question:
Write a generator that yields lines from a file matching a keyword.

Sample Answer:
```python
def search_lines(file_path, keyword):
    with open(file_path, "r") as handle:
        for line in handle:
            if keyword in line:
                yield line.rstrip("\n")
```

Time Complexity:
- $O(n)$ over all lines

Space Complexity:
- $O(1)$ excluding yielded output

Follow-Up Questions:
- Q: Why is a generator better here?
    A: It avoids loading the full file into memory and yields results lazily.
- Q: How would you handle encoding errors?
    A: I would open the file with an explicit encoding and possibly `errors="replace"` or `errors="ignore"` depending on requirements.
- Q: How would you search multiple files efficiently?
    A: Iterate files one by one, or use concurrency if file I/O is the real bottleneck.

### 3. Detect a cycle in a linked list
Question:
How would you detect whether a linked list has a cycle?

Sample Answer:
```python
class Node(object):
    def __init__(self, value):
        self.value = value
        self.next = None



def has_cycle(head):
    slow = head
    fast = head

    while fast and fast.next:
        slow = slow.next
        fast = fast.next.next
        if slow == fast:
            return True

    return False
```

Time Complexity:
- $O(n)$

Space Complexity:
- $O(1)$

Follow-Up Questions:
- Q: Can you find where the cycle starts?
    A: Yes. After slow and fast meet, move one pointer to head and advance both one step at a time until they meet again.
- Q: Why is this better than using a set?
    A: It uses constant extra space instead of storing visited nodes.
- Q: Where is cycle detection useful in real systems?
    A: In linked structures, graph-like traversals, and detecting unintended reference loops.

### 4. Implement retry logic with a decorator
Question:
Write a decorator that retries a function a fixed number of times.

Sample Answer:
```python
import time



def retry(retries=3, delay=1):
    def decorator(function):
        def wrapper(*args, **kwargs):
            last_error = None
            for _ in range(retries):
                try:
                    return function(*args, **kwargs)
                except Exception as error:
                    last_error = error
                    time.sleep(delay)
            raise last_error
        return wrapper
    return decorator
```

Time Complexity:
- Time: O(r * T), where r is retry count and T is single-call cost
- Space: O(1)

Follow-Up Questions:
- Q: Why should retries be used carefully?
    A: Retrying non-idempotent operations can create duplicate side effects.
- Q: What improvement is common in real systems?
    A: Exponential backoff with jitter to avoid retry storms.
- Q: Would you retry all exceptions?
    A: No. Only retry transient failures such as timeouts or temporary connection issues.

### 5. Longest Substring Without Repeating Characters
Question:
Find the length of the longest substring without repeating characters.

Sample Answer:
```python
def longest_unique_substring_length(value):
    seen = {}
    left = 0
    best = 0

    for right, char in enumerate(value):
        if char in seen and seen[char] >= left:
            left = seen[char] + 1
        seen[char] = right
        best = max(best, right - left + 1)

    return best
```

Time Complexity:
- Time: O(n)
- Space: O(k)

Follow-Up Questions:
- Q: What technique is this?
    A: Sliding window.
- Q: Why move the left pointer only forward?
    A: So each position is processed efficiently without revisiting earlier windows unnecessarily.
- Q: How would you return the substring itself?
    A: Track the best start index and best length while iterating.

## How to Answer Coding Questions Well
- Start with a clear explanation before writing code.
- Mention assumptions and edge cases.
- Write a correct solution first, then optimize if needed.
- State time and space complexity clearly.
- Be ready to explain alternatives and tradeoffs.

## Quick Revision Topics
- String manipulation
- Hash map and set patterns
- Sliding window
- Two pointers
- Recursion and generators
- Sorting vs heap-based approaches
- Decorators and context managers
- Retry logic and safe error handling

## Final Note
For Python coding interviews at the 5 to 7 year level, interviewers usually expect more than just correct code. Strong answers show clean implementation, complexity awareness, edge-case thinking, and the ability to handle follow-up questions with confidence.
For Python coding interviews at the 5 to 7 year level, interviewers usually look for more than just working code. Strong answers show clarity, correctness, complexity awareness, and the ability to handle follow-up questions confidently.
For Python coding interviews at the 5 to 7 year level, interviewers usually look for more than just working code. Strong answers show clarity, correctness, complexity awareness, and the ability to handle follow-up questions confidently.
- What changes if the input is streamed?

---

## How to Explain a Coding Solution in Interview
- First explain the brute-force idea if relevant.
- Then present the optimized solution.
- State time complexity and space complexity clearly.
- Mention edge cases.
- If possible, explain tradeoffs between readability and optimization.

## Quick Revision Checklist
- Strings
- Lists and dictionaries
- Sets
- Recursion
- Sliding window
- Two pointers
- Hash map counting
- Generators
- Decorators
- File handling
- Cache patterns
- Retry patterns

## Final Note
For 5 to 7 years of experience, coding rounds usually test more than whether the code works. Interviewers often look for clarity, edge-case awareness, complexity analysis, and your ability to explain why a solution is appropriate.