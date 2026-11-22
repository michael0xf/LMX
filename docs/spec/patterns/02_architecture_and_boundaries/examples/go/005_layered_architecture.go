package main
func dataPrice() int { return 10 }
func applicationTotal(quantity int) int { return quantity * dataPrice() }
func presentationHandle(quantity int) int { return applicationTotal(quantity) }
func demo() int { return presentationHandle(3) }
