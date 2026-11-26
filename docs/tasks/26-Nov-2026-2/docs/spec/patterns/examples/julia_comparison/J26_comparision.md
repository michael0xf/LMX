# J26. Хвостовое окно истории в выбранном направлении

## Общий наблюдаемый договор

Взять последние min(count,length(values)) элементов и вернуть их в исходном порядке при newestFirst=0 либо в обратном порядке при ненулевом newestFirst. count должен быть неотрицательным; отрицательное значение отвергается до изменения данных. count=0 и пустой вход дают новый пустой Array. Источник, ссылки его элементов и их цели сохраняются; результат — отдельный внешний контейнер того же профиля. Тип элементов не ограничен числами.

Один прикладной договор: процедурный вариант задаёт алгоритм циклами, функциональный использует общие выражения и операции. Все объявления и throws входят в размер; обе формы требуют нового P0-прогона.

count=0 обработан явно: values[-0:] означало бы весь Array, поэтому выбран values[:0]. Оба условных выражения ленивые; невыбранный срез не строится. При count больше длины новая форма среза обрезает границу. Julia использует обычные one-based Vector и включающую конечную границу форму диапазона. Отрицательный count даёт ReceiverIndex в LMX и ArgumentError в Julia; общий проверяемый исход — отказ negative_count. Отрицательные границы среза не превращают values[-1] в допустимый скалярный доступ. Декорация .op передаёт depth=1 базовой операции; ссылки throws используют её базовое точное имя. Ресиверные имена с добавленной точкой не создаются как алиасы.

## Вход и ожидаемое наблюдение

```json
{
  "arguments": {
    "values": [
      1,
      2,
      3,
      4,
      5,
      6
    ],
    "count": 3,
    "newestFirst": 1
  },
  "result": [
    6,
    5,
    4
  ]
}
```

## Размер полных клиентов

| Полный исходник | Непробельные символы | Все Unicode-символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX процедурный | 402 | 675 | 25 |
| LMX функциональный | 201 | 299 | 11 |
| Julia | <span style="color:#176233"><u>172</u></span> | 209 | 5 |

Обе LMX-формы опубликованы и считаются независимо. Все определения, обработчики и ссылки на throws входят в полный размер. Выбор единственного LMX-варианта по длине не выполняется.

## LMX — процедурный

```lmx
Example:
    @: values
    int: count
    int: newestFirst
    return: @
    run:
        throws: copy(FxSeqInfo\get\throws) copy(FxSeqAllocate\make\throws) ReceiverIndex
        if: count < 0
            throw: ReceiverIndex()
        @: info FxSeqInfo\get(values)
        int: n count
        if: n > length(values)
            n := length(values)
        @: out FxSeqAllocate\make(info\arrayType; n)
        int: at length(values) - n
        int: step 1
        if: newestFirst
            at := length(values) - 1
            step := -1
        int: i 0
        while: i < n
            out[i] := values[at]
            at += step
            i += 1
        return: out
```

[Полный исходник](source/lmx/procedural/J26.lm3). 402 непробельных символов; 25 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

```lmx
Example:
    @: values
    int: count
    int: newestFirst
    return: @
    run:
        throws: copy(slice\throws) ReceiverIndex
        if: count < 0
            throw: ReceiverIndex()
        @: window count = 0 ? values[:0] : values[-count:]
        return: newestFirst ? window[::-1] : window
```

[Полный исходник](source/lmx/J26.lm3). 201 непробельных символов; 11 непустых строк. Все объявления и Throws включены.

## Julia

[Полный исходник](source/julia/J26.jl).

```julia
function example(values, count, newest_first)
    count >= 0 || throw(ArgumentError("count"))
    window = values[end - min(count, length(values)) + 1:end]
    newest_first != 0 ? reverse(window) : window
end
```

## Общие библиотечные реализации

- `slice / [-count:] / [::-1]`: [договор Expression](../../../TERNARY_AND_SLICES.ru.md#slice-contract)
- `?:`: [договор Expression](../../../TERNARY_AND_SLICES.ru.md#conditional)
- `depth`: [договор Expression](../../../OPERATOR_DEPTH.ru.md)

Тела библиотечного ядра сохранены в одном общем источнике и не размножаются для двух стилей. Иностранный клиент использует свои настоящие средства; соседние comparison-реализации он не импортирует.

## Проверка

Изменённые LMX-исходники: parser/P0 **NOT_RUN**; прежний receipt не переносится на новый хэш. LMX и Julia runtime: **NOT_RUN** в этой сборке. Проверяются обе LMX-формы как текст и общий независимый oracle; это не языковое исполнение. Численные размеры пересчитаны по текущим полным исходникам.

## Первичные источники

- <https://docs.julialang.org/en/v1/base/arrays/>
- <https://docs.julialang.org/en/v1/manual/control-flow/#man-conditional-evaluation>
