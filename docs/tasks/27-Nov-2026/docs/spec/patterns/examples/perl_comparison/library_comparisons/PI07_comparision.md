# PI07. Построение шаблонов и операции над regex-движком

Общий byte/ASCII-профиль: построение буквальных и последовательных шаблонов, повторения с обеими стратегиями, уникальные именованные захваты и ссылка на ранее объявленную группу; wholeMatch/matches; ленивые неперекрывающиеся eachMatch; matchedValue/captureValue; полная замена строкой или callback; split с пустыми краевыми полями. Пустые совпадения продвигаются по правилам движка, отсутствующий и пустой capture различаются.

Это отдельное сравнение реализации. Клиенты Perl **не импортируют** этот модуль: они используют настоящий CORE/List::Util. LMX вызывает предлагаемое ядро.

## Граница реализации

Perl использует собственный regex engine для распознавания/поиска. В отдельном модуле самостоятельно реализованы строитель шаблона, validation, снимок Match, состояние итератора, выбор/сборка результата замены, однократный callback и сборка split. Модуль не вызывает одноимённые s///, native split(pattern), List::Util либо Perl-клиент. LMX ниже использует свой существующий Pattern engine; его полные примитивы, комбинаторы, TextView, курсоры и FxSeq/runtime доступны в канонической src/regex, а не скрыты в клиенте.

## Размер

| Полный исходник | Непробельные символы | Все Unicode-символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX | 9915 | 14305 | 427 |
| Perl | <span style="color:#176233"><u>3999</u></span> | 5209 | 168 |

## LMX

[Исходник](source/lmx/PI07.lmx). Корни извлекаются из канонических модулей; SHA-256 фиксируется в examples.json.

