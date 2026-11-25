import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/weather_viewmodel.dart';
import 'viewmodels/search_viewmodel.dart';
import 'views/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WeatherViewModel()),
        ChangeNotifierProvider(create: (_) => SearchViewModel()),
      ],
      child: MaterialApp(
        title: 'Weather App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1565C0),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
          textTheme: const TextTheme(
            displayLarge: TextStyle(fontSize: 72, fontWeight: FontWeight.w300, color: Colors.white),
            displayMedium: TextStyle(fontSize: 48, fontWeight: FontWeight.w300, color: Colors.white),
            headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w500, color: Colors.white),
            headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: Colors.white),
            titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
            titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white70),
            bodyLarge: TextStyle(fontSize: 16, color: Colors.white),
            bodyMedium: TextStyle(fontSize: 14, color: Colors.white70),
            labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
