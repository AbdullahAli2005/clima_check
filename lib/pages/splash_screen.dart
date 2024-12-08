import 'package:clima_check/pages/weather_screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToWeatherScreen();
  }

  Future<void> _navigateToWeatherScreen() async {
    await Future.delayed(
        const Duration(seconds: 3)); // Adjust duration as needed
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const WeatherScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Image.asset(
          'assets/images/neon.jpg', // Your splash image path
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

// Container(
//         height: MediaQuery.of(context).size.height,
//         width: MediaQuery.of(context).size.width,
//         child: Image.asset(
//           'assets/images/neon.jpg', // Your splash image path
//           fit: BoxFit.cover,
//         ),
// ),
