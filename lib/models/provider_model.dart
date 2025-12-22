// lib/models/provider_model.dart

class ProviderModel {
  final String id;
  final String pid; // ✅ Only real PID (PROV-xxx)
  final String fullname;
  final String email;
  final String phone;
  final String? avatar;
  final double? rating;
  final int? reviewCount;
  final int? totalBookings;
  final bool isVerified;
  final String? bio;
  final Map<String, dynamic>? metadata;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? businessName;
  final String? username;
  final String? firstName;
  final String? lastName;
  final String? address;
  final String? city;
  final String? country;
  final List<String>? languages;
  final List<String>? specialties;
  final double? responseRate;
  final int? responseTimeHours;
  final bool? isOnline;
  final DateTime? lastActive;

  ProviderModel({
    required this.id,
    required this.pid,
    required this.fullname,
    required this.email,
    required this.phone,
    this.avatar,
    this.rating,
    this.reviewCount,
    this.totalBookings,
    this.isVerified = false,
    this.bio,
    this.metadata,
    this.createdAt,
    this.updatedAt,
    this.businessName,
    this.username,
    this.firstName,
    this.lastName,
    this.address,
    this.city,
    this.country,
    this.languages,
    this.specialties,
    this.responseRate,
    this.responseTimeHours,
    this.isOnline,
    this.lastActive,
  });

  factory ProviderModel.fromJson(Map<String, dynamic> json) {
    return ProviderModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      pid: json['pid']?.toString() ?? '',
      fullname: json['fullname']?.toString() ??
          json['name']?.toString() ??
          json['businessName']?.toString() ??
          'Unknown Provider', // ✅ Never empty
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      avatar: json['avatar']?.toString() ??
          json['profileImage']?.toString() ??
          json['profilePicture']?.toString(),
      rating: json['rating'] != null
          ? (json['rating'] is num
              ? (json['rating'] as num).toDouble()
              : double.tryParse(json['rating'].toString()) ?? 0.0)
          : null,
      reviewCount: _parseInt(json['reviewCount'] ?? json['reviewsCount']),
      totalBookings: _parseInt(json['totalBookings'] ?? json['bookingCount']),
      isVerified: json['isVerified'] == true,
      bio: json['bio']?.toString() ??
          json['description']?.toString() ??
          json['about']?.toString(),
      metadata:  json['metadata'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['metadata'])
          : null,
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
      businessName: json['businessName']?.toString(),
      username: json['username']?.toString(),
      firstName: json['firstName']?.toString(),
      lastName: json['lastName']?.toString(),
      address: json['address']?.toString(),
      city: json['city']?.toString(),
      country: json['country']?.toString(),
      languages: json['languages'] is List
          ? List<String>.from(json['languages'].map((x) => x.toString()))
          : null,
      specialties: json['specialties'] is List
          ? List<String>.from(json['specialties'].map((x) => x.toString()))
          : null,
      responseRate: json['responseRate'] != null
          ? (json['responseRate'] is num
              ? (json['responseRate'] as num).toDouble()
              : double.tryParse(json['responseRate'].toString()) ?? 0.0)
          : null,
      responseTimeHours: _parseInt(json['responseTimeHours']),
      isOnline: json['isOnline'] == true,
      lastActive: _parseDateTime(json['lastActive']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pid': pid,
      'fullname': fullname,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'rating': rating,
      'reviewCount': reviewCount,
      'totalBookings': totalBookings,
      'isVerified': isVerified,
      'bio': bio,
      'metadata': metadata,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'businessName': businessName,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'address': address,
      'city': city,
      'country': country,
      'languages': languages,
      'specialties': specialties,
      'responseRate': responseRate,
      'responseTimeHours': responseTimeHours,
      'isOnline': isOnline,
      'lastActive': lastActive?.toIso8601String(),
    };
  }

  String get initials {
    if (fullname.isEmpty || fullname == 'Unknown Provider') return '?';
    final parts = fullname.trim().split(' ').where((part) => part.isNotEmpty).toList();
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (fullname.length >= 2) return fullname.substring(0, 2).toUpperCase();
    return fullname.isNotEmpty ? fullname[0].toUpperCase() : '?';
  }

