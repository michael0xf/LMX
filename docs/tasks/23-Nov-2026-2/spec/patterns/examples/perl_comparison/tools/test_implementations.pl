use strict;
use warnings;
use FindBin;
use JSON::PP;
use Scalar::Util qw(refaddr);
use sort 'stable';

my $root="$FindBin::Bin/..";
for my $number (1..7) {
    my $file=sprintf "%s/library_comparisons/source/perl/PI%02d.pm",$root,$number;
    my $loaded=do $file;
    die "$file: $@ $!" unless $loaded;
}
my $json=JSON::PP->new->canonical;
my @checks;
sub assert { $_[0] or die "$_[1]\n" }
sub equal {
    my ($actual,$expected)=@_;
    my $a=$json->encode($actual); my $b=$json->encode($expected);
    $a eq $b or die "actual=$a expected=$b\n";
}
sub raises {
    my ($action,$needle)=@_;
    my $ok=eval { $action->();1 };
    my $error=$@;
    !$ok && "$error" =~ /\Q$needle\E/ or die "Expected $needle; got $error\n";
}
sub test {
    my ($module,$name,$action)=@_;
    my $ok=eval { $action->();1 };
    push @checks,{module=>$module,name=>$name,status=>$ok?'PASS':'FAIL',error=>$ok?'':"$@"};
}

test('PI01','map empty avoids callback',sub {
    equal(PerlComparison::Sequences::map_values([],sub {die 'called'}),[]);
});
test('PI01','map arbitrary references and undef',sub {
    my $ref={width=>8};
    my $out=PerlComparison::Sequences::map_values([1,$ref,undef],sub {[$_[0]]});
    assert(refaddr($out->[1][0])==refaddr($ref),'reference identity');
    equal($out,[[1],[$ref],[undef]]);
});
test('PI01','map ordered failure and untouched input',sub {
    my $input=[1,2,3];my @seen;
    raises(sub {PerlComparison::Sequences::map_values($input,sub {
        push @seen,$_[0];die "Second\n" if $_[0]==2;$_[0]*2;
    })},'Second');
    equal(\@seen,[1,2]);equal($input,[1,2,3]);
});
test('PI01','filter stable references and empty',sub {
    my $a={n=>1};my $b={n=>2};
    my $out=PerlComparison::Sequences::filter_values([$a,$b,$a],sub {0+($_[0]{n}==1)});
    equal($out,[$a,$a]);assert(refaddr($out->[0])==refaddr($a),'reference identity');
    equal(PerlComparison::Sequences::filter_values([],sub {die 'called'}),[]);
});
test('PI01','fold empty returns same seed',sub {
    my $seed={value=>42};
    my $out=PerlComparison::Sequences::fold_values([],$seed,sub {die 'called'});
    assert(refaddr($seed)==refaddr($out),'seed identity');
});
test('PI01','fold generic string accumulator',sub {
    equal(PerlComparison::Sequences::fold_values(['a','b'],'>',sub {$_[0].$_[1]}),'>ab');
});
test('PI01','scan initial reference and empty seed',sub {
    my $seed={total=>10};
    my $out=PerlComparison::Sequences::scan_values([2,-3],$seed,sub {{total=>$_[0]{total}+$_[1]}});
    equal($out,[{total=>10},{total=>12},{total=>9}]);
    assert(refaddr($out->[0])==refaddr($seed),'seed identity');
    equal(PerlComparison::Sequences::scan_values([],0,sub {die 'called'}),[0]);
});
test('PI01','any short circuit and empty false',sub {
    my @seen;
    equal(PerlComparison::Sequences::any_value([0,1,2],sub {push @seen,$_[0];0+($_[0]==1)}),1);
    equal(\@seen,[0,1]);
    equal(PerlComparison::Sequences::any_value([],sub {die 'called'}),0);
});
test('PI01','all short circuit and empty true',sub {
    my @seen;
    equal(PerlComparison::Sequences::all_values([1,0,2],sub {push @seen,$_[0];$_[0]}),0);
    equal(\@seen,[1,0]);
    equal(PerlComparison::Sequences::all_values([],sub {die 'called'}),1);
});
test('PI01','predicate rejects noninteger results',sub {
    raises(sub {PerlComparison::Sequences::any_value([1],sub {[]})},'PredicateType');
    raises(sub {PerlComparison::Sequences::filter_values([1],sub {1.5})},'PredicateType');
});
test('PI01','flatMap exactly one level and empty',sub {
    equal(PerlComparison::Sequences::flat_map([[1,[2]],[],[[3]]],sub {$_[0]}),[1,[2],[3]]);
    equal(PerlComparison::Sequences::flat_map([],sub {die 'called'}),[]);
    raises(sub {PerlComparison::Sequences::flat_map([1],sub {42})},'SequenceType');
});
test('PI01','input and callback admission',sub {
    raises(sub {PerlComparison::Sequences::map_values({},sub {1})},'SequenceType');
    raises(sub {PerlComparison::Sequences::fold_values([],0,42)},'CallableType');
});

