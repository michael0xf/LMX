# Отдельные ожидаемые отказы и диагностика

Эти исходники преднамеренно не завершаются успешным результатом при указанных
входах. Все тексты, вызовы, входы и ожидаемое состояние назначения приведены
в [общем README](../README.md#отдельные-отрицательные-fixtures).
Production parser/translator/runtime: **NOT_RUN**. Структурные ошибки ранга,
формы и непригодное выражение fuse — диагностика транслятора/интерпретатора,
а не введённые здесь языковые исключения.

- [014_shape_mismatch.lm3](014_shape_mismatch.lm3): Отказ: число элементов не совпадает; singleton Array не скаляр.
- [015_admission_before_writes.lm3](015_admission_before_writes.lm3): Отказ допуска второго элемента до любых записей.
- [016_fuse_contraction.lm3](016_fuse_contraction.lm3): Отказ: fuse не превращает свёртку в поэлементное умножение.
- [019_frame_mismatch.lm3](019_frame_mismatch.lm3): При depth=1 внешние frames имеют разные размеры.
- [020_excess_depth.lm3](020_excess_depth.lm3): Глубина обхода 2 превышает rank=1 входного Array.
- [023_broadcast_mismatch.lm3](023_broadcast_mismatch.lm3): Несовместимый broadcast RHS среза.
