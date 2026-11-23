package PerlComparison::Records;
use strict;
use warnings;
use Scalar::Util qw(refaddr reftype blessed);
sub clone_data {
    my ($value, $seen) = @_;
    return $value unless ref $value;
    blessed($value) and die "MergeType\n";
    my $address = refaddr($value);
    return $seen->{$address} if exists $seen->{$address};
    my $kind = reftype($value);
    if ($kind eq 'HASH') {
        my $out = {};
        $seen->{$address} = $out;
        for my $key (keys %$value) { $out->{$key} = clone_data($value->{$key}, $seen) }
        return $out;
    }
    if ($kind eq 'ARRAY') {
        my $out = [];
        $seen->{$address} = $out;
        for my $item (@$value) { push @$out, clone_data($item, $seen) }
        return $out;
    }
    if ($kind eq 'SCALAR' || $kind eq 'REF') {
        my $target;
        my $out = \$target;
        $seen->{$address} = $out;
        $target = clone_data($$value, $seen);
        return $out;
    }
    die "MergeType\n";
}
sub derive_record {
    my ($base, $extension) = @_;
    ref($base) eq 'HASH' && ref($extension) eq 'HASH' or die "MergeType\n";
    my %seen;
    my $model = clone_data($base, \%seen);
    my $extra = clone_data($extension, \%seen);
    for my $key (keys %$extra) { $model->{$key} = $extra->{$key} }
    my %group;
    for my $key (keys %$model) { $group{$key} = $model->{$key} }
    return \%group;
}
1;
