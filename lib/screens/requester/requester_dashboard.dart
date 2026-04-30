import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/request_model.dart';
import '../../providers/app_state.dart';
import '../../utils/theme.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/request_card.dart';

class RequesterDashboard extends StatelessWidget {
  const RequesterDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cererile mele'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.push('/requester/profile'),
          ),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, appState, _) {
          final requests = appState.getMyRequests();
          final activeRequests = requests
              .where(
                (r) =>
                    r.status == RequestStatus.open ||
                    r.status == RequestStatus.accepted ||
                    r.status == RequestStatus.inProgress,
              )
              .toList();

          return RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(const Duration(milliseconds: 100));
            },
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Cereri active',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    TextButton.icon(
                      onPressed: () => context.push('/requester/all-requests'),
                      icon: const Icon(Icons.history, size: 18),
                      label: const Text('Vezi toate'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (activeRequests.isEmpty)
                  EmptyState(
                    icon: Icons.inbox,
                    title: 'Nicio cerere activă',
                    message: 'Creează o cerere nouă pentru a primi ajutor',
                    action: ElevatedButton.icon(
                      onPressed: () =>
                          context.push('/requester/create-request'),
                      icon: const Icon(Icons.add),
                      label: const Text('Creează cerere'),
                    ),
                  )
                else
                  ...activeRequests.asMap().entries.map(
                    (entry) {
                      final index = entry.key;
                      final request = entry.value;
                      return _AnimatedRequestCard(
                        index: index,
                        request: request,
                        requesterInfo:
                            appState.getUserById(request.requesterId),
                        onTap: () =>
                            context.push('/requester/request/${request.id}'),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/requester/create-request'),
        icon: const Icon(Icons.add),
        label: const Text('Cerere nouă'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
    );
  }
}

class _AnimatedRequestCard extends StatelessWidget {
  final int index;
  final Request request;
  final dynamic requesterInfo;
  final VoidCallback onTap;

  const _AnimatedRequestCard({
    required this.index,
    required this.request,
    required this.requesterInfo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: RequestCard(
        request: request,
        requesterInfo: requesterInfo,
        onTap: onTap,
      ),
    );
  }
}
