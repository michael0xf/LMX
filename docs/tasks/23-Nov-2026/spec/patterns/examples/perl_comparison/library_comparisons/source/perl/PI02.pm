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
