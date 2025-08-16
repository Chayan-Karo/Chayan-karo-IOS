import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeViewModel extends ChangeNotifier {
  // State variables
  String _address = 'Fetching location...';
  String _locationLabel = 'Home';
  bool _isLoading = false;

  // Getters
  String get address => _address;
  String get locationLabel => _locationLabel;
  bool get isLoading => _isLoading;

  // Static data (for now - will be moved to repository later)
  final List<Map<String, String>> categories = [
    {'title': 'Female Saloon', 'icon': 'assets/icons/female_saloon.svg'},
    {'title': 'Female Spa', 'icon': 'assets/icons/female_spa.svg'},
    {'title': 'Male Saloon', 'icon': 'assets/icons/male_saloon.svg'},
    {'title': 'Male Spa', 'icon': 'assets/icons/male_spa.svg'},
    {'title': 'Hair & Skin', 'icon': 'assets/icons/hair_skin.svg'},
    {'title': 'Home Repairs', 'icon': 'assets/icons/home_repairs.svg'},
    {'title': 'Cleaning', 'icon': 'assets/icons/cleaning.svg'},
    {'title': 'AC Services', 'icon': 'assets/icons/ac_service.svg'},
  ];

  final List<Map<String, dynamic>> goToServices = [
    {
      'title': 'Beauty & Wellness (Men)',
      'subtitle': '10 services',
      'images': ['assets/m1.webp', 'assets/m2.webp', 'assets/m3.webp', 'assets/m4.webp'],
    },
    {
      'title': 'Appliance and Repair',
      'subtitle': '4 services',
      'images': ['assets/a1.webp', 'assets/a2.webp', 'assets/a3.webp', 'assets/a4.webp'],
    },
    {
      'title': 'Carpenter & Plumber',
      'subtitle': '2 services',
      'images': ['assets/c1.webp', 'assets/c2.webp', 'assets/c3.webp', 'assets/c4.webp'],
    },
  ];

  final List<Map<String, String>> mostUsedServices = [
    {'image': 'assets/z1.webp', 'title': 'Window AC frame Installation'},
    {'image': 'assets/z2.webp', 'title': 'Women Salon Services'},
    {'image': 'assets/z3.webp', 'title': 'Home Deep Cleaning'},
    {'image': 'assets/z4.webp', 'title': 'Spa for Men'},
  ];

  // AC Repair Section Data
  final List<Map<String, String>> acRepairItems = [
    {'imagePath': 'assets/ac_services.webp', 'title': 'AC Services'},
    {'imagePath': 'assets/ac_repair.webp', 'title': 'AC Repair & Gas Refill'},
    {'imagePath': 'assets/ac_installation.webp', 'title': 'AC Installation'},
    {'imagePath': 'assets/ac_uninstallation.webp', 'title': 'AC Uninstallation'},
  ];

  // Appliances Repair Data
  final List<Map<String, String>> appliancesRepairItems = [
    {'title': 'Chimney', 'image': 'assets/chimney.webp'},
    {'title': 'Washing Machine', 'image': 'assets/washing_machine.webp'},
    {'title': 'Water Purifier', 'image': 'assets/water_purifier.webp'},
    {'title': 'Refrigerator', 'image': 'assets/refrigerator.webp'},
    {'title': 'Air Cooler', 'image': 'assets/air_cooler.webp'},
    {'title': 'Television', 'image': 'assets/television.webp'},
    {'title': 'AC Services and Repair', 'image': 'assets/ac_repair.webp'},
  ];

  // Male Spa Data
  final List<Map<String, String>> maleSpaItems = [
    {'imagePath': 'assets/spa_men_swedish.webp', 'label': 'Swedish Massage'},
    {'imagePath': 'assets/spa_men_backrelief.webp', 'label': 'Back Relief'},
    {'imagePath': 'assets/spa_men_bodypolish.webp', 'label': 'Body Polish'},
  ];

  // Salon Men Data
  final List<Map<String, String>> salonMenItems = [
    {'imagePath': 'assets/salon_men_haircut_beard.webp', 'label': 'Haircut & Beard Styling'},
    {'imagePath': 'assets/salon_men_haircolor_spa.webp', 'label': 'Hair Colour & Hair Spa'},
    {'imagePath': 'assets/salon_men_facial_cleanup.webp', 'label': 'Facial & Cleanup'},
  ];

  // Saloon Women Data
  final List<Map<String, String>> saloonWomenItems = [
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
  ];

  // Spa Women Data
  final List<Map<String, String>> spaWomenItems = [
    {'imagePath': 'assets/spa_massage.webp', 'label': 'Full Body Massage'},
    {'imagePath': 'assets/spa_scrub.webp', 'label': 'Body Scrub'},
    {'imagePath': 'assets/spa_steam.webp', 'label': 'Steam Therapy'},
  ];

  // Banner Data
  final Map<String, String> bannerData = {
    'title': "Let's make a package just\nfor you, Manvi!",
    'subtitle': "Salon for women",
    'image': 'assets/banner_woman.webp',
  };

  // Initialize
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    
    await _loadSavedAddress();
    
    _isLoading = false;
    notifyListeners();
  }

  // Load saved address from SharedPreferences
  Future<void> _loadSavedAddress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _locationLabel = prefs.getString('location_label') ?? 'Home';
      _address = prefs.getString('location_address') ?? 'Not Available';
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading address: $e');
    }
  }

  // Update location
  Future<void> updateLocation(String label, String address) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('location_label', label);
      await prefs.setString('location_address', address);
      
      _locationLabel = label;
      _address = address;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating location: $e');
    }
  }
}