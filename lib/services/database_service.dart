import 'package:firebase_database/firebase_database.dart';
import '../models/plant_data.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  final DatabaseReference _root =
      FirebaseDatabase.instance.ref('plant_monitor');

  // ─── Streams ───────────────────────────────────────────────────────────────

  Stream<SensorData> get sensorStream {
    return _root.child('sensors').onValue.map((event) {
      if (event.snapshot.value == null) return SensorData();
      return SensorData.fromMap(
          event.snapshot.value as Map<dynamic, dynamic>);
    }).asBroadcastStream();
  }

  Stream<ControlData> get controlStream {
    return _root.child('controls').onValue.map((event) {
      if (event.snapshot.value == null) return ControlData();
      return ControlData.fromMap(
          event.snapshot.value as Map<dynamic, dynamic>);
    }).asBroadcastStream();
  }

  Stream<ScheduleData> get scheduleStream {
    return _root.child('schedule').onValue.map((event) {
      if (event.snapshot.value == null) return ScheduleData();
      return ScheduleData.fromMap(
          event.snapshot.value as Map<dynamic, dynamic>);
    }).asBroadcastStream();
  }

  Stream<String> get notificationStream {
    return _root.child('notifications/skip_message').onValue.map((event) {
      return event.snapshot.value?.toString() ?? '';
    }).asBroadcastStream();
  }

  // ─── Writes ────────────────────────────────────────────────────────────────

  Future<void> setManualValve(bool isOn) async {
    await _root.child('controls/manual_valve_on').set(isOn);
  }

  Future<void> setExpectedMoisture(int percent) async {
    await _root.child('controls/expected_moisture_percent').set(percent);
  }

  Future<void> setSchedule({
    required int hour,
    required int minute,
    required int endHour,
    required int endMinute,
    required bool isActive,
  }) async {
    await _root.child('schedule').update({
      'watering_hour': hour,
      'watering_minute': minute,
      'end_hour': endHour,
      'end_minute': endMinute,
      'is_active': isActive,
    });
  }

  Future<void> clearNotification() async {
    await _root.child('notifications/skip_message').set('');
  }
}
