# mixa_shell — доведение порта ClearShell на философии Message

Для агента, который продолжает `mixa_shell.lm2`. Граф уже лежит в этом каталоге.
Этот файл — порядок работы. Норма языка — книга, глава про `post`, и
`PORT_OF_CLEARSHELL.txt` §1.1. Здесь нет новой нормы.

Сейчас граф не транслируется. Это ожидаемо: `post` в ядре ещё не ход программы,
а заголовки модулей нельзя подключать пачкой.

## 1. Философия, которую нельзя подменить реализацией

1. Модуль не есть нить и не есть Message. Несколько модулей сидят у одного
   владельца и зовут друг друга прямым вызовом. Владельцев четыре: `Shell`,
   `Files`, `Audio`, `Process`. Пятого владельца не заводить, пока нет отдельной
   полосы, которая реально живёт своей очередью.
2. Вызов через границу владельца — обычный вызов LMX. `post` только перевозит
   его. Не заводить второй API, словарь методов, массив экспорта и разбор
   подписи по почте. Текст нормы: `docs/new_parts/threadMessageAPI.ru.md`.
3. У письма один `ask` и одно назначение `answer`, если результат один.
   Несколько `answer` на один `ask` размножают уже посчитанный результат.
   Несколько `ask` в одном `post` — несколько независимых вызовов, и каждый
   результат уходит во все `answer`. Поэтому `play` не кладёт в один `post`
   и `audio\play`, и `files\read_bytes`. Чтение байтов пишет сам `Audio`.
4. M1…Mn, которые пишут в M0, кладут целую операцию в очередь M0. M0 исполняет
   её один за другим. Локов приложения, чужих указателей и второй арены на
   двоих нет. Это `PORT_OF_CLEARSHELL.txt` §1.1 и `PROCESS_SEAM.txt`.
5. Доставка передаёт уже принадлежащее хранилище и не копирует его. Копия —
   отдельная операция. Ответ `list` передаёт снимок каталога владельцу экрана.
   `Files` второй копии не держит. `Shell` не получает указатель в арену `Files`.
6. Отказ доставки — `unanswered` / `undelivered`. Не выдумывать успешный ответ
   только потому, что письмо ушло. `Shell\note_refused` — этот отказ.
7. `native` — слово Structure владельца, не поле массива. Win32 и headless —
   слово `native` у `Shell`, не пятый Message.
8. `mtk_*` и `mixa_calculator_syntax` — значения. Их не сажать на почту.
9. Три шва не склеивать. Экран — `BACKEND_SEAM.txt` (пиксели и события).
   Имена и байты — `FILE_SEAM.txt`. Процесс — `PROCESS_SEAM.txt` (запуск,
   чтение без блокировки, запись, статус, kill, close; stderr влит в stdout;
   stdin закрыт, пока в него явно не пишут). Консоль — файл, не терминал.
10. Эталон `clearshell_reference/` не править. Где шов молчит, поведение
    берётся из эталона. Где шов говорит иначе, шов старше эталона.

Ядро `post` этим портом не пишется. Пока `next_core_tasks.md` §8 не закрыт,
транспорт в ядре не начинать. Граф уже записывает письма. Трансляция
`mixa_shell.lm2` не есть цель ближайших шагов.

## 2. Почему одно приложение не собралось

Это не дыра ClearShell. Модули уже были отдельными единицами Си.

- `*_l2.h.lm1` и настоящий `.h.lm1` объявляли один тип. Совместный `predef`
  останавливался на `duplicate type name`. Журнал: `REPORT.md`, `CONVERSION.md`.
- Тело, подключённое заголовком и одновременно скомпилированное, давало на
  линковке несколько определений.
- Входов два, и ни один не владеет модулями. `mixa_app_main.lm2` крутит
  контроллер циклом Си. `mixa_app_main_msg.lm1` поднимает четыре нити на
  старом `lmx_service_post` и одной общей арене детей. Соседний модуль
  по-прежнему звался как функция Си.
- `PORT_OF_CLEARSHELL.txt` §1.1 оставил доставку письмом на потом. Модули
  росли отдельно. Склейка так и не стала графом.

`mixa_app_main*` этим шагом не удалены: это прежние входы продукта, не
корни графа. Порт их не вызывает. Со всеми `.lm1` в один бинарник их
по-прежнему не линковать.

