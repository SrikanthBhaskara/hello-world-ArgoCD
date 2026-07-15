# Thorough Understanding of Algorithms and Design Patterns

## Why This Area Matters
Interviewers ask about algorithms and design patterns to check whether you can build solutions that are efficient, maintainable, and reusable. They do not only want textbook definitions. They want to know whether you can apply these ideas in practical engineering work.

## How to Study Algorithms Properly
Algorithms should not be studied as isolated names. For each topic, understand four things:
1. What kind of problem it solves.
2. The common approach used to solve it.
3. The time and space tradeoff.
4. The signals that tell you this technique is useful.

## Searching

### What it is
Searching means finding whether a target value exists, where it exists, or which item satisfies a condition.

### Main types
- Linear search
- Binary search
- Search using hashing
- Search in trees or graphs

### Linear search
Linear search checks each element one by one. It is simple and works on unsorted data, but it can be slow for large collections because the time complexity is $O(n)$.

### Binary search
Binary search works on sorted data. It repeatedly cuts the search range in half, which gives $O(log n)$ time complexity.

### When to use binary search
- The data is sorted.
- You need fast lookups.
- You need to find boundaries such as first valid value or last valid value.

### Interview signal
If the problem says sorted array, sorted list, ordered values, or finding a threshold, binary search should come to mind.

## Sorting

### What it is
Sorting arranges data in a specific order so later operations like searching, merging, grouping, or ranking become easier.

### Why sorting matters
Sorting often changes a difficult problem into an easier one. For example, duplicate detection, interval merging, and nearest-neighbor style problems become simpler after sorting.

### Common sorting algorithms to know conceptually
- Bubble sort: simple but inefficient, usually $O(n^2)$.
- Insertion sort: useful for small or nearly sorted data.
- Merge sort: stable and typically $O(n log n)$.
- Quick sort: fast in practice, average $O(n log n)$, worst case $O(n^2)$.
- Heap sort: $O(n log n)$ and based on heap structure.

### What interviewers usually expect
You normally do not need to implement every sorting algorithm from scratch unless explicitly asked. More often, interviewers want to know when sorting helps solve a higher-level problem.

## Hashing

### What it is
Hashing uses a hash-based structure such as a set or dictionary to support fast lookup, insertion, and update operations. Average-case complexity is often close to $O(1)$.

### What hashing helps with
- Duplicate detection
- Frequency counting
- Grouping
- Fast membership checks
- Mapping one value to another

### Common examples
- Check whether an array contains duplicates.
- Count character frequency in a string.
- Group words by shared property.
- Cache already computed results.

### Interview signal
If the problem asks whether something exists, how many times something appears, or how to find duplicates efficiently, hashing is often a strong first option.

## Recursion

### What it is
Recursion solves a problem by defining the solution in terms of smaller versions of the same problem.

### Core ideas
- Base case: when recursion should stop.
- Recursive case: how the problem becomes smaller.
- Stack behavior: each recursive call adds call-stack cost.

### Where recursion is useful
- Tree traversal
- Graph traversal
- Divide-and-conquer problems
- Backtracking problems

### Common risk
If the base case is missing or wrong, recursion can cause infinite calls or stack overflow. Interviewers care about whether you understand the stopping condition clearly.

## Dynamic Programming Basics

### What it is
Dynamic programming is used when a problem has overlapping subproblems and optimal substructure. Instead of recalculating the same work repeatedly, you store intermediate results.

### Two major forms
- Top-down with memoization
- Bottom-up with tabulation

### How to recognize a dynamic programming problem
- A brute-force recursive solution repeats work.
- The problem asks for minimum, maximum, count, or total combinations.
- The problem can be broken into smaller states.

### Simple examples
- Fibonacci with memoization
- Climbing stairs
- Longest common subsequence
- Coin change

### Interview advice
Even if you do not solve advanced DP quickly, you should be able to explain state, transition, and why caching repeated work helps.

## Trees and Graphs Basics

### Trees
Trees are hierarchical structures. Common operations include traversal, search, insertion, and aggregation.

### Common traversals
- Preorder
- Inorder
- Postorder
- Level order

### Graphs
Graphs represent relationships between nodes. They are useful for dependency modeling, path finding, connectivity, and network-like problems.

### Common graph techniques
- Depth-first search
- Breadth-first search
- Visited tracking
- Shortest path basics

### Interview signal
If the problem involves parent-child hierarchy, nested structure, dependency ordering, routes, or connections between entities, trees or graphs may be the correct model.

## Sliding Window

### What it is
Sliding window is a technique for problems involving contiguous subarrays or substrings. Instead of recalculating the whole range repeatedly, you move a window forward and update state incrementally.

