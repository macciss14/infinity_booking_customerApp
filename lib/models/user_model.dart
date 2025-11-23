import '../utils/constants.dart';

class User {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String address;
  final String? profilePhoto;
  final List<String>? preferredServices;
  final bool twoFactorEnabled;
  final DateTime registrationDate;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.address,
    this.profilePhoto,
    this.preferredServices,
    this.twoFactorEnabled = false,
    required this.registrationDate,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    print('🔄 User.fromJson - parsing user: ${json.keys}');

    // Enhanced profile photo extraction
    String? photo;
    if (json['profilePhoto'] != null && json['profilePhoto'] != "") {
      photo = json['profilePhoto'];
    } else if (json['profilePicture'] != null) {
      photo = json['profilePicture'];
    } else if (json['avatar'] != null) {
      photo = json['avatar'];
    } else if (json['photoUrl'] != null) {
      photo = json['photoUrl'];
    } else if (json['image'] != null) {
      photo = json['image'];
    } else if (json['photo'] != null) {
      photo = json['photo'];
    }

    // Enhanced phone extraction - handle different field names
    String phone = '';
    if (json['phonenumber'] != null &&
        json['phonenumber'].toString().isNotEmpty) {
      phone = json['phonenumber'].toString();
    } else if (json['phoneNumber'] != null &&
        json['phoneNumber'].toString().isNotEmpty) {
      phone = json['phoneNumber'].toString();
    } else if (json['phone'] != null && json['phone'].toString().isNotEmpty) {
      phone = json['phone'].toString();
    } else if (json['mobile'] != null && json['mobile'].toString().isNotEmpty) {
      phone = json['mobile'].toString();
    }

    // Enhanced address extraction
    String address = '';
    if (json['address'] != null && json['address'].toString().isNotEmpty) {
      address = json['address'].toString();
    } else if (json['location'] != null &&
        json['location'].toString().isNotEmpty) {
      address = json['location'].toString();
    } else if (json['userAddress'] != null &&
        json['userAddress'].toString().isNotEmpty) {
      address = json['userAddress'].toString();
    }

    DateTime created;
    try {
      String dateString = json['registeredAt']?.toString() ??
          json['createdAt']?.toString() ??
          json['registrationDate']?.toString() ??
          DateTime.now().toString();
      created = DateTime.parse(dateString);
    } catch (_) {
      created = DateTime.now();
    }

    print('📱 Extracted phone: "$phone"');
    print('🏠 Extracted address: "$address"');
    print('📸 Extracted photo: $photo');

    return User(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      fullName: json['fullname']?.toString() ??
          json['fullName']?.toString() ??
          json['name']?.toString() ??
          'Unknown User',
      email: json['email']?.toString() ?? '',
      phone: phone,
      address: address,
      profilePhoto: photo,
      preferredServices: (json['preferredServices'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      twoFactorEnabled: json['isTwoFactorEnabled'] ?? false,
      registrationDate: created,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullname': fullName,
      'email': email,
      'phonenumber': phone,
      'address': address,
      'profilePhoto': profilePhoto,
      'preferredServices': preferredServices,
      'isTwoFactorEnabled': twoFactorEnabled,
      'registeredAt': registrationDate.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    String? address,
    String? profilePhoto,
    List<String>? preferredServices,
    bool? twoFactorEnabled,
    DateTime? registrationDate,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      preferredServices: preferredServices ?? this.preferredServices,
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
      registrationDate: registrationDate ?? this.registrationDate,
    );
  }

  String? getProfilePhotoUrl() {
    if (profilePhoto == null || profilePhoto!.isEmpty) return null;

    if (profilePhoto!.startsWith("http")) {
      return profilePhoto;
    }

    // Handle relative URLs
    if (profilePhoto!.startsWith("/")) {
      return "${Constants.apiBaseUrl}${profilePhoto}";
    }

    return "${Constants.apiBaseUrl}/uploads/$profilePhoto";
  }
}
