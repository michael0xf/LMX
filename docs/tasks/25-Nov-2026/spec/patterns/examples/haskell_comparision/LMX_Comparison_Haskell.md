# LMX / Haskell

Редакция 24 ноября 2026 года. Полные размеры листингов.

## LMX / Haskell

### Прикладные сценарии

| ID | Сценарий | LMX процедурный | LMX функциональный | Haskell | Граница |
| --- | --- | --- | --- | --- | --- |
| H01 | Replace and invoke a first-class callable | <span style="color:#176233"><u>191</u></span> | <span style="color:#176233"><u>191</u></span> | 256 | Полная пара |
| H02 | Named signature positions versus candidate names | 245 | 215 | 332 | Аналогия |
| H03 | Independent bound prefixes and residual callable admission | 495 | 239 | <span style="color:#176233"><u>137</u></span> | Полная пара |
| H04 | Overrideable copied default | 265 | 205 | <span style="color:#176233"><u>162</u></span> | Полная пара |
| H05 | Dynamic and lexical binding after a graph copy | 218 | 206 | 362 | Аналогия |
| H06 | Order of two composed computations | 223 | 167 | <span style="color:#176233"><u>67</u></span> | Полная пара |
| H07 | Prepared value versus raw source occurrence | 354 | 354 | 582 | Аналогия |
| H08 | Owned formal copy versus caller place | 94 | 94 | 285 | Аналогия |
| H09 | Finite iterator with a live declaration and body | 285 | 285 | 569 | Аналогия |
| R01 | Merge an existing record and add a field | 184 | 183 | 293 | Аналогия |
| R02 | Copy a field stream into group assignment | 93 | 93 | 192 | Аналогия |
| R03 | Imported parent identity versus copied parent identity | 226 | 226 | 568 | Аналогия |
| R04 | Computed initializer, local write and repeated activation | 383 | 383 | 514 | Аналогия |
| R06a | Graph copy preserving shared targets | 189 | 189 | 909 | Аналогия |
| R06b | Graph copy preserving a cycle | 139 | 139 | 911 | Аналогия |
| R07 | User operand and preserved computation | 159 | 159 | 217 | Аналогия |
| R09 | Uninitialized payload and local versus graph write | 189 | 189 | 454 | Аналогия |
| A01 | Shared structural slots and replacement field identity | 126 | 126 | 486 | Аналогия |
| V02 | Whole ASCII ticket-code predicate | 226 | 160 | <span style="color:#176233"><u>146</u></span> | Полная пара |
| V03 | Inject a read dependency and check interaction counts | 308 | <span style="color:#176233"><u>298</u></span> | 459 | Полная пара |
| V04 | Distinguish a named failure from a numeric result | <span style="color:#176233"><u>160</u></span> | <span style="color:#176233"><u>160</u></span> | 257 | Полная пара |
| V05 | Command/read integration check and fault modes | <span style="color:#176233"><u>547</u></span> | <span style="color:#176233"><u>547</u></span> | 885 | Полная пара |
| M01 | Serial state updates at one Message owner | <span style="color:#176233"><u>93</u></span> | <span style="color:#176233"><u>93</u></span> | 425 | Полная пара |
| M05 | Void Message procedure without a fabricated reply | 49 | 49 | 289 | Аналогия |
| Итого | — | 2508 | <span style="color:#176233"><u>2060</u></span> | 2794 | — |

Итоги включают только полные пары. Аналогии и отсутствие контрольного листинга не считаются нулём.

Для функциональных клиентских сценариев опубликованы оба варианта LMX: процедурный с явным алгоритмом и функциональный с общими операциями и композицией. Они сохраняют один наблюдаемый договор. Выбор единственного варианта по краткости не производится. Общие реализации библиотеки учитываются отдельно и не размножаются по стилям.

Считаются все непробельные Unicode-символы полного показанного листинга, включая объявления, локальные вспомогательные методы, комментарии и Throws. Списки ошибок копируются из вызываемых методов там, где это сохраняет контракт; текст copy и всех дополнительных отказов входит в размер. Зелёным подчёркивается минимальное число в сопоставимой строке; при равенстве — все победители.

LMX parser/runtime: NOT_RUN для изменённых листингов. Проверки исходников и публикации не являются исполнением языка. Размер кода не измеряет скорость или расход памяти.

## Общие реализации

### Общие реализации библиотеки

| ID | Операции | LMX — реализация | Контроль |
| --- | --- | --- | --- |
| H01 | apply | 2083 | <span style="color:#176233"><u>79</u></span> |
| H03 | partial | 16390 | <span style="color:#176233"><u>699</u></span> |
| H06 | compose | 14403 | <span style="color:#176233"><u>389</u></span> |
| H07 | lazy, once | 14590 | <span style="color:#176233"><u>1309</u></span> |
| H09 | Cycles\iterate | <span style="color:#176233"><u>73</u></span> | 644 |
| V02 | between | <span style="color:#176233"><u>250</u></span> | 315 |
| R01 | derive / record composition | <span style="color:#176233"><u>71</u></span> | 108 |

Полные указанные тела сравниваются отдельно от клиентов. Пересекающиеся зависимости нельзя складывать повторно.

Считаются все непробельные Unicode-символы полного показанного листинга, включая объявления, локальные вспомогательные методы, комментарии и Throws. Списки ошибок копируются из вызываемых методов там, где это сохраняет контракт; текст copy и всех дополнительных отказов входит в размер. Зелёным подчёркивается минимальное число в сопоставимой строке; при равенстве — все победители.

LMX parser/runtime: NOT_RUN для изменённых листингов. Проверки исходников и публикации не являются исполнением языка. Размер кода не измеряет скорость или расход памяти.

Одинаковые числовые данные используются в Markdown, PDF и XLSX. Машинный источник — PUBLICATION_DATA.json в корне каталога patterns; генератор — tools/build_publication_data.py.
