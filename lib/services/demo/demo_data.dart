import '../../models/message_model.dart';
import '../../models/request_model.dart';
import '../../models/user_model.dart';

class DemoData {
  static const String demoPassword = 'parola123';

  static const String mariaId = 'demo_user_maria';
  static const String elenaId = 'demo_user_elena';
  static const String andreiId = 'demo_user_andrei';
  static const String ioanaId = 'demo_user_ioana';
  static const String vladId = 'demo_user_vlad';

  static List<User> users() {
    final now = DateTime.now();

    return [
      User(
        id: mariaId,
        name: 'Maria Ionescu',
        email: 'maria.ionescu@demo.linko',
        role: UserRole.requester,
        phone: '0722 104 889',
        isVerified: true,
        completedRequests: 1,
        createdAt: now.subtract(const Duration(days: 180)),
        lastActive: now.subtract(const Duration(minutes: 20)),
      ),
      User(
        id: elenaId,
        name: 'Elena Pop',
        email: 'elena.pop@demo.linko',
        role: UserRole.requester,
        phone: '0744 318 502',
        isVerified: true,
        completedRequests: 2,
        createdAt: now.subtract(const Duration(days: 220)),
        lastActive: now.subtract(const Duration(hours: 2)),
      ),
      User(
        id: andreiId,
        name: 'Andrei Dima',
        email: 'andrei.dima@demo.linko',
        role: UserRole.requester,
        phone: '0731 887 219',
        isVerified: true,
        completedRequests: 1,
        createdAt: now.subtract(const Duration(days: 140)),
        lastActive: now.subtract(const Duration(hours: 1)),
      ),
      User(
        id: ioanaId,
        name: 'Ioana Stan',
        email: 'ioana.stan@demo.linko',
        role: UserRole.volunteer,
        phone: '0756 220 144',
        isVerified: true,
        completedTasks: 3,
        avgResponseMinutes: 8,
        createdAt: now.subtract(const Duration(days: 300)),
        lastActive: now.subtract(const Duration(minutes: 5)),
      ),
      User(
        id: vladId,
        name: 'Vlad Marin',
        email: 'vlad.marin@demo.linko',
        role: UserRole.volunteer,
        phone: '0729 551 603',
        isVerified: true,
        completedTasks: 1,
        avgResponseMinutes: 12,
        createdAt: now.subtract(const Duration(days: 240)),
        lastActive: now.subtract(const Duration(minutes: 45)),
      ),
    ];
  }

