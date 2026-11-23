package PerlComparison::Patterns;
use strict;
use warnings;
sub text {
    my ($source) = @_;
    defined($source) && !ref($source) or die "PatternEncoding\n";
    for my $character (CORE::split //, $source) {
        ord($character) <= 255 or die "PatternEncoding\n";
    }
    return "$source";
}
sub literal {
    return quotemeta(text($_[0]));
}
sub sequence {
    my ($parts) = @_;
    ref($parts) eq 'ARRAY' or die "PatternArgument\n";
    my $source = '';
    for my $part (@$parts) {
        defined($part) && !ref($part) or die "PatternArgument\n";
        $source .= "(?:$part)";
    }
    return $source;
}
sub name {
    my ($name) = @_;
    defined($name) && !ref($name) && $name =~ /\A[A-Za-z_][A-Za-z0-9_]*\z/
        or die "PatternArgument\n";
    return $name;
}
sub capture {
    my ($name, $pattern) = @_;
    $name = name($name);
    defined($pattern) && !ref($pattern) or die "PatternArgument\n";
    return "(?<$name>$pattern)";
}
sub same_as {
    my $name = name($_[0]);
    return "\\k<$name>";
}
sub repeated {
    my ($pattern, $minimum, $maximum, $extend_first) = @_;
    $minimum = 0 unless defined $minimum;
    $extend_first = 1 unless defined $extend_first;
    defined($pattern) && !ref($pattern) or die "PatternArgument\n";
    !ref($minimum) && $minimum =~ /\A[0-9]+\z/ or die "PatternArgument\n";
    if (defined $maximum) {
        !ref($maximum) && $maximum =~ /\A[0-9]+\z/ && $maximum >= $minimum
            or die "PatternArgument\n";
    }
    !ref($extend_first) && $extend_first =~ /\A[01]\z/
        or die "PatternArgument\n";
    return '' if $pattern eq '';
    my $bound = defined($maximum) ? "$minimum,$maximum" : "$minimum,";
    return "(?:$pattern){$bound}" . ($extend_first ? '' : '?');
}
sub then_pattern {
    @_ >= 2 or die "PatternArgument\n";
    return sequence([@_]);
}
sub times {
    my ($pattern, $count) = @_;
    defined($count) or die "PatternArgument\n";
    return repeated($pattern, $count, $count, 1);
}
sub at_least {
    my ($pattern, $minimum) = @_;
    defined($minimum) or die "PatternArgument\n";
    return repeated($pattern, $minimum, undef, 1);
}
sub at_most {
    my ($pattern, $maximum) = @_;
    defined($maximum) or die "PatternArgument\n";
    return repeated($pattern, 0, $maximum, 1);
}
sub optional {
    return repeated($_[0], 0, 1, 1);
}
sub compiled {
    my ($pattern, $whole) = @_;
    defined($pattern) && !ref($pattern) or die "PatternArgument\n";
    my $ready = $whole ? "\\A(?:$pattern)\\z" : "(?:$pattern)";
    my $regex = eval { qr/$ready/ };
    die "PatternArgument: $@" if $@;
    return $regex;
}
sub snapshot {
    my ($source) = @_;
    return {source => $source, begin => $-[0], end => $+[0], captures => {%+}};
}
sub checked_match {
    my ($match) = @_;
    ref($match) eq 'HASH' && ref($match->{captures}) eq 'HASH'
        or die "MatchType\n";
    defined($match->{source}) && !ref($match->{source}) or die "MatchType\n";
    for my $key ('begin', 'end') {
        defined($match->{$key}) && !ref($match->{$key}) && $match->{$key} =~ /\A[0-9]+\z/
            or die "PatternPosition\n";
    }
    $match->{begin} <= $match->{end} && $match->{end} <= length($match->{source})
        or die "PatternPosition\n";
    return $match;
}
sub whole_match {
    my ($source, $pattern) = @_;
    $source = text($source);
    my $regex = compiled($pattern, 1);
    return [0, undef] unless $source =~ /$regex/;
    return [1, snapshot($source)];
}
sub matches {
    return whole_match(@_)->[0];
}
sub each_match {
    my ($source, $pattern) = @_;
    $source = text($source);
    my $regex = compiled($pattern, 0);
    my $finished = 0;
    pos($source) = 0;
    return sub {
        return undef if $finished;
        if ($source =~ /$regex/gc) {
            return snapshot($source);
        }
        $finished = 1;
        return undef;
    };
}
sub matched_text {
    my $match = checked_match($_[0]);
    return substr($match->{source}, $match->{begin}, $match->{end} - $match->{begin});
}
sub capture_text {
    my ($match, $name) = @_;
    checked_match($match);
    $name = name($name);
    return [0, undef] unless exists $match->{captures}{$name};
    return [1, $match->{captures}{$name}];
}
sub replace_all {
    my ($source, $pattern, $replacement) = @_;
    $source = text($source);
    my $callback = ref($replacement) eq 'CODE';
    $replacement = text($replacement) unless $callback;
    my $next = each_match($source, $pattern);
    my ($out, $copied_until) = ('', 0);
    while (my $match = $next->()) {
        $out .= substr($source, $copied_until, $match->{begin} - $copied_until);
        my $insert = $callback ? text($replacement->($match)) : $replacement;
        $out .= $insert;
        $copied_until = $match->{end};
    }
    return $out . substr($source, $copied_until);
}
sub split_parts {
    my ($source, $pattern) = @_;
    $source = text($source);
    my $next = each_match($source, $pattern);
    my @out;
    my $copied_until = 0;
    while (my $match = $next->()) {
        push @out, substr($source, $copied_until, $match->{begin} - $copied_until);
        $copied_until = $match->{end};
    }
    push @out, substr($source, $copied_until);
    return \@out;
}
1;
