# J22. Цифры в ASCII-строке

## Общий договор

Сохранить только символы от ASCII 0 до 9 в прежнем порядке. Контракт строкового клиента ограничен ASCII, а не всеми Unicode-категориями цифр.

LMX char[] и Julia String имеют разные физические представления. Здесь сравнивается последовательность ASCII-символов; результат LMX остаётся char[], поскольку filter сохраняет плотный профиль.

Вход:

```json
{
  "text": "AB-09 x2!"
}
```

Ожидаемое наблюдение:

```json
"092"
```

## LMX

```lmx
Digit:
    char: value
    return: int
    accepts:
        return: value >= '0' && value <= '9'

Example:
    char[]: text
    return: char[]
    run:
        throws: copy(FxThrows\traversal)
        return: \filter(text; Digit\accepts)
```

## Julia

```julia
example(text) = filter(c -> '0' <= c <= '9', text)
```

## Размер полного клиента

| Язык | Без пробельных символов | Непустые строки | Все Unicode-символы |
| --- | ---: | ---: | ---: |
| LMX | 164 | 11 | 238 |
| Julia | 41 | 1 | 51 |

## Реализации использованного ядра

- `filter`: [полная пара реализации](library_comparisons/JI01_comparision.md)

Julia-клиент использует реальные Base/пакет; реализации из library_comparisons он не импортирует. [Общие зависимости и границы](library_comparisons/README.md) учитываются отдельно. Код проверен как текст и по договорам; исполнение LMX/Julia здесь не заявлено.

## Первичные источники

- [https://docs.julialang.org/en/v1/base/collections/](https://docs.julialang.org/en/v1/base/collections/)
- [https://docs.julialang.org/en/v1/base/strings/](https://docs.julialang.org/en/v1/base/strings/)
