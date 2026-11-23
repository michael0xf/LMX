# SI03. Устойчивая сортировка и первые уникальные элементы

## Общий договор

Новая внешняя последовательность, неизменный источник, прежняя идентичность ссылочных элементов. Устойчивая bottom-up merge sort использует трёхсторонний целый comparator. unique оставляет первое вхождение по явному равенству. Пустой и одиночный вход не вызывают comparator. Вход и ключи не меняются из callbacks.

CL reference не вызывает sort/stable-sort/remove-duplicates. Обе реализации показывают алгоритмы; общая инфраструктура профиля последовательности перечислена отдельно.

Generic unique линейно ищет в уже принятой части и имеет O(n²), sort имеет O(n log n). Это не замер скорости SBCL и не описание внутреннего алгоритма его стандартной библиотеки. CL native remove-duplicates может разделять внешнюю последовательность с входом, а reference здесь всегда строит результат по договору LMX; клиент S08 не наблюдает идентичность внешнего контейнера.

Эта самостоятельная reference-реализация не является исходником SBCL и не импортируется ни одним клиентским примером. Сравниваются показанные алгоритмы в указанном профиле; весь ANSI Common Lisp API не заявлен.

## LMX: действующие тела ядра

```lmx
FxSort:
    private:
        @: items
        @: compare
    required: items compare
    return: @
    sort:
        throws: FxCallFailure FxKernelFailure FxTypeToken ReceiverIndex SequenceElement SequenceSize
        private: @: info FxSeqInfo\get(items)
        private: int: count length(items)
        private: @: current FxSeqSlice\slice(items; 0; count)
        if: count < 2
            return: current
        private: @: scratch FxSeqAllocate\make(info\arrayType; count)
        private: int: width 1
        while: width < count
            private: int: start 0
            while: start < count
                private: int: middle count
                if: width < count - start
                    middle := start + width
                private: int: end count
                if: width < count - middle
                    end := middle + width
                private: int: left start
                private: int: right middle
                private: int: at start
                while: at < end
                    private: int: takeLeft 0
                    if: right = end
                        takeLeft := 1
                    else:
                        if: left < middle
                            private: @: a FxSeqRead\read(current; left)
                            private: @: b FxSeqRead\read(current; right)
                            private: @: answer FxApply\apply(compare; FxTwo\make(a; b))
                            private: int: order FxSeqInteger\read(answer)
                            takeLeft := order <= 0
                    ---
                    private: @: selected 0
                    if: takeLeft != 0
                        selected := FxSeqRead\read(current; left)
                        left += 1
                    else:
                        selected := FxSeqRead\read(current; right)
                        right += 1
                    ---
                    FxSeqStore\write(scratch; at; selected)
                    at += 1
                start := end
            private: @: previous current
            current := scratch
            scratch := previous
            # Guard before doubling: count bounds the array length and bytes.
            if: width > count - width
                width := count
            else:
                width += width
        ---
        return: current

FxUnique:
    private:
        @: items
        @: same
    required: items same
    return: @
    unique:
        throws:
            FxCallFailure
            FxKernelFailure
            FxPredicate
            FxTypeToken
            ReceiverIndex
            SequenceElement
            SequenceSize
        private: @: info FxSeqInfo\get(items)
        private: int: count length(items)
        private: @: result FxSeqAllocate\make(info\arrayType; count)
        private: int: used 0
        private: int: i 0
        while: i < count
            private: @: item FxSeqRead\read(items; i)
            private: int: duplicate 0
            private: int: j 0
            while: j < used
                private: @: previous FxSeqRead\read(result; j)
                private: @: answer FxApply\apply(same; FxTwo\make(previous; item))
                if: FxSeqPredicate\truth(answer) != 0
                    duplicate := 1
                    break
                j += 1
            if: duplicate = 0
                FxSeqStore\write(result; used; item)
                used += 1
            i += 1
        sys\resize(result; used)
        return: result
```

## Common Lisp: отдельная реализация того же профиля

```lisp
(in-package #:lmx-sbcl-reference)

(defun sort-values (items compare)
  (sequence-value items)
  (function-value compare)
  (let* ((source (snapshot items)) (size (length source))
         (target (make-array size)) (width 1))
    (loop while (< width size) do
      (loop for begin from 0 below size by (* 2 width) do
        (let* ((middle (min size (+ begin width)))
               (end (min size (+ middle width)))
               (left begin) (right middle) (out begin))
          (loop while (and (< left middle) (< right end)) do
            (let ((order (funcall compare (aref source left)
                                          (aref source right))))
              (check-type order integer)
              (if (<= order 0)
                  (progn (setf (aref target out) (aref source left))
                         (incf left))
                  (progn (setf (aref target out) (aref source right))
                         (incf right)))
              (incf out)))
          (loop while (< left middle) do
            (setf (aref target out) (aref source left))
            (incf left) (incf out))
          (loop while (< right end) do
            (setf (aref target out) (aref source right))
            (incf right) (incf out))))
      (rotatef source target)
      (setf width (* 2 width)))
    (same-profile items source)))

(defun unique-values (items same)
  (sequence-value items)
  (function-value same)
  (let ((source (coerce items 'vector))
        (out (make-array 0 :adjustable t :fill-pointer 0)))
    (dotimes (i (length source))
      (let ((value (aref source i)) (found nil))
        (dotimes (j (length out))
          (when (integer-truth (funcall same (aref out j) value))
            (setf found t)
            (return)))
        (unless found (vector-push-extend value out))))
    (same-profile items out)))
```

## Размер исходников

| Язык | Полный без пробельных | Без сложного Throws | Непустые строки | Все Unicode-символы |
| --- | ---: | ---: | ---: | ---: |
| LMX | 1894 | 1751 | 97 | 3530 |
| Common Lisp | 1218 | — | 43 | 1845 |

Это размеры первичных тел, а не замер производительности. [Общие LMX определения](../source/implementations/lmx/shared_dependencies.lmx), [Common Lisp runtime](../source/implementations/common-lisp/runtime.lisp) и [реестр замыкания](../validation/implementation_dependencies.json) учитываются отдельно. Повторно прибавлять общие определения к каждой строке нельзя. Сигнатуры и admission LMX шире общего профиля SI05/SI06; их стоимость оставлена видимой.

## Проверка

Исполнение reference на SBCL: **PASS**. [Протокол](../validation/implementation_execution.json) содержит тесты и hashes проверенных файлов. LMX: **NOT_RUN**, текущий интегрированный исполняемый движок в этом пакете отсутствует. Совпадение текста с ядром и замыкание зависимостей проверяются отдельно; это не заменяет исполнение.

## Происхождение LMX

- `FxSort` — [patterns/LMX_Fn_Receivers/src/corePerlExamples.lmx](../../../LMX_Fn_Receivers/src/corePerlExamples.lmx), SHA-256 `37eaee6a42aa868c91832a98e74183a9ad80f6761a50a7cebddc900a265b2d4a`.
- `FxUnique` — [patterns/LMX_Fn_Receivers/src/corePerlExamples.lmx](../../../LMX_Fn_Receivers/src/corePerlExamples.lmx), SHA-256 `45e5c9ba86ebc9d39d746aaddb819ee0770027085f46bb27681f4a13679bb019`.

## Первичные источники Common Lisp

- [https://www.lispworks.com/documentation/HyperSpec/Body/f_sort_.htm](https://www.lispworks.com/documentation/HyperSpec/Body/f_sort_.htm)
- [https://www.lispworks.com/documentation/HyperSpec/Body/f_rm_dup.htm](https://www.lispworks.com/documentation/HyperSpec/Body/f_rm_dup.htm)
