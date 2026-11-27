-- Role/default/type payloads keep their declared order and evidence.
SELECT predicate, ordinal, name, type_name, value_text, payload_lmx,
       evidence, evidence_key
FROM lmx_catalogue
WHERE record_kind = 'attribute' AND subject_key = :callable_key
  AND predicate IN ('parameter', 'parameter-default', 'return', 'throws', 'body-role')
ORDER BY CASE predicate
    WHEN 'parameter' THEN 0 WHEN 'parameter-default' THEN 1
    WHEN 'return' THEN 2 WHEN 'throws' THEN 3 ELSE 4 END,
    ordinal, record_key;
