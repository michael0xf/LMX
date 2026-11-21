# События, распределённое состояние и согласованность

[Руководство RU](LMX_Design_Patterns.ru.md) · [Guide EN](LMX_Design_Patterns.en.md)

Сохранены исходные IDs 11,12,41,48,50,51,55,57; добавлен 86. LMX-обработчики размещаются в исполняемых Message с одной полосой записи и собственными аренами. Между владельцами используются post/send/receive и уже описанный HTTP-профиль §32: endpoint+route, application/lmx, intake/admission, синхронный reply либо replyTo/correlation. Обозначения transport/db/store/coordinator в листингах — явно перечисленные адаптерные контракты, не новые встроенные ресиверы. Их реализация одинаково исключена из всех трёх листингов и длины кода. Серийный turn не заменяет транзакцию БД, consensus, долговременный журнал или дедупликацию. Код собственный; источники задают смысл и ограничения паттернов. LMX-фикстура заранее помещает зависимости и начальное состояние в фактический DATA владельца; входы с потенциальной неоднозначностью позиции передаются явно по имени. Например, account\debit(amount := 30). Листинги контролей рассчитаны на Python 3.10+, C# 12, Java 17 и Go 1.18+ там, где соответствующий язык присутствует.

[LMX_Comparison_04_events_and_consistency.xlsx](LMX_Comparison_04_events_and_consistency.xlsx) · [LMX_Comparison_04_events_and_consistency.pdf](LMX_Comparison_04_events_and_consistency.pdf) · [LMX_Comparison_04_events_and_consistency.md](LMX_Comparison_04_events_and_consistency.md)

Редактируемый источник материалов — patterns.json. Листинги вынесены в examples.
