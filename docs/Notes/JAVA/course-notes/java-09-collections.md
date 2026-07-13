# Java Collections Framework

## Collections Hierarchy

```
          Collection (Interface)
                 |
     ┌───────────┼───────────┐
     │           │           │
   List        Set         Queue
     │           │           │
ArrayList    HashSet    PriorityQueue
LinkedList   TreeSet    LinkedList
Vector       LinkedHashSet  ArrayDeque
Stack
```

```
        Map (Interface)
            |
     ┌──────┼──────┐
  HashMap  TreeMap  LinkedHashMap
  Hashtable
Properties
```

## List Interface

### ArrayList

Dynamic array that grows automatically.

```java
import java.util.ArrayList;
import java.util.List;

// Creation
List<String> list = new ArrayList<>();
ArrayList<Integer> numbers = new ArrayList<>();

// With initial capacity
List<String> list2 = new ArrayList<>(100);

// From another collection
List<String> copy = new ArrayList<>(list);

// Add elements
list.add("Apple");
list.add("Banana");
list.add(1, "Cherry");  // Add at index

// Access elements
String first = list.get(0);
int size = list.size();

// Modify
list.set(0, "Mango");  // Replace at index

// Remove
list.remove(0);        // By index
list.remove("Banana"); // By object
list.clear();          // Remove all

// Check
boolean contains = list.contains("Apple");
boolean isEmpty = list.isEmpty();
int index = list.indexOf("Apple");  // -1 if not found

// Iterate
for (String item : list) {
    System.out.println(item);
}

// forEach (Java 8+)
list.forEach(item -> System.out.println(item));
list.forEach(System.out::println);  // Method reference

// Convert to array
String[] array = list.toArray(new String[0]);
```

**Characteristics**:
- ✅ Fast random access O(1)
- ✅ Allows duplicates
- ✅ Maintains insertion order
- ❌ Slow insertion/deletion in middle O(n)
- ❌ Not synchronized (not thread-safe)

### LinkedList

Doubly-linked list implementation.

```java
import java.util.LinkedList;

LinkedList<String> list = new LinkedList<>();

// Add elements
list.add("First");
list.addFirst("Zero");   // Add at beginning
list.addLast("Last");    // Add at end

// Access
String first = list.getFirst();
String last = list.getLast();
String element = list.get(1);

// Remove
list.removeFirst();
list.removeLast();
list.remove(0);

// Use as Stack (LIFO)
list.push("A");
String top = list.pop();

// Use as Queue (FIFO)
list.offer("A");
String front = list.poll();
```

**Characteristics**:
- ✅ Fast insertion/deletion at ends O(1)
- ✅ Implements both List and Deque
- ❌ Slow random access O(n)
- ❌ More memory (stores prev/next pointers)

### Vector (Legacy, avoid)

```java
import java.util.Vector;

Vector<Integer> vector = new Vector<>();
vector.add(1);
vector.add(2);

// Thread-safe but slow (synchronized methods)
// Use ArrayList with Collections.synchronizedList() instead
```

### ArrayList vs LinkedList

| Operation | ArrayList | LinkedList |
|-----------|-----------|------------|
| get(i) | O(1) ⚡ | O(n) 🐌 |
| add(element) | O(1)* ⚡ | O(1) ⚡ |
| add(i, element) | O(n) 🐌 | O(n) 🐌 |
| remove(i) | O(n) 🐌 | O(n) 🐌 |
| addFirst/addLast | O(n) 🐌 | O(1) ⚡ |
| Memory | Less | More |

*Amortized O(1) - occasional resizing

**When to use**:
- **ArrayList**: Frequent access, rare modification
- **LinkedList**: Frequent insertion/deletion at ends, implementing queue/stack

## Set Interface

No duplicates allowed, unordered (except TreeSet).

### HashSet

Hash table-based implementation.

