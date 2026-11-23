# Объявленные выходы и обработчики функциональных примеров

Здесь разобраны текущие основные листинги 083, 084 и 098. Это пояснение к их коду, а не другая редакция библиотеки. В сравнении измеряется опубликованный вызываемый компонент; внешняя программа, которая его вызывает и выбирает политику обработки отказов, не включается в размер клиента ни для одного из трёх языков. Внутренние обработчики, необходимые самому сравниваемому алгоритму, входят в основной листинг и его размер.

По [норме LMX](../../LMX_semantics.en.md#exceptions), вызывающий код должен поймать каждый явно объявленный выход либо перечислить его в собственном `throws`. Поэтому наличие `throws` не требует `catch` в том же методе: оно как раз описывает выходы, которые метод передаёт своему вызывающему. До реальной точки входа с необработанными объявленными выходами цепочка дойти не может: вызывающая сторона должна выполнить это обязательство. Отдельное правило необязательного перехвата неявных отказов встроенных операций не превращает написанный в исходнике `throws` в необязательный список.

`throws` и `catch` решают разные задачи. Первый описывает объявленные имена выходов; второй содержит исполняемую реакцию. Вынести повторяющийся список в одну структуру допустимо, но это не создаёт обработчик автоматически и не скрывает его стоимость.

<a id="trampoline"></a>
## 083: один список выходов и разыменование результата

В [основном клиенте 083](examples/lmx/083_trampoline.lm3) восемь имён записаны один раз в `Steps\Throws`. Общий `code`, `even_step`, `odd_step` и вложенный `Example\run` используют `throws: copy(Throws)`. Алгоритм шага записан один раз в `code`; локальные `x` и `next` задаются каждым шагом и доступны общему коду по динамическому связыванию. Объявление и все четыре обращения входят в подсчёт. Вход — `Steps\Example\run(n)`.

Это использование обычного потока, который производит `copy`; оно не вводит новое снятие единственной анонимной структуры и не переносит раскрытие аргументов в P0. О правилах построения и передачи структур см. [семантику LMX](../../LMX_semantics.en.md).

Запись `return: \trampoline(even_step(n))` содержит обычный вызов `trampoline`, а затем префиксное разыменование его результата. Имени или отдельной операции `\trampoline` здесь нет. Более подробная равнозначная запись:

```lmx
@: result trampoline(even_step(n))
return: \result
```

`even_step` возвращает Bounce. Драйвер `trampoline` получает конечную ссылку из `Bounce\value`: это запись, которую `done` ранее получил через `(1 record)` или `(0 record)`. Префикс `\` читает из неё само целое число для `return: int`. Вызов связывается раньше префикса, как прямо указано для формы `\b(args)` в [разделе о ссылках](../../LMX_semantics.en.md) и в [грамматике](../../LMX_grammar.en.md). `trampoline` — обычный добавленный ресивер; его реализация называется `FxTrampoline\trampoline`. Это не новая синтаксическая конструкция языка. Реальное тело драйвера находится в [containers.lmx](../LMX_Fn_Receivers/src/containers.lmx) и [сравнении 092](092_trampoline_container_and_runner_implementation_comparision.md).

### Где вызывающая сторона ловит отказ

`Example\run` в первичном сравнении — вызываемый клиент, а не корень Message. Haskell `parity` и Scala `parity` в том же сравнении также являются вызываемыми функциями. Следующий дополнительный клиент показывает конкретный `catch` для конверта общего вызова:

<!-- source: examples/lmx/083_trampoline_failure_boundary.lm3 -->

```lmx
# Complete application example: parity plus a partial failure boundary.
# Official core operations are provided by the current core.
# This is not a complete Message entry; other exits propagate.

Steps:
    int: n
    return: @
    Throws:
        FxIndex
        FxArity
        FxRecordArity
        FxTypeToken
        FxKernelFailure
        FxCallFailure
        ReceiverIndex
        SequenceSize
    code:
        throws: copy(Throws)
        if: n = 0
            return: done(value := (x record))
        return: more(thunk := partial(next; (n - 1)))
    even_step:
        throws: copy(Throws)
        int: x 1
        @: next odd_step
        return: code()
    odd_step:
        throws: copy(Throws)
        int: x 0
        @: next even_step
        return: code()
    Example:
        int: n
        return: int
        run:
            throws: copy(Throws)
            return: \trampoline(even_step(n))

ParityResult:
    int: n
    return: @
    run:
        throws:
            FxIndex
            FxArity
            FxRecordArity
            FxTypeToken
            FxKernelFailure
            ReceiverIndex
            SequenceSize
        return: ok(value := (Steps\Example\run(n) record))
        catch: FxCallFailure (@: outcome)
            return: err(reason := outcome)
```

[Исходник дополнительного клиента](examples/lmx/083_trampoline_failure_boundary.lm3) сохраняет успешное число в `ok` и полный конверт отказа в `err`. В нём не подменяется отказ ответом о чётности. Имена и payload исходного отказа остаются в `outcome`; их форма соответствует [FxApply](../LMX_Fn_Receivers/src/generic_runtime.lmx) и [контракту attempt](../LMX_Fn_Receivers/src/kernel_contracts.lmx). `ok` и `err` — обычные конструкторы из [containers.lmx](../LMX_Fn_Receivers/src/containers.lmx).

Этот дополнительный клиент намеренно обрабатывает только `FxCallFailure`; остальные семь выходов явно передаются дальше. Он не объявлен завершённым корневым обработчиком. Их окончательная политика принадлежит вызывающему приложению: здесь нет придуманного payload для служебных отказов и нет автоматического превращения любого сбоя в успех. Дополнительный клиент, как и двухстрочное разъяснение выше, не прибавляется к первичному листингу 083.

<a id="execute-around"></a>
## 084: прямой локальный Around и общий bracket

**В прежнем листинге уже были и `throw`, и `catch` для `ResourceFailure`.** Пометка «исторический» относилась к сохранённой публикации, а не означала, что язык перестал принимать её обычные вызовы и `finally`. Дополнительные служебные имена и `FxCallFailure` появились при переводе этого прикладного клиента на общий record-API; сам паттерн Execute Around их не требует.

В прежней публикации 084 было пропущено определение `Around`, хотя клиент вызывал `Around\use`. Теперь сохранённый процедурный вариант в [сравнении 084](084_execute_around_comparision.md) и в закомментированной части его исходника показан целиком: перед неизменённым клиентом добавлено точное тело `Around` из сохранённого варианта [098](098_execute_around_implementation_comparision.md). Его полный размер — **719 непробельных символов / 50 непустых строк**: 563 символа клиента и 156 символов определения. Исходные строки клиента остаются без изменений в `alternative.LMX.code` и `procedural_lmx`; добавленное определение хранится отдельно в `alternative.LMX.context_prefix`.

Текущий основной [клиент 084](examples/lmx/084_execute_around.lm3) содержит локальный `Around` целиком. Внутри него по-прежнему передаются и вызываются три callbacks — acquire, release и action. После успешного acquisition регистрируется `finally`, затем вызывается action. Это полноценный Execute Around, а не подмена переданного действия заранее известной функцией.

Весь локальный helper вместе с клиентом занимает **709 непробельных символов**. Общие `Trace\code` и `Trace\eval` исключают повторение записи события и проверки отказа; все определения остаются в одном листинге. Предыдущий текущий вариант `local_callbacks` (719 символов) сохранён рядом. Действующая альтернатива общего `bracket` занимает **802**; она сохранена целиком в том же [сравнении 084](084_execute_around_comparision.md) и в [отдельном исходнике](examples/lmx/variants/084_execute_around_core.lm3). Выбор локального helper не подключает старую редакцию ядра и не отменяет общий `bracket`. Реализация 098 сохраняет широкий контракт: произвольный результат, typed-record transport и дополнительные аргументы action. Прикладной сценарий 084 требует конкретный `int`-результат, поэтому эти дополнительные возможности не являются условием допустимости каждого его варианта.

### Где throw и catch в основных клиентах

Обработка прикладного отказа является частью сценария, поэтому она написана и учтена во всех трёх основных клиентах:

| Действие | LMX — локальный Around целиком | Haskell | Scala |
| --- | --- | --- | --- |
| Создать прикладной отказ | `throw: ResourceFailure()` | `failure = ioError (userError "ResourceFailure")`, затем `failure` в ветке | `throw new ResourceFailure` |
| Обозначить возможный выход в объявлении | `throws: ResourceFailure` у acquire, action и локального helper | В приведённом `run :: Int -> IO Int` нет списка имён исключений | В приведённом `def run(mode: Int): Int` нет списка имён исключений |
| Перехватить отказ | `catch: ResourceFailure ()` у `Example\run` | `try (bracket acquire release action)` с результатом `IO (Either IOException Int)` | `try { ... } catch { case _: ResourceFailure => -events }` |
| Выбрать ответ после перехвата | `return: -Trace\events` | `either (const (-logValue)) (...) result` | Возвратить `-events` из соответствующей ветки `catch` |

Ссылки на текущие контрольные исходники: [Haskell 084](examples/haskell/084_execute_around.hs), [Scala 084](examples/scala/084_execute_around.scala), [LMX 084](examples/lmx/084_execute_around.lm3). Таблица описывает именно эти основные файлы. Отсутствие слова `throws` в Haskell и Scala не означает отсутствие отказа или обработки: в их клиентах явно видны `ioError` с `try` и `throw` с `catch` соответственно.

У Haskell результат `try` разветвляется через `Either`: при отказе клиент возвращает отрицательный журнал, а при успехе использует значение и журнал. Наличие `IO` в подписи само по себе не перечисляет имена возможных отказов. В Scala тип прикладного исключения назван непосредственно в ветке `catch`.

В основном LMX выход `ResourceFailure` передаётся напрямую от callback через локальный `Around` к `Trace\Example\run`, который его ловит. Здесь нет конверта общего record-API, поэтому не нужна и его распаковка. Локальный helper — часть приложения, возвращающая нужный приложению `int`; все его строки включены в 709 символов. Он не заявляется равнообщей заменой встроенного `bracket`.

### Что остаётся в действующей общей альтернативе

Общий `bracket` передаёт отказ продолжения через конверт `FxCallFailure`; исходные имя и payload сохранены внутри. Его клиент ловит этот конверт, проверяет, что имя равно `ResourceFailure`, и затем возвращает отрицательный журнал. Это особенность выбранного общего API, сохранённая в альтернативе, а не новое правило для всех обычных вызовов LMX.

Из исходящего `throws` этого альтернативного `Example\run` удалён пойманный `FxCallFailure`: обработчик покрывает вызов и не выбрасывает это имя повторно. Удалены также `FxIndex`, `FxArity` и `FxRecordArity`, которых нет в объявленном контракте единственного непосредственно используемого общего `bracket`. Остаются его `FxKernelFailure`, `FxTypeToken`, `ReceiverIndex` и `SequenceSize`. В основной прямой вариант этот список не перенесён.

Диагностический `sys\assert` в обработчике общего варианта не превращён в восстанавливаемый `throw`; его режим определён [нормой диагностики](../../LMX_semantics.en.md#exceptions).

В обоих действующих LMX-вариантах ожидаемые наблюдения сохранены: успех даёт **42123** — значение ресурса 42 и журнал `123`; отказ action даёт **−123**; отказ acquire даёт **−1**, потому что ресурс ещё не получен и release вызывать не для чего. Оба сохраняют поля ресурса, три переданных callbacks и журнал; ни одна ветвь не заменена константным успешным ответом ради уменьшения листинга.

<a id="cleanup"></a>
## 098: обработка ради освобождения и окончательный обработчик — разные места

[Реализация 098](098_execute_around_implementation_comparision.md) по-прежнему сравнивает общий компонент. Он освобождает уже полученный ресурс и сохраняет поведение выхода. В LMX этот компонент используется действующей общей альтернативой 084; основной клиент 084 содержит свой короткий локальный helper полностью. Контракт 098 не сужается до этой прикладной специализации.

- В [Haskell 098](examples/haskell/098_execute_around_implementation.hs) сначала выполняется `resource <- acquire`. Только вызов action обёрнут в ``action resource `catch` failed``. Обработчик `failed` вызывает release, затем `throwIO err`. При обычном завершении release вызывается после action. В этом коде перехват служит освобождению и повторной передаче отказа, а не окончательному ответу приложения.
- В [Scala 098](examples/scala/098_execute_around_implementation.scala) ресурс также получают до защищённого action; запись `try action(resource) finally release(resource)` выполняет освобождение при выходе из action. Отдельный локальный `catch` для этого не нужен; прикладной `catch` написан в клиенте 084.
- В [LMX 098](examples/lmx/098_execute_around_implementation.lm3) обработка освобождения регистрируется через `finally` только после успешного получения ресурса. Объявленные выходы общего компонента передаются клиенту; действующая общая альтернатива 084 перехватывает конверт прикладного отказа. Основной локальный Around использует тот же порядок регистрации `finally`, но вызывает переданные callbacks напрямую и передаёт `ResourceFailure` без конверта. Оба следуют [общим правилам finally](../../LMX_semantics.en.md#exits).

Сравнивается показанный синхронный сценарий. Ни один из этих вспомогательных листингов не заявляется полной заменой всех гарантий промышленных библиотек обработки ресурсов, асинхронных исключений или отмены.

## Проверка и граница подсчёта

Изменения касаются текста и исходников. В этой редакции не заявлено исполнение LMX, Haskell или Scala. `tools/check_publication.py` проверяет соответствие основных и сохранённых листингов данным, выбор короткого допустимого варианта и наличие этого пояснения; оно не доказывает работу ядра.

Для 083 общий список объявлений считается ровно один раз вместе с четырьмя явными обращениями. Для основного 084 учитываются весь локальный Around, прикладной код, прямой catch и журнал. Общая альтернатива отдельно учитывает свой клиент, конверт и проверку имени; её общий компонент остаётся в реализации 098. Общие требования 098 не являются дополнительными требованиями к int-сценарию 084. Дополнительный вызывающий клиент из этого файла показан отдельно от сравнения, а не скрыт за измеряемым вызовом. Стоимость реализаций общего ядра по-прежнему раскрывается в [реестре зависимостей](IMPLEMENTATION_DEPENDENCIES.md).

## English reading guide

The 083 primary is a callable parity client, just like the Haskell and Scala controls. Its finite exit list is declared once in `Steps\Throws`; the shared body and three callers use four explicit `copy(Throws)` operations. The common step receives x and next through dynamic binding; the entry is `Steps\Example\run`. Prefix `\` dereferences the completed `trampoline(...)` result record. It does not name a different receiver. `trampoline` is the ordinary added receiver implemented by `FxTrampoline\trampoline`, not a special syntax form.

The companion `ParityResult` catches `FxCallFailure` and preserves the outcome in the `err` case. Its other declared exits still propagate, so it is not presented as a complete Message entry. The caller must handle or declare those remaining names.

The saved procedural 084 presentation includes the exact original Around definition from 098 before its unchanged client: 719 characters / 50 nonblank lines, including 563 client characters and 156 definition characters. The raw historical client remains separately preserved. The earlier 084 source already declared, raised, and caught `ResourceFailure`. The current primary shares the Trace code and eval methods, retains the direct failure path, and includes the entire callback-supplied local Around helper in its 709-character count. The previous 719-character current listing and the generic 802-character bracket client remain complete alternatives. The generic client catches and validates FxCallFailure and retains its remaining technical exits. The local helper does not replace generic implementation 098 or select another core edition. The Haskell client raises with `ioError`, catches with `try`, and branches on `Either`; Scala uses `throw` and `catch`. Both include real failure handling without a written finite `throws` list in their signatures.

In generic implementation 098, Haskell catches only to release and rethrow, whereas Scala and LMX use `finally` for cleanup. The corresponding client supplies the application-level response. The 084 primary uses its fully counted local helper; the generic 084 alternative uses 098. These are source-level explanations of the linked current files, not runtime test results.
