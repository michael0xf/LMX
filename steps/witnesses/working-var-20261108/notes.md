# Codex: рабочие значения явной var и последовательное тело fn

## Изменение

Построитель принимает полную форму fn с явной var; args/return/var/body остаются обычными Lmx.
Оба потребителя исполняют последовательные присваивания, вызовы и return. Числовые рабочие значения и dirty-отметки
живут только в кадре текущей активации; строки имён сравниваются адресами. Кадр ссылается на реальные ячейки var,
не создаёт второй постоянный граф и освобождается при выходе. Публикация изменённых полей следует порядку var;
аргументы вычисляются до публикации перед вызовом. Уже чистые поля не записываются повторно.

Var исполняется как обычная Lmx через существующий call. Вычисляемый инициализатор заменяется опубликованным значением
в её настоящем слоте, следующий вход не повторяет эффект. Native содержит вычисления тела и отдельный вход var;
общие функции обслуживают места, допуск и публикацию. Обёртка native публикует изменения также при возврате ошибки.
Интерпретатор использует тот же механизм. Формалы int копируются в отдельные места вызова.

Источники нормы: [книга, рабочее состояние](../../../docs/LMX_semantics.ru.md#dynamic),
[публикация и рекурсия](../../../docs/LMX_semantics.ru.md#activation-history),
[спецификация реализации §§3.4, 3.5, 6.3](../../../docs/kernel-implementation.ru.md).
Это перенос существующей нормы, без нового решения автора.

## Результат

Tuple graph15/tool12/rt12, восемь сценариев × interp/native/forced = **24/24**:

- own_effects: mytest(a(5)) и mytest(a:5) дают36, счётчик a после них1 и2; alter(original) даёт7,
  исходный original остаётся5. Имя a совпадает с формалом mytest и не перехватывается.
- own_publication: после рабочей записи x=2 вызов pair(x;work\var\x) получает2 и прежнее опубликованное1,
  даёт21. После публикации x=2 второй вход даёт22.
- own_initializer: два вызова cached дают1 и1, tick вызван один раз; var хранит int:seeded1 вместо инициализатора.
- own_error: x=9 публикуется до выхода с делением на ноль; interp отвечает6, native/forced завершаются с1.
  GRAPH-CHECK проверяет здесь только статус. Состояние x=9 отдельно проверено по секции GRAPH-AFTER всех трёх
  именованных run.log/interp.log. Проверочный host теперь печатает AFTER также после отказа, прежде чем вернуть ошибку.
- point_fields, nested_expressions, saved_address (два обхода), indirect_int сохраняют прежние результаты.

Mutation11/11 и method-mutation8/8 сохранены: сброс native при изменении кода, сохранение при записи данных,
постоянная внутренняя адресация и отсутствие активации после обхода. Это не проверка всей рекурсии/всех видов exit.

## Tuple

R = C:/Nyasha_Planet/LMX; P = R/build2/codex_fix250generationchain01; S = P/cold-graph309-codex01;
B = P/cold-candidate48/full48/g2/frontend; F = P/cold-graph309/fe309a/l2trans.exe.
TOOL = S/tool12/lmxtool-tool.exe; GRAPH = S/graph15/graph_trans-prod.exe; RT = S/rt12.

- P/pins/codex313-source05.sha256, 299 входов: 1600085e93642595c07367ab39c443321d4e8a82dabec1ee058a015e3f1a5e50.
- TOOL: 3ba6ca37dc7b5aff5a45b964c111afdeb34d973f0c1ac0caa6a1f892df0b3ad7.
- GRAPH: e96576567cf6d7c42ec1acd934639245b78f4d5719431277fa6957e0e26bbca2.
- RT/driver.o: 12ea7a4f6949a13e6618cf624adf02777ffa6703546a1b7fc09ea7f8bba6f939.
- RT/driver-observe.o: a570f5341713ab76a4ca21a00594e882b8f73796bd41b8cd2e89c7d9d068e019.
- F: b1851f7b56e568088e3e71fdf3b8676de7e01d86481b8c43efe268309778166f.

    TOOL11 0 entry 0 -- build-self R S B F S/rt09/driver.o tool12
    TOOL 0 entry 0 -- build-runtime R S B F rt12
    TOOL 0 entry 0 -- build-graph R S B F RT graph15
    TOOL 0 entry 0 -- graph-check R S B F RT GRAPH OUT SOURCE EXPECTED EXIT COUNT INTERPRETER-ANSWER
    GRAPH 0 entry 0 -- mutation
    GRAPH 0 entry 0 -- method-mutation S/tests/graph/point_take.lm2

OUT — абсолютный новый путь S/check15-CASE. Для saved_address EXIT=0 COUNT=2; для own_error EXIT=1 COUNT=1
INTERPRETER-ANSWER=6 (EXPECTED не используется при ненулевом EXIT).
Результаты сборок: S/tool12/record.txt, S/rt12/record.txt, S/graph15/record.txt.
Результаты проверок: S/check15-CASE/record.txt и P/pins/codex313-CASE15.log.
Архив содержит17 точных копий: [список](records.list), [SHA оригиналов](records.sha256),
[SHA LF-копий Git](records-lf.sha256). Оригиналы остаются неизменными в P.

Промежуточные неудачи сохранены: rt10 отказал на адресе индексированного поля, rt11 — на записи такого поля;
L2-исходник исправлен на типизированный указатель строки временного кадра, rt12 прошёл. Первый check13 имел ошибочно
относительный OUT, второй выявил несколько функций внутри одного external-блока генерируемого L1; graph14 исправил
генерацию. Graph15 меняет только вывод AFTER у проверочного host после ошибки. Успехи старых попыток не подменяют
указанный конечный tuple.
Первый относительный вывод сохранён в S/check13-relative-output (перенесён из R/check13-own_effects).

Docs-check S/docs17 — PASS: 35 парных разделов семантики, 14 случаев implements, 27 парных разделов грамматики,
44 дословные выдержки, 615 импортированных файлов, ссылки, LF для22415 tracked files; 81 checks, 0 roots.
Точный лог P/pins/codex313-docs17.log. Scoped git diff --cached --check — PASS.

## Остаток

Поддерживается явная int-var. Собственные объявления из тела ещё не добавляются построителем в var; такие операторы
пока отвергаются. Полные снимки динамических входов, ветвления/циклы, остальные типы рабочих мест, все формы
call:code data и выхода, codec/copy/merge/attach/GC чистого графа и корни Message/mail открыты.
Новая отдельная проверка merge-примера35 этим срезом не заявляется. Самосборка из чистого графа, две последовательные
самогенерации, collector/3pass/FULL и §§8/8a не завершены. Единственный writer/build — Codex, цель active.
