import 'package:flutter/material.dart';

class DeliverySettingsPage extends StatefulWidget {
  const DeliverySettingsPage({super.key});

  @override
  State<DeliverySettingsPage> createState() => _DeliverySettingsPageState();
}

class _DeliverySettingsPageState extends State<DeliverySettingsPage> {
  final _formKey = GlobalKey<FormState>();
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  final TextEditingController _estimatedMinutesController =
      TextEditingController();
  final TextEditingController _radiusController = TextEditingController();
  final TextEditingController _foodDetailsController = TextEditingController();

  @override
  void dispose() {
    _estimatedMinutesController.dispose();
    _radiusController.dispose();
    _foodDetailsController.dispose();
    super.dispose();
  }

  Future<void> _pickTime(bool isStart) async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(context: context, initialTime: now);
    if (picked != null) {
      setState(() {
        if (isStart)
          _startTime = picked;
        else
          _endTime = picked;
      });
    }
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Delivery settings saved')));
  }

  String? _validateNumber(String? v) {
    if (v == null || v.trim().isEmpty) return 'Enter a value';
    final n = double.tryParse(v);
    if (n == null) return 'Invalid number';
    if (n < 0) return 'Must be positive';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Delivery Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Delivery Time Window',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _pickTime(true),
                          child: Text(
                            _startTime == null
                                ? 'Start time'
                                : _startTime!.format(context),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _pickTime(false),
                          child: Text(
                            _endTime == null
                                ? 'End time'
                                : _endTime!.format(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Estimated Delivery',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _estimatedMinutesController,
                    decoration: const InputDecoration(
                      labelText: 'Estimated time (minutes)',
                      prefixIcon: Icon(Icons.timer),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: false,
                    ),
                    validator: (v) {
                      final err = _validateNumber(v);
                      if (err != null) return err;
                      final n = int.tryParse(v!.trim());
                      if (n == null) return 'Enter whole minutes';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _radiusController,
                    decoration: const InputDecoration(
                      labelText: 'Delivery radius (km)',
                      prefixIcon: Icon(Icons.map),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: _validateNumber,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Details of Food',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _foodDetailsController,
                    decoration: const InputDecoration(
                      labelText: 'Food details (allergens, packaging, notes)',
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    onPressed: _save,
                    child: const Text('Save Delivery Settings'),
                  ),
                  const SizedBox(height: 8),
                  if (_startTime != null || _endTime != null)
                    Text(
                      'Window: ${_startTime?.format(context) ?? '-'} — ${_endTime?.format(context) ?? '-'}',
                    ),
                  if (_estimatedMinutesController.text.isNotEmpty)
                    Text('Estimated: ${_estimatedMinutesController.text} min'),
                  if (_radiusController.text.isNotEmpty)
                    Text('Radius: ${_radiusController.text} km'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
