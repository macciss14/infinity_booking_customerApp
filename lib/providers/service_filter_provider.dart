// lib/providers/service_filter_provider.dart - FIXED VERSION
import 'package:flutter/material.dart';
import '../models/service_model.dart';
import '../models/category_model.dart';
import '../models/subcategory_model.dart';

class ServiceFilterProvider with ChangeNotifier {
  // State
  List<ServiceModel> _allServices = [];
  List<CategoryModel> _allCategories = [];
  List<SubcategoryModel> _allSubcategories = [];
  List<ServiceModel> _filteredServices = [];
  CategoryModel? _selectedCategory;
  SubcategoryModel? _selectedSubcategory;
  String _searchQuery = '';
  String _sortBy = 'newest'; // newest, oldest, price_low, price_high
  bool _isLoading = false;
  String? _error;

  // Getters
  List<ServiceModel> get allServices => _allServices;
  List<CategoryModel> get allCategories => _allCategories;
  List<SubcategoryModel> get allSubcategories => _allSubcategories;
  List<ServiceModel> get filteredServices => _filteredServices;
  CategoryModel? get selectedCategory => _selectedCategory;
  SubcategoryModel? get selectedSubcategory => _selectedSubcategory;
  String get searchQuery => _searchQuery;
  String get sortBy => _sortBy;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasActiveFilters =>
      _searchQuery.isNotEmpty ||
      _selectedCategory != null ||
      _selectedSubcategory != null;

  // Initialize data
  Future<void> initializeData({
    required List<ServiceModel> services,
    required List<CategoryModel> categories,
    required List<SubcategoryModel> subcategories,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      _allServices = services;
      _allCategories = categories;
      _allSubcategories = subcategories;

      // Apply initial filtering and sorting
      _applyFilters();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  // Select category - FIXED: Only select one category at a time
  void selectCategory(CategoryModel? category) {
    if (_selectedCategory?.id == category?.id) {
      // Clicking the same category again should deselect it
      _selectedCategory = null;
    } else {
      _selectedCategory = category;
    }
    _selectedSubcategory = null; // Clear subcategory when changing category
    _applyFilters();
    notifyListeners();
  }

  // Select subcategory
  void selectSubcategory(SubcategoryModel? subcategory) {
    if (_selectedSubcategory?.id == subcategory?.id) {
      // Clicking the same subcategory again should deselect it
      _selectedSubcategory = null;
    } else {
      _selectedSubcategory = subcategory;
    }
    _applyFilters();
    notifyListeners();
  }

  // Set sort option
  void setSortBy(String sortOption) {
    _sortBy = sortOption;
    _applyFilters();
    notifyListeners();
  }

  // Clear all filters
  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _selectedSubcategory = null;
    _applyFilters();
    notifyListeners();
  }

  // Get subcategories for selected category
  List<SubcategoryModel> getSubcategoriesForSelectedCategory() {
    if (_selectedCategory == null) return [];

    return _allSubcategories
        .where((subcategory) => subcategory.categoryId == _selectedCategory!.id)
        .toList();
  }

  // Apply all filters and sorting
  void _applyFilters() {
    List<ServiceModel> filtered = _allServices;

    // Apply category filter
    if (_selectedCategory != null) {
      final subcategoryIds = _allSubcategories
          .where((sub) => sub.categoryId == _selectedCategory!.id)
          .map((sub) => sub.id)
          .toList();

      filtered = filtered.where((service) {
        if (service.subcategoryIds.isEmpty) return false;

        // Check if service has any subcategory in this category
        for (var serviceSubId in service.subcategoryIds) {
          if (subcategoryIds.contains(serviceSubId)) {
            return true;
          }
        }
        return false;
      }).toList();
    }

    // Apply subcategory filter
    if (_selectedSubcategory != null) {
      filtered = filtered.where((service) {
        if (service.subcategoryIds.isEmpty) return false;

        // Check if service has this specific subcategory
        return service.subcategoryIds.contains(_selectedSubcategory!.id);
      }).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((service) {
        return service.name.toLowerCase().contains(query) ||
            service.description.toLowerCase().contains(query) ||
            (service.providerName ?? '').toLowerCase().contains(query) ||
            // Check category name
            getCategoryName(service.categoryId).toLowerCase().contains(query) ||
            // Check subcategory names
            getSubcategoryNames(service.subcategoryIds)
                .toLowerCase()
                .contains(query);
      }).toList();
    }

    // Apply sorting
    filtered = _sortServices(filtered);

    _filteredServices = filtered;
  }

  // Sort services based on selected option
  List<ServiceModel> _sortServices(List<ServiceModel> services) {
    List<ServiceModel> sorted = List.from(services);

    switch (_sortBy) {
      case 'newest':
        // Sort by ID (assuming higher IDs are newer)
        sorted.sort((a, b) => b.id.compareTo(a.id));
        return sorted;
      case 'oldest':
        sorted.sort((a, b) => a.id.compareTo(b.id));
        return sorted;
      case 'price_low':
        sorted.sort((a, b) => a.price.compareTo(b.price));
        return sorted;
      case 'price_high':
        sorted.sort((a, b) => b.price.compareTo(a.price));
        return sorted;
      default:
        return sorted;
    }
  }

  // Helper methods to get category/subcategory names
  String getCategoryName(String categoryId) {
    if (categoryId.isEmpty) return 'Uncategorized';

    try {
      final category = _allCategories.firstWhere(
        (cat) => cat.id == categoryId,
      );
      return category.name;
    } catch (e) {
      return 'Uncategorized';
    }
  }

  String getSubcategoryNames(List<String> subcategoryIds) {
    if (subcategoryIds.isEmpty) return '';

    final names = <String>[];
    for (var id in subcategoryIds) {
      try {
        final subcategory = _allSubcategories.firstWhere(
          (sub) => sub.id == id,
        );
        names.add(subcategory.name);
      } catch (e) {
        names.add('Unknown');
      }
    }

    return names.join(', ');
  }
}
