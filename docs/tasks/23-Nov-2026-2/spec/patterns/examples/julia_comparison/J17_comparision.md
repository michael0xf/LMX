# J17. Дополнение существующего массива

## Общий договор

Добавить values в конец target и вернуть тот же target. Сравниваемый домен: отдельные совместимые векторы без перекрытия; наблюдаются содержимое и идентичность target.

LMX дополнительно умеет безопасно подготовить перекрывающиеся источники; это свойство проверяется отдельно на реализациях, а не приписывается Base.append!.

Вход:

```json
{
  "target": [
    1,
    2
  ],
  "values": [
    3,
    4
  ]
}
```

Ожидаемое наблюдение:

```json
{
  "returned": [
    1,
    2,
    3,
    4
  ],
  "target": [
    1,
    2,
    3,
    4
  ],
  "same_target": true
}
```

## LMX

```lmx
Example:
    @: target
    @: values
    return: @
    run:
        throws: copy(FxThrows\mutation)
        return: append(target; values)
```

## Julia

```julia
example(target, values) = append!(target, values)
```

## Размер полного клиента

| Язык | Без пробельных символов | Без сложного Throws | Непустые строки | Все Unicode-символы |
| --- | ---: | ---: | ---: | ---: |
| LMX | 94 | 94 | 7 | 139 |
| Julia | 45 | 45 | 1 | 50 |

Дополнительная колонка оставляет заголовок и первый аргумент Throws; copy(Throws) сохраняется целиком. Полный исходник и его основной счёт не изменяются.

## Реализации использованного ядра

- `append`: [полная пара реализации](library_comparisons/JI03_comparision.md)

Julia-клиент использует реальные Base/пакет; реализации из library_comparisons он не импортирует. [Общие зависимости и границы](library_comparisons/README.md) учитываются отдельно. Код проверен как текст и по договорам; исполнение LMX/Julia здесь не заявлено.

## Первичные источники

- [https://docs.julialang.org/en/v1/base/collections/](https://docs.julialang.org/en/v1/base/collections/)
