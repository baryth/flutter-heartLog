import 'package:flutter/widgets.dart';

abstract class AppStrings {
  static late AppStrings _instance;
  static AppStrings get instance => _instance;

  static void init() {
    final lang =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    _instance = lang == 'pl' ? _PolishStrings() : _EnglishStrings();
  }

  String get appTitle;
  String get appSubtitle;
  String get setSystolic;
  String get setDiastolic;
  String get setPulse;
  String get dragToAdjust;
  String get allValuesSet;
  String get confirmSystolic;
  String get confirmDiastolic;
  String get confirmPulse;
  String get add;
  String get measurementSaved;
  String get recent;
  String get records;
  String get noMeasurements;
  String get addFirstReading;
  String get historyTooltip;
  String get historyTitle;
  String get swipeHint;
  String get editMeasurement;
  String get systolic;
  String get diastolic;
  String get pulse;
  String get cancel;
  String get save;
  String get metricsTitle;
  String get periodWeek;
  String get periodMonth;
  String get periodYear;
  String get periodAll;
  String get average;
  String get noData;
  String get metricsTooltip;
}

class _EnglishStrings extends AppStrings {
  @override String get appTitle => 'HeartLog';
  @override String get appSubtitle => 'Track your measurements';
  @override String get setSystolic => 'Set systolic';
  @override String get setDiastolic => 'Set diastolic';
  @override String get setPulse => 'Set pulse';
  @override String get dragToAdjust => 'tap & drag value to adjust';
  @override String get allValuesSet => 'All values set  —  tap Add to save';
  @override String get confirmSystolic => 'Confirm systolic';
  @override String get confirmDiastolic => 'Confirm diastolic';
  @override String get confirmPulse => 'Confirm pulse';
  @override String get add => 'Add';
  @override String get measurementSaved => 'Measurement saved';
  @override String get recent => 'Recent';
  @override String get records => 'records';
  @override String get noMeasurements => 'No measurements yet';
  @override String get addFirstReading => 'Add your first reading above';
  @override String get historyTooltip => 'History';
  @override String get historyTitle => 'History';
  @override String get swipeHint => 'Swipe left to delete · tap to edit';
  @override String get editMeasurement => 'Edit Measurement';
  @override String get systolic => 'Systolic';
  @override String get diastolic => 'Diastolic';
  @override String get pulse => 'Pulse';
  @override String get cancel => 'Cancel';
  @override String get save => 'Save';
  @override String get metricsTitle => 'Metrics';
  @override String get metricsTooltip => 'Metrics';
  @override String get periodWeek => 'Week';
  @override String get periodMonth => 'Month';
  @override String get periodYear => 'Year';
  @override String get periodAll => 'All';
  @override String get average => 'AVERAGE';
  @override String get noData => 'No data for this period';
}

class _PolishStrings extends AppStrings {
  @override String get appTitle => 'HeartLog';
  @override String get appSubtitle => 'Śledź swoje pomiary';
  @override String get setSystolic => 'Ustaw skurczowe';
  @override String get setDiastolic => 'Ustaw rozkurczowe';
  @override String get setPulse => 'Ustaw puls';
  @override String get dragToAdjust => 'naciśnij i przeciągnij wartość';
  @override String get allValuesSet => 'Wszystkie ustawione  —  naciśnij Dodaj';
  @override String get confirmSystolic => 'Potwierdź skurczowe';
  @override String get confirmDiastolic => 'Potwierdź rozkurczowe';
  @override String get confirmPulse => 'Potwierdź puls';
  @override String get add => 'Dodaj';
  @override String get measurementSaved => 'Pomiar zapisany';
  @override String get recent => 'Ostatnie';
  @override String get records => 'pomiary';
  @override String get noMeasurements => 'Brak pomiarów';
  @override String get addFirstReading => 'Dodaj swój pierwszy pomiar powyżej';
  @override String get historyTooltip => 'Historia';
  @override String get historyTitle => 'Historia';
  @override String get swipeHint => 'Przesuń w lewo, aby usunąć · dotknij, aby edytować';
  @override String get editMeasurement => 'Edytuj pomiar';
  @override String get systolic => 'Skurczowe';
  @override String get diastolic => 'Rozkurczowe';
  @override String get pulse => 'Puls';
  @override String get cancel => 'Anuluj';
  @override String get save => 'Zapisz';
  @override String get metricsTitle => 'Metryki';
  @override String get metricsTooltip => 'Metryki';
  @override String get periodWeek => 'Tydzień';
  @override String get periodMonth => 'Miesiąc';
  @override String get periodYear => 'Rok';
  @override String get periodAll => 'Wszystkie';
  @override String get average => 'ŚREDNIA';
  @override String get noData => 'Brak danych w tym okresie';
}
