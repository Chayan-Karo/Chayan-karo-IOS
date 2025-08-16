import 'package:floor/floor.dart';
import 'package:json_annotation/json_annotation.dart';
import '../converters/date_time_converter.dart';

part 'service_entity.g.dart';

@JsonSerializable()
@Entity(tableName: 'services')
class ServiceEntity {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  
  @ColumnInfo(name: 'title')
  final String title;
  
  @ColumnInfo(name: 'subtitle')
  final String? subtitle;
  
  @ColumnInfo(name: 'image_path')
  final String imagePath;
  
  @ColumnInfo(name: 'price')
  final double? price;
  
  @ColumnInfo(name: 'category')
  final String category;
  
  @ColumnInfo(name: 'rating')
  final double? rating;
  
  @ColumnInfo(name: 'created_at')
  final DateTime createdAt;

  ServiceEntity({
    this.id,
    required this.title,
    this.subtitle,
    required this.imagePath,
    this.price,
    required this.category,
    this.rating,
    required this.createdAt,
  });

  factory ServiceEntity.fromJson(Map<String, dynamic> json) => _$ServiceEntityFromJson(json);
  Map<String, dynamic> toJson() => _$ServiceEntityToJson(this);
}
