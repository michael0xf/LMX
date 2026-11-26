# Научные форматы, netCDF-5 и MPI

Первичные записи этого решения находятся в
[scientific_profiles.lmx](../types/scientific_profiles.lmx),
[common_models.lmx](../types/common_models.lmx) и
[converters.lmx](../types/converters.lmx). Версии библиотек, профиль сборки и
публичные C API берутся из компонентных LMX-каталогов; этот файл объясняет
названия форматов и общий договор данных.

## Что означает netCDF-5

**netCDF-5 / CDF-5 — действительное название формата.** Upstream `ncgen`
употребляет его в собственной документации; `-5`, `-k nc5`, `-k cdf5` и
«64-bit data» обозначают соответствующий выбор формата. В C API используются
`NC_CDF5` / `NC_64BIT_DATA` и идентификатор `NC_FORMAT_CDF5`. Имя формата
сохраняется в каталоге вместе с этими aliases. Версия пакета netCDF-C
учитывается отдельно; библиотека 4.x может читать и писать формат netCDF-5.
Основание: [ncgen.1 версии 4.10.1](https://github.com/Unidata/netcdf-c/blob/v4.10.1/ncgen/ncgen.1)
и [разбор параметров ncgen](https://github.com/Unidata/netcdf-c/blob/v4.10.1/ncgen/main.c).

| Формат | Выбор при создании | Отношение к HDF5 |
|---|---|---|
| netCDF classic / CDF-1 | Обычный classic profile | Собственное CDF-кодирование |
| netCDF 64-bit offset / CDF-2 | `NC_64BIT_OFFSET` | Собственное CDF-кодирование |
| **netCDF-5 / CDF-5** | `NC_CDF5` / `NC_64BIT_DATA` | Собственное CDF-кодирование |
| netCDF-4 | `NC_NETCDF4` | Хранение через HDF5 backend |
| netCDF-4 classic model | `NC_NETCDF4 \| NC_CLASSIC_MODEL` | HDF5 storage с ограничением модели данных |

Эта таблица описывает форматы, а доступность конкретного драйвера проверяется
по выбранной сборке. Проверка CDF-5 должна включать запись одним из netCDF-C и
PnetCDF с чтением другим, чтение фактического format ID и значений за пределом
32-битного диапазона. Создание любого файла с расширением `.nc` само по себе
такой проверкой не является. В выбранной сборке cross-read и format checks прошли;
MPI-проверки выполнялись с одним rank. Подробности и границы результата —
в [scientific_netcdf/VERIFICATION.json](../../../third_party/lmx_c99_compact/extensions/scientific_netcdf/VERIFICATION.json)
и [PnetCDF/VERIFICATION.json](../../../third_party/lmx_c99_compact/extensions/scientific_pnetcdf/VERIFICATION.json).

## Одна модель массива, разные ресурсы

Все перечисленные backend используют общий `Tensor` и явный `Hyperslab`.
File/dataset/variable handles остаются ресурсами соответствующего владельца.
Общие данные не делают взаимозаменяемыми HDF5 `hid_t`, netCDF `ncid`, PnetCDF
request ID или MPI communicator. Нельзя передать число с тем же машинным
размером вместо проверенного живого ресурса. Различия между file selection и
memory layout проверяет конвертер `scientificSelection`.

MPI добавляет `MpiContext`, а не новый языковой runtime. Акторы одного
процесса могут держать ссылки на разрешённый owner-bound communicator с
учётом фактически предоставленного thread support. Между процессами и
узлами переносится протокол создания/согласования ресурса; raw handle не
имеет самостоятельного переносимого смысла. Коллективный I/O, независимый
режим, порядок участия и завершение запросов явно входят в договор
`mpiResource`. Подробности и первоисточники — в
[описании общих моделей](../types/README.ru.md#научные-массивы-и-локальная-распределённая-работа).

`independent: immutable:` определения этих моделей, пакетов и CODE
используются по ссылке. Открытые файлы, MPI requests и изменяемые рабочие
буферы не возникают от одного факта публикации общей ветви. Для HDF5,
netCDF, MAT и PnetCDF не вводятся новые числовые primitives; существующие
`bigint`, `decimal`, `real` и машинные типы преобразуются в поддерживаемые
форматом значения по явному договору точности.
