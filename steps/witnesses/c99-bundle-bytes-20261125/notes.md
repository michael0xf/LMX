# Пакет C99: байты автора восстановлены, 2026-11-25

Пакет автора `third_party/lmx_c99_bundle` (коммиты `f2acd36bc` и `5bff1ac2f`) хранился не так, как говорит его
`SHA256SUMS`: при импонте корневое правило `* text=auto eol=lf` перевело 226 файлов к LF, 41 файл не попал в коммит
(их закрывали вложенные `.gitignore` поставщиков), один файл отличался байтами. По решению Sol и Astra
(`SOL-ASTRA-C99-VENDOR-BYTES-20261125-01`) восстановлены только доказанные байты; это отдельный срез импорта, он не
зависит от K5a и широкой проверки.

## Решение

Правило: в корневом `.gitattributes` — `third_party/lmx_c99_bundle/** -text`; одним атрибутом точности не получить,
байты уже изменились при импорте. Восстановить только доказанные байты; 41 отсутствующий путь добавить явно
(`git add -f` только их, сохранить executable bit); остальное не нормализовать и не перепаковывать.
`vendor/civetweb/.gitattributes` сохранить побайтно; его пять `.cmd` (`build.cmd`, `mingw.cmd`,
`test/windows.cgi.cmd`, `test/windows_fail.cgi.cmd`, `test/windows_fail_silent.cgi.cmd`) держат схему `i/lf`,
`w/crlf`, атрибут `text eol=crlf`: байты checkout дают SHA автора — схему сохранить. Для этих пяти файлов
`check_eol` (Python) и `ce_endings` (L2) проверяют `i/lf` + `w/crlf` + действующий `text eol=crlf` до пропуска;
`ce_controls`/`check_ctrl` не выключать; общий LF для кода сохраняется. Приёмка: в чистом checkout итогового коммита
все 10 955 строк `SHA256SUMS` присутствуют и совпадают; пять `.cmd` проверяются как checkout, не как blob; docs gate —
отдельный результат EOL/CTRL.

## Аудит

Два независимых разбора совпали: Astra (по `source_restore.json`) и helper (`T/c99-import-20261125/helper`), затем мой
(`c99_restore.py audit`, `CF/c99-restore-01/audit.tsv`). Строк `SHA256SUMS` — 10 955; отслеживается в пакете 10 915
файлов (в списках нет только самого `SHA256SUMS`):

| класс | строк | что сделано |
| --- | --- | --- |
| blob равен байтам автора | 10 682 | ничего |
| blob равен после LF→CRLF | 226 | байты CRLF записаны в рабочее дерево и добавлены под `-text` |
| то же, пять `.cmd` civetweb | 5 | не тронуты: blob LF, checkout CRLF (схема сохранена) |
| отсутствует | 41 | извлечены из четырёх архивов `source_archives`, `git add -f` |
| другой | 1 | `vendor/libsodium/builds/msvc/resource.rc` — из архива |

226 файлов по поставщикам: mbedtls 66, libsodium 35, decnumber 32, cquadpack 28, wavelib 22, zlib 14, mpdecimal 12,
cephes 9, libtommath 5, stb 2, `source_archives/loose` 2. 42 файла взяты без преобразования из
`libsodium-1.0.22-stable.tar.gz` (24 и `resource.rc`), `civetweb-1.16.tar.gz` (11), `mbedtls-3.6.7.tar.bz2` (4),
`wavelib-7f61bf59….tar.gz` (2); каждый сверен по SHA-256 до записи. Семь из них исполняемые по режиму архива
(`build-aux/compile`, `config.guess`, `depcomp`, `install-sh`, `missing`, `test-driver`, `configure`) — в индексе
`100755`. Все 41 отсутствующий путь закрыт вложенными `.gitignore` (`git check-ignore --no-index`): civetweb —
`*.pfx`, `VisualStudio/unit_test/*`, `fuzztest/http1/**`, `fuzztest/http1c/**`, `fuzztest/url/**`, `civetweb`;
libsodium — `aclocal.m4`, `compile`, `config.*`, `configure`, `depcomp`, `install-sh`, `ltmain.sh`, `m4/*.m4`,
`Makefile.in`, `missing`, `test-driver`; mbedtls — `Testing`; wavelib — `*.yml`.

## Что изменено

