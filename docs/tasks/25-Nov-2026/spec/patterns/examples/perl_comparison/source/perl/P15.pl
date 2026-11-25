use strict;
use warnings;
sub example {
    my ($items) = @_;
    my @accepted = grep { /\A[A-Za-z][A-Za-z0-9_]*\z/ } @$items;
    return [\@accepted, scalar(@$items) - scalar(@accepted)];
}
