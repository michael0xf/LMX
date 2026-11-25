/* Static SQLite embedding; bound values are data and are never SQL syntax. */
#include "sqlite3.h"
#include <stdio.h>
#include <stdlib.h>

int main(void)
{
    sqlite3 *db = NULL;
    sqlite3_stmt *statement = NULL;
    int success = 0;
    if (sqlite3_open(":memory:", &db) != SQLITE_OK) goto cleanup;
    if (sqlite3_exec(db, "CREATE TABLE structures(name TEXT, fields INTEGER)",
            NULL, NULL, NULL) != SQLITE_OK) goto cleanup;
    if (sqlite3_prepare_v2(db, "INSERT INTO structures VALUES(?1, ?2)",
            -1, &statement, NULL) != SQLITE_OK) goto cleanup;
    if (sqlite3_bind_text(statement, 1, "my 2d example", -1, SQLITE_STATIC) != SQLITE_OK) goto cleanup;
    if (sqlite3_bind_int(statement, 2, 6) != SQLITE_OK) goto cleanup;
    if (sqlite3_step(statement) != SQLITE_DONE) goto cleanup;
    sqlite3_finalize(statement); statement = NULL;
    if (sqlite3_prepare_v2(db, "SELECT name, fields FROM structures",
            -1, &statement, NULL) != SQLITE_OK) goto cleanup;
    if (sqlite3_step(statement) != SQLITE_ROW) goto cleanup;
    printf("SQLite %s: %s has %d fields\n", sqlite3_libversion(),
        (const char *)sqlite3_column_text(statement, 0), sqlite3_column_int(statement, 1));
    if (sqlite3_step(statement) != SQLITE_DONE) goto cleanup;
    success = 1;
cleanup:
    if (!success) fprintf(stderr, "SQLite error: %s\n", db ? sqlite3_errmsg(db) : "open failed");
    if (statement) sqlite3_finalize(statement);
    if (db && sqlite3_close(db) != SQLITE_OK) success = 0;
    return success ? EXIT_SUCCESS : EXIT_FAILURE;
}
