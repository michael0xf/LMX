# PI06. Полный синхронный bracket

Acquire без обязательных аргументов, release(resource), action(resource, дополнительные аргументы) с произвольным результатом, включая void/undef. После успешного acquire release выполняется ровно один раз при успехе и обычном отказе action; после отказа acquire не выполняется. Отказ release имеет приоритет над сохранённым отказом action.

Это отдельное сравнение реализации. Клиенты Perl **не импортируют** этот модуль: они используют настоящий CORE/List::Util. LMX вызывает предлагаемое ядро.

## Граница реализации

LMX регистрирует finally до acquire и охраняет cleanup успешным outcome. Perl помещает acquire/action в один защищённый eval, сохраняет точный outcome и затем отдельно выполняет release; дополнительный eval задаёт явный приоритет отказа cleanup. Так реализация поддерживает двойной отказ, не полагаясь на неопределённый порядок двух исключений native defer. В прикладном P24 используется настоящий defer с не бросающим release.

## Размер

| Полный исходник | Непробельные символы | Все Unicode-символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX | 316 | 462 | 16 |
| Perl | 454 | 637 | 23 |

## LMX

[Исходник](source/lmx/PI06.lmx). Корни извлекаются из канонических модулей; SHA-256 фиксируется в examples.json.

```lmx
FxAround:
    private:
        @: acquire
        @: release
        @: action
        @: arguments ()
    return: @
    around:
        throws: copy(FxThrows\traversal)
        private: @: resourceArgs (copy(()))
        sys\resize(resourceArgs; 1)
        resourceArgs[0] := FxApply\apply(acquire; ())
        finally:
            FxApply\apply(release; resourceArgs)
        ---
        return: FxApply\apply(action; FxAppend\append(resourceArgs; arguments))
```

## Perl

[Исходник](source/perl/PI06.pm).

```perl
package PerlComparison::Resources;
use strict;
use warnings;
sub bracket {
    my ($acquire, $release, $action, @arguments) = @_;
    ref($acquire) eq 'CODE' && ref($release) eq 'CODE' && ref($action) eq 'CODE'
        or die "CallableType\n";
    my ($ready, $resource, $value) = (0);
    my $ok = eval {
        $resource = $acquire->();
        $ready = 1;
        $value = $action->($resource, @arguments);
        1;
    };
    my $failure = $@;
    if ($ready) {
        my $released = eval { $release->($resource); 1 };
        if (!$released) { $failure = $@; $ok = 0 }
    }
    die $failure unless $ok;
    return $value;
}
1;
```

## Проверка и ограничения

Синхронный договор обычного возврата и исключений callbacks, один Message/один вызов; нет гарантии после смерти процесса, exit или внешнего асинхронного прерывания между host-инструкциями. Для асинхронного запуска post всего owner-метода переносит результат, а ресурс/cleanup остаются в его арене. Post внутри action и немедленный выход не продлевают жизнь ресурса. Общая Perl-реализация обходится стандартным eval; экспериментальный defer остаётся только в отдельном клиентском примере. Haskell mask и общие межпоточные ссылки не обещаны.

Запуск Perl: [отчёт](../validation/implementation_tests.json). LMX: **NOT_RUN**; проверка текста не подменяет запуск.

## Первичные источники

- <https://perldoc.perl.org/5.40.1/perlsyn#defer-blocks>
- <https://perldoc.perl.org/5.40.1/functions/eval>
- <https://perldoc.perl.org/5.40.1/functions/die>
