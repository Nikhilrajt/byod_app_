// lib/state/health_mode_notifier.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HealthModeNotifier extends ChangeNotifier {
  bool _isOn;

  HealthModeNotifier([this._isOn = false]);

  bool get isOn => _isOn;

  void toggle() {
    _isOn = !_isOn;
    notifyListeners();
    _save();
  }

  void setOn(bool v) {
    _isOn = v;
    notifyListeners();
    _save();
  }

  // persist to SharedPreferences (optional)
  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('health_mode', _isOn);
    } catch (_) {}
  }

  // load saved value (call before runApp)
  static Future<bool> loadSaved() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('health_mode') ?? false;
    } catch (_) {
      return false;
    }
  }
}
