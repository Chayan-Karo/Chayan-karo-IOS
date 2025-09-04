// Import models with explicit naming to avoid conflicts
import '../../models/home_models.dart' as models;
import '../remote/api_service.dart';
import '../local/database.dart';

class HomeRepository {
  final ApiService _apiService;
  final AppDatabase _database;

  HomeRepository({
    required ApiService apiService,
    required AppDatabase database,
  })  : _apiService = apiService,
        _database = database;

  // Dummy categories data for immediate display
  List<models.ServiceCategory> _getDummyCategories() {
    return [
      models.ServiceCategory(title: 'Female Saloon', icon: 'assets/icons/female_saloon.svg'),
      models.ServiceCategory(title: 'Female Spa', icon: 'assets/icons/female_spa.svg'),
      models.ServiceCategory(title: 'Male Saloon', icon: 'assets/icons/male_saloon.svg'),
      models.ServiceCategory(title: 'Male Spa', icon: 'assets/icons/male_spa.svg'),
      models.ServiceCategory(title: 'Hair & Skin', icon: 'assets/icons/hair_skin.svg'),
      models.ServiceCategory(title: 'Home Repairs', icon: 'assets/icons/home_repairs.svg'),
      models.ServiceCategory(title: 'Cleaning', icon: 'assets/icons/cleaning.svg'),
      models.ServiceCategory(title: 'AC Services', icon: 'assets/icons/ac_service.svg'),
    ];
  }

  // Get categories - dummy data first strategy with database persistence
  Future<List<models.ServiceCategory>> getCategories() async {
    final dummyCategories = _getDummyCategories();
    
    try {
      // Try to get from local database first
      final localCategories = await _database.getAllCategories();
      if (localCategories.isNotEmpty) {
        print('📱 Returning ${localCategories.length} categories from local database');
        return localCategories;
      }

      // If no local data, fetch from API
      print('🌐 Fetching categories from API...');
      final remoteCategories = await _apiService.getCategories();
      
      // Save to local database
      await _database.clearCategories();
      await _database.insertCategories(remoteCategories);
      print('💾 Saved ${remoteCategories.length} categories to database');
      
      return remoteCategories;
    } catch (e) {
      // If everything fails, save and return dummy data
      print('🔄 Using dummy categories data for development: $e');
      
      try {
        await _database.clearCategories();
        await _database.insertCategories(dummyCategories);
        print('💾 Saved ${dummyCategories.length} dummy categories to database');
      } catch (dbError) {
        print('❌ Could not save dummy categories to database: $dbError');
      }
      
      return dummyCategories;
    }
  }

  // Dummy most used services data
  List<models.Service> _getDummyMostUsedServices() {
    return [
      models.Service(title: 'Window AC frame Installation', image: 'assets/z1.webp'),
      models.Service(title: 'Women Salon Services', image: 'assets/z2.webp'),
      models.Service(title: 'Home Deep Cleaning', image: 'assets/z3.webp'),
      models.Service(title: 'Spa for Men', image: 'assets/z4.webp'),
      models.Service(title: 'Hair Cut & Styling', image: 'assets/z1.webp'),
      models.Service(title: 'Kitchen Deep Clean', image: 'assets/z2.webp'),
    ];
  }

  // Get most used services - dummy data first strategy with database persistence
  Future<List<models.Service>> getMostUsedServices() async {
    final dummyServices = _getDummyMostUsedServices();
    
    try {
      final localServices = await _database.getServicesByType('mostUsed');
      if (localServices.isNotEmpty) {
        print('📱 Returning ${localServices.length} most used services from local database');
        return localServices;
      }

      print('🌐 Fetching most used services from API...');
      final remoteServices = await _apiService.getMostUsedServices();
      await _database.insertServices(remoteServices, 'mostUsed');
      print('💾 Saved ${remoteServices.length} most used services to database');
      
      return remoteServices;
    } catch (e) {
      // If everything fails, save and return dummy data
      print('🔄 Using dummy services data for development: $e');
      
      try {
        // Clear existing services of this type first
        await _database.insertServices(dummyServices, 'mostUsed');
        print('💾 Saved ${dummyServices.length} dummy most used services to database');
      } catch (dbError) {
        print('❌ Could not save dummy services to database: $dbError');
      }
      
      return dummyServices;
    }
  }

