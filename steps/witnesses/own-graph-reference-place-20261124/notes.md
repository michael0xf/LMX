# Одно собственное место обычной Graph-ссылки

Codex, 2026-11-24. Компонент принят по адресным распискам на базе опубликованного индексного компонента
`6d4ad9384b20e9524ec3fabe208cfa18d9e67177` и документационного коммита `4761996e3`.
Весь 27.16, M14, шаг 21.25 и W1–W5 этим не закрыты.
Коммит own опубликован: `03ee5bef0d0a86de5c556cdf30eea0f71fb2c29e`.

## Исправленный случай

Cached собственная CODE-local Graph-ссылка с внутренним физическим Lmx depth=1 имела два payload:
постоянный C-local q и LmxWalkValue WV. Bare read брал q, full/free reader брал WV, а @inst мог брать source slot.
В free_model_admit это давало null в through после передачи адреса текущего inst.
Диагностическая трасса debug-free-model202 и чтение Astra 202/202a установили эту цепочку до правки.
Методы и builder прежнего принятого числового FE побайтно совпали с индексной эмиссией этого случая;
историческое исполнение прежнего binary этим сравнением не заявляется.

Теперь единственный payload выбранной локали — существующий void* member WV.ref.
Bare/full read, собственная запись, свободное имя, @x и прямые потребители Structure/модели читают одно место.
Отдельный изменяемый q не объявляется. _from и _bound остаются происхождением и идентификацией binding.
Собственная запись захватывает RHS и контекст до изменения владельца, включая self-assignment.
Receiving type владельца сохраняется; type RHS не становится типом места.

ADDRESS готовит физический LmxWalkPlace с address=storage=&WV.ref, descriptor=0 и context=&устойчивый WV.
Существующий lmx_walk_place_reference сохраняет этого владельца как referent адресного значения.
Unevaluated ADDRESS остаётся выражением того же адреса, без исполнения producer.
Binding по-прежнему предлагает value=&WV, storage=0; own_storage_local не расширен этой ветвью.
Инициализатор CODE выполняется в достигнутом объявлении, не при подготовке C-local.

## Место до первой записи

Объявленный WV.ref физически существует и до появления значения. ADDRESS берёт его адрес напрямую.
Общий value_storage сохраняет прежний контракт: для отсутствующего значения он возвращает 0.
Физический pointee точного member определяется по типу владельца без чтения отсутствующего payload.
После успешной косвенной записи raw и checked stores обновляют present/kind/ref этого владельца,
сохраняя его receiving type и обычный перенос model/references/referent.
Идентичность адреса именно &owner.ref ограничивает эту ветвь; произвольный C pointee не угадывается.

Не добавлены kernel API, exports, типы, поля Value, второй payload, registry или SOURCE admission в native.
Runtime сохраняет ABI4 и прежнее определение ScalarABI. Source graph не получает локальное значение.
Array, FOREIGN/raw C pointers и большие глубины не включены в отбор own Graph-reference.

## Состав и сборки

T означает каталог tz-20261121 текущего запуска; S — sol-m14-field-values-01.
Расписки: T/own-graph-accept-20261124/root01. Частный пакет: T/native-own-address-codex.
Код и контроли — 9 путей: 5 изменённых модулей, 1 новый тест, inputs.list/inputs.sha256/full-suite.tsv.
Документы перечислены отдельными путями в коммите и не включены в этот счёт кода.

- Frontend: l2_frontend_core, l2_frontend_lower, l2_frontend_useplan.
- Kernel: lmx_walk_values, lmx_value_owned; сигнатуры и exports прежние.
- Новый runs-тест: dyn/own_graph_reference_place.lm2, expectation 7 записан до запуска и не менялся.
- В full-suite добавлена одна строка после free_graph_address; существующие строки не ослаблены.

Промежуточный FEP01 перевёл три модуля: exit 0, 303 s; host01: exit 0, 74 s.
Его six-row check исправил free_model_admit и free_graph_address, но ещё не проверял отсутствующее значение.
При чтении absent case найдена неправильная зависимость ADDRESS от value_storage; исправлена до его исполнения.
P0 первой kernel-правки обнаружил пропущенный tail cutter; cutter добавлен, оба kernel P0 прошли.

Итоговые производители:

- Tool: принятый codex-index-s2126e-g2-tool, переиспользован без изменения исходников инструмента.
  SHA-256: f6fbb0f8e7036b76a0d44db56a8d2ae4da8c6c6a434d5b8dfe97f313d1311c61
- Runtime codex-own-s2126f-rt02: exit 0, 108 s.
  driver.o SHA-256: 06a307bed73984b0b1ef09e3b0641d5f4929933fd35bfccce4882bc237144908
  driver-observe.o SHA-256: ea68d46ffc3d309e5a8f9dcf1245baf07c0299e7ff13aa52450e48e584645928
