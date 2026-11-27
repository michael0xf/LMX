-- Follow forward containment/link edges, not the bookkeeping realparent edge.
WITH RECURSIVE reachable(node_key) AS (
    SELECT object_key FROM lmx_catalogue
    WHERE subject_key = :start_key AND object_key IS NOT NULL
      AND (record_kind = 'field' OR (record_kind = 'relation' AND predicate = 'link_target'))
    UNION
    SELECT f.object_key FROM lmx_catalogue AS f
    JOIN reachable AS r ON f.subject_key = r.node_key
    WHERE f.object_key IS NOT NULL
      AND (f.record_kind = 'field' OR (f.record_kind = 'relation' AND predicate = 'link_target'))
)
SELECT EXISTS(SELECT 1 FROM reachable WHERE node_key = :start_key)
    AS forward_cycle_reaches_start;
