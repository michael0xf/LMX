use strict;
use warnings;
use sort 'stable';
use List::Util qw(sum0);
sub example {
    my ($items, $limit) = @_;
    my @selected = sort { $a->{priority} <=> $b->{priority} } @$items;
    splice @selected, $limit if @selected > $limit;
    return [\@selected, sum0(map { $_->{width} } @selected)];
}
