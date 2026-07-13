# Java 25 Notes

## Purpose

This file is a deeper study note for Java 25.

Use it for:

- interview preparation
- revision notes
- understanding what changed from Java 21 to Java 25
- evaluating the latest LTS release
- learning which preview-era ideas became standard

## Java 25 in One Line

Java 25 is the latest LTS and standardizes several features that were still evolving after Java 21.

## Release Identity

Java 25 matters less because it changes everyday syntax as dramatically as Java 21, and more because it stabilizes several language and runtime directions that were emerging in Java 22 to 24.

Think of it as:

- maturity
- standardization
- runtime polish
- cleaner ergonomics

GA date:

- Java 25 reached General Availability on 2025-09-16

## Compared With Java 21

### Newly added as standard features

- scoped values
- Key Derivation Function API
- module import declarations
- compact source files and instance main methods
- flexible constructor bodies
- compact object headers
- generational Shenandoah

### Still preview or experimental in Java 25

- structured concurrency fifth preview
- primitive types in patterns, `instanceof`, and `switch` third preview
- Stable Values preview
- PEM encodings of cryptographic objects preview
- some JFR and Ahead-of-Time related features are experimental or runtime oriented

### Removed, deprecated, or newly restricted

- 32-bit x86 port removed
- by this stage, Security Manager is no longer part of a modern usage strategy

### Modified behavior and platform changes

- context-sharing direction improves through scoped values
- modular source usage becomes simpler with module import declarations
- lightweight source files become easier for demos and teaching
- constructor initialization becomes more flexible
- runtime memory footprint and GC options continue improving

## Most Important New Standard Features

### Scoped values

Why it matters:

- cleaner context propagation
- useful with modern concurrency
- better fit than heavy thread-local usage in some designs

Conceptually:

- Java 21 introduced the idea in preview
- Java 25 makes it standard

Why it matters in real systems:

- request context, correlation context, and operation-scoped data often need safe propagation
- thread-local-heavy code becomes harder to reason about in modern concurrent designs

How to think about it:

- context should belong to an execution scope
- not every piece of context should be mutable global thread state

### Module import declarations

Why it matters:

- simplifies source-level module use
- makes modular programming easier to write and read

Why you should care even if your app is not fully modular:

- it shows Java continues to improve module ergonomics
- it reduces source noise around modular code

### Compact source files and instance main methods

Why it matters:

- simpler beginner programs
- less boilerplate for tiny tools and demos
- better teaching ergonomics

Why advanced teams may still care:

- faster prototyping
- cleaner tiny examples and internal tooling

### Flexible constructor bodies

Why it matters:

- cleaner constructor logic
- easier initialization flow than older constructor restrictions

Conceptual benefit:

- constructor code can be expressed more naturally
- fewer awkward workarounds during initialization

### Compact object headers

Why it matters:

- potential memory savings
- more relevant to runtime tuning than day-to-day business logic

Why platform engineers care:

- memory footprint matters at scale
- runtime efficiency improvements are valuable even when syntax does not change much

### Generational Shenandoah

Why it matters:

- improved GC options in low-pause environments
- shows continued GC maturity beyond just application syntax changes

## Old Style vs Java 25 Direction

### Thread-local-heavy thinking vs scoped values

Older style:

- context often stored with `ThreadLocal`
- awkward in structured and modern concurrent flows
- easy to misuse or leak context

Java 25 direction:

- scoped values are the cleaner modern model for some context propagation scenarios
- context becomes more execution-scope oriented

### More boilerplate main class vs compact source

Older style:

```java
public class HelloWorld {
    public static void main(String[] args) {
        System.out.println("Hello");
    }
}
```

Java 25 direction:

- small source-file ergonomics are much lighter
- especially useful for learning and tiny scripts

### Older constructor constraints vs flexible constructor bodies

Older direction:

- constructor code often had to work around stricter structure rules

Java 25 direction:

- initialization logic is more natural and expressive

## Important Conceptual Changes Since Java 21

### Scoped values matured

In Java 21:

- preview

In Java 25:

- standard

Why this matters:

- it signals a stronger official direction for context propagation in modern Java

### Language ergonomics matured

From Java 21 to Java 25:

- source-level simplification features became more solid
- constructor flexibility improved
- modular code ergonomics improved

### Runtime improvements matter more in this release

Compared with Java 21:

- some of the most interesting gains are in runtime behavior, memory footprint, GC, and tooling maturity

## What To Learn Deeply

- scoped values
- module import declarations
- compact source files and instance main methods
- flexible constructor bodies
- compact object headers at a conceptual level
- how Java 25 differs from Java 21 in maturity

