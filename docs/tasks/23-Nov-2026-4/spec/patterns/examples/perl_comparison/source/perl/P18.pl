use strict;
use warnings;
sub example {
    my ($text, $needle, $replacement) = @_;
    return $text =~ s/(?:\Q$needle\E)/$replacement/gr;
}
