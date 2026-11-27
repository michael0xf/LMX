-- Run this gate and the requested key query in ONE SQLite read transaction.
-- Bind :expected_snapshot and :node_key. A returned key never grants runtime authority.
SELECT CASE
    WHEN :expected_snapshot IS NULL THEN 'catalogue-snapshot-required'
    WHEN (SELECT value_text FROM lmx_catalogue WHERE record_key = '@snapshot') IS NULL
        THEN 'catalogue-not-ready'
    WHEN :expected_snapshot <> (SELECT value_text FROM lmx_catalogue WHERE record_key = '@snapshot')
        THEN 'catalogue-stale'
    WHEN NOT EXISTS (SELECT 1 FROM lmx_catalogue
        WHERE record_kind = 'node' AND record_key = :node_key)
        THEN 'catalogue-key-not-found'
    ELSE 'ok'
    END AS status,
    (SELECT value_text FROM lmx_catalogue WHERE record_key = '@snapshot') AS snapshot,
    (SELECT value_text FROM lmx_catalogue WHERE record_kind = 'attribute'
        AND subject_key = '@snapshot' AND predicate = 'basis') AS basis;
