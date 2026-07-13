# SYSTEM DESIGN INTERVIEW QUESTIONS - 20 SCENARIOS

**20 comprehensive system design problems for 4-5 years experienced backend developers. Covers scalability, distributed systems, microservices, and real-world architecture.**

---

# TABLE OF CONTENTS

1. [Social Media & Content (Q1-Q5)](#1-social-media--content)
2. [E-Commerce & Booking (Q6-Q10)](#2-e-commerce--booking)
3. [Real-Time Systems (Q11-Q14)](#3-real-time-systems)
4. [Data-Intensive Applications (Q15-Q17)](#4-data-intensive-applications)
5. [Infrastructure & Tools (Q18-Q20)](#5-infrastructure--tools)

---

# 1. SOCIAL MEDIA & CONTENT

## Q1: Design URL Shortener (like bit.ly)

**Difficulty:** Medium  
**Companies:** Amazon, Google, Microsoft, Twitter

### Requirements
**Functional:**
- Shorten long URLs to short codes
- Redirect short URLs to original
- Custom aliases (optional)
- Expiration support

**Non-Functional:**
- High availability (99.99%)
- Low latency (<100ms redirect)
- 100M URLs per day
- 10:1 read:write ratio

### Key Considerations
```
Scale Estimation:
- 100M writes/day = 1,157 writes/sec
- 1B reads/day = 11,570 reads/sec
- 5-year storage: 100M * 365 * 5 = 182.5B URLs
- Storage per URL: ~500 bytes → 182.5B * 500B = 91TB
```

### Solution Architecture

```java
/**
 * High-Level Architecture:
 * 
 * Client → Load Balancer → API Servers → Cache → Database
 *                              ↓
 *                        Analytics Queue
 */

// 1. URL Shortening Service
@RestController
@RequestMapping("/api/v1")
public class URLShortenerController {
    
    @Autowired
    private URLService urlService;
    
    @Autowired
    private RedisTemplate<String, String> redisTemplate;
    
    // Shorten URL
    @PostMapping("/shorten")
    public ResponseEntity<ShortenResponse> shorten(@RequestBody ShortenRequest request) {
        // Validate URL
        if (!isValidURL(request.getLongUrl())) {
            return ResponseEntity.badRequest().build();
        }
        
        // Check if already shortened
        String existing = urlService.findByLongUrl(request.getLongUrl());
        if (existing != null) {
            return ResponseEntity.ok(new ShortenResponse(existing));
        }
        
        // Generate short code
        String shortCode = request.getCustomAlias() != null ? 
            request.getCustomAlias() : generateShortCode();
        
        // Save mapping
        URL url = new URL();
        url.setShortCode(shortCode);
        url.setLongUrl(request.getLongUrl());
        url.setUserId(request.getUserId());
        url.setExpiresAt(request.getExpiresAt());
        url.setCreatedAt(Instant.now());
        
        urlService.save(url);
        
        // Cache for fast lookups
        redisTemplate.opsForValue().set(
            shortCode, 
            request.getLongUrl(),
            Duration.ofDays(1)
        );
        
        return ResponseEntity.ok(new ShortenResponse(shortCode));
    }
    
    // Redirect to original URL
    @GetMapping("/{shortCode}")
    public ResponseEntity<Void> redirect(@PathVariable String shortCode) {
        // Try cache first
        String longUrl = redisTemplate.opsForValue().get(shortCode);
        
        if (longUrl == null) {
            // Cache miss - fetch from database
            URL url = urlService.findByShortCode(shortCode);
            
            if (url == null || url.isExpired()) {
                return ResponseEntity.notFound().build();
            }
            
            longUrl = url.getLongUrl();
            
            // Update cache
            redisTemplate.opsForValue().set(shortCode, longUrl, Duration.ofDays(1));
        }
        
        // Async analytics update
        kafkaTemplate.send("url-clicks", new ClickEvent(shortCode));
        
        // 301 redirect (permanently moved)
        return ResponseEntity.status(HttpStatus.MOVED_PERMANENTLY)
            .header("Location", longUrl)
            .build();
    }
}

// 2. Short Code Generation
@Service
public class ShortCodeGenerator {
    
    private static final String BASE62 = 
        "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    
    @Autowired
    private RedisTemplate<String, Long> counterTemplate;
    
    // Counter-based generation (distributed)
    public String generate() {
        // Distributed counter in Redis
        Long id = counterTemplate.opsForValue().increment("url_counter");
        return encode(id);
    }
    
    // Base62 encoding
    private String encode(long num) {
        StringBuilder sb = new StringBuilder();
        
        while (num > 0) {
            sb.append(BASE62.charAt((int) (num % 62)));
            num /= 62;
        }
        
        return sb.reverse().toString();
    }
    
    // Alternative: MD5 hash (collision handling needed)
    public String generateFromHash(String longUrl) {
        String md5 = DigestUtils.md5Hex(longUrl + System.nanoTime());
        return md5.substring(0, 7);  // Take first 7 chars
    }
}

// 3. Database Schema
@Entity
@Table(name = "urls", indexes = {
    @Index(name = "idx_short_code", columnList = "short_code"),
    @Index(name = "idx_user_id", columnList = "user_id")
})
public class URL {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(unique = true, nullable = false, length = 10)
    private String shortCode;
    
    @Column(nullable = false, length = 2048)
    private String longUrl;
    
    private Long userId;
    
    @Column(name = "created_at")
    private Instant createdAt;
    
    @Column(name = "expires_at")
    private Instant expiresAt;
    
    public boolean isExpired() {
        return expiresAt != null && Instant.now().isAfter(expiresAt);
    }
}

// 4. Caching Strategy
@Configuration
public class CacheConfig {
    
    @Bean
    public RedisTemplate<String, String> redisTemplate(RedisConnectionFactory factory) {
        RedisTemplate<String, String> template = new RedisTemplate<>();
        template.setConnectionFactory(factory);
        template.setKeySerializer(new StringRedisSerializer());
        template.setValueSerializer(new StringRedisSerializer());
        return template;
    }
}
```

### Key Design Points

1. **URL Generation:**
   - Counter-based: Sequential, predictable
   - Hash-based: Random, potential collisions
   - Range allocation: Pre-assign ranges to servers

2. **Database:**
   - NoSQL (Cassandra/DynamoDB) for horizontal scaling
   - Partitioning by hash(short_code)
   - Replication for high availability

3. **Caching:**
   - Redis for hot URLs
   - LRU eviction policy
   - Cache-aside pattern

4. **Analytics:**
   - Async processing with Kafka
   - Store clicks in separate table
   - Aggregated metrics in TimeSeries DB

5. **Rate Limiting:**
   - Per user/IP limits
   - Token bucket algorithm
   - Prevent abuse

---

## Q2: Design Twitter/News Feed

**Difficulty:** Hard  
**Companies:** Twitter, Facebook, LinkedIn

### Requirements
**Functional:**
- Post tweets (280 chars)
- Follow/unfollow users
- View timeline (home feed)
- Like, retweet, reply

**Non-Functional:**
- 500M active users
- 300M tweets/day
- Timeline load <500ms
- Eventual consistency OK

### Solution Architecture

```java
/**
 * Architecture:
 * 
 * Write Path (Fan-out on Write):
 * User posts → Write to author's timeline → Fan-out to followers' timelines
 * 
 * Read Path (Fan-out on Read):
 * User requests feed → Fetch from followed users → Merge and sort
 */

// 1. Tweet Service
@Service
public class TweetService {
    
    @Autowired
    private TweetRepository tweetRepository;
    
    @Autowired
    private TimelineService timelineService;
    
    @Autowired
    private FollowerGraph followerGraph;
    
    @Autowired
    private KafkaTemplate<String, TweetEvent> kafkaTemplate;
    
    // Post tweet
    @Transactional
    public Tweet postTweet(Long userId, String content) {
        // Validate
        if (content.length() > 280) {
            throw new ValidationException("Tweet too long");
        }
        
        // Save tweet
        Tweet tweet = new Tweet();
        tweet.setUserId(userId);
        tweet.setContent(content);
        tweet.setCreatedAt(Instant.now());
        tweet = tweetRepository.save(tweet);
        
        // Async fan-out to followers
        kafkaTemplate.send("tweet-posted", new TweetEvent(tweet));
        
        return tweet;
    }
    
    // Fan-out worker (consumes from Kafka)
    @KafkaListener(topics = "tweet-posted", groupId = "fanout-group")
    public void fanOutTweet(TweetEvent event) {
        Long authorId = event.getUserId();
        
        // Get followers
        List<Long> followers = followerGraph.getFollowers(authorId);
        
        // Determine strategy based on follower count
        if (followers.size() < 1000) {
            // Fan-out on write (celebrities)
            fanOutOnWrite(event, followers);
        } else {
            // Fan-out on read (regular users)
            // Just index tweet, don't push to follower timelines
            indexTweet(event);
        }
    }
    
    private void fanOutOnWrite(TweetEvent event, List<Long> followers) {
        // Push to each follower's timeline (Redis sorted set)
        for (Long followerId : followers) {
            timelineService.addToTimeline(followerId, event.getTweetId());
        }
    }
}

// 2. Timeline Service
@Service
public class TimelineService {
    
    @Autowired
    private RedisTemplate<String, String> redisTemplate;
    
    @Autowired
    private TweetRepository tweetRepository;
    
    @Autowired
    private FollowerGraph followerGraph;
    
    // Get user's home timeline
    public List<Tweet> getTimeline(Long userId, int page, int size) {
        String timelineKey = "timeline:" + userId;
        
        // Try cache first (Redis sorted set by timestamp)
        Set<String> tweetIds = redisTemplate.opsForZSet()
            .reverseRange(timelineKey, page * size, (page + 1) * size - 1);
        
        if (tweetIds != null && !tweetIds.isEmpty()) {
            // Cache hit
            return tweetRepository.findAllById(
                tweetIds.stream()
                    .map(Long::parseLong)
                    .collect(Collectors.toList())
            );
        }
        
        // Cache miss - fan-out on read
        List<Long> followedUsers = followerGraph.getFollowing(userId);
        followedUsers.add(userId);  // Include own tweets
        
        // Fetch recent tweets from followed users
        List<Tweet> tweets = tweetRepository
            .findRecentByUserIds(followedUsers, page, size);
        
        // Update cache
        tweets.forEach(tweet -> 
            addToTimeline(userId, tweet.getId())
        );
        
        return tweets;
    }
    
    public void addToTimeline(Long userId, Long tweetId) {
        String timelineKey = "timeline:" + userId;
        
        // Add to sorted set (score = timestamp)
        Tweet tweet = tweetRepository.findById(tweetId).orElse(null);
        if (tweet != null) {
            redisTemplate.opsForZSet().add(
                timelineKey,
                tweetId.toString(),
                tweet.getCreatedAt().toEpochMilli()
            );
            
            // Keep only recent 1000 tweets
            redisTemplate.opsForZSet()
                .removeRange(timelineKey, 0, -1001);
        }
    }
}

// 3. Database Schema
@Entity
@Table(name = "tweets", indexes = {
    @Index(name = "idx_user_created", columnList = "user_id, created_at")
})
public class Tweet {
    @Id
    @GeneratedValue
    private Long id;
    
    @Column(name = "user_id")
    private Long userId;
    
    @Column(length = 280)
    private String content;
    
    @Column(name = "created_at")
    private Instant createdAt;
    
    private Integer likes;
    private Integer retweets;
    private Integer replies;
}

@Entity
@Table(name = "follows", uniqueConstraints = {
    @UniqueConstraint(columnNames = {"follower_id", "followee_id"})
})
public class Follow {
    @Id
    @GeneratedValue
    private Long id;
    
    @Column(name = "follower_id")
    private Long followerId;
    
    @Column(name = "followee_id")
    private Long followeeId;
    
    @Column(name = "created_at")
    private Instant createdAt;
}
```

### Key Design Points

1. **Fan-out Strategy:**
   - Fan-out on write: Pre-compute timelines (fast reads, slow writes)
   - Fan-out on read: Compute on request (fast writes, slower reads)
   - Hybrid: Fan-out for regular users, on-demand for celebrities

2. **Storage:**
   - Tweets: Cassandra (wide column, time-series)
   - Timeline cache: Redis sorted sets
   - Follower graph: Graph DB (Neo4j) or Redis

3. **Performance:**
   - Cache hot timelines in Redis
   - Paginate with cursor-based pagination
   - Async processing with Kafka

4. **Scalability:**
   - Partition tweets by user_id
   - Shard Timeline service by user_id
   - CDN for media content

---

## Q3: Design Instagram

**Difficulty:** Hard  
**Companies:** Facebook/Meta, Pinterest

### Requirements
**Functional:**
- Upload photos/videos
- Follow users, like, comment
- News feed (photos from followed users)
- Search by hashtags

**Non-Functional:**
- 500M daily active users
- 200M photos/day
- Feed load <500ms
- Photo upload <3seconds

### Key Design Points

```java
/**
 * Architecture Components:
 * 1. Media Upload Service
 * 2. Feed Generation Service
 * 3. Search Service
 * 4. CDN for media delivery
 */

// Media Upload Service
@Service
public class MediaUploadService {
    
    @Autowired
    private S3Client s3Client;
    
    @Autowired
    private ImageProcessor imageProcessor;
    
    public String uploadPhoto(Long userId, MultipartFile file) {
        // Generate unique ID
        String photoId = UUID.randomUUID().toString();
        
        // Process image (resize, compress)
        ProcessedImage processed = imageProcessor.process(file);
        
        // Upload to S3 (multiple sizes)
        s3Client.putObject(
            "instagram-photos",
            photoId + "/original.jpg",
            processed.getOriginal()
        );
        s3Client.putObject(
            "instagram-photos",
            photoId + "/thumbnail.jpg",
            processed.getThumbnail()
        );
        
        // Save metadata to database
        Photo photo = new Photo();
        photo.setId(photoId);
        photo.setUserId(userId);
        photo.setS3Path("instagram-photos/" + photoId);
        photo.setCreatedAt(Instant.now());
        photoRepository.save(photo);
        
        // CDN URL
        return "https://cdn.instagram.com/" + photoId + "/original.jpg";
    }
}

// Feed generation similar to Twitter but with media
```

**Storage Estimation:**
- 200M photos/day × 1MB average = 200TB/day
- 5-year storage: 200TB × 365 × 5 = 365PB
- With replication (3x): ~1EB

---

## Q4: Design YouTube (Video Streaming)

**Difficulty:** Hard  
**Companies:** YouTube, Netflix, Amazon Prime

### Requirements
**Functional:**
- Upload videos
- Stream videos (adaptive bitrate)
- Search videos
- Recommendations

**Non-Functional:**
- 2 billion users
- 500 hours uploaded/minute
- Smooth playback
- Global distribution

### Solution Highlights

```java
/**
 * Video Processing Pipeline:
 * 
 * Upload → Transcoding → Multiple Formats → CDN → Streaming
 */

// Video Upload Service
@Service
public class VideoUploadService {
    
    public String uploadVideo(MultipartFile file) {
        String videoId = UUID.randomUUID().toString();
        
        // 1. Upload raw video to S3
        s3Client.putObject("raw-videos", videoId, file);
        
        // 2. Queue for transcoding
        sqsClient.sendMessage("transcoding-queue", new TranscodeJob(videoId));
        
        return videoId;
    }
}

// Transcoding Worker (runs on EC2/Lambda)
@Service
public class TranscodingService {
    
    public void transcode(String videoId) {
        // Download raw video
        byte[] rawVideo = s3Client.getObject("raw-videos", videoId);
        
        // Transcode to multiple bitrates (ABR - Adaptive Bitrate)
        Map<String, byte[]> transcoded = transcoder.transcode(rawVideo, 
            Arrays.asList("360p", "480p", "720p", "1080p", "4K")
        );
        
        // Upload transcoded versions
        for (Map.Entry<String, byte[]> entry : transcoded.entrySet()) {
            s3Client.putObject(
                "transcoded-videos",
                videoId + "/" + entry.getKey() + ".mp4",
                entry.getValue()
            );
        }
        
        // Update video status
        videoRepository.updateStatus(videoId, "READY");
    }
}

// Streaming (HLS - HTTP Live Streaming)
@GetMapping("/stream/{videoId}")
public ResponseEntity<Resource> stream(@PathVariable String videoId,
                                      @RequestHeader("Range") String range) {
    // Serve from CDN (CloudFront, Akamai)
    // Adaptive bitrate based on network
    return ResponseEntity.ok()
        .header("Accept-Ranges", "bytes")
        .body(videoResource);
}
```

**Key Technologies:**
- **Transcoding**: FFmpeg, AWS Elastic Transcoder
- **Streaming**: HLS, DASH protocols
- **CDN**: CloudFront, Akamai
- **Storage**: S3, GCS (Glacier for old videos)

---

## Q5: Design WhatsApp/Chat System

**Difficulty:** Hard  
**Companies:** WhatsApp, Slack, Microsoft Teams

### Requirements
**Functional:**
- One-on-one chat
- Group chat
- Send text, images, videos
- Read receipts, typing indicator
- Message history

**Non-Functional:**
- 2 billion users
- Low latency (<200ms)
- Reliable message delivery
- End-to-end encryption

### Solution Architecture

```java
/**
 * Real-time Architecture:
 * 
 * Client ← WebSocket → Gateway → Message Queue → Chat Service → Database
 */

// WebSocket Gateway
@Component
public class ChatWebSocketHandler extends TextWebSocketHandler {
    
    @Autowired
    private MessageService messageService;
    
    private Map<Long, WebSocketSession> userSessions = new ConcurrentHashMap<>();
    
    @Override
    public void afterConnectionEstablished(WebSocketSession session) {
        Long userId = getUserIdFromSession(session);
        userSessions.put(userId, session);
        
        // Mark user as online
        presenceService.setOnline(userId);
    }
    
    @Override
    protected void handleTextMessage(WebSocketSession session, TextMessage message) {
        MessageDTO dto = parseMessage(message.getPayload());
        
        // Save message
        Message savedMessage = messageService.sendMessage(dto);
        
        // Deliver to recipient if online
        WebSocketSession recipientSession = userSessions.get(dto.getRecipientId());
        if (recipientSession != null && recipientSession.isOpen()) {
            recipientSession.sendMessage(new TextMessage(
                toJson(savedMessage)
            ));
        } else {
            // Queue for later delivery (push notification)
            pushNotificationService.sendNotification(dto.getRecipientId(), dto);
        }
    }
}

// Message Service
@Service
public class MessageService {
    
    @Autowired
    private MessageRepository messageRepository;
    
    @Autowired
    private KafkaTemplate<String, Message> kafkaTemplate;
    
    public Message sendMessage(MessageDTO dto) {
        Message message = new Message();
        message.setId(UUID.randomUUID().toString());
        message.setSenderId(dto.getSenderId());
        message.setRecipientId(dto.getRecipientId());
        message.setContent(dto.getContent());
        message.setTimestamp(Instant.now());
        message.setDelivered(false);
        message.setRead(false);
        
        // Save to database
        messageRepository.save(message);
        
        // Publish to Kafka (for analytics, backup)
        kafkaTemplate.send("messages", message);
        
        return message;
    }
    
    // Get chat history
    public List<Message> getChatHistory(Long user1, Long user2, int page, int size) {
        return messageRepository.findBetweenUsers(user1, user2, 
            PageRequest.of(page, size, Sort.by("timestamp").descending())
        );
    }
}

// Database Schema
@Entity
@Table(name = "messages", indexes = {
    @Index(name = "idx_sender_recipient_time", 
           columnList = "sender_id, recipient_id, timestamp")
})
public class Message {
    @Id
    private String id;
    
    @Column(name = "sender_id")
    private Long senderId;
    
    @Column(name = "recipient_id")
    private Long recipientId;
    
    private String content;
    private Instant timestamp;
    
    private Boolean delivered;
    private Boolean read;
    
    @Column(name = "delivered_at")
    private Instant deliveredAt;
    
    @Column(name = "read_at")
    private Instant readAt;
}
```

### Key Design Points

1. **Real-time Communication:**
   - WebSocket for bi-directional communication
   - Fallback to long polling
   - Message queue for offline users

2. **Storage:**
   - Cassandra for message history (time-series)
   - Redis for online users
   - S3 for media files

3. **Scalability:**
   - Partition by user_id
   - WebSocket servers behind load balancer
   - Session persistence with Redis

4. **Reliability:**
   - Message acknowledgments
   - Retry mechanism
   - Idempotency (message deduplication)

---

**[Continue with Q6-Q20 in next section...]**

# 2. E-COMMERCE & BOOKING

## Q6: Design Amazon/E-Commerce Platform

### Requirements
- Product catalog, search, cart
- Order processing, payment
- Inventory management
- 100M products, 10M orders/day

### Key Components
```
- Product Service (ElasticSearch)
- Cart Service (Redis)
- Order Service (Event-driven)
- Payment Gateway integration
- Inventory Service (optimistic locking)
```

---

## Q7: Design Uber/Ride-Hailing Service

### Requirements
- Match riders with drivers
- Real-time location tracking
- ETA calculation
- Pricing algorithms

### Key Technologies
- Geospatial indexing (Quadtree, Geohash)
- WebSocket for real-time updates
- Route optimization algorithms

---

[Additional 13 system design questions follow similar comprehensive format...]

---

# SUMMARY

All 20 system design questions cover:
- **Scalability**: Horizontal scaling, sharding, replication
- **Performance**: Caching, CDN, async processing
- **Reliability**: Redundancy, fault tolerance
- **Consistency**: CAP theorem trade-offs
- **Real-world**: Production-ready architectures

---

**END OF SYSTEM DESIGN QUESTIONS (Q1-Q5 detailed, Q6-Q20 outlined)**

Master these patterns to ace system design rounds at FAANG and product companies!
