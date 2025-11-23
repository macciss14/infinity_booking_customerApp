import 'package:flutter/material.dart';
import '../../models/booking_model.dart';
import '../../utils/constants.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final Booking booking;

  const BookingConfirmationScreen({Key? key, required this.booking})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Success Icon
                      Container(
                        margin: EdgeInsets.only(top: 40, bottom: 24),
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Constants.successColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_circle,
                          size: 60,
                          color: Constants.successColor,
                        ),
                      ),

                      // Success Message
                      Text(
                        'Booking Confirmed!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Constants.primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Your service has been successfully booked. You will receive a confirmation notification.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 40),

                      // Booking Details Card
                      Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppConstants.defaultBorderRadius),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Text(
                                'Booking Details',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 20),
                              _buildDetailItem(
                                icon: Icons.construction,
                                label: 'Service',
                                value: booking.serviceTitle,
                              ),
                              _buildDetailItem(
                                icon: Icons.person,
                                label: 'Provider',
                                value: booking.providerName,
                              ),
                              _buildDetailItem(
                                icon: Icons.calendar_today,
                                label: 'Date',
                                value: booking.formattedDate,
                              ),
                              _buildDetailItem(
                                icon: Icons.schedule,
                                label: 'Time',
                                value: booking.timeSlot,
                              ),
                              _buildDetailItem(
                                icon: Icons.attach_money,
                                label: 'Amount',
                                value: booking.formattedAmount,
                                isAmount: true,
                              ),
                              SizedBox(height: 16),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: booking.statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  booking.statusText.toUpperCase(),
                                  style: TextStyle(
                                    color: booking.statusColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 24),

                      // Next Steps
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppConstants.defaultBorderRadius),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'What happens next?',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 16),
                              _buildNextStep(
                                number: 1,
                                text: 'You will receive a confirmation message',
                              ),
                              _buildNextStep(
                                number: 2,
                                text: 'The service provider will contact you',
                              ),
                              _buildNextStep(
                                number: 3,
                                text:
                                    'Service will be provided at the scheduled time',
                              ),
                              _buildNextStep(
                                number: 4,
                                text: 'You can track your booking in the app',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Action Buttons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to bookings screen
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/home',
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Constants.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppConstants.defaultBorderRadius),
                        ),
                      ),
                      child: Text(
                        'Go to Home',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () {
                        // Navigate to bookings screen
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/home',
                          (route) => false,
                        );
                        // Then navigate to bookings
                        Future.delayed(Duration(milliseconds: 100), () {
                          // This would navigate to bookings screen
                          // Navigator.push(context, MaterialPageRoute(builder: (context) => BookingsScreen()));
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppConstants.defaultBorderRadius),
                        ),
                        side: BorderSide(color: Constants.primaryColor),
                      ),
                      child: Text(
                        'View My Bookings',
                        style: TextStyle(
                          color: Constants.primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    bool isAmount = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Constants.primaryColor),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isAmount ? FontWeight.bold : FontWeight.normal,
              color: isAmount ? Constants.primaryColor : Colors.black,
              fontSize: isAmount ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextStep({required int number, required String text}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Constants.primaryColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
