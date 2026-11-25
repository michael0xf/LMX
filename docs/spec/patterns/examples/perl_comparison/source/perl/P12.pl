use strict;
use warnings;
sub example {
    my ($base, $patch) = @_;
    my $settings = {%$base, %$patch};
    return [$settings, $settings->{width} * $settings->{height}];
}
