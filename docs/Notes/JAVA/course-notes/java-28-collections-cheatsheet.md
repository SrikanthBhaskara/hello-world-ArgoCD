# Java Collections Quick Reference

## Collection Types Overview

```
┌─────────────────────────────────────────────────────┐
│              COLLECTION TYPES                       │
├─────────────┬──────────────┬─────────────┬─────────┤
│    LIST     │     SET      │    QUEUE    │   MAP   │
├─────────────┼──────────────┼─────────────┼─────────┤
│ Ordered     │ No Duplicates│    FIFO     │Key-Value│
│ Duplicates  │ Unordered    │  Priority   │ Pairs   │
│ Index-based │              │             │         │
└─────────────┴──────────────┴─────────────┴─────────┘
```

## Quick Selection Guide

| Need | Use |
|------|-----|
| Fast random access | `ArrayList<E>` |
| Fast insertion/deletion | `LinkedList<E>` |
| Unique elements | `HashSet<E>` |
| Sorted unique elements | `TreeSet<E>` |
| Key-value pairs | `HashMap<K,V>` |
| Sorted key-value pairs | `TreeMap<K,V>` |
| Maintain insertion order | `LinkedHashSet<E>` or `LinkedHashMap<K,V>` |
| Thread-safe collection | `ConcurrentHashMap<K,V>` |
| Priority queue | `PriorityQueue<E>` |
| Stack (LIFO) | `ArrayDeque<E>` |
| Queue (FIFO) | `ArrayDeque<E>` or `LinkedList<E>` |

## List Interface

### ArrayList

```java
// Creation
List<String> list = new ArrayList<>();
List<Integer> nums = new ArrayList<>(Arrays.asList(1, 2, 3));

// Basic Operations
list.add("Apple");                // [Apple]
list.add(0, "Banana");            // [Banana, Apple]
list.set(0, "Cherry");            // [Cherry, Apple]
String item = list.get(1);        // "Apple"
list.remove(0);                   // [Apple]
list.remove("Apple");             // []
int size = list.size();
boolean empty = list.isEmpty();
list.clear();

// Bulk Operations
list.addAll(Arrays.asList("A", "B", "C"));
list.containsAll(Arrays.asList("A", "B"));
list.removeAll(Arrays.asList("A", "B"));
list.retainAll(Arrays.asList("C"));

// Search
int index = list.indexOf("Apple");        // -1 if not found
int last = list.lastIndexOf("Apple");
boolean has = list.contains("Apple");

// Conversion
String[] array = list.toArray(new String[0]);
List<String> subList = list.subList(1, 3);

// Iteration
for (String s : list) { }
list.forEach(s -> System.out.println(s));
list.forEach(System.out::println);

// Sorting
Collections.sort(list);
list.sort(Comparator.naturalOrder());
list.sort(Comparator.reverseOrder());
list.sort((a, b) -> a.length() - b.length());

// Other
Collections.reverse(list);
Collections.shuffle(list);
Collections.fill(list, "X");
```

**ArrayList**: `O(1)` get, `O(n)` insert/remove

### LinkedList

```java
LinkedList<String> list = new LinkedList<>();

// Same as ArrayList, plus:
list.addFirst("First");
list.addLast("Last");
String first = list.getFirst();
String last = list.getLast();
list.removeFirst();
list.removeLast();

// Stack operations (LIFO)
list.push("Top");
String top = list.pop();

// Queue operations (FIFO)
list.offer("Element");
String front = list.poll();
String peek = list.peek();
```

**LinkedList**: `O(1)` insert/remove at ends, `O(n)` get

## Set Interface

### HashSet

```java
// Creation
Set<String> set = new HashSet<>();
Set<Integer> nums = new HashSet<>(Arrays.asList(1, 2, 3));

// Basic Operations
set.add("Apple");                 // true (added)
set.add("Apple");                 // false (duplicate)
set.remove("Apple");              // true (removed)
set.contains("Apple");            // false
int size = set.size();
set.clear();

// Set Operations
Set<Integer> a = new HashSet<>(Arrays.asList(1, 2, 3));
Set<Integer> b = new HashSet<>(Arrays.asList(3, 4, 5));

// Union
Set<Integer> union = new HashSet<>(a);
union.addAll(b);                  // {1, 2, 3, 4, 5}

// Intersection
Set<Integer> inter = new HashSet<>(a);
inter.retainAll(b);               // {3}

// Difference
Set<Integer> diff = new HashSet<>(a);
diff.removeAll(b);                // {1, 2}

// Iteration
for (String s : set) { }
set.forEach(System.out::println);
```

**HashSet**: `O(1)` add, remove, contains

### TreeSet

