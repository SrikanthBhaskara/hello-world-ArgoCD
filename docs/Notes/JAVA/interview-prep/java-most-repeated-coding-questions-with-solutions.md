# Java Most Repeated Coding Questions With Solutions

## Purpose

This file is the solution companion for the repeated coding bank.

Use it when you want:
- Java code for the most repeated interview problems
- a short explanation you can speak in interviews
- complexity summary for each answer
- a practical bridge between question names and implementation

Pair this file with:
- [Java 200+ repeated coding interview questions bank](../coding/java-200-plus-repeated-coding-interview-questions.md)
- [Java coding questions with solutions](./java-coding-questions-with-solutions.md)
- [Java coding questions: advanced patterns with solutions](./java-coding-questions-advanced-patterns-with-solutions.md)

## Shared Interview Models

Use these helper classes for linked-list and tree problems.

```java
class ListNode {
    int val;
    ListNode next;

    ListNode() {}

    ListNode(int val) {
        this.val = val;
    }

    ListNode(int val, ListNode next) {
        this.val = val;
        this.next = next;
    }
}

class TreeNode {
    int val;
    TreeNode left;
    TreeNode right;

    TreeNode(int val) {
        this.val = val;
    }
}
```

## 1. Two Sum

### Idea

Store each number in a map and check whether its complement has already been seen.

### Code

```java
import java.util.HashMap;
import java.util.Map;

class TwoSumSolution {
    public int[] twoSum(int[] nums, int target) {
        Map<Integer, Integer> seen = new HashMap<>();

        for (int i = 0; i < nums.length; i++) {
            int complement = target - nums[i];
            if (seen.containsKey(complement)) {
                return new int[]{seen.get(complement), i};
            }
            seen.put(nums[i], i);
        }

        return new int[0];
    }
}
```

### Interview Answer

Brute force is `O(n^2)`, but a hashmap reduces lookup to `O(1)` average, so the full solution becomes linear.

### Complexity

- Time: `O(n)`
- Space: `O(n)`

## 2. Best Time to Buy and Sell Stock

### Idea

Track the minimum price seen so far and keep updating the best profit.

### Code

```java
class BestTimeToBuySellStockSolution {
    public int maxProfit(int[] prices) {
        int minPrice = Integer.MAX_VALUE;
        int bestProfit = 0;

        for (int price : prices) {
            minPrice = Math.min(minPrice, price);
            bestProfit = Math.max(bestProfit, price - minPrice);
        }

        return bestProfit;
    }
}
```

### Interview Answer

The key is that for each day I only need the cheapest earlier buy point, not all previous combinations.

### Complexity

- Time: `O(n)`
- Space: `O(1)`

## 3. Contains Duplicate

### Idea

Use a set and stop as soon as a duplicate is found.

### Code

```java
import java.util.HashSet;
import java.util.Set;

class ContainsDuplicateSolution {
    public boolean containsDuplicate(int[] nums) {
        Set<Integer> seen = new HashSet<>();

        for (int num : nums) {
            if (!seen.add(num)) {
                return true;
            }
        }

        return false;
    }
}
```

### Interview Answer

A set is ideal because I only care whether I have already seen a value, not how many times it appeared.

### Complexity

- Time: `O(n)`
- Space: `O(n)`

## 4. Product of Array Except Self

### Idea

Build prefix products from the left and suffix products from the right without using division.

### Code

```java
class ProductExceptSelfSolution {
    public int[] productExceptSelf(int[] nums) {
        int n = nums.length;
        int[] result = new int[n];

        int prefix = 1;
        for (int i = 0; i < n; i++) {
            result[i] = prefix;
            prefix *= nums[i];
        }

        int suffix = 1;
        for (int i = n - 1; i >= 0; i--) {
            result[i] *= suffix;
            suffix *= nums[i];
        }

        return result;
    }
}
```

### Interview Answer

Instead of recalculating product for every index, I reuse left-side product and right-side product so each element is processed twice only.

### Complexity

- Time: `O(n)`
- Space: `O(1)` extra, ignoring output array

## 5. Maximum Subarray

### Idea

Use Kadane's algorithm and decide at each index whether to continue the current subarray or start fresh.

### Code

```java
class MaximumSubarraySolution {
    public int maxSubArray(int[] nums) {
        int current = nums[0];
        int best = nums[0];

        for (int i = 1; i < nums.length; i++) {
            current = Math.max(nums[i], current + nums[i]);
            best = Math.max(best, current);
        }

        return best;
    }
}
```

### Interview Answer

This is a compact dynamic programming decision: take the current number alone or extend the previous subarray.

### Complexity

- Time: `O(n)`
- Space: `O(1)`

## 6. 3Sum

### Idea

Sort the array, fix one number, then use two pointers to find the remaining pair.

### Code

```java
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

class ThreeSumSolution {
    public List<List<Integer>> threeSum(int[] nums) {
        Arrays.sort(nums);
        List<List<Integer>> result = new ArrayList<>();

        for (int i = 0; i < nums.length - 2; i++) {
            if (i > 0 && nums[i] == nums[i - 1]) {
                continue;
            }

            int left = i + 1;
            int right = nums.length - 1;

            while (left < right) {
                int sum = nums[i] + nums[left] + nums[right];
                if (sum == 0) {
                    result.add(List.of(nums[i], nums[left], nums[right]));
                    left++;
                    right--;

                    while (left < right && nums[left] == nums[left - 1]) {
                        left++;
                    }
                    while (left < right && nums[right] == nums[right + 1]) {
                        right--;
                    }
                } else if (sum < 0) {
                    left++;
                } else {
                    right--;
                }
            }
        }

        return result;
    }
}
```

### Interview Answer

Sorting helps avoid duplicates and transforms the problem into a repeated two-sum style scan.

### Complexity

- Time: `O(n^2)`
- Space: `O(1)` extra, ignoring output

## 7. Container With Most Water

