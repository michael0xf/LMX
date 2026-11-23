use strict;
use warnings;
sub example {
    my ($text) = @_;
    return [0, '', ''] unless $text =~ /\A(?<key>[A-Za-z]+)=(?<value>[0-9]+)\z/;
    return [1, $+{key}, $+{value}];
}
