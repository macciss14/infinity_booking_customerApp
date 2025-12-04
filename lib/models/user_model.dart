// models/user_model.dart
import '../utils/constants.dart'; // Add this import

class UserModel {
  final String id;
  final String fullname;
  final String email;
  final String phonenumber;
  final String? profilephoto;
  final String? address;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? customerProfileId; // Add this to store the nested ID

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
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Extract user ID from top-level (this is what you should use for /users/{id})
    final userId = (json['_id'] ?? json['id'] ?? '').toString();

    // Extract customer profile ID if exists
    String? customerProfileId;
    Map<String, dynamic> userData = json;

    if (json.containsKey('customerProfile') && json['customerProfile'] is Map) {
      final customerProfile =
          Map<String, dynamic>.from(json['customerProfile']);
      customerProfileId = customerProfile['_id']?.toString();

      // Merge customer profile data with top-level data
      userData = {
        ...customerProfile,
        // Keep top-level fields that might not be in customerProfile
        'profilePhoto': json['profilePhoto'] ?? customerProfile['profilePhoto'],
        'email': json['email'] ?? customerProfile['email'],
      };
    }

    return UserModel(
      id: userId, // Use top-level user ID for API calls
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
          ? DateTime.tryParse(userData['createdAt'].toString()) ??
              DateTime.now()
          : DateTime.now(),
      updatedAt: userData['updatedAt'] != null
          ? DateTime.tryParse(userData['updatedAt'].toString())
          : null,
      customerProfileId: customerProfileId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullname': fullname,
      'email': email,
      'phonenumber': phonenumber,
      'profilephoto': profilephoto,
      'address': address,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'customerProfileId': customerProfileId,
    };
  }

  UserModel copyWith({
    String? id,
    String? fullname,
    String? email,
    String? phonenumber,
    String? profilephoto,
    String? address,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? customerProfileId,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullname: fullname ?? this.fullname,
      email: email ?? this.email,
      phonenumber: phonenumber ?? this.phonenumber,
      profilephoto: profilephoto ?? this.profilephoto,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      customerProfileId: customerProfileId ?? this.customerProfileId,
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

  @override
  String toString() {
    return 'UserModel(id: $id, fullname: $fullname, email: $email, phonenumber: $phonenumber, profilephoto: $profilephoto, address: $address, customerProfileId: $customerProfileId)';
  }
}
