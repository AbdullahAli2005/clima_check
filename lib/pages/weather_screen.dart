import 'dart:convert';
import 'package:clima_check/secrets.dart';
import 'package:clima_check/widgets/weather_messages.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:weather_icons/weather_icons.dart';

import '../widgets/additional_info_item.dart';
import '../widgets/hourly_forecast_item.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String, dynamic>> weather;
  String cityName = 'London'; // Default city name
  late ScrollController _scrollController;
  bool isTemperatureVisible = false;
  String currentTemperature = '';

  final TextEditingController _cityController = TextEditingController();
  String _bgImg = 'assets/images/clouds.jpg'; // Default background image path

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    weather = getCurrentWeather();
  }

  void _scrollListener() {
    // Check if the scroll offset is past a certain point, like 150.0 pixels
    if (_scrollController.offset > 280.0 && !isTemperatureVisible) {
      setState(() {
        isTemperatureVisible = true;
      });
    } else if (_scrollController.offset <= 150.0 && isTemperatureVisible) {
      setState(() {
        isTemperatureVisible = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> getCurrentWeather([String? searchCity]) async {
    try {
      String city = searchCity ?? cityName;
      String url =
          'https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$openWeatherAPIKey';

      final result = await http.get(Uri.parse(url));
      final data = jsonDecode(result.body);

      if (data['cod'] != "200") {
        throw 'An unexpected error occurred';
      }

      // Set background image based on weather condition
      final mainWeatherCondition = data['list'][0]['weather'][0]['main'];
      final currentTempInCelsius = data['list'][0]['main']['temp'] - 273.15;

      setState(() {
        // Store the fetched temperature
        currentTemperature = currentTempInCelsius
            .toStringAsFixed(1); // Set the temperature for the AppBar
      });

      setState(() {
        if (currentTempInCelsius < 0) {
          // If temperature is below 0°C, set the background to snow
          _bgImg = 'assets/images/snow.jpg';
        } else if (mainWeatherCondition == 'Clear') {
          _bgImg = 'assets/images/clear.jpg';
        } else if (mainWeatherCondition == 'Clouds') {
          _bgImg = 'assets/images/clouds.jpg';
        } else if (mainWeatherCondition == 'Drizzle') {
          _bgImg = 'assets/images/rain.jpg';
        } else if (mainWeatherCondition == 'Rain') {
          _bgImg = 'assets/images/rain.jpg';
        } else if (mainWeatherCondition == 'Fog') {
          _bgImg = 'assets/images/fog.jpg';
        } else if (mainWeatherCondition == 'Snow') {
          _bgImg = 'assets/images/snow.jpg';
        } else if (mainWeatherCondition == 'Thunderstorm') {
          _bgImg = 'assets/images/thunderstorm.jpg';
        } else if (mainWeatherCondition == 'Tornado') {
          _bgImg = 'assets/images/thunderstorm.jpg';
        } else {
          _bgImg = 'assets/images/haze.jpg';
        }
      });

      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            // Background Image
            Image.asset(
              _bgImg,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            // Custom Header Container to replace AppBar
            headerWidget(),
            // Main content of the screen
            Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.1,
                ),
                searchField(),
                Expanded(
                  child: FutureBuilder(
                    future: weather,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator
                              .adaptive(), // Progress indicator
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text(snapshot.error.toString()),
                        );
                      }

                      final data = snapshot.data!;

                      final currentWeatherData = data['list'][0];
                      // Convert temperature to Celsius
                      final currentTemp =
                          (currentWeatherData['main']['temp'] - 273.15)
                              .toStringAsFixed(1);
                      final feelsLike =
                          (currentWeatherData['main']['feels_like'] - 273.15)
                              .toStringAsFixed(1);
                      final currentSky =
                          currentWeatherData['weather'][0]['main'];
                      final currentPressure =
                          currentWeatherData['main']['pressure'];
                      // Convert wind speed to km/h
                      final currentWindSpeed =
                          (currentWeatherData['wind']['speed'] * 3.6)
                              .toStringAsFixed(1);
                      final currentHumidity =
                          currentWeatherData['main']['humidity'];
                      final precipitation = currentWeatherData
                              .containsKey('rain')
                          ? currentWeatherData['rain']['3h'].toString()
                          : "0.0"; // Default to 0 mm if no rain data is available

                      return SingleChildScrollView(
                        controller: _scrollController,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.26,
                              ),
                              // MAIN CARD
                              Container(
                                color: Colors.transparent,
                                width: double.infinity,
                                child: Card(
                                  elevation: 10,
                                  color: Colors.white.withOpacity(
                                      0.2), // Semi-transparent background color
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      children: [
                                        Text(
                                          "$currentTemp °C",
                                          style: const TextStyle(
                                            fontSize: 64,
                                            fontWeight: FontWeight.bold,
                                            color: Colors
                                                .white, // White text color for better contrast
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          currentSky,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors
                                                .white, // White text color
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          "Feels like $feelsLike °C",
                                          style: const TextStyle(
                                            fontSize: 18,
                                            color: Colors
                                                .white, // White text color
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),
                              const Text(
                                'Hourly Forecast',
                                style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              const SizedBox(height: 26),
                              SizedBox(
                                height: 120,
                                child: ListView.builder(
                                  itemCount: 5,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) {
                                    final hourlyForecast =
                                        data['list'][index + 1];
                                    final hourlySky = data['list'][index + 1]
                                        ['weather'][0]['main'];
                                    final hourlyTemp = (hourlyForecast['main']
                                                ['temp'] -
                                            273.15)
                                        .toStringAsFixed(1);
                                    final time = DateTime.parse(
                                        hourlyForecast['dt_txt']);
                                    return HourlyForecastItem(
                                      time: DateFormat.j().format(time),
                                      temperature: "$hourlyTemp °C",
                                      icon: hourlySky == 'Clouds' ||
                                              hourlySky == 'Rain'
                                          ? Icons.cloud
                                          : Icons.sunny,
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Additional Info',
                                style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              const SizedBox(height: 16),
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.32,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.45,
                                        child: AdditionalInfoItem(
                                          icon: WeatherIcons.rain,
                                          label: 'Precipitation',
                                          value1: precipitation.toString(),
                                          value2: "mm",
                                          message: getWeatherMessage(
                                            precipitation: double.tryParse(
                                                    precipitation.toString()) ??
                                                0.0, // Safe conversion
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.32,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.45,
                                        child: AdditionalInfoItem(
                                          icon: Icons.water_drop,
                                          label: 'Humidity',
                                          value1: "$currentHumidity%",
                                          value2: "",
                                          message: getWeatherMessage(
                                            humidity: double.tryParse(
                                                    currentHumidity
                                                        .toString()) ??
                                                0.0, // Safe conversion
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.32,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.45,
                                        child: AdditionalInfoItem(
                                          icon: Icons.air,
                                          label: 'Wind Speed',
                                          value1: currentWindSpeed.toString(),
                                          value2: "km/h",
                                          message: getWeatherMessage(
                                            windSpeed: double.tryParse(
                                                    currentWindSpeed
                                                        .toString()) ??
                                                0.0, // Safe conversion
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.32,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.45,
                                        child: AdditionalInfoItem(
                                          icon: Icons.compress,
                                          label: 'Pressure',
                                          value1: currentPressure.toString(),
                                          value2: "hPa",
                                          message: getWeatherMessage(
                                            pressure: double.tryParse(
                                                    currentPressure
                                                        .toString()) ??
                                                0.0, // Safe conversion
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Padding searchField() {
    return Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _cityController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.black26,
                    hintText: 'Enter City Name',
                    hintStyle: const TextStyle(color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          // Update the cityName and fetch the new weather data
                          cityName = _cityController.text;
                          weather = getCurrentWeather(cityName);
                        });
                      },
                    ),
                  ),
                ),
              );
  }

  Positioned headerWidget() {
    return Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.black
                    .withOpacity(0.1), // Semi-transparent background
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Title Text
                  Row(
                    children: [
                      Text(
                        cityName.toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Colors.white, 
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (isTemperatureVisible)
                        Text(
                          currentTemperature.isNotEmpty
                              ? "$currentTemperature °C"
                              : "", // Display temperature if available
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                  // Refresh Icon
                  IconButton(
                    onPressed: () {
                      setState(() {
                        weather = getCurrentWeather();
                      });
                    },
                    icon: const Icon(Icons.refresh,
                        color: Colors.white), // Icon color to white
                  ),
                ],
              ),
            ),
          );
  }
}
