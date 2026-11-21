# Apply: библиотечный вызов переданного действия

## Общая граница

Готовый apply принимает действие int → int и одно число, вызывает действие один раз и возвращает его результат. В H01 клиент сначала выбирает удвоение, затем прибавление единицы; результаты 14 и 8 кодируются числом **1408**.

Клиент: [раздел H01](../../LMX_examples_and_analogies.ru.md#h01) и [его исходник](../lmx/H01.lm3). Здесь полностью показан повторяемый механизм, исключённый из клиента. Прикладные действия, входные значения и наблюдения остаются у клиента. Это компоненты данного корпуса, а не новые встроенные операции.

## Реализация LMX

[Исходник](../../examples/libraries/lmx/Application.lm3). Он подготавливается вместе с клиентом существующим загрузчиком Fable. import разрешает доступные имена; он не читает файл по пути.

```lmx
Application:
    @: operation
    int: value
    return: int
    apply:
        return: operation(value)
```

## Реализация Haskell

[Модуль](../../examples/libraries/haskell/IntApply.hs). Папка examples/libraries/haskell добавляется к пути поиска модулей. Прикладные проверки находятся в [Analogies.hs](../haskell/Analogies.hs).

```haskell
module IntApply (apply) where

apply :: (Int -> Int) -> Int -> Int
apply operation value = operation value
```

## Контракт и ограничения

LMX `Application\apply` — обычный метод со своим DATA: `operation`, `value`, `return`. Переданная ссылка сохраняет исходный DATA выбранного действия. Библиотека не копирует действие и не меняет его лексического владельца. Проверка конкретной сигнатуры через fn остаётся предметом H02.

Пользовательский операнд здесь не сокращает повторяемую композицию: тело уже содержит один прямой вызов. Поэтому дополнительный OPERANDS_TEMPLATE не вводится. Haskell использует полностью показанную собственную функцию, а не скрытый стандартный `$`. В `applicationExample` изменяемый выбор действия представлен явным IORef; функция библиотеки только применяет полученное значение.

**English scope.** Both clients receive the complete helper shown here. The operation is invoked once; function-reference rebinding belongs to the client and is not hidden in the helper.

## Размер реализаций

| Реализация | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 71 | 6 |
| Haskell | 87 | 3 |

Подсчитаны полные листинги выше, включая модуль Haskell и заголовки LMX. Вызовы, наблюдения и тестовая обвязка относятся к клиентам. Библиотека уменьшает клиентский листинг; её код остаётся видимым и считается отдельно. Эти размеры не оценивают быстродействие.

## Проверка и источники

LMX проверен по документации; исполнение ядра не заявляется. Проверки Haskell написаны в Analogies.hs; наличие теста не является сообщением о его выполнении. Из корня распакованного корпуса:

```sh
runghc -iexamples/libraries/haskell examples/haskell/Analogies.hs
```

- [LMX: обычный вызов и DATA](../../newdocs/LMX_semantics.en.md#call-receivers).
- [Haskell 2010: application and lambda expressions](https://www.haskell.org/onlinereport/haskell2010/haskellch3.html).
