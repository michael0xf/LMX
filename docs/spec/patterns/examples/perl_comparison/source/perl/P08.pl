use strict;
use warnings;
use sort 'stable';
sub example {
    my ($items) = @_;
    return [sort { $a->{priority} <=> $b->{priority} } @$items];
}
