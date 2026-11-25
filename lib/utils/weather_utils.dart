class WeatherUtils {
  /// WMO Weather interpretation codes
  static String getWeatherDescription(int code) {
    if (code == 0) return 'Langit Cerah';
    if (code == 1) return 'Sebagian Cerah';
    if (code == 2) return 'Sebagian Berawan';
    if (code == 3) return 'Mendung';
    if (code >= 45 && code <= 48) return 'Kabut';
    if (code >= 51 && code <= 55) return 'Gerimis';
    if (code >= 56 && code <= 57) return 'Gerimis Beku';
    if (code >= 61 && code <= 65) return 'Hujan';
    if (code >= 66 && code <= 67) return 'Hujan Beku';
    if (code >= 71 && code <= 77) return 'Salju';
    if (code >= 80 && code <= 82) return 'Hujan Lebat';
    if (code == 85 || code == 86) return 'Salju Lebat';
    if (code >= 95 && code <= 99) return 'Badai Petir';
    return 'Tidak Diketahui';
  }

  static String getWeatherIcon(int code) {
    if (code == 0) return '☀️';
    if (code == 1) return '🌤️';
    if (code == 2) return '⛅';
    if (code == 3) return '☁️';
    if (code >= 45 && code <= 48) return '🌫️';
    if (code >= 51 && code <= 57) return '🌦️';
    if (code >= 61 && code <= 67) return '🌧️';
    if (code >= 71 && code <= 77) return '❄️';
    if (code >= 80 && code <= 82) return '🌧️';
    if (code == 85 || code == 86) return '❄️';
    if (code >= 95 && code <= 99) return '⛈️';
    return '🌡️';
  }

  static String formatDayName(String dateStr) {
    final date = DateTime.parse(dateStr);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = target.difference(today).inDays;
    if (diff == 0) return 'Hari Ini';
    if (diff == 1) return 'Besok';
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    return days[date.weekday - 1];
  }
}
