-- OPTIONAL demonstration: adds an FTS virtual table (and SQLite shadow tables).
-- Not part of the one-main-table baseline. Requires compiled-in FTS5 support.
-- No triggers/watchers: regenerate explicitly together with a publication.
CREATE VIRTUAL TABLE lmx_catalogue_fts USING fts5(
    record_key UNINDEXED,
    name,
    body,
    tokenize = 'unicode61 remove_diacritics 0'
);

BEGIN IMMEDIATE;
DELETE FROM lmx_catalogue_fts;
INSERT INTO lmx_catalogue_fts(record_key, name, body)
SELECT record_key, coalesce(name, ''), coalesce(value_text, '')
FROM lmx_catalogue
WHERE record_kind = 'node'
   OR (record_kind = 'text' AND predicate = 'documentation');
COMMIT;

-- Application search, with :query bound as an FTS query string:
-- SELECT record_key, name, body FROM lmx_catalogue_fts
-- WHERE lmx_catalogue_fts MATCH :query ORDER BY rank, record_key;
