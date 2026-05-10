import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../models/request_model.dart';
import '../models/message_model.dart';
import '../models/notification_model.dart';

class MockDataService {
  static const _uuid = Uuid();

  static User createMockRequester() {
    return User(
      id: 'user_req_1',
      name: 'Maria Popescu',
      email: 'maria.popescu@email.com',
      role: UserRole.requester,
      phone: '+40 722 123 456',
      address: 'Str. Mihai Bravu nr. 23, București',
      isVerified: true,
      completedTasks: 3,
      createdAt: DateTime.now().subtract(const Duration(days: 47)),
      lastActive:
          DateTime.now().subtract(const Duration(hours: 2, minutes: 13)),
    );
  }

  static User createMockVolunteer() {
    return User(
      id: 'user_vol_1',
      name: 'Andrei Ionescu',
      email: 'andrei.ionescu@email.com',
      role: UserRole.volunteer,
      phone: '+40 733 456 789',
      address: 'Str. Victoriei nr. 45, București',
      isVerified: true,
      completedTasks: 12,
      createdAt: DateTime.now().subtract(const Duration(days: 93)),
      lastActive: DateTime.now().subtract(const Duration(minutes: 17)),
      avgResponseMinutes: 14,
    );
  }

  static Map<String, User> getMockUsers() {
    final now = DateTime.now();
    return {
      'user_req_1': User(
        id: 'user_req_1',
        name: 'Maria Popescu (78 years old)',
        email: 'maria.popescu@email.com',
        role: UserRole.requester,
        phone: '+40 722 123 456',
        address: 'Str. Mihai Bravu nr. 23, București',
        isVerified: true,
        completedTasks: 3,
        createdAt: now.subtract(const Duration(days: 47)),
        lastActive: now.subtract(const Duration(hours: 2, minutes: 13)),
      ),
      'user_req_2': User(
        id: 'user_req_2',
        name: 'Ion Dumitrescu - 72 years old',
        email: 'ion.dumitrescu@email.com',
        role: UserRole.requester,
        phone: '+40 744 567 890',
        address: 'Str. Dorobanți nr. 12, București',
        isVerified: true,
        completedTasks: 8,
        createdAt: now.subtract(const Duration(days: 118)),
        lastActive: now.subtract(const Duration(minutes: 11)),
      ),
      'user_req_3': User(
        id: 'user_req_3',
        name: 'Elena Radu',
        email: 'elena.radu@email.com',
        role: UserRole.requester,
        phone: '+40 755 678 901',
        address: 'Str. Florilor nr. 45, București',
        isVerified: false,
        completedTasks: 0,
        createdAt: now.subtract(const Duration(days: 6)),
        lastActive: now.subtract(const Duration(minutes: 23)),
      ),
      'user_req_4': User(
        id: 'user_req_4',
        name: 'Vasile Popa, 45 years old',
        email: 'vasile.popa@email.com',
        role: UserRole.requester,
        phone: '+40 766 789 012',
        address: 'Str. Libertății nr. 78, București',
        isVerified: true,
        completedTasks: 2,
        createdAt: now.subtract(const Duration(days: 31)),
        lastActive: now.subtract(const Duration(hours: 3, minutes: 47)),
      ),
      'user_vol_1': User(
        id: 'user_vol_1',
        name: 'Andrei Ionescu',
        email: 'andrei.ionescu@email.com',
        role: UserRole.volunteer,
        phone: '+40 733 456 789',
        address: 'Str. Victoriei nr. 45, București',
        isVerified: true,
        completedTasks: 12,
        createdAt: now.subtract(const Duration(days: 93)),
        lastActive: now.subtract(const Duration(minutes: 17)),
        avgResponseMinutes: 14,
      ),
      'user_vol_2': User(
        id: 'user_vol_2',
        name: 'Ana Gheorghe',
        email: 'ana.gheorghe@email.com',
        role: UserRole.volunteer,
        phone: '+40 777 890 123',
        address: 'Str. Unirii nr. 34, București',
        isVerified: true,
        completedTasks: 7,
        createdAt: now.subtract(const Duration(days: 62)),
        lastActive: now.subtract(const Duration(hours: 1, minutes: 8)),
        avgResponseMinutes: 23,
      ),
    };
  }

