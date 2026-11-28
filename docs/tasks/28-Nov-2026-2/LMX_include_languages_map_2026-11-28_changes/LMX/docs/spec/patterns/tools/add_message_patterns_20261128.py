#!/usr/bin/env python3
"""Update four authored Message records from their complete source mirrors."""
from pathlib import Path
import hashlib
import json

ROOT = Path(__file__).resolve().parents[1]
GROUP = ROOT / "06_async_and_messages"
COMMON_RU = (
    "Исполняемые экземпляры создаются штатным R0/Message host profile. "
    "Message не вводит deadlock; синхронного ожидания потока и LMX synchronized здесь нет. "
    "post сам связывает адресованный обмен и корреляцию. Поля token/epoch относятся к прикладному "
    "deadline или поколению ресурса, не реализуют второй scheduler. "
    "events — nonblocking owner-local observer для проверяемого trace; он не обращается синхронно "
    "к чужому Message. Физические timer/lifecycle/native adapters остаются REQUIRE_IMPLEMENTATION. "
    "LMX parser/type/runtime: NOT_RUN."
)
COMMON_EN = (
    "Executable instances use the ordinary R0/Message host profile. "
    "Message itself does not introduce deadlock; no blocking thread wait or LMX synchronized is added. "
    "post already binds addressed exchange and correlation. token/epoch are application deadline "
    "or resource-generation data, not a second scheduler. events is a nonblocking owner-local "
    "observation sink, never a synchronous call into another Message. Physical timer/lifecycle/native "
    "adapters remain REQUIRE_IMPLEMENTATION. LMX parser/type/runtime: NOT_RUN."
)

