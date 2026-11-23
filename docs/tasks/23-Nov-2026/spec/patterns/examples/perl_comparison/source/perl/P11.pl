use strict;
use warnings;
sub example {
    my ($items) = @_;
    my (%groups, @order);
    for my $event (@$items) {
        my $key = $event->{kind};
        push @order, $key unless exists $groups{$key};
        push @{$groups{$key}}, $event;
    }
    return [map { [0 + $_, $groups{$_}] } @order];
}
