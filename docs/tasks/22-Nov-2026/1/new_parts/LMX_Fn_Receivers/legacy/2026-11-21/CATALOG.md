# Каталог всех 50 ресиверов


`BODY` означает, что библиотечное тело написано в указанной области применения.
`BODY_WITH_BRIDGE` — тело алгоритма написано и требует четырёх согласованных
интерфейсов FxKernel. `GAP` — честно отключённая заготовка с описанным
недостающим доступом. Ни один статус не означает пройденный запуск LMX.


Полное семейство общих адаптеров сопровождается сохранёнными специализациями
Int/@. Остальные ресиверы сохраняют конкретные области применения: например,
bind/traverse — Maybe<@>, diff/patch — идентичности ссылок, коллекции — ссылки.
Они не объявляются универсальными по всем возможным типам и эффектам.


| № | Ресивер | Основной API | Статус | Область |
|---|---|---|---|---|
| 01 | types | `RxTypes\types` | BODY | физические типы полей; плотный Array<int> |
| 02 | names | `RxNames\names` | GAP | нужен доступ к существующей таблице имён |
| 03 | signature | `RxSignature\signature` | BODY_WITH_BRIDGE | полная сигнатура через общий семантический анализ FxKernel |
| 04 | signatureTypes | `FxSignatureOperand\make` | BODY_WITH_BRIDGE | OPERANDS_TEMPLATE: результат слева, все входы справа; типовые токены -> обычная fn-сигнатура |
| 05 | lambda | `FxLambda\lambda` | BODY_WITH_BRIDGE | N разных входов; последняя ступень возвращает точный исходный R |
| 06 | apply | `RxApplyInt\apply` | BODY | binary int; также unary int и @ |
| 07 | partial | `FxPartial\partial` | BODY_WITH_BRIDGE | префикс 0..N; N-K входов; при K=N отложенный nullary |
| 08 | uncurry | `FxUncurry\uncurry` | BODY_WITH_BRIDGE | явные contract и failures; остановка по N, включая callable-result |
| 09 | flip | `FxFlip\flip` | BODY_WITH_BRIDGE | первые две позиции произвольного N>=2, вместе с типами |
| 10 | compose | `RxComposeInt\compose` | BODY | unary int и @; F(G(x)) |
| 11 | pipe | `RxPipeInt\pipe` | BODY | unary int и @; G(F(x)) |
| 12 | identity | `RxIdentityInt\identity` | BODY | фабрики identity для int и @ |
| 13 | map | `RxMap\map` | BODY | последовательная обработка ссылок |
| 14 | filter | `RxFilter\filter` | BODY | ссылки + int-предикат |
| 15 | fold | `RxFold\fold` | BODY | левая свёртка ссылок |
| 16 | zip | `RxZip\zip` | BODY | пары ссылок; длина min |
| 17 | zipWith | `RxZipWith\zipWith` | BODY | ссылочная binary-функция |
| 18 | scan | `RxScan\scan` | BODY | n+1 результатов, начиная с seed |
| 19 | bind | `RxBind\bind` | BODY | конкретный Maybe<@> |
| 20 | traverse | `RxTraverse\traverse` | BODY | Maybe<@>, остановка на отсутствии |
| 21 | memo | `RxMemo\memo` | BODY | явное равенство ключей; линейный кеш |
| 22 | fix | `RxFix\fix` | BODY | явная рекурсия через self |
| 23 | select | `RxSelect\select` | BODY | физические индексы, ссылки |
| 24 | omit | `RxOmit\omit` | BODY | физические индексы, ссылки |
| 25 | rename | `RxRename\rename` | GAP | нужен штатный доступ к записи канонических имён |
| 26 | reorder | `RxReorder\reorder` | BODY | полная перестановка без повторов |
| 27 | project | `RxProject\project` | BODY | select и одна общая copy |
| 28 | defaults | `RxDefaults\defaults` | BODY | merge(fallback;source), порядок fallback |
| 29 | diff | `RxDiff\diff` | BODY | изменения вектора идентичностей ссылок |
| 30 | patch | `RxPatch\patch` | BODY | проверка базы и применение diff в новый контейнер |
| 31 | bindFields | `RxBindFields\bindFields` | BODY | defaults callable, не удаление входных позиций |
| 32 | derive | `RxDerive\derive` | BODY | обычная композиция merge |
| 33 | transpose | `RxTranspose\transpose` | BODY | прямоугольный массив ссылочных строк |
| 34 | groupBy | `RxGroupBy\groupBy` | BODY | явные keyOf/sameKey, стабильный порядок |
| 35 | lazy | `RxLazy\lazy` | BODY | thunk @; кеш первого успеха |
| 36 | force | `RxForce\force` | BODY | обычный запуск thunk |
| 37 | once | `RxOnce\once` | BODY | один успешный вызов; ошибки допускают новую попытку |
| 38 | repeat | `RxRepeat\repeat` | BODY | count запусков; массив результатов |
| 39 | until | `RxUntil\runUntil` | BODY | step, затем проверка; имя core until сохранено |
| 40 | retry | `RxRetry\retryCall` | BODY | ограниченные попытки для RxTaskFailure |
| 41 | around | `RxAround\around` | BODY | acquire / finally release / action |
| 42 | recover | `RxRecover\recover` | BODY | обработка RxTaskFailure с payload |
| 43 | adapter | `RxAdapter\adapter` | BODY | before -> F -> after; unary @ |
| 44 | permute | `RxPermute\permute` | BODY | перестановка упакованных позиционных actuals |
| 45 | overload | `RxOverload\overload` | BODY | явные предикаты; ровно один выбранный callable |
| 46 | predicate | `RxPredicate\predicate` | BODY | нормализация к int 0/1 |
| 47 | guard | `RxGuard\guard` | BODY | проверка до вызова |
| 48 | trace | `RxTrace\trace` | BODY | события входа, результата и выхода без результата |
| 49 | contract | `RxContract\contract` | BODY | явные pre/post вызовы |
| 50 | composeData | `RxComposeData\composeData` | BODY | merge фактического parent и overlay данных |
