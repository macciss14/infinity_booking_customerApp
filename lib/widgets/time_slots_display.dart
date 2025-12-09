// lib/widgets/time_slots_display.dart
import 'package:flutter/material.dart';
import '../models/service_model.dart';
import '../utils/time_slots_utils.dart';

class TimeSlotsDisplay extends StatefulWidget {
  final ServiceModel service;
  final bool viewOnly;
  final ValueChanged<Map<String, dynamic>?>? onSlotSelected;
  final bool hideSelectedSummary;
  final List<dynamic>? existingBookings;

  const TimeSlotsDisplay({
    super.key,
    required this.service,
    this.viewOnly = true,
    this.onSlotSelected,
    this.hideSelectedSummary = false,
    this.existingBookings,
  });

  @override
  State<TimeSlotsDisplay> createState() => _TimeSlotsDisplayState();
}

class _TimeSlotsDisplayState extends State<TimeSlotsDisplay> {
  Map<String, dynamic>? _selectedSlot;
  List<Map<String, dynamic>> _daySlots = [];

  @override
  void initState() {
    super.initState();
    _loadTimeSlots();
  }

  void _loadTimeSlots() {
    final serviceSlots = widget.service.slots is List
        ? List<dynamic>.from(widget.service.slots)
        : [];
    final existingBookings = widget.existingBookings ?? [];
    _daySlots = getAllDays(serviceSlots, existingBookings);
  }

  String _getSlotIdentifier(
      Map<String, dynamic> daySlot, Map<String, dynamic> timeSlot) {
    return '${daySlot['day']}-${daySlot['date']}-${timeSlot['startTime']}-${timeSlot['endTime']}';
  }

  bool _isSlotSelected(
      Map<String, dynamic> daySlot, Map<String, dynamic> timeSlot) {
    if (_selectedSlot == null) return false;
    return _selectedSlot!['identifier'] ==
        _getSlotIdentifier(daySlot, timeSlot);
  }

  void _selectTimeSlot(
      Map<String, dynamic> daySlot, Map<String, dynamic> timeSlot) {
    if (widget.viewOnly) return;
    if (timeSlot['isBooked'] == true || timeSlot['isAvailable'] != true) return;

    final identifier = _getSlotIdentifier(daySlot, timeSlot);
    if (_selectedSlot != null && _selectedSlot!['identifier'] == identifier) {
      _clearSelection();
      return;
    }

    setState(() {
      _selectedSlot = {
        'identifier': identifier,
        'day': daySlot['day'],
        'date': daySlot['date'],
        'formattedDate': daySlot['formattedDate'],
        'timeSlot': timeSlot,
        'serviceId': widget.service.id,
        'serviceName': widget.service.name,
      };
    });
    widget.onSlotSelected?.call(_selectedSlot!);
  }

  void _clearSelection() {
    setState(() => _selectedSlot = null);
    widget.onSlotSelected?.call(null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!widget.viewOnly)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Select Time Slot',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        if (!widget.viewOnly) const SizedBox(height: 8),
        _daySlots.isEmpty
            ? _buildEmptyState()
            : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:
                      MediaQuery.of(context).size.width > 600 ? 3 : 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                ),
                itemCount: _daySlots.length,
                itemBuilder: (context, index) {
                  final daySlot = _daySlots[index];
                  return _buildDayCard(daySlot);
                },
              ),
        if (_selectedSlot != null &&
            !widget.viewOnly &&
            !widget.hideSelectedSummary)
          _buildSelectedSlotSummary(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(Icons.schedule, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          const Text('No time slots available'),
          Text(widget.viewOnly
              ? 'Check back later'
              : 'Contact provider for availability'),
        ],
      ),
    );
  }

  Widget _buildDayCard(Map<String, dynamic> daySlot) {
    final timeSlots = (daySlot['timeSlots'] as List<dynamic>?) ?? [];
    final isWorkingDay = daySlot['isWorkingDay'] == true;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isWorkingDay ? Colors.grey[300]! : Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isWorkingDay ? Colors.blue[50] : Colors.grey[100],
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(getDayDisplayName(daySlot['day']),
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isWorkingDay
                                ? Colors.blue[800]
                                : Colors.grey[700])),
                    if (daySlot['formattedDate'] != null)
                      Text(daySlot['formattedDate'],
                          style: TextStyle(
                              fontSize: 11,
                              color: isWorkingDay
                                  ? Colors.blue[600]
                                  : Colors.grey[500])),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isWorkingDay ? Colors.green[50] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(isWorkingDay ? 'Working' : 'Day Off',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isWorkingDay
                              ? Colors.green[700]
                              : Colors.grey[600])),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: isWorkingDay
                  ? timeSlots.isEmpty
                      ? const Center(child: Text('No slots'))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: timeSlots.length,
                          itemBuilder: (context, index) {
                            final timeSlot =
                                timeSlots[index] as Map<String, dynamic>;
                            return _buildTimeSlot(daySlot, timeSlot);
                          },
                        )
                  : const Center(child: Text('Day Off')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlot(
      Map<String, dynamic> daySlot, Map<String, dynamic> timeSlot) {
    final isBooked = timeSlot['isBooked'] == true;
    final isAvailable = timeSlot['isAvailable'] == true && !isBooked;
    final isSelected = _isSlotSelected(daySlot, timeSlot);
    final color = isBooked
        ? Colors.red
        : isAvailable
            ? Colors.green
            : Colors.grey;

    return GestureDetector(
      onTap: () => _selectTimeSlot(daySlot, timeSlot),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blue[50]
              : (isBooked
                  ? Colors.red[50]
                  : (isAvailable ? Colors.green[50] : Colors.grey[100])),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: isSelected ? Colors.blue : color.withOpacity(0.3),
              width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            if (!widget.viewOnly)
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey[400]!,
                      width: 2),
                  color: isSelected ? Colors.blue : Colors.transparent,
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${formatTime(timeSlot['startTime'])} - ${formatTime(timeSlot['endTime'])}',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.blue[800] : color),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                isBooked
                    ? 'Booked'
                    : (isAvailable ? 'Available' : 'Unavailable'),
                style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w600, color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedSlotSummary() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.blue[800]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Selected Time Slot',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: Colors.blue[800])),
                const SizedBox(height: 4),
                Text(
                    '${getDayDisplayName(_selectedSlot!['day'])} • ${_selectedSlot!['formattedDate']}',
                    style: TextStyle(fontSize: 14)),
                Text(
                    '${formatTime(_selectedSlot!['timeSlot']['startTime'])} - ${formatTime(_selectedSlot!['timeSlot']['endTime'])}',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          TextButton(
            onPressed: _clearSelection,
            child: const Text('Change', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }
}
