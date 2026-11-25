# curl 8.23.0 и zlib 1.4

В `vendor/curl` и `vendor/zlib` сохранены полные неизменённые исходные
релизные архивы. Общая CMake-сборка создаёт статические библиотеки;
upstream-примеры, документация и собственные наборы тестов автоматически
не компилируются. URL, SHA-256 и исходная проверка находятся в
`provenance/curl.json` и `provenance/zlib.json`.

| Библиотека | Релиз | Первичный источник | Лицензия |
|---|---|---|---|
| curl / libcurl | 8.23.0, 2026-10-14 | [curl releases](https://curl.se/docs/versions.html) | curl, `vendor/curl/COPYING` |
| zlib | 1.4, 2026-11-04 | [zlib](https://zlib.net/) | zlib, `vendor/zlib/LICENSE` |

## Подключение

```cmake
add_subdirectory(path/to/lmx_c99_bundle lmx-libs)
target_link_libraries(my_app PRIVATE LMX::curl LMX::zlib)
```

`LMX::curl` приносит общий Mbed TLS 3.6.7 и bundled zlib. Заголовки приложения:
`<curl/curl.h>` и `<zlib.h>`. Группа включается через `LMX_WITH_CURL_ZLIB=ON`.
`LMX::zlib` и стандартная target `ZLIB::ZLIB` направлены на один `zlibstatic`.

## TLS и сетевые возможности

Единственный выбранный TLS backend — **Mbed TLS 3.6.7** из `vendor/mbedtls`.
Он статически собирается в том же CMake graph и используется CivetWeb.
OpenSSL, Schannel и другие TLS backends отключены. Полный профиль требует
POSIX pthreads; native Windows в этой редакции нашего адаптера не поддержан.

Поддержка HTTP/HTTPS, HTTP proxy, HTTP/1.1, Unix sockets, IPv6 и встроенных
протоколов curl сохранена. HTTP gzip/deflate включён через zlib. В частности,
`curl_version()` проверенной сборки возвращает:

```text
libcurl/8.23.0 mbedTLS/3.6.7 zlib/1.4
```

Отключены дополнительные зависимости: c-ares, libpsl/libidn2, libssh/libssh2,
LDAP/LDAPS, GSSAPI/GSASL, libuv, Brotli, Zstandard, nghttp2/ngtcp2/quiche,
OpenSSL QUIC и другие опции HTTP/3. Это означает отсутствие соответствующих
возможностей, например HTTP/2, HTTP/3 и SFTP. Список протоколов/возможностей
фактической конфигурации записан в validation report. В частности, DNS
работает через штатный threaded resolver и системные функции.

Доверенные корни CA выбирает приложение: `CURL_CA_BUNDLE`/`CURL_CA_PATH` при
конфигурации либо `CURLOPT_CAINFO`/`CURLOPT_CAPATH` при исполнении. В проверенной
Linux-среде CMake обнаружил системный CA bundle. Его путь не является
переносимой частью приложения. В коллекцию не включён production CA bundle;
тестовый CA используется только в локальном HTTPS-тесте.

## Как подключены библиотеки, ещё не построенные при configure

Модуль `cmake/CURL_ZLIB.cmake` передаёт finder curl заголовки Mbed TLS и уже
объявленные CMake-targets `mbedtls`, `mbedx509`, `mbedcrypto`. Поэтому не нужны
предварительная установка TLS-библиотеки и путь к системному префиксу.

Единственная Mbed TLS link-проба curl проверяет наличие DES API для NTLM.
Она заменена компиляцией проверки конфигурации/объявления в static object;
затем реальный crypto known-answer test проверяет связывание и результат DES.
Так configure не пытается связать ещё не построенные архивы.

Для zlib поиск внешней библиотеки в пробах curl отключён, а реальный target
`libcurl_static` получает `HAVE_LIBZ=1` и зависимость на bundled `zlibstatic`.
Значение `#undef HAVE_LIBZ` в сгенерированном header закомментировано и не
отменяет compile definition. Строка списка Features, напечатанная upstream
curl до добавления этой зависимости, может не содержать libz: runtime-тест
проверяет фактическую версию zlib и автоматическую распаковку gzip.
Upstream-код и generated headers не редактируются.

## Результаты проверки

На Linux x86-64, GCC 14.2.0, CMake 4.4.5, Ninja, Release с чистого cache
собраны 195 C translation units curl и 15 zlib. Все compile commands используют
`-std=c99 -pedantic-errors`; режимы C11/GNU99 не включались.

Пройдены `zlib_roundtrip`, `curl_version_and_url`, `curl_local_http_gzip`.
Совместный `network_https_verified_and_rejected` также проверил TLS 1.2/1.3,
цепочку/имя сервера, отказы при чужом CA и неправильном имени и параллельные
запросы. Всего шесть сетевых тестов прошли. Проверенный HTTPS executable
динамически зависит только от libc и loader; curl, zlib и Mbed TLS связаны
статически. Полностью статическая libc этим не обещается.

Полные upstream test suites, macOS, native Windows, ARM64 и 32-bit не проверены.
Полный отчёт: `docs/validation/network_mbedtls_report.json`.
Глобальное завершение curl должно происходить после остановки всех других
пользователей Mbed TLS, включая серверы CivetWeb: см. `MBEDTLS.md`.
