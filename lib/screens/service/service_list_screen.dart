import 'package:flutter/material.dart';
import '../../services/category_service.dart';
import '../../services/service_service.dart';
import '../../models/category_model.dart';
import '../../models/service_model.dart';
import '../../utils/constants.dart';
import 'service_detail_screen.dart';

class ServiceListScreen extends StatefulWidget {
  final String? categoryId;
  final String? categoryName;

  const ServiceListScreen({Key? key, this.categoryId, this.categoryName})
      : super(key: key);

  @override
  _ServiceListScreenState createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
  List<Service> _services = [];
  List<Category> _categories = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedCategoryId = '';
  int _currentPage = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.categoryId ?? '';
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final categories = await CategoryService.getCategories();
      final services = await ServiceService.getServices(
        categoryId: _selectedCategoryId,
        searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
      );

      setState(() {
        _categories = categories;
        _services = services;
        _isLoading = false;
        _hasMore = services.length >= 10;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackbar('Failed to load services: $e');
    }
  }

  Future<void> _loadMoreServices() async {
    if (!_hasMore || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final moreServices = await ServiceService.getServices(
        categoryId: _selectedCategoryId.isEmpty ? null : _selectedCategoryId,
        searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
        page: _currentPage + 1,
      );

      setState(() {
        _services.addAll(moreServices);
        _currentPage++;
        _hasMore = moreServices.length >= 10;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackbar('Failed to load more services: $e');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Constants.errorColor,
      ),
    );
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query;
      _currentPage = 1;
      _services.clear();
    });
    _loadInitialData();
  }

  void _onCategorySelected(String categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
      _currentPage = 1;
      _services.clear();
    });
    _loadInitialData();
  }

  void _clearFilters() {
    setState(() {
      _selectedCategoryId = '';
      _searchQuery = '';
      _currentPage = 1;
      _services.clear();
    });
    _loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.categoryName ?? 'All Services',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Constants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search and Filter Section
          _buildSearchFilterSection(),

          // Services List
          Expanded(
            child: _isLoading && _services.isEmpty
                ? _buildLoadingIndicator()
                : _services.isEmpty
                    ? _buildEmptyState()
                    : _buildServicesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchFilterSection() {
    return Container(
      padding: EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Bar
          TextField(
            onChanged: _onSearch,
            decoration: InputDecoration(
              hintText: 'Search services...',
              prefixIcon: Icon(Icons.search, color: Constants.primaryColor),
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AppConstants.defaultBorderRadius),
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          SizedBox(height: 12),

          // Categories Filter
          _buildCategoriesFilter(),

          // Active Filters
          if (_selectedCategoryId.isNotEmpty || _searchQuery.isNotEmpty)
            _buildActiveFilters(),
        ],
      ),
    );
  }

  Widget _buildCategoriesFilter() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length + 1, // +1 for "All" option
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildCategoryChip(
              category: Category(
                id: '',
                name: 'All',
                description: 'All categories',
                createdAt: DateTime.now(),
              ),
              isSelected: _selectedCategoryId.isEmpty,
            );
          }

          final category = _categories[index - 1];
          return _buildCategoryChip(
            category: category,
            isSelected: _selectedCategoryId == category.id,
          );
        },
      ),
    );
  }

  Widget _buildCategoryChip(
      {required Category category, required bool isSelected}) {
    return Container(
      margin: EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(category.name),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            _onCategorySelected(category.id);
          } else {
            _onCategorySelected('');
          }
        },
        backgroundColor: Colors.grey[100],
        selectedColor: Constants.primaryColor.withOpacity(0.2),
        checkmarkColor: Constants.primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? Constants.primaryColor : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildActiveFilters() {
    return Row(
      children: [
        Text(
          'Active filters:',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        SizedBox(width: 8),
        if (_selectedCategoryId.isNotEmpty)
          Chip(
            label: Text(
              _categories
                  .firstWhere((cat) => cat.id == _selectedCategoryId)
                  .name,
              style: TextStyle(fontSize: 12),
            ),
            backgroundColor: Constants.primaryColor.withOpacity(0.1),
            deleteIcon: Icon(Icons.close, size: 16),
            onDeleted: () => _onCategorySelected(''),
          ),
        if (_searchQuery.isNotEmpty)
          Chip(
            label: Text(
              '"$_searchQuery"',
              style: TextStyle(fontSize: 12),
            ),
            backgroundColor: Constants.accentColor.withOpacity(0.1),
            deleteIcon: Icon(Icons.close, size: 16),
            onDeleted: () => _onSearch(''),
          ),
        Spacer(),
        TextButton(
          onPressed: _clearFilters,
          child: Text(
            'Clear all',
            style: TextStyle(
              color: Constants.primaryColor,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServicesList() {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (scrollNotification is ScrollEndNotification &&
            scrollNotification.metrics.pixels ==
                scrollNotification.metrics.maxScrollExtent &&
            _hasMore) {
          _loadMoreServices();
        }
        return false;
      },
      child: ListView.builder(
        padding: EdgeInsets.all(AppConstants.defaultPadding),
        itemCount: _services.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _services.length) {
            return _buildLoadMoreIndicator();
          }
          return _buildServiceItem(_services[index]);
        },
      ),
    );
  }

  Widget _buildServiceItem(Service service) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ServiceDetailScreen(service: service),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        child: Padding(
          padding: EdgeInsets.all(16),
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
                  image: service.images.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(service.images.first),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: service.images.isEmpty
                    ? Icon(Icons.construction, color: Colors.grey[400])
                    : null,
              ),
              SizedBox(width: 16),

              // Service Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      service.description.truncate(80),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        SizedBox(width: 4),
                        Text(
                          service.ratingText,
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                        SizedBox(width: 8),
                        Text(
                          '(${service.reviewCount})',
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        Spacer(),
                        Icon(Icons.schedule, size: 14, color: Colors.grey[500]),
                        SizedBox(width: 4),
                        Text(
                          service.duration,
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          service.formattedPrice,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Constants.primaryColor,
                          ),
                        ),
                        Spacer(),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: service.isAvailable
                                ? Constants.successColor.withOpacity(0.1)
                                : Constants.errorColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            service.isAvailable ? 'Available' : 'Unavailable',
                            style: TextStyle(
                              fontSize: 10,
                              color: service.isAvailable
                                  ? Constants.successColor
                                  : Constants.errorColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Constants.primaryColor),
          SizedBox(height: 16),
          Text(
            'Loading services...',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: _isLoading
            ? CircularProgressIndicator(color: Constants.primaryColor)
            : Text(
                'No more services',
                style: TextStyle(color: Colors.grey[500]),
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'No services found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try adjusting your search terms'
                : 'No services available in this category',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500]),
          ),
          SizedBox(height: 20),
          if (_searchQuery.isNotEmpty || _selectedCategoryId.isNotEmpty)
            ElevatedButton(
              onPressed: _clearFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: Constants.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: Text('Clear Filters'),
            ),
        ],
      ),
    );
  }
}
