use strict;
use warnings;
sub example {
    my ($items) = @_;
    return [grep { $_ % 2 == 0 } @$items];
}
