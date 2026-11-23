# PI05. Композиция записей и копирование data-графа

Новый результат по модели base с заменой одноимённых совместимых полей extension. Дополнительная Perl-реализация показывает общий map копирования data-графа: вложенные HASH/ARRAY/SCALAR-ссылки, разделяемые цели и циклы поддержаны, вход не меняется. В клиенте P12 требуется только плоская запись настроек; там штатный хеш Perl достаточно точно реализует задачу.

Это отдельное сравнение реализации. Клиенты Perl **не импортируют** этот модуль: они используют настоящий CORE/List::Util. LMX вызывает предлагаемое ядро.

## Граница реализации

LMX derive вызывает базовую операцию языка merge: весь графовый копировщик уже входит в язык. Perl-реализация самостоятельно копирует data-граф одним refaddr-map и накладывает поля. Контейнер результата отделён от копии модели; внутренние ссылки остаются связаны с общей картой копирования.

## Размер

| Полный исходник | Непробельные символы | Все Unicode-символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX | 71 | 106 | 6 |
| Perl | 1002 | 1370 | 44 |

## LMX

[Исходник](source/lmx/PI05.lmx). Корни извлекаются из канонических модулей; SHA-256 фиксируется в examples.json.

```lmx
RxDerive:
    @: base
    @: extension
    return: @
    derive:
        return: (merge(base; extension))
```

## Perl

[Исходник](source/perl/PI05.pm).

```perl
package PerlComparison::Records;
use strict;
use warnings;
use Scalar::Util qw(refaddr reftype blessed);
sub clone_data {
    my ($value, $seen) = @_;
    return $value unless ref $value;
    blessed($value) and die "MergeType\n";
    my $address = refaddr($value);
    return $seen->{$address} if exists $seen->{$address};
    my $kind = reftype($value);
    if ($kind eq 'HASH') {
        my $out = {};
        $seen->{$address} = $out;
        for my $key (keys %$value) { $out->{$key} = clone_data($value->{$key}, $seen) }
        return $out;
    }
    if ($kind eq 'ARRAY') {
        my $out = [];
        $seen->{$address} = $out;
        for my $item (@$value) { push @$out, clone_data($item, $seen) }
        return $out;
    }
    if ($kind eq 'SCALAR' || $kind eq 'REF') {
        my $target;
        my $out = \$target;
        $seen->{$address} = $out;
        $target = clone_data($$value, $seen);
        return $out;
    }
    die "MergeType\n";
}
sub derive_record {
    my ($base, $extension) = @_;
    ref($base) eq 'HASH' && ref($extension) eq 'HASH' or die "MergeType\n";
    my %seen;
    my $model = clone_data($base, \%seen);
    my $extra = clone_data($extension, \%seen);
    for my $key (keys %$extra) { $model->{$key} = $extra->{$key} }
    my %group;
    for my $key (keys %$model) { $group{$key} = $model->{$key} }
    return \%group;
}
1;
```

## Проверка и ограничения

Сравнение data-профиля не переносит на Perl lexical parent, нативные реализации, protected/independent/immutable, типовую совместимость имён и порядок модельных индексов LMX. Неподдерживаемые host-объекты/код отвергаются MergeType, а не молча теряются. Полную семантику merge определяет LMX_semantics.en.md, раздел The common graph-copying map. Для P12 идентичность изменяемых вложенных графов не является обещанным результатом.

Запуск Perl: [отчёт](../validation/implementation_tests.json). LMX: **NOT_RUN**; проверка текста не подменяет запуск.

## Первичные источники

- <https://perldoc.perl.org/5.40.1/perlref>
- <https://perldoc.perl.org/5.40.1/perldata>
- <https://perldoc.perl.org/5.40.1/Scalar::Util#refaddr>
