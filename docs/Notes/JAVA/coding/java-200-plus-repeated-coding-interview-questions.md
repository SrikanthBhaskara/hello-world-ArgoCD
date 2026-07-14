# Java 200+ Repeated Coding Interview Questions Bank

## Purpose

This file is a large Java coding question bank covering more than 200 repeated interview problems.

Use it for:
- company-style coding preparation
- DSA topic-wise revision
- repeated interview question tracking
- selecting high-frequency problems instead of solving random problems

This file focuses on:
- repeated and high-frequency interview questions
- Java-friendly pattern grouping
- problem names you should know by heart
- quick pattern direction for each question

For full code and worked solutions, pair this file with:
- [Most repeated coding questions with solutions](../interview-prep/java-most-repeated-coding-questions-with-solutions.md)
- [Solved coding questions](../interview-prep/java-coding-questions-with-solutions.md)
- [Solved advanced coding patterns](../interview-prep/java-coding-questions-advanced-patterns-with-solutions.md)
- [DSA Blind 75 / Top 100 roadmap](../interview-guides/java-dsa-blind-75-top-100-roadmap.md)
- [Java algorithms and interview patterns guide](../interview-guides/java-algorithms-and-patterns-interview-guide.md)

## How To Use This Bank

1. First solve the repeated medium problems from arrays, strings, hashing, sliding window, binary search, and trees.
2. Then move to graph, heap, backtracking, and dynamic programming questions.
3. Mark each problem as:
- `Not Started`
- `Tried`
- `Solved`
- `Can Explain`
4. A problem is truly done only when you can explain brute-force, optimized approach, and time-space complexity.

## 1. Arrays and Strings (1-40)

1. Two Sum - pattern: hashing
2. Best Time to Buy and Sell Stock - pattern: running minimum
3. Contains Duplicate - pattern: set
4. Product of Array Except Self - pattern: prefix and suffix product
5. Maximum Subarray - pattern: Kadane's algorithm
6. Maximum Product Subarray - pattern: tracking min and max
7. Find Minimum in Rotated Sorted Array - pattern: binary search
8. Search in Rotated Sorted Array - pattern: binary search
9. 3Sum - pattern: sorting plus two pointers
10. Container With Most Water - pattern: two pointers
11. Move Zeroes - pattern: two pointers
12. Merge Sorted Array - pattern: reverse fill
13. Remove Duplicates from Sorted Array - pattern: slow and fast pointers
14. Remove Element - pattern: write pointer
15. Squares of a Sorted Array - pattern: two pointers
16. Sort Colors - pattern: Dutch national flag
17. Missing Number - pattern: cyclic math or XOR
18. Single Number - pattern: XOR
19. Majority Element - pattern: Boyer-Moore voting
20. Rotate Array - pattern: reverse parts
21. Plus One - pattern: carry handling
22. Find Pivot Index - pattern: prefix sum
23. Running Sum of 1D Array - pattern: prefix sum
24. Subarray Sum Equals K - pattern: prefix sum plus map
25. Continuous Subarray Sum - pattern: prefix remainder map
26. Maximum Average Subarray I - pattern: fixed sliding window
27. Find All Numbers Disappeared in an Array - pattern: marking or cyclic placement
28. Find Duplicate Number - pattern: Floyd cycle or binary search on value range
29. Trapping Rain Water - pattern: two pointers or prefix max
30. Candy - pattern: greedy two-pass
31. Gas Station - pattern: greedy
32. Jump Game - pattern: greedy reachability
33. Jump Game II - pattern: greedy layer expansion
34. First Missing Positive - pattern: index placement
35. Set Matrix Zeroes - pattern: in-place markers
36. Spiral Matrix - pattern: boundary traversal
37. Rotate Image - pattern: transpose plus reverse
38. Valid Sudoku - pattern: hashing
39. Group Anagrams - pattern: frequency signature
40. Longest Consecutive Sequence - pattern: set sequence start

## 2. Sliding Window and Two Pointers (41-65)

