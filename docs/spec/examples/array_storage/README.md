# Плоский Array: мерность, пути и инициализаторы

[Договор хранения](../../ARRAY_STORAGE.ru.md) хранит в каноническом описании
TypeRef только rank/extents полного нормализованного типа. Строки инициализатора
не добавляют скрытых осей. При capacity=length второго дескриптора
нет; при резерве нужна только запись capacity. Все примеры используют обычные
Array/Structure без новых полей Lmx. Старые host-проверки ниже проверяют значения
и форму, но не реализацию новых профилей и выделение служебных дескрипторов.
Отдельной сущности «массив массивов» нет.

## Готовый rank-three вход

В 001, 002 и 005 вход `[][][]int: arr` принимает готовое значение,
сконструированное как `[2][2][2]int`, с плоским storage `[1,2,3,4,5,6,7,8]`.
При допуске готового значения к общему rank-three входу его более полный
TypeRef сохраняется. Само `[][][]int` без такого входного описания не
восстанавливает оси по старому инициализатору. Корень загружается обычным способом;
для наблюдения затем явно запрашивается `Example\run`.

| Пример | Ожидаемый результат | Проверяемый договор |
| --- | --- | --- |
| 001 | `[8,6,6,3,6]` | length; flat index; те же координаты; отдельная flat selection |
| 002 | `42` | Одна ячейка для flat/nD записи и чтения |
| 003 | `[1,21,0]` | Один whole child в [arr2], его идентичность и пустое VALUE |
| 004 | `[21,21,21]` | Обычные именные и индексные пути к одному полю |
| 005 | `[8,6,16,16]` | Axis depth=3, новый результат с shape[2,2,2], неизменный источник |
| 006 | Две пары одинаковых плоских потоков; у всех TYPE [][]int с неизвестными размерами осей | Обе формы проверяют строки и уплощают их, не сохраняя границы |
| 009 | `[3,3,3,4,4,4]` | Обычные DATA-поля не требуют прямоугольности; квадратные/круглые формы равны |

Плоский потребитель читает исходные T/length/storage. Он не меняет rank на 1
ради чтения и не создаёт заменяющее значение. Новой rank-one величиной может
быть сам результат явно запрошенной плоской выборки. Явные пользовательские
ограничения rank сохраняют свой обычный допуск.

При соответствующих i и j пути сопоставляются без потери последнего выбора:

| Именованная/смешанная запись | Индексная запись |
| --- | --- |
| `struct\struct2\field` | `struct[i]\[j]` |
| `struct\struct2\field[k]` | `struct[i]\[j]\[k]` |

## Окончательные авторские формы

При `a=1`, `b=2`, `c=3`, `d=4` обе строки ниже создают один и тот же плоский
массив длины 9, rank=2. Написанные строки имеют форму 3×3, но размеры
не сохраняются в TYPE `[][]int`:

```lmx
[][]int: [a b c; a b d; a b c]
[][]int: [[a b c] [a b d] [a b c]]
```

Числовая пара также равнозначна: rank=2, storage `[1,2,3,4,5,6]`; размеры
осей остаются неизвестными. Чтобы сохранить именно 3×2, нужен тип `[3][2]int`.

```lmx
[][]int: [1 2; 3 4; 5 6]
[][]int: [[1 2] [3 4] [5 6]]
```

Следующие две записи **ошибочны**: длины строк равны 3, 4 и 5. В обеих
формах нужен обычный shape diagnostic; не создаются ragged storage,
segmentation, отдельные row Arrays или дополнительные поля графа.

```lmx
[][]int: [a b c; a b c d; a b c d e]
[][]int: [[a b c] [a b c d] [a b c d e]]
```

Полные отрицательные исходники лежат в `negative/`. Вложенные row groups
в положительных и отрицательных примерах разделены написанными пробелами.
Символ `;` внутри вызова, строки или вложенной области не разделяет строки
внешнего инициализатора. Вне инициализатора прежнее завершение короткой формы
сохраняется. Typed initializer потребляет row groups по объявленному rank;
это не глобальное правило раскрытия готового `[arr2]`.

## Независимые обычные Structure-поля в DATA

Следующий typed rank-конструктор ошибочен: длины строк 3/3/4 различаются.

```lmx
[][]int: [[a b c] [a b d] [a b c d]]
```

Однако обе обычные DATA-формы корректны и равнозначны:

```lmx
Struct: [a b c] [a b d] [a b c d]
Struct: (a b c) (a b d) (a b c d)
```

Это три анонимные Structure-поля с независимыми длинами. Они не являются
отдельной сущностью «массив массивов» и не запрашивают общий rank=2 flat
initializer. Принимающая роль определяет потребление графа. Группировщик
не читает исходные скобки и не вводит flags их происхождения. Готовое
VALUE `[arr2]` по-прежнему содержит один целый элемент arr2.

## Проверка