  // Dummy GoTo services data
  List<models.GoToService> _getDummyGoToServices() {
    return [
      models.GoToService(
        title: 'Beauty & Wellness (Men)',
        subtitle: '10 services',
        images: ['assets/m1.webp', 'assets/m2.webp', 'assets/m3.webp', 'assets/m4.webp'],
      ),
      models.GoToService(
        title: 'Appliance and Repair',
        subtitle: '4 services',
        images: ['assets/a1.webp', 'assets/a2.webp', 'assets/a3.webp', 'assets/a4.webp'],
      ),
      models.GoToService(
        title: 'Carpenter & Plumber',
        subtitle: '2 services',
        images: ['assets/c1.webp', 'assets/c2.webp', 'assets/c3.webp', 'assets/c4.webp'],
      ),
      models.GoToService(
        title: 'Cleaning Services',
        subtitle: '6 services',
        images: ['assets/cleaning1.webp', 'assets/cleaning2.webp', 'assets/cleaning3.webp', 'assets/cleaning4.webp'],
      ),
      models.GoToService(
        title: 'Women Spa & Wellness',
        subtitle: '8 services',
        images: ['assets/w1.webp', 'assets/w2.webp', 'assets/w3.webp', 'assets/w4.webp'],
      ),
    ];
  }

  // Get GoTo services - dummy data first strategy
  Future<List<models.GoToService>> getGoToServices() async {
    final dummyGoToServices = _getDummyGoToServices();
    
    try {
      print('🌐 Fetching GoTo services from API...');
      final remoteGoToServices = await _apiService.getGoToServices();
      return remoteGoToServices;
    } catch (e) {
      // Return enhanced dummy data as fallback
      print('🔄 Using dummy goto services data for development: $e');
      return dummyGoToServices;
    }
  }

  // Dummy banner data
  models.Banner _getDummyBanner() {
    return models.Banner(
      title: "Let's make a package just\nfor you, Manvi!",
      subtitle: "Salon for women",
      image: 'assets/banner_woman.webp',
    );
  }

  // Get banner data
  Future<models.Banner> getBanner() async {
    try {
      // Try to fetch banner from API
      print('🌐 Fetching banner from API...');
      final homeData = await _apiService.getHomeData();
      return homeData?.banner ?? _getDummyBanner();
    } catch (e) {
      print('🔄 Using dummy banner data for development: $e');
      return _getDummyBanner();
    }
  }

  // Dummy appliance repair services
  List<Map<String, String>> _getDummyApplianceRepairServices() {
    return [
      {'title': 'Chimney', 'image': 'assets/chimney.webp'},
      {'title': 'Washing Machine', 'image': 'assets/washing_machine.webp'},
      {'title': 'Water Purifier', 'image': 'assets/water_purifier.webp'},
      {'title': 'Refrigerator', 'image': 'assets/refrigerator.webp'},
      {'title': 'Air Cooler', 'image': 'assets/air_cooler.webp'},
      {'title': 'Television', 'image': 'assets/television.webp'},
      {'title': 'AC Services and Repair', 'image': 'assets/ac_repair.webp'},
      {'title': 'Microwave', 'image': 'assets/microwave.webp'},
    ];
  }

  // Get appliance repair services
  Future<List<Map<String, String>>> getApplianceRepairServices() async {
    try {
      // Try to fetch from API when available
      // final services = await _apiService.getApplianceRepairServices();
      // return services;
      
      // For now, return dummy data
      print('🔄 Using dummy appliance repair services for development');
      return _getDummyApplianceRepairServices();
    } catch (e) {
      print('🔄 Using dummy appliance repair services for development: $e');
      return _getDummyApplianceRepairServices();
    }
  }

  // Dummy AC repair services
  List<Map<String, String>> _getDummyAcRepairServices() {
    return [
      {'imagePath': 'assets/ac_services.webp', 'title': 'AC Services'},
      {'imagePath': 'assets/ac_repair.webp', 'title': 'AC Repair & Gas Refill'},
      {'imagePath': 'assets/ac_installation.webp', 'title': 'AC Installation'},
      {'imagePath': 'assets/ac_uninstallation.webp', 'title': 'AC Uninstallation'},
      {'imagePath': 'assets/ac_cleaning.webp', 'title': 'AC Deep Cleaning'},
    ];
  }

  // Get AC repair services
  Future<List<Map<String, String>>> getAcRepairServices() async {
    try {
      // Try to fetch from API when available
      // final services = await _apiService.getAcRepairServices();
      // return services;
      
      // For now, return dummy data
      print('🔄 Using dummy AC repair services for development');
      return _getDummyAcRepairServices();
    } catch (e) {
      print('🔄 Using dummy AC repair services for development: $e');
      return _getDummyAcRepairServices();
    }
  }

