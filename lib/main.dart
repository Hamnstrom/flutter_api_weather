import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

Future<dynamic> fetchWeatherData() async {
  final url =
      'https://api.tomorrow.io/v4/weather/forecast?location=60.17117,24.94090&apikey=cG09i2BcEEcq17sAY1MbagbRLfUwQhl2';
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load weather data');
  }
}

void main() {
  runApp(WeatherApp());
}

class WeatherApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather Statistics',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: WeatherScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WeatherScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Current Weather'), centerTitle: true),
      body: FutureBuilder<dynamic>(
        future: fetchWeatherData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            // Parse the relevant data
            final data = snapshot.data as Map<String, dynamic>;

            // Navigate to the minutely timeline
            final timelines = data['timelines'];
            final minutelyList = timelines['minutely'] as List<dynamic>;

            if (minutelyList.isEmpty) {
              return Center(child: Text('No weather data available.'));
            }

            final latestData = minutelyList[0]['values'] as Map<String, dynamic>;

            // Extract values
            final temperature = latestData['temperature'] ?? 0.0;
            final feelsLikeTemperature = latestData['temperatureApparent'] ?? 0.0;
            final humidity = latestData['humidity'] ?? 0;
            final windSpeed = latestData['windSpeed'] ?? 0.0;
            final weatherCode = latestData['weatherCode'];
 
            // Get an icon based on temperature
            IconData getWeatherIcon(double temp) {
              if (temp > 15) {
                return Icons.wb_sunny; // Sunny
              } else if (temp < 0) {
                return Icons.ac_unit; // Snowing
              } else {
                return Icons.cloud; // Cloudy
              }
            }

            // For simplicity, map weatherCode to condition
            String weatherCondition = 'Unknown';
            if (weatherCode != null) {
              switch (weatherCode) {
                case 1100:
                  weatherCondition = 'Clear';
                  break;
                // Add more cases as needed
                default:
                  weatherCondition = 'Weather';
              }
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Location
                  Text("Helsinki", style: Theme.of(context).textTheme.headlineSmall),
                  SizedBox(height: 8),
                  // Weather Icon and Condition
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(getWeatherIcon(temperature), size: 64),
                      SizedBox(width: 16),
                      Text(
                        weatherCondition,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  // Temperature
                  Text(
                    '${temperature.toStringAsFixed(1)}°C',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  SizedBox(height: 8),
                  // Feels Like (not in your JSON, so omit or add static)
                  // For now, just show temperature as 'feels like'
                  Text(
                    'Feels like ${feelsLikeTemperature.toStringAsFixed(1)}°C',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 24),
                  // Additional Weather Details
                  Expanded(
                    child: ListView(
                      children: [
                        ListTile(
                          leading: Icon(Icons.water_drop),
                          title: Text('Humidity'),
                          trailing: Text('$humidity %'),
                        ),
                        ListTile(
                          leading: Icon(Icons.air),
                          title: Text('Wind Speed'),
                          trailing: Text('$windSpeed m/s'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Center(child: Text('No data'));
          }
        },
      ),
    );
  }
}