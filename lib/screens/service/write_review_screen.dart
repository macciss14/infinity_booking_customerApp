// lib/screens/service/write_review_screen.dart
import 'package:flutter/material.dart';
import '../../services/review_service.dart';
import '../../services/booking_service.dart';
import '../../models/booking_model.dart';
import '../../utils/constants.dart';

class WriteReviewScreen extends StatefulWidget {
  final String serviceId;
  final String? serviceName;
  final String? bookingId;

  const WriteReviewScreen({
    super.key,
    required this.serviceId,
    this.serviceName,
    this.bookingId,
  });

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  final ReviewService _reviewService = ReviewService();
  final BookingService _bookingService = BookingService();
  
  double _rating = 0.0;
  final TextEditingController _commentController = TextEditingController();
  bool _loading = false;
  bool _canReview = true;
  BookingModel? _booking;

  @override
  void initState() {
    super.initState();
    _checkReviewEligibility();
    if (widget.bookingId != null) {
      _loadBookingDetails();
    }
  }

  Future<void> _checkReviewEligibility() async {
    try {
      final canReview = await _reviewService.canReviewService(widget.serviceId);
      setState(() => _canReview = canReview);
    } catch (error) {
      print('❌ Error checking review eligibility: $error');
    }
  }

  Future<void> _loadBookingDetails() async {
    try {
      if (widget.bookingId != null) {
        final booking = await _bookingService.getBookingById(widget.bookingId!);
        setState(() => _booking = booking);
      }
    } catch (error) {
      print('❌ Error loading booking details: $error');
    }
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a rating'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write a review comment'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await _reviewService.createReview(
        serviceId: widget.serviceId,
        rating: _rating,
        comment: _commentController.text.trim(),
        bookingId: widget.bookingId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review submitted successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        
        // Navigate back with success
        Navigator.pop(context, true);
      }
    } catch (error) {
      print('❌ Error submitting review: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit review: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Write a Review'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
      body: !_canReview
          ? _buildCannotReviewView()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service info
                  if (widget.serviceName != null || _booking != null)
                    _buildServiceInfo(),
                  
                  const SizedBox(height: 20),
                  
                  // Rating section
                  _buildRatingSection(),
                  
                  const SizedBox(height: 30),
                  
                  // Review text
                  _buildReviewTextField(),
                  
                  const SizedBox(height: 40),
                  
                  // Submit button
                  _buildSubmitButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildCannotReviewView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.block,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 20),
            const Text(
              'Cannot Write Review',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                'You need to book and complete this service before writing a review.',
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
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceInfo() {
    String serviceName = widget.serviceName ?? _booking?.serviceName ?? 'This Service';
    String? providerName = _booking?.providerName;
    
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reviewing:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              serviceName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (providerName != null) ...[
              const SizedBox(height: 8),
              Text(
                'Provider: $providerName',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
            if (_booking != null) ...[
              const SizedBox(height: 8),
              Text(
                'Booked on: ${_booking!.formattedBookingDate}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How would you rate this service?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        
        // Star rating
        Center(
          child: Column(
            children: [
              // Stars
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() => _rating = (index + 1).toDouble());
                    },
                    child: Icon(
                      index < _rating.round() ? Icons.star : Icons.star_border,
                      size: 50,
                      color: Colors.amber,
                    ),
                  );
                }),
              ),
              
              const SizedBox(height: 16),
              
              // Rating text
              Text(
                _rating == 0 ? 'Tap a star to rate' : '${_rating.toStringAsFixed(1)} Stars',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _rating == 0 ? Colors.grey : Colors.amber[800],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Rating labels
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Poor', style: TextStyle(color: Colors.grey)),
                  Text('Excellent', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Rating guidance
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[100]!),
          ),
          child: const Text(
            '⭐ 5 = Excellent\n⭐ 4 = Good\n⭐ 3 = Average\n⭐ 2 = Below Average\n⭐ 1 = Poor',
            style: TextStyle(
              fontSize: 14,
              color: Color.fromARGB(255, 22, 117, 224),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewTextField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Write your review',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Share your experience with this service',
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),
        
        TextField(
          controller: _commentController,
          maxLines: 6,
          maxLength: 500,
          decoration: InputDecoration(
            hintText: 'What did you like about the service? '
                'Was the provider professional? '
                'Would you recommend it to others?',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
        
        const SizedBox(height: 8),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '${_commentController.text.length}/500',
              style: TextStyle(
                color: _commentController.text.length > 500 
                    ? Colors.red 
                    : Colors.grey[600],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Review tips
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green[100]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '💡 Review Tips:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color.fromARGB(255, 65, 171, 71),
                ),
              ),
              SizedBox(height: 4),
              Text(
                '• Be specific about your experience\n'
                '• Mention what you liked or didn\'t like\n'
                '• Keep it honest and helpful to others\n'
                '• Avoid personal information',
                style: TextStyle(
                  fontSize: 13,
                  color: Color.fromARGB(255, 65, 171, 70),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _loading ? null : _submitReview,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _loading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Submit Review',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}