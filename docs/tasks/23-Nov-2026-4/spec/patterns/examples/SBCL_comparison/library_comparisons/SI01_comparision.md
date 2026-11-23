# SI01. Обходы, фильтрация и свёртка

## Общий договор

Конечные последовательности с произвольными элементами. map и zipWith выдают последовательность результатов, filter сохраняет профиль элементов и порядок, compress выбирает по целочисленной маске ровно той же длины и проверяет всю маску до построения результата, foldl начинает с явного seed. zipWith заканчивает на меньшей длине. Порядок callbacks слева направо; ошибка прерывает обход; частичный результат не возвращается. Пустые входы и ссылочные результаты поддержаны.

Чтение позиции, выделение последовательности и обычный вызов функции — общий нижний уровень. В CL здесь нет вызова map, mapcar, remove-if-not или reduce; показаны сами алгоритмы. В LMX общий вызов включает существующие FxApply/FxKernel и нормальное принятие результата.

Общий профиль исключает изменение входа из callback. CL reference принимает конечные proper lists и векторы; последовательность результатов map/zipWith — общий вектор. filter сохраняет list/vector и actual array element type; родство native типов двух VM не утверждается. Предикат reference намеренно принимает integer truth, чтобы не потерять отличие LMX int от произвольного Lisp truth.

Эта самостоятельная reference-реализация не является исходником SBCL и не импортируется ни одним клиентским примером. Сравниваются показанные алгоритмы в указанном профиле; весь ANSI Common Lisp API не заявлен.

## LMX: действующие тела ядра

```lmx
FxMap:
    private:
        @: items
        @: transform
    required: items transform
    return: @
    map:
        throws: copy(FxThrows\traversal)
        FxSeqInfo\get(items)
        private: int: count length(items)
        private: @: result FxSeqAllocate\make(@[]; count)
        private: int: i 0
        while: i < count
            private: @: item FxSeqRead\read(items; i)
            result[i] := FxApply\apply(transform; FxOne\make(item))
            i += 1
        return: result

FxFilter:
    private:
        @: items
        @: accepts
    required: items accepts
    return: @
    filter:
        throws: copy(FxThrows\traversal)
        private: @: info FxSeqInfo\get(items)
        private: int: count length(items)
        private: @: result FxSeqAllocate\make(info\arrayType; count)
        private: int: used 0
        private: int: i 0
        while: i < count
            private: @: item FxSeqRead\read(items; i)
            private: @: flagRecord FxApply\apply(accepts; FxOne\make(item))
            # Keep filter's established ordinary int-result admission channel.
            private: int: flag \flagRecord
            if: flag != 0
                FxKernel\arrayWrite(target := result; index := used; value := item)
                used += 1
            i += 1
        sys\resize(result; used)
        return: result

FxSeqCompress:
    private:
        @: source
        @: mask
    required: source mask
    return: @
    compress:
        throws: FxKernelFailure FxShape FxTypeToken ReceiverIndex SequenceElement SequenceSize
        private: @: info FxSeqInfo\get(source)
        FxSeqInfo\get(mask)
        private: int: count length(source)
        if: length(mask) != count
            throw: FxShape()
        private: @: flags FxSeqAllocate\make(int[]; count)
        private: int: accepted 0
        private: int: i 0
        # Validate every mask value before constructing the selected result.
        while: i < count
            private: @: value FxSeqRead\read(mask; i)
            private: int: flag FxSeqInteger\read(value)
            flags[i] := flag
            if: flag != 0
                accepted += 1
            i += 1
        private: @: out FxSeqAllocate\make(info\arrayType; accepted)
        private: int: written 0
        i := 0
        while: i < count
            if: flags[i] != 0
                private: @: value FxSeqRead\read(source; i)
                FxKernel\arrayWrite(target := out; index := written; value := value)
                written += 1
            i += 1
        return: out

FxFold:
    private:
        @: items
        @: seed
        @: step
    required: items seed step
    return: @
    fold:
        throws: FxCallFailure FxKernelFailure FxTypeToken ReceiverIndex
        FxSeqInfo\get(items)
        private: int: count length(items)
        private: @: accumulator seed
        private: int: i 0
        while: i < count
            private: @: item FxSeqRead\read(items; i)
            accumulator := FxApply\apply(step; FxTwo\make(accumulator; item))
            i += 1
        return: accumulator

FxZipWith:
    private:
        @: first
        @: second
        @: combine
    required: first second combine
    return: @
    zipWith:
        throws: copy(FxThrows\traversal)
        FxSeqInfo\get(first)
        FxSeqInfo\get(second)
        private: int: count length(first)
        if: length(second) < count
            count := length(second)
        private: @: result FxSeqAllocate\make(@[]; count)
        private: int: i 0
        while: i < count
            private: @: leftValue FxSeqRead\read(first; i)
            private: @: rightValue FxSeqRead\read(second; i)
            result[i] := FxApply\apply(combine; FxTwo\make(leftValue; rightValue))
            i += 1
        return: result
```

