# Java Coding Questions With Solutions

This file focuses on practical Java coding interview problems.

Use it for:

- coding round preparation
- Java syntax revision
- collections and stream practice
- explaining solution approach in interviews

## How To Use This File

For each question:

1. first explain the brute-force idea if asked
2. then explain the optimized approach
3. write clean Java code
4. mention time and space complexity
5. call out edge cases

## 1. Reverse a String

### Question

Reverse a string.

### Solution

```java
public class ReverseStringExample {
    public static String reverse(String input) {
        if (input == null) {
            return null;
        }

        return new StringBuilder(input).reverse().toString();
    }
}
```

### Explanation

This is the cleanest Java interview answer for most beginner and mid-level rounds.

### Complexity

- Time: `O(n)`
- Space: `O(n)`

## 2. Check Palindrome

### Question

Check whether a string is a palindrome.

### Solution

```java
public class PalindromeExample {
    public static boolean isPalindrome(String input) {
        if (input == null) {
            return false;
        }

        int left = 0;
        int right = input.length() - 1;

        while (left < right) {
            if (input.charAt(left) != input.charAt(right)) {
                return false;
            }
            left++;
            right--;
        }

        return true;
    }
}
```

### Explanation

This two-pointer solution is better than reversing first because it avoids creating an extra full string.

### Complexity

- Time: `O(n)`
- Space: `O(1)`

## 3. Find Duplicate Characters in a String

### Question

Print duplicate characters in a string.

### Solution

```java
import java.util.LinkedHashMap;
import java.util.Map;

public class DuplicateCharactersExample {
    public static Map<Character, Integer> duplicates(String input) {
        Map<Character, Integer> counts = new LinkedHashMap<>();

        for (char ch : input.toCharArray()) {
            counts.put(ch, counts.getOrDefault(ch, 0) + 1);
        }

        Map<Character, Integer> duplicates = new LinkedHashMap<>();
        for (Map.Entry<Character, Integer> entry : counts.entrySet()) {
            if (entry.getValue() > 1) {
                duplicates.put(entry.getKey(), entry.getValue());
            }
        }

        return duplicates;
    }
}
```

### Explanation

`LinkedHashMap` keeps insertion order, which makes the output easier to read in interviews.

### Complexity

- Time: `O(n)`
- Space: `O(n)`

## 4. Count Word Frequency

### Question

Count word frequency in a list of strings.

### Solution

```java
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class WordFrequencyExample {
    public static Map<String, Integer> frequency(List<String> words) {
        Map<String, Integer> result = new HashMap<>();

        for (String word : words) {
            result.put(word, result.getOrDefault(word, 0) + 1);
        }

        return result;
    }
}
```

### Explanation

This is a very common `HashMap` coding problem and is also a good way to explain `getOrDefault`.

### Complexity

- Time: `O(n)`
- Space: `O(n)`

## 5. Remove Duplicates From a List

### Question

Remove duplicates from a list while preserving order.

### Solution

```java
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

public class RemoveDuplicatesExample {
    public static List<Integer> removeDuplicates(List<Integer> numbers) {
        Set<Integer> set = new LinkedHashSet<>(numbers);
        return new ArrayList<>(set);
    }
}
```

### Explanation

`LinkedHashSet` removes duplicates and preserves insertion order.

### Complexity

- Time: `O(n)`
- Space: `O(n)`

## 6. Find First Non-Repeated Character

### Question

Find the first non-repeated character in a string.

### Solution

```java
import java.util.LinkedHashMap;
import java.util.Map;

public class FirstNonRepeatedCharacterExample {
    public static Character firstNonRepeated(String input) {
        Map<Character, Integer> counts = new LinkedHashMap<>();

        for (char ch : input.toCharArray()) {
            counts.put(ch, counts.getOrDefault(ch, 0) + 1);
        }

        for (Map.Entry<Character, Integer> entry : counts.entrySet()) {
            if (entry.getValue() == 1) {
                return entry.getKey();
            }
        }

        return null;
    }
}
```

### Explanation

`LinkedHashMap` is useful here because iteration order matches original character order.

## 7. Find Second Highest Number in an Array

### Question

Find the second highest number in an array.

### Solution

```java
public class SecondHighestExample {
    public static int secondHighest(int[] numbers) {
        int first = Integer.MIN_VALUE;
        int second = Integer.MIN_VALUE;

        for (int number : numbers) {
            if (number > first) {
                second = first;
                first = number;
            } else if (number > second && number != first) {
                second = number;
            }
        }

        return second;
    }
}
```

### Explanation

This is better than sorting when the interviewer wants an optimized one-pass solution.

### Complexity

- Time: `O(n)`
- Space: `O(1)`

## 8. Move All Zeros to the End

### Question

Move all zeros in an array to the end while keeping other elements in order.

### Solution

