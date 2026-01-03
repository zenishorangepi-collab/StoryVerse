import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'package:utsav_interview/core/common_function.dart';
import 'package:http/http.dart' as http;
import 'package:utsav_interview/core/common_string.dart';

class ShareService {
  /// Share app WITH current book details
  static Future<void> shareAppWithBook({
    required String bookName,
    required String authorName,
    String? bookCoverUrl,
    String? summary,
    String? deepLink,
    BuildContext? context,
  }) async {
    try {
      String appStoreLink = 'https://apps.apple.com/app/your-app-id';
      String playStoreLink = 'https://play.google.com/store/apps/details?id=com.yourapp';

      // Build text with both app info AND book details
      String shareText = '''
${CS.vAppName}:\n"$bookName"\n by $authorName

Download the app:
 ${Platform.isIOS ? appStoreLink : playStoreLink}
''';

      // Share with book cover if available
      if (bookCoverUrl != null && bookCoverUrl.isNotEmpty) {
        await _shareWithImage(text: shareText, imageUrl: bookCoverUrl, context: context);
      } else {
        await Share.share(shareText, subject: 'Check out "$bookName" on this audiobook app!');
      }
    } catch (e) {
      debugPrint('❌ Error sharing app with book: $e');
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to share: $e')));
      }
    }
  }

  /// Share app only (without book details)
  static Future<void> shareApp({BuildContext? context}) async {
    try {
      String appStoreLink = 'https://apps.apple.com/app/your-app-id'; // Replace with your actual link
      String playStoreLink = 'https://play.google.com/store/apps/details?id=com.yourapp'; // Replace with your actual link

      String shareText = '''
🎧 Discover amazing audiobooks with our app!

📚 Thousands of books to listen to
🎵 High-quality audio
📖 Sync text with audio playback
⚡ Download for offline listening

Download now:
iOS: $appStoreLink
Android: $playStoreLink
''';

      await Share.share(shareText, subject: 'Check out this amazing audiobook app!');
    } catch (e) {
      debugPrint('❌ Error sharing app: $e');
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to share: $e')));
      }
    }
  }

  /// Share with image (local or network)
  static Future<void> _shareWithImage({required String text, required String imageUrl, BuildContext? context}) async {
    try {
      if (!isLocalFile(imageUrl)) {
        // Download image temporarily for sharing
        final response = await http.get(Uri.parse(imageUrl));

        if (response.statusCode == 200) {
          final tempDir = await getTemporaryDirectory();
          final file = File('${tempDir.path}/share_image.jpg');
          await file.writeAsBytes(response.bodyBytes);

          await Share.shareXFiles([XFile(file.path)], text: text);
        } else {
          // Fallback to text-only if download fails
          await Share.share(text);
        }
      } else {
        // Local file
        final file = File(imageUrl);
        if (await file.exists()) {
          await Share.shareXFiles([XFile(file.path)], text: text);
        } else {
          await Share.share(text);
        }
      }
    } catch (e) {
      debugPrint('❌ Error sharing with image: $e');
      // Fallback to text-only
      await Share.share(text);
    }
  }
}

