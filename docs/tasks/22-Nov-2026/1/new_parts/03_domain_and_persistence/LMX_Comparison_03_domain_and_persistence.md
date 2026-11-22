# Сравнение: Доменная модель и хранение данных

Контрольные языки: **Python, C#**. Дата редакции: 2026-11-22.

Числа — непробельные символы / непустые строки показанных листингов. Комментарии включены. Использование библиотеки и её реализация имеют отдельные строки; граница одинакова для трёх языков.

| ID | Паттерн | LMX | Python | C# | Граница |
| ---: | --- | ---: | ---: | ---: | --- |
| 016 | [Repository](016_repository_comparision.md) | 96 / 8 | 194 / 9 | 212 / 6 | Использование библиотеки |
| 094 | [FindById — implementation](094_find_by_id_implementation_comparision.md) | 227 / 17 | 68 / 5 | 266 / 13 | Реализация библиотеки |
| 017 | [Unit of Work](017_unit_of_work_comparision.md) | 226 / 18 | 233 / 11 | 339 / 14 | Ядро сценария |
| 018 | [Data Mapper](018_data_mapper_comparision.md) | 244 / 17 | 260 / 13 | 302 / 15 | Ядро сценария |
| 019 | [Active Record](019_active_record_comparision.md) | 159 / 12 | 229 / 8 | 300 / 10 | Ядро сценария |
| 020 | [Table Data Gateway](020_table_data_gateway_comparision.md) | 169 / 9 | 214 / 6 | 280 / 8 | Ядро сценария |
| 021 | [Row Data Gateway](021_row_data_gateway_comparision.md) | 121 / 7 | 176 / 5 | 214 / 5 | Ядро сценария |
| 022 | [DAO — Data Access Object](022_dao_comparision.md) | 198 / 17 | 214 / 8 | 349 / 11 | Ядро сценария |
| 023 | [DTO — Data Transfer Object](023_dto_comparision.md) | 155 / 11 | 145 / 7 | 197 / 5 | Ядро сценария |
| 024 | [Domain Model](024_domain_model_comparision.md) | 144 / 10 | 179 / 6 | 224 / 9 | Ядро сценария |
| 025 | [Transaction Script](025_transaction_script_comparision.md) | 232 / 15 | 222 / 8 | 387 / 16 | Ядро сценария |
| 026 | [Table Module](026_table_module_comparision.md) | 131 / 11 | 142 / 7 | 224 / 9 | Ядро сценария |
| 027 | [Service Layer](027_service_layer_comparision.md) | 179 / 11 | 150 / 6 | 387 / 16 | Ядро сценария |
| 028 | [Identity Map](028_identity_map_comparision.md) | 98 / 9 | 148 / 6 | 245 / 12 | Ядро сценария |
| 029 | [Lazy Load](029_lazy_load_comparision.md) | 133 / 11 | 176 / 8 | 155 / 13 | Ядро сценария |
| 030 | [Query Object](030_query_object_comparision.md) | 178 / 10 | 254 / 8 | 294 / 8 | Ядро сценария |
| 031 | [Specification](031_specification_comparision.md) | 225 / 13 | 140 / 5 | 231 / 7 | Использование библиотеки |
| 095 | [Specification combinator — implementation](095_specification_combinator_implementation_comparision.md) | 372 / 22 | 83 / 4 | 176 / 8 | Реализация библиотеки |
| 032 | [Value Object](032_value_object_comparision.md) | 273 / 9 | 142 / 6 | 224 / 9 | Использование библиотеки |
| 096 | [Money value equality — implementation](096_money_value_equality_implementation_comparision.md) | 231 / 14 | 268 / 10 | 335 / 10 | Реализация библиотеки |
| 033 | [Optimistic Offline Lock](033_optimistic_offline_lock_comparision.md) | 114 / 9 | 100 / 3 | 242 / 7 | Ядро сценария |
| 034 | [Pessimistic Offline Lock](034_pessimistic_offline_lock_comparision.md) | 200 / 14 | 295 / 8 | 438 / 10 | Протокол и порты |

Python показывает компактные функции, dataclass и явные адаптеры; C# — records, интерфейсы и привычную организацию прикладного доступа к данным. LMX сопоставляется с обоими без обязательной иерархии классов.

[Методика](../COMPARISON_METHODOLOGY.ru.md). [Проверка](../VALIDATION.md).

Суммарный рейтинг языков по разным группам не строится: состав языков, внешние библиотеки и класс задачи различаются.
