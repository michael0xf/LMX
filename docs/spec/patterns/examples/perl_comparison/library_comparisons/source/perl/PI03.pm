package PerlComparison::Ordering;
use strict;
use warnings;
sub arguments {
    my ($items, $operation) = @_;
    ref($items) eq 'ARRAY' or die "SequenceType\n";
    ref($operation) eq 'CODE' or die "CallableType\n";
}
sub integer {
    my ($value) = @_;
    defined($value) && !ref($value) && $value =~ /\A-?[0-9]+\z/
        or die "ComparisonType\n";
    return 0 + $value;
}
sub stable_sort {
    my ($items, $compare) = @_;
    arguments($items, $compare);
    my $current = [@$items];
    my $count = @$current;
    my $scratch = [];
    my $width = 1;
    while ($width < $count) {
        my $start = 0;
        while ($start < $count) {
            my $middle = $width < $count - $start ? $start + $width : $count;
            my $end = $width < $count - $middle ? $middle + $width : $count;
            my ($left, $right, $at) = ($start, $middle, $start);
            while ($at < $end) {
                my $take_left = $right == $end;
                if (!$take_left && $left < $middle) {
                    my $order = integer($compare->($current->[$left], $current->[$right]));
                    $take_left = $order <= 0;
                }
                $scratch->[$at++] = $take_left ? $current->[$left++] : $current->[$right++];
            }
            $start = $end;
        }
        ($current, $scratch) = ($scratch, $current);
        $width = $width > $count - $width ? $count : $width + $width;
    }
    return $current;
}
sub stable_unique {
    my ($items, $same) = @_;
    arguments($items, $same);
    my @out;
    ITEM: for my $item (@$items) {
        for my $previous (@out) {
            next ITEM if integer($same->($previous, $item)) != 0;
        }
        push @out, $item;
    }
    return \@out;
}
1;
