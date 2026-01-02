import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

enum PickerType { day, month, year }

class DobController extends GetxController {
  int selectedDay = 15;
  int selectedMonth = 6;
  int selectedYear = 2000;

  late FixedExtentScrollController dayController;
  late FixedExtentScrollController monthController;
  late FixedExtentScrollController yearController;

  final days = List.generate(31, (i) => i + 1);
  final months = const ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
  final years = List.generate(100, (i) => DateTime.now().year - i);
  late final List<int> listDays;
  late final List<String> listMonths;

  @override
  void onInit() {
    super.onInit();

    listDays = List.generate(124, (i) => days[i % days.length]);
    listMonths = List.generate(108, (i) => months[i % months.length]);

    // Start from middle for smooth infinite feel
    dayController = FixedExtentScrollController(initialItem: 50 + days.indexOf(selectedDay));

    monthController = FixedExtentScrollController(initialItem: 50 + (selectedMonth - 1));
    // dayController = FixedExtentScrollController(initialItem: days.indexOf(selectedDay));
    //
    // monthController = FixedExtentScrollController(initialItem: selectedMonth - 1);

    yearController = FixedExtentScrollController(initialItem: years.indexOf(selectedYear));
  }

  @override
  void onClose() {
    dayController.dispose();
    monthController.dispose();
    yearController.dispose();
    super.onClose();
  }
}
