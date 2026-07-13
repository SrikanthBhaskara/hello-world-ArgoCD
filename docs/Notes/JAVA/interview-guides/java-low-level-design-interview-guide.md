# Java Low-Level Design Interview Guide

## Purpose

This file is a complete low-level design revision note for Java interviews.

Use it for:
- object modeling interview rounds
- machine design and class design discussion
- design pattern application in Java
- writing extensible code structure under interview pressure
- converting vague requirements into classes, interfaces, workflows, and responsibilities

This note includes:
- design process
- what interviewers evaluate
- LLD principles in interview language
- common question types
- detailed examples
- sample Java class skeletons
- questions and answer framing
- mistakes to avoid

## 1. What Low-Level Design Means in Interviews

Low-level design usually means designing the internal object model of a system.

The interviewer is not asking only for architecture boxes like API gateway, Kafka, or Redis.

They usually want to know whether you can:
- identify entities correctly
- separate responsibilities well
- model relationships clearly
- avoid God objects
- write extensible Java code
- apply patterns only where they help
- think about validation, state, concurrency, and future change

## 2. What Interviewers Usually Evaluate

### Technical quality
- class design clarity
- interface usage
- encapsulation
- abstraction level
- composition vs inheritance choice
- pattern selection
- code readability

### Design thinking
- whether you ask clarifying questions
- whether you identify assumptions early
- whether you model only what matters first
- whether you can extend the design safely

### Senior-level signals
- tradeoff awareness
- concurrency awareness where shared state exists
- validation and failure-state thinking
- maintainability and testing mindset
- language of ownership instead of textbook definitions

## 3. A Strong LLD Interview Flow

Use this order in interviews:

1. clarify requirements
2. separate core features from optional features
3. identify entities and value objects
4. define responsibilities per class
5. define interfaces for variable behavior
6. draw relationships and workflow
7. show one or two core methods
8. explain extension points
9. call out tradeoffs and edge cases

## 4. Clarifying Questions To Ask First

Before jumping into classes, ask:
- what are the core features versus nice-to-have features?
- is this single-user, multi-user, or concurrent?
- does data need persistence or is in-memory enough?
- do we care about thread safety?
- what is expected scale?
- do we need auditability, retries, or rollback behavior?
- what operations should be easy to extend later?

### Good interview line
"I want to clarify scope first so I do not over-design features that are outside the actual problem."

## 5. LLD Design Checklist

After you sketch the design, check:
- does each class have one main responsibility?
- are business rules inside the right object or service?
- are interfaces used only where behavior can vary?
- are domain objects separated from orchestration logic?
- can one future feature be added without changing too many classes?
- are invalid state transitions prevented?
- is shared mutable state handled safely?

## 6. Core Java Concepts That Matter Most

### Classes and objects
Use classes to model real entities and their behavior.

### Interfaces
Use interfaces where behavior can vary by implementation.

Examples:
- payment methods
- notification channels
- parking allocation strategy
- cache eviction policy

### Abstract classes
Use abstract classes when there is common state or behavior shared by related types.

### Enums
Use enums for controlled states.

Examples:
- `TicketStatus`
- `PaymentStatus`
- `SpotType`
- `VehicleType`

### Immutable value objects
Use immutable objects for things like IDs, money, time windows, coordinates, or request metadata when mutation is not needed.

### Composition over inheritance
Prefer composition when behavior should vary independently from the entity itself.

## 7. SOLID Principles in Interview Language

### Single Responsibility
Each class should have one reason to change.

Example:
`PaymentService` should not also allocate parking spots.

### Open/Closed
The design should allow new behavior with minimal changes to existing code.

Example:
Adding `PushNotificationChannel` should not require rewriting the whole notification service.

### Liskov Substitution
Subtypes should behave safely wherever the base type is expected.

Example:
If `Vehicle` is a base type, every subtype should behave consistently in allocation or validation flow.

### Interface Segregation
Do not force classes to implement methods they do not need.

