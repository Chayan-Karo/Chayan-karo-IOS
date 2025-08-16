import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'dart:async';

import '../entities/category_entity.dart';
import '../entities/service_entity.dart';
import '../dao/category_dao.dart';
import '../dao/service_dao.dart';
import '../converters/date_time_converter.dart';

part 'app_database.g.dart';

@TypeConverters([DateTimeConverter])
@Database(version: 1, entities: [CategoryEntity, ServiceEntity])
abstract class AppDatabase extends FloorDatabase {
  CategoryDao get categoryDao;
  ServiceDao get serviceDao;
}

// Singleton Database Instance
class DatabaseManager {
  static DatabaseManager? _instance;
  static AppDatabase? _database;

  DatabaseManager._internal();

  static DatabaseManager get instance {
    _instance ??= DatabaseManager._internal();
    return _instance!;
  }

  Future<AppDatabase> get database async {
    _database ??= await $FloorAppDatabase
        .databaseBuilder('home_services_database.db')
        .build();
    return _database!;
  }
}
