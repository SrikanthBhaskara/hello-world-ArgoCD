# Streams vs Collections

## Collections
Collections store data.

## Streams
Streams process data.

## Key difference
A collection is about holding elements in memory. A stream is about describing operations over those elements.

## Important points
- Collections can be reused.
- Streams are usually consumed once.
- Collections are eager storage.
- Streams support lazy computation.

## Example comparison

### Collection-focused usage
```java
List<String> names = new ArrayList<>();
names.add("Anu");
names.add("Ravi");
```

Here the purpose is storing and reusing data.

### Stream-focused usage
```java
List<String> result = names.stream()
	.filter(name -> name.startsWith("A"))
	.map(String::toUpperCase)
	.collect(Collectors.toList());
```

Here the purpose is processing data.

## Practical distinction
If you need to store, update, and reuse data, you need a collection. If you need to express a processing pipeline over data, you use a stream.

## Interview point
This difference is important because developers often confuse streams as if they were just another collection type.

## Interview-style answer
Collections and streams solve different problems. Collections are used to store and manage data, while streams are used to describe how data should be processed. A collection is reusable storage, but a stream is usually a one-time processing pipeline created from some source.