## 3. Карта единиц, которые уже есть

Каталог `dev/mixa_sandbox/mixa_manager/`. В таблицу входят тела `.lm1`, не
заголовки и не selftest. Путь тела — тот же каталог.

### Shell — экран, одна полоса с окном

Прямые вызовы между этими файлами законны.

| Тело | Роль |
| --- | --- |
| `mixa_app_controller.lm1` | открыть / шаг / закрыть |
| `mixa_app_window.lm1` | окно |
| `mixa_app_panel.lm1` | панель кнопок |
| `mixa_app_fmpanel.lm1` | панель списка файлов |
| `mixa_app_path.lm1` | строка пути на экране |
| `mixa_buttons.lm1` | кнопки |
| `mixa_button_dispatch.lm1` | жест кнопки → операция |
| `mixa_share_button.lm1` | кнопка share |
| `mixa_share_action.lm1` | действие share до письма в Process |
| `mixa_draw.lm1` | рисование |
| `mixa_composite.lm1` | сборка кадра |
| `mixa_composite_glyphs.lm1` | глифы |
| `mixa_tiles.lm1` | клетки |
| `mixa_text_rect.lm1` | текст по клеткам |
| `mixa_palette.lm1` | цвета |
| `mixa_highlight.lm1` | подсветка уже лежащего текста |
| `mixa_pointer.lm1` | указатель |
| `mixa_selection.lm1` | отметка пользователя |
| `mixa_selection_walk.lm1` | обход отметки |
| `mixa_overlay.lm1` | слой поверх |
| `mixa_pump.lm1` | один неблокирующий съём событий за ход |
| `mixa_event_fifo.lm1` | очередь событий внутри Shell |
| `mixa_event_source.lm1` | источник событий |
| `mixa_console_window.lm1` | консоль как файл, не терминал |
| `mixa_help.lm1` | помощь |
| `mixa_cmdline.lm1` | строка, которую набрал пользователь |
| `mixa_shell_start.lm1` | единственный вход порта, `Mixa\start` |
| `mixa_shell_start_main.lm1` | `fn: main` продукта `mixa_shell_start.exe` |
| `mixa_shell_native.lm1` | слово `native`: Win32 или headless |

`mixa_backend_win32.lm1`, `mixa_backend_headless.lm1` и обе `*_ctors_*`
дают таблицу, которую `mixa_shell_native_bind` кладёт в слово `native`.
`mixa_backend_table.lm1` остаётся реестром шва. Это не пятый владелец и
не словарь методов почты. `mixa_app_win32.lm1` тоже здесь: это шов окна,
не отдельная нить.

### Files — одна очередь на имена и байты

| Тело | Роль |
| --- | --- |
| `mixa_file_manager.lm1` | каталог, снимок, вход, родитель, обновление |
| `mixa_file_win32.lm1` | шов имени на Win32 |
| `mixa_files.lm1` | операции над путями |
| `mixa_dir_win32.lm1` | перечисление каталога |
| `mixa_fileio_win32.lm1` | чтение и запись байтов |
| `mixa_copy.lm1` | копирование |
| `mixa_fm_copy.lm1` | копирование из менеджера |
| `mixa_remove.lm1` | удаление |
| `mixa_fm_remove.lm1` | удаление из менеджера |
| `mixa_remove_confirm.lm1` | решение «удалять»; вопрос рисует Shell до письма |
| `mixa_cmdline_dispatch.lm1` | разобранная строка → операция Files |

Первое тело, которое заполняется: `Files\list`. Внутри владельца это
`mixa_fm_goto` / `mixa_fm_build`. Снимок ставится только после последней
удачной аллокации. Неудача оставляет прежний каталог (`mixa_file_manager.h.lm1`).

Утечка, которую нельзя перенести в новый метод. `mixa_fm_select` зовёт
`mixa_selection_*` функцией Си. Отметка принадлежит Shell. В `Files\list` этот
вызов не копировать. Смена отметки — письмо в Shell, когда до неё дойдёт очередь.
До того жест отметки остаётся прямым вызовом внутри Shell.

### Audio

`mixa_audio.lm1`, `mixa_audio_mp3.lm1`, `mixa_audio_launch.lm1`,
`mixa_audio_scan.lm1`, `mixa_audio_panel.lm1`, `mixa_audio_button.lm1`,
`mixa_audio_win32.lm1`.

