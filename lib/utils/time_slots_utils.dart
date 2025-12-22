// lib/utils/time_slots_utils.dart
import 'package:intl/intl.dart';

List<Map<String, dynamic>> getAllDays(
  List<dynamic> serviceSlots,
  List<dynamic> existingBookings,
) {
  final List<Map<String, dynamic>> days = [];
  final now = DateTime.now();
  for (int i = 0; i < 7; i++) {
    final date = now.add(Duration(days: i));
    final dayName = getDayName(date.weekday);
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final displayDate = DateFormat('dd/MM').format(date);

    final daySlots = _getDaySlots(serviceSlots, dayName, existingBookings, formattedDate);
    days.add({
      'day': dayName,
      'date': formattedDate,
      'formattedDate': displayDate,
      'isWorkingDay': daySlots.isNotEmpty,
      'timeSlots': daySlots,
    });
  }
  return days;
}

List<Map<String, dynamic>> _getDaySlots(
  List<dynamic> serviceSlots,
  String dayName,
  List<dynamic> existingBookings,
  String date,
) {
  final List<Map<String, dynamic>> daySlots = [];
  for (var slot in serviceSlots) {
    if (slot is Map<String, dynamic>) {
      final weeklySchedule = slot['weeklySchedule'] as List?;
      if (weeklySchedule != null) {
        for (var day in weeklySchedule) {
          if (day is Map &&
              (day['day']?.toString().toLowerCase() == dayName.toLowerCase()) &&
              day['isWorkingDay'] == true) {
            final timeSlots = day['timeSlots'] as List?;
            if (timeSlots != null) {
              for (var timeSlot in timeSlots) {
                if (timeSlot is Map) {
                  final isBooked = _isSlotBooked(
                    existingBookings,
                    date,
                    timeSlot['startTime'],
                    timeSlot['endTime'],
                  );
                  daySlots.add({
                    'startTime': timeSlot['startTime'],
                    'endTime': timeSlot['endTime'],
                    'isAvailable': timeSlot['isAvailable'] == true,
                    'isBooked': isBooked,
                  });
                }
              }
            }
          }
        }
      }
    }
  }
  return daySlots;
}

bool _isSlotBooked(
  List<dynamic> existingBookings,
  String date,
  dynamic startTime,
  dynamic endTime,
) {
  for (var booking in existingBookings) {
    if (booking is Map) {
      final bookingDate = booking['bookingDate']?.toString();
      final bookingStartTime = booking['startTime']?.toString();
      final bookingEndTime = booking['endTime']?.toString();
      if (bookingDate == date &&
          bookingStartTime == startTime?.toString() &&
          bookingEndTime == endTime?.toString()) {
        return true;
      }
    }
  }
  return false;
}

String getDayName(int weekday) {
  switch (weekday) {
    case 1: return 'Monday';
    case 2: return 'Tuesday';
    case 3: return 'Wednesday';
    case 4: return 'Thursday';
    case 5: return 'Friday';
    case 6: return 'Saturday';
    case 7: return 'Sunday';
    default: return 'Unknown';
  }
}

String getDayDisplayName(String dayName) {
  final lower = dayName.toLowerCase();
  switch (lower) {
    case 'monday': return 'Mon';
    case 'tuesday': return 'Tue';
    case 'wednesday': return 'Wed';
    case 'thursday': return 'Thu';
    case 'friday': return 'Fri';
    case 'saturday': return 'Sat';
    case 'sunday': return 'Sun';
    default: return dayName.substring(0, 3);
  }
}

String formatTime(String timeString) {
  try {
    final parts = timeString.split(':');
    if (parts.length >= 2) {
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour % 12 == 0 ? 12 : hour % 12;
      return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
    }
    return timeString;
  } catch (e) {
    return timeString;
  }
}

// Convert YYYY-MM-DD → DD/MM/YYYY
String convertToDDMMYYYY(String isoDate) {
  final parts = isoDate.split('-');
  if (parts.length == 3) {
    return '${parts[2]}/${parts[1]}/${parts[0]}';
  }
  throw const FormatException('Invalid date format');
}