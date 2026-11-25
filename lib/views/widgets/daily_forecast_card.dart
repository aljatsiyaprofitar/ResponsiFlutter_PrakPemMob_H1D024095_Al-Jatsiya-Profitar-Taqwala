import 'package:flutter/material.dart';
import '../../utils/weather_utils.dart';
import '../../models/weather_model.dart';

class DailyForecastCard extends StatelessWidget {
  final DailyWeather daily;

  const DailyForecastCard({super.key, required this.daily});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              WeatherUtils.formatDayName(daily.date),
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            WeatherUtils.getWeatherIcon(daily.weatherCode),
            style: const TextStyle(fontSize: 22),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              WeatherUtils.getWeatherDescription(daily.weatherCode),
              style: const TextStyle(color: Colors.white60, fontSize: 12),
            ),
          ),
          if (daily.precipitationProbabilityMax > 0) ...[
            const Icon(Icons.water_drop, color: Colors.lightBlueAccent, size: 14),
            const SizedBox(width: 2),
            Text(
              '${daily.precipitationProbabilityMax}%',
              style: const TextStyle(color: Colors.lightBlueAccent, fontSize: 12),
            ),
            const SizedBox(width: 8),
          ],
          Text(
            '${daily.temperatureMin.round()}°',
            style: const TextStyle(color: Colors.white54, fontSize: 14),
          ),
          const Text(
            ' / ',
            style: TextStyle(color: Colors.white38, fontSize: 14),
          ),
          Text(
            '${daily.temperatureMax.round()}°',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
