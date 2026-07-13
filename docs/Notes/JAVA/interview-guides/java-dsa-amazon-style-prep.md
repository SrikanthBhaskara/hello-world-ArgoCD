# Amazon-Style Java DSA Prep

## What To Expect

Amazon-style coding rounds usually focus on:
- strong medium-level DSA
- optimization after brute-force explanation
- fast pattern recognition
- edge-case handling
- communication while coding

## Typical Difficulty

- easy: low weight
- medium: very common
- hard: possible in strong product/backend rounds

## Most Important Topics

- arrays and strings
- hashing
- sliding window
- binary search
- stack and monotonic stack
- heap and top-k
- linked list
- trees and BST
- graphs and BFS/DFS
- dynamic programming

## High-Priority Problems

### Must know first
- Two Sum
- Product of Array Except Self
- Longest Substring Without Repeating Characters
- Valid Parentheses
- Merge Intervals
- Kth Largest Element in an Array
- Top K Frequent Elements
- Reverse Linked List
- Linked List Cycle
- Binary Tree Level Order Traversal
- Validate BST
- Number of Islands
- Course Schedule
- Coin Change
- Word Break

### Follow-up heavy problems
- LRU Cache
- Sliding Window Maximum
- Lowest Common Ancestor
- Search in Rotated Sorted Array
- Merge K Sorted Lists
- Serialize and Deserialize Binary Tree
- Longest Increasing Subsequence

## What Amazon-Style Follow-Ups Usually Sound Like

- can you optimize space?
- what if input is very large?
- what if data comes as a stream?
- can you avoid sorting the whole array?
- what if duplicates are allowed?
- what if order must be preserved?

## Java Focus Areas

- `HashMap`, `HashSet`, `PriorityQueue`, `ArrayDeque`
- clean helper methods
- not overusing streams in coding rounds
- correct complexity discussion
- safe null and boundary handling

## Interview Strategy

1. state brute-force clearly
2. move to optimized approach quickly
3. explain why the chosen structure fits
4. code cleanly with small methods if needed
5. test with normal, edge, and corner cases

## Common Mistakes

- jumping into code too early
- ignoring duplicate or empty input cases
- using the wrong structure when top-k or ordering matters
- writing code that works only for the sample input

## Best Practice Plan

- solve 20 easy for speed
- solve 40 medium for pattern strength
- solve 10 to 15 hard or follow-up problems for confidence
- practice timed 35 to 45 minute rounds in Java

## Strong Interview Lines

- "The brute-force solution is `O(n^2)`, but hashing reduces it to `O(n)`."
- "Because we only need the top k, a heap is a better fit than sorting everything."
- "This is a contiguous-window problem, so sliding window gives a cleaner linear solution."
