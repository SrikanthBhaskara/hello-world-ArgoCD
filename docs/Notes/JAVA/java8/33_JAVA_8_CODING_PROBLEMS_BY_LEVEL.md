# Java 8 Coding Problems by Level

This file organizes Java 8 coding practice by difficulty level. The focus is on applying streams, lambdas, Optional, collectors, and CompletableFuture where appropriate.

## Easy Level

### Problem 1. Filter even numbers using streams
Given a list of integers, return only the even numbers.

What to practice:
- `filter`
- `collect`

Sample direction:
Use `numbers.stream().filter(n -> n % 2 == 0).collect(Collectors.toList())`

Solved code:
```java
List<Integer> numbers = Arrays.asList(1, 2, 3, 4, 5, 6);

List<Integer> evens = numbers.stream()
	.filter(n -> n % 2 == 0)
	.collect(Collectors.toList());

System.out.println(evens);
```

### Problem 2. Convert names to uppercase
Given a list of names, return a new list with all names in uppercase.

What to practice:
- `map`
- method references if useful

Solved code:
```java
List<String> names = Arrays.asList("java", "stream", "lambda");

List<String> upper = names.stream()
	.map(String::toUpperCase)
	.collect(Collectors.toList());

System.out.println(upper);
```

### Problem 3. Find total sum of numbers
Given a list of integers, return the sum.

What to practice:
- `reduce`
- primitive stream alternatives

Solved code:
```java
List<Integer> numbers = Arrays.asList(10, 20, 30, 40);

int sum = numbers.stream()
	.reduce(0, Integer::sum);

System.out.println(sum);
```

Alternative using primitive stream:
```java
int sum2 = numbers.stream().mapToInt(Integer::intValue).sum();
System.out.println(sum2);
```

### Problem 4. Safe null default with Optional
Given a possibly null string, trim it and return a default value if absent.

What to practice:
- `Optional.ofNullable`
- `map`
- `orElse`

Solved code:
```java
String input = null;

String result = Optional.ofNullable(input)
	.map(String::trim)
	.orElse("default");

System.out.println(result);
```

### Problem 5. Sort strings by length using lambda
Sort a list of strings by their lengths.

What to practice:
- lambda with `Comparator`

Solved code:
```java
List<String> names = new ArrayList<>(Arrays.asList("elephant", "cat", "tiger", "ox"));

names.sort((a, b) -> Integer.compare(a.length(), b.length()));

System.out.println(names);
```

## Intermediate Level

### Problem 6. Group employees by department
Given a list of employees, group them by department.

What to practice:
- `Collectors.groupingBy`

Solved code:
```java
class Employee {
	private final String name;
	private final String department;

	Employee(String name, String department) {
		this.name = name;
		this.department = department;
	}

	public String getDepartment() {
		return department;
	}

	public String getName() {
		return name;
	}
}

List<Employee> employees = Arrays.asList(
	new Employee("A", "IT"),
	new Employee("B", "HR"),
	new Employee("C", "IT")
);

Map<String, List<Employee>> byDepartment = employees.stream()
	.collect(Collectors.groupingBy(Employee::getDepartment));

System.out.println(byDepartment.keySet());
```

### Problem 7. Count words by frequency
Given a list of words, return a frequency map.

What to practice:
- `Collectors.groupingBy`
- `Collectors.counting`

Solved code:
```java
List<String> words = Arrays.asList("java", "stream", "java", "lambda", "stream", "java");

Map<String, Long> frequency = words.stream()
	.collect(Collectors.groupingBy(word -> word, Collectors.counting()));

System.out.println(frequency);
```

### Problem 8. Flatten nested lists
Given `List<List<String>>`, return a flat list.

What to practice:
- `flatMap`

Solved code:
```java
List<List<String>> nested = Arrays.asList(
	Arrays.asList("a", "b"),
	Arrays.asList("c", "d")
);

List<String> flat = nested.stream()
	.flatMap(List::stream)
	.collect(Collectors.toList());

System.out.println(flat);
```

### Problem 9. Find the longest string
Return the longest string from a list.

What to practice:
- `max`
- `Comparator.comparingInt`

Solved code:
```java
List<String> words = Arrays.asList("java", "microservices", "api", "backend");

Optional<String> longest = words.stream()
	.max(Comparator.comparingInt(String::length));

System.out.println(longest.orElse(""));
```

