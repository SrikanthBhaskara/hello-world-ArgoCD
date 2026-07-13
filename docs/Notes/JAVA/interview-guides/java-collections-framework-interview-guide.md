# Java Collections Framework - Complete Interview Guide

> **For 5+ Year Experienced Backend Developers**
> 
> Complete guide covering all aspects of Java Collections Framework with real-world examples, interview questions, traps, and coding problems.

---

## Table of Contents

1. [Collections Framework Overview](#1-collections-framework-overview)
2. [List Implementations](#2-list-implementations)
3. [Set Implementations](#3-set-implementations)
4. [Map Implementations](#4-map-implementations)
5. [Queue and Deque](#5-queue-and-deque)
6. [Concurrent Collections](#6-concurrent-collections)
7. [Comparator and Comparable](#7-comparator-and-comparable)
8. [Collections Utility Class](#8-collections-utility-class)
9. [Interview Questions](#9-interview-questions)
10. [Interview Traps & Edge Cases](#10-interview-traps--edge-cases)
11. [Coding Problems](#11-coding-problems)

---

# 1. COLLECTIONS FRAMEWORK OVERVIEW

## 1.1 Collection Hierarchy

```
                          Iterable<E>
                               |
                          Collection<E>
                               |
        +----------------------+----------------------+
        |                      |                      |
     List<E>                Set<E>                Queue<E>
        |                      |                      |
   +---------+          +------+------+         +-----+-----+
   |         |          |             |         |           |
ArrayList Vector    HashSet      SortedSet   PriorityQueue Deque
LinkedList Stack   LinkedHashSet    |                      |
                   EnumSet        TreeSet             ArrayDeque
                                                      LinkedList

                          Map<E>
                            |
        +-------------------+-------------------+
        |                   |                   |
     HashMap          SortedMap            WeakHashMap
        |                   |              IdentityHashMap
   LinkedHashMap         TreeMap
   EnumMap
   Hashtable
```

## 1.2 Interface Summary

```java
public class CollectionsOverview {
    
    public void demonstrateInterfaces() {
        
        // 1. Collection - Root interface
        Collection<String> collection = new ArrayList<>();
        collection.add("item");
        collection.remove("item");
        collection.contains("item");
        collection.size();
        collection.isEmpty();
        collection.clear();
        
        // 2. List - Ordered collection (allows duplicates)
        List<String> list = new ArrayList<>();
        list.add("A");
        list.add(0, "B");  // Add at index
        list.get(0);       // Get by index
        list.set(0, "C");  // Replace
        list.indexOf("C"); // Find index
        
        // 3. Set - No duplicates
        Set<String> set = new HashSet<>();
        set.add("A");
        set.add("A");  // Duplicate ignored
        System.out.println(set.size());  // 1
        
        // 4. Queue - FIFO operations
        Queue<String> queue = new LinkedList<>();
        queue.offer("A");  // Add to tail
        queue.poll();      // Remove from head
        queue.peek();      // View head without removing
        
        // 5. Deque - Double-ended queue
        Deque<String> deque = new ArrayDeque<>();
        deque.offerFirst("A");  // Add to head
        deque.offerLast("B");   // Add to tail
        deque.pollFirst();      // Remove from head
        deque.pollLast();       // Remove from tail
        
        // 6. Map - Key-value pairs
        Map<String, Integer> map = new HashMap<>();
        map.put("A", 1);
        map.get("A");
        map.containsKey("A");
        map.containsValue(1);
        map.remove("A");
    }
}
```

## 1.3 Key Characteristics

```java
public class CollectionCharacteristics {
    
    public void compareCollectionTypes() {
        
        // ArrayList: Fast random access, slow insertion/deletion
        List<String> arrayList = new ArrayList<>();
        arrayList.add("Item");      // O(1) amortized
        arrayList.get(0);           // O(1)
        arrayList.remove(0);        // O(n) - shifts elements
        
        // LinkedList: Slow access, fast insertion/deletion
        List<String> linkedList = new LinkedList<>();
        linkedList.add("Item");     // O(1)
        linkedList.get(0);          // O(n) - traverses list
        linkedList.remove(0);       // O(1)
        
        // HashSet: Fast add/contains, no order
        Set<String> hashSet = new HashSet<>();
        hashSet.add("Item");        // O(1) average
        hashSet.contains("Item");   // O(1) average
        // No get() method!
        
        // TreeSet: Sorted, slower operations
        Set<String> treeSet = new TreeSet<>();
        treeSet.add("Item");        // O(log n)
        treeSet.contains("Item");   // O(log n)
        
        // HashMap: Fast key-based operations
        Map<String, String> hashMap = new HashMap<>();
        hashMap.put("key", "value"); // O(1) average
        hashMap.get("key");          // O(1) average
        
        // TreeMap: Sorted keys, slower
        Map<String, String> treeMap = new TreeMap<>();
        treeMap.put("key", "value"); // O(log n)
        treeMap.get("key");          // O(log n)
    }
}
```

---

# 2. LIST IMPLEMENTATIONS

## 2.1 ArrayList vs LinkedList vs Vector

```java
import java.util.*;

public class ListComparison {
    
    // ArrayList - Resizable array implementation
    public void arrayListExample() {
        ArrayList<String> list = new ArrayList<>(10);  // Initial capacity
        
        // Adding elements
        list.add("Java");           // O(1) amortized
        list.add(0, "Python");      // O(n) - shifts elements
        list.addAll(Arrays.asList("C++", "Go"));
        
        // Accessing elements
        String first = list.get(0);  // O(1) - direct array access
        
        // Removing elements
        list.remove(0);              // O(n) - shifts elements
        list.remove("Java");         // O(n) - search + shift
        
        // Searching
        int index = list.indexOf("Go");     // O(n)
        boolean contains = list.contains("Python");  // O(n)
        
        // Iteration
        for (String lang : list) {
            System.out.println(lang);
        }
        
        // Convert to array
        String[] array = list.toArray(new String[0]);
    }
    
    // LinkedList - Doubly-linked list implementation
    public void linkedListExample() {
        LinkedList<String> list = new LinkedList<>();
        
        // Adding elements
        list.add("Java");           // O(1) - add to tail
        list.addFirst("Python");    // O(1) - add to head
        list.addLast("C++");        // O(1) - add to tail
        list.add(1, "Go");          // O(n) - traverse to index
        
        // Accessing elements
        String first = list.getFirst();  // O(1)
        String last = list.getLast();    // O(1)
        String at2 = list.get(2);        // O(n) - traverse
        
        // Removing elements
        list.removeFirst();         // O(1)
        list.removeLast();          // O(1)
        list.remove(1);             // O(n) - traverse
        
        // As Queue
        list.offer("Item");         // Add to tail
        list.poll();                // Remove from head
        list.peek();                // View head
        
        // As Deque
        list.offerFirst("Head");
        list.offerLast("Tail");
        list.pollFirst();
        list.pollLast();
    }
    
    // Vector - Synchronized ArrayList (legacy)
    public void vectorExample() {
        Vector<String> vector = new Vector<>(10, 5);  // Initial, increment
        
        // All methods are synchronized
        vector.add("Java");         // Thread-safe
        vector.get(0);              // Thread-safe
        
        // Legacy methods
        vector.addElement("Python");
        vector.elementAt(0);
        vector.firstElement();
        vector.lastElement();
        
        // Stack extends Vector
        Stack<String> stack = new Stack<>();
        stack.push("Item");
        stack.pop();
        stack.peek();
    }
}
```

## 2.2 ArrayList Internal Working

```java
public class ArrayListInternals {
    
    // Simplified ArrayList implementation
    public static class SimpleArrayList<E> {
        private Object[] elements;
        private int size;
        private static final int DEFAULT_CAPACITY = 10;
        
        public SimpleArrayList() {
            elements = new Object[DEFAULT_CAPACITY];
            size = 0;
        }
        
        public boolean add(E element) {
            ensureCapacity();
            elements[size++] = element;
            return true;
        }
        
        public void add(int index, E element) {
            if (index < 0 || index > size) {
                throw new IndexOutOfBoundsException();
            }
            
            ensureCapacity();
            
            // Shift elements to right
            System.arraycopy(elements, index, elements, index + 1, size - index);
            elements[index] = element;
            size++;
        }
        
        @SuppressWarnings("unchecked")
        public E get(int index) {
            if (index < 0 || index >= size) {
                throw new IndexOutOfBoundsException();
            }
            return (E) elements[index];
        }
        
        public E remove(int index) {
            if (index < 0 || index >= size) {
                throw new IndexOutOfBoundsException();
            }
            
            @SuppressWarnings("unchecked")
            E oldValue = (E) elements[index];
            
            // Shift elements to left
            int numMoved = size - index - 1;
            if (numMoved > 0) {
                System.arraycopy(elements, index + 1, elements, index, numMoved);
            }
            
            elements[--size] = null;  // Clear reference
            return oldValue;
        }
        
        private void ensureCapacity() {
            if (size == elements.length) {
                // Grow by 50%
                int newCapacity = elements.length + (elements.length >> 1);
                elements = Arrays.copyOf(elements, newCapacity);
            }
        }
        
        public int size() {
            return size;
        }
    }
    
    // Demonstrating capacity and growth
    public void demonstrateGrowth() {
        ArrayList<Integer> list = new ArrayList<>(2);
        
        System.out.println("Adding elements...");
        for (int i = 0; i < 10; i++) {
            list.add(i);
            // Capacity grows: 2 -> 3 -> 4 -> 6 -> 9 -> 13...
        }
        
        // Pre-size if you know the size
        ArrayList<Integer> presized = new ArrayList<>(1000);
        for (int i = 0; i < 1000; i++) {
            presized.add(i);  // No resizing needed
        }
    }
}
```

## 2.3 Real-World Example: Task Management System

```java
import java.time.LocalDateTime;
import java.util.*;

public class TaskManagementSystem {
    
    // Task entity
    static class Task {
        private String id;
        private String title;
        private String description;
        private TaskPriority priority;
        private TaskStatus status;
        private LocalDateTime createdAt;
        private LocalDateTime dueDate;
        
        public Task(String id, String title, TaskPriority priority) {
            this.id = id;
            this.title = title;
            this.priority = priority;
            this.status = TaskStatus.TODO;
            this.createdAt = LocalDateTime.now();
        }
        
        // Getters and setters
        public String getId() { return id; }
        public String getTitle() { return title; }
        public TaskPriority getPriority() { return priority; }
        public TaskStatus getStatus() { return status; }
        public void setStatus(TaskStatus status) { this.status = status; }
        public LocalDateTime getDueDate() { return dueDate; }
        public void setDueDate(LocalDateTime dueDate) { this.dueDate = dueDate; }
        
        @Override
        public String toString() {
            return String.format("[%s] %s - %s (%s)", id, title, priority, status);
        }
    }
    
    enum TaskPriority { LOW, MEDIUM, HIGH, CRITICAL }
    enum TaskStatus { TODO, IN_PROGRESS, DONE, CANCELLED }
    
    // Task manager using ArrayList
    static class TaskManager {
        private List<Task> tasks;
        
        public TaskManager() {
            this.tasks = new ArrayList<>();
        }
        
        // Add task
        public void addTask(Task task) {
            tasks.add(task);
        }
        
        // Get task by ID
        public Task getTaskById(String id) {
            for (Task task : tasks) {
                if (task.getId().equals(id)) {
                    return task;
                }
            }
            return null;
        }
        
        // Get tasks by status
        public List<Task> getTasksByStatus(TaskStatus status) {
            List<Task> result = new ArrayList<>();
            for (Task task : tasks) {
                if (task.getStatus() == status) {
                    result.add(task);
                }
            }
            return result;
        }
        
        // Get tasks by priority
        public List<Task> getTasksByPriority(TaskPriority priority) {
            List<Task> result = new ArrayList<>();
            for (Task task : tasks) {
                if (task.getPriority() == priority) {
                    result.add(task);
                }
            }
            return result;
        }
        
        // Get overdue tasks
        public List<Task> getOverdueTasks() {
            LocalDateTime now = LocalDateTime.now();
            List<Task> overdue = new ArrayList<>();
            
            for (Task task : tasks) {
                if (task.getDueDate() != null && 
                    task.getDueDate().isBefore(now) &&
                    task.getStatus() != TaskStatus.DONE) {
                    overdue.add(task);
                }
            }
            return overdue;
        }
        
        // Update task status
        public boolean updateTaskStatus(String id, TaskStatus newStatus) {
            Task task = getTaskById(id);
            if (task != null) {
                task.setStatus(newStatus);
                return true;
            }
            return false;
        }
        
        // Remove completed tasks
        public int removeCompletedTasks() {
            List<Task> toRemove = new ArrayList<>();
            for (Task task : tasks) {
                if (task.getStatus() == TaskStatus.DONE) {
                    toRemove.add(task);
                }
            }
            tasks.removeAll(toRemove);
            return toRemove.size();
        }
        
        // Sort tasks by priority
        public void sortByPriority() {
            tasks.sort((t1, t2) -> t2.getPriority().compareTo(t1.getPriority()));
        }
        
        // Sort tasks by due date
        public void sortByDueDate() {
            tasks.sort((t1, t2) -> {
                if (t1.getDueDate() == null) return 1;
                if (t2.getDueDate() == null) return -1;
                return t1.getDueDate().compareTo(t2.getDueDate());
            });
        }
        
        // Get all tasks
        public List<Task> getAllTasks() {
            return new ArrayList<>(tasks);  // Return copy
        }
        
        // Get statistics
        public Map<TaskStatus, Integer> getStatistics() {
            Map<TaskStatus, Integer> stats = new EnumMap<>(TaskStatus.class);
            for (TaskStatus status : TaskStatus.values()) {
                stats.put(status, 0);
            }
            
            for (Task task : tasks) {
                stats.put(task.getStatus(), stats.get(task.getStatus()) + 1);
            }
            return stats;
        }
    }
    
    // Usage
    public static void main(String[] args) {
        TaskManager manager = new TaskManager();
        
        // Add tasks
        Task task1 = new Task("T001", "Implement login", TaskPriority.HIGH);
        task1.setDueDate(LocalDateTime.now().plusDays(2));
        
        Task task2 = new Task("T002", "Write unit tests", TaskPriority.MEDIUM);
        task2.setDueDate(LocalDateTime.now().plusDays(5));
        
        Task task3 = new Task("T003", "Fix bug #123", TaskPriority.CRITICAL);
        task3.setDueDate(LocalDateTime.now().minusDays(1));  // Overdue
        
        Task task4 = new Task("T004", "Update documentation", TaskPriority.LOW);
        
        manager.addTask(task1);
        manager.addTask(task2);
        manager.addTask(task3);
        manager.addTask(task4);
        
        // Get tasks by status
        System.out.println("TODO tasks:");
        manager.getTasksByStatus(TaskStatus.TODO).forEach(System.out::println);
        
        // Update status
        manager.updateTaskStatus("T001", TaskStatus.IN_PROGRESS);
        manager.updateTaskStatus("T004", TaskStatus.DONE);
        
        // Get overdue tasks
        System.out.println("\nOverdue tasks:");
        manager.getOverdueTasks().forEach(System.out::println);
        
        // Sort by priority
        manager.sortByPriority();
        System.out.println("\nTasks by priority:");
        manager.getAllTasks().forEach(System.out::println);
        
        // Statistics
        System.out.println("\nStatistics:");
        manager.getStatistics().forEach((status, count) -> 
            System.out.println(status + ": " + count));
        
        // Remove completed
        int removed = manager.removeCompletedTasks();
        System.out.println("\nRemoved " + removed + " completed tasks");
    }
}
```

---

# 3. SET IMPLEMENTATIONS

## 3.1 HashSet vs LinkedHashSet vs TreeSet

```java
import java.util.*;

public class SetComparison {
    
    // HashSet - Unordered, fastest
    public void hashSetExample() {
        HashSet<String> set = new HashSet<>();
        
        // Adding elements
        set.add("Java");        // O(1) average
        set.add("Python");
        set.add("Java");        // Duplicate ignored
        
        System.out.println(set.size());  // 2
        
        // Order not guaranteed
        for (String lang : set) {
            System.out.println(lang);  // Random order
        }
        
        // Contains check
        if (set.contains("Java")) {  // O(1) average
            System.out.println("Found Java");
        }
        
        // Removing
        set.remove("Python");   // O(1) average
        
        // Bulk operations
        Set<String> set2 = new HashSet<>(Arrays.asList("C++", "Go"));
        set.addAll(set2);       // Union
        set.retainAll(set2);    // Intersection
        set.removeAll(set2);    // Difference
    }
    
    // LinkedHashSet - Insertion order preserved
    public void linkedHashSetExample() {
        LinkedHashSet<String> set = new LinkedHashSet<>();
        
        set.add("Java");
        set.add("Python");
        set.add("C++");
        set.add("Go");
        
        // Iteration in insertion order
        for (String lang : set) {
            System.out.println(lang);  // Java, Python, C++, Go
        }
        
        // Slightly slower than HashSet due to maintaining linked list
        // Add/Remove: O(1)
        // Memory overhead for linked list pointers
    }
    
    // TreeSet - Sorted, slower operations
    public void treeSetExample() {
        TreeSet<String> set = new TreeSet<>();
        
        set.add("Java");
        set.add("Python");
        set.add("C++");
        set.add("Go");
        
        // Iteration in sorted order
        for (String lang : set) {
            System.out.println(lang);  // C++, Go, Java, Python
        }
        
        // NavigableSet operations
        System.out.println("First: " + set.first());      // C++
        System.out.println("Last: " + set.last());        // Python
        System.out.println("Lower than Java: " + set.lower("Java"));  // Go
        System.out.println("Higher than Java: " + set.higher("Java")); // Python
        
        // Subset operations
        SortedSet<String> subset = set.subSet("Go", "Python");  // Go, Java
        SortedSet<String> headSet = set.headSet("Java");        // C++, Go
        SortedSet<String> tailSet = set.tailSet("Java");        // Java, Python
        
        // Descending order
        NavigableSet<String> descending = set.descendingSet();
        System.out.println(descending);  // [Python, Java, Go, C++]
    }
    
    // Custom comparator for TreeSet
    public void treeSetWithComparator() {
        // Sort by length, then alphabetically
        TreeSet<String> set = new TreeSet<>((s1, s2) -> {
            int lengthCompare = Integer.compare(s1.length(), s2.length());
            return lengthCompare != 0 ? lengthCompare : s1.compareTo(s2);
        });
        
        set.add("Python");
        set.add("Go");
        set.add("Java");
        set.add("JavaScript");
        
        System.out.println(set);  // [Go, Java, Python, JavaScript]
    }
}
```

## 3.2 HashSet Internal Working

```java
import java.util.*;

public class HashSetInternals {
    
    // HashSet uses HashMap internally
    public void understandHashSet() {
        // HashSet is backed by HashMap
        // Elements are stored as keys, with a dummy Object as value
        
        HashSet<String> set = new HashSet<>();
        // Internally: HashMap<String, Object> map = new HashMap<>();
        
        set.add("Java");
        // Internally: map.put("Java", PRESENT);
        // where PRESENT is: private static final Object PRESENT = new Object();
        
        set.contains("Java");
        // Internally: map.containsKey("Java");
        
        set.remove("Java");
        // Internally: map.remove("Java");
    }
    
    // Simplified HashSet implementation
    public static class SimpleHashSet<E> {
        private HashMap<E, Object> map;
        private static final Object PRESENT = new Object();
        
        public SimpleHashSet() {
            map = new HashMap<>();
        }
        
        public boolean add(E element) {
            return map.put(element, PRESENT) == null;
        }
        
        public boolean contains(E element) {
            return map.containsKey(element);
        }
        
        public boolean remove(E element) {
            return map.remove(element) == PRESENT;
        }
        
        public int size() {
            return map.size();
        }
        
        public void clear() {
            map.clear();
        }
    }
    
    // hashCode() and equals() importance
    public void demonstrateHashCodeEquals() {
        
        class Person {
            String name;
            int age;
            
            Person(String name, int age) {
                this.name = name;
                this.age = age;
            }
            
            // Without proper hashCode() and equals()
            // Set won't work correctly
        }
        
        HashSet<Person> set1 = new HashSet<>();
        Person p1 = new Person("John", 30);
        Person p2 = new Person("John", 30);
        
        set1.add(p1);
        set1.add(p2);
        System.out.println("Without hashCode/equals: " + set1.size());  // 2 (wrong!)
        
        // With proper hashCode() and equals()
        class PersonProper {
            String name;
            int age;
            
            PersonProper(String name, int age) {
                this.name = name;
                this.age = age;
            }
            
            @Override
            public boolean equals(Object o) {
                if (this == o) return true;
                if (o == null || getClass() != o.getClass()) return false;
                PersonProper that = (PersonProper) o;
                return age == that.age && Objects.equals(name, that.name);
            }
            
            @Override
            public int hashCode() {
                return Objects.hash(name, age);
            }
        }
        
        HashSet<PersonProper> set2 = new HashSet<>();
        PersonProper p3 = new PersonProper("John", 30);
        PersonProper p4 = new PersonProper("John", 30);
        
        set2.add(p3);
        set2.add(p4);
        System.out.println("With hashCode/equals: " + set2.size());  // 1 (correct!)
    }
}
```

## 3.3 Real-World Example: Unique User Tracking

```java
import java.time.LocalDateTime;
import java.util.*;

public class UniqueUserTracking {
    
    // User session
    static class UserSession {
        private String userId;
        private String sessionId;
        private String ipAddress;
        private LocalDateTime loginTime;
        
        public UserSession(String userId, String sessionId, String ipAddress) {
            this.userId = userId;
            this.sessionId = sessionId;
            this.ipAddress = ipAddress;
            this.loginTime = LocalDateTime.now();
        }
        
        public String getUserId() { return userId; }
        public String getSessionId() { return sessionId; }
        public String getIpAddress() { return ipAddress; }
        public LocalDateTime getLoginTime() { return loginTime; }
        
        @Override
        public boolean equals(Object o) {
            if (this == o) return true;
            if (o == null || getClass() != o.getClass()) return false;
            UserSession that = (UserSession) o;
            return Objects.equals(sessionId, that.sessionId);
        }
        
        @Override
        public int hashCode() {
            return Objects.hash(sessionId);
        }
        
        @Override
        public String toString() {
            return String.format("Session[user=%s, session=%s, ip=%s]",
                               userId, sessionId, ipAddress);
        }
    }
    
    // Session manager
    static class SessionManager {
        // Active sessions (unique by session ID)
        private Set<UserSession> activeSessions;
        
        // Unique users currently online (unique by user ID)
        private Set<String> onlineUsers;
        
        // Track unique IPs
        private Set<String> accessedFromIPs;
        
        // Login history (ordered by time)
        private LinkedHashSet<String> loginHistory;
        
        public SessionManager() {
            this.activeSessions = new HashSet<>();
            this.onlineUsers = new HashSet<>();
            this.accessedFromIPs = new HashSet<>();
            this.loginHistory = new LinkedHashSet<>();
        }
        
        // Add new session
        public boolean login(UserSession session) {
            boolean added = activeSessions.add(session);
            if (added) {
                onlineUsers.add(session.getUserId());
                accessedFromIPs.add(session.getIpAddress());
                loginHistory.add(session.getUserId());
                return true;
            }
            return false;  // Session already exists
        }
        
        // Remove session
        public boolean logout(String sessionId) {
            UserSession toRemove = null;
            for (UserSession session : activeSessions) {
                if (session.getSessionId().equals(sessionId)) {
                    toRemove = session;
                    break;
                }
            }
            
            if (toRemove != null) {
                activeSessions.remove(toRemove);
                
                // Check if user has other active sessions
                boolean hasOtherSessions = false;
                for (UserSession session : activeSessions) {
                    if (session.getUserId().equals(toRemove.getUserId())) {
                        hasOtherSessions = true;
                        break;
                    }
                }
                
                if (!hasOtherSessions) {
                    onlineUsers.remove(toRemove.getUserId());
                }
                
                return true;
            }
            return false;
        }
        
        // Get online user count
        public int getOnlineUserCount() {
            return onlineUsers.size();
        }
        
        // Get total session count
        public int getActiveSessionCount() {
            return activeSessions.size();
        }
        
        // Check if user is online
        public boolean isUserOnline(String userId) {
            return onlineUsers.contains(userId);
        }
        
        // Get sessions for a user
        public Set<UserSession> getUserSessions(String userId) {
            Set<UserSession> userSessions = new HashSet<>();
            for (UserSession session : activeSessions) {
                if (session.getUserId().equals(userId)) {
                    userSessions.add(session);
                }
            }
            return userSessions;
        }
        
        // Get unique IP count
        public int getUniqueIPCount() {
            return accessedFromIPs.size();
        }
        
        // Get recent logins (maintains order)
        public List<String> getRecentLogins(int limit) {
            List<String> recent = new ArrayList<>();
            int count = 0;
            // LinkedHashSet maintains insertion order
            for (String userId : loginHistory) {
                if (count++ >= limit) break;
                recent.add(userId);
            }
            Collections.reverse(recent);  // Most recent first
            return recent;
        }
        
        // Find users from same IP
        public Set<String> getUsersFromIP(String ipAddress) {
            Set<String> users = new HashSet<>();
            for (UserSession session : activeSessions) {
                if (session.getIpAddress().equals(ipAddress)) {
                    users.add(session.getUserId());
                }
            }
            return users;
        }
        
        // Detect suspicious activity (multiple users from same IP)
        public Map<String, Set<String>> detectSuspiciousIPs() {
            Map<String, Set<String>> ipToUsers = new HashMap<>();
            
            for (UserSession session : activeSessions) {
                ipToUsers.computeIfAbsent(session.getIpAddress(), k -> new HashSet<>())
                        .add(session.getUserId());
            }
            
            // Filter IPs with multiple users
            Map<String, Set<String>> suspicious = new HashMap<>();
            for (Map.Entry<String, Set<String>> entry : ipToUsers.entrySet()) {
                if (entry.getValue().size() > 1) {
                    suspicious.put(entry.getKey(), entry.getValue());
                }
            }
            
            return suspicious;
        }
    }
    
    // Usage
    public static void main(String[] args) {
        SessionManager manager = new SessionManager();
        
        // Simulate logins
        manager.login(new UserSession("user1", "sess1", "192.168.1.1"));
        manager.login(new UserSession("user1", "sess2", "192.168.1.2"));  // Same user, different device
        manager.login(new UserSession("user2", "sess3", "192.168.1.1"));  // Different user, same IP
        manager.login(new UserSession("user3", "sess4", "192.168.1.3"));
        
        // Try duplicate session
        boolean duplicate = manager.login(new UserSession("user1", "sess1", "192.168.1.1"));
        System.out.println("Duplicate session added: " + duplicate);  // false
        
        // Statistics
        System.out.println("Online users: " + manager.getOnlineUserCount());        // 3
        System.out.println("Active sessions: " + manager.getActiveSessionCount());  // 4
        System.out.println("Unique IPs: " + manager.getUniqueIPCount());            // 3
        
        // Check specific user
        System.out.println("Is user1 online? " + manager.isUserOnline("user1"));  // true
        System.out.println("user1 sessions: " + manager.getUserSessions("user1").size());  // 2
        
        // Detect suspicious activity
        System.out.println("\nSuspicious IPs (multiple users):");
        manager.detectSuspiciousIPs().forEach((ip, users) -> 
            System.out.println(ip + " -> " + users));
        
        // Logout
        manager.logout("sess1");
        System.out.println("\nAfter logout:");
        System.out.println("Is user1 online? " + manager.isUserOnline("user1"));  // true (has sess2)
        System.out.println("Active sessions: " + manager.getActiveSessionCount());  // 3
        
        manager.logout("sess2");
        System.out.println("Is user1 online? " + manager.isUserOnline("user1"));  // false (no sessions)
    }
}
```

---

# 4. MAP IMPLEMENTATIONS

## 4.1 HashMap vs LinkedHashMap vs TreeMap vs Hashtable

```java
import java.util.*;

public class MapComparison {
    
    // HashMap - Unordered, fastest
    public void hashMapExample() {
        HashMap<String, Integer> map = new HashMap<>();
        
        // Adding entries
        map.put("Java", 1995);          // O(1) average
        map.put("Python", 1991);
        map.put("C++", 1985);
        
        // Updating
        map.put("Java", 1996);          // Overwrites
        
        // Getting values
        Integer year = map.get("Java"); // O(1) average
        Integer defaultVal = map.getOrDefault("Go", 0);
        
        // Checking existence
        boolean hasKey = map.containsKey("Python");     // O(1) average
        boolean hasValue = map.containsValue(1991);     // O(n)
        
        // Removing
        map.remove("C++");              // O(1) average
        
        // Iteration (random order)
        for (Map.Entry<String, Integer> entry : map.entrySet()) {
            System.out.println(entry.getKey() + " -> " + entry.getValue());
        }
        
        // Keys and values
        Set<String> keys = map.keySet();
        Collection<Integer> values = map.values();
        
        // Compute operations (Java 8+)
        map.putIfAbsent("Go", 2009);
        map.computeIfAbsent("Rust", k -> 2010);
        map.computeIfPresent("Java", (k, v) -> v + 1);
        map.compute("Python", (k, v) -> v == null ? 1991 : v + 1);
        map.merge("Java", 1, Integer::sum);
    }
    
    // LinkedHashMap - Insertion order preserved
    public void linkedHashMapExample() {
        LinkedHashMap<String, Integer> map = new LinkedHashMap<>();
        
        map.put("Java", 1995);
        map.put("Python", 1991);
        map.put("C++", 1985);
        
        // Iteration in insertion order
        for (String key : map.keySet()) {
            System.out.println(key);  // Java, Python, C++
        }
        
        // Access order mode (for LRU cache)
        LinkedHashMap<String, Integer> lruMap = new LinkedHashMap<>(16, 0.75f, true);
        lruMap.put("A", 1);
        lruMap.put("B", 2);
        lruMap.put("C", 3);
        
        lruMap.get("A");  // Access A, moves to end
        System.out.println(lruMap.keySet());  // [B, C, A]
    }
    
    // TreeMap - Sorted by keys
    public void treeMapExample() {
        TreeMap<String, Integer> map = new TreeMap<>();
        
        map.put("Java", 1995);
        map.put("Python", 1991);
        map.put("C++", 1985);
        map.put("Go", 2009);
        
        // Iteration in sorted order
        for (String key : map.keySet()) {
            System.out.println(key);  // C++, Go, Java, Python
        }
        
        // NavigableMap operations
        System.out.println("First key: " + map.firstKey());     // C++
        System.out.println("Last key: " + map.lastKey());       // Python
        System.out.println("Lower than Java: " + map.lowerKey("Java"));   // Go
        System.out.println("Higher than Java: " + map.higherKey("Java")); // Python
        
        // First/last entry
        Map.Entry<String, Integer> firstEntry = map.firstEntry();
        Map.Entry<String, Integer> lastEntry = map.lastEntry();
        
        // Submap operations
        SortedMap<String, Integer> subMap = map.subMap("Go", "Python");  // Go, Java
        SortedMap<String, Integer> headMap = map.headMap("Java");        // C++, Go
        SortedMap<String, Integer> tailMap = map.tailMap("Java");        // Java, Python
        
        // Descending map
        NavigableMap<String, Integer> descending = map.descendingMap();
    }
    
    // Hashtable - Synchronized, legacy (avoid using)
    public void hashtableExample() {
        Hashtable<String, Integer> table = new Hashtable<>();
        
        // Similar to HashMap but:
        // - Synchronized (thread-safe but slow)
        // - Doesn't allow null keys or values
        // - Legacy class
        
        table.put("Java", 1995);
        // table.put(null, 1);     // NullPointerException
        // table.put("Key", null);  // NullPointerException
        
        // Use ConcurrentHashMap instead for thread-safety
    }
    
    // Custom comparator for TreeMap
    public void treeMapWithComparator() {
        // Sort by length descending, then alphabetically
        TreeMap<String, Integer> map = new TreeMap<>((s1, s2) -> {
            int lengthCompare = Integer.compare(s2.length(), s1.length());
            return lengthCompare != 0 ? lengthCompare : s1.compareTo(s2);
        });
        
        map.put("JavaScript", 1995);
        map.put("Go", 2009);
        map.put("Java", 1995);
        map.put("Python", 1991);
        
        System.out.println(map.keySet());  // [JavaScript, Python, Java, Go]
    }
}
```

## 4.2 HashMap Internal Working

```java
import java.util.*;

public class HashMapInternals {
    
    /* HashMap Structure:
     * - Array of buckets (Node<K,V>[] table)
     * - Each bucket is a linked list or tree (if size > 8)
     * - Default capacity: 16
     * - Load factor: 0.75 (resize when 75% full)
     * - Capacity doubles on resize
     */
    
    // Simplified Node class
    static class Node<K, V> {
        final int hash;
        final K key;
        V value;
        Node<K, V> next;
        
        Node(int hash, K key, V value, Node<K, V> next) {
            this.hash = hash;
            this.key = key;
            this.value = value;
            this.next = next;
        }
    }
    
    // Simplified HashMap implementation
    public static class SimpleHashMap<K, V> {
        private Node<K, V>[] table;
        private int size;
        private static final int DEFAULT_CAPACITY = 16;
        private static final float LOAD_FACTOR = 0.75f;
        
        @SuppressWarnings("unchecked")
        public SimpleHashMap() {
            table = (Node<K, V>[]) new Node[DEFAULT_CAPACITY];
            size = 0;
        }
        
        // Hash function
        private int hash(K key) {
            if (key == null) return 0;
            int h = key.hashCode();
            return h ^ (h >>> 16);  // XOR with upper bits
        }
        
        // Get bucket index
        private int indexFor(int hash, int length) {
            return hash & (length - 1);  // Equivalent to hash % length
        }
        
        // Put operation
        public V put(K key, V value) {
            int hash = hash(key);
            int index = indexFor(hash, table.length);
            
            // Check if key exists
            for (Node<K, V> node = table[index]; node != null; node = node.next) {
                if (node.hash == hash && Objects.equals(node.key, key)) {
                    V oldValue = node.value;
                    node.value = value;  // Update existing
                    return oldValue;
                }
            }
            
            // Add new node at head of bucket
            Node<K, V> newNode = new Node<>(hash, key, value, table[index]);
            table[index] = newNode;
            size++;
            
            // Resize if needed
            if (size > table.length * LOAD_FACTOR) {
                resize();
            }
            
            return null;
        }
        
        // Get operation
        public V get(K key) {
            int hash = hash(key);
            int index = indexFor(hash, table.length);
            
            for (Node<K, V> node = table[index]; node != null; node = node.next) {
                if (node.hash == hash && Objects.equals(node.key, key)) {
                    return node.value;
                }
            }
            
            return null;
        }
        
        // Remove operation
        public V remove(K key) {
            int hash = hash(key);
            int index = indexFor(hash, table.length);
            
            Node<K, V> prev = null;
            Node<K, V> node = table[index];
            
            while (node != null) {
                if (node.hash == hash && Objects.equals(node.key, key)) {
                    if (prev == null) {
                        table[index] = node.next;  // Remove head
                    } else {
                        prev.next = node.next;      // Remove middle/tail
                    }
                    size--;
                    return node.value;
                }
                prev = node;
                node = node.next;
            }
            
            return null;
        }
        
        // Resize operation
        @SuppressWarnings("unchecked")
        private void resize() {
            Node<K, V>[] oldTable = table;
            int newCapacity = oldTable.length * 2;
            table = (Node<K, V>[]) new Node[newCapacity];
            
            // Rehash all entries
            for (Node<K, V> head : oldTable) {
                for (Node<K, V> node = head; node != null; node = node.next) {
                    int newIndex = indexFor(node.hash, newCapacity);
                    Node<K, V> newNode = new Node<>(node.hash, node.key, node.value, table[newIndex]);
                    table[newIndex] = newNode;
                }
            }
        }
        
        public int size() {
            return size;
        }
    }
    
    // Demonstrating collision handling
    public void demonstrateCollisions() {
        // Create objects with same hash code
        class BadHash {
            String value;
            
            BadHash(String value) {
                this.value = value;
            }
            
            @Override
            public int hashCode() {
                return 1;  // All objects have same hash - worst case
            }
            
            @Override
            public boolean equals(Object o) {
                if (this == o) return true;
                if (o == null || getClass() != o.getClass()) return false;
                BadHash badHash = (BadHash) o;
                return Objects.equals(value, badHash.value);
            }
        }
        
        HashMap<BadHash, String> map = new HashMap<>();
        
        // All keys go to same bucket (linked list)
        for (int i = 0; i < 100; i++) {
            map.put(new BadHash("key" + i), "value" + i);
        }
        
        // Performance: O(n) instead of O(1)
        System.out.println(map.get(new BadHash("key50")));
    }
}
```

## 4.3 Real-World Example: Caching System

```java
import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

public class CachingSystem {
    
    // Cache entry
    static class CacheEntry<V> {
        private V value;
        private LocalDateTime expiryTime;
        private int hitCount;
        private LocalDateTime lastAccess;
        
        public CacheEntry(V value, long ttlSeconds) {
            this.value = value;
            this.expiryTime = LocalDateTime.now().plusSeconds(ttlSeconds);
            this.hitCount = 0;
            this.lastAccess = LocalDateTime.now();
        }
        
        public boolean isExpired() {
            return LocalDateTime.now().isAfter(expiryTime);
        }
        
        public V getValue() {
            hitCount++;
            lastAccess = LocalDateTime.now();
            return value;
        }
        
        public int getHitCount() { return hitCount; }
        public LocalDateTime getLastAccess() { return lastAccess; }
    }
    
    // LRU Cache using LinkedHashMap
    static class LRUCache<K, V> extends LinkedHashMap<K, V> {
        private final int maxSize;
        
        public LRUCache(int maxSize) {
            super(16, 0.75f, true);  // Access order mode
            this.maxSize = maxSize;
        }
        
        @Override
        protected boolean removeEldestEntry(Map.Entry<K, V> eldest) {
            return size() > maxSize;
        }
    }
    
    // Multi-level cache
    static class MultiLevelCache<K, V> {
        private Map<K, CacheEntry<V>> l1Cache;  // Small, fast (memory)
        private Map<K, CacheEntry<V>> l2Cache;  // Larger, slower
        private int l1MaxSize;
        private int l2MaxSize;
        private long defaultTTL;
        
        // Statistics
        private int l1Hits, l1Misses;
        private int l2Hits, l2Misses;
        
        public MultiLevelCache(int l1MaxSize, int l2MaxSize, long defaultTTL) {
            this.l1MaxSize = l1MaxSize;
            this.l2MaxSize = l2MaxSize;
            this.defaultTTL = defaultTTL;
            
            // L1: LRU cache
            this.l1Cache = new LRUCache<>(l1MaxSize);
            
            // L2: Larger cache
            this.l2Cache = new LinkedHashMap<>(16, 0.75f, true) {
                @Override
                protected boolean removeEldestEntry(Map.Entry<K, CacheEntry<V>> eldest) {
                    return size() > l2MaxSize;
                }
            };
        }
        
        // Get from cache
        public V get(K key) {
            // Try L1 first
            CacheEntry<V> entry = l1Cache.get(key);
            if (entry != null) {
                if (!entry.isExpired()) {
                    l1Hits++;
                    return entry.getValue();
                } else {
                    l1Cache.remove(key);  // Expired
                }
            }
            l1Misses++;
            
            // Try L2
            entry = l2Cache.get(key);
            if (entry != null) {
                if (!entry.isExpired()) {
                    l2Hits++;
                    // Promote to L1
                    l1Cache.put(key, entry);
                    l2Cache.remove(key);
                    return entry.getValue();
                } else {
                    l2Cache.remove(key);  // Expired
                }
            }
            l2Misses++;
            
            return null;  // Cache miss
        }
        
        // Put into cache
        public void put(K key, V value) {
            put(key, value, defaultTTL);
        }
        
        public void put(K key, V value, long ttlSeconds) {
            CacheEntry<V> entry = new CacheEntry<>(value, ttlSeconds);
            l1Cache.put(key, entry);
        }
        
        // Remove from cache
        public void remove(K key) {
            l1Cache.remove(key);
            l2Cache.remove(key);
        }
        
        // Clear cache
        public void clear() {
            l1Cache.clear();
            l2Cache.clear();
        }
        
        // Evict expired entries
        public int evictExpired() {
            int count = 0;
            
            Iterator<Map.Entry<K, CacheEntry<V>>> it = l1Cache.entrySet().iterator();
            while (it.hasNext()) {
                if (it.next().getValue().isExpired()) {
                    it.remove();
                    count++;
                }
            }
            
            it = l2Cache.entrySet().iterator();
            while (it.hasNext()) {
                if (it.next().getValue().isExpired()) {
                    it.remove();
                    count++;
                }
            }
            
            return count;
        }
        
        // Get statistics
        public Map<String, Object> getStats() {
            Map<String, Object> stats = new HashMap<>();
            stats.put("l1Size", l1Cache.size());
            stats.put("l2Size", l2Cache.size());
            stats.put("l1Hits", l1Hits);
            stats.put("l1Misses", l1Misses);
            stats.put("l2Hits", l2Hits);
            stats.put("l2Misses", l2Misses);
            
            int totalHits = l1Hits + l2Hits;
            int totalRequests = totalHits + l2Misses;
            double hitRate = totalRequests > 0 ? (double) totalHits / totalRequests : 0;
            stats.put("hitRate", String.format("%.2f%%", hitRate * 100));
            
            return stats;
        }
    }
    
    // Thread-safe cache
    static class ConcurrentCache<K, V> {
        private ConcurrentHashMap<K, CacheEntry<V>> cache;
        private long defaultTTL;
        
        public ConcurrentCache(long defaultTTL) {
            this.cache = new ConcurrentHashMap<>();
            this.defaultTTL = defaultTTL;
        }
        
        public V get(K key) {
            CacheEntry<V> entry = cache.get(key);
            if (entry != null && !entry.isExpired()) {
                return entry.getValue();
            }
            cache.remove(key);  // Expired or null
            return null;
        }
        
        public void put(K key, V value) {
            cache.put(key, new CacheEntry<>(value, defaultTTL));
        }
        
        public V computeIfAbsent(K key, java.util.function.Function<K, V> mappingFunction) {
            CacheEntry<V> entry = cache.get(key);
            if (entry != null && !entry.isExpired()) {
                return entry.getValue();
            }
            
            V value = mappingFunction.apply(key);
            if (value != null) {
                cache.put(key, new CacheEntry<>(value, defaultTTL));
            }
            return value;
        }
        
        public void clear() {
            cache.clear();
        }
    }
    
    // Usage example
    public static void main(String[] args) throws InterruptedException {
        // LRU Cache
        LRUCache<String, String> lru = new LRUCache<>(3);
        lru.put("A", "Value A");
        lru.put("B", "Value B");
        lru.put("C", "Value C");
        System.out.println("LRU: " + lru.keySet());  // [A, B, C]
        
        lru.put("D", "Value D");  // Evicts A
        System.out.println("LRU after D: " + lru.keySet());  // [B, C, D]
        
        lru.get("B");  // Access B, moves to end
        lru.put("E", "Value E");  // Evicts C
        System.out.println("LRU after E: " + lru.keySet());  // [D, B, E]
        
        System.out.println("\n--- Multi-Level Cache ---");
        
        // Multi-level cache
        MultiLevelCache<String, String> cache = new MultiLevelCache<>(2, 5, 60);
        
        cache.put("user:1", "John Doe");
        cache.put("user:2", "Jane Smith");
        cache.put("user:3", "Bob Johnson");
        
        // Access patterns
        System.out.println(cache.get("user:1"));  // L1 hit
        System.out.println(cache.get("user:1"));  // L1 hit
        System.out.println(cache.get("user:2"));  // L1 hit
        System.out.println(cache.get("user:3"));  // L2 hit (promoted to L1)
        System.out.println(cache.get("user:999")); // Miss
        
        // Statistics
        System.out.println("\nCache Statistics:");
        cache.getStats().forEach((k, v) -> System.out.println(k + ": " + v));
        
        System.out.println("\n--- Expiry Test ---");
        
        // Test expiry
        MultiLevelCache<String, String> expiryCache = new MultiLevelCache<>(10, 20, 2);
        expiryCache.put("temp", "Temporary value", 2);  // 2 seconds TTL
        System.out.println("Before expiry: " + expiryCache.get("temp"));
        
        Thread.sleep(3000);  // Wait 3 seconds
        System.out.println("After expiry: " + expiryCache.get("temp"));  // null
    }
}
```

---

# 5. QUEUE AND DEQUE

## 5.1 Queue Implementations

```java
import java.util.*;

public class QueueExamples {
    
    // LinkedList as Queue
    public void linkedListQueue() {
        Queue<String> queue = new LinkedList<>();
        
        // Add elements (offer vs add)
        queue.offer("First");   // Returns false if fails (for capacity-restricted queues)
        queue.add("Second");    // Throws exception if fails
        
        // Peek at head
        String head = queue.peek();   // Returns null if empty
        String head2 = queue.element(); // Throws exception if empty
        
        // Remove from head
        String removed = queue.poll();  // Returns null if empty
        String removed2 = queue.remove(); // Throws exception if empty
        
        System.out.println("Size: " + queue.size());
    }
    
    // PriorityQueue - Min heap by default
    public void priorityQueueExample() {
        PriorityQueue<Integer> pq = new PriorityQueue<>();
        
        // Add elements
        pq.offer(5);
        pq.offer(2);
        pq.offer(8);
        pq.offer(1);
        
        // Poll in sorted order (min heap)
        while (!pq.isEmpty()) {
            System.out.println(pq.poll());  // 1, 2, 5, 8
        }
        
        // Max heap
        PriorityQueue<Integer> maxHeap = new PriorityQueue<>(Collections.reverseOrder());
        maxHeap.offer(5);
        maxHeap.offer(2);
        maxHeap.offer(8);
        maxHeap.offer(1);
        
        while (!maxHeap.isEmpty()) {
            System.out.println(maxHeap.poll());  // 8, 5, 2, 1
        }
    }
    
    // PriorityQueue with custom objects
    public void priorityQueueWithComparator() {
        class Task {
            String name;
            int priority;  // 1 = highest
            
            Task(String name, int priority) {
                this.name = name;
                this.priority = priority;
            }
            
            @Override
            public String toString() {
                return name + " (P" + priority + ")";
            }
        }
        
        // Sort by priority (lowest number = highest priority)
        PriorityQueue<Task> taskQueue = new PriorityQueue<>(
            Comparator.comparingInt(t -> t.priority)
        );
        
        taskQueue.offer(new Task("Low priority task", 3));
        taskQueue.offer(new Task("Critical task", 1));
        taskQueue.offer(new Task("Medium task", 2));
        
        while (!taskQueue.isEmpty()) {
            System.out.println(taskQueue.poll());
        }
        // Output:
        // Critical task (P1)
        // Medium task (P2)
        // Low priority task (P3)
    }
}
```

## 5.2 Deque Implementations

```java
import java.util.*;

public class DequeExamples {
    
    // ArrayDeque - Resizable array, no capacity restrictions
    public void arrayDequeExample() {
        Deque<String> deque = new ArrayDeque<>();
        
        // Add to front
        deque.offerFirst("A");
        deque.addFirst("B");
        
        // Add to back
        deque.offerLast("C");
        deque.addLast("D");
        
        // Current: [B, A, C, D]
        
        // Peek
        String first = deque.peekFirst();  // B
        String last = deque.peekLast();    // D
        
        // Remove from front
        String removed1 = deque.pollFirst();  // B
        
        // Remove from back
        String removed2 = deque.pollLast();   // D
        
        // Result: [A, C]
    }
    
    // Deque as Stack
    public void dequeAsStack() {
        Deque<Integer> stack = new ArrayDeque<>();
        
        // Push
        stack.push(1);
        stack.push(2);
        stack.push(3);
        
        // Peek
        System.out.println(stack.peek());  // 3
        
        // Pop
        while (!stack.isEmpty()) {
            System.out.println(stack.pop());  // 3, 2, 1
        }
    }
    
    // Deque as Queue
    public void dequeAsQueue() {
        Deque<String> queue = new ArrayDeque<>();
        
        // Enqueue (add to back)
        queue.offer("First");
        queue.offer("Second");
        queue.offer("Third");
        
        // Dequeue (remove from front)
        while (!queue.isEmpty()) {
            System.out.println(queue.poll());  // First, Second, Third
        }
    }
}
```

## 5.3 Real-World Example: Request Processing System

```java
import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.*;

public class RequestProcessingSystem {
    
    // Request with priority
    static class Request {
        private String id;
        private String userId;
        private RequestType type;
        private int priority;  // 1 = highest
        private LocalDateTime timestamp;
        private String payload;
        
        public Request(String id, String userId, RequestType type, int priority, String payload) {
            this.id = id;
            this.userId = userId;
            this.type = type;
            this.priority = priority;
            this.timestamp = LocalDateTime.now();
            this.payload = payload;
        }
        
        // Getters
        public String getId() { return id; }
        public RequestType getType() { return type; }
        public int getPriority() { return priority; }
        public LocalDateTime getTimestamp() { return timestamp; }
        
        @Override
        public String toString() {
            return String.format("Request[id=%s, type=%s, priority=%d]", id, type, priority);
        }
    }
    
    enum RequestType {
        CRITICAL,    // System critical
        HIGH,        // User-facing
        NORMAL,      // Regular operations
        LOW,         // Background tasks
        BATCH        // Batch processing
    }
    
    // Priority-based request processor
    static class PriorityRequestProcessor {
        private PriorityQueue<Request> requestQueue;
        private Map<String, Request> processingRequests;
        private List<Request> completedRequests;
        
        public PriorityRequestProcessor() {
            // Sort by priority, then by timestamp
            this.requestQueue = new PriorityQueue<>((r1, r2) -> {
                int priorityCompare = Integer.compare(r1.getPriority(), r2.getPriority());
                if (priorityCompare != 0) {
                    return priorityCompare;
                }
                return r1.getTimestamp().compareTo(r2.getTimestamp());
            });
            
            this.processingRequests = new HashMap<>();
            this.completedRequests = new ArrayList<>();
        }
        
        // Submit request
        public void submitRequest(Request request) {
            requestQueue.offer(request);
            System.out.println("Queued: " + request);
        }
        
        // Process next request
        public Request processNext() {
            Request request = requestQueue.poll();
            if (request != null) {
                processingRequests.put(request.getId(), request);
                System.out.println("Processing: " + request);
                return request;
            }
            return null;
        }
        
        // Complete request
        public void completeRequest(String requestId) {
            Request request = processingRequests.remove(requestId);
            if (request != null) {
                completedRequests.add(request);
                System.out.println("Completed: " + request);
            }
        }
        
        // Get queue size
        public int getQueueSize() {
            return requestQueue.size();
        }
        
        // Get processing count
        public int getProcessingCount() {
            return processingRequests.size();
        }
        
        // Get completed count
        public int getCompletedCount() {
            return completedRequests.size();
        }
        
        // Peek next request
        public Request peekNext() {
            return requestQueue.peek();
        }
    }
    
    // Rate limiter using Deque (sliding window)
    static class RateLimiter {
        private Deque<LocalDateTime> requestTimestamps;
        private int maxRequests;
        private int windowSeconds;
        
        public RateLimiter(int maxRequests, int windowSeconds) {
            this.requestTimestamps = new ArrayDeque<>();
            this.maxRequests = maxRequests;
            this.windowSeconds = windowSeconds;
        }
        
        // Check if request is allowed
        public boolean allowRequest() {
            LocalDateTime now = LocalDateTime.now();
            LocalDateTime windowStart = now.minusSeconds(windowSeconds);
            
            // Remove timestamps outside window
            while (!requestTimestamps.isEmpty() && 
                   requestTimestamps.peekFirst().isBefore(windowStart)) {
                requestTimestamps.pollFirst();
            }
            
            // Check limit
            if (requestTimestamps.size() < maxRequests) {
                requestTimestamps.offerLast(now);
                return true;
            }
            
            return false;
        }
        
        // Get current request count
        public int getCurrentCount() {
            LocalDateTime now = LocalDateTime.now();
            LocalDateTime windowStart = now.minusSeconds(windowSeconds);
            
            // Remove old timestamps
            while (!requestTimestamps.isEmpty() && 
                   requestTimestamps.peekFirst().isBefore(windowStart)) {
                requestTimestamps.pollFirst();
            }
            
            return requestTimestamps.size();
        }
        
        // Get time until next available slot
        public long getWaitTimeSeconds() {
            if (requestTimestamps.size() < maxRequests) {
                return 0;
            }
            
            LocalDateTime oldestRequest = requestTimestamps.peekFirst();
            LocalDateTime availableTime = oldestRequest.plusSeconds(windowSeconds);
            LocalDateTime now = LocalDateTime.now();
            
            return java.time.Duration.between(now, availableTime).getSeconds();
        }
    }
    
    // Usage
    public static void main(String[] args) {
        PriorityRequestProcessor processor = new PriorityRequestProcessor();
        
        // Submit various requests
        processor.submitRequest(new Request("R1", "user1", RequestType.NORMAL, 3, "data"));
        processor.submitRequest(new Request("R2", "user2", RequestType.CRITICAL, 1, "critical"));
        processor.submitRequest(new Request("R3", "user3", RequestType.HIGH, 2, "urgent"));
        processor.submitRequest(new Request("R4", "user4", RequestType.LOW, 4, "background"));
        processor.submitRequest(new Request("R5", "user5", RequestType.CRITICAL, 1, "emergency"));
        
        System.out.println("\nQueue size: " + processor.getQueueSize());
        System.out.println("Next request: " + processor.peekNext());
        
        // Process requests in priority order
        System.out.println("\nProcessing requests:");
        while (processor.getQueueSize() > 0) {
            Request req = processor.processNext();
            // Simulate processing
            processor.completeRequest(req.getId());
        }
        
        System.out.println("\nCompleted: " + processor.getCompletedCount());
        
        // Rate limiter demo
        System.out.println("\n--- Rate Limiter ---");
        RateLimiter limiter = new RateLimiter(5, 10);  // 5 requests per 10 seconds
        
        for (int i = 1; i <= 7; i++) {
            if (limiter.allowRequest()) {
                System.out.println("Request " + i + ": Allowed");
            } else {
                System.out.println("Request " + i + ": Rate limited (wait " + 
                                 limiter.getWaitTimeSeconds() + "s)");
            }
        }
        
        System.out.println("Current count: " + limiter.getCurrentCount());
    }
}
```

---

# 6. CONCURRENT COLLECTIONS

## 6.1 ConcurrentHashMap

```java
import java.util.concurrent.*;
import java.util.*;

public class ConcurrentHashMapExample {
    
    public void basicOperations() {
        ConcurrentHashMap<String, Integer> map = new ConcurrentHashMap<>();
        
        // Thread-safe operations
        map.put("A", 1);
        map.putIfAbsent("B", 2);
        
        // Atomic operations
        map.compute("A", (k, v) -> v == null ? 1 : v + 1);
        map.computeIfAbsent("C", k -> 3);
        map.computeIfPresent("A", (k, v) -> v * 2);
        
        // Merge
        map.merge("A", 10, Integer::sum);
        
        // Bulk operations (parallel)
        map.forEach(1, (k, v) -> System.out.println(k + " = " + v));
        
        // Search
        String result = map.search(1, (k, v) -> v > 5 ? k : null);
        
        // Reduce
        Integer sum = map.reduce(1, (k, v) -> v, Integer::sum);
    }
    
    // Why ConcurrentHashMap over Hashtable or synchronized Map?
    public void comparison() {
        // 1. Hashtable - Locks entire map for every operation (slow)
        Hashtable<String, Integer> hashtable = new Hashtable<>();
        
        // 2. Synchronized Map - Locks entire map (slow)
        Map<String, Integer> syncMap = Collections.synchronizedMap(new HashMap<>());
        
        // 3. ConcurrentHashMap - Locks only segments (fast)
        ConcurrentHashMap<String, Integer> concurrentMap = new ConcurrentHashMap<>();
        
        // ConcurrentHashMap allows:
        // - Multiple concurrent reads without locking
        // - Multiple concurrent writes to different segments
        // - Better performance under concurrent access
    }
    
    // Real-world usage: Concurrent counter
    public void concurrentCounter() throws InterruptedException {
        ConcurrentHashMap<String, AtomicInteger> counters = new ConcurrentHashMap<>();
        
        // 10 threads incrementing counters
        ExecutorService executor = Executors.newFixedThreadPool(10);
        
        for (int i = 0; i < 10; i++) {
            final String threadName = "Thread-" + i;
            executor.submit(() -> {
                for (int j = 0; j < 1000; j++) {
                    counters.computeIfAbsent("counter", k -> new AtomicInteger(0))
                           .incrementAndGet();
                }
            });
        }
        
        executor.shutdown();
        executor.awaitTermination(1, TimeUnit.MINUTES);
        
        System.out.println("Final count: " + counters.get("counter").get());  // 10000
    }
}
```

## 6.2 CopyOnWriteArrayList and CopyOnWriteArraySet

```java
import java.util.concurrent.*;
import java.util.*;

public class CopyOnWriteExample {
    
    // CopyOnWriteArrayList - Thread-safe, optimized for read-heavy workloads
    public void copyOnWriteArrayList() {
        CopyOnWriteArrayList<String> list = new CopyOnWriteArrayList<>();
        
        list.add("A");
        list.add("B");
        list.add("C");
        
        // Iterator doesn't reflect changes after iterator creation
        Iterator<String> it = list.iterator();
        list.add("D");  // Won't appear in iterator
        
        while (it.hasNext()) {
            System.out.println(it.next());  // A, B, C (no D)
        }
        
        // No ConcurrentModificationException!
        for (String s : list) {
            System.out.println(s);
            list.add("E");  // Safe during iteration
        }
    }
    
    // When to use?
    public void useCase() {
        // Good for: Read-heavy, infrequent writes
        // Examples: Event listeners, observer lists, configuration
        
        CopyOnWriteArrayList<EventListener> listeners = new CopyOnWriteArrayList<>();
        
        // Multiple threads reading
        // Occasional thread adding/removing listeners
        
        // Bad for: Frequent writes (creates copy on every write)
    }
    
    // CopyOnWriteArraySet - Thread-safe Set
    public void copyOnWriteArraySet() {
        CopyOnWriteArraySet<String> set = new CopyOnWriteArraySet<>();
        
        set.add("A");
        set.add("B");
        set.add("A");  // Duplicate ignored
        
        System.out.println(set.size());  // 2
    }
    
    interface EventListener {}
}
```

## 6.3 BlockingQueue Implementations

```java
import java.util.concurrent.*;
import java.util.*;

public class BlockingQueueExamples {
    
    // ArrayBlockingQueue - Bounded, FIFO
    public void arrayBlockingQueue() throws InterruptedException {
        BlockingQueue<String> queue = new ArrayBlockingQueue<>(3);  // Capacity 3
        
        // Add (blocks if full)
        queue.put("A");
        queue.put("B");
        queue.put("C");
        // queue.put("D");  // Would block until space available
        
        // Offer with timeout
        boolean added = queue.offer("D", 1, TimeUnit.SECONDS);
        System.out.println("Added D: " + added);  // false (timeout)
        
        // Take (blocks if empty)
        String item = queue.take();
        System.out.println("Took: " + item);  // A
        
        // Poll with timeout
        String item2 = queue.poll(1, TimeUnit.SECONDS);
        System.out.println("Polled: " + item2);  // B
    }
    
    // LinkedBlockingQueue - Optionally bounded, FIFO
    public void linkedBlockingQueue() {
        // Unbounded (Integer.MAX_VALUE capacity)
        BlockingQueue<Integer> unbounded = new LinkedBlockingQueue<>();
        
        // Bounded
        BlockingQueue<Integer> bounded = new LinkedBlockingQueue<>(100);
    }
    
    // PriorityBlockingQueue - Unbounded, ordered
    public void priorityBlockingQueue() {
        BlockingQueue<Integer> pq = new PriorityBlockingQueue<>();
        
        pq.offer(5);
        pq.offer(2);
        pq.offer(8);
        
        System.out.println(pq.poll());  // 2 (min)
        System.out.println(pq.poll());  // 5
        System.out.println(pq.poll());  // 8
    }
    
    // DelayQueue - Elements available after delay
    public void delayQueueExample() throws InterruptedException {
        class DelayedTask implements Delayed {
            private String name;
            private long startTime;
            
            DelayedTask(String name, long delaySeconds) {
                this.name = name;
                this.startTime = System.currentTimeMillis() + delaySeconds * 1000;
            }
            
            @Override
            public long getDelay(TimeUnit unit) {
                long diff = startTime - System.currentTimeMillis();
                return unit.convert(diff, TimeUnit.MILLISECONDS);
            }
            
            @Override
            public int compareTo(Delayed other) {
                return Long.compare(this.getDelay(TimeUnit.MILLISECONDS), 
                                  other.getDelay(TimeUnit.MILLISECONDS));
            }
            
            @Override
            public String toString() {
                return name;
            }
        }
        
        DelayQueue<DelayedTask> queue = new DelayQueue<>();
        
        queue.put(new DelayedTask("Task 1", 3));  // 3 seconds delay
        queue.put(new DelayedTask("Task 2", 1));  // 1 second delay
        queue.put(new DelayedTask("Task 3", 2));  // 2 seconds delay
        
        // Takes in delay order (shortest delay first)
        System.out.println(queue.take());  // Task 2 (after 1s)
        System.out.println(queue.take());  // Task 3 (after 2s)
        System.out.println(queue.take());  // Task 1 (after 3s)
    }
    
    // Producer-Consumer pattern
    public void producerConsumer() throws InterruptedException {
        BlockingQueue<Integer> queue = new ArrayBlockingQueue<>(10);
        
        // Producer
        Thread producer = new Thread(() -> {
            try {
                for (int i = 1; i <= 20; i++) {
                    queue.put(i);
                    System.out.println("Produced: " + i);
                    Thread.sleep(100);
                }
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
        });
        
        // Consumer
        Thread consumer = new Thread(() -> {
            try {
                while (true) {
                    Integer item = queue.take();
                    System.out.println("Consumed: " + item);
                    Thread.sleep(200);
                }
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
        });
        
        producer.start();
        consumer.start();
        
        producer.join();
        consumer.interrupt();
    }
}
```

---

# 7. COMPARATOR AND COMPARABLE

## 7.1 Comparable Interface

```java
import java.util.*;

public class ComparableExample {
    
    // Implementing Comparable
    static class Employee implements Comparable<Employee> {
        private int id;
        private String name;
        private double salary;
        
        public Employee(int id, String name, double salary) {
            this.id = id;
            this.name = name;
            this.salary = salary;
        }
        
        // Natural ordering by ID
        @Override
        public int compareTo(Employee other) {
            return Integer.compare(this.id, other.id);
        }
        
        public int getId() { return id; }
        public String getName() { return name; }
        public double getSalary() { return salary; }
        
        @Override
        public String toString() {
            return String.format("Employee[id=%d, name=%s, salary=%.2f]", id, name, salary);
        }
    }
    
    public static void main(String[] args) {
        List<Employee> employees = Arrays.asList(
            new Employee(3, "John", 60000),
            new Employee(1, "Alice", 75000),
            new Employee(2, "Bob", 55000)
        );
        
        // Sort using natural ordering (by ID)
        Collections.sort(employees);
        employees.forEach(System.out::println);
        
        // TreeSet uses natural ordering
        Set<Employee> sortedSet = new TreeSet<>(employees);
        System.out.println("\nTreeSet:");
        sortedSet.forEach(System.out::println);
    }
}
```

## 7.2 Comparator Interface

```java
import java.util.*;

public class ComparatorExample {
    
    static class Product {
        private String name;
        private double price;
        private int rating;
        
        public Product(String name, double price, int rating) {
            this.name = name;
            this.price = price;
            this.rating = rating;
        }
        
        public String getName() { return name; }
        public double getPrice() { return price; }
        public int getRating() { return rating; }
        
        @Override
        public String toString() {
            return String.format("%s ($%.2f, rating: %d)", name, price, rating);
        }
    }
    
    public static void main(String[] args) {
        List<Product> products = Arrays.asList(
            new Product("Laptop", 1200, 4),
            new Product("Mouse", 25, 5),
            new Product("Keyboard", 80, 4),
            new Product("Monitor", 300, 5)
        );
        
        // Sort by price (ascending)
        products.sort(Comparator.comparingDouble(Product::getPrice));
        System.out.println("By price:");
        products.forEach(System.out::println);
        
        // Sort by price (descending)
        products.sort(Comparator.comparingDouble(Product::getPrice).reversed());
        System.out.println("\nBy price (desc):");
        products.forEach(System.out::println);
        
        // Sort by rating, then by price
        products.sort(
            Comparator.comparingInt(Product::getRating)
                     .reversed()
                     .thenComparingDouble(Product::getPrice)
        );
        System.out.println("\nBy rating (desc), then price:");
        products.forEach(System.out::println);
        
        // Sort by name length, then alphabetically
        products.sort(
            Comparator.comparingInt((Product p) -> p.getName().length())
                     .thenComparing(Product::getName)
        );
        System.out.println("\nBy name length, then alphabetically:");
        products.forEach(System.out::println);
        
        // Custom comparator
        Comparator<Product> customComparator = (p1, p2) -> {
            // High rating and low price is better
            int ratingCompare = Integer.compare(p2.getRating(), p1.getRating());
            if (ratingCompare != 0) {
                return ratingCompare;
            }
            return Double.compare(p1.getPrice(), p2.getPrice());
        };
        
        products.sort(customComparator);
        System.out.println("\nBest value (high rating, low price):");
        products.forEach(System.out::println);
        
        // Null-safe comparator
        List<Product> withNulls = new ArrayList<>(products);
        withNulls.add(null);
        
        withNulls.sort(
            Comparator.nullsLast(
                Comparator.comparing(Product::getName)
            )
        );
    }
}
```

## 7.3 Comparable vs Comparator

```java
import java.util.*;

public class ComparableVsComparator {
    
    /*
     * COMPARABLE:
     * - Single, natural ordering
     * - Defined in the class itself
     * - compareTo(T other)
     * - Used by: Collections.sort(list), TreeSet, TreeMap
     * - Class must be modified to change sorting
     *
     * COMPARATOR:
     * - Multiple, custom orderings
     * - Defined externally
     * - compare(T o1, T o2)
     * - Used by: Collections.sort(list, comparator), TreeSet(comparator), TreeMap(comparator)
     * - No need to modify class
     */
    
    static class Book implements Comparable<Book> {
        private String title;
        private String author;
        private int year;
        
        public Book(String title, String author, int year) {
            this.title = title;
            this.author = author;
            this.year = year;
        }
        
        // Natural ordering by title
        @Override
        public int compareTo(Book other) {
            return this.title.compareTo(other.title);
        }
        
        public String getTitle() { return title; }
        public String getAuthor() { return author; }
        public int getYear() { return year; }
        
        @Override
        public String toString() {
            return String.format("'%s' by %s (%d)", title, author, year);
        }
    }
    
    public static void main(String[] args) {
        List<Book> books = Arrays.asList(
            new Book("1984", "George Orwell", 1949),
            new Book("Brave New World", "Aldous Huxley", 1932),
            new Book("Animal Farm", "George Orwell", 1945)
        );
        
        // Using Comparable (natural ordering)
        Collections.sort(books);
        System.out.println("Natural ordering (by title):");
        books.forEach(System.out::println);
        
        // Using Comparator (custom ordering)
        Comparator<Book> byAuthor = Comparator.comparing(Book::getAuthor)
                                              .thenComparing(Book::getYear);
        books.sort(byAuthor);
        System.out.println("\nBy author, then year:");
        books.forEach(System.out::println);
        
        // Another Comparator
        Comparator<Book> byYear = Comparator.comparingInt(Book::getYear);
        books.sort(byYear);
        System.out.println("\nBy year:");
        books.forEach(System.out::println);
    }
}
```

---

# 8. COLLECTIONS UTILITY CLASS

```java
import java.util.*;

public class CollectionsUtilityExample {
    
    public void sortingAndSearching() {
        List<Integer> numbers = new ArrayList<>(Arrays.asList(5, 2, 8, 1, 9, 3));
        
        // Sort
        Collections.sort(numbers);
        System.out.println("Sorted: " + numbers);  // [1, 2, 3, 5, 8, 9]
        
        // Binary search (list must be sorted)
        int index = Collections.binarySearch(numbers, 5);
        System.out.println("Index of 5: " + index);  // 3
        
        // Reverse
        Collections.reverse(numbers);
        System.out.println("Reversed: " + numbers);  // [9, 8, 5, 3, 2, 1]
        
        // Shuffle
        Collections.shuffle(numbers);
        System.out.println("Shuffled: " + numbers);  // Random order
        
        // Rotate
        Collections.rotate(numbers, 2);  // Rotate right by 2
        System.out.println("Rotated: " + numbers);
    }
    
    public void minMaxFrequency() {
        List<Integer> numbers = Arrays.asList(5, 2, 8, 2, 9, 2, 3);
        
        // Min and Max
        int min = Collections.min(numbers);
        int max = Collections.max(numbers);
        System.out.println("Min: " + min + ", Max: " + max);  // Min: 2, Max: 9
        
        // Frequency
        int freq = Collections.frequency(numbers, 2);
        System.out.println("Frequency of 2: " + freq);  // 3
        
        // Disjoint (no common elements)
        List<Integer> list1 = Arrays.asList(1, 2, 3);
        List<Integer> list2 = Arrays.asList(4, 5, 6);
        boolean disjoint = Collections.disjoint(list1, list2);
        System.out.println("Disjoint: " + disjoint);  // true
    }
    
    public void fillAndReplace() {
        List<String> list = new ArrayList<>(Arrays.asList("A", "B", "C", "D", "E"));
        
        // Fill
        Collections.fill(list, "X");
        System.out.println("Filled: " + list);  // [X, X, X, X, X]
        
        // Replace
        list = new ArrayList<>(Arrays.asList("A", "B", "A", "C", "A"));
        Collections.replaceAll(list, "A", "Z");
        System.out.println("Replaced: " + list);  // [Z, B, Z, C, Z]
    }
    
    public void copyAndAddAll() {
        List<String> source = Arrays.asList("A", "B", "C");
        List<String> dest = new ArrayList<>(Arrays.asList("X", "Y", "Z"));
        
        // Copy
        Collections.copy(dest, source);
        System.out.println("Copied: " + dest);  // [A, B, C]
        
        // AddAll
        List<String> list = new ArrayList<>();
        Collections.addAll(list, "A", "B", "C");
        System.out.println("AddAll: " + list);  // [A, B, C]
    }
    
    public void unmodifiableCollections() {
        List<String> list = new ArrayList<>(Arrays.asList("A", "B", "C"));
        
        // Unmodifiable view
        List<String> unmodifiable = Collections.unmodifiableList(list);
        
        // unmodifiable.add("D");  // UnsupportedOperationException
        
        // Changes to original reflect in view
        list.add("D");
        System.out.println(unmodifiable);  // [A, B, C, D]
        
        // Similar methods:
        // Collections.unmodifiableSet(set)
        // Collections.unmodifiableMap(map)
        // Collections.unmodifiableCollection(collection)
    }
    
    public void synchronizedCollections() {
        // Synchronized wrappers
        List<String> syncList = Collections.synchronizedList(new ArrayList<>());
        Set<String> syncSet = Collections.synchronizedSet(new HashSet<>());
        Map<String, String> syncMap = Collections.synchronizedMap(new HashMap<>());
        
        // Must synchronize on iteration
        synchronized(syncList) {
            for (String s : syncList) {
                System.out.println(s);
            }
        }
    }
    
    public void singletonAndEmpty() {
        // Singleton collections (immutable, single element)
        Set<String> singleton = Collections.singleton("Only");
        List<String> singletonList = Collections.singletonList("Only");
        Map<String, String> singletonMap = Collections.singletonMap("key", "value");
        
        // Empty collections (immutable)
        List<String> empty = Collections.emptyList();
        Set<String> emptySet = Collections.emptySet();
        Map<String, String> emptyMap = Collections.emptyMap();
        
        // Useful for returning from methods
    }
}
```

# 9. INTERVIEW QUESTIONS

## Q1: What is the difference between ArrayList and LinkedList?

**Answer:**

| Aspect | ArrayList | LinkedList |
|--------|-----------|------------|
| **Structure** | Dynamic array | Doubly-linked list |
| **Random Access** | O(1) - Fast | O(n) - Slow (traverse) |
| **Insertion/Deletion (middle)** | O(n) - Shifts elements | O(1) - Change pointers |
| **Insertion/Deletion (beginning)** | O(n) - Shifts all | O(1) - Change head |
| **Insertion/Deletion (end)** | O(1) amortized | O(1) |
| **Memory** | Less (just array) | More (node objects + pointers) |
| **Cache locality** | Better (contiguous memory) | Worse (scattered memory) |
| **Iteration** | Faster | Slower |
| **Implements** | List | List, Deque, Queue |
| **Best for** | Random access, iterations | Frequent insertions/deletions at ends |

```java
// When to use ArrayList
List<String> arrayList = new ArrayList<>();
for (int i = 0; i < 1000; i++) {
    arrayList.add("Item " + i);  // O(1) amortized
}
String item = arrayList.get(500);  // O(1) - Very fast

// When to use LinkedList
LinkedList<String> linkedList = new LinkedList<>();
linkedList.addFirst("Head");     // O(1) - Fast
linkedList.addLast("Tail");      // O(1) - Fast
linkedList.removeFirst();        // O(1) - Fast

// As Queue
Queue<String> queue = new LinkedList<>();
queue.offer("Item");
queue.poll();
```

---

## Q2: How does HashMap work internally?

**Answer:**

HashMap uses an **array of buckets** with **hashing** to store key-value pairs.

**Key Concepts:**
1. **Hashing**: Key's `hashCode()` determines bucket index
2. **Buckets**: Array positions that store entries
3. **Collision Handling**: Multiple entries in same bucket (linked list or tree)
4. **Load Factor**: Resize threshold (default 0.75)
5. **Capacity**: Number of buckets (default 16, doubles on resize)

**Process:**

```java
// Put operation
map.put("key", "value");

// 1. Calculate hash
int hash = hash("key");  // Uses key.hashCode()

// 2. Find bucket index
int index = hash & (capacity - 1);  // Equivalent to hash % capacity

// 3. Check for existing key in bucket
//    - If found: Update value
//    - If not found: Add new entry

// 4. Check load factor
if (size > capacity * loadFactor) {
    resize();  // Double capacity, rehash all entries
}
```

**Collision Handling:**
- **Java 7**: Linked list in each bucket
- **Java 8+**: Linked list converts to **red-black tree** when bucket size > 8 (improves worst case from O(n) to O(log n))

**Example:**

```java
HashMap<String, Integer> map = new HashMap<>(16, 0.75f);

// Initial capacity: 16 buckets
// Resize when size > 16 * 0.75 = 12

map.put("A", 1);  // hash("A") % 16 = bucket 3
map.put("B", 2);  // hash("B") % 16 = bucket 7
map.put("C", 3);  // hash("C") % 16 = bucket 3 (collision!)

// Bucket 3: A -> C (linked list)
// Bucket 7: B

// Get operation
map.get("C");
// 1. hash("C") → bucket 3
// 2. Traverse list: A (equals? no), C (equals? yes)
// 3. Return value: 3
```

**Important:**
- Must override `hashCode()` and `equals()` for custom keys
- Poor `hashCode()` implementation → many collisions → O(n) performance

---

## Q3: What is the difference between HashMap and ConcurrentHashMap?

**Answer:**

| Aspect | HashMap | ConcurrentHashMap |
|--------|---------|-------------------|
| **Thread-safety** | Not thread-safe | Thread-safe |
| **Locking** | N/A | Segment-level locking (Java 7), CAS + synchronized (Java 8+) |
| **Null keys/values** | Allows one null key, multiple null values | No null keys or values |
| **Performance** | Fast (single-threaded) | Fast (multi-threaded) |
| **Iteration** | Fail-fast (ConcurrentModificationException) | Weakly consistent (no exception) |
| **Methods** | Standard Map methods | Atomic methods (putIfAbsent, compute, etc.) |

**ConcurrentHashMap Advantages:**

```java
// 1. Thread-safe operations
ConcurrentHashMap<String, Integer> map = new ConcurrentHashMap<>();

// Multiple threads can safely:
map.put("key", 1);                    // Thread 1
map.get("key");                       // Thread 2
map.computeIfAbsent("key2", k -> 2); // Thread 3

// 2. Atomic operations
map.putIfAbsent("key", 1);           // Only adds if absent
map.compute("key", (k, v) -> v + 1); // Atomic update
map.merge("key", 1, Integer::sum);   // Atomic merge

// 3. No ConcurrentModificationException
for (String key : map.keySet()) {
    map.put("new" + key, 1);  // Safe!
}

// 4. Bulk operations (parallel)
map.forEach(10, (k, v) -> System.out.println(k + "=" + v));
Integer sum = map.reduce(10, (k, v) -> v, Integer::sum);
```

**When to use:**
- **HashMap**: Single-threaded applications
- **ConcurrentHashMap**: Multi-threaded applications with concurrent access
- **Avoid**: `Collections.synchronizedMap(new HashMap<>())` - locks entire map

---

## Q4: Explain fail-fast vs fail-safe iterators.

**Answer:**

**Fail-Fast Iterators:**
- Throw `ConcurrentModificationException` if collection is modified during iteration
- Used by: ArrayList, HashMap, HashSet, etc.
- Check `modCount` (modification count)

```java
List<String> list = new ArrayList<>(Arrays.asList("A", "B", "C"));

Iterator<String> it = list.iterator();
while (it.hasNext()) {
    String item = it.next();
    list.add("D");  // ConcurrentModificationException!
}

// Correct way
Iterator<String> it2 = list.iterator();
while (it2.hasNext()) {
    it2.next();
    it2.remove();  // Use iterator's remove method
}
```

**Fail-Safe Iterators:**
- Don't throw exception if collection is modified
- Work on a **copy** or use **weakly consistent** approach
- Used by: ConcurrentHashMap, CopyOnWriteArrayList, ConcurrentSkipListSet

```java
// CopyOnWriteArrayList - works on copy
CopyOnWriteArrayList<String> list = new CopyOnWriteArrayList<>(Arrays.asList("A", "B", "C"));

for (String item : list) {
    list.add("D");  // No exception! (but won't appear in this iteration)
}

// ConcurrentHashMap - weakly consistent
ConcurrentHashMap<String, Integer> map = new ConcurrentHashMap<>();
map.put("A", 1);
map.put("B", 2);

for (String key : map.keySet()) {
    map.put("C", 3);  // No exception!
}
```

| Aspect | Fail-Fast | Fail-Safe |
|--------|-----------|-----------|
| **Exception** | Throws ConcurrentModificationException | No exception |
| **Memory** | Works on original | Works on copy or uses COW |
| **Performance** | Faster | Slower (copy overhead) |
| **Consistency** | Immediate | May not reflect recent changes |
| **Examples** | ArrayList, HashMap, HashSet | CopyOnWriteArrayList, ConcurrentHashMap |

---

## Q5: When would you use TreeMap over HashMap?

**Answer:**

**Use TreeMap when:**
1. Need sorted keys
2. Need NavigableMap operations (firstKey, lastKey, subMap, etc.)
3. Need range queries

**Use HashMap when:**
4. Don't need ordering
5. Need faster operations

```java
// HashMap - Unordered, O(1) operations
HashMap<String, Integer> hashMap = new HashMap<>();
hashMap.put("Banana", 2);
hashMap.put("Apple", 1);
hashMap.put("Cherry", 3);

System.out.println(hashMap.keySet());  // Random order: [Cherry, Apple, Banana]

// TreeMap - Sorted, O(log n) operations
TreeMap<String, Integer> treeMap = new TreeMap<>();
treeMap.put("Banana", 2);
treeMap.put("Apple", 1);
treeMap.put("Cherry", 3);

System.out.println(treeMap.keySet());  // Sorted: [Apple, Banana, Cherry]

// NavigableMap operations
System.out.println("First key: " + treeMap.firstKey());        // Apple
System.out.println("Last key: " + treeMap.lastKey());          // Cherry
System.out.println("Lower than Banana: " + treeMap.lowerKey("Banana"));   // Apple
System.out.println("Higher than Banana: " + treeMap.higherKey("Banana")); // Cherry

// Range queries
SortedMap<String, Integer> subMap = treeMap.subMap("Apple", "Cherry");
System.out.println(subMap);  // {Apple=1, Banana=2}

// Score leaderboard example
TreeMap<Integer, String> leaderboard = new TreeMap<>(Collections.reverseOrder());
leaderboard.put(1000, "Player1");
leaderboard.put(1500, "Player2");
leaderboard.put(800, "Player3");

System.out.println("Top player: " + leaderboard.firstEntry());  // 1500=Player2
```

**Performance:**

| Operation | HashMap | TreeMap |
|-----------|---------|---------|
| put() | O(1) avg | O(log n) |
| get() | O(1) avg | O(log n) |
| remove() | O(1) avg | O(log n) |
| containsKey() | O(1) avg | O(log n) |
| Iteration | O(n) | O(n) |
| Ordering | No | Yes (sorted) |

---

## Q6: What is the difference between HashSet and TreeSet?

**Answer:**

| Aspect | HashSet | TreeSet |
|--------|---------|---------|
| **Implementation** | HashMap | TreeMap (Red-Black Tree) |
| **Ordering** | No order | Sorted order |
| **Null elements** | Allows one null | No null (NullPointerException) |
| **Performance** | O(1) avg for add, remove, contains | O(log n) |
| **Comparator** | Uses hashCode() and equals() | Uses Comparable or Comparator |
| **Memory** | Less | More (tree structure) |
| **Best for** | Simple membership tests | Sorted sets, range queries |

```java
// HashSet
HashSet<Integer> hashSet = new HashSet<>();
hashSet.add(5);
hashSet.add(2);
hashSet.add(8);
hashSet.add(1);

System.out.println(hashSet);  // Random order: [1, 2, 5, 8] or [8, 5, 2, 1]

// TreeSet
TreeSet<Integer> treeSet = new TreeSet<>();
treeSet.add(5);
treeSet.add(2);
treeSet.add(8);
treeSet.add(1);

System.out.println(treeSet);  // Sorted: [1, 2, 5, 8]

// TreeSet operations
System.out.println("First: " + treeSet.first());      // 1
System.out.println("Last: " + treeSet.last());        // 8
System.out.println("Lower than 5: " + treeSet.lower(5));   // 2
System.out.println("Higher than 5: " + treeSet.higher(5)); // 8

// Subset
SortedSet<Integer> subset = treeSet.subSet(2, 8);  // [2, 5]
```

---

## Q7: Explain the contract between hashCode() and equals().

**Answer:**

**Contract:**
1. If two objects are equal (`a.equals(b) == true`), they **must** have the same hash code
2. If two objects have the same hash code, they **may or may not** be equal
3. If two objects are not equal, they **should** have different hash codes (for better performance)

**Rules:**
- If you override `equals()`, you **must** override `hashCode()`
- `hashCode()` must be consistent (same value during object's lifetime)
- `hashCode()` should use same fields as `equals()`

```java
class Person {
    private String name;
    private int age;
    
    // Correct implementation
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Person person = (Person) o;
        return age == person.age && Objects.equals(name, person.name);
    }
    
    @Override
    public int hashCode() {
        return Objects.hash(name, age);  // Uses same fields as equals
    }
}

// What happens if you violate the contract?
class BadPerson {
    private String name;
    
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        BadPerson that = (BadPerson) o;
        return Objects.equals(name, that.name);
    }
    
    // BAD: Not overriding hashCode()
    // Uses default Object.hashCode() which is based on memory address
}

// Consequences
HashSet<BadPerson> set = new HashSet<>();
BadPerson p1 = new BadPerson("John");
BadPerson p2 = new BadPerson("John");

set.add(p1);
set.add(p2);

System.out.println(p1.equals(p2));  // true
System.out.println(set.size());     // 2 (WRONG! Should be 1)
// Different hash codes → different buckets → both added
```

**Best Practices:**

```java
class Employee {
    private int id;
    private String name;
    private String department;
    
    // Use Objects.equals for null-safe comparison
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Employee employee = (Employee) o;
        return id == employee.id &&
               Objects.equals(name, employee.name) &&
               Objects.equals(department, employee.department);
    }
    
    // Use Objects.hash for consistent hashing
    @Override
    public int hashCode() {
        return Objects.hash(id, name, department);
    }
}

// Or use Lombok
@EqualsAndHashCode
class Employee {
    private int id;
    private String name;
}
```

---

## Q8: What is the difference between Collection and Collections?

**Answer:**

| Aspect | Collection | Collections |
|--------|------------|-------------|
| **Type** | Interface | Utility class |
| **Purpose** | Root interface for collections | Static utility methods |
| **Package** | java.util | java.util |
| **Hierarchy** | Extends Iterable | Final class, cannot be instantiated |
| **Examples** | List, Set, Queue extend it | sort(), binarySearch(), reverse() |

```java
// Collection - Interface
Collection<String> collection = new ArrayList<>();
collection.add("Item");
collection.remove("Item");
collection.size();

// Collections - Utility class (similar to Arrays)
List<Integer> list = Arrays.asList(5, 2, 8, 1);

// Sorting
Collections.sort(list);

// Binary search
int index = Collections.binarySearch(list, 5);

// Reverse
Collections.reverse(list);

// Shuffle
Collections.shuffle(list);

// Min/Max
int min = Collections.min(list);
int max = Collections.max(list);

// Unmodifiable
List<Integer> unmodifiable = Collections.unmodifiableList(list);

// Synchronized
List<Integer> synchronizedList = Collections.synchronizedList(new ArrayList<>());

// Singleton
Set<String> singleton = Collections.singleton("OnlyElement");

// Empty
List<String> empty = Collections.emptyList();
```

---

## Q9: When to use which collection?

**Answer:**

**Quick Decision Tree:**

```
Need key-value pairs?
├─ Yes → Map
│  ├─ Thread-safe? → ConcurrentHashMap
│  ├─ Sorted keys? → TreeMap
│  ├─ Insertion order? → LinkedHashMap
│  └─ Fast, no order? → HashMap
│
└─ No → Single values
   ├─ Duplicates allowed?
   │  ├─ Yes → List
   │  │  ├─ Random access? → ArrayList
   │  │  ├─ Frequent insert/delete at ends? → LinkedList
   │  │  └─ Thread-safe? → CopyOnWriteArrayList
   │  │
   │  └─ No → Set
   │     ├─ Sorted? → TreeSet
   │     ├─ Insertion order? → LinkedHashSet
   │     ├─ Thread-safe? → ConcurrentHashMap.newKeySet()
   │     └─ Fast, no order? → HashSet
   │
   └─ Special structures?
      ├─ FIFO queue? → LinkedList or ArrayDeque
      ├─ Priority queue? → PriorityQueue
      ├─ Thread-safe queue? → BlockingQueue implementations
      └─ Stack? → ArrayDeque (not Stack class!)
```

**Common Scenarios:**

```java
// Scenario 1: Shopping cart (ordered, duplicates allowed)
List<Product> cart = new ArrayList<>();

// Scenario 2: Unique tags (no duplicates, no order)
Set<String> tags = new HashSet<>();

// Scenario 3: User preferences (key-value, fast access)
Map<String, String> preferences = new HashMap<>();

// Scenario 4: Leaderboard (sorted by score)
TreeMap<Integer, String> leaderboard = new TreeMap<>(Collections.reverseOrder());

// Scenario 5: LRU cache (insertion order, limited size)
Map<String, Object> cache = new LinkedHashMap<String, Object>(16, 0.75f, true) {
    @Override
    protected boolean removeEldestEntry(Map.Entry<String, Object> eldest) {
        return size() > 100;
    }
};

// Scenario 6: Task queue (priority-based)
Queue<Task> taskQueue = new PriorityQueue<>(Comparator.comparingInt(Task::getPriority));

// Scenario 7: Producer-consumer (thread-safe, blocking)
BlockingQueue<Message> messageQueue = new LinkedBlockingQueue<>(100);

// Scenario 8: Event listeners (read-heavy, rare writes)
List<EventListener> listeners = new CopyOnWriteArrayList<>();

// Scenario 9: Concurrent requests counter
ConcurrentHashMap<String, AtomicInteger> requestCounts = new ConcurrentHashMap<>();

// Scenario 10: Undo/Redo operations (stack)
Deque<Action> undoStack = new ArrayDeque<>();
```

---

## Q10: What is the time complexity of common operations?

**Answer:**

**List Implementations:**

| Operation | ArrayList | LinkedList |
|-----------|-----------|------------|
| get(index) | O(1) | O(n) |
| add(element) | O(1) amortized | O(1) |
| add(index, element) | O(n) | O(n) |
| remove(index) | O(n) | O(n) |
| remove(element) | O(n) | O(n) |
| contains(element) | O(n) | O(n) |
| size() | O(1) | O(1) |
| addFirst/Last | O(n) / O(1) | O(1) / O(1) |

**Set Implementations:**

| Operation | HashSet | LinkedHashSet | TreeSet |
|-----------|---------|---------------|---------|
| add() | O(1) avg | O(1) avg | O(log n) |
| remove() | O(1) avg | O(1) avg | O(log n) |
| contains() | O(1) avg | O(1) avg | O(log n) |
| Iteration | O(n) | O(n) | O(n) |

**Map Implementations:**

| Operation | HashMap | LinkedHashMap | TreeMap | ConcurrentHashMap |
|-----------|---------|---------------|---------|-------------------|
| put() | O(1) avg | O(1) avg | O(log n) | O(1) avg |
| get() | O(1) avg | O(1) avg | O(log n) | O(1) avg |
| remove() | O(1) avg | O(1) avg | O(log n) | O(1) avg |
| containsKey() | O(1) avg | O(1) avg | O(log n) | O(1) avg |

**Queue Implementations:**

| Operation | LinkedList | ArrayDeque | PriorityQueue |
|-----------|------------|------------|---------------|
| offer() | O(1) | O(1) amortized | O(log n) |
| poll() | O(1) | O(1) | O(log n) |
| peek() | O(1) | O(1) | O(1) |

**Note:** 
- "avg" means average case
- Worst case for HashMap/HashSet is O(n) with many collisions
- Worst case improved to O(log n) in Java 8+ when bucket converts to tree (size > 8)

---

# 10. INTERVIEW TRAPS & EDGE CASES

## Trap 1: Modifying Collection During Iteration

```java
// TRAP: ConcurrentModificationException
List<String> list = new ArrayList<>(Arrays.asList("A", "B", "C", "D"));

// BAD
for (String item : list) {
    if (item.equals("B")) {
        list.remove(item);  // ConcurrentModificationException!
    }
}

// CORRECT: Use Iterator
Iterator<String> it = list.iterator();
while (it.hasNext()) {
    String item = it.next();
    if (item.equals("B")) {
        it.remove();  // Safe
    }
}

// CORRECT: Use removeIf (Java 8+)
list.removeIf(item -> item.equals("B"));

// CORRECT: Collect and remove after
List<String> toRemove = new ArrayList<>();
for (String item : list) {
    if (item.equals("B")) {
        toRemove.add(item);
    }
}
list.removeAll(toRemove);
```

## Trap 2: HashMap with Mutable Keys

```java
// TRAP: Using mutable objects as keys
class MutableKey {
    private int value;
    
    public MutableKey(int value) {
        this.value = value;
    }
    
    public void setValue(int value) {
        this.value = value;  // Mutable!
    }
    
    @Override
    public int hashCode() {
        return value;
    }
    
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        MutableKey that = (MutableKey) o;
        return value == that.value;
    }
}

Map<MutableKey, String> map = new HashMap<>();
MutableKey key = new MutableKey(1);

map.put(key, "Value");
System.out.println(map.get(key));  // "Value"

// Mutate the key
key.setValue(2);  // hashCode changes!

System.out.println(map.get(key));  // null (WRONG BUCKET!)
// Key is now in wrong bucket, can't be found

// SOLUTION: Use immutable keys
final class ImmutableKey {
    private final int value;
    
    public ImmutableKey(int value) {
        this.value = value;
    }
    
    public int getValue() {
        return value;
    }
    
    // No setter!
}
```

## Trap 3: Arrays.asList() Returns Fixed-Size List

```java
// TRAP: Cannot add/remove from Arrays.asList()
List<String> list = Arrays.asList("A", "B", "C");

list.set(0, "X");  // OK - can modify
// list.add("D");  // UnsupportedOperationException!
// list.remove("A");  // UnsupportedOperationException!

// SOLUTION: Create new ArrayList
List<String> modifiable = new ArrayList<>(Arrays.asList("A", "B", "C"));
modifiable.add("D");  // Works!

// Or use List.of() (Java 9+) for truly immutable
List<String> immutable = List.of("A", "B", "C");
// immutable.set(0, "X");  // UnsupportedOperationException
```

## Trap 4: Unmodifiable != Immutable

```java
// TRAP: Unmodifiable view still reflects changes to original
List<String> original = new ArrayList<>(Arrays.asList("A", "B", "C"));
List<String> unmodifiable = Collections.unmodifiableList(original);

// Cannot modify through unmodifiable view
// unmodifiable.add("D");  // UnsupportedOperationException

// But original can still be modified
original.add("D");

System.out.println(unmodifiable);  // [A, B, C, D] - reflects change!

// SOLUTION: Use List.copyOf() for true immutable copy (Java 10+)
List<String> immutable = List.copyOf(original);
original.add("E");
System.out.println(immutable);  // [A, B, C, D] - unchanged
```

## Trap 5: HashSet Ordering

```java
// TRAP: Assuming HashSet maintains any order
Set<Integer> set = new HashSet<>();
set.add(1);
set.add(2);
set.add(3);
set.add(4);
set.add(5);

// Order is unpredictable!
System.out.println(set);  // Could be: [1, 2, 3, 4, 5] or [3, 2, 5, 1, 4]

// SOLUTION:
// - Use LinkedHashSet for insertion order
// - Use TreeSet for sorted order
LinkedHashSet<Integer> linkedSet = new LinkedHashSet<>();
linkedSet.add(5);
linkedSet.add(2);
linkedSet.add(8);
System.out.println(linkedSet);  // [5, 2, 8] - insertion order
```

## Trap 6: Null Handling

```java
// TRAP: Different collections handle null differently

// ArrayList - allows nulls
List<String> list = new ArrayList<>();
list.add(null);  // OK
list.add(null);  // OK (multiple nulls)

// HashSet - allows one null
Set<String> hashSet = new HashSet<>();
hashSet.add(null);  // OK
hashSet.add(null);  // OK (but only one stored)

// TreeSet - NO nulls
Set<String> treeSet = new TreeSet<>();
// treeSet.add(null);  // NullPointerException!

// HashMap - one null key, multiple null values
Map<String, String> hashMap = new HashMap<>();
hashMap.put(null, "value1");  // OK
hashMap.put("key", null);     // OK
hashMap.put(null, "value2");  // Overwrites null key

// TreeMap - NO null keys (null values OK with comparator)
Map<String, String> treeMap = new TreeMap<>();
// treeMap.put(null, "value");  // NullPointerException!
treeMap.put("key", null);    // OK

// ConcurrentHashMap - NO nulls at all
Map<String, String> concurrentMap = new ConcurrentHashMap<>();
// concurrentMap.put(null, "value");  // NullPointerException!
// concurrentMap.put("key", null);    // NullPointerException!
```

## Trap 7: Removing During forEach

```java
// TRAP: Cannot remove during forEach
Map<String, Integer> map = new HashMap<>();
map.put("A", 1);
map.put("B", 2);
map.put("C", 3);

// BAD
map.forEach((k, v) -> {
    if (v > 1) {
        // map.remove(k);  // ConcurrentModificationException!
    }
});

// CORRECT: Use removeIf
map.entrySet().removeIf(entry -> entry.getValue() > 1);

// OR: Use iterator
Iterator<Map.Entry<String, Integer>> it = map.entrySet().iterator();
while (it.hasNext()) {
    Map.Entry<String, Integer> entry = it.next();
    if (entry.getValue() > 1) {
        it.remove();  // Safe
    }
}
```

## Trap 8: Comparing with == vs equals()

```java
// TRAP: Using == instead of equals()
List<String> list1 = new ArrayList<>(Arrays.asList("A", "B", "C"));
List<String> list2 = new ArrayList<>(Arrays.asList("A", "B", "C"));

System.out.println(list1 == list2);      // false (different objects)
System.out.println(list1.equals(list2)); // true (same content)

// String comparison in collections
List<String> list = new ArrayList<>();
list.add(new String("Hello"));

// BAD
if (list.get(0) == "Hello") {  // Might be false!
    // May not execute
}

// CORRECT
if (list.get(0).equals("Hello")) {  // true
    // Executes correctly
}
```

---

# 11. CODING PROBLEMS

## Problem 1: Implement LRU Cache

**Problem:** Implement an LRU (Least Recently Used) cache with O(1) get and put operations.

```java
import java.util.*;

/**
 * LRU Cache Implementation using LinkedHashMap
 * 
 * Requirements:
 * - get(key): Get value, mark as recently used. Return -1 if not found.
 * - put(key, value): Add or update. Remove least recently used if capacity exceeded.
 * - Both operations should be O(1)
 */
public class LRUCache<K, V> extends LinkedHashMap<K, V> {
    private final int capacity;
    
    public LRUCache(int capacity) {
        // LinkedHashMap with access-order mode
        super(capacity, 0.75f, true);
        this.capacity = capacity;
    }
    
    // Remove eldest entry when size exceeds capacity
    @Override
    protected boolean removeEldestEntry(Map.Entry<K, V> eldest) {
        return size() > capacity;
    }
    
    // Get operation (marks as recently used automatically)
    public V getValue(K key) {
        return super.get(key);
    }
    
    // Put operation
    public void putValue(K key, V value) {
        super.put(key, value);
    }
}

// Alternative implementation with manual LinkedHashMap management
class LRUCacheManual {
    private int capacity;
    private Map<Integer, Integer> cache;
    
    public LRUCacheManual(int capacity) {
        this.capacity = capacity;
        this.cache = new LinkedHashMap<Integer, Integer>(capacity, 0.75f, true) {
            @Override
            protected boolean removeEldestEntry(Map.Entry<Integer, Integer> eldest) {
                return size() > LRUCacheManual.this.capacity;
            }
        };
    }
    
    public int get(int key) {
        return cache.getOrDefault(key, -1);
    }
    
    public void put(int key, int value) {
        cache.put(key, value);
    }
}

// Implementation using HashMap + Doubly Linked List (for understanding)
class LRUCacheFromScratch {
    private int capacity;
    private Map<Integer, Node> cache;
    private Node head;  // Most recently used
    private Node tail;  // Least recently used
    
    class Node {
        int key;
        int value;
        Node prev;
        Node next;
        
        Node(int key, int value) {
            this.key = key;
            this.value = value;
        }
    }
    
    public LRUCacheFromScratch(int capacity) {
        this.capacity = capacity;
        this.cache = new HashMap<>();
        
        // Dummy head and tail
        head = new Node(0, 0);
        tail = new Node(0, 0);
        head.next = tail;
        tail.prev = head;
    }
    
    public int get(int key) {
        if (!cache.containsKey(key)) {
            return -1;
        }
        
        Node node = cache.get(key);
        
        // Move to head (most recently used)
        removeNode(node);
        addToHead(node);
        
        return node.value;
    }
    
    public void put(int key, int value) {
        if (cache.containsKey(key)) {
            // Update existing
            Node node = cache.get(key);
            node.value = value;
            removeNode(node);
            addToHead(node);
        } else {
            // Add new
            Node newNode = new Node(key, value);
            cache.put(key, newNode);
            addToHead(newNode);
            
            // Check capacity
            if (cache.size() > capacity) {
                // Remove least recently used (tail)
                Node lru = tail.prev;
                removeNode(lru);
                cache.remove(lru.key);
            }
        }
    }
    
    private void removeNode(Node node) {
        node.prev.next = node.next;
        node.next.prev = node.prev;
    }
    
    private void addToHead(Node node) {
        node.next = head.next;
        node.prev = head;
        head.next.prev = node;
        head.next = node;
    }
}

// Usage and testing
class LRUCacheTest {
    public static void main(String[] args) {
        System.out.println("=== Testing LRU Cache ===");
        
        LRUCache<Integer, String> cache = new LRUCache<>(3);
        
        cache.putValue(1, "One");
        cache.putValue(2, "Two");
        cache.putValue(3, "Three");
        System.out.println("Cache: " + cache);  // {1=One, 2=Two, 3=Three}
        
        cache.getValue(1);  // Access 1, makes it most recent
        cache.putValue(4, "Four");  // Evicts 2 (least recent)
        System.out.println("Cache after adding 4: " + cache);  // {3=Three, 1=One, 4=Four}
        
        System.out.println("Get 2: " + cache.getValue(2));  // null (evicted)
        System.out.println("Get 3: " + cache.getValue(3));  // "Three"
        
        cache.putValue(5, "Five");  // Evicts 1
        System.out.println("Cache after adding 5: " + cache);  // {4=Four, 3=Three, 5=Five}
        
        // Test manual implementation
        System.out.println("\n=== Testing Manual LRU Cache ===");
        
        LRUCacheManual lru = new LRUCacheManual(2);
        
        lru.put(1, 1);
        lru.put(2, 2);
        System.out.println("Get 1: " + lru.get(1));  // 1
        
        lru.put(3, 3);  // Evicts 2
        System.out.println("Get 2: " + lru.get(2));  // -1 (evicted)
        
        lru.put(4, 4);  // Evicts 1
        System.out.println("Get 1: " + lru.get(1));  // -1 (evicted)
        System.out.println("Get 3: " + lru.get(3));  // 3
        System.out.println("Get 4: " + lru.get(4));  // 4
    }
}
```

**Complexity:**
- Time: O(1) for both get and put
- Space: O(capacity)

---

## Problem 2: Group Anagrams

**Problem:** Given an array of strings, group anagrams together.

```java
import java.util.*;

/**
 * Group Anagrams
 * 
 * Input: ["eat", "tea", "tan", "ate", "nat", "bat"]
 * Output: [["bat"], ["nat", "tan"], ["ate", "eat", "tea"]]
 */

public class GroupAnagrams {
    
    // Solution 1: Using sorted string as key
    public List<List<String>> groupAnagrams1(String[] strs) {
        Map<String, List<String>> map = new HashMap<>();
        
        for (String str : strs) {
            // Sort characters to get key
            char[] chars = str.toCharArray();
            Arrays.sort(chars);
            String key = new String(chars);
            
            // Add to group
            map.computeIfAbsent(key, k -> new ArrayList<>()).add(str);
        }
        
        return new ArrayList<>(map.values());
    }
    
    // Solution 2: Using character count as key (faster)
    public List<List<String>> groupAnagrams2(String[] strs) {
        Map<String, List<String>> map = new HashMap<>();
        
        for (String str : strs) {
            // Count characters
            int[] count = new int[26];
            for (char c : str.toCharArray()) {
                count[c - 'a']++;
            }
            
            // Build key from count
            StringBuilder key = new StringBuilder();
            for (int i = 0; i < 26; i++) {
                if (count[i] > 0) {
                    key.append((char)('a' + i)).append(count[i]);
                }
            }
            
            // Add to group
            map.computeIfAbsent(key.toString(), k -> new ArrayList<>()).add(str);
        }
        
        return new ArrayList<>(map.values());
    }
    
    // Solution 3: Using prime numbers (unique factorization)
    public List<List<String>> groupAnagrams3(String[] strs) {
        // Assign prime number to each letter
        int[] primes = {2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97, 101};
        
        Map<Long, List<String>> map = new HashMap<>();
        
        for (String str : strs) {
            long key = 1;
            for (char c : str.toCharArray()) {
                key *= primes[c - 'a'];
            }
            
            map.computeIfAbsent(key, k -> new ArrayList<>()).add(str);
        }
        
        return new ArrayList<>(map.values());
    }
    
    // Test
    public static void main(String[] args) {
        GroupAnagrams solution = new GroupAnagrams();
        
        String[] strs = {"eat", "tea", "tan", "ate", "nat", "bat"};
        
        System.out.println("Solution 1 (sorted): " + solution.groupAnagrams1(strs));
        System.out.println("Solution 2 (count): " + solution.groupAnagrams2(strs));
        System.out.println("Solution 3 (prime): " + solution.groupAnagrams3(strs));
        
        // Edge cases
        System.out.println("\nEdge cases:");
        System.out.println("Empty: " + solution.groupAnagrams1(new String[]{}));
        System.out.println("Single: " + solution.groupAnagrams1(new String[]{"a"}));
        System.out.println("No anagrams: " + solution.groupAnagrams1(new String[]{"abc", "def", "ghi"}));
    }
}
```

**Complexity:**
- Solution 1: O(n * k log k) where n = number of strings, k = max string length
- Solution 2: O(n * k) - faster
- Solution 3: O(n * k) - fastest but risk of overflow with long strings
- Space: O(n * k)

---

## Problem 3: Top K Frequent Elements

**Problem:** Given an array of integers, return the k most frequent elements.

```java
import java.util.*;

/**
 * Top K Frequent Elements
 * 
 * Input: nums = [1,1,1,2,2,3], k = 2
 * Output: [1,2]
 */

public class TopKFrequentElements {
    
    // Solution 1: Using Heap (PriorityQueue)
    public int[] topKFrequent1(int[] nums, int k) {
        // Count frequencies
        Map<Integer, Integer> freqMap = new HashMap<>();
        for (int num : nums) {
            freqMap.put(num, freqMap.getOrDefault(num, 0) + 1);
        }
        
        // Min heap based on frequency
        PriorityQueue<Map.Entry<Integer, Integer>> heap = 
            new PriorityQueue<>((a, b) -> a.getValue() - b.getValue());
        
        // Keep only k elements in heap
        for (Map.Entry<Integer, Integer> entry : freqMap.entrySet()) {
            heap.offer(entry);
            if (heap.size() > k) {
                heap.poll();  // Remove least frequent
            }
        }
        
        // Extract result
        int[] result = new int[k];
        for (int i = 0; i < k; i++) {
            result[i] = heap.poll().getKey();
        }
        
        return result;
    }
    
    // Solution 2: Using Bucket Sort (O(n) time)
    public int[] topKFrequent2(int[] nums, int k) {
        // Count frequencies
        Map<Integer, Integer> freqMap = new HashMap<>();
        for (int num : nums) {
            freqMap.put(num, freqMap.getOrDefault(num, 0) + 1);
        }
        
        // Bucket sort: bucket[i] contains numbers with frequency i
        List<Integer>[] buckets = new List[nums.length + 1];
        for (int i = 0; i < buckets.length; i++) {
            buckets[i] = new ArrayList<>();
        }
        
        for (Map.Entry<Integer, Integer> entry : freqMap.entrySet()) {
            int freq = entry.getValue();
            buckets[freq].add(entry.getKey());
        }
        
        // Collect top k from highest frequency
        List<Integer> result = new ArrayList<>();
        for (int i = buckets.length - 1; i >= 0 && result.size() < k; i--) {
            result.addAll(buckets[i]);
        }
        
        return result.stream().mapToInt(Integer::intValue).toArray();
    }
    
    // Solution 3: Using TreeMap (sorted by frequency)
    public int[] topKFrequent3(int[] nums, int k) {
        // Count frequencies
        Map<Integer, Integer> freqMap = new HashMap<>();
        for (int num : nums) {
            freqMap.put(num, freqMap.getOrDefault(num, 0) + 1);
        }
        
        // TreeMap: frequency -> list of numbers
        TreeMap<Integer, List<Integer>> treeMap = new TreeMap<>(Collections.reverseOrder());
        
        for (Map.Entry<Integer, Integer> entry : freqMap.entrySet()) {
            int freq = entry.getValue();
            treeMap.computeIfAbsent(freq, f -> new ArrayList<>()).add(entry.getKey());
        }
        
        // Collect top k
        List<Integer> result = new ArrayList<>();
        for (List<Integer> list : treeMap.values()) {
            result.addAll(list);
            if (result.size() >= k) {
                break;
            }
        }
        
        return result.subList(0, k).stream().mapToInt(Integer::intValue).toArray();
    }
    
    // Test
    public static void main(String[] args) {
        TopKFrequentElements solution = new TopKFrequentElements();
        
        int[] nums1 = {1, 1, 1, 2, 2, 3};
        int k1 = 2;
        System.out.println("Input: " + Arrays.toString(nums1) + ", k = " + k1);
        System.out.println("Heap: " + Arrays.toString(solution.topKFrequent1(nums1, k1)));
        System.out.println("Bucket: " + Arrays.toString(solution.topKFrequent2(nums1, k1)));
        System.out.println("TreeMap: " + Arrays.toString(solution.topKFrequent3(nums1, k1)));
        
        int[] nums2 = {1};
        int k2 = 1;
        System.out.println("\nInput: " + Arrays.toString(nums2) + ", k = " + k2);
        System.out.println("Result: " + Arrays.toString(solution.topKFrequent1(nums2, k2)));
        
        int[] nums3 = {4, 1, -1, 2, -1, 2, 3};
        int k3 = 2;
        System.out.println("\nInput: " + Arrays.toString(nums3) + ", k = " + k3);
        System.out.println("Result: " + Arrays.toString(solution.topKFrequent2(nums3, k3)));
    }
}
```

**Complexity:**
- Solution 1 (Heap): O(n log k) time, O(n) space
- Solution 2 (Bucket): O(n) time, O(n) space - **Best**
- Solution 3 (TreeMap): O(n log n) time, O(n) space

---

## Problem 4: Design a File System (Trie with HashMap)

**Problem:** Design an in-memory file system with mkdir, ls, addContentToFile, readContentFromFile operations.

```java
import java.util.*;

/**
 * In-Memory File System
 * 
 * Operations:
 * - ls(path): List directory contents
 * - mkdir(path): Create directory
 * - addContentToFile(path, content): Add content to file
 * - readContentFromFile(path): Read file content
 */

public class FileSystem {
    
    class Node {
        String name;
        boolean isFile;
        String content;
        Map<String, Node> children;
        
        Node(String name) {
            this.name = name;
            this.isFile = false;
            this.content = "";
            this.children = new TreeMap<>();  // TreeMap for sorted listing
        }
    }
    
    private Node root;
    
    public FileSystem() {
        root = new Node("");
    }
    
    // List directory contents or file name
    public List<String> ls(String path) {
        Node node = navigate(path);
        
        if (node.isFile) {
            // Return file name
            return Arrays.asList(node.name);
        } else {
            // Return sorted directory contents
            return new ArrayList<>(node.children.keySet());
        }
    }
    
    // Create directory
    public void mkdir(String path) {
        navigate(path, true);
    }
    
    // Add content to file (creates file if doesn't exist)
    public void addContentToFile(String filePath, String content) {
        Node node = navigate(filePath, true);
        node.isFile = true;
        node.content += content;
    }
    
    // Read file content
    public String readContentFromFile(String filePath) {
        Node node = navigate(filePath);
        return node.content;
    }
    
    // Navigate to path
    private Node navigate(String path) {
        return navigate(path, false);
    }
    
    // Navigate to path, optionally creating nodes
    private Node navigate(String path, boolean create) {
        if (path.equals("/")) {
            return root;
        }
        
        String[] parts = path.split("/");
        Node current = root;
        
        for (int i = 1; i < parts.length; i++) {  // Skip empty first element
            String part = parts[i];
            
            if (!current.children.containsKey(part)) {
                if (create) {
                    current.children.put(part, new Node(part));
                } else {
                    throw new IllegalArgumentException("Path not found: " + path);
                }
            }
            
            current = current.children.get(part);
        }
        
        // Set name for last node
        if (parts.length > 0) {
            current.name = parts[parts.length - 1];
        }
        
        return current;
    }
    
    // Visualize file system
    public void printStructure() {
        System.out.println("File System Structure:");
        printNode(root, 0);
    }
    
    private void printNode(Node node, int depth) {
        String indent = "  ".repeat(depth);
        
        if (node == root) {
            System.out.println("/");
        }
        
        for (Node child : node.children.values()) {
            System.out.print(indent + "├─ " + child.name);
            if (child.isFile) {
                System.out.println(" (file, size: " + child.content.length() + ")");
            } else {
                System.out.println(" (dir)");
                printNode(child, depth + 1);
            }
        }
    }
    
    // Test
    public static void main(String[] args) {
        FileSystem fs = new FileSystem();
        
        // Create directories
        fs.mkdir("/home");
        fs.mkdir("/home/user");
        fs.mkdir("/home/user/documents");
        fs.mkdir("/home/user/downloads");
        
        // Create files
        fs.addContentToFile("/home/user/readme.txt", "Hello World!");
        fs.addContentToFile("/home/user/readme.txt", " Welcome!");
        fs.addContentToFile("/home/user/documents/notes.txt", "My notes");
        
        // List operations
        System.out.println("ls /: " + fs.ls("/"));
        System.out.println("ls /home: " + fs.ls("/home"));
        System.out.println("ls /home/user: " + fs.ls("/home/user"));
        System.out.println("ls /home/user/readme.txt: " + fs.ls("/home/user/readme.txt"));
        
        // Read file
        System.out.println("\nRead /home/user/readme.txt:");
        System.out.println(fs.readContentFromFile("/home/user/readme.txt"));
        
        // Print structure
        System.out.println();
        fs.printStructure();
    }
}
```

**Complexity:**
- ls: O(m + k log k) where m = path length, k = children count
- mkdir: O(m)
- addContentToFile: O(m + c) where c = content length
- readContentFromFile: O(m)
- Space: O(n * m) where n = number of nodes

---

# 12. SUMMARY & BEST PRACTICES

## Quick Reference Guide

### When to Use Which Collection

| Use Case | Collection |
|----------|------------|
| Random access, fast iteration | `ArrayList` |
| Frequent add/remove at ends | `LinkedList` |
| Unique elements, fast lookup | `HashSet` |
| Unique elements, sorted | `TreeSet` |
| Unique elements, insertion order | `LinkedHashSet` |
| Key-value pairs, fast lookup | `HashMap` |
| Key-value pairs, sorted keys | `TreeMap` |
| Key-value pairs, insertion order | `LinkedHashMap` |
| Thread-safe map | `ConcurrentHashMap` |
| Thread-safe list (read-heavy) | `CopyOnWriteArrayList` |
| FIFO queue | `ArrayDeque` or `LinkedList` |
| Priority queue | `PriorityQueue` |
| Producer-consumer | `BlockingQueue` |
| Stack | `ArrayDeque` (not `Stack`!) |
| LRU cache | `LinkedHashMap` (access-order) |

### Performance Cheat Sheet

```java
// O(1) average
HashMap.get/put/remove
HashSet.add/contains/remove
ArrayList.get/set/add (at end)
LinkedList.addFirst/addLast/removeFirst/removeLast
ArrayDeque.offerFirst/offerLast/pollFirst/pollLast

// O(log n)
TreeMap.get/put/remove
TreeSet.add/contains/remove
PriorityQueue.offer/poll

// O(n)
ArrayList.add/remove (at middle)
LinkedList.get/set
Contains on any List
```

### Best Practices

✅ **DO:**
- Use generics for type safety
- Override `hashCode()` and `equals()` for custom keys in HashMap/HashSet
- Use immutable objects as map keys
- Use `ArrayList` as default List implementation
- Use `HashMap` as default Map implementation
- Use `ArrayDeque` instead of `Stack`
- Use `ConcurrentHashMap` for thread-safe maps
- Use iterator's `remove()` when modifying during iteration
- Pre-size collections if size is known
- Use `List.of()`, `Set.of()`, `Map.of()` for immutable collections (Java 9+)

❌ **DON'T:**
- Don't use `Vector` or `Hashtable` (legacy, poorly synchronized)
- Don't modify collection during iteration (except with iterator)
- Don't use mutable objects as map keys
- Don't assume order in `HashMap` or `HashSet`
- Don't use `Arrays.asList()` if you need to add/remove elements
- Don't confuse `Collection` (interface) with `Collections` (utility class)
- Don't use `==` for element comparison in collections

---

**Complete Collections Framework Guide Includes:**
✅ Collections Hierarchy & Overview
✅ List Implementations (ArrayList, LinkedList, Vector)
✅ Set Implementations (HashSet, LinkedHashSet, TreeSet)
✅ Map Implementations (HashMap, LinkedHashMap, TreeMap, Hashtable)
✅ Queue & Deque (PriorityQueue, ArrayDeque)
✅ Concurrent Collections (ConcurrentHashMap, CopyOnWriteArrayList, BlockingQueue)
✅ Comparator & Comparable
✅ Collections Utility Class
✅ 10 Interview Questions with Detailed Answers
✅ 8 Interview Traps & Edge Cases
✅ 4 Complete Coding Problems with Solutions
✅ Real-World Examples (Task Management, User Tracking, Caching, Request Processing)
✅ Internal Working (ArrayList, HashSet, HashMap)
✅ Performance Analysis & Best Practices

**Total: ~4500+ lines of interview-ready content!** 🚀

**Ready for Java Collections interviews at any level!**
