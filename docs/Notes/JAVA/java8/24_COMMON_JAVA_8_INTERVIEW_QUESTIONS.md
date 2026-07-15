# Common Java 8 Interview Questions

## Typical questions
- What are the major features introduced in Java 8?
- What is a lambda expression?
- What is a functional interface?
- Difference between `map` and `flatMap`?
- Difference between `orElse` and `orElseGet`?
- What are intermediate and terminal operations?
- When should parallel streams be avoided?
- Why is `java.time` better than old date APIs?
- What is CompletableFuture used for?

## How to answer well
- Give definition first.
- Add why the feature exists.
- Add one practical example.
- Mention one common misuse or tradeoff if relevant.

## Interview point
Strong answers connect feature, purpose, and practical engineering benefit.

## Sample strong answer shape
1. Give the definition.
2. Explain why Java 8 introduced it.
3. Give one code or real-world example.
4. Mention one misuse, limitation, or tradeoff.

## Example strong answer

### Question: What is the difference between `map` and `flatMap`?
`map` transforms each input element into exactly one output value, while `flatMap` transforms each input element into a stream or collection of values and then flattens them into a single output stream. For example, if I want to convert lines of text into one list of words, I would use `flatMap` because each line can produce multiple words.