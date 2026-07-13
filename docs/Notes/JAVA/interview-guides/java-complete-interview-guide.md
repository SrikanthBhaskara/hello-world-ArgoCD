# COMPLETE JAVA INTERVIEW PREPARATION GUIDE
## For 4-5 Years Experience

**Comprehensive collection of 16 interview guides covering every aspect of Java development from fundamentals to advanced enterprise applications, including 30 coding problems, 20 system design questions, and real FAANG interview questions.**

---

# 📚 TABLE OF CONTENTS

## Core Java Fundamentals

### [1. Java OOP Principles Interview Guide](java-oop-interview-guide.md)
**Topics Covered:**
- ✅ Encapsulation (data hiding, getters/setters, immutability)
- ✅ Inheritance (single, multilevel, hierarchical, hybrid)
- ✅ Polymorphism (compile-time, runtime, method overloading/overriding)
- ✅ Abstraction (abstract classes, interfaces)
- ✅ Composition vs Inheritance (when to use each)
- ✅ SOLID principles
- ✅ Design patterns basics
- Interview questions, traps, and coding problems

**Lines:** ~6,000 | **Difficulty:** Beginner to Intermediate

---

### [2. Java Strings Interview Guide](java-strings-interview-guide.md)
**Topics Covered:**
- ✅ String Pool (String Constant Pool, interning)
- ✅ String Immutability (why, benefits, security)
- ✅ StringBuilder vs StringBuffer (performance, thread-safety)
- ✅ String methods (searching, manipulation, formatting)
- ✅ Regular expressions
- ✅ String encoding (UTF-8, UTF-16)
- Performance optimization techniques
- Interview questions and coding problems

**Lines:** ~2,500 | **Difficulty:** Beginner to Intermediate

---

### [3. Exception Handling Interview Guide](java-exception-handling-interview-guide.md)
**Topics Covered:**
- ✅ Checked vs Unchecked exceptions
- ✅ Custom exceptions (when and how to create)
- ✅ Best practices (try-with-resources, exception chaining)
- ✅ Exception hierarchy
- ✅ try-catch-finally blocks
- ✅ Multi-catch blocks
- Common pitfalls and anti-patterns
- Interview questions and scenarios

**Lines:** ~3,500 | **Difficulty:** Beginner to Intermediate

---

### [4. Java Collections Framework Interview Guide](java-collections-framework-interview-guide.md)
**Topics Covered:**
- ✅ List implementations (ArrayList, LinkedList, Vector)
- ✅ Set implementations (HashSet, TreeSet, LinkedHashSet)
- ✅ Map implementations (HashMap, TreeMap, LinkedHashMap, ConcurrentHashMap)
- ✅ Internal working of HashMap (hashing, buckets, collision handling)
- ✅ Fail-fast vs fail-safe iterators
- ✅ Queue and Deque (PriorityQueue, ArrayDeque)
- ✅ Concurrent collections (ConcurrentHashMap, CopyOnWriteArrayList)
- Comparator and Comparable
- Interview questions and LRU Cache implementation

**Lines:** ~4,500 | **Difficulty:** Intermediate

---

### [5. JVM & Memory Management Interview Guide](java-jvm-memory-management-interview-guide.md)
**Topics Covered:**
- ✅ JVM, JRE, JDK differences
- ✅ JVM Architecture (Class Loader, Memory Areas, Execution Engine)
- ✅ Memory model (Heap, Stack, Method Area, PC Register)
- ✅ Stack vs Heap (what goes where, when)
- ✅ Garbage collection (algorithms, collectors)
- ✅ GC tuning (G1, ZGC, Parallel GC)
- ✅ Memory leaks (causes, detection, prevention)
- ✅ JVM parameters and tuning
- ✅ OutOfMemoryError types
- Profiling tools (jmap, jstack, jstat)

**Lines:** ~8,500 | **Difficulty:** Intermediate to Advanced

---

## Advanced Java

### [6. Multithreading & Concurrency Interview Guide](java-multithreading-concurrency-interview-guide.md)
**Topics Covered:**
- ✅ Thread lifecycle (NEW, RUNNABLE, BLOCKED, WAITING, TERMINATED)
- ✅ Thread creation (Thread class, Runnable, Callable)
- ✅ Synchronization (synchronized keyword, locks, monitors)
- ✅ ExecutorService (thread pools, Callable, Future)
- ✅ Deadlock (causes, detection, prevention)
- ✅ Concurrent collections (ConcurrentHashMap, CopyOnWriteArrayList)
- ✅ Locks (ReentrantLock, ReadWriteLock)
- ✅ Atomic variables (AtomicInteger, AtomicReference)
- ✅ CompletableFuture
- ThreadLocal and inter-thread communication
- Producer-Consumer, Dining Philosophers problems