  static List<Request> requests() {
    final now = DateTime.now();

    return [
      Request(
        id: 'demo_req_insulin',
        requesterId: mariaId,
        requesterName: 'Maria Ionescu',
        category: RequestCategory.pharmacy,
        description:
            'I ran out of insulin for tonight. Prescription is ready at Farmacia Tei.',
        urgency: RequestUrgency.high,
        location: 'Str. Baba Novac 18, Bucharest (1.2 km)',
        preferredTime: _atHour(now, 18),
        status: RequestStatus.open,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      Request(
        id: 'demo_req_errands_post',
        requesterId: mariaId,
        requesterName: 'Maria Ionescu',
        category: RequestCategory.errands,
        description:
            'Please pick up a registered letter from the post office tomorrow morning.',
        urgency: RequestUrgency.low,
        location: 'Piata Alba Iulia, Bucharest (1.6 km)',
        preferredTime: _atHour(now.add(const Duration(days: 2)), 11),
        status: RequestStatus.open,
        createdAt: now.subtract(const Duration(days: 1, hours: 1)),
      ),
      Request(
        id: 'demo_req_elena_groceries',
        requesterId: elenaId,
        requesterName: 'Elena Pop',
        category: RequestCategory.groceries,
        description: 'Bread, milk, eggs, and two yogurts. Nothing heavy.',
        urgency: RequestUrgency.medium,
        location: 'Calea Mosilor 221, Bucharest (900 m)',
        preferredTime: _atHour(now.add(const Duration(days: 1)), 10),
        status: RequestStatus.accepted,
        volunteerId: ioanaId,
        volunteerName: 'Ioana Stan',
        createdAt: now.subtract(const Duration(hours: 7)),
      ),
      Request(
        id: 'demo_req_checkin_father',
        requesterId: andreiId,
        requesterName: 'Andrei Dima',
        category: RequestCategory.checkIn,
        description:
            'My father is not answering. Please check he is okay and call me after.',
        urgency: RequestUrgency.high,
        location: 'Bd. Iuliu Maniu 59, Bucharest (2.8 km)',
        preferredTime: _atHour(now, 14),
        status: RequestStatus.inProgress,
        volunteerId: vladId,
        volunteerName: 'Vlad Marin',
        isProxy: true,
        proxyForName: 'Gheorghe Dima',
        proxyRelationship: 'father',
        proxyNotes: 'He is 76. Building manager knows him.',
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      Request(
        id: 'demo_req_maria_completed',
        requesterId: mariaId,
        requesterName: 'Maria Ionescu',
        category: RequestCategory.pharmacy,
        description: 'Weekly vitamins and supplements from nearby pharmacy.',
        urgency: RequestUrgency.low,
        location: 'Str. Unirii 8, Bucharest (0.8 km)',
        preferredTime: _atHour(now.subtract(const Duration(days: 8)), 11),
        status: RequestStatus.completed,
        volunteerId: ioanaId,
        volunteerName: 'Ioana Stan',
        createdAt: now.subtract(const Duration(days: 8, hours: 3)),
        completedAt: now.subtract(const Duration(days: 8, hours: 2)),
      ),
      Request(
        id: 'demo_req_elena_completed_2',
        requesterId: elenaId,
        requesterName: 'Elena Pop',
        category: RequestCategory.groceries,
        description: 'Small grocery run: bread and butter.',
        urgency: RequestUrgency.low,
        location: 'Mega Image, Calea Mosilor, Bucharest (0.5 km)',
        preferredTime: _atHour(now.subtract(const Duration(days: 15)), 10),
        status: RequestStatus.completed,
        volunteerId: ioanaId,
        volunteerName: 'Ioana Stan',
        createdAt: now.subtract(const Duration(days: 15, hours: 3)),
        completedAt: now.subtract(const Duration(days: 15, hours: 2)),
      ),
      Request(
        id: 'demo_req_andrei_completed',
        requesterId: andreiId,
        requesterName: 'Andrei Dima',
        category: RequestCategory.checkIn,
        description: 'Quick check-in visit for my elderly neighbor.',
        urgency: RequestUrgency.high,
        location: 'Str. Florilor 12, Bucharest (1.9 km)',
        preferredTime: _atHour(now.subtract(const Duration(days: 11)), 15),
        status: RequestStatus.completed,
        volunteerId: ioanaId,
        volunteerName: 'Ioana Stan',
        createdAt: now.subtract(const Duration(days: 11, hours: 2)),
        completedAt: now.subtract(const Duration(days: 11, hours: 1)),
      ),
      Request(
        id: 'demo_req_elena_completed',
        requesterId: elenaId,
        requesterName: 'Elena Pop',
        category: RequestCategory.pharmacy,
        description: 'Blood pressure medication pickup from local pharmacy.',
        urgency: RequestUrgency.medium,
        location: 'Sos. Stefan cel Mare 12, Bucharest (1.1 km)',
        preferredTime: _atHour(now.subtract(const Duration(days: 3)), 16),
        status: RequestStatus.completed,
        volunteerId: vladId,
        volunteerName: 'Vlad Marin',
        createdAt: now.subtract(const Duration(days: 3, hours: 4)),
        completedAt: now.subtract(const Duration(days: 3, hours: 3)),
      ),
    ];
  }

  static Map<String, List<Message>> messagesByRequest() {
    final now = DateTime.now();

    return {
      'demo_req_elena_groceries': [
        Message(
          id: 'demo_msg_1',
          requestId: 'demo_req_elena_groceries',
          senderId: 'system',
          senderName: 'System',
          content: 'Ioana Stan accepted the request.',
          timestamp: now.subtract(const Duration(hours: 6, minutes: 45)),
          isRead: true,
          isSystemMessage: true,
        ),
        Message(
          id: 'demo_msg_2',
          requestId: 'demo_req_elena_groceries',
          senderId: elenaId,
          senderName: 'Elena Pop',
          content: 'Thank you. Regular milk, not skimmed, if possible.',
          timestamp: now.subtract(const Duration(hours: 6, minutes: 40)),
          isRead: true,
        ),
        Message(
          id: 'demo_msg_3',
          requestId: 'demo_req_elena_groceries',
          senderId: ioanaId,
          senderName: 'Ioana Stan',
          content: 'Of course. I will text you when I leave the store.',
          timestamp: now.subtract(const Duration(hours: 6, minutes: 30)),
          isRead: true,
        ),
      ],
      'demo_req_checkin_father': [
        Message(
          id: 'demo_msg_4',
          requestId: 'demo_req_checkin_father',
          senderId: andreiId,
          senderName: 'Andrei Dima',
          content: 'Please ring once; he moves slowly to the door.',
          timestamp: now.subtract(const Duration(hours: 2, minutes: 20)),
          isRead: true,
        ),
        Message(
          id: 'demo_msg_5',
          requestId: 'demo_req_checkin_father',
          senderId: vladId,
          senderName: 'Vlad Marin',
          content: 'Understood. I am nearby and heading there now.',
          timestamp: now.subtract(const Duration(hours: 2, minutes: 10)),
          isRead: true,
        ),
      ],
    };
  }

  static DateTime _atHour(DateTime date, int hour) {
    return DateTime(date.year, date.month, date.day, hour);
  }
}