41. Longest Substring Without Repeating Characters - pattern: sliding window
42. Longest Repeating Character Replacement - pattern: sliding window
43. Minimum Window Substring - pattern: sliding window with counts
44. Permutation in String - pattern: fixed window comparison
45. Find All Anagrams in a String - pattern: fixed window counts
46. Minimum Size Subarray Sum - pattern: shrinking window
47. Fruit Into Baskets - pattern: at most two distinct
48. Subarrays with K Different Integers - pattern: at most K trick
49. Longest Mountain in Array - pattern: expansion
50. Backspace String Compare - pattern: reverse two pointers
51. Valid Palindrome - pattern: two pointers
52. Valid Palindrome II - pattern: two pointers with one deletion
53. Is Subsequence - pattern: two pointers
54. Reverse String - pattern: two pointers
55. Reverse Words in a String - pattern: split or reverse scan
56. Reverse Vowels of a String - pattern: two pointers
57. Long Pressed Name - pattern: two pointers
58. Interval List Intersections - pattern: two pointers
59. Merge Strings Alternately - pattern: two pointers
60. Compare Version Numbers - pattern: token comparison
61. Merge Alternately From Two Arrays - pattern: two pointers
62. Append Characters to String to Make Subsequence - pattern: subsequence pointer
63. Number of Substrings Containing All Three Characters - pattern: sliding window
64. Maximum Number of Vowels in a Substring of Given Length - pattern: fixed window
65. Longest Nice Subarray - pattern: bitwise sliding window

## 3. Hashing, Maps, and Sets (66-85)

66. Two Sum II variation with map
67. Intersection of Two Arrays - pattern: set
68. Intersection of Two Arrays II - pattern: map counts
69. Ransom Note - pattern: character counting
70. Isomorphic Strings - pattern: bidirectional mapping
71. Word Pattern - pattern: map consistency
72. Happy Number - pattern: set cycle detection
73. Contains Nearby Duplicate - pattern: index map
74. Logger Rate Limiter - pattern: map time tracking
75. Top K Frequent Elements - pattern: map plus heap or bucket
76. Sort Characters by Frequency - pattern: map plus bucket
77. Unique Number of Occurrences - pattern: map plus set
78. Find the Difference - pattern: counting or XOR
79. Valid Anagram - pattern: counting
80. First Unique Character in a String - pattern: frequency counting
81. Subdomain Visit Count - pattern: map aggregation
82. Roman to Integer - pattern: scanning rules
83. Integer to Roman - pattern: greedy map
84. Design HashMap - pattern: bucket design
85. Design HashSet - pattern: bucket design

## 4. Stack, Monotonic Stack, and Queue (86-105)

86. Valid Parentheses - pattern: stack
87. Min Stack - pattern: stack with min tracking
88. Evaluate Reverse Polish Notation - pattern: stack
89. Daily Temperatures - pattern: monotonic stack
90. Next Greater Element I - pattern: monotonic stack
91. Next Greater Element II - pattern: circular monotonic stack
92. Largest Rectangle in Histogram - pattern: monotonic stack
93. Basic Calculator - pattern: stack and sign handling
94. Decode String - pattern: stack
95. Remove All Adjacent Duplicates in String - pattern: stack simulation
96. Asteroid Collision - pattern: stack
97. Online Stock Span - pattern: monotonic stack
98. Implement Queue using Stacks - pattern: two stacks
99. Implement Stack using Queues - pattern: queue rotation
100. Sliding Window Maximum - pattern: monotonic deque
101. Simplify Path - pattern: stack
102. Score of Parentheses - pattern: stack or depth math
103. Remove K Digits - pattern: monotonic stack
104. Next Smaller Element variation - pattern: monotonic stack
105. Trapping Rain Water via stack - pattern: stack

## 5. Linked List (106-125)

106. Reverse Linked List - pattern: iterative reversal
107. Linked List Cycle - pattern: fast and slow pointers
108. Linked List Cycle II - pattern: cycle entry detection
109. Merge Two Sorted Lists - pattern: merge pointers
110. Remove Nth Node From End of List - pattern: two pointers
111. Reorder List - pattern: split, reverse, merge
112. Middle of the Linked List - pattern: fast and slow
113. Palindrome Linked List - pattern: reverse half
114. Intersection of Two Linked Lists - pattern: pointer switching
115. Add Two Numbers - pattern: carry simulation
116. Swap Nodes in Pairs - pattern: pointer rewiring
117. Reverse Nodes in K-Group - pattern: segment reversal
118. Odd Even Linked List - pattern: partition pointers
119. Sort List - pattern: merge sort on list
120. Copy List with Random Pointer - pattern: map or interleave copy
121. Partition List - pattern: two dummy lists
122. Remove Duplicates from Sorted List - pattern: simple traversal
123. Remove Duplicates from Sorted List II - pattern: skip duplicates
124. Rotate List - pattern: length plus cycle
125. Flatten a Multilevel Doubly Linked List - pattern: DFS or stack

