use strict;
use warnings;
use List::Util qw(sum0);
sub example {
    my ($items, $initial) = @_;
    my $balance = $initial + sum0(@$items);
    return [$balance, 0 + ($balance < 0)];
}