- `.gitattributes`: три строки (комментарий и правило `third_party/lmx_c99_bundle/** -text`). Действующие атрибуты
  пакета после правила: 10 151 файл `-text` (было 9242 под `text=auto eol=lf`, 276 binary по догадке git), пять `.cmd`
  — `text eol=crlf` (`git check-attr`: text set, eol crlf).
- 268 путей пакета: 41 добавлен, 227 изменён (226 к CRLF, `resource.rc`).
- `tools/check_docs.py` `check_eol`: `w/crlf` не находка, когда индекс `i/lf` и в атрибутах есть `eol=crlf` без
  `text=false`; `selfbuild/tools/docs_check_eol.lm2` `ce_record` (`offsets[7]` — слово `eol=crlf`, `offsets[8]` —
  `text=false`; массив 9) и `ce_endings` — то же правило. Проверка control-байтов не менялась. (Это правило было шире
  решения — оно допускало тройку для любого пути; сужено, см. «Уточнение gate» ниже.)
- `selfbuild/inputs.sha256`: одна строка (`tools/docs_check_eol.lm2`), манифест `eb9ec0a5…`.

## Свидетельства

**Индекс.** `c99_restore.py verify`: 10 955 из 10 955 строк равны байтам автора в индексе, пять — как checkout
(`i/lf`), плохих 0 (`CF/c99-restore-01/verify-index.txt`). Python-проверка `check_eol` и `check_ctrl` на
отслеженных 50 943 файлах: проходит.

**Инструменты.** P0 `selfbuild/tools/docs_check_eol.lm2` — `20261125-061656-edc1387f0644`. Цепочка компонентов из
рабочего дерева (стадия `CF/coder-c99-build-01`): 06:17–06:29 (build-self 0,8 мин; runtime принятым frontend
1,8 мин — `driver.o` `fe093e74` равен принятому; hosted frontend 7,0 мин; runtime им 1,9 мин, побайтно равен первой
сборке; graph 0,3 мин). Проверка документации новым tool (индекс 284) — зелёная целиком, впервые с импорта пакета:
`OK: 38 paired semantic chapters, 14 satisfies cases, both source snapshots; 29 paired grammar sections, 40 verbatim
source excerpts, 615 imported files, links, exact semantic opening; line endings LF in the index for all 50943 tracked
files (verbatim imports exempt)`; 82 из 82 проверок водителя. Контроль (индекс 285): рабочая копия обычного
отслеженного файла, переведённая к CRLF, тем же tool снова находка (`DOCS-EOL w/crlf … (working copy is not LF)`,
выход 1); файл возвращён, дерево равно HEAD. Индексы 281–283 тем же списком строк до правки: 281 находка, все в
пакете, 81 из 82 проверок.

**Чистый checkout.** Дерево индекса перед коммитом (`git write-tree`, `40f473d1a…`) выгружено командами `read-tree` и
`checkout-index` в пустой каталог (`CF/c99-restore-01/co-40f473d1a`): все 10 955 файлов на диске равны байтам
автора, пять `.cmd` — как checkout, плохих 0 (`verify-checkout-40f473d1a.txt`). Поддерево пакета в этом дереве —
`29a740d5079b…`; оно же в коммите. Самый длинный путь пакета от корня репозитория — 151 знак: обычный clone
укладывается в предел Windows без `core.longpaths`.

## Уточнение gate по аудиту Sol

Аудит Sol (`CODER-C99-DONE-20261125-01-EOL-AUDIT`): принятое в первом коммите правило допускало `i/lf` + `w/crlf` +
`text eol=crlf` для любого пути и не требовало этой тройки от самих пяти `.cmd`, если те стали `w/lf` или попали в
общий пропуск (`-text`, `i/none`). По аудиту сделано:

- исключение ограничено пятью точными путями (`C99_CMD` в `tools/check_docs.py`; `ce_five` в
  `docs_check_eol.lm2`); для всякого прочего пути исключения по атрибуту нет;
- тройка требуется от каждого из пяти до всякого пропуска: `-text`, `text=false`, `i/none`, `w/lf` или пропавший
  `eol=crlf` — находка (`a .cmd of the C99 bundle must be i/lf + w/crlf + text eol=crlf`);
- проверка control-байтов (`check_ctrl`, `ce_controls`) не менялась и по-прежнему читает эти пять файлов.

