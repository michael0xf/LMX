# Шаблоны проектирования на Lingvamyxa: 10–18

Русская версия. 21 ноября 2026 года.

Продолжение первых девяти примеров: State, Chain of Responsibility, Composite, Proxy, Facade, Builder, Prototype, Memento и Bridge. Порядок учебный, а не рейтинг популярности. Архитектурная отправная точка — компактная реализация на Python; связанные методы LMX объединены общим DATA, а `demo` расположен рядом с ними.

Для каждого шаблона зафиксирован общий сценарий на LMX, Python, Java, C++, C#, TypeScript, Go и Rust. Полные листинги и измерения находятся в отдельных сравнительных файлах. Здесь приведены те же LMX-листинги и объяснение их работы.

## Правила чтения

Каждый пример — самостоятельная программа. DATA вызываемого кода — его фактический parent. Наличие общего поля не обязывает каждый метод группы его использовать. `@: selected method` сохраняет ссылку, `selected()` вызывает выбранный метод. Самостоятельный `fn`-контракт нужен только когда требуется отдельно описанная сигнатура.

Объявленный вход без начального значения может получить одноимённое значение непосредственного caller. Свободное имя без собственного объявления может обозначать его локальное место, допускающее изменение. Default не вытесняется автопередачей. Переданный alias сохраняет исходное место, а старый транзитивный fallback не превращает копию в alias. `private` закрывает неявное динамическое связывание в обе стороны; это не универсальный запрет явного доступа.

`node\` выбирает лексическое хранимое поле, а не parent. Явные пути используются для состояния, которое должно пережить отдельный вызов. `copy` и `merge` копируют исходный граф по своим контрактам; чтение локального значения и копирование хранимого графа различаются. В примерах со снимками и продуктами нужные значения сначала записываются в копируемый граф.

Пустая строка закрывает весь корневой синтаксический блок. Вложенный `---` применяется только когда после закрытия вложенной структуры нужно продолжить внешнюю. Последний блок может закончиться на EOF.

[Правила связывания][B] · [Импорт][D] · [Границы блоков][E]

**Копирование и потоки полей.** `import`, `copy` и `merge` в любом месте записи получают обычные аргументы в роли CODE. `copy` принимает один допущенный источник, `merge` — не меньше двух; оба выдают поток полей. Когда нужен один объект, поток явно собирается в группу: `(copy(Product))` или `(merge(Model Settings))`. Текущая принимающая структура не становится дополнительным источником `merge`. Ресиверы остаются в исходном графе, а их результаты обрабатываются в namespace. Обычные W/E-правила сохраняются и после группировки. [Копирование, композиция и группировка][S]

## Сводная таблица

[Excel с формулами](LMX_Comparison_10-18.xlsx) · [PDF](LMX_Comparison_10-18.pdf)

Измерены непробельные символы полного показанного исходника, включая объявления, импорты, необходимые оболочки и demo. Внешний запуск, main, печать, тесты и runtime не включены. Имена не нормализованы; Python без необязательных аннотаций. Отношения вычислены из сумм, а не как среднее отношений по отдельным шаблонам.

| Шаблон | LMX | Python | Java | C++ | C# | TypeScript | Go | Rust |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| State | 152 | 250 | 326 | 307 | 267 | 283 | 325 | 340 |
| Chain of Responsibility | 295 | 297 | 549 | 361 | 461 | 437 | 441 | 434 |
| Composite | 301 | 295 | 480 | 453 | 469 | 499 | 312 | 379 |
| Proxy | 191 | 181 | 346 | 209 | 274 | 256 | 217 | 220 |
| Facade | 170 | 204 | 274 | 236 | 286 | 316 | 244 | 235 |
| Builder | 355 | 499 | 574 | 436 | 581 | 514 | 543 | 565 |
| Prototype | 226 | 209 | 280 | 165 | 273 | 219 | 199 | 225 |
| Memento | 333 | 396 | 460 | 381 | 450 | 440 | 450 | 456 |
| Bridge | 276 | 320 | 645 | 399 | 487 | 490 | 413 | 425 |
| **Сумма** | **2299** | **2651** | **3934** | **2947** | **3548** | **3454** | **3144** | **3279** |
| **Сумма / LMX** | 1.000× | 1.153× | 1.711× | 1.282× | 1.543× | 1.502× | 1.368× | 1.426× |

## 10. State — Состояние

Текущее состояние само выбирает поведение следующего вызова.

```lmx
machine:
    return: int
    closed:
        state := opened
        return: 0
    opened:
        state := closed
        return: 1
    demo:
        @: state closed
        int: result state()
        result += state()
        result += state()
        return: result