  static User? getUserById(String userId) {
    return getMockUsers()[userId];
  }

  static List<Request> getMockRequests() {
    final now = DateTime.now();
    return [
      Request(
        id: 'req_completed_1',
        requesterId: 'user_req_1',
        requesterName: 'Maria Popescu (78 years old)',
        category: RequestCategory.pharmacy,
        description: 'Blood pressure medication',
        urgency: RequestUrgency.medium,
        location: 'Farmacia Catena (0.5 km)',
        preferredTime: now.subtract(const Duration(days: 25)),
        status: RequestStatus.completed,
        volunteerId: 'user_vol_1',
        volunteerName: 'Andrei Ionescu',
        createdAt: now.subtract(const Duration(days: 26)),
        completedAt: now.subtract(const Duration(days: 25, hours: 2)),
      ),
      Request(
        id: 'req_completed_2',
        requesterId: 'user_req_2',
        requesterName: 'Ion Dumitrescu - 72 years old',
        category: RequestCategory.groceries,
        description: 'Bread, milk, cheese',
        urgency: RequestUrgency.low,
        location: 'Mega Image (0.8 km)',
        preferredTime: now.subtract(const Duration(days: 20)),
        status: RequestStatus.completed,
        volunteerId: 'user_vol_1',
        volunteerName: 'Andrei Ionescu',
        createdAt: now.subtract(const Duration(days: 21)),
        completedAt: now.subtract(const Duration(days: 20, hours: 1)),
      ),
      Request(
        id: 'req_completed_3',
        requesterId: 'user_req_1',
        requesterName: 'Maria Popescu (78 years old)',
        category: RequestCategory.checkIn,
        description: 'Check-in - not answering the phone',
        urgency: RequestUrgency.high,
        location: 'Str. Mihai Bravu nr. 23 (0.3 km)',
        preferredTime: now.subtract(const Duration(days: 18)),
        status: RequestStatus.completed,
        volunteerId: 'user_vol_1',
        volunteerName: 'Andrei Ionescu',
        createdAt: now.subtract(const Duration(days: 18, hours: 2)),
        completedAt: now.subtract(const Duration(days: 18, hours: 1)),
      ),
      Request(
        id: 'req_completed_4',
        requesterId: 'user_req_4',
        requesterName: 'Vasile Popa, 45 years old',
        category: RequestCategory.errands,
        description: 'Pay bills at the counter',
        urgency: RequestUrgency.medium,
        location: 'Oficiul Poștal (1.5 km)',
        preferredTime: now.subtract(const Duration(days: 15)),
        status: RequestStatus.completed,
        volunteerId: 'user_vol_1',
        volunteerName: 'Andrei Ionescu',
        createdAt: now.subtract(const Duration(days: 16)),
        completedAt: now.subtract(const Duration(days: 15, hours: 3)),
      ),
      Request(
        id: 'req_completed_5',
        requesterId: 'user_req_2',
        requesterName: 'Ion Dumitrescu - 72 years old',
        category: RequestCategory.pharmacy,
        description: 'Insulin and diabetes medication',
        urgency: RequestUrgency.high,
        location: 'Farmacia Sensiblu (1.2 km)',
        preferredTime: now.subtract(const Duration(days: 12)),
        status: RequestStatus.completed,
        volunteerId: 'user_vol_1',
        volunteerName: 'Andrei Ionescu',
        createdAt: now.subtract(const Duration(days: 13)),
        completedAt: now.subtract(const Duration(days: 12, hours: 2)),
      ),
      Request(
        id: 'req_completed_6',
        requesterId: 'user_req_1',
        requesterName: 'Maria Popescu (78 years old)',
        category: RequestCategory.groceries,
        description: 'Weekly groceries',
        urgency: RequestUrgency.medium,
        location: 'Carrefour Express (0.6 km)',
        preferredTime: now.subtract(const Duration(days: 10)),
        status: RequestStatus.completed,
        volunteerId: 'user_vol_1',
        volunteerName: 'Andrei Ionescu',
        createdAt: now.subtract(const Duration(days: 11)),
        completedAt: now.subtract(const Duration(days: 10, hours: 1)),
      ),
      Request(
        id: 'req_completed_7',
        requesterId: 'user_req_4',
        requesterName: 'Vasile Popa, 45 years old',
        category: RequestCategory.checkIn,
        description: 'Health check-in',
        urgency: RequestUrgency.medium,
        location: 'Str. Libertății nr. 78 (1.5 km)',
        preferredTime: now.subtract(const Duration(days: 8)),
        status: RequestStatus.completed,
        volunteerId: 'user_vol_1',
        volunteerName: 'Andrei Ionescu',
        createdAt: now.subtract(const Duration(days: 9)),
        completedAt: now.subtract(const Duration(days: 8, hours: 2)),
      ),
      Request(
        id: 'req_completed_8',
        requesterId: 'user_req_2',
        requesterName: 'Ion Dumitrescu - 72 years old',
        category: RequestCategory.groceries,
        description: 'demo_fresh_food_description',
        urgency: RequestUrgency.low,
        location: 'Piața Obor (2 km)',
        preferredTime: now.subtract(const Duration(days: 6)),
        status: RequestStatus.completed,
        volunteerId: 'user_vol_1',
        volunteerName: 'Andrei Ionescu',
        createdAt: now.subtract(const Duration(days: 7)),
        completedAt: now.subtract(const Duration(days: 6, hours: 3)),
      ),
      Request(
        id: 'req_completed_9',
        requesterId: 'user_req_1',
        requesterName: 'Maria Popescu (78 years old)',
        category: RequestCategory.pharmacy,
        description: 'demo_vitamins_description',
        urgency: RequestUrgency.low,
        location: 'Farmacia Helpnet (0.4 km)',
        preferredTime: now.subtract(const Duration(days: 4)),
        status: RequestStatus.completed,
        volunteerId: 'user_vol_1',
        volunteerName: 'Andrei Ionescu',
        createdAt: now.subtract(const Duration(days: 5)),
        completedAt: now.subtract(const Duration(days: 4, hours: 1)),
      ),
      Request(
        id: 'req_completed_10',
        requesterId: 'user_req_4',
        requesterName: 'Vasile Popa, 45 years old',
        category: RequestCategory.errands,
        description: 'demo_post_office_description',
        urgency: RequestUrgency.medium,
        location: 'Oficiul Poștal 2 (1.8 km)',
        preferredTime: now.subtract(const Duration(days: 3)),
        status: RequestStatus.completed,
        volunteerId: 'user_vol_1',
        volunteerName: 'Andrei Ionescu',
        createdAt: now.subtract(const Duration(days: 4)),
        completedAt: now.subtract(const Duration(days: 3, hours: 2)),
      ),
      Request(
        id: 'req_completed_11',
        requesterId: 'user_req_2',
        requesterName: 'Ion Dumitrescu - 72 years old',
        category: RequestCategory.checkIn,
        description: 'demo_post_surgery_description',
        urgency: RequestUrgency.high,
        location: 'Str. Dorobanți nr. 12 (0.8 km)',
        preferredTime: now.subtract(const Duration(days: 2)),
        status: RequestStatus.completed,
        volunteerId: 'user_vol_1',
        volunteerName: 'Andrei Ionescu',
        createdAt: now.subtract(const Duration(days: 2, hours: 3)),
        completedAt: now.subtract(const Duration(days: 2, hours: 1)),
      ),
      Request(
        id: 'req_completed_12',
        requesterId: 'user_req_1',
        requesterName: 'Maria Popescu (78 years old)',
        category: RequestCategory.groceries,
        description: 'Bread and dairy products',
        urgency: RequestUrgency.medium,
        location: 'Mega Image (0.3 km)',
        preferredTime: now.subtract(const Duration(days: 1)),
        status: RequestStatus.completed,
        volunteerId: 'user_vol_1',
        volunteerName: 'Andrei Ionescu',
        createdAt: now.subtract(const Duration(days: 1, hours: 5)),
        completedAt: now.subtract(const Duration(days: 1, hours: 3)),
      ),
      Request(
        id: 'req_1',
        requesterId: 'user_req_2',
        requesterName: 'Ion Dumitrescu - 72 years old',
        category: RequestCategory.pharmacy,
        description:
            'I need insulin before 6 PM. I am diabetic and cannot go to the pharmacy alone. The prescription is ready and paid.',
        urgency: RequestUrgency.high,
        location: 'Catena Pharmacy, Dorobanți Street no. 15 (0.8 km)',
        preferredTime: now.add(const Duration(hours: 2, minutes: 7)),
        status: RequestStatus.open,
        createdAt: now.subtract(const Duration(minutes: 9)),
      ),
      Request(
        id: 'req_2',
        requesterId: 'user_req_3',
        requesterName: 'Elena Radu',
        category: RequestCategory.checkIn,
        description:
            'My grandmother, Maria, is 82 and has not answered the phone for two days. I am worried. Could someone knock on her door?',
        urgency: RequestUrgency.high,
        location: 'Str. Florilor nr. 45, Ap. 2B (1.2 km)',
        preferredTime: now.add(const Duration(minutes: 33)),
        status: RequestStatus.open,
        createdAt: now.subtract(const Duration(minutes: 19)),
        isProxy: true,
        proxyForName: 'Maria Radu',
        proxyRelationship: 'Grandmother',
        proxyNotes: 'Hard of hearing - please knock loudly',
      ),
      Request(
        id: 'req_3',
        requesterId: 'user_req_1',
        requesterName: 'Maria Popescu (78 years old)',
        category: RequestCategory.groceries,
        description:
            'I need bread, milk, and eggs. I cannot carry heavy bags up the stairs anymore.',
        urgency: RequestUrgency.medium,
        location: 'Mega Image, Str. Mihai Bravu (0.3 km)',
        preferredTime: now.add(const Duration(hours: 3, minutes: 12)),
        status: RequestStatus.accepted,
        volunteerId: 'user_vol_1',
        volunteerName: 'Andrei Ionescu',
        createdAt: now.subtract(const Duration(hours: 1, minutes: 18)),
      ),
      Request(
        id: 'req_4',
        requesterId: 'user_req_4',
        requesterName: 'Vasile Popa, 45 years old',
        category: RequestCategory.errands,
        description:
            'My father is 78 and needs to take a parcel to the post office, but he cannot go alone. The parcel is ready.',
        urgency: RequestUrgency.low,
        location: 'Post Office 1 (1.5 km)',
        preferredTime: now.add(const Duration(days: 1, minutes: 23)),
        status: RequestStatus.open,
        createdAt: now.subtract(const Duration(hours: 2, minutes: 54)),
        isProxy: true,
        proxyForName: 'Vasile Popa Sr.',
        proxyRelationship: 'Father',
        proxyNotes: 'The parcel is ready by the door',
      ),
      Request(
        id: 'req_5',
        requesterId: 'user_req_1',
        requesterName: 'Maria Popescu (78 years old)',
        category: RequestCategory.pharmacy,
        description:
            'I need this week’s medication. The prescription is ready at the pharmacy.',
        urgency: RequestUrgency.medium,
        location: 'Sensiblu, Unirii Square',
        preferredTime: now.subtract(const Duration(days: 2, minutes: 17)),
        status: RequestStatus.completed,
        volunteerId: 'user_vol_2',
        volunteerName: 'Ana Gheorghe',
        createdAt: now.subtract(const Duration(days: 3, minutes: 8)),
        completedAt: now.subtract(const Duration(days: 2, minutes: 3)),
      ),
    ];
  }

