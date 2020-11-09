package librarian

import (
	"github.com/gorilla/websocket"
	"qrcoor/formation"

	"log"
)

var BillConnections map[string]BillConnection

type BillConnection struct {
	Issuer map[string]Connection
	Payer  map[string]Connection
}

func AddConnection(r formation.IncomingConnectMessage, c *websocket.Conn) {
	_, found := BillConnections[r.BillID]
	if !found {
		BillConnections[r.BillID] = NewBillConnection()
	}
	switch r.Role {
	case formation.RoleTypeIssuer:
		billConn := BillConnections[r.BillID]
		billConn.Issuer["main"] = Connection{
			Address: r.Address,
			Conn:    c,
		}
	case formation.RoleTypePayer:
		billConn := BillConnections[r.BillID]
		billConn.Payer[r.Address] = Connection{
			Address: r.Address,
			Conn:    c,
		}

	}
}

func AllTransactionIsSet(billID string) bool {
	//return true
	connections, found := BillConnections[billID]
	if !found {
		return false
	}
	for _, v := range connections.Payer {
		if v.Transaction == "" {
			return false
		}
	}
	return true
}

func GetAllTransactions(billID string) []string {
	var res []string
	connections, found := BillConnections[billID]
	if !found {
		return res
	}
	for _, v := range connections.Payer {
		res = append(res, v.Transaction)
	}
	return res
}

func NewBillConnection() BillConnection {
	billConnection := BillConnection{
		Issuer: make(map[string]Connection),
		Payer: make(map[string]Connection),
	}
	return billConnection
}

type Connection struct {
	Address     string
	Transaction string
	Conn        *websocket.Conn
}

func (c *Connection) Close() {
	defer func() {
		if r := recover(); r != nil {
			log.Println(r)
		}
	}()
	c.Conn.Close()
}

func (c *Connection) AddTransaction(trans string) {
	c.Transaction = trans
}

func RemoveBillConnection(billID string) {
	delete(BillConnections, billID)
}

func (c *BillConnection) RemoveConnection(address string) {
	delete(c.Payer, address)
}

func RemovePayerConnection(billID string, address string) {
	connection := BillConnections[billID]
	connection.RemoveConnection(address)
}

func initConnections() {
	BillConnections = make(map[string]BillConnection)
}
