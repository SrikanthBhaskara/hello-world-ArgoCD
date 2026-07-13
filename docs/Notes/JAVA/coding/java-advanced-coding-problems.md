# JAVA CODING PROBLEMS - ADVANCED SET (Problems 21-30)

**10 additional advanced coding problems for senior developers (4-5 years experience). These complement the first 20 problems to give you 30 total interview problems.**

---

# TABLE OF CONTENTS

1. [Advanced Data Structures (Problems 21-23)](#1-advanced-data-structures)
2. [Graph & Tree Problems (Problems 24-26)](#2-graph--tree-problems)
3. [Dynamic Programming (Problems 27-28)](#3-dynamic-programming)
4. [System Design Coding (Problems 29-30)](#4-system-design-coding)

---

# 1. ADVANCED DATA STRUCTURES

## Problem 21: Implement Trie (Prefix Tree)

**Difficulty:** Medium  
**Companies:** Amazon, Google, Microsoft

**Problem:** Implement a trie with insert, search, and startsWith methods.

```java
/**
 * Trie for efficient string operations
 * Use cases: Autocomplete, spell checker, IP routing
 */
public class Trie {
    
    private class TrieNode {
        Map<Character, TrieNode> children;
        boolean isEndOfWord;
        
        TrieNode() {
            children = new HashMap<>();
            isEndOfWord = false;
        }
    }
    
    private final TrieNode root;
    
    public Trie() {
        root = new TrieNode();
    }
    
    // Insert word: O(m) time where m = word length
    public void insert(String word) {
        TrieNode current = root;
        
        for (char c : word.toCharArray()) {
            current.children.putIfAbsent(c, new TrieNode());
            current = current.children.get(c);
        }
        
        current.isEndOfWord = true;
    }
    
    // Search exact word: O(m) time
    public boolean search(String word) {
        TrieNode node = searchPrefix(word);
        return node != null && node.isEndOfWord;
    }
    
    // Check if prefix exists: O(m) time
    public boolean startsWith(String prefix) {
        return searchPrefix(prefix) != null;
    }
    
    private TrieNode searchPrefix(String prefix) {
        TrieNode current = root;
        
        for (char c : prefix.toCharArray()) {
            if (!current.children.containsKey(c)) {
                return null;
            }
            current = current.children.get(c);
        }
        
        return current;
    }
    
    // Delete word
    public boolean delete(String word) {
        return delete(root, word, 0);
    }
    
    private boolean delete(TrieNode current, String word, int index) {
        if (index == word.length()) {
            if (!current.isEndOfWord) {
                return false;  // Word doesn't exist
            }
            current.isEndOfWord = false;
            return current.children.isEmpty();
        }
        
        char c = word.charAt(index);
        TrieNode node = current.children.get(c);
        if (node == null) {
            return false;
        }
        
        boolean shouldDeleteCurrentNode = delete(node, word, index + 1);
        
        if (shouldDeleteCurrentNode) {
            current.children.remove(c);
            return current.children.isEmpty() && !current.isEndOfWord;
        }
        
        return false;
    }
    
    // Find all words with given prefix (autocomplete)
    public List<String> findWordsWithPrefix(String prefix) {
        List<String> results = new ArrayList<>();
        TrieNode node = searchPrefix(prefix);
        
        if (node != null) {
            dfs(node, prefix, results);
        }
        
        return results;
    }
    
    private void dfs(TrieNode node, String prefix, List<String> results) {
        if (node.isEndOfWord) {
            results.add(prefix);
        }
        
        for (Map.Entry<Character, TrieNode> entry : node.children.entrySet()) {
            dfs(entry.getValue(), prefix + entry.getKey(), results);
        }
    }
    
    @Test
    public void testTrie() {
        Trie trie = new Trie();
        trie.insert("apple");
        trie.insert("app");
        trie.insert("apricot");
        
        assertTrue(trie.search("apple"));
        assertFalse(trie.search("app"));  // Not inserted as isEndOfWord
        assertTrue(trie.startsWith("app"));
        
        List<String> words = trie.findWordsWithPrefix("ap");
        assertEquals(3, words.size());
        assertTrue(words.contains("apple"));
        assertTrue(words.contains("app"));
        assertTrue(words.contains("apricot"));
    }
}
```

**Key Points:**
- HashMap for children nodes
- isEndOfWord flag for complete words
- DFS for prefix search (autocomplete)
- O(m) for all operations where m = string length

---

## Problem 22: Design Min Stack

**Difficulty:** Medium  
**Companies:** Amazon, Bloomberg, Microsoft

**Problem:** Design a stack that supports push, pop, top, and retrieving minimum element in O(1) time.

```java
/**
 * Min Stack with O(1) min operation
 */
public class MinStack {
    
    // Approach 1: Two stacks
    private final Stack<Integer> stack;
    private final Stack<Integer> minStack;
    
    public MinStack() {
        stack = new Stack<>();
        minStack = new Stack<>();
    }
    
    public void push(int val) {
        stack.push(val);
        
        if (minStack.isEmpty() || val <= minStack.peek()) {
            minStack.push(val);
        }
    }
    
    public void pop() {
        int val = stack.pop();
        
        if (val == minStack.peek()) {
            minStack.pop();
        }
    }
    
    public int top() {
        return stack.peek();
    }
    
    public int getMin() {
        return minStack.peek();
    }
}

// Approach 2: Single stack with pairs
class MinStackOptimized {
    
    private static class Node {
        int value;
        int min;
        
        Node(int value, int min) {
            this.value = value;
            this.min = min;
        }
    }
    
    private final Stack<Node> stack;
    
    public MinStackOptimized() {
        stack = new Stack<>();
    }
    
    public void push(int val) {
        if (stack.isEmpty()) {
            stack.push(new Node(val, val));
        } else {
            int currentMin = Math.min(val, stack.peek().min);
            stack.push(new Node(val, currentMin));
        }
    }
    
    public void pop() {
        stack.pop();
    }
    
    public int top() {
        return stack.peek().value;
    }
    
    public int getMin() {
        return stack.peek().min;
    }
    
    @Test
    public void testMinStack() {
        MinStack minStack = new MinStack();
        minStack.push(-2);
        minStack.push(0);
        minStack.push(-3);
        
        assertEquals(-3, minStack.getMin());
        minStack.pop();
        assertEquals(0, minStack.top());
        assertEquals(-2, minStack.getMin());
    }
}
```

**Key Points:**
- Two stacks: main + min tracking
- Or single stack with (value, min) pairs
- All operations O(1)
- Handle duplicates correctly

---

## Problem 23: Implement LFU Cache

**Difficulty:** Hard  
**Companies:** Amazon, Google, Facebook

**Problem:** Design Least Frequently Used (LFU) cache with O(1) get and put.

```java
/**
 * LFU Cache - Evict least frequently used item
 * If tie, evict least recently used
 */
public class LFUCache {
    
    private class Node {
        int key, value, frequency;
        Node prev, next;
        
        Node(int key, int value) {
            this.key = key;
            this.value = value;
            this.frequency = 1;
        }
    }
    
    private class DoublyLinkedList {
        Node head, tail;
        int size;
        
        DoublyLinkedList() {
            head = new Node(0, 0);
            tail = new Node(0, 0);
            head.next = tail;
            tail.prev = head;
            size = 0;
        }
        
        void addToHead(Node node) {
            node.next = head.next;
            node.prev = head;
            head.next.prev = node;
            head.next = node;
            size++;
        }
        
        void remove(Node node) {
            node.prev.next = node.next;
            node.next.prev = node.prev;
            size--;
        }
        
        Node removeTail() {
            if (size == 0) return null;
            Node node = tail.prev;
            remove(node);
            return node;
        }
    }
    
    private final int capacity;
    private int minFrequency;
    private final Map<Integer, Node> cache;  // key -> node
    private final Map<Integer, DoublyLinkedList> frequencyMap;  // frequency -> list
    
    public LFUCache(int capacity) {
        this.capacity = capacity;
        this.minFrequency = 0;
        this.cache = new HashMap<>();
        this.frequencyMap = new HashMap<>();
    }
    
    public int get(int key) {
        if (!cache.containsKey(key)) {
            return -1;
        }
        
        Node node = cache.get(key);
        updateFrequency(node);
        return node.value;
    }
    
    public void put(int key, int value) {
        if (capacity == 0) return;
        
        if (cache.containsKey(key)) {
            Node node = cache.get(key);
            node.value = value;
            updateFrequency(node);
        } else {
            if (cache.size() >= capacity) {
                // Evict LFU (or LRU if tie)
                DoublyLinkedList minFreqList = frequencyMap.get(minFrequency);
                Node nodeToRemove = minFreqList.removeTail();
                cache.remove(nodeToRemove.key);
            }
            
            Node newNode = new Node(key, value);
            cache.put(key, newNode);
            minFrequency = 1;
            
            frequencyMap.putIfAbsent(1, new DoublyLinkedList());
            frequencyMap.get(1).addToHead(newNode);
        }
    }
    
    private void updateFrequency(Node node) {
        int oldFreq = node.frequency;
        DoublyLinkedList oldList = frequencyMap.get(oldFreq);
        oldList.remove(node);
        
        if (oldFreq == minFrequency && oldList.size == 0) {
            minFrequency++;
        }
        
        node.frequency++;
        frequencyMap.putIfAbsent(node.frequency, new DoublyLinkedList());
        frequencyMap.get(node.frequency).addToHead(node);
    }
    
    @Test
    public void testLFUCache() {
        LFUCache cache = new LFUCache(2);
        cache.put(1, 1);
        cache.put(2, 2);
        assertEquals(1, cache.get(1));  // freq: 1->2, 2->1
        cache.put(3, 3);                 // Evicts key 2
        assertEquals(-1, cache.get(2));
        assertEquals(3, cache.get(3));
    }
}
```

**Key Points:**
- HashMap + DoublyLinkedList per frequency
- Track minimum frequency
- O(1) for all operations
- Complex but frequently asked

---

# 2. GRAPH & TREE PROBLEMS

## Problem 24: Word Ladder

**Difficulty:** Hard  
**Companies:** Amazon, Google, Facebook, LinkedIn

**Problem:** Transform beginWord to endWord by changing one letter at a time. Each intermediate word must exist in dictionary.

```java
/**
 * Input: beginWord = "hit", endWord = "cog"
 *        wordList = ["hot","dot","dog","lot","log","cog"]
 * Output: 5 ("hit" -> "hot" -> "dot" -> "dog" -> "cog")
 */
public class WordLadder {
    
    // BFS approach: O(M² × N) time where M = word length, N = words count
    public int ladderLength(String beginWord, String endWord, List<String> wordList) {
        Set<String> wordSet = new HashSet<>(wordList);
        if (!wordSet.contains(endWord)) {
            return 0;
        }
        
        Queue<String> queue = new LinkedList<>();
        queue.offer(beginWord);
        
        int level = 1;
        
        while (!queue.isEmpty()) {
            int size = queue.size();
            
            for (int i = 0; i < size; i++) {
                String currentWord = queue.poll();
                
                if (currentWord.equals(endWord)) {
                    return level;
                }
                
                // Try all possible transformations
                char[] chars = currentWord.toCharArray();
                for (int j = 0; j < chars.length; j++) {
                    char originalChar = chars[j];
                    
                    for (char c = 'a'; c <= 'z'; c++) {
                        if (c == originalChar) continue;
                        
                        chars[j] = c;
                        String newWord = new String(chars);
                        
                        if (wordSet.contains(newWord)) {
                            queue.offer(newWord);
                            wordSet.remove(newWord);  // Mark as visited
                        }
                    }
                    
                    chars[j] = originalChar;  // Restore
                }
            }
            
            level++;
        }
        
        return 0;  // No transformation found
    }
    
    // Bidirectional BFS: Faster for large graphs
    public int ladderLengthBidirectional(String beginWord, String endWord, 
                                         List<String> wordList) {
        Set<String> wordSet = new HashSet<>(wordList);
        if (!wordSet.contains(endWord)) {
            return 0;
        }
        
        Set<String> beginSet = new HashSet<>();
        Set<String> endSet = new HashSet<>();
        beginSet.add(beginWord);
        endSet.add(endWord);
        
        int level = 1;
        
        while (!beginSet.isEmpty() && !endSet.isEmpty()) {
            // Always expand smaller set
            if (beginSet.size() > endSet.size()) {
                Set<String> temp = beginSet;
                beginSet = endSet;
                endSet = temp;
            }
            
            Set<String> nextLevel = new HashSet<>();
            
            for (String word : beginSet) {
                char[] chars = word.toCharArray();
                
                for (int i = 0; i < chars.length; i++) {
                    char originalChar = chars[i];
                    
                    for (char c = 'a'; c <= 'z'; c++) {
                        chars[i] = c;
                        String newWord = new String(chars);
                        
                        if (endSet.contains(newWord)) {
                            return level + 1;
                        }
                        
                        if (wordSet.contains(newWord)) {
                            nextLevel.add(newWord);
                            wordSet.remove(newWord);
                        }
                    }
                    
                    chars[i] = originalChar;
                }
            }
            
            beginSet = nextLevel;
            level++;
        }
        
        return 0;
    }
    
    @Test
    public void testWordLadder() {
        List<String> wordList = Arrays.asList("hot","dot","dog","lot","log","cog");
        assertEquals(5, ladderLength("hit", "cog", wordList));
    }
}
```

**Key Points:**
- BFS for shortest path
- Generate all possible transformations
- Bidirectional BFS for optimization
- Remove visited words to avoid cycles

---

## Problem 25: Binary Tree Maximum Path Sum

**Difficulty:** Hard  
**Companies:** Amazon, Google, Microsoft, Facebook

**Problem:** Find the maximum path sum in a binary tree. Path can start and end at any node.

```java
/**
 * Input:    1
 *          / \
 *         2   3
 * Output: 6 (2 -> 1 -> 3)
 */
public class BinaryTreeMaxPathSum {
    
    private int maxSum;
    
    public int maxPathSum(TreeNode root) {
        maxSum = Integer.MIN_VALUE;
        maxPathSumHelper(root);
        return maxSum;
    }
    
    // Returns max path sum starting from this node going down
    private int maxPathSumHelper(TreeNode node) {
        if (node == null) {
            return 0;
        }
        
        // Recursively get max path sum from left and right
        // Take 0 if negative (don't include that branch)
        int leftMax = Math.max(0, maxPathSumHelper(node.left));
        int rightMax = Math.max(0, maxPathSumHelper(node.right));
        
        // Path through current node (left + node + right)
        int pathThroughNode = leftMax + node.val + rightMax;
        
        // Update global max
        maxSum = Math.max(maxSum, pathThroughNode);
        
        // Return max path that can continue upward (one branch only)
        return node.val + Math.max(leftMax, rightMax);
    }
    
    @Test
    public void testMaxPathSum() {
        TreeNode root = new TreeNode(1);
        root.left = new TreeNode(2);
        root.right = new TreeNode(3);
        
        assertEquals(6, maxPathSum(root));
        
        // Test with negative values
        TreeNode root2 = new TreeNode(-10);
        root2.left = new TreeNode(9);
        root2.right = new TreeNode(20);
        root2.right.left = new TreeNode(15);
        root2.right.right = new TreeNode(7);
        
        assertEquals(42, maxPathSum(root2));  // 15 -> 20 -> 7
    }
}
```

**Key Points:**
- Post-order traversal (process children first)
- Track global max separately
- Handle negative values (don't include if negative)
- Return single branch max to parent

---

## Problem 26: Clone Graph

**Difficulty:** Medium  
**Companies:** Amazon, Facebook, Google

**Problem:** Deep copy an undirected graph.

```java
/**
 * Clone connected undirected graph
 */
public class CloneGraph {
    
    class Node {
        public int val;
        public List<Node> neighbors;
        
        public Node(int val) {
            this.val = val;
            neighbors = new ArrayList<>();
        }
    }
    
    // DFS approach with HashMap
    public Node cloneGraph(Node node) {
        if (node == null) return null;
        
        Map<Node, Node> visited = new HashMap<>();
        return dfs(node, visited);
    }
    
    private Node dfs(Node node, Map<Node, Node> visited) {
        if (visited.containsKey(node)) {
            return visited.get(node);
        }
        
        // Create clone
        Node clone = new Node(node.val);
        visited.put(node, clone);
        
        // Clone neighbors
        for (Node neighbor : node.neighbors) {
            clone.neighbors.add(dfs(neighbor, visited));
        }
        
        return clone;
    }
    
    // BFS approach
    public Node cloneGraphBFS(Node node) {
        if (node == null) return null;
        
        Map<Node, Node> visited = new HashMap<>();
        Queue<Node> queue = new LinkedList<>();
        
        // Clone first node
        Node clone = new Node(node.val);
        visited.put(node, clone);
        queue.offer(node);
        
        while (!queue.isEmpty()) {
            Node current = queue.poll();
            
            for (Node neighbor : current.neighbors) {
                if (!visited.containsKey(neighbor)) {
                    // Clone neighbor
                    visited.put(neighbor, new Node(neighbor.val));
                    queue.offer(neighbor);
                }
                
                // Add clone to neighbors
                visited.get(current).neighbors.add(visited.get(neighbor));
            }
        }
        
        return clone;
    }
    
    @Test
    public void testCloneGraph() {
        Node node1 = new Node(1);
        Node node2 = new Node(2);
        Node node3 = new Node(3);
        Node node4 = new Node(4);
        
        node1.neighbors.addAll(Arrays.asList(node2, node4));
        node2.neighbors.addAll(Arrays.asList(node1, node3));
        node3.neighbors.addAll(Arrays.asList(node2, node4));
        node4.neighbors.addAll(Arrays.asList(node1, node3));
        
        Node clone = cloneGraph(node1);
        
        assertNotSame(node1, clone);
        assertEquals(node1.val, clone.val);
        assertEquals(node1.neighbors.size(), clone.neighbors.size());
    }
}
```

**Key Points:**
- HashMap to track visited/cloned nodes
- DFS or BFS traversal
- Clone nodes and relationships
- Handle cycles correctly

---

# 3. DYNAMIC PROGRAMMING

## Problem 27: Coin Change

**Difficulty:** Medium  
**Companies:** Amazon, Microsoft, Google

**Problem:** Find minimum number of coins to make up amount. Return -1 if impossible.

```java
/**
 * Input: coins = [1,2,5], amount = 11
 * Output: 3 (5 + 5 + 1)
 */
public class CoinChange {
    
    // DP approach: O(amount × coins) time, O(amount) space
    public int coinChange(int[] coins, int amount) {
        int[] dp = new int[amount + 1];
        Arrays.fill(dp, amount + 1);  // Initialize with infinity
        dp[0] = 0;  // Base case: 0 coins for amount 0
        
        for (int i = 1; i <= amount; i++) {
            for (int coin : coins) {
                if (coin <= i) {
                    dp[i] = Math.min(dp[i], dp[i - coin] + 1);
                }
            }
        }
        
        return dp[amount] > amount ? -1 : dp[amount];
    }
    
    // BFS approach (finds shortest path)
    public int coinChangeBFS(int[] coins, int amount) {
        if (amount == 0) return 0;
        
        Queue<Integer> queue = new LinkedList<>();
        Set<Integer> visited = new HashSet<>();
        queue.offer(0);
        visited.add(0);
        
        int level = 0;
        
        while (!queue.isEmpty()) {
            int size = queue.size();
            level++;
            
            for (int i = 0; i < size; i++) {
                int current = queue.poll();
                
                for (int coin : coins) {
                    int next = current + coin;
                    
                    if (next == amount) {
                        return level;
                    }
                    
                    if (next < amount && !visited.contains(next)) {
                        queue.offer(next);
                        visited.add(next);
                    }
                }
            }
        }
        
        return -1;
    }
    
    @Test
    public void testCoinChange() {
        int[] coins = {1, 2, 5};
        assertEquals(3, coinChange(coins, 11));
        assertEquals(-1, coinChange(new int[]{2}, 3));
        assertEquals(0, coinChange(coins, 0));
    }
}
```

**Key Points:**
- DP array: dp[i] = min coins for amount i
- For each amount, try each coin
- Or use BFS for shortest path
- Handle impossible cases

---

## Problem 28: Longest Increasing Subsequence

**Difficulty:** Medium  
**Companies:** Amazon, Google, Microsoft, Facebook

**Problem:** Find length of longest increasing subsequence.

```java
/**
 * Input: [10,9,2,5,3,7,101,18]
 * Output: 4 ([2,3,7,101] or [2,3,7,18])
 */
public class LongestIncreasingSubsequence {
    
    // DP approach: O(n²) time, O(n) space
    public int lengthOfLIS(int[] nums) {
        if (nums.length == 0) return 0;
        
        int[] dp = new int[nums.length];
        Arrays.fill(dp, 1);  // Each element is LIS of length 1
        
        int maxLength = 1;
        
        for (int i = 1; i < nums.length; i++) {
            for (int j = 0; j < i; j++) {
                if (nums[i] > nums[j]) {
                    dp[i] = Math.max(dp[i], dp[j] + 1);
                }
            }
            maxLength = Math.max(maxLength, dp[i]);
        }
        
        return maxLength;
    }
    
    // Binary Search + DP: O(n log n) time, O(n) space
    public int lengthOfLISOptimized(int[] nums) {
        List<Integer> tails = new ArrayList<>();
        
        for (int num : nums) {
            int pos = binarySearch(tails, num);
            
            if (pos == tails.size()) {
                tails.add(num);
            } else {
                tails.set(pos, num);
            }
        }
        
        return tails.size();
    }
    
    private int binarySearch(List<Integer> tails, int target) {
        int left = 0, right = tails.size();
        
        while (left < right) {
            int mid = left + (right - left) / 2;
            
            if (tails.get(mid) < target) {
                left = mid + 1;
            } else {
                right = mid;
            }
        }
        
        return left;
    }
    
    @Test
    public void testLIS() {
        int[] nums = {10, 9, 2, 5, 3, 7, 101, 18};
        assertEquals(4, lengthOfLIS(nums));
        assertEquals(4, lengthOfLISOptimized(nums));
    }
}
```

**Key Points:**
- DP: dp[i] = length of LIS ending at i
- Or binary search for O(n log n)
- Maintain sorted tail elements
- Not actual subsequence, just length

---

# 4. SYSTEM DESIGN CODING

## Problem 29: Design In-Memory File System

**Difficulty:** Hard  
**Companies:** Amazon, Google, Dropbox

**Problem:** Implement in-memory file system with ls, mkdir, addContentToFile, readContentFromFile.

```java
/**
 * In-memory file system
 */
public class FileSystem {
    
    private class Node {
        boolean isFile;
        String content;
        Map<String, Node> children;
        
        Node() {
            isFile = false;
            content = "";
            children = new HashMap<>();
        }
    }
    
    private final Node root;
    
    public FileSystem() {
        root = new Node();
    }
    
    // List files/directories in path
    public List<String> ls(String path) {
        Node node = navigate(path);
        List<String> result = new ArrayList<>();
        
        if (node.isFile) {
            // If file, return just the file name
            String[] parts = path.split("/");
            result.add(parts[parts.length - 1]);
        } else {
            // If directory, return all children sorted
            result.addAll(node.children.keySet());
            Collections.sort(result);
        }
        
        return result;
    }
    
    // Create directory (and parent directories if needed)
    public void mkdir(String path) {
        navigate(path);  // Creates path if doesn't exist
    }
    
    // Add content to file (creates file if doesn't exist)
    public void addContentToFile(String filePath, String content) {
        Node node = navigate(filePath);
        node.isFile = true;
        node.content += content;
    }
    
    // Read file content
    public String readContentFromFile(String filePath) {
        Node node = navigate(filePath);
        return node.content;
    }
    
    // Navigate to path, creating nodes as needed
    private Node navigate(String path) {
        String[] parts = path.split("/");
        Node current = root;
        
        for (String part : parts) {
            if (part.isEmpty()) continue;
            
            current.children.putIfAbsent(part, new Node());
            current = current.children.get(part);
        }
        
        return current;
    }
    
    @Test
    public void testFileSystem() {
        FileSystem fs = new FileSystem();
        
        assertEquals(Collections.emptyList(), fs.ls("/"));
        
        fs.mkdir("/a/b/c");
        fs.addContentToFile("/a/b/c/d", "hello");
        
        assertEquals(Arrays.asList("a"), fs.ls("/"));
        assertEquals("hello", fs.readContentFromFile("/a/b/c/d"));
        
        fs.addContentToFile("/a/b/c/d", " world");
        assertEquals("hello world", fs.readContentFromFile("/a/b/c/d"));
    }
}
```

**Key Points:**
- Trie-like structure with HashMap
- Distinguish files from directories
- Create parent directories automatically
- Handle edge cases (root, empty paths)

---

## Problem 30: Design Consistent Hashing

**Difficulty:** Hard  
**Companies:** Amazon, Netflix, Uber, LinkedIn

**Problem:** Implement consistent hashing for distributed systems (load balancer, cache, etc).

```java
/**
 * Consistent Hashing for distributed systems
 * Use case: Distribute load across servers, minimize rehashing
 */
public class ConsistentHashing {
    
    private final TreeMap<Integer, String> ring;  // Hash -> Server
    private final int numberOfReplicas;
    
    public ConsistentHashing(int numberOfReplicas) {
        this.ring = new TreeMap<>();
        this.numberOfReplicas = numberOfReplicas;
    }
    
    // Add server to ring
    public void addServer(String server) {
        for (int i = 0; i < numberOfReplicas; i++) {
            int hash = hash(server + i);
            ring.put(hash, server);
        }
    }
    
    // Remove server from ring
    public void removeServer(String server) {
        for (int i = 0; i < numberOfReplicas; i++) {
            int hash = hash(server + i);
            ring.remove(hash);
        }
    }
    
    // Get server for key
    public String getServer(String key) {
        if (ring.isEmpty()) {
            return null;
        }
        
        int hash = hash(key);
        
        // Find nearest server clockwise
        Map.Entry<Integer, String> entry = ring.ceilingEntry(hash);
        
        if (entry == null) {
            // Wrap around to first server
            entry = ring.firstEntry();
        }
        
        return entry.getValue();
    }
    
    // Simple hash function (use better hash in production)
    private int hash(String key) {
        return key.hashCode();
    }
    
    // Get distribution statistics
    public Map<String, Integer> getDistribution(List<String> keys) {
        Map<String, Integer> distribution = new HashMap<>();
        
        for (String key : keys) {
            String server = getServer(key);
            distribution.put(server, distribution.getOrDefault(server, 0) + 1);
        }
        
        return distribution;
    }
    
    @Test
    public void testConsistentHashing() {
        ConsistentHashing ch = new ConsistentHashing(3);
        
        ch.addServer("Server1");
        ch.addServer("Server2");
        ch.addServer("Server3");
        
        // Test key distribution
        assertEquals("Server1", ch.getServer("key1"));
        assertEquals("Server2", ch.getServer("key2"));
        
        // Remove server and check redistribution
        ch.removeServer("Server2");
        assertNotEquals("Server2", ch.getServer("key2"));
        
        // Test distribution balance
        List<String> keys = new ArrayList<>();
        for (int i = 0; i < 1000; i++) {
            keys.add("key" + i);
        }
        
        Map<String, Integer> distribution = ch.getDistribution(keys);
        System.out.println("Distribution: " + distribution);
        
        // Each server should get roughly 500 keys (with 2 servers remaining)
        for (int count : distribution.values()) {
            assertTrue(count > 400 && count < 600);  // Allow some variance
        }
    }
}

// Advanced: Weighted Consistent Hashing
class WeightedConsistentHashing extends ConsistentHashing {
    
    private final Map<String, Integer> serverWeights;
    
    public WeightedConsistentHashing() {
        super(1);  // Base replicas
        this.serverWeights = new HashMap<>();
    }
    
    // Add server with weight (higher weight = more load)
    public void addServer(String server, int weight) {
        serverWeights.put(server, weight);
        
        // Add virtual nodes based on weight
        int replicas = weight * 100;  // Scale weight
        for (int i = 0; i < replicas; i++) {
            super.addServer(server + i);
        }
    }
}
```

**Key Points:**
- TreeMap for sorted ring
- Virtual nodes for better distribution
- ceilingEntry() for clockwise search
- Minimize data movement on add/remove
- Use in load balancers, distributed caches

---

# SUMMARY

## Advanced Problems Covered (21-30)

1. **Trie** - Prefix tree for efficient string operations
2. **Min Stack** - Stack with O(1) minimum
3. **LFU Cache** - Least Frequently Used eviction
4. **Word Ladder** - BFS shortest transformation path
5. **Binary Tree Max Path Sum** - Tree traversal with global tracking
6. **Clone Graph** - Deep copy with cycle handling
7. **Coin Change** - DP or BFS for minimum coins
8. **Longest Increasing Subsequence** - DP or binary search
9. **In-Memory File System** - Trie-like design
10. **Consistent Hashing** - Distributed systems load balancing

## Key Techniques

- **Advanced Data Structures**: Trie, specialized stacks/caches
- **Graph Algorithms**: BFS, DFS, bidirectional search
- **Tree Algorithms**: Post-order traversal, path tracking
- **Dynamic Programming**: Bottom-up, optimization
- **System Design**: Distributed algorithms, hashing

## Coming Up Next

These 10 problems (21-30) combined with the previous 20 problems give you **30 comprehensive coding problems** for senior developer interviews.

Next guide will cover **20 System Design Questions** for complete interview preparation!

---

**END OF ADVANCED CODING PROBLEMS (21-30)**

Practice these problems to master advanced algorithms and data structures for FAANG interviews!
