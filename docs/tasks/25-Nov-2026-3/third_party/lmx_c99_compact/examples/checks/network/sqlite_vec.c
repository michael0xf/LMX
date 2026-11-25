#include <sqlite-vec.h>
#include <math.h>
#include <stdio.h>
#include <string.h>

#define REQUIRE(x) do { if (!(x)) { fprintf(stderr, "sqlite-vec check failed at %d: %s; %s\n", __LINE__, #x, db ? sqlite3_errmsg(db) : "no db"); goto done; } } while (0)

static int scalar(sqlite3 *db, const char *sql, double expected)
{
    sqlite3_stmt *statement = NULL;
    int ok = sqlite3_prepare_v2(db, sql, -1, &statement, NULL) == SQLITE_OK;
    if (ok) ok = sqlite3_step(statement) == SQLITE_ROW
        && fabs(sqlite3_column_double(statement, 0) - expected) < 0.00001;
    if (ok) ok = sqlite3_step(statement) == SQLITE_DONE;
    if (sqlite3_finalize(statement) != SQLITE_OK) ok = 0;
    return ok;
}

int main(void)
{
    sqlite3 *db = NULL;
    sqlite3 *second = NULL;
    sqlite3_stmt *statement = NULL;
    char *message = NULL;
    float vector[16];
    float query[16] = {0};
    int result = 1;
    int row, column, rc;
    REQUIRE(sizeof(float) == 4);
    REQUIRE(sqlite3_open(":memory:", &db) == SQLITE_OK);
    /* Linking the library must not register extensions implicitly. */
    REQUIRE(sqlite3_prepare_v2(db, "SELECT vec_version()", -1, &statement, NULL) == SQLITE_ERROR);
    REQUIRE(statement == NULL);
    REQUIRE(sqlite3_vec_init(db, &message, NULL) == SQLITE_OK);
    sqlite3_free(message);
    message = NULL;
    REQUIRE(sqlite3_prepare_v2(db, "SELECT vec_version(), vec_debug()", -1, &statement, NULL) == SQLITE_OK);
    REQUIRE(sqlite3_step(statement) == SQLITE_ROW);
    REQUIRE(strcmp((const char *)sqlite3_column_text(statement, 0), SQLITE_VEC_VERSION) == 0);
#ifdef LMX_TEST_VEC_AVX
    REQUIRE(strstr((const char *)sqlite3_column_text(statement, 1), "Build flags: avx") != NULL);
#else
    REQUIRE(strstr((const char *)sqlite3_column_text(statement, 1), "Build flags: avx") == NULL);
    REQUIRE(strstr((const char *)sqlite3_column_text(statement, 1), "neon") == NULL);
#endif
    printf("SQLite %s; %s\n", sqlite3_libversion(), sqlite3_column_text(statement, 1));
    REQUIRE(sqlite3_finalize(statement) == SQLITE_OK);
    statement = NULL;
    REQUIRE(sqlite3_exec(db, "CREATE VIRTUAL TABLE vectors USING vec0(embedding float[16]);", NULL, NULL, &message) == SQLITE_OK);
    REQUIRE(sqlite3_prepare_v2(db, "INSERT INTO vectors(rowid, embedding) VALUES (?1, ?2)", -1, &statement, NULL) == SQLITE_OK);
    for (row = 1; row <= 3; ++row) {
        for (column = 0; column < 16; ++column) vector[column] = (float)(row - 1);
        REQUIRE(sqlite3_bind_int(statement, 1, row) == SQLITE_OK);
        REQUIRE(sqlite3_bind_blob(statement, 2, vector, (int)sizeof(vector), SQLITE_TRANSIENT) == SQLITE_OK);
        REQUIRE(sqlite3_step(statement) == SQLITE_DONE);
        REQUIRE(sqlite3_reset(statement) == SQLITE_OK);
    }
    REQUIRE(sqlite3_finalize(statement) == SQLITE_OK);
    statement = NULL;
    REQUIRE(sqlite3_prepare_v2(db, "SELECT rowid, distance FROM vectors WHERE embedding MATCH ?1 AND k=2 ORDER BY distance", -1, &statement, NULL) == SQLITE_OK);
    REQUIRE(sqlite3_bind_blob(statement, 1, query, (int)sizeof(query), SQLITE_TRANSIENT) == SQLITE_OK);
    REQUIRE(sqlite3_step(statement) == SQLITE_ROW);
    REQUIRE(sqlite3_column_int(statement, 0) == 1 && fabs(sqlite3_column_double(statement, 1)) < 0.00001);
    REQUIRE(sqlite3_step(statement) == SQLITE_ROW);
    REQUIRE(sqlite3_column_int(statement, 0) == 2 && fabs(sqlite3_column_double(statement, 1) - 4.0) < 0.00001);
    REQUIRE(sqlite3_step(statement) == SQLITE_DONE);
    REQUIRE(sqlite3_finalize(statement) == SQLITE_OK);
    statement = NULL;
    REQUIRE(scalar(db, "SELECT vec_distance_l2('[0,0,0]', '[3,4,0]')", 5.0));
    REQUIRE(scalar(db, "SELECT vec_distance_cosine('[1,0]', '[0,1]')", 1.0));
    REQUIRE(scalar(db, "SELECT sum(value) FROM vec_each(vec_bit(X'81'))", 2.0));
    rc = sqlite3_exec(db, "INSERT INTO vectors(rowid,embedding) VALUES (99,'[1,2]')", NULL, NULL, &message);
    REQUIRE(rc != SQLITE_OK && message && strstr(message, "dimension"));
    sqlite3_free(message);
    message = NULL;
    REQUIRE(scalar(db, "SELECT count(*) FROM vectors", 3.0));
    /* Registration is per connection, not a global auto-extension side effect. */
    REQUIRE(sqlite3_open(":memory:", &second) == SQLITE_OK);
    REQUIRE(sqlite3_prepare_v2(second, "SELECT vec_version()", -1, &statement, NULL) == SQLITE_ERROR);
    REQUIRE(statement == NULL);
    REQUIRE(sqlite3_close(second) == SQLITE_OK);
    second = NULL;
    REQUIRE(sqlite3_close(db) == SQLITE_OK);
    db = NULL;
    puts("sqlite-vec: explicit registration, vec0/KNN, distance, bit iteration, invalid dimensions and clean close passed");
    result = 0;
done:
    sqlite3_finalize(statement);
    sqlite3_free(message);
    if (second) sqlite3_close(second);
    if (db) sqlite3_close(db);
    return result;
}
