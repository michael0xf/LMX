# 089. Supervision Tree

Родитель наблюдает за прямым ребёнком и ограниченно перезапускает его после отказа.

## Общий сценарий

Первый запуск ребёнка отказывает, второй успешен. Разрешён один restart; повторный отказ останавливает восстановление.

**Ожидаемое наблюдение:** Созданы две разные child identities; успешный ребёнок не перезапускается.

**Граница сравнения:** Протокол и порты. Политики бюджета различаются: LMX/Go — один restart за жизнь примера, OTP — один за 60 секунд. Сценарий исполняется внутри этого окна. Recovery внешних эффектов и повтор jobs отдельно.

## LMX

```lmx
SupervisorMessage:
    int: failed
    int: restarts 0
    @: template
    @: lifecycle
    @: child
    stopped:
        if: failed = 0
            return
        if: node\restarts >= 1
            lifecycle\reportExhausted()
            return
        node\restarts += 1
        node\child := lifecycle\startChild(template)
```

LMX использует отдельные исполняемые Message с собственной ареной и последовательными turns. Шаблоны явно запускаются хостом; адресованные вызовы проходят общий post, а удалённый профиль — описанный HTTP transport. Полный контракт обвязки находится в MESSAGE_HTTP_PROFILE.md. Приведён авторский protocol/core пример, не проверенный парсером runtime fixture. lifecycle.startChild(template):MessageAddress явно создаёт нового прямого ребёнка с копией шаблона/своей ареной; reportExhausted():void сообщает отказ родителю. Lifecycle-провайдер передаёт stopped однократно, только для текущего child и после его полной остановки; события прежних поколений не поступают в этот handler. child — прикладная ссылка, не альтернативный membership registry. Erlang фрагмент — callbacks модуля -behaviour(supervisor), WorkerModule поставляет start_link/0.

[Отдельный листинг](examples/lmx/089_supervision_tree.lm3)

## Go

```go
func Supervise(run func() error) error {
    for attempt:=0; attempt<2; attempt++ {
        done := make(chan error, 1)
        go func() { done <- run() }()
        err := <-done
        if err == nil { return nil }
        if attempt == 1 { return err }
    }
    return nil
}
```

Фрагмент Go; import перечислен там, где нужен; package/harness вынесен. lifecycle.startChild(template):MessageAddress явно создаёт нового прямого ребёнка с копией шаблона/своей ареной; reportExhausted():void сообщает отказ родителю. Lifecycle-провайдер передаёт stopped однократно, только для текущего child и после его полной остановки; события прежних поколений не поступают в этот handler. child — прикладная ссылка, не альтернативный membership registry. Erlang фрагмент — callbacks модуля -behaviour(supervisor), WorkerModule поставляет start_link/0.

[Отдельный листинг](examples/go/089_supervision_tree.go)

## Erlang

```erlang
start_link(WorkerModule) -> supervisor:start_link(?MODULE, WorkerModule).
init(WorkerModule) ->
    Flags = #{strategy => one_for_one, intensity => 1, period => 60},
    Child = #{id => worker, start => {WorkerModule,start_link,[]},
              restart => transient, shutdown => 5000, type => worker},
    {ok,{Flags,[Child]}}.
```

Функции Erlang для одного модуля; -module/-export и запускающий тест вынесены. lifecycle.startChild(template):MessageAddress явно создаёт нового прямого ребёнка с копией шаблона/своей ареной; reportExhausted():void сообщает отказ родителю. Lifecycle-провайдер передаёт stopped однократно, только для текущего child и после его полной остановки; события прежних поколений не поступают в этот handler. child — прикладная ссылка, не альтернативный membership registry. Erlang фрагмент — callbacks модуля -behaviour(supervisor), WorkerModule поставляет start_link/0.

[Отдельный листинг](examples/erlang/089_supervision_tree.erl)

## Разбор LMX

LMX использует отдельные исполняемые Message с собственной ареной и последовательными turns. Шаблоны явно запускаются хостом; адресованные вызовы проходят общий post, а удалённый профиль — описанный HTTP transport. Полный контракт обвязки находится в MESSAGE_HTTP_PROFILE.md. Приведён авторский protocol/core пример, не проверенный парсером runtime fixture. lifecycle.startChild(template):MessageAddress явно создаёт нового прямого ребёнка с копией шаблона/своей ареной; reportExhausted():void сообщает отказ родителю. Lifecycle-провайдер передаёт stopped однократно, только для текущего child и после его полной остановки; события прежних поколений не поступают в этот handler. child — прикладная ссылка, не альтернативный membership registry. Erlang фрагмент — callbacks модуля -behaviour(supervisor), WorkerModule поставляет start_link/0.

