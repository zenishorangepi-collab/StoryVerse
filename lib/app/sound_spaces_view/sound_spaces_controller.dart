import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class SoundSpacesController extends GetxController {
  List listChipName = ["All", "Focus", "Sleep", "Story", "Nature", "Ambience"];
  double sliderPosition = 0;
  int selectedTile = 0;
  LinearGradient myGradient = LinearGradient(colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)], begin: Alignment.topLeft, end: Alignment.bottomRight);
}
