# 104. Levenshtein distance / расстояние редактирования

Найти минимальное число вставок, удалений и замен между двумя последовательностями произвольных токенов.

## Договор и полезный результат

left и right — конечные random-access последовательности; same(a,b) — заданный стабильный полный предикат равенства без изменения inputs. Любые фактические типы, в том числе записи, поддерживаются через существующий допуск callback. Вставка, удаление и замена имеют стоимость 1; совпадение — 0. Возвращается одно неотрицательное целое, edit script не строится. same вызывается ровно n*m раз, сначала по left, внутри по right; при пустой стороне не вызывается. Текст предварительно представлен одинаковыми токенами: пример с emoji работает над явно заданными токенами и не предполагает равенство UTF-16 code units, байтов, Unicode scalar values или графем. Нормализация текста не выполняется.

## Почему эти языки

Python — естественный контроль для последовательностей и NLP; JavaScript — для обработки пользовательского текста и токенов на клиенте. Оба примера принимают массивы и явный comparator, поэтому строковая кодировка не подменяет задачу.

## Алгоритм, источники и стоимость

Учебник Introduction to Information Retrieval задаёт динамическую рекуррентность минимума для вставки, удаления и замены и оценку O(n*m). Здесь эта же рекуррентность обобщена со строковых символов на токены с явно переданным равенством.

