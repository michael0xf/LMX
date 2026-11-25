use strict;
use warnings;
sub example {
    my ($text) = @_;
    return scalar reverse($text =~ tr/ACGT/TGCA/r);
}
