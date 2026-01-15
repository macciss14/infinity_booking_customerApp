// lib/utils/time_slots_utils.dart
import 'package:flutter/foundation.dart';
import '../models/service_model.dart';
import '../models/booking_model.dart';

class TimeSlotsUtils {
  // Week days configuration
  static const List<Map<String, String>> weekDays = [
    {'day': 'monday', 'displayName': 'Monday'},
    {'day': 'tuesday', 'displayName': 'Tuesday'},
    {'day': 'wednesday', 'displayName': 'Wednesday'},
    {'day': 'thursday', 'displayName': 'Thursday'},
    {'day': 'friday', 'displayName': 'Friday'},
    {'day': 'saturday', 'displayName': 'Saturday'},
    {'day': 'sunday', 'displayName': 'Sunday'},
  ];

  // =================== CORE TIME SLOT FUNCTIONS ===================

  // Get all time slots grouped by date for calendar view
  static Map<String, DateEntry> getAllTimeSlotsByDate(
    List<ServiceSlot> serviceSlots, {
    List<TimeSlotsBooking> existingBookings = const [],
  }) {
    final timeSlotsByDate = <String, DateEntry>{};

    if (serviceSlots.isEmpty) {
      debugPrint('WARNING: No service slots provided');
      return timeSlotsByDate;
    }

    // Log service slots for debugging
    debugPrint('Processing ${serviceSlots.length} service slots');

    // Parse existing bookings into a map for quick lookup
    final bookedSlotsMap = <String, TimeSlotsBooking>{};
    for (final booking in existingBookings) {
      if (booking.bookingDate != null && booking.startTime != null) {
        String bookingDate;
        
        // Handle booking date conversion
        if (booking.bookingDate is DateTime) {
          final date = booking.bookingDate as DateTime;
          bookingDate = formatDateForStorage(date);
        } else if (booking.bookingDate is String) {
          // Convert to yyyy-MM-dd format
          bookingDate = formatDateStringToKey(booking.bookingDate as String);
        } else {
          continue; // Skip if bookingDate is not valid
        }
        
        if (bookingDate.isNotEmpty) {
          final key = '$bookingDate-${booking.startTime}';
          bookedSlotsMap[key] = booking;
          debugPrint('Booked slot: $key');
        }
      }
    }

    debugPrint('Found ${bookedSlotsMap.length} booked slots');

    // Get today's date
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);

    // Process each service slot
    for (final serviceSlot in serviceSlots) {
      // CASE 1: Schedule (changed from weeklySchedule)
      if (serviceSlot.schedule != null && serviceSlot.schedule!.isNotEmpty) {
        debugPrint('Processing schedule with ${serviceSlot.schedule!.length} days');
        
        // Check if any day has dates
        bool hasDates = false;
        for (final day in serviceSlot.schedule!) {
          if (day.date != null ||
              (day.dates != null && day.dates!.isNotEmpty) ||
              (day.dateRanges != null && day.dateRanges!.isNotEmpty)) {
            hasDates = true;
            break;
          }
        }

        if (hasDates) {
          _processScheduleWithDates(
            serviceSlot.schedule!,
            timeSlotsByDate,
            bookedSlotsMap,
            todayStart,
          );
        } else {
          _processScheduleWithoutDates(
            serviceSlot.schedule!,
            timeSlotsByDate,
            bookedSlotsMap,
            todayStart,
          );
        }
      }

      // CASE 2: Direct date-based slots
      else if (serviceSlot.specificDates != null &&
          serviceSlot.specificDates!.isNotEmpty) {
        debugPrint('Processing ${serviceSlot.specificDates!.length} specific dates');
        
        for (final dateSlot in serviceSlot.specificDates!) {
          if (dateSlot.date != null &&
              dateSlot.timeSlots != null &&
              dateSlot.timeSlots!.isNotEmpty) {
            final date = parseDate(dateSlot.date);
            if (date != null && !date.isBefore(todayStart)) {
              final dateKey = formatDateForStorage(date);

              if (!timeSlotsByDate.containsKey(dateKey)) {
                timeSlotsByDate[dateKey] = DateEntry(
                  date: dateKey,
                  formattedDate: formatDateForDisplay(date),
                  day: getDayName(date.weekday % 7),
                  dayDisplay: getDayDisplayName(getDayName(date.weekday % 7)),
                  timeSlots: [],
                  isWorkingDay: true,
                  dateObject: date,
                );
              }

              final dateEntry = timeSlotsByDate[dateKey]!;

              for (final timeSlot in dateSlot.timeSlots!) {
                final slotKey = '$dateKey-${timeSlot.startTime}';
                final existingBooking = bookedSlotsMap[slotKey];
                final isBooked = existingBooking != null;
                final isAvailable = timeSlot.isAvailable ?? true;

                final slotWithStatus = timeSlot.copyWith(
                  isBooked: isBooked,
                  isAvailable: isAvailable && !isBooked,
                  bookingId: existingBooking?.id,
                  slotIdentifier: generateSlotIdentifier(
                    dateEntry.day,
                    dateKey,
                    timeSlot,
                  ),
                  status: getSlotStatus(isAvailable, isBooked),
                );

                dateEntry.timeSlots.add(slotWithStatus);
              }
            }
          }
        }
      }
    }

