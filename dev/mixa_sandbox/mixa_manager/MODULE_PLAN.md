# План модулей myxa_manager — порт из clearshell_reference/ClearShell/app/src/main/java/com/mtk/shell

## Источник
C:\Nyasha_Planet\L1\mixa_manager\clearshell_reference\com\mtk\shell\
(ClearShell.java: 15K строк, монолит с внутренними классами — НЕ разбиваем на Java, а сразу проектируем L1-модули)

## Стратегия
Каждая Java-функция/класс → `.lm1`-модуль в светлом стиле (заголовок `.h.lm1` + юнит `.lm1`).
Модули группируются по пяти пластям (ниже). Внутренние классы ClearShell.java
разбиваются на отдельные модули — это не разрушение Java, а проектирование L1 ядра,
где каждый класс становится отдельным паблишабельным модулем.

## Карта порта: Java-источник → L1-модуль

| Java источник | Логический модуль | Существующий .lm1? | Статус |
|---|---|---|---|
| ClearShell.java → `ShellButton` | mixa_shell_buttons | частично (mixa_buttons) | PORT NEEDED |
| ClearShell.java → `FirstScreen/ButtonPanel` | mixa_shell_panel | mixa_app_panel | PORT NEEDED |
| ClearShell.java → `CustomAction` | mixa_shell_action | mixa_share_action | PORT NEEDED |
| ClearShell.java → `Procedure/SetFile/Function` | mixa_shell_procedure | — | NEW |
| ClearShell.java → `Contact`, `ContactAdapter`, `AllContacts` | mixa_contacts | — | NEW |
| ClearShell.java → `FileAdapter`, `DirAdapter`, `FindAdapter` | mixa_file_browser | mixa_file_manager | PORT NEEDED |
| ClearShell.java → `Mp3Adapter`, `AudioService` | mixa_audio | mixa_audio* | PARTIAL |
| ClearShell.java → `App`, `AppAdapter`, `Apps` | mixa_apps | — | NEW |
| ClearShell.java → `TextAdapter`, `TextItem` | mixa_text_browser | — | NEW |
| ClearShell.java → `ZipAdapter`, `ZipItem` | mixa_zip_browser | — | NEW |
| ClearShell.java → `ListView0`, `ListPanel` | mixa_list_view | — | NEW |
| ClearShell.java → `SF extends SurfaceView` | mixa_surface_view | — | NEW |
| ClearShellService.java | mixa_service | — | NEW |
| AutoStartClearShell.java | mixa_autostart | — | NEW |
| AudioService.java / AudioServiceBinder.java | mixa_audio_service | mixa_audio_launch | PARTIAL |
| Files.java | mixa_files | — | NEW |
| AppPermissionsActivity.java | mixa_permissions | — | NEW |
| FSync.java | mixa_fsync | — | NEW |
| StorageList.java | mixa_storage_list | — | NEW |
| ZipList.java | mixa_zip_list | — | NEW |
| NotificationLogService.java | mixa_notifications | — | NEW |
| GenericFileProvider.java | mixa_file_provider | — | NEW |
| Mtk.java | mixa_mtk_core | — | NEW |

## Пять пластей модулей

### Пласт 1: UI shell (кнопки, панели, layout)
**Цель:** разбить ClearShell.java на независимые UI-модули. Каждый внутренний класс → модуль.

**Модули:**
- `mixa_shell_buttons.lm1` — ShellButton: набор кнопок с dispatch на CustomAction
- `mixa_shell_panel.h.lm1` + `mixa_shell_panel.lm1` — FirstScreen/ButtonPanel: layout + item management
- `mixa_shell_action.h.lm1` + `mixa_shell_action.lm1` — CustomAction/CustomButton: абстракция действия
- `mixa_shell_procedure.lm1` — Procedure/SetFile/Function: интерфейсы для операций
- `mixa_surface_view.lm1` — SF extends SurfaceView: кастомная surface (preview камеры/видео)
- `mixa_list_view.lm1` — ListView0/ListPanel: адаптер списка с LiveVector

**Существующие аналоги:** mixa_app_panel, mixa_app_window, mixa_buttons, mixa_app_controller
**Разрыв:** UI → event-driven через mixa_event_fifo + L3 Thread scheduler (без OS потоков)

### Пласт 2: Браузеры контента (файлы, текст, zip, контакты, приложения)
**Цель:** каждый браузер → self-contained модуль с Adaptером паттерном.

**Модули:**
- `mixa_file_browser.lm1` — FileAdapter/DirAdapter/FindAdapter: иерархический файловый браузер
- `mixa_text_browser.lm1` — TextAdapter/TextItem: текстовый файл вьювер
- `mixa_zip_browser.lm1` — ZipAdapter/ZipItem: zip-архив внутри файлового браузера
- `mixa_contacts.lm1` — Contact/ContactAdapter/AllContacts: телефонная книга
- `mixa_apps.lm1` — App/AppAdapter/Apps: браузер приложений
- `mixa_highlight.lm1` — поиск подсветки в текстовых файлах

**Существующие аналоги:** mixa_file_manager, mixa_selection, mixa_highlight, mixa_app_fmpanel

