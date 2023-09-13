import 'package:dart_suncalc/suncalc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multitool/flutter_multitool.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MaterialApp(
    restorationScopeId: 'app',
    home: MainApp(),
  ));
}

class MainApp extends StatefulWidget {
  const MainApp({
    super.key,
  });

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with RestorationMixin {
  @override
  String? get restorationId => 'dsd455';

  DateTime? moonrise;
  DateTime? moonset;

  double? lat;
  double? lng;

  @override
  void initState() {
    initializeDateFormatting('ru');
    super.initState();
  }

  final RestorableDateTime _selectedDate = RestorableDateTime(DateTime.now());

  void _calculate() {
    if (lat != null && lng != null) {
      final moonTimes = SunCalc.getMoonTimes(
        _selectedDate.value,
        lat: lat!,
        lng: lng!,
      );

      moonrise = moonTimes.riseDateTime?.toLocal();
      moonset = moonTimes.setDateTime?.toLocal();

      setState(() {});
    }
  }

  late final RestorableRouteFuture<DateTime?> _restorableDatePickerRouteFuture =
      RestorableRouteFuture<DateTime?>(
    onComplete: _selectDate,
    onPresent: (NavigatorState navigator, Object? arguments) {
      return navigator.restorablePush(
        _datePickerRoute,
        arguments: _selectedDate.value.millisecondsSinceEpoch,
      );
    },
  );

  @pragma('vm:entry-point')
  static Route<DateTime> _datePickerRoute(
    BuildContext context,
    Object? arguments,
  ) {
    return DialogRoute<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return DatePickerDialog(
          restorationId: 'date_picker_dialog',
          initialEntryMode: DatePickerEntryMode.calendarOnly,
          initialDate: DateTime.fromMillisecondsSinceEpoch(arguments! as int),
          firstDate: DateTime(2015),
          lastDate: DateTime(2030),
        );
      },
    );
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_selectedDate, 'selected_date');
    registerForRestoration(
        _restorableDatePickerRouteFuture, 'date_picker_route_future');
  }

  void _selectDate(DateTime? newSelectedDate) {
    if (newSelectedDate != null) {
      setState(() {
        _selectedDate.value = newSelectedDate;

        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        //   content: Text(
        //       'Selected: ${_selectedDate.value.day}/${_selectedDate.value.month}/${_selectedDate.value.year}'),
        // ));
      });

      _calculate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Укажите дату:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Container(
                decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(20)),
                width: 400,
                child: OutlinedButton(
                  style: const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.white)),
                  onPressed: () {
                    _restorableDatePickerRouteFuture.present();
                  },
                  child:
                      Text(DateFormat.yMMMMd('ru').format(_selectedDate.value)),
                ).paddingAll(20),
              ),
              const Text(
                'Укажите координаты:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ).paddingOnly(bottom: 20),
              Container(
                decoration: BoxDecoration(
                    color: Colors.greenAccent.shade100,
                    borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text('Latitude: '),
                        TextField(
                          inputFormatters: [
                            DecimalTextInputFormatter(decimalRange: 6)
                          ],
                          onChanged: (value) {
                            lat = double.parse(value);
                            _calculate();
                          },
                        ).expanded(),
                      ],
                    ),
                    Row(
                      children: [
                        const Text('Longtude: '),
                        TextField(
                          inputFormatters: [
                            DecimalTextInputFormatter(decimalRange: 6)
                          ],
                          onChanged: (value) {
                            lng = double.parse(value);
                            _calculate();
                          },
                        ).expanded(),
                      ],
                    ),
                  ],
                ).paddingAll(20),
              ),
              const Text(
                'Результат:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ).paddingAll(20),
              Container(
                decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text('Время восхода Луны: ').expanded(),
                        Text(
                          moonrise.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    Row(
                      children: [
                        const Text('Время заката Луны: ').expanded(),
                        Text(
                          moonset.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ).paddingAll(20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
