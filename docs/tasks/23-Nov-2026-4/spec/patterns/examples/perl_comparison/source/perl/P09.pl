use strict;
use warnings;
use List::Util qw(uniq);
sub example {
    my ($items) = @_;
    return [uniq @$items];
}
