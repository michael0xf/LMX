# A narrow compatibility patch is applied only to files in the build tree.
function(lmx_civetweb_mbedtls_copy source destination)
    file(MAKE_DIRECTORY "${destination}")
    configure_file("${source}/civetweb.c" "${destination}/civetweb.c" COPYONLY)
    file(READ "${source}/mod_mbedtls.inl" _module)
    foreach(_needle IN ITEMS
        "#include \"mbedtls/ctr_drbg.h\""
        "\tDEBUG_TRACE(\"%s\", \"Initializing MbedTLS SSL\");"
        "\tmbedtls_ssl_setup(*ssl, &ssl_ctx->conf);"
        "\tDEBUG_TRACE(\"TLS connection %p accepted, state: %d\", ssl, (*ssl)->state);"
        "\tDEBUG_TRACE(\"TLS handshake rc: %d, state: %d\", rc, ssl->state);")
        string(FIND "${_module}" "${_needle}" _position)
        if(_position EQUAL -1)
            message(FATAL_ERROR "CivetWeb Mbed TLS compatibility input no longer matches the pinned 1.16 source.")
        endif()
    endforeach()
    string(REPLACE "#include \"mbedtls/ctr_drbg.h\""
        "#include \"mbedtls/version.h\"\n#include \"mbedtls/ctr_drbg.h\"\n#if defined(MBEDTLS_PSA_CRYPTO_C)\n#include \"psa/crypto.h\"\n#endif"
        _module "${_module}")
    # TLS 1.3 in 3.6 uses PSA. Initialize it even if no curl client has run yet.
    # PSA initialization is idempotent and protected by the selected threading
    # configuration. Do not free process-global PSA state while peers use it.
    string(REPLACE "\tDEBUG_TRACE(\"%s\", \"Initializing MbedTLS SSL\");"
        "\tDEBUG_TRACE(\"%s\", \"Initializing MbedTLS SSL\");\n#if defined(MBEDTLS_PSA_CRYPTO_C)\n\tif (psa_crypto_init() != PSA_SUCCESS) {\n\t\treturn -1;\n\t}\n#endif"
        _module "${_module}")
    string(REPLACE "\tmbedtls_ssl_setup(*ssl, &ssl_ctx->conf);"
        "\trc = mbedtls_ssl_setup(*ssl, &ssl_ctx->conf);\n\tif (rc != 0) {\n\t\tmbedtls_ssl_free(*ssl);\n\t\tmg_free(*ssl);\n\t\t*ssl = NULL;\n\t\treturn -1;\n\t}"
        _module "${_module}")
    # Logging must not reach into now-private Mbed TLS context members.
    string(REPLACE "\tDEBUG_TRACE(\"TLS connection %p accepted, state: %d\", ssl, (*ssl)->state);"
        "\tDEBUG_TRACE(\"TLS connection %p accepted\", ssl);" _module "${_module}")
    string(REPLACE "\tDEBUG_TRACE(\"TLS handshake rc: %d, state: %d\", rc, ssl->state);"
        "\tDEBUG_TRACE(\"TLS handshake rc: %d\", rc);" _module "${_module}")
    file(WRITE "${destination}/mod_mbedtls.inl" "${_module}")
endfunction()
