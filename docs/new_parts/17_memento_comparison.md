# 17. Memento: LMX и семь других языков

20 ноября 2026 года. Обновлено 21 ноября 2026 года. Продолжение серии: шаблоны 10–18.

## Задача

Editor сохраняет значения 5 и 9, затем меняется на 13. demo хранит два снимка, не разбирая их содержимое, и передаёт их владельцу для восстановления. Чтения после восстановления дают 5 и 9; результат 59.

**Внешний вызов LMX:** `Editor\demo()`. **Ожидаемый результат: 59.**

Это минимальный Memento с договором использования API: хранитель не читает и не изменяет внутренности снимка. Защита от намеренного доступа, неизменяемость снимка, проверка владельца и ограничение истории не заявляются ни в одном варианте. private LMX регулирует неявное связывание и не заменяет такую защиту. Состояние состоит из одного числа; внешние ресурсы не копируются.

## Архитектура LMX

Editor владеет state и операциями set/read. Вложенная группа history описывает вход snapshot и результат Editor. save возвращает явно сгруппированную копию живого графа Editor — `(copy(Editor))`; restore записывает сохранённое значение в лексическое поле node\state исходного Editor. Снимки не являются ссылками на один изменяемый state. Python использует ту же схему save/restore и копию объекта. [Потоки полей и группировка][S]

Применены согласованные правила: DATA метода — его фактический parent; обычные ссылки на методы не требуют отдельного `fn`; объявленные входы без initializer допускают autofill, свободные имена — связь с местом непосредственного caller. `node\` выбирает лексическую связь. Пустая строка завершает корневой блок. [Связывание][B] · [Импорт][D] · [Границы блоков][E]

## Подсчёт исходников

Главная метрика — **непробельные символы**: `sum(not ch.isspace() for ch in code)`. Дополнительно показаны полный размер и число физических строк. Нормализация: LF, без пустых строк по краям, один LF в конце.

В подсчёт входят весь показанный исходник, импорты, необходимые языковые оболочки и `demo`. Внешний запуск, `main`, печать результата, тестовая обвязка и реализация стандартной библиотеки/runtime не включены. Имена не нормализованы. Python записан без необязательных аннотаций типов. Сравниваются конкретные реализации одной задачи; это не оценка быстродействия или одинаковых статических гарантий.

| Язык | Непробельных символов | Всего символов | Строк | К размеру LMX |
|---|---:|---:|---:|---:|
| LMX | 333 | 562 | 26 | 1.00× |
| Python | 396 | 558 | 29 | 1.19× |
| Java | 460 | 786 | 36 | 1.38× |
| C++ | 381 | 562 | 32 | 1.14× |
| C# | 450 | 749 | 34 | 1.35× |
| TypeScript | 440 | 623 | 32 | 1.32× |
| Go | 450 | 591 | 34 | 1.35× |
| Rust | 456 | 649 | 35 | 1.37× |

Общая таблица серии доступна в [Excel](LMX_Comparison_10-18.xlsx) и [PDF](LMX_Comparison_10-18.pdf).

## 1. LMX

```lmx
Editor:
    int: value
    int: state 0
    return: int
    set:
        node\state := value
    read:
        return: state
    history:
        @: snapshot
        return: Editor
        save:
            return: (copy(Editor))
        restore:
            node\state := snapshot\state
    ---
    demo:
        set(5)
        @: first history\save()
        set(9)
        @: second history\save()
        set(13)
        history\restore(snapshot := first)
        int: low read()
        history\restore(snapshot := second)
        return: low * 10 + read()
```

Внешний вызов: `Editor\demo()`. Он не входит в подсчёт.

Первый save фиксирует 5, второй — 9. set(13) меняет только текущий Editor. restore(first) возвращает 5, которое сохраняется в low; restore(second) возвращает 9. Вычисляется 5×10+9. Хранитель вызывает только save, restore и обычный read текущего объекта.

## 2. Python

```python
from copy import copy

class Editor:
    def __init__(self):
        self.state = 0

    def set(self, value):
        self.state = value

    def read(self):
        return self.state

    def save(self):
        return copy(self)

    def restore(self, snapshot):
        self.state = snapshot.state

def demo():
    editor = Editor()
    editor.set(5)
    first = editor.save()
    editor.set(9)
    second = editor.save()
    editor.set(13)
    editor.restore(first)
    low = editor.read()
    editor.restore(second)
    return low * 10 + editor.read()
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## 3. Java

```java
class Example {
    static class Editor {
        int state;

        void set(int value) {
            state = value;
        }

        int read() {
            return state;
        }

        Editor save() {
            Editor snapshot = new Editor();
            snapshot.state = state;
            return snapshot;
        }

        void restore(Editor snapshot) {
            state = snapshot.state;
        }
    }

    public static int demo() {
        Editor editor = new Editor();
        editor.set(5);
        Editor first = editor.save();
        editor.set(9);
        Editor second = editor.save();
        editor.set(13);
        editor.restore(first);
        int low = editor.read();
        editor.restore(second);
        return low * 10 + editor.read();
    }
}
```

