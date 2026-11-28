# Воспроизводимые native-проверки матричных backends

Эта директория — **C99/Python инструмент проверки исходных библиотек**. Она не является реализацией LMX, примером синтаксиса LMX или заменой его парсера. LMX-подключение находится в соседних `ports.lmx`, `backend_profiles.lmx`, `calls.lmx`.

`run_host_probe.py` проверяет SHA-256 рассмотренных vendor/build files по соседнему `validation_report.json`, создаёт generated views в отдельной output-директории, компилирует 28 выбранных C translation units и запускает 12 различающих случаев. Vendor остаётся только для чтения. Нужны Python 3, C99 compiler с указанными GCC/Clang-compatible flags, libm и `nm`; CMake не требуется.

Пример запуска проверочного инструмента из корня проекта:

```sh
python3 doc/core_catalog/matrix/validation/run_host_probe.py \
  --collection third_party/lmx_c99_compact \
  --output /tmp/lmx-matrix-native-review
```

Для дерева с именем `docs` вместо `doc` путь первого аргумента соответственно меняется. `--cc` выбирает один compiler executable; shell-фрагмент не принимается. Native stdout содержит как JSON-наблюдения, так и настоящие сообщения liquid; runner извлекает только JSON-строки.

В output сохраняются точный argv-командный список, build/execute logs, `nm` output, SHA-256 проверочных исходников и каждой скомпилированной единицы, `report.json`. Флаги включают `-std=c99 -pedantic-errors -O0 -ffp-contract=off`. Generated acoustic/Mint views создают существующие scripts из архива; Utensil применяет ровно две замены из проверенного `UtensilView.cmake`. Liquid compile-time metadata помечает отдельный selected-source probe.

Случаи с singular inverse и unpivoted LU намеренно подтверждают **ограничения** upstream: внутренний отказ теряется либо появляются nonfinite факторы при внешнем success. `pass=true` здесь означает воспроизведённый контрпример; это не утверждение, что общий LMX solve корректен. Остальные случаи различают порядок right division, transpose/adjoint, square-only QR, rectangular pivoted QR, fixed-point overflow, GF(2), symmetric eig и два dense tensor products.

Production LMX parser/runtime, C-shim bridge, полная штатная CMake/CTest-сборка, GPU, внешний BLAS/LAPACK и широкие stability/performance tests этим инструментом не запускаются. Старые отчёты коллекции он не меняет.

## Отдельные целочисленные и floating-format проверки

[Целочисленный oracle](matrix_power_integer_host.c) проверяет разложение
показателя, порядок квадратов и число умножений для знакового C99 деления
с усечением к нулю, включая INT32/INT64 MIN/MAX. В
[результате](matrix_power_integer_host.json) — 20 037 входных случаев,
0 failures. Он проверяет управляющую арифметику `FxMatrixPower`, а не
исполнение LMX или точность матричных умножений.

[FP16 probe](fp16_format_host.c) обращается к настоящему header из
`vendor/fp16/include`; [результат](fp16_format_host.json) — 9 случаев,
0 failures. Различаются IEEE и ARM alternative half, signed zero,
subnormal, infinity и NaN. Это проверка native формата, не исполненный
конвертер `binaryFloatFormat` из LMX.

Оба инструмента запускались с UndefinedBehaviorSanitizer. Точные argv и результаты
сохранены в [type_probe_report.json](type_probe_report.json). Воспроизводимый
отдельный запуск из корня проекта, с результатами вне исходников:

```sh
cc -std=c99 -fsanitize=undefined -fno-sanitize-recover=undefined \
  doc/core_catalog/matrix/validation/matrix_power_integer_host.c \
  -o /tmp/lmx-matrix-power-integer-host
/tmp/lmx-matrix-power-integer-host
cc -std=c99 -fsanitize=undefined -fno-sanitize-recover=undefined \
  -I third_party/lmx_c99_compact/vendor/fp16/include \
  doc/core_catalog/matrix/validation/fp16_format_host.c \
  -lm -o /tmp/lmx-fp16-format-host
/tmp/lmx-fp16-format-host
```
