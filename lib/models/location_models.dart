import 'package:json_annotation/json_annotation.dart';
part 'location_models.g.dart';

@JsonSerializable()
class AddAddressRequest {
  @JsonKey(name: 'locationId')
  final String locationId;
  @JsonKey(name: 'addressLine1')
  final String addressLine1;
  @JsonKey(name: 'addressLine2')
  final String addressLine2;
  @JsonKey(name: 'city')
  final String city;
  @JsonKey(name: 'state')
  final String state;
  @JsonKey(name: 'postCode')
  final String postCode;
  @JsonKey(name: 'lat')
  final double lat;
  @JsonKey(name: 'long')
  final double long;
  @JsonKey(name: 'addressType') // Matches your backend requirement
  final String? addressType;

  AddAddressRequest({
    required this.locationId,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.state,
    required this.postCode,
    required this.lat,
    required this.long,
    this.addressType,
  });

  factory AddAddressRequest.fromJson(Map<String, dynamic> json) =>
      _$AddAddressRequestFromJson(json);
  Map<String, dynamic> toJson() => _$AddAddressRequestToJson(this);
}

@JsonSerializable()
class AddAddressResponse {
  final bool success;
  final String message;
  final String? addressId;
  @JsonKey(name: 'locationId')
  final String? locationId;

  AddAddressResponse({
    required this.success,
    required this.message,
    this.addressId,
    this.locationId,
  });

  /// Custom factory to handle APIs that don't send `success` explicitly
  factory AddAddressResponse.fromJson(Map<String, dynamic> json) {
    final rawSuccess = json['success'] as bool?;
    final rawMessage = json['message'] as String?;
    final rawResult = json['result'] as String?;
    final type = json['type'] as String?;

    final inferredSuccess = rawSuccess ?? (type == 'Add address');
    final inferredMessage =
        rawMessage ?? rawResult ?? 'Address added successfully.';

    return AddAddressResponse(
      success: inferredSuccess,
      message: inferredMessage,
      addressId: json['addressId'] as String?,
      locationId: json['locationId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => _$AddAddressResponseToJson(this);
}

@JsonSerializable()
class CustomerAddress {
  final String id;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String postCode;
  final bool isDefault;
  final String? label;
  final String? addressType;
  final String? latitude;
  final String? longitude;
  @JsonKey(name: 'locationId')
  final String? locationId;

  CustomerAddress({
    required this.id,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.state,
    required this.postCode,
    required this.isDefault,
    this.label,
    this.addressType, // ➕ ADD THIS LINE
    this.latitude,
    this.longitude,
    this.locationId,
  });

  CustomerAddress copyWith({
    String? id,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? postCode,
    bool? isDefault,
    String? label,
    String? addressType,
    String? latitude,
    String? longitude,
    String? locationId,
  }) {
    return CustomerAddress(
      id: id ?? this.id,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      state: state ?? this.state,
      postCode: postCode ?? this.postCode,
      isDefault: isDefault ?? this.isDefault,
      label: label ?? this.label,
      addressType: addressType ?? this.addressType,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationId: locationId ?? this.locationId,
    );
  }

  factory CustomerAddress.fromJson(Map<String, dynamic> json) =>
      _$CustomerAddressFromJson(json);
  Map<String, dynamic> toJson() => _$CustomerAddressToJson(this);
}

@JsonSerializable()
class GetCustomerAddressesResponse {
  final String type;
  final List<CustomerAddress> result;

  GetCustomerAddressesResponse({
    required this.type,
    required this.result,
  });

  factory GetCustomerAddressesResponse.fromJson(Map<String, dynamic> json) =>
      _$GetCustomerAddressesResponseFromJson(json);
  Map<String, dynamic> toJson() =>
      _$GetCustomerAddressesResponseToJson(this);
}

@JsonSerializable()
class CachedLocationData {
  final String label;
  final String address;
  final double latitude;
  final double longitude;
  final String? houseNumber;
  final String? landmark;
  final String? city;
  final String? state;
  final String? postCode;
  final DateTime savedAt;
  final String? addressType;

  CachedLocationData({
    required this.label,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.houseNumber,
    this.landmark,
    this.city,
    this.state,
    this.postCode,
    this.addressType,
    required this.savedAt,
  });

  factory CachedLocationData.fromJson(Map<String, dynamic> json) =>
      _$CachedLocationDataFromJson(json);
  Map<String, dynamic> toJson() => _$CachedLocationDataToJson(this);
}

// NEW: Serviceable locations from /user/getLocation
@JsonSerializable()
class ServiceLocation {
  final String id; // send this as locationId on add-address
  final String? areaId;
  final String? areaName;
  final String? postCode;

  ServiceLocation({
    required this.id,
    this.areaId,
    this.areaName,
    this.postCode,
  });

  factory ServiceLocation.fromJson(Map<String, dynamic> json) =>
      _$ServiceLocationFromJson(json);
  Map<String, dynamic> toJson() => _$ServiceLocationToJson(this);
}

@JsonSerializable()
class ServiceLocationsResponse {
  final String type;
  final List<ServiceLocation> result;

  ServiceLocationsResponse({
    required this.type,
    required this.result,
  });

  factory ServiceLocationsResponse.fromJson(Map<String, dynamic> json) =>
      _$ServiceLocationsResponseFromJson(json);
  Map<String, dynamic> toJson() =>
      _$ServiceLocationsResponseToJson(this);
}
@JsonSerializable()
class BaseResponse {
  final bool success;
  final String? message;

  BaseResponse({
    required this.success,
    this.message,
  });

  factory BaseResponse.fromJson(Map<String, dynamic> json) {
    final rawSuccess = json['success'] as bool?;
    final result = json['result'] as String?;
    final type = json['type'] as String?;

    // Improved inference logic
    bool inferredSuccess = rawSuccess ?? false;
    
    if (rawSuccess == null) {
      // 1. Check if the message says successfully
      if (result != null && result.toLowerCase().contains('successfully')) {
        inferredSuccess = true;
      } 
      // 2. Check if the type matches known success types
      else if (type != null && (type.contains('Delete') || type.contains('Update'))) {
        inferredSuccess = true;
      }
    }

    return BaseResponse(
      success: inferredSuccess,
      message: json['message'] as String? ?? result,
    );
  }

  Map<String, dynamic> toJson() => _$BaseResponseToJson(this);
}