### Idea

Use two pointers and always move the pointer at the smaller height.

### Code

```java
class ContainerWithMostWaterSolution {
    public int maxArea(int[] height) {
        int left = 0;
        int right = height.length - 1;
        int best = 0;

        while (left < right) {
            int area = Math.min(height[left], height[right]) * (right - left);
            best = Math.max(best, area);

            if (height[left] < height[right]) {
                left++;
            } else {
                right--;
            }
        }

        return best;
    }
}
```

### Interview Answer

Moving the taller pointer cannot improve area if the shorter side still limits the container, so I move the smaller side.

### Complexity

- Time: `O(n)`
- Space: `O(1)`

## 8. Longest Substring Without Repeating Characters

### Idea

Maintain a sliding window and the last seen index of each character.

### Code

```java
import java.util.HashMap;
import java.util.Map;

class LongestSubstringWithoutRepeatingSolution {
    public int lengthOfLongestSubstring(String s) {
        Map<Character, Integer> lastSeen = new HashMap<>();
        int left = 0;
        int best = 0;

        for (int right = 0; right < s.length(); right++) {
            char current = s.charAt(right);
            if (lastSeen.containsKey(current)) {
                left = Math.max(left, lastSeen.get(current) + 1);
            }
            lastSeen.put(current, right);
            best = Math.max(best, right - left + 1);
        }

        return best;
    }
}
```

### Interview Answer

The important point is that the left pointer never moves backward, so the solution stays linear.

### Complexity

- Time: `O(n)`
- Space: `O(k)`

## 9. Longest Repeating Character Replacement

### Idea

Track the count of the most frequent character in the window and shrink when replacements needed exceed `k`.

### Code

```java
class LongestRepeatingCharacterReplacementSolution {
    public int characterReplacement(String s, int k) {
        int[] counts = new int[26];
        int left = 0;
        int maxCount = 0;
        int best = 0;

        for (int right = 0; right < s.length(); right++) {
            maxCount = Math.max(maxCount, ++counts[s.charAt(right) - 'A']);

            while (right - left + 1 - maxCount > k) {
                counts[s.charAt(left) - 'A']--;
                left++;
            }

            best = Math.max(best, right - left + 1);
        }

        return best;
    }
}
```

### Interview Answer

Window size minus the frequency of the dominant character tells me how many replacements are required.

### Complexity

- Time: `O(n)`
- Space: `O(1)`

## 10. Minimum Window Substring

### Idea

Expand the right pointer to satisfy all required characters, then shrink the left pointer to get the smallest valid window.

### Code

```java
import java.util.HashMap;
import java.util.Map;

class MinimumWindowSubstringSolution {
    public String minWindow(String s, String t) {
        if (t.length() > s.length()) {
            return "";
        }

        Map<Character, Integer> need = new HashMap<>();
        for (char ch : t.toCharArray()) {
            need.put(ch, need.getOrDefault(ch, 0) + 1);
        }

        int required = need.size();
        int formed = 0;
        Map<Character, Integer> window = new HashMap<>();
        int left = 0;
        int bestLength = Integer.MAX_VALUE;
        int bestStart = 0;

        for (int right = 0; right < s.length(); right++) {
            char ch = s.charAt(right);
            window.put(ch, window.getOrDefault(ch, 0) + 1);

            if (need.containsKey(ch) && window.get(ch).intValue() == need.get(ch).intValue()) {
                formed++;
            }

            while (formed == required) {
                if (right - left + 1 < bestLength) {
                    bestLength = right - left + 1;
                    bestStart = left;
                }

                char leftChar = s.charAt(left);
                window.put(leftChar, window.get(leftChar) - 1);
                if (need.containsKey(leftChar) && window.get(leftChar) < need.get(leftChar)) {
                    formed--;
                }
                left++;
            }
        }

        return bestLength == Integer.MAX_VALUE ? "" : s.substring(bestStart, bestStart + bestLength);
    }
}
```

### Interview Answer

This is a classic variable-size sliding window where validity is controlled by required character counts.

### Complexity

- Time: `O(n)`
- Space: `O(k)`

## 11. Valid Parentheses

### Idea

Push opening brackets and validate each closing bracket against the top of the stack.

### Code

```java
import java.util.ArrayDeque;
import java.util.Deque;
import java.util.Map;

class ValidParenthesesSolution {
    public boolean isValid(String s) {
        Map<Character, Character> pairs = Map.of(')', '(', '}', '{', ']', '[');
        Deque<Character> stack = new ArrayDeque<>();

        for (char ch : s.toCharArray()) {
            if (pairs.containsValue(ch)) {
                stack.push(ch);
            } else if (pairs.containsKey(ch)) {
                if (stack.isEmpty() || stack.pop() != pairs.get(ch)) {
                    return false;
                }
            }
        }

        return stack.isEmpty();
    }
}
```

### Interview Answer

A stack matches the nested nature of brackets because the latest opener must be closed first.

### Complexity

- Time: `O(n)`
- Space: `O(n)`

## 12. Daily Temperatures

### Idea

Use a monotonic decreasing stack of indices.

### Code

```java
import java.util.ArrayDeque;
import java.util.Deque;

class DailyTemperaturesSolution {
    public int[] dailyTemperatures(int[] temperatures) {
        int[] result = new int[temperatures.length];
        Deque<Integer> stack = new ArrayDeque<>();

        for (int i = 0; i < temperatures.length; i++) {
            while (!stack.isEmpty() && temperatures[i] > temperatures[stack.peek()]) {
                int previousIndex = stack.pop();
                result[previousIndex] = i - previousIndex;
            }
            stack.push(i);
        }

        return result;
    }
}
```

### Interview Answer

The stack stores unresolved colder days, and each index is pushed and popped at most once.

### Complexity

- Time: `O(n)`
- Space: `O(n)`

## 13. Reverse Linked List

### Idea