```

**Вызов:** `machine\demo()`. **Ожидаемый результат: 1.**

demo создаёт state = closed. Первый вызов возвращает 0 и выбирает opened; второй возвращает 1 и выбирает closed; третий возвращает 0. Вызовы разделены на три оператора, поэтому порядок эффектов не зависит от приоритетов одного арифметического выражения. Сумма равна 1.

Это поведенческие состояния в виде callable, без обязательной иерархии классов State. Демонстрация создаёт собственный контекст заново. В LMX private на state запретил бы показанное неявное связывание; здесь такой модификатор не задан.

**LMX: 152** непробельных символов. [Сравнение на восьми языках](10_state_comparison.md).

[Refactoring.Guru — State in Python, conceptual example](https://refactoring.guru/design-patterns/state/python/example)

## 11. Chain of Responsibility — Цепочка обязанностей

Два заменяемых обработчика: второй получает запрос, только если первый его пропустил.

```lmx
chain:
    int: value
    @: first negative
    @: second even
    return: int
    negative:
        if: value < 0
            return: 1
        return: 0
    even:
        if: value % 2 = 0
            return: 2
        return: 0
    dispatch:
        int: result first()
        if: result
            return: result
        return: second()
    demo:
        int: result dispatch(-2)
        result += dispatch(4)
        result += dispatch(3)
        result += dispatch(-2; even; negative)
        return: result
```

**Вызов:** `chain\demo()`. **Ожидаемый результат: 5.**

С порядком по умолчанию запросы −2, 4, 3 дают 1, 2, 0. Затем явный вызов с порядком even, negative даёт 2 для того же −2. Итог равен 5. Если первый обработчик принял запрос, второй не вызывается.

Минимальная цепочка ровно из двух настраиваемых обработчиков. Первый принявший запрос завершает обработку; если оба отказываются, результат 0. Произвольная длина цепочки, пустая цепочка и асинхронные обработчики в этот сценарий не входят.

**LMX: 295** непробельных символов. [Сравнение на восьми языках](11_chain_of_responsibility_comparison.md).

[Refactoring.Guru — Chain of Responsibility in Python, conceptual example](https://refactoring.guru/design-patterns/chain-of-responsibility/python/example)

## 12. Composite — Компоновщик

Лист и бинарная композиция предоставляют один total; Pair рекурсивно складывает результаты детей.

```lmx
Leaf:
    int: value
    return: int
    total:
        return: value

Pair:
    @: left
    @: right
    return: int
    total:
        return: left\total() + right\total()
    demo:
        @: a (merge(Leaf; (int: value 2)))
        @: b (merge(Leaf; (int: value 3)))
        @: c (merge(Leaf; (int: value 5)))
        @: inner (merge(Pair; (@: left b; @: right c)))
        @: tree (merge(Pair; (@: left a; @: right inner)))
        return: tree\total()
```

Каждый `merge` имеет два явных источника; скобки вокруг его потока создают один объект для соответствующей переменной-ссылки.

**Вызов:** `Pair\demo()`. **Ожидаемый результат: 10.**

Создаются листья a=2, b=3, c=5; inner объединяет b и c, а tree — a и inner. inner\total() возвращает 8, затем tree\total() — 10. Точно такая же операция действует при дальнейшей вложенности Pair.

Конечное ациклическое бинарное дерево: каждый внутренний узел содержит ровно двух детей, глубина произвольна. LMX merge копирует используемый граф и перенаправляет ссылки; это не разделяемые изменяемые a/b/c. Другие версии используют ссылки или заимствования. Сравнивается построение и чтение без последующих изменений листьев; стоимость копирования и семантика редактирования дерева не приравниваются.

**LMX: 301** непробельных символов. [Сравнение на восьми языках](12_composite_comparison.md).

[Refactoring.Guru — Composite in Python, conceptual example](https://refactoring.guru/design-patterns/composite/python/example)

## 13. Proxy — контроль перед обращением к службе

Прокси и служба имеют один интерфейс. Прокси отклоняет отрицательный запрос и делегирует разрешённый.

```lmx
requests:
    int: value
    return: int
    real:
        return: value * 2
    proxy:
        if: value < 0
            return: 0
        return: real()
    demo:
        @: request proxy
        int: denied request(-3)
        int: allowed request(7)
        request := real
        return: denied + allowed + request(-3)
