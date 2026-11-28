# Асинхронность, исполнители и Message

Редакция 28 ноября 2026 года. Полные размеры листингов.

## Асинхронность, исполнители и Message

### Сравнения

| ID | Сценарий | LMX | Go | Erlang | Слой |
| --- | --- | --- | --- | --- | --- |
| 058 | Thread Pool | <span style="color:#176233"><u>233</u></span> | 290 | 322 | Сценарий |
| 059 | Producer-Consumer | 225 | <span style="color:#176233"><u>154</u></span> | 276 | Сценарий |
| 060 | Actor Model | <span style="color:#176233"><u>100</u></span> | 141 | 144 | Сценарий |
| 061 | Active Object | <span style="color:#176233"><u>143</u></span> | 247 | 194 | Сценарий |
| 062 | Reactor | <span style="color:#176233"><u>100</u></span> | 157 | 168 | Сценарий |
| 063 | Proactor | 140 | 214 | <span style="color:#176233"><u>106</u></span> | Сценарий |
| 064 | Future / Promise | 268 | <span style="color:#176233"><u>256</u></span> | 292 | Сценарий |
| 071 | Half-Sync / Half-Async | <span style="color:#176233"><u>174</u></span> | 205 | 259 | Сценарий |
| 088 | Structured Concurrency | <span style="color:#176233"><u>316</u></span> | 517 | 602 | Сценарий |
| 089 | Supervision Tree | 204 | <span style="color:#176233"><u>181</u></span> | 269 | Сценарий |
| 090 | MapReduce | <span style="color:#176233"><u>216</u></span> | 290 | 267 | Сценарий |
| 109 | Request-Response / Ask | 930 | <span style="color:#176233"><u>799</u></span> | 1024 | Сценарий |
| 110 | Become / Selective Stash | 1144 | <span style="color:#176233"><u>936</u></span> | 1120 | Сценарий |
| 111 | Phased Message Lifecycle | 1562 | <span style="color:#176233"><u>1233</u></span> | 1858 | Сценарий |
| 112 | External Blocking Adapter | <span style="color:#176233"><u>877</u></span> | 1031 | 1109 | Сценарий |

Go показывает каналы и goroutine, Erlang — изолированные процессы, mail и OTP supervision. Это характерные контроли для Message-модели LMX. Сравнения явно различают логического исполнителя, OS thread, readiness и завершение I/O.

15 сравнений: базовые исполнители/Message, structured concurrency, supervision, MapReduce и четыре явных прикладных протокола 109–112. Message сохраняет штатное исполнение; физические блокирующие native операции остаются на L2 boundary.

Считаются все непробельные Unicode-символы полного показанного листинга, включая объявления, локальные вспомогательные методы, комментарии и Throws. Списки ошибок копируются из вызываемых методов там, где это сохраняет контракт; текст copy и всех дополнительных отказов входит в размер. Зелёным подчёркивается минимальное число в сопоставимой строке; при равенстве — все победители.

LMX parser/runtime: NOT_RUN для изменённых листингов. Проверки исходников и публикации не являются исполнением языка. Размер кода не измеряет скорость или расход памяти.

Одинаковые числовые данные используются в Markdown, PDF и XLSX. Машинный источник — PUBLICATION_DATA.json в корне каталога patterns; генератор — tools/build_publication_data.py.