Walk through the list and reverse pointers one node at a time.

### Code

```java
class ReverseLinkedListSolution {
    public ListNode reverseList(ListNode head) {
        ListNode previous = null;
        ListNode current = head;

        while (current != null) {
            ListNode next = current.next;
            current.next = previous;
            previous = current;
            current = next;
        }

        return previous;
    }
}
```

### Interview Answer

This is an in-place pointer problem. The important part is storing `next` before changing the link.

### Complexity

- Time: `O(n)`
- Space: `O(1)`

## 14. Linked List Cycle

### Idea

Use slow and fast pointers. If there is a cycle, they will eventually meet.

### Code

```java
class LinkedListCycleSolution {
    public boolean hasCycle(ListNode head) {
        ListNode slow = head;
        ListNode fast = head;

        while (fast != null && fast.next != null) {
            slow = slow.next;
            fast = fast.next.next;
            if (slow == fast) {
                return true;
            }
        }

        return false;
    }
}
```

### Interview Answer

This avoids extra memory and is the standard Floyd cycle detection approach.

### Complexity

- Time: `O(n)`
- Space: `O(1)`

## 15. Merge Two Sorted Lists

### Idea

Use a dummy node and merge exactly like merge-sort merge logic.

### Code

```java
class MergeTwoSortedListsSolution {
    public ListNode mergeTwoLists(ListNode list1, ListNode list2) {
        ListNode dummy = new ListNode(0);
        ListNode tail = dummy;

        while (list1 != null && list2 != null) {
            if (list1.val <= list2.val) {
                tail.next = list1;
                list1 = list1.next;
            } else {
                tail.next = list2;
                list2 = list2.next;
            }
            tail = tail.next;
        }

        tail.next = list1 != null ? list1 : list2;
        return dummy.next;
    }
}
```

### Interview Answer

A dummy node simplifies head handling and makes pointer updates less error-prone.

### Complexity

- Time: `O(m + n)`
- Space: `O(1)`

## 16. Remove Nth Node From End of List

### Idea

Move the fast pointer `n` steps first, then move both pointers together.

### Code

```java
class RemoveNthNodeFromEndSolution {
    public ListNode removeNthFromEnd(ListNode head, int n) {
        ListNode dummy = new ListNode(0, head);
        ListNode slow = dummy;
        ListNode fast = dummy;

        for (int i = 0; i <= n; i++) {
            fast = fast.next;
        }

        while (fast != null) {
            slow = slow.next;
            fast = fast.next;
        }

        slow.next = slow.next.next;
        return dummy.next;
    }
}
```

### Interview Answer

The gap between pointers allows me to locate the previous node of the target in one pass.

### Complexity

- Time: `O(n)`
- Space: `O(1)`

## 17. Binary Search

### Idea

Search the sorted array by cutting the search space in half each step.

### Code

```java
class BinarySearchSolution {
    public int search(int[] nums, int target) {
        int left = 0;
        int right = nums.length - 1;

        while (left <= right) {
            int mid = left + (right - left) / 2;
            if (nums[mid] == target) {
                return mid;
            }
            if (nums[mid] < target) {
                left = mid + 1;
            } else {
                right = mid - 1;
            }
        }

        return -1;
    }
}
```

### Interview Answer

I use `left + (right - left) / 2` to avoid overflow and preserve the standard boundary logic.

### Complexity

- Time: `O(log n)`
- Space: `O(1)`

## 18. Search in Rotated Sorted Array

### Idea

At every step, at least one half is sorted. Use that to decide which side to keep.

### Code

```java
class SearchInRotatedSortedArraySolution {
    public int search(int[] nums, int target) {
        int left = 0;
        int right = nums.length - 1;

        while (left <= right) {
            int mid = left + (right - left) / 2;
            if (nums[mid] == target) {
                return mid;
            }

            if (nums[left] <= nums[mid]) {
                if (nums[left] <= target && target < nums[mid]) {
                    right = mid - 1;
                } else {
                    left = mid + 1;
                }
            } else {
                if (nums[mid] < target && target <= nums[right]) {
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

### Interview Answer

The main observation is that rotation does not destroy sortedness in both halves at the same time.

### Complexity

- Time: `O(log n)`
- Space: `O(1)`

## 19. Find Minimum in Rotated Sorted Array

### Idea

Use binary search and compare the middle element with the right boundary.

### Code

```java
class FindMinimumInRotatedSortedArraySolution {
    public int findMin(int[] nums) {
        int left = 0;
        int right = nums.length - 1;

        while (left < right) {
            int mid = left + (right - left) / 2;
            if (nums[mid] > nums[right]) {
                left = mid + 1;
            } else {
                right = mid;
            }
        }

        return nums[left];
    }
}
```

### Interview Answer

If the middle element is greater than the rightmost value, the minimum must be in the right half.

### Complexity

- Time: `O(log n)`
- Space: `O(1)`

## 20. Merge Intervals

### Idea

Sort by start time, then either append a new interval or merge into the last one.

### Code

```java
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

class MergeIntervalsSolution {
    public int[][] merge(int[][] intervals) {
        Arrays.sort(intervals, (a, b) -> Integer.compare(a[0], b[0]));
        List<int[]> merged = new ArrayList<>();

        for (int[] interval : intervals) {
            if (merged.isEmpty() || merged.get(merged.size() - 1)[1] < interval[0]) {
                merged.add(interval);
            } else {
                merged.get(merged.size() - 1)[1] = Math.max(merged.get(merged.size() - 1)[1], interval[1]);
            }
        }

        return merged.toArray(new int[merged.size()][]);
    }
}
```

### Interview Answer

Sorting makes all overlaps local, so I only need to compare with the last merged interval.

### Complexity

- Time: `O(n log n)`
- Space: `O(n)`

## 21. Meeting Rooms II

### Idea

Sort meetings by start time and track ongoing meeting end times in a min-heap.

### Code

```java
import java.util.Arrays;
import java.util.PriorityQueue;

