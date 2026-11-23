use strict;
use warnings;
sub example {
    my ($text) = @_;
    return $text =~ tr/ACGT/TGCA/r;
}
