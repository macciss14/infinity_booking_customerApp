// lib/screens/booking/booking_screen.dart
import 'package:flutter/material.dart';
import '../../services/service_service.dart';
import '../../models/service_model.dart';
import '../../utils/constants.dart';
import '../../config/route_helper.dart';

class BookingScreen extends StatefulWidget {
  final String serviceId;
  const BookingScreen({super.key, required this.serviceId});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final ServiceService _serviceService = ServiceService();
  late Future<ServiceModel> _serviceFuture;
  late Future<List<dynamic>> _slotsFuture;

  final TextEditingController _notesController = TextEditingController();
  String? _selectedSlotId;

  @override
  void initState() {
    super.initState();
    _serviceFuture = _serviceService.getServiceById(widget.serviceId);
    _slotsFuture = _serviceService.getServiceSlots(widget.serviceId);
  }

  void _navigateToConfirmation() {
    if (_selectedSlotId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a time slot')),
      );
      return;
    }

    RouteHelper.pushNamed(
      context,
      RouteHelper.bookingConfirmation,
      arguments: {
        'serviceId': widget.serviceId,
        'slotId': _selectedSlotId,
        'notes': _notesController.text,
      },
    );
  }

  String _formatSlotTime(String isoString) {
    try {
      final dt = DateTime.parse(isoString);
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return isoString.substring(11, 16); // Fallback: "HH:MM" from ISO string
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Service'),
        backgroundColor: AppColors.primary,
      ),
      body: FutureBuilder<ServiceModel>(
        future: _serviceFuture,
        builder: (context, serviceSnapshot) {
          if (serviceSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (serviceSnapshot.hasError) {
            return _buildErrorWidget('Failed to load service: ${serviceSnapshot.error}');
          }
          final service = serviceSnapshot.data!;

          return FutureBuilder<List<dynamic>>(
            future: _slotsFuture,
            builder: (context, slotSnapshot) {
              return SingleChildScrollView(
                padding: EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            service.imageUrl != null
                                ? CircleAvatar(
                                    radius: 30,
                                    backgroundImage: NetworkImage(service.imageUrl!),
                                  )
                                : const CircleAvatar(
                                    radius: 30,
                                    backgroundColor: AppColors.primary,
                                    child: Icon(Icons.build, color: Colors.white),
                                  ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    service.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '\$${service.price.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                  Text(
                                    'by ${service.providerName}',
                                    style: TextStyle(color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Available Time Slots',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (slotSnapshot.connectionState == ConnectionState.waiting)
                      const LinearProgressIndicator(),
                    if (slotSnapshot.hasError)
                      _buildErrorWidget('Failed to load slots: ${slotSnapshot.error}'),
                    if (slotSnapshot.hasData) ...[
                      if (slotSnapshot.data!.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange, width: 1),
                          ),
                          child: const Text(
                            'No available slots. Please check back later.',
                            style: TextStyle(color: Colors.orange),
                          ),
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: (slotSnapshot.data as List<dynamic>).map((slot) {
                            final String slotId = slot['id']?.toString() ?? '';
                            final String startTime = slot['start']?.toString() ?? '';
                            final displayTime = _formatSlotTime(startTime);

                            return FilterChip(
                              label: Text(displayTime),
                              selected: _selectedSlotId == slotId,
                              onSelected: (bool selected) {
                                setState(() => _selectedSlotId = selected ? slotId : null);
                              },
                              selectedColor: AppColors.primaryLight,
                              checkmarkColor: Colors.white,
                            );
                          }).toList(),
                        ),
                    ],
                    const SizedBox(height: 24),
                    const Text(
                      'Additional Notes (Optional)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _notesController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Special requests or instructions...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedSlotId == null ? null : _navigateToConfirmation,
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedSlotId == null ? Colors.grey : AppColors.primaryLight,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Confirm Booking',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(color: Colors.red[700], fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _slotsFuture = _serviceService.getServiceSlots(widget.serviceId);
                });
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}