  // Dummy male spa services
  List<Map<String, String>> _getDummyMaleSpaServices() {
    return [
      {'imagePath': 'assets/spa_men_swedish.webp', 'label': 'Swedish Massage'},
      {'imagePath': 'assets/spa_men_backrelief.webp', 'label': 'Back Relief'},
      {'imagePath': 'assets/spa_men_bodypolish.webp', 'label': 'Body Polish'},
      {'imagePath': 'assets/spa_men_facial.webp', 'label': 'Deep Cleansing Facial'},
      {'imagePath': 'assets/spa_men_aromatherapy.webp', 'label': 'Aromatherapy'},
    ];
  }

  // Get male spa services
  Future<List<Map<String, String>>> getMaleSpaServices() async {
    try {
      // Try to fetch from API when available
      print('🔄 Using dummy male spa services for development');
      return _getDummyMaleSpaServices();
    } catch (e) {
      print('🔄 Using dummy male spa services for development: $e');
      return _getDummyMaleSpaServices();
    }
  }

  // Dummy salon men services
  List<Map<String, String>> _getDummySalonMenServices() {
    return [
      {'imagePath': 'assets/salon_men_haircut_beard.webp', 'label': 'Haircut & Beard Styling'},
      {'imagePath': 'assets/salon_men_haircolor_spa.webp', 'label': 'Hair Colour & Hair Spa'},
      {'imagePath': 'assets/salon_men_facial_cleanup.webp', 'label': 'Facial & Cleanup'},
      {'imagePath': 'assets/salon_men_massage.webp', 'label': 'Head Massage'},
    ];
  }

  // Get salon men services
  Future<List<Map<String, String>>> getSalonMenServices() async {
    try {
      // Try to fetch from API when available
      print('🔄 Using dummy salon men services for development');
      return _getDummySalonMenServices();
    } catch (e) {
      print('🔄 Using dummy salon men services for development: $e');
      return _getDummySalonMenServices();
    }
  }

  // Dummy women salon services
  List<Map<String, String>> _getDummyWomenSalonServices() {
    return [
      {
        'title1': 'Bleach & Detan',
        'image1': 'assets/saloon_bleach.webp',
        'title2': 'Facial & Cleanup',
        'image2': 'assets/saloon_facial.webp',
      },
      {
        'title1': 'Pedicure',
        'image1': 'assets/saloon_pedicure.webp',
        'title2': 'Threading',
        'image2': 'assets/saloon_threading.webp',
      },
      {
        'title1': 'Waxing',
        'image1': 'assets/saloon_waxing.webp',
        'title2': 'Manicure',
        'image2': 'assets/saloon_manicure.webp',
      },
      {
        'title1': 'Hair Styling',
        'image1': 'assets/saloon_styling.webp',
        'title2': 'Hair Spa',
        'image2': 'assets/saloon_spa.webp',
      },
    ];
  }

  // Get women salon services
  Future<List<Map<String, String>>> getWomenSalonServices() async {
    try {
      // Try to fetch from API when available
      print('🔄 Using dummy women salon services for development');
      return _getDummyWomenSalonServices();
    } catch (e) {
      print('🔄 Using dummy women salon services for development: $e');
      return _getDummyWomenSalonServices();
    }
  }

  // Dummy women spa services
  List<Map<String, String>> _getDummyWomenSpaServices() {
    return [
      {'imagePath': 'assets/spa_massage.webp', 'label': 'Full Body Massage'},
      {'imagePath': 'assets/spa_scrub.webp', 'label': 'Body Scrub'},
      {'imagePath': 'assets/spa_steam.webp', 'label': 'Steam Therapy'},
      {'imagePath': 'assets/spa_facial.webp', 'label': 'Relaxing Facial'},
      {'imagePath': 'assets/spa_aromatherapy.webp', 'label': 'Aromatherapy'},
    ];
  }

  // Get women spa services
  Future<List<Map<String, String>>> getWomenSpaServices() async {
    try {
      // Try to fetch from API when available
      print('🔄 Using dummy women spa services for development');
      return _getDummyWomenSpaServices();
    } catch (e) {
      print('🔄 Using dummy women spa services for development: $e');
      return _getDummyWomenSpaServices();
    }
  }

  // Get complete home data
  Future<models.HomeData?> getHomeData() async {
    try {
      print('🌐 Fetching complete home data from API...');
      return await _apiService.getHomeData();
    } catch (e) {
      print('🔄 API not available, using repository fallback methods: $e');
      return null;
    }
  }
}