```lmx
RxTextViewMake:
    private:
        []char: source
        int: profile
    return: @
    make:
        private: @: validated RxTextBuild\make(source := source; profile := profile)
        private: @: out (copy(TextView))
        out\source := source
        out\profile := profile
        return: out

RxPrepare:
    private: @TextView: source
    required: source
    return: @
    make:
        private: @: prepared RxTextBuild\make(source := source\source; profile := source\profile)
        prepared\view := source
        return: prepared

RxByteText:
    private: []char: source
    required: source
    return: @
    byteText:
        return: RxTextViewMake\make(source := source; profile := 1)

RxPrimitiveConfig:
    @: probe 0
    @: payload 0

RxLiteral:
    private: @: value
    required: value
    return: @
    literal:
        return: RxPrimitiveMake\make(RxLiteralProbe\probe; value)

RxSameAs:
    private: []char: name
    required: name
    return: @
    sameAs:
        private: @: payload (copy(RxNameConfig))
        payload\name := name
        return: RxPrimitiveMake\make(RxSameAsProbe\probe; payload)

RxPartsConfig:
    @: originalParts 0
    []@: parts []

RxPartsPrepare:
    private: @: patterns
    return: @
    prepare:
        throws: copy(FxThrows\pattern)
        private: @: info FxSeqInfo\get(source := patterns)
        private: []@: parts []
        sys\resize(parts; length(patterns))
        private: int: i 0
        while: i < length(patterns)
            private: @: item FxSeqRead\read(patterns; i)
            parts[i] := RxNormalize\make(value := item)
            i += 1
        private: @: config (copy(RxPartsConfig))
        config\originalParts := patterns
        config\parts := parts
        return: config

RxSequence:
    private: @: patterns
    required: patterns
    return: @
    then:
        throws: copy(FxThrows\pattern)
        private: @: config RxPartsPrepare\prepare(patterns := patterns)
        if: length(config\parts) = 0
            return: emptyPattern
        if: length(config\parts) = 1
            return: config\parts[0]
        return: RxPatternFactory\make(RxSequenceOpen\open; config)

RxRepeatConfig:
    @: pattern 0
    int: minimum 0
    int: bounded 0
    int: maximum 0
    int: order 0

RxRepeated:
    private:
        @: pattern
        int: minimum 0
        @: maximum unbounded
        int: order extendFirst
    required: pattern
    return: @
    repeated:
        throws: copy(FxThrows\pattern)
        if: minimum < 0
            throw: PatternArgument()
        if: order != extendFirst && order != stopFirst
            throw: PatternArgument()
        private: @: config (copy(RxRepeatConfig))
        config\pattern := RxNormalize\make(value := pattern)
        config\minimum := minimum
        config\order := order
        # A copied configuration keeps its role; identity is not its contract.
        if: FxKernel\acceptsRequirement(candidate := maximum; requirement := RxUnbounded) = 0
            private: int: bound \maximum
            if: bound < minimum || bound < 0
                throw: PatternArgument()
            config\bounded := 1
            config\maximum := bound
        return: RxPatternFactory\make(RxRepeatOpen\open; config)

RxCaptureConfig:
    []char: name ""
    @: pattern 0

RxCapture:
    private:
        []char: name
        @: pattern
    required: name pattern
    return: @
    capture:
        throws: copy(FxThrows\pattern)
        private: @: config (copy(RxCaptureConfig))
        config\name := name
        config\pattern := RxNormalize\make(value := pattern)
        return: RxPatternFactory\make(RxCaptureOpen\open; config)

RxLogicalArguments:
    private:
        @: left
        []@: right
    required: right
    return: @
    collect:
        private: int: extra 0
        if: left != nil
            extra := 1
        private: []@: out []
        sys\resize(out; length(right) + extra)
        if: extra != 0
            out[0] := left
        private: int: i 0
        while: i < length(right)
            out[i + extra] := right[i]
            i += 1
        return: out

RxThenOperand:
    private:
        @: left
        int: depth
        []@: right
    required: right
    const: int: PASS_ARGS_AS_IS 0
    const: int: PRIORITY sys\priority("+")
    return: @
    then:
        throws: copy(FxThrows\pattern)
        private: @: args RxLogicalArguments\collect(left := left; right := right)
        if: length(args) < 2
            throw: PatternArgument()
        return: RxSequence\then(patterns := args)

RxRepeatOperands:
    private:
        @: left
        int: depth
        []@: right
    required: right
    const: int: PASS_ARGS_AS_IS 0
    const: int: PRIORITY sys\priority("*")
    return: @
    times:
        throws: copy(FxThrows\pattern)
        private: @: args RxLogicalArguments\collect(left := left; right := right)
        if: length(args) != 2
            throw: PatternArgument()
        private: int: count \args[1]
        return: RxRepeated\repeated(pattern := args[0]; minimum := count; maximum := args[1])
    atLeast:
        throws: copy(FxThrows\pattern)
        private: @: args RxLogicalArguments\collect(left := left; right := right)
        if: length(args) != 2
            throw: PatternArgument()
        private: int: count \args[1]
        return: RxRepeated\repeated(pattern := args[0]; minimum := count)
    atMost:
        throws: copy(FxThrows\pattern)
        private: @: args RxLogicalArguments\collect(left := left; right := right)
        if: length(args) != 2
            throw: PatternArgument()
        private: int: count \args[1]
        if: count < 0
            throw: PatternArgument()
        return: RxRepeated\repeated(pattern := args[0]; maximum := args[1])
    optional:
        throws: copy(FxThrows\pattern)
        private: @: args RxLogicalArguments\collect(left := left; right := right)
        if: length(args) != 1
            throw: PatternArgument()
        return: RxRepeated\repeated(pattern := args[0]; maximum := 1)

RxSelectAt:
    private:
        @RxPreparedSource: source
        @Pattern: pattern
        int: position
        int: whole 0
        int: nonEmpty 0
    return: @
    select:
        # whole filters the END position only; the supplied start may be nonzero.
        private: @: cursor RxOpen\open(pattern; source; position; 0)
        private: @: next cursor()
        while: next\present != 0
            private: @: candidate next\value
            private: int: accepted 1
            if: whole != 0 && candidate\position != length(source\units)
                accepted := 0
            if: nonEmpty != 0 && candidate\position = position
                accepted := 0
            if: accepted != 0
                return: FxSome\some(value := RxMatchMake\make(source; position; candidate))
            next := cursor()
        return: FxNone\none()

RxWholeMatch:
    private:
        @: source
        @: pattern
    required: source pattern
    return: @
    wholeMatch:
        throws: copy(FxThrows\pattern)
        private: @: prepared RxPrepareSource\make(source := source)
        private: @: ready RxNormalize\make(value := pattern)
        return: RxSelectAt\select(source := prepared; pattern := ready; position := 0; whole := 1)

RxFindState:
    @: source 0
    @: pattern 0
    int: position 0
    int: nonEmpty 0
    int: finished 0

RxFindStateMake:
    private:
        @RxPreparedSource: source
        @Pattern: pattern
    return: @
    make:
        private: @: out (copy(RxFindState))
        out\source := source
        out\pattern := pattern
        return: out

RxFindNext:
    private: @: state
    return: @
    step:
        if: state\finished != 0
            return: FxNone\none()
        private: int: end length(state\source\units)
        while: state\position <= end
            private: @: selected RxSelectAt\select(source := state\source; pattern := state\pattern; position := state\position; nonEmpty := state\nonEmpty)
            if: selected\present != 0
                private: @: matched selected\value
                if: matched\end > matched\begin
                    state\position := matched\end
                    state\nonEmpty := 0
                else:
                    if: matched\end = end
                        state\finished := 1
                    else:
                        state\nonEmpty := 1
                ---
                return: selected
            state\nonEmpty := 0
            if: state\position = end
                state\finished := 1
                return: FxNone\none()
            state\position += 1
        state\finished := 1
        return: FxNone\none()

RxFindAllOwner:
    private: @: state 0
    Next:
        return: @
        next:
            throws: Stop
            private: @: owner parent()
            private: @: state owner\private\state
            while: 1
                private: @: selected RxFindNext\step(state := state)
                if: selected\present = 0
                    throw: Stop()
                yield: selected\value

RxEachMatch:
    private:
        @: source
        @: pattern
    required: source pattern
    return: @
    eachMatch:
        throws: copy(FxThrows\pattern)
        private: @: prepared RxPrepareSource\make(source := source)
        private: @: ready RxNormalize\make(value := pattern)
        private: @: owner (copy(RxFindAllOwner))
        owner\private\state := RxFindStateMake\make(prepared; ready)
        return: owner\Next\next

RxMatches:
    private:
        @: source
        @: pattern
    required: source pattern
    return: int
    matches:
        throws: copy(FxThrows\pattern)
        private: @: found RxWholeMatch\wholeMatch(source := source; pattern := pattern)
        return: found\present

RxMatchedValue:
    private: @Match: result
    required: result
    return: @
    matchedValue:
        return: RxSourceSlice\copyValue(result\private\prepared; result\begin; result\end)

RxLastCapture:
    private:
        @Match: result
        []char: name
    required: result name
    return: @
    lastCapture:
        private: @: latest RxCaptureLatest\find(result\captures; name)
        if: latest\present = 0
            return: latest
        private: @: entry latest\value
        return: FxSome\some(value := RxSpanMake\make(result\private\prepared; entry\begin; entry\end))

RxCaptureValue:
    private:
        @Match: result
        []char: name
    required: result name
    return: @
    captureValue:
        private: @: latest RxLastCapture\lastCapture(result; name)
        if: latest\present = 0
            return: latest
        private: @: span latest\value
        private: @: text RxSourceSlice\copyValue(span\private\prepared; span\begin; span\end)
        return: FxSome\some(value := text)

RxReplace:
    private:
        @: source
        @: pattern
        @RxReplacementInput: replacement
    required: source pattern replacement
    return: @
    replace:
        throws: copy(FxThrows\pattern)
        private: @: admittedReplacement replacement
        private: @: prepared RxPrepareSource\make(source := source)
        private: @: ready RxNormalize\make(value := pattern)
        private: @: state RxFindStateMake\make(prepared; ready)
        private: @: out RxSourceSlice\copyValue(prepared; 0; 0)
        private: int: copiedUntil 0
        private: @: selected RxFindNext\step(state := state)
        while: selected\present != 0
            private: @: matched selected\value
            private: @: replacementValue RxReplacementValue\make(admittedReplacement; matched)
            RxSourceAppendSpan\append(out; prepared; copiedUntil; matched\begin)
            RxSourceAppend\append(out; replacementValue; prepared)
            copiedUntil := matched\end
            selected := RxFindNext\step(state := state)
        # Search position and source-copy position remain separate.
        RxSourceAppendSpan\append(out; prepared; copiedUntil; length(prepared\units))
        return: out

RxSplit:
    private:
        @: source
        @: pattern
    required: source pattern
    return: @
    split:
        throws: copy(FxThrows\pattern)
        private: @: prepared RxPrepareSource\make(source := source)
        private: @: ready RxNormalize\make(value := pattern)
        private: @: state RxFindStateMake\make(prepared; ready)
        private: []@: parts []
        private: int: copiedUntil 0
        private: @: selected RxFindNext\step(state := state)
        while: selected\present != 0
            private: @: matched selected\value
            private: @: text RxSourceSlice\copyValue(prepared; copiedUntil; matched\begin)
            FxSeqPush\append(parts; text)
            copiedUntil := matched\end
            selected := RxFindNext\step(state := state)
        private: @: tail RxSourceSlice\copyValue(prepared; copiedUntil; length(prepared\units))
        FxSeqPush\append(parts; tail)
        return: parts

RxReplacementInput:
    @: literal 0
    @: operation 0

RxReplacementLiteral:
    private: @: value
    required: value
    return: @
    accept:
        throws: copy(FxThrows\pattern)
        FxSeqInfo\get(value)
        private: @: result (copy(RxReplacementInput))
        result\literal := value
        return: result

RxReplacementCallable:
    private: @: operation
    required: operation
    return: @
    accept:
        throws: copy(FxThrows\pattern)
        private: @: shape FxKernel\signature(operation)
        if: length(shape\inputTypes) != 1 || shape\hasResult = 0
            throw: FxArity()
        private: @: result (copy(RxReplacementInput))
        result\operation := operation
        return: result

RxReplacementValue:
    private:
        @RxReplacementInput: replacement
        @Match: matched
    required: replacement matched
    return: @
    make:
        throws: copy(FxThrows\pattern)
        private: @: result replacement\literal
        if: replacement\operation != 0
            result := FxApply\apply(replacement\operation; FxOne\make(matched))
        private: @RxPreparedSource: source matched\private\prepared
        private: @: validate source\domain\literalUnits
        validate(value := result; profile := source\profile)
        return: result
```

