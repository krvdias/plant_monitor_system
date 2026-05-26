import 'dart:async';
import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/plant_data.dart';
import '../widgets/weather_banner.dart';
import '../widgets/sensor_card.dart';
import '../widgets/moisture_gauge.dart';
import '../constants.dart';
import 'schedule_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _db = DatabaseService();

  SensorData _sensors = SensorData();
  ControlData _controls = ControlData();
  ScheduleData _schedule = ScheduleData();
  String _lastNotification = '';

  // For saturation notification
  Timer? _saturationTimer;
  StreamSubscription<SensorData>? _sensorSub;
  StreamSubscription<ControlData>? _controlSub;

  @override
  void initState() {
    super.initState();

    // Listen for Firebase-pushed notifications (schedule skip, etc.)
    _db.notificationStream.listen((msg) {
      if (msg.isNotEmpty && msg != _lastNotification) {
        _lastNotification = msg;
        _showNotificationSnackbar(msg);
      }
    });

    // Keep local copies of sensor & control data for the saturation check
    _sensorSub = _db.sensorStream.listen((s) => _sensors = s);
    _controlSub = _db.controlStream.listen((c) {
      final wasOn = _controls.manualValveOn;
      _controls = c;
      if (c.manualValveOn && !wasOn) {
        // Valve just turned ON — start repeating timer
        _startSaturationTimer();
      } else if (!c.manualValveOn && wasOn) {
        // Valve turned OFF — cancel timer
        _saturationTimer?.cancel();
        _saturationTimer = null;
      }
    });

    // Cache schedule so the dashboard card never flashes the default "disabled" state
    _db.scheduleStream.listen((s) {
      if (mounted) setState(() => _schedule = s);
    });
  }

  void _startSaturationTimer() {
    _saturationTimer?.cancel();
    // Check immediately, then every 2 minutes
    _checkSaturation();
    _saturationTimer = Timer.periodic(const Duration(minutes: 2), (_) {
      if (_controls.manualValveOn) {
        _checkSaturation();
      } else {
        _saturationTimer?.cancel();
        _saturationTimer = null;
      }
    });
  }

  void _checkSaturation() {
    if (_sensors.moisturePercent >= _controls.expectedMoisturePercent) {
      _showNotificationSnackbar(
          '💧 Expected soil moisture value saturated — consider turning off manual watering.');
    }
  }

  @override
  void dispose() {
    _saturationTimer?.cancel();
    _sensorSub?.cancel();
    _controlSub?.cancel();
    super.dispose();
  }

  void _showNotificationSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 6),
        backgroundColor: const Color(0xFF1E2A3A),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFF4ECDC4), width: 1.5),
        ),
        content: Row(
          children: [
            const Icon(Icons.notifications_active_rounded,
                color: Color(0xFF4ECDC4), size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message,
                  style: TextStyle(fontSize: 13, color: Colors.white)),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: const Color(0xFF4ECDC4),
          onPressed: () => _db.clearNotification(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1923),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              backgroundColor: const Color(0xFF0F1923),
              floating: true,
              pinned: false,
              toolbarHeight: 80,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('🌿 $appName',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          )),
                      Text('Live Dashboard • v$appVersion',
                          style: TextStyle(
                              fontSize: 12, color: Colors.white38)),
                    ],
                  ),
                  // Live indicator
                  StreamBuilder<SensorData>(
                    stream: _db.sensorStream,
                    builder: (context, snap) {
                      final connected = snap.hasData;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: (connected
                                  ? const Color(0xFF6BCB77)
                                  : Colors.red)
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: connected
                                ? const Color(0xFF6BCB77)
                                : Colors.red,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: connected
                                    ? const Color(0xFF6BCB77)
                                    : Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              connected ? 'LIVE' : 'OFFLINE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: connected
                                    ? const Color(0xFF6BCB77)
                                    : Colors.red,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Weather Banner
                  StreamBuilder<SensorData>(
                    stream: _db.sensorStream,
                    builder: (context, snap) {
                      final data = snap.data ?? SensorData();
                      return WeatherBanner(
                        temperature: data.temperature,
                        humidity: data.humidity,
                        isRaining: data.isRaining,
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Sensor Grid
                  StreamBuilder<SensorData>(
                    stream: _db.sensorStream,
                    builder: (context, snap) {
                      final data = snap.data ?? SensorData();
                      return GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.1,
                        children: [
                          SensorCard(
                            label: 'AIR TEMP',
                            value: data.temperature.toStringAsFixed(1),
                            unit: '°C',
                            icon: Icons.thermostat_rounded,
                            color: const Color(0xFFFF6B35),
                            secondaryColor: const Color(0xFFFFD93D),
                          ),
                          SensorCard(
                            label: 'HUMIDITY',
                            value: data.humidity.toStringAsFixed(0),
                            unit: '%',
                            icon: Icons.water_drop_rounded,
                            color: const Color(0xFF4ECDC4),
                            secondaryColor: const Color(0xFF00D2FF),
                          ),
                          SensorCard(
                            label: 'RAINING',
                            value: data.isRaining ? 'YES' : 'NO',
                            unit: '',
                            icon: Icons.umbrella_rounded,
                            color: const Color(0xFF3A7BD5),
                            secondaryColor: const Color(0xFF00D2FF),
                          ),
                          SensorCard(
                            label: 'MOISTURE',
                            value: data.moisturePercent.toString(),
                            unit: '%',
                            icon: Icons.water_outlined,
                            color: const Color(0xFF6BCB77),
                            secondaryColor: const Color(0xFF4ECDC4),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Moisture Gauge
                  StreamBuilder<SensorData>(
                    stream: _db.sensorStream,
                    builder: (ctxS, snapS) {
                      return StreamBuilder<ControlData>(
                        stream: _db.controlStream,
                        builder: (ctxC, snapC) {
                          final sensors = snapS.data ?? SensorData();
                          final controls = snapC.data ?? ControlData();
                          return MoistureGauge(
                            moisture: sensors.moisturePercent,
                            expected: controls.expectedMoisturePercent,
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Controls Card
                  StreamBuilder<ControlData>(
                    stream: _db.controlStream,
                    builder: (context, snap) {
                      final controls = snap.data ?? ControlData();
                      // Determine valve indicator: use actual valveState reported by ESP32
                      final valveActuallyOn = controls.valveState;
                      return Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E2A3A),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Controls',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                            const SizedBox(height: 16),

                            // Manual Valve Toggle
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: controls.manualValveOn
                                    ? const Color(0xFF6BCB77).withOpacity(0.1)
                                    : Colors.white.withOpacity(0.04),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: controls.manualValveOn
                                      ? const Color(0xFF6BCB77).withOpacity(0.5)
                                      : Colors.white10,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: (controls.manualValveOn
                                              ? const Color(0xFF6BCB77)
                                              : Colors.white38)
                                          .withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.water_rounded,
                                      color: controls.manualValveOn
                                          ? const Color(0xFF6BCB77)
                                          : Colors.white38,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Manual Watering',
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white)),
                                        const SizedBox(height: 4),
                                        // Valve ON/OFF indicator badge
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: valveActuallyOn
                                                    ? const Color(0xFF6BCB77)
                                                        .withOpacity(0.2)
                                                    : Colors.red
                                                        .withOpacity(0.15),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                border: Border.all(
                                                  color: valveActuallyOn
                                                      ? const Color(0xFF6BCB77)
                                                          .withOpacity(0.6)
                                                      : Colors.red
                                                          .withOpacity(0.4),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    width: 6,
                                                    height: 6,
                                                    decoration: BoxDecoration(
                                                      color: valveActuallyOn
                                                          ? const Color(
                                                              0xFF6BCB77)
                                                          : Colors.red,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    valveActuallyOn
                                                        ? 'Valve ON'
                                                        : 'Valve OFF',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: valveActuallyOn
                                                          ? const Color(
                                                              0xFF6BCB77)
                                                          : Colors.red,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Switch(
                                    value: controls.manualValveOn,
                                    onChanged: (v) =>
                                        _db.setManualValve(v),
                                    activeColor: const Color(0xFF6BCB77),
                                    activeTrackColor: const Color(0xFF6BCB77)
                                        .withOpacity(0.3),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Expected Moisture Slider
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Target Moisture',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white)),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6BCB77)
                                        .withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${controls.expectedMoisturePercent}%',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF6BCB77),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: const Color(0xFF6BCB77),
                                inactiveTrackColor:
                                    const Color(0xFF6BCB77).withOpacity(0.2),
                                thumbColor: const Color(0xFF6BCB77),
                                overlayColor:
                                    const Color(0xFF6BCB77).withOpacity(0.2),
                                trackHeight: 4,
                              ),
                              child: Slider(
                                value: controls.expectedMoisturePercent
                                    .toDouble(),
                                min: 10,
                                max: 90,
                                divisions: 16,
                                onChanged: (v) =>
                                    _db.setExpectedMoisture(v.round()),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('10% (Dry)',
                                    style: TextStyle(
                                        fontSize: 10, color: Colors.white38)),
                                Text('90% (Wet)',
                                    style: TextStyle(
                                        fontSize: 10, color: Colors.white38)),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Schedule Quick-View Card
                  StreamBuilder<ScheduleData>(
                    stream: _db.scheduleStream,
                    builder: (context, snap) {
                      // Use cached _schedule as fallback — prevents the card from
                      // briefly flashing "Schedule disabled" on stream reconnect
                      final schedule = snap.data ?? _schedule;
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ScheduleScreen()),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E2A3A),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: schedule.isActive
                                  ? const Color(0xFF6BCB77).withOpacity(0.3)
                                  : Colors.white10,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF6BCB77).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.schedule_rounded,
                                    color: Color(0xFF6BCB77), size: 22),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Watering Schedule',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white)),
                                    Text(
                                      schedule.isActive
                                          ? 'Slot: ${schedule.slotString}'
                                          : 'Schedule disabled',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: schedule.isActive
                                              ? const Color(0xFF6BCB77)
                                              : Colors.white38),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded,
                                  color: Colors.white38),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 30),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
