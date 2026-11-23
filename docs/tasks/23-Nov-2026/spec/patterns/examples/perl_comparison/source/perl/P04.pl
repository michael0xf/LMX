use strict;
use warnings;
use List::Util qw(reductions);
sub example {
    my ($deltas, $initial) = @_;
    return [reductions { $a + $b } $initial, @$deltas];
}
