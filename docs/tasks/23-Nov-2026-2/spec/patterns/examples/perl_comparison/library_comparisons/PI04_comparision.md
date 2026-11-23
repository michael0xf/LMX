# PI04. Группировка с произвольным ключом

Ключи и элементы произвольны, включая структуры/ссылки. keyOf вызывается один раз на элемент. sameKey сравнивает с ключами уже созданных групп по порядку. Сохраняются порядок первых ключей, порядок элементов и полные значения/ссылки. Пустой вход возвращает пустой массив.

Это отдельное сравнение реализации. Клиенты Perl **не импортируют** этот модуль: они используют настоящий CORE/List::Util. LMX вызывает предлагаемое ядро.

## Граница реализации

Обе реализации используют список групп и явное равенство; они не принуждают пользовательский ключ к строке. Для клиентских целых ключей Perl вправе использовать свою настоящую хеш-таблицу и автоматическое создание массива.

## Размер

| Источник | Все символы | Без пробельных | Без сложного Throws | Непустые строки |
|---|---:|---:|---:|---:|
| LMX | 1284 | 782 | 716 | 37 |
| Perl | 827 | 568 | 568 | 26 |

Дополнительная колонка исключает только аргументы Throws после первого. Заголовок, первый аргумент и ссылки copy(Throws) сохраняются; исходник не изменяется.

## LMX

[Исходник](source/lmx/PI04.lmx). Корни извлекаются из канонических модулей; SHA-256 фиксируется в examples.json.

```lmx
FxGroup:
    @: key 0
    @: items 0

FxGroupBy:
    private:
        @: items
        @: keyOf
        @: sameKey
    required: items keyOf sameKey
    return: @
    groupBy:
        throws: FxCallFailure FxKernelFailure FxTypeToken ReceiverIndex SequenceElement SequenceSize
        FxSeqInfo\get(items)
        private: int: count length(items)
        private: @: result FxSeqAllocate\make(@[]; 0)
        private: int: i 0
        while: i < count
            private: @: item FxSeqRead\read(items; i)
            private: @: key FxApply\apply(keyOf; FxOne\make(item))
            private: @: group 0
            private: int: j 0
            while: j < length(result)
                private: FxGroup@: candidate result[j]
                private: @: flagRecord FxApply\apply(sameKey; FxTwo\make(candidate\key; key))
                private: int: flag \flagRecord
                if: flag != 0
                    group := candidate
                    break
                j += 1
            if: group = 0
                group := (copy(FxGroup))
                group\key := key
                group\items := FxSeqAllocate\make(@[]; 0)
                FxSeqPush\append(result; group)
            FxSeqPush\append(group\items; item)
            i += 1
        return: result
```

## Perl

[Исходник](source/perl/PI04.pm).

```perl
package PerlComparison::Groups;
use strict;
use warnings;
sub group_by {
    my ($items, $key_of, $same_key) = @_;
    ref($items) eq 'ARRAY' or die "SequenceType\n";
    ref($key_of) eq 'CODE' && ref($same_key) eq 'CODE' or die "CallableType\n";
    my @groups;
    for my $item (@$items) {
        my $key = $key_of->($item);
        my $selected;
        for my $group (@groups) {
            my $same = $same_key->($group->{key}, $key);
            defined($same) && !ref($same) && $same =~ /\A-?[0-9]+\z/
                or die "PredicateType\n";
            if ($same != 0) { $selected = $group; last }
        }
        if (!defined $selected) {
            $selected = {key => $key, items => []};
            push @groups, $selected;
        }
        push @{$selected->{items}}, $item;
    }
    return \@groups;
}
1;
```

## Проверка и ограничения

Здесь нет обещания O(n) для произвольного пользовательского sameKey: худший случай квадратичен. Callback не меняет вход; его отказ прекращает операцию и не публикует частичные группы. Нули, пустые ключи и составные ключи не служат sentinel.

Запуск Perl: [отчёт](../validation/implementation_tests.json). LMX: **NOT_RUN**; проверка текста не подменяет запуск.

## Первичные источники

- <https://perldoc.perl.org/5.40.1/perldsc#HASHES-OF-ARRAYS>
- <https://perldoc.perl.org/5.40.1/perlref>
