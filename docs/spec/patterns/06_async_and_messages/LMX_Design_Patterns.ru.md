# LMX: Асинхронность, исполнители и Message

Go показывает каналы и goroutine, Erlang — изолированные процессы, mail и OTP supervision. Это характерные контроли для Message-модели LMX. Сравнения явно различают логического исполнителя, OS thread, readiness и завершение I/O.

15 сравнений: базовые исполнители/Message, structured concurrency, supervision, MapReduce и четыре явных прикладных протокола 109–112. Message сохраняет штатное исполнение; физические блокирующие native операции остаются на L2 boundary.

## Файлы

Markdown и CSV включают все 15 сравнений. XLSX и PDF в рабочем каталоге относятся к предыдущей редакции с 11 сравнениями.

- [Markdown](LMX_Comparison_06_async_and_messages.md)
- [Excel](LMX_Comparison_06_async_and_messages.xlsx)
- [PDF](LMX_Comparison_06_async_and_messages.pdf)
- [CSV](LMX_Comparison_06_async_and_messages.csv)

## Каталог

### 058. [Thread Pool](058_thread_pool_comparision.md)

Ограниченный набор исполнителей переиспользуется для последовательности заданий.

**Сценарий:** Два worker обрабатывают четыре задания 1,2,3,4, вычисляя квадрат.

**Наблюдение:** Получено множество результатов {1,4,9,16}; одновременно активны не более двух worker. Порядок ответов не задан.

LMX ограничивает количество логических исполнителей; отображение на OS threads определяется штатным Thread scheduler. Go goroutine и Erlang process также не равны одному выделенному OS thread.

### 059. [Producer-Consumer](059_producer_consumer_comparision.md)

Производитель и потребитель связываются очередью, сохраняя порядок одного отправителя.

**Сценарий:** Один producer отправляет 1,2,3, затем finish. Consumer суммирует значения.

**Наблюдение:** После finish получен 6; каждый элемент принят один раз в данном безаварийном локальном сценарии.

LMX и Erlang выражают consumer владельцем состояния; Go показывает канал между producer goroutine и вызывающей goroutine. Буфер Go ограничен двумя; базовый mailbox не получает такой предел автоматически.

### 060. [Actor Model](060_actor_model_comparision.md)

Владелец изолированного состояния принимает целые операции через сообщения.

**Сценарий:** Два клиента отправляют add(2) и add(5) в один счётчик из состояния 0.

**Наблюдение:** После подтверждённого выполнения обеих операций read возвращает 7 при любом порядке их admission.

Message непосредственно соответствует выбранной actor-модели: один владелец mutable graph и последовательное исполнение. Структурный callable и транспорт не создают общего mutable heap между владельцами.

### 061. [Active Object](061_active_object_comparision.md)

Вызов ставит операцию в очередь владельца и отделён от её исполнения.

**Сценарий:** Клиент отправляет compute(6); отдельный исполнитель вычисляет удвоение и доставляет 12.

**Наблюдение:** Submit не исполняет compute на полосе клиента; получен один результат 12.

В LMX транспорт обычного вызова уже описан через post. Go выделяет request/reply object; Erlang использует envelope с Ref. Методы результата не выбираются заново по списку слушателей.

### 062. [Reactor](062_reactor_comparision.md)

Готовность дескриптора запускает обработчик, который сам выполняет неблокирующее чтение.

**Сценарий:** Провайдер сообщает ready(fd=3); ReadReady(3) возвращает 2 байта, затем would-block=0.

**Наблюдение:** Первая готовность приводит к чтению и одному sink(2); would-block не завершает соединение.

У LMX событие готовности становится Message. Существенный признак Reactor сохранён: реальные байты читает handler после уведомления. Go/Erlang loops показывают тот же adapter boundary.

### 063. [Proactor](063_proactor_comparision.md)

Операция чтения запускается заранее; обработчик получает уже завершённый результат.

**Сценарий:** SubmitRead(fd=3,token=7) затем completion(7,2). Handler не вызывает дополнительное чтение.

**Наблюдение:** Ровно один submit и sink(2); completion с чужим token игнорируется.

От Reactor отличается момент выполнения I/O и содержимое уведомления. Сообщение LMX само не превращает readiness provider в completion provider.

### 064. [Future / Promise](064_future_promise_comparision.md)

Однократно завершённый результат доступен всем ожидающим и поздним читателям.

**Сценарий:** Два клиента запрашивают результат до resolve(7), третий — после. Повтор resolve(9) отклоняется.

**Наблюдение:** Три клиента получают 7; resolve принимает только первое значение.

LMX/Erlang сохраняют ожидающих у владельца. Go close(done) одновременно публикует значение и разблокирует читателей по контракту каналов; это не polling.

### 071. [Half-Sync / Half-Async](071_half_sync_half_async_comparision.md)

Асинхронный ввод отделён очередью от синхронной обработки и выдачи результата.

**Сценарий:** Ввод доставляет frame 3 и 4; worker синхронно вычисляет квадрат; writer получает 9 и 16.

**Наблюдение:** Обработка не выполняется внутри I/O callback; результаты 9,16 переданы writer.

Разделение ролей выражается самостоятельными Message и почтой. Go канал соединяет async-facing слой и sync worker; Erlang отделяет процесс worker от отправителя.

### 088. [Structured Concurrency](088_structured_concurrency_comparision.md)

