# Java Coding Questions: Advanced Patterns With Solutions

This file covers common interview coding patterns that were not fully covered in the first Java coding note.

Use it for:

- intermediate to advanced coding rounds
- pattern-based problem solving
- explaining optimized approaches in interviews

## Topics Covered Here

- two pointers
- sliding window
- binary search
- intervals
- stacks
- heaps
- trees
- graphs
- backtracking
- dynamic programming

## 1. Two Sum

### Question

Given an array and a target, return indices of the two numbers that add up to the target.

### Solution

```java
import java.util.HashMap;
import java.util.Map;

public class TwoSumExample {
    public static int[] twoSum(int[] numbers, int target) {
        Map<Integer, Integer> seen = new HashMap<>();

        for (int i = 0; i < numbers.length; i++) {
            int complement = target - numbers[i];
            if (seen.containsKey(complement)) {
                return new int[]{seen.get(complement), i};
            }
            seen.put(numbers[i], i);
        }

        return new int[0];
    }
}
```

### Explanation

This is a classic `HashMap` lookup problem. Mention the brute-force `O(n^2)` approach first, then improve it to `O(n)`.

### Complexity

- Time: `O(n)`
- Space: `O(n)`

## 2. Longest Substring Without Repeating Characters

### Question

Find the length of the longest substring without repeating characters.

### Solution

```java
import java.util.HashMap;
import java.util.Map;

public class LongestSubstringExample {
    public static int lengthOfLongestSubstring(String input) {
        Map<Character, Integer> lastSeen = new HashMap<>();
        int left = 0;
        int maxLength = 0;

        for (int right = 0; right < input.length(); right++) {
            char current = input.charAt(right);
            if (lastSeen.containsKey(current)) {
                left = Math.max(left, lastSeen.get(current) + 1);
            }
            lastSeen.put(current, right);
            maxLength = Math.max(maxLength, right - left + 1);
        }

        return maxLength;
    }
}
```

### Explanation

This is a standard sliding-window problem. The key idea is that the left pointer never moves backward.

## 3. Maximum Sum Subarray

### Question

Find the maximum sum of a contiguous subarray.

### Solution

```java
public class MaxSubarrayExample {
    public static int maxSubarraySum(int[] numbers) {
        int current = numbers[0];
        int best = numbers[0];

        for (int i = 1; i < numbers.length; i++) {
            current = Math.max(numbers[i], current + numbers[i]);
            best = Math.max(best, current);
        }

        return best;
    }
}
```

### Explanation

This is Kadane's algorithm. It is a must-know dynamic programming style interview problem.

## 4. Binary Search

### Question

Search a target value in a sorted array.

### Solution

```java
public class BinarySearchExample {
    public static int search(int[] numbers, int target) {
        int left = 0;
        int right = numbers.length - 1;

        while (left <= right) {
            int mid = left + (right - left) / 2;

            if (numbers[mid] == target) {
                return mid;
            } else if (numbers[mid] < target) {
                left = mid + 1;
            } else {
                right = mid - 1;
            }
        }

        return -1;
    }
}
```

### Explanation

This checks whether you know sorted-search optimization and safe midpoint calculation.

## 5. Search Insert Position

### Question

Return the index if found, otherwise return the index where the target should be inserted.

### Solution

```java
public class SearchInsertExample {
    public static int searchInsert(int[] numbers, int target) {
        int left = 0;
        int right = numbers.length - 1;

        while (left <= right) {
            int mid = left + (right - left) / 2;

            if (numbers[mid] == target) {
                return mid;
            } else if (numbers[mid] < target) {
                left = mid + 1;
            } else {
                right = mid - 1;
            }
        }

        return left;
    }
}
```

## 6. Merge Intervals

### Question

Merge overlapping intervals.

### Solution

```java
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class MergeIntervalsExample {
    public static int[][] merge(int[][] intervals) {
        Arrays.sort(intervals, (a, b) -> Integer.compare(a[0], b[0]));
        List<int[]> merged = new ArrayList<>();

        for (int[] interval : intervals) {
            if (merged.isEmpty() || merged.get(merged.size() - 1)[1] < interval[0]) {
                merged.add(interval);
            } else {
                merged.get(merged.size() - 1)[1] =
                        Math.max(merged.get(merged.size() - 1)[1], interval[1]);
            }
        }

        return merged.toArray(new int[merged.size()][]);
    }
}
```

