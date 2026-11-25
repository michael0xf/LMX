use strict;
use warnings;
use List::Util qw(sum0);
sub example {
    my ($items) = @_;
    my @calibrated = map { $_ * 3 } @$items;
    return [\@calibrated, sum0(@calibrated)];
}