Example:
Do not create one giant `NotificationChannel` interface with unrelated methods for every channel type.

### Dependency Inversion
High-level modules should depend on abstractions.

Example:
`NotificationService` should depend on `NotificationChannel`, not directly on `EmailChannel`.

## 8. Composition vs Inheritance

### Prefer composition when
- behavior can change independently
- you want pluggable strategies
- multiple combinations are possible
- inheritance tree would become rigid

### Use inheritance when
- there is a strong is-a relationship
- common behavior is truly stable
- subtype substitution is natural

### Good interview line
"I prefer composition here because the behavior varies more than the identity of the entity."

## 9. Patterns That Frequently Fit LLD Rounds

### Builder
Use when object creation has many optional fields.

### Factory
Use when creation depends on type or configuration.

### Strategy
Use when one algorithm or policy must be replaceable.

### Observer
Use when one action triggers multiple subscribers.

### State
Use when behavior depends on lifecycle state.

### Template Method
Use when the algorithm skeleton is fixed but steps vary.

### Singleton
Use carefully. Mention it only when shared controlled access is clearly needed.

## 10. Common LLD Questions and Best-Fit Patterns

| Question | Useful patterns or ideas |
| --- | --- |
| Parking lot | strategy, factory, enums, state |
| Notification system | strategy, factory, observer |
| Rate limiter | strategy, thread safety, immutable context |
| Cache | strategy, interface, generics, concurrency |
| Splitwise | domain modeling, validation, service orchestration |
| Elevator | state, scheduling policy, concurrency discussion |
| Movie booking | locking or seat reservation discussion, state transitions |
| Tic-tac-toe | board model, validation, simple state handling |

## 11. Example 1: Parking Lot Design

### Problem statement
Design a parking lot that supports different vehicle sizes and parking spot allocation.

### Clarifying assumptions
- multiple floors are supported
- vehicles can be bike, car, truck
- spot size matters
- one vehicle gets one ticket
- payment happens when exiting

### Core entities
- `ParkingLot`
- `ParkingFloor`
- `ParkingSpot`
- `Vehicle`
- `Ticket`
- `EntryGate`
- `ExitGate`
- `PaymentService`
- `ParkingStrategy`

### Good responsibility split
- `ParkingLot`: top-level orchestration
- `ParkingFloor`: manages floor-level spot inventory
- `ParkingSpot`: spot state and occupancy
- `ParkingStrategy`: decides which spot to assign
- `Ticket`: parking session record
- `PaymentService`: fee calculation and payment processing

### Java skeleton
```java
public enum VehicleType {
    BIKE, CAR, TRUCK
}

public enum SpotType {
    SMALL, MEDIUM, LARGE
}

public enum TicketStatus {
    ACTIVE, PAID, LOST
}

public abstract class Vehicle {
    private final String plateNumber;
    private final VehicleType vehicleType;

    protected Vehicle(String plateNumber, VehicleType vehicleType) {
        this.plateNumber = plateNumber;
        this.vehicleType = vehicleType;
    }

    public String getPlateNumber() {
        return plateNumber;
    }

    public VehicleType getVehicleType() {
        return vehicleType;
    }
}

public class ParkingSpot {
    private final String id;
    private final SpotType spotType;
    private Vehicle currentVehicle;

    public ParkingSpot(String id, SpotType spotType) {
        this.id = id;
        this.spotType = spotType;
    }

    public boolean isAvailable() {
        return currentVehicle == null;
    }

    public boolean canFit(Vehicle vehicle) {
        return switch (vehicle.getVehicleType()) {
            case BIKE -> true;
            case CAR -> spotType == SpotType.MEDIUM || spotType == SpotType.LARGE;
            case TRUCK -> spotType == SpotType.LARGE;
        };
    }

    public void assignVehicle(Vehicle vehicle) {
        this.currentVehicle = vehicle;
    }

    public void removeVehicle() {
        this.currentVehicle = null;
    }
}

public interface ParkingStrategy {
    ParkingSpot allocateSpot(List<ParkingFloor> floors, Vehicle vehicle);
}
```