```java
import java.util.HashSet;
import java.util.Set;

Set<String> set = new HashSet<>();

// Add elements
set.add("Apple");
set.add("Banana");
set.add("Apple");   // Duplicate ignored

System.out.println(set);  // [Banana, Apple] (unordered)

// Remove
set.remove("Apple");

// Check
boolean hasApple = set.contains("Apple");

// Set operations
Set<Integer> set1 = new HashSet<>(Arrays.asList(1, 2, 3));
Set<Integer> set2 = new HashSet<>(Arrays.asList(3, 4, 5));

// Union
Set<Integer> union = new HashSet<>(set1);
union.addAll(set2);  // [1, 2, 3, 4, 5]

// Intersection
Set<Integer> intersection = new HashSet<>(set1);
intersection.retainAll(set2);  // [3]

// Difference
Set<Integer> difference = new HashSet<>(set1);
difference.removeAll(set2);  // [1, 2]
```

**Characteristics**:
- ✅ No duplicates
- ✅ Fast operations O(1) average
- ❌ No ordering
- ❌ Allows one null

### LinkedHashSet

Maintains insertion order.

```java
Set<String> set = new LinkedHashSet<>();
set.add("Banana");
set.add("Apple");
set.add("Cherry");

System.out.println(set);  // [Banana, Apple, Cherry] (insertion order)
```

### TreeSet

Sorted set (natural or custom order).

```java
import java.util.TreeSet;

TreeSet<Integer> set = new TreeSet<>();
set.add(5);
set.add(1);
set.add(3);

System.out.println(set);  // [1, 3, 5] (sorted)

// Navigation
int first = set.first();  // 1
int last = set.last();    // 5
int higher = set.higher(3);  // 5 (next element)
int lower = set.lower(3);    // 1 (previous element)

// Range views
Set<Integer> subset = set.subSet(2, 6);  // [3, 5]
Set<Integer> headSet = set.headSet(3);   // [1]
Set<Integer> tailSet = set.tailSet(3);   // [3, 5]

// Custom comparator
TreeSet<String> names = new TreeSet<>(Comparator.reverseOrder());
names.add("Alice");
names.add("Bob");
System.out.println(names);  // [Bob, Alice]
```

**Characteristics**:
- ✅ Sorted order
- ✅ No duplicates
- ✅ NavigableSet methods
- ❌ Slower than HashSet O(log n)
- ❌ No null values

### HashSet vs LinkedHashSet vs TreeSet

| Feature | HashSet | LinkedHashSet | TreeSet |
|---------|---------|---------------|---------|
| Order | No | Insertion | Sorted |
| Performance | O(1) ⚡ | O(1) ⚡ | O(log n) |
| Null | 1 allowed | 1 allowed | Not allowed |
| Memory | Less | More | More |

## Map Interface

Key-value pairs, no duplicate keys.

### HashMap

Hash table-based implementation.

```java
import java.util.HashMap;
import java.util.Map;

Map<String, Integer> map = new HashMap<>();

// Add/Update
map.put("Alice", 25);
map.put("Bob", 30);
map.put("Alice", 26);  // Updates Alice's value

// Access
int age = map.get("Alice");  // 26
int defaultAge = map.getOrDefault("Charlie", 0);  // 0

// Remove
map.remove("Bob");

// Check
boolean hasKey = map.containsKey("Alice");
boolean hasValue = map.containsValue(25);

// Size
int size = map.size();
boolean empty = map.isEmpty();

// Iterate over keys
for (String key : map.keySet()) {
    System.out.println(key + ": " + map.get(key));
}

// Iterate over values
for (Integer value : map.values()) {
    System.out.println(value);
}

// Iterate over entries (preferred)
for (Map.Entry<String, Integer> entry : map.entrySet()) {
    System.out.println(entry.getKey() + ": " + entry.getValue());
}

// forEach (Java 8+)
map.forEach((key, value) -> {
    System.out.println(key + ": " + value);
});

// Compute if absent
map.computeIfAbsent("Charlie", k -> 28);

// Merge
map.merge("Alice", 1, (oldVal, newVal) -> oldVal + newVal);  // Increment age

// Replace
map.replace("Alice", 27);
map.replace("Alice", 26, 27);  // Only if current value is 26
```

