# R07. User operand and preserved computation

## Общий договор

The explicit Haskell syntax tree yields the same arithmetic result 20. It is a manually defined AST and interpreter, not a user operand integrated into the ordinary parser and retained LMX graph.

Это упражнение самого пользовательского операнда в обычном Expression, а не только вычисления числа20. Общий шаблон и форма вызова обязательны в обоих стилях.

Обоим стилям соответствует одна минимальная форма, необходимая для проверяемого низкоуровневого договора. Её исходник и листинг приведены один раз, значения в обоих столбцах равны. Два разных алгоритма не заявляются.

## LMX — общая минимальная форма обоих стилей

```lmx
Operands:
    copy: sys\OPERANDS_TEMPLATE
    return: int
    add:
        return: \left + \right[0]
    Example:
        int: n
        return: int
        calculate:
            return: (n add 3) add n
        demo:
            return: calculate(2) + calculate(5)
```

[Полный исходник](../../lmx/R07.lm3)

## Haskell

Сопоставимого существующего листинга для этого договора нет. Новая иностранная реализация не сочиняется; статус остаётся lmx_only.

## Размер полного текста

| Запись | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX — процедурный | **159** | 12 |
| LMX — функциональный | **159** | 12 |

Обе LMX-записи учитываются целиком, включая объявления, общие локальные helpers и Throws. Ошибки не исключаются из подсчёта. Общая реализация ядра не размножается ради стилей. Существующий статус иностранной пары/аналогии сохранён.

Runtime LMX: NOT_RUN. Это публикация исходников, договоров и полных размеров, не новый parser/runtime receipt.
