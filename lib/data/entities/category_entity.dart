import 'package:floor/floor.dart';
import 'package:json_annotation/json_annotation.dart';
import '../converters/date_time_converter.dart';

part 'category_entity.g.dart';

@JsonSerializable()
@Entity(tableName: 'categories')
class CategoryEntity {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  
  @ColumnInfo(name: 'title')
  final String title;
  
  @ColumnInfo(name: 'icon_path')
  final String iconPath;
  
  @ColumnInfo(name: 'created_at')
  final DateTime createdAt;

  CategoryEntity({
    this.id,
    required this.title,
    required this.iconPath,
    required this.createdAt,
  });

  factory CategoryEntity.fromJson(Map<String, dynamic> json) => _$CategoryEntityFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryEntityToJson(this);
}
