#!/usr/bin/env python3
"""Host SQLite verification only. This is not an LMX runtime implementation."""
from __future__ import annotations

import json
import sqlite3
from datetime import datetime, timezone
from pathlib import Path

HERE = Path(__file__).resolve().parent
SCHEMA = HERE.parent.parent / "schema" / "catalogue.sql"
DATABASE = HERE / "sample.sqlite3"


def records(connection, sql, parameters=None):
    return [dict(row) for row in connection.execute(sql, parameters or {})]


def query(connection, name, parameters=None):
    return records(connection, (HERE / "queries" / (name + ".sql")).read_text(), parameters)


def check_case(case, actual):
    expected = case["expect"]
    if "rows" in expected:
        assert len(actual) == expected["rows"], (case, actual)
    for key, column in {
        "keys": "record_key", "callers": "caller_key", "callees": "callee_key",
        "entries": "native_entry", "tests": "test_key", "subjects": "node_key",
        "names": "field_name", "targets": "value_key", "ordinals": "ordinal",
        "realparents": "realparent_key", "facts": "record_key", "evidence": "evidence",
        "slot_kinds": "slot_kind",
    }.items():
        if key in expected:
            assert [row[column] for row in actual] == expected[key], (case, actual)
    if "snapshot" in expected:
        assert any(row["record_kind"] == "snapshot" and row["value_text"] == expected["snapshot"] for row in actual)
    if "basis" in expected:
        assert any(row["predicate"] == "basis" and row["value_text"] == expected["basis"] for row in actual)
    if "unresolved_count" in expected:
        assert all(row["unresolved_relations_in_snapshot"] == expected["unresolved_count"] for row in actual)
        assert all(row["effects_coverage"] == "partial" for row in actual)
    if "native_state" in expected:
        assert all(row["native_state"] == expected["native_state"] for row in actual)
    if "status" in expected:
        assert all(row["execution_status"] == expected["status"] for row in actual)
    if "default_lmx" in expected:
        assert any(row["predicate"] == "parameter-default" and row["payload_lmx"] == expected["default_lmx"] for row in actual)
    if "cycle" in expected:
        assert actual == [{"forward_cycle_reaches_start": expected["cycle"]}]
    if "admission_status" in expected:
        assert [row["status"] for row in actual] == [expected["admission_status"]]


def rejects(connection, label, statement):
    connection.execute("SAVEPOINT negative_case")
    try:
        connection.execute(statement)
    except sqlite3.IntegrityError as error:
        result = {"case": label, "status": "REJECTED", "sqlite_error": str(error)}
    else:
        raise AssertionError("Constraint did not reject " + label)
    finally:
        connection.execute("ROLLBACK TO negative_case")
        connection.execute("RELEASE negative_case")
    return result


def gated_rejection(connection, label, statement, issue):
    connection.execute("SAVEPOINT provider_gate")
    try:
        connection.execute(statement)
        errors = query(connection, "00_validate")
        assert any(row["issue"] == issue for row in errors), errors
        return {"case": label, "status": "REJECTED_BY_PROVIDER_GATE", "issues": errors}
    finally:
        connection.execute("ROLLBACK TO provider_gate")
        connection.execute("RELEASE provider_gate")


def publication_check(connection):
    original = list(connection.execute("SELECT * FROM lmx_catalogue ORDER BY record_key"))
    columns = [row[1] for row in connection.execute("PRAGMA table_info(lmx_catalogue)")]
    insert = "INSERT INTO lmx_catalogue (" + ",".join(columns) + ") VALUES (" + ",".join("?" for _ in columns) + ")"
    reader = sqlite3.connect(DATABASE, isolation_level=None)
    snapshot_sql = "SELECT value_text FROM lmx_catalogue WHERE record_key='@snapshot'"
    old = reader.execute(snapshot_sql).fetchone()[0]
    connection.execute("BEGIN IMMEDIATE")
    connection.execute("DELETE FROM lmx_catalogue")
    connection.execute("INSERT INTO lmx_catalogue(record_key,record_kind,predicate,value_text,evidence) VALUES('@snapshot','snapshot','active','incomplete-candidate','written')")
    assert reader.execute(snapshot_sql).fetchone()[0] == old
    assert query(connection, "00_validate")
    connection.execute("ROLLBACK")
    assert reader.execute(snapshot_sql).fetchone()[0] == old

    updated = []
    for row in original:
        values = list(row)
        if row["record_key"] == "@snapshot":
            values[columns.index("value_text")] = "fixture-snapshot-2"
        updated.append(values)
    connection.execute("BEGIN IMMEDIATE")
    connection.execute("DELETE FROM lmx_catalogue")
    connection.executemany(insert, updated)
    assert not query(connection, "00_validate")
    assert reader.execute(snapshot_sql).fetchone()[0] == old
    connection.execute("COMMIT")
    assert reader.execute(snapshot_sql).fetchone()[0] == "fixture-snapshot-2"
    assert query(connection, "14_admit_key", {"expected_snapshot": old, "node_key": "n:total"})[0]["status"] == "catalogue-stale"
    assert query(connection, "14_admit_key", {"expected_snapshot": "fixture-snapshot-2", "node_key": "n:total"})[0]["status"] == "ok"
    connection.execute("BEGIN IMMEDIATE")
    connection.execute("DELETE FROM lmx_catalogue")
    connection.executemany(insert, original)
    connection.execute("COMMIT")
    reader.close()
    return {
        "status": "PASS", "rollback_preserves_previous_publication": True,
        "separate_reader_sees_old_before_commit": True,
        "separate_reader_sees_new_after_commit": True,
        "old_publication_key_rejected_after_replacement": True,
        "runtime_native_atomicity": "NOT_CLAIMED",
    }


