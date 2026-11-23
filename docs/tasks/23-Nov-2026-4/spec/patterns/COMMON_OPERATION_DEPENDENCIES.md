# Общие реализации примеров и их зависимости

Примеры 093–097 используют канонические определения одного ядра. Прикладные предикаты и проекции задают отдельный договор, но не повторяют общий алгоритм. Листинги в каталогах являются автоматически обновляемыми копиями для публикации. Источник каждой реализации указан ниже.

| Пример | Общие определения | Размер первичного листинга, символы | Зависимости |
| --- | --- | ---: | --- |
| 093 | [FxPipe](LMX_Fn_Receivers/src/coreGenericOperations.lmx) | 399 | 48 определений |
| 094 | [FxFindFirst](LMX_Fn_Receivers/src/coreComparisonGroups.lmx) | 371 | 47 определений |
| 095 | [FxAllOfTypeToken](LMX_Fn_Receivers/src/coreComparisonGroups.lmx), [FxAllOfState](LMX_Fn_Receivers/src/coreComparisonGroups.lmx), [FxAllOfEngine](LMX_Fn_Receivers/src/coreComparisonGroups.lmx), [FxAllOf](LMX_Fn_Receivers/src/coreComparisonGroups.lmx) | 1673 | 51 определений |
| 096 | [FxEquals](LMX_Fn_Receivers/src/coreGenericOperations.lmx) | 248 | 45 определений |
| 097 | [FxRetryValue](LMX_Fn_Receivers/src/coreGenericOperations.lmx) | 608 | 47 определений |

Полные исходники и контрольные суммы зависимостей находятся в [машинном реестре](validation/common_operation_dependencies.json). Каждое определение считается один раз внутри выбранного компонента. Между компонентами зависимости пересекаются.

Полный конечный throws сохраняется и учитывается целиком: заголовки, все аргументы и ссылки на общий банк. Никакая часть объявления ошибок не исключается из подсчёта.

Контрольные языки сохраняют опубликованные исходники и свой прикладной профиль. Это не сравнение полного охвата всех стандартных библиотек. Source accounting не заменяет исполнение: LMX runtime — NOT_RUN.

Воспроизведение: python3 tools/sync_common_operation_examples.py, затем обычная регенерация публикаций и метрик.
