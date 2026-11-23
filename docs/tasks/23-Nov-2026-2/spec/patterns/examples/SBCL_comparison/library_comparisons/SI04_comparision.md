# SI04. Замена диапазона и сохранение target

## Общий договор

Полный replaceRange: полуоткрытый [begin,end), вставка, удаление, рост, уменьшение, пустые диапазоны и совпадение values с target. Вставка сначала подготавливается и проверяется, затем сдвигается хвост. Возвращается прежний target, а не удалённые элементы. Ссылочные цели сохраняются.

LMX использует общий изменяемый массив. CL reference использует adjustable vector с fill pointer и собственной памятью. Это ближайший физический профиль сохраняющего идентичность расширяемого массива; клиент S09 с обычным replace ограничен одинаковыми длинами, поэтому его договор уже, чем библиотечная реализация.

Reference не выдаётся за реализацию CL:replace: стандартный replace не изменяет длину. Здесь отдельно реализован именно LMX replaceRange. Допускаются перекрывающиеся источники; target должен владеть backing storage, displaced target отвергается. Ошибка типов подготовки не меняет target; исчерпание памяти не даёт общего обещания транзакции. CL actual array element type не равен полной системе admission LMX.

Эта самостоятельная reference-реализация не является исходником SBCL и не импортируется ни одним клиентским примером. Сравниваются показанные алгоритмы в указанном профиле; весь ANSI Common Lisp API не заявлен.

## LMX: действующие тела ядра

```lmx
FxSeqReplaceRange:
    private:
        @: target
        int: begin
        int: end
        @: values
    required: target begin end values
    return: @
    replaceRange:
        throws: copy(FxThrows\mutation)
        private: @: info FxSeqInfo\get(target)
        FxSeqInfo\get(values)
        private: int: removed FxSeqBounds\count(target; begin; end)
        private: int: oldSize length(target)
        private: int: added length(values)
        private: int: retained oldSize - removed
        private: int: newSize FxSeqSize\sum(retained; added; info\maxLength)
        private: @: stage FxSeqAllocate\make(info\arrayType; added)
        private: int: i 0
        # This conservative overlap-safe path buffers only the inserted range.
        # Dense preparation keeps dense T storage; @[] keeps direct references.
        # No hidden user converter or initializer is called by arrayAdmit.
        # Full ordinary admission belongs here, never in the commit loop.
        while: i < added
            private: @: sourceValue FxSeqRead\read(values; i)
            private: @: ready FxSeqAdmit\admit(target; sourceValue)
            FxKernel\arrayWrite(target := stage; index := i; value := ready)
            i += 1
        # Capacity can change while descriptor identity is retained. Resource
        # failure is ordinary; no general transactional promise is introduced.
        sys\reserve(target; newSize)
        if: newSize > oldSize
            private: int: shift newSize - oldSize
            sys\resize(target; newSize)
            i := oldSize
            # Move the tail backwards before inserting, like a typed memmove.
            while: i > end
                i -= 1
                private: @: value FxSeqRead\read(target; i)
                FxKernel\arrayWrite(target := target; index := i + shift; value := value)
        ---
        else:
            private: int: destination begin + added
            i := end
            # For shrink/equal length the forward order does not overwrite a
            # source tail element that has not yet been read.
            while: i < oldSize
                private: @: value FxSeqRead\read(target; i)
                FxKernel\arrayWrite(target := target; index := destination; value := value)
                destination += 1
                i += 1
            sys\resize(target; newSize)
        i := 0
        while: i < added
            private: @: value FxSeqRead\read(stage; i)
            FxKernel\arrayWrite(target := target; index := begin + i; value := value)
            i += 1
        return: target
```

## Common Lisp: отдельная реализация того же профиля

```lisp
(in-package #:lmx-sbcl-reference)

(defun replace-range (target begin end values)
  (check-type target vector)
  (unless (and (adjustable-array-p target)
               (array-has-fill-pointer-p target))
    (error "Target must be an adjustable vector with a fill pointer"))
  (when (array-displacement target)
    (error "Target must own its backing storage"))
  (sequence-value values)
  (let* ((old-size (length target))
         (removed (checked-bounds old-size begin end))
         (added (length values))
         (new-size (+ (- old-size removed) added))
         (stage (make-array added :element-type (array-element-type target))))
    (when (or (>= new-size array-dimension-limit)
              (>= new-size array-total-size-limit))
      (error "Sequence size exceeds the implementation limit"))
    (dotimes (i added)
      (let ((value (elt values i)))
        (unless (typep value (array-element-type target))
          (error 'type-error :datum value
                            :expected-type (array-element-type target)))
        (setf (aref stage i) value)))
    (when (> new-size (array-total-size target))
      (adjust-array target new-size))
    (if (> new-size old-size)
        (let ((shift (- new-size old-size)))
          (setf (fill-pointer target) new-size)
          (loop for i downfrom (1- old-size) to end do
            (setf (aref target (+ i shift)) (aref target i))))
        (progn
          (loop for i from end below old-size
                for destination from (+ begin added) do
                  (setf (aref target destination) (aref target i)))
          (setf (fill-pointer target) new-size)))
    (dotimes (i added)
      (setf (aref target (+ begin i)) (aref stage i)))
    target))
```

## Размер исходников

| Язык | Полный без пробельных | Без сложного Throws | Непустые строки | Все Unicode-символы |
| --- | ---: | ---: | ---: | ---: |
| LMX | 1729 | 1729 | 58 | 2583 |
| Common Lisp | 1262 | — | 38 | 1732 |

Это размеры первичных тел, а не замер производительности. [Общие LMX определения](../source/implementations/lmx/shared_dependencies.lmx), [Common Lisp runtime](../source/implementations/common-lisp/runtime.lisp) и [реестр замыкания](../validation/implementation_dependencies.json) учитываются отдельно. Повторно прибавлять общие определения к каждой строке нельзя. Сигнатуры и admission LMX шире общего профиля SI05/SI06; их стоимость оставлена видимой.

## Проверка

Исполнение reference на SBCL: **PASS**. [Протокол](../validation/implementation_execution.json) содержит тесты и hashes проверенных файлов. LMX: **NOT_RUN**, текущий интегрированный исполняемый движок в этом пакете отсутствует. Совпадение текста с ядром и замыкание зависимостей проверяются отдельно; это не заменяет исполнение.

## Происхождение LMX

- `FxSeqReplaceRange` — [patterns/LMX_Fn_Receivers/src/sequences_mutation.lmx](../../../LMX_Fn_Receivers/src/sequences_mutation.lmx), SHA-256 `e7c1587a6366b20dc32c9ab1331da3f58d6fe164c1338c304c287133474d23e6`.

## Первичные источники Common Lisp

- [https://www.lispworks.com/documentation/HyperSpec/Body/f_replac.htm](https://www.lispworks.com/documentation/HyperSpec/Body/f_replac.htm)
- [https://www.lispworks.com/documentation/HyperSpec/Body/f_adjust.htm](https://www.lispworks.com/documentation/HyperSpec/Body/f_adjust.htm)
- [https://www.lispworks.com/documentation/HyperSpec/Body/f_mk_ar.htm](https://www.lispworks.com/documentation/HyperSpec/Body/f_mk_ar.htm)
