# Патч: рекурсивная группировка Expression по чистому графу

**Редакция:** 24 ноября 2026. Этот Markdown-файл предназначен для размещения рядом с директорией `spec`; все пути в diff начинаются с `spec/`.

**Основа:** состояние после применения `LMX_spec_changes_2026-11-24_corrected.tar.gz`, SHA-256 `db8278d1dd37d45414457a2bf94e1a7a8cf8249a95c3a40ae9d9763b49411469`. Это отдельное дополнение к последней исправленной документации, а не патч непосредственно к исходной авторской загрузке.

## Правило

Группировщик принимает граф узлов и связей. Раскрытие и упаковка выполняются **во временном представлении в памяти**. Исходный граф, фактические `parent`, порядок исходных вхождений и исходный текст остаются неизменными. Алгоритм не получает скобок, не ищет их и не создаёт строку для повторного разбора.

Каждая допущенная Expression-группа рекурсивно обрабатывается вместе с внутренними операциями и приоритетами. Полученный результат занимает одну позицию охватывающего уровня:

- Одна единица прозрачна. Ею может быть атом, уже подготовленная подгруппа или полное выражение.
- Несколько единиц образуют одну подгруппу. Их поля не присоединяются к соседним аргументам.
- Пустая группа остаётся присутствующим пустым аргументом.

Принцип упаковки тот же, что нужен для одного `left`. В широком `right` упакованный результат является одним подгрупповым аргументом. Выбор элементов единственной группы последовательностным получателем производится по уже нормализованному плану.

Следующие пары показывают **одинаковое представление плана**, а не переписывание исходника:

```lmx
1 + 2 (((3))) (4) ((5))
1 + 2 3 4 5

1 + 2 (((5 6))) (4) 5
1 + 2 (5 6) 4 5
```

Во второй паре справа четыре аргумента: `2`, подгруппа `(5 6)`, `4`, `5`. Группировщик успешно подготавливает их. Несоответствие числовому договору отклоняет сам `+`.

```lmx
1 + 2 (+ 5 6) 4 5
```

Здесь внутренний операнд указан явно. Он получает отсутствующий `left` и два элемента `right`; одна полная вычисляемая единица занимает одну внешнюю позицию. Эквивалентность `(+ 5 6)` и `(5 + 6)` реализует сам метод. Группировщик, разборщик и передача методу не переставляют эти аргументы и не добавляют операции.

Временный `PreparedAtom` сохраняет границу исходного атома даже тогда, когда его содержимое — целый `Apply`. Поэтому `2 * (3 + 4)` сохраняет внутреннее сложение целиком. Оболочка плана также удерживает исходные вхождения и контексты для RAW; она не является новым публичным типом LMX или узлом исходного графа.

### Последовательности и границы

| Запись | Подготовленные правые единицы |
| --- | --- |
| `(a b c) := (a c b)` | `a`, `c`, `b` |
| `(a b) := (((x y)))` | `x`, `y` по последовательностному договору присваивания |
| `(a b) := (((x y))) z` | Одна подгруппа `(x y)` и `z` |
| `(a b c) := (f g h) (f g h) (f g h)` | Три материальные подгруппы |
| `(a b c) := (x + 1) (y * 2) (z - 3)` | Три полные вычисляемые единицы |
| `(a b c) := (((x y)))` | Два значения против трёх целей: отказ до записи |

Фраза «дополнительного раскрывающего прохода после группировки нет» относится к адаптеру применения: рекурсивная обработка уже выполнена группировщиком. Она не запрещает обработку вложенных Expression-групп.

Графовые позиции целого VALUE, TYPE, DATA и RAW сохраняют свои принимающие договоры. Возвращённое готовое значение не запускается заново как CODE. Число полей, выданных `copy`, не подменяет число единиц исходного плана и не меняет договор коллектора. Правило фактического `parent`, существующий механизм обычных вызовов и два варианта обычного операнда — без `left` либо с одним `left` — сохранены.

## Состав патча

| Пути относительно каталога с `spec` | Изменение |
| --- | --- |
| `spec/EXPRESSION_GROUPING.md`, `spec/EXPRESSION_ALGORITHM.md` | Нормативное объяснение, алгоритм в памяти и авторские примеры |
| `spec/LMX_semantics.en.md`, `spec/LMX_semantics.ru.md` | Согласованная двуязычная норма и таблицы границ |
| `spec/SIGNATURE_EXPRESSION_REVIEW.md` | Исправление примера вложенной Expression-группы с сохранением договоров целого TYPE |
| `spec/patterns/OPERAND_USAGE_PROFILE.md`, `spec/patterns/LMX_regression_examples.to_fable.en.md` | Профиль операндов и наблюдаемые формы аргументов |
| `spec/REVISION_2026-11-24.md` | Уточнение прежнего описания группировщика |
| `spec/tools/expression_grouping_reference.py` | Рекурсивная нормализация графового плана и сохранение атомарных границ |
| `spec/validation/expression_grouping_reference_test.py` | Проверки нормализации, метода-получателя и неизменности источника |
| `spec/validation/expression_grouping_cases_20261124.json`, `spec/validation/signature_expression_cases_20261124.json` | Исправление прежнего singleton-сценария и восемь новых нормативных случаев |
| `spec/validation/expression_planner_host_checks_20261124.json` | Результат 49 host-проверок и контрольные суммы проверенных файлов |

## Проверка

Патч проверен на отдельной копии основы: `git apply --check -p0`, применение, побайтовое совпадение всех 13 полученных файлов с проверенной редакцией. После применения **49 host-тестов проходят**. Проверены нормализованные аргументы авторских примеров, сохранение полного внутреннего выражения, отсутствие переноса `right[0]` в `left`, сохранение исходного графа и контекстов.

Недопустимая материальная подгруппа дошла до тела тестового числового метода одним значением; ошибка возникла внутри метода после успешного планирования. Python-представление подгруппы и Python `TypeError` относятся только к host-тесту и не вводят новый тип или код ошибки LMX.

Нормативные наборы после правки содержат **46 случаев группировки и 23 случая сигнатур**. Исполнение настоящего LMX-парсера, транслятора и runtime имеет статус **NOT_RUN**. Проверочная реализация принимает уже выбранный Expression-граф; production-интеграция принимающих ролей, потоков полей и планировщика эффектов остаётся механизмом проекта.

Сравниваемые клиентские исходники и их размеры этим патчем не меняются. При следующей сборке комплекта обновить производные манифесты и сводные отчёты обычными генераторами; существующие PDF/XLSX относятся к прежней сборке. Архив здесь не пересобирается.

## Как применить

Сохранить этот файл в каталоге, содержащем `spec`. Из него извлекается единственный блок unified diff:

```python
from pathlib import Path

source = Path("LMX_expression_grouping_patch_2026-11-24.md").read_text(encoding="utf-8")
patch = source.split("````diff\n", 1)[1].split("\n````", 1)[0] + "\n"
Path("LMX_expression_grouping_patch_2026-11-24.diff").write_text(patch, encoding="utf-8")
```

Из того же каталога:

```bash
git apply --check -p0 LMX_expression_grouping_patch_2026-11-24.diff
git apply -p0 LMX_expression_grouping_patch_2026-11-24.diff
python spec/validation/expression_grouping_reference_test.py
```

## Unified diff

````diff
--- spec/EXPRESSION_ALGORITHM.md
+++ spec/EXPRESSION_ALGORITHM.md
@@ -51,7 +51,7 @@
 
 Последовательность соседних атомов без операнда между ними остаётся последовательностью. В бинарном случае справа один элемент. В общем случае правый хвост может содержать несколько элементов; количество формалов не используется как скрытый разделитель исходного выражения.
 
-Внутренняя группа сначала остаётся одной единицей внешнего уровня. Её содержимое обрабатывается при выборе соответствующего принимающего договора. Это позволяет одновременно сохранить DATA-описание, группу целого выражения, TYPE-модель и коллектор потока полей.
+Внутренняя группа занимает одну позицию внешнего уровня. В допущенном графе Expression её содержимое рекурсивно планируется; одна полученная единица прозрачна, несколько единиц представлены одной подгруппой. Целая операция остаётся одной единицей, её исходные токены наружу не вставляются. Это структурная нормализация без исполнения. Договоры DATA-описания, полного TYPE, RAW и коллектора потока полей сохраняют свои области; возвращённые значения не обходятся заново как код.
 
 ## 3. Ровно две формы: без левого атома и с одним левым атомом
 
@@ -215,55 +215,66 @@
     return unit
 ```
 
-Вызов `_unit` в первой позиции не требует фиктивного левого элемента. Цикл верхнего уровня повторяет его до конца выбранного структурного уровня; несколько результатов остаются последовательностью. При встрече вложенной группы внешние операции не захватывают её поля до решения о принимаемой роли.
+Вызов `_unit` в первой позиции не требует фиктивного левого элемента. Цикл верхнего уровня повторяет его до конца выбранного структурного уровня; несколько результатов остаются последовательностью. Этот проход строит зависимости на одном уровне. Затем `normalize_expression` рекурсивно подготавливает вложенные Expression-группы, сохраняя каждую как один внешний атом и не перенося её токены через границу приоритетов. Оба шага относятся к общему группировщику; ни один не выполняет тело операнда.
 
 Полный код, включая `Limit`, `Cursor`, `LeftView`, разрешение graph view, общий вызов метода без изменения входного вектора и порядок группового присваивания: [expression_grouping_reference.py](tools/expression_grouping_reference.py).
 
-## 7. Чем алгоритмически было прежнее правило двух групп
-
-Для группового присваивания:
-
-```lmx
-(a b c) := (a c b)
-```
-
-происходят следующие действия:
-
-1. На внешнем уровне найдены левая группа, `:=` и одна правая группа.
-2. Договор группового присваивания потребляет слева последовательность мест, справа последовательность значений. Группировщик выбирает непосредственный уровень каждой принятой группы и группирует находящиеся там операции, если они есть.
-3. Получены две последовательности: `a, b, c` и `a, c, b`. Исходные контейнеры и `parent` не изменены.
-4. **Отдельный адаптер применения** помещает левую последовательность в одну позицию `left`, сохраняя ссылки на места. Правую последовательность он передаёт через массив ссылок `right`.
+## 7. Рекурсивный план и упаковка атомов
+
+Уровень разбирается обычным `Planner.plan`; найденные вложенные Expression-группы проходят тот же алгоритм рекурсивно. После обработки содержимого группы применяется общий принцип **одна внешняя позиция**:
 
 ```text
