import 'package:flutter/material.dart';
import '../models/request_model.dart';
import '../models/user_model.dart';
import '../utils/theme.dart';
import '../utils/formatters.dart';

class RequestCard extends StatelessWidget {
  final Request request;
  final VoidCallback onTap;
  final User? requesterInfo;

  const RequestCard({
    super.key,
    required this.request,
    required this.onTap,
    this.requesterInfo,
  });

  IconData _getCategoryIcon() {
    switch (request.category) {
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
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getCategoryIcon(),
                      color: AppTheme.primaryColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.categoryLabel,
                          style:
                              Theme.of(context).textTheme.bodyLarge!.copyWith(
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.2,
                                  ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              request.requesterName,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            if (requesterInfo?.isVerified == true) ...[
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.verified,
                                size: 14,
                                color: AppTheme.secondaryColor,
                              ),
                            ],
                          ],
                        ),
                        if (requesterInfo != null) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                '${requesterInfo!.completedTasks} finalizate',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                      fontSize: 11,
                                      color: AppTheme.textSecondary,
                                    ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '•',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                requesterInfo!.lastActiveLabel,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                      fontSize: 11,
                                      color: AppTheme.textSecondary,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.getUrgencyColor(request.urgencyLabel)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      request.urgencyLabel,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color:
                                AppTheme.getUrgencyColor(request.urgencyLabel),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                request.description,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      height: 1.5,
                      color: AppTheme.textPrimary.withValues(alpha: 0.9),
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (request.isProxy) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.people, size: 15, color: AppTheme.primaryColor),
                    const SizedBox(width: 6),
                    Text(
                      'Cerere în numele altcuiva',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(Icons.location_on,
                      size: 16, color: AppTheme.textSecondary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      request.location,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.access_time,
                      size: 16, color: AppTheme.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    Formatters.formatPreferredTime(request.preferredTime),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.getStatusColor(request.statusLabel)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      request.statusLabel,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: AppTheme.getStatusColor(request.statusLabel),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
