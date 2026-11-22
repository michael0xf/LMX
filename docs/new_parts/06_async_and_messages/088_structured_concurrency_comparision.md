# 088. Structured Concurrency

Родитель ограничивает время жизни двух дочерних задач своим scope и дожидается обеих даже при ошибке.

## Общий сценарий

Дочерние задачи возвращают 2 и 3: итог 5. Если первая отказывает, вторая получает stop request; scope завершается только после обоих stopped notifications.

**Ожидаемое наблюдение:** Успех даёт 5. При ошибке ошибка возвращается после завершения обеих задач; живого ребёнка за границей scope нет.

**Граница сравнения:** Протокол и порты. Parent-child hierarchy сама по себе не вычисляет join результата. Зависшая некооперативная Go задача задержит scope; LMX применяет свой close/watchdog профиль; Erlang shutdown может не выполнить пользовательский finally. В этом ограниченном fixture scope вызывается один раз в отдельном новом collector process с пустым mailbox; в него поступают только результаты и DOWN двух созданных monitored children. Для использования в общем mailbox необходимы scope correlation и фильтрация своих monitor references; показанный gather такой общей маршрутизацией не является.

Все три листинга относятся к указанному сценарию. Предоставленные порты и библиотеки перечислены рядом с кодом; их реализации не входят в размер листинга.

## LMX

```lmx
ScopeMessage:
    int: childId
    int: ok
    int: value
    int: seen0 0
    int: seen1 0
    int: remaining 2
    int: failed 0
    int: total 0
    @: lifecycle
    @: result
    stopped:
        if: childId = 0
            if: node\seen0 = 1
                return
            node\seen0 := 1
        if: childId = 1
            if: node\seen1 = 1
                return
            node\seen1 := 1
        if: ok = 0
            node\failed := 1
            lifecycle\requestStopChildren()
        if: ok = 1
            node\total += value
        node\remaining -= 1
        if: node\remaining = 0
            result\finish(1 - node\failed; node\total)
```

LMX использует отдельные исполняемые Message с собственной ареной и последовательными turns. Шаблоны явно запускаются хостом; адресованные вызовы проходят общий post, а удалённый профиль — описанный HTTP transport. Полный контракт обвязки находится в MESSAGE_HTTP_PROFILE.md. Приведён авторский protocol/core пример, не проверенный парсером runtime fixture. Хост запускает ровно двух прямых детей ScopeMessage; stopped(childId:0|1,ok:0|1,value:int) приходит только после cleanup и безопасной остановки ребёнка. lifecycle.requestStopChildren():void посылает stop через штатный Thread.children без второго реестра. result.finish(ok:int,total:int):void закрывает scope после barrier; при ok=0 total не является успешным результатом.

[Отдельный листинг](examples/lmx/088_structured_concurrency.lm3)

## Go

```go
import ("context"; "sync")
type Outcome struct { value int; err error }
func Scope(a, b func(context.Context) (int, error)) (int, error) {
    ctx, cancel := context.WithCancel(context.Background()); defer cancel()
    out := make(chan Outcome, 2)
    var wg sync.WaitGroup
    for _, fn := range []func(context.Context)(int,error){a,b} {
        wg.Add(1)
        go func(f func(context.Context)(int,error)) {
            defer wg.Done(); v,e := f(ctx); out <- Outcome{v,e}
        }(fn)
    }
    total := 0; var first error
    for i:=0; i<2; i++ {
        r := <-out
        if r.err != nil && first == nil { first = r.err; cancel() }
        total += r.value
    }
    wg.Wait(); return total, first
}
```

Фрагмент Go; import перечислен там, где нужен; package/harness вынесен. Хост запускает ровно двух прямых детей ScopeMessage; stopped(childId:0|1,ok:0|1,value:int) приходит только после cleanup и безопасной остановки ребёнка. lifecycle.requestStopChildren():void посылает stop через штатный Thread.children без второго реестра. result.finish(ok:int,total:int):void закрывает scope после barrier; при ok=0 total не является успешным результатом.

[Отдельный листинг](examples/go/088_structured_concurrency.go)

## Erlang

```erlang
scope(A, B) ->
    Parent = self(),
    Children = [spawn_monitor(fun() -> Parent ! {result,self(),F()} end) || F <- [A,B]],
    gather(Children, 0, none).
gather([], Total, none) -> {ok,Total};
gather([], _, Error) -> {error,Error};
gather(Children, Total, Error) ->
    receive
        {result,_,{ok,V}} -> gather(Children, Total+V, Error);
        {result,_,{error,E}} ->
            [exit(P,shutdown) || {P,_} <- Children], gather(Children, Total, E);
        {'DOWN',Ref,process,_,normal} ->
            gather(lists:keydelete(Ref,2,Children), Total, Error);
        {'DOWN',Ref,process,_,Reason} ->
            Rest = lists:keydelete(Ref,2,Children),
            [exit(P,shutdown) || {P,_} <- Rest],
            gather(Rest, Total, case Error of none -> Reason; _ -> Error end)
    end.
```