## Common Lisp: отдельная реализация того же профиля

```lisp
(in-package #:lmx-sbcl-reference)

(defun map-values (items transform)
  (sequence-value items)
  (function-value transform)
  (let* ((source (coerce items 'vector))
         (out (make-array (length source))))
    (dotimes (i (length source) out)
      (setf (aref out i) (funcall transform (aref source i))))))

(defun filter-values (items accepts)
  (sequence-value items)
  (function-value accepts)
  (let ((source (coerce items 'vector))
        (out (make-array 0 :adjustable t :fill-pointer 0)))
    (dotimes (i (length source))
      (let ((value (aref source i)))
        (when (integer-truth (funcall accepts value))
          (vector-push-extend value out))))
    (same-profile items out)))

(defun fold-values (items seed step)
  (sequence-value items)
  (function-value step)
  (let ((source (coerce items 'vector)) (accumulator seed))
    (dotimes (i (length source) accumulator)
      (setf accumulator (funcall step accumulator (aref source i))))))

(defun compress-values (items mask)
  (sequence-value items)
  (sequence-value mask)
  (unless (= (length items) (length mask))
    (error "Mask and source lengths differ"))
  (let* ((source (coerce items 'vector)) (flags (snapshot mask))
         (accepted 0))
    (dotimes (i (length flags))
      (when (integer-truth (aref flags i)) (incf accepted)))
    (let ((out (make-array accepted)) (written 0))
      (dotimes (i (length source))
        (unless (zerop (aref flags i))
          (setf (aref out written) (aref source i))
          (incf written)))
      (same-profile items out))))

(defun zip-with-values (first second combine)
  (sequence-value first)
  (sequence-value second)
  (function-value combine)
  (let* ((a (coerce first 'vector)) (b (coerce second 'vector))
         (size (min (length a) (length b))) (out (make-array size)))
    (dotimes (i size out)
      (setf (aref out i) (funcall combine (aref a i) (aref b i))))))
```

## Размер исходников

| Язык | Без пробельных | Непустые строки | Все Unicode-символы |
| --- | ---: | ---: | ---: |
| LMX | 2483 | 115 | 3805 |
| Common Lisp | 1503 | 47 | 1912 |

Это размеры первичных тел, а не замер производительности. [Общие LMX определения](../source/implementations/lmx/shared_dependencies.lmx), [Common Lisp runtime](../source/implementations/common-lisp/runtime.lisp) и [реестр замыкания](../validation/implementation_dependencies.json) учитываются отдельно. Повторно прибавлять общие определения к каждой строке нельзя. Сигнатуры и admission LMX шире общего профиля SI05/SI06; их стоимость оставлена видимой.

## Проверка

Исполнение reference на SBCL: **PASS**. [Протокол](../validation/implementation_execution.json) содержит тесты и hashes проверенных файлов. LMX: **NOT_RUN**, текущий интегрированный исполняемый движок в этом пакете отсутствует. Совпадение текста с ядром и замыкание зависимостей проверяются отдельно; это не заменяет исполнение.

## Происхождение LMX

- `FxMap` — [patterns/LMX_Fn_Receivers/src/collections.lmx](../../../LMX_Fn_Receivers/src/collections.lmx), SHA-256 `49c1cb3d1577c37469adf35e404ca945dc8e331a87312695951bf35f4e935dbb`.
- `FxFilter` — [patterns/LMX_Fn_Receivers/src/collections.lmx](../../../LMX_Fn_Receivers/src/collections.lmx), SHA-256 `542bdf6db0e61ac6b33c361a2b658db22cf4993b70667052f54fb95e104712d0`.
- `FxSeqCompress` — [patterns/LMX_Fn_Receivers/src/sequences.lmx](../../../LMX_Fn_Receivers/src/sequences.lmx), SHA-256 `1e4d207e73ac79896ce881e466673552e8715b51bbb3e5284ad6917648fe63d4`.
- `FxFold` — [patterns/LMX_Fn_Receivers/src/collections.lmx](../../../LMX_Fn_Receivers/src/collections.lmx), SHA-256 `28284bf3f75237774f902a6c8db5b662686965754bae34616b124d34881990b2`.
- `FxZipWith` — [patterns/LMX_Fn_Receivers/src/collections.lmx](../../../LMX_Fn_Receivers/src/collections.lmx), SHA-256 `6db9499add9b08adc4931b289e9a589c9b6fc4d30f9641d9358d074ca6fa8fbf`.

## Первичные источники Common Lisp

- [https://www.lispworks.com/documentation/HyperSpec/Body/f_mapc_.htm](https://www.lispworks.com/documentation/HyperSpec/Body/f_mapc_.htm)
- [https://www.lispworks.com/documentation/HyperSpec/Body/f_rm_rm.htm](https://www.lispworks.com/documentation/HyperSpec/Body/f_rm_rm.htm)
- [https://www.lispworks.com/documentation/HyperSpec/Body/f_reduce.htm](https://www.lispworks.com/documentation/HyperSpec/Body/f_reduce.htm)
