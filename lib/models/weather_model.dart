class CurrentWeather {
  final double temperature;
  final double apparentTemperature;
  final int relativeHumidity;
  final double precipitation;
  final int weatherCode;
  final double windSpeed;

  CurrentWeather({
    required this.temperature,
    required this.apparentTemperature,
    required this.relativeHumidity,
    required this.precipitation,
    required this.weatherCode,
    required this.windSpeed,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      temperature: (json['temperature_2m'] as num).toDouble(),
      apparentTemperature: (json['apparent_temperature'] as num).toDouble(),
      relativeHumidity: (json['relative_humidity_2m'] as num).toInt(),
      precipitation: (json['precipitation'] as num).toDouble(),
      weatherCode: (json['weather_code'] as num).toInt(),
      windSpeed: (json['wind_speed_10m'] as num).toDouble(),
    );
  }
}

class DailyWeather {
  final String date;
  final double temperatureMax;
  final double temperatureMin;
  final int precipitationProbabilityMax;
  final int weatherCode;

  DailyWeather({
    required this.date,
    required this.temperatureMax,
    required this.temperatureMin,
    required this.precipitationProbabilityMax,
    required this.weatherCode,
  });
}

class WeatherData {
  final CurrentWeather current;
  final List<DailyWeather> daily;

  WeatherData({required this.current, required this.daily});

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final currentJson = json['current'] as Map<String, dynamic>;
    final currentWeather = CurrentWeather.fromJson(currentJson);

    final dailyJson = json['daily'] as Map<String, dynamic>;
    final times = dailyJson['time'] as List;
    final tempMax = dailyJson['temperature_2m_max'] as List;
    final tempMin = dailyJson['temperature_2m_min'] as List;
    final precipProb = dailyJson['precipitation_probability_max'] as List;
    final codes = dailyJson['weather_code'] as List;

    final dailyList = List.generate(times.length, (i) {
      return DailyWeather(
        date: times[i] as String,
        temperatureMax: (tempMax[i] as num).toDouble(),
        temperatureMin: (tempMin[i] as num).toDouble(),
        precipitationProbabilityMax: (precipProb[i] as num? ?? 0).toInt(),
        weatherCode: (codes[i] as num).toInt(),
      );
    });

    return WeatherData(current: currentWeather, daily: dailyList);
  }
}
