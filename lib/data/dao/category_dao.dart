import 'package:floor/floor.dart';
import '../entities/category_entity.dart';

@dao
abstract class CategoryDao {
  @Query('SELECT * FROM categories ORDER BY title ASC')
  Future<List<CategoryEntity>> getAllCategories();

  @Query('SELECT * FROM categories WHERE id = :id')
  Future<CategoryEntity?> getCategoryById(int id);

  @insert
  Future<void> insertCategory(CategoryEntity category);

  @insert
  Future<void> insertCategories(List<CategoryEntity> categories);

  @update
  Future<void> updateCategory(CategoryEntity category);

  @delete
  Future<void> deleteCategory(CategoryEntity category);

  @Query('DELETE FROM categories')
  Future<void> clearAll();
}