## Сопоставление

LMX использует штатное отношение прямого родительства; restart strategy остаётся приложением. Erlang OTP поставляет зрелый supervisor; Go пример реализует короткий ограниченный контроллер.

### Асинхронная граница

Прикладной протокол выполняется обычными turns Message. post уже обеспечивает адресованный вызов, корреляцию и доставку обработчиков; второй scheduler не требуется. post не реализует очередь, транзакцию, barrier отмены или внешний I/O provider этого протокола: явно объявленные порты сохраняют свои договоры.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 204 | 14 |
| Go | 181 | 10 |
| Erlang | 269 | 6 |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

Автор считает явные конечные списки отказов и общий Throws/copy(Throws) преимуществом LMX: видно, какой метод какие исходы порождает. Основные размеры и отношения сохраняют весь текст. Все объявления, аргументы и ссылки на общий банк ошибок учитываются целиком.

## English explanation

A parent monitors its direct child and restarts it after failure under a bounded policy.

**Scenario.** The first child launch fails and the second succeeds. Allow one restart; a second failure stops recovery.

**Expected observation.** Two distinct child identities are created; a successful child is not restarted.

**LMX.** LMX uses separate executable Messages with their own arenas and serial turns. Templates are explicitly launched by the host; addressed calls use post and remote delivery uses the documented HTTP transport. MESSAGE_HTTP_PROFILE.md defines shared integration. This is an original protocol/core example, not a parser-validated runtime fixture. lifecycle.startChild(template):MessageAddress explicitly creates a new direct child with copied template and its own arena; reportExhausted():void reports exhaustion to the parent. The lifecycle provider delivers stopped exactly once for the current child and only after full termination; stale notifications from prior generations do not enter this handler. child is an application reference, not an alternative membership registry. The Erlang fragment supplies callbacks for a -behaviour(supervisor) module; WorkerModule provides start_link/0.

**Comparison.** LMX uses ordinary direct parenthood; restart strategy remains application policy. Erlang OTP supplies a supervisor; the Go example implements a small bounded controller.

**Scope and limitations.** Budgets differ: LMX/Go permit one restart over this example lifetime, OTP one per 60 seconds. The scenario runs within that window. External-effect recovery and job redelivery are separate.

The shown application protocol runs on existing Message turns. post already supplies addressed invocation, reply correlation and handler delivery; it needs no second scheduler here. It does not supply this protocol’s queue, transaction, cancellation barrier or external I/O provider. Those explicitly declared ports retain their stated contracts; this listing is not a hidden implementation of an entire networking/storage library.

### Dependencies and execution boundaries

- **LMX:** LMX uses separate executable Messages with their own arenas and serial turns. Templates are explicitly launched by the host; addressed calls use post and remote delivery uses the documented HTTP transport. MESSAGE_HTTP_PROFILE.md defines shared integration. This is an original protocol/core example, not a parser-validated runtime fixture. lifecycle.startChild(template):MessageAddress explicitly creates a new direct child with copied template and its own arena; reportExhausted():void reports exhaustion to the parent. The lifecycle provider delivers stopped exactly once for the current child and only after full termination; stale notifications from prior generations do not enter this handler. child is an application reference, not an alternative membership registry. The Erlang fragment supplies callbacks for a -behaviour(supervisor) module; WorkerModule provides start_link/0.
- **Go:** Go fragment; imports are included where needed; package/harness is separate. lifecycle.startChild(template):MessageAddress explicitly creates a new direct child with copied template and its own arena; reportExhausted():void reports exhaustion to the parent. The lifecycle provider delivers stopped exactly once for the current child and only after full termination; stale notifications from prior generations do not enter this handler. child is an application reference, not an alternative membership registry. The Erlang fragment supplies callbacks for a -behaviour(supervisor) module; WorkerModule provides start_link/0.
- **Erlang:** Erlang functions for one module; -module/-export and the test harness are separate. lifecycle.startChild(template):MessageAddress explicitly creates a new direct child with copied template and its own arena; reportExhausted():void reports exhaustion to the parent. The lifecycle provider delivers stopped exactly once for the current child and only after full termination; stale notifications from prior generations do not enter this handler. child is an application reference, not an alternative membership registry. The Erlang fragment supplies callbacks for a -behaviour(supervisor) module; WorkerModule provides start_link/0.

## Источники / Sources

- [Erlang — Supervisor Behaviour](https://www.erlang.org/doc/system/sup_princ.html) — Родитель наблюдает за прямым ребёнком и ограниченно перезапускает его после отказа.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