**Characteristics**:
- ✅ Fast operations O(1) average
- ✅ Allows one null key, multiple null values
- ❌ No ordering
- ❌ Not synchronized

### LinkedHashMap

Maintains insertion order.

```java
Map<String, Integer> map = new LinkedHashMap<>();
map.put("Banana", 2);
map.put("Apple", 1);
map.put("Cherry", 3);

// Iteration preserves insertion order
map.forEach((k, v) -> System.out.println(k));
// Output: Banana, Apple, Cherry
```

### TreeMap

Sorted by keys.

```java
import java.util.TreeMap;

TreeMap<String, Integer> map = new TreeMap<>();
map.put("Charlie", 30);
map.put("Alice", 25);
map.put("Bob", 28);

System.out.println(map);  // {Alice=25, Bob=28, Charlie=30}

// Navigation
String firstKey = map.firstKey();   // "Alice"
String lastKey = map.lastKey();     // "Charlie"

Map.Entry<String, Integer> firstEntry = map.firstEntry();
Map.Entry<String, Integer> lastEntry = map.lastEntry();

// Range views
Map<String, Integer> subMap = map.subMap("Alice", "Charlie");
```

**Characteristics**:
- ✅ Sorted by keys
- ✅ NavigableMap methods
- ❌ Slower O(log n)
- ❌ No null keys

### Hashtable (Legacy, avoid)

```java
import java.util.Hashtable;

Hashtable<String, Integer> table = new Hashtable<>();
table.put("A", 1);

// Thread-safe but slow (synchronized methods)
// Use ConcurrentHashMap instead
```

### HashMap vs LinkedHashMap vs TreeMap

| Feature | HashMap | LinkedHashMap | TreeMap |
|---------|---------|---------------|---------|
| Order | No | Insertion | Sorted (keys) |
| Performance | O(1) ⚡ | O(1) ⚡ | O(log n) |
| Null keys | 1 | 1 | 0 |
| Null values | Yes | Yes | Yes |

## Queue Interface

FIFO (First-In-First-Out) operations.

### PriorityQueue

Elements ordered by priority (natural or custom).

```java
import java.util.PriorityQueue;
import java.util.Queue;

Queue<Integer> pq = new PriorityQueue<>();

// Add elements
pq.offer(5);
pq.offer(1);
pq.offer(3);

// Remove in priority order
System.out.println(pq.poll());  // 1 (smallest)
System.out.println(pq.poll());  // 3
System.out.println(pq.poll());  // 5

// Custom comparator (max heap)
PriorityQueue<Integer> maxHeap = new PriorityQueue<>(Comparator.reverseOrder());

// Peek without removing
int top = pq.peek();
```

### ArrayDeque

Double-ended queue, can be used as stack or queue.

```java
import java.util.ArrayDeque;
import java.util.Deque;

Deque<String> deque = new ArrayDeque<>();

// Add
deque.addFirst("A");
deque.addLast("B");
deque.offer("C");  // Same as addLast

// Remove
String first = deque.pollFirst();
String last = deque.pollLast();

// Use as Stack (LIFO)
deque.push("X");
String top = deque.pop();

// Use as Queue (FIFO)
deque.offer("Y");
String front = deque.poll();
```

## Utility Classes

### Collections

Static utility methods.

