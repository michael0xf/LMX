package PerlComparison::Groups;
use strict;
use warnings;
sub group_by {
    my ($items, $key_of, $same_key) = @_;
    ref($items) eq 'ARRAY' or die "SequenceType\n";
    ref($key_of) eq 'CODE' && ref($same_key) eq 'CODE' or die "CallableType\n";
    my @groups;
    for my $item (@$items) {
        my $key = $key_of->($item);
        my $selected;
        for my $group (@groups) {
            my $same = $same_key->($group->{key}, $key);
            defined($same) && !ref($same) && $same =~ /\A-?[0-9]+\z/
                or die "PredicateType\n";
            if ($same != 0) { $selected = $group; last }
        }
        if (!defined $selected) {
            $selected = {key => $key, items => []};
            push @groups, $selected;
        }
        push @{$selected->{items}}, $item;
    }
    return \@groups;
}
1;