### Explanation

This is a high-frequency interview pattern: sort first, then merge in one pass.

## 7. Meeting Rooms

### Question

Given intervals of meeting times, determine if a person can attend all meetings.

### Solution

```java
import java.util.Arrays;

public class MeetingRoomsExample {
    public static boolean canAttendAll(int[][] intervals) {
        Arrays.sort(intervals, (a, b) -> Integer.compare(a[0], b[0]));

        for (int i = 1; i < intervals.length; i++) {
            if (intervals[i][0] < intervals[i - 1][1]) {
                return false;
            }
        }

        return true;
    }
}
```

## 8. Top K Frequent Elements

### Question

Find the top `k` most frequent elements.

### Solution

```java
import java.util.HashMap;
import java.util.Map;
import java.util.PriorityQueue;

public class TopKFrequentExample {
    public static int[] topKFrequent(int[] numbers, int k) {
        Map<Integer, Integer> frequency = new HashMap<>();
        for (int number : numbers) {
            frequency.put(number, frequency.getOrDefault(number, 0) + 1);
        }

        PriorityQueue<Integer> heap =
                new PriorityQueue<>((a, b) -> frequency.get(a) - frequency.get(b));

        for (int key : frequency.keySet()) {
            heap.offer(key);
            if (heap.size() > k) {
                heap.poll();
            }
        }

        int[] result = new int[k];
        for (int i = k - 1; i >= 0; i--) {
            result[i] = heap.poll();
        }

        return result;
    }
}
```

### Explanation

This is a heap-based problem. It is good for explaining frequency maps plus priority queues.

## 9. Kth Largest Element

### Question

Find the kth largest element in an array.

### Solution

```java
import java.util.PriorityQueue;

public class KthLargestExample {
    public static int findKthLargest(int[] numbers, int k) {
        PriorityQueue<Integer> minHeap = new PriorityQueue<>();

        for (int number : numbers) {
            minHeap.offer(number);
            if (minHeap.size() > k) {
                minHeap.poll();
            }
        }

        return minHeap.peek();
    }
}
```

## 10. Valid Anagram Using Frequency Count

### Question

Check whether two strings are anagrams without sorting.

### Solution

```java
public class AnagramCountExample {
    public static boolean isAnagram(String first, String second) {
        if (first.length() != second.length()) {
            return false;
        }

        int[] counts = new int[26];

        for (int i = 0; i < first.length(); i++) {
            counts[first.charAt(i) - 'a']++;
            counts[second.charAt(i) - 'a']--;
        }

        for (int count : counts) {
            if (count != 0) {
                return false;
            }
        }

        return true;
    }
}
```

### Explanation

This improves on the sorting-based answer when the interviewer asks for a more optimized approach.

## 11. Product of Array Except Self

### Question

Return an array where each element is the product of all other elements except itself.

### Solution

```java
public class ProductExceptSelfExample {
    public static int[] productExceptSelf(int[] numbers) {
        int[] result = new int[numbers.length];

        int prefix = 1;
        for (int i = 0; i < numbers.length; i++) {
            result[i] = prefix;
            prefix *= numbers[i];
        }

        int suffix = 1;
        for (int i = numbers.length - 1; i >= 0; i--) {
            result[i] *= suffix;
            suffix *= numbers[i];
        }

        return result;
    }
}
```

## 12. Maximum Profit From Stock

### Question

Given stock prices, find the maximum profit from one buy and one sell.

### Solution

```java
public class StockProfitExample {
    public static int maxProfit(int[] prices) {
        int minPrice = Integer.MAX_VALUE;
        int maxProfit = 0;

        for (int price : prices) {
            minPrice = Math.min(minPrice, price);
            maxProfit = Math.max(maxProfit, price - minPrice);
        }

        return maxProfit;
    }
}
```

## 13. Maximum Depth of Binary Tree

### Question

Find the maximum depth of a binary tree.

### Solution

```java
public class MaxDepthTreeExample {
    static class TreeNode {
        int val;
        TreeNode left;
        TreeNode right;
    }

    public static int maxDepth(TreeNode root) {
        if (root == null) {
            return 0;
        }

        return 1 + Math.max(maxDepth(root.left), maxDepth(root.right));
    }
}
```

