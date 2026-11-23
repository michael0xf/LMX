use strict;
use warnings;
use List::Util qw(sum0);
sub example {
    my ($items) = @_;
    return sum0(@$items);
}