Внешний вызов: `Example.demo()`. Он не входит в подсчёт.

## 4. C++

```cpp
struct Editor {
    int state = 0;

    void set(int value) {
        state = value;
    }

    int read() const {
        return state;
    }

    Editor save() const {
        return *this;
    }

    void restore(const Editor& snapshot) {
        state = snapshot.state;
    }
};

int demo() {
    Editor editor;
    editor.set(5);
    auto first = editor.save();
    editor.set(9);
    auto second = editor.save();
    editor.set(13);
    editor.restore(first);
    int low = editor.read();
    editor.restore(second);
    return low * 10 + editor.read();
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## 5. C#

```csharp
static class Example {
    sealed class Editor {
        int state;

        public void Set(int value) {
            state = value;
        }

        public int Read() {
            return state;
        }

        public Editor Save() {
            return (Editor)MemberwiseClone();
        }

        public void Restore(Editor snapshot) {
            state = snapshot.state;
        }
    }

    public static int Demo() {
        var editor = new Editor();
        editor.Set(5);
        var first = editor.Save();
        editor.Set(9);
        var second = editor.Save();
        editor.Set(13);
        editor.Restore(first);
        int low = editor.Read();
        editor.Restore(second);
        return low * 10 + editor.Read();
    }
}
```

Внешний вызов: `Example.Demo()`. Он не входит в подсчёт.

## 6. TypeScript

```typescript
class Editor {
    state = 0;

    set(value: number): void {
        this.state = value;
    }

    read(): number {
        return this.state;
    }

    save(): Editor {
        return Object.assign(new Editor(), this);
    }

    restore(snapshot: Editor): void {
        this.state = snapshot.state;
    }
}

function demo(): number {
    const editor = new Editor();
    editor.set(5);
    const first = editor.save();
    editor.set(9);
    const second = editor.save();
    editor.set(13);
    editor.restore(first);
    const low = editor.read();
    editor.restore(second);
    return low * 10 + editor.read();
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## 7. Go

```go
package main

type Editor struct {
    state int
}

func (editor *Editor) set(value int) {
    editor.state = value
}

func (editor Editor) read() int {
    return editor.state
}

func (editor Editor) save() Editor {
    return editor
}

func (editor *Editor) restore(snapshot Editor) {
    editor.state = snapshot.state
}

func demo() int {
    editor := Editor{}
    editor.set(5)
    first := editor.save()
    editor.set(9)
    second := editor.save()
    editor.set(13)
    editor.restore(first)
    low := editor.read()
    editor.restore(second)
    return low * 10 + editor.read()
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## 8. Rust

```rust
#[derive(Clone, Default)]
struct Editor {
    state: i32,
}

impl Editor {
    fn set(&mut self, value: i32) {
        self.state = value;
    }

    fn read(&self) -> i32 {
        self.state
    }

    fn save(&self) -> Self {
        self.clone()
    }

    fn restore(&mut self, snapshot: &Self) {
        self.state = snapshot.state;
    }
}

pub fn demo() -> i32 {
    let mut editor = Editor::default();
    editor.set(5);
    let first = editor.save();
    editor.set(9);
    let second = editor.save();
    editor.set(13);
    editor.restore(&first);
    let low = editor.read();
    editor.restore(&second);
    low * 10 + editor.read()
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## Проверка

В этой редакции проверены согласованность LMX-листинга с документами `newdocs`, явная группировка результатов копирования/композиции там, где нужен один объект, и ссылки на правила языка. Ожидаемый результат LMX следует из показанного сценария; запуск ядра не проводился.

Листинги Python, Java, C++, C#, TypeScript, Go и Rust сохранены из исходного сравнения. Сообщения исходной редакции об их выполнении относятся к той проверке; это обновление документации не выдаёт их за новый запуск. Подсчёт размеров выполняется заново по листингам текущего файла.

## Источники

Сетевые образцы использованы для проверки ролей шаблона. Показанные программы — самостоятельные адаптации общего сценария, а не подсчёт длины исходников этих страниц.

- [Refactoring.Guru — Memento](https://refactoring.guru/design-patterns/memento)
- [Refactoring.Guru — Memento in Python](https://refactoring.guru/design-patterns/memento/python/example)

[B]: newdocs/TZ/LMX_Fable_TZ_Binding_and_Callables_v2_2026-11-19.md
[D]: newdocs/TZ/LMX_Fable_TZ_Declaration_Arguments_and_Import_v2_2026-11-20.md
[E]: newdocs/TZ/LMX_Fable_TZ_Blank_Line_Block_Terminator_2026-11-20.md

[S]: newdocs/LMX_semantics.en.md#merge-two-forms
