use strict;
use warnings;
sub example {
    my ($lines) = @_;
    my @repaired = map { /\A([A-Za-z]+) \1\z/ ? ($1) : () } @$lines;
    return [\@repaired, scalar(@$lines) - scalar(@repaired)];
}