### When it is useful
- Longest substring problems
- Fixed-size window sums or averages
- Smallest subarray meeting a condition
- Contiguous range analysis

### Types
- Fixed-size window
- Variable-size window

### Why it is efficient
Many brute-force contiguous-range problems are $O(n^2)$, but sliding window often reduces them to $O(n)$ because each element is processed a limited number of times.

## Two Pointers

### What it is
Two pointers use two positions moving through data in a controlled way. It is common in sorted arrays, string scanning, linked lists, and partitioning problems.

### Common uses
- Pair sum in sorted array
- Removing duplicates in place
- Reversing or partitioning arrays
- Fast and slow pointer problems in linked lists

### Interview signal
If the problem involves sorted data, pair matching, shrinking from both ends, or scanning with relative movement, two pointers is a likely candidate.

## Heap or Priority Queue Basics

### What it is
A heap is a structure that gives efficient access to the smallest or largest item. A priority queue uses that behavior to always process the highest-priority element next.

### Where it is useful
- Top K problems
- Scheduling
- Stream processing
- Repeatedly taking min or max efficiently

### Complexity intuition
Insertion and removal are commonly $O(log n)$, while peeking at the top element is often $O(1)$.

### Interview signal
If the problem involves repeatedly selecting the smallest, largest, earliest, or highest-priority item, a heap is often the right tool.

## Complexity Awareness
You do not need to mention complexity mechanically, but you should know the tradeoff between a brute-force approach and a more optimized one.

### Example
If a duplicate-checking problem is solved with nested loops, the time complexity is $O(n^2)$. If it uses a set, it can often be reduced to $O(n)$.

## Design Patterns: Why They Matter
Design patterns are reusable solution structures for common software design problems. They help improve clarity, extensibility, and maintainability when used appropriately.

## Common Patterns to Know in Depth

### Singleton
Ensures only one instance of a class exists.

Use carefully because it can create hidden global state and make testing harder.

### Factory
Encapsulates object creation.

Useful when object creation is complex or when the caller should not know the exact concrete type.

### Strategy
Encapsulates interchangeable behavior behind a common interface.

Useful when the system supports multiple algorithms or business rules that should be swapped cleanly.

### Observer
Allows one object to notify other interested objects about a change.

Useful in event-driven systems, notification flows, and UI-style state updates.

### Adapter
Wraps one interface so it can work with another expected interface.

Useful when integrating older code or third-party components without rewriting them.

### Decorator
Adds behavior around an existing object without changing the core implementation.

Useful for logging, metrics, retries, access checks, or layered behavior.

### Repository
Separates data access logic from business logic.

Useful for testability and keeping persistence concerns out of domain code.

### Dependency Injection
Provides dependencies from outside instead of creating them directly inside a class.

Useful for loose coupling, easier testing, and clearer architecture.

## Practical Understanding Matters More Than Memorization
Interviewers usually care more about whether you can recognize when a pattern is useful than whether you can recite a formal definition.

## How to Speak About This in Interviews

### Sample interview answer
I try to understand algorithms and design patterns from a practical perspective. For algorithms, I focus on recognizing the problem shape, choosing an efficient approach based on constraints, and explaining the tradeoff between simpler and optimized solutions. For design patterns, I focus on maintainability and whether the pattern actually improves the design instead of adding unnecessary abstraction.

## Common Interview Questions

### How do you choose between a simple brute-force solution and an optimized one
I consider input size, performance need, code clarity, and whether the optimization adds worthwhile value. If the brute-force approach is too slow or repeats work unnecessarily, I look for a better structure such as hashing, sliding window, two pointers, or dynamic programming.

### What is the risk of overusing design patterns
The code can become harder to understand if patterns are added without a real problem they solve. Patterns should reduce complexity, not create ceremony.

### Do you need advanced algorithms in everyday backend work
Not always, but strong fundamentals help solve data-processing and performance problems more effectively. Even when advanced algorithms are rare, clear complexity awareness is valuable.

## Coding Examples and Solved Problems

### 1. Searching Example: Binary Search

Problem:
Find the index of a target in a sorted array. Return `-1` if it does not exist.

```python
def binary_search(nums, target):
	left = 0
	right = len(nums) - 1

	while left <= right:
		mid = (left + right) // 2

		if nums[mid] == target:
			return mid
		if nums[mid] < target:
			left = mid + 1
		else:
			right = mid - 1

	return -1
```

Explanation:
This works because the array is sorted. Each step removes half of the remaining search space.

Complexity:
- Time: $O(log n)$
- Space: $O(1)$

### 2. Hashing Example: Contains Duplicate

Problem:
Check whether a list contains duplicate values.

