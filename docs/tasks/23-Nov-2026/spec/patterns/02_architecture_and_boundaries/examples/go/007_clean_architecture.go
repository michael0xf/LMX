package main
func eligible(income, expense int) bool { return income-expense >= 30 }
func execute(income, expense int, output func(bool) int) int {
    return output(eligible(income, expense))
}
func render(decision bool) int { if decision { return 200 }; return 422 }
func demo() int { return execute(100, 60, render) }