```java
TreeSet<Integer> set = new TreeSet<>();
TreeSet<String> sorted = new TreeSet<>(Comparator.reverseOrder());

// Same as HashSet, plus:
set.add(5);
set.add(1);
set.add(3);                       // Sorted: [1, 3, 5]

int first = set.first();          // 1
int last = set.last();            // 5
int higher = set.higher(3);       // 5 (next element)
int lower = set.lower(3);         // 1 (previous element)
int ceiling = set.ceiling(2);     // 3 (≥ 2)
int floor = set.floor(4);         // 3 (≤ 4)

// Range views
Set<Integer> sub = set.subSet(2, 6);     // [3, 5]
Set<Integer> head = set.headSet(3);      // [1]
Set<Integer> tail = set.tailSet(3);      // [3, 5]
```

**TreeSet**: `O(log n)` add, remove, contains

### LinkedHashSet

```java
Set<String> set = new LinkedHashSet<>();
// Maintains insertion order
set.add("Banana");
set.add("Apple");
// Prints: Banana, Apple (insertion order)
```

## Map Interface

### HashMap

```java
// Creation
Map<String, Integer> map = new HashMap<>();
Map<String, Integer> init = new HashMap<>() {{
    put("A", 1);
    put("B", 2);
}};

// Basic Operations
map.put("Alice", 25);             // null (new entry)
map.put("Alice", 26);             // 25 (updated)
int age = map.get("Alice");       // 26
int def = map.getOrDefault("Bob", 0);  // 0
map.remove("Alice");              // 26 (removed value)
map.containsKey("Alice");         // false
map.containsValue(26);            // false
int size = map.size();
map.clear();

// Compute Operations (Java 8+)
map.computeIfAbsent("Alice", k -> 25);         // Only if absent
map.computeIfPresent("Alice", (k, v) -> v + 1); // Only if present
map.compute("Alice", (k, v) -> (v == null) ? 1 : v + 1);

// Merge
map.merge("Alice", 1, (old, new) -> old + new);  // Increment

// Replace
map.replace("Alice", 27);         // Only if key exists
map.replace("Alice", 26, 27);     // Only if current value is 26

// putIfAbsent
map.putIfAbsent("Bob", 30);       // Only if Bob not present

// Iteration
for (String key : map.keySet()) {
    System.out.println(key + ": " + map.get(key));
}

for (Integer value : map.values()) {
    System.out.println(value);
}

for (Map.Entry<String, Integer> entry : map.entrySet()) {
    System.out.println(entry.getKey() + ": " + entry.getValue());
}

// forEach (Java 8+)
map.forEach((k, v) -> System.out.println(k + ": " + v));

// Conversion
Set<String> keys = map.keySet();
Collection<Integer> values = map.values();
Set<Map.Entry<String, Integer>> entries = map.entrySet();
```

**HashMap**: `O(1)` get, put, remove

### TreeMap

```java
TreeMap<String, Integer> map = new TreeMap<>();

// Same as HashMap, plus:
map.put("Charlie", 30);
map.put("Alice", 25);
map.put("Bob", 28);
// Sorted by keys: {Alice=25, Bob=28, Charlie=30}

String firstKey = map.firstKey();             // "Alice"
String lastKey = map.lastKey();               // "Charlie"
Map.Entry<String, Integer> first = map.firstEntry();
Map.Entry<String, Integer> last = map.lastEntry();

String higher = map.higherKey("Bob");         // "Charlie"
String lower = map.lowerKey("Bob");           // "Alice"

// Range views
Map<String, Integer> sub = map.subMap("Alice", "Charlie");
Map<String, Integer> head = map.headMap("Bob");
Map<String, Integer> tail = map.tailMap("Bob");
```

**TreeMap**: `O(log n)` get, put, remove

### LinkedHashMap

```java
Map<String, Integer> map = new LinkedHashMap<>();
// Maintains insertion order
map.put("Banana", 2);
map.put("Apple", 1);
// Iteration preserves order: Banana, Apple
```

## Queue / Deque

### ArrayDeque

```java
Deque<String> deque = new ArrayDeque<>();

// Queue operations (FIFO)
deque.offer("A");                 // Add to tail
deque.offer("B");
String head = deque.poll();       // Remove from head ("A")
String peek = deque.peek();       // View head ("B")

// Stack operations (LIFO)
deque.push("X");                  // Add to head
String top = deque.pop();         // Remove from head ("X")

// Deque operations
deque.addFirst("First");
deque.addLast("Last");
deque.removeFirst();
deque.removeLast();
String first = deque.getFirst();
String last = deque.getLast();
```

### PriorityQueue

```java
// Min heap (natural order)
PriorityQueue<Integer> pq = new PriorityQueue<>();
pq.offer(5);
pq.offer(1);
pq.offer(3);
int min = pq.poll();              // 1 (smallest)

// Max heap (reverse order)
PriorityQueue<Integer> maxHeap = new PriorityQueue<>(Comparator.reverseOrder());
maxHeap.offer(5);
maxHeap.offer(1);
maxHeap.offer(3);
int max = maxHeap.poll();         // 5 (largest)

// Custom comparator
PriorityQueue<String> byLength = new PriorityQueue<>(
    (a, b) -> a.length() - b.length()
);
```

## Collections Utility

