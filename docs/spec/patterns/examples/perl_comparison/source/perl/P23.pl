use strict;
use warnings;
sub squares {
    my ($limit) = @_;
    my $i = 0;
    return sub { return undef if $i >= $limit; my $n = $i++; return $n * $n };
}
sub example {
    my ($limit) = @_;
    my $next = squares($limit);
    my @result;
    while (defined(my $value = $next->())) {
        push @result, $value;
    }
    return \@result;
}
