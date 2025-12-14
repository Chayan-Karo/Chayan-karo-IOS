// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reschedule_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RescheduleBookingRequest _$RescheduleBookingRequestFromJson(
  Map<String, dynamic> json,
) => RescheduleBookingRequest(
  bookingId: json['bookingId'] as String,
  spId: json['spId'] as String,
  addressId: json['addressId'] as String,
  bookingTime: json['bookingTime'] as String,
  bookingDate: json['bookingDate'] as String,
  rescheduleReason: json['rescheduleReason'] as String,
);

Map<String, dynamic> _$RescheduleBookingRequestToJson(
  RescheduleBookingRequest instance,
) => <String, dynamic>{
  'bookingId': instance.bookingId,
  'spId': instance.spId,
  'addressId': instance.addressId,
  'bookingTime': instance.bookingTime,
  'bookingDate': instance.bookingDate,
  'rescheduleReason': instance.rescheduleReason,
};

RescheduleBookingEnvelope _$RescheduleBookingEnvelopeFromJson(
  Map<String, dynamic> json,
) => RescheduleBookingEnvelope(
  type: json['type'] as String?,
  result: json['result'] == null
      ? null
      : RescheduleResult.fromJson(json['result'] as Map<String, dynamic>),
);

Map<String, dynamic> _$RescheduleBookingEnvelopeToJson(
  RescheduleBookingEnvelope instance,
) => <String, dynamic>{'type': instance.type, 'result': instance.result};

RescheduleResult _$RescheduleResultFromJson(Map<String, dynamic> json) =>
    RescheduleResult(
      message: json['message'] as String,
      bookingId: json['bookingId'] as String,
    );

Map<String, dynamic> _$RescheduleResultToJson(RescheduleResult instance) =>
    <String, dynamic>{
      'message': instance.message,
      'bookingId': instance.bookingId,
    };
