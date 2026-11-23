use strict;
use warnings;
use JSON::PP;
my $request=decode_json(do { local $/; <STDIN> });
open my $source, '<', $request->{file} or die "$request->{file}: $!";
my $code=do { local $/; <$source> };
close $source;
my $compiled=eval "package PerlComparisonClient;\n$code\n1;";
die $@ unless $compiled;
my $json=JSON::PP->new->canonical;
my @results;
for my $case (@{$request->{cases}}) {
    my $args=$case->{args};
    my $before=$json->encode($args);
    my $result;
    my $history='ab';
    $history =~ /b/ if $case->{prime_empty_pattern};
    my $ok=eval { $result=PerlComparisonClient::example(@$args); 1 };
    my $failure=$@;
    push @results, {
        ok=>$ok ? JSON::PP::true : JSON::PP::false,
        result=>$result,error=>$ok ? '' : "$failure",
        input_unchanged=>$before eq $json->encode($args) ? JSON::PP::true : JSON::PP::false
    };
}
print $json->encode(\@results);
