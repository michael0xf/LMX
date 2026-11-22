# Partial: общий префикс аргументов

Редакция: 22 ноября 2026 года. Клиент: [H03](../lmx/H03.lm3), [разбор](../../LMX_examples_and_analogies.ru.md#h03).

## Контракт общего ресивера

partial принимает callable с N входами и контейнер K записей. Построенный callable имеет N−K обязательных входов p0… и точный исходный результат R. K=0 и K=N допустимы; полный префикс создаёт отложенный nullary-callable. Новая функция не исполняет цель при создании. Примитивы захватываются по значению, ссылки сохраняют идентичность цели.

Публичный ресивер `partial` уже входит в единое текущее ядро и используется прямо. Никаких import или выбираемых версий библиотек нет. Внутренние Fx/Rx-имена ниже обозначают структуры реализации ядра.

Этот документ показывает исходники общего ядрового механизма и локального процедурного приёма. Это разные области контракта, а не две взаимозаменяемые версии ядра: специализированный приём не подменяет весь общий API только потому, что он короче. Основной клиент выбирается отдельно из корректных вариантов по полной длине и границе учёта, см. H03.

## Полный алгоритм ресивера ядра LMX

Ниже приведено консервативное замыкание по корневым LMX-определениям от `FxPartial`: полные определения перечислены один раз, включая те, которые упомянуты в генерируемом тексте тела. Это видимый исходник текущего ядра; он не подменяется строкой импорта. Общие определения повторно используются другими receivers; одинаковые определения не считаются новой самостоятельной реализацией для каждого клиента.

- [generic_functions.lmx](../../LMX_Fn_Receivers/src/generic_functions.lmx)

```lmx
FxBuild:
    private:
        @: contract
        []: char bodyText
        @: state
        @: failures
    return: @
    make:
        throws:
            FxKernelFailure
            FxTypeToken
        private: @: shape FxKernel\signature(subject := contract)
        private: @: bodyGraph sys\fromLmx(bodyText)
        return: FxKernel\callable(contract; shape\names; bodyGraph; state; failures)

FxCaptureFailures:
    return: @
    names:
        private: @: out (copy(()))
        sys\resize(out; 1)
        out[0] := "FxRecordArity"
        return: out

FxCaptureState:
    @: record 0

FxRecordOperands:
    copy: sys\OPERANDS_TEMPLATE
    required: left right
    return: @
    record:
        throws:
            FxRecordArity
        if: length(right) != 0
            throw: FxRecordArity()
        return: left

FxConcat:
    private:
        []: char first
        []: char second
    return: []: char
    concat:
        private: []: char out ()
        private: int: n length(first)
        private: int: m length(second)
        sys\resize(out; n + m)
        private: int: i 0
        while: i < n
            out[i] := first[i]
            i += 1
        private: int: j 0
        while: j < m
            out[n + j] := second[j]
            j += 1
        return: out

FxDecimal:
    private: int: number
    return: []: char
    decimal:
        throws:
            FxIndex
        if: number < 0
            throw: FxIndex()
        private: []: char digits "0123456789"
        private: []: char reversed ()
        private: int: used 0
        private: int: rest number
        while: 1
            sys\resize(reversed; used + 1)
            reversed[used] := digits[rest % 10]
            used += 1
            rest := rest / 10
            if: rest = 0
                break
        ---
        private: []: char out ()
        sys\resize(out; used)
        private: int: i 0
        while: i < used
            out[i] := reversed[used - i - 1]
            i += 1
        return: out

FxLabels:
    private: int: count
    return: @
    labels:
        throws:
            FxIndex
        if: count < 0
            throw: FxIndex()
        private: @: out (copy(()))
        sys\resize(out; count)
        private: int: i 0
        while: i < count
            out[i] := FxConcat\concat("p"; FxDecimal\decimal(i))
            i += 1
        return: out

FxSignatures:
    private:
        @: inputs
        @: result
    return: @
    make:
        throws:
            FxIndex
            FxKernelFailure
            FxTypeToken
        private: @: labels FxLabels\labels(length(inputs))
        private: @: data FxKernel\signatureData(inputs := inputs; result := result; labels := labels)
        Built :: data
        return: Built

FxTypeTokens:
    reference:
        @: value

FxCaptureOne:
    private:
        @: requirement
        @: sourceRecord
    return: @
    capture:
        throws:
            FxIndex
            FxKernelFailure
            FxRecordArity
            FxTypeToken
        private: @: inputTypes (copy(()))
        sys\resize(inputTypes; 1)
        inputTypes[0] := requirement
        private: @: referenceType FxKernel\normalizeType(token := FxTypeTokens\reference[0])
        private: @: contract FxSignatures\make(inputTypes; referenceType)
        private: @: state (copy(FxCaptureState))
        state\record := FxRecordOperands\record
        private: @: failures FxCaptureFailures\names()
        # FxRecordArity невозможно при написанном пустом RHS, но имя включается
        # в явный контракт тела как объявленный исход используемого операнда.
        private: @: receiver FxBuild\make(contract; "return: (p0 node\\private\\state\\record)\n"; state; failures)
        return: receiver(p0 := \sourceRecord)

FxCapturePrefix:
    private:
        @: inputTypes
        @: prefix
    return: @
    capture:
        throws:
            FxArity
            FxIndex
            FxKernelFailure
            FxRecordArity
            FxTypeToken
        if: length(prefix) > length(inputTypes)
            throw: FxArity()
        private: @: captured (copy(()))
        sys\resize(captured; length(prefix))
        private: int: i 0
        while: i < length(prefix)
            captured[i] := FxCaptureOne\capture(inputTypes[i]; prefix[i])
            i += 1
        return: captured

FxCallState:
    @: target 0
    @: targetContract 0
    @: info 0
    @: prefix 0
    @: record 0
    @: stageBuilder 0

FxNewState:
    private:
        @: target
        @: info
        @: prefix
    return: @
    make:
        throws:
            FxIndex
            FxKernelFailure
            FxTypeToken
        private: @: state (copy(FxCallState))
        state\target := target
        state\targetContract := FxSignatures\make(info\inputTypes; info\resultType)
        state\info := info
        state\prefix := prefix
        state\record := FxRecordOperands\record
        return: state

FxSlice:
    private:
        @: values
        int: start
        int: count
    return: @
    slice:
        throws:
            FxIndex
        if: start < 0 || count < 0 || start > length(values)
            throw: FxIndex()
        if: count > length(values) - start
            throw: FxIndex()
        private: @: out (copy(()))
        sys\resize(out; count)
        private: int: i 0
        while: i < count
            out[i] := values[start + i]
            i += 1
        return: out

FxTargetCallText:
    private:
        int: total
        int: captured
        int: swapFirstTwo 0
        int: hasResult
    return: []: char
    build:
        throws:
            FxIndex
        private: []: char out "private: @: fx_target node\\private\\state\\targetContract node\\private\\state\\target\n"
        if: hasResult != 0
            out := FxConcat\concat(out; "return: ")
        out := FxConcat\concat(out; "fx_target(")
        private: int: i 0
        while: i < total
            if: i > 0
                out := FxConcat\concat(out; "; ")
            out := FxConcat\concat(out; "p")
            out := FxConcat\concat(out; FxDecimal\decimal(i))
            out := FxConcat\concat(out; " := ")
            if: i < captured
                out := FxConcat\concat(out; "\\node\\private\\state\\prefix[")
                out := FxConcat\concat(out; FxDecimal\decimal(i))
                out := FxConcat\concat(out; "]")
            else:
                private: int: input i - captured
                if: swapFirstTwo != 0
                    if: i = 0
                        input := 1
                    if: i = 1
                        input := 0
                ---
                out := FxConcat\concat(out; "p")
                out := FxConcat\concat(out; FxDecimal\decimal(input))
            ---
            i += 1
        out := FxConcat\concat(out; ")\n")
        if: hasResult = 0
            out := FxConcat\concat(out; "return\n")
        return: out

FxPartial:
    private:
        @: operation
        @: prefix
    return: @
    partial:
        throws:
            FxArity
            FxIndex
            FxKernelFailure
            FxRecordArity
            FxTypeToken
        private: @: info FxKernel\signature(subject := operation)
        private: @: inputs info\inputTypes
        private: int: n length(inputs)
        private: int: k length(prefix)
        if: k > n
            throw: FxArity()
        private: @: captured FxCapturePrefix\capture(inputs; prefix)
        private: @: remaining FxSlice\slice(inputs; k; n - k)
        private: @: contract FxSignatures\make(remaining; info\resultType)
        private: @: state FxNewState\make(operation; info; captured)
        private: []: char body FxTargetCallText\build(n; k; 0; info\hasResult)
        return: FxBuild\make(contract; body; state; info\throws)
```

Явная граница ядра: `FxKernel`, системные примитивы и стандартные вызовы, описанные в [KERNEL_REQUIREMENTS.md](../../LMX_Fn_Receivers/KERNEL_REQUIREMENTS.md). Это требуемые адаптеры к штатным операциям графа/вызова, а не показанный здесь C-код готового ядра. Их реализация не спрятана в цифре «размер библиотеки»: статус и условия приёмки приведены отдельно. Полный [собранный файл](../../LMX_Fn_Receivers/LMX_Receivers.lmx) и [экспорт имён](../../LMX_Fn_Receivers/src/public.lmx) находятся рядом.

## Реализация Haskell

В Haskell partial связывает первый вход уже каррированной функции. Полиморфные a/b/r не фиксируют Int; r само может быть функцией. Для нескольких исходных аргументов Haskell повторяет обычную аппликацию, тогда как LMX принимает явный вектор префикса. Числа 5 и 100 принадлежат клиенту.

[Точный исходник модуля](../libraries/haskell/Partial.hs):

```haskell
module Partial (partial) where

partial :: (a -> b -> r) -> a -> (b -> r)
partial binary first = \second -> binary first second
```

## Процедурный механизм сценария на том же ядре

Этот обычный пользовательский код показывает явный механизм конкретного сценария. Его int-специализация не является ограничением общего core-ресивера. Он не заменяет весь общий контракт ядра и не является старой библиотечной версией. У клиента он считается, если включён в его выбранный исходник; в таблице ниже его стоимость показана отдельно.

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

## Размеры и границы сравнения

| Показанный код | Непробельные символы | Непустые строки | UTF-8 байты |
| --- | ---: | ---: | ---: |
| LMX: алгоритм и перечисленные LMX-зависимости | 4875 | 265 | 7921 |
| Haskell: весь показанный модуль | 101 | 3 | 128 |
| LMX: процедурный механизм сценария, отдельный контракт | 275 | 18 | 418 |

Это механические размеры показанных исходников. LMX строит обычные графовые callable с точными сигнатурами; Haskell пользуется собственным типовым и функциональным runtime. Таблица не утверждает равенства стоимости их ядер, минимальности замыкания зависимостей или одинаковой реализации. Реализация ядра показана отдельно от клиента. Исключать её из конкурентного клиентского сравнения допустимо при сопоставимом встроенном/библиотечном/операторном механизме у контроля, либо как естественный механизм языка без скрытого предметного алгоритма. Архитектуры не обязаны совпадать; поля, состояние, копии, идентичности и эффекты обязаны сохраняться. Сравнение по клиентам и исходные сохранённые хеши — в [functional_receiver_counts.json](../validation/functional_receiver_counts.json).

**Проверка:** текст, ссылки и размеры воспроизводятся [скриптом](../tools/update_receiver_comparisons.py). LMX и GHC здесь не запускались; подготовленные assertions в [Analogies.hs](../haskell/Analogies.hs) не являются receipt исполнения.
