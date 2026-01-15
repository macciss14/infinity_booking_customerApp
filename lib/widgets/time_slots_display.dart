// lib/widgets/time_slots_display.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:developer';
import '../models/service_model.dart';
import '../models/booking_model.dart';
import '../utils/time_slots_utils.dart';

class TimeSlotsDisplay extends StatefulWidget {
  final ServiceModel service;
  final List<BookingModel> existingBookings;
  final Function(SelectedSlot)? onSlotSelected;
  final bool viewOnly;

  const TimeSlotsDisplay({
    Key? key,
    required this.service,
    this.existingBookings = const [],
    this.onSlotSelected,
    this.viewOnly = false,
  }) : super(key: key);

  @override
  _TimeSlotsDisplayState createState() => _TimeSlotsDisplayState();
}

class _TimeSlotsDisplayState extends State<TimeSlotsDisplay> {
  late Map<String, DateEntry> _timeSlotsByDate;
  SelectedSlot? _selectedSlot;
  bool _isLoading = true;
  DateTime _currentMonth = DateTime.now();
  PageController _calendarPageController = PageController();

  @override
  void initState() {
    super.initState();
    log('TimeSlotsDisplay initialized for service: ${widget.service.name}');
    _loadTimeSlots();
  }

  @override
  void dispose() {
    _calendarPageController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant TimeSlotsDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.service != oldWidget.service ||
        widget.existingBookings != oldWidget.existingBookings) {
      log('TimeSlotsDisplay updated, reloading slots');
      _loadTimeSlots();
    }
  }

  void _loadTimeSlots() {
    setState(() {
      _isLoading = true;
    });

    try {
      final serviceSlots = widget.service.slots;
      
      // Debug: Log service slots
      log('Loading time slots for service: ${widget.service.name}');
      log('Service has ${serviceSlots?.length ?? 0} slot configurations');
      
      // Check if slots exist
      if (serviceSlots == null || serviceSlots.isEmpty) {
        log('ERROR: Service has no slots defined');
        _timeSlotsByDate = {};
        setState(() {
          _isLoading = false;
        });
        return;
      }
      
      // Debug: Log existing bookings
      log('Existing bookings count: ${widget.existingBookings.length}');
      
      final convertedBookings = _convertToTimeSlotsBookings();
      log('Converted bookings for timeslots: ${convertedBookings.length}');
      
      _timeSlotsByDate = TimeSlotsUtils.getAllTimeSlotsByDate(
        serviceSlots,
        existingBookings: convertedBookings,
      );
      
      // Debug: Log generated time slots
      log('Generated time slots for ${_timeSlotsByDate.length} dates');
      _timeSlotsByDate.forEach((date, entry) {
        log('Date: $date, Slots: ${entry.timeSlots.length}, Available: ${entry.availableSlotsCount}');
      });

      // Find first available date with slots
      final availableDates = _timeSlotsByDate.values
          .where((dateEntry) => dateEntry.hasAvailableSlots)
          .toList();

      log('Available dates with slots: ${availableDates.length}');
      
      if (availableDates.isNotEmpty) {
        _selectedSlot = SelectedSlot(
          date: availableDates.first.date,
          serviceId: widget.service.id,
        );
        log('Selected first available date: ${_selectedSlot!.date}');
      } else {
        log('WARNING: No available dates found!');
      }
    } catch (e, stackTrace) {
      log('Error loading time slots: $e');
      log('Stack trace: $stackTrace');
      _timeSlotsByDate = {};
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<TimeSlotsBooking> _convertToTimeSlotsBookings() {
    log('Converting ${widget.existingBookings.length} bookings to TimeSlotsBooking');
    
    final result = widget.existingBookings.map((booking) {
      // Debug info for each booking
      log('Booking: ID=${booking.id}, '
          'Date=${booking.bookingDate}, '
          'ForTimeslots=${booking.timeSlotsBookingDate}, '
          'Time=${booking.startTime}-${booking.endTime}');
      
      return TimeSlotsBooking(
        id: booking.id,
        bookingDate: booking.timeSlotsBookingDate, // Use the new method
        startTime: booking.startTime,
        endTime: booking.endTime,
      );
    }).toList();
    
    log('Converted ${result.length} bookings');
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth < 400;

    if (_isLoading) {
      return _buildLoadingState(isSmallScreen, screenHeight);
    }

    if (_timeSlotsByDate.isEmpty) {
      log('No time slots generated for display');
      return _buildEmptyState(isSmallScreen, screenHeight);
    }

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 12 : 16,
          vertical: 12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Debug panel (only in debug mode)
            if (kDebugMode) _buildDebugPanel(),
            
            _buildCalendarSection(isSmallScreen, isMediumScreen),
            const SizedBox(height: 20),
            _buildTimeSlotsSection(isSmallScreen, isMediumScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(bool isSmallScreen, double screenHeight) {
    return SizedBox(
      height: screenHeight * 0.5,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: isSmallScreen ? 30 : 40,
              height: isSmallScreen ? 30 : 40,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            Text(
              'Loading available time slots...',
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 15,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isSmallScreen, double screenHeight) {
    return Container(
      height: screenHeight * 0.4,
      padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: isSmallScreen ? 60 : 70,
              color: Colors.grey[400],
            ),
            SizedBox(height: isSmallScreen ? 16 : 20),
            Text(
              'No Available Time Slots',
              style: TextStyle(
                fontSize: isSmallScreen ? 18 : 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isSmallScreen ? 10 : 12),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 10 : 20),
              child: Text(
                'This service is not currently available for booking. '
                'Please check back later or try a different service.',
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 15,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (kDebugMode) ...[
              SizedBox(height: 20),
              _buildDebugPanel(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarSection(bool isSmallScreen, bool isMediumScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Date',
          style: TextStyle(
            fontSize: isSmallScreen ? 16 : 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 8),
        _buildCalendarView(isSmallScreen, isMediumScreen),
      ],
    );
  }

  Widget _buildCalendarView(bool isSmallScreen, bool isMediumScreen) {
    final monthsToShow = 3; // Show current month and next 2 months
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          // Month navigation header
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 12 : 16,
              vertical: isSmallScreen ? 12 : 14,
            ),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(isSmallScreen ? 12 : 16),
                topRight: Radius.circular(isSmallScreen ? 12 : 16),
              ),
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Previous month button
                _buildMonthNavButton(
                  Icons.chevron_left_rounded,
                  () => _navigateToPreviousMonth(),
                  isSmallScreen,
                ),
                
                // Current month display
                StreamBuilder<DateTime>(
                  stream: Stream.periodic(const Duration(milliseconds: 100)).map((_) => _currentMonth),
                  builder: (context, snapshot) {
                    final monthName = _getMonthYearString(_currentMonth);
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 16 : 20,
                        vertical: isSmallScreen ? 6 : 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        monthName,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 15 : 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                    );
                  },
                ),
                
                // Next month button
                _buildMonthNavButton(
                  Icons.chevron_right_rounded,
                  () => _navigateToNextMonth(),
                  isSmallScreen,
                ),
              ],
            ),
          ),
          
          // Calendar grid
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            child: _buildCalendarGrid(isSmallScreen, isMediumScreen),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthNavButton(IconData icon, VoidCallback onTap, bool isSmallScreen) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isSmallScreen ? 36 : 40,
        height: isSmallScreen ? 36 : 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: isSmallScreen ? 22 : 24,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildCalendarGrid(bool isSmallScreen, bool isMediumScreen) {
    final calendarData = TimeSlotsUtils.getCalendarData(
      widget.service.slots,
      existingBookings: _convertToTimeSlotsBookings(),
    );

    final cellSize = isSmallScreen ? 36.0 : (isMediumScreen ? 40.0 : 44.0);
    final cellPadding = isSmallScreen ? 4.0 : 6.0;

    return Column(
      children: [
        // Weekday headers
        Row(
          children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
              .map((day) => Expanded(
                    child: Container(
                      height: cellSize,
                      alignment: Alignment.center,
                      child: Text(
                        day,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 13 : 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
        SizedBox(height: 4),
        
        // Calendar weeks
        ...calendarData.calendar.map((week) {
          return Container(
            margin: EdgeInsets.only(bottom: 4),
            child: Row(
              children: week.map((day) {
                return Expanded(
                  child: GestureDetector(
                    onTap: day.hasAvailableSlots && !widget.viewOnly
                        ? () => _onDateSelected(day.dateKey)
                        : null,
                    child: Container(
                      margin: EdgeInsets.all(cellPadding / 2),
                      height: cellSize,
                      decoration: BoxDecoration(
                        color: day.hasAvailableSlots
                            ? (day.dateKey == _selectedSlot?.date
                                ? Theme.of(context).primaryColor
                                : Colors.green[50])
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: day.hasAvailableSlots
                              ? (day.dateKey == _selectedSlot?.date
                                  ? Theme.of(context).primaryColor
                                  : Colors.green[300]!)
                              : Colors.transparent,
                          width: day.dateKey == _selectedSlot?.date ? 2 : 1,
                        ),
                        boxShadow: day.dateKey == _selectedSlot?.date
                            ? [
                                BoxShadow(
                                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [],
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              day.dayOfMonth?.toString() ?? '',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 14 : 15,
                                fontWeight: FontWeight.w600,
                                color: day.hasAvailableSlots
                                    ? (day.dateKey == _selectedSlot?.date
                                        ? Colors.white
                                        : Colors.green[800])
                                    : Colors.grey[400],
                              ),
                            ),
                            if (day.hasAvailableSlots && day.dateKey != _selectedSlot?.date)
                              Container(
                                width: 4,
                                height: 4,
                                margin: const EdgeInsets.only(top: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green[500],
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }),
        
        // Legend
        SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
            ),
            Text(
              'Selected',
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 13,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(width: 16),
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: Colors.green[500],
                shape: BoxShape.circle,
              ),
            ),
            Text(
              'Available',
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 13,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(width: 16),
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                shape: BoxShape.circle,
              ),
            ),
            Text(
              'Unavailable',
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 13,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeSlotsSection(bool isSmallScreen, bool isMediumScreen) {
    final availableDates = _timeSlotsByDate.values
        .where((dateEntry) => dateEntry.hasAvailableSlots)
        .toList();

    if (availableDates.isEmpty) {
      return _buildNoSlotsState(isSmallScreen);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Time Slots',
          style: TextStyle(
            fontSize: isSmallScreen ? 16 : 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 12),
        
        // Date tabs
        SizedBox(
          height: isSmallScreen ? 48 : 52,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: availableDates.length,
            itemBuilder: (context, index) {
              final dateEntry = availableDates[index];
              final isSelected = _selectedSlot?.date == dateEntry.date;
              return Padding(
                padding: EdgeInsets.only(
                  right: index < availableDates.length - 1 ? 8 : 0,
                  left: index == 0 ? 0 : 0,
                ),
                child: GestureDetector(
                  onTap: () => _showTimeSlotsForDate(dateEntry),
                  child: Container(
                    constraints: BoxConstraints(
                      minWidth: isSmallScreen ? 90 : 100,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? Theme.of(context).primaryColor : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected 
                            ? Theme.of(context).primaryColor 
                            : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _formatShortDate(dateEntry.formattedDate),
                          style: TextStyle(
                            fontSize: isSmallScreen ? 13 : 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Colors.grey[800],
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          dateEntry.dayDisplay,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 11 : 12,
                            color: isSelected 
                                ? Colors.white.withOpacity(0.9) 
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        
        SizedBox(height: 16),
        
        // Time slots for selected date
        if (_selectedSlot != null && _selectedSlot!.date != null)
          _buildTimeSlotsForDate(_selectedSlot!.date!, isSmallScreen, isMediumScreen)
        else
          _buildTimeSlotsForDate(availableDates.first.date, isSmallScreen, isMediumScreen),
      ],
    );
  }

  Widget _buildNoSlotsState(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
        border: Border.all(color: Colors.amber[300]!),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.amber[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.info_outline_rounded,
              color: Colors.amber[700],
              size: 20,
            ),
          ),
          SizedBox(width: isSmallScreen ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No Available Slots',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 15 : 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.amber[800],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'All time slots are booked for this period. '
                  'Please try selecting a different date.',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 13 : 14,
                    color: Colors.amber[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlotsForDate(String dateKey, bool isSmallScreen, bool isMediumScreen) {
    final dateEntry = _timeSlotsByDate[dateKey];
    if (dateEntry == null) {
      log('ERROR: No date entry found for key: $dateKey');
      return _buildNoSlotsForDate(isSmallScreen);
    }
    
    if (dateEntry.timeSlots.isEmpty) {
      log('DEBUG: Date entry exists but has no time slots: $dateKey');
      return _buildNoSlotsForDate(isSmallScreen);
    }

    final availableSlots = dateEntry.timeSlots
        .where((slot) => slot.isAvailable ?? false)
        .toList();

    log('Available slots for $dateKey: ${availableSlots.length}');
    
    if (availableSlots.isEmpty) {
      log('DEBUG: All slots are booked for date: $dateKey');
      return _buildNoSlotsForDate(isSmallScreen);
    }

    // Calculate optimal columns based on screen size
    final crossAxisCount = isSmallScreen ? 3 : (isMediumScreen ? 4 : 4);
    final childAspectRatio = isSmallScreen ? 1.2 : (isMediumScreen ? 1.1 : 1.0);
    final spacing = isSmallScreen ? 8.0 : 10.0;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: availableSlots.length,
      itemBuilder: (context, index) {
        final slot = availableSlots[index];
        final isSelected = _selectedSlot?.timeSlot == slot &&
            _selectedSlot?.date == dateKey;

        return GestureDetector(
          onTap: widget.viewOnly ? null : () => _onSlotSelected(slot, dateKey, dateEntry),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: isSelected 
                  ? Theme.of(context).primaryColor 
                  : (widget.viewOnly ? Colors.grey[100] : Colors.white),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected 
                    ? Theme.of(context).primaryColor 
                    : (widget.viewOnly ? Colors.grey[300]! : Colors.blue[200]!),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isSelected 
                      ? Theme.of(context).primaryColor.withOpacity(0.2)
                      : Colors.black.withOpacity(0.05)),
                  blurRadius: isSelected ? 8 : 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: isSmallScreen ? 14 : 16,
                  color: isSelected ? Colors.white : Colors.blue[600],
                ),
                SizedBox(width: 4),
                Text(
                  TimeSlotsUtils.formatTime(slot.startTime),
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 15,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : Colors.blue[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 2),
            Text(
              'to',
              style: TextStyle(
                fontSize: isSmallScreen ? 11 : 12,
                color: isSelected 
                    ? Colors.white.withOpacity(0.9) 
                    : Colors.blue[600],
              ),
            ),
            SizedBox(height: 2),
            Text(
              TimeSlotsUtils.formatTime(slot.endTime),
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 15,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.blue[700],
              ),
            ),
            if (slot.isBooked == true)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Booked',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.red[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
      },
    );
  }

  Widget _buildNoSlotsForDate(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.schedule_outlined,
              size: isSmallScreen ? 40 : 48,
              color: Colors.grey[400],
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            Text(
              'No Slots Available',
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: isSmallScreen ? 8 : 10),
            Text(
              'All time slots are booked for this date.\nSelect a different date to see available options.',
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 15,
                color: Colors.grey[600],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebugPanel() {
    final availableDates = _timeSlotsByDate.values
        .where((dateEntry) => dateEntry.hasAvailableSlots)
        .toList();
    
    final allSlotsCount = _timeSlotsByDate.values.fold(0, (sum, entry) => sum + entry.timeSlots.length);
    final availableSlotsCount = _timeSlotsByDate.values.fold(0, 
      (sum, entry) => sum + entry.timeSlots.where((slot) => slot.isAvailable ?? false).length);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bug_report, size: 16, color: Colors.blue[700]),
              const SizedBox(width: 8),
              Text(
                'DEBUG INFO',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '• Service: ${widget.service.name} (ID: ${widget.service.id})',
            style: const TextStyle(fontSize: 11, color: Color.fromARGB(255, 36, 133, 231)),
          ),
          Text(
            '• Service Slots: ${widget.service.slots?.length ?? 0}',
            style: const TextStyle(fontSize: 11, color: Color.fromARGB(255, 33, 129, 225)),
          ),
          Text(
            '• Existing Bookings: ${widget.existingBookings.length}',
            style: const TextStyle(fontSize: 11, color: Color.fromARGB(255, 40, 136, 231)),
          ),
          Text(
            '• Generated Dates: ${_timeSlotsByDate.length}',
            style: const TextStyle(fontSize: 11, color: Color.fromARGB(255, 38, 131, 224)),
          ),
          Text(
            '• Available Dates: ${availableDates.length}',
            style: const TextStyle(fontSize: 11, color: Color.fromARGB(255, 35, 134, 232)),
          ),
          Text(
            '• Total Slots: $allSlotsCount',
            style: const TextStyle(fontSize: 11, color: Color.fromARGB(255, 33, 126, 218)),
          ),
          Text(
            '• Available Slots: $availableSlotsCount',
            style: const TextStyle(fontSize: 11, color: Color.fromARGB(255, 35, 125, 215)),
          ),
          if (_selectedSlot != null && _selectedSlot!.date != null)
            Text(
              '• Selected Date: ${_selectedSlot!.date}',
              style: const TextStyle(fontSize: 11, color: Color.fromARGB(255, 69, 170, 74)),
            ),
        ],
      ),
    );
  }

  String _getMonthYearString(DateTime date) {
    final monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${monthNames[date.month - 1]} ${date.year}';
  }

  String _formatShortDate(String formattedDate) {
    try {
      final parts = formattedDate.split(' ');
      if (parts.length >= 3) {
        final day = parts[1]; // Month short
        final date = parts[2].replaceFirst(',', '');
        return '$day $date';
      }
    } catch (e) {
      // Fallback to original
    }
    return formattedDate;
  }

  void _navigateToPreviousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
    // Trigger reload for the new month
    _loadTimeSlotsForMonth(_currentMonth);
  }

  void _navigateToNextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
    // Trigger reload for the new month
    _loadTimeSlotsForMonth(_currentMonth);
  }

  void _loadTimeSlotsForMonth(DateTime month) {
    // Implement logic to load time slots for specific month
    // This might involve filtering your existing timeSlotsByDate
    // or making a new API call if needed
    log('Loading slots for month: ${month.month}/${month.year}');
    
    // For now, just reload with current data
    _loadTimeSlots();
  }

  void _onDateSelected(String? dateKey) {
    if (dateKey == null) return;
    
    final dateEntry = _timeSlotsByDate[dateKey];
    if (dateEntry != null && dateEntry.timeSlots.isNotEmpty) {
      _showTimeSlotsForDate(dateEntry);
    }
  }

  void _showTimeSlotsForDate(DateEntry dateEntry) {
    setState(() {
      _selectedSlot = SelectedSlot(
        date: dateEntry.date,
        serviceId: widget.service.id,
      );
    });
    log('Selected date: ${dateEntry.date}');
  }

  void _onSlotSelected(TimeSlot slot, String dateKey, DateEntry dateEntry) {
    final newSelectedSlot = SelectedSlot(
      date: dateKey,
      timeSlot: slot,
      serviceId: widget.service.id,
    );

    setState(() {
      _selectedSlot = newSelectedSlot;
    });

    widget.onSlotSelected?.call(newSelectedSlot);
    
    // Show confirmation
    _showSelectionConfirmation(slot);
    log('Selected slot: $dateKey ${slot.startTime}-${slot.endTime}');
  }

  void _showSelectionConfirmation(TimeSlot slot) {
    final startTime = TimeSlotsUtils.formatTime(slot.startTime);
    final endTime = TimeSlotsUtils.formatTime(slot.endTime);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Selected: $startTime - $endTime',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: Theme.of(context).primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}