```python
def contains_duplicate(nums):
	seen = set()

	for value in nums:
		if value in seen:
			return True
		seen.add(value)

	return False
```

Explanation:
The set gives fast membership checking, so each value can be checked in average $O(1)$ time.

Complexity:
- Time: $O(n)$
- Space: $O(n)$

### 3. Recursion Example: Tree Depth

Problem:
Find the maximum depth of a binary tree.

```python
class Node:
	def __init__(self, value=0, left=None, right=None):
		self.value = value
		self.left = left
		self.right = right


def max_depth(root):
	if root is None:
		return 0

	return 1 + max(max_depth(root.left), max_depth(root.right))
```

Explanation:
The recursive idea is simple: the depth of a node is `1 + max(left_depth, right_depth)`.

Complexity:
- Time: $O(n)$
- Space: $O(h)$ where `h` is the tree height because of recursion stack

### 4. Dynamic Programming Example: Climbing Stairs

Problem:
You can climb 1 or 2 steps at a time. How many distinct ways are there to reach step `n`?

```python
def climb_stairs(n):
	if n <= 2:
		return n

	first = 1
	second = 2

	for _ in range(3, n + 1):
		first, second = second, first + second

	return second
```

Explanation:
The number of ways to reach step `n` depends on the previous two states. This is a classic dynamic programming pattern.

Complexity:
- Time: $O(n)$
- Space: $O(1)$

### 5. Trees and Graphs Example: Breadth-First Search

Problem:
Traverse a binary tree level by level.

```python
from collections import deque


def level_order(root):
	if root is None:
		return []

	result = []
	queue = deque([root])

	while queue:
		level_size = len(queue)
		level = []

		for _ in range(level_size):
			node = queue.popleft()
			level.append(node.value)

			if node.left:
				queue.append(node.left)
			if node.right:
				queue.append(node.right)

		result.append(level)

	return result
```

Explanation:
Breadth-first search uses a queue and processes nodes level by level.

Complexity:
- Time: $O(n)$
- Space: $O(n)$

### 6. Sliding Window Example: Maximum Sum of Size K

Problem:
Find the maximum sum of any contiguous subarray of size `k`.

```python
def max_sum_subarray(nums, k):
	if len(nums) < k:
		return None

	window_sum = sum(nums[:k])
	best = window_sum

	for right in range(k, len(nums)):
		window_sum += nums[right]
		window_sum -= nums[right - k]
		best = max(best, window_sum)

	return best
```

Explanation:
Instead of recalculating every subarray sum from scratch, the window is updated by removing one element and adding one new element.

Complexity:
- Time: $O(n)$
- Space: $O(1)$

### 7. Two Pointers Example: Pair Sum in Sorted Array

Problem:
Given a sorted array and a target, return whether two numbers add up to the target.

```python
def has_pair_with_sum(nums, target):
	left = 0
	right = len(nums) - 1

	while left < right:
		current = nums[left] + nums[right]

		if current == target:
			return True
		if current < target:
			left += 1
		else:
			right -= 1

	return False
```

Explanation:
Because the data is sorted, moving the pointers changes the sum in a predictable way.

Complexity:
- Time: $O(n)$
- Space: $O(1)$

### 8. Heap Example: Top K Largest Elements

Problem:
Return the `k` largest elements from an array.

```python
import heapq


def top_k_largest(nums, k):
	heap = []

	for value in nums:
		heapq.heappush(heap, value)
		if len(heap) > k:
			heapq.heappop(heap)

	return sorted(heap, reverse=True)
```

Explanation:
The heap keeps only the top `k` values seen so far, so memory stays limited.

Complexity:
- Time: $O(n log k)$
- Space: $O(k)$

### 9. Pattern Selection Example

Question:
How do you know whether to use hashing, sliding window, or two pointers?

Answer:
- Use hashing when you need fast membership, frequency, or mapping.
- Use sliding window when the problem involves contiguous ranges.
- Use two pointers when the data is sorted or when two moving positions make the comparison efficient.

## More Coding Problems by Difficulty Level

### Easy Problems

#### Problem 1: First Unique Character in a String
Return the index of the first non-repeating character. Return `-1` if every character repeats.

```python
from collections import Counter


def first_unique_char(text):
	counts = Counter(text)

	for index, ch in enumerate(text):
		if counts[ch] == 1:
			return index

	return -1
```

Why this problem matters:
It tests hashing, frequency counting, and clean iteration.

Complexity:
- Time: $O(n)$
- Space: $O(n)$

#### Problem 2: Merge Two Sorted Arrays
Given two sorted arrays, merge them into one sorted array.

