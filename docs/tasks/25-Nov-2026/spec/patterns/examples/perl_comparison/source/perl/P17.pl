use strict;
use warnings;
sub example {
    my ($text, $minimum) = @_;
    my @words = $text =~ /[A-Za-z]+/g;
    my @selected = grep { length($_) >= $minimum } @words;
    return [\@selected, scalar(@words) - scalar(@selected)];
}
