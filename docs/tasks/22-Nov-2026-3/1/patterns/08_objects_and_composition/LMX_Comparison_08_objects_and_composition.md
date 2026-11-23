# Сравнение: Объекты, зависимости и композиция

Контрольные языки: **Java, Python**. Дата редакции: 2026-11-22.

Числа — непробельные символы / непустые строки показанных листингов. Комментарии включены. Использование библиотеки и её реализация имеют отдельные строки; граница одинакова для трёх языков.

| ID | Паттерн | LMX | Java | Python | Граница |
| ---: | --- | ---: | ---: | ---: | --- |
| 072 | [Dependency Injection](072_dependency_injection_comparision.md) | 163 / 13 | 246 / 9 | 154 / 7 | Ядро сценария |
| 073 | [Service Locator](073_service_locator_comparision.md) | 223 / 19 | 238 / 8 | 151 / 7 | Ядро сценария |
| 074 | [Null Object](074_null_object_comparision.md) | 138 / 13 | 205 / 9 | 98 / 7 | Ядро сценария |
| 075 | [Object Pool](075_object_pool_comparision.md) | 266 / 22 | 350 / 14 | 280 / 16 | Ядро сценария |
| 076 | [Simple Factory](076_simple_factory_comparision.md) | 201 / 17 | 155 / 5 | 141 / 7 | Ядро сценария |
| 077 | [Multiton](077_multiton_comparision.md) | 246 / 21 | 283 / 13 | 291 / 13 | Ядро сценария |
| 078 | [Marker Interface](078_marker_interface_comparision.md) | 175 / 13 | 238 / 7 | 177 / 10 | Ядро сценария |
| 079 | [Fluent Interface](079_fluent_interface_comparision.md) | 285 / 19 | 251 / 9 | 220 / 11 | Ядро сценария |
| 080 | [Type Object](080_type_object_comparision.md) | 225 / 16 | 283 / 11 | 265 / 14 | Ядро сценария |
| 081 | [Extension Object](081_extension_object_comparision.md) | 255 / 21 | 285 / 12 | 308 / 16 | Ядро сценария |

Java показывает номинальные интерфейсы, классы и явные объектные контракты; Python — динамическую композицию и функции. Такое сравнение не вынуждает все языки копировать Java-иерархии и выявляет реальные различия nominal/structural.

[Методика](../COMPARISON_METHODOLOGY.ru.md). [Проверка](../VALIDATION.md).

Суммарный рейтинг языков по разным группам не строится: состав языков, внешние библиотеки и класс задачи различаются.
