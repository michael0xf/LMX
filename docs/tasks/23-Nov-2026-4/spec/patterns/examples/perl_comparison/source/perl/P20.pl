use strict;
use warnings;
sub example {
    my ($text) = @_;
    return 0 + ($text =~ /\A(?<word>[A-Za-z]+) \k<word>\z/);
}