### Пласт 3: Медиа и сервисы
**Цель:** аудио + фоновые сервисы + автозапуск.

**Модули:**
- `mixa_audio_service.lm1` — AudioService/AudioServiceBinder: фоновое аудио
- `mixa_autostart.lm1` — AutoStartClearShell: автозапуск при загрузке
- `mixa_service.lm1` — ClearShellService: основной сервис
- `mixa_notifications.lm1` — NotificationLogService: лог уведомлений
- `mixa_permissions.lm1` — AppPermissionsActivity: запрос прав

**Существующие аналоги:** mixa_audio*, mixa_backend*

### Пласт 4: Инфраструктура (map-библиотека + утилиты)
**Цель:** перенести com/mtk/map/ как отдельный слой myxa_manager (они уже портованы, см. dev/mixa_sandbox).

**Модули (уже есть в dev/mixa_sandbox/mixa_manager/):**
- `mixa_overlay.lm1` — Overlay
- `mixa_selection.lm1` — Selection
- `mixa_draw.lm1` — Draw
- `mixa_composite.lm1` — Composite/Glyphs
- `mixa_pump.lm1` — Pump
- `mixa_event_fifo.lm1` — EventFIFO
- `mixa_event_source.lm1` — EventSource (C bridge)

**Модули mtk/map (порт из clearshell_reference/ClearShell/app/src/main/java/com/mtk/map):**

| Java источник | L1-модуль (.h.lm1 + .lm1) | Статус |
|---|---|---|
| Const.java | mtk_const | PORT DONE |
| IntArray.java | mtk_int_array | PORT DONE |
| LongArray.java | mtk_long_array | PORT DONE |
| IntEnum.java | mtk_int_enum | PORT DONE |
| Array.java | mtk_array | PORT DONE |
| Bytes.java | mtk_bytes | PORT DONE |
| Named.java | mtk_named | PORT DONE |
| Key.java | mtk_key | PORT DONE |
| HTable.java | mtk_table | PORT DONE |
| IntTable.java | mtk_int_table | PORT DONE |

Создано 10 L1-модулей (по 20 файлов: .h.lm1 + .lm1). Все файлы находятся в
`dev/mixa_sandbox/mixa_manager/`. Самосборка НЕ запускалась (по указанию).
dev/l2src_sandbox НЕ тронут. Публикация в корень `L1\mixa_manager\` не выполнялась
(запрещено до GREEN).

### Пласт 5: Core runtime (Mtk, Files, FSync, и т.д.)
**Цель:** утилиты и core-классы, не привязанные к UI.

**Модули:**
- `mixa_mtk_core.lm1` — Mtk: фабрика и core интерфейсы
- `mixa_files.lm1` — Files: работа с файловой системой
- `mixa_fsync.lm1` — FSync: фоновый поиск по файлам
- `mixa_storage_list.lm1` — StorageList: список storage-устройств
- `mixa_zip_list.lm1` — ZipList: управление zip-списками
- `mixa_file_provider.lm1` — GenericFileProvider: content provider для файлов

## Ограничения (из спеки и архитектуры)

1. **Event-driven, not callback-hell:** каждый модуль — L3 Thread с собственным mailbox. Внутри turn читается/писается в арену. Межмодульный обмен — Message через lmx_post (адрес в памяти, адреса не двигаются — спека 19.29.7).

2. **No Valued aggregates** (Lingvamyxa_spec.txt:1095, docs/L1_spec.txt:443): структуры ходятся по адресу, агрегаты не передаются по значению.

3. **Synchronization = mailbox only** (Model §30): ни одной блокировки вне admission. UI Thread, Audio Thread — все L3 Thread с собственным mailbox.

4. **No OS threads from L1 modules:** планировщик обходит объекты по turn-ам (model 29). `lmx_manager`/`lmx_thread` реализуют это без создания потоков.

5. **Адреса не двигаются** (Model §22/§23): arena-stored объекты остаются на месте. Конверты в `lmx_post` теперь через `lmx_pool` с регистрацией диапазонов.

## Порядок реализации

1. **Пласт 4** (инфраструктура) — фундамент для остальных
2. **Пласт 5** (core) — Mtk, Files, FSync
3. **Пласт 1** (UI shell) — кнопки, панели
4. **Пласт 2** (браузеры) — файлы, текст, zip, контакты
5. **Пласт 3** (медиа) — аудио/сервисы

## Связь с существующими .lm1

| Существует в корне | Переносить |
|---|---|
| mixa_app*.lm1 | частично — переименовать/дополнить |
| mixa_audio*.lm1 | частично — добавить сервис/биндер |
| mixa_file_*.lm1 | частично — расширить до браузера |
| mixa_backend_*.lm1 | частично — UI backend |

## Источники правды для реализации
- `l1src/l1trans.lm1` — язык L1
- `dev/l2src_sandbox/l2src/lmx_*.lm1` — модель L3 Thread/Message/mailbox
- `clearshell_reference/ClearShell/app/src/main/java/com/mtk/shell/*.java` — порт-источник (read-only)
- `docs/L1_spec.txt` — фактшит для писателя L1
- `Lingvamyxa_spec.txt` — спека языка L2
