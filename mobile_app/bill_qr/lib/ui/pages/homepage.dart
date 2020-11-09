import 'package:bill_qr/constants.dart';
import 'package:bill_qr/providers/wallet_provider.dart';
import 'package:bill_qr/ui/dialogs/deposit_dialog.dart';
import 'package:bill_qr/ui/dialogs/withdraw_dialog.dart';
import 'package:bill_qr/ui/pages/create_bill_page.dart';
import 'package:bill_qr/ui/pages/scanner_page.dart';
import 'package:bill_qr/ui/widgets/avatar.dart';
import 'package:bill_qr/ui/widgets/dialogs/custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:jdenticon_dart/jdenticon_dart.dart';

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String balance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Avatar(
              svg: Jdenticon.toSvg(WalletProvider.address),
              size: 140,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          balance != null
                              ? double.parse(balance).toStringAsFixed(2)
                              : "-----",
                          style: Theme.of(context).textTheme.headline4,
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                          "XLM",
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      ],
                    ),
                    ButtonTheme(
                      minWidth: 140,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          OutlineButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(18.0),
                                bottomLeft: Radius.circular(18.0),
                              ),
                              side: BorderSide(color: Colors.red, width: 2),
                            ),
                            child: Row(children: [
                              Icon(Icons.arrow_upward),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                "DEPOSIT",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: priText,
                                ),
                              ),
                            ]),
                            onPressed: () => showNormalDialog(
                              context: context,
                              widget: DepositDialog(),
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          OutlineButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(18.0),
                                bottomRight: Radius.circular(18.0),
                              ),
                              side: BorderSide(color: Colors.red),
                            ),
                            child: Row(children: [
                              Icon(Icons.arrow_downward),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                "WITHDRAW",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: priText,
                                ),
                              )
                            ]),
                            onPressed: () => showNormalDialog(
                              context: context,
                              widget: WithdrawDialog(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Text(
                        WalletProvider.address,
                        overflow: TextOverflow.clip,
                        style: TextStyle(fontSize: 8),
                      ),
                    ),
                    Divider(
                      thickness: 2,
                      color: secText,
                    ),
                  ],
                )
              ],
            ),
            ButtonTheme(
                minWidth: 200,
                child: Column(
                  children: [
                    RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(24)),
                        //side: BorderSide(color: Colors.red, width: 2),
                      ),
                      child: Container(
                        margin: EdgeInsets.all(5),
                        child: Text(
                          "CREATE NEW BILL",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                      color: priText,
                      textColor: secText,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateBillPage(),
                          ),
                        );
                      },
                      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                      splashColor: Colors.grey,
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(24)),
                        //side: BorderSide(color: Colors.red, width: 2),
                      ),
                      child: Container(
                        margin: EdgeInsets.all(5),
                        child: Text(
                          "BILL PAYMENT",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                      color: priText,
                      textColor: secText,
                      onPressed: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ScannerPage(),
                          ),
                        );
                      },
                      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                      splashColor: Colors.grey,
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WalletProvider.getBalance().then((value) {
      setState(() {
        balance = value;
      });
    });
  }
}
