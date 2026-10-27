# Перенос координат frontend и служебных функций backend

Проверенный срез237 переносит112 функций frontend и129 функций backend
в ordinary L2. Два libc stream accessor теперь тоже исполняются из L2;
обычный cold bootstrap использует их свежий object, а не прежний BASE object.
Основа — main `42207dfb`. Это промежуточный bootstrap, не завершённая
самосборка L3/L2. Числа и полные SHA — в [verification.json](verification.json).

## Поддерживаемые исходники

Frontend сохраняет732 прежних storage declarations;112 bodies и93 prototypes
заменены модулем координат. Остаются1525 definitions. Backend text75
(74fn+1voidsub) и state54 используют те же машинные ячейки;43 декларации
их состояния печатает L3. Остаются52 алгоритма и OS/main на L1.
[Проверка исходной дельты](promotion237-source-readback01.json) связывает
все восемь новых/изменённых исходников с frozen83 и прежними Git bytes.

L3 ABI writer сохраняет28 bodyless signatures, включая два stream accessor;
их две реализации теперь находятся в `l2_libc.lm2`. Свежий B1 генерирует
libc C и frontend, затем C-заголовки и runtime. В actual records новые
B1 `07A52AFA`, frontend `09DAAB2D` и libc object `AF9FDAE3` действительно
потреблены последующими командами. Язык, интерфейсный допуск и грамматика
не расширены. Library adapter и обычный call/implements здесь не переделаны.

Обычная input selection: runtime57+p0=0+driver=0+backend1+tools8+tests17=83.
Новый `backend.list` берёт единственный maintained root из `REPO/l1src`;
дубликата в sandbox нет. Этот root пока ещё содержит L1-алгоритмы.

## Фактический короткий bootstrap

[Команда](cold04-bootstrap.command) исполняла maintained L3 control tool
`E8176CBC` с явными seed F0/B0. [Журнал](cold04-bootstrap.log) и
[terminal receipt](cold04-bootstrap-terminal.json): session2973, exit0,
2026-10-26T23:40:47.8055108Z → 2026-10-27T00:52:43.3252128Z,
4315.519702с, smoke9/0, BOOTSTRAP quick0 failures.

G1 `DD82B832` действительно построил G2 `A1B7EF47`; оба запустили
собственное хеширование и последовательно стали рабочим binary.
Рабочий EXE raw-равен G2; existing `exe-same` дал1.
L1 `D41F8F61` и C `8C6A190A` были сохранены как ожидания до появления
обоих EXE, затем сверены с G2 до его линковки. Итоговые object
`D8690FC8` равны. [Prelink evidence](g2-actual-prelink-checkpoint01.json)
не подменено поздним отчётом о готовом binary.

Один запуск existing language verifier проверил170 файлов:83 stage inputs,
2 prelink outputs,83 canonical sources и2 input-list data. Фактический
[вывод](cold04-final170.log) — VERIFIED170/failed0; GNU также0.
Это те же проверки файлов одним CLI startup, не новая система проверок.
Double-space format сохранён: GNU space-star rows прежний verifier
пропускает, поэтому один exit0 без фактического числа строк не принимался.

[Три serial GCC-MM](cold04-dependency-readback.json) выбрали8 backend,
20 frontend и40 runtime заголовков, всего63 unique. Все пути — внутри
generated headers этой стадии, с проверенными хешами actual B0/B1 producers.
Новой C-сборки ради dependency readback не было.

## Значения и границы проверки

Четыре existing S8.1 logs сохраняют вызовы41/41/42/42/43/42, counts42/42/43,
после изменения A1 —101/43, runtime-candidate142/y42/x1/pad9/w10,
отказы30/33/34 и unused-formal3/called8.
[Readback](cold04-s81-readback.json) проверил36 actual record-bound pins.
Программы линкованы с production runtime; OBS только собран.
Forced/walkroot не доказывает обход тела каждого native callee.
Это не сильный unknown graph-built candidate, retained/copy closure
или завершённая общая проверка used-interface/UNKNOWN.

Полная сверка83 canonical inputs обнаружила прежний разъезд одного fixture.
[Выравнивание](canonical237-promotion.json) переносит ровно49 строк
PHYSICAL-CONSTRUCTION из ранее исполненного225 snapshot `0AC54A83`,
не меняя frozen237. Его [реальный старый запуск](fixture225-RUN.log)
наблюдал51/42, sharing/cycles1, три заблокированные записи и failed0.
Current smoke9 этот fixture не содержит: нового исполнения237 не заявляется.
Остальные прежние assertions сохранены.

Cold02 L2 refusal и cold03 strict-C refusal относились к переносу представления:
native-char/const spelling и actual scratch-array arguments. Исправлены
точные мосты прежних C-типов, не допуск или правила L2. Старые результаты
не переписаны. Ошибки подготовки metadata-команд и выравнивания отдельно
записаны в receipts; они не названы отказами компилятора.

Common used-interface/UNKNOWN, uniform native/Q49, остальная source closure,
два полных самозамещения и mailT01–T26 остаются OPEN. Следующие resolve120,
backend emit/platform/CLI и intern19 — приватная подготовка, не результат237.

Копии журналов используют LF; одна пустая финальная строка JSON source-readback
удалена для diff-check. Полные исходные и конечные SHA, а также исторические
40-строчные excerpts указаны в [provenance](packet-copy-provenance.json).