test('PI02','select order repetitions and reference identity',sub {
    my $a={v=>1};my $b={v=>2};
    my $out=PerlComparison::Ranges::select_values([$a,$b],[1,0,1]);
    equal($out,[$b,$a,$b]);assert(refaddr($out->[0])==refaddr($b),'selected identity');
});
test('PI02','select empty',sub {equal(PerlComparison::Ranges::select_values([],[]),[])});
for my $invalid (-1,2,0.5,undef) {
    test('PI02','select rejects '.(defined($invalid)?$invalid:'undef'),sub {
        my $input=[10,20];
        raises(sub {PerlComparison::Ranges::select_values($input,[0,$invalid])},'ReceiverIndex');
        equal($input,[10,20]);
    });
}
test('PI02','splice growth same target and removed snapshot',sub {
    my $target=[1,2,3,4];my $address=refaddr($target);
    equal(PerlComparison::Ranges::splice_values($target,1,3,[8,9,10]),[2,3]);
    equal($target,[1,8,9,10,4]);assert(refaddr($target)==$address,'target identity');
});
test('PI02','splice shrink all and append',sub {
    my $target=[1,2];
    equal(PerlComparison::Ranges::splice_values($target,0,2,[]),[1,2]);
    equal($target,[]);
    equal(PerlComparison::Ranges::splice_values($target,0,0,[7]),[]);
    equal($target,[7]);
});
test('PI02','splice self alias snapshots source',sub {
    my $target=[1,2,3];
    equal(PerlComparison::Ranges::splice_values($target,1,2,$target),[2]);
    equal($target,[1,1,2,3,3]);
});
test('PI02','splice range failure leaves target',sub {
    my $target=[1,2];
    raises(sub {PerlComparison::Ranges::splice_values($target,2,1,[9])},'ReceiverIndex');
    equal($target,[1,2]);
});

