use strict;
use warnings;
sub example {
    my ($text, $columns) = @_;
    my @fields = length($text) ? split(/,/, $text, -1) : ('');
    return [\@fields, 0 + (@fields == $columns), scalar grep { $_ eq '' } @fields];
}