class MeetingRoomsIISolution {
    public int minMeetingRooms(int[][] intervals) {
        if (intervals.length == 0) {
            return 0;
        }

        Arrays.sort(intervals, (a, b) -> Integer.compare(a[0], b[0]));
        PriorityQueue<Integer> minHeap = new PriorityQueue<>();
        minHeap.offer(intervals[0][1]);

        for (int i = 1; i < intervals.length; i++) {
            if (intervals[i][0] >= minHeap.peek()) {
                minHeap.poll();
            }
            minHeap.offer(intervals[i][1]);
        }

        return minHeap.size();
    }
}
```

### Interview Answer

The heap represents currently occupied rooms, and the smallest end time is the first room that can be reused.

### Complexity

- Time: `O(n log n)`
- Space: `O(n)`

## 22. Maximum Depth of Binary Tree

### Idea

Depth is `1 + max(leftDepth, rightDepth)`.

### Code

```java
class MaximumDepthBinaryTreeSolution {
    public int maxDepth(TreeNode root) {
        if (root == null) {
            return 0;
        }
        return 1 + Math.max(maxDepth(root.left), maxDepth(root.right));
    }
}
```

### Interview Answer

This is a straightforward recursive tree-height problem and is usually one of the first tree warm-up questions.

### Complexity

- Time: `O(n)`
- Space: `O(h)`

## 23. Binary Tree Level Order Traversal

### Idea

Use BFS with a queue and process nodes level by level.

### Code

```java
import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Deque;
import java.util.List;

