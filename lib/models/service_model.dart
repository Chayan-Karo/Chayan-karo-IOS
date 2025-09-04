// models/service_model.dart
class ServiceModel {
  final String id;
  final String name;
  final double price;
  final String duration;
  final String description;
  final String imagePath;

  ServiceModel({
    required this.id,
    required this.name,
    required this.price,
    required this.duration,
    required this.description,
    required this.imagePath,
  });
}