- Lower-only FEP02: exit 0, 200 s; host02 link с RT02: exit 0, 74 s.
  Frontend: S/codex-own-s2126f-fep02/l2trans.exe.
  SHA-256: aa427e11ff26a83f1d549b678ceb2ddf9fad638befc26c3189c9f695c2f540c2
- Backend и libc переиспользованы из принятого G2 bundle с проверкой хешей.
  l1trans.exe SHA-256: 87b986154bcf866721577628c1078db39b7d6e1ae3b5d8e42d534627323a7463
  l2_libc.o SHA-256: af9fdae33655f8e6235310720787102921450f0f88f9b7bb2f365d372f553d37
- Graph codex-own-s2126f-graph01: exit 0, 22 s, FEH02 + RT02.
  SHA-256: 4b6a0fd931920d9c024249503bc7fe6ac540ca57127aa4f5d7d5564aa53c02d2

Сначала обнаружены 36 изменённых full-suite test headers против закреплённой базы G2.
Они сохранены отдельно и восстановлены из generations-consumed; затем проверка дала 481/481 совпадений.
Первый reuse/ABI manifest содержит 477 путей: из 481 исключены только 3 selected sources и 3 bodies,
добавлены backend/libc bundle. Заголовки всех трёх выбранных модулей оставлены инвариантами.
До и после части проверки прошли. Дополнительно проверены 1677 неизменённых source inputs.
Для lower-only части reuse/ABI 481 построен из закреплённой базы и явных FEP01/RT02 record delta;
старые declaration hashes сохранены, selected lower body/source исключены. До и после части — 481/0 failed.
Замена ABI или исключение изменившегося заголовка ради прохода не выполнялись.

## Исполнение

new1-02.log: одна новая строка, 0 failures, 2 builds и 4 исполнения.
Она проверяет indirect write, затем bare/free/deref read; bare write, затем deref read;
self-assignment, RHS со счётчиком ровно один раз и первую indirect write в local без значения.
Pointer используется только пока жив его владелец. Поля First/Second/Third сохраняют исходные значения.

controls11-02.log: 11 строк, 0 failures, 22 builds и 44 исполнения:
free_model_admit, free_graph_address, free_held_receive, absent_head_definition, declaration_site,
exact_scalar_storage, execution_gc_roots, graph_fn_data_typed, graph_call_values,
address_of_local, code_place_absent_assigned.
Extra-source absent_head_definition_part и declaration_site_part сохранены.
В сумме 12 строк: 72 PASS lines = 24 builds + 48 executions, не 72 маршрута.

В forced-эмиссии новой строки native entry оставлен только корню единицы;
обычные вызовы идут через общий dispatcher к portable producer, а не считаются walked по одному имени флага.
В native-эмиссии chosen нет постоянного q payload; два ADDRESS выбирают &WV.ref с устойчивым owner.
Эти наблюдения эмиссии дополняют исполнение, не заменяют его.

Отрицательный контроль baseline-new1.log использует прежние принятые G2 frontend и runtime ABI4.
Программа собирается; оба native исполнения возвращают 81 против прежнего ожидания 7.
Это первая проверка initialized case; до отсутствующего значения этот запуск не доходит.
Тот же исходник и expectation 7 проходят на FEH02/RT02: новая строка различает старую и исправленную семантику.

graph-seven.log: 7 graph-check строк, 21/21 interp/native/forced routes, CHECKS 7 lines/0 failed.
Сюда входят path_write_replaces_one_cell, caller_place_write_stays_local, path_write_native_level2,
path_context_alias_chain, path_context_rhs_call_once, path_context_alias_reassigned и path_context_alias_after_call.
Проверены source-cell replacement, сохранение исходного места вызова и контекстные пути на новом Graph bundle.

Манифест: 1681 файл; MANIFEST 0 failed, VERIFY R/S 0 failed.
inputs.sha256 SHA-256: 69d3bc44e10b4fe171f7d25a31baadde329e792c337f3f8890377fee8011a60f
git diff --check прошёл. Полные G1/G2, full-suite и performance campaign здесь не повторялись:
это компонентный цикл тел frontend/kernel без изменения ABI, exports или формата графа.

## Открытая граница

Полный индексный набор на опубликованной базе имел 52 failed assertions в 18 программах.
Этот итог не пересчитывается вычитанием отдельных исправленных строк без нового полного прогона.
Промежуточный first6 сохранил 12 failures в held_structure_places, place_map и callable_place_fields.
Повтор boundary3-02.log на итоговом bundle подтвердил те же 12 failures в этих трёх строках.
Их expectation 7 не менялся. Весь набор зелёным не объявлен.

Следующая работа — W1: убрать description snapshot/parent restore и удерживать уже выбранное описание кадра.
Частный W1-код и его P0 не входят в этот компонент и не объявляются принятыми.
Общий actual-to-place M14, GraphTool missing lowering, dense Array, descriptor/index и 32-bit ABI открыты.
