import 'package:flutter/foundation.dart';

class SaathiViewModel extends ChangeNotifier {
  final List<Map<String, dynamic>> _saathiList = [
    {"name": "Anita Kumari", "rating": "4.8", "jobs": "354", "image": "assets/saathi1.webp"},
    {"name": "Ansh Kumar", "rating": "4.8", "jobs": "354", "image": "assets/saathi2.webp"},
    {"name": "Sunil Kumar", "rating": "4.8", "jobs": "354", "image": "assets/saathi3.webp"},
    {"name": "Anita Kumari", "rating": "4.8", "jobs": "354", "image": "assets/saathi1.webp"},
    {"name": "Sunil Kumar", "rating": "4.8", "jobs": "354", "image": "assets/saathi3.webp"},
    {"name": "Anita Kumari", "rating": "4.8", "jobs": "354", "image": "assets/saathi1.webp"},
  ];

  int _selectedIndex = 0;

  // Getters to expose data to the view
  List<Map<String, dynamic>> get saathiList => _saathiList;
  int get selectedIndex => _selectedIndex;

  // Business logic methods
  void onItemTapped(int index) {
    if (index == _selectedIndex) return;
    _selectedIndex = index;
    notifyListeners();
  }

  // Navigation logic
  void navigateToScreen(int index) {
    switch (index) {
      case 1:
        // Navigate to Booking
        break;
      case 2:
        // Navigate to Home
        break;
      case 3:
        // Navigate to Rewards
        break;
      case 4:
        // Navigate to Profile
        break;
    }
  }

  // Optional: Method to add new saathi
  void addSaathi(Map<String, dynamic> saathi) {
    _saathiList.add(saathi);
    notifyListeners();
  }

  // Optional: Method to remove saathi
  void removeSaathi(int index) {
    if (index >= 0 && index < _saathiList.length) {
      _saathiList.removeAt(index);
      notifyListeners();
    }
  }
}
