# Статистика редакции 23 ноября 2026 года

**90 паттернов + 9 реализаций библиотек: 99 сравнений и 297 основных листингов.** Сохранены также 23 исходных GoF-сравнения (184 листинга) и отдельная подборка 24 LMX-примеров.

Считаются непробельные Unicode-символы и непустые строки основного листинга. Среди сопоставимых способов выбирается более короткий. Полные альтернативы остаются только для другого подхода; малые различия изложены примечанием. Реализации общих зависимостей учитываются отдельно; размеры кода не означают скорость исполнения.

## Группы и границы сравнения

| Группа | Слой | Количество | LMX, символы | Контроль 1 | Символы | Контроль 2 | Символы |
| --- | --- | ---: | ---: | --- | ---: | --- | ---: |
| [Интерфейс и навигация](01_ui_and_navigation/LMX_Comparison_01_ui_and_navigation.md) | Сценарии | 7 | 1307 | TypeScript | 1802 | C# | 2219 |
| [Архитектура и границы компонентов](02_architecture_and_boundaries/LMX_Comparison_02_architecture_and_boundaries.md) | Сценарии | 10 | 2495 | Java | 2939 | Go | 2468 |
| [Архитектура и границы компонентов](02_architecture_and_boundaries/LMX_Comparison_02_architecture_and_boundaries.md) | Клиенты библиотек | 1 | 268 | Java | 374 | Go | 246 |
| [Архитектура и границы компонентов](02_architecture_and_boundaries/LMX_Comparison_02_architecture_and_boundaries.md) | Реализации | 1 | 839 | Java | 308 | Go | 178 |
| [Доменная модель и хранение данных](03_domain_and_persistence/LMX_Comparison_03_domain_and_persistence.md) | Сценарии | 16 | 2681 | Python | 3137 | C# | 4577 |
| [Доменная модель и хранение данных](03_domain_and_persistence/LMX_Comparison_03_domain_and_persistence.md) | Клиенты библиотек | 3 | 795 | Python | 542 | C# | 704 |
| [Доменная модель и хранение данных](03_domain_and_persistence/LMX_Comparison_03_domain_and_persistence.md) | Реализации | 3 | 2854 | Python | 1036 | C# | 1790 |
| [События, распределённое состояние и согласованность](04_events_and_consistency/LMX_Comparison_04_events_and_consistency.md) | Сценарии | 9 | 2275 | Java | 3422 | Go | 3328 |
| [Облако, HTTP и отказоустойчивость](05_cloud_and_resilience/LMX_Comparison_05_cloud_and_resilience.md) | Сценарии | 11 | 1795 | Go | 2047 | C# | 2187 |
| [Облако, HTTP и отказоустойчивость](05_cloud_and_resilience/LMX_Comparison_05_cloud_and_resilience.md) | Клиенты библиотек | 2 | 614 | Go | 1226 | C# | 1083 |
| [Облако, HTTP и отказоустойчивость](05_cloud_and_resilience/LMX_Comparison_05_cloud_and_resilience.md) | Реализации | 1 | 6081 | Go | 2456 | C# | 3462 |
| [Асинхронность, исполнители и Message](06_async_and_messages/LMX_Comparison_06_async_and_messages.md) | Сценарии | 11 | 2167 | Go | 2652 | Erlang | 2899 |
| [Координация состояния: Message и общая память](07_state_coordination/LMX_Comparison_07_state_coordination.md) | Сценарии | 6 | 796 | Java | 1445 | Rust | 1556 |
| [Объекты, зависимости и композиция](08_objects_and_composition/LMX_Comparison_08_objects_and_composition.md) | Сценарии | 10 | 2177 | Java | 2534 | Python | 2085 |
| [Функциональные вычисления](09_functional_computation/LMX_Comparison_09_functional_computation.md) | Клиенты библиотек | 4 | 1737 | Haskell | 1152 | Scala | 1119 |
| [Функциональные вычисления](09_functional_computation/LMX_Comparison_09_functional_computation.md) | Реализации | 4 | 2040 | Haskell | 1558 | Scala | 1667 |

По разным группам не строится общий рейтинг языков: контрольные языки, сценарии и границы библиотек различаются. Основные и альтернативные реализации имеют явно указанные границы обобщения и зависимости; короткий клиент использует показанный рядом компонент единого текущего ядра.

