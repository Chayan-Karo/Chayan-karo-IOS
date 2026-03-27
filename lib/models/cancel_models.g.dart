// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cancel_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CancelBookingRequest _$CancelBookingRequestFromJson(
  Map<String, dynamic> json,
) => CancelBookingRequest(
  bookingId: json['bookingId'] as String,
  reason: json['reason'] as String,
);

Map<String, dynamic> _$CancelBookingRequestToJson(
  CancelBookingRequest instance,
) => <String, dynamic>{
  'bookingId': instance.bookingId,
  'reason': instance.reason,
};

CancelBookingEnvelope _$CancelBookingEnvelopeFromJson(
  Map<String, dynamic> json,
) => CancelBookingEnvelope(
  type: json['type'] as String?,
  result: json['result'] == null
      ? null
      : CancelResult.fromJson(json['result'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CancelBookingEnvelopeToJson(
  CancelBookingEnvelope instance,
) => <String, dynamic>{'type': instance.type, 'result': instance.result};

CancelResult _$CancelResultFromJson(Map<String, dynamic> json) => CancelResult(
  message: json['message'] as String,
  bookingId: json['bookingId'] as String,
);

Map<String, dynamic> _$CancelResultToJson(CancelResult instance) =>
    <String, dynamic>{
      'message': instance.message,
      'bookingId': instance.bookingId,
    };
