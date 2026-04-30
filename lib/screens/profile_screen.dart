import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../providers/app_state.dart';
import '../utils/theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        final user = appState.currentUser;

        if (user == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Profil')),
            body: const Center(child: Text('Nu ești autentificat')),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Profil')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                        child: Text(
                          user.name[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.name,
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (user.isVerified)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.secondaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.verified,
                                    size: 16,
                                    color: AppTheme.secondaryColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Verificat',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                          color: AppTheme.secondaryColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              user.trustLevel,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Column(
                  children: [
                    _ProfileItem(
                      icon: Icons.person,
                      label: 'Rol',
                      value: user.role == UserRole.requester
                          ? 'Solicitant'
                          : 'Voluntar',
                    ),
                    const Divider(height: 1),
                    _ProfileItem(
                      icon: Icons.phone,
                      label: 'Telefon',
                      value: user.phone ?? 'Necompletat',
                    ),
                    const Divider(height: 1),
                    _ProfileItem(
                      icon: Icons.location_on,
                      label: 'Adresă',
                      value: user.address ?? 'Necompletat',
                    ),
                    const Divider(height: 1),
                    _ProfileItem(
                      icon: Icons.check_circle,
                      label: 'Sarcini finalizate',
                      value: '${user.completedTasks}',
                    ),
                    const Divider(height: 1),
                    _ProfileItem(
                      icon: Icons.access_time,
                      label: 'Ultima activitate',
                      value: user.lastActiveLabel,
                    ),
                    if (user.role == UserRole.volunteer &&
                        user.avgResponseMinutes != null) ...[
                      const Divider(height: 1),
                      _ProfileItem(
                        icon: Icons.speed,
                        label: 'Timp răspuns',
                        value: user.responseTimeLabel,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Ieși din cont?'),
                      content: const Text('Sigur vrei să ieși?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Nu'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Da, ieși'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true && context.mounted) {
                    await appState.logout();
                    if (context.mounted) {
                      context.go('/');
                    }
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('Ieși din cont'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.errorColor,
                  side: const BorderSide(color: AppTheme.errorColor),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.textSecondary, size: 20),
          const SizedBox(width: 16),
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
      ),
    );
  }
}
