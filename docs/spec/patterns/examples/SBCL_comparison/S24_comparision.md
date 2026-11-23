# S24. SBCL: очередь сообщений и отдельный поток

Протокольная аналогия. Требует LMX integration fixture и исключена из итоговых коэффициентов.

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

## Размер основного варианта

| Источник | Полный, без пробельных | Без сложного Throws | Все символы | Непустые строки |
| --- | ---: | ---: | ---: | ---: |
| LMX | 435 | 435 | 828 | 39 |
| Common Lisp / SBCL | 251 | — | 305 | 8 |

Учитывается полный основной листинг. Тестовый стенд и отдельные реализации ядра в него не входят; их файлы и размеры приведены отдельно.

## LMX

[Исходник](source/lmx/S24.lm3).

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

## Common Lisp / SBCL

[Исходник](source/common-lisp/S24.lisp).

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

## Почему эти варианты сопоставимы

Исходный полный вариант; нормы и конечные эффекты проверены.

В первичный исходник включены producer и worker. Симметричный хостовый bootstrap вынесен в source/common-lisp/S24_host.lisp; он создаёт mailbox/thread и ждёт завершения. Это действующие API SBCL, а не модель в одном потоке.

Message имеют отдельные арены; host заранее передаёт адреса worker и collector и данные items. Адресованные методы приведены полностью: WorkerMessage/Add/add, WorkerMessage/Finish/finish, CollectorMessage/accept. post не считается синхронным join. Producer сохраняется до обработки его pending reply, worker заканчивается только после finish, collector — после результата. Полный L3 bootstrap и parser fixture post в текущем пакете отсутствуют, поэтому пример исключён из суммарных отношений размеров.

Средства Common Lisp/SBCL: `SB-CONCURRENCY:MAKE-MAILBOX`, `SB-CONCURRENCY:SEND-MESSAGE`, `SB-CONCURRENCY:RECEIVE-MESSAGE`, `SB-THREAD:MAKE-THREAD`, `SB-THREAD:JOIN-THREAD`.

## Реализации используемых функций

Основной листинг использует базовые средства языка и полностью приведённые прикладные определения.

Common Lisp-клиент не загружает сравнительные reference-реализации.

## Проверка

SBCL: [фактический отчёт](validation/common_lisp.json). LMX: **NOT_RUN**; структурная проверка текста не доказывает исполнение.

## Первичные источники

- <https://www.sbcl.org/manual/index.html#Mailbox-_0028lock_002dfree_0029>
- <https://www.sbcl.org/manual/index.html#Threading>
