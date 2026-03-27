class CheckAvailabilityResponse {
  final String? type;
  final String? result;

  CheckAvailabilityResponse({this.type, this.result});

  factory CheckAvailabilityResponse.fromJson(Map<String, dynamic> json) {
    return CheckAvailabilityResponse(
      type: json['type'],
      result: json['result'],
    );
  }

  // Helper to check if successful based on your JSON sample
  bool get isAvailable => result == "Provider is available to take the service.";
}