```java
import java.util.Collections;

List<Integer> list = new ArrayList<>(Arrays.asList(5, 2, 8, 1));

// Sort
Collections.sort(list);  // [1, 2, 5, 8]
Collections.sort(list, Collections.reverseOrder());  // [8, 5, 2, 1]

// Search (must be sorted)
int index = Collections.binarySearch(list, 5);

// Reverse
Collections.reverse(list);

// Shuffle
Collections.shuffle(list);

// Min/Max
int min = Collections.min(list);
int max = Collections.max(list);

// Fill
Collections.fill(list, 0);  // All elements = 0

// Frequency
int count = Collections.frequency(list, 5);

// Synchronized wrapper
List<Integer> syncList = Collections.synchronizedList(list);

// Unmodifiable wrapper
List<Integer> immutableList = Collections.unmodifiableList(list);

// Singleton collections
Set<String> singletonSet = Collections.singleton("only");
List<String> singletonList = Collections.singletonList("only");
```

### Arrays

Static utility methods for arrays.

```java
import java.util.Arrays;

int[] arr = {5, 2, 8, 1, 9};

// Sort
Arrays.sort(arr);  // [1, 2, 5, 8, 9]

// Binary search (must be sorted)
int index = Arrays.binarySearch(arr, 5);

// Fill
Arrays.fill(arr, 0);  // All elements = 0

// Copy
int[] copy = Arrays.copyOf(arr, arr.length);
int[] partial = Arrays.copyOfRange(arr, 1, 3);

// Compare
boolean equal = Arrays.equals(arr, copy);

// Convert to List
List<Integer> list = Arrays.asList(1, 2, 3);  // Fixed-size list

// String
System.out.println(Arrays.toString(arr));  // [1, 2, 5, 8, 9]
```

## Choosing the Right Collection

### Decision Tree

```
Need key-value pairs?
├─ Yes → Map
│  ├─ Need sorting? → TreeMap
│  ├─ Need insertion order? → LinkedHashMap
│  └─ Fast access? → HashMap
└─ No → Collection
   ├─ No duplicates? → Set
   │  ├─ Need sorting? → TreeSet
   │  ├─ Need insertion order? → LinkedHashSet
   │  └─ Fast access? → HashSet
   └─ Allow duplicates? → List/Queue
      ├─ Fast random access? → ArrayList
      ├─ Fast insertion/deletion? → LinkedList
      └─ Priority ordering? → PriorityQueue
```

## Performance Summary

| Collection | Add | Remove | Get | Contains | Memory |
|------------|-----|--------|-----|----------|--------|
| ArrayList | O(1)* | O(n) | O(1) | O(n) | Low |
| LinkedList | O(1) | O(1) | O(n) | O(n) | High |
| HashSet | O(1) | O(1) | N/A | O(1) | Medium |
| TreeSet | O(log n) | O(log n) | N/A | O(log n) | Medium |
| HashMap | O(1) | O(1) | O(1) | O(1) | Medium |
| TreeMap | O(log n) | O(log n) | O(log n) | O(log n) | Medium |

*Amortized

## Common Pitfalls

### 1. ConcurrentModificationException

```java
List<Integer> list = new ArrayList<>(Arrays.asList(1, 2, 3, 4, 5));

// WRONG: Modifying while iterating
for (Integer num : list) {
    if (num % 2 == 0) {
        list.remove(num);  // ConcurrentModificationException!
    }
}

// CORRECT: Use iterator
Iterator<Integer> it = list.iterator();
while (it.hasNext()) {
    if (it.next() % 2 == 0) {
        it.remove();  // Safe removal
    }
}

// CORRECT: Use removeIf (Java 8+)
list.removeIf(num -> num % 2 == 0);
```

### 2. Using == for object comparison

```java
List<String> list = Arrays.asList("hello");

if (list.contains("hello")) {  // Correct: uses equals()
    // Found
}

if (list.get(0) == "hello") {  // WRONG: compares references
    // May not work
}
```

### 3. Not overriding equals() and hashCode()

```java
class Person {
    String name;
    
// If used in HashSet/HashMap, MUST override:
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof Person)) return false;
        Person person = (Person) o;
        return Objects.equals(name, person.name);
    }
    
    @Override
    public int hashCode() {
        return Objects.hash(name);
    }
}
```

---

**Previous**: [← Strings](java-08-strings.md) | **Next**: [Exceptions →](java-10-exceptions.md)
