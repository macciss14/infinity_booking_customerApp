// lib/screens/service/service_list_screen.dart - COMPLETE FIXED VERSION
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/service_service.dart';
import '../../services/category_service.dart';
import '../../models/service_model.dart';
import '../../models/category_model.dart';
import '../../models/subcategory_model.dart';
import '../../providers/service_filter_provider.dart';
import '../../utils/constants.dart';
import '../../config/route_helper.dart';

class ServiceListScreen extends StatefulWidget {
  final String? categoryId;
  final String? subcategoryId;
  final String? searchQuery;
  final String? categoryName;
  final String? subcategoryName;

  const ServiceListScreen({
    super.key,
    this.categoryId,
    this.subcategoryId,
    this.searchQuery,
    this.categoryName,
    this.subcategoryName,
  });

  @override
  State<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
  final ServiceService _serviceService = ServiceService();
  final CategoryService _categoryService = CategoryService();

  late Future<List<ServiceModel>> _servicesFuture;
  late Future<List<CategoryModel>> _categoriesFuture;
  late Future<List<SubcategoryModel>> _subcategoriesFuture;
  bool _isLoading = true;
  late TextEditingController _searchController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadData() {
    setState(() {
      _isLoading = true;
    });

    _servicesFuture = _serviceService.getAllServices();
    _categoriesFuture = _categoryService.getCategories();

    // Load subcategories after categories are loaded
    _subcategoriesFuture = _loadAllSubcategories();
  }

