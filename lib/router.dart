import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'screens/welcome_screen.dart';
import 'screens/role_selection_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/requester/requester_dashboard.dart';
import 'screens/requester/create_request_screen.dart';
import 'screens/requester/request_detail_screen.dart';
import 'screens/requester/all_requests_screen.dart';
import 'screens/volunteer/volunteer_dashboard.dart';
import 'screens/volunteer/volunteer_request_detail.dart';
import 'screens/volunteer/volunteer_task_detail.dart';
import 'screens/chat_screen.dart';
import 'screens/profile_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final appState = context.read<AppState>();
    final isAuthenticated = appState.isAuthenticated;
    final currentUser = appState.currentUser;

    final isAuthRoute = state.matchedLocation == '/auth' ||
        state.matchedLocation == '/role-selection' ||
        state.matchedLocation == '/';

    if (!isAuthenticated && !isAuthRoute) {
      return '/';
    }

    if (isAuthenticated && state.matchedLocation == '/') {
      if (currentUser?.role.name == 'requester') {
        return '/requester';
      } else {
        return '/volunteer';
      }
    }

    return null;
  },
  routes: [
    GoRoute(path: '/', builder: (context, state) => const WelcomeScreen()),
    GoRoute(
      path: '/role-selection',
      builder: (context, state) => const RoleSelectionScreen(),
    ),
    GoRoute(
      path: '/auth',
      builder: (context, state) {
        final role = state.uri.queryParameters['role'];
        final mode = state.uri.queryParameters['mode'];
        return AuthScreen(role: role, mode: mode);
      },
    ),
    GoRoute(
      path: '/requester',
      builder: (context, state) => const RequesterDashboard(),
    ),
    GoRoute(
      path: '/requester/create-request',
      builder: (context, state) => const CreateRequestScreen(),
    ),
    GoRoute(
      path: '/requester/request/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return RequestDetailScreen(requestId: id);
      },
    ),
    GoRoute(
      path: '/requester/all-requests',
      builder: (context, state) => const AllRequestsScreen(),
    ),
    GoRoute(
      path: '/requester/chat/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ChatScreen(requestId: id);
      },
    ),
    GoRoute(
      path: '/chat/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ChatScreen(requestId: id);
      },
    ),
    GoRoute(
      path: '/requester/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/volunteer',
      builder: (context, state) => const VolunteerDashboard(),
    ),
    GoRoute(
      path: '/volunteer/request/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return VolunteerRequestDetail(requestId: id);
      },
    ),
    GoRoute(
      path: '/volunteer/task/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return VolunteerTaskDetail(requestId: id);
      },
    ),
    GoRoute(
      path: '/volunteer/chat/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ChatScreen(requestId: id);
      },
    ),
    GoRoute(
      path: '/volunteer/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
);
