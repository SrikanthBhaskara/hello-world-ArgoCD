# Java DSA Blind 75 / Top 100 Roadmap

## Purpose

This file gives you a practical Java DSA roadmap for interview preparation.

Use it for:
- beginner to 6+ years coding-round preparation
- Blind 75 style revision
- topic-wise problem practice in Java
- deciding what to practice first instead of solving random problems

## How To Use This Roadmap

1. Learn the pattern first.
2. Solve 3 to 5 easy problems in Java.
3. Solve core medium problems without looking at hints.
4. Re-solve weak problems after 2 to 3 days.
5. Explain time and space complexity aloud.
6. Write clean Java using good method names and edge-case handling.

## What To Focus On By Experience Level

### 0 to 2 years
- arrays and strings
- hashing
- stack and queue basics
- linked list basics
- binary search
- simple trees

### 2 to 4 years
- sliding window
- two pointers
- recursion and backtracking
- heap and top-k
- BFS and DFS
- medium DP

### 4 to 7 years
- faster pattern recognition
- code quality under pressure
- clean tradeoff explanation
- multiple-solution discussion
- stronger graph, DP, and tree confidence

## Stage 1: Arrays and Strings

### Patterns to learn
- frequency counting
- two pointers
- prefix sum
- Kadane's algorithm
- in-place traversal

### Must-practice problems
- Two Sum
- Best Time to Buy and Sell Stock
- Contains Duplicate
- Product of Array Except Self
- Maximum Subarray
- Maximum Product Subarray
- Find Minimum in Rotated Sorted Array
- Search in Rotated Sorted Array
- 3Sum
- Container With Most Water

### Java focus
- `HashMap`
- `HashSet`
- `StringBuilder`
- array traversal
- careful index bounds

## Stage 2: Sliding Window and Two Pointers

### Patterns to learn
- fixed window
- variable window
- duplicate control using map or set
- left and right pointer movement rules

### Must-practice problems
- Longest Substring Without Repeating Characters
- Longest Repeating Character Replacement
- Minimum Window Substring
- Permutation in String
- Valid Palindrome
- Move Zeroes
- Remove Duplicates from Sorted Array
- Squares of a Sorted Array

### Java focus
- `Map<Character, Integer>` for counts
- `Set<Character>` for uniqueness checks
- keeping left pointer monotonic

## Stage 3: Intervals

### Patterns to learn
- sort and merge
- overlap detection
- greedy interval decisions

### Must-practice problems
- Merge Intervals
- Insert Interval
- Non-overlapping Intervals
- Meeting Rooms
- Meeting Rooms II
- Minimum Number of Arrows to Burst Balloons

### Java focus
- `Arrays.sort` with comparator
- interval array handling
- merging in a list then converting result

## Stage 4: Linked List

### Patterns to learn
- dummy node
- fast and slow pointers
- reversal
- merge process

### Must-practice problems
- Reverse Linked List
- Linked List Cycle
- Merge Two Sorted Lists
- Remove Nth Node From End of List
- Reorder List
- Middle of the Linked List
- Add Two Numbers
- Copy List with Random Pointer

### Java focus
- custom `ListNode`
- pointer updates in the right order
- dummy nodes to simplify edge cases

## Stage 5: Stack and Queue

### Patterns to learn
- matching pairs
- monotonic stack
- BFS queue processing

### Must-practice problems
- Valid Parentheses
- Min Stack
- Evaluate Reverse Polish Notation
- Daily Temperatures
- Next Greater Element
- Largest Rectangle in Histogram
- Implement Queue using Stacks
- Implement Stack using Queues

### Java focus
- prefer `Deque` over legacy `Stack`
- `ArrayDeque` for stack or queue behavior

## Stage 6: Binary Search

### Patterns to learn
- exact match
- first or last occurrence
- search insert
- binary search on answer

### Must-practice problems
- Binary Search
- Search Insert Position
- Find First and Last Position of Element in Sorted Array
- Search a 2D Matrix
- Koko Eating Bananas
- Capacity To Ship Packages Within D Days
- Median of Two Sorted Arrays

### Java focus
- safe midpoint: `left + (right - left) / 2`
- identify monotonic condition clearly

## Stage 7: Trees

### Patterns to learn
- DFS recursion
- BFS level order
- postorder aggregation
- BST property usage

### Must-practice problems
- Maximum Depth of Binary Tree
- Same Tree
- Invert Binary Tree
- Binary Tree Level Order Traversal
- Subtree of Another Tree
- Validate Binary Search Tree
- Kth Smallest Element in a BST
- Lowest Common Ancestor of a BST
- Binary Tree Right Side View
- Construct Binary Tree from Preorder and Inorder Traversal
- Diameter of Binary Tree
- Balanced Binary Tree

### Java focus
- recursive helper methods
- `Queue<TreeNode>` for BFS
- when to return value vs mutate shared result

## Stage 8: Heaps / Priority Queue

### Patterns to learn
- top k
- min-heap vs max-heap
- streaming ranking

