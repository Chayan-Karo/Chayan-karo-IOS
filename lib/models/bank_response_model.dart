import 'package:json_annotation/json_annotation.dart';
import 'bank_model.dart';

part 'bank_response_model.g.dart';

@JsonSerializable()
class BankListResponse {
  final String? type;
  final List<BankDetail>? result; // This maps the list in your logs

  BankListResponse({this.type, this.result});

  factory BankListResponse.fromJson(Map<String, dynamic> json) => 
      _$BankListResponseFromJson(json);
}