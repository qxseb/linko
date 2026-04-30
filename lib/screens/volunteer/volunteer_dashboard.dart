import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/request_model.dart';
import '../../providers/app_state.dart';
import '../../utils/theme.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/request_card.dart';
import 'impact_screen.dart';

class VolunteerDashboard extends StatefulWidget {
  const VolunteerDashboard({super.key});

  @override
  State<VolunteerDashboard> createState() => _VolunteerDashboardState();
}

class _VolunteerDashboardState extends State<VolunteerDashboard> {
  int _selectedIndex = 0;
  RequestCategory? _selectedCategory;
  RequestUrgency? _selectedUrgency;

  String _getCategoryLabel(RequestCategory category) {
    switch (category) {
      case RequestCategory.groceries:
        return 'Cumpărături';
      case RequestCategory.pharmacy:
        return 'Farmacie';
      case RequestCategory.errands:
        return 'Treburi';
      case RequestCategory.checkIn:
        return 'Verificare';
    }
  }

  String _getUrgencyLabel(RequestUrgency urgency) {
    switch (urgency) {
      case RequestUrgency.low:
        return 'Normală';
      case RequestUrgency.medium:
        return 'Medie';
      case RequestUrgency.high:
        return 'Urgentă';
    }
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filtrează cereri',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  TextButton(
                    onPressed: () {
                      setModalState(() {
                        _selectedCategory = null;
                        _selectedUrgency = null;
                      });
                      setState(() {
                        _selectedCategory = null;
                        _selectedUrgency = null;
                      });
                    },
                    child: const Text('Resetează'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Categorie',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: RequestCategory.values.map((category) {
                  final isSelected = _selectedCategory == category;
                  return FilterChip(
                    label: Text(_getCategoryLabel(category)),
                    selected: isSelected,
                    onSelected: (selected) {
                      setModalState(() {
                        _selectedCategory = selected ? category : null;
                      });
                      setState(() {
                        _selectedCategory = selected ? category : null;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Text(
                'Urgență',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: RequestUrgency.values.map((urgency) {
                  final isSelected = _selectedUrgency == urgency;
                  return FilterChip(
                    label: Text(_getUrgencyLabel(urgency)),
                    selected: isSelected,
                    onSelected: (selected) {
                      setModalState(() {
                        _selectedUrgency = selected ? urgency : null;
                      });
                      setState(() {
                        _selectedUrgency = selected ? urgency : null;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Aplică filtre'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0
            ? 'Hartă cereri'
            : _selectedIndex == 1
                ? 'Listă cereri'
                : _selectedIndex == 2
                    ? 'Sarcinile mele'
                    : 'Impactul tău'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.push('/volunteer/profile'),
          ),
        ],
      ),
      body: _selectedIndex == 0
          ? _buildMapView()
          : _selectedIndex == 1
              ? _buildAvailableRequests()
              : _selectedIndex == 2
                  ? _buildMyTasks()
                  : _buildImpact(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.map), label: 'Hartă'),
          NavigationDestination(icon: Icon(Icons.list), label: 'Listă'),
          NavigationDestination(icon: Icon(Icons.task), label: 'Sarcini'),
          NavigationDestination(icon: Icon(Icons.favorite), label: 'Impact'),
        ],
      ),
    );
  }

  Widget _buildMapView() {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        final requests = appState.getAvailableRequests();
        final displayRequests = requests.take(8).toList();

        return Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.surfaceColor,
                    AppTheme.backgroundColor,
                    AppTheme.surfaceColor,
                  ],
                ),
              ),
            ),
            CustomPaint(
              size: Size.infinite,
              painter: _MapPatternPainter(),
            ),
            CustomPaint(
              size: Size.infinite,
              painter: _GridPainter(),
            ),
            Positioned(
              left: MediaQuery.of(context).size.width / 2 - 20,
              top: MediaQuery.of(context).size.height / 2 - 20,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue.shade700,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            ...displayRequests.asMap().entries.map((entry) {
              final index = entry.key;
              final request = entry.value;
              return _buildMarker(
                  context, request, index, displayRequests.length);
            }),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Card(
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.favorite,
                          color: AppTheme.primaryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${displayRequests.length} ${displayRequests.length == 1 ? 'persoană are' : 'persoane au'} nevoie de tine',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Apasă pe un marker pentru a ajuta',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMarker(
    BuildContext context,
    Request request,
    int index,
    int total,
  ) {
    final size = MediaQuery.of(context).size;
    final positions = _calculateMarkerPositions(size, total);
    final position = positions[index];

    final color = _getUrgencyColor(request.urgency);
    final isUrgent = request.urgency == RequestUrgency.high;

    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onTap: () => _showRequestPreview(context, request),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 300 + (index * 100)),
          curve: Curves.elasticOut,
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: child,
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  if (isUrgent)
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 1.0, end: 1.3),
                      duration: const Duration(milliseconds: 1500),
                      curve: Curves.easeInOut,
                      builder: (context, pulse, child) {
                        return Transform.scale(
                          scale: pulse,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: color.withValues(alpha: 0.2),
                            ),
                          ),
                        );
                      },
                      onEnd: () {
                        if (mounted) setState(() {});
                      },
                    ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      _getCategoryIcon(request.category),
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  _extractDistance(request.location),
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Offset> _calculateMarkerPositions(Size size, int count) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    final positions = [
      Offset(centerX - 100, centerY - 120),
      Offset(centerX + 80, centerY - 80),
      Offset(centerX - 60, centerY + 40),
      Offset(centerX + 100, centerY + 60),
      Offset(centerX - 130, centerY + 100),
      Offset(centerX + 60, centerY - 140),
      Offset(centerX - 90, centerY - 40),
      Offset(centerX + 120, centerY + 20),
    ];

    return positions.take(count).toList();
  }