DATA = [
    dict(
        id=109, name="Request-Response / Ask", slug="request_response_ask",
        summary_ru="Запрос завершается поздним reply либо deadline; owner продолжает обслуживать сообщения.",
        summary_en="A request finishes through a later reply or deadline while its owner continues serving messages.",
        scenario_ru="Один запрос с token=1 истекает. После этого начинается token=2. Поздний reply token=1 игнорируется; reply token=2 со значением 12 принимается. Query обслуживается при active=1.",
        scenario_en="Request token 1 expires, then token 2 starts. A late reply for token 1 is ignored; token 2 accepts value 12. Query remains serviceable while active.",
        expected_ru="Для token=1 один terminal timeout, для token=2 один результат 12; повторный reply/deadline не создаёт нового результата. Busy и исчерпание i64 counter дают отдельный отказ.",
        expected_en="Token 1 has one terminal timeout and token 2 one result 12; repeated replies/deadlines create no further result. Busy and i64 counter exhaustion are separate rejections.",
        lmx_detail_ru="timer.schedule(token,selfAddress) только регистрирует поздний expire(token), не вызывает его внутри start. Service возвращает AskReply, answer выбирает received. Timeout переводит только локальный запрос в terminal state и не отменяет совершённый сервисом эффект. finished(token,status,value): status=0 success, status=1 timeout; при timeout value не является результатом. Host сохраняет ожидаемый failure route обычного post при transport rejection; здесь service/timer admission заранее принят.",
        lmx_detail_en="timer.schedule(token,selfAddress) registers a later expire(token), never reenters start. The service returns AskReply and answer selects received. Timeout ends only the local request and does not undo a service effect. finished status 0 means success and 1 timeout; the timeout value is inactive. The ordinary post failure route handles transport rejection; this fixture pre-admits service/timer delivery.",
        comparison_ru="LMX показывает post/answer и owner state; Go — тот же автомат в channel loop с явными nonblocking Compute/Schedule ports; Erlang — process receive и send_after. Это прикладное управление deadline, а не новый блокирующий ask primitive.",
        comparison_en="LMX shows post/answer and owner state, Go the same state machine in a channel loop with nonblocking Compute/Schedule ports, and Erlang receive/send_after. This is application deadline policy, not a new blocking ask primitive.",
        limits_ru="Один in-flight request на экземпляр; durable retries, exactly-once effect, service cancellation и общий multiplexed pending map не обещаны. Token counter не переиспользуется; новая owner identity отделяет следующий запуск. Все значения примера малы и не переполняют арифметику service.",
        limits_en="One in-flight request per instance. No durable retry, exactly-once effect, service cancellation or general multiplexed pending map. Tokens are not reused; a new owner identity separates restarts. Fixture values do not overflow service arithmetic.",
        go_notes="Go channel loop is complete; Compute queues DoubleReply on a separate service, Schedule queues a later Kind=2 event. Both supplied ports return immediately. Finished/Rejected/Status are nonblocking observers. Host wiring and timer implementation are outside the measured listing.",
        erlang_notes="Functions belong to one ordinary Erlang module; module/export and launcher are outside the fragment. The service and client are separate processes. send_after is an actual timer. The fixture injects controlled completion order; it does not assert a timed-out operation never ran.",
        sources=[
            ("Go specification: channel and select", "https://go.dev/ref/spec", "Channel loop и порядок событий.", "Channel loop and event ordering."),
            ("Erlang gen_statem: asynchronous requests", "https://www.erlang.org/doc/apps/stdlib/gen_statem.html", "Поздний reply и явный request identity.", "Later replies and request identity."),
        ],
    ),
    dict(
        id=110, name="Become / Selective Stash", slug="become_selective_stash",
        summary_ru="Изменение поведения откладывает только work; control, queries и replies сохраняют обслуживание.",
        summary_en="A behavior change defers only work; control, queries and replies remain serviceable.",
        scenario_ru="В paused phase принять work(1,2) и work(2,3), третий work отклонить из-за capacity=2. Между ними обслужить query и reply. become(1) запускает FIFO pump по одному элементу на turn; stop отменяет оставшийся stash.",
        scenario_en="While paused, accept work(1,2) and work(2,3), reject the third work at capacity two, and serve query/reply. become(1) pumps FIFO work one item per turn; stop rejects any remainder.",
        expected_ru="Query видит phase=0,count=2; reply доставлен сразу по своему handler. Принятые work дают 4 и 6 по FIFO, без повторного эффекта от лишнего pump. Stop не помещается в stash и оставляет count=0.",
        expected_en="Query observes phase 0/count 2 and reply runs through its own handler. Accepted work yields 4 then 6, with no repeated effect from extra pumps. Stop is never stashed and leaves count zero.",
        lmx_detail_ru="Кольцо из двух элементов полностью реализовано внутри LMX: ids,values,head,count. phase 0 paused, 1 running, 2 stopped. become меняет обычные данные поведения; это не встроенный scheduler opcode. pump удаляет item до эффекта и публикует лишь следующий обычный self Message. Control/query/reply ни в одной ветви не идут в очередь work. Stash содержит copied scalar values, не ссылки на умерший Frame.",
        lmx_detail_en="The two-item ring is entirely implemented in LMX using ids/values/head/count. Phases are paused 0, running 1, stopped 2. become changes ordinary behavior data, not a scheduler opcode. pump removes the item before its effect and posts only the next ordinary self Message. Control/query/reply never enter the work queue; stored values are scalars, not references to a dead Frame.",
        comparison_ru="Go использует ограниченный slice и отдельный wake channel; Erlang — bounded list и self message. gen_statem postpone служит концептуальным аналогом, но здесь список явно ограничен и отложены только work. Полный небольшой FIFO включён во все листинги.",
        comparison_en="Go uses a bounded slice and a separate wake channel; Erlang a bounded list and self message. gen_statem postpone is the conceptual analogue, but this queue is explicitly bounded and only work is deferred. Each listing includes its complete small FIFO.",
        limits_ru="Нет durable mailbox, общей selective-receive политики или автоматического повторения всех сообщений. Capacity=2 выбрана для проверяемого сценария. Внешний host не закрывает вход Go до завершения stop; hard termination вне этого договора.",
        limits_en="No durable mailbox, general selective-receive policy or automatic replay of all messages. Capacity two makes the fixture bounded. The Go host keeps input open until stop completes; hard termination is outside this contract.",
        go_notes="Complete channel/select owner loop. Kind 0 work, 1 become, 2 reply, 3 query, 4 stop. emit is a nonblocking observer; the host keeps the input channel live through stop. The wake channel coalesces scheduling hints, not work items.",
        erlang_notes="Ordinary process functions, with module/export and launcher outside the fragment. Only work tuples enter the bounded queue. The process keeps answering query/reply after stop until the harness sends terminate.",
        sources=[
            ("Erlang gen_statem behavior", "https://www.erlang.org/doc/system/statem.html", "Изменение состояния, postpone и сохранение системного обслуживания.", "State changes, postpone and continued system-message service."),
            ("Go specification: select", "https://go.dev/ref/spec", "Независимое обслуживание control и wake channels.", "Separate control and wake channel service."),
        ],
    ),
    dict(
        id=111, name="Phased Message Lifecycle", slug="phased_message_lifecycle",
        summary_ru="Живой parent сначала завершает работу детей, затем закрывает их, затем закрывается сам.",
        summary_en="A live parent drains children, then closes them, then closes itself.",
        scenario_ru="Два текущих ребёнка получают drain. Каждый запускает native flush и продолжает query; flushed освобождает завершённый native ресурс и посылает drained. После двух drained parent запрашивает закрытие children, после двух stopped публикует итог и закрывает себя.",
        scenario_en="Two current children receive drain. Each starts native flush and keeps serving query; flushed releases the completed native resource and sends drained. After both drained events the parent requests child close; after both stopped events it publishes the result and closes itself.",
        expected_ru="Порядок phase parent: 0→1→2→3; duplicate и чужое epoch ничего не уменьшают. Query работает в phases 1 и 2. Итог ровно один, и нет запроса или ожидания из уже остановленного parent/poststop.",
        expected_en="Parent phases progress 0→1→2→3; duplicates and foreign epochs do not decrement counts. Query works in phases 1 and 2. Exactly one result is published, with no request or wait from a stopped parent/poststop.",
        lmx_detail_ru="lifecycle.requestChildrenClose(epoch) только инициирует штатное закрытие двух прямых Thread.children; stopped(id,epoch) доставляется после действительной остановки и cleanup. Прикладные first/second являются адресатами drain, не вторым membership registry. requestOwnerClose инициируется в живом handler только после всех stopped. native.beginFlush возвращает admission сразу и позже посылает flushed(epoch,ok); releaseCompleted не ждёт будущего callback. childId 0/1 и generation задаёт host при создании отдельных экземпляров.",
        lmx_detail_en="requestChildrenClose(epoch) only initiates ordinary close of the two direct Thread.children; stopped arrives after actual termination and cleanup. first/second are drain destinations, not another membership registry. requestOwnerClose starts from the live handler after all stopped events. beginFlush admits immediately and later sends flushed; releaseCompleted never waits for another callback. The host binds childId 0/1 and the generation when creating distinct instances.",
        comparison_ru="Это дополнение к 089 Supervision Tree: рестарт и его budget остаются отдельной политикой. Go явно хранит phases и seen arrays, Erlang подтверждает остановку monitor references/DOWN, LMX использует штатный lifecycle provider. Фаза остановки не переносится в poststop.",
        comparison_en="This complements 089 Supervision Tree; restart and its budget remain separate policy. Go stores phases/seen arrays, Erlang confirms termination through monitor references/DOWN, and LMX uses its ordinary lifecycle provider. Shutdown coordination never moves into poststop.",
        limits_ru="Ограниченный graceful fixture: оба ребёнка живы при beginStop, все native flush завершаются, host сообщает actual stopped. Неожиданный hard crash, watchdog и restart — дополнительные сценарии 089/host provider, не фиктивный успешный drain. Flush failure передаётся как failed итог после корректного освобождения ресурса.",
        limits_en="Bounded graceful fixture: both children are alive at beginStop, native flushes complete, and the host reports actual stopped. Hard crash, watchdog and restart remain separate 089/host scenarios, never a fabricated successful drain. A flush failure yields a failed result after resources are released.",
        go_notes="Complete parent/child channel handlers; ports asynchronously route Drain, Flush, Drained and actual stopped events. CloseChildren/CloseOwner initiate lifecycle requests without joining a goroutine inside a handler. The host supplies generation and two child IDs.",
        erlang_notes="Parent and children are separate ordinary processes. Parent uses real process monitors and matches both monitor reference and PID. Flush is an explicitly supplied asynchronous native adapter, Release returns after completed flush cleanup. No child calls a blocking parent supervisor stop.",
        sources=[
            ("Erlang supervisor behavior", "https://www.erlang.org/doc/system/sup_princ.html", "Shutdown является фазой жизненного цикла, restart — отдельная стратегия.", "Shutdown is a lifecycle phase and restart a separate strategy."),
            ("Go pipelines and cancellation", "https://go.dev/blog/pipelines", "Прекращение admission отличается от завершения уже запущенной работы.", "Stopping admission differs from completing already running work."),
        ],
    ),
    dict(
        id=112, name="External Blocking Adapter", slug="external_blocking_adapter",
        summary_ru="Физический блокирующий вызов вынесен в native L2 worker; LMX получает обычный Message completion.",
        summary_en="A physically blocking call runs in a native L2 worker; LMX receives an ordinary Message completion.",
        scenario_ru="Принять один native job, обслужить query, начать close, отклонить новые jobs. Native completion возвращает действительный ok/value после освобождения native holds; затем owner освобождает idle adapter и закрывается.",
        scenario_en="Admit one native job, serve query, begin close and reject new jobs. A native completion reports real ok/value after releasing native holds; then the owner releases the idle adapter and closes.",
        expected_ru="Пока native call не завершён, active=1 и query обслуживается. beginClose не считает job завершённым. Один completion даёт один итог; stale token ничего не меняет; releaseIdle и close происходят только при active=0.",
        expected_en="While the native call runs, active is one and query remains serviceable. beginClose does not mark the job complete. One completion yields one result; a stale token changes nothing. releaseIdle/close occur only when inactive.",
        lmx_detail_ru="native.submit(token,value,selfAddress):int — узкая L2/host граница: 1 означает admission, 0 отказ без запуска. Она копирует вход, удерживает ресурсы и немедленно возвращается; blocking I/O, C API locks и OS waits исполняются только вне Message owner в выбранном native executor/process. completed(token,ok,value) публикуется после возврата native call и освобождения его holds, не синхронным callback в submit. releaseIdle допустим лишь после последнего completion. c.* и физические synchronization primitives остаются L2. Успешная admission не является successful job result.",
        lmx_detail_en="native.submit(token,value,selfAddress):int is a narrow L2/host boundary: one admits and zero rejects without launching. It copies input, retains resources and returns immediately. Blocking I/O, C API locks and OS waits run outside the Message owner in the selected native executor/process. completed is posted after the native call returns and its holds are released, never as a reentrant submit callback. releaseIdle runs only after the last completion. c.* and physical synchronization remain L2. Admission is not job success.",
        comparison_ru="Go запускает ровно одну goroutine с действительным supplied blocking function и bounded completion channel; Erlang запускает отдельный процесс, а native Call обязан быть port либо корректно dirty-scheduled NIF. Сам spawn не делает произвольный блокирующий NIF безопасным. LMX-автомат не маскирует отсутствие физического adapter.",
        comparison_en="Go starts one goroutine with the supplied blocking function and a bounded completion channel. Erlang starts a process, but native Call must use a port or correctly dirty-scheduled NIF; spawn alone does not make an arbitrary blocking NIF safe. The LMX state machine does not hide its missing physical adapter.",
        limits_ru="Один job и один owner. Hard worker crash требует отдельного failure completion либо явного unknown outcome от host; force-kill native thread и подтверждённая отмена не обещаны. В данном fixture call в итоге возвращает либо выдаёт перехваченный failure. Числовой value при ok=0 не считается успешным результатом.",
        limits_en="One job and owner. Hard worker crash requires a separate failure completion or explicit unknown outcome; force-killing a native thread and confirmed cancellation are not promised. This fixture's call eventually returns or raises a captured failure. A value with ok=false is inactive.",
        go_notes="Complete owner loop and goroutine wrapper; call is the real supplied blocking function, releaseIdle is the resource finalizer, emit is a nonblocking observer. A panic becomes a failed completion. The buffered done channel has one slot for the single admitted job. Compiler/runtime NOT_RUN.",
        erlang_notes="Complete ordinary process loop and worker invocation; Call must be an external port-backed operation or an appropriately scheduled dirty NIF. Normal exceptions become failure. An uncatchable process/VM termination is outside the bounded fixture and requires host failure signaling.",
        sources=[
            ("Erlang native functions: dirty schedulers", "https://www.erlang.org/doc/apps/erts/erl_nif.html", "Длительная native работа требует соответствующей physical execution boundary.", "Long native work requires the appropriate physical execution boundary."),
            ("Erlang ports", "https://www.erlang.org/doc/system/c_port.html", "Внешний процесс и framed native completion.", "External processes and framed native completion."),
            ("Go pipelines and cancellation", "https://go.dev/blog/pipelines", "Завершение уже принятой работы и жизненный цикл producer/consumer.", "Completion of admitted work and producer/consumer lifetime."),
        ],
    ),
]



