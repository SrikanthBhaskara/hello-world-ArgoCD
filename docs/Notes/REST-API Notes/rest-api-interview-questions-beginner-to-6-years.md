# REST API Interview Questions: Beginner to 6 Years

These notes are written for spoken interview practice. Use the `Short answer` first, then the `Better answer` when the interviewer wants depth.

## Beginner Level

### 1. What is a REST API?
Short answer:
A REST API is an HTTP-based interface that exposes resources through URLs and uses standard methods like GET, POST, PUT, PATCH, and DELETE.

Better answer:
REST API stands for Representational State Transfer API. It is a resource-oriented way of designing web services where clients interact with server resources using standard HTTP methods. The main ideas are statelessness, predictable URI design, and proper use of HTTP semantics.

### 2. What is the difference between REST and SOAP?
Short answer:
REST is a lightweight architectural style commonly using JSON over HTTP, while SOAP is a protocol with stricter standards and XML-based messaging.

Better answer:
REST is simpler and more flexible, which is why it is common in modern web and microservice systems. SOAP has built-in standards for security and contracts, but it is heavier. I would choose based on integration needs, though REST is more common for modern application APIs.

### 3. Why are nouns preferred in REST URLs instead of verbs?
Short answer:
Because the URL should represent the resource, and the HTTP method should represent the action.

Better answer:
Using nouns keeps the API resource-oriented and consistent. For example, `POST /users` is better than `POST /createUser` because the HTTP method already tells us the action. This improves readability and avoids inconsistent endpoint naming.

### 4. What are the main HTTP methods used in REST?
Short answer:
GET, POST, PUT, PATCH, and DELETE.

Better answer:
GET is used to read data, POST is used to create or trigger processing, PUT is used to replace a resource, PATCH is used for partial update, and DELETE is used to remove a resource. The important part is not just naming them, but using them according to their semantics.

### 5. What is statelessness in REST?
Short answer:
Statelessness means each request contains all the information needed for the server to process it.

Better answer:
In a stateless API, the server does not depend on stored conversational context from earlier requests. This improves scalability and makes load balancing easier because any server instance can process the request if the required auth and data are included.

### 6. What is the difference between path variables and query parameters?
Short answer:
Path variables identify a specific resource, and query parameters are usually used for filtering, sorting, or pagination.

Better answer:
I use path variables when the value is part of the resource identity, such as `/users/123`. I use query parameters when the value modifies how results are returned, such as `/users?page=1&size=20`.

### 7. What is JSON and why is it commonly used in REST APIs?
Short answer:
JSON is a lightweight data-interchange format that is easy for humans to read and easy for systems to parse.

Better answer:
JSON is compact, widely supported, and much easier to work with than XML in many modern systems. That is why most REST APIs use JSON for request and response bodies unless a different format is specifically needed.

### 8. What is the difference between `PUT` and `PATCH`?
Short answer:
PUT is generally used for full replacement, while PATCH is used for partial update.

Better answer:
If I want to replace the resource representation, I use PUT. If I want to change only selected fields, I use PATCH. This matters because it affects payload design, idempotency thinking, and client expectations.

### 9. What is the difference between `POST` and `PUT`?
Short answer:
POST usually creates a new resource, while PUT usually updates or replaces a resource at a known URL.

Better answer:
POST is commonly used when the server decides the new resource identifier, such as creating a new order. PUT is commonly used when the resource identity is already known, and it is usually idempotent while POST is usually not.

### 10. What does idempotent mean?
Short answer:
It means repeating the same request produces the same final server state.

Better answer:
Idempotency matters because retries happen in distributed systems. For example, multiple PUT requests with the same payload should lead to the same final state. That makes retry behavior safer.

## Intermediate Level

### 11. What is the difference between safe and idempotent methods?
Short answer:
Safe methods do not change server state, and idempotent methods can be repeated without changing the final state further.

Better answer:
GET is both safe and idempotent because it should only read data. DELETE is idempotent because deleting the same resource again should still leave it deleted, but it is not safe because it changes state. This distinction often comes up in API design and retry logic.

