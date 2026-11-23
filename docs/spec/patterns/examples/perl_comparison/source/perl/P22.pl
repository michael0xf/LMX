use strict;
use warnings;
sub make_counter {
    my ($value) = @_;
    return sub { $value += shift };
}
sub example {
    my ($initial) = @_;
    my $first = make_counter($initial);
    my $second = make_counter(100);
    return [$first->(1), $first->(3), $second->(2), $first->(-2)];
}
