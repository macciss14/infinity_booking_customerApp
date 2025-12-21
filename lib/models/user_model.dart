import 'package:infinity_booking_customerApp/utils/constants.dart';

class UserModel {
  final String id;
  final String fullname;
  final String email;
  final String phonenumber;
  final String? profilephoto;
  final String? address;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? customerProfileId;
  final String? pid;
  final String? role;
  final bool? isActive;
  final bool? isVerified;
  final String? authToken;

  UserModel({
    required this.id,
    required this.fullname,
    required this.email,
    required this.phonenumber,
    this.profilephoto,
    this.address,
    required this.createdAt,
    this.updatedAt,
    this.customerProfileId,
    this.pid,
    this.role,
    this.isActive,
    this.isVerified,
    this.authToken,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Extract user ID from top-level
    final userId = (json['_id'] ?? json['id'] ?? '').toString();

    // Extract customer profile ID if exists
    String? customerProfileId;
    Map<String, dynamic> userData = json;

    if (json.containsKey('customerProfile') && json['customerProfile'] is Map) {
      final customerProfile = Map<String, dynamic>.from(json['customerProfile']);
      customerProfileId = customerProfile['_id']?.toString();

      // Merge customer profile data with top-level data
      userData = {
        ...customerProfile,
        'profilePhoto': json['profilePhoto'] ?? customerProfile['profilePhoto'],
        'email': json['email'] ?? customerProfile['email'],
      };
    }

    return UserModel(
      id: userId,
      pid: json['pid'],
      fullname: userData['fullname'] ?? userData['name'] ?? '',
      email: userData['email'] ?? '',
      phonenumber: userData['phonenumber'] ??
          userData['phone'] ??
          userData['phoneNumber'] ??
          '',
      profilephoto: json['profilePhoto'] ??
          userData['profilePhoto'] ??
          userData['profilephoto'] ??
          userData['profileImage'] ??
          userData['avatar'] ??
          userData['photo'] ??
          null,
      address: userData['address'] ?? userData['location'] ?? null,
      createdAt: userData['createdAt'] != null
          ? DateTime.tryParse(userData['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: userData['updatedAt'] != null
          ? DateTime.tryParse(userData['updatedAt'].toString())
          : null,
      customerProfileId: customerProfileId,
      role: json['role'] ?? 'customer',
      isActive: json['isActive'] ?? true,
      isVerified: json['isVerified'] ?? false,
      authToken: json['authToken'] ?? json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pid': pid,
      'fullname': fullname,
      'email': email,
      'phonenumber': phonenumber,
      'profilephoto': profilephoto,
      'address': address,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'customerProfileId': customerProfileId,
      'role': role,
      'isActive': isActive,
      'isVerified': isVerified,
    };
  }

  UserModel copyWith({
    String? id,
    String? pid,
    String? fullname,
    String? email,
    String? phonenumber,
    String? profilephoto,
    String? address,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? customerProfileId,
    String? role,
    bool? isActive,
    bool? isVerified,
    String? authToken,
  }) {
    return UserModel(
      id: id ?? this.id,
      pid: pid ?? this.pid,
      fullname: fullname ?? this.fullname,
      email: email ?? this.email,
      phonenumber: phonenumber ?? this.phonenumber,
      profilephoto: profilephoto ?? this.profilephoto,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      customerProfileId: customerProfileId ?? this.customerProfileId,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      authToken: authToken ?? this.authToken,
    );
  }

  // Helper method to get complete profile photo URL
  String get completeProfilePhotoUrl {
    if (profilephoto == null || profilephoto!.isEmpty) return '';

    if (profilephoto!.startsWith('http')) {
      return profilephoto!;
    } else {
      // Handle relative paths
      String relativePath = profilephoto!;
      if (!relativePath.startsWith('/')) {
        relativePath = '/$relativePath';
      }
      return '${AppConstants.baseUrl}$relativePath';
    }
  }

  // Helper methods
  String get displayName => fullname.isNotEmpty ? fullname : email.split('@').first;

  bool get isCustomer => role == 'customer' || role == null;
  bool get isProvider => role == 'provider';
  bool get isAdmin => role == 'admin';

  String get initials {
    if (fullname.isNotEmpty) {
      final names = fullname.split(' ');
      final initials = names.map((n) => n.isNotEmpty ? n[0] : '').join('');
      return initials.toUpperCase().substring(0, initials.length > 2 ? 2 : 1);
    }
    return email.isNotEmpty ? email.substring(0, 1).toUpperCase() : 'U';
  }

  @override
  String toString() {
    return 'UserModel(id: $id, fullname: $fullname, email: $email, pid: $pid, role: $role)';
  }
}