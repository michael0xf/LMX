-- Publication metadata and explicit coverage; no implicit freshness claim.
SELECT record_kind, predicate, name, value_text, evidence
FROM lmx_catalogue
WHERE record_key = '@snapshot' OR subject_key = '@snapshot'
ORDER BY record_kind, predicate, ordinal, record_key;
