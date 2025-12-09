import 'package:flutter/material.dart';
import '../../models/review_model.dart';
import '../../services/review_service.dart';
import '../../utils/constants.dart';

class ReviewsScreen extends StatefulWidget {
  final String serviceId;
  const ReviewsScreen({super.key, required this.serviceId});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final ReviewService _reviewService = ReviewService();
  List<ReviewModel> _reviews = [];
  bool _loading = true;
  double _averageRating = 0.0;
  int _totalReviews = 0;
  int _fiveStarCount = 0;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() => _loading = true);
    try {
      _reviews = await _reviewService.getServiceReviews(widget.serviceId);
      
      // Calculate statistics
      _totalReviews = _reviews.length;
      if (_reviews.isNotEmpty) {
        final total = _reviews.fold(0.0, (sum, review) => sum + (review.rating ?? 0));
        _averageRating = total / _reviews.length;
        _fiveStarCount = _reviews.where((review) => (review.rating ?? 0).round() == 5).length;
      }
    } catch (error) {
      print('Error loading reviews: $error');
    } finally {
      setState(() => _loading = false);
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.split(' ');
    return parts.map((p) => p.isNotEmpty ? p[0] : '').join('').toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Service Reviews'),
        backgroundColor: AppColors.primary,
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _reviews.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star, size: 64, color: Colors.grey[400]),
                      SizedBox(height: 16),
                      Text(
                        'No Reviews Yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Be the first to review this service!',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Statistics Card
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(
                                'Average Rating',
                                '${_averageRating.toStringAsFixed(1)}/5',
                                Colors.amber,
                              ),
                              _buildStatItem(
                                'Total Reviews',
                                _totalReviews.toString(),
                                Colors.blue,
                              ),
                              _buildStatItem(
                                '5 Star',
                                _fiveStarCount.toString(),
                                Colors.green,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),

                      // Reviews List
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _reviews.length,
                        itemBuilder: (context, index) {
                          return _buildReviewCard(_reviews[index]);
                        },
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewCard(ReviewModel review) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        _getInitials(review.customerName ?? 'Anonymous'),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          review.customerName ?? 'Anonymous User',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          _formatDate(review.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.star, size: 16, color: Colors.amber),
                      SizedBox(width: 4),
                      Text(
                        (review.rating ?? 0).toStringAsFixed(1),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.orange[800],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),

            // Comment
            Text(
              review.comment ?? 'No comment provided.',
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
              ),
            ),
            SizedBox(height: 12),

            // Provider Response
            if (review.response != null)
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Provider Response',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[700],
                            fontSize: 12,
                          ),
                        ),
                        if (review.respondedAt != null)
                          Text(
                            _formatDate(review.respondedAt),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      review.response!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

            // Footer
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if ((review.helpfulCount ?? 0) > 0)
                  Row(
                    children: [
                      Icon(Icons.thumb_up, size: 16, color: Colors.grey[600]),
                      SizedBox(width: 4),
                      Text(
                        '${review.helpfulCount} helpful',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  )
                else
                  Container(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: review.status == 'published'
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    review.status?.toUpperCase() ?? '',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: review.status == 'published'
                          ? Colors.green[800]
                          : Colors.orange[800],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}