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
  bool _checkingEligibility = true;
  String? _errorMessage;
  String? _bookingIdToUse;
  bool _canReview = false;
  BookingModel? _selectedBooking;

  @override
  void initState() {
    super.initState();
    _setupReview();
  }

  Future<void> _setupReview() async {
    try {
      setState(() {
        _checkingEligibility = true;
        _errorMessage = null;
      });

      print('🔍 Setting up review for service: ${widget.serviceId}');

      // If bookingId is provided, use it directly
      if (widget.bookingId != null && widget.bookingId!.isNotEmpty) {
        print('✅ Using provided booking ID: ${widget.bookingId}');
        _bookingIdToUse = widget.bookingId;
        _canReview = true;
      } else {
        // Find completed bookings for this service
        await _findCompletedBooking();
      }

      print('✅ Setup complete. Can review: $_canReview');
      print('✅ Booking ID to use: $_bookingIdToUse');

    } catch (error) {
      print('❌ Error in setup: $error');
      _errorMessage = 'Error setting up review. Please try again.';
      _setCannotReviewState();
    } finally {
      if (mounted) {
        setState(() => _checkingEligibility = false);
      }
    }
  }

  Future<void> _findCompletedBooking() async {
    try {
      print('🔍 Searching for completed bookings for service: ${widget.serviceId}');
      
      final bookings = await _bookingService.getUserBookings();
      print('📊 Total bookings found: ${bookings.length}');
      
      // Find completed bookings for this service
      final completedBookings = bookings.where((booking) {
        final isSameService = booking.serviceId == widget.serviceId;
        final isCompleted = booking.status == 'completed';
        
        if (isSameService) {
          print('📋 Booking ${booking.id}: service=${booking.serviceId}, status=${booking.status}');
        }
        
        return isSameService && isCompleted;
      }).toList();

      if (completedBookings.isNotEmpty) {
        // Use the most recent completed booking
        completedBookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _selectedBooking = completedBookings.first;
        _bookingIdToUse = _selectedBooking!.id; // This is the bookingId string from backend
        _canReview = true;
        
        print('✅ Found completed booking: ${_selectedBooking!.id}');
        print('✅ Booking status: ${_selectedBooking!.status}');
        print('✅ Booking created: ${_selectedBooking!.createdAt}');
      } else {
        print('❌ No completed bookings found');
        _errorMessage = 'No completed booking found for this service. '
            'Please wait until your booking is marked as completed.';
        _setCannotReviewState();
      }
    } catch (error) {
      print('❌ Error finding bookings: $error');
      _errorMessage = 'Unable to load your bookings. Please try again.';
      _setCannotReviewState();
    }
  }

  void _setCannotReviewState() {
    setState(() {
      _canReview = false;
      _bookingIdToUse = null;
      _selectedBooking = null;
    });
  }

  Future<void> _submitReview() async {
    if (!_canReview || _bookingIdToUse == null) {
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
      print('📝 Submitting review...');
      print('Service ID: ${widget.serviceId}');
      print('Booking ID (string): $_bookingIdToUse');
      print('Rating: $_rating');
      print('Comment: ${_commentController.text.trim()}');

      await _reviewService.createReview(
        serviceId: widget.serviceId,
        bookingId: _bookingIdToUse!, // This should be the bookingId string from backend
        rating: _rating,
        comment: _commentController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review submitted successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        
        Navigator.pop(context, true);
      }
    } catch (error) {
      print('❌ Error submitting review: $error');
      String errorMessage = error.toString();
      
      // Handle specific error messages
      if (errorMessage.contains('Booking not found')) {
        errorMessage = 'Booking not found. Please make sure the booking is completed.';
      } else if (errorMessage.contains('already reviewed')) {
        errorMessage = 'You have already reviewed this service.';
      } else if (errorMessage.contains('completed bookings')) {
        errorMessage = 'You can only review completed bookings.';
      } else if (errorMessage.contains('own bookings')) {
        errorMessage = 'You can only review your own bookings.';
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit review: $errorMessage'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Setting up review...',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
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
            const Text(
              'Cannot Write Review',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                _errorMessage ?? 'You need to complete a booking for this service first.',
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
              onPressed: _setupReview,
              child: const Text('Check Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceInfo() {
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
              widget.serviceName ?? 'This Service',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_selectedBooking != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Booking Details:',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${_selectedBooking!.id}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        color: Color.fromARGB(255, 86, 85, 85),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Status: ${_selectedBooking!.status.toUpperCase()}',
                      style: TextStyle(
                        fontSize: 12,
                        color: _selectedBooking!.status == 'completed' 
                            ? Colors.green 
                            : Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Date: ${_selectedBooking!.formattedBookingDate}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (_bookingIdToUse != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Booking ID:',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _bookingIdToUse!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        color: Color.fromARGB(255, 75, 73, 73),
                      ),
                    ),
                  ],
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
            ],
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
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: (_loading || !_canReview) ? null : _submitReview,
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Write a Review'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          if (_loading || _checkingEligibility)
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
      body: _checkingEligibility
          ? _buildLoadingView()
          : !_canReview
              ? _buildErrorView()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Service info
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

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}