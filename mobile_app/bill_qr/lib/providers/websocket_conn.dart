import 'dart:convert';

import 'package:bill_qr/models/bill.dart';
import 'package:bill_qr/providers/wallet_provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketSession {
  Bill bill;
  BillSecret billSecret;
  WebSocketChannel ws;
  bool active;

  WebSocketSession(this.bill, this.billSecret, {this.active: true});

  connectAsIssuer() {
    Map<String, dynamic> inner = Map<String, dynamic>();
    inner["Role"] = "issuer";
    inner["Address"] = WalletProvider.address;
    inner["BillID"] = billSecret.ID;
    inner["Secret"] = billSecret.Secret;

    Map<String, dynamic> mapQuery = Map<String, dynamic>();
    mapQuery['Type'] = "connect";
    mapQuery['Data'] = inner;

    String query = jsonEncode(mapQuery);
    ws.sink.add(query);
  }

  connectAsPayer() {
    Map<String, dynamic> inner = Map<String, dynamic>();
    inner["Role"] = "payer";
    inner["Address"] = WalletProvider.address;
    inner["BillID"] = bill.ID;
    inner["Secret"] = "";

    Map<String, dynamic> mapQuery = Map<String, dynamic>();
    mapQuery['Type'] = "connect";
    mapQuery['Data'] = inner;

    String query = jsonEncode(mapQuery);
    ws.sink.add(query);
  }

  sendPaySignal() {
    Map<String, dynamic> mapQuery = Map<String, dynamic>();
    mapQuery['Type'] = "pay";
    mapQuery['Data'] = "";
    String query = jsonEncode(mapQuery);
    ws.sink.add(query);
  }

  sendReception() {
    Map<String, dynamic> mapQuery = Map<String, dynamic>();
    mapQuery['Type'] = "reception";
    mapQuery['Data'] = "";
    String query = jsonEncode(mapQuery);
    ws.sink.add(query);
  }

  sendTransaction(String trans) {
    Map<String, dynamic> mapQuery = Map<String, dynamic>();
    mapQuery['Type'] = "transaction";
    mapQuery['Data'] = trans;
    String query = jsonEncode(mapQuery);
    ws.sink.add(query);
  }
}
