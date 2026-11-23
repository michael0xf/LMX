# J22. Цифры в ASCII-строке

## Общий договор

Сохранить только символы от ASCII 0 до 9 в прежнем порядке. Контракт строкового клиента ограничен ASCII, а не всеми Unicode-категориями цифр.

Две поэлементные маски int 0/1 умножаются; compress оставляет ровно ASCII-цифры и сохраняет плотный char[]. Профиль сравнения ограничен ASCII, без обещания Unicode-категорий.

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
Example:
    char[]: text
    return: char[]
    run:
        throws: copy(FxThrows\mutation) FxShape
        return: \compress(text; (text >= '0') * (text <= '9'))
```

## Julia

```julia
example(text) = filter(c -> '0' <= c <= '9', text)
```

## Размер полного клиента

| Язык | Без пробельных символов | Без сложного Throws | Непустые строки | Все Unicode-символы |
| --- | ---: | ---: | ---: | ---: |
| LMX | 119 | 112 | 6 | 165 |
| Julia | 41 | 41 | 1 | 51 |

Дополнительная колонка оставляет заголовок и первый аргумент Throws; copy(Throws) сохраняется целиком. Полный исходник и его основной счёт не изменяются.

## Реализации использованного ядра

- `compress`: [полная пара реализации](library_comparisons/JI02_comparision.md)

Julia-клиент использует реальные Base/пакет; реализации из library_comparisons он не импортирует. [Общие зависимости и границы](library_comparisons/README.md) учитываются отдельно. Код проверен как текст и по договорам; исполнение LMX/Julia здесь не заявлено.

## Первичные источники

- [https://docs.julialang.org/en/v1/base/collections/](https://docs.julialang.org/en/v1/base/collections/)
- [https://docs.julialang.org/en/v1/base/strings/](https://docs.julialang.org/en/v1/base/strings/)