### Explanation

This is a very common recursion-based tree problem.

## 14. Inorder Traversal of Binary Tree

### Question

Return inorder traversal of a binary tree.

### Solution

```java
import java.util.ArrayList;
import java.util.List;

public class InorderTraversalExample {
    static class TreeNode {
        int val;
        TreeNode left;
        TreeNode right;
    }

    public static List<Integer> inorder(TreeNode root) {
        List<Integer> result = new ArrayList<>();
        traverse(root, result);
        return result;
    }

    private static void traverse(TreeNode node, List<Integer> result) {
        if (node == null) {
            return;
        }

        traverse(node.left, result);
        result.add(node.val);
        traverse(node.right, result);
    }
}
```

## 15. Level Order Traversal

### Question

Return level order traversal of a binary tree.

### Solution

```java
import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Deque;
import java.util.List;

public class LevelOrderTraversalExample {
    static class TreeNode {
        int val;
        TreeNode left;
        TreeNode right;
    }

    public static List<List<Integer>> levelOrder(TreeNode root) {
        List<List<Integer>> result = new ArrayList<>();
        if (root == null) {
            return result;
        }

        Deque<TreeNode> queue = new ArrayDeque<>();
        queue.offer(root);

        while (!queue.isEmpty()) {
            int size = queue.size();
            List<Integer> level = new ArrayList<>();

            for (int i = 0; i < size; i++) {
                TreeNode node = queue.poll();
                level.add(node.val);

                if (node.left != null) {
                    queue.offer(node.left);
                }
                if (node.right != null) {
                    queue.offer(node.right);
                }
            }

            result.add(level);
        }

        return result;
    }
}
```

## 16. Validate Binary Search Tree

### Question

Check whether a binary tree is a valid BST.

### Solution

```java
public class ValidateBstExample {
    static class TreeNode {
        int val;
        TreeNode left;
        TreeNode right;
    }

    public static boolean isValidBST(TreeNode root) {
        return validate(root, Long.MIN_VALUE, Long.MAX_VALUE);
    }

    private static boolean validate(TreeNode node, long min, long max) {
        if (node == null) {
            return true;
        }

        if (node.val <= min || node.val >= max) {
            return false;
        }

        return validate(node.left, min, node.val)
                && validate(node.right, node.val, max);
    }
}
```

## 17. Number of Islands

### Question

Count number of islands in a grid.

### Solution

```java
public class NumberOfIslandsExample {
    public static int numIslands(char[][] grid) {
        int count = 0;

        for (int row = 0; row < grid.length; row++) {
            for (int col = 0; col < grid[0].length; col++) {
                if (grid[row][col] == '1') {
                    count++;
                    dfs(grid, row, col);
                }
            }
        }

        return count;
    }

    private static void dfs(char[][] grid, int row, int col) {
        if (row < 0 || col < 0 || row >= grid.length || col >= grid[0].length
                || grid[row][col] == '0') {
            return;
        }

        grid[row][col] = '0';

        dfs(grid, row + 1, col);
        dfs(grid, row - 1, col);
        dfs(grid, row, col + 1);
        dfs(grid, row, col - 1);
    }
}
```

### Explanation

This is a classic DFS grid traversal problem.

## 18. Generate All Subsets

### Question

Generate all subsets of an array.

### Solution

```java
import java.util.ArrayList;
import java.util.List;

public class SubsetsExample {
    public static List<List<Integer>> subsets(int[] numbers) {
        List<List<Integer>> result = new ArrayList<>();
        backtrack(numbers, 0, new ArrayList<>(), result);
        return result;
    }

    private static void backtrack(int[] numbers, int start,
                                  List<Integer> current,
                                  List<List<Integer>> result) {
        result.add(new ArrayList<>(current));

        for (int i = start; i < numbers.length; i++) {
            current.add(numbers[i]);
            backtrack(numbers, i + 1, current, result);
            current.remove(current.size() - 1);
        }
    }
}
```

## 19. Generate Valid Parentheses

### Question

Generate all valid combinations of `n` pairs of parentheses.

### Solution

