# Зависимости сетевой группы LMX

Выбранная связка: **CivetWeb 1.16 + curl 8.23.0 + Mbed TLS 3.6.7 + zlib 1.4**.
Все её сторонние библиотечные исходники включены в `vendor/` и строятся в
общем CMake graph. Дополнительная установка OpenSSL не нужна; OpenSSL
backend в этой редакции не используется.

## Полный состав выбранного профиля

| Компонент | Источник в наборе | Роль и состояние |
|---|---|---|
| CivetWeb | `vendor/civetweb` | HTTP/HTTPS и WebSocket сервер; статическая C target `LMX::civetweb` |
| curl / libcurl | `vendor/curl` | Сетевой клиент; `LMX::curl` |
| Mbed TLS `mbedtls` | `vendor/mbedtls` | Общий TLS transport клиента и сервера |
| Mbed TLS `mbedx509` | Тот же релиз | Сертификаты X.509 |
| Mbed TLS `mbedcrypto` | Тот же релиз | Криптография, entropy/DRBG, PSA |
| Mbed TLS framework | `vendor/mbedtls/framework` | Уже включён в официальный полный релиз; инфраструктура, не runtime dependency |
| Everest / HACL* | `vendor/mbedtls/3rdparty/everest` | Исходники и CMake archive присутствуют; optional Curve25519 implementation отключён конфигурацией |
| p256-m | `vendor/mbedtls/3rdparty/p256-m` | Исходники и CMake archive присутствуют; optional PSA P-256 driver отключён конфигурацией |
| zlib | `vendor/zlib` | gzip/deflate curl, компрессия CivetWeb, также доступна klib |
| C runtime, sockets, DNS, файлы, время, OS entropy | Целевая POSIX-система и toolchain | Системные средства исполнения |
| POSIX pthreads | Целевая POSIX-система | Рабочие потоки CivetWeb, DNS curl, mutex в Mbed TLS |
| `librt` при наличии/необходимости | Целевая Unix-система | Временные API на старых runtimes |

Три основные TLS-библиотеки и два внутренних CMake archive поставляются из
одного полного архива Mbed TLS 3.6.7. В приложении используйте targets LMX:
CMake передаёт транзитивные зависимости, include paths и общую конфигурацию.
Не смешивайте другой Mbed TLS binary/config с этими заголовками.

Для TLS в этой интеграции выбран POSIX pthread adapter. На Linux x86-64
связка собрана и проверена; macOS и другие POSIX-platforms не проверены.
Native Windows требует другого threading adapter и пока отклоняется CMake.
Наличие Windows-ветвей в upstream не означает их проверки или готовности
нашего выбранного профиля.

## Не включённые опции

Не требуются OpenSSL, GnuTLS, wolfSSL, Rustls, Lua, Duktape, SQLite, Check,
Brotli, Zstandard, c-ares, libssh/libssh2, libidn2/libpsl, LDAP, GSSAPI/GSASL,
libuv, nghttp2/ngtcp2/quiche и другие отключённые опции. Полные vendor-деревья
сохраняют документацию и исходники некоторых необязательных компонентов;
это не включает их в итоговый бинарник.

У CivetWeb 1.16 Mbed TLS backend не реализованы HTTPS/WSS client API и
server mTLS. Сетевые клиентские запросы выполняет curl. Включённые WS/WSS
server и IPv6 не проверялись отдельным протокольным тестом.

## Инструменты сборки

Для выбранной сетевой группы нужны C99-компилятор, linker/archiver, CMake
3.20+ и Make/Ninja. Python 3 может использоваться штатным CMake Mbed TLS
для диагностической проверки конфигурации, но не является обязательной
runtime-библиотекой. Исходники генераторов сохранены, однако `GEN_FILES=OFF`,
готовые файлы входят в релиз. Upstream-программы и собственные наборы тестов
отключены. Perl, NASM и отдельная сборка OpenSSL не требуются этому профилю.
Набор использованных средств остальных групп описан в их документации.

## Сертификаты и жизненный цикл

Серверу приложение предоставляет сертификат и закрытый ключ. Клиенту —
production-набор доверенных CA или подходящее хранилище целевой системы.
Это данные приложения, не дополнительные исходные библиотеки. Тестовые
сертификаты/ключ в `tests/tls-fixtures` публичны и не пригодны для production.

Завершайте все TLS-запросы и серверы до `curl_global_cleanup()`: в curl 8.23.0
он освобождает общий PSA crypto state. Mbed TLS собран с threading
`MBEDTLS_THREADING_C` + `MBEDTLS_THREADING_PTHREAD`; рабочие потоки CivetWeb
могут безопасно использовать общий RNG. Подробнее: `MBEDTLS.md`.

## Лицензии и проверка

CivetWeb — MIT; curl — curl license; zlib — zlib license. Mbed TLS/framework
и p256-m допускают выбор Apache-2.0 или GPL-2.0-or-later; здесь выбран
Apache-2.0. Everest использует Apache-2.0. Оригинальные тексты и notices
сохранены в исходных деревьях, включая необязательные части.

Чистая Linux x86-64 Release-сборка: 330 C translation units с
`-std=c99 -pedantic-errors`, 6/6 сетевых CTests. Среди проверок — реальный
HTTP/gzip обмен и HTTPS curl → CivetWeb: TLS 1.2/1.3, доверенный CA/имя,
отказ для чужого CA/имени, восемь параллельных клиентов. У тестового HTTPS
binary `ldd` показывает libc и loader; сторонние библиотеки связаны
статически. Это не гарантия для непроверенных ОС и конфигураций.

Первичные источники: [CivetWeb 1.16](https://github.com/civetweb/civetweb/releases/tag/v1.16),
[Mbed TLS 3.6.7](https://github.com/Mbed-TLS/mbedtls/releases/tag/mbedtls-3.6.7),
[curl 8.23.0 source](https://github.com/curl/curl/tree/curl-8_23_0),
[zlib](https://zlib.net/). Точные hashes, локальные изменения build-копии и
результаты: `provenance/`, `patches/civetweb-1.16-mbedtls-3.6.patch`,
`docs/validation/network_mbedtls_report.json`.
