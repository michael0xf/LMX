-- This searches a normalized display projection, not full TypeRef equivalence.
SELECT n.record_key, n.name, n.type_name, n.evidence, n.payload_lmx
FROM lmx_catalogue AS n
WHERE n.record_kind = 'node' AND n.type_name = :type_name
ORDER BY n.name, n.record_key;
