use strict;
use warnings;
sub example {
    my ($items) = @_;
    my (%count, @order);
    for (@$items) {
        push @order, $_ unless exists $count{$_};
        ++$count{$_};
    }
    return [map { [0 + $_, $count{$_}] } @order];
}
