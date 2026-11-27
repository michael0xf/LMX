-- Visible uncertainty, including why a call/effect target was not resolved.
SELECT f.record_key, f.subject_key, n.name AS subject_name,
       f.predicate, f.name AS site, f.evidence, f.value_text AS reason
FROM lmx_catalogue AS f JOIN lmx_catalogue AS n ON n.record_key = f.subject_key
WHERE f.evidence IN ('dynamic-unresolved', 'not-analysed')
ORDER BY f.subject_key, f.predicate, f.record_key;
