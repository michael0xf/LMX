#include <stdio.h>
#include <string.h>
#include <curl/curl.h>

#define CHECK(x) do { if (!(x)) { fprintf(stderr, "%s:%d: %s\n", __FILE__, __LINE__, #x); return 1; } } while (0)

int main(void)
{
    const curl_version_info_data *version;
    const char *const *protocol;
    CURLU *url;
    char *part = NULL;
    int http = 0, https = 0;
    CHECK(curl_global_init(CURL_GLOBAL_DEFAULT) == CURLE_OK);
    version = curl_version_info(CURLVERSION_NOW);
    CHECK(version != NULL);
    CHECK(strcmp(version->version, "8.23.0") == 0);
    CHECK(version->features & CURL_VERSION_SSL);
    CHECK(version->features & CURL_VERSION_LIBZ);
    CHECK(version->ssl_version != NULL);
    CHECK(strstr(version->ssl_version, "mbedTLS/3.6.7") != NULL);
    CHECK(version->libz_version != NULL && strcmp(version->libz_version, "1.4") == 0);
    for (protocol = version->protocols; *protocol; ++protocol) {
        if (!strcmp(*protocol, "http")) http = 1;
        if (!strcmp(*protocol, "https")) https = 1;
    }
    CHECK(http && https);
    url = curl_url();
    CHECK(url != NULL);
    CHECK(curl_url_set(url, CURLUPART_URL, "https://example.invalid/lmx/path?value=7", 0) == CURLUE_OK);
    CHECK(curl_url_get(url, CURLUPART_PATH, &part, 0) == CURLUE_OK);
    CHECK(strcmp(part, "/lmx/path") == 0);
    curl_free(part);
    curl_url_cleanup(url);
    printf("%s\n", curl_version());
    curl_global_cleanup();
    return 0;
}