### 12. Which status code do you use for resource creation?
Short answer:
`201 Created`

Better answer:
For successful creation, I prefer `201 Created`, often with a `Location` header pointing to the new resource. That communicates both success and the URI of what was created.

### 13. What is the difference between `401 Unauthorized` and `403 Forbidden`?
Short answer:
`401` means authentication is missing or invalid, and `403` means the user is authenticated but not allowed.

Better answer:
I explain it as identity versus permission. `401` is about proving who you are. `403` is about the server knowing who you are but still denying the action because the permission is not sufficient.

### 14. How should error handling work in a REST API?
Short answer:
Use the correct status code, return a clear message, and keep the error format consistent.

Better answer:
A good error response should help the client understand what failed without exposing internal secrets or stack traces. I prefer a standard error structure that includes status, message, path, timestamp, and field-level validation details when applicable.

### 15. How do you handle validation errors?
Short answer:
Return a client-side error such as `400 Bad Request` with field-specific messages.

Better answer:
Validation errors should tell the client exactly what is wrong, such as a missing required field or invalid email format. That improves usability and reduces repeated bad requests. In Spring Boot this is often handled centrally with validation annotations and exception handling advice.

### 16. How do you design pagination in REST APIs?
Short answer:
Use parameters like page and size, or limit and offset.

Better answer:
Pagination prevents huge responses and improves performance. I also return metadata like total elements, total pages, current page, and page size so the client can navigate results properly.

### 17. What is API versioning and why is it needed?
Short answer:
API versioning helps us evolve an API without breaking existing clients.

Better answer:
When an API contract changes in a breaking way, existing consumers may fail. Versioning allows controlled evolution. URI-based versioning like `/api/v1/users` is common because it is explicit and easy for consumers to understand.

### 18. What is content negotiation?
Short answer:
It is the mechanism where client and server agree on representation format, often using the `Accept` header.

Better answer:
Content negotiation lets the client say what response format it wants and lets the server decide whether it can provide that format. In many modern APIs JSON is the default, but the concept is still important for understanding HTTP design.

### 19. How does caching help REST APIs?
Short answer:
Caching reduces repeated processing and improves response time.

Better answer:
REST APIs can use headers like `Cache-Control`, `ETag`, and `If-None-Match` so clients or proxies do not download unchanged data repeatedly. This improves performance and reduces server load.

### 20. What is HATEOAS?
Short answer:
It is the idea that responses can include links to related actions or resources.

Better answer:
HATEOAS is part of REST theory, where the client discovers available actions through links provided in responses. It is not always fully used in enterprise APIs, but knowing the concept shows a deeper understanding of REST maturity.

## Experienced Level

### 21. How do you design a REST API for partial update safely?
Short answer:
Use PATCH carefully, validate only intended fields, and make update rules explicit.

Better answer:
For partial updates, I define clearly which fields are patchable, validate them properly, and make sure the merge behavior is predictable. I also consider concurrency and audit concerns because partial updates can create subtle bugs when multiple clients update the same resource.

### 22. How do you prevent duplicate creation during retries?
Short answer:
Use idempotency keys for sensitive create operations.

Better answer:
In operations like payment or order creation, retries can create duplicate business actions. I handle that by using an idempotency key sent by the client so the server can detect repeated requests and return the original result safely.

### 23. How do you handle concurrent updates on the same resource?
Short answer:
Use optimistic locking with a version field or ETag-based preconditions.

Better answer:
When two clients update the same record, one update can accidentally overwrite the other. I prevent that using optimistic locking, usually through a version field or ETag with `If-Match`. If the version has changed, the server rejects the update with a conflict or precondition failure.

### 24. How do you secure a REST API?
Short answer:
Use HTTPS, authentication, authorization, validation, rate limiting, and secure error handling.

Better answer:
Security is layered. I start with HTTPS, then strong authentication such as JWT or OAuth-based flows, role or permission checks for authorization, input validation, secret protection, rate limiting, and careful logging. I also avoid exposing internal exceptions or sensitive data in responses.

### 25. How do you design error responses for distributed systems?
Short answer:
Keep them consistent, traceable, and safe for clients.

