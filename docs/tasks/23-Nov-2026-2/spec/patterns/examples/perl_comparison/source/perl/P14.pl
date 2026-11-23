use strict;
use warnings;
sub example {
    my ($text) = @_;
    return length($text) ? [split /,/, $text, -1] : [''];
}
