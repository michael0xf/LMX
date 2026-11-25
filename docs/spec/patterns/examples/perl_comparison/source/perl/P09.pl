use strict;
use warnings;
use List::Util qw(uniqnum);
sub example {
    my ($items) = @_;
    my @selected = uniqnum(@$items);
    return [\@selected, scalar(@$items) - scalar(@selected)];
}