Байты файла — письмо `files\read_bytes`, его пишет `Audio\play`. Общей кучи
с Files нет. Панель и кнопка звука рисуются на Shell; состояние дорожки живёт
в Audio. Показ состояния на экране — ответ `shell\show_audio`.

### Process

`mixa_process_win32.lm1`, `mixa_process_marker.lm1`, `mixa_share.lm1`,
`mixa_share_win32.lm1`, `mixa_service.lm1`, `mixa_autostart.lm1`,
`mixa_permissions.lm1`, `mixa_notification_log.lm1`.

Отдельного `mixa_process.lm1` нет: шов процесса — `PROCESS_SEAM.txt`, тело
запуска — `mixa_process_win32.lm1`. Шесть операций шва (spawn, read, write,
status, kill, close) остаются методами этого владельца. `read` не блокирует
ход: ждать внутри чтения нельзя, очередь Message этого не видит.

### Не владельцы

`mtk_array`, `mtk_bytes`, `mtk_const`, `mtk_int_array`, `mtk_int_enum`,
`mtk_int_table`, `mtk_key`, `mtk_long_array`, `mtk_named`, `mtk_table`,
`mixa_calculator_syntax`.

`mixa_app_main.lm1` и `mixa_app_main_msg.lm1` — старые входы. Не третий и не
четвёртый корень графа.

### Ещё нет тела

Их не имитировать пустым модулем и не сажать на нового владельца.

| Эталон ClearShell | Куда ляжет тело, когда его напишут |
| --- | --- |
| ZipAdapter / ZipList | Files, письмо уже можно звать как чтение архива тем же `list` после смены корня |
| TextAdapter | Shell рисует, байты даёт `files\read_text` |
| FindAdapter / FSync | `files\find` |
| Contact / AllContacts | фоновая загрузка — отдельная полоса только когда появится тело; до того не выдумывать |
| App / Apps | список — экран Shell; запуск — `process\launch` |
| StorageList | Files, корень смены тома |
| GenericFileProvider | Files |
| редактор, короткое окно, системное меню | в эталоне это чужая библиотека; своего тела нет (`PORT_OF_CLEARSHELL.txt` §1.1) |

## 4. Письма, которые граф уже называет

Все в `Mixa`. Одно письмо — один `ask`. Отказ — `shell\note_refused`.

| Метод Mixa | Кто исполняет | Куда ответ |
| --- | --- | --- |
| `start` | `files\list` | `shell\show_rows` |
| `open_text` | `files\read_text` | `shell\show_text` |
| `play` | `audio\play` | `shell\show_audio` |
| `copy_paths` | `files\copy` | `shell\show_progress` |
| `find` | `files\find` | `shell\show_rows` |
| `launch` | `process\launch` | отказа нет отдельным ответом; недоставка — `note_refused` |
| `share` | `process\share` | то же |
| `up` | `files\up` | `shell\show_rows` |
| `refresh` | `files\refresh` | `shell\show_rows` |
| `remove` | `files\remove` | `shell\show_rows` |
| `stop` | `audio\stop` | недоставка — `note_refused` |
| `scan` | `audio\scan` | `shell\show_rows` |

`Audio\play` само пишет `files\read_bytes` и принимает байты в `have_bytes`.
Поле `Audio.files` — тот же Message, что `Mixa.files`, не второй граф файлов.
Связать поле при сборке экземпляра, не копией каталога.

Подтверждение удаления рисует Shell (`mixa_remove_confirm` как решение экрана)
до `Mixa\remove`. Письмо `files\remove` уходит уже после согласия.

## 5. Порядок для следующего агента

Брать сверху. Шаг не перепрыгивать. Один шаг — одна посадка, если она меняет
исполняемое тело. Правка только графа и этого файла почту ядра не требует.

### Шаг A. Прочитать

`mixa_shell.lm2`, этот файл, `PORT_OF_CLEARSHELL.txt` §1.1, `FILE_SEAM.txt`,
`PROCESS_SEAM.txt`, `BACKEND_SEAM.txt`, главу `post` в
`docs/new_parts/threadMessageAPI.ru.md`. Эталон смотреть и не править.

Не начинать с `build_mixa.ps1` на всех единицах.

### Шаг B. Заполнить `Files\list` — сделано