Свидетельства. Правило Python на девяти синтетических записях: пять как сейчас — 0; одна из пяти с `w/lf`, без
атрибута, под `-text`, с `i/none`, с `text=false` — по находке; обычный путь с `eol=crlf` и `w/crlf` — находка; обычный
LF — 0; обычная CRLF-копия — находка. На настоящем дереве и настоящем tool (стадия `CF/coder-gate-build-01`, tool
`coder-gate-tool01` `694a130e`, frontend `7dedade3`, runtime `fe093e74`, graph `88668fd2`; манифест 1788 `963bf8e7…`;
P0 модуля `20261125-075810-6ce9269ed0a5`): индекс 287 — зелёный целиком (50 944 отслеженных файла); контроль 1
(индекс 288) — обычный отслеженный путь с явно приписанным `text eol=crlf` и CRLF-копией снова находка (`working copy is
not LF`), правило Python — находка; контроль 2 (индекс 289) — `build.cmd` с LF-копией (`i/lf w/lf attr/text
eol=crlf`) — находка (`a .cmd of the C99 bundle must be i/lf + w/crlf + text eol=crlf`), правило Python — находка. Оба
файла возвращены (`build.cmd` — SHA автора `e144e63b6be0…`). Цепочка из рабочего дерева: 07:58–08:22.

## Границы

- 83 исходника `tests/graph` без файла ожидания и прочие долги пакета в этот срез не входят: восстановлены только
  строки `SHA256SUMS`.
- Скрипты helper (`locate.py`, `restore.py`) не применялись: `locate.py` не открывал архивы `.tar.gz`, `.tar.bz2`,
  `.tar.xz` (суффикс определялся по последнему расширению), план `restore.py` не возвращал CRLF-байты 226 файлам и не
  извлекал 42 из архивов. Применён мой `c99_restore.py` (аудит, запись, индекс, проверка, чистый checkout).

## Производители и продолжение

`CF` — `C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01`. Рабочая стадия `CF/coder-c99-build-01`.

| Назначение | Путь | SHA-256, начало |
| --- | --- | --- |
| Tool | `CF/coder-c99-build-01/coder-c99-tool01/lmxtool-tool.exe` | `5e138580` |
| Frontend | `CF/coder-c99-build-01/coder-c99-feh01/l2trans.exe` | `1335e249` |
| Runtime | `CF/coder-c99-build-01/coder-c99-rt02` (= `-rt01`), `driver.o` | `fe093e74` (`driver-observe.o` `f7eb3de9`) |
| Graph | `CF/coder-c99-build-01/coder-c99-graph02/graph_trans-prod.exe` | `cf006880` |

Манифест — 1788 входов (`eb9ec0a5…`). Протоколы — `…/tz-20261121/w21-7-c99-bytes-accept-20261125/root01` (цепочка),
`CF/c99-restore-01` (аудит, списки, проверка индекса, checkout). Следующее — широкая проверка границы этапа на
окончательном комплекте: `bootstrap quick` (G1 и G2 целиком, smoke на каждом), сравнения неподвижной точки, полный
список и полный набор фикстур графа на G2 (решение Sol `CODER-G1G2-PROCEDURE-20261125-01-PRELIM`).

## Уборка после удаления пакета автором (2026-11-25)

Автор удалил пакет из репозитория своим коммитом `f91bd6089` («third_party», 09:22:22, сделан в общем checkout):
все 10 956 отслеживаемых путей `third_party/lmx_c99_bundle` и ничего больше; папки нет и в рабочем дереве. Записи
выше — историческое свидетельство восстановления на `02e0aced0`; они не пересматриваются. Решение Sol
(`CODER-THIRDPARTY-REMOVED-20261125-01-ANSWER`): осиротевшее исключение убрать отдельным малым срезом, прочие правила
концов строк и control-байтов остаются общими; для проверки достаточно обычного docs check новым tool и одного общего
CRLF-контроля; повторные G1/G2 не нужны. Будущая работа по подключению библиотек в v3 коммитом удаления не менялась.

**Что удалено** — три файла возвращены побайтно к виду до восстановления (`6fbc30fd4`, сверено `git diff --quiet`):

