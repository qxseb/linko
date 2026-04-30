import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/request_model.dart';
import '../../providers/app_state.dart';
import '../../utils/theme.dart';
import '../../utils/formatters.dart';

class VolunteerRequestDetail extends StatelessWidget {
  final String requestId;

  const VolunteerRequestDetail({super.key, required this.requestId});

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
          appBar: AppBar(title: const Text('Detalii cerere')),
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
                                    color: AppTheme.getUrgencyColor(
                                      request.urgencyLabel,
                                    ).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    request.urgencyLabel,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                          color: AppTheme.getUrgencyColor(
                                            request.urgencyLabel,
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
                        icon: Icons.schedule,
                        label: 'Postată',
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
                            label: 'Notițe importante',
                            value: request.proxyNotes!,
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Requester',
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppTheme.primaryColor.withValues(
                              alpha: 0.2,
                            ),
                            child: Text(
                              request.requesterName[0].toUpperCase(),
                              style: const TextStyle(
                                color: AppTheme.primaryColor,
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
                                  request.requesterName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .copyWith(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  'Verified Member',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (request.status == RequestStatus.open) ...[
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: appState.isLoading
                        ? null
                        : () async {
                            try {
                              final requesterMessage =
                                  await appState.acceptRequest(requestId);
                              if (context.mounted) {
                                await showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (dialogContext) => Dialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(24),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TweenAnimationBuilder<double>(
                                            tween: Tween(begin: 0.0, end: 1.0),
                                            duration: const Duration(
                                                milliseconds: 600),
                                            curve: Curves.elasticOut,
                                            builder: (context, scale, child) {
                                              return Transform.scale(
                                                scale: scale,
                                                child: Container(
                                                  width: 80,
                                                  height: 80,
                                                  decoration: BoxDecoration(
                                                    color: AppTheme
                                                        .secondaryColor
                                                        .withValues(alpha: 0.1),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                    Icons.favorite,
                                                    size: 40,
                                                    color:
                                                        AppTheme.secondaryColor,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                          const SizedBox(height: 24),
                                          Text(
                                            'Ai ales să ajuți această persoană',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge!
                                                .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            request.requesterName,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .copyWith(
                                                  color: AppTheme.primaryColor,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'îți mulțumește pentru ajutor',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 24),
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                Navigator.of(dialogContext)
                                                    .pop();
                                              },
                                              child: const Text('Continuă'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );

                                if (context.mounted) {
                                  final router = GoRouter.of(context);
                                  final scaffoldMessenger =
                                      ScaffoldMessenger.of(context);

                                  scaffoldMessenger.showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 20,
                                            backgroundColor: AppTheme
                                                .primaryColor
                                                .withValues(alpha: 0.2),
                                            child: Text(
                                              requesterMessage.senderName[0]
                                                  .toUpperCase(),
                                              style: const TextStyle(
                                                color: AppTheme.primaryColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  requesterMessage.senderName,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  requesterMessage.content,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.black87,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      backgroundColor: Colors.white,
                                      behavior: SnackBarBehavior.floating,
                                      duration: const Duration(seconds: 4),
                                      margin: const EdgeInsets.all(16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 8,
                                      dismissDirection:
                                          DismissDirection.horizontal,
                                      action: SnackBarAction(
                                        label: 'Răspunde',
                                        textColor: AppTheme.primaryColor,
                                        onPressed: () {
                                          router.push('/chat/$requestId');
                                        },
                                      ),
                                    ),
                                  );

                                  await Future.delayed(
                                      const Duration(milliseconds: 500));
                                  if (context.mounted) {
                                    context.go('/volunteer');
                                  }
                                }
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(e.toString()),
                                    backgroundColor: AppTheme.errorColor,
                                  ),
                                );
                              }
                            }
                          },
                    icon: appState.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.check),
                    label: Text(appState.isLoading
                        ? 'Se acceptă...'
                        : 'Acceptă cererea'),
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

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
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
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
