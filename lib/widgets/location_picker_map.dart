import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../services/location_service.dart';
import '../utils/theme.dart';

class LocationPickerResult {
  final double latitude;
  final double longitude;
  final String addressText;

  const LocationPickerResult({
    required this.latitude,
    required this.longitude,
    required this.addressText,
  });
}

class LocationPickerMap extends StatefulWidget {
  final LocationPickerResult? initial;

  const LocationPickerMap({super.key, this.initial});

  @override
  State<LocationPickerMap> createState() => _LocationPickerMapState();
}

class _LocationPickerMapState extends State<LocationPickerMap> {
  final MapController _mapController = MapController();
  final TextEditingController _addressController = TextEditingController();

  LatLng _center = const LatLng(44.4268, 26.1025);
  bool _loadingGps = true;

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      _center = LatLng(widget.initial!.latitude, widget.initial!.longitude);
      _addressController.text = widget.initial!.addressText;
      _loadingGps = false;
    } else {
      _fetchGps();
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _fetchGps() async {
    try {
      final Position? pos = await LocationService.getCurrentPosition();
      if (pos != null && mounted) {
        setState(() {
          _center = LatLng(pos.latitude, pos.longitude);
          _loadingGps = false;
        });
        _mapController.move(_center, 15);
      } else {
        if (mounted) setState(() => _loadingGps = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loadingGps = false);
    }
  }

  void _onConfirm() {
    final camera = _mapController.camera;
    final picked = camera.center;
    final address = _addressController.text.trim();

    if (address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add a short address description'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.of(context).pop(
      LocationPickerResult(
        latitude: picked.latitude,
        longitude: picked.longitude,
        addressText: address,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick location'),
        actions: [
          TextButton(
            onPressed: _onConfirm,
            child: const Text(
              'Confirm',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: _loadingGps
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Getting your location…'),
                ],
              ),
            )
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _center,
                    initialZoom: 15,
                    onMapEvent: (event) {
                      if (mounted) {
                        setState(() {
                          _center = _mapController.camera.center;
                        });
                      }
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.linko.app',
                    ),
                  ],
                ),

                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 48,
                        color: AppTheme.primaryColor,
                        shadows: const [
                          Shadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      Container(
                        width: 8,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),

                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 24,
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pan the map to place the pin',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(color: AppTheme.textSecondary),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _addressController,
                            decoration: const InputDecoration(
                              labelText: 'Address description',
                              hintText: 'e.g. Near Catena pharmacy, Dorobanti St.',
                              prefixIcon: Icon(Icons.edit_location_alt),
                            ),
                            textCapitalization: TextCapitalization.sentences,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _onConfirm,
                              icon: const Icon(Icons.check),
                              label: const Text('Confirm location'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Positioned(
                  right: 16,
                  bottom: 220,
                  child: FloatingActionButton.small(
                    heroTag: 'picker_recenter',
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryColor,
                    elevation: 4,
                    onPressed: _fetchGps,
                    child: const Icon(Icons.my_location),
                  ),
                ),
              ],
            ),
    );
  }
}
