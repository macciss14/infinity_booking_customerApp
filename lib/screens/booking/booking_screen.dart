import 'package:flutter/material.dart';
import '../../models/service_model.dart';
import '../../services/booking_service.dart';
import '../../utils/constants.dart';
import 'booking_confirmation_screen.dart';

class BookingScreen extends StatefulWidget {
  final Service service;

  const BookingScreen({Key? key, required this.service}) : super(key: key);

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _selectedTimeSlot = '';
  bool _isLoading = false;

  // Available time slots
  final List<String> _timeSlots = [
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '01:00 PM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
    '05:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    // Set initial time to next available slot
    _setInitialTime();
  }

  void _setInitialTime() {
    final now = DateTime.now();
    final currentHour = now.hour;

    // Find next available time slot
    for (final slot in _timeSlots) {
      final hour = int.parse(slot.split(':')[0]);
      final isPM = slot.contains('PM');
      final slotHour = isPM && hour != 12 ? hour + 12 : hour;

      if (slotHour > currentHour) {
        setState(() {
          _selectedTimeSlot = slot;
        });
        break;
      }
    }

    // If no future slots found today, use first slot tomorrow
    if (_selectedTimeSlot.isEmpty) {
      setState(() {
        _selectedDate = DateTime.now().add(Duration(days: 1));
        _selectedTimeSlot = _timeSlots.first;
      });
    }
  }

  Future<void> _createBooking() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedTimeSlot.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select a time slot'),
            backgroundColor: Constants.errorColor,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        print('🔄 Creating booking for service: ${widget.service.id}');

        final booking = await BookingService.createBooking(
          serviceId: widget.service.id,
          bookingDate: _selectedDate,
          timeSlot: _selectedTimeSlot,
          totalAmount: widget.service.price,
          customerNotes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );

        print('✅ Booking created successfully: ${booking.id}');

        // Navigate to confirmation screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BookingConfirmationScreen(booking: booking),
          ),
        );
      } catch (e) {
        print('💥 Error creating booking: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create booking: $e'),
            backgroundColor: Constants.errorColor,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Constants.primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Constants.primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        // Reset time slot when date changes
        _selectedTimeSlot = _timeSlots.first;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getDayName(DateTime date) {
    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return days[date.weekday % 7];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Service'),
        backgroundColor: Constants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service Summary
              _buildServiceSummary(),
              SizedBox(height: 24),

              // Date Selection
              _buildDateSelection(),
              SizedBox(height: 24),

              // Time Slot Selection
              _buildTimeSlotSelection(),
              SizedBox(height: 24),

              // Additional Notes
              _buildNotesSection(),
              SizedBox(height: 32),

              // Booking Summary
              _buildBookingSummary(),
              SizedBox(height: 32),

              // Book Button
              _buildBookButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceSummary() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            // Service Image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
                image: widget.service.images.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(widget.service.images.first),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: widget.service.images.isEmpty
                  ? Icon(Icons.construction, color: Colors.grey[400])
                  : null,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.service.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    widget.service.providerName,
                    style: TextStyle(
                      color: Constants.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    widget.service.duration,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Text(
              widget.service.formattedPrice,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Constants.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Date',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppConstants.defaultBorderRadius),
          ),
          child: ListTile(
            leading: Icon(Icons.calendar_today, color: Constants.primaryColor),
            title: Text(
              _formatDate(_selectedDate),
              style: TextStyle(fontSize: 16),
            ),
            subtitle: Text(_getDayName(_selectedDate)),
            trailing: Icon(Icons.arrow_drop_down),
            onTap: _selectDate,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSlotSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Time Slot',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _timeSlots.map((slot) {
            final isSelected = _selectedTimeSlot == slot;
            return ChoiceChip(
              label: Text(slot),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedTimeSlot = selected ? slot : '';
                });
              },
              selectedColor: Constants.primaryColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Notes (Optional)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        TextFormField(
          controller: _notesController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText:
                'Any special requirements or notes for the service provider...',
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppConstants.defaultBorderRadius),
            ),
            contentPadding: EdgeInsets.all(16),
          ),
          validator: (value) {
            if (value != null && value.length > 500) {
              return 'Notes should be less than 500 characters';
            }
            return null;
          },
        ),
        SizedBox(height: 8),
        Text(
          '${_notesController.text.length}/500 characters',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildBookingSummary() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Booking Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _buildSummaryRow('Service', widget.service.title),
            _buildSummaryRow('Provider', widget.service.providerName),
            _buildSummaryRow('Date', _formatDate(_selectedDate)),
            _buildSummaryRow('Time', _selectedTimeSlot),
            _buildSummaryRow('Duration', widget.service.duration),
            Divider(height: 24),
            _buildSummaryRow(
              'Total Amount',
              widget.service.formattedPrice,
              isBold: true,
              isPrimary: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isBold = false, bool isPrimary = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: Colors.grey[700],
            ),
          ),
          Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isPrimary ? Constants.primaryColor : Colors.black,
              fontSize: isPrimary ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _createBooking,
        style: ElevatedButton.styleFrom(
          backgroundColor: Constants.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppConstants.defaultBorderRadius),
          ),
          elevation: 2,
        ),
        child: _isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Confirm Booking - ${widget.service.formattedPrice}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}
