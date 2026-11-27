-- Return every occurrence; never GROUP BY field name or target.
SELECT f.record_key AS occurrence_key, f.ordinal, f.name AS field_name,
       f.object_key AS value_key, v.type_name,
       CASE WHEN f.object_key IS NULL THEN f.value_text ELSE 'node' END AS slot_kind,
       rp.object_key AS realparent_key, f.evidence
FROM lmx_catalogue AS f LEFT JOIN lmx_catalogue AS v ON v.record_key = f.object_key
LEFT JOIN lmx_catalogue AS rp ON rp.record_kind = 'relation'
    AND rp.predicate = 'realparent' AND rp.subject_key = v.record_key
WHERE f.record_kind = 'field' AND f.subject_key = :owner_key
ORDER BY f.ordinal;