[Manning / Raghavan / Schütze: edit distance](https://nlp.stanford.edu/IR-book/html/htmledition/edit-distance-1.html).

Ровно n*m вызовов same, O(n*m+n+m) всех шагов с учётом пустых сторон и начальной строки; O(m) одновременно нужных элементов строк DP. Каждая строка создаётся заново, поэтому совокупный объём выделений — O(n*m); освобождение завершённых строк зависит от runtime. Функциональный внешний fold также создаёт range длины n, внутренний — range длины m: логическая дополнительная память функциональной формы O(n+m), а не безусловно O(m).

Python min и JavaScript Math.min не скрывают DP: все три кандидата вычисляются в листинге. В LMX generic min/minimum уже есть в ядре; в единственном общем EditCell показаны обычные ветви, чтобы процедурный стиль не получил функционального обхода через служебный helper.

## LMX: общий договор двух форм

Общий EditCell вычисляет единственную клетку. Процедурная форма использует два while и явное заполнение начальной строки; функциональная — вложенные foldl по range. Последняя сохраняет приватную текущую строку и записывает результат клетки, чтобы не копировать растущий префикс при каждом шаге. В коде нет ограничения токенов типом int и нет встроенного сравнения строк вместо переданного same.

Выбираемый driver — часть fixture, а не особая точка запуска. Корень поднимается как L3 Thread без DATA; указанный ниже обычный вызов выполняется после запуска. Общие методы доступны в том же графе, а динамически передаваемые рабочие переменные не помечены private.

| Стиль | Обычный вызов после запуска |
| --- | --- |
| Процедурный | `EditDistance\run(left; right; same)` |
| Функциональный | `EditDistance\run(left; right; same)` |

### Общая реализация подготовки и шага

[Исходник](examples/lmx/common/104_edit_distance.lm3). Это необходимая часть обоих полных листингов; её стоимость не исчезает при сравнении.

```lmx
EditCell:
    int: west
    int: j
    return: int
    value:
        throws: copy(FxSeqRead\read\throws) copy(FxApply\apply\throws) copy(FxSeqPredicate\truth\throws) ReceiverIndex
        @: first FxSeqRead\read(left; i - 1)
        @: second FxSeqRead\read(right; j - 1)
        @: flag FxApply\apply(same; FxTwo\make(first; second))
        int: cost 1
        if: FxSeqPredicate\truth(flag) != 0
            cost := 0
        int: best previous[j] + 1
        if: west + 1 < best
            best := west + 1
        if: previous[j - 1] + cost < best
            best := previous[j - 1] + cost
        return: best
```

## LMX — процедурный

[Исходник](examples/lmx/procedural/104_edit_distance.lm3); требуется общая часть выше.

```lmx
EditDistance:
    @: left
    @: right
    @: same
    return: int
    run:
        throws: copy(FxSeqAllocate\make\throws) copy(EditCell\value\throws)
        int: m length(right)
        @: previous FxSeqAllocate\make(int[]; m + 1)
        int: j 0
        while: j <= m
            previous[j] := j
            j += 1
        int: i 1
        while: i <= length(left)
            @: current FxSeqAllocate\make(int[]; m + 1)
            current[0] := i
            j := 1
            while: j <= m
                current[j] := EditCell\value(current[j - 1]; j)
                j += 1
            previous := current
            i += 1
        return: previous[m]
```

## LMX — функциональный

[Исходник](examples/lmx/104_edit_distance.lm3); требуется общая часть выше.

```lmx
EditWrite:
    int: west
    int: j
    return: int
    cell:
        throws: copy(EditCell\value\throws)
        current[j] := EditCell\value(west; j)
        return: current[j]

EditRow:
    @: previous
    int: i
    return: @
    build:
        throws: copy(FxSeqAllocate\make\throws) copy(range\throws) copy(foldl\throws) ReceiverIndex
        @: current FxSeqAllocate\make(int[]; length(right) + 1)
        current[0] := i
        foldl(range(1; length(right) + 1); (i record); EditWrite\cell)
        return: current

EditDistance:
    @: left
    @: right
    @: same
    return: int
    run:
        throws: copy(range\throws) copy(foldl\throws) ReceiverIndex
        @: initial range(0; length(right) + 1)
        @: previous \foldl(range(1; length(left) + 1); (initial record); EditRow\build)
        return: previous[length(right)]
```

## Python

[Полный исходник](examples/python/104_edit_distance.py).

```python
from operator import eq


def edit_distance(left, right, same=eq):
    previous = list(range(len(right) + 1))
    for i, first in enumerate(left, 1):
        current = [i]
        for j, second in enumerate(right, 1):
            cost = 0 if same(first, second) else 1
            current.append(min(previous[j] + 1, current[-1] + 1,
                               previous[j - 1] + cost))
        previous = current
    return previous[-1]
```

## JavaScript

[Полный исходник](examples/javascript/104_edit_distance.js).

```javascript
function editDistance(left, right, same = (a, b) => a === b) {
    let previous = Array.from({length: right.length + 1}, (_, index) => index);
    for (let i = 1; i <= left.length; ++i) {
        const current = [i];
        for (let j = 1; j <= right.length; ++j) {
            const cost = same(left[i - 1], right[j - 1]) ? 0 : 1;
            current.push(Math.min(previous[j] + 1, current[j - 1] + 1,
                                  previous[j - 1] + cost));
        }
        previous = current;
    }
    return previous[right.length];
}

module.exports = {editDistance};
```

## Контрольные сценарии

Все фиксированные случаи этой задачи из [cases.json](tests/cases.json) приведены ниже; алгоритм принимает и остальные допустимые входы.

| Случай | Вход | Ожидаемый результат |
| --- | --- | --- |
| `edit_empty` | `{"left":[],"right":[]}` | `0` |
| `edit_insert` | `{"left":[],"right":["a","b"]}` | `2` |
| `edit_kitten` | `{"left":["k","i","t","t","e","n"],"right":["s","i","t","t","i","n","g"]}` | `3` |
| `edit_unicode_tokens` | `{"left":["я","🙂","好"],"right":["я","好"]}` | `1` |
| `edit_records` | `{"left":[{"key":1,"label":"a"},{"key":2,"label":"b"}],"right":[{"key":1,"label":"different"},{"key":3,"label":"c"}],"comparator":"key"}` | `1` |

## Сравнительная публикация и проверка

Полные размеры обеих LMX-форм пересчитаны по текущим исходникам и приведены ниже. Общие части входят в каждую использующую их границу ровно один раз; все объявления и Throws сохранены.

Иностранные программы проверены [воспроизводимым runner](tests/run_foreign.py), фиксированными случаями и 120 генерируемыми входами на задачу. [Отчёт исполнения](tests/validation.json) различает это от неподтверждённого исполнения LMX. Callback и resource failures не заменяются фиктивным успехом; нарушение явно перечисленных предусловий не является заявленным API восстановления ошибок.

## Размер полного исходника

| Запись | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX — процедурный | 793 | 42 |
| LMX — функциональный | 1030 | 46 |
| Python | <span style="color:#176233"><u>296</u></span> | 11 |
| JavaScript | 388 | 14 |

Для каждой LMX-формы считаются все её source_files, включая общие определения ровно один раз. Все объявления и Throws входят в размер. Зелёным подчёркнут минимум полного сопоставимого листинга; равные минимумы выделены вместе.
