import 'package:bill_qr/providers/wallet_provider.dart';
import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:qr/qr.dart';

import '../../constants.dart';

class DepositDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 10,
      ),
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Deposit",
              style: Theme.of(context).textTheme.headline4,
            ),
            Text("Please send XLM tokens to this address."),
            SizedBox(
              height: 20,
            ),
            Text("XLM Address", style: Theme.of(context).textTheme.headline6),
            SelectableText(
              WalletProvider.address,
              style: Theme.of(context).textTheme.bodyText2,
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PrettyQr(
                  typeNumber: 4,
                  size: 200,
                  data: WalletProvider.address,
                  errorCorrectLevel: QrErrorCorrectLevel.M,
                  roundEdges: true,
                  elementColor: priText,
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
