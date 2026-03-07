import 'package:json_annotation/json_annotation.dart';

part 'bank_model.g.dart';

@JsonSerializable()
class BankDetail {
  final String? id; //
  final String? bankName;
  final String? accountNumber;
  final String? ifscCode;
  final String? upiId;

  BankDetail({
    this.id,
    this.bankName,
    this.accountNumber,
    this.ifscCode,
    this.upiId,
  });

  factory BankDetail.fromJson(Map<String, dynamic> json) => _$BankDetailFromJson(json);
  Map<String, dynamic> toJson() => _$BankDetailToJson(this);
}