test('PI03','sort empty and singleton do not compare',sub {
    equal(PerlComparison::Ordering::stable_sort([],sub {die 'called'}),[]);
    my $one={name=>'only'};
    my $out=PerlComparison::Ordering::stable_sort([$one],sub {die 'called'});
    assert(refaddr($one)==refaddr($out->[0]),'single reference');
});
test('PI03','sort stable records and all fields',sub {
    my $a={key=>2,id=>'a',width=>8};my $b={key=>1,id=>'b',width=>4};my $c={key=>2,id=>'c',width=>12};
    my $input=[$a,$b,$c];
    my $out=PerlComparison::Ordering::stable_sort($input,sub {$_[0]{key}<=>$_[1]{key}});
    equal($out,[$b,$a,$c]);equal($input,[$a,$b,$c]);
    assert(refaddr($out->[1])==refaddr($a),'record identity');
});
test('PI03','sort generic string elements',sub {
    equal(PerlComparison::Ordering::stable_sort(['b','aa','a'],sub {$_[0] cmp $_[1]}),['a','aa','b']);
});
for my $size (0..31) {
    test('PI03',"sort against actual stable sort, size $size",sub {
        my @items=map {{key=>(($_*7+3)%5),order=>$_,width=>$_+1}} 0..$size-1;
        my @expected=sort {$a->{key}<=>$b->{key}} @items;
        equal(PerlComparison::Ordering::stable_sort(\@items,sub {$_[0]{key}<=>$_[1]{key}}),\@expected);
    });
}
test('PI03','sort callback failure and bad result',sub {
    my $items=[3,1,2];my $calls=0;
    raises(sub {PerlComparison::Ordering::stable_sort($items,sub {die "Compare\n" if ++$calls==2;$_[0]<=>$_[1]})},'Compare');
    equal($items,[3,1,2]);
    raises(sub {PerlComparison::Ordering::stable_sort([2,1],sub {[]})},'ComparisonType');
});
test('PI03','unique structural equality retains first object',sub {
    my $a={key=>'x',width=>8};my $b={key=>'x',width=>9};my $c={key=>'y',width=>10};
    my $out=PerlComparison::Ordering::stable_unique([$a,$b,$c],sub {0+($_[0]{key} eq $_[1]{key})});
    equal($out,[$a,$c]);assert(refaddr($out->[0])==refaddr($a),'first identity');
});
test('PI03','unique empty singleton no callback',sub {
    equal(PerlComparison::Ordering::stable_unique([],sub {die 'called'}),[]);
    equal(PerlComparison::Ordering::stable_unique([0],sub {die 'called'}),[0]);
});
test('PI03','unique callback failure leaves input',sub {
    my $items=[1,2,1];
    raises(sub {PerlComparison::Ordering::stable_unique($items,sub {die "Same\n"})},'Same');
    equal($items,[1,2,1]);
});

test('PI04','group arbitrary structural keys and whole records',sub {
    my $a={kind=>[1,'x'],width=>8};my $b={kind=>[2,'y'],width=>9};my $c={kind=>[1,'x'],width=>10};
    my $out=PerlComparison::Groups::group_by([$a,$b,$c],sub {$_[0]{kind}},sub {0+($_[0][0]==$_[1][0] && $_[0][1] eq $_[1][1])});
    equal($out,[{key=>[1,'x'],items=>[$a,$c]},{key=>[2,'y'],items=>[$b]}]);
    assert(refaddr($out->[0]{items}[0])==refaddr($a),'whole item retained');
});
test('PI04','empty and one key evaluation per item',sub {
    equal(PerlComparison::Groups::group_by([],sub {die 'called'},sub {die 'called'}),[]);
    my $calls=0;
    PerlComparison::Groups::group_by([1,2,1],sub {++$calls;$_[0]},sub {0+($_[0]==$_[1])});
    equal($calls,3);
});
test('PI04','key failure and same admission',sub {
    my $items=[1,2];
    raises(sub {PerlComparison::Groups::group_by($items,sub {die "Key\n"},sub {1})},'Key');
    raises(sub {PerlComparison::Groups::group_by($items,sub {$_[0]},sub {[]})},'PredicateType');
    equal($items,[1,2]);
});

test('PI05','record fields and zero not absent',sub {
    equal(PerlComparison::Records::derive_record({width=>80,height=>24,theme=>'dark'},{width=>0,border=>0}),{width=>0,height=>24,theme=>'dark',border=>0});
    equal(PerlComparison::Records::derive_record({},{}),{});
});
test('PI05','common graph map across two sources',sub {
    my $child={width=>8};
    my $out=PerlComparison::Records::derive_record({a=>$child},{b=>$child});
    assert(refaddr($out->{a})==refaddr($out->{b}),'one shared copy');
    assert(refaddr($out->{a})!=refaddr($child),'new mutable target');
    $out->{a}{width}=9;equal($child->{width},8);
});
test('PI05','cycles and distinct collecting group',sub {
    my $base={width=>8};$base->{self}=$base;
    my $out=PerlComparison::Records::derive_record($base,{height=>24});
    assert(refaddr($out)!=refaddr($out->{self}),'group distinct from copied model');
    assert(refaddr($out->{self})==refaddr($out->{self}{self}),'cycle retained');
    equal($out->{self}{height},24);
});
test('PI05','scalar references and unsupported host code',sub {
    my $value=42;
    my $out=PerlComparison::Records::derive_record({p=>\$value},{});
    assert(refaddr($out->{p})!=refaddr(\$value),'scalar target copied');
    equal($out->{p}->$*,42);
    raises(sub {PerlComparison::Records::derive_record({code=>sub {1}},{})},'MergeType');
});