Тело: `mixa_shell_files.lm1`, `mixa_shell_files_list`. Один заголовок
`mixa_file_manager.h.lm1`. Успех переносит `entries` из `MixaFm` вызывающему.
Отказ чужого пути не меняет каталог и не подменяет уже отданный снимок.
Свидетель `tests/mixa_shell_files_selftest.lm1`: 8 проверок, 0 отказов.
Он вклеивает тело менеджера один раз и не является общим бинарником.
`mixa_fm_select` этим методом не зовётся.

### Шаг B, как он был поставлен

Вход: путь, хранилище которого принадлежит отправителю письма.

Действие внутри Files, прямым вызовом: `mixa_fm_goto`. Заголовок подключать
один. Пару `mixa_file_manager_l2.h.lm1` и `mixa_file_manager.h.lm1` вместе не
подключать.

Ответ Shell — передача снимка, без второй копии и без указателя в арену Files.
Поля снимка брать из `MixaFmEntry`, не выдумывать параллельную структуру.

Готово, когда одна маленькая программа кормит `list` каталогом и экран получает
снимок, а мутант «поставить снимок до конца аллокации» оставляет прежний
каталог. Это ещё не общий бинарник.

Не переносить вызов `mixa_selection_*` из `mixa_fm_select`.

### Шаг C. То же для `up` и `refresh` — сделано

`mixa_shell_files_up` и `mixa_shell_files_refresh` в том же файле и том же
свидетеле. На корне `up` даёт `MIXA_FM_ERR_ROOT` и оставляет снимок.
`refresh` заново читает каталог и снова отдаёт строки наружу.

### Шаг C, как он был поставлен

`mixa_fm_parent` и `mixa_fm_refresh`. Тот же ответ, что у `list`. Неудача
оставляет текущий каталог. Свидетель на каждую функцию отдельно.

### Шаг D. `read_text` и `read_bytes` — сделано

Оба имени — один перенос `mixa_shell_files_read`. Шов `mixa_fileio_win32`:
файл читается целиком, без обрезки. `len` — размер файла, байт после него
нулевой, отдельной текстовой копии нет. `Files` буфер не хранит. Отказ
не подменяет уже отданные байты. Пустой файл — успешный перенос длины 0.
Чтение каталога отказывается. Свидетель тот же, плюс эти проверки.

### Шаг D, как он был поставлен

Имена и байты — шов Files (`mixa_fileio_win32`). Текст консоли живёт в файле
(`FILE_SEAM.txt`): экран читает его тем же `read_text`, отдельного буфера
консоли в памяти не заводить.

`Audio\have_bytes` принимает байты передачей хранилища, не копией.

### Шаг E. `copy` и `remove` — сделано. `find` — нет

`mixa_shell_files_copy_file` копирует один файл через `mixa_fileio` и
прибавляет прогресс один раз, когда файл уже лег. Отказ прогресс не зовёт и
назначения не оставляет. Дерево по-прежнему `mixa_copy_run`, его этот шаг не
подменяет.

`mixa_shell_files_remove` — это `mixa_dir_remove` названного пути. Отметку
Shell он не читает. Повторное удаление отказывается.

`find` тела не получил: FSync нет, обход не выдуман.

Свидетель файлов: 22 проверки, 0 отказов.

### Шаг E, как он был поставлен

Тела: `mixa_fm_copy`, `mixa_fm_remove`, поиск — когда появится тело FSync;
до него `find` остаётся названным письмом без выдуманного обхода.

`copy` отвечает прогрессом в `show_progress` по мере хода Files, не одним
общим барьером на все файлы. `post` не обещает join.

Удаление: Shell спрашивает, затем одно письмо `remove`.

### Шаг F. Audio — сделано без устройства

`mixa_shell_audio_scan` зовёт `mixa_audio_scan_directory_vt` и отдаёт имена.
`play` и `stop` — `mixa_audio_play` / `mixa_audio_stop`. Пустой контроллер
отказывается. Устройство не открывается. Панель и кнопки остаются на Shell.
Свидетель `tests/mixa_shell_audio_selftest.lm1`: 4 проверки, 0 отказов.

### Шаг F, как он был поставлен

`play` уже пишет письмо в Files. Тело после `have_bytes` — `mixa_audio_mp3` /
`mixa_audio_launch`. `stop` и `scan` — прямые вызовы тех же модулей.
`mixa_audio_panel` и `mixa_audio_button` не переезжают в Audio: они рисуются
на Shell.