[14 прежних host-проверок](../../validation/array_storage_reference_report.json)
проверяли модель предыдущей редакции: один flat/nD адрес, прежний
final-element bounds contract, shape/identity источника, rectangular init,
once/order, защищённые внутренние разделители, независимые DATA-поля и whole child в [arr2].
Они использовали уже ограниченные общим P0 графовые области, но не проверяли
новый TypeRef ABI и запрет уточнения типа строками инициализатора. Ожидания
сохранённой shape только из строк следует мигрировать; source mirrors ниже
сохранены как исходные фикстуры, а их прежние подписи не являются новой нормой.
**Production P0, транслятор и LMX runtime новой редакции: NOT_RUN.**

[cases.json](cases.json) сохраняет ожидаемые наблюдения и отдельные
отрицательные случаи. [doc_examples](doc_examples/README.md) содержит
точные source/Markdown mirrors с тем же статусом исполнения.

<!-- generated-source-blocks:start -->

## Полные листинги

### 001_flat_and_coordinates.lm3

Положительная форма: Плоский доступ и nD-доступ читают одно значение; flat selection не меняет rank исходника.

```lmx
Example:
    [][][]int: arr
    return: @
    run:
        throws: copy(slice\throws)
        @: selected arr[1:7:2]
        return: (length(arr) arr[5] arr[1][0][1] length(selected) selected[2])
```

### 002_same_place.lm3

Положительная форма: Запись через линейный индекс видна через координаты того же места.

```lmx
Example:
    [][][]int: arr
    return: int
    run:
        arr[5] := 42
        return: arr[1][0][1]
```

### 003_inline_whole_value.lm3

Положительная форма: [arr2] сохраняет один целый элемент по ссылке; [] даёт присутствующий пустой Array.

```lmx
Example:
    return: @
    run:
        []int: arr2 [10 20]
        @: wrapper [arr2]
        @: empty []
        arr2[1] := 21
        return: (length(wrapper) wrapper[0]\[1] length(empty))
```

### 004_ordinary_structure_paths.lm3

Положительная форма: Именованные и индексные пути Structure выбирают те же поля; дополнительный k сохранён.

```lmx
Values:
    int: first 10
    int: second 20

Branch:
    @: field Values

struct:
    @: struct2 Branch

Example:
    return: @
    run:
        @: named struct\struct2\field
        @: indexed struct[0]\[0]
        indexed[1] := 21
        return: (named[1] struct\struct2\field[1] struct[0]\[0]\[1])
```

### 005_axis_depth.lm3

Положительная форма: Depth=3 проходит логические оси одного плоского Array; исходный shape сохраняется и для flat-чтения.

```lmx
Example:
    [][][]int: arr
    return: @
    run:
        throws: copy(`+`\throws)
        @: shifted arr .(3)+ 10
        return: (length(arr) arr[5] shifted[5] shifted[1][0][1])
```

### 006_rectangular_initializers.lm3

Положительная форма: Финальная авторская пара и числовая пара равны по данным и форме; row groups разделены пробелами.

```lmx
Example:
    int: a 1
    int: b 2
    int: c 3
    int: d 4
    return: @
    run:
        @: semicolon ([][]int: [a b c; a b d; a b c])
        @: grouped ([][]int: [[a b c] [a b d] [a b c]])
        @: numericSemicolon ([][]int: [1 2; 3 4; 5 6])
        @: numericGrouped ([][]int: [[1 2] [3 4] [5 6]])
        return: (semicolon grouped numericSemicolon numericGrouped)
```

### 009_data_structure_groups.lm3

Положительная форма: В DATA квадратные и круглые формы дают те же три обычные безымянные Structure с независимыми длинами 3/3/4.

```lmx
Example:
    int: a 1
    int: b 2
    int: c 3
    int: d 4
    Square:
        Struct: [a b c] [a b d] [a b c d]
    Round:
        Struct: (a b c) (a b d) (a b c d)
    return: @
    run:
        return: (length(Square\Struct) length([0]Square\Struct) length([1]Square\Struct) length([2]Square\Struct) [2]Square\Struct\[3] [2]Round\Struct\[3])
```

### 007_unequal_semicolon_rows.lm3

Отрицательный пример: Отрицательный пример: длины строк различаются. Разделители корректны; ошибка относится к форме.

```lmx
Example:
    int: a 1
    int: b 2
    int: c 3
    int: d 4
    int: e 5
    return: @
    run:
        return: ([][]int: [a b c; a b c d; a b c d e])
```

### 008_unequal_grouped_rows.lm3

Отрицательный пример: Та же ошибка формы с явно разделёнными вложенными группами; это не ошибка отсутствующего пробела.

```lmx
Example:
    int: a 1
    int: b 2
    int: c 3
    int: d 4
    int: e 5
    return: @
    run:
        return: ([][]int: [[a b c] [a b c d] [a b c d e]])
```

### 010_unequal_three_three_four.lm3

Отрицательный пример: Точная отрицательная typed-форма автора: три строки 3/3/4; обычные DATA-поля тех же длин допустимы.

```lmx
Example:
    int: a 1
    int: b 2
    int: c 3
    int: d 4
    return: @
    run:
        return: ([][]int: [[a b c] [a b d] [a b c d]])
```

<!-- generated-source-blocks:end -->
