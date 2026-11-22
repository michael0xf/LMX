package patterns
import "fmt"
type WriteModel struct { Balance int; Publish func(int) }
func (w *WriteModel) Add(amount int) error {
    if amount < 0 { return fmt.Errorf("amount") }
    w.Balance += amount
    w.Publish(w.Balance)
    return nil
}
type ReadModel struct { Visible int }
func (r *ReadModel) Apply(snapshot int) int { r.Visible=snapshot; return r.Visible }
func (r *ReadModel) Query() int { return r.Visible }