```java
import java.util.Arrays;

public class MoveZerosExample {
    public static void moveZeros(int[] numbers) {
        int index = 0;

        for (int number : numbers) {
            if (number != 0) {
                numbers[index++] = number;
            }
        }

        while (index < numbers.length) {
            numbers[index++] = 0;
        }
    }
}
```

### Explanation

This keeps non-zero values in order and fills remaining positions with zero.

## 9. Find Missing Number in Array

### Question

Given numbers from `1` to `n`, find the missing number.

### Solution

```java
public class MissingNumberExample {
    public static int findMissing(int[] numbers, int n) {
        int expectedSum = n * (n + 1) / 2;
        int actualSum = 0;

        for (int number : numbers) {
            actualSum += number;
        }

        return expectedSum - actualSum;
    }
}
```

### Explanation

This is a classic arithmetic-sum approach. Mention overflow risk if the input range is very large.

## 10. Merge Two Sorted Arrays

### Question

Merge two sorted arrays into one sorted array.

### Solution

```java
public class MergeSortedArraysExample {
    public static int[] merge(int[] first, int[] second) {
        int[] result = new int[first.length + second.length];

        int i = 0;
        int j = 0;
        int k = 0;

        while (i < first.length && j < second.length) {
            if (first[i] <= second[j]) {
                result[k++] = first[i++];
            } else {
                result[k++] = second[j++];
            }
        }

        while (i < first.length) {
            result[k++] = first[i++];
        }

        while (j < second.length) {
            result[k++] = second[j++];
        }

        return result;
    }
}
```

### Explanation

This is the merge step from merge sort and is a very common interview pattern.

## 11. Check Anagram

### Question

Check whether two strings are anagrams.

### Solution

```java
import java.util.Arrays;

public class AnagramExample {
    public static boolean isAnagram(String first, String second) {
        if (first == null || second == null || first.length() != second.length()) {
            return false;
        }

        char[] a = first.toCharArray();
        char[] b = second.toCharArray();

        Arrays.sort(a);
        Arrays.sort(b);

        return Arrays.equals(a, b);
    }
}
```

### Explanation

Sorting is easy to explain. If asked for a more optimized solution, use frequency counting.

## 12. Find Intersection of Two Arrays

### Question

Find the common elements between two arrays.

### Solution

```java
import java.util.HashSet;
import java.util.Set;

public class ArrayIntersectionExample {
    public static Set<Integer> intersection(int[] first, int[] second) {
        Set<Integer> values = new HashSet<>();
        Set<Integer> result = new HashSet<>();

        for (int number : first) {
            values.add(number);
        }

        for (int number : second) {
            if (values.contains(number)) {
                result.add(number);
            }
        }

        return result;
    }
}
```

## 13. Find Duplicate Number in Array

### Question

Find duplicates in an integer array.

### Solution

```java
import java.util.HashSet;
import java.util.Set;

public class DuplicateNumbersExample {
    public static Set<Integer> duplicates(int[] numbers) {
        Set<Integer> seen = new HashSet<>();
        Set<Integer> duplicates = new HashSet<>();

        for (int number : numbers) {
            if (!seen.add(number)) {
                duplicates.add(number);
            }
        }

        return duplicates;
    }
}
```

## 14. Sort Employees by Salary

### Question

Sort employees by salary.

### Solution

```java
import java.util.Comparator;
import java.util.List;

public class EmployeeSortExample {
    static class Employee {
        private final String name;
        private final double salary;

        Employee(String name, double salary) {
            this.name = name;
            this.salary = salary;
        }

        public double getSalary() {
            return salary;
        }
    }

    public static void sortBySalary(List<Employee> employees) {
        employees.sort(Comparator.comparing(Employee::getSalary));
    }
}
```

### Explanation

This is a good Java 8 coding question because it checks lambda and comparator knowledge.

## 15. Group Employees by Department

### Question

Group employees by department.

### Solution

```java
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

public class GroupByDepartmentExample {
    static class Employee {
        private final String name;
        private final String department;

        Employee(String name, String department) {
            this.name = name;
            this.department = department;
        }

        public String getDepartment() {
            return department;
        }
    }

    public static Map<String, List<Employee>> groupByDepartment(List<Employee> employees) {
        return employees.stream()
                .collect(Collectors.groupingBy(Employee::getDepartment));
    }
}
```

### Explanation

This is a very common stream-based interview question.

## 16. Count Occurrences Using Streams

### Question

Count occurrences of each element in a list using streams.

### Solution

```java
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

public class StreamFrequencyExample {
    public static Map<String, Long> frequency(List<String> items) {
        return items.stream()
                .collect(Collectors.groupingBy(Function.identity(), Collectors.counting()));
    }
}
```

### Explanation

This is a good answer when the interviewer specifically wants Java 8 stream usage.

## 17. Find Max and Min in a List

### Question

Find maximum and minimum in a list.

### Solution

