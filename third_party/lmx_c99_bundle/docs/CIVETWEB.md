# CivetWeb 1.16 с Mbed TLS 3.6.7

В `vendor/civetweb` включён полный неизменённый исходный дистрибутив
стабильного **CivetWeb 1.16**, тег `v1.16`, от 10 апреля 2023 года.

- [Официальный релиз](https://github.com/civetweb/civetweb/releases/tag/v1.16).
- Commit: `d7ba35bbb649209c66e582d5a0244ba988a15159`.
- SHA-256 архива: `f0e471c1bf4e7804a6cfb41ea9d13e7d623b2bcc7bc1e2a4dd54951a24d60285`.
- Основной код: MIT, `vendor/civetweb/LICENSE.md`.
- Полный перечень исходников и хешей: `provenance/civetweb.json`.

Полный архив сохраняет и необязательные компоненты с собственными лицензиями.
Их наличие в дереве не включает их в библиотеку.

## CMake и возможности

Приложение связывается с **`LMX::civetweb`** и включает `<civetweb.h>`.
Это статическая C-библиотека; C++ wrapper и standalone server не собираются.
Группа `LMX_WITH_RUNTIME_EXTRAS` включает CivetWeb, decNumber и SLJIT.

| Возможность | Выбранное состояние |
|---|---|
| HTTP-сервер и HTTP-клиентский C API | Включены |
| HTTPS-сервер | Mbed TLS 3.6.7, `LMX_CIVETWEB_TLS=ON` |
| WebSocket | `USE_WEBSOCKET`; серверный WSS использует тот же TLS transport |
| IPv6 | `USE_IPV6` |
| Сжатие zlib | `LMX_CIVETWEB_ZLIB=ON`, общая zlib 1.4 |
| Lua, Duktape, экспериментальный HTTP/2 | Выключены |
| HTTPS/WSS-клиентский API CivetWeb | Не реализован upstream Mbed TLS backend 1.16; клиентские запросы выполняет curl |
| Проверка клиентского сертификата сервером (mTLS) | Не реализована этим backend |

Mbed TLS adapter CivetWeb 1.16 не поддерживает все параметры OpenSSL backend.
В частности, он настраивает сертификат/ключ сервера, но устанавливает
`MBEDTLS_SSL_VERIFY_NONE` для сертификата клиента. Это не отключает проверку
серверного сертификата в curl: клиент проверяет цепочку и имя отдельно.
WebSocket/IPv6 включены, однако отдельный WS/WSS-обмен и IPv6-соединение
текущими тестами не проверялись.

## Совместимость без изменения vendor

Собственный CMake CivetWeb 1.16 ориентирован на OpenSSL; наш
`cmake/CivetWeb.cmake` собирает C API непосредственно и задаёт
`USE_MBEDTLS` вместе с `NO_SSL`, как предусматривает `mod_mbedtls.inl`.
Здесь `NO_SSL` исключает legacy OpenSSL-код; транспорт Mbed TLS остаётся
включён благодаря `USE_MBEDTLS`. OpenSSL не ищется и не загружается.

`cmake/CivetWebMbedTLSCompat.cmake` создаёт копию `civetweb.c` и изменённый
`mod_mbedtls.inl` только в build-каталоге. Адаптация делает четыре изменения:

1. Явно включает заголовок версии Mbed TLS и при наличии PSA его заголовок.
2. Инициализирует PSA до запуска сервера: это нужно для TLS 1.3 в Mbed TLS 3.6.
3. Проверяет результат `mbedtls_ssl_setup()` и освобождает контекст при ошибке.
4. Убирает чтение закрытого поля `ssl->state` из диагностического вывода.

CMake проверяет ожидаемые исходные фрагменты и останавливается, если новая
версия upstream больше им не соответствует. Точный diff сохранён в
`patches/civetweb-1.16-mbedtls-3.6.patch`. Файлы `vendor/civetweb` не меняются.

## Зависимости

`LMX::mbedtls` транзитивно приносит `mbedx509`, `mbedcrypto` и внутренние
CMake-targets Mbed TLS. `LMX::zlib` используется для сжатия. Серверу нужны
системные pthreads, sockets, файловые и временные POSIX API. На некоторых
Unix-системах для времени отдельно подключается `librt`.

По умолчанию curl, CivetWeb и klib используют одну bundled zlib. Если группа
`LMX_WITH_CURL_ZLIB=OFF`, CivetWeb всё равно собирает bundled Mbed TLS, но для
сжатия требуется уже подготовленная zlib через `find_package(ZLIB)` либо
`LMX_CIVETWEB_ZLIB=OFF`. Отключение `LMX_CIVETWEB_TLS` влияет только на
сервер CivetWeb и не отключает TLS у curl.

Сборка выбранного TLS-профиля требует POSIX pthreads и намеренно останавливается
на native Windows без threading adapter. Подробнее о внутреннем составе,
лицензиях, инструментах и CA: `NETWORK_DEPENDENCIES_RU.md` и `MBEDTLS.md`.

## Проверка и потоки приложения

Чистая Release-сборка прошла на Linux x86-64 с GCC 14.2.0 и CMake 4.4.5;
C99 установлен через `C_STANDARD=99`, `C_EXTENSIONS=OFF` и
`-pedantic-errors`. `runtime.civetweb` выполняет реальный HTTP-обмен на
loopback: GET, путь/query, заголовки в обе стороны, тело ответа.

`network_https_verified_and_rejected` выполняет curl → CivetWeb запросы
по TLS 1.2 и TLS 1.3 с проверкой доверенного CA и имени localhost, проверяет
отказ с чужим CA и именем 127.0.0.1, а затем запускает восемь одновременных
клиентов. Сервер запускается до `curl_global_init()`, проверяя самостоятельную
инициализацию PSA. Все шесть тестов сетевой группы прошли; полные upstream
наборы и другие платформы не проверялись. Тестовые ключи из
`tests/tls-fixtures` публичны и предназначены только для тестов.

Callbacks CivetWeb выполняются в рабочих потоках сервера. Если LMX изменяет
своё хранилище только в одном основном потоке, HTTP-callback передаёт задание
этому потоку через очередь или другую синхронизацию приложения. Число
`num_threads=1` не превращает callback в вызов главного потока.

Перед `curl_global_cleanup()` остановите все CivetWeb-серверы: curl завершает
общий PSA crypto state. Подробности жизненного цикла приведены в `MBEDTLS.md`.

Источники: [backend 1.16](https://github.com/civetweb/civetweb/blob/v1.16/src/mod_mbedtls.inl),
[CivetWeb C API](https://github.com/civetweb/civetweb/blob/v1.16/src/civetweb.c),
[embedding](https://civetweb.github.io/civetweb/Embedding.html).
