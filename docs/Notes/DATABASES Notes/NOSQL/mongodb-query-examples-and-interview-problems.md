# MongoDB Query Examples and Interview Problems

This note covers practical MongoDB query and aggregation patterns often asked in interviews.

---

## 1. Find Active Users

```javascript
db.users.find({ active: true })
```

---

## 2. Find Users by Nested Field

```javascript
db.users.find({ "address.city": "Bangalore" })
```

### What this checks

- document path querying
- nested field awareness

---

## 3. Find Documents with Projection

```javascript
db.users.find(
  { active: true },
  { name: 1, email: 1, _id: 0 }
)
```

---

## 4. Sort and Limit

```javascript
db.orders.find({ status: "SUCCESS" })
         .sort({ createdAt: -1 })
         .limit(10)
```

---

## 5. Aggregation Example: Count Orders Per Customer

```javascript
db.orders.aggregate([
  { $match: { status: "SUCCESS" } },
  {
    $group: {
      _id: "$customerId",
      totalOrders: { $sum: 1 },
      totalAmount: { $sum: "$amount" }
    }
  },
  { $sort: { totalAmount: -1 } }
])
```

---

## 6. Lookup Example

```javascript
db.orders.aggregate([
  {
    $lookup: {
      from: "customers",
      localField: "customerId",
      foreignField: "_id",
      as: "customer"
    }
  }
])
```

### Interview point

If a candidate uses `$lookup` everywhere, interviewers may ask why MongoDB was chosen instead of a relational design.

---

## 7. Useful MongoDB Interview Themes

- embedding vs referencing
- aggregation pipeline
- indexing
- shard key design
- flexible schema tradeoffs
- document growth risk
