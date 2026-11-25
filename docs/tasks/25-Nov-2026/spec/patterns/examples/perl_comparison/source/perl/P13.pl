use strict;
use warnings;
sub example {
    my ($rows) = @_;
    my @items = map { @$_ } @$rows;
    my @sizes = map { scalar @$_ } @$rows;
    return [\@items, \@sizes];
}
