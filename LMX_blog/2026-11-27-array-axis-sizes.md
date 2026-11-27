# Массив размеров осей в префиксе типа

Техническая выдержка из сообщения автора в чате Sol 27 ноября 2026 года.

```text
форму описания типа "[]\(sizes)type" где sizes -- не число а массив чисел
[]int: sizes [2 2 3 3]
[]\(sizes)type: customTypeArray
которая объявлет тип
[2][2][3][3]type: customTypeArray
```

[Договор массива размеров](../docs/spec/TYPE_DECLARATION_FORMS.md#extent-vector-prefix).
