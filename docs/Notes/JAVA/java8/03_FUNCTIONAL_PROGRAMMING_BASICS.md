# Functional Programming Basics

## What it means in Java 8
Java 8 introduced functional programming concepts into Java, but Java is still not a pure functional language. The idea is to write some logic in terms of transformations, functions, and reduced side effects.

## Core ideas
- Behavior can be passed as input.
- Functions can be represented more compactly.
- Transformation pipelines can be expressed clearly.
- Immutability is preferred where practical.

## What changed for developers
Instead of always writing loops and state mutation manually, developers can express intent through `map`, `filter`, `reduce`, and lambda-based callbacks.

## Functional style benefits
- Less boilerplate
- Better readability for data operations
- Easier composition of behavior
- Cleaner separation between what and how

## Limits in Java
Java still has mutable state, object-oriented structure, checked exceptions, and side effects. Functional programming in Java 8 is a useful style, not a complete language identity change.

## Core functional ideas that appear in Java 8
- Passing behavior as values
- Writing transformations instead of manual mutation
- Focusing on expressions and pipelines
- Reducing unnecessary side effects where practical

## What Java did not become
Java did not become a purely functional language. It still has mutable objects, classes, inheritance, exceptions, and imperative control flow. Java 8 simply gave developers more functional tools.

## Interview point
Explain that Java 8 brought functional programming support mainly through lambdas, functional interfaces, and streams, but Java remains multi-paradigm.