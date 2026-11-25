use strict;
use warnings;
sub example {
    my ($text, $needle, $replacement) = @_;
    my $out = $text;
    my $changed = $out =~ s/(?:\Q$needle\E)/$replacement/g;
    return [$out, 0 + $changed];
}
