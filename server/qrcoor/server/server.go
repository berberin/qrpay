package server

import (
	"github.com/Pallinder/go-randomdata"
	"github.com/gin-gonic/gin"
	"github.com/gorilla/websocket"
	"golang.org/x/crypto/acme/autocert"
	"log"
	"net/http"
	"qrcoor/config"
	"qrcoor/formation"
	"qrcoor/librarian"
	"time"
)

var (
	upgrader = websocket.Upgrader{
		HandshakeTimeout: 10 * time.Second,
	}
)

func RunServer() error {
	r := gin.Default()

	r.POST("/issue", createBill)
	r.GET("/connect", handleConnect)
	r.GET("/bill", getBillInfo)

	if config.GlobalConfig.TLS {
		m := autocert.Manager{
			Prompt:     autocert.AcceptTOS,
			HostPolicy: autocert.HostWhitelist(config.GlobalConfig.HostName...),
			Cache:      autocert.DirCache(config.GlobalConfig.CacheDir),
		}
		s := &http.Server{
			Addr:      config.GlobalConfig.Port,
			TLSConfig: m.TLSConfig(),
			Handler:   r,
		}
		return s.ListenAndServeTLS("", "")
	}

	log.Println(config.GlobalConfig.Port)
	return r.Run(config.GlobalConfig.Port)

}

func getBillInfo(c *gin.Context) {
	//billID := c.Param("a")
	billID := c.Request.URL.Query().Get("billID")
	log.Println(billID)
	bill, found := librarian.GetBillFromCache(billID)
	if found {
		c.JSON(http.StatusAccepted, bill)
	}
}

func createBill(c *gin.Context) {
	var preBill formation.PreBill
	err := c.BindJSON(&preBill)
	if err != nil {
		log.Println(err)
		c.JSON(http.StatusAlreadyReported, gin.H{})
	}
	bill := formation.Bill{
		ID:      randomdata.Letters(7),
		Unit:    preBill.Unit,
		Content: preBill.Content,
		Address: preBill.Address,
	}
	librarian.AddBillToCache(bill)
	s := randomdata.RandStringRunes(12)
	librarian.AddBillSecret(bill.ID, s)
	c.JSON(http.StatusCreated, gin.H{"BillID": bill.ID, "Price": bill.TotalPrice(), "Unit": bill.Unit, "Secret": s})

}

func handleConnect(c *gin.Context) {
	ws, err := upgrader.Upgrade(c.Writer, c.Request, nil)
	if err != nil {
		log.Println(err)
	}
	defer ws.Close()

	_, msg, err := ws.ReadMessage()
	if err != nil {
		log.Println(err)
		return
	}

	message := formation.MessageFromJson(msg)
	if message.Type == formation.MessageTypeConnect {
		// todo: handle bloc
		connectMessage := message.Data.(formation.IncomingConnectMessage)

		billSecret, found := librarian.GetBillSecret(connectMessage.BillID)
		if !found {
			return
		}
		switch connectMessage.Role {
		case formation.RoleTypeIssuer:
			// todo: handle issuer
			if billSecret != connectMessage.Secret {
				return
			}
			librarian.AddConnection(connectMessage, ws)
			//  defer librarian.RemoveConnection
			defer librarian.RemoveBillConnection(connectMessage.BillID)
			for {
				_, msg, err := ws.ReadMessage()
				if err != nil {
					log.Println(err)
					return
				}
				innerMessage := formation.MessageFromJson(msg)
				if innerMessage.Type == formation.MessageTypeReception {
					// todo: send reception
					// todo: add status code
					// context: after completed transactions
					for _, v := range librarian.BillConnections[connectMessage.BillID].Payer {
						v.Conn.WriteJSON(formation.Message{
							Type: formation.MessageTypeReception,
							Data: "",
						})
					}
				}
			}

		case formation.RoleTypePayer:
			librarian.AddConnection(connectMessage, ws)
			defer librarian.RemovePayerConnection(connectMessage.BillID, connectMessage.Address)

			// todo: broadcast
			messageOut := formation.OutgoingConnectMessage{}
			bill, _ := librarian.GetBillFromCache(connectMessage.BillID)
			messageOut.Peer = len(librarian.BillConnections[connectMessage.BillID].Payer)
			if messageOut.Peer > 1 {
				messageOut.Role = formation.RoleTypeSubPayer
			} else {
				messageOut.Role = formation.RoleTypePayer
			}
			messageOut.Total = bill.TotalPrice()
			var addresses []string
			for k := range librarian.BillConnections[connectMessage.BillID].Payer {
				addresses = append(addresses, k)
			}
			messageOut.Address = addresses

			//todo: turn on issuer
			librarian.BillConnections[connectMessage.BillID].Issuer["main"].Conn.WriteJSON(formation.Message{
				Type: formation.MessageTypeConnect,
				Data: messageOut,
			})
			for _, v := range librarian.BillConnections[connectMessage.BillID].Payer {
				v.Conn.WriteJSON(formation.Message{
					Type: formation.MessageTypeConnect,
					Data: messageOut,
				})
			}

			for {
				_, msg, err := ws.ReadMessage()
				if err != nil {
					log.Println(err)
					return
				}
				innerMessage := formation.MessageFromJson(msg)
				switch innerMessage.Type {
				case formation.MessageTypePay:
					for _, v := range librarian.BillConnections[connectMessage.BillID].Payer {
						v.Conn.WriteJSON(formation.Message{
							Type: formation.MessageTypePay,
							Data: "",
						})
					}
				case formation.MessageTypeTransaction:
					// note: transaction data in STRING
					billConn := librarian.BillConnections[connectMessage.BillID]
					//connect := billConn.Payer[connectMessage.Address].
					connection := billConn.Payer[connectMessage.Address]
					//innerMessage.Data.(formation.IncomingTransactionMessage).Transaction
					connection.AddTransaction(innerMessage.Data.(formation.IncomingTransactionMessage).Transaction)
					billConn.Payer[connectMessage.Address] = connection

					// wait to send to
					if librarian.AllTransactionIsSet(connectMessage.BillID) {
						// send to issuer
						trans := librarian.GetAllTransactions(connectMessage.BillID)
						librarian.BillConnections[connectMessage.BillID].Issuer["main"].Conn.WriteJSON(formation.Message{
							Type: formation.MessageTypeTransaction,
							Data: trans,
						})
					}
				}
			}
		}
	}
}
