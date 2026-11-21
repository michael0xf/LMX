# Pipe: последовательная композиция подготовленных действий

## Общая граница

Готовый конвейер последовательно передаёт целое значение выбранным стадиям. В H06 путь 4 → twice → next даёт **9**, обратный порядок — **10**, общий код — **910**. Стадии остаются в клиенте. Контроль эффектов требует одного вызова каждой стадии в записанном порядке.

Клиент: [раздел H06](../../LMX_examples_and_analogies.ru.md#h06) и [его исходник](../lmx/H06.lm3). Здесь полностью показан повторяемый механизм, исключённый из клиента. Прикладные действия, входные значения и наблюдения остаются у клиента. Это компоненты данного корпуса, а не новые встроенные операции.

## Реализация LMX

[Исходник](../../02_architecture_and_boundaries/examples/lmx/093_pipe_implementation.lm3). Он подготавливается вместе с клиентом существующим загрузчиком Fable. import разрешает доступные имена; он не читает файл по пути.

```lmx
PipeLibrary:
    copy: sys\OPERANDS_TEMPLATE
    return: int
    pipe:
        int: value \left
        int: i 0
        while: i < length(right)
            @: stage \right[i]
            value := stage(value)
            i += 1
        return: value
```

## Реализация Haskell

[Модуль](../../examples/libraries/haskell/IntPipe.hs). Папка examples/libraries/haskell добавляется к пути поиска модулей. Прикладные проверки находятся в [Analogies.hs](../haskell/Analogies.hs).

```haskell
module IntPipe (pipe, pipeIO) where

pipe :: Int -> [Int -> Int] -> Int
pipe value [] = value
pipe value (stage : rest) =
  let next = stage value
  in next `seq` pipe next rest

pipeIO :: Int -> [Int -> IO Int] -> IO Int
pipeIO value [] = pure value
pipeIO value (stage : rest) = do
  next <- stage value
  next `seq` pipeIO next rest
```

## Контракт и ограничения

LMX повторно использует [компонент 093](../../02_architecture_and_boundaries/093_pipe_implementation_comparision.md). `copy: sys\OPERANDS_TEMPLATE` стоит первым в DATA. Заголовок задаёт режим 0 и приоритет сложения; return: int принадлежит pipe. Весь правый массив обходится явно: наличие right само по себе не создаёт fold.

Bare-ссылки на стадии подготавливаются как значения и не вызываются заранее. Тело pipe явно вызывает каждую стадию один раз. Если обычный вызов передал пустой массив именно формальному right, возвращается исходное значение. Операторная запись `4 pipe emptyArray` передала бы один правый аргумент-массив, а не ноль стадий: автоматического раскрытия массива здесь нет. Это также не правило о любой форме с отсутствующим actual. Здесь используются стадии int → int без объявленного recoverable failure и значения без переполнения.

Haskell pipe покрывает чистые стадии. Для проверки эффектов полный модуль дополнительно предоставляет pipeIO, последовательно исполняющий действия. compositionEffects проверяет результаты (9,10) и журнал ["twice","next","next","twice"]. Прикладные стадии остаются в клиенте. Чистая функция не выдаётся за действие с побочным эффектом.

Оба Haskell-варианта принудительно получают промежуточный Int через seq перед переходом к следующей стадии. Поэтому последующая стадия не может отбросить ещё не вычисленный предыдущий результат; отдельно от этого IO задаёт порядок эффектов.

merge компонует поля и связи графа, а не исполняет все стадии по очереди. Конвейер возвращает конечное число; он не выдаётся за фабрику сохраняемого замыкания-композиции.

**English scope.** LMX reuses 093. The full Haskell module includes pure and IO interfaces because effectful stage order is an explicit check, not an assumption about pure expression evaluation.

## Размер реализаций

| Реализация | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 145 | 11 |
| Haskell | 257 | 11 |

Подсчитаны полные листинги выше, включая модуль Haskell и заголовки LMX. Вызовы, наблюдения и тестовая обвязка относятся к клиентам. Библиотека уменьшает клиентский листинг; её код остаётся видимым и считается отдельно. Эти размеры не оценивают быстродействие.

## Проверка и источники

LMX проверен по документации; исполнение ядра не заявляется. Проверки Haskell написаны в Analogies.hs; наличие теста не является сообщением о его выполнении. Из корня распакованного корпуса:

```sh
runghc -iexamples/libraries/haskell examples/haskell/Analogies.hs
```

- [LMX: операнды](../../newdocs/LMX_semantics.en.md#operand-receiver).
- [LMX: копирование графа](../../newdocs/LMX_semantics.en.md#composition).
- [Haskell 2010: order of IO actions](https://www.haskell.org/onlinereport/haskell2010/haskellch7.html).

- [Haskell 2010: seq и порядок вычисления](https://www.haskell.org/onlinereport/haskell2010/haskellch6.html).
