-- Ordinal groups entry/module/ABI fields for one exported binding.
-- Module and entry names are artifact metadata, never RAM addresses.
SELECT n.record_key AS node_key, n.name,
       e.ordinal AS binding_ordinal, m.value_text AS native_module,
       e.value_text AS native_entry, a.value_text AS native_abi,
       st.value_text AS native_state, e.evidence, e.evidence_key
FROM lmx_catalogue AS e
JOIN lmx_catalogue AS n ON n.record_key = e.subject_key
LEFT JOIN lmx_catalogue AS m ON m.record_kind = 'attribute'
    AND m.subject_key = e.subject_key AND m.predicate = 'native-module'
    AND m.ordinal = e.ordinal
LEFT JOIN lmx_catalogue AS a ON a.record_kind = 'attribute'
    AND a.subject_key = e.subject_key AND a.predicate = 'native-abi'
    AND a.ordinal = e.ordinal
LEFT JOIN lmx_catalogue AS st ON st.record_kind = 'attribute'
    AND st.subject_key = e.subject_key AND st.predicate = 'native-state'
    AND st.ordinal = e.ordinal
WHERE e.record_kind = 'attribute' AND e.predicate = 'native-entry'
ORDER BY n.name, e.ordinal;
