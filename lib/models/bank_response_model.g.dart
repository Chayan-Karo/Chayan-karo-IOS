// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bank_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BankListResponse _$BankListResponseFromJson(Map<String, dynamic> json) =>
    BankListResponse(
      type: json['type'] as String?,
      result: (json['result'] as List<dynamic>?)
          ?.map((e) => BankDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$BankListResponseToJson(BankListResponse instance) =>
    <String, dynamic>{'type': instance.type, 'result': instance.result};
