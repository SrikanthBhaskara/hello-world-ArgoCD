# Java Data Structures Interview Guide

## Purpose

This file helps you revise the most important data structures for Java interviews.

Use it for:
- quick DSA revision
- choosing the right structure in coding rounds
- explaining tradeoffs to the interviewer

## Core Rule

When choosing a data structure, first ask:
- do I need fast lookup?
- do I need ordering?
- do I need top-k retrieval?
- do I need FIFO or LIFO behavior?
- do I need hierarchical or graph traversal?

## Arrays
- Best for indexed access
- Access: `O(1)`
- Insert or delete in middle: `O(n)`
- Common use: traversal, prefix sum, two pointers

## Strings
- Immutable in Java
- Use `StringBuilder` for repeated modification
- Common use: sliding window, frequency counting, palindrome, parsing

## ArrayList
- Dynamic array
- Index access: `O(1)`
- Append: amortized `O(1)`
- Middle insertion or deletion: `O(n)`
- Best when random access matters

## Linked List
- Node-based sequential structure
- Insert or delete after node reference: `O(1)`
- Search or index access: `O(n)`
- Common interview use: reverse, cycle, merge, middle node

## Stack
- LIFO structure
- Use `Deque` / `ArrayDeque` in Java
- Push, pop, peek: `O(1)`
- Common use: valid parentheses, monotonic stack, DFS

## Queue
- FIFO structure
- Use `Queue` or `Deque`
- Offer, poll, peek: usually `O(1)`
- Common use: BFS, scheduling, level order traversal

## Deque
- Double-ended queue
- Useful as both stack and queue
- Common use: sliding window maximum, monotonic queue

## HashMap
- Key-value lookup using hashing
- Average put/get/remove: `O(1)`
- Common use: counting, complement lookup, caching, grouping
- Interview note: mention `equals()` and `hashCode()`

## HashSet
- Unique elements with fast membership check
- Average add/contains/remove: `O(1)`
- Common use: duplicate detection, visited set

## TreeMap and TreeSet
- Sorted structures
- Operations: `O(log n)`
- Common use: sorted keys, floor/ceiling, range behavior

## PriorityQueue / Heap
- Min-heap by default in Java
- Insert and remove top: `O(log n)`
- Peek: `O(1)`
- Common use: top-k, kth largest, scheduling, merge k lists

## Binary Tree
- Hierarchical structure
- Common use: DFS, BFS, recursion, divide and conquer
- Common questions: depth, diameter, level order, LCA

## Binary Search Tree
- Ordered binary tree
- Average search: `O(log n)`
- Worst if unbalanced: `O(n)`
- Common questions: validate BST, kth smallest, iterator

## Trie
- Prefix tree
- Common use: autocomplete, prefix search, word dictionary
- Tradeoff: faster prefix logic but higher memory use

## Graph
- Nodes plus edges
- Common representation: adjacency list
- Common use: BFS, DFS, topological sort, shortest path

## Union-Find
- Tracks connected components efficiently
- Common use: connectivity, cycle detection, Kruskal-style problems

## Monotonic Stack / Queue
- Keep elements in increasing or decreasing order
- Common use: next greater element, daily temperatures, sliding window maximum

## Quick Choice Guide
- Fast lookup: `HashMap` / `HashSet`
- Sorted keys: `TreeMap` / `TreeSet`
- Top-k: `PriorityQueue`
- LIFO: `Deque`
- FIFO: `Queue`
- Prefix matching: trie
- Tree traversal: binary tree
- Relationship modeling: graph

## Interviewer-Friendly Lines
- "If lookup dominates, I think hash-based structures first."
- "If sorted order matters, tree-based structures are usually a better fit."
- "If I only need the current smallest or largest candidate repeatedly, a heap is better than sorting everything."