Функции Erlang для одного модуля; -module/-export и запускающий тест вынесены. Хост запускает ровно двух прямых детей ScopeMessage; stopped(childId:0|1,ok:0|1,value:int) приходит только после cleanup и безопасной остановки ребёнка. lifecycle.requestStopChildren():void посылает stop через штатный Thread.children без второго реестра. result.finish(ok:int,total:int):void закрывает scope после barrier; при ok=0 total не является успешным результатом. В этом ограниченном fixture scope вызывается один раз в отдельном новом collector process с пустым mailbox; в него поступают только результаты и DOWN двух созданных monitored children. Для использования в общем mailbox необходимы scope correlation и фильтрация своих monitor references; показанный gather такой общей маршрутизацией не является.

[Отдельный листинг](examples/erlang/088_structured_concurrency.erl)

## Разбор LMX

LMX использует отдельные исполняемые Message с собственной ареной и последовательными turns. Шаблоны явно запускаются хостом; адресованные вызовы проходят общий post, а удалённый профиль — описанный HTTP transport. Полный контракт обвязки находится в MESSAGE_HTTP_PROFILE.md. Приведён авторский protocol/core пример, не проверенный парсером runtime fixture. Хост запускает ровно двух прямых детей ScopeMessage; stopped(childId:0|1,ok:0|1,value:int) приходит только после cleanup и безопасной остановки ребёнка. lifecycle.requestStopChildren():void посылает stop через штатный Thread.children без второго реестра. result.finish(ok:int,total:int):void закрывает scope после barrier; при ok=0 total не является успешным результатом.

## Сопоставление

LMX использует уже описанную иерархию Message и добавляет явный result barrier. Go показывает cooperative cancellation, Erlang — monitor и принудительный shutdown; эти способы отмены не тождественны.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 364 | 28 |
| Go | 517 | 20 |
| Erlang | 602 | 18 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

A parent bounds two child tasks to its scope and waits for both even after a failure.

**Scenario.** Children return 2 and 3: result 5. If one fails, the other receives a stop request; scope finishes only after both stopped notifications.

**Expected observation.** Success yields 5. A failure is returned only after both tasks finish; no live child outlives the scope.

**LMX.** LMX uses separate executable Messages with their own arenas and serial turns. Templates are explicitly launched by the host; addressed calls use post and remote delivery uses the documented HTTP transport. MESSAGE_HTTP_PROFILE.md defines shared integration. This is an original protocol/core example, not a parser-validated runtime fixture. The host launches exactly two direct children of ScopeMessage; stopped(childId:0|1,ok:0|1,value:int) arrives only after cleanup and safe child termination. lifecycle.requestStopChildren():void sends stop through ordinary Thread.children without a second registry. result.finish(ok:int,total:int):void closes the scope after the barrier; total is not a successful result when ok=0.

**Comparison.** LMX uses its existing Message hierarchy and adds an explicit result barrier. Go shows cooperative cancellation; Erlang uses monitors and shutdown signals. These cancellation mechanisms are not identical.

**Scope and limitations.** Parent-child hierarchy does not automatically join results. A noncooperative Go task delays the scope; LMX uses its close/watchdog profile; Erlang shutdown may skip application cleanup. In this bounded fixture, scope runs once in a dedicated new collector process with an empty mailbox; only results and DOWN notifications from its two monitored children reach it. Use in a shared mailbox requires scope correlation and filtering of owned monitor references; the shown gather is not a general mailbox router.

### Dependencies and execution boundaries

- **LMX:** LMX uses separate executable Messages with their own arenas and serial turns. Templates are explicitly launched by the host; addressed calls use post and remote delivery uses the documented HTTP transport. MESSAGE_HTTP_PROFILE.md defines shared integration. This is an original protocol/core example, not a parser-validated runtime fixture. The host launches exactly two direct children of ScopeMessage; stopped(childId:0|1,ok:0|1,value:int) arrives only after cleanup and safe child termination. lifecycle.requestStopChildren():void sends stop through ordinary Thread.children without a second registry. result.finish(ok:int,total:int):void closes the scope after the barrier; total is not a successful result when ok=0.
- **Go:** Go fragment; imports are included where needed; package/harness is separate. The host launches exactly two direct children of ScopeMessage; stopped(childId:0|1,ok:0|1,value:int) arrives only after cleanup and safe child termination. lifecycle.requestStopChildren():void sends stop through ordinary Thread.children without a second registry. result.finish(ok:int,total:int):void closes the scope after the barrier; total is not a successful result when ok=0.
- **Erlang:** Erlang functions for one module; -module/-export and the test harness are separate. The host launches exactly two direct children of ScopeMessage; stopped(childId:0|1,ok:0|1,value:int) arrives only after cleanup and safe child termination. lifecycle.requestStopChildren():void sends stop through ordinary Thread.children without a second registry. result.finish(ok:int,total:int):void closes the scope after the barrier; total is not a successful result when ok=0. In this bounded fixture, scope runs once in a dedicated new collector process with an empty mailbox; only results and DOWN notifications from its two monitored children reach it. Use in a shared mailbox requires scope correlation and filtering of owned monitor references; the shown gather is not a general mailbox router.

## Источники / Sources

- [Go — Pipelines and cancellation](https://go.dev/blog/pipelines) — Родитель ограничивает время жизни двух дочерних задач своим scope и дожидается обеих даже при ошибке.
- [Erlang — Supervision principles](https://www.erlang.org/doc/system/sup_princ.html) — Родитель ограничивает время жизни двух дочерних задач своим scope и дожидается обеих даже при ошибке.

**Норма LMX:** [CORE](../../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md), [уточнение 21 ноября](../../tasks/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
