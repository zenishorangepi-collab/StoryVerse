import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:utsav_interview/core/common_string.dart';

class VoiceController extends GetxController {
  String? selectedLang;
  String? selectedFlag;
  String selectedShortBy = "";
  String selectedAge = "";
  String selectedGender = "";
  List<String> listSelectedBestFor = []; // multiple allowed

  final listBestForItems = [CS.vNarrativeStory, CS.vConversational, CS.vCharactersAnimation, CS.vInformativeEducational, CS.vEntertainmentTV];
}
