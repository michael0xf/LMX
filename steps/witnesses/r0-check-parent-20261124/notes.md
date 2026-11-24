# W2: R0 image and a real parent turn

Компонент W2 принят по адресным результатам ниже. W3–W5, весь 27.10, M13/M14 и 21.25 остаются открыты.
Начальная база: 0f1a19e20a787ca4d479379b84498313ec459498.
План: [27.10](../../../next_core_tasks_v3.md#backends-20261123).
Предыдущий компонент: [W1](../frame-selected-description-20261124/notes.md).

## Изменение

emit и emit-check строят один и тот же исходный граф в настоящем R0.
Дополнительного корня программы в слоте 0 графа R0 больше нет; лексический parent R0 равен 0.
Наблюдательная обёртка R0 печатает граф и выполняет тело, не устанавливая Message.success.

before_turn ставит entry настоящего parent Thread. Этот entry делегирует публичному lmx_root_host_entry.
Родитель сначала принимает настоящее exit-письмо, затем, при его отсутствии, выносит обычный verdict.
Только проверочный parent может принять завершённый body0 без success.
Для свежего R0 это turn=1, state=IDLE, body_status=0 и running!=0 после успешной manager round.
exited остаётся фактом принятого письма; success и running дочернего R0 не подменяются.
Собственный host может завершить свою успешную проверку. Thread-parent не становится graph.parent.

manager_step сохраняет результат thread_turn, выполняет прежние tick/finish и передаёт THREAD_INVALID.
Обычный STOPPED не становится новой общей ошибкой manager.
launch_result проверяет manager round, второй host turn и phase=2.
host_entry устанавливает phase после успешного make/take; нулевой done не считается результатом пропущенного хода.
Вердикт no-letter теперь заполняется в родительском turn. Тексты остановленного R0 сохраняют диагностический признак.

Наблюдатель перехватывает также существующий launch_tapped.
Оба launch-входа используют один прежний учёт launches, builder, body status, stderr и закрытого host.
Без собственного hook драйвера caller tap передаётся прямо; без caller tap сохраняется прежний hook.
При композиции сначала выполняется driver_before_turn, затем caller tap с тем же адресом Root.
Одна typed callback-ячейка существует только в прежнем process-wide C-состоянии наблюдателя.
Прежнее значение хранится на стеке и восстанавливается сразу после синхронного launch_result.
Это не runtime registry, не второй граф и не новый Root/Launch context.

Root/Launch layouts, runtime exports и физический формат графа не менялись.
Список экспортов наблюдателя l2_driver вырос с 13 до 14; рецепт добавляет tapped-перехват.
Скрытый граф-аргумент, глобальные функции доступа, lmx_graph_find и цепочка graphs относятся к следующему W3.

## Производители

Все расписки: T/w2-accept-20261124/root01.
T — build2/codex_fix250generationchain01/runs/fable-m10-call-forms-20261116-01/fable/tz-20261121.
S — build2/codex_fix250generationchain01/sol-m14-field-values-01.

- Tool01: S/codex-w2-s2126h-tool01/lmxtool-tool.exe; exit 0, 45 секунд.
  SHA-256: 73e965d60059afa169de735642839728e941f24b630a9400727bd3434374cae8.
  Рецепт собран принятыми own-fep02 и W2 RT01; это производитель нового наблюдателя.
- Frontend переиспользован: S/codex-own-s2126f-fep02/l2trans.exe.
  SHA-256: aa427e11ff26a83f1d549b678ceb2ddf9fad638befc26c3189c9f695c2f540c2.
- RT04: S/codex-w2-s2126h-rt04; exit 0, 105 секунд; минимум свободной commit-памяти 3453 MB.
  driver.o: 8e9583ae9a9a314229389c066fc745c867d197954855eba939cebc666d54498d.
  driver-observe.o: 151f76dd25f4e22414f8ae25b8efa96f198bd2d19b6ce22fc89595629ac4ea38.
- Graph04: S/codex-w2-s2126h-graph04/graph_trans-prod.exe; exit 0, 21 секунда.
  SHA-256: 304b499b9a7d882baaa13767e6a6fe23b007302769f90fea82142379df83a743.

Tool01 не объявлен побайтно равным прежнему tool; runtime RT04 не объявлен равным RT03.
Полный G1/G2, fixedpoint и full-suite на этом компонентном шаге не запускались.

## Адресные результаты

Восемь Graph-строк, 24/24 interp/native/forced:

- root_closed_names;
- send_exit и send_in_fn: настоящее exit-письмо с кодом 1;
- path_write_native_level2.lm2: образ файла с записью L2;
- frame_computed_description: повторный вход и выбранное описание W1;
- level2_record_node;
- bind_place_computed_once;
- новая r0_exit_text: exit 1 и непустые stdout/stderr.

Логи семи прежних строк: final-ИМЯ.log. Новый тест: exit-text-final02.log.
Его .expected задан исходным exit 1 и двумя текстами; перед исполнением проверен build-only дамп формы.
После GRAPH-AFTER-END в обоих native/forced run.log отдельно проверены w2-exit-out и w2-exit-err.
Ненулевое настоящее письмо и его тексты не заменены решением о body0.

controls9-final.log: 9 строк, 0 отказов; 18 сборок и 36 исполнений, а не 54 маршрута.
Строки: graph_copy_names, graph_fn_data_typed, graph_call_values, execution_gc_roots,
own_graph_reference_place, frame_description_gc, os_throws, struct_call_throws, local_array_const_index.
Режимы native/forced и roots 0/1. Расписка: guard-controls9-final.txt, 51 секунда.

Девять дополнительных диагностических запусков прошли на RT04:

- observed-body: parent done=0, child turn=1/body=0/success=0, graph.parent=0.
- stopped-before: parent done=1, child turn=0/body=0/success=0.
- tap-refusal: ненулевой caller tap даёт launch failure, тело и parent judgment не исполняются.
- boundary-refusal: нулевое тело, затем отказ настоящей публикации prepared child; parent не принимает body0.
- body-failure: статус 41 проходит наблюдатель; stopped=1 сохраняется; verdict 1.
- ordinary-native и ordinary-forced: та же программа без success/exit даёт verdict 1.
- два composed запуска: успех и отказ caller tap вместе с прежним ref hook.

Это копии сгенерированного L1 с узкими наблюдениями/инъекциями, не новый поддерживаемый runner.
Исходный L1 Graph02 побайтно равен соответствующему финальному Graph04: probe-producer-same.log.
Пробы и логи лежат в probes/; итоговая проверка — probes-final-check.txt.
MAIN/BEFORE печатают одинаковый адрес Root; каждый callback вызывается один раз.
В composed-пробах caller видит ровно mainArgs и письмо peer, затем снимает своего ненужного test-peer с service.
Это проверка композиции hook, не проверка языкового ответа на Ping.
После launch отдельно проверяется восстановление callback-ячейки; все четыре старые проверки драйвера остаются.
Boundary-проба использует настоящий отказ публикации reservation без child; pointer UB не выполняется.

## Состав и граница

Срез: 5 изменённых модулей/рецептов, 2 новых Graph-файла и inputs.list/inputs.sha256 — 9 путей кода и контролей.
Документы: 5 активных файлов и это свидетельство.
Итоговый манифест: 1686 файлов.
SHA-256: 9f180a95879e6371e04e6cce0a9a977fc7cb3a40952caf7a250056a476e02ee4.
verify корня и stage: 1686/0 failed; неизменная база: 1679/0 failed.
full-suite.tsv не менялся. Приватная неудачная root_turn_status не входит в манифест и срез.

Попытки до финала сохранены отдельно: L1 external с двумя функциями исправлен до Graph02;
прямое присваивание fnptr исправлено до RT03; признак stopped после failed turn исправлен в RT04.
Отдельная nested-launch проба отвергнута: она нарушала current Thread assertion-владельца.
Её ошибки не перенесены в штатные ожидания и не считаются проверкой runtime.

level2_record_root и level2_record_file остаются красными относительно прежних .expected:
оба интерпретатора, прежний W1 Graph и новый Graph, отвечают 3; native/forced также не проходят.
Логи: check-ИМЯ и old-ИМЯ.log. Это старые обращения к data/shared, ожидания не изменялись.
Полный набор зелёным не объявлен; прежние 52 отказа в 18 программах не пересчитаны по этим контролям.

Полный docs check, bootstrap, 32-битный ABI, W3–W5 и весь v3 не заявлены готовыми.
Проверка документации ограничена изменённой прозой, целями ссылок и git diff --check.