//   /// Share book/novel details with text and image
//   static Future<void> shareBook({
//     required String bookName,
//     required String authorName,
//     String? bookCoverUrl,
//     String? summary,
//     String? deepLink,
//     BuildContext? context,
//     bool includeAppLinks = true,
//   }) async {
//     try {
//       // Create share text
//       String shareText = _buildShareText(
//         bookName: bookName,
//         authorName: authorName,
//         summary: summary,
//         deepLink: deepLink,
//         includeAppLinks: includeAppLinks,
//       );
//
//       // If book cover is available, share with image
//       if (bookCoverUrl != null && bookCoverUrl.isNotEmpty) {
//         await _shareWithImage(
//           text: shareText,
//           imageUrl: bookCoverUrl,
//           context: context,
//         );
//       } else {
//         // Share text only
//         await Share.share(
//           shareText,
//           subject: 'Check out "$bookName" by $authorName',
//         );
//       }
//     } catch (e) {
//       debugPrint('❌ Error sharing book: $e');
//       if (context != null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to share: $e')),
//         );
//       }
//     }
//   }
//
//   /// Share book with custom image/template (for social media)
//   static Future<void> shareBookWithCustomImage({
//     required String bookName,
//     required String authorName,
//     required String bookCoverUrl,
//     String? summary,
//     String? deepLink,
//     BuildContext? context,
//   }) async {
//     try {
//       // Generate custom share image with app branding
//       final customImagePath = await _generateCustomShareImage(
//         bookName: bookName,
//         authorName: authorName,
//         bookCoverUrl: bookCoverUrl,
//         summary: summary,
//       );
//
//       String shareText = _buildShareText(
//         bookName: bookName,
//         authorName: authorName,
//         summary: summary,
//         deepLink: deepLink,
//         includeAppLinks: true,
//       );
//
//       if (customImagePath != null) {
//         await Share.shareXFiles(
//           [XFile(customImagePath)],
//           text: shareText,
//         );
//       } else {
//         // Fallback to regular share
//         await shareBook(
//           bookName: bookName,
//           authorName: authorName,
//           bookCoverUrl: bookCoverUrl,
//           summary: summary,
//           deepLink: deepLink,
//           context: context,
//         );
//       }
//     } catch (e) {
//       debugPrint('❌ Error sharing custom image: $e');
//       // Fallback to regular share
//       await shareBook(
//         bookName: bookName,
//         authorName: authorName,
//         bookCoverUrl: bookCoverUrl,
//         summary: summary,
//         deepLink: deepLink,
//         context: context,
//       );
//     }
//   }
//
//   /// Share current audio clip/timestamp
//   static Future<void> shareAudioClip({
//     required String bookName,
//     required String authorName,
//     required String chapterName,
//     required String timestamp,
//     String? bookCoverUrl,
//     String? deepLink,
//     BuildContext? context,
//   }) async {
//     try {
//       String shareText = '''
// 📚 Check out this moment from "$bookName"
// ✍️ By $authorName
//
// 📖 Chapter: $chapterName
// ⏱️ Timestamp: $timestamp
//
// ${deepLink ?? 'Download the app to listen!'}
// ''';
//
//       if (bookCoverUrl != null && bookCoverUrl.isNotEmpty) {
//         await _shareWithImage(
//           text: shareText,
//           imageUrl: bookCoverUrl,
//           context: context,
//         );
//       } else {
//         await Share.share(shareText);
//       }
//     } catch (e) {
//       debugPrint('❌ Error sharing audio clip: $e');
//       if (context != null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to share: $e')),
//         );
//       }
//     }
//   }
//
//   /// Build formatted share text
//   static String _buildShareText({
//     required String bookName,
//     required String authorName,
//     String? summary,
//     String? deepLink,
//     bool includeAppLinks = true,
//   }) {
//     String text = '''
// 📚 "$bookName"
// ✍️ By $authorName
// ''';
//
//     if (summary != null && summary.isNotEmpty) {
//       // Limit summary to 150 characters
//       String shortSummary = summary.length > 150
//           ? '${summary.substring(0, 150)}...'
//           : summary;
//       text += '\n📖 $shortSummary\n';
//     }
//
//     if (deepLink != null && deepLink.isNotEmpty) {
//       text += '\n🔗 Listen now: $deepLink';
//     }
//
//     if (includeAppLinks) {
//       text += '\n\n📱 Download the app:\niOS: https://apps.apple.com/app/your-app-id\nAndroid: https://play.google.com/store/apps/details?id=com.yourapp';
//     }
//
//     return text;
//   }
//
//   /// Generate custom share image with book cover and app branding
//   static Future<String?> _generateCustomShareImage({
//     required String bookName,
//     required String authorName,
//     required String bookCoverUrl,
//     String? summary,
//   }) async {
//     try {
//       final recorder = ui.PictureRecorder();
//       final canvas = Canvas(recorder);
//       final size = Size(1080, 1920); // Instagram story size
//
//       // Background gradient
//       final bgPaint = Paint()
//         ..shader = LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
//         ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
//       canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);
//
//       // Load and draw book cover
//       if (isNetworkUrl(bookCoverUrl)) {
//         final response = await http.get(Uri.parse(bookCoverUrl));
//         if (response.statusCode == 200) {
//           final codec = await ui.instantiateImageCodec(response.bodyBytes);
//           final frame = await codec.getNextFrame();
//           final image = frame.image;
//
//           // Draw book cover with shadow
//           final coverRect = Rect.fromCenter(
//             center: Offset(size.width / 2, size.height * 0.35),
//             width: 400,
//             height: 600,
//           );
//
//           // Shadow
//           final shadowPaint = Paint()
//             ..color = Colors.black.withOpacity(0.5)
//             ..maskFilter = MaskFilter.blur(BlurStyle.normal, 30);
//           canvas.drawRRect(
//             RRect.fromRectAndRadius(
//               coverRect.shift(Offset(0, 10)),
//               Radius.circular(12),
//             ),
//             shadowPaint,
//           );
//
//           // Book cover
//           canvas.drawImageRect(
//             image,
//             Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
//             coverRect,
//             Paint()..filterQuality = FilterQuality.high,
//           );
//         }
//       }
//
//       // Draw text
//       final titlePainter = TextPainter(
//         text: TextSpan(
//           text: bookName,
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 48,
//             fontWeight: FontWeight.bold,
//             height: 1.2,
//           ),
//         ),
//         textDirection: TextDirection.ltr,
//         maxLines: 2,
//       )..layout(maxWidth: size.width - 80);
//
//       titlePainter.paint(
//         canvas,
//         Offset(40, size.height * 0.65),
//       );
//
//       final authorPainter = TextPainter(
//         text: TextSpan(
//           text: 'by $authorName',
//           style: TextStyle(
//             color: Colors.white70,
//             fontSize: 32,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         textDirection: TextDirection.ltr,
//       )..layout(maxWidth: size.width - 80);
//
//       authorPainter.paint(
//         canvas,
//         Offset(40, size.height * 0.65 + titlePainter.height + 20),
//       );
//
//       // App logo/branding at bottom
//       final appNamePainter = TextPainter(
//         text: TextSpan(
//           text: '🎧 YourAppName',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 36,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         textDirection: TextDirection.ltr,
//       )..layout();
//
//       appNamePainter.paint(
//         canvas,
//         Offset(
//           (size.width - appNamePainter.width) / 2,
//           size.height - 150,
//         ),
//       );
//
//       final callToActionPainter = TextPainter(
//         text: TextSpan(
//           text: 'Listen Now',
//           style: TextStyle(
//             color: Color(0xFF4ECDC4),
//             fontSize: 28,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         textDirection: TextDirection.ltr,
//       )..layout();
//
//       callToActionPainter.paint(
//         canvas,
//         Offset(
//           (size.width - callToActionPainter.width) / 2,
//           size.height - 80,
//         ),
//       );
//
//       // Convert to image
//       final picture = recorder.endRecording();
//       final img = await picture.toImage(size.width.toInt(), size.height.toInt());
//       final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
//       final buffer = byteData!.buffer.asUint8List();
//
//       // Save to temp file
//       final tempDir = await getTemporaryDirectory();
//       final file = File('${tempDir.path}/share_image_${DateTime.now().millisecondsSinceEpoch}.png');
//       await file.writeAsBytes(buffer);
//
//       return file.path;
//     } catch (e) {
//       debugPrint('❌ Error generating custom image: $e');
//       return null;
//     }
//   }