- `.gitattributes`: правило `third_party/lmx_c99_bundle/** -text` с двумя строками комментария.
- `tools/check_docs.py`: множество `C99_CMD` пяти путей `.cmd` и его ветка в `check_eol`; прежний текст документации
  функции.
- `selfbuild/tools/docs_check_eol.lm2`: `ce_five`, ветка пяти путей в `ce_endings`, два смещения атрибутов (`eol=crlf`,
  `text=false`) в `ce_record`; массив смещений снова из 7.

**Свидетельства.** Расписка до правки на исходниках после удаления — docs check индекс 291 (д7, 10:32) зелёный.
Python-правило: `python tools/check_docs.py` зелёный (39 999 отслеживаемых файлов); общий CRLF-контроль — CRLF-копия
обычного отслеживаемого файла (`to_lmx_uds.md`, `i/lf` + `w/crlf`) даёт находку `w/crlf … (a tool or editor wrote CRLF
into the working tree)`, выход 1; файл восстановлен. L2-проверка новым tool: docs check индекс 292 зелёный; тот же
контроль — индекс 293: `DOCS-EOL w/crlf to_lmx_uds.md (working copy is not LF)`, `DOCS-EOL failed: 1 findings`, выход 1;
файл восстановлен. P0 `docs_check_eol.lm2` — `20261125-110705-7d5922553731`.

**Цепочка компонентов** (стадия `CF/coder-c99x-build-01`, копия стадии д7 с тремя изменёнными файлами дерева;
10:40–11:06): build-self 1,3 мин; runtime принятым frontend 2,7 мин (`1d5fe501` / `a53dbeba` — ядро не менялось);
hosted frontend 17,4 мин; runtime им 3,9 мин — побайтно равен первой сборке; graph 0,4 мин. Манифест — 1788 входов
(`56e59d02…`), сверен с репозиторием и со стадией. Наборы строк не запускались: менялось только правило docs check
внутри инструмента; ядро — тот же объект (`driver.o` комплекта д7), а runtime, собранный новым frontend, побайтно равен
собранному принятым frontend.

| Назначение | Путь | SHA-256, начало |
| --- | --- | --- |
| Tool | `CF/coder-c99x-build-01/coder-c99x-tool01/lmxtool-tool.exe` | `18a6d125` |
| Frontend | `CF/coder-c99x-build-01/coder-c99x-feh01/l2trans.exe` | `c107730c` |
| Runtime | `CF/coder-c99x-build-01/coder-c99x-rt02` (= `-rt01`), `driver.o` | `1d5fe501` (`driver-observe.o` `a53dbeba`) |
| Graph | `CF/coder-c99x-build-01/coder-c99x-graph02/graph_trans-prod.exe` | `776bf676` |

Протоколы — `CF/c99x-01/chain01`.

**Состояние main после измерений.** Пока шла цепочка, автор добавил в репозиторий новый пакет: коммиты `443350e0e`
(«third_party_C99», 11:10:19) и `538c7511d` («third_party», 11:12:35) — `third_party/lmx_c99_compact`, 4 543
отслеживаемых пути, других изменений нет. На дереве с ним docs check красен по общему правилу, не из-за этой уборки:
четыре находки `i/-text` — бинарные файлы пакета без явного атрибута `-text`
(`extensions/postgresql/prebuilt/windows-x86_64/bin/libpq.dll`, `…/lib/libpq.dll.a`,
`prebuilt/windows-x86_64/runtime/libwinpthread-1.dll`, `vendor/postgresql/src/port/win32.ico`); текстовые файлы пакета
в индексе LF. Атрибут для нового пакета и сверка его байтов с архивом автора (отчёт пакета называет архив
`LMX_C99_collection_compact_2026-11-25.tar.gz`, SHA-256 `b3cc7cff…`, 4 563 файла против 4 543 в репозитории) — отдельный
вопрос Sol (`CODER-THIRDPARTY-COMPACT-20261125-01`); коммит уборки это состояние не меняет.

## Новый пакет автора: атрибут четырёх бинарных файлов и исключение control-байтов (2026-11-25)

