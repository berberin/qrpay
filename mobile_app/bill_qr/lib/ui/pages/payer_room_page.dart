import 'dart:convert';
import 'dart:developer';

import 'package:bill_qr/models/bill.dart';
import 'package:bill_qr/providers/bill_provider.dart';
import 'package:bill_qr/providers/wallet_provider.dart';
import 'package:bill_qr/providers/websocket_conn.dart';
import 'package:bill_qr/ui/pages/done_page.dart';
import 'package:bill_qr/ui/widgets/dialogs/custom_dialog.dart';
import 'package:bill_qr/ui/widgets/payer_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:qr/qr.dart';
import 'package:web_socket_channel/io.dart';

import '../../constants.dart';

class PayerRoomPage extends StatefulWidget {
  final Bill bill;

  const PayerRoomPage({Key key, this.bill}) : super(key: key);
  @override
  _PayerRoomPageState createState() => _PayerRoomPageState();
}

class _PayerRoomPageState extends State<PayerRoomPage> {
  List<PayerWidget> payerWidgetList;
  double price;
  int peer;
  bool theFirstPayer;
  bool theFirstConnectMessage;
  WebSocketSession webSocketSession;

  @override
  void initState() {
    super.initState();
    payerWidgetList = List<PayerWidget>();
    price = widget.bill.totalPrice();
    peer = 1;
    theFirstPayer = true;
    theFirstConnectMessage = true;
    webSocketSession = WebSocketSession(widget.bill, null);
    connectWSChannel();
  }

  @override
  void dispose() {
    webSocketSession.active = false;
    super.dispose();
  }

  void connectWSChannel() async {
    if (!webSocketSession.active) {
      return;
    }
    webSocketSession.ws = IOWebSocketChannel.connect(
      urlConnect,
      pingInterval: Duration(seconds: 50),
    );
    webSocketSession.ws.stream.listen(
      eventListenerWS,
      onDone: () => connectWSChannel(),
      onError: (error) => connectWSChannel(),
      cancelOnError: true,
    );
    webSocketSession.connectAsPayer();
  }

  void eventListenerWS(event) async {
    log(event);
    Map<String, dynamic> message = jsonDecode(event);

    switch (message["Type"]) {
      case "connect":
        {
          if (message["Data"]["Role"] == "subpayer" && theFirstConnectMessage) {
            theFirstPayer = false;
          }
          theFirstConnectMessage = false;
          peer = message["Data"]["Peer"];
          price = widget.bill.totalPrice() / peer;
          payerWidgetList = List<PayerWidget>();
          for (int i = 0; i < message["Data"]["Address"].length; i++) {
            payerWidgetList.add(PayerWidget(
              address: message["Data"]["Address"][i],
            ));
          }
          setState(() {});
          break;
        }
      case "pay":
        {
          String trans = await WalletProvider.createTransaction(
              widget.bill.Address, price);
          webSocketSession.sendTransaction(trans);
          break;
        }
      case "reception":
        {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DonePage(),
            ),
          );
          break;
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                PrettyQr(
                  data: BillProvider.BillToQRString(widget.bill),
                  elementColor: priText,
                  size: 120,

                  //todo: tinh' type phu hop: https://www.qrcode.com/en/about/version.html
                  typeNumber: 4,
                  roundEdges: true,
                  errorCorrectLevel: QrErrorCorrectLevel.M,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.bill.totalPrice().toString(),
                          style: Theme.of(context)
                              .textTheme
                              .headline5
                              .copyWith(color: secText),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text(
                          widget.bill.Unit,
                          style: Theme.of(context).textTheme.headline5,
                        )
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        Text(
                          widget.bill.ID,
                          style: Theme.of(context)
                              .textTheme
                              .headline5
                              .copyWith(color: secText),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text(
                          "ID",
                          style: Theme.of(context).textTheme.headline5,
                        )
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    OutlineButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        side: BorderSide(color: Colors.red),
                      ),
                      child: Row(children: [
                        Icon(
                          Icons.help_rounded,
                          color: priText,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Details",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: priText,
                          ),
                        )
                      ]),
                      onPressed: () {
                        showNormalDialog(
                          context: context,
                          widget: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                height: 400,
                                padding: EdgeInsets.all(15),
                                child: ListView.builder(
                                  physics: BouncingScrollPhysics(),
                                  itemCount: widget.bill.Content.length + 3,
                                  itemBuilder: (BuildContext ctx, int index) {
                                    if (index == 0) {
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "Details",
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline4,
                                        ),
                                      );
                                    }
                                    if (index ==
                                        widget.bill.Content.length + 1) {
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Total:",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline5,
                                            ),
                                            Text(
                                              widget.bill
                                                  .totalPrice()
                                                  .toStringAsFixed(2),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline4,
                                            )
                                          ],
                                        ),
                                      );
                                    }
                                    if (index ==
                                        widget.bill.Content.length + 2) {
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Center(
                                          child: OutlineButton(
                                            child: Text("OK"),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ),
                                      );
                                    }
                                    return Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 5),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Text(widget
                                                .bill.Content[index - 1].Amount
                                                .toString()),
                                            Expanded(
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 10),
                                                child: Text(
                                                  widget.bill.Content[index - 1]
                                                      .Base.Name,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              widget.bill.Content[index - 1]
                                                  .Base.Price
                                                  .toStringAsFixed(2),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                )
              ],
            ),

            Column(
              children: [
                Text(
                  "You are going to pay: ",
                  style: Theme.of(context).textTheme.headline5,
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  price.toStringAsFixed(2),
                  style: Theme.of(context).textTheme.headline4,
                )
              ],
            ),
            // todo: payer now widget
            Column(
              children: [
                Text(
                  "Payers:",
                  style: Theme.of(context).textTheme.headline5,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: payerWidgetList,
                )
              ],
            ),

            theFirstPayer
                ? Column(
                    children: [
                      RaisedButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(24)),
                          //side: BorderSide(color: Colors.red, width: 2),
                        ),
                        child: Container(
                          margin:
                              EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                          child: Text(
                            "PAY NOW!",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                        color: priText,
                        textColor: secText,
                        onPressed: () async {
                          webSocketSession.sendPaySignal();
                        },
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                        splashColor: Colors.grey,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text("You can trigger pay now or wait for others ...")
                    ],
                  )
                : Container(
                    child: Text(
                        "Only the first payer can trigger payment process."),
                  )
          ],
        ),
        backgroundColor: backgroundColor,
      ),
    );
  }
}
