import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../models/request_model.dart';
import '../../providers/app_state.dart';
import '../../services/location_service.dart';
import '../../utils/english_text.dart';
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

  Position? _userPosition;
  bool _loadingLocation = true;
  String? _locationError;
  final MapController _mapController = MapController();

  int? _focusedMarkerIndex;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _cycleTo(
    int index,
    List<Request> requests,
    LatLng userPoint,
  ) {
    if (requests.isEmpty) return;
    final i = index.clamp(0, requests.length - 1);
    final point = _getRequestLatLng(userPoint, i, requests[i]);
    setState(() => _focusedMarkerIndex = i);
    _mapController.move(point, 16.0);
  }

  void _cycleNext(List<Request> requests, LatLng userPoint) {
    if (requests.isEmpty) return;
    final next = _focusedMarkerIndex == null
        ? 0
        : (_focusedMarkerIndex! + 1) % requests.length;
    _cycleTo(next, requests, userPoint);
  }

  void _cyclePrev(List<Request> requests, LatLng userPoint) {
    if (requests.isEmpty) return;
    final prev = _focusedMarkerIndex == null
        ? requests.length - 1
        : (_focusedMarkerIndex! - 1 + requests.length) % requests.length;
    _cycleTo(prev, requests, userPoint);
  }

  void _clearFocus(LatLng userPoint) {
    setState(() => _focusedMarkerIndex = null);
    _mapController.move(userPoint, 14.5);
  }

  Future<void> _fetchLocation() async {
    setState(() {
      _loadingLocation = true;
      _locationError = null;
    });
    try {
      final position = await LocationService.getCurrentPosition();
      if (!mounted) return;
      setState(() {
        _userPosition = position;
        _loadingLocation = false;
        if (position == null) {
          _locationError =
              'Location permission denied.\nPlease enable it in your device settings.';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingLocation = false;
        _locationError = 'Could not get your location.';
      });
    }
  }

  String _getCategoryLabel(RequestCategory category) {
    switch (category) {
      case RequestCategory.groceries:
        return 'Groceries';
      case RequestCategory.pharmacy:
        return 'Pharmacy';
      case RequestCategory.errands:
        return 'Errands';
      case RequestCategory.checkIn:
        return 'Check-in';
    }
  }

  String _getUrgencyLabel(RequestUrgency urgency) {
    switch (urgency) {
      case RequestUrgency.low:
        return 'Low';
      case RequestUrgency.medium:
        return 'Medium';
      case RequestUrgency.high:
        return 'High';
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
                    'Filter requests',
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
                    child: const Text('Reset'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Category',
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
                'Urgency',
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
                  child: const Text('Apply filters'),
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
            ? 'Request map'
            : _selectedIndex == 1
                ? 'Request list'
                : _selectedIndex == 2
                    ? 'My tasks'
                    : 'Your impact'),
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
          setState(() {
            _selectedIndex = index;
            if (index != 0) _focusedMarkerIndex = null;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.map), label: 'Map'),
          NavigationDestination(icon: Icon(Icons.list), label: 'List'),
          NavigationDestination(icon: Icon(Icons.task), label: 'Tasks'),
          NavigationDestination(icon: Icon(Icons.favorite), label: 'Impact'),
        ],
      ),
    );
  }

  Widget _buildMapView() {
    if (_loadingLocation) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Getting your location…'),
          ],
        ),
      );
    }

    if (_locationError != null || _userPosition == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.location_off,
                size: 64,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(height: 16),
              Text(
                'Location unavailable',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 8),
              Text(
                _locationError ??
                    'Enable location permissions to see the map.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _fetchLocation,
                icon: const Icon(Icons.refresh),
                label: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
    }

    return Consumer<AppState>(
      builder: (context, appState, _) {
        final requests = appState.getAvailableRequests();
        final displayRequests = requests.take(8).toList();
        final userPoint = LatLng(
          _userPosition!.latitude,
          _userPosition!.longitude,
        );

        final focusedIndex = _focusedMarkerIndex != null &&
                _focusedMarkerIndex! < displayRequests.length
            ? _focusedMarkerIndex
            : null;
        final focusedRequest =
            focusedIndex != null ? displayRequests[focusedIndex] : null;

        return Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: userPoint,
                initialZoom: 14.5,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.linko.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: userPoint,
                      width: 52,
                      height: 52,
                      child: _buildUserLocationMarker(),
                    ),
                    ...displayRequests.asMap().entries
                        .where((e) => e.key != focusedIndex)
                        .map((entry) {
                      final point =
                          _getRequestLatLng(userPoint, entry.key, entry.value);
                      return Marker(
                        point: point,
                        width: 52,
                        height: 52,
                        child: GestureDetector(
                          onTap: () {
                            _cycleTo(entry.key, displayRequests, userPoint);
                          },
                          child: _buildRequestMarkerWidget(
                            entry.value,
                            isFocused: false,
                          ),
                        ),
                      );
                    }),
                    if (focusedIndex != null)
                      Marker(
                        point: _getRequestLatLng(
                          userPoint,
                          focusedIndex,
                          displayRequests[focusedIndex],
                        ),
                        width: 68,
                        height: 68,
                        child: GestureDetector(
                          onTap: () => _showRequestPreview(
                            context,
                            displayRequests[focusedIndex],
                          ),
                          child: _buildRequestMarkerWidget(
                            displayRequests[focusedIndex],
                            isFocused: true,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),

            Positioned(
              right: 16,
              bottom: 148,
              child: FloatingActionButton.small(
                heroTag: 'recenter',
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primaryColor,
                elevation: 4,
                onPressed: () => _clearFocus(userPoint),
                child: const Icon(Icons.my_location),
              ),
            ),

            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Card(
                elevation: 8,
                clipBehavior: Clip.hardEdge,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: focusedRequest != null
                      ? Column(
                          key: ValueKey(focusedIndex),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: _getUrgencyColor(
                                        focusedRequest.urgency,
                                      ).withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      _getCategoryIcon(focusedRequest.category),
                                      color: _getUrgencyColor(
                                        focusedRequest.urgency,
                                      ),
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          focusedRequest.category.label,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge!
                                              .copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          focusedRequest.requesterName,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getUrgencyColor(
                                        focusedRequest.urgency,
                                      ).withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      focusedRequest.urgency.label,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                            color: _getUrgencyColor(
                                              focusedRequest.urgency,
                                            ),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(height: 1),
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(4, 4, 12, 4),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.chevron_left),
                                    onPressed: () => _cyclePrev(
                                      displayRequests,
                                      userPoint,
                                    ),
                                    tooltip: 'Previous',
                                  ),
                                  Text(
                                    '${focusedIndex! + 1} of '
                                    '${displayRequests.length}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textSecondary,
                                        ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.chevron_right),
                                    onPressed: () => _cycleNext(
                                      displayRequests,
                                      userPoint,
                                    ),
                                    tooltip: 'Next',
                                  ),
                                  const Spacer(),
                                  FilledButton.tonal(
                                    onPressed: () => context.push(
                                      '/volunteer/request/'
                                      '${focusedRequest.id}',
                                    ),
                                    child: const Text('Details'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : Column(
                          key: const ValueKey('overview'),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryColor
                                          .withValues(alpha: 0.1),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          displayRequests.isEmpty
                                              ? 'No active requests nearby'
                                              : '${displayRequests.length} '
                                                  '${displayRequests.length == 1 ? 'person needs' : 'people need'} you',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge!
                                              .copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          displayRequests.isEmpty
                                              ? 'Check back later for new opportunities'
                                              : 'Tap a marker or use arrows to explore',
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
                            if (displayRequests.isNotEmpty) ...[
                              const Divider(height: 1),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(4, 4, 4, 4),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.chevron_left),
                                      onPressed: () => _cyclePrev(
                                        displayRequests,
                                        userPoint,
                                      ),
                                      tooltip: 'Previous marker',
                                    ),
                                    Text(
                                      'Navigate markers',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                            color: AppTheme.textSecondary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.chevron_right),
                                      onPressed: () => _cycleNext(
                                        displayRequests,
                                        userPoint,
                                      ),
                                      tooltip: 'Next marker',
                                    ),
                                  ],
                                ),
                              ),
                            ],
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

  Widget _buildUserLocationMarker() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue.shade600.withValues(alpha: 0.2),
          ),
        ),
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: Colors.blue.shade700,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withValues(alpha: 0.45),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRequestMarkerWidget(
    Request request, {
    bool isFocused = false,
  }) {
    final color = _getUrgencyColor(request.urgency);
    final isUrgent = request.urgency == RequestUrgency.high;

    return AnimatedScale(
      scale: isFocused ? 1.25 : 1.0,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutBack,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isUrgent || isFocused)
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: isFocused ? 58 : 52,
              height: isFocused ? 58 : 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(
                  alpha: isFocused ? 0.28 : 0.18,
                ),
              ),
            ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: isFocused ? 4 : 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(
                    alpha: isFocused ? 0.65 : 0.4,
                  ),
                  blurRadius: isFocused ? 18 : 8,
                  spreadRadius: isFocused ? 3 : 1,
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
    );
  }

  LatLng _getRequestLatLng(LatLng center, int index, Request request) {
    if (request.latitude != null && request.longitude != null) {
      return LatLng(request.latitude!, request.longitude!);
    }
    const offsets = [
      [0.006, 0.008],
      [0.004, -0.009],
      [-0.008, 0.005],
      [-0.003, -0.007],
      [0.010, 0.003],
      [-0.007, -0.004],
      [0.002, 0.011],
      [-0.009, 0.006],
    ];
    if (index >= offsets.length) return center;
    return LatLng(
      center.latitude + offsets[index][0],
      center.longitude + offsets[index][1],
    );
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
                        request.category.label,
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
                    request.urgency.label,
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
                    requestLocationText(
                      request,
                      userLatitude: _userPosition?.latitude,
                      userLongitude: _userPosition?.longitude,
                    ),
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
                child: const Text('See details'),
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
                      ? 'No requests match these filters'
                      : 'No requests available',
                  message: hasFilters
                      ? 'Try changing the filters'
                      : 'Check again later',
                  action: hasFilters
                      ? TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedCategory = null;
                              _selectedUrgency = null;
                            });
                          },
                          child: const Text('Reset filters'),
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
                            '${requests.length} ${requests.length == 1 ? 'request' : 'requests'} nearby',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        if (hasFilters)
                          Chip(
                            label: Text(
                              '${(_selectedCategory != null ? 1 : 0) + (_selectedUrgency != null ? 1 : 0)} ${(_selectedCategory != null ? 1 : 0) + (_selectedUrgency != null ? 1 : 0) == 1 ? 'filter' : 'filters'}',
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
                          userLatitude: _userPosition?.latitude,
                          userLongitude: _userPosition?.longitude,
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
                title: 'No active task',
                message: 'Accept a request to start helping',
              )
            : ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Active tasks',
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
                        userLatitude: _userPosition?.latitude,
                        userLongitude: _userPosition?.longitude,
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

class _AnimatedRequestCard extends StatelessWidget {
  final int index;
  final Request request;
  final dynamic requesterInfo;
  final double? userLatitude;
  final double? userLongitude;
  final VoidCallback onTap;

  const _AnimatedRequestCard({
    required this.index,
    required this.request,
    required this.requesterInfo,
    this.userLatitude,
    this.userLongitude,
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
        userLatitude: userLatitude,
        userLongitude: userLongitude,
        onTap: onTap,
      ),
    );
  }
}
