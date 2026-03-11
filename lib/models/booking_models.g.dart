// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookingServiceItem _$BookingServiceItemFromJson(Map<String, dynamic> json) =>
    BookingServiceItem(
      categoryId: json['categoryId'] as String,
      serviceId: json['serviceId'] as String,
      discountPercentage: (json['discountPercentage'] as num).toInt(),
      price: json['price'] as num,
      discountPrice: json['discountPrice'] as num,
    );

Map<String, dynamic> _$BookingServiceItemToJson(BookingServiceItem instance) =>
    <String, dynamic>{
      'categoryId': instance.categoryId,
      'serviceId': instance.serviceId,
      'discountPercentage': instance.discountPercentage,
      'price': instance.price,
      'discountPrice': instance.discountPrice,
    };

BookingAmount _$BookingAmountFromJson(Map<String, dynamic> json) =>
    BookingAmount(
      actualAmount: json['actualAmount'] as num,
      plateFormFee: json['plateFormFee'] as num,
      gstAmount: json['gstAmount'] as num,
      gstPercentage: json['gstPercentage'] as num,
    );

Map<String, dynamic> _$BookingAmountToJson(BookingAmount instance) =>
    <String, dynamic>{
      'actualAmount': instance.actualAmount,
      'plateFormFee': instance.plateFormFee,
      'gstAmount': instance.gstAmount,
      'gstPercentage': instance.gstPercentage,
    };

AddBookingRequest _$AddBookingRequestFromJson(Map<String, dynamic> json) =>
    AddBookingRequest(
      spId: json['spId'] as String,
      totalDuration: (json['totalDuration'] as num).toInt(),
      addressId: json['addressId'] as String,
      bookingTime: json['bookingTime'] as String,
      bookingDate: json['bookingDate'] as String,
      paymentMode: json['paymentMode'] as String,
      couponId: json['couponId'] as String?,
      bookingAmount: BookingAmount.fromJson(
        json['bookingAmount'] as Map<String, dynamic>,
      ),
      bookingService: (json['bookingService'] as List<dynamic>)
          .map((e) => BookingServiceItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AddBookingRequestToJson(AddBookingRequest instance) =>
    <String, dynamic>{
      'spId': instance.spId,
      'totalDuration': instance.totalDuration,
      'addressId': instance.addressId,
      'bookingTime': instance.bookingTime,
      'bookingDate': instance.bookingDate,
      'paymentMode': instance.paymentMode,
      'couponId': instance.couponId,
      'bookingAmount': instance.bookingAmount,
      'bookingService': instance.bookingService,
    };

AddBookingResponse _$AddBookingResponseFromJson(Map<String, dynamic> json) =>
    AddBookingResponse(
      type: json['type'] as String?,
      result: json['result'] == null
          ? null
          : AddBookingResult.fromJson(json['result'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AddBookingResponseToJson(AddBookingResponse instance) =>
    <String, dynamic>{'type': instance.type, 'result': instance.result};

AddBookingResult _$AddBookingResultFromJson(Map<String, dynamic> json) =>
    AddBookingResult(
      message: json['message'] as String?,
      bookingId: json['bookingId'] as String?,
    );

Map<String, dynamic> _$AddBookingResultToJson(AddBookingResult instance) =>
    <String, dynamic>{
      'message': instance.message,
      'bookingId': instance.bookingId,
    };
