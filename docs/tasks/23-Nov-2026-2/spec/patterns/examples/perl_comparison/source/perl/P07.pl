use strict;
use warnings;
sub example {
    my ($items, $begin, $end, $values) = @_;
    my @removed = splice @$items, $begin, $end - $begin, @$values;
    return [$items, \@removed];
}