```java
import java.util.Collections;

List<Integer> list = new ArrayList<>(Arrays.asList(5, 2, 8, 1));

// Sort
Collections.sort(list);           // [1, 2, 5, 8]
Collections.sort(list, Comparator.reverseOrder());  // [8, 5, 2, 1]

// Search (must be sorted first)
int index = Collections.binarySearch(list, 5);

// Reverse
Collections.reverse(list);

// Shuffle
Collections.shuffle(list);

// Min / Max
int min = Collections.min(list);
int max = Collections.max(list);

// Fill
Collections.fill(list, 0);

// Frequency
int count = Collections.frequency(list, 5);

// Synchronized wrapper
List<Integer> syncList = Collections.synchronizedList(list);
Map<String, Integer> syncMap = Collections.synchronizedMap(map);
Set<String> syncSet = Collections.synchronizedSet(set);

// Unmodifiable
List<Integer> immutable = Collections.unmodifiableList(list);

// Singleton
Set<String> single = Collections.singleton("only");

// Empty
List<String> empty = Collections.emptyList();
Set<String> emptySet = Collections.emptySet();
Map<String, Integer> emptyMap = Collections.emptyMap();

// Copy
List<Integer> dest = new ArrayList<>(Collections.nCopies(list.size(), 0));
Collections.copy(dest, list);

// Rotate
Collections.rotate(list, 2);      // Shift right by 2

// Swap
Collections.swap(list, 0, 1);

// Replace all
Collections.replaceAll(list, 5, 10);  // Replace all 5s with 10

// Index of sublist
int idx = Collections.indexOfSubList(list, sublist);
```

## Arrays Utility

```java
import java.util.Arrays;

int[] arr = {5, 2, 8, 1, 9};

// Sort
Arrays.sort(arr);                 // [1, 2, 5, 8, 9]

// Search (must be sorted)
int index = Arrays.binarySearch(arr, 5);

// Fill
Arrays.fill(arr, 0);              // All elements = 0

// Copy
int[] copy = Arrays.copyOf(arr, arr.length);
int[] partial = Arrays.copyOfRange(arr, 1, 3);

// Compare
boolean eq = Arrays.equals(arr, copy);
int cmp = Arrays.compare(arr, copy);

// Mismatch
int idx = Arrays.mismatch(arr, copy);  // Java 9+

// Convert to List (fixed-size)
List<Integer> list = Arrays.asList(1, 2, 3);

// Convert to String
String str = Arrays.toString(arr);     // [1, 2, 5, 8, 9]

// 2D array
int[][] matrix = {{1,2},{3,4}};
String s = Arrays.deepToString(matrix);  // [[1, 2], [3, 4]]
boolean eq2 = Arrays.deepEquals(matrix, copy2d);

// Stream (Java 8+)
int sum = Arrays.stream(arr).sum();
int max = Arrays.stream(arr).max().getAsInt();
```

## Performance Cheat Sheet

| Collection | Get | Add | Remove | Contains | Space |
|------------|-----|-----|--------|----------|-------|
| **ArrayList** | O(1) | O(1)* | O(n) | O(n) | Low |
| **LinkedList** | O(n) | O(1) | O(1)** | O(n) | High |
| **HashSet** | - | O(1) | O(1) | O(1) | Medium |
| **LinkedHashSet** | - | O(1) | O(1) | O(1) | High |
| **TreeSet** | - | O(log n) | O(log n) | O(log n) | Medium |
| **HashMap** | O(1) | O(1) | O(1) | O(1) | Medium |
| **LinkedHashMap** | O(1) | O(1) | O(1) | O(1) | High |
| **TreeMap** | O(log n) | O(log n) | O(log n) | O(log n) | Medium |
| **ArrayDeque** | O(1) | O(1) | O(1) | O(n) | Low |
| **PriorityQueue** | O(1) | O(log n) | O(log n) | O(n) | Low |

\* Amortized  
\** At ends

## Common Patterns

### Remove while iterating
```java
// WRONG
for (Integer num : list) {
    if (num % 2 == 0) list.remove(num);  // ConcurrentModificationException
}

// CORRECT
Iterator<Integer> it = list.iterator();
while (it.hasNext()) {
    if (it.next() % 2 == 0) it.remove();
}

// BEST (Java 8+)
list.removeIf(num -> num % 2 == 0);
```

### Count frequency
```java
Map<String, Integer> freq = new HashMap<>();
for (String word : words) {
    freq.put(word, freq.getOrDefault(word, 0) + 1);
    // OR: freq.merge(word, 1, Integer::sum);
}
```

### Group by
```java
Map<String, List<Person>> byCity = people.stream()
    .collect(Collectors.groupingBy(Person::getCity));
```

### Sort with custom comparator
```java
list.sort(Comparator.comparing(Person::getAge));
list.sort(Comparator.comparing(Person::getName).reversed());
list.sort(Comparator.comparing(Person::getAge)
                    .thenComparing(Person::getName));
```

---

**See Also**: [Collections Framework](java-09-collections.md) | [Interview Prep](java-29-interview-prep.md)