```python
def merge_sorted_arrays(nums1, nums2):
	left = 0
	right = 0
	merged = []

	while left < len(nums1) and right < len(nums2):
		if nums1[left] <= nums2[right]:
			merged.append(nums1[left])
			left += 1
		else:
			merged.append(nums2[right])
			right += 1

	merged.extend(nums1[left:])
	merged.extend(nums2[right:])
	return merged
```

Why this problem matters:
It checks sorting awareness and pointer-based traversal.

Complexity:
- Time: $O(n + m)$
- Space: $O(n + m)$

### Intermediate Problems

#### Problem 3: Longest Substring Without Repeating Characters
Find the length of the longest substring without duplicate characters.

```python
def longest_unique_substring(text):
	seen = {}
	left = 0
	best = 0

	for right, ch in enumerate(text):
		if ch in seen and seen[ch] >= left:
			left = seen[ch] + 1

		seen[ch] = right
		best = max(best, right - left + 1)

	return best
```

Why this problem matters:
It combines hashing with variable-size sliding window.

Complexity:
- Time: $O(n)$
- Space: $O(min(n, k))$ where $k$ is the character set size

#### Problem 4: Product of Array Except Self
Return an array where each element is the product of all other elements except the current one, without using division.

```python
def product_except_self(nums):
	result = [1] * len(nums)

	prefix = 1
	for index in range(len(nums)):
		result[index] = prefix
		prefix *= nums[index]

	suffix = 1
	for index in range(len(nums) - 1, -1, -1):
		result[index] *= suffix
		suffix *= nums[index]

	return result
```

Why this problem matters:
It tests array reasoning, prefix-suffix thinking, and optimization without extra nested loops.

Complexity:
- Time: $O(n)$
- Space: $O(1)$ extra space if output array is not counted

### Difficult Problems

#### Problem 5: Kth Largest Element in an Array
Return the `k`th largest element in an unsorted array.

```python
import heapq


def kth_largest(nums, k):
	heap = []

	for value in nums:
		heapq.heappush(heap, value)
		if len(heap) > k:
			heapq.heappop(heap)

	return heap[0]
```

Why this problem matters:
It checks heap usage and partial-order thinking instead of full sorting.

Complexity:
- Time: $O(n log k)$
- Space: $O(k)$

#### Problem 6: Number of Islands
Given a grid of `1`s and `0`s, count how many connected islands of `1`s exist.

```python
def num_islands(grid):
	if not grid:
		return 0

	rows = len(grid)
	cols = len(grid[0])
	count = 0

	def dfs(row, col):
		if row < 0 or row >= rows or col < 0 or col >= cols:
			return
		if grid[row][col] != "1":
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

Why this problem matters:
It tests graph traversal, recursion, visited handling, and grid reasoning.

Complexity:
- Time: $O(rows * cols)$
- Space: $O(rows * cols)$ in worst-case recursion depth

### How to Use These Problems in Interview Preparation
- Start by identifying the pattern before writing code.
- State the brute-force idea briefly.
- Explain why the chosen technique is better.
- Mention time and space complexity clearly.
- Test with one normal case and one edge case.

## Interview Style Q&A

### Q1. How do you decide which algorithmic technique to try first?
I look at the shape of the problem. If it involves fast lookup or counting, hashing is a strong candidate. If it involves contiguous subarrays or substrings, sliding window is often useful. If the input is sorted, I consider binary search or two pointers. The goal is to recognize patterns instead of treating every problem as completely new.

### Q2. What is the difference between recursion and dynamic programming?
Recursion defines a solution in terms of smaller versions of the same problem. Dynamic programming is used when those smaller problems overlap and repeated work can be saved. So dynamic programming often starts from a recursive idea but improves it by storing intermediate results.

### Q3. When would you use a heap instead of sorting the whole list?
I would use a heap when I only need the top `k` elements or repeated min or max access. Sorting the entire list may do more work than necessary if I do not need full order.

### Q4. How do design patterns help in practical engineering work?
They help when a recurring structural problem appears, such as varying behavior, controlled object creation, event notification, or dependency separation. I use patterns when they make the code easier to extend or test, not just because I know the pattern name.

### Q5. What is the biggest mistake people make with design patterns?
They often introduce abstraction before there is a real need. That can make code harder to understand. A pattern is useful only if it solves an actual maintainability or design problem.

## Quick Revision Checklist
- Can I explain when to use binary search instead of linear search?
- Can I explain when hashing is better than nested loops?
- Can I explain how sliding window reduces repeated work?
- Can I explain the difference between recursion and dynamic programming?
- Can I explain when heaps are useful?
- Can I explain 3 to 4 patterns with practical examples?
- Can I explain when not to use a pattern?