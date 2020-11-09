package formation

type PreBill struct {
	Unit    string
	Content []ItemGroup
	Address string
}

type Bill struct {
	ID      string
	Unit    string
	Content []ItemGroup
	Address string
}

func (p *Bill) TotalPrice() float64 {
	return TotalPrice(p.Content)
}
