# Java 8 Solved Coding Examples by Topic

This file gives practical Java 8 coding examples grouped by topic. The goal is not only to show syntax, but to show when each feature is useful.

## 1. Lambda Example: Sorting Employees by Name

```java
List<String> names = Arrays.asList("Ravi", "Anu", "Kiran");
names.sort((a, b) -> a.compareTo(b));
System.out.println(names);
```

Why it matters:
This shows how lambdas replace anonymous comparator classes.

## 2. Method Reference Example: Printing a List

```java
List<String> names = Arrays.asList("A", "B", "C");
names.forEach(System.out::println);
```

Why it matters:
This shows how an existing method can replace a simple lambda.

## 3. Predicate Example: Filter Even Numbers

```java
Predicate<Integer> isEven = n -> n % 2 == 0;
List<Integer> nums = Arrays.asList(1, 2, 3, 4, 5, 6);

List<Integer> evens = nums.stream()
    .filter(isEven)
    .collect(Collectors.toList());

System.out.println(evens);
```

## 4. Function Example: Convert Names to Lengths

```java
List<String> words = Arrays.asList("java", "stream", "lambda");

List<Integer> lengths = words.stream()
    .map(String::length)
    .collect(Collectors.toList());

System.out.println(lengths);
```

## 5. Consumer Example: Log Each Value

```java
Consumer<String> log = value -> System.out.println("Value: " + value);
Arrays.asList("x", "y", "z").forEach(log);
```

## 6. Supplier Example: Lazy Object Creation

```java
Supplier<List<String>> listSupplier = ArrayList::new;
List<String> result = listSupplier.get();
result.add("created lazily");
System.out.println(result);
```

## 7. Stream filter + map Example

```java
List<String> names = Arrays.asList("Anu", "Ravi", "Arjun", "Sam");

List<String> filtered = names.stream()
    .filter(name -> name.startsWith("A"))
    .map(String::toUpperCase)
    .collect(Collectors.toList());

System.out.println(filtered);
```

## 8. flatMap Example: Flatten Nested Lists

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

## 9. Collectors.groupingBy Example

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

Map<String, List<Employee>> grouped = employees.stream()
    .collect(Collectors.groupingBy(Employee::getDepartment));

System.out.println(grouped.keySet());
```

## 10. reduce Example: Sum of Numbers

```java
List<Integer> nums = Arrays.asList(1, 2, 3, 4, 5);
int sum = nums.stream().reduce(0, Integer::sum);
System.out.println(sum);
```

## 11. Optional Example: Safe Null Handling

```java
String input = null;

String value = Optional.ofNullable(input)
    .map(String::trim)
    .orElse("default");

System.out.println(value);
```

## 12. Optional Chain Example

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

## 13. Date API Example

```java
LocalDate today = LocalDate.now();
LocalDate afterTenDays = today.plusDays(10);
System.out.println(afterTenDays);
```

## 14. Map computeIfAbsent Example

```java
Map<String, List<String>> teamMap = new HashMap<>();
teamMap.computeIfAbsent("backend", key -> new ArrayList<>()).add("Alice");
teamMap.computeIfAbsent("backend", key -> new ArrayList<>()).add("Bob");
System.out.println(teamMap);
```

## 15. CompletableFuture Example: Async Greeting

```java
CompletableFuture<String> future = CompletableFuture
    .supplyAsync(() -> "Java")
    .thenApply(text -> text + " 8")
    .thenApply(String::toUpperCase);

System.out.println(future.join());
```

## 16. CompletableFuture thenCompose Example

```java
CompletableFuture<String> fetchUser() {
    return CompletableFuture.supplyAsync(() -> "user-101");
}

CompletableFuture<String> fetchOrders(String userId) {
    return CompletableFuture.supplyAsync(() -> "orders for " + userId);
}

CompletableFuture<String> result = fetchUser()
    .thenCompose(userId -> fetchOrders(userId));

System.out.println(result.join());
```

## 17. Parallel Stream Example

```java
long count = IntStream.rangeClosed(1, 1_000_000)
    .parallel()
    .filter(n -> n % 2 == 0)
    .count();

System.out.println(count);
```

## 18. Primitive Stream Example

```java
int total = IntStream.rangeClosed(1, 100).sum();
System.out.println(total);
```

## How to Use These Examples
- Rewrite each example manually.
- Convert one lambda example into anonymous inner class form.
- Explain what changes if the code becomes stateful.
- Practice speaking about why Java 8 makes each case cleaner.