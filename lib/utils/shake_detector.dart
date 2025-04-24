import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

class ShakeDetector {
  final Function onShake;

  // For shake detection
  final double shakeThreshold;
  final int minTimeBetweenShakes;
  final int shakeCountRequired;

  // Keep track of shake events
  int _shakeCount = 0;
  int _lastShakeTimestamp = 0;

  // Last acceleration values
  double _lastX = 0.0;
  double _lastY = 0.0;
  double _lastZ = 0.0;

  bool _listenStarted = false;

  ShakeDetector({
    required this.onShake,
    this.shakeThreshold = 3.0, // Increased threshold for less sensitivity
    this.minTimeBetweenShakes = 1000, // Increased time between shakes
    this.shakeCountRequired = 1, // Reduced to 1 for more immediate response
  });

  void startListening() {
    if (_listenStarted) return;

    _listenStarted = true;
    _shakeCount = 0;
    _lastShakeTimestamp = 0;

    accelerometerEvents.listen((AccelerometerEvent event) {
      _detectShake(event);
    });
  }

  void _detectShake(AccelerometerEvent event) {
    int now = DateTime.now().millisecondsSinceEpoch;

    // If the last shake was too recent, ignore this event
    if ((now - _lastShakeTimestamp) < minTimeBetweenShakes) {
      return;
    }

    // Calculate delta from last values
    double deltaX = event.x - _lastX;
    double deltaY = event.y - _lastY;
    double deltaZ = event.z - _lastZ;

    // Update last values
    _lastX = event.x;
    _lastY = event.y;
    _lastZ = event.z;

    // Calculate acceleration magnitude
    double acceleration =
        sqrt(deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ) / 9.8;

    if (acceleration > shakeThreshold) {
      _lastShakeTimestamp = now;
      _shakeCount++;

      if (_shakeCount >= shakeCountRequired) {
        _shakeCount = 0;
        onShake();
      }
    }
  }
}