**Lines:** ~3,800 | **Difficulty:** Intermediate to Advanced

---

### [7. Java 8+ Features Interview Guide](java-8-plus-features-interview-guide.md)
**Topics Covered:**
- ✅ Lambda expressions (syntax, functional interfaces)
- ✅ Streams API (filter, map, reduce, collect)
- ✅ Functional interfaces (Predicate, Function, Consumer, Supplier)
- ✅ Optional (handling nulls, best practices)
- ✅ Method references (static, instance, constructor)
- ✅ Default and static methods in interfaces
- ✅ Date and Time API (LocalDate, LocalTime, ZonedDateTime)
- ✅ CompletableFuture (async programming)
- ✅ Java 9+ features (modules, var, records, sealed classes)
- Stream performance and parallel streams

**Lines:** ~5,000 | **Difficulty:** Intermediate to Advanced

---

## Enterprise Java

### [8. Spring Framework & Spring Boot Interview Guide](java-spring-framework-interview-guide.md)
**Topics Covered:**
- Spring Core (IoC, Dependency Injection)
- Bean lifecycle and scopes
- Aspect-Oriented Programming (AOP)
- Spring Boot fundamentals (auto-configuration, starters)
- REST APIs with Spring MVC
- Exception handling and validation
- Spring Data JPA
- Transactions (@Transactional, propagation)
- Spring Security basics
- Testing Spring applications
- Actuator and production features

**Lines:** ~4,000 | **Difficulty:** Intermediate to Advanced

---

### [9. Database & JPA/Hibernate Interview Guide](java-database-jpa-hibernate-interview-guide.md)
**Topics Covered:**
- JDBC fundamentals (connection management, PreparedStatement)
- JPA overview and architecture
- Entity mappings and annotations
- Entity relationships (OneToOne, OneToMany, ManyToMany)
- JPQL and native queries
- Hibernate internals (entity lifecycle, persistence context)
- First-level and second-level cache
- Lazy loading vs eager loading (LazyInitializationException)
- N+1 query problem and solutions
- Transaction management
- Connection pooling (HikariCP)
- Query optimization (pagination, projections, batch operations)
- Spring Data JPA

**Lines:** ~3,500 | **Difficulty:** Intermediate to Advanced

---

### [10. Design Patterns Interview Guide](java-design-patterns-interview-guide.md)
**Topics Covered:**
- Creational patterns (Singleton, Factory, Builder, Prototype)
- Structural patterns (Adapter, Decorator, Proxy, Facade)
- Behavioral patterns (Strategy, Observer, Template Method)
- Enterprise patterns (DAO, DTO, Service Locator, MVC)
- Design patterns in Spring Framework
- SOLID principles with examples
- Anti-patterns to avoid
- Pattern selection and trade-offs

**Lines:** ~5,000 | **Difficulty:** Intermediate to Advanced

---

### [11. Microservices Architecture Interview Guide](java-microservices-architecture-interview-guide.md)
**Topics Covered:**
- Microservices fundamentals (monolith vs microservices)
- Service discovery (Eureka)
- API Gateway (Spring Cloud Gateway)
- Load balancing (client-side, server-side)
- Configuration management (Spring Cloud Config)
- Circuit Breaker pattern (Resilience4j)
- Inter-service communication (REST, messaging)
- Distributed tracing (Sleuth, Zipkin)
- Messaging (Kafka, RabbitMQ)
- Saga pattern (distributed transactions)
- CQRS and Event Sourcing
- Security in microservices (JWT)
- Monitoring and health checks
- Docker deployment

**Lines:** ~4,500 | **Difficulty:** Advanced

---

### [12. Testing & Build Tools Interview Guide](java-testing-build-tools-interview-guide.md)
**Topics Covered:**
- Testing fundamentals (unit, integration, E2E)
- JUnit 5 (assertions, lifecycle, parameterized tests)
- Mockito (mocking, stubbing, verification, BDD style)
- Spring Boot testing (@WebMvcTest, @DataJpaTest, @SpringBootTest)
- Integration testing (@TestConfiguration, profiles)
- REST API testing (MockMvc)
- Database testing (H2, @Sql, TestContainers)
- TestContainers (Docker containers for testing)
- Code coverage (JaCoCo)
- Testing best practices (FIRST principles)
- Maven (lifecycle, dependencies, multi-module)
- Gradle (Groovy DSL, tasks)

