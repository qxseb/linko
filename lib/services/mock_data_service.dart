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
        name: 'Maria Popescu (78 ani)',
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
        name: 'Ion Dumitrescu - 72 ani',
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
        name: 'Vasile Popa, 45 ani',
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
        requesterName: 'Maria Popescu (78 ani)',
        category: RequestCategory.pharmacy,
        description: 'Medicamente pentru tensiune',
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
        requesterName: 'Ion Dumitrescu - 72 ani',
        category: RequestCategory.groceries,
        description: 'Pâine, lapte, brânză',
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
        requesterName: 'Maria Popescu (78 ani)',
        category: RequestCategory.checkIn,
        description: 'Verificare - nu răspunde la telefon',
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
        requesterName: 'Vasile Popa, 45 ani',
        category: RequestCategory.errands,
        description: 'Plată facturi la ghișeu',
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
        requesterName: 'Ion Dumitrescu - 72 ani',
        category: RequestCategory.pharmacy,
        description: 'Insulină și medicamente pentru diabet',
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
        requesterName: 'Maria Popescu (78 ani)',
        category: RequestCategory.groceries,
        description: 'Cumpărături săptămânale',
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
        requesterName: 'Vasile Popa, 45 ani',
        category: RequestCategory.checkIn,
        description: 'Verificare stare de sănătate',
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
        requesterName: 'Ion Dumitrescu - 72 ani',
        category: RequestCategory.groceries,
        description: 'Fructe și legume proaspete',
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
        requesterName: 'Maria Popescu (78 ani)',
        category: RequestCategory.pharmacy,
        description: 'Vitamine și suplimente',
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
        requesterName: 'Vasile Popa, 45 ani',
        category: RequestCategory.errands,
        description: 'Ridicare colet de la poștă',
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
        requesterName: 'Ion Dumitrescu - 72 ani',
        category: RequestCategory.checkIn,
        description: 'Verificare după operație',
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
        requesterName: 'Maria Popescu (78 ani)',
        category: RequestCategory.groceries,
        description: 'Pâine și produse lactate',
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
        requesterName: 'Ion Dumitrescu - 72 ani',
        category: RequestCategory.pharmacy,
        description:
            'Am nevoie de insulina pana la 18:00. Sunt diabetic si nu mai pot merge singur la farmacie, reteta e gata si platita',
        urgency: RequestUrgency.high,
        location: 'Farmacia Catena, Str. Dorobanți nr. 15 (0.8 km)',
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
            'Bunica mea (Maria, 82 ani) nu raspunde la telefon de 2 zile. Sunt ingrijorata.. poate trece cineva sa bata la usa?',
        urgency: RequestUrgency.high,
        location: 'Str. Florilor nr. 45, Ap. 2B (1.2 km)',
        preferredTime: now.add(const Duration(minutes: 33)),
        status: RequestStatus.open,
        createdAt: now.subtract(const Duration(minutes: 19)),
        isProxy: true,
        proxyForName: 'Maria Radu',
        proxyRelationship: 'Bunică',
        proxyNotes: 'Nu aude bine - bateți tare în ușă',
      ),
      Request(
        id: 'req_3',
        requesterId: 'user_req_1',
        requesterName: 'Maria Popescu (78 ani)',
        category: RequestCategory.groceries,
        description:
            'As avea nevoie de paine, lapte si oua. Nu mai pot sa car pungi grele pe scari',
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
        requesterName: 'Vasile Popa, 45 ani',
        category: RequestCategory.errands,
        description:
            'Tatal meu (78 ani) trebuie sa duca un colet la posta dar nu poate merge singur. Coletul e pregatit',
        urgency: RequestUrgency.low,
        location: 'Oficiul Poștal 1 (1.5 km)',
        preferredTime: now.add(const Duration(days: 1, minutes: 23)),
        status: RequestStatus.open,
        createdAt: now.subtract(const Duration(hours: 2, minutes: 54)),
        isProxy: true,
        proxyForName: 'Vasile Popa Sr.',
        proxyRelationship: 'Tată',
        proxyNotes: 'Coletul e pregătit la ușă',
      ),
      Request(
        id: 'req_5',
        requesterId: 'user_req_1',
        requesterName: 'Maria Popescu (78 ani)',
        category: RequestCategory.pharmacy,
        description:
            'Medicamentele mele de saptamana asta. Reteta e gata la farmacie',
        urgency: RequestUrgency.medium,
        location: 'Sensiblu, Piața Unirii',
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
            content: 'Cererea a fost acceptată',
            timestamp: now.subtract(const Duration(minutes: 49)),
            isRead: true,
            isSystemMessage: true,
          ),
          Message(
            id: 'msg_req3_1',
            requestId: requestId,
            senderId: 'user_req_1',
            senderName: 'Maria Popescu (78 ani)',
            content: 'Buna Andrei! Multumesc mult ca m-ai ales 😊',
            timestamp: now.subtract(const Duration(minutes: 47)),
            isRead: true,
          ),
          Message(
            id: 'msg_req3_2',
            requestId: requestId,
            senderId: 'user_vol_1',
            senderName: 'Andrei Ionescu',
            content: 'Cu drag! Ajung pe la 18:30. Ce paine vreti?',
            timestamp: now.subtract(const Duration(minutes: 43)),
            isRead: true,
          ),
          Message(
            id: 'msg_req3_3',
            requestId: requestId,
            senderId: 'user_req_1',
            senderName: 'Maria Popescu',
            content:
                'Paine alba, o cutie de 10 oua si lapte 1.5%. Iti las banii la usa',
            timestamp: now.subtract(const Duration(minutes: 39)),
            isRead: true,
          ),
          Message(
            id: 'msg_req3_4',
            requestId: requestId,
            senderId: 'user_vol_1',
            senderName: 'Andrei Ionescu',
            content: 'Ok, am notat! Ne vedem atunci 👍',
            timestamp: now.subtract(const Duration(minutes: 37)),
            isRead: true,
          ),
          Message(
            id: 'msg_req3_5',
            requestId: requestId,
            senderId: 'user_req_1',
            senderName: 'Maria Popescu',
            content: 'Multumesc mult! Sunt acasa',
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
            content: 'Cererea a fost acceptată',
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
            content: 'Buna Ana! Reteta e pe numele meu, Maria Popescu',
            timestamp:
                now.subtract(const Duration(days: 2, hours: 3, minutes: 2)),
            isRead: true,
          ),
          Message(
            id: 'msg_req5_system2',
            requestId: requestId,
            senderId: 'system',
            senderName: 'System',
            content: 'Cererea este acum în lucru',
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
                'Buna ziua! Am ajuns la farmacie. Cam cat trebuie sa astept?',
            timestamp:
                now.subtract(const Duration(days: 2, hours: 2, minutes: 48)),
            isRead: true,
          ),
          Message(
            id: 'msg_req5_3',
            requestId: requestId,
            senderId: 'user_req_1',
            senderName: 'Maria Popescu (78 ani)',
            content: 'De obicei 10-15 minute. Imi pare rau de asteptare!',
            timestamp:
                now.subtract(const Duration(days: 2, hours: 2, minutes: 41)),
            isRead: true,
          ),
          Message(
            id: 'msg_req5_4',
            requestId: requestId,
            senderId: 'user_vol_2',
            senderName: 'Ana Gheorghe',
            content: 'Nicio problema! Am luat medicamentele, vin spre dvs',
            timestamp:
                now.subtract(const Duration(days: 2, hours: 2, minutes: 27)),
            isRead: true,
          ),
          Message(
            id: 'msg_req5_5',
            requestId: requestId,
            senderId: 'user_req_1',
            senderName: 'Maria Popescu (78 ani)',
            content: 'Super! Te astept. Multumesc mult! 🙏',
            timestamp:
                now.subtract(const Duration(days: 2, hours: 2, minutes: 22)),
            isRead: true,
          ),
          Message(
            id: 'msg_req5_6',
            requestId: requestId,
            senderId: 'user_vol_2',
            senderName: 'Ana Gheorghe',
            content: 'Am ajuns! Sunt la usa',
            timestamp:
                now.subtract(const Duration(days: 2, hours: 2, minutes: 4)),
            isRead: true,
          ),
          Message(
            id: 'msg_req5_system3',
            requestId: requestId,
            senderId: 'system',
            senderName: 'System',
            content: 'Cererea a fost finalizată',
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
              'Multumesc din suflet ca m-ai ales! Chiar am nevoie urgent, reteta e gata si platita la farmacie';
        } else {
          content =
              'Iti multumesc mult! Reteta e pe numele meu, ${request.requesterName.split(',').first.split('(').first.trim()}. Astept sa aud de tine!';
        }
        break;
      case RequestCategory.checkIn:
        if (request.isProxy) {
          content =
              'Iti multumesc din inima! Sunt foarte ingrijorata pentru ea. E la parter, apartament 2B. Te rog sa bati tare, nu aude bine';
        } else {
          content = 'Multumesc mult! Sunt acasa toata ziua si astept';
        }
        break;
      case RequestCategory.groceries:
        content =
            'Iti multumesc ca ai acceptat! ${request.description.split('.').first}. Iti las banii la usa 😊';
        break;
      case RequestCategory.errands:
        if (request.isProxy) {
          content =
              'Multumesc mult pentru ajutor! Coletul e pregatit langa usa, e cam greu vreo 5kg. Tatal meu va fi foarte recunoscator!';
        } else {
          content = 'Super, multumesc! Totul e pregatit si te astept';
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
              'Perfect. Ajung in 10 min la farmacie, iti dau un semn cand am ridicat-o';
        } else {
          content =
              'Ok! Trec pe acolo in curand. Iti scriu cand am ridicat medicamentele';
        }
        break;
      case RequestCategory.checkIn:
        if (request.isProxy) {
          content = 'Am inteles. Plec acum, in 5 min sunt acolo';
        } else {
          content =
              'Perfect! Trec imediat sa verific, iti dau un semn cand ajung';
        }
        break;
      case RequestCategory.groceries:
        content = 'Perfect! Ce paine vrei? Si ce lapte - 1.5% sau 3.5%?';
        break;
      case RequestCategory.errands:
        if (request.isProxy) {
          content =
              'Nicio problema! Pot sa car si mai mult. Trec maine dimineata pe la 10?';
        } else {
          content = 'Ok! Cand ar fi cel mai bine sa trec?';
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
        title: 'Cerere acceptată',
        message: 'Andrei a acceptat cererea ta',
        requestId: 'req_3',
        timestamp: now.subtract(const Duration(hours: 1)),
        isRead: false,
      ),
      AppNotification(
        id: 'notif_2',
        userId: userId,
        type: NotificationType.newMessage,
        title: 'Mesaj nou',
        message: 'Andrei: Cu plăcere! Ajung pe la 14:00',
        requestId: 'req_3',
        timestamp: now.subtract(const Duration(minutes: 40)),
        isRead: false,
      ),
      AppNotification(
        id: 'notif_3',
        userId: userId,
        type: NotificationType.requestCompleted,
        title: 'Gata!',
        message: 'Medicamentele au fost ridicate',
        requestId: 'req_5',
        timestamp: now.subtract(const Duration(days: 2)),
        isRead: true,
      ),
    ];
  }

  static String generateId() => _uuid.v4();
}