NOTES_RU = {
 109: {"Go": "Полный channel loop. Compute ставит DoubleReply в отдельный service; Schedule публикует позднее событие Kind=2. Оба supplied ports возвращаются сразу. Finished/Rejected/Status — nonblocking observer. Host wiring и физический таймер перечислены отдельно.", "Erlang": "Функции одного обычного модуля; module/export и launcher вне фрагмента. Service и client — разные процессы; send_after — настоящий timer. Fixture задаёт порядок событий; timeout не доказывает отсутствие эффекта сервиса."},
 110: {"Go": "Полный channel/select loop: Kind 0 work, 1 become, 2 reply, 3 query, 4 stop. emit — nonblocking observer. Host сохраняет input до завершения stop; wake объединяет только scheduling hints, не work items.", "Erlang": "Обычный process loop с полной bounded queue. Только work помещается в stash. После stop query/reply остаются доступными до отдельного terminate от harness; module/export и launcher вне листинга."},
 111: {"Go": "Полные parent/child handlers. Ports асинхронно маршрутизируют Drain, Flush, Drained и actual stopped. CloseChildren/CloseOwner инициируют lifecycle без join в handler. Host задаёт generation и два child IDs.", "Erlang": "Parent и children — отдельные процессы. Parent использует настоящие monitors и сверяет monitor reference вместе с PID. Flush — явно поставленный async native adapter; Release вызывается после completion. Child не вызывает блокирующий stop своего supervisor."},
 112: {"Go": "Полный owner loop и goroutine wrapper. call — действительная supplied blocking function, releaseIdle освобождает ресурс, emit не блокирует. Panic даёт failed completion. У done channel один slot для единственного принятого job. Компиляция и исполнение NOT_RUN.", "Erlang": "Полный process loop и worker invocation. Call обязан использовать внешний port или корректно dirty-scheduled NIF. Обычные exceptions превращаются в failure; неконтролируемая гибель процесса/VM требует отдельного host failure signal."},
}


