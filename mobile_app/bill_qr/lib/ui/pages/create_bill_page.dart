import 'package:bill_qr/models/bill.dart';
import 'package:bill_qr/providers/bill_provider.dart';
import 'package:bill_qr/providers/wallet_provider.dart';
import 'package:bill_qr/ui/widgets/dialogs/custom_dialog.dart';
import 'package:bill_qr/ui/widgets/text_form.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';
import 'issuer_page.dart';

class CreateBillPage extends StatefulWidget {
  @override
  _CreateBillPageState createState() => _CreateBillPageState();
}

class _CreateBillPageState extends State<CreateBillPage> {
  PreBill preBill;
  List<Widget> itemList;
  TextEditingController _amountController;
  TextEditingController _nameController;
  TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _nameController = TextEditingController();
    _priceController = TextEditingController();
    preBill = PreBill(
        Unit: "XLM",
        Address: WalletProvider.address,
        Content: List<ItemGroup>());
    itemList = List<Widget>();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _priceController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Create new bill",
                  style: Theme.of(context).textTheme.headline4,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: itemList.isEmpty
                    ? Text("Please add an item to this bill.")
                    : Column(
                        children: itemList,
                      ),
              ),
              Divider(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total price:",
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    Text(
                      preBill.Content.isEmpty
                          ? "0.00" + " XLM"
                          : preBill.totalPrice().toStringAsFixed(2) + " XLM",
                      style: Theme.of(context)
                          .textTheme
                          .headline5
                          .copyWith(color: secText),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 25,
              ),
              Center(
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(24)),
                    //side: BorderSide(color: Colors.red, width: 2),
                  ),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    child: Text(
                      "CREATE",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  color: priText,
                  textColor: secText,
                  onPressed: () async {
                    if (preBill.Content.isEmpty) {
                      return;
                    }
                    BillProvider.createBill(preBill).then((value) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => IssuerPage(
                            billSecret: value,
                          ),
                        ),
                      );
                    });
                  },
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  splashColor: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            showNormalDialog(
              context: context,
              widget: addItem(),
            );
          },
          child: Icon(Icons.library_add),
          tooltip: "Add item!",
        ),
        backgroundColor: backgroundColor,
      ),
    );
  }

  Widget addItem() {
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
              "Add new item to bill",
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              "Please enter new item's info.",
            ),
            SizedBox(
              height: 20,
            ),
            Text("Receiver", style: Theme.of(context).textTheme.headline6),
            SizedBox(
              height: 10,
            ),
            TextForm(
              labelText: "Name of item",
              hintText: "Coffee size L",
              controller: _nameController,
            ),
            SizedBox(
              height: 10,
            ),
            TextForm(
              labelText: "Price",
              keyboardType: TextInputType.number,
              controller: _priceController,
            ),
            SizedBox(
              height: 10,
            ),
            TextForm(
              labelText: "Amount",
              keyboardType: TextInputType.number,
              controller: _amountController,
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlineButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  child: Text("CANCEL"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                SizedBox(
                  width: 10,
                ),
                RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  child: Text("ADD"),
                  color: secText,
                  onPressed: () {
                    preBill.Content.add(ItemGroup(
                        Item(_nameController.text,
                            double.parse(_priceController.text)),
                        int.parse(_amountController.text)));
                    itemList.add(Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(int.parse(_amountController.text).toString()),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                _nameController.text,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Text(
                            double.parse(_priceController.text)
                                .toStringAsFixed(2),
                          ),
                        ],
                      ),
                    ));
                    _priceController.clear();
                    _nameController.clear();
                    _amountController.clear();
                    setState(() {});
                    Navigator.pop(context);
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
