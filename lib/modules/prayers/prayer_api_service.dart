import 'dart:convert';
import 'package:http/http.dart' as http;

class PrayerApiService {
  final String _city = 'Tlemcen';
  final String _country = 'Algeria';
  final int _method = 19; // Algerian Ministry of Religious Affairs

  Future<Map<String, String>> fetchTodayTimings() async {
    final url =
        'https://api.aladhan.com/v1/timingsByCity?city=$_city&country=$_country&method=$_method';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final timings = Map<String, String>.from(data['data']['timings']);

        return {
          'Fajr': timings['Fajr'] ?? '',
          'Dhuhr': timings['Dhuhr'] ?? '',
          'Asr': timings['Asr'] ?? '',
          'Maghrib': timings['Maghrib'] ?? '',
          'Isha': timings['Isha'] ?? '',
        };
      } else {
        throw Exception('Failed to load prayer timings');
      }
    } catch (e) {
      // In case of error (offline), just return generic empty times.
      return {
        'Fajr': '--:--',
        'Dhuhr': '--:--',
        'Asr': '--:--',
        'Maghrib': '--:--',
        'Isha': '--:--',
      };
    }
  }
}