Автор продолжил работу над пакетом в общем checkout: `d901de2b9` («README.md», 11:30:57) добавил `README.md` и
`README_RU.md` пакета; `b23b7b834` («delete old tasks», 11:35:11) удалил старые пакеты документации
`docs/tasks/22-Nov-2026*` и `23-Nov-2026{,-2,-4}` — 6 568 путей; отслеживаемых файлов стало 37 977. Три точных правила
`.gitattributes` для `docs/tasks/23-Nov-2026{,-2,-4}/spec/patterns/03_domain_and_persistence/024_domain_model_comparision.md`
осиротели; по решению Sol (`CODER-D4-CTRL-DONE-20261125-01-ATTR-ANSWER`) они удалены вместе со своим комментарием, а
общий шаблон `docs/tasks/**/*.patch -text` с комментарием сохранён: он введён `f6bfe9ff87` как общее правило (патчи
пакетов автора хранятся побайтно со своими концами строк), и `b23b7b834` удалил лишь старые снимки, не меняя формат
будущего импорта; совпадений шаблона в HEAD сейчас нет, `git check-attr` для любого `.patch` под `docs/tasks` даёт
`text: unset`. Проверка: `python tools/check_docs.py` зелёный; сборка не требуется.

**Четыре бинарных файла** (решение Sol `CODER-THIRDPARTY-COMPACT-20261125-01-ANSWER`): только `.gitattributes`, четыре
точных пути помечены `-text` ровно — `libpq.dll`, `libpq.dll.a`, `libwinpthread-1.dll`, `win32.ico`; заголовки
проверены: обе DLL с `MZ`, архив `ar`, заголовок ICO; `git check-attr` — `text: unset`; `ls-files --eol` —
`i/-text w/-text attr/-text`; объекты те же. Для всего пакета `-text` не нужен: тексты — под обычным контролем. Коммит
`73ba211e3`. Сверка с архивом автора ведётся отдельно, когда архив доступен.

**Control-байты.** После этого правило control-байтов давало 145 находок в 70 сторонних исходниках пакета: 131 байт
0x0C — пагинация Cephes (66 файлов `.c` и `.h` под `vendor/cephes/`); 14 байт 0x1B — ANSI-оформление
(`vendor/libsodium/build-aux/ltmain.sh`, `vendor/libsodium/test/default/Makefile.in`); 3 байта 0x07 — литеральный FS
в awk (`vendor/libsodium/configure`, `vendor/postgresql/configure`); всего 148 байт, ни одна строка не смешивает
значения. Решение Sol (`CODER-THIRDPARTY-COMPACT-20261125-02-ASTRA-ANSWER`): исключение по паре путь + байт в
`check_ctrl` (`tools/check_docs.py`) и `ce_controls` (`selfbuild/tools/docs_check_eol.lm2`, новая функция
`ce_allowed_byte`): пропускается только названный байт на названном пути; иной байт C0 дальше в той же строке —
находка; контроль концов строк по этим текстам сохраняется; без нового атрибута, без `-text` для Cephes и скриптов,
без нормализации исходников.

**Свидетельства.** Пересобран только инструмент: стадия `CF/coder-ctrl-build-01`, tool `88275b97` (build-self 0,9 мин);
ядро, frontend и graph producer — комплект `coder-c99x`, не пересобирались. Обычный docs check: Python зелёный; L2 —
индекс 296 зелёный (37 977 отслеживаемых файлов, уже после удаления старых пакетов документации). Отрицательные
контроли — в частном клоне репозитория (`CF/ctrl-01/repo`, скрипт `ctrl_controls.py`; файлы автора в общем checkout не
трогались), каждая — находка в обеих проверках:

| Контроль | Что внесено | Python | L2 |
| --- | --- | --- | --- |
| исходное состояние | ничего | зелёный (44 545) | выход 0 |
| соседний путь вне разрешения | перевод страницы в `CMakeLists.txt` пакета | `byte 12` | `DOCS-CTRL … byte 12` |
| чужой байт C0 после разрешённого в той же строке | 0x1B сразу после перевода страницы в `bessel/i1.c` | `byte 27` | `DOCS-CTRL … byte 27` |
| иной байт на разрешённом пути | перевод страницы в `ltmain.sh` (там разрешён только 0x1B) | `byte 12` | `DOCS-CTRL … byte 12` |
| CRLF в затронутом тексте | `bessel/airy.c` переведён к CRLF | `w/crlf …` | `DOCS-EOL w/crlf …` |

P0 `docs_check_eol.lm2` — `20261125-113307-9c796da04118`. Манифест 1788 `6724c64c`. Протоколы — `CF/ctrl-01/`.
