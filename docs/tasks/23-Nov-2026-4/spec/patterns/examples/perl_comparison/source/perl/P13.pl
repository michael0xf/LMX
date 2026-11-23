use strict;
use warnings;
sub example {
    my ($rows) = @_;
    return [map { @$_ } @$rows];
}
