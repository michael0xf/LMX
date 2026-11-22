package main
type Kernel struct { extension func(int) int }
func (k *Kernel) Install(implementation func(int) int) { k.extension = implementation }
func (k *Kernel) Execute(value int) int { return k.extension(value) }
func demo() int {
    k := &Kernel{extension: func(x int) int { return x * 2 }}
    first := k.Execute(5)
    k.Install(func(x int) int { return x * 3 })
    return first + k.Execute(5)
}
