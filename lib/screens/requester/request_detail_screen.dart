import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/request_model.dart';
import '../../providers/app_state.dart';
import '../../utils/theme.dart';
import '../../utils/formatters.dart';

class RequestDetailScreen extends StatelessWidget {
  final String requestId;

  const RequestDetailScreen({super.key, required this.requestId});

  IconData _getCategoryIcon(RequestCategory category) {
    switch (category) {
      case RequestCategory.groceries:
        return Icons.shopping_cart;
      case RequestCategory.pharmacy:
        return Icons.local_pharmacy;
      case RequestCategory.errands:
        return Icons.directions_run;
      case RequestCategory.checkIn:
        return Icons.favorite;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        final request = appState.getRequestById(requestId);

        if (request == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Detalii cerere')),
            body: const Center(child: Text('Cerere negăsită')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Detalii cerere'),
            actions: [
              if (request.status == RequestStatus.open)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Anulezi cererea?'),
                        content: const Text(
                          'Ești sigur că vrei să anulezi această cerere?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Nu'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Da, anulează'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true && context.mounted) {
                      await appState.cancelRequest(requestId);
                      if (context.mounted) {
                        context.pop();
                      }
                    }
                  },
                ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color:
                                  AppTheme.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getCategoryIcon(request.category),
                              color: AppTheme.primaryColor,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  request.categoryLabel,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.displaySmall,
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.getStatusColor(
                                      request.statusLabel,
                                    ).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    request.statusLabel,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                          color: AppTheme.getStatusColor(
                                            request.statusLabel,
                                          ),
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 32),
                      _DetailRow(
                        icon: Icons.description,
                        label: 'Descriere',
                        value: request.description,
                      ),
                      const SizedBox(height: 16),
                      _DetailRow(
                        icon: Icons.location_on,
                        label: 'Locație',
                        value: request.location,
                      ),
                      const SizedBox(height: 16),
                      _DetailRow(
                        icon: Icons.access_time,
                        label: 'Timp preferat',
                        value: Formatters.formatPreferredTime(
                          request.preferredTime,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _DetailRow(
                        icon: Icons.priority_high,
                        label: 'Urgență',
                        value: request.urgencyLabel,
                        valueColor: AppTheme.getUrgencyColor(
                          request.urgencyLabel,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _DetailRow(
                        icon: Icons.schedule,
                        label: 'Creată',
                        value: Formatters.formatDate(request.createdAt),
                      ),
                      if (request.isProxy) ...[
                        const Divider(height: 32),
                        _DetailRow(
                          icon: Icons.people,
                          label: 'Cerere pentru',
                          value:
                              '${request.proxyForName} (${request.proxyRelationship})',
                        ),
                        if (request.proxyNotes != null) ...[
                          const SizedBox(height: 16),
                          _DetailRow(
                            icon: Icons.info_outline,
                            label: 'Notițe',
                            value: request.proxyNotes!,
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
              if (request.volunteerId != null) ...[
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Voluntar',
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppTheme.secondaryColor
                                  .withValues(alpha: 0.2),
                              child: Text(
                                request.volunteerName![0].toUpperCase(),
                                style: const TextStyle(
                                  color: AppTheme.secondaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    request.volunteerName!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    'Voluntar verificat',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.message),
                              onPressed: () =>
                                  context.push('/requester/chat/$requestId'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (request.status == RequestStatus.accepted ||
                  request.status == RequestStatus.inProgress) ...[
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context.push('/requester/chat/$requestId'),
                    icon: const Icon(Icons.message),
                    label: const Text('Scrie mesaj'),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppTheme.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.w500,
                      color: valueColor,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
