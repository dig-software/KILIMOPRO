import 'package:flutter/material.dart';
import '../services/weather_service.dart';

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherService _weatherService = WeatherService();
  Map<String, dynamic>? _weatherData;
  String _advice = "";

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  void _loadWeather() async {
    try {
      final data = await _weatherService.fetchWeather("Nairobi"); // hardcoded for now
      setState(() {
        _weatherData = data;
        _advice = _generateAdvice(data);
      });
    } catch (e) {
      setState(() {
        _advice = "Error loading weather data. Check your connection.";
      });
    }
  }

  String _generateAdvice(Map<String, dynamic> data) {
    final temp = data['main']['temp'];
    final humidity = data['main']['humidity'];
    String advice = "";

    if (temp > 30) {
      advice += "High heat expected. Increase water supply and ventilation.\n";
    } else if (temp < 18) {
      advice += "Cold conditions. Keep housing warm to prevent respiratory issues.\n";
    }

    if (humidity > 80) {
      advice += "High humidity. Keep litter dry to avoid coccidiosis.\n";
    }

    // Example vaccination reminder (static for now)
    advice += "Next Vaccination: Newcastle – due in 2 weeks.";

    return advice;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Weather & Farm Advisory")),
      body: _weatherData == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Temp: ${_weatherData!['main']['temp']}°C",
                    style: TextStyle(fontSize: 22),
                  ),
                  Text(
                    "Condition: ${_weatherData!['weather'][0]['description']}",
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(height: 20),
                  Text(
                    _advice,
                    style: TextStyle(fontSize: 18, color: Colors.green),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
    );
  }
}