    // Remove duplicates and sort
    for (final dateEntry in timeSlotsByDate.values) {
      dateEntry.timeSlots = removeDuplicateTimeSlots(dateEntry.timeSlots);
      dateEntry.timeSlots.sort((a, b) =>
          convertToMinutes(a.startTime).compareTo(convertToMinutes(b.startTime)));
    }

    // Sort dates chronologically
    final sortedKeys = timeSlotsByDate.keys.toList()..sort();
    final sortedMap = <String, DateEntry>{};
    for (final key in sortedKeys) {
      sortedMap[key] = timeSlotsByDate[key]!;
      if (kDebugMode) {
        print('Date $key has ${timeSlotsByDate[key]!.timeSlots.length} slots, '
            '${timeSlotsByDate[key]!.timeSlots.where((s) => s.isAvailable ?? false).length} available');
      }
    }

    debugPrint('Generated time slots for ${sortedMap.length} dates');
    return sortedMap;
  }

  static void _processScheduleWithDates(
    List<DaySchedule> schedule,
    Map<String, DateEntry> timeSlotsByDate,
    Map<String, TimeSlotsBooking> bookedSlotsMap,
    DateTime today,
  ) {
    for (final daySchedule in schedule) {
      if (daySchedule.isWorkingDay &&
          daySchedule.timeSlots != null &&
          daySchedule.timeSlots!.isNotEmpty) {
        final datesToProcess = <String>[];

        // Check for specific date field
        if (daySchedule.date != null) {
          datesToProcess.add(daySchedule.date!);
        }

        // Check for dates array
        if (daySchedule.dates != null && daySchedule.dates!.isNotEmpty) {
          datesToProcess.addAll(daySchedule.dates!);
        }

        // Check for date ranges
        if (daySchedule.dateRanges != null &&
            daySchedule.dateRanges!.isNotEmpty) {
          for (final range in daySchedule.dateRanges!) {
            if (range.startDate != null && range.endDate != null) {
              final start = parseDate(range.startDate);
              final end = parseDate(range.endDate);
              if (start != null && end != null) {
                final startDate = DateTime(start.year, start.month, start.day);
                final endDate = DateTime(end.year, end.month, end.day);

                if (!endDate.isBefore(today)) {
                  var current = startDate.isBefore(today) ? today : startDate;

                  while (!current.isAfter(endDate)) {
                    if (getDayName(current.weekday % 7).toLowerCase() ==
                        daySchedule.day.toLowerCase()) {
                      datesToProcess.add(formatDateForStorage(current));
                    }
                    current = current.add(const Duration(days: 1));
                  }
                }
              }
            }
          }
        }

        debugPrint('Processing ${datesToProcess.length} dates for ${daySchedule.day}');

        // Process all dates
        for (final dateString in datesToProcess) {
          final date = parseDate(dateString);
          if (date != null && !date.isBefore(today)) {
            final dateKey = formatDateForStorage(date);

            if (!timeSlotsByDate.containsKey(dateKey)) {
              timeSlotsByDate[dateKey] = DateEntry(
                date: dateKey,
                formattedDate: formatDateForDisplay(date),
                day: daySchedule.day,
                dayDisplay: getDayDisplayName(daySchedule.day),
                timeSlots: [],
                isWorkingDay: true,
                dateObject: date,
              );
            }

            final dateEntry = timeSlotsByDate[dateKey]!;

            // Add all time slots for this date
            for (final timeSlot in daySchedule.timeSlots!) {
              final slotKey = '$dateKey-${timeSlot.startTime}';
              final existingBooking = bookedSlotsMap[slotKey];
              final isBooked = existingBooking != null;
              final isAvailable = timeSlot.isAvailable ?? true;

              final slotWithStatus = timeSlot.copyWith(
                isBooked: isBooked,
                isAvailable: isAvailable && !isBooked,
                bookingId: existingBooking?.id,
                slotIdentifier: generateSlotIdentifier(
                  daySchedule.day,
                  dateKey,
                  timeSlot,
                ),
                status: getSlotStatus(isAvailable, isBooked),
              );

              dateEntry.timeSlots.add(slotWithStatus);
            }
          }
        }
      }
    }
  }

  static void _processScheduleWithoutDates(
    List<DaySchedule> schedule,
    Map<String, DateEntry> timeSlotsByDate,
    Map<String, TimeSlotsBooking> bookedSlotsMap,
    DateTime today,
  ) {
    final workingDays = schedule.where((day) =>
        day.isWorkingDay &&
        day.timeSlots != null &&
        day.timeSlots!.isNotEmpty).toList();

    if (workingDays.isEmpty) {
      debugPrint('No working days found in schedule');
      return;
    }

    final endDate = today.add(const Duration(days: 90));
    var currentDate = today;
    final daysProcessed = <String>{};

    debugPrint('Generating schedule for next 90 days with ${workingDays.length} working days');

    while (!currentDate.isAfter(endDate) && daysProcessed.length < 90) {
      final dateKey = formatDateForStorage(currentDate);
      final dayName = getDayName(currentDate.weekday % 7);

      final daySchedule = workingDays.firstWhere(
        (day) => day.day.toLowerCase() == dayName.toLowerCase(),
        orElse: () => DaySchedule(
          day: dayName,
          isWorkingDay: false,
          timeSlots: [],
        ),
      );

      if (daySchedule.isWorkingDay && !daysProcessed.contains(dateKey)) {
        if (!timeSlotsByDate.containsKey(dateKey)) {
          timeSlotsByDate[dateKey] = DateEntry(
            date: dateKey,
            formattedDate: formatDateForDisplay(currentDate),
            day: dayName,
            dayDisplay: getDayDisplayName(dayName),
            timeSlots: [],
            isWorkingDay: true,
            dateObject: currentDate,
          );
        }

        final dateEntry = timeSlotsByDate[dateKey]!;

        for (final timeSlot in daySchedule.timeSlots!) {
          final slotKey = '$dateKey-${timeSlot.startTime}';
          final existingBooking = bookedSlotsMap[slotKey];
          final isBooked = existingBooking != null;
          final isAvailable = timeSlot.isAvailable ?? true;

          final slotWithStatus = timeSlot.copyWith(
            isBooked: isBooked,
            isAvailable: isAvailable && !isBooked,
            bookingId: existingBooking?.id,
            slotIdentifier: generateSlotIdentifier(dayName, dateKey, timeSlot),
            status: getSlotStatus(isAvailable, isBooked),
          );

          dateEntry.timeSlots.add(slotWithStatus);
        }

        daysProcessed.add(dateKey);
      }

      currentDate = currentDate.add(const Duration(days: 1));
    }

    debugPrint('Generated ${daysProcessed.length} days from schedule');
  }

  // =================== UTILITY FUNCTIONS ===================

  // Format service type
  static String formatServiceType(String? type) {
    if (type == null || type.isEmpty) return 'Standard';
    return type[0].toUpperCase() + type.substring(1);
  }

  // Get initials from name
  static String getInitials(String? name) {
    if (name == null || name.isEmpty) return '?';
    final parts = name.split(' ').where((part) => part.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    } else {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
  }

  // Format duration
  static String formatDuration(int? minutes) {
    if (minutes == null || minutes == 0) return 'N/A';

    final hours = minutes ~/ 60;
    final mins = minutes % 60;

    if (hours == 0) {
      return '${mins}m';
    } else if (mins == 0) {
      return '${hours}h';
    } else {
      return '${hours}h ${mins}m';
    }
  }

  // Get day display name
  static String getDayDisplayName(String day) {
    try {
      final foundDay = weekDays.firstWhere(
        (d) => d['day'] == day.toLowerCase(),
      );
      return foundDay['displayName']!;
    } catch (e) {
      return day;
    }
  }

  // Format time (12-hour format)
  static String formatTime(String? timeString) {
    if (timeString == null || timeString.isEmpty) return '--:--';

    try {
      if (timeString.contains(':')) {
        final parts = timeString.split(':');
        if (parts.length >= 2) {
          final hour = int.tryParse(parts[0]) ?? 0;
          final minutes = parts[1].length >= 2 ? parts[1].substring(0, 2) : parts[1].padLeft(2, '0');
          final period = hour >= 12 ? 'PM' : 'AM';
          final displayHour = hour % 12 == 0 ? 12 : hour % 12;
          return '$displayHour:$minutes $period';
        }
      }
      return timeString;
    } catch (error) {
      return timeString;
    }
  }

  // =================== HELPER FUNCTIONS ===================

  static List<TimeSlot> removeDuplicateTimeSlots(List<TimeSlot> timeSlots) {
    if (timeSlots.isEmpty) return [];

    final seen = <String>{};
    final uniqueSlots = <TimeSlot>[];

    for (final slot in timeSlots) {
      final key = '${slot.startTime}-${slot.endTime}';
      if (!seen.contains(key)) {
        seen.add(key);
        uniqueSlots.add(slot);
      }
    }

    return uniqueSlots;
  }

  static int convertToMinutes(String timeString) {
    if (timeString.isEmpty) return 0;
    final parts = timeString.split(':');
    if (parts.length < 2) return 0;
    final hours = int.tryParse(parts[0]) ?? 0;
    final minutes = int.tryParse(parts[1]) ?? 0;
    return hours * 60 + minutes;
  }

  static String getSlotStatus(bool isAvailable, bool isBooked) {
    if (isBooked) return 'booked';
    if (!isAvailable) return 'unavailable';
    return 'available';
  }

  static String generateSlotIdentifier(
      String day, String date, TimeSlot timeSlot) {
    return '$day-$date-${timeSlot.startTime}-${timeSlot.endTime}';
  }

  static String formatDateForDisplay(DateTime date) {
    final weekday = _getWeekdayShort(date.weekday);
    final month = _getMonthShort(date.month);
    return '$weekday $month ${date.day}, ${date.year}';
  }

  static String formatDateForStorage(DateTime date) {
    final year = date.year;
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  static String formatDateStringToKey(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';

    try {
      if (dateString.contains('/')) {
        // Convert from dd/MM/yyyy to yyyy-MM-dd
        final parts = dateString.split('/');
        if (parts.length == 3) {
          final day = parts[0].padLeft(2, '0');
          final month = parts[1].padLeft(2, '0');
          final year = parts[2];
          return '$year-$month-$day';
        }
      } else if (dateString.contains('-') && dateString.split('-').length == 3) {
        // Already in yyyy-MM-dd format
        return dateString;
      }
    } catch (e) {
      debugPrint('Error formatting date string: $dateString - $e');
    }

    return dateString;
  }

  static String getMonthName(int monthIndex) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[monthIndex];
  }

  static int getDayIndex(String dayName) {
    final dayMap = {
      'sunday': 0,
      'monday': 1,
      'tuesday': 2,
      'wednesday': 3,
      'thursday': 4,
      'friday': 5,
      'saturday': 6,
    };

    final lowerDayName = dayName.toLowerCase();
    return dayMap[lowerDayName] ?? 0;
  }

  static String getDayName(int dayIndex) {
    const days = [
      'sunday',
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday'
    ];
    return days[dayIndex];
  }

  static DateTime? parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;

    try {
      // Try parsing yyyy-MM-dd format first
      if (dateString.contains('-') && dateString.split('-').length == 3) {
        final parts = dateString.split('-');
        if (parts.length == 3) {
          final year = int.tryParse(parts[0]) ?? DateTime.now().year;
          final month = int.tryParse(parts[1]) ?? 1;
          final day = int.tryParse(parts[2]) ?? 1;
          return DateTime(year, month, day);
        }
      }
      
      // Try parsing dd/MM/yyyy format
      if (dateString.contains('/') && dateString.split('/').length == 3) {
        final parts = dateString.split('/');
        if (parts.length == 3) {
          final day = int.tryParse(parts[0]) ?? 1;
          final month = int.tryParse(parts[1]) ?? 1;
          final year = int.tryParse(parts[2]) ?? DateTime.now().year;
          return DateTime(year, month, day);
        }
      }
      
      // Try parsing as ISO string
      final parsed = DateTime.tryParse(dateString);
      if (parsed != null) return parsed;
      
    } catch (error) {
      debugPrint('Error parsing date: $dateString - $error');
      return null;
    }

    return null;
  }

  // =================== CALENDAR FUNCTIONS ===================

  // Get calendar data for a specific month
  static CalendarData getCalendarData(
    List<ServiceSlot> serviceSlots, {
    List<TimeSlotsBooking> existingBookings = const [],
    int? year,
    int? month,
  }) {
    final currentDate = DateTime.now();
    final targetYear = year ?? currentDate.year;
    final targetMonth = month ?? currentDate.month;

    // Get all time slots
    final allTimeSlots =
        getAllTimeSlotsByDate(serviceSlots, existingBookings: existingBookings);

    // If no slots, return empty calendar
    if (allTimeSlots.isEmpty) {
      return CalendarData(
        year: targetYear,
        month: targetMonth,
        monthName: getMonthName(targetMonth),
        calendar: [],
        totalDates: 0,
        availableDates: 0,
      );
    }

    // Generate calendar for the specified month
    final calendar = _generateCalendarGrid(targetYear, targetMonth, allTimeSlots);

    // Count available dates
    int availableDatesCount = 0;
    for (final dateEntry in allTimeSlots.values) {
      if (dateEntry.timeSlots.any((slot) => slot.isAvailable ?? false)) {
        availableDatesCount++;
      }
    }

    return CalendarData(
      year: targetYear,
      month: targetMonth,
      monthName: getMonthName(targetMonth),
      calendar: calendar,
      totalDates: allTimeSlots.length,
      availableDates: availableDatesCount,
    );
  }

  static List<List<CalendarDay>> _generateCalendarGrid(
    int year,
    int month,
    Map<String, DateEntry> timeSlotsByDate,
  ) {
    final firstDay = DateTime(year, month, 1);
    final lastDay = month < 12 ? DateTime(year, month + 1, 0) : DateTime(year + 1, 1, 0);
    final daysInMonth = lastDay.day;

    final firstDayOfWeek = firstDay.weekday % 7;

    final calendar = <List<CalendarDay>>[];
    var week = <CalendarDay>[];

    // Add empty cells for days before the first day of month
    for (var i = 0; i < firstDayOfWeek; i++) {
      week.add(CalendarDay.empty());
    }

    // Add days of the month
    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      final dateKey = formatDateForStorage(date);
      final dateSlots = timeSlotsByDate[dateKey];

      final hasSlots = dateSlots != null;
      final hasAvailableSlots =
          dateSlots?.timeSlots.any((slot) => slot.isAvailable ?? false) ?? false;

      final dateInfo = CalendarDay(
        date: date,
        dateKey: dateKey,
        formattedDate: formatDateForDisplay(date),
        dayOfMonth: day,
        dayOfWeek: getDayName(date.weekday % 7),
        hasSlots: hasSlots,
        timeSlots: dateSlots?.timeSlots ?? [],
        isWorkingDay: dateSlots?.isWorkingDay ?? false,
        hasAvailableSlots: hasAvailableSlots,
        isEmpty: false,
      );

      week.add(dateInfo);

      if (week.length == 7) {
        calendar.add([...week]);
        week = [];
      }
    }

    if (week.isNotEmpty) {
      while (week.length < 7) {
        week.add(CalendarDay.empty());
      }
      calendar.add(week);
    }

    return calendar;
  }

  // Get slots for specific date
  static DateEntry getSlotsForDate(
    List<ServiceSlot> serviceSlots,
    List<TimeSlotsBooking> existingBookings,
    String dateString,
  ) {
    final allSlots = getAllTimeSlotsByDate(
      serviceSlots,
      existingBookings: existingBookings,
    );
    final dateKey = formatDateStringToKey(dateString);

    if (allSlots.containsKey(dateKey)) {
      return allSlots[dateKey]!;
    }

    final date = parseDate(dateKey) ?? DateTime.now();
    return DateEntry(
      date: dateKey,
      formattedDate: formatDateForDisplay(date),
      day: getDayName(date.weekday % 7),
      dayDisplay: getDayDisplayName(getDayName(date.weekday % 7)),
      timeSlots: [],
      isWorkingDay: false,
      dateObject: date,
    );
  }

  // Get available dates count
  static int getAvailableDatesCount(ServiceModel service) {
    if (service.slots.isEmpty) {
      return 0;
    }

    final allTimeSlots = getAllTimeSlotsByDate(service.slots);

    var count = 0;
    for (final dateEntry in allTimeSlots.values) {
      final availableSlots =
          dateEntry.timeSlots.where((slot) => slot.isAvailable ?? false).toList();
      if (availableSlots.isNotEmpty) {
        count++;
      }
    }

    return count;
  }

  // Get available slots count for ServiceCard
  static int getAvailableSlotsCount(ServiceModel service) {
    if (service.slots.isEmpty) {
      return 0;
    }

    final allTimeSlots = getAllTimeSlotsByDate(service.slots);

    var totalAvailableSlots = 0;
    for (final dateEntry in allTimeSlots.values) {
      final availableSlots =
          dateEntry.timeSlots.where((slot) => slot.isAvailable ?? false).toList();
      totalAvailableSlots += availableSlots.length;
    }

    return totalAvailableSlots;
  }

  // Get next available date
  static NextAvailableDate? getNextAvailableDate(
    List<ServiceSlot> serviceSlots, {
    List<TimeSlotsBooking> existingBookings = const [],
  }) {
    final allSlots = getAllTimeSlotsByDate(
      serviceSlots,
      existingBookings: existingBookings,
    );
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);

    final sortedDates = allSlots.keys.toList()..sort();

    for (final dateKey in sortedDates) {
      final date = parseDate(dateKey);
      if (date != null && !date.isBefore(todayStart)) {
        final dateEntry = allSlots[dateKey]!;
        final availableSlots =
            dateEntry.timeSlots.where((slot) => slot.isAvailable ?? false).toList();
        if (availableSlots.isNotEmpty) {
          return NextAvailableDate(
            date: dateKey,
            formattedDate: dateEntry.formattedDate,
            day: dateEntry.dayDisplay,
            timeSlots: availableSlots,
          );
        }
      }
    }

    return null;
  }

  // Prepare booking data
  static Map<String, dynamic> prepareBookingData({
    required SelectedSlot selectedSlot,
    required ServiceModel service,
    required Map<String, dynamic> provider,
    required String customerId,
  }) {
    if (selectedSlot.timeSlot == null) {
      throw Exception('No time slot selected');
    }

    if (selectedSlot.timeSlot!.isBooked == true || 
        !(selectedSlot.timeSlot!.isAvailable ?? false)) {
      throw Exception('Selected time slot is not available for booking');
    }

    String bookingDate;

    if (selectedSlot.date != null) {
      // Convert from yyyy-MM-dd to dd/MM/yyyy for API
      if (selectedSlot.date!.contains('-')) {
        final parts = selectedSlot.date!.split('-');
        if (parts.length == 3) {
          // yyyy-MM-dd -> dd/MM/yyyy
          bookingDate = '${parts[2]}/${parts[1]}/${parts[0]}';
        } else {
          // Fallback to today
          final today = DateTime.now();
          bookingDate = '${today.day.toString().padLeft(2, '0')}/${today.month.toString().padLeft(2, '0')}/${today.year}';
        }
      } else if (selectedSlot.date!.contains('/')) {
        // Already in dd/MM/yyyy format
        bookingDate = selectedSlot.date!;
      } else {
        // Fallback to today
        final today = DateTime.now();
        bookingDate = '${today.day.toString().padLeft(2, '0')}/${today.month.toString().padLeft(2, '0')}/${today.year}';
      }
    } else {
      final today = DateTime.now();
      bookingDate = '${today.day.toString().padLeft(2, '0')}/${today.month.toString().padLeft(2, '0')}/${today.year}';
    }

    final serviceId = selectedSlot.serviceId ?? service.id;
    final providerId = provider['id'] ?? provider['_id'] ?? provider['pid'];

    if (serviceId.isEmpty) throw Exception('Service ID is required');
    if (providerId == null) throw Exception('Provider ID is required');

    debugPrint('Preparing booking data: date=$bookingDate, time=${selectedSlot.timeSlot!.startTime}-${selectedSlot.timeSlot!.endTime}');

    return {
      'customerId': customerId,
      'providerId': providerId.toString(),
      'serviceId': serviceId,
      'bookingDate': bookingDate, // dd/MM/yyyy format for API
      'startTime': selectedSlot.timeSlot!.startTime,
      'endTime': selectedSlot.timeSlot!.endTime,
      'notes': 'Booking for ${service.name}',
      'totalAmount': service.totalPrice,
      'status': 'pending',
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  // Validate time slot
  static bool isValidTimeSlot(TimeSlot? timeSlot) {
    return timeSlot != null &&
        timeSlot.startTime.isNotEmpty &&
        timeSlot.endTime.isNotEmpty;
  }

  // =================== PRIVATE HELPER METHODS ===================

  static String _getWeekdayShort(int weekday) {
    const weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return weekdays[weekday];
  }

  static String _getMonthShort(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  // Convert date from dd/MM/yyyy to yyyy-MM-dd
  static String convertToYYYYMMDD(String dateString) {
    if (dateString.contains('/')) {
      final parts = dateString.split('/');
      if (parts.length == 3) {
        final day = parts[0].padLeft(2, '0');
        final month = parts[1].padLeft(2, '0');
        final year = parts[2];
        return '$year-$month-$day';
      }
    }
    return dateString;
  }

  // Convert date from yyyy-MM-dd to dd/MM/yyyy
  static String convertToDDMMYYYY(String dateString) {
    if (dateString.contains('-')) {
      final parts = dateString.split('-');
      if (parts.length == 3) {
        final year = parts[0];
        final month = parts[1].padLeft(2, '0');
        final day = parts[2].padLeft(2, '0');
        return '$day/$month/$year';
      }
    }
    return dateString;
  }
}

// =================== TIME SLOTS UTILITY MODELS ===================

class DateEntry {
  final String date;
  final String formattedDate;
  final String day;
  final String dayDisplay;
  List<TimeSlot> timeSlots;
  final bool isWorkingDay;
  final DateTime dateObject;

  DateEntry({
    required this.date,
    required this.formattedDate,
    required this.day,
    required this.dayDisplay,
    required this.timeSlots,
    required this.isWorkingDay,
    required this.dateObject,
  });

  bool get hasAvailableSlots {
    return timeSlots.any((slot) => slot.isAvailable ?? false);
  }

  int get availableSlotsCount {
    return timeSlots.where((slot) => slot.isAvailable ?? false).length;
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'formattedDate': formattedDate,
      'day': day,
      'dayDisplay': dayDisplay,
      'timeSlots': timeSlots.map((slot) => slot.toJson()).toList(),
      'isWorkingDay': isWorkingDay,
      'hasAvailableSlots': hasAvailableSlots,
      'availableSlotsCount': availableSlotsCount,
      'dateObject': dateObject.toIso8601String(),
    };
  }
}

class CalendarDay {
  final DateTime? date;
  final String? dateKey;
  final String? formattedDate;
  final int? dayOfMonth;
  final String? dayOfWeek;
  final bool hasSlots;
  final List<TimeSlot> timeSlots;
  final bool isWorkingDay;
  final bool hasAvailableSlots;
  final bool isEmpty;

  const CalendarDay({
    this.date,
    this.dateKey,
    this.formattedDate,
    this.dayOfMonth,
    this.dayOfWeek,
    required this.hasSlots,
    required this.timeSlots,
    required this.isWorkingDay,
    required this.hasAvailableSlots,
    required this.isEmpty,
  });

  factory CalendarDay.empty() {
    return CalendarDay(
      date: null,
      dateKey: null,
      formattedDate: null,
      dayOfMonth: null,
      dayOfWeek: null,
      hasSlots: false,
      timeSlots: [],
      isWorkingDay: false,
      hasAvailableSlots: false,
      isEmpty: true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (date != null) 'date': date!.toIso8601String(),
      'dateKey': dateKey,
      'formattedDate': formattedDate,
      'dayOfMonth': dayOfMonth,
      'dayOfWeek': dayOfWeek,
      'hasSlots': hasSlots,
      'timeSlots': timeSlots.map((slot) => slot.toJson()).toList(),
      'isWorkingDay': isWorkingDay,
      'hasAvailableSlots': hasAvailableSlots,
      'isEmpty': isEmpty,
    };
  }
}

class CalendarData {
  final int year;
  final int month;
  final String monthName;
  final List<List<CalendarDay>> calendar;
  final int totalDates;
  final int availableDates;

  const CalendarData({
    required this.year,
    required this.month,
    required this.monthName,
    required this.calendar,
    required this.totalDates,
    required this.availableDates,
  });

  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'month': month,
      'monthName': monthName,
      'calendar': calendar.map(
        (week) => week.map((day) => day.toJson()).toList()
      ).toList(),
      'totalDates': totalDates,
      'availableDates': availableDates,
    };
  }
}

class NextAvailableDate {
  final String date;
  final String formattedDate;
  final String day;
  final List<TimeSlot> timeSlots;

  const NextAvailableDate({
    required this.date,
    required this.formattedDate,
    required this.day,
    required this.timeSlots,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'formattedDate': formattedDate,
      'day': day,
      'timeSlots': timeSlots.map((slot) => slot.toJson()).toList(),
    };
  }
}

// Simple booking model for time slots utility
class TimeSlotsBooking {
  final String id;
  final dynamic bookingDate; // Can be String or DateTime
  final String startTime;
  final String endTime;

  const TimeSlotsBooking({
    required this.id,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
  });
}