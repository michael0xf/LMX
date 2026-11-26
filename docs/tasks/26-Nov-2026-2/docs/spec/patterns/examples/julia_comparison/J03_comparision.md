# J03. Последние уникальные события из журнала

## Общий наблюдаемый договор

Журнал хранит события от старых к новым. Просмотреть его с конца и оставить первое встреченное значение каждого события: последнее появление в исходнике выигрывает. Вернуть новый массив, источник сохранить. Общий проверяемый домен — скалярные значения с одинаковой политикой равенства.

Обе полные реализации выполняют один новый прикладной сценарий: процедурная задаёт алгоритм явно, функциональная использует общие операции ядра. Изменённые тексты требуют нового P0-прогона.

Сценарий расширен по замечанию автора: показана обработка данных и полезный итог, а не только вызов одной функции. Обе полные реализации выполняют один новый прикладной сценарий: процедурная задаёт алгоритм явно, функциональная использует общие операции ядра. Изменённые тексты требуют нового P0-прогона.

## Вход и ожидаемое наблюдение

```json
{
  "arguments": {
    "xs": [
      7,
      3,
      7,
      2,
      3,
      9
    ]
  },
  "result": [
    9,
    3,
    2,
    7
  ]
}
```

## Размер полных клиентов

| Полный исходник | Непробельные символы | Все Unicode-символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX процедурный | 484 | 745 | 21 |
| LMX функциональный | 96 | 135 | 6 |
| Julia | <span style="color:#176233"><u>66</u></span> | 81 | 4 |

Обе LMX-формы опубликованы и считаются независимо. Все определения, обработчики и ссылки на throws входят в полный размер. Выбор единственного LMX-варианта по длине не выполняется.

## LMX — процедурный

```lmx
Example:
    @: xs
    return: @
    run:
        throws: copy(FxSeqInfo\get\throws) copy(FxSeqAllocate\make\throws) copy(FxSeqRead\read\throws) copy(FxSeqStore\write\throws) copy(FxValueSame\test\throws) copy(sys\resize\throws)
        @: info FxSeqInfo\get(xs)
        @: out FxSeqAllocate\make(info\arrayType; length(xs))
        int: used 0
        int: i length(xs)
        while: i > 0
            i -= 1
            @: item FxSeqRead\read(xs; i)
            int: j 0
            while: j < used && FxValueSame\test(FxSeqRead\read(out; j); item; 0) = 0
                j += 1
            if: j = used
                FxSeqStore\write(out; used; item)
                used += 1
        ---
        sys\resize(out; used)
        return: out
```

[Полный исходник](source/lmx/procedural/J03.lm3). 484 непробельных символов; 21 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

```lmx
Example:
    @: xs
    return: @
    run:
        throws: copy(reverse\throws) copy(unique\throws)
        return: unique(reverse(xs))
```

[Полный исходник](source/lmx/J03.lm3). 96 непробельных символов; 6 непустых строк. Все объявления и Throws включены.

## Julia

[Полный исходник](source/julia/J03.jl).

```julia
function example(xs)
    latest_first = reverse(xs)
    unique(latest_first)
end
```

## Общие библиотечные реализации

- `reverse`: [полная пара реализации](library_comparisons/JI02_comparision.md)
- `unique`: [полная пара реализации](library_comparisons/JI04_comparision.md)

Тела библиотечного ядра сохранены в одном общем источнике и не размножаются для двух стилей. Иностранный клиент использует свои настоящие средства; соседние comparison-реализации он не импортирует.

## Проверка

Изменённые LMX-исходники: parser/P0 **NOT_RUN**; прежний receipt не переносится на новый хэш. LMX и Julia runtime: **NOT_RUN** в этой сборке. Проверяются обе LMX-формы как текст и общий независимый oracle; это не языковое исполнение. Численные размеры пересчитаны по текущим полным исходникам.

## Первичные источники

- <https://docs.julialang.org/en/v1/base/arrays/>
- <https://docs.julialang.org/en/v1/base/collections/>