def main():
    assert sqlite3.sqlite_version_info >= (3, 37, 0), sqlite3.sqlite_version
    if DATABASE.exists():
        DATABASE.unlink()
    connection = sqlite3.connect(DATABASE, isolation_level=None)
    connection.row_factory = sqlite3.Row
    connection.executescript(SCHEMA.read_text())
    connection.executescript((HERE / "sample_publication.sql").read_text())
    cases = json.loads((HERE / "query_cases.json").read_text())["cases"]
    outputs = []
    for case in cases:
        actual = query(connection, case["query"], case["parameters"])
        check_case(case, actual)
        outputs.append({"query": case["query"], "parameters": case["parameters"], "status": "PASS", "rows": actual})

    negatives = [
        rejects(connection, "duplicate-field-position", "INSERT INTO lmx_catalogue(record_key,record_kind,subject_key,predicate,object_key,ordinal,name,evidence) VALUES('bad:slot','field','n:shared','field','n:value3',0,'other','graph-observed')"),
        rejects(connection, "second-realparent", "INSERT INTO lmx_catalogue(record_key,record_kind,subject_key,predicate,object_key,evidence) VALUES('bad:parent','relation','n:shared','realparent','n:values','graph-observed')"),
        rejects(connection, "invalid-ordinal-type", "UPDATE lmx_catalogue SET ordinal='not-an-integer' WHERE record_key='f:shared:0'"),
        rejects(connection, "unknown-evidence-label", "UPDATE lmx_catalogue SET evidence='assumed-proven' WHERE record_key='r:total-dynamic'"),
        rejects(connection, "dynamic-target-presented-as-resolved", "UPDATE lmx_catalogue SET object_key='n:reduce' WHERE record_key='r:total-dynamic'"),
        rejects(connection, "invalid-basis", "UPDATE lmx_catalogue SET value_text='latest' WHERE record_key='meta:basis'"),
        rejects(connection, "null-coverage", "UPDATE lmx_catalogue SET value_text=NULL WHERE record_key='coverage:effects'"),
        rejects(connection, "unmarked-null-slot", "UPDATE lmx_catalogue SET value_text=NULL WHERE record_key='f:shared:3'"),
        gated_rejection(connection, "dangling-target", "UPDATE lmx_catalogue SET object_key='missing:node' WHERE record_key='r:total-reduce'", "dangling-object"),
        gated_rejection(connection, "invented-full-toLmx-capture", "UPDATE lmx_catalogue SET value_text='complete' WHERE record_key='coverage:runtime-lmx'", "complete-lmx-without-payload"),
    ]
    publication = publication_check(connection)
    assert connection.execute("PRAGMA integrity_check").fetchone()[0] == "ok"
    main_tables = [row[0] for row in connection.execute("SELECT name FROM sqlite_schema WHERE type='table' ORDER BY name")]
    assert main_tables == ["lmx_catalogue"], main_tables

    optional = sqlite3.connect(":memory:", isolation_level=None)
    optional.row_factory = sqlite3.Row
    optional.executescript(SCHEMA.read_text())
    optional.executescript((HERE / "sample_publication.sql").read_text())
    try:
        optional.executescript((HERE / "optional_fts5.sql").read_text())
        fts_rows = records(optional, "SELECT record_key FROM lmx_catalogue_fts WHERE lmx_catalogue_fts MATCH :query ORDER BY rank,record_key", {"query": "последовательности"})
        assert fts_rows == [{"record_key": "doc:total"}], fts_rows
        fts = {"host_status": "PASS", "runtime_provider_status": "NOT_IMPLEMENTED_BY_THIS_FIXTURE", "rows": fts_rows}
    except sqlite3.OperationalError as error:
        if "no such module: fts5" not in str(error).lower():
            raise
        fts = {"host_status": "UNAVAILABLE", "reason": str(error)}
    optional.close()
    receipt = {
        "status": "PASS", "checked_at_utc": datetime.now(timezone.utc).isoformat(),
        "engine": "SQLite via Python sqlite3 host binding", "sqlite_version": sqlite3.sqlite_version,
        "database": "sample.sqlite3", "main_tables": main_tables,
        "fact_count": connection.execute("SELECT count(*) FROM lmx_catalogue").fetchone()[0],
        "query_cases_passed": len(outputs), "negative_cases_passed": len(negatives),
        "negative_cases": negatives, "publication_atomicity": publication,
        "fts5_optional": fts, "integrity_check": "ok",
        "LMX_compiler_execution": "NOT_RUN", "kernel_toLmx_capture": "NOT_RUN",
        "endturn_integration": "NOT_IMPLEMENTED_BY_THIS_FIXTURE",
    }
    (HERE / "query_results.json").write_text(json.dumps(outputs, ensure_ascii=False, indent=2) + "\n")
    (HERE / "validation_receipt.json").write_text(json.dumps(receipt, ensure_ascii=False, indent=2) + "\n")
    connection.close()
    print(json.dumps({key: receipt[key] for key in ("status", "sqlite_version", "fact_count", "query_cases_passed", "negative_cases_passed", "integrity_check")}, ensure_ascii=False))


if __name__ == "__main__":
    main()
