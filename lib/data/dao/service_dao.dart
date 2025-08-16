import 'package:floor/floor.dart';
import '../entities/service_entity.dart';

@dao
abstract class ServiceDao {
  @Query('SELECT * FROM services ORDER BY title ASC')
  Future<List<ServiceEntity>> getAllServices();

  @Query('SELECT * FROM services WHERE category = :category')
  Future<List<ServiceEntity>> getServicesByCategory(String category);

  @Query('SELECT * FROM services WHERE id = :id')
  Future<ServiceEntity?> getServiceById(int id);

  @insert
  Future<void> insertService(ServiceEntity service);

  @insert
  Future<void> insertServices(List<ServiceEntity> services);

  @update
  Future<void> updateService(ServiceEntity service);

  @delete
  Future<void> deleteService(ServiceEntity service);

  @Query('DELETE FROM services')
  Future<void> clearAll();
}
