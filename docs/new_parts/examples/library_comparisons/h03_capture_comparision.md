# Capture: сохранить один аргумент и вернуть действие

## Общая граница

Готовая библиотека сохраняет первое целое значение и ссылку на бинарное действие int × int → int, после чего возвращает действие с одним входом. Клиент сам задаёт сложение и создаёт add5/add100. Наблюдение **(6, 101, 6)**, код **6101006**; внешний saved = 1000 не влияет на результат.

Клиент: [раздел H03](../../LMX_examples_and_analogies.ru.md#h03) и [его исходник](../lmx/H03.lm3). Здесь полностью показан повторяемый механизм, исключённый из клиента. Прикладные действия, входные значения и наблюдения остаются у клиента. Это компоненты данного корпуса, а не новые встроенные операции.

## Реализация LMX

[Исходник](../../09_functional_computation/examples/lmx/099_integer_partial_application_implementation.lm3). Он подготавливается вместе с клиентом существующим загрузчиком Fable. import разрешает доступные имена; он не читает файл по пути.

```lmx
CapturePrototype:
    int: saved 0
    @: binary 0
    inputs:
        int: second
        return: int
        apply:
            return: node\binary(node\saved; second)

Curry:
    @: binary
    int: first
    return: @
    capture:
        @: instance (copy(CapturePrototype))
        @: owner parent(instance\inputs)
        owner\saved := first
        owner\binary := binary
        return: instance\inputs\apply
```

## Реализация Haskell

[Модуль](../../examples/libraries/haskell/CurryInt.hs). Папка examples/libraries/haskell добавляется к пути поиска модулей. Прикладные проверки находятся в [Analogies.hs](../haskell/Analogies.hs).

```haskell
module CurryInt (capture) where

capture :: (Int -> Int -> Int) -> Int -> (Int -> Int)
capture binary first = \second -> binary first second
```

## Контракт и ограничения

Это повторное использование [реализации 099](../../09_functional_computation/099_integer_partial_application_implementation_comparision.md). LMX-исходник остаётся в каталоге 099. CurryInt.hs здесь — точная копия Haskell-модуля 099 с правильным именем файла для обычного поиска модулей; содержимое и SHA-256 сверяются в аудите.

Фабрика копирует граф прототипа, выбирает фактического владельца `parent(instance\inputs)` и явно записывает saved и binary. Внешняя группа `(copy(...))` имеет собственные клетки; запись только в её слот saved не была бы записью в лексическое состояние метода. Возвращается ссылка на `inputs\apply`, а не адрес локальной переменной фабрики. После двух созданий `CapturePrototype\saved` остаётся 0.

`node\saved` и `node\binary` выбирают сохранённый лексический контекст. Возвращённый метод имеет только вход second; `add5(1; saved := 25)` отклоняется: saved не является его формалом. Это отличается от default H04 и свободного динамического имени H05.

Операнд для обычного двухаргументного вызова capture не нужен. В Haskell лексическое замыкание записано непосредственно; LMX показывает своё явное построение графа. Скрытый захват кадра LMX не предполагается.

**English scope.** The same custom capture library is used by H03 and pattern 085/099. Application arithmetic remains in the client. LMX explicitly stores the value and callable reference in the copied lexical owner.

## Размер реализаций

| Реализация | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 275 | 18 |
| Haskell | 114 | 3 |

Подсчитаны полные листинги выше, включая модуль Haskell и заголовки LMX. Вызовы, наблюдения и тестовая обвязка относятся к клиентам. Библиотека уменьшает клиентский листинг; её код остаётся видимым и считается отдельно. Эти размеры не оценивают быстродействие.

## Проверка и источники

LMX проверен по документации; исполнение ядра не заявляется. Проверки Haskell написаны в Analogies.hs; наличие теста не является сообщением о его выполнении. Из корня распакованного корпуса:

```sh
runghc -iexamples/libraries/haskell examples/haskell/Analogies.hs
```

- [LMX: копирование и возвращаемые методы](../../newdocs/LMX_semantics.en.md#composition).
- [Haskell 2010: lambda and let expressions](https://www.haskell.org/onlinereport/haskell2010/haskellch3.html).
