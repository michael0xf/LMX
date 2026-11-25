use strict;
use warnings;
sub example {
    my ($items, $labels, $positions) = @_;
    return [[@$items[@$positions]], [@$labels[@$positions]]];
}
