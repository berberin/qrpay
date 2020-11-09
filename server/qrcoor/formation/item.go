package formation

type Item struct {
	Name  string
	Price float64
}

type ItemGroup struct {
	Amount int
	Base   Item
}

func (p *ItemGroup) TotalPrice() float64 {
	return p.Base.Price * float64(p.Amount)
}

func TotalPrice(list []ItemGroup) float64 {
	sum := 0.0
	for _, v := range list {
		sum = sum + v.TotalPrice()
	}
	return sum
}