**Lines:** ~4,500 | **Difficulty:** Intermediate to Advanced

---

## Coding Practice

### [13. Java Coding Interview Problems](../coding/java-coding-interview-problems.md)
**20 Comprehensive Problems:**

**Arrays & Strings (5 problems):**
1. Two Sum - HashMap approach
2. Longest Substring Without Repeating Characters - Sliding window
3. Merge Intervals - Sorting and merging
4. Valid Parentheses - Stack-based solution
5. Rotate Array - Reverse algorithm

**Collections & Data Structures (4 problems):**
6. LRU Cache - HashMap + Doubly Linked List
7. Group Anagrams - HashMap with sorted keys
8. Top K Frequent Elements - Heap or bucket sort
9. Design HashMap - From scratch implementation

**Multithreading (3 problems):**
10. Print Numbers Alternately - wait() and notify()
11. Thread-Safe Singleton - Multiple approaches
12. Rate Limiter - Token bucket algorithm

**Java 8 Streams (4 problems):**
13. Find Second Highest Salary - Streams with distinct()
14. Group Employees by Department - Collectors.groupingBy()
15. FlatMap for Unique Words - flatMap() operations
16. Parallel Stream Processing - Performance comparison

**Design & OOP (3 problems):**
17. Design Parking Lot System - Full OOP design
18. Design Logger with Rate Limiting - ConcurrentHashMap
19. Implement Thread Pool - BlockingQueue and worker threads

**Real-World (1 problem):**
20. URL Shortener - Base62 encoding, collision handling

**Lines:** ~5,500 | **Difficulty:** Easy to Hard

---

### [14. Java Advanced Coding Problems](../coding/java-advanced-coding-problems.md)
**10 Advanced Problems (21-30):**

**Advanced Data Structures (3 problems):**
21. Implement Trie - Prefix tree with insert, search, startsWith, delete, autocomplete
22. Design Min Stack - O(1) getMin with two approaches
23. Implement LFU Cache - Least Frequently Used with O(1) operations

**Graph & Tree Algorithms (3 problems):**
24. Word Ladder - BFS shortest transformation path, bidirectional BFS
25. Binary Tree Maximum Path Sum - Post-order traversal, handling negative values
26. Clone Graph - Deep copy with DFS/BFS, cycle handling

**Dynamic Programming (2 problems):**
27. Coin Change - DP minimum coins, BFS approach
28. Longest Increasing Subsequence - DP O(n²), Binary Search O(n log n)

**System Design Coding (2 problems):**
29. Design In-Memory File System - Trie-like structure with ls, mkdir, addContent, readContent
30. Design Consistent Hashing - TreeMap ring, virtual nodes, weighted variant

**Lines:** ~4,500 | **Difficulty:** Medium to Hard

---

## System Design

### [15. System Design Interview Questions](java-system-design-questions.md)
**20 Comprehensive System Design Scenarios:**

**Social Media & Content (5 designs):**
- Q1: Design URL Shortener (bit.ly)
- Q2: Design Twitter News Feed
- Q3: Design Instagram
- Q4: Design YouTube Video Streaming
- Q5: Design WhatsApp Chat System

**E-Commerce & Booking (5 designs):**
- Q6: Design Amazon E-Commerce Platform
- Q7: Design Uber Ride-Hailing Service
- Q8: Design Hotel Booking System
- Q9: Design Payment Gateway
- Q10: Design Food Delivery App

**Real-Time Systems (4 designs):**
- Q11: Design Real-Time Notification System
- Q12: Design Rate Limiter
- Q13: Design Web Crawler
- Q14: Design Search Autocomplete

**Data-Intensive (3 designs):**
- Q15: Design Recommendation Engine
- Q16: Design Analytics Platform
- Q17: Design Distributed Cache

**Infrastructure (3 designs):**
- Q18: Design API Gateway
- Q19: Design Message Queue
- Q20: Design Monitoring System

Each design includes:
- Functional & non-functional requirements
- Capacity estimation
- API design
- Database schema
- Architecture components
- Scalability considerations
- Trade-offs discussion
- Technology stack

