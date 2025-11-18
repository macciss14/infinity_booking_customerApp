// lib/models/user_model.dart

import 'dart:convert';

class User {
  final String id;
  final String fullName;
  final String email;
  final String phone; // Maps to 'phoneNumber' from backend profile response
  final String address;
  final String?
  profilePictureUrl; // Maps to 'profileImage' from backend profile response
  final List<String>?
  preferredServices; // Maps to 'preferredServices' from backend profile response
  final bool
  twoFactorEnabled; // Maps to 'isTwoFactorEnabled' from backend profile response
  final DateTime
  registrationDate; // Maps to 'registeredAt' from backend profile response

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone, // Internal field name for phone number
    required this.address,
    this.profilePictureUrl,
    this.preferredServices,
    this.twoFactorEnabled = false,
    required this.registrationDate,
  });

  // Factory constructor to create a User instance from JSON data
  factory User.fromJson(Map<String, dynamic> json) {
    // IMPORTANT: The key name 'phoneNumber' must match EXACTLY what the /users/profile endpoint returns
    return User(
      id:
          json['_id'] ??
          json['id'] ??
          '', // Adjust key based on your API response (often _id in MongoDB)
      fullName:
          json['fullname'] ??
          json['fullName'] ??
          json['full_name'] ??
          '', // Adjust key based on your API response - auth endpoints might use 'fullname', profile might use 'fullName'
      email: json['email'] ?? '', // Adjust key based on your API response
      phone:
          json['phoneNumber'] ??
          json['phone'] ??
          json['phonenumber'] ??
          '', // CRITICAL: Check backend response for /users/profile. Likely 'phoneNumber' per schema.
      address: json['address'] ?? '', // Adjust key based on your API response
      profilePictureUrl:
          json['profileImage'] ??
          json['profilePictureUrl'] ??
          json['profile_image_url'], // Adjust key based on your API response - likely 'profileImage' from CustomerProfile
      preferredServices: (json['preferredServices'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      twoFactorEnabled:
          json['isTwoFactorEnabled'] ??
          json['two_factor_enabled'] ??
          json['isTwoFactorEnabled'] ??
          false, // Adjust key based on your API response - likely 'isTwoFactorEnabled' from CustomerProfile
      registrationDate: DateTime.parse(
        json['registeredAt'] ??
            json['registrationDate'] ??
            json['registration_date'] ??
            DateTime.now().toIso8601String(),
      ), // Adjust key based on your API response - likely 'registeredAt' from CustomerProfile
    );
  }

  // Method to convert a User instance back to a JSON map (e.g., for sending updates to the API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullname':
          fullName, // Key expected by backend for updates (likely 'fullname' per auth/register)
      'email': email,
      'phoneNumber':
          phone, // Key expected by backend for updates (likely 'phoneNumber' per CustomerProfile)
      'address': address,
      'profileImage':
          profilePictureUrl, // Key expected by backend for updates (likely 'profileImage' per CustomerProfile)
      'preferredServices':
          preferredServices, // Key expected by backend for updates (likely 'preferredServices' per CustomerProfile)
      'isTwoFactorEnabled':
          twoFactorEnabled, // Key expected by backend for updates (likely 'isTwoFactorEnabled' per CustomerProfile)
      'registeredAt': registrationDate
          .toIso8601String(), // Key expected by backend for updates (likely 'registeredAt' per CustomerProfile)
    };
  }
}

// Optional: Extension for easy updates (helpful for updating local state/cache after an API call)
extension UserExtension on User {
  User copyWith({
    String? fullName,
    String? phone,
    String? address,
    String? profilePictureUrl,
    List<String>? preferredServices,
    bool? twoFactorEnabled,
  }) {
    return User(
      id: this.id,
      fullName: fullName ?? this.fullName,
      email: this.email, // Email typically doesn't change via this method
      phone: phone ?? this.phone, // Use provided phone or keep existing
      address: address ?? this.address,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      preferredServices: preferredServices ?? this.preferredServices,
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
      registrationDate:
          this.registrationDate, // Registration date doesn't change
    );
  }
}
