-- Declared test association is not a passing execution result.
WITH RECURSIVE affected(node_key) AS (
    SELECT record_key FROM lmx_catalogue
    WHERE record_kind = 'node' AND record_key = :changed_key
    UNION
    SELECT r.subject_key FROM lmx_catalogue AS r
    JOIN affected AS a ON r.object_key = a.node_key
    WHERE r.record_kind = 'relation'
      AND r.predicate IN ('calls', 'reads', 'writes', 'uses', 'uses_type', 'depends')
      AND r.evidence = 'resolved-for-this-compilation'
)
SELECT DISTINCT t.record_key AS test_key, t.name AS test_name,
       r.evidence AS association_evidence, status.value_text AS execution_status,
       status.evidence AS execution_evidence
FROM affected AS a JOIN lmx_catalogue AS r ON r.subject_key = a.node_key
JOIN lmx_catalogue AS t ON t.record_key = r.object_key
LEFT JOIN lmx_catalogue AS status ON status.record_kind = 'attribute'
    AND status.subject_key = t.record_key AND status.predicate = 'test-status'
WHERE r.record_kind = 'relation' AND r.predicate = 'tested_by'
ORDER BY t.name, t.record_key;
