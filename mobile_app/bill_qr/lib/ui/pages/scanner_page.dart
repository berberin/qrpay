import 'dart:convert';

import 'package:bill_qr/constants.dart';
import 'package:bill_qr/models/bill.dart';
import 'package:bill_qr/providers/bill_provider.dart';
import 'package:bill_qr/ui/pages/payer_room_page.dart';
import 'package:bill_qr/ui/widgets/text_form.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qr_bar_scanner/qr_bar_scanner_camera.dart';

class ScannerPage extends StatefulWidget {
  static const id = 'ReaderScreen';

  @override
  _ScannerPageState createState() => _ScannerPageState();
}

// with WidgetsBindingObserver
class _ScannerPageState extends State<ScannerPage> {
  bool _camState = false;
  TextEditingController idController;

  _scanCode() {
    setState(() {
      _camState = true;
    });
  }

  @override
  void initState() {
    super.initState();
    idController = TextEditingController();
    _scanCode();
    //WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    //WidgetsBinding.instance.removeObserver(this);
    idController.dispose();
    super.dispose();
  }

//  @override
//  void didChangeAppLifecycleState(AppLifecycleState state) {
//    if (state == AppLifecycleState.resumed){
//      setState(() {
//        _scanCode();
//      });
//    }
//    if (state == AppLifecycleState.paused){
//      setState(() {
//        _scanCode();
//      });
//    }
//  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        child: Stack(children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: _camState
                ? QRBarScannerCamera(
                    onError: (context, error) => Text(error.toString()),
                    qrCodeCallback: (code) async {
                      setState(() {
                        _camState = false;
                      });
                      Map<String, dynamic> res = jsonDecode(code);
                      Bill bill = await BillProvider.getBillInfo(res['ID']);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PayerRoomPage(
                            bill: bill,
                          ),
                        ),
                      );
                    },
                  )
                : Container(),
          ),
          Positioned(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(16)),
                color: Color(0x55fefefe),
              ),
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    "Scan the bill's QR",
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    "or",
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  TextForm(
                    hintText: "Enter the bill's ID",
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.send_to_mobile,
                        color: priText,
                      ),
                      onPressed: () async {
                        String id = idController.text;
                        if (id != "") {
                          Bill bill = await BillProvider.getBillInfo(id);
                          if (bill.ID.length > 0) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PayerRoomPage(
                                  bill: bill,
                                ),
                              ),
                            );
                          }
                        }
                      },
                    ),
                    controller: idController,
                    onEditingComplete: () async {
                      String id = idController.text;
                      if (id != "") {
                        Bill bill = await BillProvider.getBillInfo(id);
                        if (bill.ID.length > 0) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PayerRoomPage(
                                bill: bill,
                              ),
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
            top: 10,
            left: 10,
            right: 10,
          ),
        ]),
      ),
    );
  }
}
