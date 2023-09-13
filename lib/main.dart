import 'package:dart_suncalc/suncalc.dart';
import 'package:flutter/material.dart';

void main() {
  final now = DateTime.now();

  // Расчет времени восхода и заката Луны для текущей даты и местоположения
  final moonTimes = SunCalc.getMoonTimes(
    now,
    lat: 58.6,
    lng: 49.67,
  );

  final moonrise = moonTimes.riseDateTime?.toLocal();
  final moonset = moonTimes.setDateTime?.toLocal();

  print('Время восхода Луны: $moonrise');
  print('Время заката Луны: $moonset');

  runApp(MainApp(
    moonrise: moonrise,
    moonset: moonset,
  ));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key, required this.moonrise, required this.moonset});

  final DateTime? moonrise;
  final DateTime? moonset;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Время восхода Луны: $moonrise'),
              const SizedBox(
                height: 50,
              ),
              Text('Время заката Луны: $moonset'),
            ],
          ),
        ),
      ),
    );
  }
}
