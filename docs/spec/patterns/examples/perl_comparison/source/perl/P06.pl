use strict;
use warnings;
sub example {
    my ($items, $positions) = @_;
    return [@$items[@$positions]];
}