for my $mode (0..4) {
    test('PI06',"lifecycle success/failure mode $mode",sub {
        my @trace;my $released=0;my $result;
        my $ok=eval {
            $result=PerlComparison::Resources::bracket(
                sub {push @trace,'acquire';die "Acquire\n" if $mode==2;{value=>42,width=>8}},
                sub {++$released;push @trace,'release';die "Release\n" if $mode==3 || $mode==4},
                sub {push @trace,'action';die "Action\n" if $mode==1 || $mode==4;$_[0]{value}+$_[0]{width}}
            );1;
        };
        my $failure=$@;
        if ($mode==0) {assert($ok,'success');equal($result,50)}
        else {
            assert(!$ok,'failed');
            my $expected=$mode==2?'Acquire':$mode>=3?'Release':'Action';
            assert("$failure" =~ /\Q$expected\E/,'failure precedence');
        }
        equal($released,$mode==2?0:1);
        equal(\@trace,$mode==2?['acquire']:['acquire','action','release']);
    });
}
test('PI06','undef resource and arbitrary extra arguments',sub {
    my $released=0;
    my $out=PerlComparison::Resources::bracket(sub {undef},sub {$released++},
        sub {my ($resource,@args)=@_;assert(!defined($resource),'valid undef resource');\@args},
        1,'a',{width=>8},[2,3]);
    equal($out,[1,'a',{width=>8},[2,3]]);equal($released,1);
});
test('PI06','exception object identity',sub {
    my $failure={name=>'UserFailure'};
    my $ok=eval {PerlComparison::Resources::bracket(sub {1},sub {},sub {die $failure});1};
    my $observed=$@;
    assert(!$ok && refaddr($observed)==refaddr($failure),'same exception object');
});