### Problem 10. Build map with computeIfAbsent
Given pairs of department and employee names, build a map from department to employee list.

What to practice:
- `computeIfAbsent`

Solved code:
```java
Map<String, List<String>> teamMap = new HashMap<>();

teamMap.computeIfAbsent("IT", key -> new ArrayList<>()).add("Alice");
teamMap.computeIfAbsent("IT", key -> new ArrayList<>()).add("Bob");
teamMap.computeIfAbsent("HR", key -> new ArrayList<>()).add("Carol");

System.out.println(teamMap);
```

### Problem 11. Optional nested lookup
Given `User -> Address -> City`, return city name safely.

What to practice:
- chained `Optional.map`

Solved code:
```java
class Address {
	private final String city;

	Address(String city) {
		this.city = city;
	}

	public String getCity() {
		return city;
	}
}

class User {
	private final Address address;

	User(Address address) {
		this.address = address;
	}

	public Address getAddress() {
		return address;
	}
}

User user = new User(new Address("Hyderabad"));

String city = Optional.ofNullable(user)
	.map(User::getAddress)
	.map(Address::getCity)
	.orElse("Unknown");

System.out.println(city);
```

## Advanced Level

### Problem 12. Parallel stream sum with caution
Process a large numeric dataset and explain when parallel execution helps or hurts.

What to practice:
- `parallelStream`
- performance reasoning

Solved code:
```java
long count = IntStream.rangeClosed(1, 1_000_000)
	.parallel()
	.filter(n -> n % 2 == 0)
	.count();

System.out.println(count);
```

Explanation:
This can help when the dataset is large and the work per element is meaningful. It can hurt when the dataset is small or the overhead of splitting work exceeds the benefit.

### Problem 13. Async user and order fetch
Fetch user info and then fetch that user's orders asynchronously.

What to practice:
- `CompletableFuture`
- `thenCompose`

Solved code:
```java
public static CompletableFuture<String> fetchUser() {
	return CompletableFuture.supplyAsync(() -> "user-101");
}

public static CompletableFuture<String> fetchOrders(String userId) {
	return CompletableFuture.supplyAsync(() -> "orders for " + userId);
}

CompletableFuture<String> result = fetchUser()
	.thenCompose(userId -> fetchOrders(userId));

System.out.println(result.join());
```

### Problem 14. Combine two async service results
Fetch profile and balance asynchronously, then merge them into one response.

What to practice:
- `thenCombine`

Solved code:
```java
CompletableFuture<String> profileFuture = CompletableFuture.supplyAsync(() -> "Profile: Alice");
CompletableFuture<Integer> balanceFuture = CompletableFuture.supplyAsync(() -> 5000);

CompletableFuture<String> combined = profileFuture.thenCombine(
	balanceFuture,
	(profile, balance) -> profile + ", Balance: " + balance
);

System.out.println(combined.join());
```

### Problem 15. Handle async fallback
Create a future that may fail and recover using `exceptionally`.

What to practice:
- async exception handling

Solved code:
```java
CompletableFuture<String> future = CompletableFuture.supplyAsync(() -> {
	throw new RuntimeException("Service failed");
}).exceptionally(ex -> "fallback-response");

System.out.println(future.join());
```

### Problem 16. Multi-step stream pipeline
Given a list of orders, filter successful ones, map to amount, and produce total amount per customer.

What to practice:
- filtering
- mapping
- grouping
- summarizing or reducing

Solved code:
```java
class Order {
	private final String customer;
	private final int amount;
	private final boolean success;

	Order(String customer, int amount, boolean success) {
		this.customer = customer;
		this.amount = amount;
		this.success = success;
	}

	public String getCustomer() {
		return customer;
	}

	public int getAmount() {
		return amount;
	}

	public boolean isSuccess() {
		return success;
	}
}

List<Order> orders = Arrays.asList(
	new Order("Alice", 100, true),
	new Order("Bob", 200, false),
	new Order("Alice", 300, true),
	new Order("Bob", 150, true)
);

Map<String, Integer> totals = orders.stream()
	.filter(Order::isSuccess)
	.collect(Collectors.groupingBy(
		Order::getCustomer,
		Collectors.summingInt(Order::getAmount)
	));

System.out.println(totals);
```

## How to Practice These Problems
- Solve once with plain Java style.
- Solve again using Java 8 features.
- Compare readability and complexity.
- Explain why the Java 8 approach is better or not better for that case.
- Add one edge case for each solution.