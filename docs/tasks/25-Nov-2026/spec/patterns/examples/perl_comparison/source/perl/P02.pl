use strict;
use warnings;
use List::Util qw(sum0);
sub example {
    my ($items) = @_;
    my @accepted = grep { $_ >= 0 && $_ % 2 == 0 } @$items;
    return [\@accepted, sum0(@accepted)];
}
