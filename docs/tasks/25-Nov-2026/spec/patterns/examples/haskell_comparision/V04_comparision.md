# V04. Distinguish a named failure from a numeric result

## Общий договор

Распознать именно именованную ошибку NoSample; обычный числовой ноль ошибкой не считается.

**Сопоставимость: полная пара.** NoSample — отдельный тип Exception. catch обрабатывает только этот тип; zero успешно возвращает 0 и checker возвращает 0. Другая ошибка не поглощается. В сравнении показаны объявления исключения, throwIO и весь обработчик, без ручного сравнения строк имени ошибки.

## LMX — общая минимальная форма обоих стилей

Именованный catch отличает NoSample от нормального нулевого результата. Его минимальная прямая форма общая; универсальное recover изменило бы границу типов/ошибок.

Оба стилевых варианта ссылаются на один полный исходник; повторный листинг не нужен.

```lmx
UnavailableSensor:
    return: int
    read:
        throws: NoSample
        throw: NoSample()
    zero:
        return: 0

FailureCheck:
    @: candidate
    return: int
    check:
        candidate()
        return: 0
        catch: NoSample ()
            return: 1
```

[Полный исходник](source/lmx/V04.lm3)

## Haskell

```haskell
module V04 where

import Control.Exception (Exception, catch, throwIO)

data NoSample = NoSample deriving Show
instance Exception NoSample

unavailable, zero :: IO Int
unavailable = throwIO NoSample
zero = pure 0

check :: IO Int -> IO Int
check candidate = (candidate >> pure 0) `catch` (\NoSample -> pure 1)
```

[Полный исходник](source/haskell/V04.hs).

## Сравнение

| Аспект | LMX | Haskell |
| --- | --- | --- |
| Представленные формы | Полные процедурная и функциональная записи | Полный самостоятельный модуль; custom helpers указаны явно |
| Договор | Распознать именно именованную ошибку NoSample; обычный числовой ноль ошибкой не считается. | Наблюдения и пределы соответствия описаны выше |
| Числовой рейтинг | Полный сопоставимый текст | Тот же полный договор |
| Метрики этой редакции | Полные актуальные исходники | Полный модуль и необходимые собственные зависимости |
| Исполнение | NOT_RUN | NOT_RUN |

Все размеры пересчитаны по актуальным исходникам. Обе LMX-формы включают объявления и полные Throws. Пользовательские Haskell-зависимости учитываются в полной границе один раз; несовпадающие механизмы остаются явно отмеченными аналогиями.

## Проверяемые наблюдения

[Контракты и ожидаемые результаты](validation/fixtures.json), [исполнимый Haskell harness](validation/Main.hs), [команда проверки](README.md#проверка). Ожидаемый результат не является протоколом успешного исполнения. GHC в среде подготовки отсутствует; компиляция и выполнение новых модулей не заявлены.

LMX всегда стартует с корня как L3 Thread без DATA и пользовательских аргументов. Именованные операции фикстуры выполняются после старта обычным механизмом вызовов; они не заменяют точку запуска программы.

Источники интерфейсов Haskell: [Haskell 2010 Report: expressions](https://www.haskell.org/onlinereport/haskell2010/haskellch3.html); [base: Control.Exception](https://hackage-content.haskell.org/package/base-4.20.1.0/docs/Control-Exception.html).

## Размер полного исходника

| Запись | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX — процедурный | <span style="color:#176233"><u>160</u></span> | 15 |
| LMX — функциональный | <span style="color:#176233"><u>160</u></span> | 15 |
| Haskell | 257 | 9 |

