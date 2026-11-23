# H05. Dynamic and lexical binding after a graph copy

## Общий договор

The Haskell functions receive explicit environments and reproduce 26/6. They do not copy an executable graph, preserve parent relationships or implement LMX dynamic name lookup after copy.

Копирование графа и последующая запись в источник обязательны. Процедурный вариант сохраняет два чтения; функциональный объединяет их выражением, сохраняя динамический и лексический пути.

## LMX — процедурный

```lmx
Source:
    int: y 5
    methods:
        int: x
        return: int
        dynamic:
            return: x + y
        lexical:
            return: x + node\y

BindingProbe:
    return: int
    run:
        @: copied (copy(Source))
        Source\y := 8
        int: y 25
        int: a copied\methods\dynamic(1)
        int: b copied\methods\lexical(1)
        return: a * 100 + b
```

[Полный исходник](../../lmx/procedural/H05.lm3)

## LMX — функциональный

```lmx
Source:
    int: y 5
    methods:
        int: x
        return: int
        dynamic:
            return: x + y
        lexical:
            return: x + node\y

BindingProbe:
    return: int
    run:
        @: copied (copy(Source))
        Source\y := 8
        int: y 25
        return: copied\methods\dynamic(1) * 100 + copied\methods\lexical(1)
```

[Полный исходник](../../lmx/H05.lm3)

## Haskell

Сопоставимого существующего листинга для этого договора нет. Новая иностранная реализация не сочиняется; статус остаётся lmx_only.

## Размер полного текста

| Запись | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX — процедурный | 218 | 18 |
| LMX — функциональный | **206** | 16 |

Обе LMX-записи учитываются целиком, включая объявления, общие локальные helpers и Throws. Ошибки не исключаются из подсчёта. Общая реализация ядра не размножается ради стилей. Существующий статус иностранной пары/аналогии сохранён.

Runtime LMX: NOT_RUN. Это публикация исходников, договоров и полных размеров, не новый parser/runtime receipt.