  Future<List<SubcategoryModel>> _loadAllSubcategories() async {
    try {
      final categories = await _categoriesFuture;
      final allSubcategories = <SubcategoryModel>[];

      print('Loading subcategories for ${categories.length} categories...');

      for (var category in categories) {
        try {
          print(
              'Fetching subcategories for category: ${category.name} (${category.id})');
          final subcategories =
              await _categoryService.getSubcategoriesByCategory(category.id);
          if (subcategories.isNotEmpty) {
            print(
                'Found ${subcategories.length} subcategories for ${category.name}');
            allSubcategories.addAll(subcategories);
          } else {
            print('No subcategories found for ${category.name}');
          }
        } catch (e) {
          print('Error loading subcategories for ${category.name}: $e');
          // Continue with other categories
        }
      }

      print('Total subcategories loaded: ${allSubcategories.length}');
      return allSubcategories;
    } catch (e) {
      print('Error loading all subcategories: $e');
      return [];
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildSearchBar(ServiceFilterProvider filterProvider) {
    // Update controller if search query changed from elsewhere
    if (_searchController.text != filterProvider.searchQuery) {
      _searchController.text = filterProvider.searchQuery;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search services, categories, providers...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: filterProvider.searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    filterProvider.setSearchQuery('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        onChanged: (value) {
          // Update filter provider with search query
          filterProvider.setSearchQuery(value);
        },
      ),
    );
  }

  Widget _buildCategoryChips(ServiceFilterProvider filterProvider) {
    if (filterProvider.allCategories.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: Colors.white,
        child: const Text(
          'No categories available',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Categories',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: filterProvider.allCategories.length +
                  1, // +1 for "All" option
              itemBuilder: (context, index) {
                if (index == 0) {
                  // "All" option
                  final isSelected = filterProvider.selectedCategory == null;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: const Text('All'),
                      selected: isSelected,
                      onSelected: (selected) {
                        filterProvider.selectCategory(null);
                      },
                      selectedColor: AppColors.primary,
                      backgroundColor: Colors.grey[200],
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                }

                final category = filterProvider.allCategories[index - 1];
                final isSelected =
                    filterProvider.selectedCategory?.id == category.id;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(category.name),
                    selected: isSelected,
                    onSelected: (selected) {
                      filterProvider.selectCategory(category);
                    },
                    selectedColor: AppColors.primaryLight,
                    backgroundColor: Colors.grey[200],
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubcategoryChips(ServiceFilterProvider filterProvider) {
    final subcategories = filterProvider.getSubcategoriesForSelectedCategory();

    if (filterProvider.selectedCategory == null || subcategories.isEmpty) {
      return const SizedBox();
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Subcategories in ${filterProvider.selectedCategory!.name}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: subcategories.length + 1, // +1 for "All" option
              itemBuilder: (context, index) {
                if (index == 0) {
                  // "All" option for subcategories
                  final isSelected = filterProvider.selectedSubcategory == null;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: const Text('All'),
                      selected: isSelected,
                      onSelected: (selected) {
                        filterProvider.selectSubcategory(null);
                      },
                      selectedColor: AppColors.secondary,
                      backgroundColor: Colors.grey[200],
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                }

                final subcategory = subcategories[index - 1];
                final isSelected =
                    filterProvider.selectedSubcategory?.id == subcategory.id;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(subcategory.name),
                    selected: isSelected,
                    onSelected: (selected) {
                      filterProvider.selectSubcategory(subcategory);
                    },
                    selectedColor: AppColors.secondary,
                    backgroundColor: Colors.grey[200],
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilters(ServiceFilterProvider filterProvider) {
    if (!filterProvider.hasActiveFilters) return const SizedBox();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          if (filterProvider.selectedCategory != null)
            Chip(
              label: Text(filterProvider.selectedCategory!.name),
              onDeleted: () => filterProvider.selectCategory(null),
              deleteIcon: const Icon(Icons.close, size: 16),
            ),
          if (filterProvider.selectedSubcategory != null)
            Chip(
              label: Text(filterProvider.selectedSubcategory!.name),
              onDeleted: () => filterProvider.selectSubcategory(null),
              deleteIcon: const Icon(Icons.close, size: 16),
            ),
          if (filterProvider.searchQuery.isNotEmpty)
            Chip(
              label: Text('"${filterProvider.searchQuery}"'),
              onDeleted: () {
                _searchController.clear();
                filterProvider.setSearchQuery('');
              },
              deleteIcon: const Icon(Icons.close, size: 16),
            ),
          OutlinedButton.icon(
            onPressed: () {
              _searchController.clear();
              filterProvider.clearFilters();
            },
            icon: const Icon(Icons.clear_all, size: 16),
            label: const Text('Clear All'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortDropdown(ServiceFilterProvider filterProvider) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.sort, size: 20, color: Colors.grey),
          const SizedBox(width: 8),
          const Text('Sort by:', style: TextStyle(color: Colors.grey)),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: filterProvider.sortBy,
            underline: Container(height: 0),
            items: const [
              DropdownMenuItem(
                value: 'newest',
                child: Text('Newest First'),
              ),
              DropdownMenuItem(
                value: 'oldest',
                child: Text('Oldest First'),
              ),
              DropdownMenuItem(
                value: 'price_low',
                child: Text('Price: Low to High'),
              ),
              DropdownMenuItem(
                value: 'price_high',
                child: Text('Price: High to Low'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                filterProvider.setSortBy(value);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(
      ServiceModel service, ServiceFilterProvider filterProvider) {
    final categoryName = filterProvider.getCategoryName(service.categoryId);
    final subcategoryNames =
        filterProvider.getSubcategoryNames(service.subcategoryIds);

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 1,
      child: InkWell(
        onTap: () {
          RouteHelper.pushNamed(
            context,
            RouteHelper.serviceDetail,
            arguments: service.id,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                  image:
                      service.imageUrl != null && service.imageUrl!.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(service.imageUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                ),
                child: service.imageUrl == null || service.imageUrl!.isEmpty
                    ? const Icon(
                        Icons.build,
                        size: 40,
                        color: Colors.grey,
                      )
                    : null,
              ),
              const SizedBox(width: 12),

              // Service Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Category and Subcategory
                    if (categoryName.isNotEmpty &&
                        categoryName != 'Uncategorized')
                      Wrap(
                        spacing: 8,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              categoryName,
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (subcategoryNames.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                subcategoryNames.split(', ').first,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),

                    const SizedBox(height: 6),

                    // Description
                    Text(
                      service.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // Price and Provider
                    Row(
                      children: [
                        // Price
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            service.formattedPrice,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondary,
                              fontSize: 14,
                            ),
                          ),
                        ),

                        const Spacer(),

                        // Provider
                        Row(
                          children: [
                            const Icon(
                              Icons.person_outline,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              service.providerName ?? 'Service Provider',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ServiceFilterProvider filterProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              filterProvider.hasActiveFilters
                  ? 'No services match your filters'
                  : 'No services available',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              filterProvider.hasActiveFilters
                  ? 'Try adjusting your search or filters'
                  : 'Check back later for new services',
              style: const TextStyle(
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            if (filterProvider.hasActiveFilters)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: ElevatedButton(
                  onPressed: () {
                    _searchController.clear();
                    filterProvider.clearFilters();
                  },
                  child: const Text('Clear All Filters'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(top: 8),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 80,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildServicesList(ServiceFilterProvider filterProvider) {
    if (filterProvider.isLoading) {
      return _buildLoadingState();
    }

    if (filterProvider.filteredServices.isEmpty) {
      return _buildEmptyState(filterProvider);
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(top: 8, bottom: 20),
      itemCount: filterProvider.filteredServices.length,
      itemBuilder: (context, index) {
        final service = filterProvider.filteredServices[index];
        return _buildServiceCard(service, filterProvider);
      },
    );
  }

  Widget _buildHeaderContent(ServiceFilterProvider filterProvider) {
    return Column(
      children: [
        // Search Bar
        _buildSearchBar(filterProvider),

        // Categories (with "All" option)
        _buildCategoryChips(filterProvider),

        // Subcategories (if category selected)
        _buildSubcategoryChips(filterProvider),

        // Active Filters
        _buildActiveFilters(filterProvider),

        // Sort Dropdown
        _buildSortDropdown(filterProvider),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Services'),
          backgroundColor: AppColors.primary,
        ),
        body: _buildLoadingState(),
      );
    }

    return FutureBuilder(
      future: Future.wait(
          [_servicesFuture, _categoriesFuture, _subcategoriesFuture]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Services'),
              backgroundColor: AppColors.primary,
            ),
            body: _buildLoadingState(),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Services'),
              backgroundColor: AppColors.primary,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Failed to load services',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final services = snapshot.data![0] as List<ServiceModel>;
        final categories = snapshot.data![1] as List<CategoryModel>;
        final subcategories = snapshot.data![2] as List<SubcategoryModel>;

        return ChangeNotifierProvider(
          create: (context) {
            final provider = ServiceFilterProvider();
            provider.initializeData(
              services: services,
              categories: categories,
              subcategories: subcategories,
            );

            // Apply initial filters from constructor
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (widget.categoryId != null && widget.categoryId!.isNotEmpty) {
                final category = categories.firstWhere(
                  (cat) => cat.id == widget.categoryId,
                  orElse: () => CategoryModel(id: '', name: ''),
                );
                if (category.id.isNotEmpty) {
                  provider.selectCategory(category);
                }
              }
              if (widget.subcategoryId != null &&
                  widget.subcategoryId!.isNotEmpty) {
                final subcategory = subcategories.firstWhere(
                  (sub) => sub.id == widget.subcategoryId,
                  orElse: () =>
                      SubcategoryModel(id: '', name: '', categoryId: ''),
                );
                if (subcategory.id.isNotEmpty) {
                  provider.selectSubcategory(subcategory);
                }
              }
              if (widget.searchQuery != null &&
                  widget.searchQuery!.isNotEmpty) {
                _searchController.text = widget.searchQuery!;
                provider.setSearchQuery(widget.searchQuery!);
              }
            });

            return provider;
          },
          child: Consumer<ServiceFilterProvider>(
            builder: (context, filterProvider, child) {
              return Scaffold(
                appBar: AppBar(
                  title: Text(_getAppBarTitle(filterProvider)),
                  backgroundColor: AppColors.primary,
                  actions: [
                    if (filterProvider.hasActiveFilters)
                      IconButton(
                        icon: const Icon(Icons.clear_all),
                        onPressed: () {
                          _searchController.clear();
                          filterProvider.clearFilters();
                        },
                        tooltip: 'Clear filters',
                      ),
                  ],
                ),
                body: RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      _loadData();
                    });
                    await Future.delayed(const Duration(seconds: 1));
                  },
                  child: CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      // Fixed header section (search, categories, filters)
                      SliverToBoxAdapter(
                        child: _buildHeaderContent(filterProvider),
                      ),

                      // Services list
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            // Services count
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                              child: Row(
                                children: [
                                  Text(
                                    '${filterProvider.filteredServices.length} ${filterProvider.filteredServices.length == 1 ? 'service' : 'services'} found',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (filterProvider.hasActiveFilters)
                                    TextButton(
                                      onPressed: () {
                                        _searchController.clear();
                                        filterProvider.clearFilters();
                                      },
                                      child: const Text(
                                        'Clear filters',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Services grid/list
                      filterProvider.isLoading
                          ? SliverToBoxAdapter(
                              child: _buildLoadingState(),
                            )
                          : filterProvider.filteredServices.isEmpty
                              ? SliverToBoxAdapter(
                                  child: _buildEmptyState(filterProvider),
                                )
                              : SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      final service = filterProvider
                                          .filteredServices[index];
                                      return _buildServiceCard(
                                          service, filterProvider);
                                    },
                                    childCount:
                                        filterProvider.filteredServices.length,
                                  ),
                                ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _getAppBarTitle(ServiceFilterProvider filterProvider) {
    // First check if constructor provided names
    if (widget.categoryName != null && widget.categoryName!.isNotEmpty) {
      return widget.categoryName!;
    }
    if (widget.subcategoryName != null && widget.subcategoryName!.isNotEmpty) {
      return widget.subcategoryName!;
    }

    // Fall back to filter provider names
    if (filterProvider.selectedSubcategory != null) {
      return filterProvider.selectedSubcategory!.name;
    } else if (filterProvider.selectedCategory != null) {
      return filterProvider.selectedCategory!.name;
    } else if (filterProvider.searchQuery.isNotEmpty) {
      return 'Search Results';
    }
    return 'All Services';
  }
}