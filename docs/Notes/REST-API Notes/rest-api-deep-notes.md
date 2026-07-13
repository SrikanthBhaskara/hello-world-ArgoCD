# REST API Deep Notes

These notes are meant for deep learning, revision, and interview preparation. They cover fundamentals, design rules, common mistakes, and real request and response examples.

## 1. What is a REST API?

REST stands for Representational State Transfer. A REST API is an HTTP-based way for systems to communicate using resources, standard methods, and stateless requests.

Example idea:
- `users`
- `orders`
- `products`

In REST, we usually act on resources through URLs:

```http
GET /users/123
POST /orders
PUT /users/123
DELETE /orders/789
```

## 2. Core REST Constraints

### Client-server

The client sends requests and the server processes them. Their responsibilities stay separate.

### Stateless

Each request should contain all the information the server needs to process it. The server should not depend on conversational session state from earlier requests.

Good example:

```http
GET /users/123
Authorization: Bearer <token>
```

Bad design:
- Request 2 only works because request 1 stored temporary state in server memory.

### Cacheable

Responses can be marked cacheable to improve performance and reduce repeated work.

### Uniform interface

The API should use consistent resource naming, standard HTTP methods, and predictable response structures.

## 3. REST vs HTTP

HTTP is the protocol.
REST is an architectural style that commonly uses HTTP.

Important point:
- Not every HTTP API is truly RESTful.
- An API can use HTTP but still ignore REST ideas like proper resource naming, statelessness, and method semantics.

## 4. Resource-Oriented Design

REST APIs should be designed around nouns, not actions.

Good:

```http
GET /users
GET /users/123
POST /users
DELETE /users/123
```

Less RESTful:

```http
GET /getUsers
POST /createUser
POST /deleteUser
```

Why nouns are better:
- cleaner URL design
- easier consistency
- HTTP methods already express the action

## 5. HTTP Methods and Their Meaning

### GET

Used to fetch data.

Example:

```http
GET /products/101
```

Properties:
- safe
- should not modify data
- idempotent

### POST

Used to create a new resource or trigger processing.

Example:

```http
POST /orders
Content-Type: application/json

{
  "customerId": 123,
  "items": [
    { "productId": 101, "quantity": 2 }
  ]
}
```

Properties:
- not idempotent in normal create use

### PUT

Used to replace an existing resource completely, or create it at a known URL in some designs.

Example:

```http
PUT /users/123
Content-Type: application/json

{
  "id": 123,
  "name": "Ravi",
  "email": "ravi@example.com"
}
```

Properties:
- idempotent

### PATCH

Used to partially update a resource.

Example:

```http
PATCH /users/123
Content-Type: application/json

{
  "email": "ravi.new@example.com"
}
```

Properties:
- often not guaranteed idempotent by semantics, though many PATCH operations are implemented idempotently

### DELETE

Used to remove a resource.

Example:

```http
DELETE /users/123
```

Properties:
- idempotent

## 6. Safe vs Idempotent

### Safe

A safe operation should not change server-side state.

Example:
- `GET /users/123`

### Idempotent

If the same request is sent multiple times, the final result should be the same as sending it once.

Examples:
- `GET /users/123`
- `PUT /users/123`
- `DELETE /users/123`

Not usually idempotent:
- `POST /orders`

Interview explanation:
- Safe is about no state change.
- Idempotent is about repeated execution reaching the same final state.

## 7. Common HTTP Status Codes

### 2xx success

- `200 OK`: successful request with response body
- `201 Created`: resource created successfully
- `202 Accepted`: request accepted for asynchronous processing
- `204 No Content`: successful request with no response body

### 4xx client-side errors

- `400 Bad Request`: invalid request input
- `401 Unauthorized`: authentication missing or invalid
- `403 Forbidden`: authenticated but not allowed
- `404 Not Found`: resource does not exist
- `405 Method Not Allowed`: wrong HTTP method for endpoint
- `409 Conflict`: state conflict, such as duplicate or version conflict
- `415 Unsupported Media Type`: wrong content type
- `422 Unprocessable Entity`: validation passed format but business rules failed
- `429 Too Many Requests`: rate limit exceeded

### 5xx server-side errors

- `500 Internal Server Error`: unexpected server failure
- `502 Bad Gateway`: upstream dependency returned bad response
- `503 Service Unavailable`: service temporarily unavailable
- `504 Gateway Timeout`: upstream dependency timed out

## 8. URI Design Best Practices

Use plural resource names:

```http
/users
/orders
/payments
```

Use hierarchical relationships when useful:

```http
/users/123/orders
/orders/789/items
```

Avoid verbs in URLs:

```http
/users/activate
```

Prefer:

```http
POST /users/123/activation
```

or

```http
PATCH /users/123
```

depending on the use case.

## 9. Query Parameters

Use query parameters for filtering, sorting, searching, or pagination.