## 6. Binary Search (126-145)

126. Binary Search - pattern: classic
127. Search Insert Position - pattern: classic binary search
128. Find First and Last Position of Element in Sorted Array - pattern: boundary search
129. Search a 2D Matrix - pattern: flattened binary search
130. Search a 2D Matrix II - pattern: top-right walk
131. Guess Number Higher or Lower - pattern: binary search
132. First Bad Version - pattern: binary search on answer
133. Peak Index in a Mountain Array - pattern: binary search
134. Find Peak Element - pattern: slope binary search
135. Sqrt(x) - pattern: binary search on answer
136. Koko Eating Bananas - pattern: binary search on speed
137. Capacity To Ship Packages Within D Days - pattern: binary search on capacity
138. Split Array Largest Sum - pattern: binary search on answer
139. Minimize Max Distance to Gas Station style - pattern: answer search
140. Median of Two Sorted Arrays - pattern: partition binary search
141. Search in Rotated Sorted Array II - pattern: binary search with duplicates
142. Find Minimum in Rotated Sorted Array II - pattern: duplicate handling
143. Time Based Key-Value Store - pattern: map plus binary search
144. Find Right Interval - pattern: sort plus binary search
145. Arrange Coins - pattern: binary search math

## 7. Intervals and Greedy (146-165)

146. Merge Intervals - pattern: sort and merge
147. Insert Interval - pattern: merge with insertion
148. Non-overlapping Intervals - pattern: greedy keep earliest end
149. Meeting Rooms - pattern: overlap detection
150. Meeting Rooms II - pattern: heap of end times
151. Minimum Number of Arrows to Burst Balloons - pattern: greedy intervals
152. Can Attend Meetings variation - pattern: sorted intervals
153. Employee Free Time - pattern: merge intervals
154. Queue Reconstruction by Height - pattern: greedy sort and insert
155. Task Scheduler - pattern: greedy counting
156. Reorganize String - pattern: heap plus greedy
157. Partition Labels - pattern: greedy last occurrence
158. Lemonade Change - pattern: greedy cash tracking
159. Hand of Straights - pattern: ordered map greedy
160. Boats to Save People - pattern: sorted two pointers greedy
161. Candy - pattern: greedy two-pass
162. Jump Game - pattern: greedy reachability
163. Jump Game II - pattern: greedy range expansion
164. Gas Station - pattern: greedy restart
165. Wiggle Subsequence - pattern: greedy sign tracking

## 8. Trees and BST (166-195)

166. Maximum Depth of Binary Tree - pattern: DFS
167. Same Tree - pattern: recursion
168. Invert Binary Tree - pattern: recursion
169. Binary Tree Level Order Traversal - pattern: BFS
170. Binary Tree Right Side View - pattern: BFS
171. Balanced Binary Tree - pattern: height with validation
172. Diameter of Binary Tree - pattern: postorder aggregation
173. Subtree of Another Tree - pattern: recursion
174. Validate Binary Search Tree - pattern: bounds check
175. Kth Smallest Element in a BST - pattern: inorder traversal
176. Lowest Common Ancestor of a BST - pattern: BST property
177. Lowest Common Ancestor of a Binary Tree - pattern: recursion
178. Construct Binary Tree from Preorder and Inorder Traversal - pattern: recursion with index map
179. Serialize and Deserialize Binary Tree - pattern: BFS or DFS serialization
180. Path Sum - pattern: DFS
181. Path Sum II - pattern: DFS with path
182. Binary Tree Maximum Path Sum - pattern: postorder choice
183. Count Good Nodes in Binary Tree - pattern: DFS max-so-far
184. House Robber III - pattern: tree DP
185. Sum Root to Leaf Numbers - pattern: path accumulation
186. Populating Next Right Pointers in Each Node - pattern: BFS
187. Convert Sorted Array to BST - pattern: divide and conquer
188. Convert BST to Greater Tree - pattern: reverse inorder
189. Delete Node in a BST - pattern: BST deletion
190. Closest Binary Search Tree Value - pattern: BST traversal
191. Minimum Absolute Difference in BST - pattern: inorder
192. Recover Binary Search Tree - pattern: inorder anomaly detection
193. Symmetric Tree - pattern: mirrored recursion
194. Zigzag Level Order Traversal - pattern: BFS
195. Vertical Order Traversal - pattern: BFS plus column map

## 9. Heaps, Priority Queue, and Top-K (196-210)

