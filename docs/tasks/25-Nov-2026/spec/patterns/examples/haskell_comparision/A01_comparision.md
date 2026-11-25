# A01. Shared structural slots and replacement field identity

## Общий договор

Две ссылки выбирают одну структуру слотов; замена второго поля y на z сохраняет длину 2 и делает z=9 видимым через исходную ссылку: 209.

**Сопоставимость: аналогия.** Общий IORef списка Field передаёт изменение через обе ссылки. Заменяется целый Field, включая имя, а не только число. Это явная модель дескриптора с именами; она не приписывает обычным Haskell-record полям возможность менять их имена и не моделирует все правила идентичности примитивов LMX.

## LMX — общая минимальная форма обоих стилей

Проверяется замена структурной позиции с изменением видимого имени поля и сохранением общего descriptor. Нужна настоящая запись в слот; обе формы минимально совпадают.

Оба стилевых варианта ссылаются на один полный исходник; повторный листинг не нужен.

```lmx
Slots:
    int: x 1
    int: y 2

Replacement:
    int: z 9

SlotProbe:
    return: int
    run:
        @: same Slots
        same[1] := Replacement[0]
        return: length(Slots) * 100 + Slots\z
```

[Полный исходник](source/lmx/A01.lm3)

## Haskell

```haskell
module A01 where

import Data.IORef (newIORef, readIORef, modifyIORef')

data Field = Field { name :: String, value :: Int } deriving (Eq, Show)

replaceAt :: Int -> a -> [a] -> [a]
replaceAt index replacement xs = take index xs ++ [replacement] ++ drop (index+1) xs

example :: IO (Int, [String])
example = do
  slots <- newIORef [Field "x" 1, Field "y" 2]
  let same = slots
      replacement = [Field "z" 9]
  modifyIORef' same (replaceAt 1 (head replacement))
  fields <- readIORef slots
  let Just z = lookup "z" [(name field,value field) | field <- fields]
  pure (length fields * 100 + z, map name fields)
```

[Полный исходник](source/haskell/A01.hs).

## Сравнение

| Аспект | LMX | Haskell |
| --- | --- | --- |
| Представленные формы | Полные процедурная и функциональная записи | Полный самостоятельный модуль; custom helpers указаны явно |
| Договор | Две ссылки выбирают одну структуру слотов; замена второго поля y на z сохраняет длину 2 и делает z=9 видимым через исходную ссылку: 209. | Наблюдения и пределы соответствия описаны выше |
| Числовой рейтинг | Не применяется к неполной аналогии | Граница аналогии не маскируется совпадением чисел |
| Метрики этой редакции | Полные актуальные исходники | Полный модуль и необходимые собственные зависимости |
| Исполнение | NOT_RUN | NOT_RUN |

Все размеры пересчитаны по актуальным исходникам. Обе LMX-формы включают объявления и полные Throws. Пользовательские Haskell-зависимости учитываются в полной границе один раз; несовпадающие механизмы остаются явно отмеченными аналогиями.

## Проверяемые наблюдения

[Контракты и ожидаемые результаты](validation/fixtures.json), [исполнимый Haskell harness](validation/Main.hs), [команда проверки](README.md#проверка). Ожидаемый результат не является протоколом успешного исполнения. GHC в среде подготовки отсутствует; компиляция и выполнение новых модулей не заявлены.

LMX всегда стартует с корня как L3 Thread без DATA и пользовательских аргументов. Именованные операции фикстуры выполняются после старта обычным механизмом вызовов; они не заменяют точку запуска программы.

Источники интерфейсов Haskell: [Haskell 2010 Report: expressions](https://www.haskell.org/onlinereport/haskell2010/haskellch3.html); [base: Data.IORef](https://hackage-content.haskell.org/package/base-4.20.1.0/docs/Data-IORef.html).

## Размер полного исходника

| Запись | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX — процедурный | 126 | 11 |
| LMX — функциональный | 126 | 11 |
| Haskell | 486 | 14 |

