# Java Algorithms and Interview Patterns Guide

## Purpose

This file is for coding-round pattern recognition and algorithm revision in Java.

Use it for:
- identifying patterns quickly
- improving brute-force solutions
- explaining optimized approaches clearly

## Interview Flow

1. clarify input and output
2. state brute-force idea
3. identify the pattern
4. present optimized solution
5. mention complexity and edge cases

## Two Pointers
- Use for sorted arrays, palindrome checks, pair matching
- Common problems: two sum sorted, valid palindrome, container with most water

## Sliding Window
- Use for contiguous substring or subarray problems
- Common problems: longest substring without repeating characters, minimum window substring, max sum window

## Fast and Slow Pointers
- Use for cycle detection or middle-of-list problems
- Common problems: linked list cycle, middle of linked list

## Prefix Sum
- Use when repeated range sum or subarray sum checks matter
- Common problems: subarray sum equals k, range sum query

## Binary Search
- Use for sorted input or monotonic condition
- Common problems: binary search, search insert, first or last occurrence, binary search on answer

## Sorting Plus Scan
- Use for intervals and ordering problems
- Common problems: merge intervals, meeting rooms, non-overlapping intervals

## Hashing
- Use for fast lookup, frequency, complements, deduplication
- Common problems: two sum, anagram grouping, longest consecutive sequence

## Stack Pattern
- Use for matching pairs and next greater or smaller style problems
- Common problems: valid parentheses, daily temperatures, largest rectangle in histogram

## Queue and BFS
- Use for level order, shortest path in unweighted graph, multi-source spread
- Common problems: binary tree level order traversal, rotten oranges, shortest path in grid

## DFS and Backtracking
- Use for tree traversal, combinations, permutations, path exploration
- Common problems: subsets, permutations, combination sum, word search, N-Queens

## Dynamic Programming
- Use for overlapping subproblems and optimal substructure
- Common problems: climbing stairs, house robber, coin change, LIS, LCS, word break

## Greedy
- Use when a local optimal choice can be justified globally
- Common problems: jump game, gas station, interval scheduling

## Heap / Top-K
- Use when you repeatedly need best k or current min/max candidate
- Common problems: kth largest, top k frequent, merge k sorted lists, median stream

## Tree Patterns
- DFS recursion
- BFS level order
- postorder aggregation
- inorder for BST behavior
- Common problems: max depth, validate BST, LCA, diameter

## Graph Patterns
- BFS
- DFS
- topological sort
- shortest path
- Union-Find
- Common problems: number of islands, course schedule, clone graph

## Monotonic Stack / Queue
- Use when nearest greater or smaller elements matter
- Common problems: daily temperatures, stock span, sliding window maximum

## Pattern Recognition Hints
- sorted input often suggests binary search or two pointers
- substring or subarray often suggests sliding window or prefix sum
- top-k suggests heap
- all combinations suggests backtracking
- shortest path in unweighted graph suggests BFS
- repeated recursive states suggest DP

## Practice Order
1. arrays and strings
2. hashing and sliding window
3. linked list, stack, queue
4. binary search and intervals
5. trees and recursion
6. heaps and backtracking
7. graphs and BFS/DFS
8. dynamic programming

## Interviewer-Friendly Lines
- "The brute-force solution is `O(n^2)`, but hashing reduces it to `O(n)`."
- "Because the input is sorted, two pointers is cleaner than nested loops."
- "This is a contiguous window problem, so sliding window fits naturally."
- "The repeated subproblems suggest dynamic programming."
- "We only need the top k, so a heap is better than sorting the full input every time."
