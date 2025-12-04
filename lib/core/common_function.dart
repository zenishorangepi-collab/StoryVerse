import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:utsav_interview/core/common_style.dart';

extension CommonPaddingHorizontal on Widget {
  Widget screenPadding() {
    return paddingOnly(left: 16, right: 16);
  }

  Widget commonHeadingText(String text) {
    return Text(text, style: AppTextStyles.heading4);
  }
}
