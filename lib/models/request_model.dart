import '../utils/date_time_utils.dart';

enum RequestCategory { groceries, pharmacy, errands, checkIn }

enum RequestUrgency { low, medium, high }

enum RequestStatus { open, accepted, inProgress, completed, cancelled }

class Request {
  final String id;
  final String requesterId;
  final String requesterName;
  final RequestCategory category;
  final String description;
  final RequestUrgency urgency;
  final String location;
  final double? latitude;
  final double? longitude;
  final DateTime preferredTime;
  final RequestStatus status;
  final String? volunteerId;
  final String? volunteerName;
  final DateTime createdAt;
  final DateTime? completedAt;
  final bool isProxy;
  final String? proxyForName;
  final String? proxyRelationship;
  final String? proxyNotes;

  Request({
    required this.id,
    required this.requesterId,
    required this.requesterName,
    required this.category,
    required this.description,
    required this.urgency,
    required this.location,
    this.latitude,
    this.longitude,
    required this.preferredTime,
    this.status = RequestStatus.open,
    this.volunteerId,
    this.volunteerName,
    required this.createdAt,
    this.completedAt,
    this.isProxy = false,
    this.proxyForName,
    this.proxyRelationship,
    this.proxyNotes,
  });

  String get categoryLabel {
    switch (category) {
      case RequestCategory.groceries:
        return 'Groceries';
      case RequestCategory.pharmacy:
        return 'Pharmacy';
      case RequestCategory.errands:
        return 'Errands';
      case RequestCategory.checkIn:
        return 'Check-in';
    }
  }

  String get urgencyLabel {
    switch (urgency) {
      case RequestUrgency.low:
        return 'Low';
      case RequestUrgency.medium:
        return 'Medium';
      case RequestUrgency.high:
        return 'High';
    }
  }

  String get statusLabel {
    switch (status) {
      case RequestStatus.open:
        return 'Open';
      case RequestStatus.accepted:
        return 'Accepted';
      case RequestStatus.inProgress:
        return 'In progress';
      case RequestStatus.completed:
        return 'Completed';
      case RequestStatus.cancelled:
        return 'Cancelled';
    }
  }

  Request copyWith({
    RequestStatus? status,
    String? volunteerId,
    String? volunteerName,
    DateTime? completedAt,
    double? latitude,
    double? longitude,
  }) {
    return Request(
      id: id,
      requesterId: requesterId,
      requesterName: requesterName,
      category: category,
      description: description,
      urgency: urgency,
      location: location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      preferredTime: preferredTime,
      status: status ?? this.status,
      volunteerId: volunteerId ?? this.volunteerId,
      volunteerName: volunteerName ?? this.volunteerName,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
      isProxy: isProxy,
      proxyForName: proxyForName,
      proxyRelationship: proxyRelationship,
      proxyNotes: proxyNotes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'requesterId': requesterId,
        'requesterName': requesterName,
        'category': category.name,
        'description': description,
        'urgency': urgency.name,
        'location': location,
        'latitude': latitude,
        'longitude': longitude,
        'preferredTime': preferredTime.toIso8601String(),
        'status': status.name,
        'volunteerId': volunteerId,
        'volunteerName': volunteerName,
        'createdAt': createdAt.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'isProxy': isProxy,
        'proxyForName': proxyForName,
        'proxyRelationship': proxyRelationship,
        'proxyNotes': proxyNotes,
      };

  factory Request.fromJson(Map<String, dynamic> json) => Request(
        id: json['id'],
        requesterId: json['requesterId'],
        requesterName: json['requesterName'],
        category: RequestCategory.values.firstWhere(
          (e) => e.name == json['category'],
        ),
        description: json['description'],
        urgency:
            RequestUrgency.values.firstWhere((e) => e.name == json['urgency']),
        location: json['location'],
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        preferredTime:
            parseLocalDateTime(json['preferredTime']) ?? DateTime.now(),
        status:
            RequestStatus.values.firstWhere((e) => e.name == json['status']),
        volunteerId: json['volunteerId'],
        volunteerName: json['volunteerName'],
        createdAt: parseLocalDateTime(json['createdAt']) ?? DateTime.now(),
        completedAt: json['completedAt'] != null
            ? parseLocalDateTime(json['completedAt'])
            : null,
        isProxy: json['isProxy'] ?? false,
        proxyForName: json['proxyForName'],
        proxyRelationship: json['proxyRelationship'],
        proxyNotes: json['proxyNotes'],
      );
}
