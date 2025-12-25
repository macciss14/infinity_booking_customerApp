// lib/screens/service/reviews_screen.dart - FIXED VERSION
import 'package:flutter/material.dart';
import '../../models/review_model.dart';
import '../../services/review_service.dart';
import '../../utils/constants.dart';
import '../../config/route_helper.dart';

class ReviewsScreen extends StatefulWidget {
  final String serviceId;
  final String? serviceName;
  const ReviewsScreen({
    super.key,
    required this.serviceId,
    this.serviceName,
  });

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final ReviewService _reviewService = ReviewService();
  List<ReviewModel> _reviews = [];
  bool _loading = true;
  double _averageRating = 0.0;
  int _totalReviews = 0;
  Map<int, int> _ratingDistribution = {
    5: 0,
    4: 0,
    3: 0,
    2: 0,
    1: 0,
  };

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    if (!mounted) return;

    setState(() => _loading = true);
    try {
      // Load reviews
      _reviews = await _reviewService.getServiceReviews(widget.serviceId);

      // Calculate statistics
      _calculateStatistics();

      // Also try to get detailed statistics from API
      final stats = await _reviewService.getReviewStatistics(widget.serviceId);
      if (stats.isNotEmpty && mounted) {
        setState(() {
          _averageRating =
              (stats['averageRating'] as num?)?.toDouble() ?? _averageRating;
          _totalReviews =
              (stats['totalReviews'] as num?)?.toInt() ?? _totalReviews;

          // Update rating distribution if available
          if (stats['ratingDistribution'] is Map) {
            final distribution =
                stats['ratingDistribution'] as Map<String, dynamic>;
            _ratingDistribution = {
              5: (distribution['5'] as num?)?.toInt() ?? 0,
              4: (distribution['4'] as num?)?.toInt() ?? 0,
              3: (distribution['3'] as num?)?.toInt() ?? 0,
              2: (distribution['2'] as num?)?.toInt() ?? 0,
              1: (distribution['1'] as num?)?.toInt() ?? 0,
            };
          }
        });
      }
    } catch (error) {
      print('❌ Error loading reviews: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to load reviews'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _loadReviews,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _calculateStatistics() {
    _totalReviews = _reviews.length;

    if (_reviews.isEmpty) {
      _averageRating = 0.0;
      _ratingDistribution = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
      return;
    }

    double totalRating = 0;
    _ratingDistribution = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};

    for (var review in _reviews) {
      final rating = review.rating?.round() ?? 0;
      totalRating += review.rating ?? 0;

      if (rating >= 1 && rating <= 5) {
        _ratingDistribution[rating] = (_ratingDistribution[rating] ?? 0) + 1;
      }
    }

    _averageRating = totalRating / _reviews.length;
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Loading reviews...',
            style: TextStyle(color: Colors.grey[600]),
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
          Icon(
            Icons.reviews,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          const Text(
            'No Reviews Yet',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Be the first to review this service!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => _navigateToWriteReview(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Write First Review'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Overall rating
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      _averageRating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < _averageRating.round()
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 16,
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$_totalReviews ${_totalReviews == 1 ? 'review' : 'reviews'}',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                // Rating breakdown
                Expanded(
                  child: Column(
                    children: List.generate(5, (index) {
                      final rating = 5 - index;
                      final count = _ratingDistribution[rating] ?? 0;
                      final percentage =
                          _totalReviews > 0 ? (count / _totalReviews * 100) : 0;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 20,
                              child: Text(
                                '$rating',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: LinearProgressIndicator(
                                value: percentage / 100,
                                backgroundColor: Colors.grey[200],
                                color: Colors.amber,
                                minHeight: 8,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${percentage.toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).reversed.toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(ReviewModel review) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Review header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    review.reviewerInitials,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Reviewer info - FIXED: Use reviewerName property
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.reviewerName, // FIXED: Changed from getReviewerName()
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        review.formattedCreatedAt,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // Rating
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        (review.rating ?? 0).toStringAsFixed(1),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Comment
            Text(
              review.comment ?? 'No comment provided.',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[800],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),

            // Provider response
            if (review.hasProviderResponse)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  border: Border(
                    left: BorderSide(
                      color: Colors.blue,
                      width: 3,
                    ),
                  ),
                  borderRadius: BorderRadius.circular(4),
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
                            color: Colors.blue[800],
                            fontSize: 12,
                          ),
                        ),
                        if (review.respondedAt != null)
                          Text(
                            review.formattedResponseDate, // FIXED: Changed from formattedRespondedAt
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      review.providerResponseText,
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
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Helpful button
                InkWell(
                  onTap: () => _markHelpful(review.id),
                  child: Row(
                    children: [
                      Icon(
                        Icons.thumb_up,
                        size: 16,
                        color:
                            review.isHelpful ? Colors.blue : Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Helpful (${review.helpfulCount ?? 0})',
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              review.isHelpful ? Colors.blue : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                // Status badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: review.isPublished
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    review.status?.toUpperCase() ?? 'PUBLISHED',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: review.isPublished
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

  Future<void> _markHelpful(String reviewId) async {
    try {
      await _reviewService.markHelpful(reviewId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Marked as helpful'),
          backgroundColor: Colors.green,
        ),
      );
      _loadReviews(); // Refresh to update count
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to mark helpful: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToWriteReview(BuildContext context) {
    RouteHelper.goToWriteReview(
      context,
      serviceId: widget.serviceId,
      serviceName: widget.serviceName,
    );
  }

  // REMOVE or update this dialog - it's not working with the new ReviewService
  // The dialog tries to call createReview directly but the user needs to go through WriteReviewScreen
  // to check for booking eligibility first
  
  // Future<void> _showAddReviewDialog() async {
  //   // This dialog doesn't work anymore because createReview requires booking check
  //   // Users should use WriteReviewScreen instead
  //   _navigateToWriteReview(context);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reviews for ${widget.serviceName ?? "Service"}'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _navigateToWriteReview(context),
            tooltip: 'Write a Review',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReviews,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _loading
          ? _buildLoadingState()
          : _reviews.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadReviews,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Statistics
                        _buildStatisticsCard(),
                        const SizedBox(height: 24),

                        // Reviews count
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Customer Reviews ($_totalReviews)',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () => _navigateToWriteReview(context),
                                icon: const Icon(Icons.edit, size: 16),
                                label: const Text('Write a Review'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Reviews list
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _reviews.length,
                          itemBuilder: (context, index) {
                            return _buildReviewCard(_reviews[index]);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}