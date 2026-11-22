type Catalog interface { Price() int; Shipping() int }
func Mobile(c Catalog) int { return c.Price() }
func Web(c Catalog) int { return c.Price() + c.Shipping() }
