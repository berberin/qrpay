package formation

import (
	"encoding/json"
	"log"
)

type MessageType string
type RoleType string

const (
	MessageTypeIssue       MessageType = "issue_bill"
	MessageTypeConnect     MessageType = "connect"
	MessageTypePay         MessageType = "pay"
	MessageTypeTransaction MessageType = "transaction"
	MessageTypeReception   MessageType = "reception"
)
const (
	RoleTypeIssuer   RoleType = "issuer"
	RoleTypePayer    RoleType = "payer"
	RoleTypeSubPayer RoleType = "subpayer"
)

type Message struct {
	Type MessageType
	Data interface{}
}

type IssueRequestMessage struct {
	Address string
	Items   []ItemGroup
}

type IncomingConnectMessage struct {
	Role    RoleType
	Address string
	BillID  string
	Secret  string
}

func (t *IncomingConnectMessage) FromMap(m map[string]interface{}) {
	t.Role = RoleType(m["Role"].(string))
	t.Address = m["Address"].(string)
	t.BillID = m["BillID"].(string)
	t.Secret = m["Secret"].(string)
}

type OutgoingConnectMessage struct {
	Role  RoleType
	Address []string
	Peer  int
	Total float64
}

type IncomingPayMessage struct {
}

// payer send to server
type IncomingTransactionMessage struct {
	Transaction string
}

func (t *IncomingTransactionMessage) FromMap(m string) {
	t.Transaction = m
}

// send to bill issuer
type OutgoingTransactionMessage struct {
	TransactionList []string
}

type IncomingReceptionMessage struct {
}

//todo: data to incterface

func MessageFromJson(data []byte) Message {
	var message Message
	err := json.Unmarshal(data, &message)
	if err != nil {
		log.Println(err)
		return message
	}
	switch message.Type {
	case MessageTypeConnect:
		var t IncomingConnectMessage
		t.FromMap(message.Data.(map[string]interface{}))
		message.Data = t

	case MessageTypeTransaction:
		var t IncomingTransactionMessage
		t.FromMap(message.Data.(string))
		message.Data = t
	}
	return message
}