196. Kth Largest Element in an Array - pattern: min-heap
197. Top K Frequent Elements - pattern: heap or bucket
198. Find Median from Data Stream - pattern: two heaps
199. Merge K Sorted Lists - pattern: heap
200. K Closest Points to Origin - pattern: heap
201. Last Stone Weight - pattern: max-heap
202. Reorganize String - pattern: max-heap
203. Furthest Building You Can Reach - pattern: heap resource allocation
204. Smallest Range Covering Elements from K Lists - pattern: heap
205. IPO - pattern: two heaps
206. Sort Nearly Sorted Array - pattern: heap
207. Sliding Window Median - pattern: dual heaps
208. Kth Smallest Element in a Sorted Matrix - pattern: heap or binary search
209. Connect Sticks - pattern: min-heap greedy
210. Task Scheduler variant - pattern: heap plus cooldown

## 10. Backtracking and Recursion (211-225)

211. Subsets - pattern: backtracking
212. Subsets II - pattern: backtracking with duplicate skip
213. Permutations - pattern: backtracking
214. Permutations II - pattern: backtracking with used tracking
215. Combination Sum - pattern: backtracking
216. Combination Sum II - pattern: backtracking with duplicate skip
217. Combination Sum III - pattern: constrained backtracking
218. Letter Combinations of a Phone Number - pattern: backtracking
219. Palindrome Partitioning - pattern: backtracking
220. Word Search - pattern: DFS backtracking
221. Generate Parentheses - pattern: constrained backtracking
222. N-Queens - pattern: backtracking with state sets
223. Restore IP Addresses - pattern: partition backtracking
224. Sudoku Solver - pattern: constraint backtracking
225. Expression Add Operators - pattern: backtracking expression building

## 11. Graphs, BFS, DFS, and Union-Find (226-245)

226. Number of Islands - pattern: DFS or BFS
227. Max Area of Island - pattern: DFS
228. Clone Graph - pattern: DFS or BFS with map
229. Course Schedule - pattern: topological sort
230. Course Schedule II - pattern: topological ordering
231. Pacific Atlantic Water Flow - pattern: reverse reachability DFS/BFS
232. Graph Valid Tree - pattern: union-find or DFS
233. Number of Connected Components in an Undirected Graph - pattern: union-find
234. Redundant Connection - pattern: union-find
235. Rotting Oranges - pattern: multi-source BFS
236. Walls and Gates - pattern: multi-source BFS
237. Word Ladder - pattern: BFS shortest path
238. Open the Lock - pattern: BFS state search
239. Minimum Knight Moves style - pattern: BFS
240. Reconstruct Itinerary - pattern: Eulerian path DFS
241. Accounts Merge - pattern: union-find or graph
242. Network Delay Time - pattern: Dijkstra
243. Cheapest Flights Within K Stops - pattern: BFS or Bellman-Ford style
244. Alien Dictionary - pattern: graph topological sort
245. Evaluate Division - pattern: weighted graph traversal

## 12. Dynamic Programming (246-275)

246. Climbing Stairs - pattern: 1D DP
247. Min Cost Climbing Stairs - pattern: 1D DP
248. House Robber - pattern: DP
249. House Robber II - pattern: circular DP
250. Coin Change - pattern: unbounded DP
251. Coin Change II - pattern: combinations DP
252. Longest Increasing Subsequence - pattern: DP or patience sorting
253. Longest Common Subsequence - pattern: 2D DP
254. Edit Distance - pattern: 2D DP
255. Word Break - pattern: DP
256. Decode Ways - pattern: DP
257. Unique Paths - pattern: grid DP
258. Unique Paths II - pattern: obstacle DP
259. Minimum Path Sum - pattern: grid DP
260. Partition Equal Subset Sum - pattern: knapsack DP
261. Target Sum - pattern: subset transformation DP
262. Combination Sum IV - pattern: ordered combination DP
263. Palindromic Substrings - pattern: DP expand check
264. Longest Palindromic Substring - pattern: expand or DP
265. Best Time to Buy and Sell Stock with Cooldown - pattern: state DP
266. Best Time to Buy and Sell Stock with Transaction Fee - pattern: state DP
267. Interleaving String - pattern: 2D DP
268. Distinct Subsequences - pattern: 2D DP
269. Burst Balloons - pattern: interval DP
270. Maximum Length of Repeated Subarray - pattern: DP
271. Longest Valid Parentheses - pattern: DP or stack
272. Delete and Earn - pattern: transformed DP
273. Perfect Squares - pattern: DP
274. Can Partition K Subsets - pattern: backtracking plus memo
275. Scramble String style advanced DP - pattern: recursive memo

