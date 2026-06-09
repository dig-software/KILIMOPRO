import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey = "53d2d8238d042120fd4a2ee2d6836daa"; // replace with your OpenWeatherMap key

  Future<Map<String, dynamic>> fetchWeather(String city) async {
    final url = Uri.parse(
      "https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric"
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to load weather data");
    }
  }
}