class BinaryTreeLevelOrderTraversalSolution {
    public List<List<Integer>> levelOrder(TreeNode root) {
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

### Interview Answer

The queue naturally models BFS, and level size lets me separate each layer cleanly.

### Complexity

- Time: `O(n)`
- Space: `O(n)`

## 24. Validate BST

### Idea

Each node must lie within a valid min-max range inherited from ancestors.

### Code

```java
class ValidateBSTSolution {
    public boolean isValidBST(TreeNode root) {
        return validate(root, Long.MIN_VALUE, Long.MAX_VALUE);
    }

    private boolean validate(TreeNode node, long min, long max) {
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

### Interview Answer

A local child comparison is not enough. BST validity depends on the full ancestor range.

### Complexity

- Time: `O(n)`
- Space: `O(h)`

## 25. Lowest Common Ancestor of a Binary Tree

### Idea

Search both subtrees. If one node is found in each side, the current root is the answer.

### Code

```java
class LowestCommonAncestorBinaryTreeSolution {
    public TreeNode lowestCommonAncestor(TreeNode root, TreeNode p, TreeNode q) {
        if (root == null || root == p || root == q) {
            return root;
        }

        TreeNode left = lowestCommonAncestor(root.left, p, q);
        TreeNode right = lowestCommonAncestor(root.right, p, q);

        if (left != null && right != null) {
            return root;
        }

        return left != null ? left : right;
    }
}
```

### Interview Answer

This works because the first node where the paths to `p` and `q` split is their lowest common ancestor.

### Complexity

- Time: `O(n)`
- Space: `O(h)`

## 26. Diameter of Binary Tree

### Idea

At each node, the longest path through it is `leftHeight + rightHeight`.

### Code

```java
class DiameterOfBinaryTreeSolution {
    private int diameter = 0;

    public int diameterOfBinaryTree(TreeNode root) {
        height(root);
        return diameter;
    }

    private int height(TreeNode node) {
        if (node == null) {
            return 0;
        }

        int left = height(node.left);
        int right = height(node.right);
        diameter = Math.max(diameter, left + right);

        return 1 + Math.max(left, right);
    }
}
```

### Interview Answer

I compute height bottom-up and update the best path while returning subtree heights.

### Complexity

- Time: `O(n)`
- Space: `O(h)`

## 27. Kth Smallest Element in a BST

### Idea

Inorder traversal of a BST gives values in sorted order.

### Code

```java
import java.util.ArrayDeque;
import java.util.Deque;

class KthSmallestInBSTSolution {
    public int kthSmallest(TreeNode root, int k) {
        Deque<TreeNode> stack = new ArrayDeque<>();
        TreeNode current = root;

        while (current != null || !stack.isEmpty()) {
            while (current != null) {
                stack.push(current);
                current = current.left;
            }

            current = stack.pop();
            k--;
            if (k == 0) {
                return current.val;
            }
            current = current.right;
        }

        return -1;
    }
}
```

### Interview Answer

Because BST inorder is sorted, I can stop as soon as I reach the kth node.

### Complexity

- Time: `O(h + k)`
- Space: `O(h)`

## 28. Number of Islands

### Idea

Whenever I find land, run DFS or BFS to mark the full island visited.

### Code

```java
class NumberOfIslandsSolution {
    public int numIslands(char[][] grid) {
        int islands = 0;

        for (int row = 0; row < grid.length; row++) {
            for (int col = 0; col < grid[0].length; col++) {
                if (grid[row][col] == '1') {
                    islands++;
                    dfs(grid, row, col);
                }
            }
        }

        return islands;
    }

    private void dfs(char[][] grid, int row, int col) {
        if (row < 0 || col < 0 || row >= grid.length || col >= grid[0].length || grid[row][col] != '1') {
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

### Interview Answer

The grid becomes a graph. Each DFS marks one connected component of land.

### Complexity

- Time: `O(m * n)`
- Space: `O(m * n)` worst case recursion

## 29. Course Schedule

### Idea

Use topological sorting with indegree counts.

### Code

```java
import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Deque;
import java.util.List;

class CourseScheduleSolution {
    public boolean canFinish(int numCourses, int[][] prerequisites) {
        List<List<Integer>> graph = new ArrayList<>();
        for (int i = 0; i < numCourses; i++) {
            graph.add(new ArrayList<>());
        }

        int[] indegree = new int[numCourses];
        for (int[] edge : prerequisites) {
            graph.get(edge[1]).add(edge[0]);
            indegree[edge[0]]++;
        }

        Deque<Integer> queue = new ArrayDeque<>();
        for (int i = 0; i < numCourses; i++) {
            if (indegree[i] == 0) {
                queue.offer(i);
            }
        }

        int visited = 0;
        while (!queue.isEmpty()) {
            int course = queue.poll();
            visited++;

            for (int next : graph.get(course)) {
                indegree[next]--;
                if (indegree[next] == 0) {
                    queue.offer(next);
                }
            }
        }

        return visited == numCourses;
    }
}
```

### Interview Answer

If I can process all nodes in topological order, there is no cycle blocking completion.

### Complexity

- Time: `O(V + E)`
- Space: `O(V + E)`

## 30. Clone Graph

### Idea

Use DFS and a map from original node to cloned node.

### Code

```java
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

class Node {
    public int val;
    public List<Node> neighbors;

    public Node() {
        val = 0;
        neighbors = new ArrayList<>();
    }

    public Node(int val) {
        this.val = val;
        neighbors = new ArrayList<>();
    }
}

class CloneGraphSolution {
    private final Map<Node, Node> clones = new HashMap<>();

    public Node cloneGraph(Node node) {
        if (node == null) {
            return null;
        }
        if (clones.containsKey(node)) {
            return clones.get(node);
        }

        Node copy = new Node(node.val);
        clones.put(node, copy);

        for (Node neighbor : node.neighbors) {
            copy.neighbors.add(cloneGraph(neighbor));
        }

        return copy;
    }
}
```

### Interview Answer

The map prevents infinite loops on cycles and also ensures the same node is not cloned twice.

### Complexity

- Time: `O(V + E)`
- Space: `O(V)`

## 31. Rotting Oranges

### Idea

Run multi-source BFS starting from all initially rotten oranges.

### Code

```java
import java.util.ArrayDeque;
import java.util.Deque;

class RottingOrangesSolution {
    public int orangesRotting(int[][] grid) {
        Deque<int[]> queue = new ArrayDeque<>();
        int fresh = 0;

        for (int row = 0; row < grid.length; row++) {
            for (int col = 0; col < grid[0].length; col++) {
                if (grid[row][col] == 2) {
                    queue.offer(new int[]{row, col});
                } else if (grid[row][col] == 1) {
                    fresh++;
                }
            }
        }

        int minutes = 0;
        int[][] directions = {{1, 0}, {-1, 0}, {0, 1}, {0, -1}};

        while (!queue.isEmpty() && fresh > 0) {
            int size = queue.size();
            for (int i = 0; i < size; i++) {
                int[] cell = queue.poll();
                for (int[] direction : directions) {
                    int newRow = cell[0] + direction[0];
                    int newCol = cell[1] + direction[1];

                    if (newRow >= 0 && newCol >= 0 && newRow < grid.length && newCol < grid[0].length
                            && grid[newRow][newCol] == 1) {
                        grid[newRow][newCol] = 2;
                        fresh--;
                        queue.offer(new int[]{newRow, newCol});
                    }
                }
            }
            minutes++;
        }

        return fresh == 0 ? minutes : -1;
    }
}
```

### Interview Answer

This is level-based BFS where each level represents one minute of spread.

### Complexity

- Time: `O(m * n)`
- Space: `O(m * n)`

## 32. Kth Largest Element in an Array

### Idea

Maintain a min-heap of size `k`.

### Code

```java
import java.util.PriorityQueue;

class KthLargestElementSolution {
    public int findKthLargest(int[] nums, int k) {
        PriorityQueue<Integer> minHeap = new PriorityQueue<>();

        for (int num : nums) {
            minHeap.offer(num);
            if (minHeap.size() > k) {
                minHeap.poll();
            }
        }

        return minHeap.peek();
    }
}
```

### Interview Answer

Keeping only the top `k` elements is cheaper than fully sorting if I only need the kth largest.

### Complexity

- Time: `O(n log k)`
- Space: `O(k)`

## 33. Top K Frequent Elements

### Idea

Count frequencies, then use a heap ordered by frequency.

### Code

```java
import java.util.HashMap;
import java.util.Map;
import java.util.PriorityQueue;

class TopKFrequentElementsSolution {
    public int[] topKFrequent(int[] nums, int k) {
        Map<Integer, Integer> frequency = new HashMap<>();
        for (int num : nums) {
            frequency.put(num, frequency.getOrDefault(num, 0) + 1);
        }

        PriorityQueue<Integer> minHeap = new PriorityQueue<>((a, b) -> frequency.get(a) - frequency.get(b));
        for (int num : frequency.keySet()) {
            minHeap.offer(num);
            if (minHeap.size() > k) {
                minHeap.poll();
            }
        }

        int[] result = new int[k];
        for (int i = k - 1; i >= 0; i--) {
            result[i] = minHeap.poll();
        }

        return result;
    }
}
```

### Interview Answer

The map gives frequencies, and the heap keeps only the top `k` frequent values.

### Complexity

- Time: `O(n log k)`
- Space: `O(n)`

## 34. Find Median from Data Stream

### Idea

Use a max-heap for the smaller half and a min-heap for the larger half.

### Code

```java
import java.util.Collections;
import java.util.PriorityQueue;

class MedianFinder {
    private final PriorityQueue<Integer> lower = new PriorityQueue<>(Collections.reverseOrder());
    private final PriorityQueue<Integer> higher = new PriorityQueue<>();

    public void addNum(int num) {
        if (lower.isEmpty() || num <= lower.peek()) {
            lower.offer(num);
        } else {
            higher.offer(num);
        }

        if (lower.size() > higher.size() + 1) {
            higher.offer(lower.poll());
        } else if (higher.size() > lower.size()) {
            lower.offer(higher.poll());
        }
    }

    public double findMedian() {
        if (lower.size() == higher.size()) {
            return (lower.peek() + higher.peek()) / 2.0;
        }
        return lower.peek();
    }
}
```

### Interview Answer

Balancing two heaps gives constant-time median lookup and logarithmic insertion.

### Complexity

- Add: `O(log n)`
- Find median: `O(1)`

## 35. Merge K Sorted Lists

### Idea

Use a min-heap to always take the smallest current node across all lists.

### Code

```java
import java.util.PriorityQueue;

class MergeKSortedListsSolution {
    public ListNode mergeKLists(ListNode[] lists) {
        PriorityQueue<ListNode> minHeap = new PriorityQueue<>((a, b) -> a.val - b.val);

        for (ListNode node : lists) {
            if (node != null) {
                minHeap.offer(node);
            }
        }

        ListNode dummy = new ListNode(0);
        ListNode tail = dummy;

        while (!minHeap.isEmpty()) {
            ListNode node = minHeap.poll();
            tail.next = node;
            tail = tail.next;

            if (node.next != null) {
                minHeap.offer(node.next);
            }
        }

        return dummy.next;
    }
}
```

### Interview Answer

The heap gives me the next global minimum across all list heads without scanning every list each time.

### Complexity

- Time: `O(n log k)`
- Space: `O(k)`

## 36. Subsets

### Idea

Use backtracking and choose whether to include each element.

### Code

```java
import java.util.ArrayList;
import java.util.List;

class SubsetsSolution {
    public List<List<Integer>> subsets(int[] nums) {
        List<List<Integer>> result = new ArrayList<>();
        backtrack(nums, 0, new ArrayList<>(), result);
        return result;
    }

    private void backtrack(int[] nums, int index, List<Integer> path, List<List<Integer>> result) {
        result.add(new ArrayList<>(path));

        for (int i = index; i < nums.length; i++) {
            path.add(nums[i]);
            backtrack(nums, i + 1, path, result);
            path.remove(path.size() - 1);
        }
    }
}
```

### Interview Answer

This is a classic decision-tree generation problem where each recursive call explores one branch.

### Complexity

- Time: `O(n * 2^n)`
- Space: `O(n)` recursion, excluding output

## 37. Permutations

### Idea

Use backtracking and a `used` array to build one ordering at a time.

### Code

```java
import java.util.ArrayList;
import java.util.List;

class PermutationsSolution {
    public List<List<Integer>> permute(int[] nums) {
        List<List<Integer>> result = new ArrayList<>();
        backtrack(nums, new boolean[nums.length], new ArrayList<>(), result);
        return result;
    }

    private void backtrack(int[] nums, boolean[] used, List<Integer> path, List<List<Integer>> result) {
        if (path.size() == nums.length) {
            result.add(new ArrayList<>(path));
            return;
        }

        for (int i = 0; i < nums.length; i++) {
            if (used[i]) {
                continue;
            }

            used[i] = true;
            path.add(nums[i]);
            backtrack(nums, used, path, result);
            path.remove(path.size() - 1);
            used[i] = false;
        }
    }
}
```

### Interview Answer

Unlike subsets, permutations care about order, so I must track which elements are already used.

### Complexity

- Time: `O(n * n!)`
- Space: `O(n)` recursion, excluding output

## 38. Combination Sum

### Idea

Try each candidate and allow reuse by staying on the same index in recursion.

### Code

```java
import java.util.ArrayList;
import java.util.List;

class CombinationSumSolution {
    public List<List<Integer>> combinationSum(int[] candidates, int target) {
        List<List<Integer>> result = new ArrayList<>();
        backtrack(candidates, target, 0, new ArrayList<>(), result);
        return result;
    }

    private void backtrack(int[] candidates, int target, int index, List<Integer> path, List<List<Integer>> result) {
        if (target == 0) {
            result.add(new ArrayList<>(path));
            return;
        }
        if (target < 0) {
            return;
        }

        for (int i = index; i < candidates.length; i++) {
            path.add(candidates[i]);
            backtrack(candidates, target - candidates[i], i, path, result);
            path.remove(path.size() - 1);
        }
    }
}
```

### Interview Answer

The important rule here is that reuse is allowed, so the recursive call continues from the same index.

### Complexity

- Time: exponential
- Space: `O(target)` recursion depth in the worst case

## 39. Word Search

### Idea

Start DFS from each cell and mark cells as visited during the current path.

### Code

```java
class WordSearchSolution {
    public boolean exist(char[][] board, String word) {
        for (int row = 0; row < board.length; row++) {
            for (int col = 0; col < board[0].length; col++) {
                if (dfs(board, word, row, col, 0)) {
                    return true;
                }
            }
        }
        return false;
    }

    private boolean dfs(char[][] board, String word, int row, int col, int index) {
        if (index == word.length()) {
            return true;
        }
        if (row < 0 || col < 0 || row >= board.length || col >= board[0].length || board[row][col] != word.charAt(index)) {
            return false;
        }

        char saved = board[row][col];
        board[row][col] = '#';

        boolean found = dfs(board, word, row + 1, col, index + 1)
                || dfs(board, word, row - 1, col, index + 1)
                || dfs(board, word, row, col + 1, index + 1)
                || dfs(board, word, row, col - 1, index + 1);

        board[row][col] = saved;
        return found;
    }
}
```

### Interview Answer

This is backtracking on a 2D grid. I temporarily mark a cell as used and restore it during backtracking.

### Complexity

- Time: `O(m * n * 4^L)` in the worst case
- Space: `O(L)` recursion

## 40. Generate Parentheses

### Idea

Add `(` while possible and add `)` only when it keeps the string valid.

### Code

```java
import java.util.ArrayList;
import java.util.List;

class GenerateParenthesesSolution {
    public List<String> generateParenthesis(int n) {
        List<String> result = new ArrayList<>();
        backtrack(n, 0, 0, new StringBuilder(), result);
        return result;
    }

    private void backtrack(int n, int open, int close, StringBuilder current, List<String> result) {
        if (current.length() == 2 * n) {
            result.add(current.toString());
            return;
        }

        if (open < n) {
            current.append('(');
            backtrack(n, open + 1, close, current, result);
            current.deleteCharAt(current.length() - 1);
        }

        if (close < open) {
            current.append(')');
            backtrack(n, open, close + 1, current, result);
            current.deleteCharAt(current.length() - 1);
        }
    }
}
```

### Interview Answer

The pruning rule is the full trick: a closing bracket can never exceed the number of open brackets already placed.

### Complexity

- Time: Catalan-number growth
- Space: `O(n)` recursion, excluding output

## 41. Climbing Stairs

### Idea

This is Fibonacci-style DP where each state depends on the previous two.

### Code

```java
class ClimbingStairsSolution {
    public int climbStairs(int n) {
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

### Interview Answer

To reach step `n`, the last move came from step `n - 1` or `n - 2`.

### Complexity

- Time: `O(n)`
- Space: `O(1)`

## 42. House Robber

### Idea

For each house, choose between robbing it plus `dp[i-2]` or skipping it and keeping `dp[i-1]`.

### Code

```java
class HouseRobberSolution {
    public int rob(int[] nums) {
        int robPrevious = 0;
        int skipPrevious = 0;

        for (int num : nums) {
            int newRob = skipPrevious + num;
            skipPrevious = Math.max(skipPrevious, robPrevious);
            robPrevious = newRob;
        }

        return Math.max(robPrevious, skipPrevious);
    }
}
```

### Interview Answer

This is a simple include-or-exclude DP with adjacent-house restriction.

### Complexity

- Time: `O(n)`
- Space: `O(1)`

## 43. Coin Change

### Idea

Bottom-up DP where `dp[i]` is the minimum coins needed to form amount `i`.

### Code

```java
import java.util.Arrays;

class CoinChangeSolution {
    public int coinChange(int[] coins, int amount) {
        int[] dp = new int[amount + 1];
        Arrays.fill(dp, amount + 1);
        dp[0] = 0;

        for (int value = 1; value <= amount; value++) {
            for (int coin : coins) {
                if (coin <= value) {
                    dp[value] = Math.min(dp[value], dp[value - coin] + 1);
                }
            }
        }

        return dp[amount] > amount ? -1 : dp[amount];
    }
}
```

### Interview Answer

The DP transition tries every coin as the last coin used for the current amount.

### Complexity

- Time: `O(amount * numberOfCoins)`
- Space: `O(amount)`

## 44. Longest Increasing Subsequence

### Idea

Use dynamic programming where `dp[i]` is the LIS ending at index `i`.

### Code

```java
import java.util.Arrays;

class LongestIncreasingSubsequenceSolution {
    public int lengthOfLIS(int[] nums) {
        int[] dp = new int[nums.length];
        Arrays.fill(dp, 1);
        int best = 1;

        for (int i = 1; i < nums.length; i++) {
            for (int j = 0; j < i; j++) {
                if (nums[j] < nums[i]) {
                    dp[i] = Math.max(dp[i], dp[j] + 1);
                }
            }
            best = Math.max(best, dp[i]);
        }

        return best;
    }
}
```

### Interview Answer

This `O(n^2)` version is usually acceptable in interviews unless they explicitly ask for the binary-search optimization.

### Complexity

- Time: `O(n^2)`
- Space: `O(n)`

## 45. Longest Common Subsequence

### Idea

Build a 2D DP table where each cell represents the LCS of prefixes.

### Code

```java
class LongestCommonSubsequenceSolution {
    public int longestCommonSubsequence(String text1, String text2) {
        int[][] dp = new int[text1.length() + 1][text2.length() + 1];

        for (int i = 1; i <= text1.length(); i++) {
            for (int j = 1; j <= text2.length(); j++) {
                if (text1.charAt(i - 1) == text2.charAt(j - 1)) {
                    dp[i][j] = dp[i - 1][j - 1] + 1;
                } else {
                    dp[i][j] = Math.max(dp[i - 1][j], dp[i][j - 1]);
                }
            }
        }

        return dp[text1.length()][text2.length()];
    }
}
```

### Interview Answer

If the characters match, I extend the diagonal state. Otherwise I carry the best result from dropping one side.

### Complexity

- Time: `O(m * n)`
- Space: `O(m * n)`

## 46. Word Break

### Idea

Use DP where `dp[i]` means the prefix ending at `i` can be segmented.

### Code

```java
import java.util.HashSet;
import java.util.List;
import java.util.Set;

class WordBreakSolution {
    public boolean wordBreak(String s, List<String> wordDict) {
        Set<String> words = new HashSet<>(wordDict);
        boolean[] dp = new boolean[s.length() + 1];
        dp[0] = true;

        for (int end = 1; end <= s.length(); end++) {
            for (int start = 0; start < end; start++) {
                if (dp[start] && words.contains(s.substring(start, end))) {
                    dp[end] = true;
                    break;
                }
            }
        }

        return dp[s.length()];
    }
}
```

### Interview Answer

Each index asks whether there is a previous valid split point that forms a valid word up to the current position.

### Complexity

- Time: `O(n^3)` with substring cost in basic Java form
- Space: `O(n)`

## 47. LRU Cache

### Idea

Use a hashmap for direct access and a doubly linked list to maintain recency order.

### Code

```java
import java.util.HashMap;
import java.util.Map;

class LRUCache {
    private static class Node {
        int key;
        int value;
        Node prev;
        Node next;

        Node(int key, int value) {
            this.key = key;
            this.value = value;
        }
    }

    private final int capacity;
    private final Map<Integer, Node> map = new HashMap<>();
    private final Node head = new Node(0, 0);
    private final Node tail = new Node(0, 0);

    public LRUCache(int capacity) {
        this.capacity = capacity;
        head.next = tail;
        tail.prev = head;
    }

    public int get(int key) {
        Node node = map.get(key);
        if (node == null) {
            return -1;
        }
        moveToFront(node);
        return node.value;
    }

    public void put(int key, int value) {
        Node node = map.get(key);
        if (node != null) {
            node.value = value;
            moveToFront(node);
            return;
        }

        Node newNode = new Node(key, value);
        map.put(key, newNode);
        addToFront(newNode);

        if (map.size() > capacity) {
            Node lru = tail.prev;
            removeNode(lru);
            map.remove(lru.key);
        }
    }

    private void moveToFront(Node node) {
        removeNode(node);
        addToFront(node);
    }

    private void addToFront(Node node) {
        node.next = head.next;
        node.prev = head;
        head.next.prev = node;
        head.next = node;
    }

    private void removeNode(Node node) {
        node.prev.next = node.next;
        node.next.prev = node.prev;
    }
}
```

### Interview Answer

The hashmap gives `O(1)` lookup, and the doubly linked list gives `O(1)` remove and move operations for recency updates.

### Complexity

- Get: `O(1)`
- Put: `O(1)`

## 48. Insert Delete GetRandom O(1)

### Idea

Use a list for random access and a map from value to index for `O(1)` updates.

### Code

```java
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;

class RandomizedSet {
    private final List<Integer> values = new ArrayList<>();
    private final Map<Integer, Integer> indexMap = new HashMap<>();
    private final Random random = new Random();

    public boolean insert(int val) {
        if (indexMap.containsKey(val)) {
            return false;
        }
        indexMap.put(val, values.size());
        values.add(val);
        return true;
    }

    public boolean remove(int val) {
        Integer index = indexMap.get(val);
        if (index == null) {
            return false;
        }

        int lastValue = values.get(values.size() - 1);
        values.set(index, lastValue);
        indexMap.put(lastValue, index);

        values.remove(values.size() - 1);
        indexMap.remove(val);
        return true;
    }

    public int getRandom() {
        return values.get(random.nextInt(values.size()));
    }
}
```

### Interview Answer

The swap-with-last trick avoids `O(n)` deletion from the middle of the list.

### Complexity

- Insert: `O(1)` average
- Remove: `O(1)` average
- Get random: `O(1)`

## 49. Time Based Key-Value Store

### Idea

Store timestamped values per key and binary-search the latest valid timestamp.

### Code

```java
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

class TimeMap {
    private static class Entry {
        int timestamp;
        String value;

        Entry(int timestamp, String value) {
            this.timestamp = timestamp;
            this.value = value;
        }
    }

    private final Map<String, List<Entry>> store = new HashMap<>();

    public void set(String key, String value, int timestamp) {
        store.computeIfAbsent(key, ignored -> new ArrayList<>()).add(new Entry(timestamp, value));
    }

    public String get(String key, int timestamp) {
        List<Entry> entries = store.get(key);
        if (entries == null) {
            return "";
        }

        int left = 0;
        int right = entries.size() - 1;
        String answer = "";

        while (left <= right) {
            int mid = left + (right - left) / 2;
            if (entries.get(mid).timestamp <= timestamp) {
                answer = entries.get(mid).value;
                left = mid + 1;
            } else {
                right = mid - 1;
            }
        }

        return answer;
    }
}
```

### Interview Answer

Each key has sorted writes by timestamp, so retrieval is just a rightmost binary search.

### Complexity

- Set: `O(1)` amortized
- Get: `O(log n)` per key

## 50. Design Twitter

### Idea

Store each user's tweets, keep follow relations, and merge the latest tweet streams using a max-heap.

### Code

```java
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.PriorityQueue;
import java.util.Set;

class Twitter {
    private static class Tweet {
        int id;
        int time;

        Tweet(int id, int time) {
            this.id = id;
            this.time = time;
        }
    }

    private int time = 0;
    private final Map<Integer, Set<Integer>> follows = new HashMap<>();
    private final Map<Integer, List<Tweet>> tweets = new HashMap<>();

    public void postTweet(int userId, int tweetId) {
        tweets.computeIfAbsent(userId, ignored -> new ArrayList<>()).add(new Tweet(tweetId, time++));
    }

    public List<Integer> getNewsFeed(int userId) {
        follows.computeIfAbsent(userId, ignored -> new HashSet<>()).add(userId);
        PriorityQueue<Tweet> maxHeap = new PriorityQueue<>((a, b) -> b.time - a.time);

        for (int followee : follows.get(userId)) {
            List<Tweet> userTweets = tweets.getOrDefault(followee, List.of());
            for (int i = Math.max(0, userTweets.size() - 10); i < userTweets.size(); i++) {
                maxHeap.offer(userTweets.get(i));
            }
        }

        List<Integer> feed = new ArrayList<>();
        while (!maxHeap.isEmpty() && feed.size() < 10) {
            feed.add(maxHeap.poll().id);
        }

        return feed;
    }

    public void follow(int followerId, int followeeId) {
        follows.computeIfAbsent(followerId, ignored -> new HashSet<>()).add(followeeId);
    }

    public void unfollow(int followerId, int followeeId) {
        if (followerId == followeeId) {
            return;
        }
        follows.getOrDefault(followerId, Set.of()).remove(followeeId);
    }
}
```

### Interview Answer

For interview purposes, I keep the model simple: follow graph plus recent tweets, then use a heap to return the latest feed.

### Complexity

- Post tweet: `O(1)`
- Follow and unfollow: `O(1)` average
- Get news feed: depends on followed users and recent tweets considered

## Final Advice

For each of these questions, practice answering in this order:

1. State the brute-force idea.
2. State why it is slow.
3. Name the pattern for the optimized approach.
4. Write clean Java code.
5. Mention complexity and edge cases.

If you can do that consistently for these 50 problems, your coding round performance will improve significantly.
