import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

class ReferController extends GetxController {
  final String referralLink = "https://yourapp.com/referral?code=ABCDE123";

  void shareReferLink() async {
    await Share.share(referralLink);
  }
}
