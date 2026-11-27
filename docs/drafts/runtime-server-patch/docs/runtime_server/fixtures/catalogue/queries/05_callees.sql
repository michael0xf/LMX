-- LEFT JOIN preserves unresolved dynamic call sites.
SELECT r.record_key AS fact_key, r.object_key AS callee_key, callee.name AS callee,
       r.name AS call_site, r.evidence, r.evidence_key, r.value_text AS reason
FROM lmx_catalogue AS r
LEFT JOIN lmx_catalogue AS callee ON callee.record_key = r.object_key
WHERE r.record_kind = 'relation' AND r.predicate = 'calls'
  AND r.subject_key = :caller_key
ORDER BY r.ordinal, r.record_key;