### Interview explanation
Say that allocation policy is separated into a strategy because later the interviewer may ask for nearest-spot, cheapest-spot, or floor-priority behavior.

### Good answer line
"I separated allocation policy because spot selection logic changes more often than the parking spot model itself."

## 12. Example 2: Notification System Design

### Problem statement
Design a system that sends email, SMS, and push notifications.

### Clarifying assumptions
- one request may go to one or more channels
- message formatting may differ by channel
- retry behavior may differ by channel
- notification history may be tracked separately

### Core entities
- `NotificationRequest`
- `NotificationMessage`
- `NotificationChannel`
- `EmailChannel`
- `SmsChannel`
- `PushChannel`
- `TemplateService`
- `NotificationService`

### Java skeleton
```java
public record NotificationRequest(
        String userId,
        String templateId,
        Map<String, String> variables,
        Set<ChannelType> channels) {
}

public interface NotificationChannel {
    void send(NotificationMessage message);
}

public class EmailChannel implements NotificationChannel {
    @Override
    public void send(NotificationMessage message) {
        // integrate email provider
    }
}

public class NotificationService {
    private final Map<ChannelType, NotificationChannel> channels;
    private final TemplateService templateService;

    public NotificationService(Map<ChannelType, NotificationChannel> channels,
                               TemplateService templateService) {
        this.channels = channels;
        this.templateService = templateService;
    }

    public void notify(NotificationRequest request) {
        NotificationMessage message = templateService.render(request);
        for (ChannelType channelType : request.channels()) {
            channels.get(channelType).send(message);
        }
    }
}
```

### Interview explanation
Mention that formatting is separate from delivery so template rendering does not get mixed into delivery adapters.

### Extension ideas
- retry policy per channel
- audit log or delivery history
- async delivery queue
- user preference filtering

## 13. Example 3: Rate Limiter Design

### Problem statement
Design a rate limiter with interchangeable strategies.

### Clarifying assumptions
- start with in-memory design
- support user-based limiting
- allow future support for distributed storage
- strategy may be fixed window, sliding window, or token bucket

### Core entities
- `RateLimiter`
- `LimitPolicy`
- `FixedWindowPolicy`
- `SlidingWindowPolicy`
- `RequestContext`
- `RateLimitResult`

### Java skeleton
```java
public record RequestContext(String clientId, long timestampMillis) {
}

public record RateLimitResult(boolean allowed, long retryAfterMillis) {
}

public interface LimitPolicy {
    RateLimitResult allow(RequestContext context);
}

public class FixedWindowPolicy implements LimitPolicy {
    private final int limit;
    private final long windowMillis;
    private final ConcurrentHashMap<String, AtomicInteger> counters = new ConcurrentHashMap<>();

    public FixedWindowPolicy(int limit, long windowMillis) {
        this.limit = limit;
        this.windowMillis = windowMillis;
    }

    @Override
    public RateLimitResult allow(RequestContext context) {
        AtomicInteger counter = counters.computeIfAbsent(context.clientId(), id -> new AtomicInteger());
        int current = counter.incrementAndGet();
        return new RateLimitResult(current <= limit, 0L);
    }
}
```

### Interview explanation
Call out that a real distributed limiter likely needs Redis or another shared store, and exact behavior under concurrency becomes an important tradeoff.

## 14. Example 4: Cache With Pluggable Eviction

### Problem statement
Design a cache that supports configurable eviction policy.

### Core entities
- `Cache<K, V>`
- `EvictionPolicy<K>`
- `LruEvictionPolicy<K>`
- `CacheEntry<V>`

### Java skeleton
```java
public interface Cache<K, V> {
    V get(K key);
    void put(K key, V value);
}

public interface EvictionPolicy<K> {
    void onAccess(K key);
    void onInsert(K key);
    K evictKey();
}
```

