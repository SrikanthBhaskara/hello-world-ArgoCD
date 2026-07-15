# Java 8 Date and Time API

## Why it matters
The old `Date` and `Calendar` APIs were difficult to use correctly. They were mutable, not intuitive, and had several design issues. Java 8 introduced the `java.time` API, which is more consistent, immutable, and easier to reason about.

## Core design improvements
- Immutability
- Thread safety
- Clear separation of date, time, and timezone concepts
- Better method names
- Cleaner arithmetic and formatting

## Key classes
- `LocalDate`
- `LocalTime`
- `LocalDateTime`
- `ZonedDateTime`
- `Period`
- `Duration`
- `DateTimeFormatter`

## Examples

### Date only
```java
LocalDate today = LocalDate.now();
LocalDate nextMonth = today.plusMonths(1);
```

### Time only
```java
LocalTime now = LocalTime.now();
```

### Date and time
```java
LocalDateTime timestamp = LocalDateTime.now();
```

### Zoned date and time
```java
ZonedDateTime indiaTime = ZonedDateTime.now(ZoneId.of("Asia/Kolkata"));
```

## Period vs Duration
- `Period` is for date-based amounts such as days, months, years.
- `Duration` is for time-based amounts such as seconds, minutes, hours.

## Formatting example
```java
DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd-MM-yyyy");
String formatted = LocalDate.now().format(formatter);
```

## Why interviewers ask about this
Because many legacy codebases still contain old date APIs, and engineers should know why `java.time` is safer and more maintainable.

## Interview-style answer
The Java 8 date and time API replaced older mutable and awkward date classes with a cleaner, immutable, and thread-safe model. Classes like `LocalDate`, `LocalDateTime`, and `ZonedDateTime` make it easier to handle real-world time logic correctly, and the API is far more expressive for date arithmetic and formatting.