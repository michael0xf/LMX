# D-12 — printTree.lm2 на корень и mainArgs

STARTED grok/d12-printtree, база main `338ed30`. REVIEW dd153e2 — OK, не BLOCK. Ответы dd153e2-1/-2 на main `338ed30`.

## Факт

`dev/l2src_sandbox/printTree.lm2` (и копия `l2src/printTree.lm2`) — документный пример L2 §18.2. Сегодня l2trans (harness `20260925_192542`) отказывает его: `unknown type`, atom `LmP0Document`, строка `@: LmP0Document`. Форма — старый `fn: main (int: argc; @@: char argv)` внутри `L2:`.

Корень уже принимает аргументы письмом `MainLetter` / `mainArgs` (`entry_argc_if`). `c.*` и вызов парсера на корне — «L2 operation outside a method body» (Q7). Вызов метода с корня с нечисловым входом (`run(@ m\mainArgs[1][0])`) — «a call with an input that is not a number» (тот же Q7). `length(m\mainArgs)` внутри метода — «length requires one known primitive own array»; на корне то же `length` уже бежит. Поле `m`, объявленное после метода, из метода — `unresolved name` / `unresolved dynamic=m`.

## Правка

Ядро и `l2trans.lm1` не менять. Пример:

- корень объявляет `MainLetter` и поле `m` до методов, принимает письмо, сравнивает `length(m\mainArgs)` с 2;
- не два аргумента — `usage()` (печать строки и 0);
- иначе `run()`: `lm_p0_parse_file: @ m\mainArgs[1][0] @ document` и прежний разбор/дамп через `c.*`;
- выход — `sendMessage: exit`, не `return:` с значением в корне;
- типы сырого ABI — `c.LmP0Document` / `c.LmP0Diagnostic`;
- оба близнеца — одна копия.

`@ document` остаётся адресом локальной ячейки-указателя. L2 §18.2 называет это и письмо `mainArgs`. Q7 не чинится этим срезом.

## Проверка

l2trans, l1trans, `gcc -c`. Прогон тем же драйвером, что harness (`-Dmain=l2_generated_main` и переименования запуска): без пути — usage и exit 0; файл `entry_argc_if.lm2` — дамп и exit 0; нет файла — entry 1 и stderr `P0 parse error while reading`. `check_docs`. Полный гейт 282/402 не повторять: ядро, транслятор и строки harness не меняются.

## RESULT

Посажено на `grok/d12-printtree`. `printTree.lm2` в обоих близнецах — одна копия. Корень принимает `MainLetter` / `mainArgs`. `usage()` печатает строку и возвращает 0. `run()` передаёт `@ m\mainArgs[1][0]` и `@ document` в `lm_p0_parse_file`. Выход корня — `sendMessage: exit`.

l2trans exit 0 (L1 31106 байт, `# entry statements: 5`, вызов `lm_p0_parse_file(@ l2_cp1[0U], @ document)`). l1trans exit 0. `gcc -c` exit 0. Связка с `l2_eternal_driver.o`: без пути — `usage: printTree <source>`, exit 0, 12 checks; `entry_argc_if.lm2` — дамп `structure fields=6`, exit 0; нет файла — entry 1, stderr `P0 parse error while reading`. `check_docs` OK. Ядро и транслятор не менялись, полный 282/402 не повторялся.
