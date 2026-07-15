# MongoDB Deep Notes

MongoDB is a document database well suited to document-oriented access patterns and flexible schema use cases.

---

## 1. When MongoDB Fits Well

MongoDB is strong when:

- data is naturally document-oriented
- nested objects fit the access pattern
- schema evolves quickly
- denormalized reads are acceptable

---

## 2. Document Model

MongoDB stores data as BSON-like documents.

This is useful for:

- nested structures
- object-style payloads
- flexible attributes

### Interview tradeoff

Flexible schema helps fast iteration, but it can reduce consistency unless the application validates document structure carefully.

---

## 3. Embedding vs Referencing

### Embedding

- good when related data is usually read together
- reduces join-like lookups

### Referencing

- useful when related data is large or reused separately
- avoids oversized documents

### Strong answer

This choice should follow read and update patterns, not only data modeling preference.

---

## 4. Indexing in MongoDB

Common index topics:

- single-field indexes
- compound indexes
- multikey indexes
- text indexes
- TTL indexes

### Important point

MongoDB indexes improve query speed, but they also slow writes and add storage cost, just like relational systems.

---

## 5. Aggregation Pipeline

MongoDB aggregation is commonly used for:

- filtering
- grouping
- reshaping documents
- analytics-like processing

Interviewers may ask about stages like:

- `$match`
- `$group`
- `$project`
- `$sort`
- `$lookup`

---

## 6. Replication and Sharding

### Replication

- improves availability
- uses replica sets

### Sharding

- distributes data across shards
- depends heavily on shard key design

### Strong answer

Bad shard keys create hot shards and uneven scaling, so access-pattern-driven design is critical.

---

## 7. Production Risks

Common risks:

- large documents
- poor index design
- too much flexible schema drift
- weak shard key choice
- unexpected memory or working set pressure

---

## 8. When Not to Choose MongoDB

Avoid defaulting to MongoDB when:

- strict relational integrity matters
- complex joins are central
- transactional multi-entity consistency is the main requirement