```

**Вызов:** `requests\demo()`. **Ожидаемый результат: 8.**

request(-3) через proxy возвращает 0, не вызывая real. request(7) делегирует и даёт 14. После request := real тот же отрицательный запрос возвращает −6. Итог demo: 0 + 14 − 6 = 8.

Это минимальный защитный прокси с фиксированной службой и числовым правилом допуска. Различаются отказ и делегирование; полноценная авторизация, кэш и общий конструктор прокси в сценарий не входят. Политика задана самим примером, а не языком.

**LMX: 191** непробельных символов. [Сравнение на восьми языках](13_proxy_comparison.md).

[Refactoring.Guru — Proxy in Python, conceptual example](https://refactoring.guru/design-patterns/proxy/python/example)

## 14. Facade — единая операция над двумя подсистемами

Расчёт заказа объединяет цену товаров и стоимость доставки; клиент вызывает один quote.

```lmx
checkout:
    int: quantity
    int: price
    int: weight
    int: zone
    return: int
    subtotal:
        return: quantity * price
    fee:
        return: weight * 2 + zone * 5
    quote:
        return: subtotal() + fee()
    demo:
        return: quote(3; 10; 2; 1)
```

**Вызов:** `checkout\demo()`. **Ожидаемый результат: 39.**

quote(3; 10; 2; 1) получает subtotal = 30 и fee = 9, затем возвращает 39. Дополнительный сценарий quote(1; 8; 3; 2) возвращает 24.

Фасад координирует две самостоятельно вызываемые операции расчёта товаров и доставки. Им не нужны отдельные namespace или классы, чтобы оставаться отдельными операциями: как и в Python, они собраны в одну группу. Оплаты, складских транзакций и правил округления в задаче нет.

**LMX: 170** непробельных символов. [Сравнение на восьми языках](14_facade_comparison.md).

[Refactoring.Guru — Facade in Python, conceptual example](https://refactoring.guru/design-patterns/facade/python/example)

## 15. Builder — Строитель

Пошаговая сборка прямоугольника и выдача независимого готового продукта.

```lmx
Rectangle:
    int: width 0
    int: height 0
    return: int
    area:
        return: width * height
    builder:
        int: value
        return: Rectangle
        set_width:
            node\width := value
        set_height:
            node\height := value
        finish:
            return: (copy(Rectangle))
    ---
    demo:
        builder\set_width(3)
        builder\set_height(4)
        @: first builder\finish()
        builder\set_width(5)
        builder\set_height(2)
        @: second builder\finish()
        return: first\area() + second\area()
```

**Вызов:** `Rectangle\demo()`. **Ожидаемый результат: 22.**

После первых двух шагов first имеет размеры 3 и 4. Изменение заготовки на 5 и 2 не меняет first: finish создаёт отдельный граф. second имеет площадь 10, first — 12. Каждый demo задаёт оба размера перед первым finish, поэтому повторный запуск также возвращает 22.

Один вид продукта, два шага, повторное использование builder и независимость результатов. Отдельный Director и семейство разных представлений не входят в пример. Размеры — обычные int; проверка геометрических ограничений не добавлена ни в одном языке.

**LMX: 355** непробельных символов. [Сравнение на восьми языках](15_builder_comparison.md).

[Refactoring.Guru — Builder](https://refactoring.guru/design-patterns/builder) · [Refactoring.Guru — Builder in Python](https://refactoring.guru/design-patterns/builder/python/example)

## 16. Prototype — Прототип

Копирование уже настроенного экземпляра с сохранением поведения и независимыми полями.

```lmx
Point:
    int: x 3
    int: y 4
    return: int
    score:
        return: x * 10 + y
    demo:
        @: original (copy(Point))
        original := parent(original\score)
        original\x := 7
        @: replica (copy(original))
        replica := parent(replica\score)
        replica\y := 9
        return: original\score() + replica\score()