  static List<Message> getMockMessages(String requestId) {
    final now = DateTime.now();

    switch (requestId) {
      case 'req_1':
        return [];

      case 'req_2':
        return [];

      case 'req_3':
        return [
          Message(
            id: 'msg_req3_system1',
            requestId: requestId,
            senderId: 'system',
            senderName: 'System',
            content: 'request_accepted',
            timestamp: now.subtract(const Duration(minutes: 49)),
            isRead: true,
            isSystemMessage: true,
          ),
          Message(
            id: 'msg_req3_1',
            requestId: requestId,
            senderId: 'user_req_1',
            senderName: 'Maria Popescu (78 years old)',
            content: 'Hi Andrei! Thank you so much for choosing me.',
            timestamp: now.subtract(const Duration(minutes: 47)),
            isRead: true,
          ),
          Message(
            id: 'msg_req3_2',
            requestId: requestId,
            senderId: 'user_vol_1',
            senderName: 'Andrei Ionescu',
            content:
                'Gladly. I will arrive around 6:30 PM. What kind of bread would you like?',
            timestamp: now.subtract(const Duration(minutes: 43)),
            isRead: true,
          ),
          Message(
            id: 'msg_req3_3',
            requestId: requestId,
            senderId: 'user_req_1',
            senderName: 'Maria Popescu',
            content:
                'White bread, a box of 10 eggs, and 1.5% milk. I will leave the money by the door.',
            timestamp: now.subtract(const Duration(minutes: 39)),
            isRead: true,
          ),
          Message(
            id: 'msg_req3_4',
            requestId: requestId,
            senderId: 'user_vol_1',
            senderName: 'Andrei Ionescu',
            content: 'Got it. See you then.',
            timestamp: now.subtract(const Duration(minutes: 37)),
            isRead: true,
          ),
          Message(
            id: 'msg_req3_5',
            requestId: requestId,
            senderId: 'user_req_1',
            senderName: 'Maria Popescu',
            content: 'Thank you so much. I am home.',
            timestamp: now.subtract(const Duration(minutes: 34)),
            isRead: true,
          ),
        ];

      case 'req_4':
        return [];

      case 'req_5':
        return [
          Message(
            id: 'msg_req5_system1',
            requestId: requestId,
            senderId: 'system',
            senderName: 'System',
            content: 'request_accepted',
            timestamp:
                now.subtract(const Duration(days: 2, hours: 3, minutes: 7)),
            isRead: true,
            isSystemMessage: true,
          ),
          Message(
            id: 'msg_req5_1',
            requestId: requestId,
            senderId: 'user_req_1',
            senderName: 'Maria Popescu',
            content: 'Hi Ana. The prescription is under my name, Maria Popescu.',
            timestamp:
                now.subtract(const Duration(days: 2, hours: 3, minutes: 2)),
            isRead: true,
          ),
          Message(
            id: 'msg_req5_system2',
            requestId: requestId,
            senderId: 'system',
            senderName: 'System',
            content: 'request_in_progress',
            timestamp:
                now.subtract(const Duration(days: 2, hours: 2, minutes: 53)),
            isRead: true,
            isSystemMessage: true,
          ),
          Message(
            id: 'msg_req5_2',
            requestId: requestId,
            senderId: 'user_vol_2',
            senderName: 'Ana Gheorghe',
            content:
                'Hello. I have reached the pharmacy. About how long should I expect to wait?',
            timestamp:
                now.subtract(const Duration(days: 2, hours: 2, minutes: 48)),
            isRead: true,
          ),
          Message(
            id: 'msg_req5_3',
            requestId: requestId,
            senderId: 'user_req_1',
            senderName: 'Maria Popescu (78 years old)',
            content: 'Usually 10 to 15 minutes. I am sorry about the wait.',
            timestamp:
                now.subtract(const Duration(days: 2, hours: 2, minutes: 41)),
            isRead: true,
          ),
          Message(
            id: 'msg_req5_4',
            requestId: requestId,
            senderId: 'user_vol_2',
            senderName: 'Ana Gheorghe',
            content:
                'No problem. I picked up the medication and I am heading to you now.',
            timestamp:
                now.subtract(const Duration(days: 2, hours: 2, minutes: 27)),
            isRead: true,
          ),
          Message(
            id: 'msg_req5_5',
            requestId: requestId,
            senderId: 'user_req_1',
            senderName: 'Maria Popescu (78 years old)',
            content: 'Great, I will wait for you. Thank you so much.',
            timestamp:
                now.subtract(const Duration(days: 2, hours: 2, minutes: 22)),
            isRead: true,
          ),
          Message(
            id: 'msg_req5_6',
            requestId: requestId,
            senderId: 'user_vol_2',
            senderName: 'Ana Gheorghe',
            content: 'I arrived. I am at the door.',
            timestamp:
                now.subtract(const Duration(days: 2, hours: 2, minutes: 4)),
            isRead: true,
          ),
          Message(
            id: 'msg_req5_system3',
            requestId: requestId,
            senderId: 'system',
            senderName: 'System',
            content: 'request_completed',
            timestamp:
                now.subtract(const Duration(days: 2, hours: 1, minutes: 58)),
            isRead: true,
            isSystemMessage: true,
          ),
        ];

      default:
        return [];
    }
  }

