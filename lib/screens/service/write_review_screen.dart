// lib/screens/service/write_review_screen.dart - FIXED VERSION
import 'package:flutter/material.dart';
import '../../services/review_service.dart';
import '../../services/booking_service.dart';
import '../../models/booking_model.dart';
import '../../utils/constants.dart';

class WriteReviewScreen extends StatefulWidget {
  final String serviceId;
  final String? serviceName;
  final String? bookingId; // Optional if we need to find it

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
  bool _findingBooking = true;
  BookingModel? _booking;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _findOrValidateBooking();
  }

  Future<void> _findOrValidateBooking() async {
    try {
      setState(() {
        _findingBooking = true;
        _errorMessage = null;
      });

      print('🔍 Finding booking for service: ${widget.serviceId}');

      // Case 1: If bookingId is provided, validate it
      if (widget.bookingId != null) {
        print('📋 Using provided booking ID: ${widget.bookingId}');
        try {
          _booking = await _bookingService.getBookingById(widget.bookingId!);
          if (_booking?.serviceId == widget.serviceId) {
            print('✅ Provided booking ID is valid');
            _canReview = true;
          } else {
            _errorMessage = 'Invalid booking for this service';
            _canReview = false;
          }
        } catch (e) {
          print('❌ Error loading provided booking: $e');
          _errorMessage = 'Could not validate booking';
          _canReview = false;
        }
      } 
      // Case 2: Find booking from user's bookings
      else {
        print('🔍 Searching for user bookings for service: ${widget.serviceId}');
        final bookings = await _bookingService.getUserBookings();
        
        // Find completed/approved bookings for this service
        final validBookings = bookings.where((booking) {
          return booking.serviceId == widget.serviceId && 
                 (booking.status == 'completed' || 
                  booking.status == 'approved' ||
                  booking.status == 'delivered' ||
                  booking.status == 'fulfilled');
        }).toList();
        
        if (validBookings.isNotEmpty) {
          // Use the most recent booking
          validBookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          _booking = validBookings.first;
          print('✅ Found booking ID: ${_booking!.id} for service');
          _canReview = true;
        } else {
          _errorMessage = 'No completed booking found for this service';
          _canReview = false;
          print('❌ No valid bookings found. Available bookings:');
          for (var booking in bookings) {
            print('   - Booking ${booking.id}: service=${booking.serviceId}, status=${booking.status}');
          }
        }
      }
      
      // Double-check with backend API
      if (_canReview) {
        try {
          final canReviewApi = await _reviewService.canReviewService(widget.serviceId);
          if (!canReviewApi) {
            _errorMessage = 'Cannot review this service yet. Please complete your booking first.';
            _canReview = false;
          }
        } catch (e) {
          print('⚠️ API review check failed, but proceeding with local check: $e');
          // Continue with local check if API fails
        }
      }

    } catch (error) {
      print('❌ Error checking review eligibility: $error');
      _errorMessage = 'Error checking review eligibility: ${error.toString()}';
      _canReview = false;
    } finally {
      setState(() {
        _findingBooking = false;
      });
    }
  }

  Future<void> _submitReview() async {
    if (!_canReview || _booking == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage ?? 'Cannot submit review'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

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
      print('📝 Submitting review for service: ${widget.serviceId}');
      print('📝 Using booking ID: ${_booking!.id}');
      print('📝 Rating: $_rating');
      print('📝 Comment: ${_commentController.text.trim()}');

      await _reviewService.createReview(
        serviceId: widget.serviceId,
        rating: _rating,
        comment: _commentController.text.trim(),
        // bookingId parameter is now handled inside createReview()
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
            content: Text('Failed to submit review: ${error.toString()}'),
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
          if (_loading || _findingBooking)
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
      body: _findingBooking
          ? _buildFindingBookingView()
          : !_canReview
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

  Widget _buildFindingBookingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Checking review eligibility...',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'Looking for your booking...',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
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
              Icons.error_outline,
              size: 80,
              color: Colors.orange[400],
            ),
            const SizedBox(height: 20),
            Text(
              _errorMessage?.contains('booking') == true
                  ? 'Booking Required'
                  : 'Cannot Write Review',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                _errorMessage ?? 'You need to book and complete this service before writing a review.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text(
                'Go Back',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _findOrValidateBooking,
              child: const Text('Check Again'),
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
                'Booking ID: ${_booking!.id.substring(0, 8)}...',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontFamily: 'monospace',
                ),
              ),
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
        onPressed: (_loading || !_canReview || _booking == null) ? null : _submitReview,
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