def metrics(code):
    return dict(characters=sum(not c.isspace() for c in code),
                nonblank_lines=sum(bool(line.strip()) for line in code.splitlines()),
                utf8_bytes=len(code.encode()), sha256=hashlib.sha256(code.encode()).hexdigest())


group = json.loads((GROUP / "patterns.json").read_text())
old = {item["id"]: item for item in group["patterns"]}
for authored in DATA:
    record = {key: value for key, value in authored.items()
              if key not in {"lmx_detail_ru", "lmx_detail_en", "go_notes", "erlang_notes", "sources"}}
    record.update(scope="protocol", kind="pattern")
    record["lmx_notes_ru"] = COMMON_RU + " " + authored["lmx_detail_ru"]
    record["lmx_notes_en"] = COMMON_EN + " " + authored["lmx_detail_en"]
    record["listings"] = []
    for language, directory, suffix in (("LMX", "lmx", "lm3"), ("Go", "go", "go"), ("Erlang", "erlang", "erl")):
        code = (GROUP / "examples" / directory / f"{record['id']:03d}_{record['slug']}.{suffix}").read_text().strip() + "\n"
        note = record["lmx_notes_en"] if language == "LMX" else authored["go_notes" if language == "Go" else "erlang_notes"]
        record["listings"].append(dict(language=language, code=code,
            notes_ru=record["lmx_notes_ru"] if language == "LMX" else NOTES_RU[record["id"]][language],
            notes_en=note, metrics=metrics(code)))
    record["sources"] = [dict(title=title, url=url, why_ru=ru, why_en=en)
                         for title, url, ru, en in authored["sources"]]
    record["post_scope_note_ru"] = (
        "Ошибки маршрута, deadline, stale generation и blanket stash относятся к прикладному протоколу. "
        "Они не означают deadlock механизма Message. Все handlers завершают текущий turn; "
        "результаты приходят штатными сообщениями, без LMX synchronized или ожидания потока."
    )
    record["post_scope_note_en"] = (
        "Routing, deadline, stale-generation and blanket-stash mistakes are application protocol errors, "
        "not Message scheduling deadlocks. Handlers finish their turns and receive ordinary later messages; "
        "no LMX synchronized or thread wait is introduced."
    )
    old[record["id"]] = record
