import 'package:get/get.dart';
import 'package:utsav_interview/app/home_screen/models/novel_model.dart';

class BookDetailsController extends GetxController {
  NovelsDataModel novelData = Get.arguments;
  String audioDuration = "";

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    novelData = Get.arguments;
    audioDuration = secondsToMinSec(novelData.totalAudioLength ?? 0.0);
  }
}

String secondsToMinSec(double seconds) {
  final int totalSeconds = seconds.floor();

  final int minutes = totalSeconds ~/ 60;
  final int remainingSeconds = totalSeconds % 60;

  return '${minutes}m ${remainingSeconds}s';
}