### Must-practice problems
- Kth Largest Element in an Array
- Top K Frequent Elements
- Find Median from Data Stream
- Merge K Sorted Lists
- Task Scheduler
- Smallest Range Covering Elements from K Lists

### Java focus
- `PriorityQueue` default min-heap
- custom comparator for max-heap behavior

## Stage 9: Backtracking

### Patterns to learn
- choose, recurse, un-choose
- path building
- pruning invalid paths early

### Must-practice problems
- Subsets
- Combination Sum
- Permutations
- Word Search
- Palindrome Partitioning
- Generate Parentheses
- N-Queens
- Letter Combinations of a Phone Number

### Java focus
- `List<List<Integer>>` result patterns
- cloning current path before adding to result
- backtracking by removing last element

## Stage 10: Graphs

### Patterns to learn
- BFS
- DFS
- visited tracking
- topological sort
- Union-Find basics

### Must-practice problems
- Number of Islands
- Clone Graph
- Course Schedule
- Pacific Atlantic Water Flow
- Graph Valid Tree
- Number of Connected Components in an Undirected Graph
- Redundant Connection
- Word Ladder
- Rotting Oranges

### Java focus
- adjacency list with `Map<Integer, List<Integer>>` or `List<List<Integer>>`
- visited set or boolean array
- queue for BFS

## Stage 11: Dynamic Programming

### Patterns to learn
- 1D DP
- 2D DP
- include or exclude decision
- sequence DP
- state transition thinking

### Must-practice problems
- Climbing Stairs
- House Robber
- House Robber II
- Coin Change
- Longest Increasing Subsequence
- Longest Common Subsequence
- Word Break
- Combination Sum IV
- Decode Ways
- Partition Equal Subset Sum
- Unique Paths
- Edit Distance

### Java focus
- define state clearly
- start from recurrence before code
- optimize space only after base solution is correct

## Stage 12: Greedy

### Patterns to learn
- local best choice proof
- sort then choose
- interval scheduling

### Must-practice problems
- Jump Game
- Gas Station
- Partition Labels
- Non-overlapping Intervals
- Hand of Straights

### Java focus
- explain why greedy works
- do not present greedy as a guess

## Stage 13: Advanced Topics for Stronger Rounds

### Topics
- trie
- union-find
- monotonic queue
- segment tree basics
- bit manipulation basics
- graph shortest path

### Must-practice problems
- Implement Trie
- Design Add and Search Words Data Structure
- Accounts Merge
- Network Delay Time
- Cheapest Flights Within K Stops
- Sliding Window Maximum
- Single Number
- Sum of Two Integers

## Blind 75 Style Core Set

If time is limited, prioritize these:
- Two Sum
- Best Time to Buy and Sell Stock
- Contains Duplicate
- Product of Array Except Self
- Maximum Subarray
- 3Sum
- Merge Intervals
- Reverse Linked List
- Linked List Cycle
- Valid Parentheses
- Binary Search
- Search in Rotated Sorted Array
- Maximum Depth of Binary Tree
- Validate BST
- Binary Tree Level Order Traversal
- Kth Largest Element in an Array
- Top K Frequent Elements
- Combination Sum
- Number of Islands
- Course Schedule
- Climbing Stairs
- Coin Change
- Longest Increasing Subsequence
- Word Break
- House Robber

## 8-Week DSA Roadmap

### Week 1
- arrays and strings
- hashing basics
- solve 10 easy plus 5 medium

### Week 2
- two pointers
- sliding window
- solve 8 easy plus 7 medium

### Week 3
- linked list
- stack and queue
- solve 6 easy plus 8 medium

### Week 4
- binary search
- intervals
- solve 5 easy plus 8 medium

### Week 5
- trees part 1
- recursion
- solve 10 tree problems

### Week 6
- heaps
- backtracking
- solve 8 medium plus 2 hard

### Week 7
- graphs
- BFS and DFS
- solve 8 medium plus 2 hard

### Week 8
- dynamic programming
- mixed revision
- mock coding rounds with timer

## How To Explain Solutions Better

### Good coding-round structure
- "The brute-force solution is ..."
- "We can optimize it using ..."
- "The core idea is ..."
- "Time complexity is ... and space complexity is ..."
- "Edge cases are ..."

### What interviewers like
- clear variable names
- edge-case awareness
- not over-complicating easy problems
- pattern recognition
- tradeoff explanation

## Java-Specific Coding Tips

- use `ArrayDeque` for stack or queue interviews
- prefer helper methods for recursion clarity
- avoid unnecessary global state unless it simplifies recursion
- use `Collections.reverseOrder()` carefully with `PriorityQueue`
- mention `equals` and `hashCode` when using objects as map keys
- avoid overusing streams in coding rounds when loops are clearer

## Pair This With

- [Java data structures interview guide](./java-data-structures-interview-guide.md)
- [Java algorithms and interview patterns guide](./java-algorithms-and-patterns-interview-guide.md)
- [Solved coding questions](../interview-prep/java-coding-questions-with-solutions.md)
- [Solved advanced coding patterns](../interview-prep/java-coding-questions-advanced-patterns-with-solutions.md)
- [Coding banks](../coding/README.md)
