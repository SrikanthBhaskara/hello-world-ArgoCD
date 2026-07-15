# Solr Deep Notes

Solr is a search platform built on Lucene and is commonly used for full-text search, faceting, filtering, and relevance-based query systems.

---

## 1. When Solr Fits Well

Solr is useful when:

- full-text search matters
- ranking and relevance matter
- faceting and filtering matter
- large searchable indexes are needed

It is usually not the source-of-truth transactional database.

---

## 2. Indexing Concepts

Common topics:

- documents
- fields
- schema
- analyzers
- tokenization
- indexing pipeline

### Strong answer

Search quality depends heavily on schema design and analyzer choice, not only on storing documents in Solr.

---

## 3. Querying Concepts

Common query features:

- keyword search
- phrase search
- filters
- boosting
- sorting
- faceting

### Important distinction

Search query behavior is often very different from transactional exact-match database queries.

---

## 4. Solr Schema and Analyzers

An analyzer decides how text is processed for indexing and querying.

Examples:

- lowercasing
- stemming
- stop-word removal
- token splitting

### Interview point

If search quality is poor, the issue may be analyzer design rather than cluster size or hardware.

---

## 5. Operational Considerations

Senior answers may mention:

- index size
- commit behavior
- replication
- shard layout
- reindex strategy
- source-of-truth synchronization

---

## 6. Common Production Problems

- stale or incomplete indexing
- poor schema design
- weak analyzer choices
- slow queries from bad filters or faceting patterns
- inconsistency between source database and search index

---

## 7. Strong Interview Angle

Solr should be described as a complementary search system. Good answers explain how it integrates with source data, how indexing lag is handled, and how reindexing or schema changes are performed safely.