### Шаг G. Process — сделано

`mixa_shell_process_launch` — `mixa_process_spawn`. Плохой каталог даёт
`MIXA_PROC_ERR_SPAWN` и не оставляет процесс. Запущенный `echo` пишет в файл
консоли то, что `read` забирает без ожидания; stdin закрыт. `share` записывает
пути и не вызывает `begin`. Свидетель `tests/mixa_shell_process_selftest.lm1`:
4 проверки, 0 отказов.

### Шаг G, как он был поставлен

`launch` — spawn из `PROCESS_SEAM.txt` через `mixa_process_win32`: команда и
каталог. Не стартанул — отказ, это не код выхода уже запущенного.
Дальше отдельные методы: `read` без блокировки, `write`, `status`, `kill`,
`close`. Вывод ребёнка дописывается в файл консоли, экран видит его через
`files\read_text`. stderr влит в stdout. stdin закрыт, пока нет явной записи.

`share` — `mixa_share` / `mixa_share_win32` после того, как Shell собрал
действие (`mixa_share_action`) и отправил одно письмо.

### Шаг H. Ход Shell — сделано для пустого опроса

`mixa_shell_turn` один раз снимает `mixa_pump_drain` и забирает уже лежащие
события. Headless без ввода даёт 0 событий и не ждёт. `GetMessage` не
вызывается. Свидетель `tests/mixa_shell_turn_selftest.lm1`: 3 проверки,
0 отказов. Жест, который шлёт письмо, этим шагом не разобран: для него нужен
настоящий вход, а не пустой опрос.

### Шаг H, как он был поставлен

Один ход владельца: снять события (`mixa_pump`, один неблокирующий съём),
разобрать жест (`mixa_button_dispatch`), отправить не больше тех писем,
которые жест назвал, нарисовать ответ. `GetMessage`, который ждёт, в этот ход
не ставить: ждать должна очередь Message, не чужой цикл окна.
`mixa_app_main_msg.lm1` уже держит Peek, а не GetMessage; новый ход не
возвращает блокирующий насос.

### Шаг I. Один вход — сделано

`mixa_shell_start` — это `Mixa\start`. Перед письмом он кладёт бэкенд
в слово `native`. Пустого слова письмо не уходит. Одно письмо: `files\list`,
ответ `shell\show_rows`, отказ `shell\note_refused`. Внутри Files вызов прямой,
`mixa_shell_files_list`. Снимок переносится на Shell. Чужой путь увеличивает
отказ и не подменяет уже отданные строки. `mixa_app_main*` не вызывается.
Общий линк всех `.lm1` одним телом не есть критерий шага.

На `main` лежал другой набросок того же шага: `mixa_shell_main.lm1`,
`MixaShellHost`, `mixa_shell_bind_native`, `mixa_shell_run` и свидетель
`tests/mixa_shell_entry_selftest.lm1`. Он вшивал таблицу headless внутрь
bind и не очищал слово при закрытии. Письмо, один ход и закрытие уже есть:
`mixa_shell_start`, `mixa_shell_turn`, `mixa_shell_native_close`. Слово
принимает ту таблицу, которую передал вызывающий. Имена наброска сняты.

Продукт этого входа — отдельный бинарник `mixa_shell_start.exe`. Его
`fn: main` лежит в `mixa_shell_start_main.lm1`. Он вызывает
`mixa_shell_start`, затем не больше заданного числа `mixa_shell_turn`,
затем закрывает слово и Files. Это не `mixa_app_main.exe`, не самотест
модуля и не цикл `mixa_app_controller`. `build_mixa.ps1` линкует его
строкой `exe:mixa_shell_start` из `mixa_shell_start_main.o` через
`Resolve-Link`. Если в замыкание попали `mixa_app_main.o`,
`mixa_app_main_msg.o`, `mixa_app_controller.o` или `mixa_shell_main.o`,
скрипт этот линк отвергает.

Свидетель `tests/mixa_shell_start_selftest.lm1`: 8 проверок. Он вклеивает
тела Files, ход и этот вход один раз. Здесь он только переведён: шов
каталога тянет `<windows.h>`, компилятор останавливается на этом заголовке.
Прогон — на машине с Win32. Из `dev/mixa_sandbox`, тем же `l1trans`, которым
собирают остальные свидетели mixa: перевести
`mixa_manager/tests/mixa_shell_start_selftest.lm1`, заголовки `*.h.lm1` его
`predef` положить как `mixa_manager/*.lm1.h`, собрать `gcc -std=c99` и
запустить. Успех — строка `shell-start: 8 checks, 0 failures` и код 0.
Ноль проверок или ненулевой код — отказ.

