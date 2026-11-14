# M11.5в — вычисляемые fn/sub в собственной data (срез 370)

Приёмка пройдена. База main — 5d5a4ea8;
кодовая база — принятый 369 (035d3fcd).
Writer/build — Codex (Sol), работа и будущий коммит непосредственно в main.
Прежний W3 — только контрольная копия. Pipeline:
build2/codex_fix250generationchain01/runs/sol-m11-computed-data-20261113-01.

## Изменение

fn_apply допускает корень собственной data текущего кадра через прежние receiver_bind/make
и Space.rows. Готовый метод выбирается по owner, написанному имени при наличии и parent
исходного Frame; исходное описание не подменяется. Повторный запуск в том же исполнении
сохраняет построенный метод и его данные. Другой исходный Frame этим совпадением не считается.

Временный binding_open прежнего Frame обозначает ещё не завершённые локальные имена.
Известные free inputs удерживаются на входе до эффектов data; новый local сразу перекрывает
entry fallback, в том числе для следующего initializer. После ordered data оставшийся
потребляемый absent отказывает до body без повторного чтения внешнего источника. Закрытая
область сохраняет ранний отказ до инициализаторов. Новой постоянной таблицы нет.

Обходчик и native используют один выбор чтения actual по живому контракту: обычное выражение,
готовое значение или написанная whole-Structure. Выбор хранится в хвосте прежней временной
карты вызова, не предсказывается повторно по лексической доступности вложенной головы.
bind_formals сопоставляет actual/formal; bind_fields проверяет прямые поля whole-Structure
с учётом полноты и defaults, без пробного вычисления admit. Numeric-контекст не объявляет
имя поля аргумента собственным местом. Группы P0 остаются целыми.

Если цель до data ещё неизвестна или может быть затенена, прежние строки кадра сохраняют
возможные entry-снимки неоднозначной группы. Пока владелец сам не потребил имя, эти строки
не видны детям. Классификационный resolve не потребляет их; фактические readers отмечают
только строку текущей активации. Нет прототипа выдуманной функции, позднего захвата внешнего
значения, универсального журнала, копии графа или нового вида кадра.
Native проверяет наличие результата до actuals, затем использует общие bind/admit/invoke;
совместимый native тела вычисленно созданного метода остаётся задачей M14.

## Языковые случаи

fn_prepared и merge_code_descriptions объявляют computed fn в own data main, без временных
корневых @-псевдонимов. Описания args/data записаны вертикально, сохранённые группы code
отражены в дампе; прежние числа и количества частей сохранены.

[computed_data_reentry](../../../selfbuild/tests/graph/computed_data_reentry.lm2):
внешний int triple90, локальные fn/sub из описаний, именованный actual и следующая
инициализация, повтор outer и пути. Независимые результаты: initial4; first581
(k5/calls2/r8/bump1), second892 (k8/calls3/r9/bump2), path10/calls4, bumps3.
Исходные счётчики0/0 и внешний triple90 сохраняются.

[closed_data_missing](../../../selfbuild/tests/graph/closed_data_missing.lm2) отказывает3
до tick при calls0. [open_data_missing](../../../selfbuild/tests/graph/open_data_missing.lm2)
заканчивает ordered data при calls1 и отказывает3 до body, который записал бы99.
Native/forced отвечают1; полный AFTER сравнивается с независимо заданным состоянием.
[computed_data_named](../../../selfbuild/tests/graph/computed_data_named.lm2) даёт9/6
и сохраняет имя actual селектором до построения локальной цели.

[grouped_actual_contract](../../../selfbuild/tests/graph/grouped_actual_contract.lm2)
проверяет closed5/outside8, open55/outside8, data118/calls0/outside8, whole37 и empty34.
В числовом случае k5 захвачен до change→8; после фактического чтения leaf тоже видит5.
В data-случае группы local(never) и local(k) не исполняются; leaf получает8.
Golden построен из BEFORE и этих вычислений, не скопирован из AFTER.

post_loop прежде отказывал5 также на принятом369: RepeatOwn запускал data как код.
Теперь он явно подаёт RepeatOwn\\data и RepeatOwn\\code. Все13 чисел
3/0/2/3/1/9/4/2/2/0/2/2/1 сохранены; исправленный источник проверен и на baseline369.

## Приёмка

Source08: 624 canonical-входа; inputs.sha256 обновлён, verify624 и stage-copy прошли.
Manifest: 5ae4d48139a2e570fbe91eac99ed76382ffaa2c469e7fff4de46cccf1a8afdbf.
API graph68/run53; Frame добавляет binding_open штатным генератором.

Runtime06/graph05 прошли19 случаев interp/native/forced (57 режимов), 12 полных AFTER
отрицательных состояний и весь mutation. Включены прежние M8 p0_argument_structure,
whole_arguments и named_arguments. Полный bootstrap03 quick из принятого seed369 завершён:
настоящие G1/G2, по9 smoke-строк, fixedpoint13 и verify624 прошли. Настоящий G2 заново собрал
graph-tool и повторил19 случаев в трёх режимах, AFTER12 и mutation. Рабочая связка —
boot-m11-computed-data-03/g2 и graph-m11-computed-data-g2-03/graph_trans-prod.exe.
Штатные render semantics и docs check прошли:35 пар семантики,14 implements cases,27 пар
грамматики,44 выдержки,615 импортов, ссылки, точное начало и LF всех27224 файлов индекса.
Diff --check чист. Records содержат только окончательные запуски. Далее commit/push из main.

Переходный source05 прошёл G1/G2. Source06 прошёл15 целевых случаев, но отдельный группированный
actual обнаружил позднее чтение8 вместо5; bootstrap02 остановлен до исправления. Runtime04
отказал из-за оставшегося неполного generated frontend header после той остановки. Штатная
build-frontend02 восстановила closure; runtime05, затем окончательный runtime06 прошли.
Эти промежуточные попытки не выданы за финальную приёмку.

## Открытая граница

Шаг3 to_sol и весь M11 не закрыты: остальные root merge-держатели и адресные формы, затем
root/self и повторы; computed fn/sub в code/inline, indexed repeated methods, M11.7/test и
рабочий frontend M11.8. M6/M13 reference overlap, void/null/depth/arrays и обе формы descriptor
остаются открыты. M14 — native обычных C, общий прямой кеш и уточнённый flush, совместимый native
копии и GC живых/приостановленных кадров с working roots — этой приёмкой не реализованы.
