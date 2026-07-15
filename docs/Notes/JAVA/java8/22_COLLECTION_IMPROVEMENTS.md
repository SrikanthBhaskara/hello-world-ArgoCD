# Collection Improvements in Java 8

## Important additions
- forEach
- removeIf
- replaceAll
- computeIfAbsent
- computeIfPresent
- merge

## Example: removeIf
```java
names.removeIf(name -> name.isEmpty());
```

## Example: computeIfAbsent
```java
map.computeIfAbsent("team", k -> new ArrayList<>()).add("Alice");
```

## Example: merge
```java
Map<String, Integer> scoreMap = new HashMap<>();
scoreMap.merge("java", 1, Integer::sum);
scoreMap.merge("java", 1, Integer::sum);
System.out.println(scoreMap);
```

## Example: replaceAll
```java
List<String> names = new ArrayList<>(Arrays.asList("java", "stream"));
names.replaceAll(String::toUpperCase);
System.out.println(names);
```

## Why it matters
These additions reduced repetitive map and collection update boilerplate.

## Why `computeIfAbsent` matters
Before Java 8, developers often had to write repetitive check-then-put code. Java 8 collection improvements reduced that boilerplate and made intent clearer.

## Interview point
Be able to explain why methods like `computeIfAbsent` improved common data structure update patterns.

## Interview-style answer
Java 8 improved collections and maps by adding methods such as `forEach`, `removeIf`, `replaceAll`, `computeIfAbsent`, and `merge`. These reduce boilerplate and make update patterns more expressive, especially when working with maps and mutable collections.