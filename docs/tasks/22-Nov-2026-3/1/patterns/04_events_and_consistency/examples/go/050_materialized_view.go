package patterns
import "fmt"
type Projection struct { Total,Last int }
func (p *Projection) Apply(seq,delta int) (int,error) {
    if seq<=p.Last { return p.Total,nil }
    if seq!=p.Last+1 { return 0,fmt.Errorf("gap") }
    p.Total+=delta
    p.Last=seq
    return p.Total,nil
}
func (p *Projection) Query() int { return p.Total }
