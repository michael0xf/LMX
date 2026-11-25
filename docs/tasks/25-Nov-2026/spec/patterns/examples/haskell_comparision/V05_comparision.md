# V05. Command/read integration check and fault modes

## Общий договор

Два обязательных цикла set(1),observe,set(0),observe; при fault=0/1/2 ответы True/False/False. Всегда две записи, два чтения, trace=1202.

**Сопоставимость: полная пара.** Device хранит две произвольные операции. Общая cycleDevice выполняет set и observe; check сначала исполняет оба IO-цикла, затем применяет && к полученным Bool. Поэтому ошибка первого сравнения не отменяет выключение. State позволяет проверить commanded=0 и sensed=0/0/1. Сравнивается этот локальный контракт устройства; внутренние parent-адреса LMX не объявлены Haskell-адресами.

## LMX — общая минимальная форма обоих стилей

Оба цикла set/observe должны выполняться безусловно, в том числе после неуспешного первого. Замена на короткое замыкание пропустила бы off. Общие mark/cycle и обязательные эффекты сохраняются.

Оба стилевых варианта ссылаются на один полный исходник; повторный листинг не нужен.

```lmx
Indicator:
    int: command
    int: fault 0
    int: commanded 0
    int: sensed 0
    int: writes 0
    int: reads 0
    int: trace 0
    return: int
    mark:
        node\trace := node\trace * 10 + command
        return: 1
    set:
        node\commanded := command
        node\writes += 1
        mark()
        if: node\fault = 0
            node\sensed := command
        if: node\fault = 1
            node\sensed := 0
        if: node\fault = 2
            node\sensed := 1
        return: 1
    observe:
        node\reads += 1
        mark(2)
        return: node\sensed

Commissioning:
    @: candidate
    int: command
    return: int
    cycle:
        int: ack candidate\set(command := command)
        int: seen candidate\observe()
        return: ack = 1 && seen = command
    check:
        int: on cycle(command := 1)
        int: off cycle(command := 0)
        return: on && off
```

[Полный исходник](source/lmx/V05.lm3)

## Haskell

```haskell
module V05 where

import Prelude hiding (reads)
import Data.IORef (IORef, newIORef, readIORef, modifyIORef')

data State = State
  { commanded :: Int, sensed :: Int, writes :: Int, reads :: Int, trace :: Int }
  deriving (Eq, Show)
data Device = Device { set :: Int -> IO Int, observe :: IO Int }

makeDevice :: Int -> IO (Device, IORef State)
makeDevice fault = do
  state <- newIORef (State 0 0 0 0 0)
  let mark event = modifyIORef' state (\s -> s { trace = trace s * 10 + event })
      setCommand command = do
        modifyIORef' state (\s -> s { commanded = command, writes = writes s + 1,
          sensed = case fault of { 0 -> command; 1 -> 0; 2 -> 1; _ -> sensed s } })
        mark command
        pure 1
      readSensor = do
        modifyIORef' state (\s -> s { reads = reads s + 1 })
        mark 2
        sensed <$> readIORef state
  pure (Device setCommand readSensor, state)

cycleDevice :: Device -> Int -> IO Bool
cycleDevice candidate command = do
  ack <- set candidate command
  seen <- observe candidate
  pure (ack == 1 && seen == command)

check :: Device -> IO Bool
check candidate = do
  on <- cycleDevice candidate 1
  off <- cycleDevice candidate 0
  pure (on && off)
```

[Полный исходник](source/haskell/V05.hs).

## Сравнение

| Аспект | LMX | Haskell |
| --- | --- | --- |
| Представленные формы | Полные процедурная и функциональная записи | Полный самостоятельный модуль; custom helpers указаны явно |
| Договор | Два обязательных цикла set(1),observe,set(0),observe; при fault=0/1/2 ответы True/False/False. Всегда две записи, два чтения, trace=1202. | Наблюдения и пределы соответствия описаны выше |
| Числовой рейтинг | Полный сопоставимый текст | Тот же полный договор |
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
| LMX — процедурный | <span style="color:#176233"><u>547</u></span> | 39 |
| LMX — функциональный | <span style="color:#176233"><u>547</u></span> | 39 |
| Haskell | 885 | 31 |

