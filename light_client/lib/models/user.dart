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

  static List<User> mockUsers = [
    User(
      id: 'u1',
      name: 'Alex Rivera',
      email: 'alex@example.com',
      role: UserRole.client,
      membershipTier: 'Elite',
      membershipExpiry: DateTime.now().add(const Duration(days: 90)),
    ),
    User(
      id: 'u2',
      name: 'Jordan Smith',
      email: 'jordan@example.com',
      role: UserRole.staff,
      membershipTier: 'Staff',
      membershipExpiry: DateTime.now().add(const Duration(days: 365)),
    ),
    User(
      id: 'u3',
      name: 'Sam Chen',
      email: 'sam@example.com',
      role: UserRole.admin,
      membershipTier: 'Admin',
      membershipExpiry: DateTime.now().add(const Duration(days: 365)),
    ),
  ];
}
