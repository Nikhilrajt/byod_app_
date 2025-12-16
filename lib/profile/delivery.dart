import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Delivery extends StatefulWidget {
  const Delivery({super.key});

  @override
  State<Delivery> createState() => _DeliveryState();
}

class _DeliveryState extends State<Delivery>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  // Simulation values
  double _distanceKm = 2.0; // start closer for the 'accept/assign' style mock
  final double _speedKmph = 30; // assumed average rider speed
  AnimationController? _riderController;

  // countdown timer for the accept CTA (example from mock)
  late AnimationController _countdownController;
  final Duration _countdown = const Duration(seconds: 45);

  // Mannarkkad, Palakkad, Kerala (approximate)
  String _pickup = 'Getting current location...';
  String _drop = 'Nearby Drop Location, Mannarkkad';

  // coordinates (approximate Mannarkkad)
  LatLng _pickupLatLng = LatLng(10.9881, 76.4731);
  String pickup = 'Mannarkkad';

  // coordinates (approximate Mannarkkad)
  LatLng _dropLatLng = LatLng(10.8550, 76.6050);
  late LatLng _riderLatLng;
  final MapController _mapController = MapController();
  final double _zoom = 14.0;
  bool? _tilesAvailable;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _countdownController = AnimationController(
      vsync: this,
      duration: _countdown,
    );
    _countdownController.addListener(() => setState(() {}));
    _countdownController.forward();
    // start rider near pickup so map centers on Mannarkkad
    _riderLatLng = LatLng(
      _pickupLatLng.latitude + 0.001,
      _pickupLatLng.longitude + 0.001,
    );
    _getCurrentLocation();
    // move map to initial rider position after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        _mapController.move(_pickupLatLng, 14.0);
      } catch (_) {}
      // quick check whether OSM tiles can be fetched from this device
      _checkTile();
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      setState(() {
        _pickupLatLng = LatLng(position.latitude, position.longitude);
        _pickup = placemarks.first.name ?? 'Unknown Location';
        _riderLatLng = LatLng(
          _pickupLatLng.latitude + 0.001,
          _pickupLatLng.longitude + 0.001,
        );
        _mapController.move(_pickupLatLng, 14.0);
        _startSimulation();
      });
    } catch (e) {
      setState(() {
        _pickup = 'Could not get location';
      });
    }
  }

  Future<void> _checkTile() async {
    const tileUrl = 'https://a.tile.openstreetmap.org/14/4823/6160.png';
    try {
      await precacheImage(NetworkImage(tileUrl), context);
      setState(() {
        _tilesAvailable = true;
      });
    } catch (e) {
      setState(() {
        _tilesAvailable = false;
      });
    }
  }

  void _startSimulation() {
    // Cancel any previous rider animation
    _riderController?.dispose();

    // Estimate seconds for rider to reach drop using distance/speed
    final hours = (_distanceKm / _speedKmph).clamp(0.0, 1000.0);
    final seconds = (hours * 3600).ceil();

    _riderController = AnimationController(
      vsync: this,
      duration: Duration(seconds: seconds > 0 ? seconds : 5),
    );

    final tween = LatLngTween(begin: _riderLatLng, end: _dropLatLng);
    _riderController!.addListener(() {
      setState(() {
        _riderLatLng = tween.evaluate(_riderController!);
        // update distance based on remaining fraction
        final remainingFraction = 1.0 - _riderController!.value;
        _distanceKm = (_distanceKm * remainingFraction).clamp(
          0.0,
          double.infinity,
        );
        try {
          _mapController.move(_riderLatLng, _zoom);
        } catch (_) {}
      });
    });

    _riderController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _distanceKm = 0.0);
      }
    });

    _riderController!.forward();
  }

  @override
  void dispose() {
    _riderController?.dispose();
    _countdownController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  String get _distanceText {
    if (_distanceKm >= 1.0) return '${_distanceKm.toStringAsFixed(1)} km';
    return '${(_distanceKm * 1000).toStringAsFixed(0)} m';
  }

  String get _etaText {
    if (_distanceKm <= 0.05) return 'Arriving';
    final hours = _distanceKm / _speedKmph;
    final mins = (hours * 60).ceil();
    return '$mins Min To Reach';
  }

  void _accept() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Accepted')));
  }

  void _save() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Saved')));
  }

  void _searchAndSetDropLocation() async {
    try {
      List<Location> locations = await locationFromAddress(
        _searchController.text,
      );
      if (locations.isNotEmpty) {
        setState(() {
          _dropLatLng = LatLng(
            locations.first.latitude,
            locations.first.longitude,
          );
          _drop = _searchController.text;
          _startSimulation();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not find location')));
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery'),
      ),
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSearch(),
              const SizedBox(height: 12),
              Expanded(
                child: Stack(
                  children: [
                    _mapWidget(),
                    if (_tilesAvailable == false)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.wifi_off,
                                    size: 42,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Tiles unreachable — check network',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _infoCard(),
              const SizedBox(height: 12),
              _buildButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearch() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search for a drop-off location',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: _searchAndSetDropLocation,
          icon: const Icon(Icons.search),
        ),
      ],
    );
  }

  Widget _mapWidget() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _pickupLatLng,
          initialZoom: _zoom,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
          ),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
          ),
          PolylineLayer(
            polylines: [
              Polyline(
                points: [_pickupLatLng, _riderLatLng, _dropLatLng],
                color: Colors.deepOrange.withOpacity(0.8),
                strokeWidth: 4.0,
              ),
            ],
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 40,
                height: 40,
                point: _pickupLatLng,
                child: const Icon(Icons.location_on, color: Colors.green),
              ),
              Marker(
                width: 40,
                height: 40,
                point: _riderLatLng,
                child: const FaIcon(
                  FontAwesomeIcons.bicycle,
                  color: Colors.deepOrange,
                ),
              ),
              Marker(
                width: 36,
                height: 36,
                point: _dropLatLng,
                child: const Icon(Icons.flag, color: Colors.redAccent),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoCard() {
    return Card(
      color: Colors.grey.shade900,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _pickup,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      Text(_drop, style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _etaText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _distanceText,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: const [
                        Text(
                          'Booking Type',
                          style: TextStyle(color: Colors.white54),
                        ),
                        SizedBox(height: 6),
                        Text('Now', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: const [
                        Text(
                          'Payment Method',
                          style: TextStyle(color: Colors.white54),
                        ),
                        SizedBox(height: 6),
                        Text('Cash', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: _accept,
            child: const Text('Accept', style: TextStyle(fontSize: 16)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(onPressed: _save, child: const Text('Save')),
        ),
      ],
    );
  }
}

class LatLngTween extends Tween<LatLng> {
  LatLngTween({required LatLng begin, required LatLng end})
    : super(begin: begin, end: end);

  @override
  LatLng lerp(double t) {
    return LatLng(
      begin!.latitude + (end!.latitude - begin!.latitude) * t,
      begin!.longitude + (end!.longitude - begin!.longitude) * t,
    );
  }
}