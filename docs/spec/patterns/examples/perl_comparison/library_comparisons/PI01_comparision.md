# PI01. Общие последовательные коллекции

Полные последовательные алгоритмы для произвольных значений: map, filter, fold с seed, scan с начальным seed, короткие any/all, раскрытие ровно одного уровня bind. Порядок вызовов сохранён. Пустые входы, произвольные ссылки и результаты, ошибки callbacks входят в договор.

Это отдельное сравнение реализации. Клиенты Perl **не импортируют** этот модуль: они используют настоящий CORE/List::Util. LMX вызывает предлагаемое ядро.

## Граница реализации

Общий нижний уровень — доступ к массиву и обычный вызов callback. На стороне LMX это уже имеющиеся FxSeq*/FxApply, на стороне Perl — массивы, push и вызов coderef. Сами map/grep/List::Util в сравнительной реализации не вызываются. FxListBind и публичные алиасы foldl/scanl только перенаправляют на показанные алгоритмы.

## Размер

| Полный исходник | Непробельные символы | Все Unicode-символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX | 2960 | 4587 | 146 |
| Perl | <span style="color:#176233"><u>1387</u></span> | 1937 | 85 |

## LMX

[Исходник](source/lmx/PI01.lmx). Корни извлекаются из канонических модулей; SHA-256 фиксируется в examples.json.

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
        private: @: result FxSeqAllocate\make([]@; count)
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

FxScan:
    private:
        @: items
        @: seed
        @: step
    required: items seed step
    return: @
    scan:
        throws: copy(FxThrows\traversal)
        FxSeqInfo\get(items)
        private: int: count length(items)
        private: @: result FxSeqAllocate\make([]@; 0)
        private: @: info FxSeqInfo\get(result)
        private: int: total FxSeqSize\sum(count; 1; info\maxLength)
        sys\resize(result; total)
        private: @: accumulator seed
        result[0] := accumulator
        private: int: i 0
        while: i < count
            private: @: item FxSeqRead\read(items; i)
            accumulator := FxApply\apply(step; FxTwo\make(accumulator; item))
            result[i + 1] := accumulator
            i += 1
        return: result

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

FxSeqBind:
    private:
        @: items
        @: next
    required: items next
    return: @
    bind:
        throws: copy(FxThrows\traversal)
        FxSeqInfo\get(items)
        private: int: count length(items)
        private: @: out FxSeqAllocate\make([]@; 0)
        private: @: info FxSeqInfo\get(out)
        private: int: i 0
        while: i < count
            private: @: item FxSeqRead\read(items; i)
            private: @: part FxApply\apply(next; FxOne\make(item))
            FxSeqInfo\get(part)
            private: int: before length(out)
            private: int: added length(part)
            private: int: after FxSeqSize\sum(before; added; info\maxLength)
            sys\resize(out; after)
            private: int: j 0
            while: j < added
                out[before + j] := FxSeqRead\read(part; j)
                j += 1
            i += 1
        return: out
```

## Perl

[Исходник](source/perl/PI01.pm).

```perl
package PerlComparison::Sequences;
use strict;
use warnings;
sub array {
    ref($_[0]) eq 'ARRAY' or die "SequenceType\n";
    return $_[0];
}
sub callable {
    ref($_[0]) eq 'CODE' or die "CallableType\n";
    return $_[0];
}
sub truth {
    my ($value) = @_;
    defined($value) && !ref($value) && $value =~ /\A-?[0-9]+\z/
        or die "PredicateType\n";
    return $value != 0;
}
sub map_values {
    my ($items, $transform) = @_;
    array($items); callable($transform);
    my @out;
    for my $item (@$items) {
        my $value = $transform->($item);
        push @out, $value;
    }
    return \@out;
}
sub filter_values {
    my ($items, $accepts) = @_;
    array($items); callable($accepts);
    my @out;
    for my $item (@$items) {
        push @out, $item if truth($accepts->($item));
    }
    return \@out;
}
sub fold_values {
    my ($items, $seed, $step) = @_;
    array($items); callable($step);
    my $value = $seed;
    for my $item (@$items) {
        $value = $step->($value, $item);
    }
    return $value;
}
sub scan_values {
    my ($items, $seed, $step) = @_;
    array($items); callable($step);
    my $value = $seed;
    my @out = ($seed);
    for my $item (@$items) {
        $value = $step->($value, $item);
        push @out, $value;
    }
    return \@out;
}
sub any_value {
    my ($items, $accepts) = @_;
    array($items); callable($accepts);
    for my $item (@$items) {
        return 1 if truth($accepts->($item));
    }
    return 0;
}
sub all_values {
    my ($items, $accepts) = @_;
    array($items); callable($accepts);
    for my $item (@$items) {
        return 0 unless truth($accepts->($item));
    }
    return 1;
}
sub flat_map {
    my ($items, $next) = @_;
    array($items); callable($next);
    my @out;
    for my $item (@$items) {
        my $part = array($next->($item));
        for my $value (@$part) {
            push @out, $value;
        }
    }
    return \@out;
}
1;
```

## Проверка и ограничения

Callbacks не меняют слоты или длину входа. Неудача прекращает обход и не публикует частичный результат; внешние эффекты callback не откатываются. Perl не имеет метки LMX int, поэтому predicate-admission принимает числовой скаляр с целой записью; сравнение не утверждает тождество низкоуровневых типов VM. Ошибки Perl распространяются обычным die, LMX — конечным FxCallFailure.

Запуск Perl: [отчёт](../validation/implementation_tests.json). LMX: **NOT_RUN**; проверка текста не подменяет запуск.

## Первичные источники

- <https://perldoc.perl.org/5.40.1/functions/map>
- <https://perldoc.perl.org/5.40.1/functions/grep>
- <https://perldoc.perl.org/5.40.1/List::Util>
- <https://perldoc.perl.org/5.40.1/perlref>
