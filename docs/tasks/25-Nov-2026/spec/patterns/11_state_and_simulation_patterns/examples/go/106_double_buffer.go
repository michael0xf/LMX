package main

import "errors"

func evolve(cells []int, steps int) ([]int, error) {
	if steps < 0 {
		return nil, errors.New("InvalidSteps")
	}
	for _, cell := range cells {
		if cell != 0 && cell != 1 {
			return nil, errors.New("InvalidCell")
		}
	}
	current, next := make([]int, len(cells)), make([]int, len(cells))
	copy(current, cells)
	for tick := 0; tick < steps; tick++ {
		for i := range cells {
			left, right := i-1, i+1
			if left < 0 {
				left = len(cells) - 1
			}
			if right == len(cells) {
				right = 0
			}
			next[i] = (current[left] + current[right]) % 2
		}
		current, next = next, current
	}
	return current, nil
}
