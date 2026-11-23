package PerlComparison::Resources;
use strict;
use warnings;
sub bracket {
    my ($acquire, $release, $action, @arguments) = @_;
    ref($acquire) eq 'CODE' && ref($release) eq 'CODE' && ref($action) eq 'CODE'
        or die "CallableType\n";
    my ($ready, $resource, $value) = (0);
    my $ok = eval {
        $resource = $acquire->();
        $ready = 1;
        $value = $action->($resource, @arguments);
        1;
    };
    my $failure = $@;
    if ($ready) {
        my $released = eval { $release->($resource); 1 };
        if (!$released) { $failure = $@; $ok = 0 }
    }
    die $failure unless $ok;
    return $value;
}
1;
