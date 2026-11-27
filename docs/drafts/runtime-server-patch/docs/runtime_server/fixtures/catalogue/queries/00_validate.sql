-- Must return zero rows before publication is committed.
-- This is a provider gate: the provider rolls back if any row is returned.
SELECT 'snapshot-count' AS issue, '@snapshot' AS record_key
WHERE (SELECT count(*) FROM lmx_catalogue WHERE record_kind = 'snapshot') <> 1
UNION ALL
SELECT 'dangling-subject', f.record_key
FROM lmx_catalogue AS f
LEFT JOIN lmx_catalogue AS s ON s.record_key = f.subject_key
    AND s.record_kind IN ('node', 'snapshot')
WHERE f.subject_key IS NOT NULL AND s.record_key IS NULL
UNION ALL
SELECT 'dangling-object', f.record_key
FROM lmx_catalogue AS f
LEFT JOIN lmx_catalogue AS o ON o.record_key = f.object_key AND o.record_kind = 'node'
WHERE f.object_key IS NOT NULL AND o.record_key IS NULL
UNION ALL
SELECT 'dangling-evidence', f.record_key
FROM lmx_catalogue AS f
LEFT JOIN lmx_catalogue AS e ON e.record_key = f.evidence_key
    AND e.record_kind = 'text' AND e.predicate = 'evidence'
WHERE f.evidence_key IS NOT NULL AND e.record_key IS NULL
UNION ALL
SELECT 'non-contiguous-fields', subject_key
FROM lmx_catalogue WHERE record_kind = 'field'
GROUP BY subject_key HAVING min(ordinal) <> 0 OR max(ordinal) <> count(*) - 1
UNION ALL
SELECT 'missing-coverage', p.facet
FROM (
    SELECT 'graph-topology' AS facet UNION ALL SELECT 'runtime-lmx'
    UNION ALL SELECT 'call-targets' UNION ALL SELECT 'effects'
    UNION ALL SELECT 'disk-source' UNION ALL SELECT 'tests'
) AS p
WHERE NOT EXISTS (
    SELECT 1 FROM lmx_catalogue AS f
    WHERE f.record_kind = 'coverage' AND f.subject_key = '@snapshot'
      AND f.predicate = p.facet
)
UNION ALL
SELECT 'missing-publication-metadata', p.attribute_name
FROM (
    SELECT 'basis' AS attribute_name UNION ALL SELECT 'compile-token'
    UNION ALL SELECT 'published-at' UNION ALL SELECT 'graph-root-key'
) AS p
WHERE NOT EXISTS (
    SELECT 1 FROM lmx_catalogue AS f
    WHERE f.record_kind = 'attribute' AND f.subject_key = '@snapshot'
      AND f.predicate = p.attribute_name AND f.value_text IS NOT NULL
)
UNION ALL
SELECT 'complete-lmx-without-payload', '@snapshot'
WHERE EXISTS (
    SELECT 1 FROM lmx_catalogue WHERE record_kind = 'coverage'
      AND subject_key = '@snapshot' AND predicate = 'runtime-lmx' AND value_text = 'complete'
) AND NOT EXISTS (
    SELECT 1 FROM lmx_catalogue WHERE record_kind = 'text'
      AND subject_key = '@snapshot' AND predicate = 'runtime-lmx' AND payload_lmx IS NOT NULL
)
ORDER BY issue, record_key;