## Interview Questions To Expect

- Why would a team choose Java 25 over Java 21?
- What are scoped values?
- How do scoped values differ in intent from thread-local usage?
- What new standard language features arrived by Java 25?
- Which Java 25 features are standard vs still preview?
- Is Java 25 mostly a language release or also a runtime maturity release?

## Migration Notes

If you move from Java 21 to Java 25:

- check ecosystem readiness first
- decide whether the new standard features solve real project problems
- evaluate runtime behavior and footprint improvements
- keep preview-feature use deliberate and controlled
- test startup, observability, and GC behavior under your workload

## Common Pitfalls

- assuming Java 25 is only a minor follow-up to Java 21
- ignoring the importance of scoped values in modern concurrency design
- over-adopting preview features without clear need
- forgetting that runtime improvements may be the real reason to upgrade

## Practice Topics

- explain scoped values compared to `ThreadLocal`
- identify which Java 25 features are standard vs preview
- explain why a team might stay on Java 21 or move to Java 25
- summarize how Java 21 and Java 25 differ in practical value

## Deeper Notes on Choosing Java 21 vs Java 25

### When Java 21 may still be enough

Stay on Java 21 when:

- your ecosystem is already stable there
- virtual threads were the main feature you wanted
- newer Java 25 standardizations do not yet bring enough business value

### When Java 25 becomes attractive

Move to Java 25 when:

- you want the newest LTS baseline
- scoped values help your concurrency model
- you want newer standard language ergonomics
- you care about the newer runtime and footprint improvements

The practical question is usually not:

- "Is Java 25 newer?"

It is:

- "Does Java 25 solve meaningful problems for our codebase and platform?"

## Deeper Notes on Scoped Values

### Why teams care

Thread-local state is easy to start with but often hard to reason about at scale.

Problems with thread-local-heavy designs:

- hidden context flow
- accidental leaks
- coupling between execution model and state propagation

Scoped values offer a cleaner direction because:

- data is tied to execution scope
- context propagation becomes more intentional
- it fits better with structured concurrent design

### Conceptual comparison

`ThreadLocal` thinking:

- attach mutable context to a thread

Scoped-values thinking:

- bind context to a scoped execution region

This is an architectural shift, not just a syntax detail.

## Standard vs Preview Discipline

Java 25 is a good version for learning the difference between:

- features ready for normal production adoption
- features still evolving

Why this matters:

- teams should not mix "available in the JDK" with "stable adoption candidate"

Good production habit:

- standard features can enter general guidelines sooner
- preview features should be isolated, deliberate, and justified

## Runtime and Operations Perspective

Java 25 is not only interesting to application developers.

It also matters to:

- platform teams
- SREs
- performance engineers

Why:

- compact object headers affect footprint thinking
- GC choices continue improving
- JFR and AOT-related improvements matter operationally

This is why Java 25 can be valuable even if a team is not chasing new syntax.

## Real-World Migration Checklist: Java 21 to Java 25

- confirm framework and dependency support
- identify whether scoped values would improve current context propagation
- evaluate whether Java 25-only features justify organizational change
- benchmark startup, throughput, latency, and footprint
- keep preview features separate from normal coding standards
- validate build, container, and observability tooling on Java 25

## Advanced Interview Angles

- Why can Java 25 be valuable even if Java 21 already has virtual threads?
- How do scoped values change the conversation around context propagation?
- Why should teams treat standard and preview features differently?
- Why is Java 25 partly a runtime maturity release, not only a language release?

## Old Code Structure vs New Code Structure

### Context-propagation structure

Older direction:

```java
private static final ThreadLocal<String> REQUEST_ID = new ThreadLocal<>();
```

Java 25 direction:

- scoped values are the cleaner standard model for execution-scope-oriented context sharing

### Small-program structure

Older direction:

```java
public class HelloWorld {
    public static void main(String[] args) {
        System.out.println("Hello");
    }
}
```

Java 25 direction:

- compact source files and instance main methods reduce small-program boilerplate

### Constructor-logic structure

Older direction:

- constructor code often had to work around stricter structure rules

Java 25 direction:

- flexible constructor bodies make initialization flow more natural

## Short Summary

Java 25 is mainly about:

- latest LTS maturity
- cleaner context propagation
- simpler source-level ergonomics
- continued runtime improvements

## Official References

- JDK 25: https://openjdk.org/projects/jdk/25/
- Java language changes summary: https://docs.oracle.com/en/java/javase/25/language/java-language-changes-summary.html
