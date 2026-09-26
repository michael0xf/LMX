# D-20 срез 1 — `mainArgs` без NUL

Тикет `steps/tickets/20260926-02-d20-char-array.md`. База `765e760`. `l2trans.lm1` не менялся.

## Замер до правки

Письмо `mainArgs` строит ядро, не транслятор. `dev/l2src_sandbox/lmx_root.lm1` копировал `strlen(argv[i]) + 1` вместе с NUL (`alen` в `lmx_root_launch_tapped`). Тот же `+ 1` держали `al_make` / `al_holds` в `lmx_argv_letter_selftest.lm1` и `host_arg_ok` (`len = 6` у `"probe"`). Фикстура `entry_strcmp.lm2` ждала `length(m\mainArgs[1]) = 3` и байт `[2] = 0` для argv `ok`. Значит сегодня `"ok"` — длина 3.

Литерал текста в письме транслятора уже без лишнего NUL: `l2trans.lm1` :19867–:19869 выделяет `t\length - 2` и копирует столько же байт. Это не этот срез. Внутренние C-буферы транслятора (`l2_tok_text`, unquote, имена, `l2_fmt_l1_string`) остаются C-строками. Дверь `c.puts` / `c.strcmp` на корне — Q7 («L2 operation outside a method body»); строки `entry_index` и `entry_strcmp` остаются root-pending, факты harness не меняются.

## Посадка

- Ядро: `len = strlen`, `memcpy` только при `len != 0`. Пустая строка — массив длины 0, без чтения `data`.
- `al_make` повторяет ту же форму, иначе зеркало C врёт. `al_holds`: `len == strlen`, сравнение `len` байт, и для `"ok"` байт `[1]` равен `k` (107). Мутант ядра `+ 1` краснит сценарий C (`al_host_shape`), не A/B.
- `lmx_root_host_selftest`: `"probe"` — длина 5, сравнение 5 байт.
- Свидетель harness `entry_arg_len.lm2`, `Argv = @('ok')`: `length(m\mainArgs[1]) = 2`, байты `o`/`k`, Entry 7. Отказ длины — exit 1.

Норма L3 уже на main (`765e760`). Спеки L2 не менялись: строка про `LmxCharArray` без NUL уже была.

## Мутанты

| Что | Результат |
| --- | --- |
| Ядро `alen: strlen(argv[ai]) + 1U`, `al_make` без `+ 1` | RED `lmx_argv_letter_selftest`: только «C: the host's mainArgs letter» (`checks=23 failures=1`). A/B зелёные. `lmx_root_host_selftest`: «argv[1] = probe» (`checks=38 failures=1`). Evidence `build/l2src/20260926_014041`. |
| Откат | GREEN build 282/282, `lmx_argv_letter_selftest` `checks=23 failures=0`. Evidence `build/l2src/20260926_013800`. |

## Гейт

build 282/282 (`build/l2src/20260926_013800`), harness 412/412 (`build/l2_harness/20260926_014339`, `entry_arg_len` Entry 7, `entry_index`/`entry_strcmp` по-прежнему Q7), L3 11/11, имена 69/128.
