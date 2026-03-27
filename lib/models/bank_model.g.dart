// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bank_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BankDetail _$BankDetailFromJson(Map<String, dynamic> json) => BankDetail(
  id: json['id'] as String?,
  bankName: json['bankName'] as String?,
  accountNumber: json['accountNumber'] as String?,
  ifscCode: json['ifscCode'] as String?,
  upiId: json['upiId'] as String?,
);

Map<String, dynamic> _$BankDetailToJson(BankDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bankName': instance.bankName,
      'accountNumber': instance.accountNumber,
      'ifscCode': instance.ifscCode,
      'upiId': instance.upiId,
    };
