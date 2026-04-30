import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../utils/theme.dart';

class ImpactScreen extends StatelessWidget {
  const ImpactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        final user = appState.currentUser;
        final completedRequests = appState
            .getAllRequests()
            .where((r) => r.volunteerId == user?.id && r.completedAt != null)
            .toList();

        final totalTasks = completedRequests.length;
        final uniquePeople =
            completedRequests.map((r) => r.requesterId).toSet().length;

        final now = DateTime.now();
        final thisMonth = completedRequests.where((r) {
          final completedAt = r.completedAt!;
          return completedAt.year == now.year && completedAt.month == now.month;
        }).length;

        final peopleThisMonth = completedRequests
            .where((r) {
              final completedAt = r.completedAt!;
              return completedAt.year == now.year &&
                  completedAt.month == now.month;
            })
            .map((r) => r.requesterId)
            .toSet()
            .length;

        return Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.primaryColor,
                        AppTheme.secondaryColor,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.favorite,
                        size: 64,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        peopleThisMonth > 0
                            ? 'Ai ajutat $peopleThisMonth ${peopleThisMonth == 1 ? 'persoană' : 'persoane'} luna asta'
                            : 'Începe să ajuți oameni!',
                        style:
                            Theme.of(context).textTheme.headlineSmall!.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                        textAlign: TextAlign.center,
                      ),
                      if (peopleThisMonth > 0) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Mulțumim pentru dedicare! 🙏',
                          style:
                              Theme.of(context).textTheme.bodyLarge!.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.people,
                        value: uniquePeople.toString(),
                        label: 'Persoane\najutate',
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.check_circle,
                        value: totalTasks.toString(),
                        label: 'Sarcini\nfinalizate',
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.calendar_today,
                        value: thisMonth.toString(),
                        label: 'Luna\nasta',
                        color: AppTheme.warningColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.star,
                        value: user?.trustLevel ?? 'Nou',
                        label: 'Nivel\nîncredere',
                        color: Colors.amber,
                        isText: true,
                      ),
                    ),
                  ],
                ),

                if (totalTasks > 0) ...[
                  const SizedBox(height: 32),
                  Text(
                    'Activitate recentă',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  ...completedRequests.take(5).map(
                        (request) => _ImpactItem(
                          icon: _getCategoryIcon(request.category.name),
                          title: request.categoryLabel,
                          subtitle: request.requesterName,
                          date: request.completedAt!,
                        ),
                      ),
                ],

                if (totalTasks == 0) ...[
                  const SizedBox(height: 32),
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.volunteer_activism,
                          size: 80,
                          color: AppTheme.textSecondary.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Începe să ajuți!',
                          style:
                              Theme.of(context).textTheme.titleLarge!.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Acceptă prima cerere pentru\na vedea impactul tău',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'groceries':
        return Icons.shopping_cart;
      case 'pharmacy':
        return Icons.local_pharmacy;
      case 'errands':
        return Icons.directions_run;
      case 'checkIn':
        return Icons.favorite;
      default:
        return Icons.help;
    }
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final bool isText;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    this.isText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: color.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: isText ? 18 : null,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: AppTheme.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ImpactItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final DateTime date;

  const _ImpactItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.date,
  });

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) return 'Azi';
    if (diff.inDays == 1) return 'Ieri';
    if (diff.inDays < 7) return 'Acum ${diff.inDays} zile';
    if (diff.inDays < 30) return 'Acum ${(diff.inDays / 7).floor()} săptămâni';
    return 'Acum ${(diff.inDays / 30).floor()} luni';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.secondaryColor.withValues(alpha: 0.1),
          child: Icon(icon, color: AppTheme.secondaryColor, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing: Text(
          _formatDate(date),
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
      ),
    );
  }
}
