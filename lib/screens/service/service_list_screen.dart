// lib/screens/service/service_list_screen.dart
import 'package:flutter/material.dart';
import '../../models/category_model.dart';
import '../../models/service_model.dart';
import '../../models/subcategory_model.dart';
import '../../services/category_service.dart';
import '../../services/service_service.dart';
import '../../utils/constants.dart';
import 'service_detail_screen.dart';

class ServiceListScreen extends StatefulWidget {
  const ServiceListScreen({super.key});

  @override
  State<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
  final ServiceService _serviceService = ServiceService();
  final CategoryService _categoryService = CategoryService();

  late Future<List<CategoryModel>> _categoriesFuture;
  Future<List<SubcategoryModel>>? _subcategoriesFuture;
  late Future<List<ServiceModel>> _servicesFuture;

  String? _selectedCategoryId;
  String? _selectedSubcategoryId;
  String? _selectedSort = 'newest';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    _categoriesFuture = _categoryService.getCategories();
    _servicesFuture = _serviceService.getServices();
  }

  void _onSearchChanged() => _refreshServices();

  void _onCategorySelected(String? categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
      _selectedSubcategoryId = null;
      if (categoryId != null) {
        _subcategoriesFuture =
            _categoryService.getSubcategoriesByCategory(categoryId);
      } else {
        _subcategoriesFuture = null;
      }
    });
    _refreshServices();
  }

  void _onSubcategorySelected(String? subcategoryId) {
    setState(() {
      _selectedSubcategoryId = subcategoryId;
    });
    _refreshServices();
  }

  void _onSortChanged(String? value) {
    setState(() {
      _selectedSort = value;
    });
    _refreshServices();
  }

  void _refreshServices() {
    setState(() {
      _servicesFuture = _serviceService
          .searchServices(
        query: _searchController.text,
        categoryId: _selectedCategoryId,
        subcategoryId: _selectedSubcategoryId,
        sort: _selectedSort,
      )
          .catchError((error) {
        print('Service search error: $error');
        return [];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 🔍 Search Bar
          Padding(
            padding: EdgeInsets.all(AppConstants.defaultPadding),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search services, providers, categories...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppConstants.defaultBorderRadius),
                ),
              ),
            ),
          ),

          // 🏷️ Categories
          FutureBuilder<List<CategoryModel>>(
            future: _categoriesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: AppConstants.defaultPadding),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(4, (index) => _buildLoadingChip()),
                  ),
                );
              }
              if (snapshot.hasError) {
                return Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: AppConstants.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Categories:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Error loading categories',
                          style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _categoriesFuture =
                                _categoryService.getCategories();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }
              final categories = snapshot.data ?? [];
              return Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: AppConstants.defaultPadding),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildCategoryChip(
                      label: 'All',
                      isSelected: _selectedCategoryId == null,
                      onPressed: () => _onCategorySelected(null),
                    ),
                    ...categories.map((cat) => _buildCategoryChip(
                          label: cat.name,
                          isSelected: _selectedCategoryId == cat.id,
                          onPressed: () => _onCategorySelected(cat.id),
                        )),
                  ],
                ),
              );
            },
          ),

          // 🧩 Subcategories (only when category selected)
          if (_selectedCategoryId != null)
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
              child: FutureBuilder<List<SubcategoryModel>>(
                future: _subcategoriesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          List.generate(3, (index) => _buildLoadingChip()),
                    );
                  }
                  if (snapshot.hasError) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Subcategory:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('Error loading subcategories',
                            style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _subcategoriesFuture =
                                  _categoryService.getSubcategoriesByCategory(
                                      _selectedCategoryId!);
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    );
                  }
                  final subs = snapshot.data ?? [];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Subcategory:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildCategoryChip(
                            label: 'All',
                            isSelected: _selectedSubcategoryId == null,
                            onPressed: () => _onSubcategorySelected(null),
                          ),
                          ...subs.map((sub) => _buildCategoryChip(
                                label: sub.name,
                                isSelected: _selectedSubcategoryId == sub.id,
                                onPressed: () => _onSubcategorySelected(sub.id),
                              )),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),

          // 📊 Sort Dropdown
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppConstants.defaultPadding,
              vertical: 8,
            ),
            child: Row(
              children: [
                const Text('Sort:'),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedSort,
                    items: const [
                      DropdownMenuItem(value: 'newest', child: Text('Newest')),
                      DropdownMenuItem(value: 'oldest', child: Text('Oldest')),
                      DropdownMenuItem(
                          value: 'priceAsc', child: Text('Price: Low to High')),
                      DropdownMenuItem(
                          value: 'priceDesc',
                          child: Text('Price: High to Low')),
                    ],
                    onChanged: _onSortChanged,
                    isExpanded: true,
                    underline: Container(),
                  ),
                ),
              ],
            ),
          ),

          // 📋 Services List
          Expanded(
            child: FutureBuilder<List<ServiceModel>>(
              future: _servicesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return _buildErrorWidget(snapshot.error.toString());
                }
                final services = snapshot.data ?? [];
                if (services.isEmpty) {
                  return const Center(child: Text('No services found'));
                }
                return ListView.builder(
                  padding: EdgeInsets.all(AppConstants.defaultPadding),
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    final service = services[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            AppConstants.defaultBorderRadius),
                      ),
                      child: ListTile(
                        leading: service.imageUrl != null
                            ? CircleAvatar(
                                radius: 25,
                                backgroundImage:
                                    NetworkImage(service.imageUrl!),
                              )
                            : const CircleAvatar(
                                radius: 25,
                                backgroundColor: Colors.grey,
                                child: Icon(Icons.build, color: Colors.white),
                              ),
                        title: Text(
                          service.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(text: '${service.providerName}'),
                              const TextSpan(text: ' • '),
                              TextSpan(
                                text: '\$${service.price.toStringAsFixed(2)}',
                                style: TextStyle(color: AppColors.secondary),
                              ),
                            ],
                          ),
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ServiceDetailScreen(serviceId: service.id),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip({
    required String label,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) => onPressed(),
      selectedColor: AppColors.primary,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColors.primary : const Color(0xFFCED4DA),
        ),
      ),
    );
  }

  Widget _buildLoadingChip() {
    return Container(
      width: 80,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Failed to load services',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshServices,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
