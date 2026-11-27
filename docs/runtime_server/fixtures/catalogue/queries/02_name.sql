-- Bind :name as TEXT. Names are case-sensitive, not runtime identifiers.
SELECT n.record_key, n.name, n.type_name, n.evidence,
       p.value_text AS snapshot
FROM lmx_catalogue AS n
CROSS JOIN lmx_catalogue AS p
WHERE n.record_kind = 'node' AND n.name = :name
  AND p.record_key = '@snapshot'
ORDER BY n.record_key;
