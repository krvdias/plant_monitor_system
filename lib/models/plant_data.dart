class SensorData {
  final double temperature;    // DHT11 ambient temperature
  final double humidity;       // DHT11 humidity
  final int moisturePercent;   // Capacitive soil moisture (0–100%)
  final int moistureRaw;       // Raw ADC value (0–4095)
  final bool isRaining;        // HW-477 rain sensor (true = rain detected)

  SensorData({
    this.temperature = 0.0,
    this.humidity = 0.0,
    this.moisturePercent = 0,
    this.moistureRaw = 0,
    this.isRaining = false,
  });

  factory SensorData.fromMap(Map<dynamic, dynamic> map) {
    return SensorData(
      temperature:     (map['temperature']      ?? 0.0).toDouble(),
      humidity:        (map['humidity']          ?? 0.0).toDouble(),
      moisturePercent: (map['moisture_percent']  ?? 0).toInt(),
      moistureRaw:     (map['moisture_raw']      ?? 0).toInt(),
      isRaining:        map['is_raining']        ?? false,
    );
  }
}

class ControlData {
  final bool manualValveOn;
  final int expectedMoisturePercent;
  final bool valveState; // actual valve state reported by ESP32

  ControlData({
    this.manualValveOn = false,
    this.expectedMoisturePercent = 60,
    this.valveState = false,
  });

  factory ControlData.fromMap(Map<dynamic, dynamic> map) {
    return ControlData(
      manualValveOn:           map['manual_valve_on']            ?? false,
      expectedMoisturePercent: (map['expected_moisture_percent'] ?? 60).toInt(),
      valveState:               map['valve_state']               ?? false,
    );
  }
}

class ScheduleData {
  final int wateringHour;
  final int wateringMinute;
  final int endHour;
  final int endMinute;
  final bool isActive;

  ScheduleData({
    this.wateringHour = 8,
    this.wateringMinute = 0,
    this.endHour = 8,
    this.endMinute = 15,
    this.isActive = false,
  });

  factory ScheduleData.fromMap(Map<dynamic, dynamic> map) {
    return ScheduleData(
      wateringHour:   (map['watering_hour']   ?? 8).toInt(),
      wateringMinute: (map['watering_minute'] ?? 0).toInt(),
      endHour:        (map['end_hour']        ?? map['watering_hour'] ?? 8).toInt(),
      endMinute:      (map['end_minute']      ?? (map['watering_minute'] ?? 0) + 15).toInt(),
      isActive:        map['is_active']       ?? false,
    );
  }

  String _formatTime(int h, int m) {
    final minuteStr  = m.toString().padLeft(2, '0');
    final period     = h >= 12 ? 'PM' : 'AM';
    final displayHour = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '${displayHour.toString().padLeft(2, '0')}:$minuteStr $period';
  }

  String get timeString => _formatTime(wateringHour, wateringMinute);
  String get endString  => _formatTime(endHour, endMinute);
  String get slotString => '$timeString - $endString';
}

enum WeatherCondition { sunny, partlyCloudy, cloudy, rainy, hot, unknown }

extension WeatherConditionExt on WeatherCondition {
  String get label {
    switch (this) {
      case WeatherCondition.sunny:        return 'Sunny & Dry';
      case WeatherCondition.partlyCloudy: return 'Partly Cloudy';
      case WeatherCondition.cloudy:       return 'Overcast';
      case WeatherCondition.rainy:        return 'Rainy — Watering Paused';
      case WeatherCondition.hot:          return 'Hot & Arid';
      case WeatherCondition.unknown:      return 'Reading...';
    }
  }

  String get emoji {
    switch (this) {
      case WeatherCondition.sunny:        return '☀️';
      case WeatherCondition.partlyCloudy: return '⛅';
      case WeatherCondition.cloudy:       return '☁️';
      case WeatherCondition.rainy:        return '🌧️';
      case WeatherCondition.hot:          return '🌡️';
      case WeatherCondition.unknown:      return '🔄';
    }
  }
}

/// Derives a weather condition from sensor readings.
/// [isRaining] = true forces WeatherCondition.rainy regardless of DHT values.
WeatherCondition predictWeather(double temp, double humidity, {bool isRaining = false}) {
  if (isRaining) return WeatherCondition.rainy;
  if (humidity > 80 && temp < 28) return WeatherCondition.rainy;
  if (humidity > 70 && temp < 32) return WeatherCondition.cloudy;
  if (humidity > 55)              return WeatherCondition.partlyCloudy;
  if (temp > 35 && humidity < 40) return WeatherCondition.hot;
  return WeatherCondition.sunny;
}