  static Message generateRequesterResponseMessage(
    Request request,
    String volunteerId,
    String volunteerName,
  ) {
    final now = DateTime.now();
    String content;

    switch (request.category) {
      case RequestCategory.pharmacy:
        if (request.urgency == RequestUrgency.high) {
          content =
              'Thank you so much for choosing me. I really need this urgently, and the prescription is ready and paid at the pharmacy.';
        } else {
          content =
              'Thank you so much. The prescription is under my name, ${request.requesterName.split(',').first.split('(').first.trim()}. I will wait to hear from you.';
        }
        break;
      case RequestCategory.checkIn:
        if (request.isProxy) {
          content =
              'Thank you from the heart. I am very worried about her. She is on the ground floor, apartment 2B. Please knock loudly because she does not hear well.';
        } else {
          content = 'Thank you so much. I am home all day and waiting.';
        }
        break;
      case RequestCategory.groceries:
        content =
            'Thank you for accepting. I will leave the money by the door.';
        break;
      case RequestCategory.errands:
        if (request.isProxy) {
          content =
              'Thank you so much for helping. The parcel is ready by the door. It is about 5 kg, and my father will be very grateful.';
        } else {
          content = 'Great, thank you. Everything is ready and I will wait for you.';
        }
        break;
    }

    return Message(
      id: generateId(),
      requestId: request.id,
      senderId: request.requesterId,
      senderName: request.requesterName,
      content: content,
      timestamp: now,
      isRead: false,
    );
  }

  static Message generateInitialMessage(
    Request request,
    String volunteerId,
    String volunteerName,
  ) {
    final now = DateTime.now();
    String content;

    switch (request.category) {
      case RequestCategory.pharmacy:
        if (request.urgency == RequestUrgency.high) {
          content =
              'Perfect. I will reach the pharmacy in 10 minutes and message you once I pick it up.';
        } else {
          content =
              'Okay. I will stop by soon and message you once I pick up the medication.';
        }
        break;
      case RequestCategory.checkIn:
        if (request.isProxy) {
          content = 'I understand. I am leaving now and will be there in 5 minutes.';
        } else {
          content =
              'Perfect. I will check right away and message you when I arrive.';
        }
        break;
      case RequestCategory.groceries:
        content =
            'Perfect. What kind of bread would you like? And which milk: 1.5% or 3.5%?';
        break;
      case RequestCategory.errands:
        if (request.isProxy) {
          content =
              'No problem. I can carry more than that. Could I stop by tomorrow morning around 10?';
        } else {
          content = 'Okay. When would be the best time to stop by?';
        }
        break;
    }

    return Message(
      id: generateId(),
      requestId: request.id,
      senderId: volunteerId,
      senderName: volunteerName,
      content: content,
      timestamp: now,
      isRead: false,
    );
  }

  static Message generateSystemMessage(
    String requestId,
    String content,
  ) {
    return Message(
      id: generateId(),
      requestId: requestId,
      senderId: 'system',
      senderName: 'System',
      content: content,
      timestamp: DateTime.now(),
      isRead: true,
      isSystemMessage: true,
    );
  }

  static List<AppNotification> getMockNotifications(String userId) {
    final now = DateTime.now();
    return [
      AppNotification(
        id: 'notif_1',
        userId: userId,
        type: NotificationType.requestAccepted,
        title: 'Request accepted',
        message: 'Andrei accepted your request',
        requestId: 'req_3',
        timestamp: now.subtract(const Duration(hours: 1)),
        isRead: false,
      ),
      AppNotification(
        id: 'notif_2',
        userId: userId,
        type: NotificationType.newMessage,
        title: 'New message',
        message: 'Andrei: Gladly. I will arrive around 2 PM',
        requestId: 'req_3',
        timestamp: now.subtract(const Duration(minutes: 40)),
        isRead: false,
      ),
      AppNotification(
        id: 'notif_3',
        userId: userId,
        type: NotificationType.requestCompleted,
        title: 'Gata!',
        message: 'The medication has been picked up',
        requestId: 'req_5',
        timestamp: now.subtract(const Duration(days: 2)),
        isRead: true,
      ),
    ];
  }

  static String generateId() => _uuid.v4();
}

