import 'package:flutter/material.dart';
import '../../services/category_service.dart';
import '../../services/service_service.dart';
import '../../models/category_model.dart';
import '../../models/service_model.dart';
import '../../utils/constants.dart';

class HomeContent extends StatefulWidget {
  final VoidCallback onLoginRegisterPressed;

  const HomeContent({Key? key, required this.onLoginRegisterPressed})
      : super(key: key);

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  List<Category> _categories = [];
  List<Service> _featuredServices = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      print('🔄 HomeContent - Loading data...');

      // Load categories and services in parallel
      final categoriesFuture = CategoryService.getCategories();
      final servicesFuture = ServiceService.getFeaturedServices();

      final results = await Future.wait([
        categoriesFuture,
        servicesFuture,
      ], eagerError: true);

      final categories = results[0] as List<Category>;
      final services = results[1] as List<Service>;

      setState(() {
        _categories = categories;
        _featuredServices = services;
        _isLoading = false;
      });

      print(
          '✅ HomeContent - Data loaded: ${categories.length} categories, ${services.length} services');
    } catch (e) {
      print('💥 HomeContent - Error loading data: $e');
      setState(() {
        _errorMessage = 'Failed to load content. Please check your connection.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section
            _buildHeroSection(),
            SizedBox(height: 40),

            // Categories Section
            _buildCategoriesSection(),
            SizedBox(height: 40),

            // Featured Services Section
            _buildFeaturedServicesSection(),
            SizedBox(height: 40),

            // How It Works Section
            _buildHowItWorksSection(),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Constants.primaryColor.withOpacity(0.1),
            Constants.accentColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to Infinity Booking',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Constants.primaryColor,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Book your favorite services with ease. From home services to professional appointments, we connect you with the best service providers in Ethiopia.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
          SizedBox(height: 24),
          Row(
            children: [
              ElevatedButton(
                onPressed: widget.onLoginRegisterPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constants.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
                child: Text(
                  'Get Started Now',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: 16),
              OutlinedButton(
                onPressed: _loadData,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: Constants.primaryColor),
                ),
                child: Text(
                  'Explore Services',
                  style: TextStyle(
                    color: Constants.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Popular Categories',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Constants.primaryColor,
          ),
        ),
        SizedBox(height: 16),
        _isLoading
            ? _buildLoadingGrid()
            : _errorMessage.isNotEmpty
                ? _buildErrorWidget()
                : _categories.isEmpty
                    ? _buildEmptyState('No categories available yet',
                        'Categories will appear here soon')
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.2,
                        ),
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          return _buildCategoryCard(_categories[index]);
                        },
                      ),
      ],
    );
  }

  Widget _buildFeaturedServicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Featured Services',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Constants.primaryColor,
              ),
            ),
            TextButton(
              onPressed: widget.onLoginRegisterPressed,
              child: Text(
                'View All',
                style: TextStyle(
                  color: Constants.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        _isLoading
            ? _buildLoadingList()
            : _errorMessage.isNotEmpty
                ? _buildErrorWidget()
                : _featuredServices.isEmpty
                    ? _buildEmptyState('No services available',
                        'Services will appear here when providers add them')
                    : SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _featuredServices.length,
                          itemBuilder: (context, index) {
                            return _buildServiceCard(_featuredServices[index]);
                          },
                        ),
                      ),
      ],
    );
  }

  Widget _buildCategoryCard(Category category) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Opening ${category.name} services...'),
              backgroundColor: Constants.primaryColor,
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Constants.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getCategoryIcon(category.name),
                  color: Constants.primaryColor,
                  size: 24,
                ),
              ),
              SizedBox(height: 12),
              Text(
                category.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
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
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('home') || name.contains('cleaning')) {
      return Icons.home;
    } else if (name.contains('beauty') || name.contains('salon')) {
      return Icons.spa;
    } else if (name.contains('education') || name.contains('tutor')) {
      return Icons.school;
    } else if (name.contains('repair') || name.contains('maintenance')) {
      return Icons.build;
    } else if (name.contains('health') || name.contains('medical')) {
      return Icons.medical_services;
    } else {
      return Icons.category;
    }
  }

  Widget _buildServiceCard(Service service) {
    return Container(
      width: 280,
      margin: EdgeInsets.only(right: 16),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                service.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              Text(
                service.description.truncate(60),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 16),
                  SizedBox(width: 4),
                  Text(
                    service.ratingText,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '(${service.reviewCount})',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                service.formattedPrice,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Constants.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHowItWorksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How It Works',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Constants.primaryColor,
          ),
        ),
        SizedBox(height: 20),
        _buildStep(
          number: 1,
          title: 'Browse Services',
          description:
              'Explore various service categories and find what you need',
          icon: Icons.search,
        ),
        _buildStep(
          number: 2,
          title: 'Book & Pay',
          description: 'Select your preferred time and make secure payment',
          icon: Icons.calendar_today,
        ),
        _buildStep(
          number: 3,
          title: 'Get Served',
          description: 'Relax while qualified professionals serve you',
          icon: Icons.emoji_events,
        ),
      ],
    );
  }

  Widget _buildStep({
    required int number,
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Constants.primaryColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          SizedBox(width: 16),
          Icon(icon, color: Constants.primaryColor, size: 24),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(height: 12),
                Container(
                  width: 80,
                  height: 12,
                  color: Colors.grey[300],
                ),
                SizedBox(height: 4),
                Container(
                  width: 60,
                  height: 10,
                  color: Colors.grey[300],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingList() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            width: 280,
            margin: EdgeInsets.only(right: 16),
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 120, height: 16, color: Colors.grey[300]),
                    SizedBox(height: 8),
                    Container(width: 200, height: 12, color: Colors.grey[300]),
                    SizedBox(height: 8),
                    Container(width: 180, height: 12, color: Colors.grey[300]),
                    SizedBox(height: 16),
                    Container(width: 80, height: 12, color: Colors.grey[300]),
                    SizedBox(height: 8),
                    Container(width: 60, height: 16, color: Colors.grey[300]),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      padding: EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.orange),
          SizedBox(height: 16),
          Text(
            'Unable to load content',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadData,
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

  Widget _buildEmptyState(String title, String message) {
    return Container(
      padding: EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.category, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
