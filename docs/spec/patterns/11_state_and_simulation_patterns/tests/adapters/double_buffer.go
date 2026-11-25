package main

import (
    "bufio"
    "encoding/json"
    "fmt"
    "os"
    "reflect"
)

func main() {
    input := bufio.NewReader(os.Stdin)
    out := json.NewEncoder(os.Stdout)
    for {
        var steps, n int
        if _, err := fmt.Fscan(input, &steps, &n); err != nil { return }
        cells := make([]int, n)
        for i := range cells { fmt.Fscan(input, &cells[i]) }
        before := make([]int, n)
        copy(before, cells)
        result, err := evolve(cells, steps)
        if !reflect.DeepEqual(before, cells) { panic("input was changed") }
        if err != nil {
            out.Encode(map[string]any{"error": err.Error()})
            continue
        }
        again, err := evolve(cells, steps)
        if err != nil || !reflect.DeepEqual(result, again) { panic("run was not reset") }
        out.Encode(map[string]any{"cells": result})
        if n != 0 { result[0] = 1 - result[0] }
        if !reflect.DeepEqual(before, cells) { panic("result aliases input") }
    }
}
