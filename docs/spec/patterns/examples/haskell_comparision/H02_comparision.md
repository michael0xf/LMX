# H02. Named signature positions versus candidate names

## Общий договор

Различить порядок позиций сигнатуры a,b и собственные имена кандидата b,a. Упаковка двух вызовов: 2772.

**Сопоставимость: аналогия.** Haskell-код действительно вычисляет 27 и 72: два адаптера берут поля Arguments в разном порядке. Именованное связывание и проверка допуска LMX здесь представлены явно написанными адаптерами; это не встроенный Haskell-механизм именованных фактических аргументов. Поэтому числового рейтинга этой строки нет.

## LMX — процедурный

```lmx
PairOperation :: (int: a; int: b; return: int)

Candidate:
    int: b
    int: a
    return: int
    encode:
        return: b * 10 + a

SignatureProbe:
    return: int
    run:
        @PairOperation: selected Candidate\encode
        int: first selected(a := 2; b := 7)
        int: second Candidate\encode(a := 2; b := 7)
        return: first * 100 + second
```

[Полный исходник](source/lmx/procedural/H02.lm3)
## LMX — функциональный

```lmx
PairOperation :: (int: a; int: b; return: int)

Candidate:
    int: b
    int: a
    return: int
    encode:
        return: b * 10 + a

SignatureProbe:
    return: int
    run:
        @PairOperation: selected Candidate\encode
        return: selected(a := 2; b := 7) * 100 + Candidate\encode(a := 2; b := 7)
```

[Полный исходник](source/lmx/H02.lm3)

## Haskell

```haskell
module H02 where

data Arguments = Arguments { a :: Int, b :: Int }

encode :: Int -> Int -> Int
encode bValue aValue = bValue * 10 + aValue

bySignatureNames, byCandidateNames :: Arguments -> Int
bySignatureNames args = encode (a args) (b args)
byCandidateNames args = encode (b args) (a args)

example :: Int
example = let args = Arguments { a = 2, b = 7 }
          in bySignatureNames args * 100 + byCandidateNames args
```

[Полный исходник](source/haskell/H02.hs).

## Сравнение

| Аспект | LMX | Haskell |
| --- | --- | --- |
| Представленные формы | Полные процедурная и функциональная записи | Полный самостоятельный модуль; custom helpers указаны явно |
| Договор | Различить порядок позиций сигнатуры a,b и собственные имена кандидата b,a. Упаковка двух вызовов: 2772. | Наблюдения и пределы соответствия описаны выше |
| Числовой рейтинг | Не применяется к неполной аналогии | Граница аналогии не маскируется совпадением чисел |
| Метрики этой редакции | Полные актуальные исходники | Полный модуль и необходимые собственные зависимости |
| Исполнение | NOT_RUN | NOT_RUN |

Все размеры пересчитаны по актуальным исходникам. Обе LMX-формы включают объявления и полные Throws. Пользовательские Haskell-зависимости учитываются в полной границе один раз; несовпадающие механизмы остаются явно отмеченными аналогиями.

## Проверяемые наблюдения

[Контракты и ожидаемые результаты](validation/fixtures.json), [исполнимый Haskell harness](validation/Main.hs), [команда проверки](README.md#проверка). Ожидаемый результат не является протоколом успешного исполнения. GHC в среде подготовки отсутствует; компиляция и выполнение новых модулей не заявлены.

LMX всегда стартует с корня как L3 Thread без DATA и пользовательских аргументов. Именованные операции фикстуры выполняются после старта обычным механизмом вызовов; они не заменяют точку запуска программы.

Источники интерфейсов Haskell: [Haskell 2010 Report: expressions](https://www.haskell.org/onlinereport/haskell2010/haskellch3.html).

## Размер полного исходника

| Запись | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX — процедурный | 245 | 14 |
| LMX — функциональный | 215 | 12 |
| Haskell | 332 | 10 |
