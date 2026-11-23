# S24. SBCL: очередь сообщений и отдельный поток

Протокольная аналогия: LMX host fixture ожидает интеграции; оба стиля вне итоговых коэффициентов.

## Общий договор

Один producer посылает конечный список целых одному worker в FIFO mailbox, затем маркер :STOP. Worker суммирует числа и завершает работу. Хост создаёт mailbox/thread и ожидает результат; профиль гарантирует локальную доставку и отсутствие внешнего прерывания. Это не сравнение таймаутов, отказоустойчивости или разделяемой памяти.

## Входы и ожидаемые наблюдения

```json
[
  {
    "args": [
      [
        1,
        2,
        3
      ]
    ],
    "expected": 6
  },
  {
    "args": [
      []
    ],
    "expected": 0
  },
  {
    "args": [
      [
        -2,
        0,
        5
      ]
    ],
    "expected": 3
  }
]
```

## Размер полных вариантов

| Источник | Без пробельных | Все символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX — процедурный | 435 | 828 | 39 |
| LMX — функциональный | 528 | 970 | 45 |
| Common Lisp / SBCL | 251 | 305 | 8 |

Оба стиля LMX сравниваются независимо по одному договору. Все объявления, вспомогательные определения и Throws входят в размер. Реализация общих библиотечных операций учитывается отдельно один раз.

## LMX — процедурный

```lmx
ProducerMessage:
    int[]: items
    @: worker
    @: collector
    start:
        int: i 0
        while: i < length(items)
            post:
                ask:
                    worker\Add\add(value := items[i])
            ---
            i += 1
        post:
            ask:
                worker\Finish\finish()
            answer:
                collector\accept

WorkerMessage:
    int: total 0
    Add:
        int: value
        add:
            @: owner parent(node)
            owner\total += value
    ---
    Finish:
        return: int
        finish:
            @: owner parent(node)
            success := 1
            return: owner\total

CollectorMessage:
    int: value
    int: result 0
    int: completed 0
    accept:
        node\result := value
        node\completed := 1
        success := 1
```

[Полный исходник](source/lmx/procedural/S24.lm3). 435 непробельных символов; 39 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

```lmx
ProducerMessage:
    int[]: items
    @: worker
    @: collector
    Send:
        int: state
        int: value
        return: int
        send:
            post:
                ask:
                    worker\Add\add(value := value)
            ---
            return: state
    ---
    start:
        throws: copy(foldl\throws) copy(record\throws)
        (foldl items (0 record) Send\send)
        post:
            ask:
                worker\Finish\finish()
            answer:
                collector\accept

WorkerMessage:
    int: total 0
    Add:
        int: value
        add:
            @: owner parent(node)
            owner\total += value
    ---
    Finish:
        return: int
        finish:
            @: owner parent(node)
            success := 1
            return: owner\total

CollectorMessage:
    int: value
    int: result 0
    int: completed 0
    accept:
        node\result := value
        node\completed := 1
        success := 1
```

[Полный исходник](source/lmx/S24.lm3). 528 непробельных символов; 45 непустых строк. Все объявления и Throws включены.

## Common Lisp / SBCL

[Полный исходник](source/common-lisp/S24.lisp).

```common-lisp
(require :sb-concurrency)

(defun worker (inbox)
  (loop for message = (sb-concurrency:receive-message inbox)
        until (eq message :stop)
        sum message))

(defun produce (inbox items)
  (dolist (item items) (sb-concurrency:send-message inbox item))
  (sb-concurrency:send-message inbox :stop))
```

## Соответствие стилей договору

Оба стиля используют один owning Message и тот же FIFO post/reply. Функциональный foldl только обходит конечный вход, каждый Send посылает один Add; Finish идёт после него. S24 остаётся протокольной аналогией, runtime NOT_RUN.

В первичный исходник включены producer и worker. Симметричный хостовый bootstrap вынесен в source/common-lisp/S24_host.lisp; он создаёт mailbox/thread и ждёт завершения. Это действующие API SBCL, а не модель в одном потоке.

Message имеют отдельные арены; host заранее передаёт адреса worker и collector и данные items. Адресованные методы приведены полностью: WorkerMessage/Add/add, WorkerMessage/Finish/finish, CollectorMessage/accept. post не считается синхронным join. Producer сохраняется до обработки его pending reply, worker заканчивается только после finish, collector — после результата. Полный L3 bootstrap и parser fixture post в текущем пакете отсутствуют, поэтому пример исключён из суммарных отношений размеров.

## Общие операции и реализации

- `foldl`: [тело ядра](../../LMX_Fn_Receivers/src/collections.lmx); отдельное сравнение [SI01](library_comparisons/SI01_comparision.md).

- `record`: [тело ядра](../../LMX_Fn_Receivers/src/generic_functions.lmx); отдельное сравнение [SI02](library_comparisons/SI02_comparision.md).

Common Lisp-клиент использует указанные native/standard средства и не импортирует сравнительные реализации.

## Проверка

SBCL: [фактический отчёт](validation/common_lisp.json). Оба LMX-варианта: **NOT_RUN**; проверки текста не доказывают исполнение.

## Первичные источники

- <https://www.sbcl.org/manual/index.html#Mailbox-_0028lock_002dfree_0029>
- <https://www.sbcl.org/manual/index.html#Threading>