```

**Вызов:** `Point\demo()`. **Ожидаемый результат: 153.**

original остаётся (7,4), replica становится (7,9). Оба объекта сохраняют score, который читает DATA своего конкретного экземпляра. Изменение y в копии не меняет y исходного объекта; последующее изменение original.x также не меняет replica.x.

После каждого сгруппированного копирования ссылка явно выбирает фактический parent скопированного score. Поэтому запись полей и вызов метода работают с одним владельцем; тождество внешней группы этому владельцу и стабильность прежнего адреса примитивного поля не предполагаются.

Клонируется один конкретный тип с двумя скалярными полями. Пример не сравнивает глубокое копирование вложенных изменяемых объектов, внешних ресурсов или произвольной иерархии подтипов. copy имеет более общий графовый контракт; здесь проверяется лишь общий для всех программ сценарий.

**LMX: 226** непробельных символов. [Сравнение на восьми языках](16_prototype_comparison.md).

[Refactoring.Guru — Prototype](https://refactoring.guru/design-patterns/prototype) · [Refactoring.Guru — Prototype in Python](https://refactoring.guru/design-patterns/prototype/python/example)

## 17. Memento — Снимок состояния

Владелец состояния создаёт два снимка и восстанавливает их по запросу хранителя.

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

**Вызов:** `Editor\demo()`. **Ожидаемый результат: 59.**

Первый save фиксирует 5, второй — 9. set(13) меняет только текущий Editor. restore(first) возвращает 5, которое сохраняется в low; restore(second) возвращает 9. Вычисляется 5×10+9. Хранитель вызывает только save, restore и обычный read текущего объекта.

Это минимальный Memento с договором использования API: хранитель не читает и не изменяет внутренности снимка. Защита от намеренного доступа, неизменяемость снимка, проверка владельца и ограничение истории не заявляются ни в одном варианте. private LMX регулирует неявное связывание и не заменяет такую защиту. Состояние состоит из одного числа; внешние ресурсы не копируются.

**LMX: 333** непробельных символов. [Сравнение на восьми языках](17_memento_comparison.md).

[Refactoring.Guru — Memento](https://refactoring.guru/design-patterns/memento) · [Refactoring.Guru — Memento in Python](https://refactoring.guru/design-patterns/memento/python/example)

## 18. Bridge — две независимые оси изменений

Два режима управления сочетаются с двумя реализациями устройства. Менять режим и устройство можно независимо.

```lmx
bridge:
    int: level
    @: output
    return: int
    radio:
        return: level * 2
    speaker:
        return: level * 3
    basic:
        return: output()
    boost:
        level += 1
        return: output()
    demo:
        @: control basic
        @: output radio
        int: total control(4)
        output := speaker
        total += control(4)
        control := boost
        total += control(4)
        output := radio
        return: total + control(4)
```

**Вызов:** `bridge\demo()`. **Ожидаемый результат: 45.**

При level = 4 basic/radio даёт 8, basic/speaker — 12, boost/speaker — 15, boost/radio — 10. Сумма 45. Переключение output не требует менять control; переключение control не требует менять output.

Это функциональная запись Bridge: независимые семейства абстракций и реализаций выражены функциями, а не обязательными иерархиями классов. Обе оси показаны в demo; пример не сводится к единственной функции с одной заменяемой стратегией. Возвращаемые числа моделируют действие устройства, реальных драйверов здесь нет.

**LMX: 276** непробельных символов. [Сравнение на восьми языках](18_bridge_comparison.md).

[Refactoring.Guru — Bridge in Python, conceptual example](https://refactoring.guru/design-patterns/bridge/python/example)

## Проверка

Листинги LMX буквально совпадают с отдельными файлами сравнения. Они проверены по согласованным правилам и уточнениям автора; ядро LMX здесь не запускалось. Фактическая проверка остальных языков указана в каждом сравнительном файле. Числа в Excel и PDF получены из этих же листингов.

[B]: ../tasks/LMX_Fable_TZ_Binding_and_Callables_v2_2026-11-19.md
[D]: ../tasks/LMX_Fable_TZ_Declaration_Arguments_and_Import_v2_2026-11-20.md
[E]: ../tasks/LMX_Fable_TZ_Blank_Line_Block_Terminator_2026-11-20.md

[S]: ../LMX_semantics.en.md#merge-two-forms