Сборка продукта, на машине с Win32:

`powershell -NoProfile -ExecutionPolicy Bypass -File dev\mixa_sandbox\tools\build_mixa.ps1`

Успех этой цели — строка `OK exe:mixa_shell_start` и файл
`dev\mixa_sandbox\build\<stamp>\bin\mixa_shell_start.exe`. Повторный линк
готового пула объектов, без перевода:

`powershell -NoProfile -ExecutionPolicy Bypass -File dev\mixa_sandbox\tools\build_mixa.ps1 -StartLinkOnly -ReuseStamp dev\mixa_sandbox\build\<stamp>`

Запуск headless, граница шагов положительная и обязательная. Каталог
должен существовать. Здесь бинарник не собирался и не запускался:

`dev\mixa_sandbox\build\<stamp>\bin\mixa_shell_start.exe --headless <существующий каталог> 4`

Успех — код 0 и одна строка
`MIXA_START status=OK steps=4 bound=4 shown=1 refused=0 events=0`.
Нет флага `--headless` или граница не положительное число — код 2,
`reason=usage` или `reason=bad-bound`.

### Шаг I, как он был поставлен

Когда B–H имеют свидетеля каждое, заменить два старых входа на `Mixa\start`.
До этого шага `mixa_app_main*` не удалять. Общий линк всех `.lm1` не есть
критерий шага I: критерий — граф писем и прямые вызовы внутри владельца.
Повторная попытка собрать прежний `build_mixa.ps1` на всех единицах вернёт
прежние duplicate type и multiple definition.

### Шаг J. Слово native — сделано

`MixaShellOwner.native` — слово Structure владельца Shell. В него кладётся
таблица Win32 или headless. Вызовы open и poll идут через это слово, прямым
вызовом. `mixa_backend_table` остаётся реестром шва: в нём по-прежнему одно
имя `headless` в headless-сборке. Имён `native`, `shell` и посторонней
таблицы в реестре нет. Запись в слово не пишет слот реестра. Два владельца
держат одно слово и разные поверхности. Закрытие одного не гасит другой.

Свидетель `tests/mixa_shell_native_selftest.lm1`: 14 проверок, 0 отказов.
Headless, без окна и без `GetMessage`. Пустой ход по-прежнему 3 проверки,
0 отказов.

### Шаг J, как он был поставлен

После шага I бэкенд Win32 или headless становится словом `native` Shell.
Таблица `mixa_backend_table` не становится пятым владельцем и не становится
словарём методов почты.

## 6. Что уже пройдено в заходе каркаса

- Граф `mixa_shell.lm2`: четыре владельца, письма раздела 4, включая `up`,
  `refresh`, `remove`, `stop`, `scan`.
- `Audio\play` само просит байты у Files.
- Этот файл: карта тел, философия, порядок A–J.
- `Files\list` помечен первым телом и запретом тащить за собой selection.

Шаги B–D, copy/remove из E, F, G, пустой ход H, вход I и слово `native`
J закрыты. Набросок `mixa_shell_main` снят. `find` без FSync не написан.
`mixa_app_main*` остаются прежними входами продукта и не являются корнями
графа. Продукт входа порта — `mixa_shell_start.exe`. Граф `mixa_shell.lm2`
по-прежнему не транслируется: в нём записан `post`, а транспорт ядра этим
портом не пишется. Свидетель входа I и сборка `mixa_shell_start.exe` на
этой машине не выполнялись: шов каталога тянет `<windows.h>`. Свидетель
слова `native` здесь: 14 проверок, 0 отказов.

## 7. Как сажать

Каталог — `dev/mixa_sandbox/mixa_manager/`. Эталон не трогать. Ядро, `l2src/`
и `dev/l2src_sandbox/` этим портом не править: там другая очередь. Один
тяжёлый `gcc` на машине за раз, его может держать ведущий ядра. Пока шаг не
зовёт компилятор, он с той очередью не спорит.

В коммит этого порта класть только файлы mixa. Чужие правки `entry_index` /
`l2trans` не подбирать.
