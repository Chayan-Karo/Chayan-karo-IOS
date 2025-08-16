// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  CategoryDao? _categoryDaoInstance;

  ServiceDao? _serviceDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `categories` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `title` TEXT NOT NULL, `icon_path` TEXT NOT NULL, `created_at` INTEGER NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `services` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `title` TEXT NOT NULL, `subtitle` TEXT, `image_path` TEXT NOT NULL, `price` REAL, `category` TEXT NOT NULL, `rating` REAL, `created_at` INTEGER NOT NULL)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  CategoryDao get categoryDao {
    return _categoryDaoInstance ??= _$CategoryDao(database, changeListener);
  }

  @override
  ServiceDao get serviceDao {
    return _serviceDaoInstance ??= _$ServiceDao(database, changeListener);
  }
}

class _$CategoryDao extends CategoryDao {
  _$CategoryDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _categoryEntityInsertionAdapter = InsertionAdapter(
            database,
            'categories',
            (CategoryEntity item) => <String, Object?>{
                  'id': item.id,
                  'title': item.title,
                  'icon_path': item.iconPath,
                  'created_at': _dateTimeConverter.encode(item.createdAt)
                }),
        _categoryEntityUpdateAdapter = UpdateAdapter(
            database,
            'categories',
            ['id'],
            (CategoryEntity item) => <String, Object?>{
                  'id': item.id,
                  'title': item.title,
                  'icon_path': item.iconPath,
                  'created_at': _dateTimeConverter.encode(item.createdAt)
                }),
        _categoryEntityDeletionAdapter = DeletionAdapter(
            database,
            'categories',
            ['id'],
            (CategoryEntity item) => <String, Object?>{
                  'id': item.id,
                  'title': item.title,
                  'icon_path': item.iconPath,
                  'created_at': _dateTimeConverter.encode(item.createdAt)
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<CategoryEntity> _categoryEntityInsertionAdapter;

  final UpdateAdapter<CategoryEntity> _categoryEntityUpdateAdapter;

  final DeletionAdapter<CategoryEntity> _categoryEntityDeletionAdapter;

  @override
  Future<List<CategoryEntity>> getAllCategories() async {
    return _queryAdapter.queryList(
        'SELECT * FROM categories ORDER BY title ASC',
        mapper: (Map<String, Object?> row) => CategoryEntity(
            id: row['id'] as int?,
            title: row['title'] as String,
            iconPath: row['icon_path'] as String,
            createdAt: _dateTimeConverter.decode(row['created_at'] as int)));
  }

  @override
  Future<CategoryEntity?> getCategoryById(int id) async {
    return _queryAdapter.query('SELECT * FROM categories WHERE id = ?1',
        mapper: (Map<String, Object?> row) => CategoryEntity(
            id: row['id'] as int?,
            title: row['title'] as String,
            iconPath: row['icon_path'] as String,
            createdAt: _dateTimeConverter.decode(row['created_at'] as int)),
        arguments: [id]);
  }

  @override
  Future<void> clearAll() async {
    await _queryAdapter.queryNoReturn('DELETE FROM categories');
  }

  @override
  Future<void> insertCategory(CategoryEntity category) async {
    await _categoryEntityInsertionAdapter.insert(
        category, OnConflictStrategy.abort);
  }

  @override
  Future<void> insertCategories(List<CategoryEntity> categories) async {
    await _categoryEntityInsertionAdapter.insertList(
        categories, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateCategory(CategoryEntity category) async {
    await _categoryEntityUpdateAdapter.update(
        category, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteCategory(CategoryEntity category) async {
    await _categoryEntityDeletionAdapter.delete(category);
  }
}

class _$ServiceDao extends ServiceDao {
  _$ServiceDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _serviceEntityInsertionAdapter = InsertionAdapter(
            database,
            'services',
            (ServiceEntity item) => <String, Object?>{
                  'id': item.id,
                  'title': item.title,
                  'subtitle': item.subtitle,
                  'image_path': item.imagePath,
                  'price': item.price,
                  'category': item.category,
                  'rating': item.rating,
                  'created_at': _dateTimeConverter.encode(item.createdAt)
                }),
        _serviceEntityUpdateAdapter = UpdateAdapter(
            database,
            'services',
            ['id'],
            (ServiceEntity item) => <String, Object?>{
                  'id': item.id,
                  'title': item.title,
                  'subtitle': item.subtitle,
                  'image_path': item.imagePath,
                  'price': item.price,
                  'category': item.category,
                  'rating': item.rating,
                  'created_at': _dateTimeConverter.encode(item.createdAt)
                }),
        _serviceEntityDeletionAdapter = DeletionAdapter(
            database,
            'services',
            ['id'],
            (ServiceEntity item) => <String, Object?>{
                  'id': item.id,
                  'title': item.title,
                  'subtitle': item.subtitle,
                  'image_path': item.imagePath,
                  'price': item.price,
                  'category': item.category,
                  'rating': item.rating,
                  'created_at': _dateTimeConverter.encode(item.createdAt)
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<ServiceEntity> _serviceEntityInsertionAdapter;

  final UpdateAdapter<ServiceEntity> _serviceEntityUpdateAdapter;

  final DeletionAdapter<ServiceEntity> _serviceEntityDeletionAdapter;

  @override
  Future<List<ServiceEntity>> getAllServices() async {
    return _queryAdapter.queryList('SELECT * FROM services ORDER BY title ASC',
        mapper: (Map<String, Object?> row) => ServiceEntity(
            id: row['id'] as int?,
            title: row['title'] as String,
            subtitle: row['subtitle'] as String?,
            imagePath: row['image_path'] as String,
            price: row['price'] as double?,
            category: row['category'] as String,
            rating: row['rating'] as double?,
            createdAt: _dateTimeConverter.decode(row['created_at'] as int)));
  }

  @override
  Future<List<ServiceEntity>> getServicesByCategory(String category) async {
    return _queryAdapter.queryList('SELECT * FROM services WHERE category = ?1',
        mapper: (Map<String, Object?> row) => ServiceEntity(
            id: row['id'] as int?,
            title: row['title'] as String,
            subtitle: row['subtitle'] as String?,
            imagePath: row['image_path'] as String,
            price: row['price'] as double?,
            category: row['category'] as String,
            rating: row['rating'] as double?,
            createdAt: _dateTimeConverter.decode(row['created_at'] as int)),
        arguments: [category]);
  }

  @override
  Future<ServiceEntity?> getServiceById(int id) async {
    return _queryAdapter.query('SELECT * FROM services WHERE id = ?1',
        mapper: (Map<String, Object?> row) => ServiceEntity(
            id: row['id'] as int?,
            title: row['title'] as String,
            subtitle: row['subtitle'] as String?,
            imagePath: row['image_path'] as String,
            price: row['price'] as double?,
            category: row['category'] as String,
            rating: row['rating'] as double?,
            createdAt: _dateTimeConverter.decode(row['created_at'] as int)),
        arguments: [id]);
  }

  @override
  Future<void> clearAll() async {
    await _queryAdapter.queryNoReturn('DELETE FROM services');
  }

  @override
  Future<void> insertService(ServiceEntity service) async {
    await _serviceEntityInsertionAdapter.insert(
        service, OnConflictStrategy.abort);
  }

  @override
  Future<void> insertServices(List<ServiceEntity> services) async {
    await _serviceEntityInsertionAdapter.insertList(
        services, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateService(ServiceEntity service) async {
    await _serviceEntityUpdateAdapter.update(service, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteService(ServiceEntity service) async {
    await _serviceEntityDeletionAdapter.delete(service);
  }
}

// ignore_for_file: unused_element
final _dateTimeConverter = DateTimeConverter();