test('PI07','literal replacement and empty regex history',sub {
    my $history='ab';$history =~ /b/;
    equal(PerlComparison::Patterns::replace_all('ab',PerlComparison::Patterns::literal(''),'-'),'-a-b-');
    equal(PerlComparison::Patterns::replace_all('a.b aXb',PerlComparison::Patterns::literal('a.b'),'$1'),'$1 aXb');
});
test('PI07','whole match real end and empty',sub {
    equal(PerlComparison::Patterns::matches("x\n",'x'),0);
    equal(PerlComparison::Patterns::matches('',PerlComparison::Patterns::sequence([])),1);
});
test('PI07','empty capture versus absent capture',sub {
    my $match=PerlComparison::Patterns::whole_match('',PerlComparison::Patterns::capture('x',''))->[1];
    equal(PerlComparison::Patterns::capture_text($match,'x'),[1,'']);
    equal(PerlComparison::Patterns::capture_text($match,'missing'),[0,undef]);
});
test('PI07','sequence capture and sameAs',sub {
    my $pattern=PerlComparison::Patterns::sequence([
        PerlComparison::Patterns::capture('word','[A-Za-z]+'),
        PerlComparison::Patterns::literal(' '),
        PerlComparison::Patterns::same_as('word')]);
    equal(PerlComparison::Patterns::matches('cat cat',$pattern),1);
    equal(PerlComparison::Patterns::matches('cat dog',$pattern),0);
});
test('PI07','repetition bounds and selection strategy',sub {
    equal(PerlComparison::Patterns::matches('aaa',PerlComparison::Patterns::times('a',3)),1);
    equal(PerlComparison::Patterns::matches('aa',PerlComparison::Patterns::times('a',3)),0);
    equal(PerlComparison::Patterns::matches('',PerlComparison::Patterns::times('',3)),1);
    my $short=PerlComparison::Patterns::each_match('aaa',PerlComparison::Patterns::repeated('a',1,undef,0));
    equal(PerlComparison::Patterns::matched_text($short->()),'a');
    my $long=PerlComparison::Patterns::each_match('aaa',PerlComparison::Patterns::repeated('a',1,undef,1));
    equal(PerlComparison::Patterns::matched_text($long->()),'aaa');
});
test('PI07','invalid pattern name bounds and encoding',sub {
    raises(sub {PerlComparison::Patterns::capture('bad-name','a')},'PatternArgument');
    raises(sub {PerlComparison::Patterns::repeated('a',3,2)},'PatternArgument');
    raises(sub {PerlComparison::Patterns::repeated('a',-1,2)},'PatternArgument');
    raises(sub {PerlComparison::Patterns::repeated('a',0,2,'wrong')},'PatternArgument');
    raises(sub {PerlComparison::Patterns::whole_match('a','(')},'PatternArgument');
    raises(sub {PerlComparison::Patterns::text(chr(256))},'PatternEncoding');
});
test('PI07','global empty matches and terminal cursor',sub {
    my $next=PerlComparison::Patterns::each_match('ab','');
    my @positions;
    while (my $match=$next->()) {push @positions,[$match->{begin},$match->{end}]}
    equal(\@positions,[[0,0],[1,1],[2,2]]);
    assert(!defined($next->()) && !defined($next->()),'terminal cursor');
});
test('PI07','nonempty alternative after empty at same position',sub {
    my $next=PerlComparison::Patterns::each_match('a','(?:|a)');
    my @positions;
    while (my $match=$next->()) {push @positions,[$match->{begin},$match->{end}]}
    equal(\@positions,[[0,0],[0,1],[1,1]]);
});
test('PI07','replacement callback once and no rescanning',sub {
    my $calls=0;
    equal(PerlComparison::Patterns::replace_all('aa','a',sub {++$calls;'aaa'}),'aaaaaa');
    equal($calls,2);
});
test('PI07','replacement failure retains input and stops',sub {
    my $source='aaa';my $calls=0;
    raises(sub {PerlComparison::Patterns::replace_all($source,'a',sub {die "Replacement\n" if ++$calls==2;'x'})},'Replacement');
    equal($source,'aaa');equal($calls,2);
    raises(sub {PerlComparison::Patterns::replace_all('a','a',sub {[]})},'PatternEncoding');
});
test('PI07','split keeps all empty fields',sub {
    equal(PerlComparison::Patterns::split_parts('a,,',','),['a','','']);
    equal(PerlComparison::Patterns::split_parts('',','),['']);
    equal(PerlComparison::Patterns::split_parts('ab',''),['','a','b','']);
});
test('PI07','byte text includes NUL and 255',sub {
    my $source="a\0".chr(255);
    my $match=PerlComparison::Patterns::whole_match($source,PerlComparison::Patterns::literal($source));
    equal($match->[0],1);
    equal(PerlComparison::Patterns::matched_text($match->[1]),$source);
});

my @failed=grep {$_->{status} ne 'PASS'} @checks;
my $report={runtime=>"$^V",status=>@failed?'FAIL':'PASS',executed_checks=>scalar(@checks),
    checks=>\@checks,lmx=>'NOT_RUN',
    scope=>'Actual Perl implementation checks: arbitrary values, identity, empty/singleton, failure, aliasing, stable order, resource lifecycle and regex boundaries.'};
open my $file,'>',"$root/validation/implementation_tests.json" or die $!;
print $file JSON::PP->new->canonical->pretty->encode($report);
close $file;
print $json->encode({status=>$report->{status},checks=>scalar(@checks),failures=>\@failed}),"\n";
exit(@failed?1:0);
