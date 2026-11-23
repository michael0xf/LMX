# Итератор до Stop: готовая библиотека и полный цикл

## Общая граница

Библиотека вызывает шаг, исполняет тело для каждого элемента и останавливается на отдельном признаке конца. Клиент задаёт источник и действие. Серия 1, 2, 3, Stop даёт **12**, **4** шага и **3** тела. Серия −2, 0, 4, Stop после прибавления 3 и двух чтений элемента даёт **22** с теми же счётчиками.

Клиент: [раздел H09](../../LMX_examples_and_analogies.ru.md#h09) и [его исходник](../lmx/H09.lm3). Здесь полностью показан повторяемый механизм, исключённый из клиента. Прикладные действия, входные значения и наблюдения остаются у клиента. Это компоненты данного корпуса, а не новые встроенные операции.

## Реализация LMX

[Исходник](../libraries/lmx/Cycles.lm3). Он подготавливается вместе с клиентом существующим загрузчиком Fable. import разрешает доступные имена; он не читает файл по пути.

```lmx
Cycles:
    @: iteration
    @: body
    iterate:
        while: 1
            iteration()
            catch: Stop ()
                break
            body()
```

## Реализация Haskell

[Модуль](../libraries/haskell/StepIterator.hs). Папка examples/libraries/haskell добавляется к пути поиска модулей. Прикладные проверки находятся в [Analogies.hs](../haskell/Analogies.hs).

```haskell
module StepIterator (Step(..), iterateUntilStop) where

data Step a = Yield a | Stop

iterateUntilStop :: IO (Step a) -> (a -> IO ()) -> IO ()
iterateUntilStop next body = do
  step <- next
  case step of
    Stop -> pure ()
    Yield value -> do
      body value
      iterateUntilStop next body
```

## Контракт и ограничения

LMX-компонент перенесён из исходного H09 без изменения алгоритма. Он принимает объявление итерации и тело по существующему контракту передачи деклараций. iteration() выполняет объявление в принимающем корневом namespace; тело использует установленное место item. Повторного запуска RHS при входе в тело нет. Catch обрабатывает Stop шага; тело не вызывается после остановки.

Haskell-модуль определяет собственный Step a = Yield a | Stop и свой цикл. Он не выдаёт встроенный list iterator или mapM_ за показанную реализацию. Получение значения выражено IO (Step a), тело — явной функцией a -> IO (). Haskell не получает способности объявлять переменную в чужом namespace. Источник на IORef и наблюдение суммы находятся в iteratorCase файла Analogies.hs.

Нулевой элемент попадает в Yield 0, а не становится Stop. Два чтения готового значения в теле не запускают шаг. Посторонние ошибки действий не превращаются в конец потока. Аналогия ограничена протоколом и наблюдениями; одинаковое представление ленивого списка и изменяемого LMX-источника не обещается.

Операторный заголовок не добавлен: здесь проверяется переданное объявление и принимаемый namespace. Prepared-операнд изменил бы момент вычисления шага, а дополнительный raw-операнд не сокращает механизм.

**English scope.** Both custom loops are shown. Haskell passes yielded values explicitly and does not implement declaration injection into a caller namespace. Zero is data; Stop is a separate end signal.

## Размер реализаций

| Реализация | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 73 | 9 |
| Haskell | 221 | 10 |

Подсчитаны полные листинги выше, включая модуль Haskell и заголовки LMX. Вызовы, наблюдения и тестовая обвязка относятся к клиентам. Библиотека уменьшает клиентский листинг; её код остаётся видимым и считается отдельно. Эти размеры не оценивают быстродействие.

## Проверка и источники

LMX проверен по документации; исполнение ядра не заявляется. Проверки Haskell написаны в Analogies.hs; наличие теста не является сообщением о его выполнении. Из корня распакованного корпуса:

```sh
runghc -iexamples/libraries/haskell examples/haskell/Analogies.hs
```

- [LMX: declaration arguments](../../../LMX_semantics.en.md#declaration-arguments).
- [Исходное сравнение Iterator](../../01_iterator_comparison.md).
- [Haskell 2010: case expressions](https://www.haskell.org/onlinereport/haskell2010/haskellch3.html).
- [Haskell 2010: IO sequencing](https://www.haskell.org/onlinereport/haskell2010/haskellch7.html).
