import 'package:json_annotation/json_annotation.dart';

part 'bill.g.dart';

@JsonSerializable()
class PreBill {
  String Unit;
  List<ItemGroup> Content;
  String Address;

  PreBill({this.Unit, this.Content, this.Address});

  double totalPrice() {
    double totalPrice = 0;
    for (int i = 0; i < Content.length; i++) {
      totalPrice = totalPrice + Content[i].price();
    }
    return totalPrice;
  }

  factory PreBill.fromJson(Map<String, dynamic> json) =>
      _$PreBillFromJson(json);

  Map<String, dynamic> toJson() => _$PreBillToJson(this);
}

@JsonSerializable()
class Bill {
  String ID;
  String Unit;
  List<ItemGroup> Content;
  String Address;

  Bill({this.ID, this.Unit, this.Content, this.Address});

  double totalPrice() {
    double totalPrice = 0;
    for (int i = 0; i < Content.length; i++) {
      totalPrice = totalPrice + Content[i].price();
    }
    return totalPrice;
  }

  factory Bill.fromJson(Map<String, dynamic> json) => _$BillFromJson(json);

  Map<String, dynamic> toJson() => _$BillToJson(this);
}

@JsonSerializable()
class BillSecret {
  String ID;
  double Price;
  String Unit;
  String Secret;

  BillSecret({this.ID, this.Price, this.Unit, this.Secret});

  factory BillSecret.fromJson(Map<String, dynamic> json) =>
      _$BillSecretFromJson(json);

  Map<String, dynamic> toJson() => _$BillSecretToJson(this);
}

@JsonSerializable()
class Item {
  String Name;
  double Price;

  Item(this.Name, this.Price);

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);

  Map<String, dynamic> toJson() => _$ItemToJson(this);
}

@JsonSerializable()
class ItemGroup {
  Item Base;
  int Amount;

  double price() {
    return Amount * Base.Price;
  }

  ItemGroup(this.Base, this.Amount);

  factory ItemGroup.fromJson(Map<String, dynamic> json) =>
      _$ItemGroupFromJson(json);

  Map<String, dynamic> toJson() => _$ItemGroupToJson(this);
}
