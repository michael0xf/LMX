-- Keep evidence visible: observed calls are not silently promoted to static proof.
SELECT r.record_key AS fact_key, r.subject_key AS caller_key, caller.name AS caller,
       r.object_key AS callee_key, callee.name AS callee,
       r.evidence, r.evidence_key, r.value_text AS reason
FROM lmx_catalogue AS r
JOIN lmx_catalogue AS caller ON caller.record_key = r.subject_key
JOIN lmx_catalogue AS callee ON callee.record_key = r.object_key
WHERE r.record_kind = 'relation' AND r.predicate = 'calls'
  AND r.object_key = :callee_key
ORDER BY r.evidence, caller.name, r.record_key;
