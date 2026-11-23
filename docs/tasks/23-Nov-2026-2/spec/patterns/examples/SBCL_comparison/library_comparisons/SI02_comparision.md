# SI02. Короткие предикаты, первый индекс и запись значения

## Общий договор

any/all прекращают обход сразу после определяющего ответа; на пустом входе получают 0/1. index возвращает первый подходящий нулевой индекс либо отсутствие; индекс 0 никогда не означает отсутствие. LMX выражает это Maybe, CL reference — двумя values. record сохраняет принятое значение и его идентичность без копирования полезного объекта.

В CL reference циклы реализованы напрямую, some/every/position-if не вызываются. Родной CL объект уже является динамическим значением; record-value имеет смысл identity. Это не заявление о совпадении физических {type value} LMX и машинных tagged values SBCL.

Полный семантический договор относится к одному предикату над одной конечной последовательностью; опции start/end/key/from-end из всего CL API здесь не заявлены. Predicate-admission принимает integer. Физическое Maybe и multiple values отличаются, поэтому сравнивается признак присутствия и само значение.

Эта самостоятельная reference-реализация не является исходником SBCL и не импортируется ни одним клиентским примером. Сравниваются показанные алгоритмы в указанном профиле; весь ANSI Common Lisp API не заявлен.

## LMX: действующие тела ядра

```lmx
FxSeqAny:
    private:
        @: items
        @: accepts
    required: items accepts
    return: int
    any:
        throws: copy(FxThrows\predicate)
        FxSeqInfo\get(items)
        private: int: count length(items)
        private: int: i 0
        while: i < count
            private: @: item FxSeqRead\read(items; i)
            private: @: value FxApply\apply(accepts; FxOne\make(item))
            if: FxSeqPredicate\truth(value) != 0
                return: 1
            i += 1
        return: 0

FxSeqAll:
    private:
        @: items
        @: accepts
    required: items accepts
    return: int
    all:
        throws: copy(FxThrows\predicate)
        FxSeqInfo\get(items)
        private: int: count length(items)
        private: int: i 0
        while: i < count
            private: @: item FxSeqRead\read(items; i)
            private: @: value FxApply\apply(accepts; FxOne\make(item))
            if: FxSeqPredicate\truth(value) = 0
                return: 0
            i += 1
        return: 1

FxSeqIndex:
    private:
        @: items
        @: accepts
    required: items accepts
    return: @
    index:
        throws: FxCallFailure FxKernelFailure FxPredicate FxRecordArity FxTypeToken ReceiverIndex
        FxSeqInfo\get(items)
        private: int: count length(items)
        private: int: i 0
        while: i < count
            private: @: item FxSeqRead\read(items; i)
            private: @: value FxApply\apply(accepts; FxOne\make(item))
            if: FxSeqPredicate\truth(value) != 0
                return: FxSome\some(value := (i FxRecordOperands\record))
            i += 1
        return: FxNone\none()

FxRecordOperands:
    copy: sys\OPERANDS_TEMPLATE
    required: left right
    return: @
    record:
        throws: FxRecordArity
        if: length(right) != 0
            throw: FxRecordArity()
        return: left

FxMaybe:
    int: present 0
    @: value 0

FxSome:
    private: @: value
    return: @
    some:
        private: @: result (copy(FxMaybe))
        result\present := 1
        result\value := value
        return: result

FxNone:
    return: @
    none:
        return: (copy(FxMaybe))
```

## Common Lisp: отдельная реализация того же профиля

```lisp
(in-package #:lmx-sbcl-reference)

(defun record-value (value)
  value)

(defun any-value (items accepts)
  (sequence-value items)
  (function-value accepts)
  (let ((source (coerce items 'vector)))
    (dotimes (i (length source) 0)
      (when (integer-truth (funcall accepts (aref source i)))
        (return 1)))))

(defun all-value (items accepts)
  (sequence-value items)
  (function-value accepts)
  (let ((source (coerce items 'vector)))
    (dotimes (i (length source) 1)
      (unless (integer-truth (funcall accepts (aref source i)))
        (return 0)))))

(defun index-value (items accepts)
  (sequence-value items)
  (function-value accepts)
  (let ((source (coerce items 'vector)))
    (dotimes (i (length source) (values nil nil))
      (when (integer-truth (funcall accepts (aref source i)))
        (return (values i t))))))
```