group["patterns"] = [old[key] for key in sorted(old)]
group["overview_ru"] = "15 сравнений: базовые исполнители/Message, structured concurrency, supervision, MapReduce и четыре явных прикладных протокола 109–112. Message сохраняет штатное исполнение; физические блокирующие native операции остаются на L2 boundary."
group["overview_en"] = "15 comparisons cover basic workers/Message, structured concurrency, supervision, MapReduce and four explicit application protocols 109–112. Message keeps ordinary execution; physically blocking native operations remain at the L2 boundary."
(GROUP / "patterns.json").write_text(json.dumps(group, ensure_ascii=False, indent=2) + "\n")
manifest_path = ROOT / "comparison_sources/catalog_manifest.json"
manifest = json.loads(manifest_path.read_text())
new_ids = [item["id"] for item in DATA]
manifest["pattern_ids"] = sorted(set(manifest["pattern_ids"]) | set(new_ids))
manifest["comparisons"] = [item for item in manifest["comparisons"] if item["id"] not in new_ids]
manifest["comparisons"] += [dict(id=item["id"], directory=GROUP.name, kind="pattern",
                                paired_with=None, implementation_ids=[], usage_ids=[],
                                languages=["Go", "Erlang"]) for item in DATA]
manifest["comparisons"].sort(key=lambda item: item["id"])
manifest_path.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n")
print(json.dumps({"group": GROUP.name, "added_ids": new_ids, "source_listings": 12}))
