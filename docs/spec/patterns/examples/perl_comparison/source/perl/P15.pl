use strict;
use warnings;
sub example {
    my ($text) = @_;
    return 0 + ($text =~ /\A[A-Za-z][A-Za-z0-9_]*\z/);
}
