use strict;
use warnings;
sub example {
    my ($text) = @_;
    return $text =~ s/[0-9]+/'*' x length($&)/ger;
}
