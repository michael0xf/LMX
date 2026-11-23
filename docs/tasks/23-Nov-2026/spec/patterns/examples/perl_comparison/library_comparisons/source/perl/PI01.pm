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
