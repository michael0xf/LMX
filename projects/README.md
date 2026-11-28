# Планы реализации LMX

Общую очередь, зависимости и состояние работ задают [план v3](../next_core_tasks_v3.md#grammar-first-20261126) и [чеклист приёмки](../next_core_tasks_v3_checklist.md). Здесь собраны технические этапы. Языковой договор и представление данных ведутся в [документации](../docs/spec/README.md).

| Область | Реализация и приёмка | Нормативный договор |
| --- | --- | --- |
| Написание идентификатора, имена полей, профильные ключи | [Миграция и десять проверок](graph-input.md#names-rollout) | [Ключи полей](../docs/spec/reference/field-name-keys.md) |
| Текст Message и исходного файла | [Файл, память, кодек и проверка графа](graph-input.md#from-lmx-research) | [Ресивер fromLmx](../docs/spec/LMX_semantics.ru.md#from-lmx-contract) |
| Типизированная запись и размеры Array | [Переход потребителей ABI](kernel-runtime.md#type-layout) | [TypeRef](../docs/spec/TYPE_REFERENCES.md) · [Хранение](../docs/spec/ARRAY_STORAGE.ru.md) |
| Интерпретатор и runtime SLJIT | [Этапы и измерения](kernel-runtime.md#jit-rollout) | [Общие операции и ABI](../docs/spec/INTERPRETER_AND_NATIVE.md) |
| Тензорные выражения и матричные методы | [Этапы 0–8](tensor-expressions.md#integration-v3) | [Группировщик](../docs/spec/EXPRESSION_ALGORITHM.md) · [Тензорные операции](../docs/spec/TENSOR_EXPRESSIONS.md) |
