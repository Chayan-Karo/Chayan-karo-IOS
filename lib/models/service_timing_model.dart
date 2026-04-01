// lib/models/service_timing_model.dart

class ServiceTimingModel {
  final String id;
  final String startTime;
  final String endTime;
  final bool isActive;

  ServiceTimingModel({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.isActive,
  });

  factory ServiceTimingModel.fromJson(Map<String, dynamic> json) {
    // Navigate to the 'result' object in the JSON
    final data = json['result'] ?? {};
    
    return ServiceTimingModel(
      id: data['id'] ?? '',
      startTime: data['startTime'] ?? "08:30",
      endTime: data['endTime'] ?? "20:30",
      isActive: data['isActive'] ?? true,
    );
  }
}