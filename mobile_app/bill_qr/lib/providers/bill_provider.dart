import 'dart:convert';

import 'package:bill_qr/constants.dart';
import 'package:bill_qr/models/bill.dart';
import 'package:http/http.dart' as http;

class BillProvider {
  static Future<BillSecret> createBill(PreBill preBill) async {
    var response = await http.post(urlCreateBill, body: jsonEncode(preBill));
    Map<String, dynamic> resMap = json.decode(response.body);
    BillSecret billS = BillSecret(
      ID: resMap['BillID'],
      Secret: resMap['Secret'],
      Price: double.parse(resMap['Price'].toString()),
      Unit: resMap['Unit'],
    );
    print(billS.toJson());
    print(BillSecretToQRString(billS));
    return billS;
  }

  static Future<Bill> getBillInfo(String billID) async {
    String url = urlInfoBill + "?billID=$billID";
    print(url);
    var response = await http.get(url);
    print(response.body);
    Map<String, dynamic> mapRes = jsonDecode(response.body);
    Bill bill = Bill.fromJson(mapRes);
    print(bill.toJson());
    return bill;
  }

  static BillSecretToQRString(BillSecret billSecret) {
    Map<String, dynamic> qrMap = Map<String, dynamic>();
    qrMap['ID'] = billSecret.ID;
    qrMap['Unit'] = billSecret.Unit;
    qrMap['Price'] = billSecret.Price;
    return jsonEncode(qrMap);
  }

  static BillToQRString(Bill bill) {
    Map<String, dynamic> qrMap = Map<String, dynamic>();
    qrMap['ID'] = bill.ID;
    qrMap['Unit'] = bill.Unit;
    qrMap['Price'] = bill.totalPrice();
    return jsonEncode(qrMap);
  }
}