Examples:

```http
GET /users?page=1&size=20
GET /users?status=ACTIVE
GET /orders?sort=createdAt,desc
GET /products?name=phone
```

Good use cases:
- filter result sets
- sorting
- paging
- search

Not good:
- using query parameters to represent core resource identity when path variables are more natural

## 10. Request Headers

Common headers:
- `Authorization`
- `Content-Type`
- `Accept`
- `If-None-Match`
- `If-Match`
- `X-Correlation-Id`

Example:

```http
GET /users/123
Authorization: Bearer <token>
Accept: application/json
X-Correlation-Id: 2fe12417-1458-4d7a-a67a-6f7700c0a928
```

## 11. Request Body vs Path Variable vs Query Parameter

### Path variable

Used to identify a specific resource.

Example:

```http
GET /users/123
```

### Query parameter

Used for filtering or optional modifiers.

Example:

```http
GET /users?status=ACTIVE&page=2
```

### Request body

Used for create or update payloads.

Example:

```http
POST /users
Content-Type: application/json

{
  "name": "Ravi",
  "email": "ravi@example.com"
}
```

## 12. JSON Design Best Practices

Good JSON should be:
- consistent
- readable
- predictable
- not overloaded with unrelated data

Example response:

```json
{
  "id": 123,
  "name": "Ravi",
  "email": "ravi@example.com",
  "status": "ACTIVE"
}
```

Common advice:
- use stable field names
- avoid returning unnecessary internal fields
- keep date formats consistent
- use clear enum-style string values when suitable

## 13. Validation in REST APIs

Validation exists at multiple layers:
- syntax validation
- required field validation
- business validation
- security validation

Example invalid request:

```http
POST /users
Content-Type: application/json

{
  "name": "",
  "email": "wrong-format"
}
```

Possible response:

```http
400 Bad Request
Content-Type: application/json

{
  "timestamp": "2026-07-13T09:45:00Z",
  "status": 400,
  "error": "Validation failed",
  "details": [
    {
      "field": "name",
      "message": "name must not be blank"
    },
    {
      "field": "email",
      "message": "email must be valid"
    }
  ]
}
```

## 14. Error Handling Best Practices

A good REST API should return:
- correct HTTP status code
- clear message
- enough detail for debugging
- no sensitive internal information

Recommended error structure:

```json
{
  "timestamp": "2026-07-13T09:45:00Z",
  "status": 404,
  "error": "User not found",
  "path": "/users/123"
}
```

For validation:

```json
{
  "timestamp": "2026-07-13T09:45:00Z",
  "status": 400,
  "error": "Validation failed",
  "details": [
    {
      "field": "email",
      "message": "must be a valid email"
    }
  ]
}
```

Do not expose:
- stack traces to clients
- database internals
- secret values

## 15. Authentication vs Authorization

### Authentication

Who are you?

Examples:
- username and password
- JWT
- OAuth token

### Authorization

What are you allowed to do?

Examples:
- admin can delete a user
- regular user can only view own profile

Interview explanation:
- Authentication identifies.
- Authorization permits.

## 16. Tokens and JWT Basics

A token is often passed in the `Authorization` header:

```http
Authorization: Bearer <token>
```

JWT often contains:
- subject
- expiry
- roles or claims

Important caution:
- A JWT is not encrypted by default.
- Sensitive data should not be stored casually inside it.

## 17. Pagination

Pagination prevents huge payloads and improves response control.

Common styles:
- page and size
- limit and offset
- cursor-based pagination

Example:

```http
GET /users?page=0&size=20
```

Possible response:

```json
{
  "content": [
    { "id": 1, "name": "A" },
    { "id": 2, "name": "B" }
  ],
  "page": 0,
  "size": 20,
  "totalElements": 240,
  "totalPages": 12
}
```

## 18. Sorting and Filtering

Examples:

```http
GET /orders?status=PAID
GET /orders?sort=createdAt,desc
GET /orders?status=PAID&sort=createdAt,desc&page=0&size=10
```

Good API design combines them predictably.

## 19. Versioning

Why version APIs:
- avoid breaking existing clients
- allow controlled evolution

Common styles:
- URI versioning: `/api/v1/users`
- header-based versioning
- media type versioning

Most common in enterprise apps:

```http
/api/v1/users
```

Guideline:
- prefer backward-compatible changes when possible
- use a new version for breaking contract changes

## 20. Caching

Caching can improve speed and reduce server load.

Common headers:
- `Cache-Control`
- `ETag`
- `If-None-Match`
- `Last-Modified`

Example flow:

```http
GET /products/101
ETag: "v3-product-101"
```

Client later sends:

```http
GET /products/101
If-None-Match: "v3-product-101"
```

Server may return:

```http
304 Not Modified
```

## 21. Concurrency Control

Why it matters:
- two clients may update the same resource at the same time

