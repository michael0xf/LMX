# Отдельная диагностика inline singleton

[Исходник](inline_singleton_mismatch.lm3) имеет внешнюю длину 2 слева и 1 у
`[arr2]`. Array из одного элемента не является scalar broadcast. Ожидается
диагностика транслятора либо интерпретатора, без нового catchable exception.
Полный текст и ожидание — в [общем README](../README.md). Production NOT_RUN.
