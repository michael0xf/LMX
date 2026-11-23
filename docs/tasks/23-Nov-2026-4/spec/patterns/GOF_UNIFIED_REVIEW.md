# Проверка 23 корневых GoF-примеров

Прочитаны текущие LMX-листинги всех23 сравнений. Сокращения из предыдущего состояния именно загруженного архива сохранены вместе с их вариантами. Новые sequence/Pattern/factory-обертки не добавлены там, где они меняют проверяемый механизм либо делают этот конкретный исходник длиннее. Это семантическое чтение исходников, не запуск программ.

| № | Пример | Решение |
| --- | --- | --- |
| 01 | [01_iterator_comparison.md](01_iterator_comparison.md) | Живой Stop-итератор и объявление item; материализованный range заменил бы проверяемый механизм. |
| 02 | [02_strategy_comparison.md](02_strategy_comparison.md) | Смена callable-ссылки уже выражена прямо; добавление adapter/compose увеличивает код. |
| 03 | [03_factory_method_node_prototype_comparison.md](03_factory_method_node_prototype_comparison.md) | Фабричные методы сохраняют DATA и копирование продукта; sequence helper не заменяет этот сценарий. |
| 04 | [04_adapter_comparison.md](04_adapter_comparison.md) | Явная перестановка двух actuals короче общей фабрики с ее контрактом; библиотечная граница контролей сохраняется. |
| 05 | [05_observer_comparison.md](05_observer_comparison.md) | Порядок двух уведомлений и отдельные записи в состояние видимы; общий обход добавил бы код и иной транспорт. |
| 06 | [06_decorator_comparison.md](06_decorator_comparison.md) | Два прямых декоратора уже коротки; общий compose не нужен для фиксированных тел. |
| 07 | [07_command_comparison.md](07_command_comparison.md) | Проверяется изменение текущего caller place через команды; capture/partial не подставлены вместо этого механизма. |
| 08 | [08_template_method_comparison.md](08_template_method_comparison.md) | Динамические prepare/finish и явная передача промежуточного значения сохраняют смысл template method. |
| 09 | [09_visitor_comparison.md](09_visitor_comparison.md) | Обработка NoAction и динамические actions не сводятся к collection predicate. |
| 10 | [10_state_comparison.md](10_state_comparison.md) | Изменяемая ссылка state непосредственно задает переходы; новых контейнеров не требуется. |
| 11 | [11_chain_of_responsibility_comparison.md](11_chain_of_responsibility_comparison.md) | Короткое замыкание цепочки с различными ненулевыми результатами; any потерял бы код обработчика. |
| 12 | [12_composite_comparison.md](12_composite_comparison.md) | Текущий короткий derive-вариант и procedural уже сохранены; новые sequences не укорачивают дерево. |
| 13 | [13_proxy_comparison.md](13_proxy_comparison.md) | Возврат0 при запрете и переключение на real отличаются от generic guard с failure. |
| 14 | [14_facade_comparison.md](14_facade_comparison.md) | Прямые составные операции quote уже не требуют дополнительного receiver. |
| 15 | [15_builder_comparison.md](15_builder_comparison.md) | Сохраняются обе изменяемые стороны Rectangle, builder state и независимые копии. |
| 16 | [16_prototype_comparison.md](16_prototype_comparison.md) | Текущий короткий bindFields и исходное копирование сохранены; независимые состояния не заменяются общим alias. |
| 17 | [17_memento_comparison.md](17_memento_comparison.md) | Нужны две полные точки восстановления и копии графа; slice массива не является заменой snapshot. |
| 18 | [18_bridge_comparison.md](18_bridge_comparison.md) | Независимая смена control/output и изменение level сохранены. |
| 19 | [19_singleton_comparison.md](19_singleton_comparison.md) | Сохраняется identity одного Settings; once/lazy добавили бы другой механизм/вызов. |
| 20 | [20_abstract_factory_comparison.md](20_abstract_factory_comparison.md) | Текущий derive-вариант и прежний merge сохранены; вся семья Button/Frame и data coupling сохранены. |
| 21 | [21_flyweight_comparison.md](21_flyweight_comparison.md) | Ширина glyph и внешняя position обязательны; поля width присутствуют во всех8 языках. |
| 22 | [22_mediator_comparison.md](22_mediator_comparison.md) | Сохраняются связи control/fan и уведомления; общий callback wrapper не укорачивает сценарий. |
| 23 | [23_interpreter_comparison.md](23_interpreter_comparison.md) | Это проверка пользовательского operand template; замена на встроенный plus удалила бы предмет примера. |
