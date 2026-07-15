# Solr Query Examples and Search Interview Notes

This note covers interview-friendly Solr query patterns and search-system concepts.

---

## 1. Basic Query

```text
q=laptop
```

This performs a basic search for the term `laptop`.

---

## 2. Fielded Search

```text
q=title:laptop
```

This searches only the `title` field.

---

## 3. Filter Query

```text
q=laptop&fq=brand:Dell
```

### Why it matters

Filter queries help narrow results efficiently and are often cached separately from the main relevance query.

---

## 4. Sorting

```text
q=laptop&sort=price asc
```

---

## 5. Faceting

```text
q=laptop&facet=true&facet.field=brand
```

Faceting is useful for e-commerce and filterable search experiences.

---

## 6. Phrase Query

```text
q=\"wireless mouse\"
```

---

## 7. Strong Solr Interview Themes

- schema design
- analyzers
- tokenization
- faceting
- boosting
- relevance tuning
- shard and replica behavior
- source-of-truth vs search index consistency
