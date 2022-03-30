import 'dart:async';
import 'package:flutter/material.dart';

class TimerController extends ValueNotifier<int> {
  Timer? _timer;

  TimerController({int initialValue = 0}) : super(initialValue);

  get isRunning => _timer != null;

  get isStopped => _timer == null;

  get formattedTime {
    final hours = value ~/ 3600;
    final minutes = value ~/ 60;
    final seconds = value % 60;

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void start() {
    _startTimer();
  }

  void stop() {
    _stopTimer();
  }

  void reset() {
    value = 0;
    _stopTimer();
  }

  void _startTimer() {
    _timer ??= Timer.periodic(const Duration(seconds: 1), (timer) => value++);
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }
}
