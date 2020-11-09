// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PreBill _$PreBillFromJson(Map<String, dynamic> json) {
  return PreBill(
    Unit: json['Unit'] as String,
    Content: (json['Content'] as List)
        ?.map((e) =>
            e == null ? null : ItemGroup.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    Address: json['Address'] as String,
  );
}

Map<String, dynamic> _$PreBillToJson(PreBill instance) => <String, dynamic>{
      'Unit': instance.Unit,
      'Content': instance.Content,
      'Address': instance.Address,
    };

Bill _$BillFromJson(Map<String, dynamic> json) {
  return Bill(
    ID: json['ID'] as String,
    Unit: json['Unit'] as String,
    Content: (json['Content'] as List)
        ?.map((e) =>
            e == null ? null : ItemGroup.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    Address: json['Address'] as String,
  );
}

Map<String, dynamic> _$BillToJson(Bill instance) => <String, dynamic>{
      'ID': instance.ID,
      'Unit': instance.Unit,
      'Content': instance.Content,
      'Address': instance.Address,
    };

BillSecret _$BillSecretFromJson(Map<String, dynamic> json) {
  return BillSecret(
    ID: json['ID'] as String,
    Price: (json['Price'] as num)?.toDouble(),
    Unit: json['Unit'] as String,
    Secret: json['Secret'] as String,
  );
}

Map<String, dynamic> _$BillSecretToJson(BillSecret instance) =>
    <String, dynamic>{
      'ID': instance.ID,
      'Price': instance.Price,
      'Unit': instance.Unit,
      'Secret': instance.Secret,
    };

Item _$ItemFromJson(Map<String, dynamic> json) {
  return Item(
    json['Name'] as String,
    (json['Price'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$ItemToJson(Item instance) => <String, dynamic>{
      'Name': instance.Name,
      'Price': instance.Price,
    };

ItemGroup _$ItemGroupFromJson(Map<String, dynamic> json) {
  return ItemGroup(
    json['Base'] == null
        ? null
        : Item.fromJson(json['Base'] as Map<String, dynamic>),
    json['Amount'] as int,
  );
}

Map<String, dynamic> _$ItemGroupToJson(ItemGroup instance) => <String, dynamic>{
      'Base': instance.Base,
      'Amount': instance.Amount,
    };
