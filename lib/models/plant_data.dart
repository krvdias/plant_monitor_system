class SensorData {
  final double temperatureAmbient;
  final double humidity;
  final double temperatureSoil;
  final int moisturePercent;

  SensorData({
    this.temperatureAmbient = 0.0,
    this.humidity = 0.0,
    this.temperatureSoil = 0.0,
    this.moisturePercent = 0,
  });

  factory SensorData.fromMap(Map<dynamic, dynamic> map) {
    return SensorData(
      temperatureAmbient: (map['temperature_ambient'] ?? 0.0).toDouble(),
      humidity: (map['humidity'] ?? 0.0).toDouble(),
      temperatureSoil: (map['temperature_soil'] ?? 0.0).toDouble(),
      moisturePercent: (map['moisture_percent'] ?? 0).toInt(),
    );
  }
}

class ControlData {
  final bool manualValveOn;
  final int expectedMoisturePercent;

  ControlData({
    this.manualValveOn = false,
    this.expectedMoisturePercent = 60,
  });

  factory ControlData.fromMap(Map<dynamic, dynamic> map) {
    return ControlData(
      manualValveOn: map['manual_valve_on'] ?? false,
      expectedMoisturePercent: (map['expected_moisture_percent'] ?? 60).toInt(),
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
      wateringHour: (map['watering_hour'] ?? 8).toInt(),
      wateringMinute: (map['watering_minute'] ?? 0).toInt(),
      endHour: (map['end_hour'] ?? map['watering_hour'] ?? 8).toInt(),
      endMinute: (map['end_minute'] ?? (map['watering_minute'] ?? 0) + 15).toInt(),
      isActive: map['is_active'] ?? false,
    );
  }

  String _formatTime(int h, int m) {
    final minuteStr = m.toString().padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final displayHour = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '${displayHour.toString().padLeft(2, '0')}:$minuteStr $period';
  }

  String get timeString => _formatTime(wateringHour, wateringMinute);
  String get endString => _formatTime(endHour, endMinute);
  String get slotString => '$timeString - $endString';
}

enum WeatherCondition { sunny, partlyCloudy, cloudy, rainy, hot, unknown }

extension WeatherConditionExt on WeatherCondition {
  String get label {
    switch (this) {
      case WeatherCondition.sunny: return 'Sunny & Dry';
      case WeatherCondition.partlyCloudy: return 'Partly Cloudy';
      case WeatherCondition.cloudy: return 'Overcast';
      case WeatherCondition.rainy: return 'Rainy / Humid';
      case WeatherCondition.hot: return 'Hot & Arid';
      case WeatherCondition.unknown: return 'Reading...';
    }
  }

  String get emoji {
    switch (this) {
      case WeatherCondition.sunny: return '☀️';
      case WeatherCondition.partlyCloudy: return '⛅';
      case WeatherCondition.cloudy: return '☁️';
      case WeatherCondition.rainy: return '🌧️';
      case WeatherCondition.hot: return '🌡️';
      case WeatherCondition.unknown: return '🔄';
    }
  }
}

WeatherCondition predictWeather(double temp, double humidity) {
  if (humidity > 80 && temp < 28) return WeatherCondition.rainy;
  if (humidity > 70 && temp < 32) return WeatherCondition.cloudy;
  if (humidity > 55) return WeatherCondition.partlyCloudy;
  if (temp > 35 && humidity < 40) return WeatherCondition.hot;
  return WeatherCondition.sunny;
}