## Функциональная группа и общие зависимости

[Восемь сравнений](09_functional_computation/LMX_Comparison_09_functional_computation.md) разделяют реальное библиотечное использование и самостоятельные реализации. Контрольные клиенты не импортируют наши сравнительные реализации. [Реестр зависимостей](09_functional_computation/IMPLEMENTATION_DEPENDENCIES.md) считает реальные LMX-определения по одному разу, включая дополнительный curry-механизм клиента 085; неопубликованное ядро не объявляется имеющим нулевой размер.

## Корневые примеры

| Пример | Основной код, символы | Непустые строки | Второй вариант рядом |
| --- | ---: | ---: | --- |
| [A01](examples/lmx/A01.lm3) | 126 | 11 | Нет |
| [H01](examples/lmx/H01.lm3) | 207 | 15 | Да |
| [H02](examples/lmx/H02.lm3) | 271 | 14 | Да |
| [H03](examples/lmx/H03.lm3) | 341 | 24 | Да |
| [H04](examples/lmx/H04.lm3) | 265 | 18 | Нет |
| [H05](examples/lmx/H05.lm3) | 218 | 18 | Нет |
| [H06](examples/lmx/H06.lm3) | 179 | 13 | Да |
| [H07](examples/lmx/H07.lm3) | 461 | 30 | Да |
| [H08](examples/lmx/H08.lm3) | 122 | 17 | Нет |
| [H09](examples/lmx/H09.lm3) | 260 | 17 | Нет |
| [M01](examples/lmx/M01.lm3) | 97 | 9 | Нет |
| [M05](examples/lmx/M05.lm3) | 49 | 5 | Нет |
| [R01](examples/lmx/R01.lm3) | 183 | 11 | Нет |
| [R02](examples/lmx/R02.lm3) | 95 | 10 | Нет |
| [R03](examples/lmx/R03.lm3) | 244 | 16 | Нет |
| [R04](examples/lmx/R04.lm3) | 383 | 26 | Нет |
| [R06a](examples/lmx/R06a.lm3) | 189 | 11 | Нет |
| [R06b](examples/lmx/R06b.lm3) | 139 | 10 | Нет |
| [R07](examples/lmx/R07.lm3) | 159 | 12 | Нет |
| [R09](examples/lmx/R09.lm3) | 189 | 13 | Нет |
| [V02](examples/lmx/V02.lm3) | 242 | 10 | Да |
| [V03](examples/lmx/V03.lm3) | 298 | 23 | Нет |
| [V04](examples/lmx/V04.lm3) | 160 | 15 | Нет |
| [V05](examples/lmx/V05.lm3) | 552 | 33 | Нет |

[Выбор основного варианта и размеры обоих](examples/validation/functional_receiver_counts.json) и [полная стоимость библиотечных реализаций](examples/validation/receiver_library_counts.json). Общая реализация остаётся доступной, даже если более короткий процедурный вариант выбран основным.

## Исходные 23 GoF-сравнения

Все 184 основных листинга повторно пересчитаны. Для Composite, Prototype и Abstract Factory сохранены альтернативные LMX-алгоритмы, основной выбран по краткости при сопоставимой границе подсчёта. В Flyweight исправлен уровень отступа финального return; прежний некорректный вариант помечен историческим и не участвует в выборе по краткости.

| Язык | Непробельных символов |
| --- | ---: |
| LMX | 5734 |
| Python | 6870 |
| Java | 9809 |
| C++ | 7743 |
| C# | 9105 |
| TypeScript | 8843 |
| Go | 8241 |
| Rust | 8890 |

## Форматы и воспроизводимость

[CSV сводки](STATISTICS_2026-11-22.csv), [Excel сводки](STATISTICS_2026-11-22.xlsx), [PDF сводки](STATISTICS_2026-11-22.pdf), [полный JSON](validation/statistics_20261122.json). Во всех девяти группах отдельно обновлены Markdown, CSV, XLSX и PDF.

`python3 tools/refresh_statistics.py` обновляет текстовые числовые таблицы и JSON. `python3 tools/recount_patterns.py --json validation/recount_report.json` проверяет совпадение первичных JSON/исходников/Markdown и сохранённые варианты. Обновление Excel/PDF и их визуальная проверка имеют отдельные отчёты в validation. Инструменты не исполняют LMX и не измеряют скорость.
