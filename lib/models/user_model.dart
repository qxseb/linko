enum UserRole { requester, volunteer }

class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? phone;
  final String? address;
  final bool isVerified;
  final int completedTasks;
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
    required this.createdAt,
    this.lastActive,
    this.avgResponseMinutes,
  });

  String get trustLevel {
    if (completedTasks == 0) return 'Nou';
    if (completedTasks < 5) return 'Activ';
    return 'De încredere';
  }

  String get lastActiveLabel {
    if (lastActive == null) return 'Înregistrat recent';
    final diff = DateTime.now().difference(lastActive!);
    if (diff.inMinutes < 60) return 'Activ acum';
    if (diff.inHours < 24) return 'Activ azi';
    if (diff.inDays == 1) return 'Activ ieri';
    if (diff.inDays < 7) return 'Activ săptămâna asta';
    return 'Activ acum ${diff.inDays} zile';
  }

  String get responseTimeLabel {
    if (avgResponseMinutes == null) return 'Voluntar nou';
    if (avgResponseMinutes! < 15) return 'Răspunde rapid';
    if (avgResponseMinutes! < 60) return 'Răspunde în max 1h';
    return 'Răspunde în aceeași zi';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role.name,
        'phone': phone,
        'address': address,
        'isVerified': isVerified,
        'completedTasks': completedTasks,
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
        completedTasks: json['completedTasks'] ?? 0,
        createdAt: DateTime.parse(json['createdAt']),
        lastActive: json['lastActive'] != null
            ? DateTime.parse(json['lastActive'])
            : null,
        avgResponseMinutes: json['avgResponseMinutes'],
      );
}
