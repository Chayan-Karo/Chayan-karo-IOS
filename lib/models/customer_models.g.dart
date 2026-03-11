// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomerResponse _$CustomerResponseFromJson(Map<String, dynamic> json) =>
    CustomerResponse(
      type: json['type'] as String,
      result: Customer.fromJson(json['result'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CustomerResponseToJson(CustomerResponse instance) =>
    <String, dynamic>{'type': instance.type, 'result': instance.result};

Customer _$CustomerFromJson(Map<String, dynamic> json) => Customer(
  id: json['id'] as String,
  mobileNo: json['mobileNo'] as String,
  referralCode: json['referralCode'] as String?,
  emailId: json['emailId'] as String?,
  firstName: json['firstName'] as String?,
  middleName: json['middleName'] as String?,
  lastName: json['lastName'] as String?,
  gender: json['gender'] as String?,
  averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
  imageUrl: json['imageUrl'] as String?,
  status: (json['status'] as num?)?.toInt() ?? 1,
);

Map<String, dynamic> _$CustomerToJson(Customer instance) => <String, dynamic>{
  'id': instance.id,
  'mobileNo': instance.mobileNo,
  'referralCode': instance.referralCode,
  'emailId': instance.emailId,
  'firstName': instance.firstName,
  'middleName': instance.middleName,
  'lastName': instance.lastName,
  'gender': instance.gender,
  'averageRating': instance.averageRating,
  'imageUrl': instance.imageUrl,
  'status': instance.status,
};