```java
import java.util.Collections;
import java.util.List;

public class MaxMinExample {
    public static int max(List<Integer> numbers) {
        return Collections.max(numbers);
    }

    public static int min(List<Integer> numbers) {
        return Collections.min(numbers);
    }
}
```

### Explanation

If the interviewer asks for manual logic, mention a one-pass loop as an alternative.

## 18. Implement FizzBuzz

### Question

Print numbers from 1 to `n`. For multiples of 3 print `Fizz`, for 5 print `Buzz`, and for both print `FizzBuzz`.

### Solution

```java
public class FizzBuzzExample {
    public static void fizzBuzz(int n) {
        for (int i = 1; i <= n; i++) {
            if (i % 15 == 0) {
                System.out.println("FizzBuzz");
            } else if (i % 3 == 0) {
                System.out.println("Fizz");
            } else if (i % 5 == 0) {
                System.out.println("Buzz");
            } else {
                System.out.println(i);
            }
        }
    }
}
```

### Explanation

Simple problem, but interviewers watch for clarity and branch ordering.

## 19. Find Factorial

### Question

Find factorial of a number.

### Solution

```java
public class FactorialExample {
    public static long factorial(int n) {
        long result = 1;

        for (int i = 2; i <= n; i++) {
            result *= i;
        }

        return result;
    }
}
```

### Explanation

Mention recursion only if asked. Iterative code is simpler and avoids stack-depth issues for larger input.

## 20. Fibonacci Series

### Question

Print Fibonacci series up to `n` terms.

### Solution

```java
public class FibonacciExample {
    public static void printFibonacci(int n) {
        int first = 0;
        int second = 1;

        for (int i = 0; i < n; i++) {
            System.out.print(first + " ");
            int next = first + second;
            first = second;
            second = next;
        }
    }
}
```

## 21. Reverse a Linked List

### Question

Reverse a singly linked list.

### Solution

```java
public class ReverseLinkedListExample {
    static class Node {
        int value;
        Node next;

        Node(int value) {
            this.value = value;
        }
    }

    public static Node reverse(Node head) {
        Node previous = null;
        Node current = head;

        while (current != null) {
            Node next = current.next;
            current.next = previous;
            previous = current;
            current = next;
        }

        return previous;
    }
}
```

### Explanation

This is a classic pointer-manipulation question. Explain `previous`, `current`, and `next` clearly.

## 22. Detect Cycle in Linked List

### Question

Detect whether a linked list has a cycle.

### Solution

```java
public class LinkedListCycleExample {
    static class Node {
        int value;
        Node next;
    }

    public static boolean hasCycle(Node head) {
        Node slow = head;
        Node fast = head;

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

### Explanation

This uses Floyd's cycle detection algorithm and is a strong mid-level interview answer.

## 23. Balanced Parentheses

### Question

Check whether brackets in a string are balanced.

### Solution

```java
import java.util.ArrayDeque;
import java.util.Deque;
import java.util.Map;

public class BalancedParenthesesExample {
    public static boolean isBalanced(String input) {
        Map<Character, Character> pairs = Map.of(
                ')', '(',
                '}', '{',
                ']', '['
        );

        Deque<Character> stack = new ArrayDeque<>();

        for (char ch : input.toCharArray()) {
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

### Explanation

Good stack-based interview problem. Also useful for explaining `Deque` instead of old `Stack`.

## 24. Find Frequency of Characters Using Streams

### Question

Count character frequency using streams.

### Solution

```java
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

public class CharacterFrequencyStreamExample {
    public static Map<String, Long> frequency(String input) {
        return input.chars()
                .mapToObj(ch -> String.valueOf((char) ch))
                .collect(Collectors.groupingBy(Function.identity(), Collectors.counting()));
    }
}
```

### Explanation

This is more stream-heavy, so use it when the interviewer specifically wants Java 8 style.

## 25. Find Top 3 Highest Numbers

### Question

Find the top 3 highest distinct numbers from a list.

### Solution

```java
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

public class TopThreeNumbersExample {
    public static List<Integer> topThree(List<Integer> numbers) {
        return numbers.stream()
                .distinct()
                .sorted(Comparator.reverseOrder())
                .limit(3)
                .collect(Collectors.toList());
    }
}
```

### Explanation

Simple and expressive stream solution. Mention that sorting makes it `O(n log n)`.

## Common Interview Advice

- Do not jump straight into code. Explain the approach first.
- Ask about edge cases like `null`, empty input, duplicates, negatives, and ordering.
- If the problem has a brute-force and optimized solution, mention both briefly.
- Prefer readable Java over clever one-liners unless the interviewer wants stream-specific solutions.
- For Java-specific interviews, explain why you chose `HashMap`, `Set`, `Deque`, `Comparator`, or streams.

## Best Topics To Practice Next

- arrays
- strings
- `HashMap` problems
- linked lists
- stacks and queues
- trees
- sliding window
- two pointers
- recursion and backtracking
- Java 8 stream transformation problems