-План группировщика:       a b c  :=  a c b
+normalizeUnit(unit):
+    если это группа в допущенной позиции Expression:
+        children = normalizeExpression(planLevel(unit.graph, unit.context))
+        если children содержит одну единицу:
+            payload = единственная единица
+        иначе:
+            payload = Group(children)  # включая присутствующую пустую группу
+        вернуть один AtomView(payload, исходное вхождение и контекст)
+    если это полная операция:
+        рекурсивно нормализовать её Expression-аргументы
+        сохранить её границы, приоритетный план, исходные вхождения и left/right
+    иначе:
+        сохранить единицу по её принимающему договору
+
+normalizeExpression(sequence):
+    вернуть последовательность normalizeUnit(item) для каждого item
+    # не соединять поля соседних результатов-Group
+```
+
+Это внутренние представления, не новые поля графа, системные функции или изменения `OPERANDS_TEMPLATE`. В проверочном коде тонкая обёртка называется `PreparedAtom`, а материальная подгруппа — `PreparedGroup`. У единственного вложенного группового результата нормализуется его представление, поэтому `(((5 6)))` не сохраняет три контейнера в готовом плане: это один внешний атом с подгруппой `(5 6)`. Исходные узлы и контексты остаются доступны через представление.
+
+**Нельзя просто подставить внутренний `Apply` вместо группового атома.** Для `2 * (3 + 4)` вычисляемый payload — целое применение `+`; для внешнего уровня это один атом. Иначе поиск соседнего левого атома может ошибочно войти во внутренний `+` и выбрать только `4`. `PreparedAtom` сохраняет эту границу, а `LeftView` по-прежнему хранит исходное вхождение и вычислительный контекст для каждого присутствующего `left`.
+
+```lmx
+1 + 2 (((3))) (4) ((5))       # нормализованный right: 2, 3, 4, 5
+1 + 2 (((5 6))) (4) 5        # right: 2, одна подгруппа (5 6), 4, 5
+1 + 2 (+ 5 6) 4 5           # right: 2, одна вычисляемая единица, 4, 5
+```
+
+Во втором случае план строится успешно. Числовое несоответствие подгруппы проверяет `+` при обычном потреблении. Группировщик не добавляет операцию между `5` и `6` и не проверяет правила сложения. В третьем случае операция задана: внутренний `+` получает отсутствующий `left` и оба значения справа. Никакой перенос первого правого аргумента в `left` на этой стадии не допускается.
+
+### Выбор последовательности и прежнее правило двух групп
+
+После рекурсивной нормализации последовательностный потребитель выбирает элементы единственной материальной подгруппы либо уже имеющиеся соседние элементы. Этот выбор не вычисляет операции и не повторяет обход графа. В широком правом хвосте нормализованные подгруппы остаются отдельными аргументами.
+
+Для `(a b c) := (a c b)` обе группы содержат по три единицы. Последовательностный договор получает `a, b, c` и `a, c, b`; отдельная подготовка применения передаёт всю левую последовательность одним `left`, а три правые единицы — массивом ссылок. Для `(a b c) := (f g h) (f g h) (f g h)` справа уже три нормализованные подгруппы: их поля не сливаются в девять аргументов.
+
+```text
+План последовательностей:   a b c  :=  a c b
 Подготовленное применение: (a b c) := a c b
 ```
 
-Это и есть алгоритмическое содержание прежнего наблюдения «слева безымянная Structure, справа одна безымянная Structure». Левая оболочка в подготовленном применении нужна из-за **единственного аргумента `left`**. Её сохраняет или создаёт адаптер, а не обычный группирующий проход. Отдельного правила, которое повторно раскрывает RHS после этого, нет.
-
-Для другой записи:
-
-```lmx
-(a b c) := (f g h) (f g h) (f g h)
-```
-
-на текущем правом уровне уже три единицы. Это три Structure. Входить в каждую и объединять их девять полей нельзя. Аналогично `(target) := ((x y))` получает одну внутреннюю Structure `(x y)`.
-
-Существенная часть выбора уровня в проверочном коде:
-
-```python
-def expose_sequence(units, planner):
-    if len(units) == 1 and isinstance(units[0], Unit):
-        unit = units[0]
-        if unit.kind == "group":
-            context = Context(unit.node, unit.context.activation)
-            return planner.plan(unit.node, context)
-    return tuple(units)
-```
-
-Эта функция вызывается **только после выбора последовательностного договора**. Она обрабатывает один выбранный уровень, не повторяет себя для каждой вложенной группы и сохраняет прежнюю активацию. Смена текущего контекста обхода на содержимое группы не меняет физический `parent` какого-либо узла.
-
-Для полного TYPE, одной структурной переменной или DATA-описания выбор другой. Поэтому `int -> (int int)` не превращается в `int -> int int`, а `Name :: (A B)` предоставляет одно DATA-описание; его непосредственные декларации затем читает общий DATA-механизм.
+`(a b) := (((x y)))` после нормализации единственной группы получает две правые единицы `x`, `y`. `(a b) := (((x y))) z` получает две единицы `(x y)` и `z`. `(a b c) := (((x y)))` отклоняется по количеству до первой записи. Утверждение прежней редакции, что дополнительные singleton-оболочки обязательно сохраняют внутреннюю группу как единственный элемент выбранной последовательности, заменено этим правилом.
+
+У адаптера применения нет второго независимого раскрывающего прохода: рекурсивная работа принадлежит группировщику, а `prepare_actuals` только упаковывает уже выбранные ссылки. Отсутствующий `left` сохраняется. Полный TYPE, одна готовая структурная величина и DATA-описание сохраняют собственные принимающие договоры; `int -> (int int)` по-прежнему не становится `int -> int int`.
+
+### Граф, контекст и отложенные эффекты
+
+Каждое вхождение сохраняет исходный графовый диапазон и контекст. Ссылки разрешаются без изменения фактического `parent`. Применяется общая развилка имени/`parent`, а не тест написания скобок. Повторные вхождения одной цели остаются разными вхождениями; структурная подготовка не склеивает их эффекты.
+
+Нормализация не является исполнением всего достижимого графа. Тело ресивера, DATA-инициализатор, RAW и возвращённое готовое значение не обходятся как новый CODE по факту наличия структурных полей. `PreparedAtom` хранит готовый план Expression; настоящий запрос результата, порядок эффектов и короткое замыкание обеспечивает общий механизм исполнения. Представление обратного графового ребра в host-модели сохраняет конечный план; оно не устанавливает новые правила выполнения циклических графов LMX.
 
 ## 8. Вложенное выражение, поток полей и ссылка
 
@@ -330,7 +341,7 @@
 python validation/expression_grouping_reference_test.py
 ```
 
-[Host-отчёт](validation/expression_planner_host_checks_20261124.json) фиксирует выполненные проверки текущего алгоритма. Проверяются: отсутствие `left`, несколько элементов `right`, два соседних операнда с разными приоритетами, направленная степень, общий вид левого вхождения без исключений для присваивания, потребление в самом методе, цепочка присваиваний, обе формы правых групп, сохранение контекста и три ветви имени/`parent`. Отдельно проверяется снимок RHS до записи и отсутствие записи при ошибке проверки.
+[Host-отчёт](validation/expression_planner_host_checks_20261124.json) фиксирует выполненные проверки текущего алгоритма. Проверяются: отсутствие `left`, несколько элементов `right`, два соседних операнда с разными приоритетами, направленная степень, общий вид левого вхождения без исключений для присваивания, потребление в самом методе, цепочка присваиваний, обе формы правых групп, сохранение контекста и три ветви имени/`parent`. Отдельно проверяются рекурсивная нормализация одиночных групп, сохранение материальной подгруппы, обработка соседних групп с операциями, отказ числового метода после успешного планирования, граница целого внутреннего Apply, исходный граф без изменений и повторное использование уже подготовленных вхождений. Снимок RHS и проверка количества предшествуют первой записи.
 
 Проверочный код анализирует графовые единицы и строит план. Маленький host consumer подтверждает только перечисленные наблюдения; он не доказывает общий порядок эффектов, короткое замыкание или время жизни production-активаций. Для них требуется существующий механизм востребованности и продолжений LMX. Код не реализует P0, физическое хранение LMX, разрешение динамических имён, весь набор designator, native calls, TYPE admission или полный runtime. Эти механизмы подключаются из проекта; их отсутствие не заменяется выдуманными публичными функциями. Нормативные случаи для реального LMX находятся в [expression_grouping_cases_20261124.json](validation/expression_grouping_cases_20261124.json) и остаются **NOT_RUN**.
 