Родитель ограничивает время жизни двух дочерних задач своим scope и дожидается обеих даже при ошибке.

**Сценарий:** Дочерние задачи возвращают 2 и 3: итог 5. Если первая отказывает, вторая получает stop request; scope завершается только после обоих stopped notifications.

**Наблюдение:** Успех даёт 5. При ошибке ошибка возвращается после завершения обеих задач; живого ребёнка за границей scope нет.

LMX использует уже описанную иерархию Message и добавляет явный result barrier. Go показывает cooperative cancellation, Erlang — monitor и принудительный shutdown; эти способы отмены не тождественны.

### 089. [Supervision Tree](089_supervision_tree_comparision.md)

Родитель наблюдает за прямым ребёнком и ограниченно перезапускает его после отказа.

**Сценарий:** Первый запуск ребёнка отказывает, второй успешен. Разрешён один restart; повторный отказ останавливает восстановление.

**Наблюдение:** Созданы две разные child identities; успешный ребёнок не перезапускается.

LMX использует штатное отношение прямого родительства; restart strategy остаётся приложением. Erlang OTP поставляет зрелый supervisor; Go пример реализует короткий ограниченный контроллер.

### 090. [MapReduce](090_map_reduce_comparision.md)

Map порождает ключи, shuffle направляет их владельцам, reduce объединяет значения по ключу.

**Сценарий:** Две входные части [1,2] и [3,4] группируются по чётности. Map выдаёт (n mod 2,1); reduce считает элементы.

**Наблюдение:** Результат {0:2,1:2}. Чтение итогов выполняется после четырёх подтверждённых reduce-операций.

LMX выражает shuffle явным выбором Message-владельца ключа; Go channel и Erlang mail переносят ключи. Это раскрывает алгоритм map/group/reduce, но ещё не распределённый движок Google MapReduce.

### 109. [Request-Response / Ask](109_request_response_ask_comparision.md)

Запрос завершается поздним reply либо deadline; owner продолжает обслуживать сообщения.

**Сценарий:** Один запрос с token=1 истекает. После этого начинается token=2. Поздний reply token=1 игнорируется; reply token=2 со значением 12 принимается. Query обслуживается при active=1.

**Наблюдение:** Для token=1 один terminal timeout, для token=2 один результат 12; повторный reply/deadline не создаёт нового результата. Busy и исчерпание i64 counter дают отдельный отказ.

LMX показывает post/answer и owner state; Go — тот же автомат в channel loop с явными nonblocking Compute/Schedule ports; Erlang — process receive и send_after. Это прикладное управление deadline, а не новый блокирующий ask primitive.

### 110. [Become / Selective Stash](110_become_selective_stash_comparision.md)

Изменение поведения откладывает только work; control, queries и replies сохраняют обслуживание.

**Сценарий:** В paused phase принять work(1,2) и work(2,3), третий work отклонить из-за capacity=2. Между ними обслужить query и reply. become(1) запускает FIFO pump по одному элементу на turn; stop отменяет оставшийся stash.

**Наблюдение:** Query видит phase=0,count=2; reply доставлен сразу по своему handler. Принятые work дают 4 и 6 по FIFO, без повторного эффекта от лишнего pump. Stop не помещается в stash и оставляет count=0.

Go использует ограниченный slice и отдельный wake channel; Erlang — bounded list и self message. gen_statem postpone служит концептуальным аналогом, но здесь список явно ограничен и отложены только work. Полный небольшой FIFO включён во все листинги.

### 111. [Phased Message Lifecycle](111_phased_message_lifecycle_comparision.md)

Живой parent сначала завершает работу детей, затем закрывает их, затем закрывается сам.

**Сценарий:** Два текущих ребёнка получают drain. Каждый запускает native flush и продолжает query; flushed освобождает завершённый native ресурс и посылает drained. После двух drained parent запрашивает закрытие children, после двух stopped публикует итог и закрывает себя.

**Наблюдение:** Порядок phase parent: 0→1→2→3; duplicate и чужое epoch ничего не уменьшают. Query работает в phases 1 и 2. Итог ровно один, и нет запроса или ожидания из уже остановленного parent/poststop.

Это дополнение к 089 Supervision Tree: рестарт и его budget остаются отдельной политикой. Go явно хранит phases и seen arrays, Erlang подтверждает остановку monitor references/DOWN, LMX использует штатный lifecycle provider. Фаза остановки не переносится в poststop.

### 112. [External Blocking Adapter](112_external_blocking_adapter_comparision.md)

Физический блокирующий вызов вынесен в native L2 worker; LMX получает обычный Message completion.

**Сценарий:** Принять один native job, обслужить query, начать close, отклонить новые jobs. Native completion возвращает действительный ok/value после освобождения native holds; затем owner освобождает idle adapter и закрывается.

**Наблюдение:** Пока native call не завершён, active=1 и query обслуживается. beginClose не считает job завершённым. Один completion даёт один итог; stale token ничего не меняет; releaseIdle и close происходят только при active=0.

Go запускает ровно одну goroutine с действительным supplied blocking function и bounded completion channel; Erlang запускает отдельный процесс, а native Call обязан быть port либо корректно dirty-scheduled NIF. Сам spawn не делает произвольный блокирующий NIF безопасным. LMX-автомат не маскирует отсутствие физического adapter.
