use strict;
use warnings;
sub example {
    my ($items) = @_;
    return [map { $_ * 3 } @$items];
}
