import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/search_model.dart';
import '../data/repository/search_repository.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class SearchPageController extends GetxController {
  final SearchRepository _repo = SearchRepository();

  final TextEditingController textController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  var isLoading = false.obs;
  var hasError = false.obs;
  var searchResults = <SearchResult>[].obs;
  var isSearchActive = false.obs;

  // --- NEW VARIABLE ---
  // Tracks if an API search has actually completed (prevents empty state flash)
  var hasSearched = false.obs;

  Timer? _debounce;

  @override
  void onClose() {
    textController.dispose();
    focusNode.dispose();
    _debounce?.cancel();
    super.onClose();
  }

  void onSearchChanged(String query) {
    // 1. Reset hasSearched immediately when typing starts
    hasSearched.value = false;

    if (query.isEmpty) {
      isSearchActive.value = false;
      hasError.value = false;
      searchResults.clear();
      return;
    }

    isSearchActive.value = true;

    // 2. Clear previous results so screen is blank while waiting for new ones
    searchResults.clear();

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      fetchSearchResults(query);
    });
  }

  Future<void> fetchSearchResults(String query) async {
    try {
      isLoading.value = true;
      hasError.value = false;

      var results = await _repo.searchServices(query);
      searchResults.assignAll(results);
      FirebaseAnalytics.instance.logSearch(searchTerm: query);

      // 3. Mark search as completed ONLY after data returns
      hasSearched.value = true;
    } catch (e) {
      print("Search Error: $e");
      hasError.value = true;
      searchResults.clear();
      // Even on error, we mark the attempt as finished so empty state can show
      hasSearched.value = true;
    } finally {
      isLoading.value = false;
    }
  }
}