/// Generate deep link for book (implement based on your app's deep linking)
//   static String generateDeepLink({
//     required String bookId,
//     int? chapterIndex,
//     int? timestamp,
//   }) {
//     // Example deep link format
//     String baseUrl = 'https://yourapp.com/book';
//     String link = '$baseUrl/$bookId';
//
//     if (chapterIndex != null) {
//       link += '?chapter=$chapterIndex';
//     }
//
//     if (timestamp != null) {
//       link += '${chapterIndex != null ? '&' : '?'}time=$timestamp';
//     }
//
//     return link;
//   }
// }

// ============================================================
// 6. PUBSPEC.YAML DEPENDENCIES
// ============================================================

/*
Add to pubspec.yaml:

dependencies:
  share_plus: ^7.2.2
  http: ^1.1.0
  path_provider: ^2.1.1

Then run: flutter pub get
*/

// ============================================================
// 7. EXAMPLE OUTPUTS
// ============================================================

/*
📱 SHARE APP (WITHOUT BOOK):
────────────────────────────
🎧 Discover amazing audiobooks with our app!

📚 Thousands of books to listen to
🎵 High-quality audio
📖 Sync text with audio playback
⚡ Download for offline listening

Download now:
iOS: https://apps.apple.com/app/your-app-id
Android: https://play.google.com/store/apps/details?id=com.yourapp


📚 SHARE BOOK (WITH DETAILS):
─────────────────────────────
📚 "The Great Adventure"
✍️ By John Doe

📖 An epic tale of courage and discovery...

🔗 Listen now: https://yourapp.com/book/123

📱 Download the app:
iOS: https://apps.apple.com/app/your-app-id
Android: https://play.google.com/store/apps/details?id=com.yourapp


🎨 SHARE AS STORY:
──────────────────
Generates a beautiful 1080x1920 image with:
- Book cover centered
- Gradient background with your brand colors
- Book title and author name
- App logo and "Listen Now" call-to-action
Perfect for Instagram Stories, Facebook Stories, etc.


🎵 SHARE CURRENT CLIP:
──────────────────────
📚 Check out this moment from "The Great Adventure"
✍️ By John Doe

📖 Chapter: Chapter 5
⏱️ Timestamp: 15:42

🔗 https://yourapp.com/book/123?chapter=4&time=942000
*/

