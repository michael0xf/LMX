# Общая Haskell-реализация копирования графа

R06a и R06b используют один [GraphCopy.hs](../source/haskell/GraphCopy.hs). Это пользовательская реализация, а не функция base. При будущем подсчёте её полный текст учитывается как общая зависимость; стоимость нельзя прятать за import. Для каждой пары отдельно доступны полный клиент и этот общий код; в общем итоге библиотеку следует учитывать один раз.

```haskell
module GraphCopy (Node(..), copyGraph) where

import Data.IORef (IORef, newIORef, readIORef, writeIORef, modifyIORef')

data Node a = Node a [IORef (Node a)]

copyGraph :: IORef (Node a) -> IO (IORef (Node a))
copyGraph root = do
  memo <- newIORef []
  let visit source = do
        seen <- readIORef memo
        case lookup source seen of
          Just target -> pure target
          Nothing -> do
            Node value children <- readIORef source
            target <- newIORef (Node value [])
            modifyIORef' memo ((source,target):)
            copiedChildren <- mapM visit children
            writeIORef target (Node value copiedChildren)
            pure target
  visit root
```

Таблица memo сопоставляет исходный IORef новому. Новый узел регистрируется до обхода рёбер: повторное ребро получает уже созданную копию, а цикл не запускает бесконечное рекурсивное создание. Eq у IORef сравнивает идентичность ячеек: [официальная документация](https://hackage-content.haskell.org/package/base-4.20.1.0/docs/Data-IORef.html).

Граница модели: копируются именно узлы Node и связи в children; payload `a` переносится как неизменяемое значение. Скрытые ссылки внутри произвольного `a`, исполняемые структуры, DATA, parent и правила копирования всего LMX-графа этим типом не реализуются. Поэтому обе пары остаются аналогиями, даже при совпадении заданных наблюдений. Внешние записи в исходный граф во время копирования не предусмотрены.

Проверка ожидает 2107 с сохранением sharing, 83 с сохранением self-cycle, отличие копий от оригиналов и прежнее значение снимка 3. GHC: NOT_RUN. Полное тело GraphCopy входит в измеренную границу каждого использующего его Haskell-примера ровно один раз.
