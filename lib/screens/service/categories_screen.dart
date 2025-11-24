import 'package:flutter/material.dart';
import '../../services/category_service.dart';
import '../../models/category_model.dart';
import '../../utils/constants.dart';
import 'subcategories_screen.dart';
import 'service_list_screen.dart';

class CategoriesScreen extends StatefulWidget {
  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List<Category> _categories = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      print('🔄 CategoriesScreen - Loading categories...');
      final categories = await CategoryService.getCategories();

      setState(() {
        _categories = categories;
        _isLoading = false;
      });

      print('✅ CategoriesScreen - Loaded ${categories.length} categories');
    } catch (e) {
      print('💥 CategoriesScreen - Error loading categories: $e');
      setState(() {
        _errorMessage = 'Failed to load categories: $e';
        _isLoading = false;
      });
    }
  }

  void _onCategoryTap(Category category) {
    if (category.subcategories != null && category.subcategories!.isNotEmpty) {
      // Navigate to subcategories screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SubcategoriesScreen(
            category: category,
            subcategories: category.subcategories!,
          ),
        ),
      );
    } else {
      // Navigate directly to services list for this category
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ServiceListScreen(
            categoryId: category.id,
            categoryName: category.name,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Browse Categories',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Constants.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadCategories,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _errorMessage.isNotEmpty
              ? _buildErrorState()
              : _categories.isEmpty
                  ? _buildEmptyState()
                  : _buildCategoriesGrid(),
    );
  }

  Widget _buildCategoriesGrid() {
    return Padding(
      padding: EdgeInsets.all(AppConstants.defaultPadding),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.9,
        ),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return _buildCategoryCard(category);
        },
      ),
    );
  }

  Widget _buildCategoryCard(Category category) {
    final hasSubcategories =
        category.subcategories != null && category.subcategories!.isNotEmpty;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      child: InkWell(
        onTap: () => _onCategoryTap(category),
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Constants.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: category.icon != null
                    ? Icon(
                        Icons.category,
                        color: Constants.primaryColor,
                        size: 30,
                      )
                    : Icon(
                        Icons.category,
                        color: Constants.primaryColor,
                        size: 30,
                      ),
              ),
              SizedBox(height: 12),
              Text(
                category.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
              Text(
                '${category.serviceCount} services',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 4),
              if (hasSubcategories)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Constants.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${category.subcategories!.length} subcategories',
                    style: TextStyle(
                      fontSize: 10,
                      color: Constants.accentColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Constants.primaryColor),
          SizedBox(height: 16),
          Text(
            'Loading categories...',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.orange),
          SizedBox(height: 16),
          Text(
            'Unable to load categories',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _loadCategories,
            icon: Icon(Icons.refresh),
            label: Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Constants.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.category, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'No categories available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Check back later for available services',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
