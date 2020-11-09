import 'package:bill_qr/constants.dart';
import 'package:flutter/material.dart';

class DonePage extends StatefulWidget {
  @override
  _DonePageState createState() => _DonePageState();
}

class _DonePageState extends State<DonePage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Center(
              child: Icon(
                Icons.done_all,
                color: Colors.green[700],
                size: 150,
              ),
            ),
            SizedBox(
              height: 40,
            ),
            Center(
              child: Text(
                "Transaction Successful!",
                style: Theme.of(context).textTheme.headline5,
              ),
            )
          ],
        ),
        backgroundColor: backgroundColor,
      ),
    );
  }
}