--- spec/EXPRESSION_GROUPING.md
+++ spec/EXPRESSION_GROUPING.md
@@ -52,7 +52,7 @@
 
 У `S` владелец `data`, а выражение обходится в лексическом контексте `code`. Первая строка достигает по ссылке группу с другим `parent`; во второй группа безымянная. Обе обрабатываются как группы, без лексической подстановки `S: ...` и без вызова `S`. Это утверждение о группировке, а не обещание числового результата для четырёхатомного материала. Вложенные имена разрешаются с сохранением действительного контекста каждой группы. [Норма parent-развилки](LMX_semantics.en.md#expression-structure-parent-guard).
 
-В исполняемой позиции группа с одним полным выражением предоставляет результат этого выражения. Это применяется и к вложенным группам:
+В Expression группировщик рекурсивно обрабатывает каждую допущенную группу чистого графа. Одна полученная единица становится одним прозрачным атомом внешнего уровня; несколько единиц сохраняются одной подгруппой. Единица может быть атомом, подгруппой или целым выражением с уже определёнными приоритетами. Обработка не исполняет операции. В исполняемой позиции одна полная вычисляемая единица предоставляет свой результат по обычному запросу. Это применяется и к вложенным группам:
 
 | Выражение | Результат |
 | --- | ---: |
@@ -98,22 +98,55 @@
 
 Контейнер слева нужен потому, что у операнда одна левая позиция. Его сохранение или подготовка относится к применению операнда, а не к тому участку группировщика, который определяет группы. Ссылки продолжают указывать на исходные места; упаковка не копирует значения мест и не создаёт скрытую функцию.
 
-## 4. Текущий уровень сохраняет границы соседних структур
-
-При отсутствии операндов между элементами поток состоит из элементов выбранного текущего уровня. Соседние структуры не раскрываются рекурсивно.
+## 4. Рекурсивная группировка и подгруппы
+
+Группировщик рекурсивно обрабатывает весь предоставленный ему граф Expression. Он сохраняет исходный граф и строит временное представление в памяти. Ни скобки, ни количество написанных оболочек не являются входными признаками этого алгоритма.
+
+Содержимое каждой группы сначала разбирается с учётом внутренних операций и их приоритетов. Результат этой обработки представляется **одним элементом охватывающего уровня**:
+
+1. Одна единица проходит без дополнительной семантической оболочки. Это относится также к единственной единице, которая сама является подгруппой: `(((5 6)))` представляет ту же подгруппу `(5 6)`.
+2. Несколько единиц сохраняются одной подгруппой. Они не присоединяются к соседним аргументам охватывающего уровня.
+3. Пустая группа остаётся одним присутствующим пустым групповым элементом; она не означает отсутствующий аргумент.
+
+Это тот же принцип упаковки нескольких единиц в одну позицию, который применяется при подготовке `left`. У `right` такой контейнер является **подгруппой внутри массива аргументов**. Построение временного группового представления не заменяет отдельную подготовку ABI `left`/`right`.
+
+```lmx
+1 + 2 (((3))) (4) ((5))
+1 + 2 3 4 5
+
+1 + 2 (((5 6))) (4) 5
+1 + 2 (5 6) 4 5
+```
+
+Каждая пара имеет один нормализованный план. Во второй паре `right` содержит четыре элемента: `2`, подгруппу `(5 6)`, `4`, `5`. Группировщик не добавляет недостающую операцию, не превращает подгруппу в два внешних аргумента и не проверяет числовой допуск `+`. В авторском арифметическом примере такую подгруппу отклоняет сам метод `+`.
+
+```lmx
+1 + 2 (+ 5 6) 4 5
+```
+
+Здесь сложение внутри группы указано явно. `(+ 5 6)` — одна вычисляемая единица; сам внутренний метод получает отсутствующий `left` и `right = [5, 6]`. Группировщик и передача не превращают этот вход в `left = 5`, `right = [6]`. Равнозначность с `(5 + 6)` обеспечивает тело метода. По тому же принципу `2 * (3 + 4)` сохраняет целую внутреннюю единицу `3 + 4`, а не вставляет её исходные токены во внешний уровень.
+
+### Нормализация и чтение последовательности
+
+Нормализация каждого вложенного элемента и выбор элементов группы последовательностным получателем — разные шаги. Если такой получатель принимает элементы единственной нормализованной подгруппы, он получает её элементы. Если эта подгруппа соседствует с другими аргументами, она остаётся одним элементом внешнего потока.
 
 | Исходная запись | Один `left` | Элементы `right` |
 | --- | --- | --- |
 | `(a b c) := (a c b)` | Контейнер трёх мест | Три значения: `a`, `c`, `b` |
-| `(a b c) := (f g h) (f g h) (f g h)` | Контейнер трёх мест | Три Structure, по одной на каждую правую группу |
-| `(target) := ((x y))` | Контейнер одного места | Одна внутренняя Structure `(x y)` |
+| `(a b c) := (f g h) (f g h) (f g h)` | Контейнер трёх мест | Три подгруппы, не девять полей |
+| `(a b c) := (x + 1) (y * 2) (z - 3)` | Контейнер трёх мест | Три вычисляемые единицы; внутренние операции обработаны |
+| `(a b) := (((x y)))` | Контейнер двух мест | Два значения `x`, `y`: прозрачные оболочки сняты в плане до чтения последовательности |
+| `(a b) := (((x y))) z` | Контейнер двух мест | Два элемента: подгруппа `(x y)` и `z` |
+| `(a b c) := (((x y)))` | Контейнер трёх мест | Два значения: ошибка количества до первой записи |
 | `(a b) := copy(Pair)` | Контейнер двух мест | Выданный поток полей `Pair` |
 | `(a b) := (copy(Pair))` | Контейнер двух мест | Тот же поток полей на принимаемом уровне |
 | `ptr := (copy(Pair))` | Одно обычное ссылочное место | Один собранный структурный результат |
 
-Таким образом, прежняя формулировка «единственная правая безымянная Structure раскрывается при безымянной Structure слева» описывала наблюдаемый результат для таких последовательностных применений. Этот результат сохраняется и объясняется работой группировщика и подготовкой одного `left`. После них нет второго прохода «ещё раз раскрыть правую группу».
-
-Договор получателя определяет, требуется ли последовательность текущего уровня или один целый аргумент. Групповое присваивание принимает последовательности мест и значений; обычное ссылочное место принимает одно значение. Полная модель TYPE и DATA-описание также сохраняют установленные границы. Форма дерева и один `left` сами по себе не задают смысл неизвестного пользовательского операнда. [Норма и таблица границ](LMX_semantics.en.md#operand-right-only-opening).
+Для ссылочных мест в таблице предполагается обычный допуск показанных значений. Нормализация сама его не устанавливает. Прозрачная `(target)` не служит скрытым признаком выбора особого договора: принимается нормализованный материал, без проверки того, был ли атом когда-то записан в скобках.
+
+Прежняя формулировка «единственная правая безымянная Structure раскрывается при безымянной Structure слева» описывала результат последовательностного потребления и упаковки одного `left`. **Рекурсия уже входит в группировщик.** Фраза «после группировки нет дополнительного раскрывающего прохода» относится только к адаптеру применения: он не начинает группировку заново и не объединяет поля соседних подгрупп. Эта фраза не запрещает обход внутренних групп и обработку находящихся в них операций.
+
+Принимающие роли целого VALUE, TYPE, DATA и RAW сохраняются. Готовый результат вызова не превращается в новый исходник Expression; результат-Structure не раскрывается по числу полей. Коллекторы потоков сохраняют свой договор независимо от числа выданных полей. [Норма и таблица границ](LMX_semantics.en.md#operand-right-only-opening), [алгоритм](EXPRESSION_ALGORITHM.md).
 
 ## 5. Групповому присваиванию не нужна дополнительная оболочка `copy`
 
@@ -179,7 +212,10 @@
     operations = resolve_receivers_and_ready_priorities(units, context)
     plan = group_dependencies_and_complete_expressions(units, operations)
     plan = retain_data_models_bodies_and_field_collectors(plan)
-    return select_current_level_sequences(plan, receiving_contract)
+    plan = normalize_expression_groups_recursively_in_memory(plan)
+    # Одна единица прозрачна; 0 или несколько единиц дают одну подгруппу.
+    # Целое внутреннее выражение сохраняет границу одного внешнего атома.
+    return select_prepared_sequences(plan, receiving_contract)
 
 
 def prepare_operand_application(plan, operand_contract):
@@ -197,13 +233,13 @@
     return existing_actuals(left, right)  # без переноса right[0] в left
 ```
 
-Во внутреннем плане могут существовать две последовательности. На публичную форму аргументов это не влияет: анализатор готовит один `left` и массив ссылок `right`. Нет повторного раскрытия справа при передаче. `RxLogicalArguments.collect` вызывается внутри метода операнда, а `asOperand` помещает его в создаваемое тело; их алгоритм вправе обработать переданные формы по собственному договору. [Подробный алгоритм разбора графа](EXPRESSION_ALGORITHM.md) содержит полный проход по текущему уровню, отсутствие `left`, приоритеты, PLACE-зависимости и отдельную подготовку применения; рядом поставлен исполняемый проверочный код на Python.
+Во внутреннем плане могут существовать две последовательности. На публичную форму аргументов это не влияет: анализатор готовит один `left` и массив ссылок `right`. Нет повторного раскрытия справа при передаче. `RxLogicalArguments.collect` вызывается внутри метода операнда, а `asOperand` помещает его в создаваемое тело; их алгоритм вправе обработать переданные формы по собственному договору. [Подробный алгоритм разбора графа](EXPRESSION_ALGORITHM.md) содержит проход по текущему уровню, рекурсивную нормализацию графа в памяти, отсутствие `left`, приоритеты, PLACE-зависимости и отдельную подготовку применения; рядом поставлен исполняемый проверочный код на Python.
 
 Для группового присваивания подготовка значений включает снимок всех RHS и полную проверку до записи. Для короткого замыкания, отложенного BODY и RAW используются существующие правила востребованности; группировка не разрешает заранее выполнить все найденные вызовы.
 
 ## 8. Проверяемые следствия
 
-[Нормативные приёмочные случаи](validation/expression_grouping_cases_20261124.json) фиксируют вложенную арифметическую группировку, два авторских примера присваивания, bare/wrapped `copy`, границы TYPE/DATA/RAW, целые значения, контейнеры с нулём/одним/несколькими полями и отсутствие неявной свёртки. [Случаи сигнатур](validation/signature_expression_cases_20261124.json) проверяют согласование с `::` и `->`.
+[Нормативные приёмочные случаи](validation/expression_grouping_cases_20261124.json) фиксируют авторские цепочки одиночных групп, материальные подгруппы среди соседних аргументов, операции внутри групп, вложенную арифметическую группировку, примеры присваивания, bare/wrapped `copy`, границы TYPE/DATA/RAW, целые значения, контейнеры с нулём/одним/несколькими полями и отсутствие неявной свёртки. [Случаи сигнатур](validation/signature_expression_cases_20261124.json) проверяют согласование с `::` и `->`.
 
 В клиентском R02 убрана лишняя оболочка: `(a b) := copy(Pair)`. То же сокращение применено в двух библиотечных примерах и их combined-копиях. Контейнеры для скалярных присваиваний сохранены. Сравнительные таблицы пересчитываются из полных исходников; проверка соответствия документации и исходников не заменяет запуск реального транслятора.
 
--- spec/LMX_semantics.en.md
+++ spec/LMX_semantics.en.md
@@ -829,10 +829,24 @@
 without effects; ordinary demand, short-circuiting and once-per-occurrence
 evaluation decide when its operations run.
 
-A single physical child is not enough to classify a group as an expression.
-`(1 2 3 4)` is material containing four neighboring atoms, not an implicit
-operation over them; `((1 2))` does not lose its nested material level.
-The result contract also matters: `(copy(Model))` collects a **field stream**
+The grouper recursively normalizes every group in the admitted Expression
+graph. One resulting unit is transparent; several units form one subgroup
+of the enclosing level; an empty group remains present. Thus `(((1 2)))`
+represents one subgroup `(1 2)`, not a chain of single-unit wrappers.
+`(1 2 3 4)` remains a material subgroup: no operation is invented between
+its atoms. A complete operation is one unit: `2 * (3 + 4)` does not splice
+its inner tokens into the enclosing level. Source graph and contexts survive.
+
+`1 + 2 (((5 6))) (4) 5` and `1 + 2 (5 6) 4 5` have the same plan:
+the right items are `2`, subgroup `(5 6)`, `4`, `5`. Planning does not check
+numeric admission; the author's arithmetic example is refused by `+` itself.
+`1 + 2 (+ 5 6) 4 5` explicitly supplies the inner operation as one computable
+unit. The inner prefix `+` receives absent left and both right arguments;
+equivalent addition is implemented inside the method.
+[Algorithm and atomic plan view](EXPRESSION_ALGORITHM.md).
+
+The number of plan units is not the number of emitted runtime values.
+The result contract matters: `(copy(Model))` collects a **field stream**
 into a Structure even when that stream produces zero or one field. It is not
 reclassified as a scalar expression after counting the output. Thus
 `ptr := (copy(()))` supplies one empty Structure to the existing reference
@@ -894,9 +908,12 @@
     in CODE/Expression: named with the current lexical owner as parent -> ordinary receiver/call
     retain whole VALUE/TYPE/DATA contracts before this CODE classification
     resolve operation contracts and ready priorities without running bodies
-    group dependencies and complete expression units at each graph level
+    recursively group dependencies and complete units in the admitted Expression graph
+    represent a group result: one unit is transparent; zero or several units form one subgroup
+    retain one enclosing atom boundary, original occurrences and contexts
     retain DATA/model material and declared field-stream collectors
-    expose only the current-level sequence required by the receiving contract
+    select elements of a sole normalized group when the receiver consumes a sequence
+    otherwise retain neighboring normalized items without splicing subgroup fields
     retain the same LeftView(focus, valuePlan, context) for every present left
     return structured operation/sequence plan with original occurrences
 
@@ -1055,13 +1072,18 @@
 `a b c` and `a c b` around the assignment operation. These are plan units, not
 a replacement source string. The application then delivers one left bundle
 `(a b c)` and three right references. Three sibling RHS groups instead remain
-three items at that level; their children are not recursively flattened.
+three items at that level. Every group is processed recursively, but fields
+of neighboring material subgroups are not spliced. Single-unit wrappers
+are transparent. A sequence consumer of a sole normalized group reads its
+elements; application adaptation does not restart that recursion.
 
 | Written expression | Receiving contract / one left actual | Right sequence or whole item |
 | --- | --- | --- |
 | `(a b c) := (a c b)` | One bundle of three PLACE targets | Three value occurrences `a`, `c`, `b` |
 | `(a b c) := (f g h) (f g h) (f g h)` | One bundle of three PLACE targets | Three Structure values, one for each written group |
-| `(target) := ((x y))` | One bundle containing one PLACE | One inner Structure `(x y)`; no recursive flattening |
+| `(a b) := (((x y)))` | One bundle of two PLACE targets | Values `x`, `y` after normalization of the sole group |
+| `(a b) := (((x y))) z` | One bundle of two PLACE targets | Subgroup `(x y)` and value `z` |
+| `(a b c) := (x + 1) (y * 2) (z - 3)` | One bundle of three PLACE targets | Three computable units with their inner operations processed |
 | `(a b) := copy(Pair)` | Two-place sequence consumer | The emitted field stream |
 | `(a b) := (copy(Pair))` | The same two-place consumer | The same current-level fields, with the collector preserved in P0 |
 | `ptr := (copy(Pair))` | One ordinary reference place | One collected Structure |
@@ -1407,7 +1429,8 @@
 | `(a b c) := (f g h) (f g h) (f g h)` | Three Structure values, not nine fields |
 | `(a b) := copy(Pair)` | The two emitted fields of `Pair` |
 | `(a b) := (copy(Pair))` | The same two fields through the explicit collector |
-| `(target) := ((x y))` | One inner Structure for one target |
+| `(a b) := (((x y)))` | Values `x`, `y` for two targets |
+| `(a b c) := (((x y)))` | Two values for three targets; refusal before the first write |
 | `(a b c) := myFn()` | One returned value; a returned Structure is not automatically opened |
 
 The two `copy` forms are equivalent for this sequence-consuming assignment
@@ -1415,7 +1438,9 @@
 the former prohibition of bare `(a b) := copy(Pair)` and the former requirement
 that every group assignment have exactly one written RHS group are superseded
 by the author's clarification of 2026-11-24. Several current-level RHS items
-are allowed and are never recursively flattened.
+are allowed. Their groups are processed recursively: single-unit wrappers
+are transparent and several units remain one subgroup; fields of neighboring
+subgroups are never spliced.
 
 For a single ordinary reference place, `ptr := (copy(Pair))` still assigns one
 collected Structure. Bare `ptr := copy(Pair)` remains a field stream and follows
@@ -3893,7 +3918,7 @@
 
 ### Construction, source rules and verification
 
-Expression is the ordinary Structure graph interpreted with a [structural grouper](#expression-structural-grouping): it determines priorities, complete expression units and streams at the current tree level, independently of source spelling. A separate Expression application adapter packages left as one actual/reference bundle and right as an Array of references. `arg0 operand arg1 arg2 arg3` is the general form; a binary contract uses one right item, with no automatic fold or movement of the first right item into an absent left. The receiving contract selects whole-value or current-level sequence consumption. `(a b c) := (a c b)` therefore has one left bundle and three right values; three sibling RHS groups remain three Structure items. There is no extra conditional unwrapping pass after grouping. The grouper reads the clean graph. In CODE/Expression, anonymous Structures and named Structures whose actual parent differs from the current lexical owner are groups; named same-parent Structures use ordinary receiver/call handling. Reference resolution preserves the actual parent. Whole VALUE/TYPE/DATA material is not automatically reclassified as CODE. `1 + ((2))` is 3; field collectors such as `(copy(Model))` remain containers for zero, one or many fields. `::` and modifiers keep DATA consumption and the common immediate-field reader; they gain no RHS evaluator. P0, ordinary callable W/E and the existing lifetime/effect rules remain intact. See [architecture and acceptance](EXPRESSION_GROUPING.md); execution is **NOT_RUN**.
+Expression is the ordinary Structure graph interpreted with a [structural grouper](#expression-structural-grouping): it determines priorities, complete expression units and streams at the current tree level, independently of source spelling. A separate Expression application adapter packages left as one actual/reference bundle and right as an Array of references. `arg0 operand arg1 arg2 arg3` is the general form; a binary contract uses one right item, with no automatic fold or movement of the first right item into an absent left. The receiving contract selects whole-value or current-level sequence consumption. `(a b c) := (a c b)` therefore has one left bundle and three right values; three sibling material RHS groups remain three subgroup items. Recursive in-memory normalization already belongs to the grouper; the application adapter adds no conditional unwrapping pass. The grouper reads the clean graph. In CODE/Expression, anonymous Structures and named Structures whose actual parent differs from the current lexical owner are groups; named same-parent Structures use ordinary receiver/call handling. Reference resolution preserves the actual parent. Whole VALUE/TYPE/DATA material is not automatically reclassified as CODE. `1 + ((2))` is 3; field collectors such as `(copy(Model))` remain containers for zero, one or many fields. `::` and modifiers keep DATA consumption and the common immediate-field reader; they gain no RHS evaluator. P0, ordinary callable W/E and the existing lifetime/effect rules remain intact. See [architecture and acceptance](EXPRESSION_GROUPING.md); execution is **NOT_RUN**.
 
 Capture and generated source keep actual parents, private state and the normal
 lifetime rules. Code generation must respect blank-line root termination and
--- spec/LMX_semantics.ru.md
+++ spec/LMX_semantics.ru.md
@@ -732,9 +732,24 @@
 определяется без эффектов; обычный запрос результата, короткое замыкание
 и однократное исполнение вхождения определяют, когда выполняются операции.
 
-Одного физического потомка недостаточно, чтобы признать группу выражением.
-`(1 2 3 4)` — материал с четырьмя соседними атомами, а не неявная операция
-над ними; `((1 2))` не теряет вложенный уровень материала. Важен и договор
+Группировщик рекурсивно нормализует каждую группу в допущенном графе
+Expression. Одна полученная единица прозрачна; несколько единиц становятся
+одной подгруппой внешнего уровня; пустая группа остаётся присутствующей.
+Поэтому `(((1 2)))` представляет одну подгруппу `(1 2)`, а не цепочку
+одноэлементных оболочек. `(1 2 3 4)` остаётся материальной подгруппой:
+операции между её атомами нет, и группировщик её не изобретает.
+Целая операция образует одну единицу: в `2 * (3 + 4)` её токены
+не вставляются во внешний уровень. Исходный граф и контексты сохраняются.
+
+`1 + 2 (((5 6))) (4) 5` и `1 + 2 (5 6) 4 5` имеют одинаковый план:
+справа `2`, подгруппа `(5 6)`, `4`, `5`. Такой план строится без проверки
+числового допуска; в авторском примере подгруппу отклоняет сам `+`.
+`1 + 2 (+ 5 6) 4 5` задаёт внутреннюю операцию явно, и она остаётся
+одной вычисляемой единицей. Внутренний префиксный `+` получает отсутствующий
+left и два правых аргумента; их эквивалентное сложение обеспечивает метод.
+[Алгоритм и представление атома](EXPRESSION_ALGORITHM.md).
+
+Число единиц плана не подменяется числом выданных значений. Важен договор
 результата: `(copy(Model))` собирает **поток полей** в Structure даже при
 нуле или одном выходном поле. После подсчёта результата он не становится
 скалярным выражением. Поэтому `ptr := (copy(()))` передаёт одну пустую
@@ -794,9 +809,12 @@
     в CODE/Expression: именованная с parent текущего lexical owner -> обычный ресивер/вызов
     до этой CODE-классификации сохранить договоры целого VALUE/TYPE/DATA
     разрешить контракты операций и готовые приоритеты без исполнения тел
-    сгруппировать зависимости и целые выражения на каждом уровне графа
+    рекурсивно сгруппировать зависимости и целые выражения в допущенном графе Expression
+    для результата группы: одна единица прозрачна, 0 или >1 единиц дают одну подгруппу
+    сохранить границу одного внешнего атома, исходные вхождения и контексты
     сохранить DATA/модели и коллекторы с договором потока полей
-    выделить последовательность только текущего уровня по принимающему договору
+    выбрать элементы единственной нормализованной группы, если требуется последовательность
+    иначе сохранить соседние нормализованные элементы; их поля не сливать
     сохранить одинаковый LeftView(focus, valuePlan, context) для каждого присутствующего left
     вернуть структурный план операций/последовательностей с исходными вхождениями
 
@@ -960,13 +978,18 @@
 `a b c` и `a c b` вокруг операции присваивания. Это единицы плана, а не
 новая строка исходного кода. Применение затем передаёт один левый пакет
 `(a b c)` и три правые ссылки. Три соседние группы RHS остаются тремя
-элементами этого уровня; их потомки рекурсивно не уплощаются.
+элементами этого уровня. Каждая группа обработана рекурсивно, но поля
+соседних материальных подгрупп не сливаются. Одиночные оболочки прозрачны.
+Последовательностный получатель единственной нормализованной группы
+читает её элементы; адаптер применения не запускает рекурсию заново.
 
 | Записанное выражение | Принимающий договор / один левый actual | Правая последовательность либо целый элемент |
 | --- | --- | --- |
 | `(a b c) := (a c b)` | Один пакет трёх PLACE-целей | Три вхождения значений `a`, `c`, `b` |
 | `(a b c) := (f g h) (f g h) (f g h)` | Один пакет трёх PLACE-целей | Три значения Structure, по одному на каждую группу |
-| `(target) := ((x y))` | Один пакет с одним PLACE | Одна внутренняя Structure `(x y)`; без рекурсивного уплощения |
+| `(a b) := (((x y)))` | Один пакет двух PLACE | Два значения `x`, `y` после нормализации единственной группы |
+| `(a b) := (((x y))) z` | Один пакет двух PLACE | Подгруппа `(x y)` и значение `z` |
+| `(a b c) := (x + 1) (y * 2) (z - 3)` | Один пакет трёх PLACE | Три вычисляемые единицы с обработанными внутренними операциями |
 | `(a b) := copy(Pair)` | Потребитель последовательности для двух мест | Выпущенный поток полей |
 | `(a b) := (copy(Pair))` | Тот же потребитель двух мест | Те же поля текущего уровня; коллектор сохранён в P0 |
 | `ptr := (copy(Pair))` | Одно обычное место-ссылка | Одна собранная Structure |
@@ -1291,14 +1314,17 @@
 | `(a b c) := (f g h) (f g h) (f g h)` | Три значения Structure, а не девять полей |
 | `(a b) := copy(Pair)` | Два выпущенных поля `Pair` |
 | `(a b) := (copy(Pair))` | Те же два поля через явный коллектор |
-| `(target) := ((x y))` | Одна внутренняя Structure для одной цели |
+| `(a b) := (((x y)))` | Два значения `x`, `y` для двух целей |
+| `(a b c) := (((x y)))` | Два значения против трёх целей; отказ до первой записи |
 | `(a b c) := myFn()` | Одно возвращённое значение; возвращённая Structure автоматически не раскрывается |
 
 Две формы `copy` эквивалентны для этого последовательностного договора,
 если `Pair` даёт два допустимых поля. Внешний коллектор необязателен.
 Прежний запрет голого `(a b) := copy(Pair)` и прежнее требование единственной
 написанной RHS-группы заменены уточнением автора от 2026-11-24. Допустимы
-несколько RHS-элементов текущего уровня; рекурсивно они не уплощаются.
+несколько RHS-элементов текущего уровня. Их группы обрабатываются
+рекурсивно: singleton-оболочки прозрачны, несколько единиц сохраняются
+одной подгруппой; поля соседних подгрупп не сливаются.
 
 Для одного обычного места-ссылки `ptr := (copy(Pair))` по-прежнему присваивает
 одну собранную Structure. Голое `ptr := copy(Pair)` остаётся потоком полей
--- spec/REVISION_2026-11-24.md
+++ spec/REVISION_2026-11-24.md
@@ -44,9 +44,9 @@
 
 Expression использует обычное дерево LMX и общий группировщик для приоритетов и групп. Отдельный шаг анализа готовит применение: один `left`, массив ссылок `right`. Это сохраняет принцип компактной записи `head: arg0 arg1 arg2`; публичный `OPERANDS_TEMPLATE` остаётся прежним. Вопрос об обобщении интерфейса закрыт.
 
-`1 + ((2))` даёт 3. В `(a b c) := (a c b)` группировщик выделяет текущие последовательности слева и справа, после чего анализатор упаковывает левую последовательность в один аргумент. Три соседние правые группы остаются тремя Structure, без рекурсивного раскрытия. `(a b c) := copy(d)` непосредственно принимает поток полей; оболочка `(copy(d))` для этого группового присваивания не требуется. Все правые значения и проверки предшествуют первой записи.
+`1 + ((2))` даёт 3. В `(a b c) := (a c b)` группировщик выделяет текущие последовательности слева и справа, после чего анализатор упаковывает левую последовательность в один аргумент. Каждая Expression-группа обрабатывается рекурсивно: одиночные оболочки прозрачны, несколько единиц сохраняются одной подгруппой. Три соседние материальные подгруппы остаются тремя элементами, а операции внутри вычисляемых групп планируются полностью. `(a b c) := copy(d)` непосредственно принимает поток полей; оболочка `(copy(d))` для этого группового присваивания не требуется. Все правые значения и проверки предшествуют первой записи.
 
-Группировщик не удаляет контейнеры `(copy(Model))` в позиции целого значения, не превращает результат вызова в исходный код и не запускает RAW, DATA-инициализаторы или отложенные тела при планировании. Неподтверждённый TYPE-пример раскрытия заменён проверкой границы `(target) := ((x y))`. У RAW целое внутреннее Expression сохраняется одним исходным вхождением с контекстом, без раннего исполнения.
+Группировщик не удаляет контейнеры `(copy(Model))` в позиции целого значения, не превращает результат вызова в исходный код и не запускает RAW, DATA-инициализаторы или отложенные тела при планировании. TYPE-модели сохраняют собственные границы. Дополнительное уточнение заменяет прежнюю проверку `(target) := ((x y))`: `(a b) := (((x y)))` получает два значения, а `(a b) := (((x y))) z` — подгруппу и соседний атом. Авторский пример `1 + 2 (((5 6))) (4) 5` нормализуется к `1 + 2 (5 6) 4 5`; несоответствие числовому договору проверяет сам `+`, не группировщик. У RAW целое внутреннее Expression сохраняется одним исходным вхождением с контекстом, без раннего исполнения.
 
 [Полное описание с псевдокодом](EXPRESSION_GROUPING.md), двуязычная семантика, руководства, библиотечные договоры и примеры согласованы. Добавлены нормативные случаи группировки и parent-развилки; вместе со случаями сигнатур их точное число и статус **NOT_RUN** приведены в отчёте проверки.
 
--- spec/SIGNATURE_EXPRESSION_REVIEW.md
+++ spec/SIGNATURE_EXPRESSION_REVIEW.md
@@ -124,11 +124,12 @@
 | `int -> (int -> int)` | Одно вложенное выражение, дающее один полный TYPE результата. |
 | `int -> ()` | Один присутствующий пустой структурный аргумент; не пустой вектор `right`. |
 | `int -> ((int int))` | Один целый внешний контейнер; дополнительных раскрытий нет. |
-| `(target) := ((x y))` | Для группового присваивания — один элемент последовательности: внутренняя Structure `(x y)`. Вложенные поля не раскрываются повторно. |
+| `(a b) := (((x y)))` | Единственная Expression-группа нормализуется к `(x y)`; последовательностный договор получает два элемента `x`, `y`. |
+| `(a b) := (((x y))) z` | Два соседних элемента: нормализованная подгруппа `(x y)` и `z`. |
 
 Таблица фиксирует границы, а не обещает допуск всех групп как TYPE. Нульарная сигнатура записывается `` `->`(int) ``; `int -> ()` не является её сокращением. У `Name :: A B` два внешних правых вхождения, у `Name :: (A B)` одно DATA-описание, из которого общий механизм читает непосредственные декларации. Предыдущая неподтверждённая иллюстрация раскрытия TYPE в `(int int) -> ((char char))` снята: одна форма левого аргумента не разрешает раскрывать модель справа. [Точная норма текущего уровня](LMX_semantics.en.md#operand-right-only-opening).
 
-Для группового присваивания прежнее наблюдение о единственной правой группе следует из общего плана: `(a b c) := (a c b)` даёт две последовательности текущего уровня; подготовка применения упаковывает левую в один actual, а справа оставляет три значения. Три соседние правые группы дают три Structure. Дополнительного раскрывающего прохода нет. По той же причине `(a b c) := copy(d)` принимается без оболочки вокруг уже выданного потока полей.
+Для группового присваивания прежнее наблюдение о единственной правой группе следует из общего плана: `(a b c) := (a c b)` даёт две последовательности текущего уровня; подготовка применения упаковывает левую в один actual, а справа оставляет три значения. Три соседние материальные группы дают три подгруппы; внутренние Expression-операции и одиночные оболочки обрабатываются рекурсивно. Дополнительного прохода у адаптера нет: он получает уже нормализованный план. Для целого TYPE в таблице сохраняется его собственный договор, а не переносится последовательностное потребление. По той же причине `(a b c) := copy(d)` принимается без оболочки вокруг уже выданного потока полей.
 
 ## 6. Как `::` использует общий механизм
 
--- spec/patterns/LMX_regression_examples.to_fable.en.md
+++ spec/patterns/LMX_regression_examples.to_fable.en.md
@@ -975,12 +975,16 @@
 changing `Array<T>` into `Array<@>` by reinterpreting its backing.
 
 
-Also inspect the current-level plan and the separate application-adapter snapshot with an unconstrained operand probe. `a`, `b`, `c`, and `d` stand for inert values in these shape checks. The probe must admit the shown value shapes; this table does not assert admission to a particular typed operation. Checking the supplied references does not require invoking the probe body.
+Also inspect the current-level plan and the separate application-adapter snapshot with an unconstrained operand probe. `a`, `b`, `c`, and `d` stand for inert values in these shape checks. The probe must admit the shown value shapes; this table does not assert admission to a particular typed operation. Select the stated sequence or whole-value consumption explicitly in the harness; the generic operand does not acquire a contract from its name or a vanished singleton wrapper. Checking the supplied references does not require invoking the probe body.
 
 | Written application | RIGHT supplied by the application adapter | LEFT supplied by the application adapter |
 | --- | --- | --- |
 | `(a b) probe (c d)` | Two immediate right values, c and d | The original whole `(a b)` Structure |
-| `(a b) probe ((c d))` | One unnamed inner Structure `(c d)`; do not open it again | The original whole `(a b)` Structure |
+| `(a b) probe (((c d)))`, sequence consumption | Two right values c and d after normalization of the sole group | One bundle referring to a and b |
+| `(a b) probe (((c d))) 7`, sequence consumption | Two right items: normalized subgroup `(c d)` and 7 | One bundle referring to a and b |
+| `1 probe 2 (((3))) (4) ((5))` | Four right units: 2, 3, 4, 5 | Scalar 1 |
+| `1 probe 2 (((5 6))) (4) 5` | Four right units: 2, subgroup `(5 6)`, 4, 5 | Scalar 1 |
+| `1 probe 2 (+ 5 6) 4 5` | Four right units, the second being one complete prefix application of + | Scalar 1 |
 | `(a b) probe ()` | Zero current-level right items | The original whole `(a b)` Structure |
 | `1 probe (c d)` | One whole Structure in the plan for scalar LEFT | The scalar 1 |
 | `probe (c d)` with omitted LEFT | One whole Structure in the plan with omitted LEFT | Still omitted; no first-right shift |
@@ -989,7 +993,7 @@
 | `Name :: (A B)` | One whole right-hand Structure | Declaration identifier Name |
 | `Name :: A B` | Two right arguments, A and B | Declaration identifier Name |
 
-The grouper receives the pure graph and represents the left segment and the right current-level stream separately. Parentheses in the displayed cases describe that graph, not delimiter flags available to this phase. The Expression application adapter then packages the full left segment as one actual and the right items as an Array of references. The old anonymous-LEFT/sole-anonymous-RIGHT formulation is a corollary of these plan and ABI results, not an independent opening pass. A group that is already one item of the selected stream remains one item; neither the adapter nor the operand body repeats grouping. A ready value consumed as VALUE/TYPE/DATA does not automatically become CODE. In a CODE/Expression graph an anonymous Structure is always a group. A named Structure is a group when its parent differs from the current lexical parent; when those parents coincide, ordinary call processing applies. This decision uses the node name and parent, not whether the node was written inline or reached through a reference. The group case preserves the original parent and introduces no call. The grouper receives the graph without parentheses. The named `::` rows retain the shown right-argument counts, and all their arguments are DATA.
+The grouper receives the pure graph and represents the left segment and the right current-level stream separately. Parentheses in the displayed cases describe that graph, not delimiter flags available to this phase. The Expression application adapter then packages the full left segment as one actual and the right items as an Array of references. The old anonymous-LEFT/sole-anonymous-RIGHT formulation is a corollary of these plan and ABI results, not an independent opening pass. The grouper recursively normalizes every admitted Expression group before supply. One resulting unit is transparent; zero or several units remain one subgroup. Normalized neighboring subgroups are not spliced, and complete inner applications retain their atomic boundaries. The adapter and operand body do not repeat grouping or invent an operation between material atoms. The operand method alone checks admission of the supplied values. A ready value consumed as VALUE/TYPE/DATA does not automatically become CODE. In a CODE/Expression graph an anonymous Structure is always a group. A named Structure is a group when its parent differs from the current lexical parent; when those parents coincide, ordinary call processing applies. This decision uses the node name and parent, not whether the node was written inline or reached through a reference. The group case preserves the original parent and introduces no call. The grouper receives the graph without parentheses. The named `::` rows retain the shown right-argument counts, and all their arguments are DATA.
 
 Verify the retained source graph separately: P0 keeps every original group in all rows. Grouping produces a structured plan, not replacement source text, and the application adapter packages that plan without a second opening pass. `::` does not acquire an extra Frame or an automatic `end: Name` terminator. Ordinary callable W/E candidate selection is unchanged. Anonymous CODE Structures execute in place; this does not introduce a call or a new activation.
 
--- spec/patterns/OPERAND_USAGE_PROFILE.md
+++ spec/patterns/OPERAND_USAGE_PROFILE.md
@@ -28,7 +28,7 @@
 
 `right` — массив ссылок на правые аргументы. Его наличие не создаёт автоматический fold: бинарная операция задаёт один правый аргумент, вариадическая явно обходит все элементы. Пустой массив и отсутствие аргумента различаются по обычному контракту. Число правых элементов определяется планом текущего уровня Expression; контейнерное значение не превращается автоматически в список своих полей.
 
-После P0 группировщик Expression получает чистый граф и по его структуре, приоритетам и договорам операций строит план с отдельным левым участком и правым потоком текущего уровня. Это структурный план, а не строка для повторного разбора. Затем отдельный адаптер применения Expression упаковывает весь левый участок в один actual `left`, а правые элементы — в массив ссылок `right`. Например, для `(a b) op (c d)` адаптер передаёт целую левую группу и два правых элемента c, d; для `(a b) op ((c d))` — один правый элемент, внутреннюю группу `(c d)`. Прежняя формулировка об anonymous LEFT и единственной anonymous RIGHT описывает эти результаты группировки и ABI, а не отдельное снятие скобок после них. Три соседние правые группы остаются тремя элементами текущего уровня; адаптер не запускает повторную группировку. Готовое значение в принимающей роли VALUE/TYPE/DATA не становится CODE автоматически. В графе CODE/Expression безымянная Structure всегда является группой. Именованная Structure является группой, если её parent отличается от текущего lexical parent; при совпадении выполняется обычный вызов. Решение зависит от имени и parent узла, а не от записи через ссылку или встраивания. Для группового случая исходный parent сохраняется и вызов не вводится. Группировщик получает граф без скобок. P0 сохраняет исходный граф. Обычный выбор W/E у callable остаётся самостоятельным правилом. В `Name :: (A B)` справа одна целая Structure, а в `Name :: A B` — два аргумента; все аргументы `::` потребляются в DATA.
+После P0 группировщик Expression получает чистый граф и по его структуре, приоритетам и договорам операций строит план с отдельным левым участком и правым потоком текущего уровня. Это структурный план, а не строка для повторного разбора. Затем отдельный адаптер применения Expression упаковывает весь левый участок в один actual `left`, а правые элементы — в массив ссылок `right`. Для `op` с выбранным последовательностным договором `(a b) op (c d)` и `(a b) op (((c d)))` передают целую левую группу и два правых элемента c, d. В `(a b) op (((c d))) 7` справа два элемента: нормализованная подгруппа `(c d)` и 7. Группировщик рекурсивно обрабатывает каждую Expression-группу: одна единица прозрачна, несколько единиц представляются одной подгруппой. Для целой вычисляемой единицы сохраняются её границы и приоритеты; правила самого `op` не проверяются группировщиком. Прежняя формулировка об anonymous LEFT и единственной anonymous RIGHT описывает эти результаты группировки и ABI, а не отдельное снятие скобок после них. Три соседние правые группы остаются тремя элементами текущего уровня; адаптер не запускает повторную группировку. Готовое значение в принимающей роли VALUE/TYPE/DATA не становится CODE автоматически. В графе CODE/Expression безымянная Structure всегда является группой. Именованная Structure является группой, если её parent отличается от текущего lexical parent; при совпадении выполняется обычный вызов. Решение зависит от имени и parent узла, а не от записи через ссылку или встраивания. Для группового случая исходный parent сохраняется и вызов не вводится. Группировщик получает граф без скобок. P0 сохраняет исходный граф. Обычный выбор W/E у callable остаётся самостоятельным правилом. В `Name :: (A B)` справа одна целая Structure, а в `Name :: A B` — два аргумента; все аргументы `::` потребляются в DATA.
 
 Для списка мест `(a b) := copy(Pair)` копирование непосредственно даёт правый поток. Форма `(a b) := (copy(Pair))` даёт здесь тот же результат и не нужна в кратчайшем клиенте. Это не разрешает убирать контейнер из `ptr := (copy(Model))` или разворачивать аргумент-контейнер `partial`: их принимающие договоры и границы значений сохраняются.
 
@@ -67,7 +67,7 @@
 
 This comparison profile explicitly supplies the ordinary DATA fragment `sys\OPERANDS_TEMPLATE`, with prepared-value mode 0 and addition priority and without a forced result type. The structural requirement alone does not create this object or a new system API. The common library independently uses `FxPreparedOperands` and explicit operation priorities. A copied header is counted in each operator implementation. Callable values are references until explicitly invoked. A right-argument Array does not imply an automatic fold.
 
-After P0, the Expression grouper receives a pure graph and uses its structure, operation priorities and contracts to produce a structured plan with a left segment and a right stream at the current level. It does not produce text for reparsing. A separate Expression application adapter packages the entire left segment as one `left` actual and the right items as the `right` Array of references. Thus `(a b) op (c d)` supplies one whole left group and two right items c and d; `(a b) op ((c d))` supplies one inner right group `(c d)`. The former anonymous-LEFT/sole-anonymous-RIGHT condition describes these grouping and ABI results; it is not a later opening pass. Three adjacent right groups remain three current-level items; the adapter does not repeat grouping. A ready value consumed as VALUE/TYPE/DATA does not automatically become CODE. In a CODE/Expression graph an anonymous Structure is always a group. A named Structure is a group when its parent differs from the current lexical parent; when those parents coincide, ordinary call processing applies. This decision uses the node name and parent, not whether the node was written inline or reached through a reference. The group case preserves the original parent and introduces no call. The grouper receives the graph without parentheses. P0 retains the source graph, and ordinary callable W/E selection remains separate. `Name :: (A B)` has one whole right Structure, while `Name :: A B` has two right arguments; every `::` argument is consumed in DATA.
+After P0, the Expression grouper receives a pure graph and uses its structure, operation priorities and contracts to produce a structured plan with a left segment and a right stream at the current level. It does not produce text for reparsing. A separate Expression application adapter packages the entire left segment as one `left` actual and the right items as the `right` Array of references. For an `op` with a selected sequence contract, `(a b) op (c d)` and `(a b) op (((c d)))` supply one whole left group and two right items c and d. `(a b) op (((c d))) 7` instead has two right items: normalized subgroup `(c d)` and 7. The grouper recursively processes each Expression group: one unit is transparent and several units form one subgroup. A complete computable unit retains its boundary and priorities; the grouper does not check the semantics of `op`. The former anonymous-LEFT/sole-anonymous-RIGHT condition describes these grouping and ABI results; it is not a later opening pass. Three adjacent right groups remain three current-level items; the adapter does not repeat grouping. A ready value consumed as VALUE/TYPE/DATA does not automatically become CODE. In a CODE/Expression graph an anonymous Structure is always a group. A named Structure is a group when its parent differs from the current lexical parent; when those parents coincide, ordinary call processing applies. This decision uses the node name and parent, not whether the node was written inline or reached through a reference. The group case preserves the original parent and introduces no call. The grouper receives the graph without parentheses. P0 retains the source graph, and ordinary callable W/E selection remains separate. `Name :: (A B)` has one whole right Structure, while `Name :: A B` has two right arguments; every `::` argument is consumed in DATA.
 
 For a place-list target, `(a b) := copy(Pair)` consumes the copied field stream directly and is equivalent here to `(a b) := (copy(Pair))`. Scalar container assignments such as `ptr := (copy(Model))` and container arguments to `partial` retain their own value boundaries.
 
--- spec/tools/expression_grouping_reference.py
+++ spec/tools/expression_grouping_reference.py
@@ -7,7 +7,7 @@
 storage records or additions to OPERANDS_TEMPLATE. See EXPRESSION_ALGORITHM.md.
 """
 
-from dataclasses import dataclass
+from dataclasses import dataclass, replace
 from typing import Any, Callable
 
 
@@ -101,8 +101,60 @@
     right: tuple              # stand-in for the existing Array<reference>
 
 
+@dataclass(frozen=True)
+class PreparedGroup:
+    """One material subgroup with zero or several prepared items.
+
+    This transient view is not a new public LMX data type.
+    """
+    items: tuple
+
+
+@dataclass(frozen=True)
+class PreparedAtom:
+    """One original graph atom with its normalized Expression payload.
+
+    Singleton groups disappear from value, but origins retains the original
+    outer-to-inner occurrences. Thus a grouped Apply remains one source atom
+    for selecting left, and RAW still has the untouched graph and contexts.
+    """
+    origins: tuple            # original Unit(group) occurrences, outer first
+    value: Any                # one Unit/Apply, PreparedGroup or graph edge
+
+    @property
+    def raw(self):
+        return self.origins[0].raw
+
+    @property
+    def context(self):
+        return self.origins[0].context
+
+
+@dataclass
+class PreparedGraphNode:
+    """A finite planning anchor; only back edges need to retain this object."""
+    source: Unit
+    items: tuple | None = None
+
+
+@dataclass(frozen=True)
+class PreparedGraphEdge:
+    """A back edge, not a copied/infinitely expanded tree or language error."""
+    target: PreparedGraphNode
+
+
+def prepared_value(item):
+    """Read a prepared payload without reopening or evaluating the graph."""
+    while isinstance(item, PreparedAtom):
+        item = item.value
+    return item
+
+
 def rightmost_occurrence(plan):
     """Retain the adjacent atom for every operation, independently of role."""
+    if isinstance(plan, PreparedAtom):
+        # Its payload may be Apply, but that whole grouped Apply is one atom.
+        return plan
     if isinstance(plan, Unit):
         return plan
     if isinstance(plan, Apply):
@@ -268,6 +320,76 @@
         return unit
 
 
+def normalize_expression(units, planner):
+    """Recursively prepare graph groups after priority planning.
+
+    This entry is for an already selected Expression graph. It does not
+    inspect an operand's value/type admission, execute receivers, or inspect
+    values/field streams that a receiver may later produce. Existing RAW,
+    DATA and TYPE consumers keep access to the original graph occurrences.
+
+    Every nested group is planned, then packed as one atom: a singleton uses
+    its only payload; zero or several items use PreparedGroup. Several atoms
+    at the current level stay several atoms. A PreparedAtom retains a source
+    atom boundary even when its only payload is an Apply.
+
+    Memoization below is by plan occurrence, not graph node. Two references
+    to the same graph node therefore retain separate prepared occurrences.
+    An active-path back edge is retained as PreparedGraphEdge, so pure-graph
+    planning terminates without defining new runtime cycle semantics.
+    """
+    memo = {}
+    active = {}
+
+    def pack(source, items):
+        if len(items) != 1:
+            return PreparedAtom((source,), PreparedGroup(items))
+        item = items[0]
+        if isinstance(item, PreparedAtom):
+            return PreparedAtom((source,) + item.origins, item.value)
+        return PreparedAtom((source,), item)
+
+    def prepare(item):
+        entry = memo.get(id(item))
+        if entry is not None and entry[0] is item:
+            return entry[1]
+        if isinstance(item, PreparedAtom):
+            return item
+        if isinstance(item, Unit) and item.kind == "group":
+            context = Context(item.node, item.context.activation)
+            key = (id(item.node), id(context.activation))
+            if key in active:
+                result = PreparedAtom((item,), PreparedGraphEdge(active[key]))
+            else:
+                anchor = PreparedGraphNode(item)
+                active[key] = anchor
+                try:
+                    children = planner.plan(item.node, context)
+                    prepared = tuple(prepare(child) for child in children)
+                    anchor.items = prepared
+                    result = pack(item, prepared)
+                finally:
+                    del active[key]
+        elif isinstance(item, Apply):
+            left = item.left
+            if left is not ABSENT:
+                region = prepare(left.region)
+                occurrence = prepare(left.occurrence)
+                if region is not left.region or occurrence is not left.occurrence:
+                    left = LeftView(occurrence, region)
+            right = tuple(prepare(child) for child in item.right)
+            unchanged = (left is item.left and
+                         all(a is b for a, b in zip(right, item.right)))
+            result = item if unchanged else replace(item, left=left, right=right)
+        else:
+            result = item
+        # Retaining the input prevents an id from being reused during this pass.
+        memo[id(item)] = (item, result)
+        return result
+
+    return tuple(prepare(item) for item in units)
+
+
 @dataclass(frozen=True)
 class MethodOutcome:
     value: Any
@@ -301,20 +423,18 @@
 
 
 def expose_sequence(units, planner):
-    """Select one immediate material level for a SEQUENCE consumer.
-
-    This is called by grouping under the resolved receiving contract, not
-    unconditionally on every actual. Interior operations are grouped before
-    the resulting immediate units are exposed. Each unit retains the group's
-    lexical context and the existing activation. Sibling groups and their
-    children are deliberately not flattened.
-    """
-    if len(units) == 1 and isinstance(units[0], Unit):
-        unit = units[0]
-        if unit.kind == "group":
-            context = Context(unit.node, unit.context.activation)
-            return planner.plan(unit.node, context)
-    return tuple(units)
+    """Choose the prepared current level for a SEQUENCE consumer.
+
+    Normalization is generic Expression work; this helper only selects the
+    effective level of a sole group. In a wider sequence every subgroup
+    remains one atom, including an empty subgroup. Argument roles and stream
+    production are handled by the existing receiver/namespace integration.
+    """
+    units = normalize_expression(tuple(units), planner)
+    if len(units) == 1 and isinstance(units[0], PreparedAtom):
+        value = prepared_value(units[0])
+        return value.items if isinstance(value, PreparedGroup) else (value,)
+    return units
 
 
 def prepare_actuals(left_sequence, right_sequence, make_reference: Callable):
--- spec/validation/expression_grouping_cases_20261124.json
+++ spec/validation/expression_grouping_cases_20261124.json
@@ -27,6 +27,7 @@
   "phase_contract": [
     "P0 preserves the source Structure graph.",
     "The effect-free grouper derives structural operation/dependency units and streams at the current level under receiving contracts.",
+    "Recursively normalize admitted Expression groups: one unit is transparent; zero or several units retain one subgroup item. Preserve complete inner application boundaries and original graph occurrences; do not splice sibling subgroups or test operand admission.",
     "No source-only, written-group, parenthesis or returned-object flag selects graph grouping.",
     "Expression application adaptation packages one left actual/reference bundle and right Array of references; wrapping left is not the grouping pass.",
     "Ordinary demand, input roles, mode, admission and result handling apply; no separate conditional opening pass follows.",
@@ -101,8 +102,17 @@
       "code": "((1 2))",
       "status": "NORMATIVE_TARGET",
       "execution": "NOT_RUN",
-      "expected": "Preserve the nested material levels. One child that is itself material is not automatically a complete scalar expression.",
-      "automatic_role_change": false
+      "expected": "The original graph and all group nodes remain unchanged. Recursive in-memory normalization removes transparent singleton wrappers: the prepared value is one material subgroup (1 2), not a scalar or an invented operation.",
+      "automatic_role_change": false,
+      "recursive_normalization": true,
+      "expected_normalized": [
+        {
+          "group": [
+            1,
+            2
+          ]
+        }
+      ]
     },
     {
       "id": "E07",
@@ -268,17 +278,18 @@
     {
       "id": "E19",
       "language": "LMX",
-      "code": "(target) := ((x y))",
-      "status": "NORMATIVE_TARGET",
-      "execution": "NOT_RUN",
-      "expected": "One inner Structure (x y) is the single current-level RHS item for the one PLACE target.",
-      "preconditions": [
-        "target is an available assignable reference place admitting the Structure",
+      "code": "(a b) := (((x y)))",
+      "status": "NORMATIVE_TARGET",
+      "execution": "NOT_RUN",
+      "expected": "Recursive normalization makes one subgroup (x y); the group-assignment sequence contract then supplies x and y to two targets.",
+      "preconditions": [
+        "a,b are available assignable places admitting the two values",
         "x,y are available ordinary values"
       ],
       "expected_left_actuals": 1,
-      "expected_right_items": 1,
-      "recursive_flattening": false
+      "expected_right_items": 2,
+      "recursive_flattening": false,
+      "recursive_normalization": true
     },
     {
       "id": "E20",
@@ -567,6 +578,147 @@
       "atom_count": 1,
       "spelling_dispatch": false,
       "public_operand_header_changed": false
+    },
+    {
+      "id": "E39",
+      "language": "LMX",
+      "code": "1 + 2 (((3))) (4) ((5))",
+      "status": "NORMATIVE_TARGET",
+      "execution": "NOT_RUN",
+      "expected": "All singleton group chains are transparent; left remains 1.",
+      "recursive_normalization": true,
+      "sibling_field_splicing": false,
+      "expected_normalized_right": [
+        2,
+        3,
+        4,
+        5
+      ],
+      "expected_right_items": 4
+    },
+    {
+      "id": "E40",
+      "language": "LMX",
+      "code": "1 + 2 (((5 6))) (4) 5",
+      "status": "NORMATIVE_TARGET",
+      "execution": "NOT_RUN",
+      "expected": "Planning succeeds with one material subgroup. The numeric + method refuses that subgroup; grouping does not insert an operation or report numeric admission errors.",
+      "recursive_normalization": true,
+      "sibling_field_splicing": false,
+      "expected_normalized_right": [
+        2,
+        {
+          "group": [
+            5,
+            6
+          ]
+        },
+        4,
+        5
+      ],
+      "expected_right_items": 4
+    },
+    {
+      "id": "E41",
+      "language": "LMX",
+      "code": "1 + 2 (+ 5 6) 4 5",
+      "status": "NORMATIVE_TARGET",
+      "execution": "NOT_RUN",
+      "expected": "The explicit inner prefix operation is one complete computable unit. Its left is absent; the method receives both right items unchanged.",
+      "recursive_normalization": true,
+      "sibling_field_splicing": false,
+      "expected_normalized_right": [
+        2,
+        {
+          "operation": "+",
+          "left": null,
+          "right": [
+            5,
+            6
+          ]
+        },
+        4,
+        5
+      ],
+      "expected_right_items": 4
+    },
+    {
+      "id": "E42",
+      "language": "LMX",
+      "code": "(a b) := (((x y))) z",
+      "status": "NORMATIVE_TARGET",
+      "execution": "NOT_RUN",
+      "expected": "A normalized subgroup among neighboring RHS items remains one item.",
+      "recursive_normalization": true,
+      "sibling_field_splicing": false,
+      "expected_normalized_right": [
+        {
+          "group": [
+            "x",
+            "y"
+          ]
+        },
+        "z"
+      ],
+      "expected_right_items": 2
+    },
+    {
+      "id": "E43",
+      "language": "LMX",
+      "code": "(a b c) := (x + 1) (y * 2) (z - 3)",
+      "status": "NORMATIVE_TARGET",
+      "execution": "NOT_RUN",
+      "expected": "Three sibling computable groups have recursively prepared inner operations and remain three right units.",
+      "recursive_normalization": true,
+      "sibling_field_splicing": false
+    },
+    {
+      "id": "E44",
+      "language": "LMX",
+      "code": "(a b c) := (((x y)))",
+      "status": "NORMATIVE_TARGET",
+      "execution": "NOT_RUN",
+      "expected": "The sequence consumer receives two right values for three targets and refuses before the first write.",
+      "recursive_normalization": true,
+      "sibling_field_splicing": false,
+      "expected_normalized_right": [
+        "x",
+        "y"
+      ],
+      "expected_right_items": 2,
+      "preconditions": [
+        "a,b,c are distinct available assignable places",
+        "x,y are available values"
+      ],
+      "writes_before_failure": 0
+    },
+    {
+      "id": "E45",
+      "language": "LMX",
+      "code": "2 * (3 + 4)",
+      "status": "NORMATIVE_TARGET",
+      "execution": "NOT_RUN",
+      "expected": "One complete inner addition remains an atomic outer argument; the arithmetic result is 14, not 10.",
+      "recursive_normalization": true,
+      "sibling_field_splicing": false
+    },
+    {
+      "id": "E46",
+      "language": "LMX",
+      "code": "op 1 (()) 2",
+      "status": "NORMATIVE_TARGET",
+      "execution": "NOT_RUN",
+      "expected": "A present empty subgroup remains one right item; left is absent and right has three items.",
+      "recursive_normalization": true,
+      "sibling_field_splicing": false,
+      "expected_normalized_right": [
+        1,
+        {
+          "group": []
+        },
+        2
+      ],
+      "expected_right_items": 3
     }
   ],
   "lmx_parser_execution": "NOT_RUN",
--- spec/validation/expression_grouping_reference_test.py
+++ spec/validation/expression_grouping_reference_test.py
@@ -49,6 +49,10 @@
 def shape(plan):
     if plan is ref.ABSENT: return None
     if isinstance(plan, ref.LeftView): return shape(plan.region)
+    if isinstance(plan, ref.PreparedAtom): return shape(plan.value)
+    if isinstance(plan, ref.PreparedGroup):
+        return ("group", tuple(map(shape, plan.items)))
+    if isinstance(plan, ref.PreparedGraphEdge): return "graph-edge"
     if isinstance(plan, ref.Unit):
         return plan.node if plan.kind == "atom" else plan.kind
     if isinstance(plan, ref.Apply):
@@ -60,10 +64,12 @@
     """Tiny host method body; this is not LMX numeric semantics."""
     def __init__(self, function):
         self.function = function
+        self.calls = []
 
     def invoke(self, left, right, namespace, evaluate):
         values = [] if left is ref.ABSENT else [evaluate(left.region)]
         values.extend(evaluate(item) for item in right)
+        self.calls.append(tuple(values))
         consumed = ref.ABSENT if left is ref.ABSENT else left.region
         return ref.MethodOutcome(self.function(values), consumed)
 
@@ -104,11 +110,19 @@
         merged = dict(replacements)
         if more: merged.update(more)
         return evaluate_model(child, planner, methods, namespace, merged)
+    if isinstance(plan, ref.PreparedAtom):
+        return evaluate(plan.value)
+    if isinstance(plan, ref.PreparedGroup):
+        # One opaque material value in this host model. Its fields are not
+        # spliced into the caller's argument list. Numeric admission belongs
+        # to the method, after it receives this value.
+        return tuple(evaluate(item) for item in plan.items)
+    if isinstance(plan, ref.PreparedGraphEdge):
+        # No runtime cycle semantics are asserted by this planner test.
+        return plan
     if isinstance(plan, ref.Unit):
         if plan.kind == "group":
-            units = planner.plan(plan.node, ref.Context(plan.node, plan.context.activation))
-            if len(units) != 1: raise ValueError("not one complete expression")
-            return evaluate(units[0])
+            return evaluate(ref.normalize_expression((plan,), planner)[0])
         if plan.kind == "receiver":
             raise NotImplementedError("production receiver/call handling is external")
         return namespace[plan.node] if isinstance(plan.node, str) else plan.node
@@ -268,15 +282,16 @@
         app = self.plan(left, ":=", *groups)[0]
         rs = ref.expose_sequence(app.right, self.planner)
         self.assertEqual(len(rs), 3)
-        self.assertTrue(all(isinstance(item, ref.Unit) for item in rs))
-
-    def test_no_second_opening(self):
+        self.assertTrue(all(isinstance(item, ref.PreparedAtom) for item in rs))
+        self.assertTrue(all(isinstance(item.value, ref.PreparedGroup) for item in rs))
+
+    def test_singleton_chain_exposes_multi_atom_level(self):
         inner = Group(("x", "y"), self.owner)
         outer = Group((inner,), self.owner)
-        app = self.plan(Group(("target",), self.owner), ":=", outer)[0]
+        app = self.plan(Group(("a", "b"), self.owner), ":=", outer)[0]
         rs = ref.expose_sequence(app.right, self.planner)
-        self.assertEqual(len(rs), 1)
-        self.assertIs(rs[0].node, inner)
+        self.assertEqual(shape(rs), ("x", "y"))
+        self.assertIs(rs[0].context.lexical_parent, inner)
 
     def test_rhs_expression_group_is_one_computed_unit(self):
         right = Group((2, "*", 3), self.owner)
@@ -358,6 +373,157 @@
         app = self.plan(1, "+", outer)[0]
         self.assertEqual(evaluate_model(app, self.planner, self.methods, {}), 3)
 
+    def test_author_singleton_groups_prepare_scalar_right_items(self):
+        g = lambda *items: Group(items, self.owner)
+        app = ref.normalize_expression(
+            self.plan(1, "+", 2, g(g(g(3))), g(4), g(g(5))), self.planner)[0]
+        self.assertEqual(shape(app), ("+", 1, (2, 3, 4, 5)))
+        self.assertEqual(self.methods[id(self.ops["+"])].calls, [])
+
+    def test_author_material_subgroup_is_rejected_only_inside_numeric_method(self):
+        g = lambda *items: Group(items, self.owner)
+        app = ref.normalize_expression(
+            self.plan(1, "+", 2, g(g(g(5, 6))), g(4), 5), self.planner)[0]
+        self.assertEqual(shape(app), ("+", 1, (2, ("group", (5, 6)), 4, 5)))
+        method = self.methods[id(self.ops["+"])]
+        self.assertEqual(method.calls, [])
+        with self.assertRaises(TypeError):
+            evaluate_model(app, self.planner, self.methods, {})
+        # The method received the whole subgroup as one argument. Host sum,
+        # not normalization or expression traversal, then rejected it.
+        self.assertEqual(method.calls, [(1, 2, (5, 6), 4, 5)])
+
+    def test_author_prefix_operation_in_subgroup_is_one_unit(self):
+        g = lambda *items: Group(items, self.owner)
+        app = ref.normalize_expression(
+            self.plan(1, "+", 2, g(g(g("+", 5, 6))), g(4), 5), self.planner)[0]
+        self.assertEqual(shape(app), ("+", 1, (2, ("+", None, (5, 6)), 4, 5)))
+        inner = ref.prepared_value(app.right[1])
+        self.assertIs(inner.left, ref.ABSENT)
+        self.assertEqual(len(inner.right), 2)
+        self.assertEqual(evaluate_model(app, self.planner, self.methods, {}), 23)
+
+    def test_normalized_grouped_apply_remains_one_source_atom(self):
+        group = Group((3, "+", 4), self.owner)
+        app = ref.normalize_expression(self.plan(2, "*", group), self.planner)[0]
+        atom = app.right[0]
+        self.assertIsInstance(atom, ref.PreparedAtom)
+        self.assertIsInstance(atom.value, ref.Apply)
+        self.assertIs(ref.rightmost_occurrence(atom), atom)
+        self.assertEqual(evaluate_model(app, self.planner, self.methods, {}), 14)
+        store = ref.normalize_expression(self.plan(2, "*", group, ":=", 9), self.planner)[0]
+        self.assertIs(store.left.occurrence, store.left.region.right[0])
+        self.assertIsInstance(store.left.occurrence, ref.PreparedAtom)
+
+    def test_sibling_expression_groups_are_normalized_without_splicing(self):
+        g = lambda *items: Group(items, self.owner)
+        app = ref.normalize_expression(
+            self.plan(g("a", "b", "c"), ":=", g("x", "+", 1),
+                      g("y", "*", 2), g("z", "-", 3)), self.planner)[0]
+        rs = ref.expose_sequence(app.right, self.planner)
+        self.assertEqual(len(rs), 3)
+        values = tuple(evaluate_model(item, self.planner, self.methods,
+                                      {"x": 4, "y": 5, "z": 9}) for item in rs)
+        self.assertEqual(values, (5, 10, 6))
+
+    def test_empty_group_remains_one_argument_in_wider_right(self):
+        empty = Group((), self.owner)
+        app = ref.normalize_expression(self.plan("op", 1, empty, 2), self.planner)[0]
+        self.assertIs(app.left, ref.ABSENT)
+        self.assertEqual(shape(app.right), (1, ("group", ()), 2))
+        self.assertEqual(len(ref.expose_sequence(app.right, self.planner)), 3)
+        actuals = ref.prepare_actuals(ref.ABSENT, app.right, lambda x: x)
+        self.assertIs(actuals.left, ref.ABSENT)
+        self.assertEqual(len(actuals.right), 3)
+
+    def test_normalized_singleton_raw_and_all_contexts_are_retained(self):
+        foreign = object()
+        inner = Group((7,), foreign)
+        outer = Group((inner,), foreign, "S")
+        link = Link(outer)
+        atom = ref.normalize_expression(self.plan(link), self.planner)[0]
+        self.assertEqual(shape(atom), 7)
+        self.assertIs(atom.raw, link)
+        self.assertIs(atom.origins[0].node, outer)
+        self.assertIs(atom.origins[1].node, inner)
+        self.assertIs(atom.value.context.lexical_parent, inner)
+        self.assertIs(atom.value.context.activation, self.context.activation)
+        self.assertIs(outer.parent, foreign)
+        self.assertEqual(outer.items, (inner,))
+
+    def test_shared_graph_references_remain_separate_occurrences(self):
+        group = Group((1, "+", 2), object(), "S")
+        first, second = Link(group), Link(group)
+        app = ref.normalize_expression(self.plan("op", first, second), self.planner)[0]
+        one, two = app.right
+        self.assertIsNot(one, two)
+        self.assertIsNot(one.value, two.value)
+        self.assertIs(one.raw, first)
+        self.assertIs(two.raw, second)
+        self.assertIs(one.origins[0].node, two.origins[0].node)
+        self.assertEqual(shape(one), shape(two))
+
+    def test_cycle_is_retained_as_finite_prepared_graph_edge(self):
+        group = Group((), object(), "S")
+        link = Link(group)
+        group.items = (link,)
+        atom = ref.normalize_expression(self.plan(link), self.planner)[0]
+        edge = ref.prepared_value(atom)
+        self.assertIsInstance(edge, ref.PreparedGraphEdge)
+        self.assertIs(edge.target.source.node, group)
+        self.assertIs(ref.prepared_value(edge.target.items[0]), edge)
+        self.assertIs(atom.raw, link)
+        self.assertIs(group.items[0], link)
+
+    def test_normalizer_preserves_receiver_without_executing_its_body(self):
+        group = Group((), self.owner)
+        receiver = Group(("undefined", "+", 1), group, "makeRecord")
+        group.items = (receiver,)
+        atom = ref.normalize_expression(self.plan(group), self.planner)[0]
+        self.assertIsInstance(atom, ref.PreparedAtom)
+        self.assertEqual(atom.value.kind, "receiver")
+        self.assertIs(atom.value.node, receiver)
+        self.assertIs(atom.raw, group)
+        self.assertEqual(receiver.items, ("undefined", "+", 1))
+        self.assertEqual(self.methods[id(self.ops["+"])].calls, [])
+
+    def test_normalized_prefix_actuals_are_not_promoted_or_unified(self):
+        prefix = ref.normalize_expression(self.plan(":=", "a", 1), self.planner)[0]
+        infix = ref.normalize_expression(self.plan("a", ":=", 1), self.planner)[0]
+        self.assertIs(prefix.left, ref.ABSENT)
+        self.assertEqual(shape(prefix.right), ("a", 1))
+        self.assertIsNot(infix.left, ref.ABSENT)
+        self.assertEqual(shape(infix.right), (1,))
+        for app in (prefix, infix):
+            namespace = {}
+            self.assertEqual(evaluate_model(app, self.planner, self.methods, namespace), 1)
+            self.assertEqual(namespace, {"a": 1})
+        self.assertEqual(self.store.received_shapes, [(True, 2), (False, 1)])
+
+
+    def test_normalizing_prepared_plan_preserves_occurrence_identity(self):
+        group = Group((3, "+", 4), self.owner)
+        prepared = ref.normalize_expression(self.plan(2, "*", group), self.planner)
+        again = ref.normalize_expression(prepared, self.planner)
+        self.assertIs(again[0], prepared[0])
+        self.assertIs(again[0].left, prepared[0].left)
+        self.assertIs(again[0].right[0], prepared[0].right[0])
+        self.assertEqual(self.methods[id(self.ops["+"])].calls, [])
+
+    def test_source_graph_and_original_plan_stay_unchanged(self):
+        group = Group((3, "+", 4), self.owner)
+        outer = Group((2, "*", group), self.owner)
+        before_fields = (outer.items, group.items, outer.parent, group.parent)
+        original = self.planner.plan(outer, self.context)[0]
+        original_atom = original.right[0]
+        prepared = ref.normalize_expression((original,), self.planner)[0]
+        self.assertIs(original.right[0], original_atom)
+        self.assertEqual(original_atom.kind, "group")
+        self.assertIs(prepared.right[0].origins[0], original_atom)
+        self.assertEqual((outer.items, group.items, outer.parent, group.parent),
+                         before_fields)
+        self.assertIs(prepared.raw, original.raw)
+
 
 if __name__ == "__main__":
     unittest.main(verbosity=2)
--- spec/validation/expression_planner_host_checks_20261124.json
+++ spec/validation/expression_planner_host_checks_20261124.json
@@ -2,16 +2,16 @@
   "edition": "2026-11-24",
   "status": "PASS",
   "host": "Python clean-graph planner and explicitly bounded operand-method model",
-  "executed_tests": 36,
+  "executed_tests": 49,
   "command_from_spec": "python validation/expression_grouping_reference_test.py",
   "source_files": [
     {
       "path": "tools/expression_grouping_reference.py",
-      "sha256": "f8f465b1acf739988485859b493cc4348dfbfa3e808df7b3ddf244b7f50163fa"
+      "sha256": "935b42c3d93e51a88a5ea4e299d5e70cb015b598d69b9ed2fdeba691f1985f37"
     },
     {
       "path": "validation/expression_grouping_reference_test.py",
-      "sha256": "335a3eaab3cc7464f10d1b6b334650394d152994bd469cba2787e1e0ec907257"
+      "sha256": "44c1333ec84a6e26f76b3c622159c39b18b14909c8612d0b21384ee9cf4bd749"
     }
   ],
   "scope": [
@@ -24,10 +24,18 @@
     "adjacent stronger ordinary operand not swallowed by attached unary",
     "RAW graph identity, exact operation occurrence and context",
     "current-level groups, preserved sibling boundaries and separate actual packaging",
-    "explicit model arithmetic/assignment assertions and RHS validation-before-write"
+    "explicit model arithmetic/assignment assertions and RHS validation-before-write",
+    "recursive preparation of Expression groups without reading delimiters or rewriting source graph",
+    "one unit transparent; zero or several units retain one subgroup among neighboring arguments",
+    "explicit inner prefix operation keeps absent left and all right items",
+    "material subgroup reaches numeric method; host method rejects it after successful grouping",
+    "grouped Apply remains one external atom for left selection and priorities",
+    "source graph and original plan unchanged; prepared occurrence identity stable on repeated normalization",
+    "separate shared graph occurrences and finite graph back-edge representation"
   ],
   "production_lmx_parser_execution": "NOT_RUN",
   "production_lmx_translator_execution": "NOT_RUN",
   "production_lmx_runtime_execution": "NOT_RUN",
-  "limitations": "The reference consumes an adapter graph view. Production resolution, complete designators, role/admission, numerical profiles, demanded scheduling, general effect order, short circuiting and activation lifetime are outside the supplied host model. receive_application requires an already demanded node with the surrounding context retained by the production executor."
+  "limitations": "The reference consumes an adapter graph view. Production resolution, complete designators, role/admission, numerical profiles, demanded scheduling, general effect order, short circuiting and activation lifetime are outside the supplied host model. receive_application requires an already demanded node with the surrounding context retained by the production executor. normalize_expression operates on positions already admitted as an Expression graph; full receiver-role dispatch and field-stream collector integration remain production responsibilities. Host tuple and Python TypeError are test representations, not new LMX data types or error codes. Back-edge planning does not prescribe runtime semantics for cyclic Expression graphs.",
+  "correction": "Recursive in-memory graph normalization; singleton payloads and material subgroups; source graph unchanged"
 }
--- spec/validation/signature_expression_cases_20261124.json
+++ spec/validation/signature_expression_cases_20261124.json
@@ -261,24 +261,27 @@
     {
       "id": "B04",
       "language": "LMX",
-      "code": "(target) := ((x y))",
-      "preconditions": [
-        "target is an available assignable reference place admitting the whole Structure (x y)",
-        "x and y are available ordinary values; the RHS is material, not an operator expression"
+      "code": "(a b) := (((x y)))",
+      "preconditions": [
+        "a and b are available assignable places admitting x and y",
+        "x and y are ordinary values; group assignment consumes a sequence"
       ],
       "expected_shape": {
         "left_actuals": 1,
         "left_places": [
-          "target"
-        ],
-        "right_occurrences": 1,
+          "a",
+          "b"
+        ],
+        "right_occurrences": 2,
         "right_sources": [
-          "(x y)"
+          "x",
+          "y"
         ],
         "recursive_flattening": false,
-        "separate_opening_pass": false
-      },
-      "expected": "Current-level sequence consumption supplies one inner Structure for one target; application adaptation packages the left PLACE sequence as one actual.",
+        "separate_opening_pass": false,
+        "recursive_normalization": true
+      },
+      "expected": "Singleton wrappers normalize to one subgroup (x y). The selected sequence consumer reads x and y; adaptation packages the two left places as one actual.",
       "execution": "NOT_RUN"
     },
     {
````