## Размер исходников

| Язык | Полный без пробельных | Без сложного Throws | Непустые строки | Все Unicode-символы |
| --- | ---: | ---: | ---: | ---: |
| LMX | 1402 | 1339 | 78 | 2163 |
| Common Lisp | 674 | — | 24 | 843 |

Это размеры первичных тел, а не замер производительности. [Общие LMX определения](../source/implementations/lmx/shared_dependencies.lmx), [Common Lisp runtime](../source/implementations/common-lisp/runtime.lisp) и [реестр замыкания](../validation/implementation_dependencies.json) учитываются отдельно. Повторно прибавлять общие определения к каждой строке нельзя. Сигнатуры и admission LMX шире общего профиля SI05/SI06; их стоимость оставлена видимой.

## Проверка

Исполнение reference на SBCL: **PASS**. [Протокол](../validation/implementation_execution.json) содержит тесты и hashes проверенных файлов. LMX: **NOT_RUN**, текущий интегрированный исполняемый движок в этом пакете отсутствует. Совпадение текста с ядром и замыкание зависимостей проверяются отдельно; это не заменяет исполнение.

## Происхождение LMX

- `FxSeqAny` — [patterns/LMX_Fn_Receivers/src/sequences.lmx](../../../LMX_Fn_Receivers/src/sequences.lmx), SHA-256 `278519a8df43775d8d50fe278ac4ffeef91d96d6745e19734a9ada8ed0312a9b`.
- `FxSeqAll` — [patterns/LMX_Fn_Receivers/src/sequences.lmx](../../../LMX_Fn_Receivers/src/sequences.lmx), SHA-256 `6ea407232d91cd061f26a24cf4b233c9d00c9c8735ce78449bf9527ced5cff6c`.
- `FxSeqIndex` — [patterns/LMX_Fn_Receivers/src/sequences.lmx](../../../LMX_Fn_Receivers/src/sequences.lmx), SHA-256 `22227604f0bf6fc90aff292e178e982ca54056678eea94ef212ee58ca841b1dd`.
- `FxRecordOperands` — [patterns/LMX_Fn_Receivers/src/generic_functions.lmx](../../../LMX_Fn_Receivers/src/generic_functions.lmx), SHA-256 `d837d5b291ce5c4bace36acb94bf5b164ce969dc3062f7459142d142658c6d03`.
- `FxMaybe` — [patterns/LMX_Fn_Receivers/src/containers.lmx](../../../LMX_Fn_Receivers/src/containers.lmx), SHA-256 `664720047844572e08d51e3c2c789c38ae145175e1ebefa63cc034bdecf2f2b5`.
- `FxSome` — [patterns/LMX_Fn_Receivers/src/containers.lmx](../../../LMX_Fn_Receivers/src/containers.lmx), SHA-256 `773382b57e1f9271e4226f59ff65f75e60f2a14d022f53168d866496cddb2991`.
- `FxNone` — [patterns/LMX_Fn_Receivers/src/containers.lmx](../../../LMX_Fn_Receivers/src/containers.lmx), SHA-256 `740805d3653f10eee80cd7f96913329d6336ce9a3ce2d1b47816f667199e712c`.

## Первичные источники Common Lisp

- [https://www.lispworks.com/documentation/HyperSpec/Body/f_everyc.htm](https://www.lispworks.com/documentation/HyperSpec/Body/f_everyc.htm)
- [https://www.lispworks.com/documentation/HyperSpec/Body/f_pos_p.htm](https://www.lispworks.com/documentation/HyperSpec/Body/f_pos_p.htm)
- [https://www.lispworks.com/documentation/HyperSpec/Body/f_values.htm](https://www.lispworks.com/documentation/HyperSpec/Body/f_values.htm)