// ============================================================
// 8. ANDROID MANIFEST SETUP (android/app/src/main/AndroidManifest.xml)
// ============================================================

/*
Add inside <application> tag:

<provider
    android:name="androidx.core.content.FileProvider"
    android:authorities="${applicationId}.fileprovider"
    android:exported="false"
    android:grantUriPermissions="true">
    <meta-data
        android:name="android.support.FILE_PROVIDER_PATHS"
        android:resource="@xml/file_paths" />
</provider>

Then create: android/app/src/main/res/xml/file_paths.xml

<?xml version="1.0" encoding="utf-8"?>
<paths>
    <cache-path name="cache" path="." />
    <external-cache-path name="external_cache" path="." />
</paths>
*/

// ============================================================
// 9. iOS INFO.PLIST SETUP (ios/Runner/Info.plist)
// ============================================================

/*
Add these keys:

<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to share book covers</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>Save share images to your photo library</string>
*/

// ============================================================
// 10. USAGE SUMMARY
// ============================================================

/*
AVAILABLE SHARE OPTIONS:
═══════════════════════════════════════════════════════════

1. 📚 Share Book (with details & cover image)
   - Full book information
   - Book cover image
   - Summary
   - Deep link to book
   - App download links

2. 🎨 Share as Story (custom branded image)
   - Beautiful social media image (1080x1920)
   - Book cover with gradient background
   - Book title and author
   - App branding
   - Perfect for Instagram/Facebook stories

3. 🎵 Share Current Clip (current timestamp)
   - Chapter name
   - Current timestamp
   - Deep link to exact position
   - Book cover image

4. 📱 Share App (no book details)
   - App description
   - Features list
   - iOS and Android store links
   - No specific book information

5. 🔖 Share Bookmark (specific moment)
   - Bookmark text
   - Chapter and timestamp
   - Personal notes
   - Deep link to bookmark

QUICK ACTIONS:
═══════════════════════════════════════════════════════════
✓ Copy Link - Copy deep link to clipboard
✓ Message - Share via messaging apps
✓ Email - Share via email
✓ Stories - Share as social media story
✓ More - System share sheet
*/