**Lines:** ~6,000+ | **Difficulty:** Medium to Hard

---

## Real Interview Questions

### [16. Real FAANG Interview Questions](java-real-interview-questions-faang.md)
**Actual Questions from Product Companies:**

**Companies Covered:**
- Amazon (Leadership Principles, Distributed Systems)
- Google (Algorithms, System Design)
- Microsoft (Azure, Design Patterns)
- Facebook/Meta (News Feed, Social Features)
- Netflix (Microservices, Chaos Engineering)
- Uber (Geolocation, Real-time Systems)
- LinkedIn (Social Graph, Recommendations)
- Startups (MVP Architecture, Optimization)

**Content Includes:**
- Coding round questions with solutions
- System design scenarios
- Behavioral questions (STAR format)
- Follow-up questions and variations
- Company-specific expectations
- Interview tips and strategies

**Lines:** ~4,000+ | **Difficulty:** Medium to Hard

---

# 📖 STUDY PLAN FOR 4-5 YEARS EXPERIENCE

## Week 1-2: Core Java Review
- [ ] OOP Principles (Guide #1)
- [ ] Strings (Guide #2)
- [ ] Exception Handling (Guide #3)
- [ ] Practice: Coding Problems 1-5

## Week 3-4: Collections & Memory
- [ ] Collections Framework (Guide #4)
- [ ] JVM & Memory Management (Guide #5)
- [ ] Practice: Coding Problems 6-9

## Week 5-6: Concurrency & Java 8
- [ ] Multithreading & Concurrency (Guide #6)
- [ ] Java 8+ Features (Guide #7)
- [ ] Practice: Coding Problems 10-16

## Week 7-8: Enterprise Java
- [ ] Spring Framework & Boot (Guide #8)
- [ ] Database & JPA/Hibernate (Guide #9)
- [ ] Design Patterns (Guide #10)

## Week 9-10: Advanced Topics
- [ ] Microservices Architecture (Guide #11)
- [ ] Testing & Build Tools (Guide #12)
- [ ] Practice: Coding Problems 17-20

## Week 11: Advanced Algorithms & System Design
- [ ] Advanced Coding Problems (Guide #14) - Problems 21-30
- [ ] System Design Questions (Guide #15) - Q1-Q10
- [ ] Practice: Design at least 5 systems on whiteboard

## Week 12: Interview Preparation & FAANG Questions
- [ ] Real FAANG Interview Questions (Guide #16)
- [ ] System Design Questions (Guide #15) - Q11-Q20
- [ ] Review all interview questions
- [ ] Mock interviews with peers
- [ ] Company-specific preparation

---

# 🎯 INTERVIEW TOPICS CHECKLIST

## Core Java Fundamentals ✓
- [x] **OOP Concepts** - Encapsulation, Inheritance, Polymorphism, Abstraction, Composition vs Inheritance
- [x] **Java Basics** - JVM, JRE, JDK, Memory model, Stack vs Heap
- [x] **Access Modifiers** - public, private, protected, default
- [x] **Static Keyword** - static variables, methods, blocks, import
- [x] **Final Keyword** - final variables, methods, classes
- [x] **Java Collections Framework** - List, Set, Map, Queue implementations
- [x] **Strings** - String Pool, Immutability, StringBuilder vs StringBuffer
- [x] **Exception Handling** - Checked vs Unchecked, Custom exceptions, Best practices

## Advanced Java ✓
- [x] **Multithreading** - Thread lifecycle, Synchronization, ExecutorService, Deadlock, Concurrent collections
- [x] **Java 8 Features** - Lambda expressions, Streams API, Functional interfaces, Optional
- [x] **JVM Internals** - Garbage collection, Class loading, Memory areas

## Enterprise Java ✓
- [x] **Spring Framework** - IoC/DI, AOP, Spring Boot, REST APIs, Spring Data JPA, Transactions, Security
- [x] **Database & JPA** - JDBC, Entity mappings, Hibernate caching, N+1 problem, Query optimization
- [x] **Design Patterns** - Creational, Structural, Behavioral patterns, SOLID principles
- [x] **Microservices** - Service discovery, API Gateway, Circuit breaker, Distributed tracing, Messaging

## Testing & Tools ✓
- [x] **JUnit & Mockito** - Unit testing, Mocking, Integration testing
- [x] **Maven/Gradle** - Build lifecycle, Dependencies, Multi-module projects

## Coding Problems ✓
- [x] **30 Coding Problems** - Arrays, Strings, Collections, Multithreading, Streams, Design
- [x] **20 Basic Problems** - Two Sum, LRU Cache, Valid Parentheses, URL Shortener, Parking Lot
- [x] **10 Advanced Problems** - Trie, Min Stack, LFU Cache, Word Ladder, Binary Tree Max Path, Clone Graph, Coin Change, LIS, File System, Consistent Hashing

## System Design ✓
- [x] **20 System Design Questions** - URL Shortener, Twitter, Instagram, YouTube, WhatsApp, Amazon, Uber, and more
- [x] **Architecture Patterns** - Scalability, Caching, Load Balancing, Sharding, Replication
- [x] **Trade-offs** - CAP theorem, SQL vs NoSQL, Sync vs Async

## Real Interviews ✓
- [x] **FAANG Questions** - Amazon, Google, Microsoft, Facebook/Meta, Netflix, Uber, LinkedIn
- [x] **Behavioral Questions** - Leadership Principles, STAR format examples
- [x] **Company-Specific Tips** - What each company looks for

---

# 📊 COVERAGE SUMMARY

| **Category** | **Topics** | **Interview Questions** | **Coding Problems** | **Lines of Content** |
|--------------|-----------|------------------------|---------------------|---------------------|
| Core Java | 7 guides | 150+ Q&A | Basic coding | ~32,000 lines |
| Enterprise | 5 guides | 100+ Q&A | Design problems | ~21,500 lines |
| Advanced Coding | 1 guide | - | 30 problems | ~10,000 lines |
| System Design | 1 guide | 20 scenarios | - | ~6,000 lines |
| Real Interviews | 1 guide | FAANG questions | Examples | ~4,000 lines |
| **Total** | **16 guides** | **270+ Q&A** | **30 problems + 20 designs** | **73,500+ lines** |

---

# 💡 HOW TO USE THIS GUIDE

## For Interview Preparation
1. **Start with Core Java** (Guides 1-7) if you need to refresh fundamentals
2. **Focus on Enterprise Java** (Guides 8-12) for senior roles
3. **Practice Coding Problems** (Guides 13-14) regularly - all 30 problems
4. **Master System Design** (Guide 15) - whiteboard practice for all 20 scenarios
5. **Study Real Questions** (Guide 16) - prepare for company-specific rounds
6. **Review interview questions** at the end of each guide
7. **Understand trade-offs** - every guide explains when to use what

## For Quick Reference
- Each guide has a **Summary & Quick Reference** section
- Use **Table of Contents** to jump to specific topics
- **Interview Traps** sections highlight common mistakes

## For Hands-On Practice
- **30 coding problems** with complete solutions and test cases
- **20 system design scenarios** with detailed architectures
- **Code examples** in every guide are production-ready
- **Real interview questions** from FAANG companies

---

# 🚀 KEY FEATURES

✅ **Complete Coverage** - Every topic for 4-5 years experience  
✅ **30 Coding Problems** - From basic to advanced algorithms  
✅ **20 System Design Questions** - Real-world scalable architectures  
✅ **Real FAANG Questions** - Actual interview questions from product companies  
✅ **Interview-Focused** - Questions, traps, and follow-ups  
✅ **Practical Code** - Production-quality examples with test cases  
✅ **Progressive Difficulty** - Beginner to Advanced  
✅ **Problem-Solution Format** - Easy to navigate  
✅ **Best Practices** - Industry-standard approaches  
✅ **Performance Tips** - Optimization techniques  
✅ **Common Pitfalls** - Avoid these interview traps  
✅ **73,500+ Lines** - Comprehensive, in-depth coverage  

---

# 🎓 TARGET AUDIENCE

This guide is designed for:
- **Java Developers** with 4-5 years of experience
- **Preparing for interviews** at product companies, FAANG, startups
- **Backend Engineers** working with Spring Boot and microservices
- **Students** transitioning to senior developer roles
- **Self-learners** wanting comprehensive Java knowledge

---

# 📝 COMPANIES COVERED

Interview questions and problems from:
- **Amazon** - System design, coding, Java internals
- **Google** - Algorithms, concurrency, design patterns
- **Microsoft** - Collections, multithreading, Spring
- **Facebook/Meta** - Streams, design patterns, microservices
- **Oracle** - JVM, memory management, enterprise Java
- **Uber, Netflix, LinkedIn** - Real-world scenarios

---

# ⚡ QUICK START

## Option 1: Full Preparation (12 weeks)
1. **Week 1-6**: Core Java (Guides #1-7) + Problems 1-10
2. **Week 7-10**: Enterprise Java (Guides #8-12) + Problems 11-20
3. **Week 11**: Advanced Coding (Guide #14) + System Design (Guide #15, Q1-10)
4. **Week 12**: FAANG Questions (Guide #16) + System Design (Guide #15, Q11-20)

## Option 2: Quick Review (2 weeks)
1. **Week 1**: Collections (#4), Multithreading (#6), Java 8 (#7), Spring (#8) + Problems 1-15
2. **Week 2**: Advanced Problems (#14, 21-30), System Design (#15), FAANG Questions (#16)

## Option 3: Start Practice Now
1. **Coding**: [Java Coding Interview Problems](../coding/java-coding-interview-problems.md) - Try problems 1-5
2. **System Design**: [System Design Questions](java-system-design-questions.md) - Design URL Shortener
3. **Real Questions**: [FAANG Interview Questions](java-real-interview-questions-faang.md) - Amazon rounds

---

# 📚 ADDITIONAL RESOURCES

## Files in This Package
- **16 Interview Guides** (markdown format)
- **270+ Interview Questions** with detailed answers
- **30 Coding Problems** with complete solutions and test cases
- **20 System Design Scenarios** with detailed architectures
- **Real FAANG Questions** from Amazon, Google, Microsoft, Meta, Netflix, Uber, LinkedIn
- **1000+ Code Examples** (production-ready Java code)
- **Diagrams & Tables** for visual learning

## What's Included
- ✅ **Core Java** (7 guides): OOP, Strings, Exceptions, Collections, JVM, Multithreading, Java 8
- ✅ **Enterprise Java** (5 guides): Spring, Database/JPA, Design Patterns, Microservices, Testing
- ✅ **Coding Practice** (2 guides): 20 basic + 10 advanced problems
- ✅ **System Design** (1 guide): 20 scalable architecture scenarios
- ✅ **Real Interviews** (1 guide): Actual questions from product companies

---

---

# 🏆 SUCCESS TIPS

1. **Understand, Don't Memorize** - Focus on concepts, not rote learning
2. **Practice Coding** - Write code, don't just read
3. **Explain Out Loud** - Practice explaining solutions
4. **Time Yourself** - Solve problems under time constraints
5. **Review Mistakes** - Learn from wrong approaches
6. **Mock Interviews** - Practice with peers
7. **Stay Updated** - Keep learning new Java features

---

# 📞 FEEDBACK & CONTRIBUTIONS

This is a comprehensive guide meant to evolve. Suggestions for improvement are welcome!

---

**GOOD LUCK WITH YOUR INTERVIEWS! 🎯**

*Master these 16 guides (30 coding problems + 20 system design questions + real FAANG questions) and you'll be ready for any Java interview from mid-level to senior roles at product companies.*

---

# 📋 COMPLETE GUIDE LIST

1. [Java OOP Principles](java-oop-interview-guide.md)
2. [Java Strings](java-strings-interview-guide.md)
3. [Exception Handling](java-exception-handling-interview-guide.md)
4. [Collections Framework](java-collections-framework-interview-guide.md)
5. [JVM & Memory Management](java-jvm-memory-management-interview-guide.md)
6. [Multithreading & Concurrency](java-multithreading-concurrency-interview-guide.md)
7. [Java 8+ Features](java-8-plus-features-interview-guide.md)
8. [Spring Framework & Boot](java-spring-framework-interview-guide.md)
9. [Database & JPA/Hibernate](java-database-jpa-hibernate-interview-guide.md)
10. [Design Patterns](java-design-patterns-interview-guide.md)
11. [Microservices Architecture](java-microservices-architecture-interview-guide.md)
12. [Testing & Build Tools](java-testing-build-tools-interview-guide.md)
13. [Coding Problems (1-20)](../coding/java-coding-interview-problems.md)
14. [Advanced Coding Problems (21-30)](../coding/java-advanced-coding-problems.md)
15. [System Design Questions (20 scenarios)](java-system-design-questions.md)
16. [Real FAANG Interview Questions](java-real-interview-questions-faang.md)

---

**Total Content: 73,500+ lines | 270+ interview Q&A | 30 coding problems | 20 system designs**



