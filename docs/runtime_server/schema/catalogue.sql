-- LMX catalogue projection v0.1, 2026-11-27.
-- One active publication, one trusted L3Thread owner, one main facts table.
-- Requires SQLite >= 3.37.0 (STRICT tables).
-- No runtime addresses, native invalidation, triggers, FTS or history here.
-- A provider supplies a trusted table/index namespace for additional owners.
-- Do not concatenate an untrusted owner name into these identifiers.

CREATE TABLE lmx_catalogue (
    record_key   TEXT PRIMARY KEY,
    record_kind  TEXT NOT NULL CHECK (record_kind IN
        ('snapshot', 'node', 'field', 'relation', 'attribute', 'text', 'coverage')),
    subject_key  TEXT,
    predicate    TEXT,
    object_key   TEXT,
    ordinal      INTEGER CHECK (ordinal IS NULL OR ordinal >= 0),
    name         TEXT COLLATE BINARY,
    type_name    TEXT COLLATE BINARY,
    value_text   TEXT,
    evidence     TEXT NOT NULL CHECK (evidence IN
        ('graph-observed', 'written', 'resolved-for-this-compilation',
         'runtime-observed', 'dynamic-unresolved', 'not-analysed')),
    evidence_key TEXT,
    payload_lmx  TEXT,

    CHECK (
        (record_kind = 'snapshot' AND record_key = '@snapshot'
            AND subject_key IS NULL AND predicate IS 'active'
            AND value_text IS NOT NULL)
        OR
        (record_kind <> 'snapshot' AND record_key <> '@snapshot'
            AND subject_key IS NOT NULL)
    ),
    CHECK (record_kind <> 'node' OR
        (subject_key = record_key AND object_key IS NULL)),
    CHECK (record_kind <> 'field' OR
        (predicate IS 'field' AND ordinal IS NOT NULL AND
            ((object_key IS NOT NULL AND value_text IS NULL)
             OR (object_key IS NULL AND value_text IS 'null-slot')))),
    CHECK (record_kind NOT IN ('relation', 'attribute', 'text', 'coverage')
        OR predicate IS NOT NULL),
    CHECK (object_key IS NULL OR record_kind IN ('field', 'relation')),
    CHECK (record_kind <> 'coverage' OR (value_text IS NOT NULL AND value_text IN
        ('complete', 'partial', 'unavailable', 'not-applicable'))),
    CHECK (record_kind <> 'attribute' OR subject_key <> '@snapshot'
        OR predicate <> 'basis' OR (value_text IS NOT NULL
            AND value_text IN ('compile-input', 'post-tests-current'))),
    CHECK (evidence <> 'resolved-for-this-compilation' OR evidence_key IS NOT NULL),
    CHECK (record_kind <> 'relation' OR evidence <> 'dynamic-unresolved'
        OR object_key IS NULL)
) STRICT;

-- Same spelling and same target may occur at different positions.
CREATE UNIQUE INDEX lmx_catalogue_field_slot
    ON lmx_catalogue(subject_key, ordinal)
    WHERE record_kind = 'field';

CREATE UNIQUE INDEX lmx_catalogue_realparent
    ON lmx_catalogue(subject_key)
    WHERE record_kind = 'relation' AND predicate = 'realparent';

CREATE UNIQUE INDEX lmx_catalogue_coverage_facet
    ON lmx_catalogue(subject_key, predicate)
    WHERE record_kind = 'coverage';

CREATE UNIQUE INDEX lmx_catalogue_publication_attribute
    ON lmx_catalogue(predicate)
    WHERE record_kind = 'attribute' AND subject_key = '@snapshot';

CREATE INDEX lmx_catalogue_name
    ON lmx_catalogue(name, type_name, record_key)
    WHERE record_kind = 'node';

CREATE INDEX lmx_catalogue_type
    ON lmx_catalogue(type_name, name, record_key)
    WHERE record_kind = 'node';

CREATE INDEX lmx_catalogue_outgoing
    ON lmx_catalogue(subject_key, predicate, evidence, object_key)
    WHERE record_kind = 'relation';

CREATE INDEX lmx_catalogue_incoming
    ON lmx_catalogue(object_key, predicate, evidence, subject_key)
    WHERE record_kind = 'relation' AND object_key IS NOT NULL;

CREATE INDEX lmx_catalogue_attribute
    ON lmx_catalogue(subject_key, predicate, ordinal)
    WHERE record_kind = 'attribute';
