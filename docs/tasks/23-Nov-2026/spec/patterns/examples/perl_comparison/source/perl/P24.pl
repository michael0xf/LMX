use strict;
use warnings;
use feature 'defer';
no warnings 'experimental::defer';
sub example {
    my ($mode) = @_;
    my ($events, $value) = (0, 0);
    eval {
        $events = $events * 10 + 1;
        die "ResourceFailure\n" if $mode == 2;
        my $resource = {value => 42, width => 8};
        defer { $events = $events * 10 + 3 }
        $events = $events * 10 + 2;
        die "ResourceFailure\n" if $mode == 1;
        $value = $resource->{value} + $resource->{width};
    };
    return [$value, $events];
}
