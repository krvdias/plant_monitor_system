import 'package:flutter/material.dart';
import '../models/plant_data.dart';

class WeatherBanner extends StatelessWidget {
  final double temperature;
  final double humidity;

  const WeatherBanner({
    super.key,
    required this.temperature,
    required this.humidity,
  });

  @override
  Widget build(BuildContext context) {
    final condition = predictWeather(temperature, humidity);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: _gradient(condition),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _shadowColor(condition),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Row(
        children: [
          Text(condition.emoji, style: const TextStyle(fontSize: 52)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weather Forecast',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  condition.label,
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${temperature.toStringAsFixed(1)}°C  •  ${humidity.toStringAsFixed(0)}% Humidity',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  LinearGradient _gradient(WeatherCondition c) {
    switch (c) {
      case WeatherCondition.sunny:
        return const LinearGradient(
          colors: [Color(0xFFFFB347), Color(0xFFFF6B35)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case WeatherCondition.hot:
        return const LinearGradient(
          colors: [Color(0xFFFF4E50), Color(0xFFF9D423)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case WeatherCondition.partlyCloudy:
        return const LinearGradient(
          colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case WeatherCondition.cloudy:
        return const LinearGradient(
          colors: [Color(0xFF6D8299), Color(0xFF3A4A5C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case WeatherCondition.rainy:
        return const LinearGradient(
          colors: [Color(0xFF3A7BD5), Color(0xFF00D2FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFF2C3E50), Color(0xFF3D5168)],
        );
    }
  }

  Color _shadowColor(WeatherCondition c) {
    switch (c) {
      case WeatherCondition.sunny: return Colors.orange.withOpacity(0.4);
      case WeatherCondition.hot: return Colors.red.withOpacity(0.4);
      case WeatherCondition.rainy: return Colors.blue.withOpacity(0.4);
      default: return Colors.black.withOpacity(0.3);
    }
  }
}
