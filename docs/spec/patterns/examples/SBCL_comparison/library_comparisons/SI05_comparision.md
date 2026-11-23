# SI05. Частичное применение произвольной конечной функции

## Общий договор

Функция произвольной конечной позиционной арности N, префикс длины 0..N и остаток N−K. Значения префикса сохраняются в новом внешнем контейнере с прежними ссылочными целями. Полный префикс даёт thunk, тело до вызова не исполняется; ошибка тела проходит наружу. CL reference сохраняет все multiple values.

Обычный apply/funcall и lexical closure — примитивы языка CL. В reference arity передаётся как явная метаинформация, потому что ANSI CL не требует восстанавливать декларацию любого function object. LMX получает реальные требования из существующего signature-моста, и его полная реализация вместе с общими адаптерами сохраняется здесь.

Доказанный общий профиль — уже вычисленные позиционные аргументы. LMX partial также сохраняет свои defaults, DATA, динамическое связывание, admission и точную сигнатуру; CL reference не притворяется полной эмуляцией этих механизмов. Поэтому отношение размеров этих компонентов не является доказательством краткости всей системы вызова.

Эта самостоятельная reference-реализация не является исходником SBCL и не импортируется ни одним клиентским примером. Сравниваются показанные алгоритмы в указанном профиле; весь ANSI Common Lisp API не заявлен.

## LMX: действующие тела ядра

```lmx
FxPartial:
    private:
        @: operation
        @: prefix
    return: @
    partial:
        throws: copy(FxThrows\capture)
        private: @: info FxKernel\signature(subject := operation)
        private: int: n length(info\inputTypes)
        private: int: k length(prefix)
        if: k > n
            throw: FxArity()
        private: @: captured FxCapturePrefix\capture(info\inputTypes; prefix)
        private: @: remaining FxSlice\slice(info\inputTypes; k; n - k)
        private: @: contract FxSignatures\make(remaining; info\resultType)
        private: @: policy FxPrefixPolicy\make(operation; captured)
        return: FxWrap\make(contract; FxForwardEngine\run; (copy(())); info\throws; policy)
```

## Common Lisp: отдельная реализация того же профиля

```lisp
(in-package #:lmx-sbcl-reference)

(defun partial-values (operation arity prefix)
  (function-value operation)
  (check-type arity (integer 0 *))
  (sequence-value prefix)
  (let* ((captured (coerce (snapshot prefix) 'list))
         (remaining (- arity (length captured))))
    (when (minusp remaining) (error "Prefix exceeds positional arity"))
    (lambda (&rest actuals)
      (unless (= (length actuals) remaining)
        (error "Expected ~D residual arguments, got ~D"
               remaining (length actuals)))
      (apply operation (append captured actuals)))))
```

## Размер исходников

| Язык | Полный без пробельных | Без сложного Throws | Непустые строки | Все Unicode-символы |
| --- | ---: | ---: | ---: | ---: |
| LMX | 533 | 533 | 17 | 713 |
| Common Lisp | 454 | — | 13 | 573 |

Это размеры первичных тел, а не замер производительности. [Общие LMX определения](../source/implementations/lmx/shared_dependencies.lmx), [Common Lisp runtime](../source/implementations/common-lisp/runtime.lisp) и [реестр замыкания](../validation/implementation_dependencies.json) учитываются отдельно. Повторно прибавлять общие определения к каждой строке нельзя. Сигнатуры и admission LMX шире общего профиля SI05/SI06; их стоимость оставлена видимой.

## Проверка

Исполнение reference на SBCL: **PASS**. [Протокол](../validation/implementation_execution.json) содержит тесты и hashes проверенных файлов. LMX: **NOT_RUN**, текущий интегрированный исполняемый движок в этом пакете отсутствует. Совпадение текста с ядром и замыкание зависимостей проверяются отдельно; это не заменяет исполнение.

## Происхождение LMX

- `FxPartial` — [patterns/LMX_Fn_Receivers/src/generic_functions.lmx](../../../LMX_Fn_Receivers/src/generic_functions.lmx), SHA-256 `58c4cd4bf7bb30af5409b9db5f537331645a3c1b58db50af5c603d0fb69bad4e`.

## Первичные источники Common Lisp

- [https://www.lispworks.com/documentation/HyperSpec/Body/f_apply.htm](https://www.lispworks.com/documentation/HyperSpec/Body/f_apply.htm)
- [https://www.lispworks.com/documentation/HyperSpec/Body/s_fn.htm](https://www.lispworks.com/documentation/HyperSpec/Body/s_fn.htm)