## Perl

[Исходник](source/perl/PI07.pm).

```perl
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
```

## Проверка и ограничения

Это сравнение операций над общим согласованным regex-профилем, не порт всего Perl engine и не равенство всех возможностей LMX Pattern. В Perl имена capture ограничены ASCII-идентификаторами и уникальны, sameAs ссылается на объявленную предыдущую группу; повторная история captureValues и lookbehind здесь не заявлены. Исходный текст не меняется во время курсора. Все byte-значения 0..255 допустимы; Unicode-сопоставление не подменяется этим профилем. Ошибка callback распространяется, не превращается в отсутствие совпадения. Сами Pattern-строители раскрыты здесь отдельно; реальные клиенты Perl записаны обычным regex-синтаксисом. Для проверки допуска Pattern/replacement/max-count LMX теперь использует внутренний readonly acceptsRequirement и конечные FxKernelFailure/FxTypeToken. Это текущий native integration gate AR01, а не исполненный в архиве провайдер.

Запуск Perl: [отчёт](../validation/implementation_tests.json). LMX: **NOT_RUN**; проверка текста не подменяет запуск.

## Первичные источники

- <https://perldoc.perl.org/5.40.1/perlre>
- <https://perldoc.perl.org/5.40.1/perlop#Regexp-Quote-Like-Operators>
- <https://perldoc.perl.org/5.40.1/perlop#The-empty-pattern>
- <https://perldoc.perl.org/5.40.1/functions/pos>
- <https://perldoc.perl.org/5.40.1/functions/split>
