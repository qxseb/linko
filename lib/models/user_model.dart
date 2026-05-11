enum UserRole { requester, volunteer }

class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? phone;
  final String? address;
  final bool isVerified;

  final DateTime createdAt;
  final DateTime? lastActive;
  final int? avgResponseMinutes;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.address,
    this.isVerified = false,
    this.completedTasks = 0,
    this.completedRequests = 0,
    required this.createdAt,
    this.lastActive,
    this.avgResponseMinutes,
  });

  String get trustLevel {
    final count =
        role == UserRole.volunteer ? completedTasks : completedRequests;
    if (count == 0) return 'New';
    if (count < 5) return 'Active';
    return 'Trusted';
  }

  String get lastActiveText {
    if (lastActive == null) return 'Joined recently';
    final diff = DateTime.now().difference(lastActive!);
    if (diff.inMinutes < 60) return 'Active now';
    if (diff.inHours < 24) return 'Active today';
    if (diff.inDays == 1) return 'Active yesterday';
    if (diff.inDays < 7) return 'Active this week';
    return 'Active ${diff.inDays} days ago';
  }

  String get responseTimeText {
    if (avgResponseMinutes == null) return 'New volunteer';
    if (avgResponseMinutes! < 15) return 'Responds quickly';
    if (avgResponseMinutes! < 60) return 'Responds within 1h';
    return 'Responds the same day';
  }

  String get trustLevelLabel => trustLevel;
  String get lastActiveLabel => lastActiveText;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role.name,
        'phone': phone,
        'address': address,
        'isVerified': isVerified,
        'completedTasks': completedTasks,
        'completedRequests': completedRequests,
        'createdAt': createdAt.toIso8601String(),
        'lastActive': lastActive?.toIso8601String(),
        'avgResponseMinutes': avgResponseMinutes,
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        role: UserRole.values.firstWhere((e) => e.name == json['role']),
        phone: json['phone'],
        address: json['address'],
        isVerified: json['isVerified'] ?? false,
        completedTasks: (json['completedTasks'] as num?)?.toInt() ?? 0,
        completedRequests: (json['completedRequests'] as num?)?.toInt() ?? 0,
        createdAt: DateTime.parse(json['createdAt']),
        lastActive: json['lastActive'] != null
            ? DateTime.parse(json['lastActive'])
            : null,
        avgResponseMinutes: json['avgResponseMinutes'] is num
            ? (json['avgResponseMinutes'] as num).toInt()
            : null,
      );
}
