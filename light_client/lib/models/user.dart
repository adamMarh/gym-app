enum UserRole { client, staff, admin }

class User {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final UserRole role;
  final String membershipTier;
  final DateTime membershipExpiry;
  final String? phone;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.role,
    this.membershipTier = 'Standard',
    required this.membershipExpiry,
    this.phone,
  });

  bool get isAdmin => role == UserRole.admin;
  bool get isStaff => role == UserRole.staff || role == UserRole.admin;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: (json['avatarUrl'] as String?)?.isEmpty == true
          ? null
          : json['avatarUrl'] as String?,
      role: _parseRole(json['role'] as String),
      membershipTier: json['membershipTier'] as String? ?? 'Standard',
      membershipExpiry: DateTime.parse(json['membershipExpiry'] as String),
      phone: (json['phone'] as String?)?.isEmpty == true
          ? null
          : json['phone'] as String?,
    );
  }

  static UserRole _parseRole(String role) {
    switch (role) {
      case 'admin':
        return UserRole.admin;
      case 'staff':
        return UserRole.staff;
      default:
        return UserRole.client;
    }
  }

  User copyWith({
    String? name,
    String? email,
    String? avatarUrl,
    String? membershipTier,
    DateTime? membershipExpiry,
    String? phone,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role,
      membershipTier: membershipTier ?? this.membershipTier,
      membershipExpiry: membershipExpiry ?? this.membershipExpiry,
      phone: phone ?? this.phone,
    );
  }
}
