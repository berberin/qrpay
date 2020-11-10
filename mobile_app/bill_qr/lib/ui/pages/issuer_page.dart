import 'dart:convert';
import 'dart:developer';

import 'package:bill_qr/constants.dart';
import 'package:bill_qr/models/bill.dart';
import 'package:bill_qr/providers/bill_provider.dart';
import 'package:bill_qr/providers/wallet_provider.dart';
import 'package:bill_qr/providers/websocket_conn.dart';
import 'package:bill_qr/ui/widgets/dialogs/custom_dialog.dart';
import 'package:bill_qr/ui/widgets/payer_widget.dart';
import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:qr/qr.dart';
import 'package:web_socket_channel/io.dart';

import 'done_page.dart';

class IssuerPage extends StatefulWidget {
  final BillSecret billSecret;

  const IssuerPage({Key key, this.billSecret}) : super(key: key);

  @override
  _IssuerPageState createState() => _IssuerPageState();
}

class _IssuerPageState extends State<IssuerPage> {
  List<PayerWidget> payerWidgetList;
  WebSocketSession webSocketSession;
  bool testMode;

  @override
  void initState() {
    super.initState();
    payerWidgetList = List<PayerWidget>();
    webSocketSession = WebSocketSession(null, widget.billSecret);
    connectWSChannel();
    testMode = false;
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
    webSocketSession.connectAsIssuer();
  }

  void eventListenerWS(event) async {
    log(event);
    Map<String, dynamic> message = jsonDecode(event);

    switch (message["Type"]) {
      case "connect":
        {
          payerWidgetList = List<PayerWidget>();
          for (int i = 0; i < message["Data"]["Address"].length; i++) {
            payerWidgetList.add(PayerWidget(
              address: message["Data"]["Address"][i],
            ));
          }
          setState(() {});
          break;
        }
      case "transaction":
        {
          showLoadingDialog(context);
          if (!testMode) {
            for (int i = 0; i < message["Data"].length; i++) {
              // todo: verify all transaction
              String trans = message["Data"][i];
              try {
                log(trans);
                await WalletProvider.createFeebump(trans);
              } catch (e) {}
            }
          } else {
            await Future.delayed(Duration(seconds: 6));
          }

          // todo: add reception code
          Navigator.pop(context);
          webSocketSession.sendReception();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DonePage(),
            ),
          );
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
  void dispose() {
    webSocketSession.active = false;
    super.dispose();
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
            Column(
              children: [
                Text(
                  "Ask payers to scan this code.",
                ),
                Text(
                  "Please keep this screen to process payments.",
                ),
                SizedBox(
                  width: 10,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.billSecret.Price.toString(),
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      widget.billSecret.Unit,
                      style: Theme.of(context).textTheme.headline5,
                    )
                  ],
                ),
              ],
            ),
            Column(
              children: [
                Center(
                  child: PrettyQr(
                    data: BillProvider.BillSecretToQRString(widget.billSecret),
                    elementColor: priText,
                    size: 250,

                    //todo: tinh' type phu hop: https://www.qrcode.com/en/about/version.html
                    typeNumber: 4,
                    roundEdges: true,
                    errorCorrectLevel: QrErrorCorrectLevel.M,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "Bill ID:",
                  style: Theme.of(context).textTheme.headline5,
                ),
                SizedBox(
                  height: 5,
                ),
                SelectableText(
                  widget.billSecret.ID,
                  style: Theme.of(context).textTheme.headline4,
                ),
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
            )
          ],
        ),
        backgroundColor: backgroundColor,
      ),
    );
  }
}
