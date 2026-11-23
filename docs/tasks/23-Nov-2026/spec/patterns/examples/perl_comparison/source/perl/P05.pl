use strict;
use warnings;
use List::Util qw(any all);
sub example {
    my ($items) = @_;
    return [0 + (any { $_ < 0 } @$items), 0 + (all { $_ < 10 } @$items)];
}