## 13. Advanced Mixed and Design-Flavored Coding (276-300)

276. LRU Cache - pattern: hashmap plus doubly linked list
277. LFU Cache - pattern: frequency plus linked structure
278. Insert Delete GetRandom O(1) - pattern: map plus list
279. Random Pick with Weight - pattern: prefix sum plus binary search
280. Time Based Key-Value Store - pattern: map plus binary search
281. Design Twitter - pattern: heap plus linked stream
282. Design Circular Queue - pattern: array design
283. Design Browser History - pattern: doubly linked list or stacks
284. Design Underground System - pattern: map state tracking
285. Snapshot Array - pattern: versioned binary search
286. Logger Rate Limiter - pattern: map and timestamp
287. My Calendar I - pattern: ordered interval check
288. My Calendar II - pattern: overlap counting
289. TinyURL Encoder and Decoder - pattern: hashmap design
290. Basic Calculator II - pattern: stack parsing
291. Evaluate Division - pattern: graph design
292. All O`one Data Structure - pattern: complex O(1) design
293. Design File System - pattern: trie or map hierarchy
294. Design Add and Search Words Data Structure - pattern: trie with wildcard DFS
295. Stream of Characters - pattern: reversed trie or automaton thinking
296. Autocomplete System - pattern: trie plus ranking
297. Search Suggestions System - pattern: sorting or trie
298. Design Hit Counter - pattern: queue or circular buckets
299. Design Authentication Manager - pattern: TTL map
300. Rate Limiter Machine Coding variant - pattern: concurrent state and policy

## 14. Most Repeated Must-Solve 50

If you want the highest-signal repeated questions first, prioritize these 50:
- Two Sum
- Best Time to Buy and Sell Stock
- Contains Duplicate
- Product of Array Except Self
- Maximum Subarray
- 3Sum
- Container With Most Water
- Longest Substring Without Repeating Characters
- Longest Repeating Character Replacement
- Minimum Window Substring
- Valid Parentheses
- Daily Temperatures
- Reverse Linked List
- Linked List Cycle
- Merge Two Sorted Lists
- Remove Nth Node From End of List
- Binary Search
- Search in Rotated Sorted Array
- Find Minimum in Rotated Sorted Array
- Merge Intervals
- Meeting Rooms II
- Maximum Depth of Binary Tree
- Binary Tree Level Order Traversal
- Validate BST
- Lowest Common Ancestor of a Binary Tree
- Diameter of Binary Tree
- Kth Smallest Element in a BST
- Number of Islands
- Course Schedule
- Clone Graph
- Rotting Oranges
- Kth Largest Element in an Array
- Top K Frequent Elements
- Find Median from Data Stream
- Merge K Sorted Lists
- Subsets
- Permutations
- Combination Sum
- Word Search
- Generate Parentheses
- Climbing Stairs
- House Robber
- Coin Change
- Longest Increasing Subsequence
- Longest Common Subsequence
- Word Break
- LRU Cache
- Insert Delete GetRandom O(1)
- Time Based Key-Value Store
- Design Twitter

## 15. Best Practice Order

### First 30
Do arrays, strings, hashing, sliding window, binary search.

### Next 40
Do linked list, stack, queue, intervals, trees.

### Next 40
Do heap, graph basics, BFS, DFS, backtracking.

### Next 40
Do dynamic programming and advanced tree or graph problems.

### Final set
Do design-flavored coding and cache-style questions.

## 16. Interview Usage Tip

If you want maximum value from this bank, do not only mark a problem as solved.

Also check whether you can:
- identify the pattern in 30 seconds
- explain brute-force first
- explain optimized approach
- write Java cleanly without syntax struggle
- state complexity without guessing

## 17. Pair This With

- [Java coding interview problems](./java-coding-interview-problems.md)
- [Java advanced coding problems](./java-advanced-coding-problems.md)
- [Most repeated coding questions with solutions](../interview-prep/java-most-repeated-coding-questions-with-solutions.md)
- [Solved coding questions](../interview-prep/java-coding-questions-with-solutions.md)
- [Solved advanced coding patterns](../interview-prep/java-coding-questions-advanced-patterns-with-solutions.md)
- [Java DSA Blind 75 / Top 100 roadmap](../interview-guides/java-dsa-blind-75-top-100-roadmap.md)

