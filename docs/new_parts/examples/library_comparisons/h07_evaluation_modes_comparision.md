# Два чтения значения и два исполнения действия

## Общая граница

Клиент содержит счётчик и исходное выражение Meter\next(). После обнуления два вызова prepared дают **2, 4** при **2** исполнениях next; отдельная raw-серия даёт **3, 7** при **4** исполнениях. Вынесен только механизм повторного использования значения либо повторного исполнения исходного occurrence.

Клиент: [раздел H07](../../LMX_examples_and_analogies.ru.md#h07) и [его исходник](../lmx/H07.lm3). Здесь полностью показан повторяемый механизм, исключённый из клиента. Прикладные действия, входные значения и наблюдения остаются у клиента. Это компоненты данного корпуса, а не новые встроенные операции.

## Реализация LMX

[Исходник](../../examples/libraries/lmx/EvaluationModes.lm3). Он подготавливается вместе с клиентом существующим загрузчиком Fable. import разрешает доступные имена; он не читает файл по пути.

```lmx
PreparedOps:
    @: left int
    []: @(int) right
    const: int: PASS_ARGS_AS_IS 0
    const: int: PRIORITY sys\priority("+")
    return: int
    twice:
        return: \left + \left

RawOps:
    @: left
    []: @ right
    const: int: PASS_ARGS_AS_IS 1
    const: int: PRIORITY sys\priority("+")
    return: int
    twice:
        int: first sys\eval(left)
        int: second sys\eval(left)
        return: first + second
```

## Реализация Haskell

[Модуль](../../examples/libraries/haskell/EvaluationModes.hs). Папка examples/libraries/haskell добавляется к пути поиска модулей. Прикладные проверки находятся в [Analogies.hs](../haskell/Analogies.hs).

```haskell
module EvaluationModes (preparedTwice, rawTwice) where

preparedTwice :: Int -> Int
preparedTwice value = value + value

rawTwice :: IO Int -> IO Int
rawTwice action = do
  first <- action
  second <- action
  pure (first + second)
```

## Контракт и ограничения

Prepared-заголовок намеренно специальный: `@: left int` и `[]: @(int) right` сохраняют контракт типизированных ссылок на целые. Raw принимает исходные occurrences и задаёт режим 1. Общий OPERANDS_TEMPLATE задаёт общие ссылки и режим 0; он не эквивалентен этим двум заголовкам. Повторное const-объявление после copy не используется как подмена свойства.

В prepared-варианте исполнитель expression получает значение до вызова метода; два `\left` читают готовое число. В raw-варианте два явных `sys\eval(left)` исполняют исходное выражение в его живом контексте дважды. Метод возвращает int, а не служебный указатель. Правый 0 сохранён из исходной проверки; оба тела его не используют. Дополнительный контракт бинарной арности не вводится.

В Haskell preparedTwice получает готовый Int; клиент выполняет действие один раз и передаёт результат. rawTwice получает IO Int и последовательно выполняет действие дважды. Это аналог показанных эффектов, а не реализация доступа Haskell к LMX-occurrence, его namespace или sys\eval. Полный механизм Haskell не прячется за словом thunk.

Исходные формы LMX не заменяются вычисленными числами. Сырой occurrence не сохраняется после окончания своего контекста. Проверки Haskell покрывают один вызов и обе последовательные серии.

**English scope.** Prepared values and raw source occurrences remain different contracts. Haskell models effect counts using a value or an explicit IO action; it does not claim access to the LMX source graph.

## Размер реализаций

| Реализация | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 295 | 18 |
| Haskell | 187 | 8 |

Подсчитаны полные листинги выше, включая модуль Haskell и заголовки LMX. Вызовы, наблюдения и тестовая обвязка относятся к клиентам. Библиотека уменьшает клиентский листинг; её код остаётся видимым и считается отдельно. Эти размеры не оценивают быстродействие.

## Проверка и источники

LMX проверен по документации; исполнение ядра не заявляется. Проверки Haskell написаны в Analogies.hs; наличие теста не является сообщением о его выполнении. Из корня распакованного корпуса:

```sh
runghc -iexamples/libraries/haskell examples/haskell/Analogies.hs
```

- [LMX: raw operands и sys\eval](../../../LMX_semantics.en.md#raw-operands).
- [Haskell 2010: non-strict expressions](https://www.haskell.org/onlinereport/haskell2010/haskellch3.html).
- [Haskell 2010: sequential IO actions](https://www.haskell.org/onlinereport/haskell2010/haskellch7.html).