Better answer:
In distributed systems, errors need to be debuggable across services. I prefer standardized error structures with timestamp, status, code, message, path, and correlation ID. That helps both clients and backend teams trace failures quickly.

### 26. When would you return `202 Accepted`?
Short answer:
When the request is accepted but processing happens asynchronously.

Better answer:
I use `202 Accepted` for long-running operations such as report generation, scanning, or batch processing where the final result is not ready immediately. The API should then expose a status endpoint or job resource for follow-up.

### 27. How do you choose between REST and asynchronous event-driven communication?
Short answer:
REST is good for request-response interactions, and event-driven design is better for decoupled asynchronous flows.

Better answer:
If the caller needs an immediate response, REST is usually a good fit. If the workflow is long-running, loosely coupled, or fan-out based, event-driven design may be better. In real systems both styles often coexist.

### 28. What are common mistakes in REST API design?
Short answer:
Using bad URLs, wrong status codes, weak validation, inconsistent error responses, and poor versioning.

Better answer:
I often see APIs that use verbs in URLs, return `200 OK` for every situation, expose internal stack traces, skip pagination, or ignore idempotency and concurrency concerns. Good API design is not only about making endpoints work, but about making them predictable and safe over time.

### 29. How would you explain REST API design in Spring Boot?
Short answer:
Use controllers for endpoints, DTOs for payloads, validation for inputs, service layers for logic, and global exception handling for consistency.

Better answer:
In Spring Boot I separate endpoint handling from business logic. Controllers map requests, DTOs define request and response contracts, validation annotations enforce input quality, services contain business rules, and global exception handlers keep error responses consistent. That separation improves maintainability and testing.

### 30. How do you document REST APIs?
Short answer:
Document endpoints, parameters, payloads, responses, errors, and examples, usually with OpenAPI or Swagger.

Better answer:
Good documentation should help both consumers and maintainers. I include endpoint purpose, method, auth requirements, request and response examples, field descriptions, error cases, and version information. Tools like OpenAPI help keep the contract explicit and reviewable.

## Scenario-Based Questions

### 31. A client says your API sometimes creates duplicate orders. What do you check?
Short answer:
I check retry behavior, POST semantics, and whether idempotency protection exists.

Better answer:
I would investigate whether the client retries on timeout, whether the endpoint is using plain POST without idempotency protection, and whether the server stores duplicate requests safely. In order or payment flows, idempotency keys are often the right fix.

### 32. A GET endpoint is slow. What areas do you investigate?
Short answer:
I check database performance, unnecessary payload size, caching, dependency latency, and pagination.

Better answer:
I would inspect query efficiency, N+1 patterns, payload size, serialization overhead, upstream dependency latency, and whether caching or pagination should be used. I also confirm whether the slowness is in the application, database, or network path.

### 33. Your API returns `500 Internal Server Error` for invalid input. What is wrong?
Short answer:
Invalid client input should not normally return `500`; it should return a client-side error like `400`.

Better answer:
This usually means validation is happening too late or exceptions are not being mapped properly. I would move validation closer to the request boundary and standardize exception handling so client mistakes return 4xx responses instead of appearing as server failures.

### 34. A delete endpoint is called twice. What should happen?
Short answer:
The final state should still be that the resource is deleted.

Better answer:
DELETE is expected to be idempotent, so repeated deletion should not produce inconsistent behavior. The response may vary between implementations, but the important point is that the resource remains deleted and the API stays predictable.

### 35. An API consumer wants all 2 million records in one response. How do you answer?
Short answer:
I would avoid returning everything in one response and require pagination or batch export design.

Better answer:
Large unbounded responses are risky for memory, latency, and stability. I would introduce pagination, filtering, or an asynchronous export job depending on the use case. The API should protect both the server and the client from uncontrolled payloads.

## Quick Revision

- REST meaning
- resource naming
- GET, POST, PUT, PATCH, DELETE
- safe vs idempotent
- status codes
- path vs query vs body
- validation
- auth vs authorization
- pagination
- versioning
- caching
- idempotency keys
- error handling
- concurrency control