  Color _getUrgencyColor(RequestUrgency urgency) {
    switch (urgency) {
      case RequestUrgency.high:
        return const Color(0xFFEF4444);
      case RequestUrgency.medium:
        return const Color(0xFFF59E0B);
      case RequestUrgency.low:
        return const Color(0xFF10B981);
    }
  }

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

  String _extractDistance(String location) {
    final regex = RegExp(r'\(([^)]+)\)');
    final match = regex.firstMatch(location);
    return match?.group(1) ?? '1 km';
  }

  void _showRequestPreview(BuildContext context, Request request) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getCategoryIcon(request.category),
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.categoryLabel,
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        request.requesterName,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getUrgencyColor(request.urgency)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    request.urgencyLabel,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: _getUrgencyColor(request.urgency),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              request.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.location_on,
                    size: 16, color: AppTheme.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    request.location,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.push('/volunteer/request/${request.id}');
                },
                child: const Text('Vezi detalii'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableRequests() {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        var requests = appState.getAvailableRequests();

        if (_selectedCategory != null) {
          requests =
              requests.where((r) => r.category == _selectedCategory).toList();
        }
        if (_selectedUrgency != null) {
          requests =
              requests.where((r) => r.urgency == _selectedUrgency).toList();
        }

        final hasFilters =
            _selectedCategory != null || _selectedUrgency != null;

        return RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 100));
          },
          child: requests.isEmpty
              ? EmptyState(
                  icon: hasFilters
                      ? Icons.filter_list_off
                      : Icons.check_circle_outline,
                  title: hasFilters
                      ? 'Nicio cerere cu aceste filtre'
                      : 'Nicio cerere disponibilă',
                  message: hasFilters
                      ? 'Încearcă să schimbi filtrele'
                      : 'Verifică din nou mai târziu',
                  action: hasFilters
                      ? TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedCategory = null;
                              _selectedUrgency = null;
                            });
                          },
                          child: const Text('Resetează filtrele'),
                        )
                      : null,
                )
              : ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${requests.length} ${requests.length == 1 ? 'cerere' : 'cereri'} în apropiere',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        if (hasFilters)
                          Chip(
                            label: Text(
                              '${(_selectedCategory != null ? 1 : 0) + (_selectedUrgency != null ? 1 : 0)} ${(_selectedCategory != null ? 1 : 0) + (_selectedUrgency != null ? 1 : 0) == 1 ? 'filtru' : 'filtre'}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () {
                              setState(() {
                                _selectedCategory = null;
                                _selectedUrgency = null;
                              });
                            },
                          ),
                        IconButton(
                          icon: const Icon(Icons.filter_list),
                          onPressed: _showFilterDialog,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...requests.asMap().entries.map(
                      (entry) {
                        final index = entry.key;
                        final request = entry.value;
                        return _AnimatedRequestCard(
                          index: index,
                          request: request,
                          requesterInfo:
                              appState.getUserById(request.requesterId),
                          onTap: () =>
                              context.push('/volunteer/request/${request.id}'),
                        );
                      },
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildMyTasks() {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        final requests = appState.getMyVolunteerRequests();
        final activeRequests = requests
            .where(
              (r) =>
                  r.status == RequestStatus.accepted ||
                  r.status == RequestStatus.inProgress,
            )
            .toList();

        return activeRequests.isEmpty
            ? const EmptyState(
                icon: Icons.volunteer_activism,
                title: 'Nicio sarcină activă',
                message: 'Acceptă o cerere pentru a începe să ajuți',
              )
            : ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Sarcini active',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 16),
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
                            context.push('/volunteer/task/${request.id}'),
                      );
                    },
                  ),
                ],
              );
      },
    );
  }

  Widget _buildImpact() {
    return const ImpactScreen();
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.dividerColor.withValues(alpha: 0.1)
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += 50) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += 50) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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

class _MapPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.textSecondary.withValues(alpha: 0.05)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final streets = [
      [Offset(0, size.height * 0.2), Offset(size.width, size.height * 0.2)],
      [Offset(0, size.height * 0.4), Offset(size.width, size.height * 0.4)],
      [Offset(0, size.height * 0.6), Offset(size.width, size.height * 0.6)],
      [Offset(0, size.height * 0.8), Offset(size.width, size.height * 0.8)],
      [Offset(size.width * 0.25, 0), Offset(size.width * 0.25, size.height)],
      [Offset(size.width * 0.5, 0), Offset(size.width * 0.5, size.height)],
      [Offset(size.width * 0.75, 0), Offset(size.width * 0.75, size.height)],
      [const Offset(0, 0), Offset(size.width * 0.3, size.height * 0.3)],
      [
        Offset(size.width * 0.7, size.height * 0.2),
        Offset(size.width, size.height * 0.5)
      ],
    ];

    for (final line in streets) {
      canvas.drawLine(line[0], line[1], paint);
    }

    final blockPaint = Paint()
      ..color = AppTheme.textSecondary.withValues(alpha: 0.03)
      ..style = PaintingStyle.fill;

    final blocks = [
      Rect.fromLTWH(size.width * 0.1, size.height * 0.1, 60, 40),
      Rect.fromLTWH(size.width * 0.6, size.height * 0.15, 50, 50),
      Rect.fromLTWH(size.width * 0.3, size.height * 0.5, 70, 45),
      Rect.fromLTWH(size.width * 0.7, size.height * 0.65, 55, 35),
      Rect.fromLTWH(size.width * 0.15, size.height * 0.7, 65, 40),
    ];

    for (final block in blocks) {
      canvas.drawRect(block, blockPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
