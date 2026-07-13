# REAL INTERVIEW QUESTIONS FROM FAANG & PRODUCT COMPANIES

**Actual questions reported from interviews at Amazon, Google, Microsoft, Facebook/Meta, Netflix, Uber, LinkedIn, and other product companies. Compiled for 4-5 years experienced Backend Java Developers.**

---

# TABLE OF CONTENTS

1. [Amazon Interviews](#1-amazon-interviews)
2. [Google Interviews](#2-google-interviews)
3. [Microsoft Interviews](#3-microsoft-interviews)
4. [Facebook/Meta Interviews](#4-facebookmeta-interviews)
5. [Netflix Interviews](#5-netflix-interviews)
6. [Uber Interviews](#6-uber-interviews)
7. [LinkedIn Interviews](#7-linkedin-interviews)
8. [Startup Interviews](#8-startup-interviews)

---

# 1. AMAZON INTERVIEWS

## 1.1 Amazon Coding Rounds

### Round 1: Arrays & Strings (45 minutes)

**Q1.1: Two Sum Variations**
```
Given array of integers, find all pairs that sum to target K.
Follow-up: What if array is sorted? What about 3-sum?

Answer:
- Unsorted: HashMap O(n)
- Sorted: Two pointers O(n)
- 3-sum: Fix one element, two pointers O(n²)

public List<int[]> twoSum(int[] nums, int target) {
    Map<Integer, Integer> map = new HashMap<>();
    List<int[]> result = new ArrayList<>();
    
    for (int i = 0; i < nums.length; i++) {
        int complement = target - nums[i];
        if (map.containsKey(complement)) {
            result.add(new int[]{map.get(complement), i});
        }
        map.put(nums[i], i);
    }
    
    return result;
}
```

**Q1.2: Most Common Word**
```
Given a paragraph and list of banned words, return most frequent non-banned word.
"Bob hit a ball, the hit BALL flew far after it was hit."
Banned: ["hit"]
Output: "ball"

Key Points:
- Case-insensitive
- Handle punctuation
- HashMap for frequency counting

public String mostCommonWord(String paragraph, String[] banned) {
    Set<String> bannedSet = new HashSet<>(Arrays.asList(banned));
    Map<String, Integer> count = new HashMap<>();
    
    String[] words = paragraph.toLowerCase()
        .replaceAll("[^a-z ]", " ")
        .split("\\s+");
    
    for (String word : words) {
        if (!bannedSet.contains(word)) {
            count.put(word, count.getOrDefault(word, 0) + 1);
        }
    }
    
    return Collections.max(count.entrySet(), Map.Entry.comparingByValue())
        .getKey();
}
```

**Q1.3: Merge Intervals**
```
Given intervals, merge all overlapping intervals.
Input: [[1,3],[2,6],[8,10],[15,18]]
Output: [[1,6],[8,10],[15,18]]

Amazon asks: How would you handle millions of intervals?
Answer: External sorting, batch processing

public int[][] merge(int[][] intervals) {
    Arrays.sort(intervals, (a, b) -> Integer.compare(a[0], b[0]));
    
    List<int[]> merged = new ArrayList<>();
    int[] current = intervals[0];
    
    for (int i = 1; i < intervals.length; i++) {
        if (intervals[i][0] <= current[1]) {
            current[1] = Math.max(current[1], intervals[i][1]);
        } else {
            merged.add(current);
            current = intervals[i];
        }
    }
    merged.add(current);
    
    return merged.toArray(new int[merged.size()][]);
}
```

### Round 2: Data Structures (45 minutes)

**Q1.4: LRU Cache**
```
Design LRU cache with O(1) get and put operations.

Amazon Follow-ups:
1. How to make it thread-safe?
2. How to implement distributed LRU cache?
3. How to handle cache invalidation?

Answers:
1. Use ConcurrentHashMap + synchronized on operations
2. Use Redis with TTL, consistent hashing
3. Time-based expiry, event-driven invalidation

[Complete implementation in Coding Problems Guide]
```

**Q1.5: Design Log Storage System**
```
Design a system to store logs with timestamp.
Operations:
- put(id, timestamp, log)
- retrieve(start, end) - all logs in time range

Amazon expects:
- TreeMap for sorted timestamps
- Granularity optimization (year/month/day buckets)
- Pagination for large results

public class LogSystem {
    private Map<String, List<LogEntry>> buckets = new HashMap<>();
    
    public void put(int id, String timestamp, String log) {
        String bucket = getBucket(timestamp);
        buckets.computeIfAbsent(bucket, k -> new ArrayList<>())
               .add(new LogEntry(id, timestamp, log));
    }
    
    public List<Integer> retrieve(String start, String end) {
        List<Integer> result = new ArrayList<>();
        
        // Iterate relevant buckets only
        for (String bucket : buckets.keySet()) {
            if (isInRange(bucket, start, end)) {
                for (LogEntry entry : buckets.get(bucket)) {
                    if (entry.timestamp.compareTo(start) >= 0 &&
                        entry.timestamp.compareTo(end) <= 0) {
                        result.add(entry.id);
                    }
                }
            }
        }
        
        return result;
    }
}
```

### Round 3: System Design (60 minutes)

**Q1.6: Design Amazon Product Recommendation System**
```
Requirements:
- Recommend products based on browsing history
- Real-time updates
- Personalized recommendations

Components:
1. User Activity Tracker (Kafka streams)
2. Recommendation Engine (Collaborative filtering)
3. Cache Layer (Redis)
4. A/B Testing framework

Amazon looks for:
- Scalability (millions of users)
- Machine Learning integration
- Performance optimization
- Metrics and monitoring
```

**Q1.7: Design Order Management System**
```
Handle order placement, inventory updates, payment processing.

Amazon expects discussion of:
- Saga pattern for distributed transactions
- Event sourcing for order history
- Compensating transactions
- Idempotency handling

@Service
public class OrderService {
    
    @Autowired
    private EventPublisher eventPublisher;
    
    @Transactional
    public Order placeOrder(OrderRequest request) {
        // 1. Create order
        Order order = createOrder(request);
        
        // 2. Publish events for saga
        eventPublisher.publish(new OrderCreatedEvent(order));
        // → Triggers: ReserveInventory → ProcessPayment → ShipOrder
        
        return order;
    }
    
    // Compensating transaction
    @EventListener
    public void handlePaymentFailed(PaymentFailedEvent event) {
        // Release inventory
        inventoryService.releaseReservation(event.getOrderId());
        
        // Cancel order
        orderRepository.updateStatus(event.getOrderId(), OrderStatus.CANCELLED);
    }
}
```

## 1.2 Amazon Leadership Principles Questions

**LP: Customer Obsession**
```
Q: "Tell me about a time when you went above and beyond for a customer."

Technical Example:
"Our API was timing out for a customer with large datasets. Instead of asking them 
to reduce data, I implemented pagination, caching, and async processing. 
Reduced response time from 30s to <2s."
```

**LP: Dive Deep**
```
Q: "Describe a time you debugged a complex production issue."

Example:
"Memory leak in microservice. Used JProfiler to identify Spring @Scheduled tasks 
creating unbounded ThreadPoolExecutor. Fixed by using @EnableScheduling with 
proper pool configuration. Reduced memory usage 70%."
```

**LP: Ownership**
```
Q: "Tell me about a project you owned end-to-end."

Example:
"Led migration from monolith to microservices. Owned service decomposition, 
API design, data migration strategy. Resulted in 3x better scalability and 
independent deployments."
```

---

# 2. GOOGLE INTERVIEWS

## 2.1 Google Coding Rounds

### Round 1: Algorithms (45 minutes)

**Q2.1: Longest Substring Without Repeating Characters**
```
Classic sliding window problem.
Google asks: Can you do it in one pass?

public int lengthOfLongestSubstring(String s) {
    Map<Character, Integer> lastSeen = new HashMap<>();
    int maxLen = 0, start = 0;
    
    for (int end = 0; end < s.length(); end++) {
        char c = s.charAt(end);
        
        if (lastSeen.containsKey(c)) {
            start = Math.max(start, lastSeen.get(c) + 1);
        }
        
        lastSeen.put(c, end);
        maxLen = Math.max(maxLen, end - start + 1);
    }
    
    return maxLen;
}

Follow-up: What if you need to return the actual substring?
```

**Q2.2: Design In-Memory File System**
```
Google loves this question!
Operations: ls, mkdir, addContentToFile, readContentFromFile

[Complete implementation in Advanced Coding Problems #29]

Follow-ups:
1. How to add permissions (read/write)?
2. How to implement file search?
3. How to handle concurrent writes?
```

**Q2.3: Word Ladder**
```
Find shortest transformation sequence from beginWord to endWord.
Google expects: BFS explanation, bidirectional BFS optimization

[Complete implementation in Advanced Coding Problems #24]

Follow-up: What if dictionary has 1 million words?
Answer: Trie for efficient word lookup, parallel BFS
```

### Round 2: Data Structures & Trees (45 minutes)

**Q2.4: Binary Tree Maximum Path Sum**
```
[Complete implementation in Advanced Coding Problems #25]

Google Follow-ups:
Q: What if negative values dominate the tree?
A: Return 0 if all paths are negative, or allow negative max.

Q: How to get the actual path, not just sum?
A: Track path during recursion, store in global variable.
```

**Q2.5: Implement Trie with Autocomplete**
```
[Complete implementation in Advanced Coding Problems #21]

Google asks: How would you implement spell checking?
Answer: 
- Trie with edit distance (Levenshtein)
- Return words within distance threshold
- BK-tree for efficient fuzzy search
```

### Round 3: System Design (60 minutes)

**Q2.6: Design Google Drive**
```
Requirements:
- File upload/download
- Real-time sync across devices
- Sharing permissions
- Version control

Key Components:
1. Chunking Service (split large files)
2. Metadata Service (file info, permissions)
3. Sync Service (diff algorithm)
4. Notification Service (WebSocket)
5. Storage (S3/GCS)

Google expects discussion of:
- Delta sync algorithm
- Conflict resolution
- Efficient storage (deduplication)
- CDN for downloads

@Service
public class FileSyncService {
    
    public void syncFile(String fileId, FileVersion clientVersion) {
        FileVersion serverVersion = getServerVersion(fileId);
        
        // Calculate delta
        List<Chunk> changedChunks = diffAlgorithm.compare(
            clientVersion, serverVersion
        );
        
        // Only upload changed chunks
        for (Chunk chunk : changedChunks) {
            uploadChunk(fileId, chunk);
        }
        
        // Update metadata
        metadataService.updateVersion(fileId, clientVersion);
        
        // Notify other devices
        notificationService.notifyOtherDevices(fileId);
    }
}
```

**Q2.7: Design YouTube Search**
```
Requirements:
- Search videos by title, description, tags
- Ranked results (relevance, views, recency)
- Auto-suggestions
- Typo tolerance

Components:
1. ElasticSearch for indexing
2. Ranking algorithm (TF-IDF, PageRank-like)
3. Trie for autocomplete
4. Cache popular searches

Google looks for:
- Inverted index understanding
- Ranking factors discussion
- Scalability (billions of videos)
```

## 2.2 Google Culture Questions

**Q: "Tell me about your most technically challenging project."**
```
Example Answer:
"Built a real-time analytics pipeline processing 100K events/sec. 
Challenges: 
- Data skew in Kafka partitions → Custom partitioner
- High memory usage → Optimized with off-heap storage
- Late arriving data → Watermarks and windowing in Flink
Result: 99.9% accuracy with <5s latency"
```

---

# 3. MICROSOFT INTERVIEWS

## 3.1 Microsoft Coding Rounds

**Q3.1: Design HashMap from Scratch**
```
[Complete implementation in Coding Problems #8]

Microsoft Follow-ups:
Q: How does ConcurrentHashMap work?
A: Segmented locking (Java 7), CAS operations (Java 8+)

Q: What is the difference between HashMap and TreeMap?
A: HashMap O(1) unordered, TreeMap O(log n) sorted
```

**Q3.2: Implement Thread-Safe Singleton**
```
[Complete implementation in Coding Problems #12]

Microsoft asks: Why is double-checked locking needed?
Answer:
- volatile prevents instruction reordering
- First check avoids synchronized overhead after initialization
- Second check ensures only one instance is created
```

**Q3.3: Design Rate Limiter**
```
[Complete implementation in Coding Problems #13]

Microsoft expects comparison of algorithms:
1. Token Bucket - smooth rate limiting
2. Leaky Bucket - constant output rate
3. Fixed Window - simple but bursts at edges
4. Sliding Window - accurate but more memory
```

### System Design Round

**Q3.4: Design Outlook Email System**
```
Requirements:
- Send/receive emails
- Search emails
- Folders, labels
- Attachments
- Spam detection

Microsoft expects:
- SMTP/IMAP protocol knowledge
- Email storage optimization
- Search indexing (ElasticSearch)
- Attachment storage (blob storage)
- Spam filtering (ML models)

Components:
1. SMTP Server (sending)
2. IMAP Server (receiving)
3. Storage Service (Azure Blob)
4. Search Index (ElasticSearch)
5. Spam Filter (ML pipeline)
```

---

# 4. FACEBOOK/META INTERVIEWS

## 4.1 Meta Coding Rounds

**Q4.1: Valid Parentheses**
```
[Complete implementation in Coding Problems #4]

Meta Follow-up: How to generate all valid parentheses combinations?
Answer: Backtracking

public List<String> generateParentheses(int n) {
    List<String> result = new ArrayList<>();
    backtrack(result, "", 0, 0, n);
    return result;
}

private void backtrack(List<String> result, String current, 
                      int open, int close, int max) {
    if (current.length() == max * 2) {
        result.add(current);
        return;
    }
    
    if (open < max) {
        backtrack(result, current + "(", open + 1, close, max);
    }
    if (close < open) {
        backtrack(result, current + ")", open, close + 1, max);
    }
}
```

**Q4.2: Clone Graph**
```
[Complete implementation in Advanced Coding Problems #26]

Meta asks: How would you clone a social network graph efficiently?
Answer:
- Parallel processing with thread pool
- Batch processing for large graphs
- Incremental cloning (streaming)
```

**Q4.3: Design News Feed Ranking**
```
Meta core problem!

Requirements:
- Rank posts by relevance
- Consider: likes, comments, shares, recency, user preferences
- Personalized for each user

Ranking Algorithm:
Score = w1*likes + w2*comments + w3*shares + w4*recency + w5*user_affinity

@Service
public class NewsFeedRankingService {
    
    public List<Post> rankFeed(Long userId, List<Post> posts) {
        UserPreferences prefs = getUserPreferences(userId);
        
        return posts.stream()
            .map(post -> {
                double score = calculateScore(post, prefs);
                return new ScoredPost(post, score);
            })
            .sorted(Comparator.comparing(ScoredPost::getScore).reversed())
            .map(ScoredPost::getPost)
            .collect(Collectors.toList());
    }
    
    private double calculateScore(Post post, UserPreferences prefs) {
        double engagementScore = 
            0.3 * post.getLikes() + 
            0.4 * post.getComments() + 
            0.3 * post.getShares();
        
        double recencyScore = calculateRecencyScore(post.getCreatedAt());
        double affinityScore = calculateAffinity(prefs, post.getAuthorId());
        
        return 0.4 * engagementScore + 
               0.3 * recencyScore + 
               0.3 * affinityScore;
    }
}
```

---

# 5. NETFLIX INTERVIEWS

## 5.1 Netflix Coding & System Design

**Q5.1: Design Netflix Video Streaming**
```
[Detailed in System Design Q4]

Netflix-specific questions:
Q: How to handle network variations?
A: Adaptive Bitrate Streaming (ABR)
   - Monitor network bandwidth
   - Switch between quality levels
   - Buffer management

Q: How to optimize CDN costs?
A: 
- Popular content on edge servers
- Long-tail content on origin
- Predictive pre-warming
- Time-based pricing optimization

@Service
public class VideoStreamingService {
    
    public StreamResponse getStream(String videoId, String quality) {
        // Check CDN availability
        String cdnUrl = cdnService.getUrl(videoId, quality);
        
        if (cdnUrl == null) {
            // CDN miss - fetch from origin
            cdnUrl = originService.getUrl(videoId, quality);
            
            // Async CDN population
            cdnService.populateAsync(videoId, quality);
        }
        
        // Return HLS manifest
        return new StreamResponse(cdnUrl, getManifest(videoId));
    }
}
```

**Q5.2: Design Recommendation Engine**
```
Netflix's crown jewel!

Approaches:
1. Collaborative Filtering (users who liked X also liked Y)
2. Content-Based Filtering (similar genres, actors, directors)
3. Hybrid approach (combine both)

@Service
public class RecommendationService {
    
    public List<Movie> getRecommendations(Long userId, int count) {
        // Get user's watch history
        List<Movie> watchedMovies = getWatchHistory(userId);
        
        // Get similar users
        List<Long> similarUsers = findSimilarUsers(userId);
        
        // Get what similar users watched
        Map<Movie, Double> scores = new HashMap<>();
        for (Long similarUser : similarUsers) {
            List<Movie> theirMovies = getWatchHistory(similarUser);
            for (Movie movie : theirMovies) {
                if (!watchedMovies.contains(movie)) {
                    scores.merge(movie, 
                        getSimilarityScore(userId, similarUser), 
                        Double::sum
                    );
                }
            }
        }
        
        // Return top N
        return scores.entrySet().stream()
            .sorted(Map.Entry.<Movie, Double>comparingByValue().reversed())
            .limit(count)
            .map(Map.Entry::getKey)
            .collect(Collectors.toList());
    }
}
```

**Q5.3: Chaos Engineering Question**
```
Q: "How would you test resilience of microservices?"

Netflix expects Chaos Engineering discussion:
- Chaos Monkey (random instance termination)
- Latency injection
- Network partition simulation
- Dependency failure testing

Example:
@Component
public class ChaosInterceptor implements HandlerInterceptor {
    
    @Value("${chaos.enabled}")
    private boolean chaosEnabled;
    
    @Value("${chaos.failure.rate}")
    private double failureRate;
    
    @Override
    public boolean preHandle(HttpServletRequest request, 
                            HttpServletResponse response, 
                            Object handler) {
        if (chaosEnabled && Math.random() < failureRate) {
            // Inject random failure
            int scenario = (int) (Math.random() * 3);
            switch (scenario) {
                case 0: // Timeout
                    Thread.sleep(5000);
                    break;
                case 1: // Error
                    throw new RuntimeException("Chaos Monkey!");
                case 2: // Slow response
                    Thread.sleep(2000);
            }
        }
        return true;
    }
}
```

---

# 6. UBER INTERVIEWS

## 6.1 Uber Coding Rounds

**Q6.1: Design Uber Ride Matching**
```
Match riders with nearby drivers in real-time.

Key Algorithm: Geospatial Indexing

// Geohash-based matching
@Service
public class RideMatchingService {
    
    // Redis sorted set for driver locations
    @Autowired
    private RedisGeoCommands redisGeo;
    
    public List<Driver> findNearbyDrivers(Location riderLocation, double radiusKm) {
        // Find drivers within radius using geospatial index
        GeoResults<GeoLocation<String>> results = redisGeo.radius(
            "drivers",
            new Circle(new Point(riderLocation.getLon(), riderLocation.getLat()), 
                      new Distance(radiusKm, Metrics.KILOMETERS))
        );
        
        return results.getContent().stream()
            .map(result -> driverService.getDriver(result.getContent().getName()))
            .filter(Driver::isAvailable)
            .limit(10)
            .collect(Collectors.toList());
    }
    
    public Driver matchDriver(RideRequest request) {
        List<Driver> nearbyDrivers = findNearbyDrivers(
            request.getPickupLocation(), 5.0
        );
        
        // Ranking: distance, rating, acceptance rate, surge multiplier
        return nearbyDrivers.stream()
            .max(Comparator.comparing(d -> calculateMatchScore(d, request)))
            .orElse(null);
    }
    
    private double calculateMatchScore(Driver driver, RideRequest request) {
        double distanceScore = 1.0 / (getDistance(driver, request) + 1);
        double ratingScore = driver.getRating() / 5.0;
        double acceptanceScore = driver.getAcceptanceRate();
        
        return 0.5 * distanceScore + 0.3 * ratingScore + 0.2 * acceptanceScore;
    }
}
```

**Q6.2: Calculate Surge Pricing**
```
Uber's dynamic pricing algorithm.

@Service
public class SurgePricingService {
    
    public double calculateSurgeMultiplier(Location location) {
        int rides = getRideRequestsInArea(location);
        int drivers = getAvailableDriversInArea(location);
        
        double demandSupplyRatio = (double) rides / (drivers + 1);
        
        // Surge pricing formula
        if (demandSupplyRatio < 1.0) {
            return 1.0;  // No surge
        } else if (demandSupplyRatio < 2.0) {
            return 1.5;
        } else if (demandSupplyRatio < 3.0) {
            return 2.0;
        } else {
            return Math.min(3.0, 1.0 + demandSupplyRatio * 0.5);
        }
    }
}
```

**Q6.3: ETA Calculation**
```
Q: "How would you calculate accurate ETA?"

Factors:
- Distance (Google Maps API)
- Current traffic
- Historical data (same time/day)
- Driver speed patterns
- Event impacts

@Service
public class ETAService {
    
    @Autowired
    private GoogleMapsClient mapsClient;
    
    @Autowired
    private TrafficService trafficService;
    
    public Duration calculateETA(Location from, Location to) {
        // Base ETA from Maps API
        Duration baseETA = mapsClient.getDistance(from, to).getDuration();
        
        // Traffic adjustment
        double trafficMultiplier = trafficService.getTrafficMultiplier(from, to);
        
        // Historical adjustment
        double historicalMultiplier = getHistoricalMultiplier(
            LocalTime.now(), DayOfWeek.from(LocalDate.now())
        );
        
        long adjustedSeconds = Math.round(
            baseETA.getSeconds() * trafficMultiplier * historicalMultiplier
        );
        
        return Duration.ofSeconds(adjustedSeconds);
    }
}
```

---

# 7. LINKEDIN INTERVIEWS

## 7.1 LinkedIn Coding Rounds

**Q7.1: Design LinkedIn Connection System**
```
Find degrees of separation between users.

// Graph traversal (BFS)
@Service
public class ConnectionService {
    
    public int getDegreeOfSeparation(Long user1, Long user2) {
        if (user1.equals(user2)) return 0;
        
        Queue<Long> queue = new LinkedList<>();
        Set<Long> visited = new HashSet<>();
        Map<Long, Integer> degree = new HashMap<>();
        
        queue.offer(user1);
        visited.add(user1);
        degree.put(user1, 0);
        
        while (!queue.isEmpty()) {
            Long current = queue.poll();
            int currentDegree = degree.get(current);
            
            if (currentDegree >= 3) continue;  // LinkedIn shows up to 3rd degree
            
            List<Long> connections = getConnections(current);
            for (Long connection : connections) {
                if (connection.equals(user2)) {
                    return currentDegree + 1;
                }
                
                if (!visited.contains(connection)) {
                    visited.add(connection);
                    degree.put(connection, currentDegree + 1);
                    queue.offer(connection);
                }
            }
        }
        
        return -1;  // Not connected
    }
}
```

**Q7.2: Design Job Recommendation System**
```
Recommend jobs based on user profile, skills, experience.

@Service
public class JobRecommendationService {
    
    public List<Job> recommendJobs(Long userId, int count) {
        UserProfile profile = getUserProfile(userId);
        
        // Build query for ElasticSearch
        SearchQuery query = SearchQuery.builder()
            .must(matchSkills(profile.getSkills()))
            .must(matchExperience(profile.getYearsOfExperience()))
            .should(matchLocation(profile.getLocation()))
            .should(matchIndustry(profile.getIndustry()))
            .build();
        
        return elasticSearch.search(query, count);
    }
}
```

---

# 8. STARTUP INTERVIEWS

## 8.1 Common Startup Questions

**Q8.1: "We need to build an MVP quickly. How would you architect it?"**
```
Answer should emphasize:
- Monolith first (not microservices)
- Managed services (AWS RDS, Redis, S3)
- Single deployment
- Focus on core features
- Technical debt is OK initially

@SpringBootApplication
public class MVPApplication {
    // Single monolithic app
    // All features in one deployment
    // Can extract to microservices later
}
```

**Q8.2: "Our database queries are slow. How would you optimize?"**
```
Systematic approach:
1. Enable slow query log
2. Add missing indexes
3. Optimize N+1 queries (use JOIN FETCH)
4. Add caching (Redis)
5. Database connection pooling
6. Consider read replicas

Example:
// Before (N+1 problem)
List<User> users = userRepository.findAll();
users.forEach(u -> u.getOrders().size());  // N queries

// After (JOIN FETCH)
@Query("SELECT u FROM User u LEFT JOIN FETCH u.orders")
List<User> findAllWithOrders();
```

**Q8.3: "How would you handle sudden traffic spike (10x normal)?"**
```
Immediate actions:
1. Enable auto-scaling
2. Add caching layer
3. Rate limiting
4. CDN for static content
5. Database read replicas
6. Async processing for non-critical tasks

Long-term:
1. Load testing
2. Performance monitoring
3. Capacity planning
4. Circuit breakers
```

---

# SUMMARY: KEY INTERVIEW PATTERNS

## Coding Round Patterns
1. **Arrays/Strings**: Two pointers, sliding window, HashMap
2. **Trees/Graphs**: BFS, DFS, recursion
3. **Dynamic Programming**: Bottom-up, memoization
4. **Design**: LRU Cache, Rate Limiter, Thread-Safe structures

## System Design Patterns
1. **Scalability**: Horizontal scaling, load balancing, sharding
2. **Performance**: Caching, CDN, async processing
3. **Reliability**: Replication, fault tolerance, circuit breakers
4. **Data**: SQL vs NoSQL, partitioning, indexing

## Behavioral Patterns (STAR Format)
- **Situation**: Context and background
- **Task**: Your responsibility
- **Action**: What you did specifically
- **Result**: Measurable impact

---

**Company-Specific Tips:**

- **Amazon**: Leadership Principles, distributed systems, scale
- **Google**: Algorithms, clean code, computer science fundamentals
- **Microsoft**: .NET integration acceptable, Azure knowledge helps
- **Meta**: Move fast, impact-driven, social features
- **Netflix**: Resilience, microservices, chaos engineering
- **Uber**: Real-time systems, geolocation, high availability
- **LinkedIn**: Professional network, recommendations, data at scale
- **Startups**: Pragmatism, MVP mindset, wearing multiple hats

---

**FINAL PREPARATION CHECKLIST:**

✅ Practice 30 coding problems  
✅ Study 20 system design questions  
✅ Review company-specific questions  
✅ Prepare STAR stories for behavioral rounds  
✅ Mock interviews with peers  
✅ Review company blogs and tech talks  
✅ Prepare questions to ask interviewers  

---

**Good luck with your interviews! 🚀**

*Remember: Interviewers want to see your thought process, not just the final answer. Always think out loud, ask clarifying questions, and discuss trade-offs.*
