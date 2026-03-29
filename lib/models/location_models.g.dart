// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddAddressRequest _$AddAddressRequestFromJson(Map<String, dynamic> json) =>
    AddAddressRequest(
      locationId: json['locationId'] as String,
      addressLine1: json['addressLine1'] as String,
      addressLine2: json['addressLine2'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      postCode: json['postCode'] as String,
      lat: (json['lat'] as num).toDouble(),
      long: (json['long'] as num).toDouble(),
      addressType: json['addressType'] as String?,
    );

Map<String, dynamic> _$AddAddressRequestToJson(AddAddressRequest instance) =>
    <String, dynamic>{
      'locationId': instance.locationId,
      'addressLine1': instance.addressLine1,
      'addressLine2': instance.addressLine2,
      'city': instance.city,
      'state': instance.state,
      'postCode': instance.postCode,
      'lat': instance.lat,
      'long': instance.long,
      'addressType': instance.addressType,
    };

AddAddressResponse _$AddAddressResponseFromJson(Map<String, dynamic> json) =>
    AddAddressResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      addressId: json['addressId'] as String?,
      locationId: json['locationId'] as String?,
    );

Map<String, dynamic> _$AddAddressResponseToJson(AddAddressResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'addressId': instance.addressId,
      'locationId': instance.locationId,
    };

CustomerAddress _$CustomerAddressFromJson(Map<String, dynamic> json) =>
    CustomerAddress(
      id: json['id'] as String,
      addressLine1: json['addressLine1'] as String,
      addressLine2: json['addressLine2'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      postCode: json['postCode'] as String,
      isDefault: json['isDefault'] as bool,
      label: json['label'] as String?,
      addressType: json['addressType'] as String?,
      latitude: json['latitude'] as String?,
      longitude: json['longitude'] as String?,
      locationId: json['locationId'] as String?,
    );

Map<String, dynamic> _$CustomerAddressToJson(CustomerAddress instance) =>
    <String, dynamic>{
      'id': instance.id,
      'addressLine1': instance.addressLine1,
      'addressLine2': instance.addressLine2,
      'city': instance.city,
      'state': instance.state,
      'postCode': instance.postCode,
      'isDefault': instance.isDefault,
      'label': instance.label,
      'addressType': instance.addressType,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'locationId': instance.locationId,
    };

GetCustomerAddressesResponse _$GetCustomerAddressesResponseFromJson(
  Map<String, dynamic> json,
) => GetCustomerAddressesResponse(
  type: json['type'] as String,
  result: (json['result'] as List<dynamic>)
      .map((e) => CustomerAddress.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$GetCustomerAddressesResponseToJson(
  GetCustomerAddressesResponse instance,
) => <String, dynamic>{'type': instance.type, 'result': instance.result};

CachedLocationData _$CachedLocationDataFromJson(Map<String, dynamic> json) =>
    CachedLocationData(
      label: json['label'] as String,
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      houseNumber: json['houseNumber'] as String?,
      landmark: json['landmark'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      postCode: json['postCode'] as String?,
      addressType: json['addressType'] as String?,
      savedAt: DateTime.parse(json['savedAt'] as String),
    );

Map<String, dynamic> _$CachedLocationDataToJson(CachedLocationData instance) =>
    <String, dynamic>{
      'label': instance.label,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'houseNumber': instance.houseNumber,
      'landmark': instance.landmark,
      'city': instance.city,
      'state': instance.state,
      'postCode': instance.postCode,
      'savedAt': instance.savedAt.toIso8601String(),
      'addressType': instance.addressType,
    };

ServiceLocation _$ServiceLocationFromJson(Map<String, dynamic> json) =>
    ServiceLocation(
      id: json['id'] as String,
      areaId: json['areaId'] as String?,
      areaName: json['areaName'] as String?,
      postCode: json['postCode'] as String?,
    );

Map<String, dynamic> _$ServiceLocationToJson(ServiceLocation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'areaId': instance.areaId,
      'areaName': instance.areaName,
      'postCode': instance.postCode,
    };

ServiceLocationsResponse _$ServiceLocationsResponseFromJson(
  Map<String, dynamic> json,
) => ServiceLocationsResponse(
  type: json['type'] as String,
  result: (json['result'] as List<dynamic>)
      .map((e) => ServiceLocation.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ServiceLocationsResponseToJson(
  ServiceLocationsResponse instance,
) => <String, dynamic>{'type': instance.type, 'result': instance.result};

BaseResponse _$BaseResponseFromJson(Map<String, dynamic> json) => BaseResponse(
  success: json['success'] as bool,
  message: json['message'] as String?,
);

Map<String, dynamic> _$BaseResponseToJson(BaseResponse instance) =>
    <String, dynamic>{'success': instance.success, 'message': instance.message};