A common solution is optimistic locking with version fields or ETags.

Example idea:
- client reads user version 5
- client updates with version 5
- if version already became 6, server rejects update

Possible response:

```http
409 Conflict
```

or precondition-based flow with:
- `If-Match`

## 22. Idempotency in Payment or Order APIs

For sensitive create operations, duplicate requests can be dangerous.

Example:
- user clicks pay twice
- network retry sends same request again

Common solution:
- use idempotency keys

Example:

```http
POST /payments
Idempotency-Key: 7e18c669-98f8-4fdf-8c1b-5da55b6af4b8
```

This helps the server detect repeated create attempts safely.

## 23. Synchronous vs Asynchronous APIs

### Synchronous

Client waits for the result in the same request.

Example:
- fetch user profile

### Asynchronous

Server accepts the request and processes it later.

Example:
- large report generation
- media conversion
- long-running scan

Response may be:

```http
202 Accepted
```

And then client checks status:

```http
GET /jobs/456
```

## 24. REST API Security Best Practices

- always use HTTPS
- validate all inputs
- authenticate every protected request
- apply authorization checks
- avoid exposing internal stack traces
- rate limit sensitive endpoints
- log correlation IDs
- sanitize output
- protect against injection attacks

## 25. Rate Limiting

Rate limiting protects APIs from abuse, accidental overload, and brute-force patterns.

Possible response:

```http
429 Too Many Requests
```

Common headers:
- `Retry-After`
- custom remaining quota headers

## 26. Observability and API Debugging

Important operational practices:
- structured logs
- request IDs or correlation IDs
- metrics
- latency tracking
- error rate tracking
- distributed tracing

Common troubleshooting flow:
1. identify endpoint and time
2. check status code pattern
3. trace request through logs
4. inspect upstream dependencies
5. confirm payload and auth

## 27. REST API Documentation

Good API documentation should explain:
- endpoint purpose
- method
- request headers
- query parameters
- path variables
- request body
- success response
- error responses
- example requests

Common tools:
- OpenAPI
- Swagger UI

## 28. REST API Example: User Service

### Create user

```http
POST /api/v1/users
Content-Type: application/json

{
  "name": "Ravi",
  "email": "ravi@example.com"
}
```

Response:

```http
201 Created
Location: /api/v1/users/123
Content-Type: application/json

{
  "id": 123,
  "name": "Ravi",
  "email": "ravi@example.com",
  "status": "ACTIVE"
}
```

### Get user

```http
GET /api/v1/users/123
Accept: application/json
```

Response:

```json
{
  "id": 123,
  "name": "Ravi",
  "email": "ravi@example.com",
  "status": "ACTIVE"
}
```

### Update user partially

```http
PATCH /api/v1/users/123
Content-Type: application/json

{
  "status": "INACTIVE"
}
```

### Delete user

```http
DELETE /api/v1/users/123
```

Response:

```http
204 No Content
```

## 29. Common REST API Mistakes

- using verbs in URLs unnecessarily
- returning `200 OK` for every outcome
- exposing internal exception details
- not validating request data
- mixing path variables and query parameters badly
- not versioning when breaking changes happen
- returning very large unpaged lists
- poor error response consistency
- weak security on internal APIs

## 30. REST API in Spring Boot Context

In Spring Boot, common building blocks are:
- `@RestController`
- `@RequestMapping`
- `@GetMapping`
- `@PostMapping`
- `@PutMapping`
- `@PatchMapping`
- `@DeleteMapping`
- `@PathVariable`
- `@RequestParam`
- `@RequestBody`
- validation annotations
- `@ControllerAdvice`

Simple example:

```java
@RestController
@RequestMapping("/api/v1/users")
public class UserController {

    @GetMapping("/{id}")
    public UserResponse getUser(@PathVariable Long id) {
        return userService.getUser(id);
    }

    @PostMapping
    public ResponseEntity<UserResponse> createUser(@Valid @RequestBody CreateUserRequest request) {
        UserResponse response = userService.createUser(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }
}
```

## 31. Best Interview Answer Structure for REST Questions

When asked a REST API question, answer in this order:
1. define the concept
2. explain why it matters
3. give one example
4. mention one common mistake or tradeoff

Example:

Question: What is idempotency?

Better spoken answer:
Idempotency means sending the same request multiple times should leave the server in the same final state as sending it once. It matters because retries can happen in real systems. For example, `PUT` and `DELETE` are typically idempotent, while `POST` usually is not unless we use an idempotency key. A common mistake is treating duplicate create requests as harmless when they can create duplicate business actions.

## 32. Quick Revision Checklist

- REST meaning
- resource-based URL design
- HTTP methods
- safe vs idempotent
- status codes
- request headers
- path vs query vs body
- validation and error handling
- auth vs authorization
- versioning
- pagination
- caching
- rate limiting
- optimistic locking
- API documentation
