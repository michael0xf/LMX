# Проверки и точные границы результата

**2026-11-28. Production LMX: NOT_RUN.** В переданном архиве есть документация, selfbuild и tests, но нет готового parser/runtime и полного bootstrap `l1src`. Нельзя превратить статическую проверку текста или host CPython в успешный запуск LMX.

| Проверка | Что действительно проверяет | Чего не доказывает |
| --- | --- | --- |
| `static_check.py` → `static_report.json` | 16 LMX-файлов: отсутствие пустых строк перед вложенным продолжением, баланс разделителей вне строк/комментариев, объявления, обычные ссылки на тела управления сессией и прямые Python-цели в примерах; восемь пар platform/Python страниц; локальные ссылки | Полную грамматику, типизацию, эффекты `throws`, lifetime, native execution |
| `run_host_probe.py` → `host_probe_report.json` | Компилирует C99 helper и вызывает настоящий host CPython C API: isolated init, object call, exception capture, None, UTF-8 с NUL, собственную reference из borrowed, buffer с negative byte stride, attach/release GIL | Установку выбранных дистрибутивов, production provider, LMX `py.*`, остальные ОС/ISA |
| [acceptance_cases.lmx](../examples/acceptance_cases.lmx) | Явные входы и ожидаемые различающие исходы для будущего LMX harness | Сам факт выполнения этих случаев |

Команды запуска из корня LMX:

```text
python3 include_languages/validation/static_check.py
python3 include_languages/validation/run_host_probe.py
```

C helper находится только в validation. Он проверяет внешнюю C API границу и не подменяет LMX-заготовки языком C. Python-скрипты здесь являются инструментами проверки артефакта; подключаемый язык приложения остаётся Python через `py.*`.

Static report фиксирует hashes входных файлов. Проверка намеренно не является вторым P0 и не должна расти в альтернативный parser. `balanced-delimiters` — название ограниченного текстового наблюдения, а не `parser PASS`.

## Следующая реальная приёмка

1. Проверить общий production P0 на слитной цели, целой цепочке атрибутов и точном имени LMX. В готовой сессии вызвать встроенную и пользовательскую функции через один переход. Отдельно проверить отсутствие цели, исключение тела и обычные LMX-вызовы `installPython`, `openPython` и `closePython`.
2. Реализовать native ports с проверкой фактического владельца сессии и её ресурсов; подключить LMX к выбранному shared CPython либо Pyodide, запустить factorial и все различающие отказы.
3. Проверить отказ во время каждого этапа установки: поколение до публикации не становится активным, старое поколение остаётся доступно. Выполнить реальный relocation и smoke imports совместимых native wheels.
4. Проверить потерю worker response после side effect, повтор того же sequence и конфликт payload; подтвердить единственный эффект и `unknown-outcome` без скрытого retry.
5. На каждой платформе отдельно проверить ABI/loader, shutdown, Android lifecycle и 16-KB native dependencies, WASM host boundary, RISC-V toolchain/ABI. Конкретные acceptance условия находятся в отдельных platform README и PYTHON.

В итоговых отчётах отдельно перечислены `NOT_RUN` и `REQUIRE_IMPLEMENTATION`. Наличие тела LMX не скрывает отсутствующий native loader или gate lowering.
