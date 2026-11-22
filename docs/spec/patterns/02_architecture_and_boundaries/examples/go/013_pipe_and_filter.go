package main
import "example/pipe"
func normalize(value int) int { if value < 0 { return -value }; return value }
func twice(value int) int { return value * 2 }
func offset(value int) int { return value + 1 }
func pipeline(value int) int { return pipe.Apply(value, normalize, twice, offset) }
func demo() int { return pipeline(-3) }
