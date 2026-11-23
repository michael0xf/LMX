# SI06. Мемоизация с явным равенством полного ключа

## Общий договор

Любое конечное число принятых позиционных аргументов, включая ноль; равенство получает весь ключ. Сохраняется внешний снимок аргументов, ссылочные цели не копируются. Кешируются только успешные результаты; nil, отсутствие значений и ссылочный результат сохраняются различимо. Результат ошибки и ошибка сравнения не превращаются в успешную запись.

Это две общие реализации linear-cache memoize с пользовательским равенством, а не подмена ими клиентского hash-table. CL reference сохраняет native multiple values. LMX использует один типизированный результат/void и стандартный frame snapshot; исходные тела его адаптера включены в зависимости.

Ключи должны оставаться стабильны для заданного равенства. Рекурсивный повтор ещё вычисляемого ключа не имеет special in-flight suppression. Кеш локален одному Message/последовательному владельцу; конкурентное разделение mutable cache не заявлено. В S23 основной вариант сравнивает явный кеш; эта пара относится к отдельно сохранённому варианту с memoize, потому что стандарт CL не содержит такого ресивера.

Эта самостоятельная reference-реализация не является исходником SBCL и не импортируется ни одним клиентским примером. Сравниваются показанные алгоритмы в указанном профиле; весь ANSI Common Lisp API не заявлен.

## LMX: действующие тела ядра

```lmx
FxMemoEntry:
    @: key 0
    @: value 0

FxMemoState:
    @: operation 0
    @: sameKey 0
    @: entries 0

FxMemoEngine:
    private:
        @: state
        @: frame
    return: @
    run:
        throws: copy(FxThrows\snapshot)
        private: @: key FxFrameSnapshot\snapshot(frame)
        private: int: i 0
        while: i < length(state\entries)
            private: FxMemoEntry@: entry state\entries[i]
            private: @: equalityArgs FxTwo\make(FxRecords\reference(entry\key); FxRecords\reference(key))
            private: @: flagRecord FxApply\apply(state\sameKey; equalityArgs)
            private: int: flag \flagRecord
            if: flag != 0
                return: entry\value
            i += 1
        private: @: value FxFrameApply\apply(frame)
        private: @: entry (copy(FxMemoEntry))
        entry\key := key
        entry\value := value
        private: int: count length(state\entries)
        sys\resize(state\entries; count + 1)
        state\entries[count] := entry
        return: value

FxMemo:
    private:
        @: operation
        @: sameKey
    return: @
    memo:
        throws: copy(FxThrows\adapter)
        private: @: info FxKernel\signature(subject := operation)
        private: @: equality FxKernel\signature(subject := sameKey)
        private: @: state (copy(FxMemoState))
        state\operation := operation
        state\sameKey := sameKey
        state\entries := (copy(()))
        private: @: contract FxSignatures\make(info\inputTypes; info\resultType)
        private: @: failures FxFailures\union(info\throws; equality\throws)
        return: FxWrap\make(contract; FxMemoEngine\run; state; failures; FxFullPolicy\make(operation))
```

## Common Lisp: отдельная реализация того же профиля

```lisp
(in-package #:lmx-sbcl-reference)

(defun memoize-values (operation same-key)
  (function-value operation)
  (function-value same-key)
  (let ((entries (make-array 0 :adjustable t :fill-pointer 0)))
    (lambda (&rest actuals)
      (let ((key (snapshot actuals)))
        (block lookup
          (dotimes (i (length entries))
            (let ((entry (aref entries i)))
              (when (integer-truth (funcall same-key (car entry) key))
                (return-from lookup (values-list (cdr entry))))))
          (let ((values (multiple-value-list (apply operation actuals))))
            (vector-push-extend (cons key values) entries)
            (values-list values)))))))
```

## Размер исходников

| Язык | Полный без пробельных | Без сложного Throws | Непустые строки | Все Unicode-символы |
| --- | ---: | ---: | ---: | ---: |
| LMX | 1211 | 1211 | 48 | 1700 |
| Common Lisp | 508 | — | 15 | 680 |

Это размеры первичных тел, а не замер производительности. [Общие LMX определения](../source/implementations/lmx/shared_dependencies.lmx), [Common Lisp runtime](../source/implementations/common-lisp/runtime.lisp) и [реестр замыкания](../validation/implementation_dependencies.json) учитываются отдельно. Повторно прибавлять общие определения к каждой строке нельзя. Сигнатуры и admission LMX шире общего профиля SI05/SI06; их стоимость оставлена видимой.

## Проверка

Исполнение reference на SBCL: **PASS**. [Протокол](../validation/implementation_execution.json) содержит тесты и hashes проверенных файлов. LMX: **NOT_RUN**, текущий интегрированный исполняемый движок в этом пакете отсутствует. Совпадение текста с ядром и замыкание зависимостей проверяются отдельно; это не заменяет исполнение.

## Происхождение LMX

- `FxMemoEntry` — [patterns/LMX_Fn_Receivers/src/generic_combinators.lmx](../../../LMX_Fn_Receivers/src/generic_combinators.lmx), SHA-256 `a02ea4be4da7690ed48b6aeebca2fa34f7d189fe1f09a6faf72168429884773f`.
- `FxMemoState` — [patterns/LMX_Fn_Receivers/src/generic_combinators.lmx](../../../LMX_Fn_Receivers/src/generic_combinators.lmx), SHA-256 `b3c19624a4ad39492e9235a8a5ef0b0664d18ab16eac71b83a37417c0a48f10e`.
- `FxMemoEngine` — [patterns/LMX_Fn_Receivers/src/generic_combinators.lmx](../../../LMX_Fn_Receivers/src/generic_combinators.lmx), SHA-256 `61280b245abcadd82b6e78b853f82dc3722c5628bba4045e96543cec6b0faec8`.
- `FxMemo` — [patterns/LMX_Fn_Receivers/src/generic_combinators.lmx](../../../LMX_Fn_Receivers/src/generic_combinators.lmx), SHA-256 `6b326fa53fee173d06175b6d378c02c06a6e1ee024475981a26b95356e0fa3a8`.

## Первичные источники Common Lisp

- [https://www.lispworks.com/documentation/HyperSpec/Body/f_gethas.htm](https://www.lispworks.com/documentation/HyperSpec/Body/f_gethas.htm)
- [https://www.lispworks.com/documentation/HyperSpec/Body/f_apply.htm](https://www.lispworks.com/documentation/HyperSpec/Body/f_apply.htm)
- [https://www.lispworks.com/documentation/HyperSpec/Body/s_fn.htm](https://www.lispworks.com/documentation/HyperSpec/Body/s_fn.htm)
