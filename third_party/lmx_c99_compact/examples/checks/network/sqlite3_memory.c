#include "sqlite3.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Assertions remain active in Release and all failure paths release handles. */
#define CHECK(c) do { if (!(c)) { \
    fprintf(stderr, "%s:%d: %s: %s\n", __FILE__, __LINE__, #c, \
        db ? sqlite3_errmsg(db) : "no database handle"); goto cleanup; } } while (0)
static int execute(sqlite3 *db, const char *sql)
{
    char *error = NULL;
    int rc = sqlite3_exec(db, sql, NULL, NULL, &error);
    if (rc != SQLITE_OK) fprintf(stderr, "SQL: %s\n", error ? error : sqlite3_errmsg(db));
    sqlite3_free(error);
    return rc;
}
static int finish(sqlite3_stmt **statement)
{
    sqlite3_stmt *old = *statement;
    *statement = NULL;
    return sqlite3_finalize(old);
}
int main(void)
{
    sqlite3 *db = NULL;
    sqlite3_stmt *statement = NULL;
    const char value[] = "O'Reilly, `quoted`; DROP TABLE nothing;\nUTF-8: \xD0\x9B\xD0\x9C\xD0\xA5";
    const unsigned char *read_value;
    int result = EXIT_FAILURE;
    int extension_loading = -1;

    CHECK(sqlite3_libversion_number() == SQLITE_VERSION_NUMBER);
    CHECK(strcmp(sqlite3_sourceid(), SQLITE_SOURCE_ID) == 0);
    CHECK(sqlite3_threadsafe() == 1);
    CHECK(sqlite3_compileoption_used("OMIT_LOAD_EXTENSION") == 0);
    CHECK(sqlite3_open_v2(":memory:", &db,
        SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE | SQLITE_OPEN_FULLMUTEX, NULL) == SQLITE_OK);
    CHECK(sqlite3_db_mutex(db) != NULL);
    CHECK(sqlite3_db_config(db, SQLITE_DBCONFIG_ENABLE_LOAD_EXTENSION,
        -1, &extension_loading) == SQLITE_OK);
    CHECK(extension_loading == 0);
    CHECK(execute(db, "CREATE TABLE `name, a``b` (`id` INTEGER PRIMARY KEY, "
        "`value, with spaces` TEXT NOT NULL)") == SQLITE_OK);
    CHECK(sqlite3_prepare_v2(db, "INSERT INTO `name, a``b` VALUES (?1, ?2)",
        -1, &statement, NULL) == SQLITE_OK);
    CHECK(sqlite3_bind_int(statement, 1, 1) == SQLITE_OK);
    CHECK(sqlite3_bind_text(statement, 2, value, (int)strlen(value), SQLITE_TRANSIENT) == SQLITE_OK);
    CHECK(sqlite3_step(statement) == SQLITE_DONE);
    CHECK(finish(&statement) == SQLITE_OK);

    CHECK(sqlite3_prepare_v2(db, "SELECT `value, with spaces` FROM `name, a``b` WHERE id=?1",
        -1, &statement, NULL) == SQLITE_OK);
    CHECK(sqlite3_bind_int(statement, 1, 1) == SQLITE_OK);
    CHECK(sqlite3_step(statement) == SQLITE_ROW);
    read_value = sqlite3_column_text(statement, 0);
    CHECK(read_value != NULL);
    CHECK(sqlite3_column_bytes(statement, 0) == (int)strlen(value));
    CHECK(memcmp(read_value, value, strlen(value)) == 0);
    CHECK(strcmp(sqlite3_column_name(statement, 0), "value, with spaces") == 0);
    CHECK(sqlite3_step(statement) == SQLITE_DONE);
    CHECK(finish(&statement) == SQLITE_OK);

    CHECK(execute(db, "BEGIN; INSERT INTO `name, a``b` VALUES(2, 'rolled back')") == SQLITE_OK);
    CHECK(sqlite3_get_autocommit(db) == 0);
    CHECK(execute(db, "ROLLBACK") == SQLITE_OK);
    CHECK(sqlite3_get_autocommit(db) == 1);
    CHECK(sqlite3_prepare_v2(db, "SELECT count(*), min(id), max(id) FROM `name, a``b`",
        -1, &statement, NULL) == SQLITE_OK);
    CHECK(sqlite3_step(statement) == SQLITE_ROW);
    CHECK(sqlite3_column_int(statement, 0) == 1);
    CHECK(sqlite3_column_int(statement, 1) == 1 && sqlite3_column_int(statement, 2) == 1);
    CHECK(sqlite3_step(statement) == SQLITE_DONE);
    CHECK(finish(&statement) == SQLITE_OK);

    /* A failed prepare produces no leaked statement and the connection remains usable. */
    CHECK(sqlite3_prepare_v2(db, "SELECT FROM", -1, &statement, NULL) == SQLITE_ERROR);
    CHECK(statement == NULL);
    CHECK(execute(db, "SELECT 1") == SQLITE_OK);
    result = EXIT_SUCCESS;
cleanup:
    if (statement) sqlite3_finalize(statement);
    if (db && sqlite3_close(db) != SQLITE_OK) result = EXIT_FAILURE;
    if (result == EXIT_SUCCESS) puts("SQLite prepared/bound text, quoted identifiers, rollback, and error cleanup passed");
    return result;
}
