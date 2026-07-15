# Internal vs External Iteration

## External iteration
Traditional loops where the developer controls every iteration step.

```java
for (String name : names) {
    System.out.println(name);
}
```

## Internal iteration
The stream API controls the iteration internally.

```java
names.stream().forEach(System.out::println);
```

## Why it matters
Internal iteration is more declarative and allows the library to optimize execution, including possible parallelization.

## Comparison example

### External iteration
```java
List<String> result = new ArrayList<>();
for (String name : names) {
    if (name.length() > 3) {
        result.add(name.toUpperCase());
    }
}
```

### Internal iteration
```java
List<String> result = names.stream()
    .filter(name -> name.length() > 3)
    .map(String::toUpperCase)
    .collect(Collectors.toList());
```

The first version controls traversal directly. The second version describes the processing steps.

## Why this matters in design
Internal iteration allows the library to manage traversal details, which enables more declarative code and makes optimization such as parallel execution possible.

## Interview point
Explain that internal iteration shifts focus from loop mechanics to operation intent.

## Interview-style answer
External iteration means the developer controls the loop manually. Internal iteration means the library controls traversal and the developer describes the operations to apply. Java 8 streams use internal iteration, which makes many collection-processing tasks more declarative and easier to compose.