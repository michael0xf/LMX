# Сравнение: Облако, HTTP и отказоустойчивость

Контрольные языки: **Go, C#**. Дата редакции: 2026-11-21.

Числа — непробельные символы / непустые строки показанных листингов. Комментарии включены. Использование библиотеки и её реализация имеют отдельные строки; граница одинакова для трёх языков.

| ID | Паттерн | LMX | Go | C# | Граница |
| ---: | --- | ---: | ---: | ---: | --- |
| 038 | [Circuit Breaker](038_circuit_breaker_comparision.md) | 216 / 18 | 205 / 8 | 200 / 10 | Протокол и порты |
| 039 | [Retry](039_retry_comparision.md) | 102 / 8 | 112 / 4 | 125 / 4 | Использование библиотеки |
| 097 | [Retry Library — Implementation](097_retry_library_implementation_comparision.md) | 363 / 23 | 276 / 14 | 420 / 20 | Реализация библиотеки |
| 040 | [Bulkhead](040_bulkhead_comparision.md) | 113 / 11 | 238 / 7 | 196 / 6 | Протокол и порты |
| 042 | [API Gateway](042_api_gateway_comparision.md) | 189 / 10 | 227 / 9 | 175 / 7 | Протокол и порты |
| 043 | [Backends for Frontends](043_backends_for_frontends_comparision.md) | 146 / 10 | 136 / 3 | 130 / 3 | Протокол и порты |
| 044 | [Sidecar](044_sidecar_comparision.md) | 132 / 12 | 130 / 4 | 204 / 5 | Протокол и порты |
| 045 | [Ambassador](045_ambassador_comparision.md) | 162 / 9 | 177 / 5 | 167 / 5 | Использование библиотеки |
| 049 | [Cache-Aside](049_cache_aside_comparision.md) | 182 / 15 | 234 / 7 | 222 / 9 | Протокол и порты |
| 052 | [Throttling](052_throttling_comparision.md) | 179 / 14 | 177 / 7 | 170 / 9 | Протокол и порты |
| 053 | [Queue-Based Load Leveling](053_queue_based_load_leveling_comparision.md) | 113 / 10 | 189 / 6 | 202 / 7 | Протокол и порты |
| 054 | [Competing Consumers](054_competing_consumers_comparision.md) | 285 / 27 | 233 / 9 | 445 / 11 | Протокол и порты |
| 056 | [Health Endpoint Monitoring](056_health_endpoint_monitoring_comparision.md) | 96 / 9 | 84 / 5 | 77 / 2 | Протокол и порты |
| 087 | [Backpressure](087_backpressure_comparision.md) | 184 / 16 | 194 / 6 | 166 / 8 | Протокол и порты |

Go и C# дают два привычных стиля сетевых сервисов: функции/каналы и .NET delegates/Channel. Сравнивается прикладной алгоритм поверх одинаково описанных transport/provider контрактов; развёртывание учитывается отдельно.

[Методика](../COMPARISON_METHODOLOGY.ru.md). [Проверка](../VALIDATION.md).

Суммарный рейтинг языков по разным группам не строится: состав языков, внешние библиотеки и класс задачи различаются.
