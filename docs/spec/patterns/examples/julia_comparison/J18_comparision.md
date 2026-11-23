# J18. Splice с возвратом удалённых элементов

## Общий договор

Заменить нулевой полуинтервал [lo,hi) target на values; вернуть удалённый внешний массив. values совместимы и не перекрываются с target; наблюдаются также итоговый target и сохранение его идентичности.

Возврат удалённых элементов обязателен. replaceRange возвращает изменённый target и потому не подставлен вместо splice. Предупреждение Julia о перекрытии аргументов вынесено в общий домен, а не скрыто.

Вход:

```json
{
  "target": [
    1,
    2,
    3,
    4
  ],
  "lo": 1,
  "hi": 3,
  "values": [
    9,
    8,
    7
  ]
}
```

Ожидаемое наблюдение:

```json
{
  "removed": [
    2,
    3
  ],
  "target": [
    1,
    9,
    8,
    7,
    4
  ]
}
```

## LMX

```lmx
Example:
    @: target
    int: lo
    int: hi
    @: values
    return: @
    run:
        throws: copy(FxThrows\mutation)
        return: splice(target; lo; hi; values)
```

## Julia

```julia
function example(target, lo, hi, values)
    0 <= lo <= hi <= length(target) || throw(BoundsError(target, lo:hi))
    splice!(target, lo + 1:hi, values)
end
```

## Размер полного клиента

| Язык | Без пробельных символов | Без сложного Throws | Непустые строки | Все Unicode-символы |
| --- | ---: | ---: | ---: | ---: |
| LMX | 112 | 112 | 9 | 171 |
| Julia | 128 | 128 | 4 | 157 |

Дополнительная колонка оставляет заголовок и первый аргумент Throws; copy(Throws) сохраняется целиком. Полный исходник и его основной счёт не изменяются.

## Реализации использованного ядра

- `splice`: [полная пара реализации](library_comparisons/JI03_comparision.md)

Julia-клиент использует реальные Base/пакет; реализации из library_comparisons он не импортирует. [Общие зависимости и границы](library_comparisons/README.md) учитываются отдельно. Код проверен как текст и по договорам; исполнение LMX/Julia здесь не заявлено.

## Первичные источники

- [https://docs.julialang.org/en/v1/base/collections/](https://docs.julialang.org/en/v1/base/collections/)
