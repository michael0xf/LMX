-- Finite set reachability: UNION with a single key terminates even with cycles.
-- This reports possible impact through this compilation's resolved relations.
-- It is neither proof of breakage nor proof that omitted nodes are unaffected.
WITH RECURSIVE affected(node_key) AS (
    SELECT record_key FROM lmx_catalogue
    WHERE record_kind = 'node' AND record_key = :changed_key
    UNION
    SELECT r.subject_key
    FROM lmx_catalogue AS r JOIN affected AS a ON r.object_key = a.node_key
    WHERE r.record_kind = 'relation'
      AND r.predicate IN ('calls', 'reads', 'writes', 'uses', 'uses_type', 'depends')
      AND r.evidence = 'resolved-for-this-compilation'
)
SELECT n.record_key, n.name, n.type_name,
       'resolved-for-this-compilation' AS reachability_evidence,
       (SELECT value_text FROM lmx_catalogue WHERE record_key = '@snapshot') AS snapshot,
       (SELECT count(*) FROM lmx_catalogue
        WHERE record_kind = 'relation' AND evidence = 'dynamic-unresolved')
           AS unresolved_relations_in_snapshot,
       (SELECT value_text FROM lmx_catalogue WHERE record_kind = 'coverage'
        AND subject_key = '@snapshot' AND predicate = 'effects') AS effects_coverage
FROM affected AS a JOIN lmx_catalogue AS n ON n.record_key = a.node_key
ORDER BY n.name, n.record_key;
