# Default and Static Methods in Interfaces

## Why this feature was introduced
Before Java 8, if a new method was added to an interface, every existing implementation had to be updated. That was a major problem for library evolution. Default methods solved this by allowing behavior to be added without immediately breaking old implementations.

## Default methods
Default methods allow an interface to provide an implementation.

```java
interface Vehicle {
    default void start() {
        System.out.println("Starting");
    }
}
```

Any implementing class can use this default behavior or override it.

## Static methods in interfaces
Static methods allow interfaces to contain related utility logic.

```java
interface MathUtil {
    static int square(int x) {
        return x * x;
    }
}
```

These are called using the interface name, not through instances.

## Why this matters in API design
- Helps evolve library interfaces safely
- Keeps related utility behavior close to the contract
- Reduces pressure to create separate utility classes for every small helper

## When default methods are useful
- Backward-compatible interface evolution
- Shared baseline behavior across implementations
- Convenience methods closely tied to the interface contract

## When to be careful
Default methods should not become a place for unrelated or overly complex logic. They are helpful when the behavior genuinely belongs to the interface abstraction.

## Interview-style answer
Default methods in Java 8 were introduced mainly to support interface evolution without breaking all existing implementations. Static methods in interfaces allow utility behavior that naturally belongs with the interface. Together, these features made interfaces more flexible and helped library maintainers introduce improvements more safely.