  bool get hasRating => rating != null && rating! > 0;
  bool get hasReviews => reviewCount != null && reviewCount! > 0;
  bool get hasBookings => totalBookings != null && totalBookings! > 0;

  String get displayName => businessName?.isNotEmpty == true ? businessName! : fullname;

  String get contactInfo {
    final contacts = <String>[];
    if (phone.isNotEmpty) contacts.add(phone);
    if (email.isNotEmpty) contacts.add(email);
    return contacts.join(' • ');
  }

  String get formattedRating => rating == null || rating == 0 ? 'N/A' : rating!.toStringAsFixed(1);

  String get ratingColor {
    if (rating == null) return '#6b7280';
    if (rating! >= 4.5) return '#10b981';
    if (rating! >= 3.5) return '#f59e0b';
    return '#ef4444';
  }

  String get responseTimeDisplay {
    if (responseTimeHours == null) return 'N/A';
    if (responseTimeHours! < 1) return '<1 hour';
    if (responseTimeHours! <= 24) return '$responseTimeHours hours';
    return '${(responseTimeHours! / 24).toStringAsFixed(0)} days';
  }

  String get formattedJoinedDate {
    if (createdAt == null) return 'Unknown';
    final now = DateTime.now();
    final difference = now.difference(createdAt!);
    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    }
    return 'Today';
  }

  bool get hasCompleteProfile =>
      fullname.isNotEmpty && email.isNotEmpty && phone.isNotEmpty && (avatar?.isNotEmpty == true);

  String get verificationBadgeText {
    if (isVerified) return 'Verified';
    if (totalBookings != null && totalBookings! >= 10) return 'Experienced';
    if (rating != null && rating! >= 4.0) return 'Highly Rated';
    return 'New Provider';
  }

  String get verificationBadgeColor {
    if (isVerified) return '#10b981';
    if (totalBookings != null && totalBookings! >= 10) return '#3b82f6';
    if (rating != null && rating! >= 4.0) return '#f59e0b';
    return '#6b7280';
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      try {
        return int.parse(value.replaceAll(',', ''));
      } catch (_) {
        return 0;
      }
    }
    return 0;
  }

  static DateTime? _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return null;
    try {
      if (dateValue is String) return DateTime.parse(dateValue);
      if (dateValue is Map) {
        final dateMap = dateValue as Map<String, dynamic>;
        if (dateMap['\$date'] != null) {
          final dateStr = dateMap['\$date'].toString();
          return DateTime.parse(dateStr);
        }
      }
      if (dateValue is int) return DateTime.fromMillisecondsSinceEpoch(dateValue);
    } catch (e) {
      print('Error parsing date in ProviderModel: $e');
    }
    return null;
  }

  ProviderModel copyWith({
    String? id,
    String? pid,
    String? fullname,
    String? email,
    String? phone,
    String? avatar,
    double? rating,
    int? reviewCount,
    int? totalBookings,
    bool? isVerified,
    String? bio,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? businessName,
    String? username,
    String? firstName,
    String? lastName,
    String? address,
    String? city,
    String? country,
    List<String>? languages,
    List<String>? specialties,
    double? responseRate,
    int? responseTimeHours,
    bool? isOnline,
    DateTime? lastActive,
  }) {
    return ProviderModel(
      id: id ?? this.id,
      pid: pid ?? this.pid,
      fullname: fullname ?? this.fullname,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      totalBookings: totalBookings ?? this.totalBookings,
      isVerified: isVerified ?? this.isVerified,
      bio: bio ?? this.bio,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      businessName: businessName ?? this.businessName,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      languages: languages ?? this.languages,
      specialties: specialties ?? this.specialties,
      responseRate: responseRate ?? this.responseRate,
      responseTimeHours: responseTimeHours ?? this.responseTimeHours,
      isOnline: isOnline ?? this.isOnline,
      lastActive: lastActive ?? this.lastActive,
    );
  }

  @override
  String toString() => 'ProviderModel{id: $id, pid: $pid, fullname: $fullname, isVerified: $isVerified}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProviderModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          pid == other.pid;

  @override
  int get hashCode => Object.hash(id, pid);
}