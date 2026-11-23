use strict;
use warnings;
sub example {
    my ($text) = @_;
    return [$text =~ /[A-Za-z]+/g];
}