```java
import java.util.ArrayList;
import java.util.List;

public class GenerateParenthesesExample {
    public static List<String> generateParenthesis(int n) {
        List<String> result = new ArrayList<>();
        backtrack(result, "", 0, 0, n);
        return result;
    }

    private static void backtrack(List<String> result, String current,
                                  int open, int close, int n) {
        if (current.length() == n * 2) {
            result.add(current);
            return;
        }

        if (open < n) {
            backtrack(result, current + "(", open + 1, close, n);
        }

        if (close < open) {
            backtrack(result, current + ")", open, close + 1, n);
        }
    }
}
```

## 20. Climbing Stairs

### Question

You can climb 1 or 2 steps. How many distinct ways are there to reach step `n`?

### Solution

```java
public class ClimbingStairsExample {
    public static int climbStairs(int n) {
        if (n <= 2) {
            return n;
        }

        int first = 1;
        int second = 2;

        for (int i = 3; i <= n; i++) {
            int current = first + second;
            first = second;
            second = current;
        }

        return second;
    }
}
```

### Explanation

This is a simple dynamic programming problem related to Fibonacci.

## 21. Coin Change

### Question

Given coin denominations and a target amount, find the minimum number of coins needed.

### Solution

```java
import java.util.Arrays;

public class CoinChangeExample {
    public static int coinChange(int[] coins, int amount) {
        int[] dp = new int[amount + 1];
        Arrays.fill(dp, amount + 1);
        dp[0] = 0;

        for (int i = 1; i <= amount; i++) {
            for (int coin : coins) {
                if (coin <= i) {
                    dp[i] = Math.min(dp[i], dp[i - coin] + 1);
                }
            }
        }

        return dp[amount] > amount ? -1 : dp[amount];
    }
}
```

## 22. Longest Common Prefix

### Question

Find the longest common prefix among strings.

### Solution

```java
public class LongestCommonPrefixExample {
    public static String longestCommonPrefix(String[] words) {
        if (words == null || words.length == 0) {
            return "";
        }

        String prefix = words[0];

        for (int i = 1; i < words.length; i++) {
            while (!words[i].startsWith(prefix)) {
                prefix = prefix.substring(0, prefix.length() - 1);
                if (prefix.isEmpty()) {
                    return "";
                }
            }
        }

        return prefix;
    }
}
```

## 23. Longest Consecutive Sequence

### Question

Find the length of the longest consecutive sequence in an unsorted array.

### Solution

```java
import java.util.HashSet;
import java.util.Set;

public class LongestConsecutiveExample {
    public static int longestConsecutive(int[] numbers) {
        Set<Integer> set = new HashSet<>();
        for (int number : numbers) {
            set.add(number);
        }

        int longest = 0;

        for (int number : set) {
            if (!set.contains(number - 1)) {
                int current = number;
                int length = 1;

                while (set.contains(current + 1)) {
                    current++;
                    length++;
                }

                longest = Math.max(longest, length);
            }
        }

        return longest;
    }
}
```

## 24. Rotated Sorted Array Search

### Question

Search a target in a rotated sorted array.

### Solution

```java
public class RotatedArraySearchExample {
    public static int search(int[] numbers, int target) {
        int left = 0;
        int right = numbers.length - 1;

        while (left <= right) {
            int mid = left + (right - left) / 2;

            if (numbers[mid] == target) {
                return mid;
            }

            if (numbers[left] <= numbers[mid]) {
                if (target >= numbers[left] && target < numbers[mid]) {
                    right = mid - 1;
                } else {
                    left = mid + 1;
                }
            } else {
                if (target > numbers[mid] && target <= numbers[right]) {
                    left = mid + 1;
                } else {
                    right = mid - 1;
                }
            }
        }

        return -1;
    }
}
```

## 25. What To Practice Next

After this file, the biggest remaining coding areas are:

- graph shortest-path problems
- trie problems
- advanced backtracking
- DP on strings
- heap plus interval combinations
- concurrency-style Java machine coding

## Interview Advice For These Questions

- identify the pattern before coding
- say whether it is map, window, DFS, BFS, heap, binary search, or DP
- explain why the chosen structure fits
- mention complexity clearly
- do not force streams into algorithmic problems if loops are clearer
