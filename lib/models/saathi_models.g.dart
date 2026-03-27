// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saathi_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetProvidersRequest _$GetProvidersRequestFromJson(Map<String, dynamic> json) =>
    GetProvidersRequest(
      categoryId: json['categoryId'] as String,
      serviceId: json['serviceId'] as String,
      locationId: json['locationId'] as String,
      addressId: json['addressId'] as String,
      bookingDate: json['bookingDate'] as String,
      bookingTime: json['bookingTime'] as String,
      currentBookingDuration:
          (json['currentBookingDuration'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$GetProvidersRequestToJson(
  GetProvidersRequest instance,
) => <String, dynamic>{
  'categoryId': instance.categoryId,
  'serviceId': instance.serviceId,
  'locationId': instance.locationId,
  'addressId': instance.addressId,
  'bookingDate': instance.bookingDate,
  'bookingTime': instance.bookingTime,
  'currentBookingDuration': instance.currentBookingDuration,
};

SaathiResponse _$SaathiResponseFromJson(Map<String, dynamic> json) =>
    SaathiResponse(
      type: json['type'] as String,
      result: (json['result'] as List<dynamic>)
          .map((e) => SaathiProviderDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SaathiResponseToJson(SaathiResponse instance) =>
    <String, dynamic>{'type': instance.type, 'result': instance.result};

AvailabilityResultDto _$AvailabilityResultDtoFromJson(
  Map<String, dynamic> json,
) => AvailabilityResultDto(
  isAvailable: json['isAvailable'] as bool,
  waitingTimeMinutes: (json['waitingTimeMinutes'] as num).toInt(),
  nextAvailableSlot: json['nextAvailableSlot'] as String?,
);

Map<String, dynamic> _$AvailabilityResultDtoToJson(
  AvailabilityResultDto instance,
) => <String, dynamic>{
  'isAvailable': instance.isAvailable,
  'waitingTimeMinutes': instance.waitingTimeMinutes,
  'nextAvailableSlot': instance.nextAvailableSlot,
};

SaathiProviderDto _$SaathiProviderDtoFromJson(Map<String, dynamic> json) =>
    SaathiProviderDto(
      id: json['id'] as String,
      mobileNo: json['mobileNo'] as String,
      emailId: json['emailId'] as String?,
      firstName: json['firstName'] as String?,
      middleName: json['middleName'] as String?,
      lastName: json['lastName'] as String?,
      averageRating: json['averageRating'] as num?,
      totalReview: (json['totalReview'] as num?)?.toInt(),
      imgLink: json['imgLink'] as String?,
      isLocked: json['isLocked'] as bool,
      freeFromTime: (json['freeFromTime'] as num?)?.toInt(),
      availabilityResult: json['availabilityResult'] == null
          ? null
          : AvailabilityResultDto.fromJson(
              json['availabilityResult'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$SaathiProviderDtoToJson(SaathiProviderDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'mobileNo': instance.mobileNo,
      'emailId': instance.emailId,
      'firstName': instance.firstName,
      'middleName': instance.middleName,
      'lastName': instance.lastName,
      'averageRating': instance.averageRating,
      'totalReview': instance.totalReview,
      'imgLink': instance.imgLink,
      'isLocked': instance.isLocked,
      'freeFromTime': instance.freeFromTime,
      'availabilityResult': instance.availabilityResult,
    };

SaathiItem _$SaathiItemFromJson(Map<String, dynamic> json) => SaathiItem(
  id: json['id'] as String,
  name: json['name'] as String,
  mobileNo: json['mobileNo'] as String?,
  description: json['description'] as String?,
  imageUrl: json['imageUrl'] as String?,
  rating: (json['rating'] as num?)?.toDouble(),
  jobsCompleted: (json['jobsCompleted'] as num?)?.toInt(),
  isLocked: json['isLocked'] as bool,
  freeFromTime: (json['freeFromTime'] as num?)?.toInt(),
  isAvailable: json['isAvailable'] as bool?,
  nextAvailableSlot: json['nextAvailableSlot'] as String?,
);

Map<String, dynamic> _$SaathiItemToJson(SaathiItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'mobileNo': instance.mobileNo,
      'description': instance.description,
      'imageUrl': instance.imageUrl,
      'rating': instance.rating,
      'jobsCompleted': instance.jobsCompleted,
      'isLocked': instance.isLocked,
      'freeFromTime': instance.freeFromTime,
      'isAvailable': instance.isAvailable,
      'nextAvailableSlot': instance.nextAvailableSlot,
    };

LockProviderResponse _$LockProviderResponseFromJson(
  Map<String, dynamic> json,
) => LockProviderResponse(
  type: json['type'] as String,
  result: json['result'] as String,
);

Map<String, dynamic> _$LockProviderResponseToJson(
  LockProviderResponse instance,
) => <String, dynamic>{'type': instance.type, 'result': instance.result};