### Good interview line
"The cache contract and the eviction policy should change independently, so I keep them separate."

## 15. How To Talk Through a Workflow

When describing a flow, keep it simple.

### Example: Parking lot entry flow
1. vehicle arrives at entry gate
2. allocation strategy selects a valid spot
3. ticket is created with active status
4. spot is marked occupied
5. ticket is returned to the user

### Example: Notification flow
1. request comes in with user, template, and channels
2. template service renders message
3. channel-specific sender delivers message
4. optional audit log records delivery status

## 16. Common LLD Follow-Up Questions

Interviewers often ask:
- how would you extend this for another type?
- what if multiple threads access this?
- what if data must persist?
- what if one sub-flow fails?
- how would you test this design?
- what if requirements double later?

### Good answer pattern
- start with the current design
- state what extension point already exists
- mention what you would add with minimal impact

## 17. LLD Questions and Better Answers

### Question
How do you decide whether to introduce an interface?

### Better answer
I introduce an interface when behavior is expected to vary independently of the caller. If only one implementation exists and variation is unlikely, I avoid adding interfaces too early because it adds abstraction without value.

### Question
How do you decide between inheritance and composition?

### Better answer
I use inheritance only when the subtype truly is a stable specialization of the parent. If the behavior varies independently or multiple combinations may appear later, composition is safer and more maintainable.

### Question
How do you avoid a God class?

### Better answer
I separate domain state, business rules, orchestration, and infrastructure concerns. If one class starts handling validation, persistence, external integration, and business flow together, that is a strong sign responsibilities need to be split.

### Question
When do you talk about thread safety in LLD?

### Better answer
I bring it up whenever mutable shared state exists, such as caches, rate limiters, schedulers, reservation maps, or in-memory counters. I do not force concurrency into every design, but I call it out explicitly when it can change correctness.

## 18. What To Write on the Whiteboard or Editor

A good LLD answer often includes:
- 5 to 8 core classes
- 1 to 3 interfaces
- important enums
- one main service or orchestrator
- one main workflow
- one extension point

Do not try to write the entire production codebase in the interview.

## 19. Mistakes That Hurt LLD Answers

- starting with patterns before understanding the domain
- introducing interfaces for everything
- mixing DTO, entity, service, and repository concerns
- making one service class do all logic
- forgetting states and validation
- forgetting concurrency when in-memory shared state exists
- writing definitions without showing one workflow

## 20. Strong Senior-Level Phrases

- "I want to separate domain model, orchestration, and policy logic."
- "This interface gives us room to add new behavior without changing the caller."
- "I would optimize for clarity of responsibility first, then extensibility."
- "If this component is shared across threads, I would call out immutable state or synchronization explicitly."
- "I am keeping the first version simple, but I am leaving one clear extension point for likely future changes."

## 21. Practice Questions

Practice answering these aloud:
1. design a parking lot
2. design a notification system
3. design a cache
4. design a rate limiter
5. design a movie ticket booking system
6. design Splitwise expense flow
7. design an elevator scheduler
8. design a library management system

## 22. Reference Thinking

Use these related notes for deeper prep:
- [Java design patterns interview guide](./java-design-patterns-interview-guide.md)
- [Java microservices architecture interview guide](./java-microservices-architecture-interview-guide.md)
- [Java concurrency coding interview patterns](./java-concurrency-coding-interview-patterns.md)
- [Java senior architecture and tradeoffs guide](./java-senior-architecture-and-tradeoffs-guide.md)

## 23. Final Revision Advice

A weak LLD answer lists classes.

A strong LLD answer:
- asks scope questions
- gives clean responsibilities
- shows one workflow
- uses patterns only where useful
- explains extension and tradeoffs
- mentions failure or concurrency concerns when relevant

That is the difference between sounding like someone who memorized patterns and someone who can actually design maintainable systems.
