use strict;
use warnings;
sub example {
    my ($base, $patch) = @_;
    return {%$base, %$patch};
}
