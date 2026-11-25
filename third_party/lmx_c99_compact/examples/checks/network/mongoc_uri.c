/* Public API and selected-profile test; deliberately makes no database request. */
#include <mongoc/mongoc.h>
#include <stdio.h>
#include <string.h>

#if defined(MONGOC_ENABLE_SSL) || defined(MONGOC_ENABLE_CRYPTO) || defined(MONGOC_ENABLE_SASL)
#error "This test describes the explicit no-TLS/no-crypto/no-SASL collection profile"
#endif
#define REQUIRE(x) do { if (!(x)) { fprintf(stderr, "mongoc check failed: %s\n", #x); return 1; } } while (0)

int main(void)
{
    bson_error_t error = {0};
    mongoc_uri_t *uri;
    mongoc_uri_t *tls_uri;
    mongoc_uri_t *bad;
    mongoc_client_t *client;
    mongoc_database_t *database;
    const bson_t *compressors;
    mongoc_init();
#ifdef MONGOC_ENABLE_COMPRESSION_ZSTD
    uri = mongoc_uri_new_with_error("mongodb://127.0.0.1:27017/lmx?appname=LMX&compressors=zlib,zstd", &error);
#else
    uri = mongoc_uri_new_with_error("mongodb://127.0.0.1:27017/lmx?appname=LMX&compressors=zlib", &error);
#endif
    REQUIRE(uri && strcmp(mongoc_uri_get_database(uri), "lmx") == 0);
    REQUIRE(strcmp(mongoc_uri_get_appname(uri), "LMX") == 0);
    compressors = mongoc_uri_get_compressors(uri);
    REQUIRE(bson_has_field(compressors, "zlib"));
#ifdef MONGOC_ENABLE_COMPRESSION_ZSTD
    REQUIRE(bson_has_field(compressors, "zstd"));
#endif
    client = mongoc_client_new_from_uri_with_error(uri, &error);
    REQUIRE(client != NULL);
    database = mongoc_client_get_database(client, "lmx");
    REQUIRE(database && strcmp(mongoc_database_get_name(database), "lmx") == 0);
    mongoc_database_destroy(database);
    mongoc_client_destroy(client);
    mongoc_uri_destroy(uri);
    tls_uri = mongoc_uri_new_with_error("mongodb://127.0.0.1:27017/?tls=true", &error);
    REQUIRE(tls_uri != NULL);
    client = mongoc_client_new_from_uri_with_error(tls_uri, &error);
    REQUIRE(client == NULL && error.domain == MONGOC_ERROR_COMMAND
        && error.code == MONGOC_ERROR_COMMAND_INVALID_ARG);
    mongoc_uri_destroy(tls_uri);
    bad = mongoc_uri_new_with_error("not-a-mongodb-uri", &error);
    REQUIRE(bad == NULL);
    printf("libmongoc %s: URI, client lifecycle, compression profile and unsupported TLS rejection passed (offline)\n",
           mongoc_get_version());
    mongoc_cleanup();
    return 0;
}
