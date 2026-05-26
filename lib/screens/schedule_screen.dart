import 'dart:async';
import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/plant_data.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final _db = DatabaseService();
  ScheduleData _schedule = ScheduleData();
  bool _isLoading = false;
  bool _initialLoaded = false; // only auto-sync from Firebase until first user edit
  StreamSubscription<ScheduleData>? _scheduleSub;

  @override
  void initState() {
    super.initState();
    // Subscribe to the live Firebase stream so _schedule always reflects reality
    _scheduleSub = _db.scheduleStream.listen((s) {
      if (mounted && !_initialLoaded) {
        // Auto-sync until user makes their first change
        setState(() {
          _schedule = s;
          _initialLoaded = true;
        });
      } else if (mounted && _initialLoaded) {
        // After user edits, still reflect external changes (e.g. ESP32 writes)
        // but don't override unsaved user edits — we only update isActive from stream
        // (commented out intentionally to preserve mid-edit state)
      }
    });
  }

  @override
  void dispose() {
    _scheduleSub?.cancel();
    super.dispose();
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
          hour: _schedule.wateringHour, minute: _schedule.wateringMinute),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF6BCB77),
              onPrimary: Colors.black,
              surface: Color(0xFF1E2A3A),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _schedule = ScheduleData(
          wateringHour: picked.hour,
          wateringMinute: picked.minute,
          endHour: _schedule.endHour,
          endMinute: _schedule.endMinute,
          isActive: _schedule.isActive,
        );
      });
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
          hour: _schedule.endHour, minute: _schedule.endMinute),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF6BCB77),
              onPrimary: Colors.black,
              surface: Color(0xFF1E2A3A),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _schedule = ScheduleData(
          wateringHour: _schedule.wateringHour,
          wateringMinute: _schedule.wateringMinute,
          endHour: picked.hour,
          endMinute: picked.minute,
          isActive: _schedule.isActive,
        );
      });
    }
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    await _db.setSchedule(
      hour: _schedule.wateringHour,
      minute: _schedule.wateringMinute,
      endHour: _schedule.endHour,
      endMinute: _schedule.endMinute,
      isActive: _schedule.isActive,
    );
    setState(() => _isLoading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Schedule saved!', style: TextStyle()),
          backgroundColor: const Color(0xFF6BCB77),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1923),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1923),
        elevation: 0,
        title: Text('Watering Schedule',
            style: TextStyle(
                fontWeight: FontWeight.w700, color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Enable/Disable Toggle
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2A3A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.schedule_rounded,
                      color: Color(0xFF6BCB77), size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Enable Scheduling',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                        Text('Auto-water plant at set time',
                            style: TextStyle(
                                fontSize: 12, color: Colors.white54)),
                      ],
                    ),
                  ),
                  Switch(
                    value: _schedule.isActive,
                    onChanged: (v) =>
                        setState(() => _schedule = ScheduleData(
                              wateringHour: _schedule.wateringHour,
                              wateringMinute: _schedule.wateringMinute,
                              endHour: _schedule.endHour,
                              endMinute: _schedule.endMinute,
                              isActive: v,
                            )),
                    activeColor: const Color(0xFF6BCB77),
                    activeTrackColor: const Color(0xFF6BCB77).withOpacity(0.3),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Time Pickers Row
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _pickStartTime,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _schedule.isActive
                              ? [const Color(0xFF1A3A2A), const Color(0xFF1E2A3A)]
                              : [const Color(0xFF1A1A2A), const Color(0xFF1E2A3A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _schedule.isActive
                              ? const Color(0xFF6BCB77).withValues(alpha: 0.4)
                              : Colors.white10,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Start Time',
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.white54,
                                letterSpacing: 1),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _schedule.timeString,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: _schedule.isActive
                                  ? const Color(0xFF6BCB77)
                                  : Colors.white38,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Icon(Icons.touch_app, color: Colors.white38, size: 16),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: _pickEndTime,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _schedule.isActive
                              ? [const Color(0xFF3A1A1A), const Color(0xFF1E2A3A)]
                              : [const Color(0xFF1A1A2A), const Color(0xFF1E2A3A)],
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _schedule.isActive
                              ? const Color(0xFFEF5350).withValues(alpha: 0.4)
                              : Colors.white10,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'End Time',
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.white54,
                                letterSpacing: 1),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _schedule.endString,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: _schedule.isActive
                                  ? const Color(0xFFEF5350)
                                  : Colors.white38,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Icon(Icons.touch_app, color: Colors.white38, size: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A2A3A),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.blue.withOpacity(0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: Colors.blue, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'If soil moisture is already at or above your target when the schedule fires, watering will be skipped and you\'ll receive a notification.',
                      style: TextStyle(
                          fontSize: 12, color: Colors.white60, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6BCB77),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : Text('Save Schedule',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
