import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/request_card.dart';

class AllRequestsScreen extends StatelessWidget {
  const AllRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Toate cererile')),
      body: Consumer<AppState>(
        builder: (context, appState, _) {
          final requests = appState.getMyRequests();

          if (requests.isEmpty) {
            return EmptyState(
              icon: Icons.inbox,
              title: 'Nicio cerere încă',
              message: 'Creează prima cerere pentru a începe',
              action: ElevatedButton.icon(
                onPressed: () => context.push('/requester/create-request'),
                icon: const Icon(Icons.add),
                label: const Text('Creează cerere'),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: requests
                .map(
                  (request) => RequestCard(
                    request: request,
                    requesterInfo: appState.getUserById(request.requesterId),
                    onTap: () =>
                        context.push('/requester/request/${request.id}'),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }
}
