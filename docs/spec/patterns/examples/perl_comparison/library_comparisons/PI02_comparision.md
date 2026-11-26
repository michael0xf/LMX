# PI02. Срез и изменение диапазона

Нулевые индексы, полуоткрытые диапазоны, повторы в select, пустое удаление/вставка. select создаёт новый внешний массив. splice сохраняет идентичность target и возвращает удалённые элементы. Если values совпадает с target, вставляемые значения снимаются до изменения.

Это отдельное сравнение реализации. Клиенты Perl **не импортируют** этот модуль: они используют настоящий CORE/List::Util. LMX вызывает предлагаемое ядро.

## Граница реализации

Показаны проверка всех индексов, снимок вставки и commit; сравнительная Perl-реализация не вызывает штатный splice. Runtime обеспечивает расширение памяти и обычный тип элементов; LMX сохраняет полный профиль dense/[]@ и проверяет допуск до commit.

## Размер

| Полный исходник | Непробельные символы | Все Unicode-символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX | 3713 | 5483 | 144 |
| Perl | <span style="color:#176233"><u>1168</u></span> | 1532 | 50 |

## LMX

[Исходник](source/lmx/PI02.lmx). Корни извлекаются из канонических модулей; SHA-256 фиксируется в examples.json.

```lmx
FxSeqIndices:
    private:
        @: source
        @: indices
    required: source indices
    return: @
    check:
        throws: copy(FxThrows\sequence)
        FxSeqInfo\get(source)
        FxSeqInfo\get(indices)
        private: int: total length(source)
        private: int: count length(indices)
        private: @: checked FxSeqAllocate\make([]int; count)
        private: int: i 0
        while: i < count
            private: @: value FxSeqRead\read(indices; i)
            private: int: at \value
            if: at < 0 || at >= total
                throw: ReceiverIndex()
            checked[i] := at
            i += 1
        return: checked

FxSeqSelection:
    private:
        @: source
        []int: positions
    required: source positions
    return: @
    copySelected:
        throws: copy(FxThrows\sequence)
        private: @: info FxSeqInfo\get(source)
        private: int: count length(positions)
        private: @: out FxSeqAllocate\make(info\arrayType; count)
        private: int: i 0
        while: i < count
            private: @: value FxSeqRead\read(source; positions[i])
            FxKernel\arrayWrite(target := out; index := i; value := value)
            i += 1
        return: out

FxSeqSelect:
    private:
        @: source
        @: indices
    required: source indices
    return: @
    select:
        throws: copy(FxThrows\sequence)
        private: @: positions FxSeqIndices\check(source; indices)
        return: FxSeqSelection\copySelected(source; positions)

FxSeqSlice:
    private:
        @: source
        int: begin
        int: end
    required: source begin end
    return: @
    slice:
        throws: copy(FxThrows\sequence)
        private: int: count FxSeqBounds\count(source; begin; end)
        private: @: info FxSeqInfo\get(source)
        private: @: out FxSeqAllocate\make(info\arrayType; count)
        private: int: i 0
        while: i < count
            private: @: value FxSeqRead\read(source; begin + i)
            FxKernel\arrayWrite(target := out; index := i; value := value)
            i += 1
        return: out

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
        # Dense preparation keeps dense T storage; []@ keeps direct references.
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

FxSeqSplice:
    private:
        @: target
        int: begin
        int: end
        @: values
    required: target begin end values
    return: @
    splice:
        throws: copy(FxThrows\mutation)
        # Snapshot the removed range before reserve, resize, or any target
        # write. Slice preserves the complete physical element profile and
        # copies outer slots only: referenced targets remain shared.
        private: @: removed FxSeqSlice\slice(target; begin; end)
        # The common replacement path prepares all inserted values before
        # commit, including values = target and other overlapping sources.
        # Failure during preparation leaves target's contents unchanged.
        FxSeqReplaceRange\replaceRange(target; begin; end; values)
        return: removed
```

## Perl

[Исходник](source/perl/PI02.pm).

```perl
package PerlComparison::Ranges;
use strict;
use warnings;
sub array {
    ref($_[0]) eq 'ARRAY' or die "SequenceType\n";
    return $_[0];
}
sub checked_index {
    my ($value) = @_;
    defined($value) && !ref($value) && $value =~ /\A[0-9]+\z/
        or die "ReceiverIndex\n";
    return 0 + $value;
}
sub select_values {
    my ($source, $indices) = @_;
    array($source); array($indices);
    my @checked;
    for my $value (@$indices) {
        my $at = checked_index($value);
        $at < @$source or die "ReceiverIndex\n";
        push @checked, $at;
    }
    my @out;
    push @out, $source->[$_] for @checked;
    return \@out;
}
sub replace_range {
    my ($target, $begin, $end, $values) = @_;
    array($target); array($values);
    $begin = checked_index($begin); $end = checked_index($end);
    $begin <= $end && $end <= @$target or die "ReceiverIndex\n";
    my @staged = @$values;
    my @ready;
    for (my $i = 0; $i < $begin; ++$i) { push @ready, $target->[$i] }
    push @ready, @staged;
    for (my $i = $end; $i < @$target; ++$i) { push @ready, $target->[$i] }
    @$target = @ready;
    return $target;
}
sub splice_values {
    my ($target, $begin, $end, $values) = @_;
    array($target); array($values);
    $begin = checked_index($begin); $end = checked_index($end);
    $begin <= $end && $end <= @$target or die "ReceiverIndex\n";
    my @removed;
    for (my $i = $begin; $i < $end; ++$i) { push @removed, $target->[$i] }
    replace_range($target, $begin, $end, $values);
    return \@removed;
}
1;
```

## Проверка и ограничения

Проверки диапазона и staging заканчиваются до первой записи в target. Сбой подготовки не меняет target; необратимые отказы процесса/аллокатора во время commit не объявлены транзакционно откатываемыми. Perl не имеет профиля dense []T, поэтому сохраняется свой родной ARRAY и тождество его ссылочных элементов.

Запуск Perl: [отчёт](../validation/implementation_tests.json). LMX: **NOT_RUN**; проверка текста не подменяет запуск.

## Первичные источники

- <https://perldoc.perl.org/5.40.1/functions/splice>
- <https://perldoc.perl.org/5.40.1/perldata#Slices>
- <https://perldoc.perl.org/5.40.1/perlref>
