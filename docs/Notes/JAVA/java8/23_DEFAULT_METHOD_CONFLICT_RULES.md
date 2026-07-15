# Default Method Conflict Rules

## Why conflict happens
If a class implements multiple interfaces that provide the same default method, Java needs a rule to resolve ambiguity.

## Main rules
- Class methods win over interface default methods.
- More specific interfaces win over parent interfaces.
- If ambiguity still exists, the class must override the method explicitly.

## Example idea
If `A` and `B` both define `default void show()`, a class implementing both must override `show()`.

## Example scenario
If interface `A` and interface `B` both define `default void show()`, then a class implementing both must provide its own `show()` implementation.

## Code example
```java
interface A {
	default void show() {
		System.out.println("A");
	}
}

interface B {
	default void show() {
		System.out.println("B");
	}
}

class Demo implements A, B {
	@Override
	public void show() {
		System.out.println("Resolved in Demo");
	}
}
```

Without the override, the compiler would reject the ambiguity.

## Interview point
The rule is not arbitrary. It protects clarity and avoids unpredictable method resolution.

## Interview-style answer
When multiple interfaces provide the same default method, Java resolves the conflict using clear rules. Class methods take priority over interface defaults, more specific interfaces take priority over parent interfaces, and if ambiguity still remains, the implementing class must override the method explicitly.