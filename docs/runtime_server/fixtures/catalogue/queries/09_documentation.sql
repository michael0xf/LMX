-- Baseline exact substring search; FTS is optional and separate.
SELECT t.record_key AS text_key, n.record_key AS node_key, n.name,
       t.predicate, t.value_text AS text, t.evidence
FROM lmx_catalogue AS t JOIN lmx_catalogue AS n ON n.record_key = t.subject_key
WHERE t.record_kind = 'text' AND t.predicate = 'documentation'
  AND instr(t.value_text, :term) > 0
ORDER BY n.name, t.record_key;
