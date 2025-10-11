import 'dart:async';
import 'package:flutter/material.dart';

class Delivery extends StatefulWidget {
  const Delivery({super.key});

  @override
  State<Delivery> createState() => _DeliveryState();
}

class _DeliveryState extends State<Delivery> {
  // Simulation values
  double _distanceKm = 4.8; // how far the rider is from the restaurant (km)
  final double _initialDistanceKm = 4.8;
  final double _speedKmph = 25; // assumed average rider speed
  Timer? _tick;

  // mock order/agent
  final String _orderId = 'BYOD-10234';
  final String _itemSummary = '1 x Classic Cheese Pizza · ₹399';
  final String _riderName = 'Ramesh';
  final String _riderPhone = '+91 98765 43210';

  @override
  void initState() {
    super.initState();
    _startSimulation();
  }

  void _startSimulation() {
    _tick?.cancel();
    // every 4 seconds reduce distance by a bit (based on speed)
    _tick = Timer.periodic(const Duration(seconds: 4), (_) {
      setState(() {
        // distance reduction per tick = speed (km/h) * (seconds/3600)
        final reduction = _speedKmph * (4.0 / 3600.0);
        _distanceKm = (_distanceKm - reduction).clamp(
          0.0,
          -0.1,
        ); // Allows it to go slightly negative to ensure final status
        if (_distanceKm <= -0.05) {
          // Stop simulation slightly past zero
          _tick?.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  String get _distanceText {
    if (_distanceKm >= 1.0) return '${_distanceKm.toStringAsFixed(1)} km';
    if (_distanceKm > 0.1)
      return '${(_distanceKm * 1000).toStringAsFixed(0)} m';
    return '0 m';
  }

  String get _etaText {
    // ETA in minutes from current distance and speed
    if (_distanceKm <= 0.0) return 'Delivered';
    if (_distanceKm <= 0.5) return 'Arriving';
    final hours = _distanceKm / _speedKmph;
    final mins = (hours * 60).ceil();
    return '$mins min';
  }

  double get _progress {
    // Progress calculation adjusted for 0.0 being the "end" of tracking
    final covered = (_initialDistanceKm - _distanceKm).clamp(
      0.0,
      _initialDistanceKm,
    );
    return (_initialDistanceKm > 0)
        ? (covered / _initialDistanceKm).clamp(0.0, 1.0)
        : 1.0;
  }

  void _callRider() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Calling $_riderPhone...')));
  }

  void _messageRider() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Opening chat with rider...')));
  }

  void _resetSimulation() {
    setState(() {
      _distanceKm = _initialDistanceKm;
    });
    _startSimulation();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Refreshing location...')));
  }

  Widget _buildMapPlaceholder() {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const Center(child: Icon(Icons.map, size: 72, color: Colors.grey)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Helper to determine if a status is active
    final bool isAccepted =
        _distanceKm < _initialDistanceKm; // always true after start
    final bool isReady =
        _distanceKm < _initialDistanceKm - 0.5; // Arbitrary point for "Ready"
    final bool isOutForDelivery =
        _distanceKm < 3.0; // Starts "Out for Delivery" at < 3.0 km
    final bool isDelivered = _distanceKm <= 0.0; // When distance is 0 or less

    // Color to indicate active status
    const MaterialColor activeColor = Colors.deepOrange;
    const Color inactiveColor = Colors.grey;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Track your order'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: activeColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildMapPlaceholder(),
            const SizedBox(height: 12),
            // Order Summary Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order $_orderId',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _itemSummary,
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _etaText,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isDelivered ? 'Complete' : '$_distanceText away',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Rider and Progress Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: activeColor.shade50,
                          child: const Icon(Icons.person, color: activeColor),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _riderName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isDelivered
                                    ? 'Delivery Complete'
                                    : 'Rider · $_riderPhone',
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                            ],
                          ),
                        ),
                        if (!isDelivered) ...[
                          IconButton(
                            onPressed: _callRider,
                            icon: const Icon(Icons.call, color: activeColor),
                          ),
                          IconButton(
                            onPressed: _messageRider,
                            icon: const Icon(Icons.message, color: activeColor),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (!isDelivered) ...[
                      LinearProgressIndicator(
                        value: _progress,
                        backgroundColor: Colors.grey.shade200,
                        color: activeColor,
                        minHeight: 8,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${(_progress * 100).toStringAsFixed(0)}% completed',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          Text(
                            'Remaining: $_distanceText',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Simplified Delivery Status List
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Delivery status',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView(
                      children: [
                        _buildStatusTile(
                          icon: Icons.assignment_turned_in,
                          title: 'Accepted',
                          subtitle: 'We received your order',
                          isActive: isAccepted,
                        ),
                        _buildStatusTile(
                          icon: Icons.kitchen,
                          title: 'Ready',
                          subtitle: 'Restaurant has finished preparing food',
                          isActive: isReady,
                        ),
                        _buildStatusTile(
                          icon: Icons.directions_bike,
                          title: 'Out for Delivery',
                          subtitle: isOutForDelivery
                              ? (isDelivered
                                    ? 'Delivered to you'
                                    : 'Rider is $_distanceText away')
                              : 'Waiting for rider assignment',
                          isActive: isOutForDelivery,
                        ),
                        _buildStatusTile(
                          icon: Icons.check_circle,
                          title: 'Delivered',
                          subtitle: 'Enjoy your order!',
                          isActive: isDelivered,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: activeColor,
        onPressed: _resetSimulation,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  // New helper widget for status tiles
  Widget _buildStatusTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isActive,
  }) {
    const Color activeColor = Colors.deepOrange;
    const Color inactiveColor = Colors.grey;

    return ListTile(
      leading: Icon(icon, color: isActive ? activeColor : inactiveColor),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          color: isActive ? Colors.black : Colors.grey.shade700,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: isActive ? Colors.black : Colors.grey),
      ),
    );
  }
}
