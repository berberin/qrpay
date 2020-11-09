import 'package:bill_qr/ui/widgets/avatar.dart';
import 'package:flutter/material.dart';
import 'package:jdenticon_dart/jdenticon_dart.dart';

class PayerWidget extends StatelessWidget {
  final String address;

  const PayerWidget({Key key, this.address}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(5),
      child: Avatar(
        size: 30,
        svg: Jdenticon.toSvg(address),
      ),
    );
  }
}

removeFromListPayerWidget(List<PayerWidget> list, String address) {
  for (int i = 0; i < list.length; i++) {
    if (list[i].address == address) {
      list.removeAt(i);
      i--;
    }
  }
}
